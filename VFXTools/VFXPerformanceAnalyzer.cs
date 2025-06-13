using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Rendering;

//Made by Soung, 2025.6.13, Using Claude 3.7
public class VFXPerformanceAnalyzer : EditorWindow
{
    private GameObject targetPrefab;
    private Vector2 scrollPosition;
    private GameObject instantiatedPrefab;
    private Dictionary<string, Texture> texturesUsed = new Dictionary<string, Texture>();
    private Dictionary<string, Material> materialsUsed = new Dictionary<string, Material>();
    private Dictionary<string, Shader> shadersUsed = new Dictionary<string, Shader>();
    private int particleSystemCount = 0;
    private int emitterCount = 0;    private int trailRendererCount = 0;
    private int lineRendererCount = 0;
    private int batchesCount = 0;
    private int drawCallsCount = 0;
    private int vertexCount = 0;
    private int triangleCount = 0;
    private float gpuMemoryUsage = 0;
    private List<string> performanceIssues = new List<string>();
    private bool showMaterials = false;
    private bool showTextures = false;
    private bool showShaders = false;
    private bool showIssues = false;
    private bool isAnalyzing = false;
    private string statusMessage = "";
    private Dictionary<Texture, float> textureSizes = new Dictionary<Texture, float>();

    private int originalVertexCount = 0;
    private int originalTriangleCount = 0;
    private int originalDrawCalls = 0;
    private int originalBatches = 0;
    private int currentVertexCount = 0;
    private int currentTriangleCount = 0;
    private int currentDrawCalls = 0;
    private int currentBatches = 0;

    [MenuItem("工具/VFX性能分析器")]
    public static void ShowWindow()
    {
        GetWindow<VFXPerformanceAnalyzer>("特效性能分析器");
    }

    void OnGUI()
    {
        GUILayout.Label("特效预制体性能分析器", EditorStyles.boldLabel);

        EditorGUILayout.Space();

        targetPrefab = (GameObject)EditorGUILayout.ObjectField("目标特效预制体", targetPrefab, typeof(GameObject), false);

        EditorGUILayout.Space();

        if (GUILayout.Button("分析特效预制体"))
        {
            if (targetPrefab != null)
            {
                AnalyzePrefab();
            }
            else
            {
                Debug.LogError("请先选择一个特效预制体");
            }
        }

        EditorGUILayout.Space();

        if (isAnalyzing)
        {
            EditorGUILayout.HelpBox(statusMessage, MessageType.Info);
        }

        if (targetPrefab != null && !isAnalyzing && materialsUsed.Count > 0)
        {
            DisplayResults();
        }
    }

    private void AnalyzePrefab()
    {
        isAnalyzing = true;
        statusMessage = "正在分析...";

        // 清空之前的数据
        CleanupPreviousAnalysis();

        // 记录分析前的场景状态
        originalVertexCount = UnityEditor.UnityStats.vertices;
        originalTriangleCount = UnityEditor.UnityStats.triangles;
        originalDrawCalls = UnityEditor.UnityStats.drawCalls;
        originalBatches = UnityEditor.UnityStats.batches;

        // 实例化预制体进行分析
        instantiatedPrefab = Instantiate(targetPrefab);
        instantiatedPrefab.name = targetPrefab.name + " (Performance Analysis)";

        // 分析组件 - 先收集材质、纹理等基本信息
        AnalyzeComponents();

        // 强制更新场景，获取包含预制体的新状态
        SceneView.RepaintAll();
        EditorApplication.QueuePlayerLoopUpdate();

        // 等待一帧确保统计数据已更新
        EditorApplication.delayCall += () =>
        {
            // 记录当前状态并计算差异
            currentVertexCount = UnityEditor.UnityStats.vertices;
            currentTriangleCount = UnityEditor.UnityStats.triangles;
            currentDrawCalls = UnityEditor.UnityStats.drawCalls;
            currentBatches = UnityEditor.UnityStats.batches;

            // 计算预制体贡献的数量
            vertexCount = Mathf.Max(0, currentVertexCount - originalVertexCount);
            triangleCount = Mathf.Max(0, currentTriangleCount - originalTriangleCount);
            drawCallsCount = Mathf.Max(0, currentDrawCalls - originalDrawCalls);
            batchesCount = Mathf.Max(0, currentBatches - originalBatches);

            // 如果Unity Stats没有正确记录差异，回退到我们的估算
            if (drawCallsCount == 0 && batchesCount == 0)
            {
                CalculatePreciseDrawCalls();
            }

            isAnalyzing = false;
            statusMessage = "分析完成";
            Repaint();
        };
    }

    private void AnalyzeComponents()
    {
        // 收集所有粒子系统
        var particleSystems = instantiatedPrefab.GetComponentsInChildren<ParticleSystem>(true);
        particleSystemCount = particleSystems.Length;

        // 计算发射器数量
        emitterCount = 0;
        foreach (var ps in particleSystems)
        {
            var emission = ps.emission;
            if (emission.enabled)
            {
                emitterCount++;
            }

            // 检查子发射器
            var subEmitters = ps.subEmitters;
            if (subEmitters.enabled)
            {
                emitterCount += subEmitters.subEmittersCount;
            }
        }

        // 收集所有TrailRenderer
        var trailRenderers = instantiatedPrefab.GetComponentsInChildren<TrailRenderer>(true);
        trailRendererCount = trailRenderers.Length;

        // 收集所有LineRenderer
        var lineRenderers = instantiatedPrefab.GetComponentsInChildren<LineRenderer>(true);
        lineRendererCount = lineRenderers.Length;

        // 收集所有渲染器的材质和纹理
        materialsUsed.Clear();
        texturesUsed.Clear();
        shadersUsed.Clear();
        textureSizes.Clear();
        // 注意：不再在这里计算vertexCount和triangleCount，因为我们将使用Unity的Stats
        gpuMemoryUsage = 0;
        performanceIssues.Clear();

        // 处理粒子系统渲染器
        foreach (var ps in particleSystems)
        {
            var renderer = ps.GetComponent<ParticleSystemRenderer>();
            if (renderer != null)
            {
                AnalyzeRenderer(renderer, ps);
            }

            // 检查粒子系统设置可能导致的性能问题
            AnalyzeParticleSystemPerformance(ps);
        }

        // 处理Trail渲染器
        foreach (var renderer in trailRenderers)
        {
            AnalyzeRenderer(renderer);
        }

        // 处理Line渲染器
        foreach (var renderer in lineRenderers)
        {
            AnalyzeRenderer(renderer);
        }

        // 处理其他渲染器
        var otherRenderers = instantiatedPrefab.GetComponentsInChildren<Renderer>(true)
            .Where(r => !(r is ParticleSystemRenderer || r is TrailRenderer || r is LineRenderer));

        foreach (var renderer in otherRenderers)
        {
            AnalyzeRenderer(renderer);
        }
    }

    // 新增：分析粒子系统性能问题
    private void AnalyzeParticleSystemPerformance(ParticleSystem ps)
    {
        // 检查最大粒子数
        if (ps.main.maxParticles > 200)
        {
            performanceIssues.Add($"粒子系统 [{ps.name}] 最大粒子数过大: {ps.main.maxParticles}");
        }

        // 检查碰撞
        if (ps.collision.enabled)
        {
            performanceIssues.Add($"粒子系统 [{ps.name}] 启用了碰撞计算，可能影响性能");
        }

        // 检查噪声
        if (ps.noise.enabled)
        {
            performanceIssues.Add($"粒子系统 [{ps.name}] 启用了噪声模块，可能影响性能");
        }

        // 检查过多子发射器
        if (ps.subEmitters.enabled && ps.subEmitters.subEmittersCount > 5)
        {
            performanceIssues.Add($"粒子系统 [{ps.name}] 使用了{ps.subEmitters.subEmittersCount}个子发射器，过多的子发射器会影响性能");
        }
    }

    // 修改：更精确分析渲染器
    private void AnalyzeRenderer(Renderer renderer, ParticleSystem ps = null)
    {
        var materials = renderer.sharedMaterials;

        foreach (var material in materials)
        {
            if (material != null)
            {
                if (!materialsUsed.ContainsKey(material.name))
                {
                    materialsUsed.Add(material.name, material);

                    // 检查材质的shader
                    if (material.shader != null)
                    {
                        Shader shader = material.shader;
                        if (!shadersUsed.ContainsKey(shader.name))
                        {
                            shadersUsed.Add(shader.name, shader);
                        }

                        // 检查shader性能
                        AnalyzeShaderPerformance(material, shader);

                        // 分析材质中的纹理
                        int propertyCount = ShaderUtil.GetPropertyCount(shader);

                        for (int i = 0; i < propertyCount; i++)
                        {
                            if (ShaderUtil.GetPropertyType(shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
                            {
                                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                                Texture tex = material.GetTexture(propertyName);

                                if (tex != null && !texturesUsed.ContainsKey(tex.name))
                                {
                                    texturesUsed.Add(tex.name, tex);

                                    // 分析纹理性能
                                    AnalyzeTexturePerformance(tex);
                                }
                            }
                        }
                    }
                }
            }
        }

        // 移除这部分代码，因为我们现在使用Unity Stats来获取这些值
        /* 
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
        else if (renderer is ParticleSystemRenderer && ps != null)
        {
            ParticleSystemRenderer psr = renderer as ParticleSystemRenderer;
            int maxParticles = ps.main.maxParticles;
            
            if (psr.renderMode == ParticleSystemRenderMode.Mesh && psr.mesh != null)
            {
                vertexCount += psr.mesh.vertexCount * maxParticles;
                triangleCount += (psr.mesh.triangles.Length / 3) * maxParticles;
            }
            else
            {
                vertexCount += 4 * maxParticles;
                triangleCount += 2 * maxParticles;
            }
        }
        */
    }

    // 修改 CalculatePreciseDrawCalls 方法，作为备用计算方法
    private void CalculatePreciseDrawCalls()
    {
        Dictionary<int, HashSet<Material>> renderQueueToMaterials = new Dictionary<int, HashSet<Material>>();

        foreach (var material in materialsUsed.Values)
        {
            int renderQueue = material.renderQueue;
            if (!renderQueueToMaterials.ContainsKey(renderQueue))
            {
                renderQueueToMaterials[renderQueue] = new HashSet<Material>();
            }
            renderQueueToMaterials[renderQueue].Add(material);
        }

        // 计算基于渲染队列的DrawCall估算值
        drawCallsCount = 0;
        batchesCount = 0;

        foreach (var kvp in renderQueueToMaterials)
        {
            int renderQueue = kvp.Key;
            var mats = kvp.Value;

            if (renderQueue >= 3000) // 透明队列
            {
                // 透明物体通常无法批处理
                drawCallsCount += mats.Count;
                batchesCount += mats.Count;
            }
            else
            {
                // 不透明物体可能会进行静态批处理和动态批处理
                // 保守估计可以将一半的材质批处理
                drawCallsCount += Mathf.CeilToInt(mats.Count * 0.7f);
                batchesCount += Mathf.CeilToInt(mats.Count * 0.7f);
            }
        }

        // 将ParticleSystem的子发射器数量考虑到DrawCall中
        drawCallsCount += emitterCount > particleSystemCount ? (emitterCount - particleSystemCount) / 2 : 0;
        batchesCount += emitterCount > particleSystemCount ? (emitterCount - particleSystemCount) / 2 : 0;

        // 确保至少有1个DrawCall
        drawCallsCount = Mathf.Max(1, drawCallsCount);
        batchesCount = Mathf.Max(1, batchesCount);

        // 添加日志，帮助调试
        Debug.Log($"[VFX分析器] 估算 DrawCalls: {drawCallsCount}, Batches: {batchesCount} (材质数: {materialsUsed.Count}, 发射器: {emitterCount})");
    }

    // 新增：分析shader性能
    private void AnalyzeShaderPerformance(Material material, Shader shader)
    {
        string shaderName = shader.name.ToLower();

        // 检测复杂shader
        if (shaderName.Contains("distortion") || shaderName.Contains("displacement") ||
            shaderName.Contains("parallax") || shaderName.Contains("tessellation"))
        {
            performanceIssues.Add($"材质 [{material.name}] 使用了复杂shader: {shader.name}，可能影响性能");
        }


        // 获取并分析RenderQueue
        int renderQueue = material.renderQueue;
        if (renderQueue >= 3000 && renderQueue < 3100) // 透明队列
        {
            // 检查是否有多个透明材质使用相同shader
            int sameShaderCount = materialsUsed.Values.Count(m => m.shader == shader && m.renderQueue >= 3000 && m.renderQueue < 3100);
            if (sameShaderCount > 2)
            {
                performanceIssues.Add($"检测到{sameShaderCount}个透明材质使用相同shader [{shader.name}]，建议尝试合并材质或贴图来减少批次数量");
            }
        }
    }

    // 新增：分析纹理性能
    private void AnalyzeTexturePerformance(Texture texture)
    {
        if (texture is Texture2D)
        {
            Texture2D tex2D = texture as Texture2D;
            float sizeMB = 0;

            // 计算纹理内存占用
            int bpp = GetBitsPerPixel(tex2D.format);
            float memoryBytes = tex2D.width * tex2D.height * bpp / 8f;
            sizeMB = memoryBytes / (1024f * 1024f);

            // 存储纹理大小
            textureSizes[texture] = sizeMB;

            // 累计GPU内存使用
            gpuMemoryUsage += sizeMB;

            // 检查纹理尺寸是否为2的幂
            bool isPowerOfTwo = IsPowerOfTwo(tex2D.width) && IsPowerOfTwo(tex2D.height);
            if (!isPowerOfTwo)
            {
                performanceIssues.Add($"纹理 [{tex2D.name}] 的尺寸 ({tex2D.width}x{tex2D.height}) 不是2次幂，可能影响包体压缩");
            }

            // 检查大尺寸纹理
            if (tex2D.width > 1024 || tex2D.height > 1024)
            {
                performanceIssues.Add($"纹理 [{tex2D.name}] 的尺寸 ({tex2D.width}x{tex2D.height}) 较大，考虑降低分辨率");
            }

            // 检查非压缩格式
            if (tex2D.format == TextureFormat.RGBA32 || tex2D.format == TextureFormat.ARGB32 ||
                tex2D.format == TextureFormat.RGB24)
            {
                performanceIssues.Add($"纹理 [{tex2D.name}] 使用未压缩格式 ({tex2D.format})，建议使用压缩纹理格式");
            }

            // 检查MipMap设置
            if (!tex2D.mipmapCount.Equals(1) && !IsPowerOfTwo(tex2D.width) && !IsPowerOfTwo(tex2D.height))
            {
                performanceIssues.Add($"纹理 [{tex2D.name}] 启用了MipMap但尺寸不是2的幂，可能无法正确生成MipMap");
            }
        }
        else if (texture is RenderTexture)
        {
            RenderTexture rt = texture as RenderTexture;
            // RenderTexture内存占用 (假设32bpp)
            float sizeMB = (rt.width * rt.height * 4) / (1024f * 1024f);
            textureSizes[texture] = sizeMB;
            gpuMemoryUsage += sizeMB;
        }
    }

    // 新增：判断是否为2的幂
    private bool IsPowerOfTwo(int x)
    {
        return (x != 0) && ((x & (x - 1)) == 0);
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

    private void DisplayResults()
    {
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        EditorGUILayout.LabelField("性能分析结果", EditorStyles.boldLabel);

        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

        EditorGUILayout.LabelField("基本信息", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("预制体名称", targetPrefab.name);
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("组件数量", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("粒子系统数量", particleSystemCount.ToString());
        EditorGUILayout.LabelField("发射器数量", emitterCount.ToString()); // 新增
        EditorGUILayout.LabelField("拖尾渲染器数量", trailRendererCount.ToString());
        EditorGUILayout.LabelField("线条渲染器数量", lineRendererCount.ToString());
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("渲染统计", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("材质数量", materialsUsed.Count.ToString());
        EditorGUILayout.LabelField("纹理数量", texturesUsed.Count.ToString());
        EditorGUILayout.LabelField("Shader数量", shadersUsed.Count.ToString());

        // 显示Unity Status数据
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("顶点数 (Unity Stats)", vertexCount.ToString());
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("三角形数 (Unity Stats)", triangleCount.ToString());
        EditorGUILayout.EndHorizontal();

        // 显示是从Unity Stats获取还是估算的
        string drawCallSource = drawCallsCount == currentDrawCalls - originalDrawCalls ? "(Unity Stats)" : "(估算值)";
        string batchesSource = batchesCount == currentBatches - originalBatches ? "(Unity Stats)" : "(估算值)";

        // 使用彩色标签来突出显示可能的性能问题
        GUIStyle redStyle = new GUIStyle(EditorStyles.label);
        GUIStyle yellowStyle = new GUIStyle(EditorStyles.label);
        GUIStyle greenStyle = new GUIStyle(EditorStyles.label);

        redStyle.normal.textColor = Color.red;
        yellowStyle.normal.textColor = new Color(1.0f, 0.5f, 0.0f); // 橙色
        greenStyle.normal.textColor = Color.green;

        // DrawCall评估
        GUIStyle drawCallStyle = drawCallsCount > 8 ? redStyle : (drawCallsCount > 4 ? yellowStyle : greenStyle);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField($"DrawCall数量 {drawCallSource}", drawCallsCount.ToString(), drawCallStyle);
        EditorGUILayout.EndHorizontal();

        // Batches评估
        GUIStyle batchesStyle = batchesCount > 8 ? redStyle : (batchesCount > 4 ? yellowStyle : greenStyle);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField($"Batches数量 {batchesSource}", batchesCount.ToString(), batchesStyle);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.LabelField("顶点数", vertexCount.ToString());
        EditorGUILayout.LabelField("三角形数", triangleCount.ToString());

        // GPU内存评估
        GUIStyle memoryStyle = gpuMemoryUsage > 10 ? redStyle : (gpuMemoryUsage > 5 ? yellowStyle : greenStyle);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("估计GPU内存占用", gpuMemoryUsage.ToString("F2") + " MB", memoryStyle);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        // 显示性能问题
        if (performanceIssues.Count > 0)
        {
            showIssues = EditorGUILayout.Foldout(showIssues, "检测到的性能问题 (" + performanceIssues.Count + ")", true);
            if (showIssues)
            {
                EditorGUI.indentLevel++;
                foreach (var issue in performanceIssues)
                {
                    EditorGUILayout.HelpBox(issue, MessageType.Warning);
                }
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.Space();
        }

        // 显示shader列表
        showShaders = EditorGUILayout.Foldout(showShaders, "使用的Shader (" + shadersUsed.Count + ")", true);
        if (showShaders)
        {
            EditorGUI.indentLevel++;
            foreach (var shader in shadersUsed.Values)
            {
                EditorGUILayout.ObjectField(shader.name, shader, typeof(Shader), false);
            }
            EditorGUI.indentLevel--;
        }

        // 显示材质列表
        showMaterials = EditorGUILayout.Foldout(showMaterials, "使用的材质 (" + materialsUsed.Count + ")", true);
        if (showMaterials)
        {
            EditorGUI.indentLevel++;
            foreach (var material in materialsUsed.Values)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(material.name, material, typeof(Material), false);
                if (material.shader != null)
                {
                    EditorGUILayout.LabelField("Shader: " + material.shader.name, EditorStyles.miniLabel);
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUI.indentLevel--;
        }

        // 显示纹理列表
        showTextures = EditorGUILayout.Foldout(showTextures, "使用的纹理 (" + texturesUsed.Count + ")", true);
        if (showTextures)
        {
            EditorGUI.indentLevel++;

            // 按内存占用排序显示纹理
            var sortedTextures = texturesUsed.Values.OrderByDescending(t => textureSizes.ContainsKey(t) ? textureSizes[t] : 0).ToList();

            foreach (var texture in sortedTextures)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(texture.name, texture, typeof(Texture), false);

                if (texture is Texture2D)
                {
                    Texture2D tex2d = texture as Texture2D;
                    float size = textureSizes.ContainsKey(texture) ? textureSizes[texture] : 0;

                    // 高亮显示大纹理
                    GUIStyle sizeStyle = size > 1.0f ? redStyle : (size > 0.5f ? yellowStyle : EditorStyles.miniLabel);

                    EditorGUILayout.LabelField($"尺寸: {tex2d.width}x{tex2d.height}, " +
                                             $"格式: {tex2d.format.ToString()}, " +
                                             $"内存: {size:F2}MB",
                                             sizeStyle);
                }

                EditorGUILayout.EndHorizontal();
                EditorGUILayout.Space();
            }

            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space();

        if (GUILayout.Button("导出分析结果"))
        {
            ExportResults();
        }
    }

    private void ExportResults()
    {
        string path = EditorUtility.SaveFilePanel("保存分析结果", "", targetPrefab.name + "_性能分析.txt", "txt");

        if (string.IsNullOrEmpty(path))
            return;

        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        sb.AppendLine("特效预制体性能分析报告");
        sb.AppendLine("----------------------------");
        sb.AppendLine("预制体名称: " + targetPrefab.name);
        sb.AppendLine("");

        sb.AppendLine("组件数量:");
        sb.AppendLine("- 粒子系统: " + particleSystemCount);
        sb.AppendLine("- 发射器数量: " + emitterCount);
        sb.AppendLine("- 拖尾渲染器: " + trailRendererCount);
        sb.AppendLine("- 线条渲染器: " + lineRendererCount);
        sb.AppendLine("");

        sb.AppendLine("渲染统计:");
        sb.AppendLine("- 材质数量: " + materialsUsed.Count);
        sb.AppendLine("- 纹理数量: " + texturesUsed.Count);
        sb.AppendLine("- Shader数量: " + shadersUsed.Count);
        sb.AppendLine("- 预估DrawCall: " + drawCallsCount);
        sb.AppendLine("- 预估Batches: " + batchesCount);
        sb.AppendLine("- 顶点数: " + vertexCount);
        sb.AppendLine("- 三角形数: " + triangleCount);
        sb.AppendLine("- 估计GPU内存占用: " + gpuMemoryUsage.ToString("F2") + " MB");
        sb.AppendLine("");

        if (performanceIssues.Count > 0)
        {
            sb.AppendLine("检测到的性能问题:");
            foreach (var issue in performanceIssues)
            {
                sb.AppendLine("- " + issue);
            }
            sb.AppendLine("");
        }

        sb.AppendLine("使用的Shader:");
        foreach (var shader in shadersUsed.Values)
        {
            sb.AppendLine("- " + shader.name);
        }
        sb.AppendLine("");

        sb.AppendLine("使用的材质:");
        foreach (var material in materialsUsed.Values)
        {
            sb.AppendLine("- " + material.name + " (Shader: " + material.shader.name + ")");
        }
        sb.AppendLine("");

        sb.AppendLine("使用的纹理 (按内存占用排序):");
        var sortedTextures = texturesUsed.Values.OrderByDescending(t => textureSizes.ContainsKey(t) ? textureSizes[t] : 0).ToList();
        foreach (var texture in sortedTextures)
        {
            if (texture is Texture2D)
            {
                Texture2D tex2d = texture as Texture2D;
                float size = textureSizes.ContainsKey(texture) ? textureSizes[texture] : 0;
                sb.AppendLine($"- {texture.name} ({tex2d.width}x{tex2d.height}, {tex2d.format}, {size:F2}MB)");
            }
            else
            {
                sb.AppendLine("- " + texture.name);
            }
        }

        System.IO.File.WriteAllText(path, sb.ToString());

        Debug.Log("分析结果已导出至: " + path);
    }

    void OnDestroy()
    {
        CleanupPreviousAnalysis();
    }

    private void CleanupPreviousAnalysis()
    {
        if (instantiatedPrefab != null)
        {
            DestroyImmediate(instantiatedPrefab);
        }

        materialsUsed.Clear();
        texturesUsed.Clear();
        particleSystemCount = 0;
        trailRendererCount = 0;
        lineRendererCount = 0;
        batchesCount = 0;
        drawCallsCount = 0;
        vertexCount = 0;
        triangleCount = 0;
    }
}