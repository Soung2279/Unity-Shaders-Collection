using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    public enum SpriteAnimCheckSeverity
    {
        Info,
        Warning,
        Error
    }

    /// <summary>单条序列帧检查问题。Message 为通用原因，Detail 为具体上下文，AssetPath 用于定位。</summary>
    public class SpriteAnimCheckIssue
    {
        public SpriteAnimCheckSeverity Severity;
        public string CheckName;
        public string Message;
        public string Detail;
        public string PrefabPath;
        public string PrefabName;
        public string AnimationName;
        public string AssetPath;
        public string AssetName;
    }

    /// <summary>一个挂有 ActorSpriteAnimator 的预制体的检查记录，同时供列表与预览使用。</summary>
    public class SpriteAnimActorEntry
    {
        public GameObject Prefab;
        public ActorSpriteAnimator Animator;
        public string PrefabPath;
        public string PrefabName;
        public string SourceFolder;
        public string DefaultAnimation;
        public bool RendererAssigned;
        public int AnimationCount;
        public int FrameCount;
        public readonly List<string> AnimationNames = new List<string>();
        public readonly List<SpriteAnimCheckIssue> Issues = new List<SpriteAnimCheckIssue>();

        public bool HasIssue => Issues.Count > 0;
        public bool HasError => Issues.Any(issue => issue.Severity == SpriteAnimCheckSeverity.Error);
        public bool HasWarning => Issues.Any(issue => issue.Severity == SpriteAnimCheckSeverity.Warning);
    }

    public class SpriteAnimCheckReport
    {
        public DateTime CreatedAt;
        public string RootFolder = string.Empty;
        public int PrefabTotal;
        public int PrefabChecked;
        public int PrefabSkipped;
        public int AnimationCount;
        public int FrameCount;
        public int ErrorCount;
        public int WarningCount;
        public readonly List<SpriteAnimCheckIssue> Issues = new List<SpriteAnimCheckIssue>();

        public static string GetReasonKey(SpriteAnimCheckIssue issue)
        {
            return issue == null ? string.Empty : $"{issue.CheckName}|{issue.Message}";
        }

        public string ToText()
        {
            var builder = new StringBuilder();
            builder.AppendLine("序列帧动画检查报告");
            builder.AppendLine($"生成时间: {CreatedAt:yyyy-MM-dd HH:mm:ss}");
            builder.AppendLine($"扫描目录: {RootFolder}");
            builder.AppendLine($"预制体总数: {PrefabTotal}   已检查(含ActorSpriteAnimator): {PrefabChecked}   跳过: {PrefabSkipped}");
            builder.AppendLine($"动画数: {AnimationCount}   序列帧数: {FrameCount}");
            builder.AppendLine($"错误: {ErrorCount}");
            builder.AppendLine($"警告: {WarningCount}");
            builder.AppendLine();

            if (Issues.Count == 0)
            {
                builder.AppendLine("未发现序列帧动画相关问题。");
                return builder.ToString();
            }

            foreach (var group in Issues
                         .GroupBy(GetReasonKey)
                         .OrderByDescending(group => group.Any(issue => issue.Severity == SpriteAnimCheckSeverity.Error))
                         .ThenBy(group => group.First().CheckName)
                         .ThenBy(group => group.First().Message))
            {
                var first = group.First();
                builder.AppendLine($"问题原因: {first.CheckName} - {first.Message}");
                builder.AppendLine($"数量: {group.Count()}");
                foreach (var issue in group.OrderBy(issue => issue.PrefabPath, StringComparer.Ordinal).ThenBy(issue => issue.AnimationName, StringComparer.Ordinal))
                {
                    builder.AppendLine($"  [{issue.Severity}] Prefab={issue.PrefabName}; Animation={issue.AnimationName}; " +
                                       $"Detail={issue.Detail}; Asset={issue.AssetPath}");
                }

                builder.AppendLine();
            }

            return builder.ToString();
        }
    }

    /// <summary>一次扫描的完整结果。</summary>
    public class SpriteAnimCheckResult
    {
        public SpriteAnimCheckReport Report = new SpriteAnimCheckReport();
        public bool Cancelled;
        public readonly List<SpriteAnimActorEntry> Entries = new List<SpriteAnimActorEntry>();
        public readonly List<string> AnimationNames = new List<string>();

        public SpriteAnimActorEntry FindEntry(string prefabPath)
        {
            return Entries.FirstOrDefault(entry => string.Equals(entry.PrefabPath, prefabPath, StringComparison.Ordinal));
        }
    }
}
