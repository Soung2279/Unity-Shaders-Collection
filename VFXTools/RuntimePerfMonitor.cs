using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;

#if UNITY_EDITOR
public class RuntimePerfMonitor : EditorWindow
{
    // ─── 阈值配置字段 ─────────────────────────────────────────
    private bool enableFpsCheck = true;
    private float fpsLowerLimit = 30f;

    private bool enableBatchesCheck = true;
    private int batchesUpperLimit = 300;

    private bool enableSetPassCheck = true;
    private int setPassUpperLimit = 200;

    private bool enableTexMemCheck = true;
    private float texMemUpperLimitMB = 512f;

    // ─── 运行时采集数据 ───────────────────────────────────────
    private bool isMonitoring = false;
    private float currentFps = 0f;
    private int currentBatches = 0;
    private int currentSetPass = 0;
    private float currentTexMemMB = 0f;

    // Texture2D 内存采样节流：每 texMemSampleInterval 帧采样一次，避免高频 FindObjectsOfTypeAll 带来的性能损耗
    private const int TEX_MEM_SAMPLE_INTERVAL = 30;
    private int texMemFrameCounter = 0;

    // 是否在监控期间同步启用 Profiler（会引入 5~15% 额外开销，可能导致 FPS 指标偏低）
    private bool enableProfilerDuringMonitor = false;

    // 是否阻断：true = 触发后暂停并弹出 Frame Debugger（原有行为）；false = 持续记录，不中断游戏
    private bool enableInterrupt = true;
    private float lastViolationLogTime = -999f;
    private const float VIOLATION_LOG_INTERVAL = 1f; // 非阻断模式：每秒最多向日志写入一次
    private bool showViolationSummary = false;

    // 各项违规帧次统计（仅非阻断模式使用）
    private int fpsViolationCount = 0;
    private int batchesViolationCount = 0;
    private int setPassViolationCount = 0;
    private int texMemViolationCount = 0;

    // ─── UI 状态 ─────────────────────────────────────────────
    private bool showConfig = true;
    private Vector2 logScrollPos;
    private readonly List<string> triggerLog = new List<string>();
    private readonly List<string> violationReasons = new List<string>(); // 缓存复用，避免每帧 new 触发 GC
    private float lastRepaintTime = 0f;

    // ─── EditorPrefs 键名 ────────────────────────────────────
    private const string PREF_ENABLE_FPS     = "RPM_EnableFpsCheck";
    private const string PREF_FPS_LOWER      = "RPM_FpsLowerLimit";
    private const string PREF_ENABLE_BATCHES = "RPM_EnableBatchesCheck";
    private const string PREF_BATCHES_UPPER  = "RPM_BatchesUpperLimit";
    private const string PREF_ENABLE_SETPASS = "RPM_EnableSetPassCheck";
    private const string PREF_SETPASS_UPPER  = "RPM_SetPassUpperLimit";
    private const string PREF_ENABLE_TEXMEM  = "RPM_EnableTexMemCheck";
    private const string PREF_TEXMEM_UPPER   = "RPM_TexMemUpperLimitMB";
    private const string PREF_ENABLE_PROFILER   = "RPM_EnableProfilerDuringMonitor";
    private const string PREF_ENABLE_INTERRUPT  = "RPM_EnableInterrupt";

    // ─── GUIStyle 缓存 ───────────────────────────────────────
    private GUIStyle greenLabelStyle;
    private GUIStyle redLabelStyle;
    private GUIStyle monitoringLabelStyle;
    private GUIStyle logEntryStyle;
    private bool stylesInitialized = false;

    [MenuItem("TATools/VFXTools/运行时性能阈值监测")]
    public static void ShowWindow()
    {
        GetWindow<RuntimePerfMonitor>("运行时性能阈值监测");
    }

    // ─── 生命周期 ─────────────────────────────────────────────

    void OnEnable()
    {
        LoadPrefs();
        EditorApplication.playModeStateChanged += OnPlayModeChanged;
    }

    void OnDisable()
    {
        SavePrefs();
        EditorApplication.playModeStateChanged -= OnPlayModeChanged;
        StopMonitoring();
    }

    void OnPlayModeChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.ExitingPlayMode)
        {
            StopMonitoring();
            Repaint();
        }
    }

    // ─── 配置持久化 ───────────────────────────────────────────

    void LoadPrefs()
    {
        enableFpsCheck     = EditorPrefs.GetBool(PREF_ENABLE_FPS, true);
        fpsLowerLimit      = EditorPrefs.GetFloat(PREF_FPS_LOWER, 30f);
        enableBatchesCheck = EditorPrefs.GetBool(PREF_ENABLE_BATCHES, true);
        batchesUpperLimit  = EditorPrefs.GetInt(PREF_BATCHES_UPPER, 300);
        enableSetPassCheck = EditorPrefs.GetBool(PREF_ENABLE_SETPASS, true);
        setPassUpperLimit  = EditorPrefs.GetInt(PREF_SETPASS_UPPER, 200);
        enableTexMemCheck  = EditorPrefs.GetBool(PREF_ENABLE_TEXMEM, true);
        texMemUpperLimitMB = EditorPrefs.GetFloat(PREF_TEXMEM_UPPER, 512f);
        enableProfilerDuringMonitor = EditorPrefs.GetBool(PREF_ENABLE_PROFILER, false);
        enableInterrupt             = EditorPrefs.GetBool(PREF_ENABLE_INTERRUPT, true);
    }

    void SavePrefs()
    {
        EditorPrefs.SetBool(PREF_ENABLE_FPS, enableFpsCheck);
        EditorPrefs.SetFloat(PREF_FPS_LOWER, fpsLowerLimit);
        EditorPrefs.SetBool(PREF_ENABLE_BATCHES, enableBatchesCheck);
        EditorPrefs.SetInt(PREF_BATCHES_UPPER, batchesUpperLimit);
        EditorPrefs.SetBool(PREF_ENABLE_SETPASS, enableSetPassCheck);
        EditorPrefs.SetInt(PREF_SETPASS_UPPER, setPassUpperLimit);
        EditorPrefs.SetBool(PREF_ENABLE_TEXMEM, enableTexMemCheck);
        EditorPrefs.SetFloat(PREF_TEXMEM_UPPER, texMemUpperLimitMB);
        EditorPrefs.SetBool(PREF_ENABLE_PROFILER, enableProfilerDuringMonitor);
        EditorPrefs.SetBool(PREF_ENABLE_INTERRUPT, enableInterrupt);
    }

    // ─── GUIStyle 初始化（必须在 OnGUI 内调用）─────────────────

    void InitStyles()
    {
        if (stylesInitialized) return;

        greenLabelStyle = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold,
            normal    = { textColor = new Color(0.18f, 0.78f, 0.18f) }
        };

        redLabelStyle = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold,
            normal    = { textColor = new Color(0.9f, 0.2f, 0.2f) }
        };

        monitoringLabelStyle = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold,
            normal    = { textColor = new Color(0.18f, 0.78f, 0.18f) }
        };

        logEntryStyle = new GUIStyle(EditorStyles.helpBox)
        {
            wordWrap  = true,
            richText  = false,
            fontSize  = 11
        };

        stylesInitialized = true;
    }

    // ─── OnGUI ────────────────────────────────────────────────

    void OnGUI()
    {
        InitStyles();

        GUILayout.Label("运行时性能阈值监测", EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        DrawThresholdConfig();
        EditorGUILayout.Space(4);

        DrawControls();
        EditorGUILayout.Space(4);

        DrawRealtimeData();
        EditorGUILayout.Space(4);

        DrawTriggerLog();
        DrawViolationSummary();
    }

    void DrawThresholdConfig()
    {
        showConfig = EditorGUILayout.Foldout(showConfig, "阈值配置", true, EditorStyles.foldoutHeader);
        if (!showConfig) return;

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUI.BeginChangeCheck();

        const float LABEL_WIDTH = 200f;
        const float FIELD_WIDTH = 80f;

        // FPS 下限
        EditorGUILayout.BeginHorizontal();
        enableFpsCheck = EditorGUILayout.Toggle(enableFpsCheck, GUILayout.Width(16));
        EditorGUILayout.LabelField("FPS 下限（低于此值触发）", GUILayout.Width(LABEL_WIDTH));
        GUI.enabled = enableFpsCheck;
        fpsLowerLimit = EditorGUILayout.FloatField(fpsLowerLimit, GUILayout.Width(FIELD_WIDTH));
        GUI.enabled = true;
        EditorGUILayout.EndHorizontal();

        // Batches 上限
        EditorGUILayout.BeginHorizontal();
        enableBatchesCheck = EditorGUILayout.Toggle(enableBatchesCheck, GUILayout.Width(16));
        EditorGUILayout.LabelField("Batches 上限（超过此值触发）", GUILayout.Width(LABEL_WIDTH));
        GUI.enabled = enableBatchesCheck;
        batchesUpperLimit = EditorGUILayout.IntField(batchesUpperLimit, GUILayout.Width(FIELD_WIDTH));
        GUI.enabled = true;
        EditorGUILayout.EndHorizontal();

        // SetPass Calls 上限
        EditorGUILayout.BeginHorizontal();
        enableSetPassCheck = EditorGUILayout.Toggle(enableSetPassCheck, GUILayout.Width(16));
        EditorGUILayout.LabelField("SetPass Calls 上限（超过此值触发）", GUILayout.Width(LABEL_WIDTH));
        GUI.enabled = enableSetPassCheck;
        setPassUpperLimit = EditorGUILayout.IntField(setPassUpperLimit, GUILayout.Width(FIELD_WIDTH));
        GUI.enabled = true;
        EditorGUILayout.EndHorizontal();

        // Texture2D 内存上限
        EditorGUILayout.BeginHorizontal();
        enableTexMemCheck = EditorGUILayout.Toggle(enableTexMemCheck, GUILayout.Width(16));
        EditorGUILayout.LabelField("Texture2D 内存 MB 上限（超过触发）", GUILayout.Width(LABEL_WIDTH));
        GUI.enabled = enableTexMemCheck;
        texMemUpperLimitMB = EditorGUILayout.FloatField(texMemUpperLimitMB, GUILayout.Width(FIELD_WIDTH));
        GUI.enabled = true;
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(4);
        EditorGUILayout.BeginHorizontal();
        enableProfilerDuringMonitor = EditorGUILayout.Toggle(enableProfilerDuringMonitor, GUILayout.Width(16));
        EditorGUILayout.LabelField("监控期间同步启用 Profiler 录制", GUILayout.Width(LABEL_WIDTH));
        EditorGUILayout.EndHorizontal();
        if (enableProfilerDuringMonitor)
            EditorGUILayout.HelpBox("注意：Profiler 会引入额外开销（典型 5~15% FPS 下降），可能导致 FPS 阈值误报。建议确认阈值时将 FPS 下限适当降低。", MessageType.Warning);

        EditorGUILayout.Space(4);
        EditorGUILayout.BeginHorizontal();
        enableInterrupt = EditorGUILayout.Toggle(enableInterrupt, GUILayout.Width(16));
        EditorGUILayout.LabelField("触发阈值时暂停游戏", GUILayout.Width(LABEL_WIDTH + FIELD_WIDTH));
        EditorGUILayout.EndHorizontal();
        if (!enableInterrupt)
            EditorGUILayout.HelpBox("非阻断模式：监控期间持续记录违规帧数据，停止监控后显示统计汇总，游戏不会被中断。", MessageType.Info);

        if (EditorGUI.EndChangeCheck())
            SavePrefs();

        EditorGUILayout.EndVertical();
    }

    void DrawControls()
    {
        EditorGUILayout.BeginHorizontal();

        if (!isMonitoring)
        {
            GUI.enabled = EditorApplication.isPlaying;
            if (GUILayout.Button("开始监控", GUILayout.Height(26)))
            {
                texMemFrameCounter = 0;
                fpsViolationCount = 0;
                batchesViolationCount = 0;
                setPassViolationCount = 0;
                texMemViolationCount = 0;
                showViolationSummary = false;
                lastViolationLogTime = -999f;
                isMonitoring = true;
                if (enableProfilerDuringMonitor)
                {
                    // 开启 Profiler 录制（会引入额外开销，见配置项说明）
                    Profiler.enabled = true;
                    EditorApplication.ExecuteMenuItem("Window/Analysis/Profiler");
                }
                EditorApplication.update += UpdateMonitoring;
            }
            GUI.enabled = true;
        }
        else
        {
            if (GUILayout.Button("停止监控", GUILayout.Height(26)))
                StopMonitoring();
        }

        if (GUILayout.Button("清除日志", GUILayout.Height(26), GUILayout.Width(80)))
            triggerLog.Clear();

        EditorGUILayout.EndHorizontal();

        if (!EditorApplication.isPlaying)
            EditorGUILayout.HelpBox("请进入 PlayMode 后再开始监控。", MessageType.Info);
        else if (isMonitoring)
            EditorGUILayout.LabelField("● 监控中...", monitoringLabelStyle);
        else
            EditorGUILayout.LabelField("● 已停止", EditorStyles.miniLabel);
    }

    void DrawRealtimeData()
    {
        EditorGUILayout.LabelField("实时性能数据", EditorStyles.boldLabel);

        if (!EditorApplication.isPlaying)
        {
            EditorGUILayout.LabelField("— 非 PlayMode，无数据 —", EditorStyles.centeredGreyMiniLabel);
            return;
        }

        bool fpsViolated     = enableFpsCheck     && currentFps      < fpsLowerLimit;
        bool batchesViolated = enableBatchesCheck && currentBatches   > batchesUpperLimit;
        bool setPassViolated = enableSetPassCheck && currentSetPass   > setPassUpperLimit;
        bool texMemViolated  = enableTexMemCheck  && currentTexMemMB  > texMemUpperLimitMB;

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        DrawMetricRow("FPS",             $"{currentFps:F1}",          $"下限: {fpsLowerLimit}",           fpsViolated);
        DrawMetricRow("Batches",         $"{currentBatches}",          $"上限: {batchesUpperLimit}",        batchesViolated);
        DrawMetricRow("SetPass Calls",   $"{currentSetPass}",          $"上限: {setPassUpperLimit}",        setPassViolated);
        DrawMetricRow("Texture2D 内存",  $"{currentTexMemMB:F2} MB",  $"上限: {texMemUpperLimitMB} MB",    texMemViolated);
        EditorGUILayout.EndVertical();
    }

    void DrawMetricRow(string label, string valueStr, string limitStr, bool violated)
    {
        GUIStyle style = violated ? redLabelStyle : greenLabelStyle;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(label + ":", GUILayout.Width(120));
        EditorGUILayout.LabelField(valueStr, style, GUILayout.Width(100));
        EditorGUILayout.LabelField(limitStr, EditorStyles.miniLabel);
        EditorGUILayout.EndHorizontal();
    }

    void DrawTriggerLog()
    {
        EditorGUILayout.LabelField($"触发日志（{triggerLog.Count} 条）", EditorStyles.boldLabel);

        if (triggerLog.Count == 0)
        {
            EditorGUILayout.LabelField("暂无触发记录。", EditorStyles.centeredGreyMiniLabel);
            return;
        }

        float logAreaHeight = Mathf.Clamp(triggerLog.Count * 72f, 80f, 260f);
        logScrollPos = EditorGUILayout.BeginScrollView(logScrollPos, GUILayout.Height(logAreaHeight));

        for (int i = triggerLog.Count - 1; i >= 0; i--)
        {
            EditorGUILayout.LabelField(triggerLog[i], logEntryStyle);
        }

        EditorGUILayout.EndScrollView();
    }

    void DrawViolationSummary()
    {
        if (!showViolationSummary) return;

        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField("违规统计汇总（本次监控）", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        int total = fpsViolationCount + batchesViolationCount + setPassViolationCount + texMemViolationCount;
        EditorGUILayout.LabelField($"总违规帧次：{total}", EditorStyles.boldLabel);
        EditorGUILayout.Space(2);

        if (enableFpsCheck)
            EditorGUILayout.LabelField($"  FPS 低于下限 {fpsLowerLimit}：{fpsViolationCount} 帧");
        if (enableBatchesCheck)
            EditorGUILayout.LabelField($"  Batches 超上限 {batchesUpperLimit}：{batchesViolationCount} 帧");
        if (enableSetPassCheck)
            EditorGUILayout.LabelField($"  SetPass 超上限 {setPassUpperLimit}：{setPassViolationCount} 帧");
        if (enableTexMemCheck)
            EditorGUILayout.LabelField($"  Texture2D 内存超上限 {texMemUpperLimitMB} MB：{texMemViolationCount} 帧");

        EditorGUILayout.EndVertical();
    }

    // ─── 采集与检测 ───────────────────────────────────────────

    void StopMonitoring()
    {
        if (!isMonitoring) return;
        isMonitoring = false;
        EditorApplication.update -= UpdateMonitoring;
        // 若是本工具启用了 Profiler，停止监控时同步关闭，避免持续影响运行时性能
        if (enableProfilerDuringMonitor)
            Profiler.enabled = false;
        // 非阻断模式下，停止后展示统计汇总
        if (!enableInterrupt)
            showViolationSummary = true;
    }

    void UpdateMonitoring()
    {
        if (!EditorApplication.isPlaying || EditorApplication.isPaused || !isMonitoring)
            return;

        // 每帧采集：Batches / SetPass / FPS
        currentBatches = UnityEditor.UnityStats.batches;
        currentSetPass = UnityEditor.UnityStats.setPassCalls;
        currentFps     = Time.unscaledDeltaTime > 0f ? 1f / Time.unscaledDeltaTime : 999f;

        // 每 TEX_MEM_SAMPLE_INTERVAL 帧采集一次 Texture2D 内存（FindObjectsOfTypeAll 开销较大）
        texMemFrameCounter++;
        if (texMemFrameCounter >= TEX_MEM_SAMPLE_INTERVAL)
        {
            texMemFrameCounter = 0;
            currentTexMemMB = SampleTexture2DMemoryMB();
        }

        CheckThresholds();
        // 阻断模式监控期短，每帧刷新无妨；非阻断模式节流到 ≤10 fps，避免高频 Repaint 拖慢主线程
        if (enableInterrupt || Time.realtimeSinceStartup - lastRepaintTime >= 0.1f)
        {
            lastRepaintTime = Time.realtimeSinceStartup;
            Repaint();
        }
    }

    float SampleTexture2DMemoryMB()
    {
        long totalBytes = 0;
        Texture2D[] textures = Resources.FindObjectsOfTypeAll<Texture2D>();
        foreach (Texture2D tex in textures)
        {
            if (tex != null)
                totalBytes += Profiler.GetRuntimeMemorySizeLong(tex);
        }
        return totalBytes / (1024f * 1024f);
    }

    void CheckThresholds()
    {
        violationReasons.Clear(); // 复用列表，不产生 GC 分配

        if (enableFpsCheck     && currentFps      < fpsLowerLimit)
            violationReasons.Add($"FPS {currentFps:F1} 低于下限 {fpsLowerLimit}");
        if (enableBatchesCheck && currentBatches   > batchesUpperLimit)
            violationReasons.Add($"Batches {currentBatches} 超过上限 {batchesUpperLimit}");
        if (enableSetPassCheck && currentSetPass   > setPassUpperLimit)
            violationReasons.Add($"SetPass Calls {currentSetPass} 超过上限 {setPassUpperLimit}");
        if (enableTexMemCheck  && currentTexMemMB  > texMemUpperLimitMB)
            violationReasons.Add($"Texture2D 内存 {currentTexMemMB:F2}MB 超过上限 {texMemUpperLimitMB}MB");

        if (violationReasons.Count == 0) return;

        string timestamp  = DateTime.Now.ToString("HH:mm:ss");
        string reasonText = string.Join(" | ", violationReasons);
        string logEntry   = $"[帧 {Time.frameCount}]  {timestamp}\n"
                          + $"FPS: {currentFps:F1}  |  Batches: {currentBatches}  |  SetPass: {currentSetPass}  |  TexMem: {currentTexMemMB:F2}MB\n"
                          + $"触发原因: {reasonText}";

        if (enableInterrupt)
        {
            // 阻断模式：记录快照 → 停止监控 → 暂停 PlayMode → 打开 Frame Debugger / Profiler
            triggerLog.Add(logEntry);
            StopMonitoring();
            EditorApplication.isPaused = true;
            EnableFrameDebugger();
            EditorApplication.ExecuteMenuItem("Window/Analysis/Profiler");
        }
        else
        {
            // 非阻断模式：节流写入日志（每 VIOLATION_LOG_INTERVAL 秒最多一条），不中断游戏
            if (Time.realtimeSinceStartup - lastViolationLogTime >= VIOLATION_LOG_INTERVAL)
            {
                lastViolationLogTime = Time.realtimeSinceStartup;
                triggerLog.Add(logEntry);
            }
            // 无论是否写入日志，每帧均累加违规次数
            if (enableFpsCheck     && currentFps      < fpsLowerLimit)      fpsViolationCount++;
            if (enableBatchesCheck && currentBatches   > batchesUpperLimit)  batchesViolationCount++;
            if (enableSetPassCheck && currentSetPass   > setPassUpperLimit)  setPassViolationCount++;
            if (enableTexMemCheck  && currentTexMemMB  > texMemUpperLimitMB) texMemViolationCount++;
        }
    }

    void EnableFrameDebugger()
    {
        // 先打开 Frame Debugger 窗口
        EditorApplication.ExecuteMenuItem("Window/Analysis/Frame Debugger");

        // 通过反射将 FrameDebuggerUtility.locallyEnabled 设为 true（Unity 2022.1 有效）
        try
        {
            Type fdType = Type.GetType("UnityEditorInternal.FrameDebuggerUtility, UnityEditor");
            if (fdType == null)
            {
                Debug.LogWarning("[RuntimePerfMonitor] 未找到 FrameDebuggerUtility 类型，Frame Debugger 窗口已打开但未自动启用。");
                return;
            }

            // Unity 2022 使用 locallyEnabled；更早版本使用 enabled 作为回退
            PropertyInfo prop = fdType.GetProperty(
                "locallyEnabled",
                BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);

            if (prop == null)
            {
                prop = fdType.GetProperty(
                    "enabled",
                    BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
            }

            if (prop != null)
                prop.SetValue(null, true);
            else
                Debug.LogWarning("[RuntimePerfMonitor] 未找到 FrameDebuggerUtility 的启用属性，Frame Debugger 已打开但未自动启用。");
        }
        catch (Exception e)
        {
            Debug.LogWarning($"[RuntimePerfMonitor] Frame Debugger 反射启用失败: {e.Message}");
        }
    }
}
#endif
