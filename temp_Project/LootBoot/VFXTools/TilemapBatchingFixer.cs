using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

/// <summary>
    /// Tilemap 合批修复工具窗口。
    /// 将 TilemapRenderer 材质统一替换，并修复 Individual → Chunk 渲染模式。
    /// </summary>
    public class TilemapBatchingFixerWindow : EditorWindow
    {
        private const string DEFAULT_UNLIT_MAT_GUID = "9dfc825aed78fcd4ba02077103263b40";
        private const string DEFAULT_SEARCH_FOLDER  = "Assets/GameAsset/Prefab/Stage";
        private const string PREF_SEARCH_FOLDER     = "TilemapFixer_SearchFolder";
        private const string PREF_UNLIT_MAT_GUID    = "TilemapFixer_UnlitMatGuid";

        private Material targetMaterial;
        private string searchFolder;

        // ─────────────────────────────────────────────────────────────────
        [MenuItem("TATools/Tilemap/打开合批修复工具")]
        public static void OpenWindow()
        {
            var win = GetWindow<TilemapBatchingFixerWindow>("Tilemap 合批修复");
            win.minSize = new Vector2(420, 260);
            win.Show();
        }

        // ─────────────────────────────────────────────────────────────────
        private void OnEnable()
        {
            searchFolder = EditorPrefs.GetString(PREF_SEARCH_FOLDER, DEFAULT_SEARCH_FOLDER);

            string matGuid = EditorPrefs.GetString(PREF_UNLIT_MAT_GUID, DEFAULT_UNLIT_MAT_GUID);
            string matPath = AssetDatabase.GUIDToAssetPath(matGuid);
            targetMaterial = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        }

        // ─────────────────────────────────────────────────────────────────
        private void OnGUI()
        {
            // ── 配置区 ────────────────────────────────────────────────────
            EditorGUILayout.Space(6);
            EditorGUILayout.LabelField("配置", EditorStyles.boldLabel);

            EditorGUI.BeginChangeCheck();

            targetMaterial = (Material)EditorGUILayout.ObjectField(
                new GUIContent("目标材质", "替换后使用的 TilemapRenderer 材质"),
                targetMaterial, typeof(Material), false);

            EditorGUILayout.BeginHorizontal();
            searchFolder = EditorGUILayout.TextField(
                new GUIContent("搜索目录", "将递归搜索此目录下的所有 Prefab"),
                searchFolder);
            if (GUILayout.Button("浏览", GUILayout.Width(46)))
            {
                string selected = EditorUtility.OpenFolderPanel("选择 Prefab 目录", "Assets", "");
                if (!string.IsNullOrEmpty(selected))
                {
                    if (selected.StartsWith(Application.dataPath))
                        selected = "Assets" + selected.Substring(Application.dataPath.Length);
                    searchFolder = selected.Replace('\\', '/');
                    GUI.FocusControl(null);
                }
            }
            EditorGUILayout.EndHorizontal();

            if (EditorGUI.EndChangeCheck())
            {
                EditorPrefs.SetString(PREF_SEARCH_FOLDER, searchFolder);
                if (targetMaterial != null)
                    EditorPrefs.SetString(PREF_UNLIT_MAT_GUID,
                        AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(targetMaterial)));
            }

            // ── 操作区 ────────────────────────────────────────────────────
            EditorGUILayout.Space(12);
            EditorGUILayout.LabelField("操作", EditorStyles.boldLabel);

            bool folderValid = !string.IsNullOrWhiteSpace(searchFolder);

            // 操作 1：统一材质
            EditorGUILayout.HelpBox(
                "将搜索目录下所有 Prefab 的 TilemapRenderer 材质替换为上方指定的材质。",
                MessageType.None);
            using (new EditorGUI.DisabledScope(targetMaterial == null || !folderValid))
            {
                if (GUILayout.Button("[自动] 统一 TilemapRenderer 材质", GUILayout.Height(30)))
                    FixAllTilemapMaterials();
            }

            EditorGUILayout.Space(8);

            // 操作 2：统一 Chunk 模式
            EditorGUILayout.HelpBox(
                "将搜索目录下所有 Prefab 中 Individual 模式的 TilemapRenderer 改为 Chunk 模式。\n操作前请确认 Git 状态，此操作不可撤销。",
                MessageType.Warning);
            using (new EditorGUI.DisabledScope(!folderValid))
            {
                if (GUILayout.Button("[手动] 统一渲染模式为 Chunk", GUILayout.Height(30)))
                    FixAllTilemapModes();
            }

            EditorGUILayout.Space(6);
        }

        // ─────────────────────────────────────────────────────────────────
        private void FixAllTilemapMaterials()
        {
            string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { searchFolder });
            int fixedRenderers = 0, fixedPrefabs = 0;

            try
            {
                for (int i = 0; i < guids.Length; i++)
                {
                    string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                    EditorUtility.DisplayProgressBar("统一 TilemapRenderer 材质",
                        $"{Path.GetFileName(path)}  ({i + 1}/{guids.Length})",
                        (float)(i + 1) / guids.Length);

                    using var scope = new PrefabUtility.EditPrefabContentsScope(path);
                    bool dirty = false;

                    foreach (var tr in scope.prefabContentsRoot.GetComponentsInChildren<TilemapRenderer>(true))
                    {
                        if (tr.sharedMaterial == targetMaterial) continue;
                        tr.sharedMaterial = targetMaterial;
                        dirty = true;
                        fixedRenderers++;
                    }

                    if (dirty) fixedPrefabs++;
                }
            }
            finally { EditorUtility.ClearProgressBar(); }

            AssetDatabase.SaveAssets();
            Debug.Log($"[TilemapFixer] TilemapRenderer 材质修复完成：{fixedPrefabs} 个 Prefab，共 {fixedRenderers} 个已更新为 {targetMaterial.name}。");
        }

        // ─────────────────────────────────────────────────────────────────
        private void FixAllTilemapModes()
        {
            if (!EditorUtility.DisplayDialog(
                    "Tilemap 渲染模式修复",
                    $"将把 {searchFolder} 下所有 Prefab 中处于 Individual 模式的 TilemapRenderer 改为 Chunk 模式。\n\n此操作不可撤销，请先确认 Git 状态后继续。",
                    "继续修复", "取消"))
                return;

            string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { searchFolder });
            int fixedRenderers = 0, fixedPrefabs = 0;

            try
            {
                for (int i = 0; i < guids.Length; i++)
                {
                    string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                    EditorUtility.DisplayProgressBar("统一 Tilemap 渲染模式",
                        $"{Path.GetFileName(path)}  ({i + 1}/{guids.Length})",
                        (float)(i + 1) / guids.Length);

                    using var scope = new PrefabUtility.EditPrefabContentsScope(path);
                    bool dirty = false;

                    foreach (var tr in scope.prefabContentsRoot.GetComponentsInChildren<TilemapRenderer>(true))
                    {
                        if (tr.mode == TilemapRenderer.Mode.Chunk) continue;
                        tr.mode = TilemapRenderer.Mode.Chunk;
                        dirty = true;
                        fixedRenderers++;
                    }

                    if (dirty) fixedPrefabs++;
                }
            }
            finally { EditorUtility.ClearProgressBar(); }

            AssetDatabase.SaveAssets();
            Debug.Log($"[TilemapFixer] 模式修复完成：{fixedPrefabs} 个 Prefab，共 {fixedRenderers} 个 TilemapRenderer 已改为 Chunk 模式。");
        }
    }