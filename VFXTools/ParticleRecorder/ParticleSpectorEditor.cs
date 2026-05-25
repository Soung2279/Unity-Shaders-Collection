using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ParticleExporter))]
public class ParticleSpectorEditor : Editor
{
    SerializedProperty frameRateSP;
    SerializedProperty durationSP;
    SerializedProperty screenWidthSP;
    SerializedProperty screenHeightSP;

    public void OnEnable()
    {
        frameRateSP  = serializedObject.FindProperty("frameRate");
        durationSP   = serializedObject.FindProperty("duration");
        screenWidthSP  = serializedObject.FindProperty("screenWidth");
        screenHeightSP = serializedObject.FindProperty("screenHeight");
    }

    public override void OnInspectorGUI()
    {
        // 编译期间 FindProperty 可能返回 null，等待重新编译完成
        if (frameRateSP == null || durationSP == null || screenWidthSP == null || screenHeightSP == null)
        {
            EditorGUILayout.HelpBox("脚本编译中，请稍候...", MessageType.Info);
            if (GUILayout.Button("刷新"))
            {
                frameRateSP    = serializedObject.FindProperty("frameRate");
                durationSP     = serializedObject.FindProperty("duration");
                screenWidthSP  = serializedObject.FindProperty("screenWidth");
                screenHeightSP = serializedObject.FindProperty("screenHeight");
            }
            return;
        }

        base.OnInspectorGUI();
        serializedObject.Update();

        EditorGUILayout.PropertyField(frameRateSP, new GUIContent("导出帧率"));
        EditorGUILayout.PropertyField(durationSP,  new GUIContent("录制时长（秒）"));

        // 由时长和帧率推算总帧数，只读显示
        int computedFrameCount = Mathf.CeilToInt(frameRateSP.intValue * durationSP.floatValue);
        EditorGUI.BeginDisabledGroup(true);
        EditorGUILayout.IntField(new GUIContent("预计总帧数"), computedFrameCount);
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space();

        // 自动从主摄像机读取分辨率，不允许手动编辑
        Camera mainCam = Camera.main;
        if (mainCam != null)
        {
            int w = (int)mainCam.pixelWidth;
            int h = (int)mainCam.pixelHeight;
            // 同步写回序列化字段，供 ParticleExporter.Start() 兜底使用
            screenWidthSP.intValue  = w;
            screenHeightSP.intValue = h;

            EditorGUILayout.HelpBox($"摄像机分辨率（自动检测）：{w} × {h}", MessageType.Info);
            if (w != h)
            {
                EditorGUILayout.HelpBox(
                    $"当前分辨率 {w}×{h} 不是正方形。\n建议在 Game 视图中将分辨率调整为 1:1 比例，否则导出序列帧将非正方形。",
                    MessageType.Warning);
            }
        }
        else
        {
            EditorGUILayout.HelpBox("未找到主摄像机（MainCamera），无法自动检测分辨率。", MessageType.Error);
        }

        EditorGUILayout.Space();

        if (GUILayout.Button("开始"))
        {
            if (Application.isPlaying)
            {
                ParticleExporter mTestObj = target as ParticleExporter;
                mTestObj.isStart = true;
            }
        }

        serializedObject.ApplyModifiedProperties();
    }
}