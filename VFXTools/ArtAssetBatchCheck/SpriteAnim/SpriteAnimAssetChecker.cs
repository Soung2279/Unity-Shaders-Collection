using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    /// <summary>
    /// 序列帧动画资源检查：扫描指定目录下所有预制体，仅检查挂有 ActorSpriteAnimator 的预制体，
    /// 校验动画定义、序列帧引用、贴图导入设置以及与源目录的一致性。
    /// </summary>
    public static class SpriteAnimAssetChecker
    {
        private const string CheckStructure = "预制体结构";
        private const string CheckAnimation = "动画配置";
        private const string CheckFrame = "序列帧资源";
        private const string CheckImport = "贴图导入设置";
        private const string CheckSource = "源目录一致性";

        private const int MaxListedItems = 6;

        private struct FrameFile
        {
            public string Path;
            public string Action;
            public int Index;
        }

        private static Dictionary<string, List<FrameFile>> s_folderFrameCache;

        public static SpriteAnimCheckResult Run(SpriteAnimCheckConfig config)
        {
            var result = new SpriteAnimCheckResult();
            var report = result.Report;
            report.CreatedAt = DateTime.Now;
            report.RootFolder = config != null ? config.prefabRootFolder : string.Empty;
            s_folderFrameCache = new Dictionary<string, List<FrameFile>>(StringComparer.Ordinal);

            if (string.IsNullOrEmpty(report.RootFolder) || !AssetDatabase.IsValidFolder(report.RootFolder))
            {
                AddIssue(report, null, SpriteAnimCheckSeverity.Error, CheckStructure, "预制体根目录无效",
                    $"rootFolder={report.RootFolder}", string.Empty, report.RootFolder, null);
                Finish(report);
                return result;
            }

            var prefabPaths = AssetDatabase.FindAssets("t:Prefab", new[] { report.RootFolder })
                .Select(AssetDatabase.GUIDToAssetPath)
                .Where(path => path.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase))
                .OrderBy(path => path, StringComparer.Ordinal)
                .ToArray();
            report.PrefabTotal = prefabPaths.Length;

            var animationNames = new SortedSet<string>(StringComparer.Ordinal);
            try
            {
                for (var i = 0; i < prefabPaths.Length; i++)
                {
                    if (EditorUtility.DisplayCancelableProgressBar("序列帧动画检查",
                            $"({i + 1}/{prefabPaths.Length}) {Path.GetFileName(prefabPaths[i])}",
                            (float)i / Mathf.Max(1, prefabPaths.Length)))
                    {
                        result.Cancelled = true;
                        break;
                    }

                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPaths[i]);
                    if (prefab == null)
                    {
                        report.PrefabSkipped++;
                        continue;
                    }

                    var animator = prefab.GetComponentInChildren<ActorSpriteAnimator>(true);
                    if (animator == null)
                    {
                        report.PrefabSkipped++;
                        continue;
                    }

                    report.PrefabChecked++;
                    var entry = CheckPrefab(prefab, prefabPaths[i], animator, config, report);
                    foreach (var name in entry.AnimationNames)
                    {
                        animationNames.Add(name);
                    }

                    result.Entries.Add(entry);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            result.AnimationNames.AddRange(animationNames);
            Finish(report);
            return result;
        }

        private static SpriteAnimActorEntry CheckPrefab(GameObject prefab, string prefabPath,
            ActorSpriteAnimator animator, SpriteAnimCheckConfig config, SpriteAnimCheckReport report)
        {
            var entry = new SpriteAnimActorEntry
            {
                Prefab = prefab,
                Animator = animator,
                PrefabPath = prefabPath,
                PrefabName = prefab.name
            };

            var serialized = new SerializedObject(animator);
            entry.SourceFolder = serialized.FindProperty("sourceFolder")?.stringValue ?? string.Empty;
            entry.DefaultAnimation = serialized.FindProperty("defaultAnimation")?.stringValue ?? string.Empty;
            var rendererRef = serialized.FindProperty("spriteRenderer")?.objectReferenceValue as SpriteRenderer;
            entry.RendererAssigned = rendererRef != null;

            if (rendererRef == null)
            {
                var childRenderer = animator.GetComponentInChildren<SpriteRenderer>(true);
                if (childRenderer == null)
                {
                    AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckStructure, "缺少 Sprite 渲染主体",
                        "spriteRenderer 为空且子节点没有 SpriteRenderer，运行时序列帧无法显示",
                        string.Empty, prefabPath, prefab.name);
                }
                else
                {
                    AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckStructure, "未显式指定 SpriteRenderer",
                        "spriteRenderer 字段为空，运行时将自动查找子节点（建议显式指定）",
                        string.Empty, AssetDatabase.GetAssetPath(childRenderer), childRenderer.name);
                }
            }

            if (config == null || config.checkMissingScripts)
            {
                var missing = CountMissingComponents(prefab);
                if (missing > 0)
                {
                    AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckStructure, "预制体存在丢失的脚本引用",
                        $"共 {missing} 个空组件（Missing Script），需要修复引用或移除组件",
                        string.Empty, prefabPath, prefab.name);
                }
            }

            CheckAnimations(entry, config, report);
            CheckSourceFolder(entry, config, report);

            report.AnimationCount += entry.AnimationCount;
            report.FrameCount += entry.FrameCount;
            return entry;
        }

        private static void CheckAnimations(SpriteAnimActorEntry entry, SpriteAnimCheckConfig config,
            SpriteAnimCheckReport report)
        {
            var animations = entry.Animator.Animations;
            if (animations == null || animations.Length == 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckAnimation, "没有配置序列帧动画",
                    "animations 为空数组，角色不会有任何动画", string.Empty, entry.PrefabPath, entry.PrefabName);
            }
            else
            {
                var seenNames = new HashSet<string>(StringComparer.Ordinal);
                for (var i = 0; i < animations.Length; i++)
                {
                    var definition = animations[i];
                    if (definition == null)
                    {
                        AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckAnimation, "动画定义为空",
                            $"animations[{i}] 为空，运行时会被忽略", string.Empty, entry.PrefabPath, entry.PrefabName);
                        continue;
                    }

                    var name = definition.name;
                    if (string.IsNullOrEmpty(name))
                    {
                        AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckAnimation, "动画名称为空",
                            $"animations[{i}] 未命名，运行时会被忽略", string.Empty, entry.PrefabPath, entry.PrefabName);
                    }
                    else
                    {
                        entry.AnimationCount++;
                        if (!entry.AnimationNames.Contains(name))
                        {
                            entry.AnimationNames.Add(name);
                        }

                        if (!seenNames.Add(name))
                        {
                            AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckAnimation, "动画名称重复",
                                $"'{name}' 重复定义，重复项不会生效", name, entry.PrefabPath, entry.PrefabName);
                        }
                    }

                    if (definition.frameRate <= 0f)
                    {
                        AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckAnimation, "帧率无效",
                            $"frameRate={definition.frameRate}，动画帧不会推进", name, entry.PrefabPath, entry.PrefabName);
                    }

                    CheckFrames(entry, config, report, name, definition.frames);
                }
            }

            if (string.IsNullOrEmpty(entry.DefaultAnimation))
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckAnimation, "未设置默认动画",
                    "defaultAnimation 为空，运行时初始不会播放任何动画", string.Empty, entry.PrefabPath, entry.PrefabName);
            }
            else if (!entry.AnimationNames.Contains(entry.DefaultAnimation))
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckAnimation, "默认动画不存在",
                    $"defaultAnimation='{entry.DefaultAnimation}' 不在动画列表中",
                    entry.DefaultAnimation, entry.PrefabPath, entry.PrefabName);
            }
        }

        private static void CheckFrames(SpriteAnimActorEntry entry, SpriteAnimCheckConfig config,
            SpriteAnimCheckReport report, string animationName, Sprite[] frames)
        {
            if (frames == null || frames.Length == 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckFrame, "动画没有序列帧",
                    "frames 为空数组，播放时不会切换任何贴图", animationName, entry.PrefabPath, entry.PrefabName);
                return;
            }

            entry.FrameCount += frames.Length;

            var nullFrameIndices = new List<int>();
            var indices = new List<int>();
            var seenSprites = new HashSet<int>();
            var pixelsPerUnits = new HashSet<float>();
            var duplicateFrameCount = 0;
            var nameMismatchCount = 0;
            var outsideFolderCount = 0;
            string firstNameMismatchAsset = null;
            string firstOutsideFolderAsset = null;

            for (var i = 0; i < frames.Length; i++)
            {
                var sprite = frames[i];
                if (sprite == null)
                {
                    nullFrameIndices.Add(i);
                    continue;
                }

                if (!seenSprites.Add(sprite.GetInstanceID()))
                {
                    duplicateFrameCount++;
                }

                pixelsPerUnits.Add(sprite.pixelsPerUnit);

                if (TryParseFrameName(sprite.name, out var action, out var index))
                {
                    indices.Add(index);
                    if (!string.IsNullOrEmpty(animationName) &&
                        !string.Equals(action, animationName, StringComparison.OrdinalIgnoreCase))
                    {
                        nameMismatchCount++;
                        firstNameMismatchAsset ??= AssetDatabase.GetAssetPath(sprite);
                    }
                }

                var assetPath = AssetDatabase.GetAssetPath(sprite);

                if (config == null || config.checkSourceFolderConsistency)
                {
                    var folder = Path.GetDirectoryName(assetPath)?.Replace('\\', '/');
                    if (!string.IsNullOrEmpty(entry.SourceFolder) &&
                        !string.Equals(folder, entry.SourceFolder, StringComparison.OrdinalIgnoreCase))
                    {
                        outsideFolderCount++;
                        firstOutsideFolderAsset ??= assetPath;
                    }
                }
            }

            if (nullFrameIndices.Count > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Error, CheckFrame, "序列帧引用丢失",
                    $"共 {nullFrameIndices.Count} 帧为空（索引 {FormatValues(nullFrameIndices)}），贴图可能已被删除",
                    animationName, entry.PrefabPath, entry.PrefabName);
            }

            if (duplicateFrameCount > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckFrame, "动画内存在重复帧",
                    $"共 {duplicateFrameCount} 帧重复引用同一张贴图", animationName, entry.PrefabPath, entry.PrefabName);
            }

            if (nameMismatchCount > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckFrame, "序列帧命名与动画名不一致",
                    $"共 {nameMismatchCount} 帧不符合 动作_序号 命名或动作名不同",
                    animationName, firstNameMismatchAsset, Path.GetFileNameWithoutExtension(firstNameMismatchAsset ?? string.Empty));
            }

            var missingIndices = CollectMissingIndices(indices);
            if (missingIndices.Count > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckFrame, "序列帧编号不连续",
                    $"缺少序号 {FormatValues(missingIndices)}", animationName, entry.PrefabPath, entry.PrefabName);
            }

            if ((config == null || config.checkPixelsPerUnit) && pixelsPerUnits.Count > 1)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckImport, "序列帧 PixelPerUnit 不一致",
                    $"同一动画内出现 {pixelsPerUnits.Count} 种 PPU（{string.Join(",", pixelsPerUnits.Select(value => value.ToString("0.##")))}），会导致显示尺寸跳变",
                    animationName, entry.PrefabPath, entry.PrefabName);
            }

            if (outsideFolderCount > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "序列帧不在源目录内",
                    $"共 {outsideFolderCount} 帧引用自 sourceFolder 之外的目录，重新收集时会丢失",
                    animationName, firstOutsideFolderAsset, Path.GetFileNameWithoutExtension(firstOutsideFolderAsset ?? string.Empty));
            }
        }

        private static void CheckSourceFolder(SpriteAnimActorEntry entry, SpriteAnimCheckConfig config,
            SpriteAnimCheckReport report)
        {
            if (config != null && !config.checkSourceFolderConsistency)
            {
                return;
            }

            if (string.IsNullOrEmpty(entry.SourceFolder))
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "未设置源目录",
                    "sourceFolder 为空，无法校验序列帧完整性", string.Empty, entry.PrefabPath, entry.PrefabName);
                return;
            }

            if (!AssetDatabase.IsValidFolder(entry.SourceFolder))
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "源目录不存在",
                    $"sourceFolder={entry.SourceFolder} 在工程中不存在，无法校验序列帧完整性且无法重新收集",
                    string.Empty, entry.PrefabPath, entry.PrefabName);
                return;
            }

            var folderFrames = GetFolderFrames(entry.SourceFolder);
            if (folderFrames.Count == 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "源目录没有序列帧文件",
                    $"sourceFolder={entry.SourceFolder} 下没有符合 动作_序号 命名的贴图",
                    string.Empty, entry.SourceFolder, Path.GetFileName(entry.SourceFolder));
                return;
            }

            var referencedPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var definition in entry.Animator.Animations)
            {
                if (definition?.frames == null)
                {
                    continue;
                }

                foreach (var sprite in definition.frames)
                {
                    if (sprite == null)
                    {
                        continue;
                    }

                    var path = AssetDatabase.GetAssetPath(sprite);
                    if (!string.IsNullOrEmpty(path))
                    {
                        referencedPaths.Add(path);
                    }
                }
            }

            var uncollected = folderFrames.Where(file => !referencedPaths.Contains(file.Path)).ToList();
            if (uncollected.Count > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "源目录存在未收集的序列帧",
                    $"共 {uncollected.Count} 个帧文件未被任何动画引用（{FormatFrameNames(uncollected)}）",
                    string.Empty, uncollected[0].Path, Path.GetFileNameWithoutExtension(uncollected[0].Path));
            }

            var folderActions = new HashSet<string>(folderFrames.Select(file => file.Action), StringComparer.Ordinal);
            var missingActions = folderActions
                .Where(action => !entry.AnimationNames.Contains(action))
                .OrderBy(action => action, StringComparer.Ordinal)
                .ToList();
            if (missingActions.Count > 0)
            {
                AddIssue(report, entry, SpriteAnimCheckSeverity.Warning, CheckSource, "源目录动作未配置为动画",
                    $"动作 {string.Join(", ", missingActions)} 在源目录中存在但没有对应动画定义",
                    string.Empty, entry.SourceFolder, Path.GetFileName(entry.SourceFolder));
            }
        }

        private static List<FrameFile> GetFolderFrames(string folder)
        {
            s_folderFrameCache ??= new Dictionary<string, List<FrameFile>>(StringComparer.Ordinal);
            if (s_folderFrameCache.TryGetValue(folder, out var cached))
            {
                return cached;
            }

            var frames = new List<FrameFile>();
            var seenPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var guid in AssetDatabase.FindAssets("t:Sprite", new[] { folder }))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (string.IsNullOrEmpty(path) || !seenPaths.Add(path))
                {
                    continue;
                }

                if (TryParseFrameName(Path.GetFileNameWithoutExtension(path), out var action, out var index))
                {
                    frames.Add(new FrameFile { Path = path, Action = action, Index = index });
                }
            }

            frames.Sort((left, right) => string.CompareOrdinal(left.Path, right.Path));
            s_folderFrameCache[folder] = frames;
            return frames;
        }

        private static bool TryParseFrameName(string fileName, out string action, out int index)
        {
            action = null;
            index = 0;
            if (string.IsNullOrEmpty(fileName))
            {
                return false;
            }

            var separator = fileName.LastIndexOf('_');
            if (separator <= 0 || separator >= fileName.Length - 1)
            {
                return false;
            }

            if (!int.TryParse(fileName.Substring(separator + 1), out index))
            {
                return false;
            }

            action = fileName.Substring(0, separator);
            return !string.IsNullOrEmpty(action);
        }

        private static List<int> CollectMissingIndices(List<int> indices)
        {
            var missing = new List<int>();
            if (indices.Count == 0)
            {
                return missing;
            }

            var present = new HashSet<int>(indices);
            var min = indices.Min();
            var max = indices.Max();
            for (var i = min; i <= max; i++)
            {
                if (!present.Contains(i))
                {
                    missing.Add(i);
                }
            }

            return missing;
        }

        private static int CountMissingComponents(GameObject prefab)
        {
            var count = 0;
            foreach (var child in prefab.GetComponentsInChildren<Transform>(true))
            {
                foreach (var component in child.GetComponents<Component>())
                {
                    if (component == null)
                    {
                        count++;
                    }
                }
            }

            return count;
        }

        private static string FormatValues(List<int> values)
        {
            return values.Count <= MaxListedItems
                ? string.Join(", ", values)
                : string.Join(", ", values.Take(MaxListedItems)) + $", ...(共{values.Count})";
        }

        private static string FormatFrameNames(List<FrameFile> files)
        {
            var names = files.Select(file => file.Action + "_" + file.Index).ToList();
            return names.Count <= MaxListedItems
                ? string.Join(", ", names)
                : string.Join(", ", names.Take(MaxListedItems)) + $", ...(共{names.Count})";
        }

        private static void AddIssue(SpriteAnimCheckReport report, SpriteAnimActorEntry entry,
            SpriteAnimCheckSeverity severity, string checkName, string message, string detail,
            string animationName, string assetPath, string assetName)
        {
            var issue = new SpriteAnimCheckIssue
            {
                Severity = severity,
                CheckName = checkName,
                Message = message,
                Detail = detail,
                AnimationName = animationName ?? string.Empty,
                AssetPath = assetPath ?? string.Empty,
                AssetName = string.IsNullOrEmpty(assetName) ? Path.GetFileName(assetPath ?? string.Empty) : assetName,
                PrefabPath = entry?.PrefabPath ?? assetPath ?? string.Empty,
                PrefabName = entry?.PrefabName ?? string.Empty
            };

            report.Issues.Add(issue);
            entry?.Issues.Add(issue);
        }

        private static void Finish(SpriteAnimCheckReport report)
        {
            report.ErrorCount = report.Issues.Count(issue => issue.Severity == SpriteAnimCheckSeverity.Error);
            report.WarningCount = report.Issues.Count(issue => issue.Severity == SpriteAnimCheckSeverity.Warning);
        }
    }
}
