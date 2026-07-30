using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.Utilities
{
    public class ParticleMaxCountLimiterWindow : EditorWindow
    {
        private const int MaxParticleCount = 10;
        private const string MenuPath = "TATools/VFXTools/Utilities/粒子最大数量限制";
        private const string FolderPrefsKey = "VFXTools.ParticleMaxCountLimiter.Folders";

        private readonly List<DefaultAsset> scanFolders = new List<DefaultAsset>();
        private readonly List<PrefabReport> reports = new List<PrefabReport>();
        private readonly Dictionary<string, bool> reportFoldouts = new Dictionary<string, bool>();

        private Vector2 folderScroll;
        private Vector2 resultScroll;
        private int scannedPrefabCount;
        private int particlePrefabCount;
        private int scannedParticleCount;
        private bool hasCompleteScan;
        private string lastOperationSummary;

        [MenuItem(MenuPath, false, 122)]
        public static void Open()
        {
            var window = GetWindow<ParticleMaxCountLimiterWindow>("粒子数量限制");
            window.minSize = new Vector2(620f, 440f);
        }

        private void OnEnable()
        {
            LoadFolders();
        }

        private void OnDisable()
        {
            SaveFolders();
        }

        private void OnGUI()
        {
            EditorGUILayout.Space(4f);
            EditorGUILayout.LabelField("粒子最大数量限制", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(
                $"递归扫描指定目录中的 Prefab（包括未激活物体）。只处理包含 ParticleSystem 的物体。\n" +
                $"Max Particles 小于等于 {MaxParticleCount} 时不修改；大于 {MaxParticleCount} 时仅将该值改为 {MaxParticleCount}。",
                MessageType.Info);

            DrawFolderSection();

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("扫描", GUILayout.Height(30f)))
                    Scan(true);

                int particleCount = reports.Sum(report => report.Particles.Count);
                using (new EditorGUI.DisabledScope(particleCount == 0 || !hasCompleteScan))
                {
                    if (GUILayout.Button($"限制 {particleCount} 个粒子系统", GUILayout.Height(30f)))
                        ApplyLimit();
                }
            }

            EditorGUILayout.Space(4f);
            EditorGUILayout.LabelField(
                $"扫描 Prefab：{scannedPrefabCount}  |  含粒子 Prefab：{particlePrefabCount}  |  " +
                $"粒子系统：{scannedParticleCount}  |  待修改 Prefab：{reports.Count}  |  " +
                $"待修改粒子：{reports.Sum(report => report.Particles.Count)}",
                EditorStyles.boldLabel);

            if (!string.IsNullOrEmpty(lastOperationSummary))
                EditorGUILayout.HelpBox(lastOperationSummary, MessageType.Info);

            DrawResults();
        }

        private void DrawFolderSection()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("扫描目录（可多选，包含子目录）", EditorStyles.boldLabel);
                folderScroll = EditorGUILayout.BeginScrollView(folderScroll, GUILayout.MaxHeight(130f));
                int removeIndex = -1;
                for (int i = 0; i < scanFolders.Count; i++)
                {
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        var selected = (DefaultAsset)EditorGUILayout.ObjectField(
                            scanFolders[i], typeof(DefaultAsset), false);
                        if (selected != scanFolders[i])
                        {
                            string path = selected != null ? AssetDatabase.GetAssetPath(selected) : string.Empty;
                            if (selected == null || IsValidAssetsFolder(path))
                            {
                                scanFolders[i] = selected;
                                InvalidateResults();
                                SaveFolders();
                            }
                            else
                            {
                                EditorUtility.DisplayDialog("目录无效", "只能选择 Assets 下的目录。", "确定");
                            }
                        }

                        if (GUILayout.Button("-", GUILayout.Width(26f)))
                            removeIndex = i;
                    }
                }
                EditorGUILayout.EndScrollView();

                if (removeIndex >= 0)
                {
                    scanFolders.RemoveAt(removeIndex);
                    InvalidateResults();
                    SaveFolders();
                }

                using (new EditorGUILayout.HorizontalScope())
                {
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("+ 添加目录", GUILayout.Width(100f)))
                    {
                        scanFolders.Add(null);
                        InvalidateResults();
                    }
                }
            }
        }

        private void DrawResults()
        {
            resultScroll = EditorGUILayout.BeginScrollView(resultScroll);
            foreach (var report in reports)
            {
                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    bool expanded = reportFoldouts.TryGetValue(report.PrefabPath, out bool value) && value;
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        expanded = EditorGUILayout.Foldout(expanded,
                            $"{report.PrefabName}  ({report.Particles.Count})", true);
                        GUILayout.FlexibleSpace();
                        if (GUILayout.Button("定位", GUILayout.Width(50f)))
                            SelectAsset(report.PrefabPath);
                    }
                    reportFoldouts[report.PrefabPath] = expanded;

                    EditorGUILayout.SelectableLabel(report.PrefabPath, EditorStyles.wordWrappedMiniLabel,
                        GUILayout.MinHeight(EditorGUIUtility.singleLineHeight * 2f));

                    if (!expanded)
                        continue;

                    foreach (var particle in report.Particles)
                    {
                        EditorGUILayout.LabelField(
                            $"• {particle.HierarchyPath}：{particle.OriginalMaxParticles} → {MaxParticleCount}",
                            EditorStyles.wordWrappedMiniLabel);
                    }
                }
            }
            EditorGUILayout.EndScrollView();
        }

        private void Scan(bool showEmptyDialog)
        {
            reports.Clear();
            reportFoldouts.Clear();
            scannedPrefabCount = 0;
            particlePrefabCount = 0;
            scannedParticleCount = 0;
            hasCompleteScan = false;
            lastOperationSummary = null;

            string[] prefabPaths = GetPrefabPaths();
            if (prefabPaths.Length == 0)
                return;

            scannedPrefabCount = prefabPaths.Length;
            bool canceled = false;
            try
            {
                for (int i = 0; i < prefabPaths.Length; i++)
                {
                    string path = prefabPaths[i];
                    if (EditorUtility.DisplayCancelableProgressBar(
                            "扫描粒子最大数量",
                            $"{path}  ({i + 1}/{prefabPaths.Length})",
                            (i + 1) / (float)prefabPaths.Length))
                    {
                        canceled = true;
                        break;
                    }

                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                    if (prefab == null)
                        continue;

                    var particles = prefab.GetComponentsInChildren<ParticleSystem>(true);
                    if (particles.Length == 0)
                        continue;

                    particlePrefabCount++;
                    scannedParticleCount += particles.Length;
                    var report = new PrefabReport(path, prefab.name);
                    foreach (var particle in particles)
                    {
                        int maxParticles = particle.main.maxParticles;
                        if (maxParticles <= MaxParticleCount)
                            continue;

                        AssetDatabase.TryGetGUIDAndLocalFileIdentifier(
                            particle, out string assetGuid, out long localFileId);
                        report.Particles.Add(new ParticleReport(
                            GetTransformAddress(prefab.transform, particle.transform),
                            GetComponentIndex(particle),
                            GetHierarchyPath(prefab.transform, particle.transform),
                            assetGuid,
                            localFileId,
                            maxParticles));
                    }

                    if (report.Particles.Count > 0)
                        reports.Add(report);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            if (canceled)
            {
                lastOperationSummary = "扫描已取消，当前结果不完整；执行修改前请重新完整扫描。";
            }
            else
            {
                hasCompleteScan = true;
                if (reports.Count == 0 && showEmptyDialog)
                    EditorUtility.DisplayDialog("扫描完成", $"没有发现 Max Particles 大于 {MaxParticleCount} 的粒子系统。", "确定");
            }

            Repaint();
        }

        private void ApplyLimit()
        {
            int expectedParticleCount = reports.Sum(report => report.Particles.Count);
            if (!EditorUtility.DisplayDialog(
                    "确认修改",
                    $"将修改 {reports.Count} 个 Prefab 中的 {expectedParticleCount} 个 ParticleSystem。\n\n" +
                    $"只把 Max Particles 从大于 {MaxParticleCount} 的当前值改为 {MaxParticleCount}；应用前会再次核对目标与当前值。\n" +
                    "该批量操作不支持整体撤销，建议先确认版本控制状态。是否继续？",
                    "修改", "取消"))
                return;

            int changedPrefabs = 0;
            int changedParticles = 0;
            int skippedParticles = 0;
            int failedPrefabs = 0;
            bool canceled = false;

            AssetDatabase.StartAssetEditing();
            try
            {
                for (int i = 0; i < reports.Count; i++)
                {
                    PrefabReport report = reports[i];
                    if (EditorUtility.DisplayCancelableProgressBar(
                            "限制粒子最大数量",
                            $"{report.PrefabPath}  ({i + 1}/{reports.Count})",
                            (i + 1) / (float)reports.Count))
                    {
                        canceled = true;
                        break;
                    }

                    GameObject root = null;
                    try
                    {
                        root = PrefabUtility.LoadPrefabContents(report.PrefabPath);
                        int changedInPrefab = 0;
                        foreach (var particleReport in report.Particles)
                        {
                            ParticleSystem particle = ResolveParticle(root, particleReport);
                            if (particle == null || !MatchesRecordedObject(particle, particleReport))
                            {
                                skippedParticles++;
                                continue;
                            }

                            var main = particle.main;
                            if (main.maxParticles <= MaxParticleCount)
                            {
                                skippedParticles++;
                                continue;
                            }

                            main.maxParticles = MaxParticleCount;
                            EditorUtility.SetDirty(particle);
                            changedInPrefab++;
                        }

                        if (changedInPrefab > 0)
                        {
                            PrefabUtility.SaveAsPrefabAsset(root, report.PrefabPath, out bool saveSucceeded);
                            if (!saveSucceeded)
                                throw new InvalidOperationException("Prefab 保存失败。");

                            changedPrefabs++;
                            changedParticles += changedInPrefab;
                        }
                    }
                    catch (Exception exception)
                    {
                        failedPrefabs++;
                        Debug.LogError($"[ParticleMaxCountLimiter] 处理失败：{report.PrefabPath}\n{exception}");
                    }
                    finally
                    {
                        if (root != null)
                            PrefabUtility.UnloadPrefabContents(root);
                    }
                }
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
                EditorUtility.ClearProgressBar();
            }

            AssetDatabase.SaveAssets();
            string cancelText = canceled ? "（用户中途取消，已保留此前完成的修改）" : string.Empty;
            string completedSummary =
                $"修改完成{cancelText}：更新 {changedPrefabs} 个 Prefab、{changedParticles} 个 ParticleSystem；" +
                $"跳过 {skippedParticles} 个已变化或无法精确匹配的目标；失败 Prefab {failedPrefabs} 个。";
            Debug.Log($"[ParticleMaxCountLimiter] {completedSummary}");
            EditorUtility.DisplayDialog("处理完成", completedSummary, "确定");

            Scan(false);
            lastOperationSummary = completedSummary;
            Repaint();
        }

        private string[] GetPrefabPaths()
        {
            string[] paths = scanFolders
                .Where(folder => folder != null)
                .Select(AssetDatabase.GetAssetPath)
                .Where(IsValidAssetsFolder)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToArray();

            if (paths.Length == 0)
            {
                EditorUtility.DisplayDialog("无法扫描", "请至少指定一个有效的 Assets 目录。", "确定");
                return Array.Empty<string>();
            }

            return AssetDatabase.FindAssets("t:Prefab", paths)
                .Select(AssetDatabase.GUIDToAssetPath)
                .Where(path => path.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
                .ToArray();
        }

        private static bool IsValidAssetsFolder(string path)
        {
            return !string.IsNullOrEmpty(path)
                   && (string.Equals(path, "Assets", StringComparison.OrdinalIgnoreCase)
                       || path.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase))
                   && AssetDatabase.IsValidFolder(path);
        }

        private static ParticleSystem ResolveParticle(GameObject root, ParticleReport report)
        {
            Transform target = FindTransformByAddress(root.transform, report.TransformAddress);
            if (target == null || GetHierarchyPath(root.transform, target) != report.HierarchyPath)
                return null;

            var components = target.GetComponents<ParticleSystem>();
            return report.ComponentIndex >= 0 && report.ComponentIndex < components.Length
                ? components[report.ComponentIndex]
                : null;
        }

        private static bool MatchesRecordedObject(ParticleSystem particle, ParticleReport report)
        {
            if (string.IsNullOrEmpty(report.AssetGuid) || report.LocalFileId == 0)
                return true;

            if (!AssetDatabase.TryGetGUIDAndLocalFileIdentifier(
                    particle, out string currentGuid, out long currentLocalFileId))
                return true;

            return string.Equals(currentGuid, report.AssetGuid, StringComparison.OrdinalIgnoreCase)
                   && currentLocalFileId == report.LocalFileId;
        }

        private static int GetComponentIndex(ParticleSystem particle)
        {
            var components = particle.GetComponents<ParticleSystem>();
            for (int i = 0; i < components.Length; i++)
            {
                if (components[i] == particle)
                    return i;
            }
            return -1;
        }

        private static int[] GetTransformAddress(Transform root, Transform target)
        {
            var indices = new Stack<int>();
            Transform current = target;
            while (current != null && current != root)
            {
                indices.Push(current.GetSiblingIndex());
                current = current.parent;
            }
            return current == root ? indices.ToArray() : Array.Empty<int>();
        }

        private static Transform FindTransformByAddress(Transform root, IReadOnlyList<int> address)
        {
            Transform current = root;
            for (int i = 0; i < address.Count; i++)
            {
                int childIndex = address[i];
                if (childIndex < 0 || childIndex >= current.childCount)
                    return null;
                current = current.GetChild(childIndex);
            }
            return current;
        }

        private static string GetHierarchyPath(Transform root, Transform target)
        {
            var names = new Stack<string>();
            Transform current = target;
            while (current != null)
            {
                names.Push(current.name);
                if (current == root)
                    break;
                current = current.parent;
            }
            return string.Join("/", names);
        }

        private void LoadFolders()
        {
            scanFolders.Clear();
            string saved = EditorPrefs.GetString(FolderPrefsKey, "Assets");
            foreach (string path in saved.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (IsValidAssetsFolder(path))
                    scanFolders.Add(AssetDatabase.LoadAssetAtPath<DefaultAsset>(path));
            }

            if (scanFolders.Count == 0)
                scanFolders.Add(AssetDatabase.LoadAssetAtPath<DefaultAsset>("Assets"));
        }

        private void SaveFolders()
        {
            string value = string.Join("|", scanFolders
                .Where(folder => folder != null)
                .Select(AssetDatabase.GetAssetPath)
                .Where(IsValidAssetsFolder)
                .Distinct(StringComparer.OrdinalIgnoreCase));
            EditorPrefs.SetString(FolderPrefsKey, value);
        }

        private void InvalidateResults()
        {
            reports.Clear();
            reportFoldouts.Clear();
            scannedPrefabCount = 0;
            particlePrefabCount = 0;
            scannedParticleCount = 0;
            hasCompleteScan = false;
            lastOperationSummary = null;
        }

        private static void SelectAsset(string path)
        {
            var asset = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (asset == null)
                return;
            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }

        private sealed class PrefabReport
        {
            public readonly string PrefabPath;
            public readonly string PrefabName;
            public readonly List<ParticleReport> Particles = new List<ParticleReport>();

            public PrefabReport(string prefabPath, string prefabName)
            {
                PrefabPath = prefabPath;
                PrefabName = prefabName;
            }
        }

        private readonly struct ParticleReport
        {
            public readonly int[] TransformAddress;
            public readonly int ComponentIndex;
            public readonly string HierarchyPath;
            public readonly string AssetGuid;
            public readonly long LocalFileId;
            public readonly int OriginalMaxParticles;

            public ParticleReport(
                int[] transformAddress,
                int componentIndex,
                string hierarchyPath,
                string assetGuid,
                long localFileId,
                int originalMaxParticles)
            {
                TransformAddress = transformAddress;
                ComponentIndex = componentIndex;
                HierarchyPath = hierarchyPath;
                AssetGuid = assetGuid;
                LocalFileId = localFileId;
                OriginalMaxParticles = originalMaxParticles;
            }
        }
    }
}
