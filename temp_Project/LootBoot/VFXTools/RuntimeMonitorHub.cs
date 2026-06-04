using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;

// Made by Copilot, 2026.5.26, Using Claude Sonnet 4.6
// 运行时监测中心 — 合并: RuntimePerfMonitor / ShaderVariantMonitor / VFXRuntimeProfiler

#if UNITY_EDITOR
public class RuntimeMonitorHub : EditorWindow
{
    // ============================================================
    // 顶层 Tab
    // ============================================================
    private int activeTab = 0;
    private readonly string[] TAB_NAMES = { "性能阈值", "Shader 变体", "VFX 监控" };

    [MenuItem("TATools/ToolHub/整合 - 运行时性能监控")]
    public static void ShowWindow()
    {
        var win = GetWindow<RuntimeMonitorHub>("运行时监测中心");
        win.minSize = new Vector2(520, 480);
    }

    // ============================================================
    // 生命周期
    // ============================================================
    void OnEnable()
    {
        RpmLoadPrefs();
        EditorApplication.playModeStateChanged += OnPlayModeChanged;
        EditorApplication.update += OnEditorUpdate;
    }

    void OnDisable()
    {
        RpmSavePrefs();
        EditorApplication.playModeStateChanged -= OnPlayModeChanged;
        EditorApplication.update -= OnEditorUpdate;
        RpmStopMonitoring();
        SvmStopMonitoring();
        VfxStopMonitoring();
    }

    void OnPlayModeChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.ExitingPlayMode)
        {
            RpmStopMonitoring();
            SvmStopMonitoring();
            VfxStopMonitoring();
            Repaint();
        }
    }

    void OnEditorUpdate()
    {
        RpmUpdate();
        SvmEditorUpdate();
        VfxEditorUpdate();
    }

    // ============================================================
    // 公共样式
    // ============================================================
    private GUIStyle styleGreen;
    private GUIStyle styleRed;
    private GUIStyle styleBoldGreen;
    private bool stylesInited;

    private void InitStyles()
    {
        if (stylesInited) return;
        styleGreen     = new GUIStyle(EditorStyles.label) { fontStyle = FontStyle.Bold, normal = { textColor = new Color(0.18f, 0.78f, 0.18f) } };
        styleRed       = new GUIStyle(EditorStyles.label) { fontStyle = FontStyle.Bold, normal = { textColor = new Color(0.9f,  0.2f,  0.2f ) } };
        styleBoldGreen = new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = new Color(0.18f, 0.78f, 0.18f) } };
        stylesInited = true;
    }

    // ============================================================
    // OnGUI
    // ============================================================
    void OnGUI()
    {
        InitStyles();
        activeTab = GUILayout.Toolbar(activeTab, TAB_NAMES);
        EditorGUILayout.Space(4);
        switch (activeTab)
        {
            case 0: DrawPerfMonitorTab();  break;
            case 1: DrawShaderVariantTab(); break;
            case 2: DrawVfxProfilerTab();  break;
        }
    }

    // ============================================================
    // TAB 0: 运行时性能阈值监测
    // ============================================================
    private bool rpmEnableFps     = true;  private float rpmFpsLower    = 30f;
    private bool rpmEnableBatches = true;  private int   rpmBatchesUpper = 300;
    private bool rpmEnableSetPass = true;  private int   rpmSetPassUpper = 200;
    private bool rpmEnableTexMem  = true;  private float rpmTexMemUpper  = 512f;
    private bool rpmEnableProfiler = false;
    private bool rpmEnableInterrupt = true;

    private bool  rpmMonitoring;
    private float rpmFps;
    private float rpmTexMem;
    private int   rpmBatches;
    private int   rpmSetPass;
    private int   rpmTexMemFrame;
    private const int   RPM_TEX_SAMPLE_INTERVAL   = 30;
    private float rpmLastViolationLog = -999f;
    private const float RPM_VIOLATION_LOG_INTERVAL = 1f;
    private bool  rpmShowSummary;
    private int   rpmFpsViolCount, rpmBatchesViolCount, rpmSetPassViolCount, rpmTexMemViolCount;
    private float rpmLastRepaint;
    private bool  rpmShowConfig = true;
    private Vector2 rpmLogScroll;
    private readonly List<string> rpmTriggerLog   = new List<string>();
    private readonly List<string> rpmViolReasons  = new List<string>();

    // EditorPrefs 键
    private const string PREF_RPM_FPS_EN  = "RPM_EnableFpsCheck";
    private const string PREF_RPM_FPS_LO  = "RPM_FpsLowerLimit";
    private const string PREF_RPM_BAT_EN  = "RPM_EnableBatchesCheck";
    private const string PREF_RPM_BAT_UP  = "RPM_BatchesUpperLimit";
    private const string PREF_RPM_SP_EN   = "RPM_EnableSetPassCheck";
    private const string PREF_RPM_SP_UP   = "RPM_SetPassUpperLimit";
    private const string PREF_RPM_TEX_EN  = "RPM_EnableTexMemCheck";
    private const string PREF_RPM_TEX_UP  = "RPM_TexMemUpperLimitMB";
    private const string PREF_RPM_PROF    = "RPM_EnableProfilerDuringMonitor";
    private const string PREF_RPM_INT     = "RPM_EnableInterrupt";

    private void RpmLoadPrefs()
    {
        rpmEnableFps      = EditorPrefs.GetBool( PREF_RPM_FPS_EN, true);
        rpmFpsLower       = EditorPrefs.GetFloat(PREF_RPM_FPS_LO, 30f);
        rpmEnableBatches  = EditorPrefs.GetBool( PREF_RPM_BAT_EN, true);
        rpmBatchesUpper   = EditorPrefs.GetInt(  PREF_RPM_BAT_UP, 300);
        rpmEnableSetPass  = EditorPrefs.GetBool( PREF_RPM_SP_EN,  true);
        rpmSetPassUpper   = EditorPrefs.GetInt(  PREF_RPM_SP_UP,  200);
        rpmEnableTexMem   = EditorPrefs.GetBool( PREF_RPM_TEX_EN, true);
        rpmTexMemUpper    = EditorPrefs.GetFloat(PREF_RPM_TEX_UP, 512f);
        rpmEnableProfiler  = EditorPrefs.GetBool(PREF_RPM_PROF,   false);
        rpmEnableInterrupt = EditorPrefs.GetBool(PREF_RPM_INT,    true);
    }

    private void RpmSavePrefs()
    {
        EditorPrefs.SetBool( PREF_RPM_FPS_EN, rpmEnableFps);
        EditorPrefs.SetFloat(PREF_RPM_FPS_LO, rpmFpsLower);
        EditorPrefs.SetBool( PREF_RPM_BAT_EN, rpmEnableBatches);
        EditorPrefs.SetInt(  PREF_RPM_BAT_UP, rpmBatchesUpper);
        EditorPrefs.SetBool( PREF_RPM_SP_EN,  rpmEnableSetPass);
        EditorPrefs.SetInt(  PREF_RPM_SP_UP,  rpmSetPassUpper);
        EditorPrefs.SetBool( PREF_RPM_TEX_EN, rpmEnableTexMem);
        EditorPrefs.SetFloat(PREF_RPM_TEX_UP, rpmTexMemUpper);
        EditorPrefs.SetBool( PREF_RPM_PROF,   rpmEnableProfiler);
        EditorPrefs.SetBool( PREF_RPM_INT,    rpmEnableInterrupt);
    }

    private void DrawPerfMonitorTab()
    {
        // 阈值配置折叠区
        rpmShowConfig = EditorGUILayout.Foldout(rpmShowConfig, "阈值配置", true, EditorStyles.foldoutHeader);
        if (rpmShowConfig)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUI.BeginChangeCheck();
            const float LW = 200f, FW = 80f;
            RpmToggleRow(ref rpmEnableFps,     "FPS 下限（低于此值触发）",           LW, () => rpmFpsLower    = EditorGUILayout.FloatField(rpmFpsLower,    GUILayout.Width(FW)));
            RpmToggleRow(ref rpmEnableBatches, "Batches 上限（超过此值触发）",        LW, () => rpmBatchesUpper = EditorGUILayout.IntField(  rpmBatchesUpper, GUILayout.Width(FW)));
            RpmToggleRow(ref rpmEnableSetPass, "SetPass Calls 上限（超过此值触发）",  LW, () => rpmSetPassUpper = EditorGUILayout.IntField(  rpmSetPassUpper, GUILayout.Width(FW)));
            RpmToggleRow(ref rpmEnableTexMem,  "Texture2D 内存 MB 上限（超过触发）",  LW, () => rpmTexMemUpper  = EditorGUILayout.FloatField(rpmTexMemUpper,  GUILayout.Width(FW)));

            EditorGUILayout.Space(4);
            EditorGUILayout.BeginHorizontal();
            rpmEnableProfiler = EditorGUILayout.Toggle(rpmEnableProfiler, GUILayout.Width(16));
            EditorGUILayout.LabelField("监控期间同步启用 Profiler 录制", GUILayout.Width(LW));
            EditorGUILayout.EndHorizontal();
            if (rpmEnableProfiler)
                EditorGUILayout.HelpBox("注意：Profiler 会引入额外开销（5~15% FPS 下降），可能导致阈值误报。", MessageType.Warning);

            EditorGUILayout.BeginHorizontal();
            rpmEnableInterrupt = EditorGUILayout.Toggle(rpmEnableInterrupt, GUILayout.Width(16));
            EditorGUILayout.LabelField("触发阈值时暂停游戏", GUILayout.Width(LW + FW));
            EditorGUILayout.EndHorizontal();
            if (!rpmEnableInterrupt)
                EditorGUILayout.HelpBox("非阻断模式：持续记录违规帧，停止后显示汇总，游戏不会中断。", MessageType.Info);

            if (EditorGUI.EndChangeCheck()) RpmSavePrefs();
            EditorGUILayout.EndVertical();
        }

        EditorGUILayout.Space(4);

        // 控制按钮
        EditorGUILayout.BeginHorizontal();
        if (!rpmMonitoring)
        {
            GUI.enabled = EditorApplication.isPlaying;
            if (GUILayout.Button("开始监控", GUILayout.Height(26)))
            {
                rpmTexMemFrame = rpmFpsViolCount = rpmBatchesViolCount = rpmSetPassViolCount = rpmTexMemViolCount = 0;
                rpmShowSummary = false;
                rpmLastViolationLog = -999f;
                rpmMonitoring = true;
                if (rpmEnableProfiler) { Profiler.enabled = true; EditorApplication.ExecuteMenuItem("Window/Analysis/Profiler"); }
            }
            GUI.enabled = true;
        }
        else
        {
            if (GUILayout.Button("停止监控", GUILayout.Height(26))) RpmStopMonitoring();
        }
        if (GUILayout.Button("清除日志", GUILayout.Height(26), GUILayout.Width(80))) rpmTriggerLog.Clear();
        EditorGUILayout.EndHorizontal();

        if (!EditorApplication.isPlaying)
            EditorGUILayout.HelpBox("请进入 PlayMode 后再开始监控。", MessageType.Info);
        else if (rpmMonitoring)
            EditorGUILayout.LabelField("● 监控中...", styleBoldGreen);
        else
            EditorGUILayout.LabelField("● 已停止", EditorStyles.miniLabel);

        EditorGUILayout.Space(4);

        // 实时数据
        EditorGUILayout.LabelField("实时性能数据", EditorStyles.boldLabel);
        if (!EditorApplication.isPlaying)
        {
            EditorGUILayout.LabelField("— 非 PlayMode，无数据 —", EditorStyles.centeredGreyMiniLabel);
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            RpmMetricRow("FPS",            $"{rpmFps:F1}",       $"下限: {rpmFpsLower}",        rpmEnableFps     && rpmFps     < rpmFpsLower);
            RpmMetricRow("Batches",        $"{rpmBatches}",       $"上限: {rpmBatchesUpper}",     rpmEnableBatches && rpmBatches > rpmBatchesUpper);
            RpmMetricRow("SetPass Calls",  $"{rpmSetPass}",       $"上限: {rpmSetPassUpper}",     rpmEnableSetPass && rpmSetPass > rpmSetPassUpper);
            RpmMetricRow("Texture2D 内存", $"{rpmTexMem:F2} MB",  $"上限: {rpmTexMemUpper} MB",   rpmEnableTexMem  && rpmTexMem  > rpmTexMemUpper);
            EditorGUILayout.EndVertical();
        }

        // 触发日志
        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField($"触发日志（{rpmTriggerLog.Count} 条）", EditorStyles.boldLabel);
        if (rpmTriggerLog.Count > 0)
        {
            float logH = Mathf.Clamp(rpmTriggerLog.Count * 72f, 80f, 200f);
            rpmLogScroll = EditorGUILayout.BeginScrollView(rpmLogScroll, GUILayout.Height(logH));
            for (int i = rpmTriggerLog.Count - 1; i >= 0; i--)
                EditorGUILayout.LabelField(rpmTriggerLog[i], EditorStyles.helpBox);
            EditorGUILayout.EndScrollView();
        }
        else
        {
            EditorGUILayout.LabelField("暂无触发记录。", EditorStyles.centeredGreyMiniLabel);
        }

        // 违规汇总
        if (rpmShowSummary)
        {
            EditorGUILayout.Space(4);
            EditorGUILayout.LabelField("违规统计汇总（本次监控）", EditorStyles.boldLabel);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            int tot = rpmFpsViolCount + rpmBatchesViolCount + rpmSetPassViolCount + rpmTexMemViolCount;
            EditorGUILayout.LabelField($"总违规帧次：{tot}", EditorStyles.boldLabel);
            if (rpmEnableFps)      EditorGUILayout.LabelField($"  FPS 低于下限 {rpmFpsLower}：{rpmFpsViolCount} 帧");
            if (rpmEnableBatches)  EditorGUILayout.LabelField($"  Batches 超上限 {rpmBatchesUpper}：{rpmBatchesViolCount} 帧");
            if (rpmEnableSetPass)  EditorGUILayout.LabelField($"  SetPass 超上限 {rpmSetPassUpper}：{rpmSetPassViolCount} 帧");
            if (rpmEnableTexMem)   EditorGUILayout.LabelField($"  Texture2D 内存超上限 {rpmTexMemUpper} MB：{rpmTexMemViolCount} 帧");
            EditorGUILayout.EndVertical();
        }
    }

    private void RpmToggleRow(ref bool toggle, string label, float labelWidth, Action fieldDraw)
    {
        EditorGUILayout.BeginHorizontal();
        toggle = EditorGUILayout.Toggle(toggle, GUILayout.Width(16));
        EditorGUILayout.LabelField(label, GUILayout.Width(labelWidth));
        GUI.enabled = toggle;
        fieldDraw();
        GUI.enabled = true;
        EditorGUILayout.EndHorizontal();
    }

    private void RpmMetricRow(string label, string val, string limit, bool violated)
    {
        var s = violated ? styleRed : styleGreen;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(label + ":", GUILayout.Width(120));
        EditorGUILayout.LabelField(val, s, GUILayout.Width(100));
        EditorGUILayout.LabelField(limit, EditorStyles.miniLabel);
        EditorGUILayout.EndHorizontal();
    }

    private void RpmStopMonitoring()
    {
        if (!rpmMonitoring) return;
        rpmMonitoring = false;
        if (rpmEnableProfiler) Profiler.enabled = false;
        if (!rpmEnableInterrupt) rpmShowSummary = true;
    }

    private void RpmUpdate()
    {
        if (!rpmMonitoring || !EditorApplication.isPlaying || EditorApplication.isPaused) return;

        rpmBatches = UnityStats.batches;
        rpmSetPass = UnityStats.setPassCalls;
        rpmFps     = Time.unscaledDeltaTime > 0f ? 1f / Time.unscaledDeltaTime : 999f;

        rpmTexMemFrame++;
        if (rpmTexMemFrame >= RPM_TEX_SAMPLE_INTERVAL)
        {
            rpmTexMemFrame = 0;
            long bytes = 0;
            foreach (var t in Resources.FindObjectsOfTypeAll<Texture2D>())
                if (t != null) bytes += Profiler.GetRuntimeMemorySizeLong(t);
            rpmTexMem = bytes / (1024f * 1024f);
        }

        RpmCheckThresholds();

        if (rpmEnableInterrupt || Time.realtimeSinceStartup - rpmLastRepaint >= 0.1f)
        {
            rpmLastRepaint = Time.realtimeSinceStartup;
            Repaint();
        }
    }

    private void RpmCheckThresholds()
    {
        rpmViolReasons.Clear();
        if (rpmEnableFps     && rpmFps     < rpmFpsLower)     rpmViolReasons.Add($"FPS {rpmFps:F1} 低于下限 {rpmFpsLower}");
        if (rpmEnableBatches && rpmBatches > rpmBatchesUpper) rpmViolReasons.Add($"Batches {rpmBatches} 超过上限 {rpmBatchesUpper}");
        if (rpmEnableSetPass && rpmSetPass > rpmSetPassUpper) rpmViolReasons.Add($"SetPass {rpmSetPass} 超过上限 {rpmSetPassUpper}");
        if (rpmEnableTexMem  && rpmTexMem  > rpmTexMemUpper)  rpmViolReasons.Add($"TexMem {rpmTexMem:F2}MB 超过上限 {rpmTexMemUpper}MB");
        if (rpmViolReasons.Count == 0) return;

        string ts    = DateTime.Now.ToString("HH:mm:ss");
        string entry = $"[帧 {Time.frameCount}]  {ts}\nFPS:{rpmFps:F1}  Batches:{rpmBatches}  SetPass:{rpmSetPass}  TexMem:{rpmTexMem:F2}MB\n触发: {string.Join(" | ", rpmViolReasons)}";

        if (rpmEnableInterrupt)
        {
            rpmTriggerLog.Add(entry);
            RpmStopMonitoring();
            EditorApplication.isPaused = true;
            RpmEnableFrameDebugger();
            EditorApplication.ExecuteMenuItem("Window/Analysis/Profiler");
        }
        else
        {
            if (Time.realtimeSinceStartup - rpmLastViolationLog >= RPM_VIOLATION_LOG_INTERVAL)
            {
                rpmLastViolationLog = Time.realtimeSinceStartup;
                rpmTriggerLog.Add(entry);
            }
            if (rpmEnableFps     && rpmFps     < rpmFpsLower)     rpmFpsViolCount++;
            if (rpmEnableBatches && rpmBatches > rpmBatchesUpper) rpmBatchesViolCount++;
            if (rpmEnableSetPass && rpmSetPass > rpmSetPassUpper) rpmSetPassViolCount++;
            if (rpmEnableTexMem  && rpmTexMem  > rpmTexMemUpper)  rpmTexMemViolCount++;
        }
    }

    private void RpmEnableFrameDebugger()
    {
        EditorApplication.ExecuteMenuItem("Window/Analysis/Frame Debugger");
        try
        {
            Type fdType = Type.GetType("UnityEditorInternal.FrameDebuggerUtility, UnityEditor");
            if (fdType == null) return;
            var prop = fdType.GetProperty("locallyEnabled", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic)
                    ?? fdType.GetProperty("enabled",        BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
            prop?.SetValue(null, true);
        }
        catch (Exception e) { Debug.LogWarning($"[RuntimeMonitorHub] Frame Debugger 反射失败: {e.Message}"); }
    }

    // ============================================================
    // TAB 1: Shader 变体监测
    // ============================================================
    private enum SvmSubTab { Overview, ActiveShaders, Variants, LoadLog }
    private SvmSubTab svmSubTab = SvmSubTab.Overview;

    private bool  svmMonitoring;
    private float svmUpdateInterval = 1.0f;
    private float svmLastUpdate;

    private struct SvmShaderEntry { public string name; public long memoryBytes; public int variantCount; public bool isActive; }
    private readonly List<SvmShaderEntry> svmEntries    = new List<SvmShaderEntry>();
    private readonly HashSet<string>      svmActiveNames = new HashSet<string>();
    private readonly HashSet<string>      svmPrevLoaded  = new HashSet<string>();
    private readonly List<string>         svmLoadLog     = new List<string>();
    private const int SVM_LOG_MAX = 300;

    private long svmTotalMemory;
    private int  svmCollShaderCount, svmCollVariantCount;
    private bool svmSortByMemory = true;
    private string svmNameFilter = "";
    private Vector2 svmOverviewScroll, svmActiveScroll, svmVariantScroll, svmLogScroll;

    private GUIStyle svmLoadStyle, svmUnloadStyle, svmActiveTagStyle;
    private bool svmStylesInited;

    // 反射缓存
    private static MethodInfo svmGetVariantCountMethod;
    private static bool svmVariantCountChecked;
    private static MethodInfo svmGetCollShaderCount, svmGetCollVariantCount;
    private static bool svmCollMethodsChecked;

    private void SvmInitStyles()
    {
        if (svmStylesInited) return;
        svmLoadStyle      = new GUIStyle(EditorStyles.label) { fontStyle = FontStyle.Bold, normal = { textColor = new Color(0.2f, 0.85f, 0.2f) } };
        svmUnloadStyle    = new GUIStyle(EditorStyles.label) { fontStyle = FontStyle.Bold, normal = { textColor = new Color(0.9f, 0.35f, 0.35f) } };
        svmActiveTagStyle = new GUIStyle(EditorStyles.miniLabel) { fontStyle = FontStyle.Bold, normal = { textColor = new Color(0.2f, 0.85f, 0.2f) } };
        svmStylesInited = true;
    }

    private void SvmEditorUpdate()
    {
        if (!svmMonitoring || !EditorApplication.isPlaying) return;
        float now = (float)EditorApplication.timeSinceStartup;
        if (now - svmLastUpdate < svmUpdateInterval) return;
        svmLastUpdate = now;
        SvmCollectData();
        if (activeTab == 1) Repaint();
    }

    private void SvmStopMonitoring() { svmMonitoring = false; }

    private void DrawShaderVariantTab()
    {
        SvmInitStyles();

        // 控制条
        EditorGUILayout.BeginHorizontal();
        bool inPlay = EditorApplication.isPlaying;
        GUI.enabled = inPlay;
        if (!svmMonitoring)
        {
            if (GUILayout.Button("▶ 开始监测", GUILayout.Height(24), GUILayout.Width(100)))
            {
                svmPrevLoaded.Clear(); svmLoadLog.Clear(); svmEntries.Clear();
                svmLastUpdate = 0f; svmMonitoring = true;
            }
        }
        else
        {
            if (GUILayout.Button("■ 停止监测", GUILayout.Height(24), GUILayout.Width(100)))
                svmMonitoring = false;
        }
        GUI.enabled = true;
        GUILayout.Label("刷新间隔:", GUILayout.Width(55));
        svmUpdateInterval = EditorGUILayout.Slider(svmUpdateInterval, 0.1f, 5f, GUILayout.Width(180));
        GUILayout.FlexibleSpace();
        if (!inPlay)           { GUILayout.Label("● 未进入 Play 模式", EditorStyles.miniLabel); }
        else if (svmMonitoring){ GUI.color = new Color(0.2f, 0.85f, 0.2f); GUILayout.Label("● 监测中", EditorStyles.boldLabel); GUI.color = Color.white; }
        else                   { GUILayout.Label("○ 已停止", EditorStyles.miniLabel); }
        EditorGUILayout.EndHorizontal();

        if (!inPlay) EditorGUILayout.HelpBox("请进入 Play 模式后开始监测。", MessageType.Info);

        EditorGUILayout.Space(4);

        // 子 Tab 栏
        svmSubTab = (SvmSubTab)GUILayout.Toolbar((int)svmSubTab,
            new[] { "内存总览", "运行中 Shader", "Variant 统计", "加载日志" });
        EditorGUILayout.Space(4);

        switch (svmSubTab)
        {
            case SvmSubTab.Overview:      SvmDrawOverview();      break;
            case SvmSubTab.ActiveShaders: SvmDrawActiveShaders(); break;
            case SvmSubTab.Variants:      SvmDrawVariants();      break;
            case SvmSubTab.LoadLog:       SvmDrawLoadLog();       break;
        }
    }

    private void SvmCollectData()
    {
        var allShaders = Resources.FindObjectsOfTypeAll<Shader>();
        var currentNames = new HashSet<string>(allShaders.Length);
        svmEntries.Clear(); svmTotalMemory = 0;

        foreach (var shader in allShaders)
        {
            if (shader == null || string.IsNullOrEmpty(shader.name)) continue;
            currentNames.Add(shader.name);
            long mem = Profiler.GetRuntimeMemorySizeLong(shader);
            svmTotalMemory += mem;
            svmEntries.Add(new SvmShaderEntry { name = shader.name, memoryBytes = mem, variantCount = SvmGetVariantCount(shader), isActive = false });
        }

        string ts = DateTime.Now.ToString("HH:mm:ss.fff");
        foreach (string n in currentNames) if (!svmPrevLoaded.Contains(n)) SvmAppendLog($"[{ts}] ▲ LOAD    {n}");
        foreach (string n in svmPrevLoaded) if (!currentNames.Contains(n)) SvmAppendLog($"[{ts}] ▼ UNLOAD  {n}");
        svmPrevLoaded.Clear(); foreach (string n in currentNames) svmPrevLoaded.Add(n);

        svmActiveNames.Clear();
        foreach (var r in FindObjectsOfType<Renderer>())
        {
            if (!r.enabled || !r.gameObject.activeInHierarchy) continue;
            foreach (var mat in r.sharedMaterials) if (mat?.shader != null) svmActiveNames.Add(mat.shader.name);
        }
        for (int i = 0; i < svmEntries.Count; i++) { var e = svmEntries[i]; e.isActive = svmActiveNames.Contains(e.name); svmEntries[i] = e; }

        svmCollShaderCount  = SvmGetCollShaderCount();
        svmCollVariantCount = SvmGetCollVariantCount();
        SvmApplySort();
    }

    private void SvmApplySort()
    {
        if (svmSortByMemory) svmEntries.Sort((a, b) => b.memoryBytes.CompareTo(a.memoryBytes));
        else                 svmEntries.Sort((a, b) => string.Compare(a.name, b.name, StringComparison.OrdinalIgnoreCase));
    }

    private void SvmAppendLog(string entry)
    {
        svmLoadLog.Add(entry);
        if (svmLoadLog.Count > SVM_LOG_MAX) svmLoadLog.RemoveAt(0);
    }

    private void SvmDrawOverview()
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"Shader 总内存: {SvmFormatBytes(svmTotalMemory)}", EditorStyles.boldLabel);
        GUILayout.FlexibleSpace();
        GUILayout.Label($"已加载: {svmEntries.Count}  活跃: {svmActiveNames.Count}", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("过滤:", GUILayout.Width(32));
        svmNameFilter = EditorGUILayout.TextField(svmNameFilter, GUILayout.ExpandWidth(true));
        GUILayout.Label("排序:", GUILayout.Width(32));
        bool newMem  = GUILayout.Toggle( svmSortByMemory, "内存", EditorStyles.miniButtonLeft,  GUILayout.Width(46));
        bool newName = GUILayout.Toggle(!svmSortByMemory, "名称", EditorStyles.miniButtonRight, GUILayout.Width(46));
        if (newMem != svmSortByMemory || newName == svmSortByMemory) { svmSortByMemory = newMem; SvmApplySort(); }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        GUILayout.Label("状态", GUILayout.Width(36));
        GUILayout.Label("Shader 名称", GUILayout.ExpandWidth(true));
        GUILayout.Label("内存占用", GUILayout.Width(80));
        EditorGUILayout.EndHorizontal();

        svmOverviewScroll = EditorGUILayout.BeginScrollView(svmOverviewScroll);
        string filter = svmNameFilter.Trim();
        foreach (var e in svmEntries)
        {
            if (!string.IsNullOrEmpty(filter) && e.name.IndexOf(filter, StringComparison.OrdinalIgnoreCase) < 0) continue;
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            GUILayout.Label(e.isActive ? "▶" : "–", e.isActive ? svmActiveTagStyle : EditorStyles.label, GUILayout.Width(36));
            GUILayout.Label(e.name, GUILayout.ExpandWidth(true));
            GUILayout.Label(SvmFormatBytes(e.memoryBytes), GUILayout.Width(80));
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
        EditorGUILayout.HelpBox("▶ = 场景 Renderer 正在使用   – = 已加载但未激活", MessageType.None);
    }

    private void SvmDrawActiveShaders()
    {
        GUILayout.Label($"当前场景激活 Renderer 使用的 Shader（共 {svmActiveNames.Count} 个）", EditorStyles.boldLabel);
        svmActiveScroll = EditorGUILayout.BeginScrollView(svmActiveScroll);
        foreach (string n in svmActiveNames.OrderBy(x => x))
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            GUILayout.Label("▶", svmActiveTagStyle, GUILayout.Width(20));
            GUILayout.Label(n);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }

    private void SvmDrawVariants()
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        GUILayout.Label("ShaderVariantCollection 全局统计", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"已收集 Shader 数：{svmCollShaderCount}");
        GUILayout.Label($"已收集 Variant 数：{svmCollVariantCount}");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();

        if (!svmEntries.Any(e => e.variantCount >= 0))
        {
            EditorGUILayout.HelpBox("当前 Unity 版本未暴露 ShaderUtil.GetVariantCount，无法获取各 Shader 变体数。", MessageType.Warning);
            return;
        }

        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        GUILayout.Label("Shader 名称", GUILayout.ExpandWidth(true));
        GUILayout.Label("变体数", GUILayout.Width(70));
        GUILayout.Label("内存",   GUILayout.Width(80));
        EditorGUILayout.EndHorizontal();

        svmVariantScroll = EditorGUILayout.BeginScrollView(svmVariantScroll);
        foreach (var e in svmEntries.Where(e => e.variantCount >= 0).OrderByDescending(e => e.variantCount))
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            GUILayout.Label(e.name, GUILayout.ExpandWidth(true));
            GUILayout.Label(e.variantCount.ToString(), GUILayout.Width(70));
            GUILayout.Label(SvmFormatBytes(e.memoryBytes), GUILayout.Width(80));
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }

    private void SvmDrawLoadLog()
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label($"Shader 加载/卸载日志（{svmLoadLog.Count}/{SVM_LOG_MAX} 条）", EditorStyles.boldLabel);
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("清空", GUILayout.Width(48))) svmLoadLog.Clear();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.HelpBox("▲ LOAD = Shader 进入内存   ▼ UNLOAD = Shader 被卸载", MessageType.None);
        svmLogScroll = EditorGUILayout.BeginScrollView(svmLogScroll);
        for (int i = svmLoadLog.Count - 1; i >= 0; i--)
            GUILayout.Label(svmLoadLog[i], svmLoadLog[i].Contains("▲") ? svmLoadStyle : svmUnloadStyle);
        EditorGUILayout.EndScrollView();
    }

    private static string SvmFormatBytes(long bytes)
    {
        if (bytes >= 1024L * 1024 * 1024) return $"{bytes / (1024f * 1024 * 1024):F2} GB";
        if (bytes >= 1024 * 1024) return $"{bytes / (1024f * 1024):F2} MB";
        if (bytes >= 1024)        return $"{bytes / 1024f:F1} KB";
        return $"{bytes} B";
    }

    private static int SvmGetVariantCount(Shader shader)
    {
        if (!svmVariantCountChecked)
        {
            svmVariantCountChecked = true;
            svmGetVariantCountMethod = typeof(ShaderUtil).GetMethod("GetVariantCount",
                BindingFlags.Public | BindingFlags.Static | BindingFlags.NonPublic,
                null, new[] { typeof(Shader), typeof(bool) }, null);
        }
        if (svmGetVariantCountMethod == null) return -1;
        try { return Convert.ToInt32(svmGetVariantCountMethod.Invoke(null, new object[] { shader, true })); }
        catch { return -1; }
    }

    private static int SvmGetCollShaderCount()
    {
        SvmEnsureCollMethods();
        if (svmGetCollShaderCount == null) return 0;
        try { return Convert.ToInt32(svmGetCollShaderCount.Invoke(null, null)); } catch { return 0; }
    }

    private static int SvmGetCollVariantCount()
    {
        SvmEnsureCollMethods();
        if (svmGetCollVariantCount == null) return 0;
        try { return Convert.ToInt32(svmGetCollVariantCount.Invoke(null, null)); } catch { return 0; }
    }

    private static void SvmEnsureCollMethods()
    {
        if (svmCollMethodsChecked) return;
        svmCollMethodsChecked = true;
        const BindingFlags f = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static;
        svmGetCollShaderCount  = typeof(ShaderUtil).GetMethod("GetCurrentShaderVariantCollectionShaderCount",  f);
        svmGetCollVariantCount = typeof(ShaderUtil).GetMethod("GetCurrentShaderVariantCollectionVariantCount", f);
    }

    // ============================================================
    // TAB 2: VFX 运行时监控
    // ============================================================
    private GameObject vfxTarget;
    private bool  vfxMonitoring;
    private float vfxInterval  = 0.5f;
    private float vfxNextUpdate;
    private bool  vfxShowGpuWarning = true;

    private int   vfxDrawCalls, vfxBatches, vfxTriangles, vfxParticles;
    private float vfxCPUTime, vfxGPUMem;

    private readonly List<float> vfxDCHist    = new List<float>();
    private readonly List<float> vfxBatHist   = new List<float>();
    private readonly List<float> vfxTriHist   = new List<float>();
    private readonly List<float> vfxCpuHist   = new List<float>();
    private readonly List<float> vfxMemHist   = new List<float>();
    private readonly List<float> vfxPartHist  = new List<float>();
    private const int VFX_MAX_HIST = 60;
    private Vector2 vfxScroll;

    private void VfxEditorUpdate()
    {
        if (!Application.isPlaying || !vfxMonitoring) return;
        if (Time.realtimeSinceStartup < vfxNextUpdate) return;
        vfxNextUpdate = Time.realtimeSinceStartup + vfxInterval;
        VfxUpdateData();
        if (activeTab == 2) Repaint();
    }

    private void VfxStopMonitoring()
    {
        if (!vfxMonitoring) return;
        vfxMonitoring = false;
        VfxClearHistory();
    }

    private void DrawVfxProfilerTab()
    {
        GUILayout.Label("特效运行时性能分析", EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        vfxTarget   = (GameObject)EditorGUILayout.ObjectField("目标特效对象", vfxTarget, typeof(GameObject), true);
        vfxInterval = EditorGUILayout.Slider("更新间隔 (秒)", vfxInterval, 0.1f, 2.0f);
        EditorGUILayout.Space(4);

        if (vfxShowGpuWarning)
        {
            EditorGUILayout.HelpBox("注意: 目前没有直接获取GPU渲染时间的原生API。如需GPU性能分析，建议使用Unity Profiler或GPU分析工具。", MessageType.Info);
            if (GUILayout.Button("不再显示此提示")) vfxShowGpuWarning = false;
        }

        EditorGUILayout.Space(4);
        GUI.enabled = Application.isPlaying;
        if (!vfxMonitoring)
        {
            if (GUILayout.Button("开始监控")) { vfxMonitoring = true; VfxClearHistory(); }
        }
        else
        {
            if (GUILayout.Button("停止监控")) VfxStopMonitoring();
        }
        GUI.enabled = true;

        if (!Application.isPlaying)
        {
            EditorGUILayout.HelpBox("只能在游戏运行时监控性能。请进入播放模式。", MessageType.Info);
            return;
        }
        if (!vfxMonitoring) return;

        EditorGUILayout.Space(4);
        vfxScroll = EditorGUILayout.BeginScrollView(vfxScroll);
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        EditorGUILayout.LabelField("性能监控数据", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("当前 Draw Calls: " + vfxDrawCalls);
        EditorGUILayout.LabelField("当前 Batches: "    + vfxBatches);
        EditorGUILayout.LabelField("当前三角形数: "    + vfxTriangles);
        EditorGUILayout.LabelField("CPU 时间: "        + vfxCPUTime.ToString("F2") + " ms");
        EditorGUILayout.LabelField("活跃粒子数: "      + vfxParticles);
        EditorGUILayout.LabelField("GPU 内存占用: "    + vfxGPUMem.ToString("F2") + " MB");

        if (vfxDCHist.Count > 1)
        {
            VfxDrawGraph("Draw Calls 历史曲线",   vfxDCHist,   Color.green);
            VfxDrawGraph("Batches 历史曲线",       vfxBatHist,  Color.blue);
            VfxDrawGraph("三角形数 历史曲线",      vfxTriHist,  new Color(1f, 0.5f, 0f));
            VfxDrawGraph("CPU 时间 (ms) 历史曲线", vfxCpuHist,  Color.red);
            VfxDrawGraph("活跃粒子数 历史曲线",    vfxPartHist, Color.yellow);
            VfxDrawGraph("GPU 内存 (MB) 历史曲线", vfxMemHist,  Color.magenta);
        }
        EditorGUILayout.EndScrollView();
    }

    private void VfxUpdateData()
    {
        if (vfxTarget == null) return;
        vfxDrawCalls = UnityStats.drawCalls;
        vfxBatches   = UnityStats.batches;
        vfxTriangles = UnityStats.triangles;
        vfxCPUTime   = Time.deltaTime * 1000f;
        vfxParticles = 0;
        foreach (var ps in vfxTarget.GetComponentsInChildren<ParticleSystem>(true))
            vfxParticles += ps.particleCount;
        vfxGPUMem = VfxEstimateGPUMem(vfxTarget);

        VfxAddHist(vfxDCHist,   vfxDrawCalls);
        VfxAddHist(vfxBatHist,  vfxBatches);
        VfxAddHist(vfxTriHist,  vfxTriangles);
        VfxAddHist(vfxCpuHist,  vfxCPUTime);
        VfxAddHist(vfxMemHist,  vfxGPUMem);
        VfxAddHist(vfxPartHist, vfxParticles);
    }

    private void VfxAddHist(List<float> list, float val) { list.Add(val); if (list.Count > VFX_MAX_HIST) list.RemoveAt(0); }

    private void VfxClearHistory()
    {
        vfxDCHist.Clear(); vfxBatHist.Clear(); vfxTriHist.Clear();
        vfxCpuHist.Clear(); vfxMemHist.Clear(); vfxPartHist.Clear();
    }

    private float VfxEstimateGPUMem(GameObject obj)
    {
        float total = 0f;
        var textures = new HashSet<Texture>();
        foreach (var r in obj.GetComponentsInChildren<Renderer>(true))
        {
            foreach (var mat in r.sharedMaterials)
            {
                if (mat == null || mat.shader == null) continue;
                int cnt = ShaderUtil.GetPropertyCount(mat.shader);
                for (int i = 0; i < cnt; i++)
                {
                    if (ShaderUtil.GetPropertyType(mat.shader, i) != ShaderUtil.ShaderPropertyType.TexEnv) continue;
                    var tex = mat.GetTexture(ShaderUtil.GetPropertyName(mat.shader, i));
                    if (tex != null) textures.Add(tex);
                }
            }
        }
        foreach (var tex in textures)
        {
            if (tex is Texture2D t2d)       total += t2d.width * t2d.height * VfxGetBPP(t2d.format) / 8f / (1024f * 1024f);
            else if (tex is RenderTexture rt) total += rt.width  * rt.height  * 32f                  / 8f / (1024f * 1024f);
        }
        foreach (var mf in obj.GetComponentsInChildren<MeshFilter>(true))
            if (mf.sharedMesh != null) total += mf.sharedMesh.vertexCount * 100f / (1024f * 1024f);
        foreach (var ps in obj.GetComponentsInChildren<ParticleSystem>(true))
        {
            var psr = ps.GetComponent<ParticleSystemRenderer>();
            if (psr != null && psr.renderMode == ParticleSystemRenderMode.Mesh && psr.mesh != null)
                total += psr.mesh.vertexCount * 100f / (1024f * 1024f);
        }
        return total;
    }

    private int VfxGetBPP(TextureFormat f)
    {
        switch (f)
        {
            case TextureFormat.Alpha8:                                                        return 8;
            case TextureFormat.ARGB4444: case TextureFormat.RGB565:                          return 16;
            case TextureFormat.RGB24:                                                         return 24;
            case TextureFormat.RGBA32:   case TextureFormat.ARGB32:                          return 32;
            case TextureFormat.DXT1:     case TextureFormat.ETC_RGB4: case TextureFormat.ETC2_RGB:
            case TextureFormat.PVRTC_RGB4: case TextureFormat.PVRTC_RGBA4:                   return 4;
            case TextureFormat.DXT5:     case TextureFormat.ETC2_RGBA8: case TextureFormat.ASTC_4x4: return 8;
            case TextureFormat.PVRTC_RGB2: case TextureFormat.PVRTC_RGBA2: case TextureFormat.ASTC_8x8: return 2;
            case TextureFormat.ASTC_6x6:                                                     return 3;
            default:                                                                          return 16;
        }
    }

    private void VfxDrawGraph(string title, List<float> values, Color color)
    {
        if (values.Count < 2) return;
        EditorGUILayout.LabelField(title, EditorStyles.boldLabel);
        Rect rect = GUILayoutUtility.GetRect(EditorGUIUtility.currentViewWidth - 40, 60);
        float max = values.Max();
        float min = Mathf.Min(0, values.Min());
        if (Mathf.Approximately(max, min)) max = min + 1;

        Handles.BeginGUI();
        Handles.color = Color.gray;
        Handles.DrawLine(new Vector3(rect.x, rect.y), new Vector3(rect.x, rect.y + rect.height));
        Handles.DrawLine(new Vector3(rect.x, rect.y + rect.height), new Vector3(rect.x + rect.width, rect.y + rect.height));
        Handles.color = color;
        float stepX = rect.width / (values.Count - 1);
        for (int i = 0; i < values.Count - 1; i++)
        {
            float n1 = (values[i]     - min) / (max - min);
            float n2 = (values[i + 1] - min) / (max - min);
            Handles.DrawLine(
                new Vector3(rect.x + i * stepX,       rect.y + rect.height - n1 * rect.height),
                new Vector3(rect.x + (i + 1) * stepX, rect.y + rect.height - n2 * rect.height));
        }
        Handles.EndGUI();

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Min: " + min.ToString("F2"));
        GUILayout.FlexibleSpace();
        GUILayout.Label("Max: " + max.ToString("F2"));
        EditorGUILayout.EndHorizontal();
    }
}
#endif
