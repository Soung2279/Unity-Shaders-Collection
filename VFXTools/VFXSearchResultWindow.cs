using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

/// <summary>
/// 显示特效备注搜索结果的弹出窗口。
/// 每条结果展示 ID、名称与备注（自动换行），点击"选择"可将整行数据填回主工具窗口。
/// </summary>
public class VFXSearchResultWindow : EditorWindow
{
    private List<LootBootVFXtoExcel.VFXRowData> results;
    private Action<LootBootVFXtoExcel.VFXRowData> onSelected;
    private Vector2 scrollPos;
    private GUIStyle remarkStyle;

    internal static void Open(
        List<LootBootVFXtoExcel.VFXRowData> results,
        Action<LootBootVFXtoExcel.VFXRowData> onSelected)
    {
        var window = CreateInstance<VFXSearchResultWindow>();
        window.titleContent = new GUIContent("特效搜索结果");
        window.results = results;
        window.onSelected = onSelected;
        window.minSize = new Vector2(380f, 320f);
        window.ShowUtility();
    }

    private void OnGUI()
    {
        // 延迟初始化样式（GUIStyle 必须在 OnGUI 内创建）
        if (remarkStyle == null)
        {
            remarkStyle = new GUIStyle(EditorStyles.label);
            remarkStyle.wordWrap = true;
            remarkStyle.richText = false;
        }

        if (results == null || results.Count == 0)
        {
            EditorGUILayout.HelpBox("没有找到匹配的特效。", MessageType.Info);
            return;
        }

        EditorGUILayout.LabelField($"共找到 {results.Count} 条结果，点击「选择」填回配置：", EditorStyles.boldLabel);
        EditorGUILayout.Space(4f);

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        for (int i = 0; i < results.Count; i++)
        {
            LootBootVFXtoExcel.VFXRowData row = results[i];
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                // 名称（粗体，带 ID 前缀）
                EditorGUILayout.LabelField($"[{row.id}]  {row.name}", EditorStyles.boldLabel);

                // 备注（自动换行）
                if (!string.IsNullOrEmpty(row.remark))
                    EditorGUILayout.LabelField(row.remark, remarkStyle);

                // 选择按钮
                Color saved = GUI.backgroundColor;
                GUI.backgroundColor = new Color(0.35f, 0.85f, 0.35f);
                if (GUILayout.Button("选择", GUILayout.Height(22f)))
                {
                    onSelected?.Invoke(row);
                    Close();
                }
                GUI.backgroundColor = saved;
            }
            EditorGUILayout.Space(2f);
        }

        EditorGUILayout.EndScrollView();
    }
}
