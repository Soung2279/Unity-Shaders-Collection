using System;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    /// <summary>序列帧动画检查报告窗口：按问题原因分组显示，并支持导出文本报告。</summary>
    public class SpriteAnimAssetCheckReportWindow : EditorWindow
    {
        private SpriteAnimCheckReport _report;
        private Vector2 _issueScroll;
        private Vector2 _textScroll;
        private string _reportText;
        private GUIStyle _errorHeaderStyle;
        private GUIStyle _warningHeaderStyle;
        private GUIStyle _errorLabelStyle;
        private GUIStyle _warningLabelStyle;

        public static void ShowReport(SpriteAnimCheckReport report)
        {
            var window = GetWindow<SpriteAnimAssetCheckReportWindow>("序列帧检查报告");
            window.minSize = new Vector2(900, 600);
            window.SetReport(report);
            window.Show();
            window.Focus();
        }

        private void SetReport(SpriteAnimCheckReport report)
        {
            _report = report;
            _reportText = report?.ToText() ?? string.Empty;
        }

        private void OnGUI()
        {
            if (_report == null)
            {
                EditorGUILayout.HelpBox("暂无报告。", MessageType.Info);
                return;
            }

            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField(
                    $"预制体 {_report.PrefabChecked}/{_report.PrefabTotal}（跳过 {_report.PrefabSkipped}） | " +
                    $"动画 {_report.AnimationCount} | 序列帧 {_report.FrameCount} | " +
                    $"错误 {_report.ErrorCount} | 警告 {_report.WarningCount}",
                    EditorStyles.boldLabel);
                if (GUILayout.Button("导出检查报告", GUILayout.Width(120)))
                {
                    ExportReport();
                }
            }

            var listHeight = Mathf.Max(260f, position.height - 330f);
            using (var scroll = new EditorGUILayout.ScrollViewScope(_issueScroll, GUILayout.Height(listHeight)))
            {
                _issueScroll = scroll.scrollPosition;
                if (_report.Issues.Count == 0)
                {
                    EditorGUILayout.HelpBox("未发现序列帧动画相关问题。", MessageType.Info);
                }
                else
                {
                    DrawGroupedIssues();
                }
            }

            EditorGUILayout.Space(6f);
            EditorGUILayout.LabelField("检查报告预览", EditorStyles.boldLabel);
            using (var scroll = new EditorGUILayout.ScrollViewScope(_textScroll, EditorStyles.helpBox, GUILayout.MinHeight(180)))
            {
                _textScroll = scroll.scrollPosition;
                EditorGUILayout.SelectableLabel(_reportText, EditorStyles.wordWrappedLabel, GUILayout.ExpandHeight(true));
            }
        }

        private void DrawGroupedIssues()
        {
            EnsureStyles();
            var groups = _report.Issues
                .GroupBy(SpriteAnimCheckReport.GetReasonKey)
                .OrderByDescending(group => group.Any(issue => issue.Severity == SpriteAnimCheckSeverity.Error))
                .ThenBy(group => group.First().CheckName)
                .ThenBy(group => group.First().Message);

            foreach (var group in groups)
            {
                var first = group.First();
                var severity = group.Any(issue => issue.Severity == SpriteAnimCheckSeverity.Error)
                    ? SpriteAnimCheckSeverity.Error
                    : SpriteAnimCheckSeverity.Warning;

                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    EditorGUILayout.LabelField($"{first.CheckName}  ({group.Count()}项)", GetHeaderStyle(severity));
                    EditorGUILayout.LabelField(first.Message, GetLabelStyle(severity));
                    EditorGUILayout.Space(3f);

                    foreach (var issue in group
                                 .OrderBy(issue => issue.PrefabPath, StringComparer.Ordinal)
                                 .ThenBy(issue => issue.AnimationName, StringComparer.Ordinal))
                    {
                        DrawIssue(issue);
                    }
                }
            }
        }

        private void DrawIssue(SpriteAnimCheckIssue issue)
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                var animation = string.IsNullOrEmpty(issue.AnimationName) ? "-" : issue.AnimationName;
                EditorGUILayout.LabelField($"Prefab: {issue.PrefabName}    Animation: {animation}",
                    GetLabelStyle(issue.Severity));
                if (!string.IsNullOrEmpty(issue.Detail))
                {
                    EditorGUILayout.LabelField(issue.Detail, EditorStyles.wordWrappedLabel);
                }

                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(issue.AssetPath));
                    if (GUILayout.Button(issue.AssetName, EditorStyles.linkLabel, GUILayout.Width(260)))
                    {
                        PingAsset(issue.AssetPath);
                    }

                    EditorGUI.EndDisabledGroup();

                    EditorGUILayout.SelectableLabel(issue.AssetPath ?? string.Empty, EditorStyles.textField,
                        GUILayout.Height(EditorGUIUtility.singleLineHeight));
                }
            }
        }

        private void ExportReport()
        {
            var fileName = $"SpriteAnimCheckReport_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
            var path = EditorUtility.SaveFilePanel("导出检查报告", Application.dataPath, fileName, "txt");
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            File.WriteAllText(path, _reportText, Encoding.UTF8);
            if (path.Replace('\\', '/').StartsWith(Application.dataPath.Replace('\\', '/'), StringComparison.Ordinal))
            {
                AssetDatabase.Refresh();
            }

            Debug.Log($"[SpriteAnimCheck] 检查报告已导出：{path}");
        }

        private void EnsureStyles()
        {
            _errorHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = Color.red } };
            _warningHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
            _errorLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = Color.red } };
            _warningLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
        }

        private GUIStyle GetHeaderStyle(SpriteAnimCheckSeverity severity)
        {
            EnsureStyles();
            return severity == SpriteAnimCheckSeverity.Error ? _errorHeaderStyle : _warningHeaderStyle;
        }

        private GUIStyle GetLabelStyle(SpriteAnimCheckSeverity severity)
        {
            EnsureStyles();
            return severity == SpriteAnimCheckSeverity.Error ? _errorLabelStyle : _warningLabelStyle;
        }

        internal static void PingAsset(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return;
            }

            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
            if (asset == null)
            {
                Debug.LogWarning($"[SpriteAnimCheck] 定位失败，资产不存在：{assetPath}");
                return;
            }

            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }
    }
}
