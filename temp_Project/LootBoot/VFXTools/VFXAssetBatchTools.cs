using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

// Made by Copilot, 2026.5.26, Using Claude Sonnet 4.6
// 资源批处理工具箱 — 合并: MaterialShaderReplacer / TextureCrunchFinder / TilemapBatchingFixer / ParticleDelayModifier

#if UNITY_EDITOR

/// <summary>
/// 资源批处理工具箱：材质 Shader 替换 / Crunch 检测 / Tilemap 修复 / 粒子延迟修改
/// </summary>
public class VFXAssetBatchTools : EditorWindow
{
    private int activeTab = 0;
    private readonly string[] TAB_NAMES = { "材质 Shader 替换", "Crunch 检测", "Tilemap 修复", "粒子延迟" };

    [MenuItem("TATools/ToolHub/整合 - 资源批量处理")]
    public static void OpenWindow()
    {
        var window = GetWindow<VFXAssetBatchTools>("资源批处理工具箱");
        window.minSize = new Vector2(520, 440);
    }

    void OnEnable() { TmfLoadPrefs(); }

    void OnGUI()
    {
        activeTab = GUILayout.Toolbar(activeTab, TAB_NAMES);
        EditorGUILayout.Space(6);
        switch (activeTab)
        {
            case 0: DrawShaderReplacerTab(); break;
            case 1: DrawCrunchFinderTab();   break;
            case 2: DrawTilemapFixerTab();   break;
            case 3: DrawParticleDelayTab();  break;
        }
    }

    // ────────────────────────────────────────────────────────────
    // 辅助：分隔线
    // ────────────────────────────────────────────────────────────
    private static void DrawLine()
    {
        var rect = EditorGUILayout.GetControlRect(false, 1);
        EditorGUI.DrawRect(rect, new Color(0.5f, 0.5f, 0.5f, 0.5f));
    }

    // ============================================================
    // TAB 0: 材质 Shader 批量替换
    // ============================================================
    private Shader msrSourceShader;
    private Shader msrTargetShader;
    private readonly List<string> msrFoundPaths = new List<string>();
    private Vector2 msrScrollPos;
    private bool msrHasScanned;

    private void DrawShaderReplacerTab()
    {
        EditorGUILayout.LabelField("将项目中所有使用 Source Shader 的材质替换为 Target Shader，共有属性值将被保留。", EditorStyles.wordWrappedMiniLabel);
        EditorGUILayout.Space(4);

        EditorGUI.BeginChangeCheck();
        msrSourceShader = (Shader)EditorGUILayout.ObjectField("Source Shader (A)", msrSourceShader, typeof(Shader), false);
        msrTargetShader = (Shader)EditorGUILayout.ObjectField("Target Shader (B)", msrTargetShader, typeof(Shader), false);
        if (EditorGUI.EndChangeCheck()) { msrHasScanned = false; msrFoundPaths.Clear(); }

        EditorGUILayout.Space(6);

        using (new EditorGUI.DisabledScope(msrSourceShader == null || msrTargetShader == null))
        {
            if (GUILayout.Button("扫描使用 Source Shader 的材质", GUILayout.Height(28)))
                MsrScanMaterials();
        }

        if (!msrHasScanned) return;

        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField($"找到 {msrFoundPaths.Count} 个材质", EditorStyles.miniLabel);
        msrScrollPos = EditorGUILayout.BeginScrollView(msrScrollPos, GUILayout.MaxHeight(200));
        foreach (var path in msrFoundPaths)
            EditorGUILayout.LabelField(path, EditorStyles.miniLabel);
        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space(6);
        using (new EditorGUI.DisabledScope(msrFoundPaths.Count == 0))
        {
            GUI.backgroundColor = new Color(1f, 0.6f, 0.4f);
            if (GUILayout.Button($"执行替换（共 {msrFoundPaths.Count} 个材质）", GUILayout.Height(32)))
            {
                if (EditorUtility.DisplayDialog("确认执行",
                    $"将把 {msrFoundPaths.Count} 个材质的 Shader 从\n\"{msrSourceShader.name}\"\n替换为\n\"{msrTargetShader.name}\"\n\n共有属性值将被保留，建议提前做好版本控制。",
                    "执行", "取消"))
                    MsrExecuteReplacement();
            }
            GUI.backgroundColor = Color.white;
        }
    }

    private void MsrScanMaterials()
    {
        msrFoundPaths.Clear();
        msrHasScanned = true;
        string[] guids = AssetDatabase.FindAssets("t:Material", new[] { "Assets" });
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (EditorUtility.DisplayCancelableProgressBar("扫描材质", path, (float)i / guids.Length))
            {
                EditorUtility.ClearProgressBar(); msrFoundPaths.Clear(); msrHasScanned = false; return;
            }
            var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (mat != null && mat.shader == msrSourceShader) msrFoundPaths.Add(path);
        }
        EditorUtility.ClearProgressBar();
        Repaint();
    }

    private void MsrExecuteReplacement()
    {
        var srcMap = MsrBuildPropMap(msrSourceShader);
        int tgtCount = ShaderUtil.GetPropertyCount(msrTargetShader);
        int total = msrFoundPaths.Count, success = 0;
        AssetDatabase.StartAssetEditing();
        try
        {
            for (int i = 0; i < total; i++)
            {
                EditorUtility.DisplayProgressBar("替换 Shader", msrFoundPaths[i], (float)i / total);
                var mat = AssetDatabase.LoadAssetAtPath<Material>(msrFoundPaths[i]);
                if (mat == null) continue;
                var snap = MsrTakeSnapshot(mat, srcMap, msrTargetShader, tgtCount);
                mat.shader = msrTargetShader;
                MsrApplySnapshot(mat, snap);
                EditorUtility.SetDirty(mat);
                success++;
            }
        }
        finally { AssetDatabase.StopAssetEditing(); EditorUtility.ClearProgressBar(); }
        AssetDatabase.SaveAssets(); AssetDatabase.Refresh();
        Debug.Log($"[MaterialShaderReplacer] 替换完成：{success}/{total} 个材质已从 \"{msrSourceShader.name}\" 替换为 \"{msrTargetShader.name}\"");
        EditorUtility.DisplayDialog("完成", $"成功替换 {success} 个材质。", "确定");
    }

    private struct MsrSnapshot
    {
        public Dictionary<string, float>   floats;
        public Dictionary<string, Color>   colors;
        public Dictionary<string, Vector4> vectors;
        public Dictionary<string, Texture> textures;
        public Dictionary<string, int>     ints;
    }

    private static MsrSnapshot MsrTakeSnapshot(Material mat, Dictionary<string, ShaderUtil.ShaderPropertyType> srcMap, Shader tgt, int tgtCount)
    {
        var s = new MsrSnapshot
        {
            floats   = new Dictionary<string, float>(),
            colors   = new Dictionary<string, Color>(),
            vectors  = new Dictionary<string, Vector4>(),
            textures = new Dictionary<string, Texture>(),
            ints     = new Dictionary<string, int>()
        };
        for (int i = 0; i < tgtCount; i++)
        {
            string n = ShaderUtil.GetPropertyName(tgt, i);
            var    t = ShaderUtil.GetPropertyType(tgt, i);
            if (!srcMap.TryGetValue(n, out var st) || st != t) continue;
            switch (t)
            {
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:  s.floats[n]   = mat.GetFloat(n);   break;
                case ShaderUtil.ShaderPropertyType.Color:  s.colors[n]   = mat.GetColor(n);   break;
                case ShaderUtil.ShaderPropertyType.Vector: s.vectors[n]  = mat.GetVector(n);  break;
                case ShaderUtil.ShaderPropertyType.TexEnv: s.textures[n] = mat.GetTexture(n); break;
#if UNITY_2021_1_OR_NEWER
                case ShaderUtil.ShaderPropertyType.Int:    s.ints[n]     = mat.GetInt(n);     break;
#endif
            }
        }
        return s;
    }

    private static void MsrApplySnapshot(Material mat, MsrSnapshot s)
    {
        foreach (var kv in s.floats)   mat.SetFloat(kv.Key, kv.Value);
        foreach (var kv in s.colors)   mat.SetColor(kv.Key, kv.Value);
        foreach (var kv in s.vectors)  mat.SetVector(kv.Key, kv.Value);
        foreach (var kv in s.textures) mat.SetTexture(kv.Key, kv.Value);
        foreach (var kv in s.ints)     mat.SetInt(kv.Key, kv.Value);
    }

    private static Dictionary<string, ShaderUtil.ShaderPropertyType> MsrBuildPropMap(Shader shader)
    {
        int cnt = ShaderUtil.GetPropertyCount(shader);
        var map = new Dictionary<string, ShaderUtil.ShaderPropertyType>(cnt);
        for (int i = 0; i < cnt; i++) map[ShaderUtil.GetPropertyName(shader, i)] = ShaderUtil.GetPropertyType(shader, i);
        return map;
    }

    // ============================================================
    // TAB 1: 贴图 Crunch 压缩检测
    // ============================================================
    private static readonly string[] CRD_PLATFORMS = { "Default", "Standalone", "Android", "iPhone", "WebGL" };

    private DefaultAsset crdScanFolder;
    private string       crdScanFolderPath = "Assets/";
    private bool[]       crdPlatformFilter  = { true, true, true, true, true };
    private string       crdSearchFilter    = "";
    private List<CrunchEntry> crdResults    = new List<CrunchEntry>();
    private Vector2      crdScrollPos;
    private bool         crdHasScanned, crdIsScanning;
    private int          crdTotalScanned;
    private GUIStyle     crdStyleRed, crdStyleBold;
    private bool         crdStylesInited;

    private class CrunchEntry
    {
        public string       assetPath;
        public Texture2D    texture;
        public List<string> crunchedPlatforms = new List<string>();
        public List<int>    crunchQuality     = new List<int>();
    }

    private void InitCrdStyles()
    {
        if (crdStylesInited) return;
        crdStyleRed  = new GUIStyle(EditorStyles.label) { normal = { textColor = new Color(0.9f, 0.2f, 0.2f) }, fontStyle = FontStyle.Bold };
        crdStyleBold = new GUIStyle(EditorStyles.label) { fontStyle = FontStyle.Bold };
        crdStylesInited = true;
    }

    private void DrawCrunchFinderTab()
    {
        InitCrdStyles();
        EditorGUILayout.LabelField("扫描指定目录下所有贴图，列出开启了 Crunch 压缩的导入设置。", EditorStyles.wordWrappedMiniLabel);
        EditorGUILayout.Space(4);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("扫描目录", GUILayout.Width(70));
        var newFolder = (DefaultAsset)EditorGUILayout.ObjectField(crdScanFolder, typeof(DefaultAsset), false, GUILayout.Width(220));
        if (newFolder != crdScanFolder)
        {
            crdScanFolder = newFolder;
            crdScanFolderPath = crdScanFolder != null ? AssetDatabase.GetAssetPath(crdScanFolder) : "Assets/";
        }
        EditorGUILayout.LabelField(crdScanFolderPath, EditorStyles.miniLabel);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("检测平台", GUILayout.Width(70));
        for (int i = 0; i < CRD_PLATFORMS.Length; i++)
            crdPlatformFilter[i] = GUILayout.Toggle(crdPlatformFilter[i], CRD_PLATFORMS[i], GUILayout.Width(90));
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(6);
        EditorGUI.BeginDisabledGroup(crdIsScanning);
        if (GUILayout.Button("开始扫描", GUILayout.Height(28))) CrdRunScan();
        EditorGUI.EndDisabledGroup();

        if (crdIsScanning) { EditorGUILayout.HelpBox("扫描中，请稍候...", MessageType.Info); return; }
        if (!crdHasScanned) return;

        EditorGUILayout.Space(4);
        CrdDrawSummary();
        EditorGUILayout.Space(4);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("搜索路径", GUILayout.Width(60));
        crdSearchFilter = EditorGUILayout.TextField(crdSearchFilter);
        if (GUILayout.Button("清除", GUILayout.Width(46))) crdSearchFilter = "";
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space(2);
        CrdDrawResultList();
    }

    private void CrdDrawSummary()
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.LabelField($"共扫描贴图：{crdTotalScanned} 张     开启 Crunch：{crdResults.Count} 张", crdStyleBold);
        if (crdResults.Count > 0)
        {
            var pp = new Dictionary<string, int>();
            foreach (var e in crdResults) foreach (var p in e.crunchedPlatforms) { if (!pp.ContainsKey(p)) pp[p] = 0; pp[p]++; }
            EditorGUILayout.LabelField("按平台：" + string.Join("  |  ", pp.Select(kv => $"{kv.Key}: {kv.Value}")), EditorStyles.miniLabel);
        }
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("导出到 CSV", GUILayout.Width(120))) CrdExportCSV();
        if (GUILayout.Button("全部选中",   GUILayout.Width(100))) CrdSelectAll();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();
    }

    private void CrdDrawResultList()
    {
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        EditorGUILayout.LabelField("贴图路径",           EditorStyles.toolbarButton, GUILayout.ExpandWidth(true));
        EditorGUILayout.LabelField("开启 Crunch 的平台（质量）", EditorStyles.toolbarButton, GUILayout.Width(280));
        EditorGUILayout.LabelField("定位",               EditorStyles.toolbarButton, GUILayout.Width(46));
        EditorGUILayout.EndHorizontal();

        crdScrollPos = EditorGUILayout.BeginScrollView(crdScrollPos);
        var filtered = string.IsNullOrEmpty(crdSearchFilter)
            ? crdResults
            : crdResults.Where(e => e.assetPath.IndexOf(crdSearchFilter, System.StringComparison.OrdinalIgnoreCase) >= 0).ToList();

        foreach (var entry in filtered)
        {
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button(entry.assetPath, EditorStyles.miniLabel, GUILayout.ExpandWidth(true)))
                EditorGUIUtility.PingObject(entry.texture);
            EditorGUILayout.LabelField(
                string.Join(", ", entry.crunchedPlatforms.Select((p, i) => $"{p}(Q{entry.crunchQuality[i]})")),
                crdStyleRed, GUILayout.Width(280));
            if (GUILayout.Button("→", GUILayout.Width(26)))
            { Selection.activeObject = entry.texture; EditorGUIUtility.PingObject(entry.texture); }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
        if (filtered.Count == 0 && !string.IsNullOrEmpty(crdSearchFilter))
            EditorGUILayout.HelpBox("没有符合过滤条件的结果。", MessageType.None);
    }

    private void CrdRunScan()
    {
        crdResults.Clear(); crdHasScanned = false; crdIsScanning = true; crdTotalScanned = 0; Repaint();
        try
        {
            string[] guids = AssetDatabase.FindAssets("t:Texture2D", new[] { crdScanFolderPath });
            crdTotalScanned = guids.Length;
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                if (EditorUtility.DisplayCancelableProgressBar("扫描 Crunch 压缩", path, (float)i / guids.Length)) break;
                var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer == null) continue;
                var entry = CrdCheckCrunch(path, importer);
                if (entry != null) crdResults.Add(entry);
            }
        }
        finally { EditorUtility.ClearProgressBar(); crdIsScanning = false; crdHasScanned = true; Repaint(); }
    }

    private CrunchEntry CrdCheckCrunch(string path, TextureImporter importer)
    {
        var entry = new CrunchEntry { assetPath = path, texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path) };
        for (int i = 0; i < CRD_PLATFORMS.Length; i++)
        {
            if (!crdPlatformFilter[i]) continue;
            TextureImporterPlatformSettings s;
            if (CRD_PLATFORMS[i] == "Default") { s = importer.GetDefaultPlatformTextureSettings(); }
            else { s = importer.GetPlatformTextureSettings(CRD_PLATFORMS[i]); if (!s.overridden) continue; }
            if (s.crunchedCompression) { entry.crunchedPlatforms.Add(CRD_PLATFORMS[i]); entry.crunchQuality.Add(s.compressionQuality); }
        }
        return entry.crunchedPlatforms.Count > 0 ? entry : null;
    }

    private void CrdExportCSV()
    {
        string savePath = EditorUtility.SaveFilePanel("保存 CSV", "", "CrunchTextures", "csv");
        if (string.IsNullOrEmpty(savePath)) return;
        var sb = new System.Text.StringBuilder();
        sb.AppendLine("贴图路径,开启Crunch的平台,压缩质量");
        foreach (var e in crdResults)
            for (int i = 0; i < e.crunchedPlatforms.Count; i++)
                sb.AppendLine($"\"{e.assetPath}\",{e.crunchedPlatforms[i]},{e.crunchQuality[i]}");
        File.WriteAllText(savePath, sb.ToString(), System.Text.Encoding.UTF8);
        EditorUtility.RevealInFinder(savePath);
        Debug.Log($"[CrunchFinder] CSV 已导出: {savePath}");
    }

    private void CrdSelectAll()
    {
        Selection.objects = crdResults.Where(e => e.texture != null).Select(e => e.texture as Object).ToArray();
    }

    // ============================================================
    // TAB 2: Tilemap 合批修复
    // ============================================================
    private const string PREF_TMF_FOLDER   = "TilemapFixer_SearchFolder";
    private const string PREF_TMF_MAT_GUID = "TilemapFixer_UnlitMatGuid";
    private const string DEFAULT_TMF_MAT_GUID = "9dfc825aed78fcd4ba02077103263b40";
    private const string DEFAULT_TMF_FOLDER   = "Assets/GameAsset/Prefab/Stage";

    private Material tmfTargetMaterial;
    private string   tmfSearchFolder;

    private void TmfLoadPrefs()
    {
        tmfSearchFolder = EditorPrefs.GetString(PREF_TMF_FOLDER, DEFAULT_TMF_FOLDER);
        string matPath = AssetDatabase.GUIDToAssetPath(EditorPrefs.GetString(PREF_TMF_MAT_GUID, DEFAULT_TMF_MAT_GUID));
        tmfTargetMaterial = AssetDatabase.LoadAssetAtPath<Material>(matPath);
    }

    private void DrawTilemapFixerTab()
    {
        EditorGUILayout.LabelField("将 TilemapRenderer 材质统一替换，并修复 Individual → Chunk 渲染模式。", EditorStyles.wordWrappedMiniLabel);
        EditorGUILayout.Space(4);

        EditorGUI.BeginChangeCheck();
        tmfTargetMaterial = (Material)EditorGUILayout.ObjectField(
            new GUIContent("目标材质", "替换后使用的 TilemapRenderer 材质"),
            tmfTargetMaterial, typeof(Material), false);
        EditorGUILayout.BeginHorizontal();
        tmfSearchFolder = EditorGUILayout.TextField(new GUIContent("搜索目录", "递归搜索此目录下的所有 Prefab"), tmfSearchFolder);
        if (GUILayout.Button("浏览", GUILayout.Width(46)))
        {
            string sel = EditorUtility.OpenFolderPanel("选择 Prefab 目录", "Assets", "");
            if (!string.IsNullOrEmpty(sel))
            {
                if (sel.StartsWith(Application.dataPath)) sel = "Assets" + sel.Substring(Application.dataPath.Length);
                tmfSearchFolder = sel.Replace('\\', '/');
                GUI.FocusControl(null);
            }
        }
        EditorGUILayout.EndHorizontal();
        if (EditorGUI.EndChangeCheck())
        {
            EditorPrefs.SetString(PREF_TMF_FOLDER, tmfSearchFolder);
            if (tmfTargetMaterial != null)
                EditorPrefs.SetString(PREF_TMF_MAT_GUID, AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(tmfTargetMaterial)));
        }

        bool folderValid = !string.IsNullOrWhiteSpace(tmfSearchFolder);
        EditorGUILayout.Space(10);

        EditorGUILayout.HelpBox("将搜索目录下所有 Prefab 的 TilemapRenderer 材质替换为上方指定的材质。", MessageType.None);
        using (new EditorGUI.DisabledScope(tmfTargetMaterial == null || !folderValid))
        {
            if (GUILayout.Button("[自动] 统一 TilemapRenderer 材质", GUILayout.Height(30)))
                TmfFixMaterials();
        }

        EditorGUILayout.Space(8);
        EditorGUILayout.HelpBox("将搜索目录下所有 Prefab 中 Individual 模式的 TilemapRenderer 改为 Chunk 模式。\n操作前请确认 Git 状态，此操作不可撤销。", MessageType.Warning);
        using (new EditorGUI.DisabledScope(!folderValid))
        {
            if (GUILayout.Button("[手动] 统一渲染模式为 Chunk", GUILayout.Height(30)))
                TmfFixModes();
        }
    }

    private void TmfFixMaterials()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { tmfSearchFolder });
        int fixedRenderers = 0, fixedPrefabs = 0;
        try
        {
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                EditorUtility.DisplayProgressBar("统一 TilemapRenderer 材质",
                    $"{Path.GetFileName(path)}  ({i + 1}/{guids.Length})", (float)(i + 1) / guids.Length);
                using var scope = new PrefabUtility.EditPrefabContentsScope(path);
                bool dirty = false;
                foreach (var tr in scope.prefabContentsRoot.GetComponentsInChildren<TilemapRenderer>(true))
                {
                    if (tr.sharedMaterial == tmfTargetMaterial) continue;
                    tr.sharedMaterial = tmfTargetMaterial; dirty = true; fixedRenderers++;
                }
                if (dirty) fixedPrefabs++;
            }
        }
        finally { EditorUtility.ClearProgressBar(); }
        AssetDatabase.SaveAssets();
        Debug.Log($"[TilemapFixer] 材质修复完成：{fixedPrefabs} 个 Prefab，共 {fixedRenderers} 个已更新为 {tmfTargetMaterial.name}。");
    }

    private void TmfFixModes()
    {
        if (!EditorUtility.DisplayDialog("Tilemap 渲染模式修复",
            $"将把 {tmfSearchFolder} 下所有 Prefab 中处于 Individual 模式的 TilemapRenderer 改为 Chunk 模式。\n\n此操作不可撤销，请先确认 Git 状态后继续。",
            "继续修复", "取消")) return;

        string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { tmfSearchFolder });
        int fixedRenderers = 0, fixedPrefabs = 0;
        try
        {
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                EditorUtility.DisplayProgressBar("统一 Tilemap 渲染模式",
                    $"{Path.GetFileName(path)}  ({i + 1}/{guids.Length})", (float)(i + 1) / guids.Length);
                using var scope = new PrefabUtility.EditPrefabContentsScope(path);
                bool dirty = false;
                foreach (var tr in scope.prefabContentsRoot.GetComponentsInChildren<TilemapRenderer>(true))
                {
                    if (tr.mode == TilemapRenderer.Mode.Chunk) continue;
                    tr.mode = TilemapRenderer.Mode.Chunk; dirty = true; fixedRenderers++;
                }
                if (dirty) fixedPrefabs++;
            }
        }
        finally { EditorUtility.ClearProgressBar(); }
        AssetDatabase.SaveAssets();
        Debug.Log($"[TilemapFixer] 模式修复完成：{fixedPrefabs} 个 Prefab，共 {fixedRenderers} 个 TilemapRenderer 已改为 Chunk 模式。");
    }

    // ============================================================
    // TAB 3: 粒子延迟修改
    // ============================================================
    private GameObject pdmTargetObject;
    private float      pdmAdditionalDelay = 0f;

    private void DrawParticleDelayTab()
    {
        EditorGUILayout.LabelField("批量调整目标对象及所有子对象粒子系统的启动延迟时间。", EditorStyles.wordWrappedMiniLabel);
        EditorGUILayout.Space(4);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("目标对象:", GUILayout.Width(80));
        pdmTargetObject = (GameObject)EditorGUILayout.ObjectField(pdmTargetObject, typeof(GameObject), true);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("延迟时间:", GUILayout.Width(80));
        if (float.TryParse(EditorGUILayout.TextField(pdmAdditionalDelay.ToString("F4")), out float parsed))
            pdmAdditionalDelay = (float)System.Math.Round(parsed, 4);
        EditorGUILayout.LabelField("秒", GUILayout.Width(20));
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("快速调节:", GUILayout.Width(80));
        if (GUILayout.Button("-0.1",  GUILayout.Width(40))) pdmAdditionalDelay = (float)System.Math.Round(pdmAdditionalDelay - 0.1f,  4);
        if (GUILayout.Button("-0.01", GUILayout.Width(45))) pdmAdditionalDelay = (float)System.Math.Round(pdmAdditionalDelay - 0.01f, 4);
        if (GUILayout.Button("归零",  GUILayout.Width(40))) pdmAdditionalDelay = 0f;
        if (GUILayout.Button("+0.01", GUILayout.Width(45))) pdmAdditionalDelay = (float)System.Math.Round(pdmAdditionalDelay + 0.01f, 4);
        if (GUILayout.Button("+0.1",  GUILayout.Width(40))) pdmAdditionalDelay = (float)System.Math.Round(pdmAdditionalDelay + 0.1f,  4);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(8);
        GUI.enabled = pdmTargetObject != null;
        if (GUILayout.Button("应用延迟修改", GUILayout.Height(35)))
            PdmApplyDelay();
        GUI.enabled = true;

        EditorGUILayout.Space(6);
        EditorGUILayout.HelpBox(
            "1. 将游戏对象拖拽到「目标对象」字段\n" +
            "2. 设置延迟时间（支持负数）\n" +
            "3. 点击「应用延迟修改」直接完成调整\n" +
            "注意：修改支持撤销（Ctrl+Z）", MessageType.Info);
    }

    private void PdmApplyDelay()
    {
        if (pdmTargetObject == null) { EditorUtility.DisplayDialog("错误", "请先选择目标对象！", "确定"); return; }
        var particles = pdmTargetObject.GetComponentsInChildren<ParticleSystem>(true);
        if (particles.Length == 0) { EditorUtility.DisplayDialog("提示", "在指定对象中未找到任何粒子系统！", "确定"); return; }

        Undo.RegisterCompleteObjectUndo(pdmTargetObject, "Modify Particle Delays");
        int count = 0;
        foreach (var ps in particles)
        {
            if (ps == null) continue;
            var main = ps.main;
            main.startDelay = Mathf.Max(0f, (float)System.Math.Round(main.startDelay.constant + pdmAdditionalDelay, 4));
            count++;
        }
        EditorUtility.SetDirty(pdmTargetObject);
        if (PrefabUtility.IsPartOfAnyPrefab(pdmTargetObject))
        {
            var src = PrefabUtility.GetCorrespondingObjectFromSource(pdmTargetObject);
            if (src != null) PrefabUtility.SavePrefabAsset(src);
        }
        Debug.Log($"[ParticleDelayModifier] 成功修改了 {count} 个粒子系统，延迟调整: {pdmAdditionalDelay:F4} 秒");
    }
}

#endif
