using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

#if UNITY_EDITOR
public class ParticleDelayModifier : EditorWindow
{
    private GameObject targetObject;
    private float additionalDelay = 0f;

    [MenuItem("工具/VFXTools/粒子延迟修改器")]
    public static void ShowWindow()
    {
        var window = GetWindow<ParticleDelayModifier>("粒子延迟修改器");
        window.titleContent = new GUIContent("一键调整粒子延迟", EditorGUIUtility.IconContent("ParticleSystem Icon").image);
    }

    private void OnGUI()
    {
        GUILayout.Label("粒子系统启动延迟修改工具", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        // 目标对象选择
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("目标对象:", GUILayout.Width(80));
        targetObject = (GameObject)EditorGUILayout.ObjectField(targetObject, typeof(GameObject), true);
        EditorGUILayout.EndHorizontal();

        // 额外延迟时间
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("延迟时间:", GUILayout.Width(80));
        
        string delayString = additionalDelay.ToString("F4");
        string newDelayString = EditorGUILayout.TextField(delayString);
        
        if (float.TryParse(newDelayString, out float parsedDelay))
        {
            additionalDelay = (float)System.Math.Round(parsedDelay, 4);
        }
        
        EditorGUILayout.LabelField("秒", GUILayout.Width(20));
        EditorGUILayout.EndHorizontal();

        // 快速调节按钮
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("快速调节:", GUILayout.Width(80));
        
        if (GUILayout.Button("-0.1", GUILayout.Width(40)))
            additionalDelay = (float)System.Math.Round(additionalDelay - 0.1f, 4);
        if (GUILayout.Button("-0.01", GUILayout.Width(45)))
            additionalDelay = (float)System.Math.Round(additionalDelay - 0.01f, 4);
            
        if (GUILayout.Button("归零", GUILayout.Width(40)))
            additionalDelay = 0f;
            
        if (GUILayout.Button("+0.01", GUILayout.Width(45)))
            additionalDelay = (float)System.Math.Round(additionalDelay + 0.01f, 4);
        if (GUILayout.Button("+0.1", GUILayout.Width(40)))
            additionalDelay = (float)System.Math.Round(additionalDelay + 0.1f, 4);
            
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        // 应用修改按钮
        GUI.enabled = targetObject != null;
        
        if (GUILayout.Button("应用延迟修改", GUILayout.Height(35)))
        {
            ApplyDelayModification();
        }
        
        GUI.enabled = true;

        // 帮助信息
        EditorGUILayout.Space();
        EditorGUILayout.HelpBox(
            "使用说明:\n" +
            "1. 将游戏对象拖拽到'目标对象'字段\n" +
            "2. 设置延迟时间（支持负数）\n" +
            "3. 点击'应用延迟修改'直接完成调整\n" +
            "注意：修改支持撤销（Ctrl+Z）",
            MessageType.Info);
    }

    private void ApplyDelayModification()
    {
        if (targetObject == null)
        {
            EditorUtility.DisplayDialog("错误", "请先选择目标对象！", "确定");
            return;
        }

        // 获取所有子对象的粒子系统
        ParticleSystem[] particles = targetObject.GetComponentsInChildren<ParticleSystem>(true);
        
        if (particles.Length == 0)
        {
            EditorUtility.DisplayDialog("提示", "在指定对象中未找到任何粒子系统！", "确定");
            return;
        }

        // 记录撤销操作
        Undo.RegisterCompleteObjectUndo(targetObject, "Modify Particle Delays");

        int modifiedCount = 0;

        foreach (var particle in particles)
        {
            if (particle != null)
            {
                var main = particle.main;
                
                // 获取当前延迟时间并计算新值
                float currentDelay = main.startDelay.constant;
                float newDelay = (float)System.Math.Round(currentDelay + additionalDelay, 4);
                
                // 确保延迟时间不为负数
                newDelay = Mathf.Max(0f, newDelay);
                
                // 设置新的延迟时间
                main.startDelay = newDelay;
                
                modifiedCount++;
            }
        }

        // 标记对象已修改
        EditorUtility.SetDirty(targetObject);
        
        // 如果是预制体，保存更改
        if (PrefabUtility.IsPartOfAnyPrefab(targetObject))
        {
            GameObject prefabSource = PrefabUtility.GetCorrespondingObjectFromSource(targetObject);
            if (prefabSource != null)
            {
                PrefabUtility.SavePrefabAsset(prefabSource);
            }
        }

        Debug.Log($"粒子延迟修改器: 成功修改了 {modifiedCount} 个粒子系统，延迟调整: {additionalDelay:F4} 秒");
    }
}
#endif