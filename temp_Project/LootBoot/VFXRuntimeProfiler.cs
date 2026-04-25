using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

//Made by Soung, 2025.6.13, Using Claude 3.7
public class VFXRuntimeProfiler : EditorWindow
{
    private GameObject targetVFX;
    private bool isMonitoring = false;
    private float monitorInterval = 0.5f; // 更新间隔（秒）
    private float nextUpdateTime = 0;

    private int currentDrawCalls = 0;
    private int currentBatches = 0;
    private int currentTrianglesCount = 0;
    private float currentCPUTime = 0;
    // private float currentGPUTime = 0; // 移除未使用的变量
    private float currentGPUMemory = 0; // GPU内存使用估计(MB)
    private int currentActiveParticles = 0; // 当前活跃粒子数

    // 历史数据
    private List<float> drawCallHistory = new List<float>();
    private List<float> batchesHistory = new List<float>();
    private List<float> trianglesHistory = new List<float>();
    private List<float> cpuTimeHistory = new List<float>();
    private List<float> gpuMemoryHistory = new List<float>();
    private List<float> particleCountHistory = new List<float>();
    private int maxHistoryPoints = 60; // 历史数据最大点数

    private Vector2 scrollPosition;
    private bool showGpuTimeWarning = true; // 是否显示GPU时间监控警告

    [MenuItem("工具/VFXTools/VFX运行时监控")]
    public static void ShowWindow()
    {
        GetWindow<VFXRuntimeProfiler>("特效运行时数据监控");
    }

    void OnEnable()
    {
        EditorApplication.playModeStateChanged += OnPlayModeChanged;
    }

    void OnDisable()
    {
        EditorApplication.playModeStateChanged -= OnPlayModeChanged;
        if (isMonitoring)
        {
            isMonitoring = false;
            EditorApplication.update -= UpdateMonitoring;
        }
    }

    void OnPlayModeChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.ExitingPlayMode && isMonitoring)
        {
            isMonitoring = false;
            EditorApplication.update -= UpdateMonitoring;
            ClearHistory();
            Repaint();
        }
    }

    void OnGUI()
    {
        GUILayout.Label("特效运行时性能分析", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        targetVFX = (GameObject)EditorGUILayout.ObjectField("目标特效对象", targetVFX, typeof(GameObject), true);
        monitorInterval = EditorGUILayout.Slider("更新间隔 (秒)", monitorInterval, 0.1f, 2.0f);

        EditorGUILayout.Space();

        // 显示GPU时间采集相关说明
        if (showGpuTimeWarning)
        {
            EditorGUILayout.HelpBox("注意: 目前没有直接获取GPU渲染时间的原生API。如需GPU性能分析，建议使用Unity Profiler或GPU分析工具。", MessageType.Info);
            
            if (GUILayout.Button("不再显示此提示"))
            {
                showGpuTimeWarning = false;
            }
        }

        EditorGUILayout.Space();

        // 只有在运行时才能监控
        GUI.enabled = Application.isPlaying;

        if (!isMonitoring)
        {
            if (GUILayout.Button("开始监控"))
            {
                isMonitoring = true;
                ClearHistory();
                EditorApplication.update += UpdateMonitoring;
            }
        }
        else
        {
            if (GUILayout.Button("停止监控"))
            {
                isMonitoring = false;
                EditorApplication.update -= UpdateMonitoring;
            }
        }

        GUI.enabled = true;

        if (!Application.isPlaying)
        {
            EditorGUILayout.HelpBox("只能在游戏运行时监控性能。请进入播放模式。", MessageType.Info);
        }

        EditorGUILayout.Space();

        // 显示当前性能数据
        if (isMonitoring && Application.isPlaying)
        {
            DisplayPerformanceData();
        }
    }

    private void UpdateMonitoring()
    {
        if (!Application.isPlaying || !isMonitoring)
        {
            return;
        }

        if (Time.realtimeSinceStartup >= nextUpdateTime)
        {
            // 更新时间
            nextUpdateTime = Time.realtimeSinceStartup + monitorInterval;

            // 更新性能数据
            UpdatePerformanceData();

            // 重绘窗口
            Repaint();
        }
    }

    private void UpdatePerformanceData()
    {
        if (targetVFX == null)
            return;

        // 直接使用Unity的Statistics API获取准确数据
        currentDrawCalls = UnityEditor.UnityStats.drawCalls;
        currentBatches = UnityEditor.UnityStats.batches;
        currentTrianglesCount = UnityEditor.UnityStats.triangles;

        // 使用Time.deltaTime估算CPU帧时间（单位：毫秒）
        currentCPUTime = Time.deltaTime * 1000f; // 毫秒

        // 获取当前活跃的粒子数量
        var particleSystems = targetVFX.GetComponentsInChildren<ParticleSystem>(true);
        currentActiveParticles = 0;
        foreach (var ps in particleSystems)
        {
            currentActiveParticles += ps.particleCount;
        }

        // 估算GPU内存使用（基于纹理和网格）
        currentGPUMemory = EstimateGPUMemoryUsage(targetVFX);

        // 更新历史数据
        drawCallHistory.Add(currentDrawCalls);
        batchesHistory.Add(currentBatches);
        trianglesHistory.Add(currentTrianglesCount);
        cpuTimeHistory.Add(currentCPUTime);
        gpuMemoryHistory.Add(currentGPUMemory);
        particleCountHistory.Add(currentActiveParticles);

        // 限制历史数据量
        if (drawCallHistory.Count > maxHistoryPoints)
        {
            drawCallHistory.RemoveAt(0);
            batchesHistory.RemoveAt(0);
            trianglesHistory.RemoveAt(0);
            cpuTimeHistory.RemoveAt(0);
            gpuMemoryHistory.RemoveAt(0);
            particleCountHistory.RemoveAt(0);
        }
    }

    // 估算GPU内存使用
    private float EstimateGPUMemoryUsage(GameObject obj)
    {
        float estimatedMemory = 0; // 单位：MB

        // 收集所有纹理
        HashSet<Texture> textures = new HashSet<Texture>();
        var renderers = obj.GetComponentsInChildren<Renderer>(true);

        foreach (var renderer in renderers)
        {
            foreach (var material in renderer.sharedMaterials)
            {
                if (material != null && material.shader != null)
                {
                    int propertyCount = ShaderUtil.GetPropertyCount(material.shader);
                    for (int i = 0; i < propertyCount; i++)
                    {
                        if (ShaderUtil.GetPropertyType(material.shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
                        {
                            string propName = ShaderUtil.GetPropertyName(material.shader, i);
                            Texture tex = material.GetTexture(propName);
                            if (tex != null)
                            {
                                textures.Add(tex);
                            }
                        }
                    }
                }
            }
        }

        // 计算纹理内存
        foreach (var tex in textures)
        {
            if (tex is Texture2D)
            {
                Texture2D tex2d = tex as Texture2D;
                int bpp = GetBitsPerPixel(tex2d.format);
                float memorySizeMB = (tex2d.width * tex2d.height * bpp / 8f) / (1024f * 1024f);
                estimatedMemory += memorySizeMB;
            }
            else if (tex is RenderTexture)
            {
                RenderTexture rt = tex as RenderTexture;
                int bpp = 32; // 假设默认为32位
                float memorySizeMB = (rt.width * rt.height * bpp / 8f) / (1024f * 1024f);
                estimatedMemory += memorySizeMB;
            }
        }

        // 修改：同时处理MeshFilter和粒子系统的网格
        // 估算网格内存
        foreach (var meshFilter in obj.GetComponentsInChildren<MeshFilter>(true))
        {
            if (meshFilter.sharedMesh != null)
            {
                // 每个顶点约100字节（位置、法线、UV等）
                float memorySizeMB = (meshFilter.sharedMesh.vertexCount * 100f) / (1024f * 1024f);
                estimatedMemory += memorySizeMB;
            }
        }
        
        // 处理粒子系统的网格渲染模式
        foreach (var ps in obj.GetComponentsInChildren<ParticleSystem>(true))
        {
            ParticleSystemRenderer psr = ps.GetComponent<ParticleSystemRenderer>();
            if (psr != null && psr.renderMode == ParticleSystemRenderMode.Mesh && psr.mesh != null)
            {
                // 网格只上传GPU一次，不随粒子数量倍增
                float memorySizeMB = (psr.mesh.vertexCount * 100f) / (1024f * 1024f);
                estimatedMemory += memorySizeMB;
            }
        }

        return estimatedMemory;
    }

    // 获取纹理格式的每像素位数
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

    private void DisplayPerformanceData()
    {
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        EditorGUILayout.LabelField("性能监控数据", EditorStyles.boldLabel);

        EditorGUILayout.LabelField("当前Draw Calls: " + currentDrawCalls);
        EditorGUILayout.LabelField("当前Batches: " + currentBatches);
        EditorGUILayout.LabelField("当前三角形数: " + currentTrianglesCount);
        EditorGUILayout.LabelField("CPU时间: " + currentCPUTime.ToString("F2") + " ms");
        EditorGUILayout.LabelField("活跃粒子数: " + currentActiveParticles);
        EditorGUILayout.LabelField("GPU内存占用: " + currentGPUMemory.ToString("F2") + " MB");

        EditorGUILayout.Space();

        // 绘制性能曲线图
        if (drawCallHistory.Count > 1)
        {
            EditorGUILayout.LabelField("Draw Calls 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(drawCallHistory, Color.green);

            EditorGUILayout.LabelField("Batches 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(batchesHistory, Color.blue);

            EditorGUILayout.LabelField("三角形数 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(trianglesHistory, new Color(1.0f, 0.5f, 0.0f)); // 橙色

            EditorGUILayout.LabelField("CPU时间 (ms) 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(cpuTimeHistory, Color.red);

            EditorGUILayout.LabelField("活跃粒子数 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(particleCountHistory, Color.yellow);

            EditorGUILayout.LabelField("GPU内存占用 (MB) 历史曲线", EditorStyles.boldLabel);
            DrawSimpleGraph(gpuMemoryHistory, Color.magenta);
        }

        EditorGUILayout.EndScrollView();
    }

    private void DrawSimpleGraph(List<float> values, Color color)
    {
        if (values.Count < 2)
            return;

        Rect rect = GUILayoutUtility.GetRect(EditorGUIUtility.currentViewWidth - 40, 60);

        float max = values.Max();
        float min = Mathf.Min(0, values.Min()); // 确保最小值不大于0

        // 防止除以零
        if (Mathf.Approximately(max, min))
        {
            max = min + 1;
        }

        Handles.BeginGUI();

        // 画框
        Handles.color = Color.gray;
        Handles.DrawLine(new Vector3(rect.x, rect.y), new Vector3(rect.x, rect.y + rect.height));
        Handles.DrawLine(new Vector3(rect.x, rect.y + rect.height), new Vector3(rect.x + rect.width, rect.y + rect.height));

        // 画曲线
        Handles.color = color;
        float stepX = rect.width / (values.Count - 1);

        for (int i = 0; i < values.Count - 1; i++)
        {
            float normalizedValue1 = (values[i] - min) / (max - min);
            float normalizedValue2 = (values[i + 1] - min) / (max - min);

            Vector3 p1 = new Vector3(rect.x + i * stepX, rect.y + rect.height - normalizedValue1 * rect.height);
            Vector3 p2 = new Vector3(rect.x + (i + 1) * stepX, rect.y + rect.height - normalizedValue2 * rect.height);

            Handles.DrawLine(p1, p2);
        }

        Handles.EndGUI();

        // 显示最大值和最小值
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Min: " + min.ToString("F2"));
        GUILayout.FlexibleSpace();
        GUILayout.Label("Max: " + max.ToString("F2"));
        EditorGUILayout.EndHorizontal();
    }

    void OnDestroy()
    {
        if (isMonitoring)
        {
            EditorApplication.update -= UpdateMonitoring;
        }
    }

    // 清空历史数据
    private void ClearHistory()
    {
        drawCallHistory.Clear();
        batchesHistory.Clear();
        trianglesHistory.Clear();
        cpuTimeHistory.Clear();
        gpuMemoryHistory.Clear();
        particleCountHistory.Clear();
    }
}