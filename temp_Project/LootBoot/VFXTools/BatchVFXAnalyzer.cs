using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Game.Editor.ParticlePrefabCollector;

#if UNITY_EDITOR
//Made by Soung, 2025.6.13, Using Claude 3.7
public class BatchVFXAnalyzer : EditorWindow
{
    private List<GameObject> prefabsList = new List<GameObject>();
    private Vector2 scrollPosition; // 用于预制体列表
    private Vector2 resultsScrollPosition; // 新增：用于结果列表的滚动位置
    private bool analyzing = false;
    private int currentIndex = 0;
    private List<VFXAnalysisResult> results = new List<VFXAnalysisResult>();
    private bool showResultsOnly = false;
    private string searchPath = "Assets/";
    private List<string> searchKeywords = new List<string>();
    private string newKeywordInput = "";

    private enum SortField
    {
        Name,
        ParticleSystemCount,
        EmitterCount,
        MaterialCount,
        TextureCount,
        DrawCall,
        VertexCount,
        TriangleCount,
        GPUMemory,
        IssueCount
    }
    private SortField sortField = SortField.DrawCall;
    private bool sortDescending = true; // 默认降序(从高到低)

    // 预设JSON路径（与 ParticleSystemSpawner 共用同一文件）
    private string presetJsonPath = "Assets/Editor/VFXTools/VFXPresetSpawn/VFXPresets.json";

    // 用于反序列化 VFXPresets.json 的内嵌数据结构
    [System.Serializable]
    private class VFXPresetDataEntry
    {
        public string function;
        public string attribute;
        public string weapon;
        public string prefabName;
        public string prefabPath;
    }

    [System.Serializable]
    private class VFXPresetJsonRoot
    {
        public List<VFXPresetDataEntry> presets = new List<VFXPresetDataEntry>();
    }

    private class VFXAnalysisResult
    {
        public GameObject prefab;
        public string prefabName;
        public int particleSystemCount;
        public int emitterCount;
        public int materialCount;
        public int textureCount;
        public int drawCallsEstimate;
        public int batchesEstimate;
        public int vertexCount;
        public int triangleCount;
        public float gpuMemoryEstimate;
        public int shaderComplexity;
        public int duplicateTextureCount;
        public List<string> performanceIssues = new List<string>();
    }

    [MenuItem("TATools/VFXTools/VFX批量性能分析器")]
    public static void ShowWindow()
    {
        GetWindow<BatchVFXAnalyzer>("特效批量性能分析");
    }

    void OnGUI()
    {
        GUILayout.Label("// 批量特效预制体性能分析 //", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("对特效预制体进行性能分析, 部分数据使用Unity Stats值, 在编辑器模式下可能不准确。", MessageType.None, false);
        EditorGUILayout.Space();

        // 添加一个切换，用于切换是否仅显示分析结果
        showResultsOnly = EditorGUILayout.Toggle("仅显示分析结果", showResultsOnly);

        EditorGUILayout.Space();

        // 只有当不是仅显示结果模式时，才显示预制体列表部分
        if (!showResultsOnly)
        {
            // 搜索设置
            EditorGUILayout.LabelField("搜索设置", EditorStyles.boldLabel);

            // 搜索路径
            EditorGUILayout.BeginHorizontal();
            searchPath = EditorGUILayout.TextField("搜索路径", searchPath);
            if (GUILayout.Button("浏览", GUILayout.Width(50)))
            {
                string selected = EditorUtility.OpenFolderPanel("选择搜索路径", Application.dataPath, "");
                if (!string.IsNullOrEmpty(selected))
                {
                    string dataPath = Application.dataPath.Replace("\\", "/");
                    selected = selected.Replace("\\", "/");
                    if (selected.StartsWith(dataPath))
                        searchPath = "Assets" + selected.Substring(dataPath.Length);
                    else
                        EditorUtility.DisplayDialog("路径错误", "请选择 Assets 文件夹内的路径", "确定");
                }
            }
            EditorGUILayout.EndHorizontal();

            // 关键字输入（可添加多个，满足任意一个即匹配）
            EditorGUILayout.BeginHorizontal();
            newKeywordInput = EditorGUILayout.TextField("添加关键字", newKeywordInput);
            if (GUILayout.Button("添加", GUILayout.Width(50)) && !string.IsNullOrWhiteSpace(newKeywordInput))
            {
                string kw = newKeywordInput.Trim();
                if (!searchKeywords.Contains(kw))
                    searchKeywords.Add(kw);
                newKeywordInput = "";
                GUI.FocusControl(null);
            }
            EditorGUILayout.EndHorizontal();

            // 当前关键字列表
            if (searchKeywords.Count > 0)
            {
                EditorGUILayout.LabelField("当前关键字（路径或名称含任意一个即匹配）:", EditorStyles.miniLabel);
                for (int ki = 0; ki < searchKeywords.Count; ki++)
                {
                    EditorGUILayout.BeginHorizontal();
                    GUILayout.Space(10);
                    EditorGUILayout.LabelField("• " + searchKeywords[ki]);
                    if (GUILayout.Button("移除", EditorStyles.miniButton, GUILayout.Width(45)))
                    {
                        searchKeywords.RemoveAt(ki);
                        ki--;
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            else
            {
                EditorGUILayout.LabelField("（无关键字限制，将搜索指定路径下所有VFX预制体）", EditorStyles.miniLabel);
            }

            // 查找按钮行
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("按路径+关键字查找"))
            {
                FindVFXPrefabsByPathAndKeywords();
            }
            if (GUILayout.Button("自动查找全部VFX"))
            {
                FindAllVFXPrefabs();
                Debug.Log("<color=#66ccff><b><size=10>VFXAnalyzer INFO:\n>>>开始自动搜索当前工程中的所有VFX预制体, 可能需要一些时间, 请耐心等待<<<\n>>>搜索完成后, 可以在列表中查看结果, 并进行分析<<<</size></b></color>");
            }
            GUILayout.EndHorizontal();

            // 从预设JSON导入
            EditorGUILayout.LabelField("从预设JSON导入", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            presetJsonPath = EditorGUILayout.TextField(presetJsonPath);
            if (GUILayout.Button("浏览", GUILayout.Width(50)))
            {
                string absPath = EditorUtility.OpenFilePanel("选择VFXPresets.json", Application.dataPath, "json");
                if (!string.IsNullOrEmpty(absPath))
                    presetJsonPath = "Assets" + absPath.Substring(Application.dataPath.Length).Replace('\\', '/');
            }
            if (GUILayout.Button("导入", GUILayout.Width(50)))
            {
                ImportFromPresetJson();
            }
            EditorGUILayout.EndHorizontal();

            // 预制体列表
            EditorGUILayout.LabelField("特效预制体列表", EditorStyles.boldLabel);

            GUILayout.BeginHorizontal();
            if (GUILayout.Button("添加选中的预制体"))
            {
                AddSelectedPrefabs();
            }
            if (GUILayout.Button("清空列表"))
            {
                prefabsList.Clear();
                results.Clear();
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUI.enabled = prefabsList.Any(prefab => prefab != null);
            if (GUILayout.Button("导入到特效批量预览器"))
            {
                ExportToParticlePrefabCollector();
            }
            GUI.enabled = true;
            GUILayout.EndHorizontal();

            // 显示预制体列表
            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

            for (int i = 0; i < prefabsList.Count; i++)
            {
                if (prefabsList[i] != null)
                {
                    GUILayout.BeginHorizontal();
                    prefabsList[i] = (GameObject)EditorGUILayout.ObjectField(prefabsList[i], typeof(GameObject), false);

                    if (GUILayout.Button("移除", GUILayout.Width(60)))
                    {
                        prefabsList.RemoveAt(i);
                        if (i < results.Count)
                        {
                            results.RemoveAt(i);
                        }
                        i--;
                    }

                    GUILayout.EndHorizontal();
                }
                else
                {
                    prefabsList.RemoveAt(i);
                    if (i < results.Count)
                    {
                        results.RemoveAt(i);
                    }
                    i--;
                }
            }

            EditorGUILayout.EndScrollView();

            EditorGUILayout.Space();
        }

        // 分析按钮
        GUI.enabled = prefabsList.Count > 0 && !analyzing;
        GUI.backgroundColor = analyzing ? Color.yellow : Color.green;
        if (GUILayout.Button(analyzing ? "分析中..." : "分析所有预制体", GUILayout.Height(36)))
        {
            AnalyzeAllPrefabs();
        }
        GUI.backgroundColor = Color.white;
        GUI.enabled = true;

        EditorGUILayout.Space();

        // 显示分析结果
        if (results.Count > 0)
        {
            DisplayResults();
        }
    }

    // 按指定路径 + 多关键字查找VFX预制体（关键字满足任意一个即匹配）
    private void FindVFXPrefabsByPathAndKeywords()
    {
        if (!AssetDatabase.IsValidFolder(searchPath))
        {
            EditorUtility.DisplayDialog("路径错误", $"路径 '{searchPath}' 不存在，请检查搜索路径", "确定");
            return;
        }

        HashSet<string> existingPaths = new HashSet<string>();
        foreach (var existingPrefab in prefabsList)
        {
            if (existingPrefab != null)
                existingPaths.Add(AssetDatabase.GetAssetPath(existingPrefab));
        }

        string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { searchPath });
        int foundCount = 0;

        foreach (string guid in guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);

            if (existingPaths.Contains(assetPath))
                continue;

            // 关键字过滤：无关键字则全部匹配，有关键字则路径/名称含任意一个即匹配
            if (searchKeywords.Count > 0)
            {
                string lowerPath = assetPath.ToLower();
                bool matched = false;
                foreach (var kw in searchKeywords)
                {
                    if (lowerPath.Contains(kw.ToLower()))
                    {
                        matched = true;
                        break;
                    }
                }
                if (!matched)
                    continue;
            }

            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
            if (prefab != null &&
                prefab.GetComponentInChildren<ParticleSystem>(true) != null)
            {
                prefabsList.Add(prefab);
                existingPaths.Add(assetPath);
                foundCount++;
            }
        }

        string keywordsDesc = searchKeywords.Count > 0
            ? $"，关键字: [{string.Join(", ", searchKeywords)}]"
            : "（无关键字限制）";
        EditorUtility.DisplayDialog("搜索完成",
            $"路径: {searchPath}{keywordsDesc}\n共找到 {foundCount} 个VFX预制体并添加到列表", "确定");
    }

    private void AddSelectedPrefabs()
    {
        foreach (var obj in Selection.gameObjects)
        {
            if (PrefabUtility.GetPrefabAssetType(obj) != PrefabAssetType.NotAPrefab)
            {
                // 确保不重复添加
                if (!prefabsList.Contains(obj))
                {
                    prefabsList.Add(obj);
                }
            }
        }
    }

    private void FindAllVFXPrefabs()
    {
        prefabsList.Clear();
        results.Clear();

        // 查找所有预制体
        string[] guids = AssetDatabase.FindAssets("t:Prefab");
        int foundCount = 0;

        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);

            // 必须包含至少一个粒子系统
            if (prefab != null && prefab.GetComponentInChildren<ParticleSystem>(true) != null)
            {
                prefabsList.Add(prefab);
                foundCount++;
            }
        }

        EditorUtility.DisplayDialog("搜索完成", $"找到 {foundCount} 个VFX预制体", "确定");
        Debug.Log($"找到 {foundCount} 个VFX预制体");
    }

    private void ImportFromPresetJson()
    {
        if (!File.Exists(presetJsonPath))
        {
            EditorUtility.DisplayDialog("文件不存在", $"找不到配置文件：\n{presetJsonPath}", "确定");
            return;
        }

        VFXPresetJsonRoot root;
        try
        {
            string json = File.ReadAllText(presetJsonPath);
            root = JsonUtility.FromJson<VFXPresetJsonRoot>(json);
        }
        catch (System.Exception e)
        {
            EditorUtility.DisplayDialog("读取失败", $"解析JSON失败：\n{e.Message}", "确定");
            return;
        }

        if (root == null || root.presets == null || root.presets.Count == 0)
        {
            EditorUtility.DisplayDialog("导入结果", "配置文件中没有任何预设条目", "确定");
            return;
        }

        HashSet<string> existingPaths = new HashSet<string>();
        foreach (var go in prefabsList)
        {
            if (go != null)
                existingPaths.Add(AssetDatabase.GetAssetPath(go));
        }

        int addedCount = 0;
        int skipCount = 0;
        foreach (var entry in root.presets)
        {
            if (string.IsNullOrEmpty(entry.prefabPath))
                continue;

            if (existingPaths.Contains(entry.prefabPath))
            {
                skipCount++;
                continue;
            }

            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(entry.prefabPath);
            if (prefab != null)
            {
                prefabsList.Add(prefab);
                existingPaths.Add(entry.prefabPath);
                addedCount++;
            }
            else
            {
                Debug.LogWarning($"[BatchVFXAnalyzer] 无法加载预制体：{entry.prefabPath}（条目：{entry.function}/{entry.attribute}/{entry.weapon}）");
            }
        }

        EditorUtility.DisplayDialog("导入完成",
            $"从预设JSON导入完成\n新增：{addedCount} 个\n跳过（已在列表中）：{skipCount} 个", "确定");
    }

    private void ExportToParticlePrefabCollector()
    {
        List<string> prefabPaths = prefabsList
            .Where(prefab => prefab != null)
            .Select(AssetDatabase.GetAssetPath)
            .Where(path => !string.IsNullOrEmpty(path))
            .Distinct()
            .ToList();

        if (prefabPaths.Count == 0)
        {
            EditorUtility.DisplayDialog("导出失败", "当前分析列表中没有可导出的有效预制体", "确定");
            return;
        }

        ParticlePrefabCollectorWindow.ImportFromExternalAnalyzer(prefabPaths);
    }

    private void AnalyzeAllPrefabs()
    {
        if (prefabsList.Count == 0)
            return;

        analyzing = true;
        currentIndex = 0;
        results.Clear();

        // 利用延迟调用来分析每个预制体，确保Stats数据更新
        AnalyzeNextPrefabWithStats();
    }

    private void AnalyzeNextPrefabWithStats()
    {
        if (currentIndex >= prefabsList.Count)
        {
            analyzing = false;
            Repaint();
            return;
        }

        GameObject prefab = prefabsList[currentIndex];

        if (prefab != null)
        {
            // 记录初始状态
            int originalVertices = UnityEditor.UnityStats.vertices;
            int originalTriangles = UnityEditor.UnityStats.triangles;
            int originalDrawCalls = UnityEditor.UnityStats.drawCalls;
            int originalBatches = UnityEditor.UnityStats.batches;

            // 实例化预制体
            GameObject instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;

            // 分析基本组件
            VFXAnalysisResult result = new VFXAnalysisResult();
            result.prefab = prefab;
            result.prefabName = prefab.name;

            // 延迟一帧获取统计数据
            SceneView.RepaintAll();
            EditorApplication.QueuePlayerLoopUpdate();

            EditorApplication.delayCall += () =>
            {
                // 先读取Stats（instance仍然存在），再收集组件数据
                int currentVertices = UnityEditor.UnityStats.vertices;
                int currentTriangles = UnityEditor.UnityStats.triangles;
                int currentDrawCalls = UnityEditor.UnityStats.drawCalls;
                int currentBatches = UnityEditor.UnityStats.batches;

                // 收集基本组件信息（内部不再销毁instance）
                CollectComponentData(instance, result);

                // 计算Stats差值，若有效则覆盖组件估算值
                int statsDeltaVertices = Mathf.Max(0, currentVertices - originalVertices);
                int statsDeltaTriangles = Mathf.Max(0, currentTriangles - originalTriangles);
                int statsDeltaDrawCalls = Mathf.Max(0, currentDrawCalls - originalDrawCalls);
                int statsDeltaBatches = Mathf.Max(0, currentBatches - originalBatches);

                if (statsDeltaVertices > 0)
                    result.vertexCount = statsDeltaVertices;
                if (statsDeltaTriangles > 0)
                    result.triangleCount = statsDeltaTriangles;
                if (statsDeltaDrawCalls > 0)
                {
                    result.drawCallsEstimate = statsDeltaDrawCalls;
                    result.batchesEstimate = statsDeltaBatches;
                }
                else
                {
                    // Stats无效，保留CollectComponentData中基于渲染队列的估算值
                    Debug.LogWarning($"[批量分析器] 无法从Stats获取DrawCall数据，使用渲染队列估算值 - DrawCalls: {result.drawCallsEstimate}, Batches: {result.batchesEstimate}");
                }

                // 添加到结果列表
                results.Add(result);

                // 销毁实例
                DestroyImmediate(instance);

                // 分析下一个预制体
                currentIndex++;
                if (currentIndex >= prefabsList.Count)
                {
                    // 所有预制体分析完成后，进行初始排序
                    SortResults();
                }
                AnalyzeNextPrefabWithStats();
            };
        }
        else
        {
            currentIndex++;
            AnalyzeNextPrefabWithStats();
        }
    }

    // 收集组件数据的辅助方法
    private void CollectComponentData(GameObject instance, VFXAnalysisResult result)
    {
        int vertexCount = 0;
        int triangleCount = 0;

        // 分析粒子系统
        var particleSystems = instance.GetComponentsInChildren<ParticleSystem>(true);
        result.particleSystemCount = particleSystems.Length;

        // 计算发射器数量
        result.emitterCount = 0;
        foreach (var ps in particleSystems)
        {
            var emission = ps.emission;
            if (emission.enabled)
            {
                result.emitterCount++;
            }

            // 检查子发射器
            var subEmitters = ps.subEmitters;
            if (subEmitters.enabled)
            {
                result.emitterCount += subEmitters.subEmittersCount;
            }
        }

        // 分析材质和纹理 (这部分代码可以保持不变)
        HashSet<Material> materials = new HashSet<Material>();
        Dictionary<string, Texture> uniqueTextures = new Dictionary<string, Texture>();
        HashSet<string> textureHashes = new HashSet<string>();

        // 收集所有渲染器
        var renderers = instance.GetComponentsInChildren<Renderer>(true);

        // 收集材质和纹理信息
        foreach (var renderer in renderers)
        {
            foreach (var material in renderer.sharedMaterials)
            {
                if (material != null && !materials.Contains(material))
                {
                    materials.Add(material);

                    // 分析材质中的纹理
                    if (material.shader != null)
                    {
                        Shader shader = material.shader;
                        int propertyCount = ShaderUtil.GetPropertyCount(shader);

                        for (int i = 0; i < propertyCount; i++)
                        {
                            if (ShaderUtil.GetPropertyType(shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
                            {
                                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                                Texture tex = material.GetTexture(propertyName);

                                if (tex != null)
                                {
                                    // 计算纹理哈希值用于检测重复
                                    string texHash = "";
                                    if (tex is Texture2D)
                                    {
                                        Texture2D tex2D = tex as Texture2D;
                                        texHash = tex2D.width + "x" + tex2D.height + "_" + tex2D.format.ToString();
                                    }

                                    if (!uniqueTextures.ContainsKey(tex.name))
                                    {
                                        uniqueTextures.Add(tex.name, tex);
                                    }
                                    else if (!string.IsNullOrEmpty(texHash) && !textureHashes.Contains(texHash))
                                    {
                                        // 发现名称相同但内容不同的纹理
                                        uniqueTextures.Add(tex.name + "_dup", tex);
                                    }

                                    if (!string.IsNullOrEmpty(texHash))
                                    {
                                        if (textureHashes.Contains(texHash))
                                        {
                                            result.duplicateTextureCount++;
                                        }
                                        else
                                        {
                                            textureHashes.Add(texHash);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 计算顶点和三角形数
            if (renderer is MeshRenderer)
            {
                MeshFilter meshFilter = renderer.GetComponent<MeshFilter>();
                if (meshFilter != null && meshFilter.sharedMesh != null)
                {
                    vertexCount += meshFilter.sharedMesh.vertexCount;
                    triangleCount += meshFilter.sharedMesh.triangles.Length / 3;
                }
            }
            else if (renderer is SkinnedMeshRenderer)
            {
                SkinnedMeshRenderer smr = renderer as SkinnedMeshRenderer;
                if (smr.sharedMesh != null)
                {
                    vertexCount += smr.sharedMesh.vertexCount;
                    triangleCount += smr.sharedMesh.triangles.Length / 3;
                }
            }
            else if (renderer is ParticleSystemRenderer)
            {
                ParticleSystemRenderer psr = renderer as ParticleSystemRenderer;
                ParticleSystem ps = psr.GetComponent<ParticleSystem>();

                // 使用实际粒子数而不是最大粒子数进行估算
                // 对于编辑器分析，可以用平均估计值或模拟数据
                float estimatedActiveParticles = ps != null ?
                    Mathf.Min(ps.main.maxParticles, ps.main.maxParticles * 0.3f) : 100; // 估计平均30%的粒子是活跃的

                if (psr.renderMode == ParticleSystemRenderMode.Mesh && psr.mesh != null)
                {
                    // 考虑GPU实例化优化
                    bool canUseGPUInstancing = psr.enableGPUInstancing &&
                                             (psr.sharedMaterial != null && psr.sharedMaterial.enableInstancing);

                    float instanceMultiplier = canUseGPUInstancing ? 0.1f : 1.0f; // GPU实例化情况下降低计数因子

                    vertexCount += (int)(psr.mesh.vertexCount * estimatedActiveParticles * instanceMultiplier);
                    triangleCount += (int)((psr.mesh.triangles.Length / 3) * estimatedActiveParticles * instanceMultiplier);
                }
                else
                {
                    // 默认四边形粒子
                    vertexCount += (int)(4 * estimatedActiveParticles);
                    triangleCount += (int)(2 * estimatedActiveParticles);
                }
            }
        }

        result.materialCount = materials.Count;
        result.textureCount = uniqueTextures.Count;

        // 更精确地估算DrawCall
        // 不同的渲染队列、不同的材质、重叠透明物体会增加DrawCall
        result.drawCallsEstimate = 0;
        Dictionary<int, HashSet<Material>> renderQueueToMaterials = new Dictionary<int, HashSet<Material>>();

        foreach (var material in materials)
        {
            int renderQueue = material.renderQueue;
            if (!renderQueueToMaterials.ContainsKey(renderQueue))
            {
                renderQueueToMaterials[renderQueue] = new HashSet<Material>();
            }
            renderQueueToMaterials[renderQueue].Add(material);
        }

        // 计算基于渲染队列的DrawCall估算值
        foreach (var kvp in renderQueueToMaterials)
        {
            if (kvp.Key >= 3000) // 透明队列
            {
                // 透明物体通常无法批处理
                result.drawCallsEstimate += kvp.Value.Count;
            }
            else
            {
                // 不透明物体可能会进行静态批处理和动态批处理
                result.drawCallsEstimate += Mathf.Max(1, kvp.Value.Count / 2);
            }
        }

        result.batchesEstimate = result.drawCallsEstimate;
        result.vertexCount = vertexCount;
        result.triangleCount = triangleCount;

        // 估算GPU内存占用
        result.gpuMemoryEstimate = 0;
        foreach (var tex in uniqueTextures.Values)
        {
            if (tex is Texture2D)
            {
                Texture2D tex2d = tex as Texture2D;
                int bpp = GetBitsPerPixel(tex2d.format);
                float memorySizeMB = (tex2d.width * tex2d.height * bpp / 8f) / (1024f * 1024f);
                result.gpuMemoryEstimate += memorySizeMB;
            }
        }

        // 估算shader复杂度
        result.shaderComplexity = 0;
        foreach (var material in materials)
        {
            if (material.shader != null)
            {
                string shaderName = material.shader.name.ToLower();

                // 基于shader名称的简单复杂度启发式算法
                if (shaderName.Contains("distortion") || shaderName.Contains("displacement"))
                {
                    result.shaderComplexity += 3;
                }
                else if (shaderName.Contains("additive") || shaderName.Contains("multiply"))
                {
                    result.shaderComplexity += 2;
                }
                else
                {
                    result.shaderComplexity += 1;
                }
            }
        }

        // 检测性能问题
        DetectPerformanceIssues(result, particleSystems, uniqueTextures.Values.ToList());
    }

    // 新增：获取纹理格式的每像素位数
    private int GetBitsPerPixel(TextureFormat format)
    {
        switch (format)
        {
            case TextureFormat.Alpha8: return 8;
            case TextureFormat.ARGB4444: return 16;
            case TextureFormat.RGB24: return 24;
            case TextureFormat.RGBA32: return 32;
            case TextureFormat.ARGB32: return 32;
            case TextureFormat.RGB565: return 16;
            case TextureFormat.DXT1: return 4;
            case TextureFormat.DXT5: return 8;
            case TextureFormat.PVRTC_RGB2: return 2;
            case TextureFormat.PVRTC_RGBA2: return 2;
            case TextureFormat.PVRTC_RGB4: return 4;
            case TextureFormat.PVRTC_RGBA4: return 4;
            case TextureFormat.ETC_RGB4: return 4;
            case TextureFormat.ETC2_RGB: return 4;
            case TextureFormat.ETC2_RGBA8: return 8;
            case TextureFormat.ASTC_4x4: return 8;
            case TextureFormat.ASTC_6x6: return 3; // 近似值
            case TextureFormat.ASTC_8x8: return 2; // 近似值
            default: return 16; // 默认假设
        }
    }

    // 新增：检测性能问题
    private void DetectPerformanceIssues(VFXAnalysisResult result, ParticleSystem[] particleSystems, List<Texture> textures)
    {
        // 检查粒子系统过多
        if (result.particleSystemCount > 10)
        {
            result.performanceIssues.Add("粒子系统数量过多(" + result.particleSystemCount + ")，考虑合并相似系统");
        }

        // 检查材质过多
        if (result.materialCount > 5)
        {
            result.performanceIssues.Add("材质数量过多(" + result.materialCount + ")，考虑合并材质");
        }

        // 检查DrawCall过多
        if (result.drawCallsEstimate > 8)
        {
            result.performanceIssues.Add("预估DrawCall数量过多(" + result.drawCallsEstimate + ")，可能影响性能");
        }

        // 检查非2次幂纹理
        foreach (var tex in textures)
        {
            if (tex is Texture2D)
            {
                Texture2D tex2d = tex as Texture2D;
                bool isPowerOfTwo = IsPowerOfTwo(tex2d.width) && IsPowerOfTwo(tex2d.height);
                if (!isPowerOfTwo)
                {
                    result.performanceIssues.Add("纹理 " + tex2d.name + " 不是2的幂尺寸(" + tex2d.width + "x" + tex2d.height + ")");
                }

                // 检查纹理过大
                if (tex2d.width > 1024 || tex2d.height > 1024)
                {
                    result.performanceIssues.Add("纹理 " + tex2d.name + " 尺寸过大(" + tex2d.width + "x" + tex2d.height + ")");
                }
            }
        }

        // 检查粒子系统设置
        foreach (var ps in particleSystems)
        {
            // 检查最大粒子数
            if (ps.main.maxParticles > 1000)
            {
                result.performanceIssues.Add("粒子系统 " + ps.name + " 最大粒子数过大(" + ps.main.maxParticles + ")");
            }

            // 检查碰撞
            if (ps.collision.enabled)
            {
                result.performanceIssues.Add("粒子系统 " + ps.name + " 启用了碰撞，可能影响性能");
            }

            // 检查子发射器
            if (ps.subEmitters.enabled && ps.subEmitters.subEmittersCount > 2)
            {
                result.performanceIssues.Add("粒子系统 " + ps.name + " 包含多个子发射器，可能影响性能");
            }
        }

        // 检查重复纹理
        if (result.duplicateTextureCount > 0)
        {
            result.performanceIssues.Add("检测到 " + result.duplicateTextureCount + " 个内容相似的重复纹理");
        }
    }

    private bool IsPowerOfTwo(int x)
    {
        return (x != 0) && ((x & (x - 1)) == 0);
    }

    private void DisplayResults()
    {
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        EditorGUILayout.LabelField("批量分析结果", EditorStyles.boldLabel);

        // 添加排序选项
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("排序方式:", GUILayout.Width(60));
        SortField newSortField = (SortField)EditorGUILayout.EnumPopup(sortField, GUILayout.Width(120));
        if (newSortField != sortField)
        {
            sortField = newSortField;
            SortResults();
        }

        GUIContent sortOrderContent = new GUIContent(sortDescending ? "↓ 降序" : "↑ 升序", "切换排序顺序");
        if (GUILayout.Button(sortOrderContent, GUILayout.Width(80)))
        {
            sortDescending = !sortDescending;
            SortResults();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        // 创建表头 - 添加可点击的表头进行排序
        EditorGUILayout.BeginHorizontal();

        // 每个表头按钮的样式
        GUIStyle headerStyle = new GUIStyle(EditorStyles.boldLabel);
        headerStyle.alignment = TextAnchor.MiddleCenter;

        // 名称表头
        if (GUILayout.Button("预制体名称", sortField == SortField.Name ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(180)))
        {
            if (sortField == SortField.Name)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.Name;
                sortDescending = true;
            }
            SortResults();
        }

        // 粒子系统表头
        if (GUILayout.Button("粒子系统", sortField == SortField.ParticleSystemCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(50)))
        {
            if (sortField == SortField.ParticleSystemCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.ParticleSystemCount;
                sortDescending = true;
            }
            SortResults();
        }

        // 发射器表头
        if (GUILayout.Button("发射器", sortField == SortField.EmitterCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(50)))
        {
            if (sortField == SortField.EmitterCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.EmitterCount;
                sortDescending = true;
            }
            SortResults();
        }

        // 材质表头
        if (GUILayout.Button("材质", sortField == SortField.MaterialCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(40)))
        {
            if (sortField == SortField.MaterialCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.MaterialCount;
                sortDescending = true;
            }
            SortResults();
        }

        // 纹理表头
        if (GUILayout.Button("纹理", sortField == SortField.TextureCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(40)))
        {
            if (sortField == SortField.TextureCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.TextureCount;
                sortDescending = true;
            }
            SortResults();
        }

        // DrawCall表头
        if (GUILayout.Button("DrawCall", sortField == SortField.DrawCall ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(60)))
        {
            if (sortField == SortField.DrawCall)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.DrawCall;
                sortDescending = true;
            }
            SortResults();
        }

        // 顶点数表头
        if (GUILayout.Button("顶点数", sortField == SortField.VertexCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(60)))
        {
            if (sortField == SortField.VertexCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.VertexCount;
                sortDescending = true;
            }
            SortResults();
        }

        // 三角形表头
        if (GUILayout.Button("三角形", sortField == SortField.TriangleCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(60)))
        {
            if (sortField == SortField.TriangleCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.TriangleCount;
                sortDescending = true;
            }
            SortResults();
        }

        // GPU内存表头
        if (GUILayout.Button("GPU内存", sortField == SortField.GPUMemory ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(60)))
        {
            if (sortField == SortField.GPUMemory)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.GPUMemory;
                sortDescending = true;
            }
            SortResults();
        }

        // 问题数表头
                if (GUILayout.Button("问题", sortField == SortField.IssueCount ?
            (sortDescending ? EditorStyles.boldLabel : headerStyle) : headerStyle, GUILayout.Width(70)))
        {
            if (sortField == SortField.IssueCount)
                sortDescending = !sortDescending;
            else
            {
                sortField = SortField.IssueCount;
                sortDescending = true;
            }
            SortResults();
        }

        EditorGUILayout.EndHorizontal();

        // 在这里开始结果列表的滚动视图
        resultsScrollPosition = EditorGUILayout.BeginScrollView(resultsScrollPosition, GUILayout.ExpandHeight(true));

        // 显示每个预制体的分析结果
        foreach (var result in results)
        {
            if (result.prefab != null)
            {
                EditorGUILayout.BeginHorizontal();

                // 添加颜色高亮（根据性能指标）
                bool hasHighDrawCalls = result.drawCallsEstimate > 50;
                bool hasManyParticleSystems = result.particleSystemCount > 25;
                bool hasHighGPUMemory = result.gpuMemoryEstimate > 20;
                bool hasIssues = result.performanceIssues.Count > 5;

                if (hasHighDrawCalls || hasManyParticleSystems || hasHighGPUMemory || hasIssues)
                {
                    GUI.color = new Color(1.0f, 0.7f, 0.7f); // 淡红色
                }
                else
                {
                    GUI.color = Color.white;
                }

                // 带图标的ObjectField，点击即在项目视窗中定位
                EditorGUILayout.ObjectField(result.prefab, typeof(GameObject), false, GUILayout.Width(180));

                EditorGUILayout.LabelField(result.particleSystemCount.ToString(), GUILayout.Width(50));
                EditorGUILayout.LabelField(result.emitterCount.ToString(), GUILayout.Width(50));
                EditorGUILayout.LabelField(result.materialCount.ToString(), GUILayout.Width(40));
                EditorGUILayout.LabelField(result.textureCount.ToString(), GUILayout.Width(40));
                EditorGUILayout.LabelField(result.drawCallsEstimate.ToString(), GUILayout.Width(60));
                EditorGUILayout.LabelField(result.vertexCount.ToString(), GUILayout.Width(60));
                EditorGUILayout.LabelField(result.triangleCount.ToString(), GUILayout.Width(60));
                EditorGUILayout.LabelField(result.gpuMemoryEstimate.ToString("F1") + "MB", GUILayout.Width(60));

                // 问题按钮
                if (result.performanceIssues.Count > 0)
                {
                    GUI.color = new Color(1.0f, 0.5f, 0.5f);
                    if (GUILayout.Button($"! {result.performanceIssues.Count} 项问题", GUILayout.Width(70)))
                    {
                        GUI.color = Color.white;
                        ShowPerformanceIssues(result);
                    }
                }
                else
                {
                    EditorGUILayout.LabelField("无问题", GUILayout.Width(70));
                }

                GUI.color = Color.white;

                EditorGUILayout.EndHorizontal();
            }
        }

        // 结束滚动视图
        EditorGUILayout.EndScrollView();
    }


    // 添加排序方法
    private void SortResults()
    {
        if (results == null || results.Count == 0)
            return;

        switch (sortField)
        {
            case SortField.Name:
                results = sortDescending
                    ? results.OrderByDescending(r => r.prefabName).ToList()
                    : results.OrderBy(r => r.prefabName).ToList();
                break;
            case SortField.ParticleSystemCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.particleSystemCount).ToList()
                    : results.OrderBy(r => r.particleSystemCount).ToList();
                break;
            case SortField.EmitterCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.emitterCount).ToList()
                    : results.OrderBy(r => r.emitterCount).ToList();
                break;
            case SortField.MaterialCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.materialCount).ToList()
                    : results.OrderBy(r => r.materialCount).ToList();
                break;
            case SortField.TextureCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.textureCount).ToList()
                    : results.OrderBy(r => r.textureCount).ToList();
                break;
            case SortField.DrawCall:
                results = sortDescending
                    ? results.OrderByDescending(r => r.drawCallsEstimate).ToList()
                    : results.OrderBy(r => r.drawCallsEstimate).ToList();
                break;
            case SortField.VertexCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.vertexCount).ToList()
                    : results.OrderBy(r => r.vertexCount).ToList();
                break;
            case SortField.TriangleCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.triangleCount).ToList()
                    : results.OrderBy(r => r.triangleCount).ToList();
                break;
            case SortField.GPUMemory:
                results = sortDescending
                    ? results.OrderByDescending(r => r.gpuMemoryEstimate).ToList()
                    : results.OrderBy(r => r.gpuMemoryEstimate).ToList();
                break;
            case SortField.IssueCount:
                results = sortDescending
                    ? results.OrderByDescending(r => r.performanceIssues.Count).ToList()
                    : results.OrderBy(r => r.performanceIssues.Count).ToList();
                break;
        }

        // 重绘窗口以显示排序结果
        Repaint();
    }

    // 添加显示性能问题详情的方法
    private void ShowPerformanceIssues(VFXAnalysisResult result)
    {
        if (result.performanceIssues.Count == 0)
            return;

        string title = result.prefabName + " 的性能问题";
        string message = string.Join("\n\n", result.performanceIssues);
        
        EditorUtility.DisplayDialog(title, message, "确定");
    }
}
#endif