using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using UnityEngine.Rendering;

// Made by Copilot, 2026.3.27, Using Claude Sonnet 4.6
// Unified VFX toolbox merging: AssetReferenceFinder, VFXPerformanceAnalyzer,
//   ModelPolygonChecker, MaterialSimilarityAnalyzer
public class VFXToolsWindow : EditorWindow
{
    // ============================================================
    // 通用
    // ============================================================
    private int activeTab = 0;
    private readonly string[] tabNames = { "引用查找", "格式扫描", "VFX性能", "模型面数", "材质复用" };

    [MenuItem("工具/VFXTools/VFX综合工具箱")]
    public static void ShowWindow()
    {
        GetWindow<VFXToolsWindow>("VFX综合工具箱");
    }

    void OnGUI()
    {
        activeTab = GUILayout.Toolbar(activeTab, tabNames);
        EditorGUILayout.Space();

        switch (activeTab)
        {
            case 0: DrawRefFinderTab(); break;
            case 1: DrawExtScannerTab(); break;
            case 2: DrawVFXAnalyzerTab(); break;
            case 3: DrawModelCheckerTab(); break;
            case 4: DrawMatSimilarityTab(); break;
        }
    }

    // ============================================================
    // TAB 0: 引用查找
    // ============================================================
    private Object targetAsset;
    private Vector2 refScrollPos;
    private List<string> referencingPrefabs = new List<string>();
    private List<string> referencingMaterials = new List<string>();
    private bool showRefPrefabs = true;
    private bool showRefMaterials = true;
    private bool isSearching = false;
    private bool hasSearched = false;
    private string searchScope = "Assets/";

    void DrawRefFinderTab()
    {
        GUILayout.Label("资产引用查找器", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("选择一个资产（纹理/材质/模型等），查找工程中哪些预制体和材质引用了它。", MessageType.Info);

        EditorGUILayout.Space();

        targetAsset = EditorGUILayout.ObjectField("目标资产", targetAsset, typeof(Object), false);

        searchScope = EditorGUILayout.TextField("搜索范围（路径前缀）", searchScope);

        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(isSearching || targetAsset == null);
        if (GUILayout.Button("开始查找引用", GUILayout.Height(30)))
        {
            FindReferences();
        }
        EditorGUI.EndDisabledGroup();

        if (hasSearched && !isSearching)
        {
            EditorGUILayout.Space();
            DisplayRefResults();
        }
    }

    void FindReferences()
    {
        string assetPath = AssetDatabase.GetAssetPath(targetAsset);
        if (string.IsNullOrEmpty(assetPath))
        {
            EditorUtility.DisplayDialog("错误", "无法获取所选资产的路径，请确保选择的是项目内的资产。", "确定");
            return;
        }

        referencingPrefabs.Clear();
        referencingMaterials.Clear();
        isSearching = true;
        hasSearched = false;

        try
        {
            string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab", new[] { searchScope });
            string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { searchScope });

            int total = prefabGuids.Length + materialGuids.Length;
            int processed = 0;

            foreach (string guid in prefabGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path == assetPath)
                {
                    processed++;
                    continue;
                }

                EditorUtility.DisplayProgressBar(
                    "查找资产引用",
                    $"[{processed}/{total}] 检查预制体: {path}",
                    (float)processed / total);

                string[] deps = AssetDatabase.GetDependencies(path, true);
                if (deps.Contains(assetPath))
                    referencingPrefabs.Add(path);

                processed++;
            }

            foreach (string guid in materialGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (path == assetPath)
                {
                    processed++;
                    continue;
                }

                EditorUtility.DisplayProgressBar(
                    "查找资产引用",
                    $"[{processed}/{total}] 检查材质: {path}",
                    (float)processed / total);

                string[] deps = AssetDatabase.GetDependencies(path, true);
                if (deps.Contains(assetPath))
                    referencingMaterials.Add(path);

                processed++;
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            isSearching = false;
            hasSearched = true;
        }

        Debug.Log($"[资产引用查找器] 查找完成：{assetPath}\n" +
                  $"  预制体引用: {referencingPrefabs.Count} 个\n" +
                  $"  材质引用:   {referencingMaterials.Count} 个");
    }

    void DisplayRefResults()
    {
        int total = referencingPrefabs.Count + referencingMaterials.Count;

        if (total == 0)
        {
            EditorGUILayout.HelpBox("未找到任何引用该资产的预制体或材质。", MessageType.Warning);
            return;
        }

        string assetPath = AssetDatabase.GetAssetPath(targetAsset);
        GUILayout.Label(
            $"「{Path.GetFileName(assetPath)}」共被 {total} 个文件引用" +
            $"（预制体: {referencingPrefabs.Count}，材质: {referencingMaterials.Count}）",
            EditorStyles.boldLabel);

        EditorGUILayout.Space();

        refScrollPos = EditorGUILayout.BeginScrollView(refScrollPos);

        // 预制体列表
        showRefPrefabs = EditorGUILayout.Foldout(showRefPrefabs, $"预制体引用 ({referencingPrefabs.Count})", true, EditorStyles.foldoutHeader);
        if (showRefPrefabs)
        {
            EditorGUI.indentLevel++;
            foreach (string path in referencingPrefabs)
                DrawAssetRow<GameObject>(path);
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.Space(4);

        // 材质列表
        showRefMaterials = EditorGUILayout.Foldout(showRefMaterials, $"材质引用 ({referencingMaterials.Count})", true, EditorStyles.foldoutHeader);
        if (showRefMaterials)
        {
            EditorGUI.indentLevel++;
            foreach (string path in referencingMaterials)
                DrawAssetRow<Material>(path);
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space();

        if (GUILayout.Button("复制结果到剪贴板"))
        {
            CopyRefResultsToClipboard(assetPath);
        }
    }

    void DrawAssetRow<T>(string path) where T : Object
    {
        EditorGUILayout.BeginHorizontal();

        T asset = AssetDatabase.LoadAssetAtPath<T>(path);
        EditorGUILayout.ObjectField(asset, typeof(T), false);

        if (GUILayout.Button("定位", GUILayout.Width(44)))
        {
            EditorGUIUtility.PingObject(asset);
            Selection.activeObject = asset;
        }

        EditorGUILayout.EndHorizontal();
    }

    void CopyRefResultsToClipboard(string assetPath)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"资产引用查找结果: {assetPath}");
        sb.AppendLine();

        sb.AppendLine($"预制体引用 ({referencingPrefabs.Count}):");
        foreach (string path in referencingPrefabs)
            sb.AppendLine($"  {path}");

        sb.AppendLine();
        sb.AppendLine($"材质引用 ({referencingMaterials.Count}):");
        foreach (string path in referencingMaterials)
            sb.AppendLine($"  {path}");

        GUIUtility.systemCopyBuffer = sb.ToString();
        Debug.Log("[资产引用查找器] 结果已复制到剪贴板");
    }

    // ============================================================
    // TAB 1: 格式扫描
    // ============================================================
    private List<string> extensionsToScan = new List<string> { ".dds" };
    private string extensionInput = ".dds";
    private string extScanScope = "Assets/";
    private Dictionary<string, List<string>> foundFilesByExt = new Dictionary<string, List<string>>();
    private Dictionary<string, bool> extFoldouts = new Dictionary<string, bool>();
    private bool hasScanned = false;
    private bool isScanning = false;
    private Vector2 extScrollPos;

    void DrawExtScannerTab()
    {
        GUILayout.Label("特定格式文件扫描", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("扫描项目目录中指定后缀名的文件，帮助找出不受平台支持的格式（如 iOS 不支持 .dds）。", MessageType.Info);

        EditorGUILayout.Space();

        // 预设快捷按钮
        GUILayout.Label("常见预设:", EditorStyles.miniBoldLabel);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("iOS 不支持 (.dds .tif .tiff)"))
            SetPresetExtensions(new[] { ".dds", ".tif", ".tiff" });
        if (GUILayout.Button("不推荐格式 (.psd .psb .tga .bmp)"))
            SetPresetExtensions(new[] { ".psd", ".psb", ".tga", ".bmp" });
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(4);

        // 手动添加
        GUILayout.Label("添加自定义后缀:", EditorStyles.miniBoldLabel);
        EditorGUILayout.BeginHorizontal();
        extensionInput = EditorGUILayout.TextField(extensionInput);
        if (GUILayout.Button("添加", GUILayout.Width(50)))
        {
            string ext = extensionInput.Trim().ToLower();
            if (!ext.StartsWith(".")) ext = "." + ext;
            if (ext.Length > 1 && !extensionsToScan.Contains(ext))
                extensionsToScan.Add(ext);
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(4);

        // 当前后缀列表
        GUILayout.Label("待扫描后缀:", EditorStyles.miniBoldLabel);
        if (extensionsToScan.Count == 0)
        {
            EditorGUILayout.HelpBox("请添加至少一个后缀名。", MessageType.Warning);
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            for (int i = extensionsToScan.Count - 1; i >= 0; i--)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label(extensionsToScan[i]);
                if (GUILayout.Button("×", GUILayout.Width(22)))
                    extensionsToScan.RemoveAt(i);
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndVertical();
        }

        EditorGUILayout.Space();

        extScanScope = EditorGUILayout.TextField("搜索范围（路径前缀）", extScanScope);

        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(isScanning || extensionsToScan.Count == 0);
        if (GUILayout.Button("开始扫描", GUILayout.Height(30)))
            ScanByExtension();
        EditorGUI.EndDisabledGroup();

        if (hasScanned && !isScanning)
        {
            EditorGUILayout.Space();
            DisplayExtScanResults();
        }
    }

    void SetPresetExtensions(string[] presets)
    {
        extensionsToScan.Clear();
        extensionsToScan.AddRange(presets);
    }

    void ScanByExtension()
    {
        foundFilesByExt.Clear();
        extFoldouts.Clear();
        isScanning = true;
        hasScanned = false;

        try
        {
            string scopeRelative = extScanScope.TrimEnd('/');
            string diskPath;
            if (scopeRelative.StartsWith("Assets/"))
                diskPath = Path.Combine(Application.dataPath, scopeRelative.Substring("Assets/".Length));
            else if (scopeRelative == "Assets")
                diskPath = Application.dataPath;
            else
                diskPath = Path.Combine(Application.dataPath, scopeRelative);

            diskPath = diskPath.Replace('/', Path.DirectorySeparatorChar);

            if (!Directory.Exists(diskPath))
            {
                EditorUtility.DisplayDialog("路径错误", $"目录不存在：{diskPath}", "确定");
                return;
            }

            foreach (string ext in extensionsToScan)
            {
                foundFilesByExt[ext] = new List<string>();
                extFoldouts[ext] = true;
            }

            string[] allFiles = Directory.GetFiles(diskPath, "*.*", SearchOption.AllDirectories);
            int total = allFiles.Length;

            for (int i = 0; i < total; i++)
            {
                string file = allFiles[i];
                string fileExt = Path.GetExtension(file).ToLower();

                if (foundFilesByExt.ContainsKey(fileExt))
                {
                    string assetPath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                    if (!assetPath.EndsWith(".meta"))
                        foundFilesByExt[fileExt].Add(assetPath);
                }

                if (i % 300 == 0)
                    EditorUtility.DisplayProgressBar("格式扫描", $"[{i}/{total}] {Path.GetFileName(file)}", (float)i / total);
            }

            int totalFound = foundFilesByExt.Values.Sum(l => l.Count);
            Debug.Log($"[格式扫描] 完成，共发现 {totalFound} 个文件。");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            isScanning = false;
            hasScanned = true;
        }
    }

    void DisplayExtScanResults()
    {
        int totalFound = foundFilesByExt.Values.Sum(l => l.Count);

        if (totalFound == 0)
        {
            EditorGUILayout.HelpBox("未发现任何指定后缀的文件，工程里没有这些格式！", MessageType.Info);
            return;
        }

        GUILayout.Label($"共发现 {totalFound} 个文件", EditorStyles.boldLabel);
        EditorGUILayout.Space(2);

        extScrollPos = EditorGUILayout.BeginScrollView(extScrollPos);

        foreach (var kv in foundFilesByExt)
        {
            if (kv.Value.Count == 0) continue;

            extFoldouts[kv.Key] = EditorGUILayout.Foldout(extFoldouts[kv.Key], $"{kv.Key}  ({kv.Value.Count} 个文件)", true, EditorStyles.foldoutHeader);
            if (extFoldouts[kv.Key])
            {
                EditorGUI.indentLevel++;
                foreach (string path in kv.Value)
                    DrawExtFileRow(path);
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.Space(2);
        }

        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space();

        if (GUILayout.Button("复制扫描结果到剪贴板"))
            CopyScanResultsToClipboard();
    }

    void DrawExtFileRow(string assetPath)
    {
        EditorGUILayout.BeginHorizontal();

        Object asset = AssetDatabase.LoadAssetAtPath<Object>(assetPath);
        if (asset != null)
            EditorGUILayout.ObjectField(asset, typeof(Object), false);
        else
            EditorGUILayout.LabelField(assetPath);

        if (GUILayout.Button("定位", GUILayout.Width(44)))
        {
            if (asset != null)
            {
                EditorGUIUtility.PingObject(asset);
                Selection.activeObject = asset;
            }
            else
            {
                EditorUtility.RevealInFinder(assetPath);
            }
        }

        EditorGUILayout.EndHorizontal();
    }

    void CopyScanResultsToClipboard()
    {
        var sb = new StringBuilder();
        sb.AppendLine("格式扫描结果：");
        sb.AppendLine();
        foreach (var kv in foundFilesByExt)
        {
            if (kv.Value.Count == 0) continue;
            sb.AppendLine($"{kv.Key} ({kv.Value.Count} 个文件):");
            foreach (string path in kv.Value)
                sb.AppendLine($"  {path}");
            sb.AppendLine();
        }
        GUIUtility.systemCopyBuffer = sb.ToString();
        Debug.Log("[格式扫描] 结果已复制到剪贴板");
    }

    // ============================================================
    // TAB 2: VFX性能分析
    // ============================================================
    private GameObject vfxTargetPrefab;
    private Vector2 vfxScrollPos;
    private GameObject vfxInstance;
    private Dictionary<string, Texture> vfxTextures = new Dictionary<string, Texture>();
    private Dictionary<string, Material> vfxMaterials = new Dictionary<string, Material>();
    private Dictionary<string, Shader> vfxShaders = new Dictionary<string, Shader>();
    private int vfxParticleCount = 0;
    private int vfxEmitterCount = 0;
    private int vfxTrailCount = 0;
    private int vfxLineCount = 0;
    private int vfxBatches = 0;
    private int vfxDrawCalls = 0;
    private int vfxVertices = 0;
    private int vfxTriangles = 0;
    private float vfxGpuMemMB = 0;
    private List<string> vfxIssues = new List<string>();
    private bool vfxShowMaterials = false;
    private bool vfxShowTextures = false;
    private bool vfxShowShaders = false;
    private bool vfxShowIssues = false;
    private bool vfxIsAnalyzing = false;
    private string vfxStatus = "";
    private Dictionary<Texture, float> vfxTexSizes = new Dictionary<Texture, float>();
    // true = values came from Unity Stats diff; false = fallback estimation
    private bool vfxUsedUnityStats = false;
    private int vfxBaseVertices = 0;
    private int vfxBaseTriangles = 0;
    private int vfxBaseDrawCalls = 0;
    private int vfxBaseBatches = 0;

    void DrawVFXAnalyzerTab()
    {
        GUILayout.Label("特效预制体性能分析器", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        vfxTargetPrefab = (GameObject)EditorGUILayout.ObjectField("目标特效预制体", vfxTargetPrefab, typeof(GameObject), false);
        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(vfxIsAnalyzing || vfxTargetPrefab == null);
        if (GUILayout.Button("分析特效预制体", GUILayout.Height(30)))
            AnalyzeVFXPrefab();
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space();

        if (vfxIsAnalyzing)
            EditorGUILayout.HelpBox(vfxStatus, MessageType.Info);

        if (vfxTargetPrefab != null && !vfxIsAnalyzing && vfxMaterials.Count > 0)
            DisplayVFXResults();
    }

    void AnalyzeVFXPrefab()
    {
        vfxIsAnalyzing = true;
        vfxStatus = "正在分析...";
        CleanupVFXAnalysis();

        vfxBaseVertices = UnityStats.vertices;
        vfxBaseTriangles = UnityStats.triangles;
        vfxBaseDrawCalls = UnityStats.drawCalls;
        vfxBaseBatches = UnityStats.batches;

        vfxInstance = Instantiate(vfxTargetPrefab);
        vfxInstance.name = vfxTargetPrefab.name + " (Analysis)";
        AnalyzeVFXComponents();

        SceneView.RepaintAll();
        EditorApplication.QueuePlayerLoopUpdate();
        EditorApplication.delayCall += () =>
        {
            int deltaDrawCalls = UnityStats.drawCalls - vfxBaseDrawCalls;
            int deltaBatches = UnityStats.batches - vfxBaseBatches;
            vfxVertices = Mathf.Max(0, UnityStats.vertices - vfxBaseVertices);
            vfxTriangles = Mathf.Max(0, UnityStats.triangles - vfxBaseTriangles);

            if (deltaDrawCalls > 0 || deltaBatches > 0)
            {
                vfxDrawCalls = Mathf.Max(0, deltaDrawCalls);
                vfxBatches = Mathf.Max(0, deltaBatches);
                vfxUsedUnityStats = true;
            }
            else
            {
                CalculateVFXDrawCallsFallback();
                vfxUsedUnityStats = false;
            }

            vfxIsAnalyzing = false;
            vfxStatus = "分析完成";
            Repaint();
        };
    }

    void AnalyzeVFXComponents()
    {
        var particleSystems = vfxInstance.GetComponentsInChildren<ParticleSystem>(true);
        vfxParticleCount = particleSystems.Length;

        vfxEmitterCount = 0;
        foreach (var ps in particleSystems)
        {
            // GetComponentsInChildren 已涵盖所有子PS（含子发射器），只需检查自身emission
            if (ps.emission.enabled) vfxEmitterCount++;
        }

        var trailRenderers = vfxInstance.GetComponentsInChildren<TrailRenderer>(true);
        vfxTrailCount = trailRenderers.Length;

        var lineRenderers = vfxInstance.GetComponentsInChildren<LineRenderer>(true);
        vfxLineCount = lineRenderers.Length;

        vfxMaterials.Clear();
        vfxTextures.Clear();
        vfxShaders.Clear();
        vfxTexSizes.Clear();
        vfxGpuMemMB = 0;
        vfxIssues.Clear();

        foreach (var ps in particleSystems)
        {
            var r = ps.GetComponent<ParticleSystemRenderer>();
            if (r != null) AnalyzeVFXRenderer(r);
            AnalyzeVFXParticlePerformance(ps);
        }
        foreach (var r in trailRenderers) AnalyzeVFXRenderer(r);
        foreach (var r in lineRenderers) AnalyzeVFXRenderer(r);

        var others = vfxInstance.GetComponentsInChildren<Renderer>(true)
            .Where(r => !(r is ParticleSystemRenderer || r is TrailRenderer || r is LineRenderer));
        foreach (var r in others) AnalyzeVFXRenderer(r);

        // 所有材质收集完毕后，统一检查同Shader透明材质过多的问题
        CheckVFXShaderOveruse();
    }

    void CheckVFXShaderOveruse()
    {
        var groups = vfxMaterials.Values
            .Where(m => m.shader != null && m.renderQueue >= 3000 && m.renderQueue < 3100)
            .GroupBy(m => m.shader);
        foreach (var g in groups)
        {
            if (g.Count() > 2)
                vfxIssues.Add($"检测到 {g.Count()} 个透明材质使用相同Shader [{g.Key.name}]，建议合并材质或贴图来减少批次");
        }
    }

    void AnalyzeVFXParticlePerformance(ParticleSystem ps)
    {
        if (ps.main.maxParticles > 200)
            vfxIssues.Add($"粒子系统 [{ps.name}] 最大粒子数过大: {ps.main.maxParticles}");
        if (ps.collision.enabled)
            vfxIssues.Add($"粒子系统 [{ps.name}] 启用了碰撞计算，可能影响性能");
        if (ps.noise.enabled)
            vfxIssues.Add($"粒子系统 [{ps.name}] 启用了噪声模块，可能影响性能");
        if (ps.subEmitters.enabled && ps.subEmitters.subEmittersCount > 5)
            vfxIssues.Add($"粒子系统 [{ps.name}] 使用了 {ps.subEmitters.subEmittersCount} 个子发射器，过多会影响性能");
    }

    void AnalyzeVFXRenderer(Renderer renderer)
    {
        foreach (var mat in renderer.sharedMaterials)
        {
            if (mat == null || vfxMaterials.ContainsKey(mat.name)) continue;
            vfxMaterials[mat.name] = mat;

            if (mat.shader == null) continue;
            Shader shader = mat.shader;
            if (!vfxShaders.ContainsKey(shader.name))
                vfxShaders[shader.name] = shader;

            AnalyzeVFXShaderPerformance(mat, shader);

            int propCount = ShaderUtil.GetPropertyCount(shader);
            for (int i = 0; i < propCount; i++)
            {
                if (ShaderUtil.GetPropertyType(shader, i) != ShaderUtil.ShaderPropertyType.TexEnv) continue;
                string propName = ShaderUtil.GetPropertyName(shader, i);
                Texture tex = mat.GetTexture(propName);
                if (tex != null && !vfxTextures.ContainsKey(tex.name))
                {
                    vfxTextures[tex.name] = tex;
                    AnalyzeVFXTexturePerformance(tex);
                }
            }
        }
    }

    void AnalyzeVFXShaderPerformance(Material mat, Shader shader)
    {
        string name = shader.name.ToLower();
        if (name.Contains("distortion") || name.Contains("displacement") ||
            name.Contains("parallax") || name.Contains("tessellation"))
            vfxIssues.Add($"材质 [{mat.name}] 使用了复杂Shader: {shader.name}，可能影响性能");
        // 同Shader透明材质过多的检查移至 CheckVFXShaderOveruse()，在所有材质收集完毕后统一执行
    }

    void AnalyzeVFXTexturePerformance(Texture texture)
    {
        if (texture is Texture2D tex2D)
        {
            int bpp = GetBitsPerPixel(tex2D.format);
            float sizeMB = tex2D.width * tex2D.height * bpp / 8f / (1024f * 1024f);
            vfxTexSizes[texture] = sizeMB;
            vfxGpuMemMB += sizeMB;

            if (!IsPowerOfTwo(tex2D.width) || !IsPowerOfTwo(tex2D.height))
                vfxIssues.Add($"纹理 [{tex2D.name}] 尺寸 ({tex2D.width}x{tex2D.height}) 不是2的幂，可能影响压缩");
            if (tex2D.width > 1024 || tex2D.height > 1024)
                vfxIssues.Add($"纹理 [{tex2D.name}] 尺寸 ({tex2D.width}x{tex2D.height}) 较大，考虑降低分辨率");
            if (tex2D.format == TextureFormat.RGBA32 || tex2D.format == TextureFormat.ARGB32 || tex2D.format == TextureFormat.RGB24)
                vfxIssues.Add($"纹理 [{tex2D.name}] 使用未压缩格式 ({tex2D.format})，建议使用压缩格式");
            if (tex2D.mipmapCount > 1 && (!IsPowerOfTwo(tex2D.width) || !IsPowerOfTwo(tex2D.height)))
                vfxIssues.Add($"纹理 [{tex2D.name}] 启用了MipMap但尺寸不是2的幂，可能无法正确生成MipMap");
        }
        else if (texture is RenderTexture rt)
        {
            float sizeMB = rt.width * rt.height * 4 / (1024f * 1024f);
            vfxTexSizes[texture] = sizeMB;
            vfxGpuMemMB += sizeMB;
        }
    }

    void CalculateVFXDrawCallsFallback()
    {
        var queueGroups = new Dictionary<int, HashSet<Material>>();
        foreach (var mat in vfxMaterials.Values)
        {
            if (!queueGroups.ContainsKey(mat.renderQueue))
                queueGroups[mat.renderQueue] = new HashSet<Material>();
            queueGroups[mat.renderQueue].Add(mat);
        }

        vfxDrawCalls = 0;
        vfxBatches = 0;
        foreach (var kvp in queueGroups)
        {
            int count = kvp.Value.Count;
            if (kvp.Key >= 3000)
            {
                // 透明队列，无法合批
                vfxDrawCalls += count;
                vfxBatches += count;
            }
            else
            {
                // 不透明队列，保守估计70%材质无法合批
                vfxDrawCalls += Mathf.CeilToInt(count * 0.7f);
                vfxBatches += Mathf.CeilToInt(count * 0.7f);
            }
        }

        // emitterCount 已是所有启用emission的PS数量（含子发射器PS），不再做额外补偿
        vfxDrawCalls = Mathf.Max(1, vfxDrawCalls);
        vfxBatches = Mathf.Max(1, vfxBatches);
        Debug.Log($"[VFX分析器] 估算 DrawCalls: {vfxDrawCalls}, Batches: {vfxBatches}");
    }

    void DisplayVFXResults()
    {
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        EditorGUILayout.LabelField("性能分析结果", EditorStyles.boldLabel);

        vfxScrollPos = EditorGUILayout.BeginScrollView(vfxScrollPos);

        EditorGUILayout.LabelField("基本信息", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("预制体名称", vfxTargetPrefab.name);
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("组件数量", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("粒子系统数量", vfxParticleCount.ToString());
        EditorGUILayout.LabelField("发射器数量", vfxEmitterCount.ToString());
        EditorGUILayout.LabelField("拖尾渲染器数量", vfxTrailCount.ToString());
        EditorGUILayout.LabelField("线条渲染器数量", vfxLineCount.ToString());
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("渲染统计", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("材质数量", vfxMaterials.Count.ToString());
        EditorGUILayout.LabelField("纹理数量", vfxTextures.Count.ToString());
        EditorGUILayout.LabelField("Shader数量", vfxShaders.Count.ToString());

        var colRed    = new GUIStyle(EditorStyles.label) { normal = { textColor = Color.red } };
        var colOrange = new GUIStyle(EditorStyles.label) { normal = { textColor = new Color(1f, 0.5f, 0f) } };
        var colGreen  = new GUIStyle(EditorStyles.label) { normal = { textColor = Color.green } };

        string statsSource = vfxUsedUnityStats ? "(Unity Stats)" : "(估算值)";

        GUIStyle dcStyle = vfxDrawCalls > 8 ? colRed : (vfxDrawCalls > 4 ? colOrange : colGreen);
        EditorGUILayout.LabelField($"DrawCall数量 {statsSource}", vfxDrawCalls.ToString(), dcStyle);

        GUIStyle batchStyle = vfxBatches > 8 ? colRed : (vfxBatches > 4 ? colOrange : colGreen);
        EditorGUILayout.LabelField($"Batches数量 {statsSource}", vfxBatches.ToString(), batchStyle);

        EditorGUILayout.LabelField($"顶点数 {statsSource}", vfxVertices.ToString());
        EditorGUILayout.LabelField($"三角形数 {statsSource}", vfxTriangles.ToString());

        GUIStyle memStyle = vfxGpuMemMB > 10 ? colRed : (vfxGpuMemMB > 5 ? colOrange : colGreen);
        EditorGUILayout.LabelField("估计GPU内存占用", $"{vfxGpuMemMB:F2} MB", memStyle);
        EditorGUILayout.Space();

        if (vfxIssues.Count > 0)
        {
            vfxShowIssues = EditorGUILayout.Foldout(vfxShowIssues, $"检测到的性能问题 ({vfxIssues.Count})", true);
            if (vfxShowIssues)
            {
                EditorGUI.indentLevel++;
                foreach (var issue in vfxIssues)
                    EditorGUILayout.HelpBox(issue, MessageType.Warning);
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.Space();
        }

        vfxShowShaders = EditorGUILayout.Foldout(vfxShowShaders, $"使用的Shader ({vfxShaders.Count})", true);
        if (vfxShowShaders)
        {
            EditorGUI.indentLevel++;
            foreach (var shader in vfxShaders.Values)
                EditorGUILayout.ObjectField(shader.name, shader, typeof(Shader), false);
            EditorGUI.indentLevel--;
        }

        vfxShowMaterials = EditorGUILayout.Foldout(vfxShowMaterials, $"使用的材质 ({vfxMaterials.Count})", true);
        if (vfxShowMaterials)
        {
            EditorGUI.indentLevel++;
            foreach (var mat in vfxMaterials.Values)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(mat.name, mat, typeof(Material), false);
                if (mat.shader != null)
                    EditorGUILayout.LabelField("Shader: " + mat.shader.name, EditorStyles.miniLabel);
                EditorGUILayout.EndHorizontal();
            }
            EditorGUI.indentLevel--;
        }

        vfxShowTextures = EditorGUILayout.Foldout(vfxShowTextures, $"使用的纹理 ({vfxTextures.Count})", true);
        if (vfxShowTextures)
        {
            EditorGUI.indentLevel++;
            foreach (var tex in vfxTextures.Values.OrderByDescending(t => vfxTexSizes.ContainsKey(t) ? vfxTexSizes[t] : 0))
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(tex.name, tex, typeof(Texture), false);
                if (tex is Texture2D t2d)
                {
                    float sz = vfxTexSizes.ContainsKey(tex) ? vfxTexSizes[tex] : 0;
                    GUIStyle szStyle = sz > 1f ? colRed : (sz > 0.5f ? colOrange : EditorStyles.miniLabel);
                    EditorGUILayout.LabelField($"{t2d.width}x{t2d.height}  {t2d.format}  {sz:F2}MB", szStyle);
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.Space();
            }
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndScrollView();
        EditorGUILayout.Space();

        if (GUILayout.Button("导出分析结果"))
            ExportVFXResults();
    }

    void ExportVFXResults()
    {
        string path = EditorUtility.SaveFilePanel("保存分析结果", "", vfxTargetPrefab.name + "_性能分析.txt", "txt");
        if (string.IsNullOrEmpty(path)) return;

        var sb = new StringBuilder();
        sb.AppendLine("特效预制体性能分析报告");
        sb.AppendLine("----------------------------");
        sb.AppendLine($"预制体名称: {vfxTargetPrefab.name}");
        sb.AppendLine();
        sb.AppendLine("组件数量:");
        sb.AppendLine($"- 粒子系统: {vfxParticleCount}");
        sb.AppendLine($"- 发射器: {vfxEmitterCount}");
        sb.AppendLine($"- 拖尾渲染器: {vfxTrailCount}");
        sb.AppendLine($"- 线条渲染器: {vfxLineCount}");
        sb.AppendLine();
        sb.AppendLine("渲染统计:");
        sb.AppendLine($"- 材质数量: {vfxMaterials.Count}");
        sb.AppendLine($"- 纹理数量: {vfxTextures.Count}");
        sb.AppendLine($"- Shader数量: {vfxShaders.Count}");
        sb.AppendLine($"- DrawCall ({(vfxUsedUnityStats ? "Unity Stats" : "估算")}): {vfxDrawCalls}");
        sb.AppendLine($"- Batches ({(vfxUsedUnityStats ? "Unity Stats" : "估算")}): {vfxBatches}");
        sb.AppendLine($"- 顶点数: {vfxVertices}");
        sb.AppendLine($"- 三角形数: {vfxTriangles}");
        sb.AppendLine($"- 估计GPU内存: {vfxGpuMemMB:F2} MB");
        sb.AppendLine();
        if (vfxIssues.Count > 0)
        {
            sb.AppendLine("检测到的性能问题:");
            foreach (var issue in vfxIssues) sb.AppendLine($"- {issue}");
            sb.AppendLine();
        }
        sb.AppendLine("Shader列表:");
        foreach (var s in vfxShaders.Values) sb.AppendLine($"- {s.name}");
        sb.AppendLine();
        sb.AppendLine("材质列表:");
        foreach (var m in vfxMaterials.Values) sb.AppendLine($"- {m.name} (Shader: {m.shader?.name})");
        sb.AppendLine();
        sb.AppendLine("纹理列表 (按内存排序):");
        foreach (var tex in vfxTextures.Values.OrderByDescending(t => vfxTexSizes.ContainsKey(t) ? vfxTexSizes[t] : 0))
        {
            if (tex is Texture2D t2d)
            {
                float sz = vfxTexSizes.ContainsKey(tex) ? vfxTexSizes[tex] : 0;
                sb.AppendLine($"- {tex.name} ({t2d.width}x{t2d.height}, {t2d.format}, {sz:F2}MB)");
            }
            else sb.AppendLine($"- {tex.name}");
        }
        File.WriteAllText(path, sb.ToString());
        Debug.Log($"[VFX分析器] 已导出至: {path}");
    }

    void CleanupVFXAnalysis()
    {
        if (vfxInstance != null) DestroyImmediate(vfxInstance);
        vfxMaterials.Clear();
        vfxTextures.Clear();
        vfxShaders.Clear();
        vfxTexSizes.Clear();
        vfxIssues.Clear();
        vfxParticleCount = 0;
        vfxEmitterCount = 0;
        vfxTrailCount = 0;
        vfxLineCount = 0;
        vfxBatches = 0;
        vfxDrawCalls = 0;
        vfxVertices = 0;
        vfxTriangles = 0;
        vfxGpuMemMB = 0;
    }

    // ============================================================
    // TAB 3: 模型面数检查
    // ============================================================
    private int modelThreshold = 10000;
    private int modelDisplayCount = 10;
    private List<ModelInfo> highPolyModels = new List<ModelInfo>();
    private Vector2 modelScrollPos;
    private bool modelIsScanning = false;
    private Dictionary<string, List<string>> modelRefMap = new Dictionary<string, List<string>>();
    private bool[] modelFoldouts;

    public class ModelInfo
    {
        public string path;
        public string name;
        public int triangleCount;
        public int vertexCount;
    }

    void DrawModelCheckerTab()
    {
        GUILayout.Label("模型面数检查工具", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        modelThreshold    = EditorGUILayout.IntField("面数阈值", modelThreshold);
        modelDisplayCount = EditorGUILayout.IntField("显示数量", modelDisplayCount);
        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(modelIsScanning);
        if (GUILayout.Button("扫描项目中的模型", GUILayout.Height(30)))
        {
            modelIsScanning = true;
            highPolyModels.Clear();
            modelRefMap.Clear();
            EditorApplication.delayCall += () =>
            {
                ScanModels();
                FindModelReferences();
                modelIsScanning = false;
                modelFoldouts = new bool[highPolyModels.Count];
            };
        }
        EditorGUI.EndDisabledGroup();
        EditorGUILayout.Space();

        if (modelIsScanning)
        {
            EditorGUILayout.HelpBox("正在扫描中...", MessageType.Info);
            return;
        }

        if (highPolyModels.Count == 0) return;

        GUILayout.Label($"面数超过 {modelThreshold} 的模型（显示前 {modelDisplayCount} 个）：", EditorStyles.boldLabel);
        modelScrollPos = EditorGUILayout.BeginScrollView(modelScrollPos);

        for (int i = 0; i < Mathf.Min(modelDisplayCount, highPolyModels.Count); i++)
        {
            ModelInfo model = highPolyModels[i];
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            GUILayout.Label($"名称: {model.name}", EditorStyles.boldLabel);
            EditorGUILayout.LabelField("三角形数量:", model.triangleCount.ToString("N0"));
            EditorGUILayout.LabelField("顶点数量:",   model.vertexCount.ToString("N0"));
            EditorGUILayout.LabelField("路径:", model.path);

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("定位模型", GUILayout.Width(100)))
            {
                Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(model.path);
                EditorGUIUtility.PingObject(Selection.activeObject);
            }
            if (modelRefMap.TryGetValue(model.path, out var refs) && refs.Count > 0)
            {
                if (GUILayout.Button("导出引用列表", GUILayout.Width(120)))
                {
                    string savePath = EditorUtility.SaveFilePanel("保存引用列表", "", model.name + "_引用列表", "txt");
                    if (!string.IsNullOrEmpty(savePath))
                        ExportModelReferences(savePath, model.path, model.name);
                }
            }
            EditorGUILayout.EndHorizontal();

            if (modelRefMap.TryGetValue(model.path, out var refList))
            {
                if (refList.Count == 0)
                {
                    EditorGUILayout.HelpBox("此模型在场景和预制体中没有被引用", MessageType.Info);
                }
                else
                {
                    if (modelFoldouts == null || i >= modelFoldouts.Length)
                        modelFoldouts = new bool[highPolyModels.Count];

                    modelFoldouts[i] = EditorGUILayout.Foldout(modelFoldouts[i], $"引用列表 ({refList.Count}个引用)", true);
                    if (modelFoldouts[i])
                    {
                        EditorGUI.indentLevel++;
                        foreach (var reference in refList)
                        {
                            EditorGUILayout.BeginHorizontal();
                            EditorGUILayout.LabelField(reference);
                            if (GUILayout.Button("定位", GUILayout.Width(60)))
                            {
                                Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(reference);
                                EditorGUIUtility.PingObject(Selection.activeObject);
                            }
                            EditorGUILayout.EndHorizontal();
                        }
                        EditorGUI.indentLevel--;
                    }
                }
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.Space();
        }

        EditorGUILayout.EndScrollView();
    }

    void ScanModels()
    {
        string[] modelPaths = AssetDatabase.FindAssets("t:Model")
            .Select(guid => AssetDatabase.GUIDToAssetPath(guid))
            .ToArray();

        var allModels = new List<ModelInfo>();
        foreach (string path in modelPaths)
        {
            if (!(AssetImporter.GetAtPath(path) is ModelImporter)) continue;

            GameObject modelObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (modelObj == null) continue;

            int totalTri = 0, totalVert = 0;
            foreach (Mesh mesh in GetMeshesFromModel(modelObj))
            {
                if (mesh == null) continue;
                totalTri  += mesh.triangles.Length / 3;
                totalVert += mesh.vertexCount;
            }

            if (totalTri >= modelThreshold)
                allModels.Add(new ModelInfo
                {
                    path          = path,
                    name          = Path.GetFileNameWithoutExtension(path),
                    triangleCount = totalTri,
                    vertexCount   = totalVert
                });
        }

        highPolyModels = allModels.OrderByDescending(m => m.triangleCount).ToList();
        Debug.Log($"[模型面数检查] 发现 {highPolyModels.Count} 个面数 >= {modelThreshold} 的模型");
    }

    void FindModelReferences()
    {
        EditorUtility.DisplayProgressBar("查找引用", "初始化...", 0f);
        foreach (var model in highPolyModels)
            modelRefMap[model.path] = new List<string>();

        try
        {
            string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
            for (int i = 0; i < prefabGuids.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(prefabGuids[i]);
                CheckModelReferencesInAsset(p);
                EditorUtility.DisplayProgressBar("查找引用", $"预制体 {i}/{prefabGuids.Length}", (float)i / prefabGuids.Length);
            }

            string[] sceneGuids = AssetDatabase.FindAssets("t:Scene");
            for (int i = 0; i < sceneGuids.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(sceneGuids[i]);
                CheckModelReferencesInAsset(p);
                EditorUtility.DisplayProgressBar("查找引用", $"场景 {i}/{sceneGuids.Length}", (float)i / sceneGuids.Length);
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
        Debug.Log("[模型面数检查] 引用查找完成");
    }

    void CheckModelReferencesInAsset(string assetPath)
    {
        string[] deps = AssetDatabase.GetDependencies(assetPath, false);
        foreach (var model in highPolyModels)
        {
            if (deps.Contains(model.path) && !modelRefMap[model.path].Contains(assetPath))
                modelRefMap[model.path].Add(assetPath);
        }
    }

    Mesh[] GetMeshesFromModel(GameObject model)
    {
        var meshes = new List<Mesh>();
        foreach (var mf in model.GetComponentsInChildren<MeshFilter>(true))
            if (mf.sharedMesh != null) meshes.Add(mf.sharedMesh);
        foreach (var smr in model.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            if (smr.sharedMesh != null) meshes.Add(smr.sharedMesh);
        return meshes.ToArray();
    }

    void ExportModelReferences(string savePath, string modelPath, string modelName)
    {
        if (!modelRefMap.ContainsKey(modelPath)) return;
        using (var writer = new StreamWriter(savePath))
        {
            writer.WriteLine($"模型: {modelName}");
            writer.WriteLine($"路径: {modelPath}");
            writer.WriteLine($"引用数量: {modelRefMap[modelPath].Count}");
            writer.WriteLine("==================================");
            foreach (var r in modelRefMap[modelPath]) writer.WriteLine(r);
        }
        Debug.Log($"[模型面数检查] 引用列表已导出至: {savePath}");
    }

    // ============================================================
    // TAB 4: 材质复用分析
    // ============================================================
    private string matTargetDir = "Assets/";
    private Vector2 matScrollPos;
    private List<MatGroup> matGroups = new List<MatGroup>();
    private bool matIsAnalyzing = false;

    public class MatInfo
    {
        public Material material;
        public string path;
        public Dictionary<string, string> textures = new Dictionary<string, string>();
        public List<string> referencedBy = new List<string>();
        public bool isRefsExpanded = false;
    }

    public class MatGroup
    {
        public List<MatInfo> materials = new List<MatInfo>();
        public string shaderName;
        public bool isExpanded = false;
    }

    void DrawMatSimilarityTab()
    {
        GUILayout.Label("材质相似性分析器", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("扫描指定目录，将使用相同贴图的材质归组，找出可合并优化的重复材质。", MessageType.Info);
        EditorGUILayout.Space();

        matTargetDir = EditorGUILayout.TextField("目标目录", matTargetDir);
        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(matIsAnalyzing);
        if (GUILayout.Button(matIsAnalyzing ? "分析中..." : "开始分析材质", GUILayout.Height(30)))
            AnalyzeMaterials();
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space();
        if (matGroups.Count > 0)
            DisplayMatResults();
    }

    void AnalyzeMaterials()
    {
        matIsAnalyzing = true;
        matGroups.Clear();
        try
        {
            EditorUtility.DisplayProgressBar("分析材质", "正在查找材质文件...", 0f);
            var allMats = FindAllMaterials();
            if (allMats.Count == 0)
            {
                EditorUtility.DisplayDialog("警告", $"在目录 {matTargetDir} 中未找到材质文件", "确定");
                return;
            }
            EditorUtility.DisplayProgressBar("分析材质", "正在分析材质属性...", 0.3f);
            AnalyzeMaterialProperties(allMats);
            EditorUtility.DisplayProgressBar("分析材质", "正在查找引用关系...", 0.6f);
            FindMaterialReferences(allMats);
            EditorUtility.DisplayProgressBar("分析材质", "正在分组材质...", 0.8f);
            GroupMaterials(allMats);
            Debug.Log($"[材质复用分析] 共分析 {allMats.Count} 个材质，发现 {matGroups.Count} 个相似分组");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            matIsAnalyzing = false;
            Repaint();
        }
    }

    List<MatInfo> FindAllMaterials()
    {
        var list = new List<MatInfo>();
        string dir = matTargetDir.TrimEnd('/');
        if (!AssetDatabase.IsValidFolder(dir))
        {
            Debug.LogWarning($"[材质复用分析] 目录不存在或无效: {dir}");
            return list;
        }
        foreach (string guid in AssetDatabase.FindAssets("t:Material", new[] { dir }))
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (mat != null) list.Add(new MatInfo { material = mat, path = path });
        }
        return list;
    }

    void AnalyzeMaterialProperties(List<MatInfo> materials)
    {
        foreach (var info in materials)
        {
            Material mat = info.material;
            if (mat?.shader == null) continue;
            Shader shader = mat.shader;
            int count = ShaderUtil.GetPropertyCount(shader);
            for (int i = 0; i < count; i++)
            {
                if (ShaderUtil.GetPropertyType(shader, i) != ShaderUtil.ShaderPropertyType.TexEnv) continue;
                string propName = ShaderUtil.GetPropertyName(shader, i);
                if (!mat.HasProperty(propName)) continue;
                Texture tex = mat.GetTexture(propName);
                if (tex != null)
                    info.textures[propName] = AssetDatabase.GetAssetPath(tex);
            }
        }
    }

    void FindMaterialReferences(List<MatInfo> materials)
    {
        string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
        for (int i = 0; i < prefabGuids.Length; i++)
        {
            if (i % 50 == 0)
                EditorUtility.DisplayProgressBar("分析材质", $"查找引用 ({i}/{prefabGuids.Length})",
                    0.6f + 0.2f * ((float)i / prefabGuids.Length));
            CheckPrefabForMatRefs(AssetDatabase.GUIDToAssetPath(prefabGuids[i]), materials);
        }

        foreach (string guid in AssetDatabase.FindAssets("t:Scene"))
        {
            string scenePath = AssetDatabase.GUIDToAssetPath(guid);
            string[] deps = AssetDatabase.GetDependencies(scenePath, false);
            foreach (var info in materials)
                if (deps.Contains(info.path) && !info.referencedBy.Contains(scenePath))
                    info.referencedBy.Add(scenePath);
        }
    }

    void CheckPrefabForMatRefs(string prefabPath, List<MatInfo> materials)
    {
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
        if (prefab == null) return;
        foreach (var renderer in prefab.GetComponentsInChildren<Renderer>(true))
        {
            foreach (var mat in renderer.sharedMaterials)
            {
                if (mat == null) continue;
                var info = materials.FirstOrDefault(m => m.material == mat);
                if (info != null && !info.referencedBy.Contains(prefabPath))
                    info.referencedBy.Add(prefabPath);
            }
        }
    }

    void GroupMaterials(List<MatInfo> materials)
    {
        matGroups.Clear();
        foreach (var shaderGroup in materials.GroupBy(m => m.material.shader?.name ?? "Unknown"))
        {
            foreach (var g in FindSimilarMatGroups(shaderGroup.ToList()).Where(g => g.Count > 1))
                matGroups.Add(new MatGroup { shaderName = shaderGroup.Key, materials = g });
        }
        matGroups.Sort((a, b) => b.materials.Count.CompareTo(a.materials.Count));
    }

    List<List<MatInfo>> FindSimilarMatGroups(List<MatInfo> materials)
    {
        var result = new List<List<MatInfo>>();
        var processed = new HashSet<MatInfo>();
        foreach (var mat in materials)
        {
            if (processed.Contains(mat)) continue;
            var group = new List<MatInfo> { mat };
            processed.Add(mat);
            foreach (var other in materials)
            {
                if (processed.Contains(other)) continue;
                if (AreMatsTextureSimilar(mat, other)) { group.Add(other); processed.Add(other); }
            }
            result.Add(group);
        }
        return result;
    }

    bool AreMatsTextureSimilar(MatInfo a, MatInfo b)
    {
        if (a.textures.Count == 0 && b.textures.Count == 0) return false;
        if (a.textures.Count != b.textures.Count) return false;
        foreach (var kvp in a.textures)
            if (!b.textures.TryGetValue(kvp.Key, out string val) || val != kvp.Value) return false;
        return true;
    }

    Color GetMatGroupColor(int count)
    {
        if (count >= 10) return Color.red;
        if (count >= 5)  return new Color(0.9f, 0.6f, 0f);  // 橙色
        return new Color(0.5f, 0.5f, 0.5f);                 // 灰色
    }

    void DisplayMatResults()
    {
        EditorGUILayout.LabelField($"分析结果 (共 {matGroups.Count} 组)", EditorStyles.boldLabel);
        matScrollPos = EditorGUILayout.BeginScrollView(matScrollPos);

        foreach (var group in matGroups)
        {
            string severity = group.materials.Count >= 10 ? " - 严重重复" :
                              group.materials.Count >= 5  ? " - 中度重复" : " - 轻度重复";
            GUIStyle groupStyle = new GUIStyle(EditorStyles.foldout)
            {
                fontStyle = FontStyle.Bold,
                normal = { textColor = GetMatGroupColor(group.materials.Count) },
                onNormal = { textColor = GetMatGroupColor(group.materials.Count) }
            };

            Rect rect = GUILayoutUtility.GetRect(new GUIContent(group.shaderName + severity), groupStyle);
            group.isExpanded = EditorGUI.Foldout(rect, group.isExpanded, group.shaderName + severity, true, groupStyle);

            if (group.isExpanded)
            {
                EditorGUI.indentLevel++;
                foreach (var info in group.materials) DisplayMatInfo(info);
                EditorGUI.indentLevel--;
                EditorGUILayout.Space();
            }
        }

        EditorGUILayout.EndScrollView();
        DisplayMatStatistics();
    }

    void DisplayMatInfo(MatInfo info)
    {
        EditorGUILayout.BeginVertical(GUI.skin.box);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.ObjectField("", info.material, typeof(Material), false, GUILayout.Width(200));
        EditorGUILayout.BeginVertical();
        EditorGUILayout.LabelField(info.material.name, EditorStyles.boldLabel);
        EditorGUILayout.LabelField(info.path, EditorStyles.miniLabel);
        EditorGUILayout.LabelField($"引用数量: {info.referencedBy.Count}", EditorStyles.miniLabel);
        EditorGUILayout.EndVertical();
        if (GUILayout.Button("定位", GUILayout.Width(50)))
        {
            EditorGUIUtility.PingObject(info.material);
            Selection.activeObject = info.material;
        }
        EditorGUILayout.EndHorizontal();

        if (info.referencedBy.Count > 0)
        {
            EditorGUI.indentLevel++;
            info.isRefsExpanded = EditorGUILayout.Foldout(info.isRefsExpanded,
                $"引用列表 ({info.referencedBy.Count}个)", EditorStyles.foldout);
            if (info.isRefsExpanded)
            {
                foreach (string refPath in info.referencedBy)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("• " + Path.GetFileName(refPath), EditorStyles.miniLabel);
                    if (GUILayout.Button("查看", EditorStyles.miniButton, GUILayout.Width(40)))
                    {
                        Object obj = AssetDatabase.LoadAssetAtPath<Object>(refPath);
                        if (obj != null) { EditorGUIUtility.PingObject(obj); Selection.activeObject = obj; }
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
    }

    void DisplayMatStatistics()
    {
        EditorGUILayout.Space();
        int total    = matGroups.Sum(g => g.materials.Count);
        int severe   = matGroups.Count(g => g.materials.Count >= 10);
        int moderate = matGroups.Count(g => g.materials.Count >= 5 && g.materials.Count < 10);
        int light    = matGroups.Count(g => g.materials.Count < 5);

        string stats = $"统计信息:\n" +
                       $"  相似材质组: {matGroups.Count}\n" +
                       $"  严重重复组 (>=10个): {severe}\n" +
                       $"  中度重复组 (5-9个): {moderate}\n" +
                       $"  轻度重复组 (2-4个): {light}\n" +
                       $"  可优化材质数: {total}\n" +
                       $"  潜在节省: {total - matGroups.Count} 个材质";
        MessageType msgType = severe > 0 ? MessageType.Error :
                              moderate > 0 ? MessageType.Warning : MessageType.Info;
        EditorGUILayout.HelpBox(stats, msgType);
    }

    // ============================================================
    // 公共工具方法
    // ============================================================
    static bool IsPowerOfTwo(int x) => x > 0 && (x & (x - 1)) == 0;

    static int GetBitsPerPixel(TextureFormat format)
    {
        switch (format)
        {
            case TextureFormat.Alpha8:       return 8;
            case TextureFormat.ARGB4444:     return 16;
            case TextureFormat.RGB24:        return 24;
            case TextureFormat.RGBA32:       return 32;
            case TextureFormat.ARGB32:       return 32;
            case TextureFormat.RGB565:       return 16;
            case TextureFormat.DXT1:         return 4;
            case TextureFormat.DXT5:         return 8;
            case TextureFormat.PVRTC_RGB2:   return 2;
            case TextureFormat.PVRTC_RGBA2:  return 2;
            case TextureFormat.PVRTC_RGB4:   return 4;
            case TextureFormat.PVRTC_RGBA4:  return 4;
            case TextureFormat.ETC_RGB4:     return 4;
            case TextureFormat.ETC2_RGB:     return 4;
            case TextureFormat.ETC2_RGBA8:   return 8;
            case TextureFormat.ASTC_4x4:     return 8;
            case TextureFormat.ASTC_6x6:     return 3;
            case TextureFormat.ASTC_8x8:     return 2;
            default:                         return 16;
        }
    }

    void OnDestroy()
    {
        CleanupVFXAnalysis();
    }
}
