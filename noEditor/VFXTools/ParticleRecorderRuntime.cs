using System;
using System.Collections;
using System.IO;
using UnityEngine;

/// <summary>
/// 粒子序列帧录制运行时组件。
/// 由 ParticleRecorderWindow 自动创建并注入临时录制场景，进入 Play Mode 后自动开始录制，完成后退出 Play Mode。
/// </summary>
public class ParticleRecorderRuntime : MonoBehaviour
{
    // ── EditorPrefs 键（public，供 Editor 程序集引用）──────────────────────
    public const string KeyFrameRate      = "PR_FrameRate";
    public const string KeyDuration       = "PR_Duration";
    public const string KeyWidth          = "PR_Width";
    public const string KeyHeight         = "PR_Height";
    public const string KeyExportPath     = "PR_ExportPath";
    public const string KeyPrefabOutPath  = "PR_PrefabOutPath";
    public const string KeyPrefabName     = "PR_PrefabName";
    public const string KeyIsRecording        = "PR_IsRecording";
    public const string KeyTempScene          = "PR_TempScene";
    public const string KeyOrigScene          = "PR_OrigScene";
    public const string KeyRecordingResult    = "PR_RecordingResult";
    public const string KeyTemplatePrefabPath = "PR_TemplatePrefabPath";
    public const string KeyMatOutPath         = "PR_MatOutPath";
    public const string KeyLastPrefabResult  = "PR_LastPrefabResult";
    public const string KeyLastAtlasResult   = "PR_LastAtlasResult";
    public const string KeyLastOutputDir     = "PR_LastOutputDir";
    public const string KeyTempSourcePrefab  = "PR_TempSourcePrefab";

    // ── 运行时状态 ──────────────────────────────────────────────────────────
    private int        frameRate;
    private int        screenWidth;
    private int        screenHeight;
    private string     exportPath;
    private string     prefabName;
    private int        frameCount;
    private float      originalTimeScale;
    private string     realFolder;

    private Camera     exportCamera;
    private Texture2D[] frames;
    private int        currentIndex = 0;
    private bool       over         = false;
    private bool       isCapturing  = false;

    private void Start()
    {
#if UNITY_EDITOR
        frameRate    = UnityEditor.EditorPrefs.GetInt   (KeyFrameRate, 25);
        float dur    = UnityEditor.EditorPrefs.GetFloat (KeyDuration,  2f);
        screenWidth  = UnityEditor.EditorPrefs.GetInt   (KeyWidth,     512);
        screenHeight = UnityEditor.EditorPrefs.GetInt   (KeyHeight,    512);
        exportPath   = UnityEditor.EditorPrefs.GetString(KeyExportPath,    "PNG_Animations");
        prefabName   = UnityEditor.EditorPrefs.GetString(KeyPrefabName,    "Output");
        frameCount   = Mathf.CeilToInt(frameRate * dur);
#else
        Debug.LogError("[ParticleRecorderRuntime] 此组件仅限在 Unity Editor 中使用。");
        Destroy(gameObject);
        return;
#endif
        Time.captureFramerate = frameRate;
        originalTimeScale     = Time.timeScale;

        realFolder = Path.Combine(exportPath, prefabName);
        if (!Directory.Exists(realFolder))
            Directory.CreateDirectory(realFolder);

        Camera mainCam = Camera.main;
        if (mainCam == null)
        {
            Debug.LogError("[ParticleRecorderRuntime] 未找到 MainCamera，录制中止。");
            over = true;   // 防止 Update 在 Play Mode 退出前触发新一帧捕捉
            FinishRecording();
            return;
        }

        // 克隆主摄像机（保留 URP/HDRP 附加组件）
        GameObject camClone = Instantiate(mainCam.gameObject);
        camClone.name          = "ExportCamera";
        exportCamera           = camClone.GetComponent<Camera>();
        exportCamera.enabled       = false;   // 不自动渲染，手动调用 Render()
        exportCamera.targetTexture = null;
        exportCamera.clearFlags    = CameraClearFlags.SolidColor;

        // 移除 AudioListener，避免"场景中存在多个 AudioListener"警告
        var al = camClone.GetComponent<AudioListener>();
        if (al != null) Destroy(al);

        frames = new Texture2D[frameCount];
        Debug.Log($"[ParticleRecorder] 开始录制：{frameCount} 帧，分辨率 {screenWidth}×{screenHeight}，输出到 {realFolder}");
    }

    private void Update()
    {
        if (over || isCapturing) return;

        if (currentIndex >= frameCount)
        {
            SaveAndFinish();
            return;
        }

        isCapturing = true;
        StartCoroutine(CaptureFrame());
    }

    private IEnumerator CaptureFrame()
    {
        // 暂停游戏时间，确保黑/白两次渲染捕捉同一帧粒子状态
        Time.timeScale = 0f;
        yield return new WaitForEndOfFrame();

        // yield 之后才能用 try-finally（C# 不允许 yield 在 try-catch 内）
        RenderTexture blackRT = null;
        RenderTexture whiteRT = null;
        Texture2D texBlack    = null;
        Texture2D texWhite    = null;
        try
        {
        blackRT = RenderTexture.GetTemporary(screenWidth, screenHeight, 24, RenderTextureFormat.ARGB32);
        whiteRT = RenderTexture.GetTemporary(screenWidth, screenHeight, 24, RenderTextureFormat.ARGB32);

        exportCamera.targetTexture   = blackRT;
        exportCamera.backgroundColor = Color.black;
        exportCamera.Render();
        RenderTexture.active = blackRT;
        texBlack = CaptureActiveRT(screenWidth, screenHeight);

        exportCamera.targetTexture   = whiteRT;
        exportCamera.backgroundColor = Color.white;
        exportCamera.Render();
        RenderTexture.active = whiteRT;
        texWhite = CaptureActiveRT(screenWidth, screenHeight);

        RenderTexture.active = null;

        // 从黑/白差值还原真实 Alpha 及颜色
        Texture2D output = new Texture2D(screenWidth, screenHeight, TextureFormat.ARGB32, false);
        for (int y = 0; y < screenHeight; y++)
        {
            for (int x = 0; x < screenWidth; x++)
            {
                Color bb    = texBlack.GetPixel(x, y);
                Color wb    = texWhite.GetPixel(x, y);
                // 取三通道差值最小值，避免单通道偏差导致 Alpha 错误
                float diff  = Mathf.Min(wb.r - bb.r, wb.g - bb.g, wb.b - bb.b);
                float alpha = Mathf.Clamp01(1f - diff);
                Color col;
                if (alpha < 1e-6f)
                {
                    col = Color.clear;
                }
                else
                {
                    // 去预乘，还原粒子真实颜色
                    col = new Color(
                        Mathf.Clamp01(bb.r / alpha),
                        Mathf.Clamp01(bb.g / alpha),
                        Mathf.Clamp01(bb.b / alpha),
                        alpha);
                }
                output.SetPixel(x, y, col);
            }
        }
        output.Apply();
        frames[currentIndex] = output;
        currentIndex++;
        }
        catch (Exception e)
        {
            Debug.LogError($"[ParticleRecorder] CaptureFrame 捕捉第 {currentIndex} 帧时出错：{e}");
            over = true;
            FinishRecording();
        }
        finally
        {
            exportCamera.targetTexture = null;
            RenderTexture.active = null;
            if (blackRT  != null) RenderTexture.ReleaseTemporary(blackRT);
            if (whiteRT  != null) RenderTexture.ReleaseTemporary(whiteRT);
            if (texBlack != null) Destroy(texBlack);
            if (texWhite != null) Destroy(texWhite);
            Time.timeScale = originalTimeScale;
            isCapturing    = false;
        }
    }

    private static Texture2D CaptureActiveRT(int w, int h)
    {
        var tex = new Texture2D(w, h, TextureFormat.ARGB32, false);
        tex.ReadPixels(new Rect(0, 0, w, h), 0, 0);
        tex.Apply();
        return tex;
    }

    private void SaveAndFinish()
    {
        over = true;
        for (int i = 0; i < frameCount; i++)
        {
            if (frames[i] == null) continue;
            File.WriteAllBytes(Path.Combine(realFolder, $"{i:D4}.png"), frames[i].EncodeToPNG());
        }
        Debug.Log($"[ParticleRecorder] 录制完成，共 {frameCount} 帧，已保存至：{realFolder}");
        FinishRecording();
    }

    private static void FinishRecording()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }
}
