using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace Game.Editor.VFXTools.Recording.ParticleRecorder
{
// ── Play Mode 状态监听（跨 Domain Reload 存活）────────────────────────────────
[InitializeOnLoad]
public static class ParticleRecorderPlayModeWatcher
{
    static ParticleRecorderPlayModeWatcher()
    {
        EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
    }

    private static void OnPlayModeStateChanged(PlayModeStateChange state)
    {
        if (state != PlayModeStateChange.EnteredEditMode) return;
        if (!EditorPrefs.GetBool(ParticleRecorderRuntime.KeyIsRecording, false)) return;

        EditorPrefs.SetBool(ParticleRecorderRuntime.KeyIsRecording, false);

        string tempScene        = EditorPrefs.GetString(ParticleRecorderRuntime.KeyTempScene,          "");
        string origScene        = EditorPrefs.GetString(ParticleRecorderRuntime.KeyOrigScene,          "");
        string exportPath       = EditorPrefs.GetString(ParticleRecorderRuntime.KeyExportPath,         "");
        string prefabName       = EditorPrefs.GetString(ParticleRecorderRuntime.KeyPrefabName,         "");
        int    frameWidth       = EditorPrefs.GetInt   (ParticleRecorderRuntime.KeyWidth,              512);
        int    frameHeight      = EditorPrefs.GetInt   (ParticleRecorderRuntime.KeyHeight,             512);
        string templatePath     = EditorPrefs.GetString(ParticleRecorderRuntime.KeyTemplatePrefabPath, "");
        string prefabOutPath    = EditorPrefs.GetString(ParticleRecorderRuntime.KeyPrefabOutPath,      "");
        string matOutPath       = EditorPrefs.GetString(ParticleRecorderRuntime.KeyMatOutPath,         "");
        string tempSourcePrefab = EditorPrefs.GetString(ParticleRecorderRuntime.KeyTempSourcePrefab,   "");
        float  duration         = EditorPrefs.GetFloat(ParticleRecorderRuntime.KeyDuration, 2f);
        int    totalFrames      = Mathf.CeilToInt(
            duration *
            EditorPrefs.GetInt  (ParticleRecorderRuntime.KeyFrameRate, 25));
        int cols = Mathf.CeilToInt(Mathf.Sqrt(totalFrames));
        int rows = Mathf.CeilToInt((float)totalFrames / cols);

        // ── 删除临时场景资源 ──────────────────────────────────────────────
        if (!string.IsNullOrEmpty(tempScene) && File.Exists(tempScene))
            AssetDatabase.DeleteAsset(tempScene);
        if (!string.IsNullOrEmpty(tempSourcePrefab) && File.Exists(tempSourcePrefab))
            AssetDatabase.DeleteAsset(tempSourcePrefab);

        // ── 恢复原始场景 ──────────────────────────────────────────────────
        if (!string.IsNullOrEmpty(origScene) && File.Exists(origScene))
            EditorSceneManager.OpenScene(origScene);
        else
            EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // ── 合成图集 ──────────────────────────────────────────────────────
        string framesDir   = Path.Combine(exportPath, prefabName);
        string atlasPath   = Path.Combine(exportPath, $"{prefabName}_atlas.png");
        string atlasResult = AtlasGenerator.Generate(framesDir, atlasPath, frameWidth, frameHeight);

        // ── 生成预制体（需设置样板预制体）────────────────────────────────
        string prefabResult = null;
        if (atlasResult != null && !string.IsNullOrEmpty(templatePath))
        {
            AssetDatabase.Refresh();
            prefabResult = PrefabGenerator.Generate(
                templatePath, atlasResult, prefabOutPath, matOutPath, prefabName, cols, rows, duration);
        }

        // ── 更新窗口状态 ──────────────────────────────────────────────────
        string resultMsg;
        if (prefabResult != null)
            resultMsg = $"录制完成 ✓   预制体：{prefabResult}   图集：{atlasResult}";
        else if (atlasResult != null)
            resultMsg = $"录制完成 ✓   图集：{atlasResult}";
        else
            resultMsg = "录制完成（图集合成失败，请查看 Console）";
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyRecordingResult, resultMsg);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastPrefabResult, prefabResult ?? "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastAtlasResult, atlasResult ?? "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastOutputDir, exportPath);

        // ── 在项目视窗中定位生成的文件 ──────────────────────────────────
        if (prefabResult != null)
        {
            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(prefabResult);
            if (asset != null)
                EditorGUIUtility.PingObject(asset);
        }
        else if (atlasResult != null)
        {
            AssetDatabase.Refresh();
            string dataPath  = Application.dataPath.Replace('\\', '/');
            string atlasNorm = System.IO.Path.GetFullPath(atlasResult).Replace('\\', '/');
            if (atlasNorm.StartsWith(dataPath, System.StringComparison.OrdinalIgnoreCase))
            {
                string atlasAssetPath = "Assets" + atlasNorm.Substring(dataPath.Length);
                var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(atlasAssetPath);
                if (asset != null)
                    EditorGUIUtility.PingObject(asset);
            }
        }
    }
}

// ── 编辑器窗口 ─────────────────────────────────────────────────────────────────
/// <summary>
/// 粒子序列帧录制器编辑器窗口。通过 TATools > 粒子序列帧录制器 打开。
/// </summary>
public class ParticleRecorderWindow : EditorWindow
{
    private const string TempScenePath = "Assets/_ParticleRecorderTemp.unity";
    private const string TempSourcePrefabPath = "Assets/_ParticleRecorderSourceTemp.prefab";
    private const string DefaultTemplatePrefabPath = "Assets/Editor/VFXTools/Recording/ParticleRecorder/ARec Sample.prefab";
    private const string DefaultSeqRelativePath = "RecordedParticles/Frames";
    private const string DefaultPrefabRelativePath = "RecordedParticles/Prefabs";
    private const string DefaultMatRelativePath = "RecordedParticles/Materials";

    // ── 持久化键（界面设置）────────────────────────────────────────────────
    private const string PrefFrameRate      = "PR_Pref_FrameRate";
    private const string PrefDuration       = "PR_Pref_Duration";
    private const string PrefOrthoSize      = "PR_Pref_OrthoSize";
    private const string PrefResolution     = "PR_Pref_Resolution";
    private const string PrefSeqExportPath  = "PR_Pref_SeqExportPath";
    private const string PrefPrefabOutPath  = "PR_Pref_PrefabOutPath";
    private const string PrefMatOutPath     = "PR_Pref_MatOutPath";
    private const string PrefFastRecord     = "PR_Pref_FastRecord";

    private enum FrameResolution
    {
        [UnityEngine.InspectorName("64 × 64")]    _64   = 64,
        [UnityEngine.InspectorName("128 × 128")]  _128  = 128,
        [UnityEngine.InspectorName("256 × 256")]  _256  = 256,
        [UnityEngine.InspectorName("512 × 512")]  _512  = 512,
        [UnityEngine.InspectorName("1024 × 1024")] _1024 = 1024,
    }

    // ── 界面字段 ─────────────────────────────────────────────────────────
    private GameObject   prefabToRecord;      // 需要录制的特效预制体
    private GameObject   prefabTemplate;      // 空特效样板预制体（用于后续生成）
    private int          frameRate   = 25;    // 导出帧率
    private float        duration    = 2f;    // 录制时长（秒）
    private FrameResolution resolution = FrameResolution._512;  // 单帧分辨率
    private float        orthoSize   = 3f;    // 正交摄像机半高（世界单位）
    private string     seqPath     = "";    // 序列帧输出路径
    private string     prefabPath  = "";    // 预制体输出路径
    private string     matPath     = "";    // 材质输出路径
    private bool       fastRecord  = true;  // 启用快速录制（编辑模式下录制）

    // ── 滚动视图 / 预览 ───────────────────────────────────────────────
    private Vector2    scroll;
    private GameObject previewInstance;    // 预览实例（在当前场景中）
    private bool       pendingContextConfirmation;
    private string     pendingContextSourceLabel;

    [MenuItem("TATools/VFXTools/Recording/粒子序列帧录制")]
    public static void ShowWindow()
    {
        OpenWindow();
    }

    [MenuItem("Assets/转换为序列帧特效", false, 1000)]
    private static void ConvertSelectedPrefabAsset()
    {
        StartContextConversion(Selection.activeObject as GameObject);
    }

    [MenuItem("Assets/转换为序列帧特效", true)]
    private static bool ValidateConvertSelectedPrefabAsset()
    {
        var go = Selection.activeObject as GameObject;
        if (go == null) return false;
        string path = AssetDatabase.GetAssetPath(go);
        return !string.IsNullOrEmpty(path) && path.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase);
    }

    [MenuItem("GameObject/转换为序列帧特效", false, 49)]
    private static void ConvertSelectedSceneObject(MenuCommand command)
    {
        StartContextConversion(command.context as GameObject ?? Selection.activeGameObject);
    }

    [MenuItem("GameObject/转换为序列帧特效", true)]
    private static bool ValidateConvertSelectedSceneObject()
    {
        return Selection.activeGameObject != null;
    }

    private static ParticleRecorderWindow OpenWindow()
    {
        var win = GetWindow<ParticleRecorderWindow>("粒子录制器");
        win.minSize = new Vector2(340, 400);
        return win;
    }

    private static void StartContextConversion(GameObject source)
    {
        if (source == null) return;
        if (!ContainsParticleSystem(source))
        {
            EditorUtility.DisplayDialog("无法转换预制体", "选择的对象不包含 ParticleSystem，无法转换。", "确定");
            return;
        }

        var win = OpenWindow();
        win.ConfigureContextConversion(source);
    }

    // ── 生命周期 ────────────────────────────────────────────────────────────
    private void OnEnable()
    {
        frameRate  = EditorPrefs.GetInt   (PrefFrameRate,  25);
        duration   = EditorPrefs.GetFloat (PrefDuration,   2f);
        orthoSize  = EditorPrefs.GetFloat (PrefOrthoSize,  3f);
        resolution = (FrameResolution)EditorPrefs.GetInt(PrefResolution, (int)FrameResolution._512);
        seqPath    = EditorPrefs.GetString(PrefSeqExportPath, GetDefaultSeqPath());
        prefabPath = EditorPrefs.GetString(PrefPrefabOutPath, GetDefaultPrefabPath());
        matPath    = EditorPrefs.GetString(PrefMatOutPath, GetDefaultMatPath());
        fastRecord = EditorPrefs.GetBool  (PrefFastRecord,  true);
        prefabTemplate = AssetDatabase.LoadAssetAtPath<GameObject>(DefaultTemplatePrefabPath);
        SceneView.duringSceneGui += OnSceneGUI;
    }

    private void OnDisable()
    {
        SavePrefs();
        SceneView.duringSceneGui -= OnSceneGUI;
        ClearPreview();
    }

    // ── 定期刷新（录制 / Play Mode 中保持 UI 响应）────────────────────────────
    private void Update()
    {
        if (Application.isPlaying || EditorPrefs.GetBool(ParticleRecorderRuntime.KeyIsRecording, false))
            Repaint();
    }

    private void SavePrefs()
    {
        EditorPrefs.SetInt   (PrefFrameRate,     frameRate);
        EditorPrefs.SetFloat (PrefDuration,      duration);
        EditorPrefs.SetFloat (PrefOrthoSize,     orthoSize);
        EditorPrefs.SetInt   (PrefResolution,    (int)resolution);
        EditorPrefs.SetString(PrefSeqExportPath, seqPath);
        EditorPrefs.SetString(PrefPrefabOutPath, prefabPath);
        EditorPrefs.SetString(PrefMatOutPath,     matPath);
        EditorPrefs.SetBool  (PrefFastRecord,     fastRecord);
    }

    // ── 绘制 ────────────────────────────────────────────────────────────────
    private void OnGUI()
    {
        scroll = EditorGUILayout.BeginScrollView(scroll);

        // ── 标题 ────────────────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        GUILayout.Label("粒子序列帧录制器", EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        // ── 预制体（可拖入或点选）───────────────────────────────────────────
        DrawSectionHeader("预制体");
        prefabToRecord = (GameObject)EditorGUILayout.ObjectField(
            new GUIContent("需要转换的特效", "需要录制的粒子系统预制体或场景对象，拖入或点击右侧按钮选择"),
            prefabToRecord, typeof(GameObject), true);

        prefabTemplate = (GameObject)EditorGUILayout.ObjectField(
            new GUIContent("样板预制体", "不填只生成图集；填写后会额外生成带序列帧材质的特效预制体"),
            prefabTemplate, typeof(GameObject), false);
        EditorGUILayout.HelpBox("样板预制体为空时只生成图集；需要自动生成特效预制体时请保留或指定样板预制体。", MessageType.Info);

        // ── 录制参数 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("录制参数");

        frameRate = Mathf.Max(1,    EditorGUILayout.IntField  (new GUIContent("导出帧率（fps）"),   frameRate));
        duration  = Mathf.Max(0.1f, EditorGUILayout.FloatField(new GUIContent("录制时长（秒）"),    duration));

        DrawExportEstimate();

        // ── 分辨率与摄像机 ───────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("单帧分辨率与摄像机");

        resolution = (FrameResolution)EditorGUILayout.EnumPopup(
            new GUIContent("单帧分辨率", "序列帧宽高，均为正方形 POT 尺寸"), resolution);
        orthoSize = Mathf.Max(0.1f, EditorGUILayout.FloatField(
                        new GUIContent("录制范围(摄像机大小)", "调整以适配粒子效果的空间范围"), orthoSize));

        bool hasPreviewing = previewInstance != null;
        EditorGUI.BeginDisabledGroup(prefabToRecord == null || Application.isPlaying);
        if (hasPreviewing)
        {
            Color oldBackgroundColor = GUI.backgroundColor;
            GUI.backgroundColor = new Color(1f, 0.35f, 0.35f);
            if (GUILayout.Button("清除预览", GUILayout.Height(32)))
                ClearPreview();
            GUI.backgroundColor = oldBackgroundColor;
        }
        else
        {
            if (GUILayout.Button("预览效果", GUILayout.Height(32)))
                CreatePreviewInstance(prefabToRecord);
        }
        EditorGUI.EndDisabledGroup();

        if (pendingContextConfirmation && previewInstance != null)
            DrawContextPreviewConfirmation();

        // ── 输出路径 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("输出路径");

        DrawPathField("序列帧输出路径", ref seqPath, GetDefaultSeqPath());
        DrawPathField("预制体输出路径", ref prefabPath, GetDefaultPrefabPath());
        DrawPathField("材质输出路径",   ref matPath, GetDefaultMatPath());

        // ── 操作按钮 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(10);
        bool busy = Application.isPlaying || EditorPrefs.GetBool(ParticleRecorderRuntime.KeyIsRecording, false);

        // 验证所有输出路径必须在 Assets 目录内
        string dataPath   = Application.dataPath.Replace('\\', '/');
        bool   pathsValid = GetPathsOutsideAssetsError(dataPath) == null;
        string blockReason = GetStartBlockReason(busy, pathsValid, dataPath);

        fastRecord = EditorGUILayout.ToggleLeft(
            new GUIContent("启用快速录制（推荐）", "勾选后在编辑模式下直接模拟粒子并渲染，无需进入 Play Mode"),
            fastRecord);
        if (!fastRecord)
            EditorGUILayout.HelpBox("兼容模式会切换临时场景并进入 Play Mode，录制完成后再恢复原场景。", MessageType.Warning);
        if (!string.IsNullOrEmpty(blockReason))
            EditorGUILayout.HelpBox(blockReason, MessageType.Warning);

        EditorGUI.BeginDisabledGroup(!string.IsNullOrEmpty(blockReason));
        if (GUILayout.Button("开始录制", GUILayout.Height(36)))
        {
            SavePrefs();
            if (fastRecord)
                StartFastRecording();
            else
                StartRecording();
        }
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space(4);
        string result = EditorPrefs.GetString(ParticleRecorderRuntime.KeyRecordingResult, "");
        if (!string.IsNullOrEmpty(result))
        {
            MessageType resultType = result.Contains("失败") || result.Contains("取消") || result.Contains("中止")
                ? MessageType.Warning
                : MessageType.Info;
            EditorGUILayout.HelpBox(result, resultType);
            DrawResultActions();
        }

        if (!busy)
            DrawStepGuide(pathsValid);

        EditorGUILayout.Space(6);
        EditorGUILayout.EndScrollView();
    }

    // ── 预览：Scene 视图绘制录制范围框 ───────────────────────────────
    private void OnSceneGUI(SceneView sv)
    {
        if (previewInstance == null) return;

        float s  = orthoSize;
        var   tl = new Vector3(-s,  s, 0);
        var   tr = new Vector3( s,  s, 0);
        var   br = new Vector3( s, -s, 0);
        var   bl = new Vector3(-s, -s, 0);

        using (new UnityEditor.Handles.DrawingScope(new Color(0.2f, 1f, 0.5f, 0.9f)))
        {
            Handles.DrawLine(tl, tr, 2f);
            Handles.DrawLine(tr, br, 2f);
            Handles.DrawLine(br, bl, 2f);
            Handles.DrawLine(bl, tl, 2f);
        }

        // 标注尺寸
        Handles.color = new Color(0.2f, 1f, 0.5f, 0.9f);
        Handles.Label(tr + new Vector3(0.05f, 0.05f, 0),
            $"录制范围 {s * 2:F2} × {s * 2:F2} 世界单位",
            new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = new Color(0.2f, 1f, 0.5f) } });

        sv.Repaint();
    }

    private void ClearPreview()
    {
        DestroyPreviewInstance();
        pendingContextConfirmation = false;
        pendingContextSourceLabel = null;
    }

    private void DestroyPreviewInstance()
    {
        if (previewInstance != null)
        {
            DestroyImmediate(previewInstance);
            previewInstance = null;
        }
    }

    private void ConfigureContextConversion(GameObject source)
    {
        prefabToRecord = source;
        CreatePreviewInstance(source);
        pendingContextSourceLabel = source.name;
        pendingContextConfirmation = true;
        Repaint();
    }

    private void LoadPrefs()
    {
        frameRate  = EditorPrefs.GetInt   (PrefFrameRate,  25);
        duration   = EditorPrefs.GetFloat (PrefDuration,   2f);
        orthoSize  = EditorPrefs.GetFloat (PrefOrthoSize,  3f);
        resolution = (FrameResolution)EditorPrefs.GetInt(PrefResolution, (int)FrameResolution._512);
        seqPath    = EditorPrefs.GetString(PrefSeqExportPath, GetDefaultSeqPath());
        prefabPath = EditorPrefs.GetString(PrefPrefabOutPath, GetDefaultPrefabPath());
        matPath    = EditorPrefs.GetString(PrefMatOutPath, GetDefaultMatPath());
        fastRecord = EditorPrefs.GetBool  (PrefFastRecord,  true);
        if (prefabTemplate == null)
            prefabTemplate = AssetDatabase.LoadAssetAtPath<GameObject>(DefaultTemplatePrefabPath);
    }

    private void CreatePreviewInstance(GameObject source)
    {
        DestroyPreviewInstance();
        if (source == null) return;
        previewInstance = PrefabUtility.IsPartOfPrefabAsset(source)
            ? (GameObject)PrefabUtility.InstantiatePrefab(source)
            : Instantiate(source);
        previewInstance.name = "[Preview] " + source.name;
        previewInstance.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
        Selection.activeGameObject = previewInstance;
        SceneView.lastActiveSceneView?.FrameSelected();
    }

    private void DrawContextPreviewConfirmation()
    {
        EditorGUILayout.Space(6);
        DrawSectionHeader("右键转换确认");
        EditorGUILayout.HelpBox($"请在 Scene 视图确认录制范围。当前对象：{pendingContextSourceLabel}\n可调整「录制范围(摄像机大小)」，确认后会读取当前窗口配置开始转换。", MessageType.Info);
        string confirmBlockReason = GetContextConfirmBlockReason();
        if (!string.IsNullOrEmpty(confirmBlockReason))
            EditorGUILayout.HelpBox(confirmBlockReason, MessageType.Warning);
        EditorGUILayout.BeginHorizontal();
        EditorGUI.BeginDisabledGroup(!string.IsNullOrEmpty(confirmBlockReason));
        if (GUILayout.Button("确认并开始转换", GUILayout.Height(28)))
        {
            SavePrefs();
            pendingContextConfirmation = false;
            if (fastRecord)
                StartFastRecording();
            else
                StartRecording();
        }
        EditorGUI.EndDisabledGroup();
        if (GUILayout.Button("取消", GUILayout.Height(28)))
            ClearPreview();
        EditorGUILayout.EndHorizontal();
    }

    private string GetContextConfirmBlockReason()
    {
        bool busy = Application.isPlaying || EditorPrefs.GetBool(ParticleRecorderRuntime.KeyIsRecording, false);
        if (busy) return "当前正在 Play Mode 或录制中，无法开始新的录制。";
        if (prefabToRecord == null) return "请选择需要转换的特效预制体或场景对象。";
        if (!ContainsParticleSystem(prefabToRecord)) return "选择的对象不包含 ParticleSystem，无法转换。";

        string dataPath = Application.dataPath.Replace('\\', '/');
        string pathError = GetPathsOutsideAssetsError(dataPath);
        if (!string.IsNullOrEmpty(pathError)) return pathError;

        var missing = new System.Text.StringBuilder();
        CheckRequiredPath("序列帧输出路径", seqPath, missing);
        if (prefabTemplate != null)
        {
            CheckRequiredPath("预制体输出路径", prefabPath, missing);
            CheckRequiredPath("材质输出路径", matPath, missing);
        }
        return missing.Length > 0 ? "以下路径不能为空：\n" + missing : null;
    }

    private static bool ContainsParticleSystem(GameObject go)
    {
        return go != null && go.GetComponentInChildren<ParticleSystem>(true) != null;
    }

    private static string GetDefaultSeqPath()
    {
        return Path.GetFullPath(Path.Combine(Application.dataPath, DefaultSeqRelativePath));
    }

    private static string GetDefaultPrefabPath()
    {
        return Path.GetFullPath(Path.Combine(Application.dataPath, DefaultPrefabRelativePath));
    }

    private static string GetDefaultMatPath()
    {
        return Path.GetFullPath(Path.Combine(Application.dataPath, DefaultMatRelativePath));
    }

    private static string ToProjectRelativeDisplay(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) return "";
        string dataPath = Application.dataPath.Replace('\\', '/').TrimEnd('/');
        string norm = Path.GetFullPath(path).Replace('\\', '/').TrimEnd('/');
        return norm.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase)
            ? "Assets" + norm.Substring(dataPath.Length)
            : norm;
    }

    private static string NormalizePathInput(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) return "";
        string p = path.Replace('\\', '/');
        if (p.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase) || string.Equals(p, "Assets", StringComparison.OrdinalIgnoreCase))
            return Path.GetFullPath(Path.Combine(Application.dataPath, "..", p));
        return path;
    }

    private void DrawExportEstimate()
    {
        int totalFrames = Mathf.CeilToInt(frameRate * duration);
        int cols = Mathf.CeilToInt(Mathf.Sqrt(totalFrames));
        int rows = Mathf.CeilToInt((float)totalFrames / cols);
        int res = (int)resolution;
        int atlasW = cols * res;
        int atlasH = rows * res;

        EditorGUI.BeginDisabledGroup(true);
        EditorGUILayout.IntField(new GUIContent("预计总帧数"), totalFrames);
        EditorGUILayout.TextField(new GUIContent("预计图集"), $"{cols} × {rows}，{atlasW} × {atlasH}px");
        EditorGUI.EndDisabledGroup();

        if (atlasW > 8192 || atlasH > 8192)
            EditorGUILayout.HelpBox("预计图集尺寸超过 8192，导入或运行时可能失败。建议降低分辨率、帧率或时长。", MessageType.Error);
        else if (atlasW > 4096 || atlasH > 4096)
            EditorGUILayout.HelpBox("预计图集尺寸超过 4096，可能导出较慢并占用较多内存。", MessageType.Warning);
        else if (totalFrames > 100)
            EditorGUILayout.HelpBox("预计帧数较多，录制与合图可能需要较长时间。", MessageType.Info);
    }

    private string GetStartBlockReason(bool busy, bool pathsValid, string dataPath)
    {
        if (busy) return "当前正在 Play Mode 或录制中，无法开始新的录制。";
        if (pendingContextConfirmation) return "请先在右键转换确认区确认或取消当前预览。";
        if (prefabToRecord == null) return "请选择需要转换的特效预制体或场景对象。";
        if (!ContainsParticleSystem(prefabToRecord)) return "选择的对象不包含 ParticleSystem，无法转换。";
        var missing = new System.Text.StringBuilder();
        CheckRequiredPath("序列帧输出路径", seqPath, missing);
        if (prefabTemplate != null)
        {
            CheckRequiredPath("预制体输出路径", prefabPath, missing);
            CheckRequiredPath("材质输出路径", matPath, missing);
        }
        if (missing.Length > 0)
            return "以下路径不能为空：\n" + missing;
        if (!pathsValid)
            return GetPathsOutsideAssetsError(dataPath);
        return null;
    }

    private static void CheckRequiredPath(string label, string path, System.Text.StringBuilder errors)
    {
        if (string.IsNullOrWhiteSpace(path))
            errors.AppendLine($"• {label}");
    }

    private void DrawResultActions()
    {
        string prefabResult = EditorPrefs.GetString(ParticleRecorderRuntime.KeyLastPrefabResult, "");
        string atlasResult = EditorPrefs.GetString(ParticleRecorderRuntime.KeyLastAtlasResult, "");
        string outputDir = EditorPrefs.GetString(ParticleRecorderRuntime.KeyLastOutputDir, "");
        if (string.IsNullOrEmpty(prefabResult) && string.IsNullOrEmpty(atlasResult) && string.IsNullOrEmpty(outputDir))
            return;

        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField("结果操作", EditorStyles.boldLabel);
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(prefabResult));
                if (GUILayout.Button("定位预制体"))
                    PingAsset(prefabResult);
                EditorGUI.EndDisabledGroup();

                EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(atlasResult));
                if (GUILayout.Button("定位图集"))
                    PingAsset(atlasResult);
                EditorGUI.EndDisabledGroup();
            }

            EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(outputDir));
            if (GUILayout.Button("打开输出目录"))
                EditorUtility.RevealInFinder(outputDir);
            EditorGUI.EndDisabledGroup();
        }
    }

    private static void PingAsset(string path)
    {
        AssetDatabase.Refresh();
        string assetPath = ToAssetPath(path);
        if (string.IsNullOrEmpty(assetPath)) return;
        var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (asset != null)
            EditorGUIUtility.PingObject(asset);
    }

    private static string ToAssetPath(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) return null;
        string norm = Path.GetFullPath(path).Replace('\\', '/');
        string dataPath = Application.dataPath.Replace('\\', '/');
        if (norm.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase))
            return "Assets" + norm.Substring(dataPath.Length);
        return path.Replace('\\', '/').StartsWith("Assets/", StringComparison.OrdinalIgnoreCase)
            ? path.Replace('\\', '/')
            : null;
    }

    // ── 辅助：操作步骤引导（彩色文字）──────────────────────────────────
    private void DrawStepGuide(bool pathsValid)
    {
        var style = new GUIStyle(EditorStyles.label)
        {
            richText = true,
            wordWrap = true,
            fontSize = 12,
            padding  = new RectOffset(4, 4, 6, 6)
        };

        bool step1Done = prefabToRecord != null;
        bool step2Done = prefabTemplate != null;
        bool step3Done = frameRate >= 1 && duration >= 0.1f;
        bool step4Done = pathsValid
            && !string.IsNullOrWhiteSpace(seqPath)
            && (prefabTemplate == null
                || (!string.IsNullOrWhiteSpace(prefabPath) && !string.IsNullOrWhiteSpace(matPath)));

        // 步骤 4 的颜色：有路径填写但不合法 → 红；合法 → 绿；未填写 → 灰
        bool anyPath  = !string.IsNullOrWhiteSpace(seqPath)
                     || !string.IsNullOrWhiteSpace(prefabPath)
                     || !string.IsNullOrWhiteSpace(matPath);
        string c4 = anyPath && !pathsValid ? "#E57373"
                  : step4Done             ? "#66BB6A"
                  :                         "#888888";

        string c1 = step1Done ? "#66BB6A" : "#888888";
        string c2 = step2Done ? "#66BB6A" : "#AAAAAA";
        string c3 = step3Done ? "#66BB6A" : "#888888";

        string m1 = step1Done ? "●" : "○";
        string m2 = step2Done ? "●" : "○";
        string m3 = step3Done ? "●" : "○";
        string m4 = anyPath && !pathsValid ? "✗" : (step4Done ? "●" : "○");

        var sb = new System.Text.StringBuilder();
        sb.AppendLine($"<color={c1}>{m1} 步骤 1：选择「录制特效预制体」</color>");
        sb.AppendLine($"<color={c2}>{m2} 步骤 2：设置「样板预制体」以自动生成序列帧预制体；不填则只生成图集</color>");
        sb.AppendLine($"<color={c3}>{m3} 步骤 3：设置导出帧率（当前 {frameRate} fps）和录制时长（当前 {duration:F1} 秒）</color>");
        sb.Append    ($"<color={c4}>{m4} 步骤 4：将各「输出路径」设置到项目 Assets 目录内</color>");

        if (anyPath && !pathsValid)
        {
            // 列出不合法的路径名（复用 GetPathsOutsideAssetsError 的检查逻辑）
            string dataPath = Application.dataPath.Replace('\\', '/');
            var   errs      = new System.Text.StringBuilder();
            CheckPath("序列帧输出路径", seqPath,    dataPath, errs);
            CheckPath("预制体输出路径", prefabPath, dataPath, errs);
            CheckPath("材质输出路径",   matPath,    dataPath, errs);
            if (errs.Length > 0)
                sb.Append($"\n<color=#E57373>{errs.ToString().TrimEnd()}</color>");
        }

        if (step1Done && step3Done && step4Done)
            sb.Append("\n\n<color=#66BB6A>✓ 准备就绪，点击「开始录制」即可！</color>");

        GUILayout.Label(sb.ToString(), style);
    }

    // ── 辅助：检查所有输出路径是否均在 Assets 目录内 ─────────────────────
    private string GetPathsOutsideAssetsError(string dataPath)
    {
        var errors = new System.Text.StringBuilder();
        CheckPath("序列帧输出路径", seqPath,    dataPath, errors);
        CheckPath("预制体输出路径", prefabPath, dataPath, errors);
        CheckPath("材质输出路径",   matPath,    dataPath, errors);
        return errors.Length > 0
            ? "以下路径不在项目 Assets 目录内，无法开始录制：\n" + errors
            : null;
    }

    private static void CheckPath(string label, string path, string dataPath,
                                   System.Text.StringBuilder errors)
    {
        if (string.IsNullOrWhiteSpace(path)) return;
        string norm = System.IO.Path.GetFullPath(path).Replace('\\', '/').TrimEnd('/');
        if (!norm.StartsWith(dataPath, System.StringComparison.OrdinalIgnoreCase))
            errors.AppendLine($"• {label}：{path}");
    }

    // ── 辅助：分区标题 ────────────────────────────────────────────────────
    private static void DrawSectionHeader(string label)
    {
        var style = new GUIStyle(EditorStyles.boldLabel) { fontSize = 11 };
        GUILayout.Label(label, style);
        Rect r = EditorGUILayout.GetControlRect(false, 1);
        EditorGUI.DrawRect(r, new Color(0.4f, 0.4f, 0.4f, 0.5f));
        EditorGUILayout.Space(2);
    }

    // ── 辅助：带「浏览」按钮的路径字段 ──────────────────────────────────
    private static void DrawPathField(string label, ref string path, string defaultPath)
    {
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUI.BeginChangeCheck();
            string editedPath = EditorGUILayout.TextField(new GUIContent(label), ToProjectRelativeDisplay(path));
            if (EditorGUI.EndChangeCheck())
                path = NormalizePathInput(editedPath);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("浏览", GUILayout.Width(64)))
            {
                string sel = EditorUtility.OpenFolderPanel("选择" + label, path, "");
                if (!string.IsNullOrEmpty(sel)) path = sel;
            }
            EditorGUI.BeginDisabledGroup(string.IsNullOrWhiteSpace(path));
            if (GUILayout.Button("打开", GUILayout.Width(64)))
                EditorUtility.RevealInFinder(path);
            EditorGUI.EndDisabledGroup();
            if (GUILayout.Button("重置", GUILayout.Width(64)))
                path = defaultPath;
            EditorGUILayout.EndHorizontal();
        }
    }

    // ── 录制流程 ──────────────────────────────────────────────────────────
    private void StartRecording()
    {
        if (prefabToRecord == null) return;
        if (prefabTemplate != null && !PrefabGenerator.ValidateTemplate(
                prefabTemplate, AssetDatabase.GetAssetPath(prefabTemplate)))
            return;
        if (!ContainsParticleSystem(prefabToRecord))
        {
            EditorUtility.DisplayDialog("无法转换预制体", "选择的对象不包含 ParticleSystem，无法转换。", "确定");
            return;
        }
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;

        string sourcePrefabPath = PrepareSourcePrefabAsset(prefabToRecord);
        if (string.IsNullOrEmpty(sourcePrefabPath)) return;
        string origScene = EditorSceneManager.GetActiveScene().path;

        // 将所有设置持久化（跨 Domain Reload 存活）
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyRecordingResult,    "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastPrefabResult, "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastAtlasResult, "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastOutputDir, seqPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyTemplatePrefabPath,
            prefabTemplate != null ? AssetDatabase.GetAssetPath(prefabTemplate) : "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyPrefabName,    prefabToRecord.name);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyExportPath,    seqPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyPrefabOutPath, prefabPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyMatOutPath,    matPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyOrigScene,     origScene);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyTempScene,     TempScenePath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyTempSourcePrefab,
            sourcePrefabPath == TempSourcePrefabPath ? TempSourcePrefabPath : "");
        EditorPrefs.SetInt   (ParticleRecorderRuntime.KeyFrameRate,     frameRate);
        EditorPrefs.SetFloat (ParticleRecorderRuntime.KeyDuration,      duration);
        EditorPrefs.SetInt   (ParticleRecorderRuntime.KeyWidth,         (int)resolution);
        EditorPrefs.SetInt   (ParticleRecorderRuntime.KeyHeight,        (int)resolution);

        // 清除预览对象及 Selection，防止 NewScene 销毁旧场景时触发
        // GameObjectInspector.OnEnable 对已销毁 GO 抛 SerializedObjectNotCreatableException
        ClearPreview();
        Selection.activeObject = null;

        // 创建空白临时场景
        var tempScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        // 正交摄像机
        var cameraGO = new GameObject("RecordingCamera");
        var cam      = cameraGO.AddComponent<Camera>();
        cam.orthographic     = true;
        cam.orthographicSize = orthoSize;
        cam.clearFlags       = CameraClearFlags.SolidColor;
        cam.backgroundColor  = Color.black;
        cam.nearClipPlane    = 0.1f;
        cam.farClipPlane     = 100f;
        cam.cullingMask      = -1;
        cam.tag              = "MainCamera";
        cameraGO.transform.SetPositionAndRotation(new Vector3(0f, 0f, -10f), Quaternion.identity);

        // 预制体实例（对准世界原点）
        var sourcePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(sourcePrefabPath);
        var instance = (GameObject)PrefabUtility.InstantiatePrefab(sourcePrefab, tempScene);
        instance.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);

        // 录制器运行时组件
        new GameObject("_ParticleRecorderRuntime").AddComponent<ParticleRecorderRuntime>();

        // 保存临时场景并进入 Play Mode
        EditorSceneManager.SaveScene(tempScene, TempScenePath);
        EditorPrefs.SetBool(ParticleRecorderRuntime.KeyIsRecording, true);
        EditorApplication.isPlaying = true;
    }

    private string PrepareSourcePrefabAsset(GameObject source)
    {
        if (PrefabUtility.IsPartOfPrefabAsset(source))
            return AssetDatabase.GetAssetPath(source);

        if (File.Exists(TempSourcePrefabPath))
            AssetDatabase.DeleteAsset(TempSourcePrefabPath);
        var tempPrefab = PrefabUtility.SaveAsPrefabAsset(source, TempSourcePrefabPath);
        AssetDatabase.ImportAsset(TempSourcePrefabPath, ImportAssetOptions.ForceUpdate);
        return tempPrefab != null ? TempSourcePrefabPath : null;
    }

    // ── 快速录制（编辑模式）──────────────────────────────────────────────────
    private void StartFastRecording()
    {
        if (prefabToRecord == null) return;
        if (prefabTemplate != null && !PrefabGenerator.ValidateTemplate(
                prefabTemplate, AssetDatabase.GetAssetPath(prefabTemplate)))
            return;
        if (!ContainsParticleSystem(prefabToRecord))
        {
            EditorUtility.DisplayDialog("无法转换预制体", "选择的对象不包含 ParticleSystem，无法转换。", "确定");
            return;
        }
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;

        string sourcePrefabPath = PrepareSourcePrefabAsset(prefabToRecord);
        if (string.IsNullOrEmpty(sourcePrefabPath)) return;
        string origScene   = EditorSceneManager.GetActiveScene().path;
        int    res         = (int)resolution;
        int    totalFrames = Mathf.CeilToInt(frameRate * duration);
        float  frameDelta  = 1f / frameRate;
        string prefabName  = prefabToRecord.name;

        ClearPreview();
        Selection.activeObject = null;

        var tempScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        // 正交摄像机
        var cameraGO = new GameObject("RecordingCamera");
        var cam      = cameraGO.AddComponent<Camera>();
        cam.orthographic     = true;
        cam.orthographicSize = orthoSize;
        cam.clearFlags       = CameraClearFlags.SolidColor;
        cam.nearClipPlane    = 0.1f;
        cam.farClipPlane     = 100f;
        cam.cullingMask      = -1;
        cam.enabled          = true;
        cam.targetTexture    = null;
        cameraGO.transform.SetPositionAndRotation(new Vector3(0f, 0f, -10f), Quaternion.identity);

        // URP 管线兼容：通过反射添加 UniversalAdditionalCameraData（如存在），
        // 否则 Camera.Render() 在 URP 项目中可能静默失败
        var urpCamDataType = Type.GetType(
            "UnityEngine.Rendering.Universal.UniversalAdditionalCameraData, Unity.RenderPipelines.Universal.Runtime");
        if (urpCamDataType != null && cameraGO.GetComponent(urpCamDataType) == null)
            cameraGO.AddComponent(urpCamDataType);

        // 预制体实例（对准世界原点）
        var sourcePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(sourcePrefabPath);
        var instance = (GameObject)PrefabUtility.InstantiatePrefab(sourcePrefab, tempScene);
        instance.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);

        // 预先缓存根级粒子系统（无祖先 PS 节点），后续增量模拟只对根节点调用一次
        var allPS      = instance.GetComponentsInChildren<ParticleSystem>(true);
        var rootPSList = new System.Collections.Generic.List<ParticleSystem>();
        foreach (var ps in allPS)
        {
            bool hasAncestorPS = false;
            for (Transform tr = ps.transform.parent; tr != null; tr = tr.parent)
            {
                if (tr.GetComponent<ParticleSystem>() != null) { hasAncestorPS = true; break; }
            }
            if (!hasAncestorPS)
                rootPSList.Add(ps);
        }

        // 停止并清空所有粒子系统，保证从干净状态启动
        foreach (var ps in allPS)
            ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);

        string realFolder = Path.Combine(seqPath, prefabName);
        if (!Directory.Exists(realFolder))
            Directory.CreateDirectory(realFolder);

        bool success = true;
        bool cancelled = false;
        string errorMessage = null;
        try
        {
            for (int i = 0; i < totalFrames; i++)
            {
                if (EditorUtility.DisplayCancelableProgressBar("快速录制中...",
                    $"正在捕捉第 {i + 1}/{totalFrames} 帧", (float)i / totalFrames))
                {
                    cancelled = true;
                    success = false;
                    break;
                }

                // 增量步进模拟：第 0 帧 restart:true 重置到初始状态，后续帧 restart:false 连续推进
                // 与编辑器粒子系统预览（Simulator）行为完全一致，确保播放时长与录制时长严格对应
                foreach (var ps in rootPSList)
                    ps.Simulate(frameDelta, withChildren: true, restart: i == 0);

                // 渲染黑底
                var blackRT = RenderTexture.GetTemporary(res, res, 24, RenderTextureFormat.ARGB32);
                RenderTexture.active = null;
                cam.targetTexture   = blackRT;
                cam.backgroundColor = Color.black;
                cam.Render();
                GL.Flush(); // 确保 GPU 完成当前帧后再读取像素
                RenderTexture.active = blackRT;
                var texBlack = new Texture2D(res, res, TextureFormat.ARGB32, false);
                texBlack.ReadPixels(new Rect(0, 0, res, res), 0, 0);
                texBlack.Apply();

                // 渲染白底
                var whiteRT = RenderTexture.GetTemporary(res, res, 24, RenderTextureFormat.ARGB32);
                RenderTexture.active = null;
                cam.targetTexture   = whiteRT;
                cam.backgroundColor = Color.white;
                cam.Render();
                GL.Flush();
                RenderTexture.active = whiteRT;
                var texWhite = new Texture2D(res, res, TextureFormat.ARGB32, false);
                texWhite.ReadPixels(new Rect(0, 0, res, res), 0, 0);
                texWhite.Apply();

                RenderTexture.active = null;
                cam.targetTexture    = null;
                RenderTexture.ReleaseTemporary(blackRT);
                RenderTexture.ReleaseTemporary(whiteRT);

                // 黑/白差值还原真实 Alpha 及颜色
                var output = new Texture2D(res, res, TextureFormat.ARGB32, false);
                for (int y = 0; y < res; y++)
                {
                    for (int x = 0; x < res; x++)
                    {
                        Color bb    = texBlack.GetPixel(x, y);
                        Color wb    = texWhite.GetPixel(x, y);
                        float diff  = Mathf.Min(wb.r - bb.r, wb.g - bb.g, wb.b - bb.b);
                        float alpha = Mathf.Clamp01(1f - diff);
                        Color col   = alpha < 1e-6f ? Color.clear
                                    : new Color(Mathf.Clamp01(bb.r / alpha),
                                                Mathf.Clamp01(bb.g / alpha),
                                                Mathf.Clamp01(bb.b / alpha), alpha);
                        output.SetPixel(x, y, col);
                    }
                }
                output.Apply();
                File.WriteAllBytes(Path.Combine(realFolder, $"{i:D4}.png"), output.EncodeToPNG());

                DestroyImmediate(texBlack);
                DestroyImmediate(texWhite);
                DestroyImmediate(output);
            }
            Debug.Log($"[ParticleRecorder] 快速录制完成，共 {totalFrames} 帧，已保存至：{realFolder}");
        }
        catch (Exception e)
        {
            Debug.LogError($"[ParticleRecorder] 快速录制出错：{e}");
            errorMessage = e.Message;
            success = false;
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            cam.targetTexture    = null;
            RenderTexture.active = null;
        }

        // 恢复原始场景
        if (!string.IsNullOrEmpty(origScene) && File.Exists(origScene))
            EditorSceneManager.OpenScene(origScene);
        else
            EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
        if (sourcePrefabPath == TempSourcePrefabPath && File.Exists(TempSourcePrefabPath))
            AssetDatabase.DeleteAsset(TempSourcePrefabPath);

        if (!success)
        {
            string failedResultMsg = cancelled
                ? "录制已取消。"
                : $"录制失败：{errorMessage}";
            EditorPrefs.SetString(ParticleRecorderRuntime.KeyRecordingResult, failedResultMsg);
            EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastPrefabResult, "");
            EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastAtlasResult, "");
            EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastOutputDir, seqPath);
            Repaint();
            return;
        }

        // 合成图集
        int    cols        = Mathf.CeilToInt(Mathf.Sqrt(totalFrames));
        int    rows        = Mathf.CeilToInt((float)totalFrames / cols);
        string atlasPath   = Path.Combine(seqPath, $"{prefabName}_atlas.png");
        string atlasResult = AtlasGenerator.Generate(realFolder, atlasPath, res, res);

        // 生成预制体
        string prefabResult      = null;
        string templateAssetPath = prefabTemplate != null ? AssetDatabase.GetAssetPath(prefabTemplate) : "";
        if (atlasResult != null && !string.IsNullOrEmpty(templateAssetPath))
        {
            AssetDatabase.Refresh();
            prefabResult = PrefabGenerator.Generate(
                templateAssetPath, atlasResult, prefabPath, matPath, prefabName, cols, rows, duration);
        }

        // 更新结果消息
        string resultMsg = prefabResult != null
            ? $"录制完成 ✓   预制体：{prefabResult}   图集：{atlasResult}"
            : atlasResult != null
            ? $"录制完成 ✓   图集：{atlasResult}"
            : "录制完成（图集合成失败，请查看 Console）";
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyRecordingResult, resultMsg);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastPrefabResult, prefabResult ?? "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastAtlasResult, atlasResult ?? "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyLastOutputDir, seqPath);

        // 在项目视窗中定位生成的文件
        if (prefabResult != null)
        {
            AssetDatabase.Refresh();
            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(prefabResult);
            if (asset != null) EditorGUIUtility.PingObject(asset);
        }
        else if (atlasResult != null)
        {
            AssetDatabase.Refresh();
            string dataPath2 = Application.dataPath.Replace('\\', '/');
            string atlasNorm = Path.GetFullPath(atlasResult).Replace('\\', '/');
            if (atlasNorm.StartsWith(dataPath2, StringComparison.OrdinalIgnoreCase))
            {
                string atlasAssetPath = "Assets" + atlasNorm.Substring(dataPath2.Length);
                var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(atlasAssetPath);
                if (asset != null) EditorGUIUtility.PingObject(asset);
            }
        }

        Repaint();
    }
}

// ── 图集生成 ─────────────────────────────────────────────────────────────────────────
/// <summary>
/// 将 PNG 序列帧合成为尽可能方正的 POT（二次幂）图集。
/// 帧排列顺序：从左到右、从上到下，行优先。
/// </summary>
public static class AtlasGenerator
{
    /// <summary>合成图集。</summary>
    /// <param name="framesDir">序列帧目录路径</param>
    /// <param name="outputPath">图集输出路径（含文件名，.png）</param>
    /// <param name="frameWidth">单帧宽度（px）</param>
    /// <param name="frameHeight">单帧高度（px）</param>
    /// <returns>实际写入的路径；若无帧或出错则返回 null</returns>
    public static string Generate(string framesDir, string outputPath, int frameWidth, int frameHeight)
    {
        if (!Directory.Exists(framesDir))
        {
            Debug.LogWarning($"[AtlasGenerator] 序列帧目录不存在：{framesDir}");
            return null;
        }

        string[] files = Directory.GetFiles(framesDir, "*.png");
        Array.Sort(files, StringComparer.OrdinalIgnoreCase);
        int n = files.Length;
        if (n == 0)
        {
            Debug.LogWarning($"[AtlasGenerator] 序列帧目录中没有 PNG 文件：{framesDir}");
            return null;
        }

        int cols = Mathf.CeilToInt(Mathf.Sqrt(n));
        int rows = Mathf.CeilToInt((float)n / cols);
        int atlasW = cols * frameWidth;
        int atlasH = rows * frameHeight;

        Debug.Log($"[AtlasGenerator] 开始合成：{n} 帧，网格 {cols}×{rows}，图集 {atlasW}×{atlasH}");

        var atlas = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, false);
        atlas.SetPixels32(new Color32[atlasW * atlasH]);

        for (int i = 0; i < n; i++)
        {
            byte[] bytes = File.ReadAllBytes(files[i]);
            var frame = new Texture2D(frameWidth, frameHeight, TextureFormat.ARGB32, false);
            frame.LoadImage(bytes);

            int col = i % cols;
            int row = i / cols;
            int x = col * frameWidth;
            int y = atlasH - (row + 1) * frameHeight;

            atlas.SetPixels(x, y, frameWidth, frameHeight, frame.GetPixels());
            UnityEngine.Object.DestroyImmediate(frame);
        }

        atlas.Apply();

        string outDir = Path.GetDirectoryName(outputPath);
        if (!string.IsNullOrEmpty(outDir) && !Directory.Exists(outDir))
            Directory.CreateDirectory(outDir);

        File.WriteAllBytes(outputPath, atlas.EncodeToPNG());
        UnityEngine.Object.DestroyImmediate(atlas);
        ConfigureAtlasImporter(outputPath);

        Debug.Log($"[AtlasGenerator] 图集已保存：{outputPath}  ({atlasW}×{atlasH}, {cols}列×{rows}行, {n} 帧)");

        foreach (string f in files)
        {
            try { File.Delete(f); }
            catch (Exception e) { Debug.LogWarning($"[AtlasGenerator] 删除序列帧失败：{f}\n{e.Message}"); }
        }
        if (Directory.GetFiles(framesDir).Length == 0 && Directory.GetDirectories(framesDir).Length == 0)
        {
            try { Directory.Delete(framesDir); }
            catch (Exception e) { Debug.LogWarning($"[AtlasGenerator] 删除目录失败：{framesDir}\n{e.Message}"); }
        }

        return outputPath;
    }

    private static void ConfigureAtlasImporter(string atlasFilePath)
    {
        string assetPath = ToAssetPath(atlasFilePath);
        if (string.IsNullOrEmpty(assetPath))
            return;

        AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
        if (AssetImporter.GetAtPath(assetPath) is not TextureImporter importer)
            return;

        importer.textureType = TextureImporterType.Default;
        importer.alphaIsTransparency = true;
        importer.mipmapEnabled = false;
        importer.SaveAndReimport();
    }

    private static string ToAssetPath(string filePath)
    {
        string normalized = Path.GetFullPath(filePath).Replace('\\', '/');
        string dataPath = Application.dataPath.Replace('\\', '/');
        return normalized.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase)
            ? "Assets" + normalized.Substring(dataPath.Length)
            : null;
    }

}


// ── 预制体生成 ─────────────────────────────────────────────────────────────────────────
/// <summary>
/// 根据样板预制体和图集，生成带序列帧材质的粒子预制体，并自动配置 TextureSheetAnimation。
/// </summary>
public static class PrefabGenerator
{
    private const string TargetParticleObjectName = "Anim";

    public static bool ValidateTemplate(GameObject templateRoot, string templatePath)
    {
        return TryGetTargetParticleSystem(templateRoot, templatePath, out _);
    }

    public static string Generate(string templatePrefabAssetPath, string atlasFilePath,
                                   string prefabOutDir, string matOutDir, string prefabName, int cols, int rows, float duration)
    {
        if (string.IsNullOrEmpty(templatePrefabAssetPath))
        {
            Debug.LogWarning("[PrefabGenerator] 未设置样板预制体，跳过预制体生成。");
            return null;
        }

        var templatePrefab = AssetDatabase.LoadAssetAtPath<GameObject>(templatePrefabAssetPath);
        if (templatePrefab == null)
        {
            Debug.LogWarning($"[PrefabGenerator] 无法加载样板预制体：{templatePrefabAssetPath}");
            return null;
        }

        if (!TryGetTargetParticleSystem(templatePrefab, templatePrefabAssetPath, out var templateParticleSystem))
            return null;

        string dataPath = Application.dataPath.Replace('\\', '/');
        string outDir   = prefabOutDir.Replace('\\', '/').TrimEnd('/');
        if (!outDir.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase))
        {
            Debug.LogWarning($"[PrefabGenerator] 预制体输出路径不在 Assets 内：{prefabOutDir}");
            return null;
        }

        string assetOutDir = "Assets" + outDir.Substring(dataPath.Length);
        if (!Directory.Exists(outDir))
            Directory.CreateDirectory(outDir);

        string matDir = string.IsNullOrEmpty(matOutDir)
            ? outDir
            : matOutDir.Replace('\\', '/').TrimEnd('/');
        if (!matDir.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase))
        {
            Debug.LogWarning($"[PrefabGenerator] 材质输出路径不在 Assets 内：{matOutDir}，将回退到预制体输出目录。");
            matDir = outDir;
        }
        string assetMatDir = "Assets" + matDir.Substring(dataPath.Length);
        if (!Directory.Exists(matDir))
            Directory.CreateDirectory(matDir);

        string atlasSourceNorm = Path.GetFullPath(atlasFilePath).Replace('\\', '/');
        string atlasAssetPath;
        if (atlasSourceNorm.StartsWith(dataPath, StringComparison.OrdinalIgnoreCase))
        {
            atlasAssetPath = "Assets" + atlasSourceNorm.Substring(dataPath.Length);
        }
        else
        {
            string atlasDestAbs = Path.GetFullPath(Path.Combine(outDir, $"{prefabName}_atlas.png")).Replace('\\', '/');
            if (!string.Equals(atlasSourceNorm, atlasDestAbs, StringComparison.OrdinalIgnoreCase))
                File.Copy(atlasFilePath, atlasDestAbs, overwrite: true);
            atlasAssetPath = $"{assetOutDir}/{prefabName}_atlas.png";
        }
        AssetDatabase.ImportAsset(atlasAssetPath, ImportAssetOptions.ForceUpdate);

        if (AssetImporter.GetAtPath(atlasAssetPath) is TextureImporter ti)
        {
            ti.textureType         = TextureImporterType.Default;
            ti.alphaIsTransparency = true;
            ti.mipmapEnabled       = false;
            ti.SaveAndReimport();
        }

        var atlasTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(atlasAssetPath);
        if (atlasTexture == null)
        {
            Debug.LogError($"[PrefabGenerator] 图集纹理导入失败：{atlasAssetPath}");
            return null;
        }

        var templateRenderer = templateParticleSystem.GetComponent<ParticleSystemRenderer>();
        var srcMat           = templateRenderer != null ? templateRenderer.sharedMaterial : null;
        string matAssetPath  = $"{assetMatDir}/{prefabName}_mat.mat";

        if (AssetDatabase.LoadAssetAtPath<Material>(matAssetPath) != null)
            AssetDatabase.DeleteAsset(matAssetPath);

        if (srcMat != null)
        {
            string srcMatPath = AssetDatabase.GetAssetPath(srcMat);
            if (!string.IsNullOrEmpty(srcMatPath))
                AssetDatabase.CopyAsset(srcMatPath, matAssetPath);
            else
                AssetDatabase.CreateAsset(new Material(srcMat), matAssetPath);
        }
        else
        {
            AssetDatabase.CreateAsset(
                new Material(Shader.Find("Universal Render Pipeline/Particles/Unlit")
                          ?? Shader.Find("Particles/Standard Unlit")), matAssetPath);
        }

        var mat = AssetDatabase.LoadAssetAtPath<Material>(matAssetPath);
        mat.mainTexture = atlasTexture;
        if (mat.HasProperty("_BaseMap"))
            mat.SetTexture("_BaseMap", atlasTexture);
        EditorUtility.SetDirty(mat);
        AssetDatabase.SaveAssets();

        var go = (GameObject)PrefabUtility.InstantiatePrefab(templatePrefab);
        PrefabUtility.UnpackPrefabInstance(go, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);

        if (!TryGetTargetParticleSystem(go, templatePrefabAssetPath, out var targetParticleSystem))
        {
            UnityEngine.Object.DestroyImmediate(go);
            return null;
        }

        var targetRenderer = targetParticleSystem.GetComponent<ParticleSystemRenderer>();
        if (targetRenderer != null)
            targetRenderer.sharedMaterial = mat;

        var main = targetParticleSystem.main;
        main.startLifetime = duration;

        var tsam = targetParticleSystem.textureSheetAnimation;
        tsam.enabled = true;
        tsam.numTilesX = cols;
        tsam.numTilesY = rows;

        string prefabAssetPath = $"{assetOutDir}/{prefabName}_Anim.prefab";
        PrefabUtility.SaveAsPrefabAsset(go, prefabAssetPath);
        UnityEngine.Object.DestroyImmediate(go);

        AssetDatabase.SaveAssets();
        Debug.Log($"[PrefabGenerator] 预制体已生成：{prefabAssetPath}  (图集 {cols}×{rows})");
        return prefabAssetPath;
    }

    private static bool TryGetTargetParticleSystem(GameObject templateRoot, string templatePath,
        out ParticleSystem particleSystem)
    {
        particleSystem = null;
        if (templateRoot == null)
        {
            ShowTemplateError(templatePath, "模板对象为空。");
            return false;
        }

        Transform target = null;
        foreach (var transform in templateRoot.GetComponentsInChildren<Transform>(true))
        {
            if (transform.name != TargetParticleObjectName)
                continue;

            if (target != null)
            {
                ShowTemplateError(templatePath, $"模板中存在多个名为“{TargetParticleObjectName}”的节点，无法确定写入目标。");
                return false;
            }

            target = transform;
        }

        if (target == null)
        {
            ShowTemplateError(templatePath, $"模板中未找到名为“{TargetParticleObjectName}”的目标节点。");
            return false;
        }

        particleSystem = target.GetComponent<ParticleSystem>();
        if (particleSystem == null)
        {
            ShowTemplateError(templatePath, $"目标节点“{TargetParticleObjectName}”上缺少 ParticleSystem 组件。");
            return false;
        }

        return true;
    }

    private static void ShowTemplateError(string templatePath, string reason)
    {
        string message = $"序列帧模板校验失败，已终止转换。\n\n模板：{templatePath}\n原因：{reason}";
        Debug.LogError($"[PrefabGenerator] {message}");
        EditorUtility.DisplayDialog("序列帧模板错误", message, "确定");
    }
}
}
