using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.Utilities
{
    public class EmptyParticleSystemCleanerWindow : EditorWindow
    {
        private const string MenuPath = "TATools/VFXTools/Utilities/空粒子系统清理";
        private const string FolderPrefsKey = "VFXTools.EmptyParticleSystemCleaner.Folders";

        private readonly List<DefaultAsset> scanFolders = new List<DefaultAsset>();
        private readonly List<PrefabReport> reports = new List<PrefabReport>();
        private readonly List<string> scannedEffectPrefabPaths = new List<string>();
        private Vector2 folderScroll;
        private Vector2 resultScroll;
        private int scannedPrefabCount;
        private int effectPrefabCount;
        private bool addPreviewAfterClean;
        private bool scanCompleted;

        [MenuItem(MenuPath, false, 121)]
        public static void Open()
        {
            var window = GetWindow<EmptyParticleSystemCleanerWindow>("空粒子清理");
            window.minSize = new Vector2(560f, 420f);
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
            EditorGUILayout.LabelField("空粒子系统清理", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(
                "特效 Prefab：自身或子物体包含 ParticleSystem，且整个层级不包含 SpriteRenderer 或 UIParticle；包含 UIParticle 时跳过整个 Prefab。\n" +
                "空粒子残留：空 ParticleSystem 及其配套 ParticleSystemRenderer，或没有 ParticleSystem 的孤立 ParticleSystemRenderer。\n" +
                "清理时仅移除上述粒子相关组件，保留 GameObject 与所有其它组件和参数。",
                MessageType.Info);

            DrawFolderSection();

            addPreviewAfterClean = EditorGUILayout.ToggleLeft(
                "清理后为被清理 Prefab 的根物体添加 ParticleGroupPlayer",
                addPreviewAfterClean);

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("扫描", GUILayout.Height(28f)))
                    Scan();

                using (new EditorGUI.DisabledScope(reports.Count == 0))
                {
                    if (GUILayout.Button($"清理 {reports.Sum(report => report.Remnants.Count)} 个粒子组件组", GUILayout.Height(28f)))
                        Clean();
                }
            }

            using (new EditorGUI.DisabledScope(!scanCompleted || scannedEffectPrefabPaths.Count == 0))
            {
                if (GUILayout.Button("批量设置预览组件", GUILayout.Height(30f)))
                    BatchSetupPreviewComponents();
            }

            EditorGUILayout.Space(4f);
            EditorGUILayout.LabelField(
                $"扫描 Prefab：{scannedPrefabCount}  |  特效 Prefab：{effectPrefabCount}  |  待清理 Prefab：{reports.Count}  |  粒子组件组：{reports.Sum(report => report.Remnants.Count)}",
                EditorStyles.boldLabel);

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
                        var selected = (DefaultAsset)EditorGUILayout.ObjectField(scanFolders[i], typeof(DefaultAsset), false);
                        if (selected != scanFolders[i])
                        {
                            string path = selected != null ? AssetDatabase.GetAssetPath(selected) : string.Empty;
                            if (selected == null || AssetDatabase.IsValidFolder(path))
                            {
                                scanFolders[i] = selected;
                                InvalidateResults();
                                SaveFolders();
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
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        if (GUILayout.Button(report.PrefabName, EditorStyles.linkLabel))
                            SelectAsset(report.PrefabPath);
                        GUILayout.FlexibleSpace();
                        GUILayout.Label($"{report.Remnants.Count} 组", EditorStyles.miniBoldLabel);
                    }

                    EditorGUILayout.SelectableLabel(report.PrefabPath, EditorStyles.wordWrappedMiniLabel,
                        GUILayout.MinHeight(EditorGUIUtility.singleLineHeight * 2f));
                    foreach (var remnant in report.Remnants)
                        EditorGUILayout.LabelField($"• {remnant.HierarchyPath}：{remnant.Reason}", EditorStyles.wordWrappedMiniLabel);
                }
            }
            EditorGUILayout.EndScrollView();
        }

        private void Scan(IEnumerable<string> retainedEffectPrefabPaths = null)
        {
            var retainedPaths = retainedEffectPrefabPaths != null
                ? new HashSet<string>(retainedEffectPrefabPaths, StringComparer.OrdinalIgnoreCase)
                : null;
            reports.Clear();
            scannedEffectPrefabPaths.Clear();
            scannedPrefabCount = 0;
            effectPrefabCount = 0;
            scanCompleted = false;

            string[] prefabPaths = GetPrefabPaths();
            scannedPrefabCount = prefabPaths.Length;
            bool canceled = false;
            try
            {
                for (int i = 0; i < prefabPaths.Length; i++)
                {
                    string path = prefabPaths[i];
                    if (EditorUtility.DisplayCancelableProgressBar("扫描空粒子系统", path,
                            i / (float)Math.Max(prefabPaths.Length, 1)))
                    {
                        canceled = true;
                        break;
                    }

                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                    if (prefab == null)
                        continue;

                    var particles = prefab.GetComponentsInChildren<ParticleSystem>(true);
                    bool isEligibleEffect = IsEffectPrefab(prefab, particles);
                    bool retainCleanedEffect = retainedPaths != null
                                               && retainedPaths.Contains(path)
                                               && particles.Length == 0
                                               && prefab.GetComponentInChildren<SpriteRenderer>(true) == null
                                               && !HasUIParticle(prefab);
                    if (!isEligibleEffect && !retainCleanedEffect)
                        continue;

                    effectPrefabCount++;
                    scannedEffectPrefabPaths.Add(path);
                    var report = new PrefabReport(path, prefab.name);
                    foreach (var particle in particles)
                    {
                        string reason = GetEmptyReason(particle);
                        if (!string.IsNullOrEmpty(reason))
                        {
                            report.Remnants.Add(new ParticleRemnantReport(
                                GetTransformAddress(prefab.transform, particle.transform),
                                GetHierarchyPath(prefab.transform, particle.transform),
                                reason,
                                true));
                        }
                    }

                    foreach (var renderer in prefab.GetComponentsInChildren<ParticleSystemRenderer>(true))
                    {
                        if (renderer.GetComponent<ParticleSystem>() != null)
                            continue;

                        report.Remnants.Add(new ParticleRemnantReport(
                            GetTransformAddress(prefab.transform, renderer.transform),
                            GetHierarchyPath(prefab.transform, renderer.transform),
                            "孤立 ParticleSystemRenderer（缺少 ParticleSystem）",
                            false));
                    }

                    if (report.Remnants.Count > 0)
                        reports.Add(report);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            scanCompleted = !canceled;
            if (canceled)
            {
                reports.Clear();
                scannedEffectPrefabPaths.Clear();
                effectPrefabCount = 0;
            }

            Repaint();
        }

        private void Clean()
        {
            int remnantCount = reports.Sum(report => report.Remnants.Count);
            if (!EditorUtility.DisplayDialog("确认清理",
                    $"将修改 {reports.Count} 个 Prefab，清理 {remnantCount} 组空粒子相关组件（空 ParticleSystem 及配套 Renderer，或孤立 Renderer）。\nGameObject、其它组件及参数均会保留。\n\n建议先确认版本控制状态。是否继续？",
                    "清理", "取消"))
                return;

            int changedPrefabs = 0;
            int removedComponentGroups = 0;
            int addedPlayers = 0;
            string[] scannedTargets = scannedEffectPrefabPaths.ToArray();
            try
            {
                for (int i = 0; i < reports.Count; i++)
                {
                    string path = reports[i].PrefabPath;
                    if (EditorUtility.DisplayCancelableProgressBar("清理空粒子系统", path,
                            i / (float)Math.Max(reports.Count, 1)))
                        break;

                    GameObject root = PrefabUtility.LoadPrefabContents(path);
                    try
                    {
                        var particles = root.GetComponentsInChildren<ParticleSystem>(true);
                        if (!IsEffectPrefab(root, particles))
                        {
                            Debug.LogWarning($"[EmptyParticleSystemCleaner] 已跳过不再符合特效定义的 Prefab：{path}");
                            continue;
                        }

                        int removedInPrefab = CleanReportedRemnants(root, reports[i]);
                        bool addedPreview = false;
                        if (removedInPrefab > 0 && addPreviewAfterClean && root.GetComponent<ParticleGroupPlayer>() == null)
                        {
                            root.AddComponent<ParticleGroupPlayer>();
                            addedPreview = true;
                        }

                        if (removedInPrefab > 0 || addedPreview)
                        {
                            PrefabUtility.SaveAsPrefabAsset(root, path);
                            changedPrefabs++;
                            removedComponentGroups += removedInPrefab;
                            if (addedPreview) addedPlayers++;
                        }
                    }
                    finally
                    {
                        PrefabUtility.UnloadPrefabContents(root);
                    }
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"[EmptyParticleSystemCleaner] 清理完成：修改 {changedPrefabs} 个 Prefab，清理 {removedComponentGroups} 组空粒子相关组件，添加 {addedPlayers} 个 ParticleGroupPlayer。");
            EditorUtility.DisplayDialog("清理完成",
                $"修改 {changedPrefabs} 个 Prefab，清理 {removedComponentGroups} 组空粒子相关组件，添加 {addedPlayers} 个 ParticleGroupPlayer。", "确定");
            Scan(scannedTargets);
        }

        private void BatchSetupPreviewComponents()
        {
            if (!EditorUtility.DisplayDialog("批量设置预览组件",
                    $"将处理本次完整扫描到的 {scannedEffectPrefabPaths.Count} 个特效 Prefab。\n存在空粒子残留时会先清理，再在根物体添加 ParticleGroupPlayer。\n\n是否继续？",
                    "执行", "取消"))
                return;

            var reportsByPath = reports.ToDictionary(report => report.PrefabPath, StringComparer.OrdinalIgnoreCase);
            string[] scannedTargets = scannedEffectPrefabPaths.ToArray();
            int changedPrefabs = 0;
            int cleanedGroups = 0;
            int addedPlayers = 0;
            try
            {
                for (int i = 0; i < scannedEffectPrefabPaths.Count; i++)
                {
                    string path = scannedEffectPrefabPaths[i];
                    if (EditorUtility.DisplayCancelableProgressBar("批量设置预览组件", path,
                            i / (float)Math.Max(scannedEffectPrefabPaths.Count, 1)))
                        break;

                    GameObject root = PrefabUtility.LoadPrefabContents(path);
                    try
                    {
                        var particles = root.GetComponentsInChildren<ParticleSystem>(true);
                        bool isEligibleEffect = IsEffectPrefab(root, particles);
                        bool isRetainedCleanedEffect = particles.Length == 0
                                                       && root.GetComponentInChildren<SpriteRenderer>(true) == null
                                                       && !HasUIParticle(root);
                        if (!isEligibleEffect && !isRetainedCleanedEffect)
                        {
                            Debug.LogWarning($"[EmptyParticleSystemCleaner] 已跳过不再符合特效定义的 Prefab：{path}");
                            continue;
                        }

                        int cleanedInPrefab = reportsByPath.TryGetValue(path, out var report)
                            ? CleanReportedRemnants(root, report)
                            : 0;
                        bool addedPlayer = false;
                        if (root.GetComponent<ParticleGroupPlayer>() == null)
                        {
                            root.AddComponent<ParticleGroupPlayer>();
                            addedPlayer = true;
                        }

                        if (cleanedInPrefab > 0 || addedPlayer)
                        {
                            PrefabUtility.SaveAsPrefabAsset(root, path);
                            changedPrefabs++;
                            cleanedGroups += cleanedInPrefab;
                            if (addedPlayer) addedPlayers++;
                        }
                    }
                    finally
                    {
                        PrefabUtility.UnloadPrefabContents(root);
                    }
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"[EmptyParticleSystemCleaner] 批量设置完成：修改 {changedPrefabs} 个 Prefab，清理 {cleanedGroups} 组残留，添加 {addedPlayers} 个 ParticleGroupPlayer。");
            EditorUtility.DisplayDialog("设置完成",
                $"修改 {changedPrefabs} 个 Prefab，清理 {cleanedGroups} 组残留，添加 {addedPlayers} 个 ParticleGroupPlayer。", "确定");
            Scan(scannedTargets);
        }

        private static int CleanReportedRemnants(GameObject root, PrefabReport report)
        {
            int removed = 0;
            foreach (var remnant in report.Remnants)
            {
                Transform target = FindTransformByAddress(root.transform, remnant.TransformAddress);
                if (target == null)
                    continue;

                if (remnant.HasParticleSystem)
                {
                    var particle = target.GetComponent<ParticleSystem>();
                    if (particle == null || string.IsNullOrEmpty(GetEmptyReason(particle)))
                        continue;

                    var renderer = target.GetComponent<ParticleSystemRenderer>();
                    if (renderer != null)
                        DestroyImmediate(renderer, true);
                    DestroyImmediate(particle, true);
                    removed++;
                    continue;
                }

                var orphanRenderer = target.GetComponent<ParticleSystemRenderer>();
                if (orphanRenderer == null || target.GetComponent<ParticleSystem>() != null)
                    continue;

                DestroyImmediate(orphanRenderer, true);
                removed++;
            }

            return removed;
        }

        private string[] GetPrefabPaths()
        {
            string[] paths = scanFolders
                .Where(folder => folder != null)
                .Select(AssetDatabase.GetAssetPath)
                .Where(AssetDatabase.IsValidFolder)
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

        private static bool IsEffectPrefab(GameObject root, ParticleSystem[] particles)
        {
            return root != null
                   && particles != null
                   && particles.Length > 0
                   && root.GetComponentInChildren<SpriteRenderer>(true) == null
                   && !HasUIParticle(root);
        }

        private static bool HasUIParticle(GameObject root)
        {
            var components = root.GetComponentsInChildren<Component>(true);
            foreach (var component in components)
            {
                if (component != null
                    && component.GetType().FullName == "Coffee.UIExtensions.UIParticle")
                    return true;
            }

            return false;
        }

        private static string GetEmptyReason(ParticleSystem particle)
        {
            var reasons = new List<string>(3);
            if (!particle.emission.enabled)
                reasons.Add("Emission 未启用");

            var renderer = particle.GetComponent<ParticleSystemRenderer>();
            if (renderer == null || !renderer.enabled)
                reasons.Add("Renderer 未启用");

            if (particle.main.maxParticles == 0)
                reasons.Add("Max Particles 为 0");

            return string.Join("、", reasons);
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
                if (AssetDatabase.IsValidFolder(path))
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
                .Where(AssetDatabase.IsValidFolder)
                .Distinct(StringComparer.OrdinalIgnoreCase));
            EditorPrefs.SetString(FolderPrefsKey, value);
        }

        private void InvalidateResults()
        {
            reports.Clear();
            scannedEffectPrefabPaths.Clear();
            scannedPrefabCount = 0;
            effectPrefabCount = 0;
            scanCompleted = false;
        }

        private static void SelectAsset(string path)
        {
            var asset = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (asset == null)
                return;
            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }

        private class PrefabReport
        {
            public readonly string PrefabPath;
            public readonly string PrefabName;
            public readonly List<ParticleRemnantReport> Remnants = new List<ParticleRemnantReport>();

            public PrefabReport(string prefabPath, string prefabName)
            {
                PrefabPath = prefabPath;
                PrefabName = prefabName;
            }
        }

        private readonly struct ParticleRemnantReport
        {
            public readonly int[] TransformAddress;
            public readonly string HierarchyPath;
            public readonly string Reason;
            public readonly bool HasParticleSystem;

            public ParticleRemnantReport(int[] transformAddress, string hierarchyPath, string reason, bool hasParticleSystem)
            {
                TransformAddress = transformAddress;
                HierarchyPath = hierarchyPath;
                Reason = reason;
                HasParticleSystem = hasParticleSystem;
            }
        }
    }
}
