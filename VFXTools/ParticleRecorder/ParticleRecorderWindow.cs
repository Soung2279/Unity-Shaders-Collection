using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

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
        float  duration         = EditorPrefs.GetFloat(ParticleRecorderRuntime.KeyDuration, 2f);
        int    totalFrames      = Mathf.CeilToInt(
            duration *
            EditorPrefs.GetInt  (ParticleRecorderRuntime.KeyFrameRate, 25));
        int cols = Mathf.CeilToInt(Mathf.Sqrt(totalFrames));
        int rows = Mathf.CeilToInt((float)totalFrames / cols);

        // ── 删除临时场景资源 ──────────────────────────────────────────────
        if (!string.IsNullOrEmpty(tempScene) && File.Exists(tempScene))
            AssetDatabase.DeleteAsset(tempScene);

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
    private bool       fastRecord  = false; // 启用快速录制（编辑模式下录制）

    // ── 滚动视图 / 预览 ───────────────────────────────────────────────
    private Vector2    scroll;
    private GameObject previewInstance;    // 预览实例（在当前场景中）

    [MenuItem("TATools/Tools/工具 - 粒子序列帧录制")]
    public static void ShowWindow()
    {
        var win = GetWindow<ParticleRecorderWindow>("粒子录制器");
        win.minSize = new Vector2(340, 400);
    }

    // ── 生命周期 ────────────────────────────────────────────────────────────
    private void OnEnable()
    {
        frameRate  = EditorPrefs.GetInt   (PrefFrameRate,  25);
        duration   = EditorPrefs.GetFloat (PrefDuration,   2f);
        orthoSize  = EditorPrefs.GetFloat (PrefOrthoSize,  3f);
        resolution = (FrameResolution)EditorPrefs.GetInt(PrefResolution, (int)FrameResolution._512);
        seqPath    = EditorPrefs.GetString(PrefSeqExportPath,
                         Path.GetFullPath(Path.Combine(Application.dataPath, "../PNG_Animations")));
        prefabPath = EditorPrefs.GetString(PrefPrefabOutPath,
                         Path.GetFullPath(Path.Combine(Application.dataPath, "RecordedPrefabs")));
        matPath    = EditorPrefs.GetString(PrefMatOutPath,
                         Path.GetFullPath(Path.Combine(Application.dataPath, "RecordedPrefabs/Materials")));
        fastRecord = EditorPrefs.GetBool  (PrefFastRecord,  false);
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
            new GUIContent("需要转换的特效", "需要录制的粒子系统预制体，拖入或点击右侧按钮选择"),
            prefabToRecord, typeof(GameObject), false);

        prefabTemplate = (GameObject)EditorGUILayout.ObjectField(
            new GUIContent("样板预制体", "用于后续生成的空模板预制体"),
            prefabTemplate, typeof(GameObject), false);

        // ── 录制参数 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("录制参数");

        frameRate = Mathf.Max(1,    EditorGUILayout.IntField  (new GUIContent("导出帧率（fps）"),   frameRate));
        duration  = Mathf.Max(0.1f, EditorGUILayout.FloatField(new GUIContent("录制时长（秒）"),    duration));

        EditorGUI.BeginDisabledGroup(true);
        EditorGUILayout.IntField(new GUIContent("预计总帧数"), Mathf.CeilToInt(frameRate * duration));
        EditorGUI.EndDisabledGroup();

        // ── 分辨率与摄像机 ───────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("单帧分辨率与摄像机");

        resolution = (FrameResolution)EditorGUILayout.EnumPopup(
            new GUIContent("单帧分辨率", "序列帧宽高，均为正方形 POT 尺寸"), resolution);
        orthoSize = Mathf.Max(0.1f, EditorGUILayout.FloatField(
                        new GUIContent("录制范围(摄像机大小)", "调整以适配粒子效果的空间范围"), orthoSize));

        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        bool hasPreviewing = previewInstance != null;
        EditorGUI.BeginDisabledGroup(prefabToRecord == null || Application.isPlaying);
        if (hasPreviewing)
        {
            if (GUILayout.Button("清除预览", GUILayout.Width(88)))
                ClearPreview();
        }
        else
        {
            if (GUILayout.Button("预览效果", GUILayout.Width(88)))
            {
                ClearPreview();
                previewInstance = (GameObject)PrefabUtility.InstantiatePrefab(prefabToRecord);
                previewInstance.name = "[Preview] " + prefabToRecord.name;
                previewInstance.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
                Selection.activeGameObject = previewInstance;
                SceneView.lastActiveSceneView?.FrameSelected();
            }
        }
        EditorGUI.EndDisabledGroup();
        EditorGUILayout.EndHorizontal();

        // ── 输出路径 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(6);
        DrawSectionHeader("输出路径");

        DrawPathField("序列帧输出路径", ref seqPath);
        DrawPathField("预制体输出路径", ref prefabPath);
        DrawPathField("材质输出路径",   ref matPath);

        // ── 操作按钮 ─────────────────────────────────────────────────────────
        EditorGUILayout.Space(10);
        bool busy = Application.isPlaying || EditorPrefs.GetBool(ParticleRecorderRuntime.KeyIsRecording, false);

        // 验证所有输出路径必须在 Assets 目录内
        string dataPath   = Application.dataPath.Replace('\\', '/');
        bool   pathsValid = GetPathsOutsideAssetsError(dataPath) == null;

        fastRecord = EditorGUILayout.ToggleLeft(
            new GUIContent("启用快速录制", "勾选后在编辑模式下直接模拟粒子并渲染，无需进入 Play Mode"),
            fastRecord);
        EditorGUI.BeginDisabledGroup(prefabToRecord == null || busy || !pathsValid);
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
            EditorGUILayout.HelpBox(result, MessageType.Info);

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
        if (previewInstance != null)
        {
            DestroyImmediate(previewInstance);
            previewInstance = null;
        }
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
            && !string.IsNullOrWhiteSpace(prefabPath)
            && !string.IsNullOrWhiteSpace(matPath);

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
        sb.AppendLine($"<color={c2}>{m2} 步骤 2：（可选）设置「样板预制体」以自动生成序列帧预制体</color>");
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
    private static void DrawPathField(string label, ref string path)
    {
        EditorGUILayout.BeginHorizontal();
        path = EditorGUILayout.TextField(new GUIContent(label), path);
        if (GUILayout.Button("浏览", GUILayout.Width(48)))
        {
            string sel = EditorUtility.OpenFolderPanel("选择" + label, path, "");
            if (!string.IsNullOrEmpty(sel)) path = sel;
        }
        EditorGUILayout.EndHorizontal();
    }

    // ── 录制流程 ──────────────────────────────────────────────────────────
    private void StartRecording()
    {
        if (prefabToRecord == null) return;
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;

        string origScene = EditorSceneManager.GetActiveScene().path;

        // 将所有设置持久化（跨 Domain Reload 存活）
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyRecordingResult,    "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyTemplatePrefabPath,
            prefabTemplate != null ? AssetDatabase.GetAssetPath(prefabTemplate) : "");
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyPrefabName,    prefabToRecord.name);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyExportPath,    seqPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyPrefabOutPath, prefabPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyMatOutPath,    matPath);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyOrigScene,     origScene);
        EditorPrefs.SetString(ParticleRecorderRuntime.KeyTempScene,     TempScenePath);
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
        var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefabToRecord, tempScene);
        instance.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);

        // 录制器运行时组件
        new GameObject("_ParticleRecorderRuntime").AddComponent<ParticleRecorderRuntime>();

        // 保存临时场景并进入 Play Mode
        EditorSceneManager.SaveScene(tempScene, TempScenePath);
        EditorPrefs.SetBool(ParticleRecorderRuntime.KeyIsRecording, true);
        EditorApplication.isPlaying = true;
    }

    // ── 快速录制（编辑模式）──────────────────────────────────────────────────
    private void StartFastRecording()
    {
        if (prefabToRecord == null) return;
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;

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
        var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefabToRecord, tempScene);
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
        try
        {
            for (int i = 0; i < totalFrames; i++)
            {
                EditorUtility.DisplayProgressBar("快速录制中...",
                    $"正在捕捉第 {i + 1}/{totalFrames} 帧", (float)i / totalFrames);

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

        if (!success) return;

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

}


// ── 预制体生成 ─────────────────────────────────────────────────────────────────────────
/// <summary>
/// 根据样板预制体和图集，生成带序列帧材质的粒子预制体，并自动配置 TextureSheetAnimation。
/// </summary>
public static class PrefabGenerator
{
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
            ti.SaveAndReimport();
        }

        var atlasTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(atlasAssetPath);
        if (atlasTexture == null)
        {
            Debug.LogError($"[PrefabGenerator] 图集纹理导入失败：{atlasAssetPath}");
            return null;
        }

        var templateRenderer = templatePrefab.GetComponentInChildren<ParticleSystemRenderer>(true);
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

        foreach (var ps in go.GetComponentsInChildren<ParticleSystem>(true))
        {
            var r = ps.GetComponent<ParticleSystemRenderer>();
            if (r != null)
                r.sharedMaterial = mat;

            var main       = ps.main;
            main.startLifetime = duration;

            var tsam       = ps.textureSheetAnimation;
            tsam.enabled   = true;
            tsam.numTilesX = cols;
            tsam.numTilesY = rows;
        }

        string prefabAssetPath = $"{assetOutDir}/{prefabName}_Anim.prefab";
        PrefabUtility.SaveAsPrefabAsset(go, prefabAssetPath);
        UnityEngine.Object.DestroyImmediate(go);

        AssetDatabase.SaveAssets();
        Debug.Log($"[PrefabGenerator] 预制体已生成：{prefabAssetPath}  (图集 {cols}×{rows})");
        return prefabAssetPath;
    }
}
