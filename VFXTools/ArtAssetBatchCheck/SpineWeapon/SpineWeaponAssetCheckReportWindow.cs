using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Game.Share;
using Spine.Unity;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public enum SpineWeaponAssetCheckSeverity
    {
        Info,
        Warning,
        Error
    }

    public class SpineWeaponAssetCheckIssue
    {
        public SpineWeaponAssetCheckSeverity Severity;
        public int HeroId;
        public int WeaponId;
        public string WeaponName;
        public string CheckName;
        public string Message;
        public string AssetPath;
        public string SpineName;
    }

    public class SpineWeaponAssetCheckReport
    {
        public DateTime CreatedAt;
        public int HeroCount;
        public int WeaponCount;
        public int CombinationCount;
        public int ErrorCount;
        public int WarningCount;
        public readonly List<SpineWeaponAssetCheckIssue> Issues = new();

        public static string GetReasonKey(SpineWeaponAssetCheckIssue issue)
        {
            return issue == null ? string.Empty : $"{issue.CheckName}|{issue.Message}";
        }

        public string ToText()
        {
            var builder = new StringBuilder();
            builder.AppendLine("Spine角色武器资源检查报告");
            builder.AppendLine($"生成时间: {CreatedAt:yyyy-MM-dd HH:mm:ss}");
            builder.AppendLine($"英雄数: {HeroCount}");
            builder.AppendLine($"武器数: {WeaponCount}");
            builder.AppendLine($"组合数: {CombinationCount}");
            builder.AppendLine($"错误: {ErrorCount}");
            builder.AppendLine($"警告: {WarningCount}");
            builder.AppendLine();

            if (Issues.Count == 0)
            {
                builder.AppendLine("未发现资源缺失或匹配错误。");
                return builder.ToString();
            }

            foreach (var group in Issues.GroupBy(issue => GetReasonKey(issue)).OrderByDescending(group => group.Any(issue => issue.Severity == SpineWeaponAssetCheckSeverity.Error)).ThenBy(group => group.Key))
            {
                var first = group.First();
                builder.AppendLine($"问题原因: {first.CheckName} - {first.Message}");
                builder.AppendLine($"数量: {group.Count()}");
                foreach (var issue in group)
                {
                    builder.AppendLine($"  [{issue.Severity}] HeroID={issue.HeroId}; WeaponID={issue.WeaponId}; Weapon={issue.WeaponName}; Spine={issue.SpineName}; Asset={issue.AssetPath}");
                }

                builder.AppendLine();
            }

            return builder.ToString();
        }
    }

    public static class SpineWeaponAssetChecker
    {
        private static readonly string[] AttackKeys = { "attack1", "attack2", "attack3" };

        public static SpineWeaponAssetCheckReport Run(SpineWeaponPreviewData.Database db)
        {
            var report = new SpineWeaponAssetCheckReport
            {
                CreatedAt = DateTime.Now,
                HeroCount = db?.Heroes.Count ?? 0,
                WeaponCount = db?.Weapons.Count ?? 0,
                CombinationCount = (db?.Heroes.Count ?? 0) * (db?.Weapons.Count ?? 0)
            };

            if (db == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, 0, null, "配置读取", "数据库为空。", string.Empty, string.Empty);
                Finish(report);
                return report;
            }

            foreach (var hero in db.Heroes)
            {
                var actorPrefabPath = SpineWeaponPreviewData.ToGameAssetPath("Prefab/Actor/" + hero.actorModelRes);
                var actorPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(actorPrefabPath);
                SkeletonDataAsset fallbackSkeleton = null;
                if (actorPrefab == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, null, "英雄Prefab", $"英雄Prefab缺失，ActorID={hero.actorId}, ModelRes={hero.actorModelRes}", actorPrefabPath, hero.actorModelRes);
                    continue;
                }

                var actorSkeleton = actorPrefab.GetComponentInChildren<SkeletonAnimation>(true);
                var actorWeaponRoot = actorPrefab.GetComponent<ActorRender>()?.WeaponRoot ?? actorPrefab.transform.Find("Spine/WeaponRoot");
                if (actorSkeleton == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, null, "英雄Prefab结构", "英雄Prefab缺少SkeletonAnimation。", actorPrefabPath, actorPrefab.name);
                }
                else
                {
                    fallbackSkeleton = actorSkeleton.skeletonDataAsset;
                }

                if (actorWeaponRoot == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, null, "英雄Prefab结构", "英雄Prefab缺少WeaponRoot。", actorPrefabPath, actorPrefab.name);
                }

                foreach (var weapon in db.Weapons)
                {
                    CheckCombination(report, hero, weapon, fallbackSkeleton);
                }
            }

            Finish(report);
            return report;
        }

        private static void CheckCombination(SpineWeaponAssetCheckReport report,
            SpineWeaponPreviewData.HeroPreviewData hero,
            SpineWeaponPreviewData.WeaponPreviewData weapon,
            SkeletonDataAsset fallbackSkeleton)
        {
            var heroSkeleton = ResolveHeroSkeleton(report, hero, weapon, fallbackSkeleton);
            var skeletonData = heroSkeleton != null ? heroSkeleton.GetSkeletonData(true) : null;
            if (skeletonData == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "英雄Spine", "无法读取英雄SkeletonData。", GetHeroSkeletonPath(hero, weapon), GetHeroSkeletonName(hero, weapon));
                return;
            }

            CheckHeroAnimation(report, hero, weapon, skeletonData, "idle", ResolveAnimationName(weapon, "idle"), heroSkeleton);
            CheckHeroAnimation(report, hero, weapon, skeletonData, "run", ResolveAnimationName(weapon, "run"), heroSkeleton);
            CheckHeroAnimation(report, hero, weapon, skeletonData, "dead", ResolveAnimationName(weapon, "dead"), heroSkeleton);
            for (int i = 0; i < AttackKeys.Length; i++)
            {
                CheckHeroAnimation(report, hero, weapon, skeletonData, AttackKeys[i], ResolveAnimationName(weapon, AttackKeys[i]), heroSkeleton);
            }

            var partCount = GetRenderPartCount(weapon);
            if (partCount <= 0)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器配置", "武器Res或Slots为空，无法挂载武器预制体。", SpineWeaponPreviewData.EquipJsonPath, weapon.DisplayName);
                return;
            }

            for (int i = 0; i < partCount; i++)
            {
                CheckWeaponPart(report, hero, weapon, skeletonData, i);
            }
        }

        private static SkeletonDataAsset ResolveHeroSkeleton(SpineWeaponAssetCheckReport report,
            SpineWeaponPreviewData.HeroPreviewData hero,
            SpineWeaponPreviewData.WeaponPreviewData weapon,
            SkeletonDataAsset fallbackSkeleton)
        {
            if (string.IsNullOrEmpty(weapon.playerModelRes))
            {
                if (fallbackSkeleton == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "英雄Spine", "武器未配置PlayerModelRes，且英雄Prefab默认SkeletonData为空。", SpineWeaponPreviewData.ToGameAssetPath("Prefab/Actor/" + hero.actorModelRes), hero.actorModelRes);
                }

                return fallbackSkeleton;
            }

            var path = GetHeroSkeletonPath(hero, weapon);
            var skeleton = AssetDatabase.LoadAssetAtPath<SkeletonDataAsset>(path);
            if (skeleton == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "英雄Spine", $"PlayerModelRes对应SkeletonData缺失，PlayerModelRes={weapon.playerModelRes}", path, GetHeroSkeletonName(hero, weapon));
            }

            return skeleton;
        }

        private static void CheckHeroAnimation(SpineWeaponAssetCheckReport report,
            SpineWeaponPreviewData.HeroPreviewData hero,
            SpineWeaponPreviewData.WeaponPreviewData weapon,
            Spine.SkeletonData skeletonData,
            string requestedKey,
            string resolvedAnim,
            SkeletonDataAsset skeletonAsset)
        {
            if (string.IsNullOrEmpty(resolvedAnim))
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "英雄动画", $"动画映射为空，requested={requestedKey}", AssetDatabase.GetAssetPath(skeletonAsset), skeletonAsset?.name);
                return;
            }

            if (skeletonData.FindAnimation(resolvedAnim) == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "英雄动画", $"英雄Spine缺少动画，requested={requestedKey}, resolved={resolvedAnim}", AssetDatabase.GetAssetPath(skeletonAsset), skeletonAsset?.name);
            }
        }

        private static void CheckWeaponPart(SpineWeaponAssetCheckReport report,
            SpineWeaponPreviewData.HeroPreviewData hero,
            SpineWeaponPreviewData.WeaponPreviewData weapon,
            Spine.SkeletonData heroSkeletonData,
            int partIndex)
        {
            var res = GetIndexedString(weapon.res, partIndex);
            if (string.IsNullOrEmpty(res))
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器配置", $"武器部件Res为空，partIndex={partIndex}", SpineWeaponPreviewData.EquipJsonPath, weapon.DisplayName);
                return;
            }

            var prefabPath = SpineWeaponPreviewData.ToGameAssetPath("Prefab/Equip/" + res + ".prefab");
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if (prefab == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器Prefab", $"武器Prefab缺失，partIndex={partIndex}, res={res}", prefabPath, res);
                return;
            }

            var weaponSkeleton = prefab.GetComponentInChildren<SkeletonAnimation>(true);
            if (weaponSkeleton == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器Prefab", $"武器Prefab缺少SkeletonAnimation，partIndex={partIndex}", prefabPath, prefab.name);
            }
            else
            {
                var weaponData = weaponSkeleton.skeletonDataAsset != null ? weaponSkeleton.skeletonDataAsset.GetSkeletonData(true) : null;
                if (weaponData == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器Spine", $"武器SkeletonData为空，partIndex={partIndex}", prefabPath, weaponSkeleton.name);
                }
                else if (weaponData.FindAnimation("idle") == null)
                {
                    AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器动画", $"武器Spine缺少idle动画，partIndex={partIndex}", AssetDatabase.GetAssetPath(weaponSkeleton.skeletonDataAsset), weaponSkeleton.skeletonDataAsset.name);
                }
            }

            var bone = GetIndexedString(weapon.slots, partIndex, "weapon_r");
            if (heroSkeletonData.FindBone(bone) == null)
            {
                AddIssue(report, SpineWeaponAssetCheckSeverity.Error, hero.id, weapon, "武器挂点", $"英雄Spine缺少武器挂点骨骼，partIndex={partIndex}, bone={bone}, res={res}", GetHeroSkeletonPath(hero, weapon), GetHeroSkeletonName(hero, weapon));
            }
        }

        private static string ResolveAnimationName(SpineWeaponPreviewData.WeaponPreviewData weapon, string animationKey)
        {
            return animationKey switch
            {
                "idle" => string.IsNullOrEmpty(weapon.idleAnim) ? "idle" : weapon.idleAnim,
                "run" => string.IsNullOrEmpty(weapon.runAnim) ? "run" : weapon.runAnim,
                "dead" => string.IsNullOrEmpty(weapon.deadAnim) ? "dead" : weapon.deadAnim,
                "attack1" => GetIndexedString(weapon.normalAttackAnims, 0, "attack1"),
                "attack2" => GetIndexedString(weapon.normalAttackAnims, 1, GetIndexedString(weapon.normalAttackAnims, 0, "attack1")),
                "attack3" => GetIndexedString(weapon.normalAttackAnims, 2, GetIndexedString(weapon.normalAttackAnims, 0, "attack1")),
                _ => animationKey
            };
        }

        private static int GetRenderPartCount(SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            if (weapon?.res == null || weapon.slots == null)
            {
                return 0;
            }

            return Mathf.Min(weapon.res.Count, weapon.slots.Count);
        }

        private static string GetIndexedString(List<string> values, int index, string fallback = null)
        {
            if (values == null || values.Count == 0)
            {
                return fallback;
            }

            if (index >= 0 && index < values.Count && !string.IsNullOrEmpty(values[index]))
            {
                return values[index];
            }

            return !string.IsNullOrEmpty(values[0]) ? values[0] : fallback;
        }

        private static string GetHeroSkeletonPath(SpineWeaponPreviewData.HeroPreviewData hero, SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            if (string.IsNullOrEmpty(weapon.playerModelRes))
            {
                return SpineWeaponPreviewData.ToGameAssetPath("Prefab/Actor/" + hero.actorModelRes);
            }

            return SpineWeaponPreviewData.ToGameAssetPath(GameConst.GetPlayerModelRealPath(hero.modelGroupId, weapon.playerModelRes));
        }

        private static string GetHeroSkeletonName(SpineWeaponPreviewData.HeroPreviewData hero, SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            return string.IsNullOrEmpty(weapon.playerModelRes) ? hero.actorModelRes : weapon.playerModelRes;
        }

        private static void AddIssue(SpineWeaponAssetCheckReport report, SpineWeaponAssetCheckSeverity severity, int heroId,
            SpineWeaponPreviewData.WeaponPreviewData weapon, string checkName, string message, string assetPath, string spineName)
        {
            report.Issues.Add(new SpineWeaponAssetCheckIssue
            {
                Severity = severity,
                HeroId = heroId,
                WeaponId = weapon?.id ?? 0,
                WeaponName = weapon?.DisplayName ?? string.Empty,
                CheckName = checkName,
                Message = message,
                AssetPath = assetPath,
                SpineName = spineName
            });
        }

        private static void Finish(SpineWeaponAssetCheckReport report)
        {
            report.ErrorCount = report.Issues.Count(issue => issue.Severity == SpineWeaponAssetCheckSeverity.Error);
            report.WarningCount = report.Issues.Count(issue => issue.Severity == SpineWeaponAssetCheckSeverity.Warning);
        }
    }

    public class SpineWeaponAssetCheckReportWindow : EditorWindow
    {
        private SpineWeaponAssetCheckReport _report;
        private Vector2 _issueScroll;
        private Vector2 _textScroll;
        private string _reportText;
        private GUIStyle _errorHeaderStyle;
        private GUIStyle _warningHeaderStyle;
        private GUIStyle _errorLabelStyle;
        private GUIStyle _warningLabelStyle;

        public static void ShowReport(SpineWeaponAssetCheckReport report)
        {
            var window = GetWindow<SpineWeaponAssetCheckReportWindow>("Spine资源检查报告");
            window.minSize = new Vector2(900, 600);
            window.SetReport(report);
            window.Show();
            window.Focus();
        }

        private void SetReport(SpineWeaponAssetCheckReport report)
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
                EditorGUILayout.LabelField($"英雄 {_report.HeroCount} | 武器 {_report.WeaponCount} | 组合 {_report.CombinationCount} | 错误 {_report.ErrorCount} | 警告 {_report.WarningCount}", EditorStyles.boldLabel);
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
                    EditorGUILayout.HelpBox("未发现资源缺失或匹配错误。", MessageType.Info);
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
                .GroupBy(SpineWeaponAssetCheckReport.GetReasonKey)
                .OrderByDescending(group => group.Any(issue => issue.Severity == SpineWeaponAssetCheckSeverity.Error))
                .ThenBy(group => group.First().CheckName)
                .ThenBy(group => group.First().Message);

            foreach (var group in groups)
            {
                var first = group.First();
                var severity = group.Any(issue => issue.Severity == SpineWeaponAssetCheckSeverity.Error)
                    ? SpineWeaponAssetCheckSeverity.Error
                    : SpineWeaponAssetCheckSeverity.Warning;

                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    EditorGUILayout.LabelField($"{first.CheckName}  ({group.Count()}项)", GetHeaderStyle(severity));
                    EditorGUILayout.LabelField(first.Message, GetLabelStyle(severity));
                    EditorGUILayout.Space(3f);

                    foreach (var issue in group.OrderBy(issue => issue.HeroId).ThenBy(issue => issue.WeaponId).ThenBy(issue => issue.AssetPath))
                    {
                        DrawIssue(issue);
                    }
                }
            }
        }

        private void DrawIssue(SpineWeaponAssetCheckIssue issue)
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField($"HeroID: {issue.HeroId}    WeaponID: {issue.WeaponId}    Weapon: {issue.WeaponName}", GetLabelStyle(issue.Severity));
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(issue.AssetPath));
                    if (GUILayout.Button(string.IsNullOrEmpty(issue.SpineName) ? "定位资产" : issue.SpineName, EditorStyles.linkLabel, GUILayout.Width(260)))
                    {
                        PingAsset(issue.AssetPath);
                    }
                    EditorGUI.EndDisabledGroup();

                    EditorGUILayout.SelectableLabel(issue.AssetPath ?? string.Empty, EditorStyles.textField, GUILayout.Height(EditorGUIUtility.singleLineHeight));
                }
            }
        }

        private void ExportReport()
        {
            var fileName = $"SpineWeaponAssetCheckReport_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
            var path = EditorUtility.SaveFilePanel("导出检查报告", Application.dataPath, fileName, "txt");
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            File.WriteAllText(path, _reportText, Encoding.UTF8);
            if (path.Replace('\\', '/').StartsWith(Application.dataPath.Replace('\\', '/')))
            {
                AssetDatabase.Refresh();
            }

            Debug.Log($"[SpineWeaponPreview][AssetCheck] 检查报告已导出：{path}");
        }

        private void EnsureStyles()
        {
            _errorHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = Color.red } };
            _warningHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
            _errorLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = Color.red } };
            _warningLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
        }

        private GUIStyle GetHeaderStyle(SpineWeaponAssetCheckSeverity severity)
        {
            EnsureStyles();
            return severity == SpineWeaponAssetCheckSeverity.Error ? _errorHeaderStyle : _warningHeaderStyle;
        }

        private GUIStyle GetLabelStyle(SpineWeaponAssetCheckSeverity severity)
        {
            EnsureStyles();
            return severity == SpineWeaponAssetCheckSeverity.Error ? _errorLabelStyle : _warningLabelStyle;
        }

        private static void PingAsset(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return;
            }

            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
            if (asset == null)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 定位失败，资产不存在：{assetPath}");
                return;
            }

            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }
    }
}
