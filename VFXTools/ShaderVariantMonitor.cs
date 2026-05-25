using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;

#if UNITY_EDITOR
public class ShaderVariantMonitor : EditorWindow
{
    // ─── Tab 枚举 ─────────────────────────────────────────────
    private enum TabIndex { Overview, ActiveShaders, Variants, LoadLog }
    private TabIndex currentTab = TabIndex.Overview;

    // ─── 监测控制 ─────────────────────────────────────────────
    private bool isMonitoring = false;
    private float updateInterval = 1.0f;
    private float lastUpdateTime = 0f;

    // ─── 采集数据 ─────────────────────────────────────────────
    private struct ShaderEntry
    {
        public string name;
        public long memoryBytes;
        public int variantCount;   // -1 表示 API 不可用
        public bool isActive;      // 是否正在被场景中的 Renderer 使用
    }

    private readonly List<ShaderEntry> shaderEntries = new List<ShaderEntry>();
    private readonly HashSet<string> activeShaderNames = new HashSet<string>();
    private readonly HashSet<string> prevLoadedNames = new HashSet<string>();
    private readonly List<string> loadUnloadLog = new List<string>();
    private const int LOG_MAX = 300;

    private long totalMemoryBytes = 0;
    private int variantCollectionShaderCount = 0;
    private int variantCollectionVariantCount = 0;

    // ─── 排序 & 过滤 ──────────────────────────────────────────
    private bool sortByMemory = true;
    private string nameFilter = "";

    // ─── 滚动位置 ─────────────────────────────────────────────
    private Vector2 overviewScroll;
    private Vector2 activeScroll;
    private Vector2 variantScroll;
    private Vector2 logScroll;

    // ─── 反射缓存：ShaderUtil 非公开方法 ────────────────────────
    private static MethodInfo getVariantCountMethod;
    private static bool variantCountMethodChecked = false;
    private static MethodInfo getCollectionShaderCountMethod;
    private static MethodInfo getCollectionVariantCountMethod;
    private static bool collectionMethodsChecked = false;

    // ─── GUIStyle 缓存 ────────────────────────────────────────
    private GUIStyle loadStyle;
    private GUIStyle unloadStyle;
    private GUIStyle activeTagStyle;
    private bool stylesInitialized = false;

    // ─── MenuItem ─────────────────────────────────────────────
    [MenuItem("TATools/VFXTools/Shader变体监测器")]
    public static void ShowWindow()
    {
        GetWindow<ShaderVariantMonitor>("Shader变体监测器");
    }

    // ─── 生命周期 ─────────────────────────────────────────────

    void OnEnable()
    {
        EditorApplication.update += OnEditorUpdate;
        EditorApplication.playModeStateChanged += OnPlayModeChanged;
    }

    void OnDisable()
    {
        EditorApplication.update -= OnEditorUpdate;
        EditorApplication.playModeStateChanged -= OnPlayModeChanged;
        isMonitoring = false;
    }

    void OnPlayModeChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.ExitingPlayMode)
        {
            isMonitoring = false;
            Repaint();
        }
    }

    void OnEditorUpdate()
    {
        if (!isMonitoring || !EditorApplication.isPlaying) return;

        float now = (float)EditorApplication.timeSinceStartup;
        if (now - lastUpdateTime < updateInterval) return;
        lastUpdateTime = now;

        CollectData();
        Repaint();
    }

    // ─── 数据采集 ─────────────────────────────────────────────

    void CollectData()
    {
        // 1. 收集所有内存中的 Shader
        var allShaders = Resources.FindObjectsOfTypeAll<Shader>();
        var currentNames = new HashSet<string>(allShaders.Length);

        shaderEntries.Clear();
        totalMemoryBytes = 0;

        foreach (var shader in allShaders)
        {
            if (shader == null) continue;
            string shaderName = shader.name;
            if (string.IsNullOrEmpty(shaderName)) continue;

            currentNames.Add(shaderName);
            long mem = Profiler.GetRuntimeMemorySizeLong(shader);
            totalMemoryBytes += mem;

            shaderEntries.Add(new ShaderEntry
            {
                name = shaderName,
                memoryBytes = mem,
                variantCount = GetVariantCount(shader),
                isActive = false  // 在第3步填充
            });
        }

        // 2. 检测 Shader 加载 / 卸载（chunk 状态代理）
        string ts = DateTime.Now.ToString("HH:mm:ss.fff");
        foreach (string n in currentNames)
        {
            if (!prevLoadedNames.Contains(n))
                AppendLog($"[{ts}] ▲ LOAD    {n}");
        }
        foreach (string n in prevLoadedNames)
        {
            if (!currentNames.Contains(n))
                AppendLog($"[{ts}] ▼ UNLOAD  {n}");
        }
        prevLoadedNames.Clear();
        foreach (string n in currentNames) prevLoadedNames.Add(n);

        // 3. 收集激活中的 Shader（来自场景中激活的 Renderer）
        activeShaderNames.Clear();
        var renderers = FindObjectsOfType<Renderer>();
        foreach (var r in renderers)
        {
            if (!r.enabled || !r.gameObject.activeInHierarchy) continue;
            Material[] mats = r.sharedMaterials;
            foreach (var mat in mats)
            {
                if (mat != null && mat.shader != null)
                    activeShaderNames.Add(mat.shader.name);
            }
        }

        // 回填 isActive
        for (int i = 0; i < shaderEntries.Count; i++)
        {
            ShaderEntry e = shaderEntries[i];
            e.isActive = activeShaderNames.Contains(e.name);
            shaderEntries[i] = e;
        }

        // 4. ShaderVariantCollection 全局统计
        variantCollectionShaderCount  = GetCollectionShaderCount();
        variantCollectionVariantCount = GetCollectionVariantCount();

        // 5. 排序
        ApplySort();
    }

    void ApplySort()
    {
        if (sortByMemory)
            shaderEntries.Sort((a, b) => b.memoryBytes.CompareTo(a.memoryBytes));
        else
            shaderEntries.Sort((a, b) => string.Compare(a.name, b.name, StringComparison.OrdinalIgnoreCase));
    }

    void AppendLog(string entry)
    {
        loadUnloadLog.Add(entry);
        if (loadUnloadLog.Count > LOG_MAX)
            loadUnloadLog.RemoveAt(0);
    }

    // ─── 工具函数 ─────────────────────────────────────────────

    /// <summary>
    /// 通过反射调用 ShaderUtil.GetCurrentShaderVariantCollectionShaderCount。
    /// </summary>
    static int GetCollectionShaderCount()
    {
        EnsureCollectionMethods();
        if (getCollectionShaderCountMethod == null) return 0;
        try { return Convert.ToInt32(getCollectionShaderCountMethod.Invoke(null, null)); }
        catch { return 0; }
    }

    /// <summary>
    /// 通过反射调用 ShaderUtil.GetCurrentShaderVariantCollectionVariantCount。
    /// </summary>
    static int GetCollectionVariantCount()
    {
        EnsureCollectionMethods();
        if (getCollectionVariantCountMethod == null) return 0;
        try { return Convert.ToInt32(getCollectionVariantCountMethod.Invoke(null, null)); }
        catch { return 0; }
    }

    static void EnsureCollectionMethods()
    {
        if (collectionMethodsChecked) return;
        collectionMethodsChecked = true;
        const BindingFlags flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static;
        getCollectionShaderCountMethod  = typeof(ShaderUtil).GetMethod("GetCurrentShaderVariantCollectionShaderCount",  flags);
        getCollectionVariantCountMethod = typeof(ShaderUtil).GetMethod("GetCurrentShaderVariantCollectionVariantCount", flags);
    }

    /// <summary>
    /// 通过反射调用 ShaderUtil.GetVariantCount(Shader, bool)。
    /// 该方法在 Unity 2019.3+ 以 [FreeFunction] 形式存在。
    /// 返回 -1 表示 API 不可用。
    /// </summary>
    static int GetVariantCount(Shader shader)
    {
        if (!variantCountMethodChecked)
        {
            variantCountMethodChecked = true;
            getVariantCountMethod = typeof(ShaderUtil).GetMethod(
                "GetVariantCount",
                BindingFlags.Public | BindingFlags.Static | BindingFlags.NonPublic,
                null,
                new[] { typeof(Shader), typeof(bool) },
                null);
        }

        if (getVariantCountMethod == null) return -1;

        try
        {
            object result = getVariantCountMethod.Invoke(null, new object[] { shader, true });
            return Convert.ToInt32(result);
        }
        catch
        {
            return -1;
        }
    }

    static string FormatBytes(long bytes)
    {
        if (bytes >= 1024L * 1024 * 1024)
            return $"{bytes / (1024f * 1024 * 1024):F2} GB";
        if (bytes >= 1024 * 1024)
            return $"{bytes / (1024f * 1024):F2} MB";
        if (bytes >= 1024)
            return $"{bytes / 1024f:F1} KB";
        return $"{bytes} B";
    }

    // ─── GUIStyle ─────────────────────────────────────────────

    void InitStyles()
    {
        if (stylesInitialized) return;

        loadStyle = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold,
            normal = { textColor = new Color(0.2f, 0.85f, 0.2f) }
        };

        unloadStyle = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold,
            normal = { textColor = new Color(0.9f, 0.35f, 0.35f) }
        };

        activeTagStyle = new GUIStyle(EditorStyles.miniLabel)
        {
            fontStyle = FontStyle.Bold,
            normal = { textColor = new Color(0.2f, 0.85f, 0.2f) }
        };

        stylesInitialized = true;
    }

    // ─── OnGUI ────────────────────────────────────────────────

    void OnGUI()
    {
        InitStyles();

        GUILayout.Label("Shader 变体监测器", EditorStyles.boldLabel);
        EditorGUILayout.Space(2);

        DrawControls();
        EditorGUILayout.Space(4);

        // Tab 栏
        currentTab = (TabIndex)GUILayout.Toolbar(
            (int)currentTab,
            new[] { "内存总览", "运行中 Shader", "Variant 统计", "加载日志" });
        EditorGUILayout.Space(4);

        switch (currentTab)
        {
            case TabIndex.Overview:     DrawOverviewTab();     break;
            case TabIndex.ActiveShaders:DrawActiveShadersTab();break;
            case TabIndex.Variants:     DrawVariantsTab();     break;
            case TabIndex.LoadLog:      DrawLoadLogTab();      break;
        }
    }

    // ─── 控制条 ───────────────────────────────────────────────

    void DrawControls()
    {
        EditorGUILayout.BeginHorizontal();

        bool inPlay = EditorApplication.isPlaying;
        GUI.enabled = inPlay;

        if (!isMonitoring)
        {
            if (GUILayout.Button("▶ 开始监测", GUILayout.Height(24), GUILayout.Width(100)))
            {
                prevLoadedNames.Clear();
                loadUnloadLog.Clear();
                shaderEntries.Clear();
                lastUpdateTime = 0f;
                isMonitoring = true;
            }
        }
        else
        {
            if (GUILayout.Button("■ 停止监测", GUILayout.Height(24), GUILayout.Width(100)))
                isMonitoring = false;
        }

        GUI.enabled = true;

        GUILayout.Label("刷新间隔:", GUILayout.Width(55));
        updateInterval = EditorGUILayout.Slider(updateInterval, 0.1f, 5f, GUILayout.Width(180));

        GUILayout.FlexibleSpace();

        // 状态指示
        if (!inPlay)
        {
            GUILayout.Label("● 未进入 Play 模式", EditorStyles.miniLabel);
        }
        else if (isMonitoring)
        {
            GUI.color = new Color(0.2f, 0.85f, 0.2f);
            GUILayout.Label("● 监测中", EditorStyles.boldLabel);
            GUI.color = Color.white;
        }
        else
        {
            GUILayout.Label("○ 已停止", EditorStyles.miniLabel);
        }

        EditorGUILayout.EndHorizontal();

        if (!inPlay)
            EditorGUILayout.HelpBox("请进入 Play 模式后开始监测。", MessageType.Info);
    }

    // ─── Tab: 内存总览 ────────────────────────────────────────

    void DrawOverviewTab()
    {
        // 汇总栏
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"Shader 总内存: {FormatBytes(totalMemoryBytes)}", EditorStyles.boldLabel);
        GUILayout.FlexibleSpace();
        GUILayout.Label($"已加载: {shaderEntries.Count}  活跃: {activeShaderNames.Count}", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(4);

        // 过滤 & 排序
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("过滤:", GUILayout.Width(32));
        nameFilter = EditorGUILayout.TextField(nameFilter, GUILayout.ExpandWidth(true));
        GUILayout.Label("排序:", GUILayout.Width(32));
        bool newSortMem  = GUILayout.Toggle( sortByMemory, "内存", EditorStyles.miniButtonLeft,  GUILayout.Width(46));
        bool newSortName = GUILayout.Toggle(!sortByMemory, "名称", EditorStyles.miniButtonRight, GUILayout.Width(46));
        if (newSortMem != sortByMemory || newSortName == sortByMemory)
        {
            sortByMemory = newSortMem;
            ApplySort();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(2);

        // 表头
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        GUILayout.Label("状态", GUILayout.Width(36));
        GUILayout.Label("Shader 名称", GUILayout.ExpandWidth(true));
        GUILayout.Label("内存占用", GUILayout.Width(80));
        EditorGUILayout.EndHorizontal();

        // 列表
        overviewScroll = EditorGUILayout.BeginScrollView(overviewScroll);
        string filter = nameFilter.Trim();
        foreach (var e in shaderEntries)
        {
            if (!string.IsNullOrEmpty(filter) &&
                e.name.IndexOf(filter, StringComparison.OrdinalIgnoreCase) < 0)
                continue;

            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);

            // 活跃标记
            if (e.isActive)
                GUILayout.Label("▶", activeTagStyle, GUILayout.Width(36));
            else
                GUILayout.Label("–", GUILayout.Width(36));

            GUILayout.Label(e.name, GUILayout.ExpandWidth(true));
            GUILayout.Label(FormatBytes(e.memoryBytes), GUILayout.Width(80));
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space(2);
        EditorGUILayout.HelpBox("▶ = 场景中 Renderer 正在使用该 Shader   – = 已加载但未激活", MessageType.None);
    }

    // ─── Tab: 运行中 Shader ───────────────────────────────────

    void DrawActiveShadersTab()
    {
        GUILayout.Label($"当前场景激活 Renderer 使用的 Shader（共 {activeShaderNames.Count} 个）",
            EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        activeScroll = EditorGUILayout.BeginScrollView(activeScroll);
        foreach (string n in activeShaderNames.OrderBy(x => x))
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            GUILayout.Label("▶", activeTagStyle, GUILayout.Width(20));
            GUILayout.Label(n);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }

    // ─── Tab: Variant 统计 ────────────────────────────────────

    void DrawVariantsTab()
    {
        // ShaderVariantCollection 全局统计
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        GUILayout.Label("ShaderVariantCollection 全局统计", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"已收集 Shader 数：{variantCollectionShaderCount}");
        GUILayout.Label($"已收集 Variant 数：{variantCollectionVariantCount}");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(4);

        // 各 Shader 的变体数
        bool hasVariantData = shaderEntries.Any(e => e.variantCount >= 0);
        if (!hasVariantData)
        {
            EditorGUILayout.HelpBox(
                "当前 Unity 版本未暴露 ShaderUtil.GetVariantCount，无法获取每个 Shader 的变体数。",
                MessageType.Warning);
        }
        else
        {
            // 表头
            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            GUILayout.Label("Shader 名称", GUILayout.ExpandWidth(true));
            GUILayout.Label("变体数", GUILayout.Width(70));
            GUILayout.Label("内存", GUILayout.Width(80));
            EditorGUILayout.EndHorizontal();

            var sorted = shaderEntries
                .Where(e => e.variantCount >= 0)
                .OrderByDescending(e => e.variantCount)
                .ToList();

            variantScroll = EditorGUILayout.BeginScrollView(variantScroll);
            foreach (var e in sorted)
            {
                EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
                GUILayout.Label(e.name, GUILayout.ExpandWidth(true));
                GUILayout.Label(e.variantCount.ToString(), GUILayout.Width(70));
                GUILayout.Label(FormatBytes(e.memoryBytes), GUILayout.Width(80));
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }
    }

    // ─── Tab: 加载日志 ────────────────────────────────────────

    void DrawLoadLogTab()
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"Shader 加载 / 卸载日志  （{loadUnloadLog.Count}/{LOG_MAX} 条）",
            EditorStyles.boldLabel);
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("清空", GUILayout.Width(48)))
            loadUnloadLog.Clear();
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.HelpBox(
            "▲ LOAD = Shader 出现在 Resources.FindObjectsOfTypeAll 中（chunk 进入内存）\n" +
            "▼ UNLOAD = Shader 从内存中消失（chunk 被卸载）",
            MessageType.None);

        EditorGUILayout.Space(2);

        logScroll = EditorGUILayout.BeginScrollView(logScroll);
        // 最新条目显示在最上方
        for (int i = loadUnloadLog.Count - 1; i >= 0; i--)
        {
            bool isLoad = loadUnloadLog[i].Contains("▲");
            GUILayout.Label(loadUnloadLog[i], isLoad ? loadStyle : unloadStyle);
        }
        EditorGUILayout.EndScrollView();
    }
}
#endif
