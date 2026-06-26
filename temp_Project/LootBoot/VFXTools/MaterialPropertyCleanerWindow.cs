using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

#if UNITY_EDITOR
public class MaterialPropertyCleanerWindow : EditorWindow
{
    private const string MenuPath = "TATools/Tools/材质残留清理";

    private static readonly HashSet<string> PreserveNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
    {
        "_Stencil", "_StencilComp", "_StencilOp", "_StencilReadMask", "_StencilWriteMask",
        "_ColorMask", "_UseUIAlphaClip", "_ClipRect", "_ClipSoftness", "_AlphaClip",
        "_ShadowMask", "_BlendOp", "_BlendOpAlpha", "_SrcBlend", "_DstBlend",
        "_SrcBlendAlpha", "_DstBlendAlpha", "_ZWrite", "_ZTest", "_Cull",
        "_QueueOffset", "_QueueControl", "_Surface", "_Blend", "_AlphaClipThreshold",
        "_BaseColor", "_Color", "_Cutoff", "_EnableExternalAlpha", "_Flip", "_MainTex", "_SampleGI"
    };

    private static readonly string[] PreservePrefixes =
    {
        "_Stencil", "_Clip", "_UI", "_Blend", "_SrcBlend", "_DstBlend",
        "_ColorMask", "_ZWrite", "_ZTest", "_Cull"
    };

    private readonly List<MaterialReport> reports = new List<MaterialReport>();
    private Vector2 scroll;
    private DefaultAsset scanFolder;

    [MenuItem(MenuPath, false, 120)]
    public static void Open()
    {
        GetWindow<MaterialPropertyCleanerWindow>("材质清理");
    }

    private void OnGUI()
    {
        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField("材质残留属性清理", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("按当前 shader 的 properties 检查材质残留属性，并清理不匹配项。", MessageType.Info);
        scanFolder = (DefaultAsset)EditorGUILayout.ObjectField("扫描目录", scanFolder, typeof(DefaultAsset), false);

        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("扫描", GUILayout.Height(26)))
                Scan();

            using (new EditorGUI.DisabledScope(reports.Count == 0))
            {
                if (GUILayout.Button("清理", GUILayout.Height(26)))
                    CleanReports();
            }
        }

        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField($"结果：{reports.Count} 个材质，{reports.Sum(r => r.RemovableCount)} 个可清理残留项。", EditorStyles.boldLabel);

        var pathStyle = new GUIStyle(EditorStyles.miniLabel) { wordWrap = true };
        scroll = EditorGUILayout.BeginScrollView(scroll);
        foreach (MaterialReport report in reports)
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button(report.Name, EditorStyles.linkLabel, GUILayout.ExpandWidth(true)))
                        SelectMaterial(report.Path);
                    GUILayout.Label($"{report.RemovableCount} 项", EditorStyles.miniLabel, GUILayout.Width(44));
                }

                EditorGUILayout.SelectableLabel(report.Path, pathStyle, GUILayout.MinHeight(EditorGUIUtility.singleLineHeight * 2));
                if (report.RemovableCount > 0)
                    EditorGUILayout.LabelField("残留属性：" + string.Join(", ", report.Removable.Select(p => p.PropertyName)), pathStyle);
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void Scan()
    {
        reports.Clear();
        string[] paths = GetMaterialPaths();
        try
        {
            for (int i = 0; i < paths.Length; i++)
            {
                if (EditorUtility.DisplayCancelableProgressBar("扫描材质", paths[i], i / (float)Math.Max(paths.Length, 1)))
                    break;

                Material material = AssetDatabase.LoadAssetAtPath<Material>(paths[i]);
                if (material == null || material.shader == null)
                    continue;

                MaterialReport report = BuildReport(material, paths[i]);
                if (report.RemovableCount > 0)
                    reports.Add(report);
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }

    private string[] GetMaterialPaths()
    {
        string folderPath = scanFolder != null ? AssetDatabase.GetAssetPath(scanFolder) : "Assets";
        if (string.IsNullOrEmpty(folderPath) || !AssetDatabase.IsValidFolder(folderPath))
            folderPath = "Assets";

        return AssetDatabase.FindAssets("t:Material", new[] { folderPath })
            .Select(AssetDatabase.GUIDToAssetPath)
            .Where(p => p.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase))
            .Distinct()
            .ToArray();
    }

    private static MaterialReport BuildReport(Material material, string path)
    {
        HashSet<string> shaderProperties = GetShaderProperties(material.shader);
        SerializedObject serializedObject = new SerializedObject(material);
        SerializedProperty savedProperties = serializedObject.FindProperty("m_SavedProperties");

        MaterialReport report = new MaterialReport(path, material.name);
        AddUnusedProperties(savedProperties, "m_TexEnvs", shaderProperties, report);
        AddUnusedProperties(savedProperties, "m_Floats", shaderProperties, report);
        AddUnusedProperties(savedProperties, "m_Ints", shaderProperties, report);
        AddUnusedProperties(savedProperties, "m_Colors", shaderProperties, report);
        return report;
    }

    private static HashSet<string> GetShaderProperties(Shader shader)
    {
        HashSet<string> result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        int count = ShaderUtil.GetPropertyCount(shader);
        for (int i = 0; i < count; i++)
            result.Add(ShaderUtil.GetPropertyName(shader, i));
        return result;
    }

    private static void AddUnusedProperties(SerializedProperty savedProperties, string arrayName, HashSet<string> shaderProperties, MaterialReport report)
    {
        SerializedProperty array = savedProperties?.FindPropertyRelative(arrayName);
        if (array == null || !array.isArray)
            return;

        for (int i = 0; i < array.arraySize; i++)
        {
            SerializedProperty element = array.GetArrayElementAtIndex(i);
            string propertyName = element.FindPropertyRelative("first")?.stringValue;
            if (!string.IsNullOrEmpty(propertyName) && !shaderProperties.Contains(propertyName) && !ShouldPreserve(propertyName))
                report.Removable.Add(new MaterialPropertyEntry(arrayName, propertyName));
        }
    }

    private static bool ShouldPreserve(string propertyName)
    {
        if (PreserveNames.Contains(propertyName))
            return true;

        for (int i = 0; i < PreservePrefixes.Length; i++)
        {
            if (propertyName.StartsWith(PreservePrefixes[i], StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }

    private void CleanReports()
    {
        int affectedMaterials = 0;
        try
        {
            for (int i = 0; i < reports.Count; i++)
            {
                MaterialReport report = reports[i];
                if (EditorUtility.DisplayCancelableProgressBar("清理材质", report.Path, i / (float)Math.Max(reports.Count, 1)))
                    break;

                Material material = AssetDatabase.LoadAssetAtPath<Material>(report.Path);
                if (material == null)
                    continue;

                Undo.RecordObject(material, "Clean Material Properties");
                SerializedObject serializedObject = new SerializedObject(material);
                SerializedProperty savedProperties = serializedObject.FindProperty("m_SavedProperties");

                int removed = 0;
                removed += RemoveUnusedProperties(savedProperties, "m_TexEnvs", material.shader);
                removed += RemoveUnusedProperties(savedProperties, "m_Floats", material.shader);
                removed += RemoveUnusedProperties(savedProperties, "m_Ints", material.shader);
                removed += RemoveUnusedProperties(savedProperties, "m_Colors", material.shader);

                if (removed > 0)
                {
                    affectedMaterials++;
                    serializedObject.ApplyModifiedPropertiesWithoutUndo();
                    EditorUtility.SetDirty(material);
                }
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log($"材质清理完成，影响 {affectedMaterials} 个材质。");
        Scan();
    }

    private static int RemoveUnusedProperties(SerializedProperty savedProperties, string arrayName, Shader shader)
    {
        SerializedProperty array = savedProperties?.FindPropertyRelative(arrayName);
        if (array == null || !array.isArray || shader == null)
            return 0;

        HashSet<string> shaderProperties = GetShaderProperties(shader);
        int removed = 0;
        for (int i = array.arraySize - 1; i >= 0; i--)
        {
            SerializedProperty element = array.GetArrayElementAtIndex(i);
            string propertyName = element.FindPropertyRelative("first")?.stringValue;
            if (string.IsNullOrEmpty(propertyName) || shaderProperties.Contains(propertyName) || ShouldPreserve(propertyName))
                continue;

            array.DeleteArrayElementAtIndex(i);
            removed++;
        }
        return removed;
    }

    private static void SelectMaterial(string path)
    {
        var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path);
        if (asset == null)
            return;

        Selection.activeObject = asset;
        EditorGUIUtility.PingObject(asset);
    }

    private class MaterialReport
    {
        public readonly string Path;
        public readonly string Name;
        public readonly List<MaterialPropertyEntry> Removable = new List<MaterialPropertyEntry>();
        public int RemovableCount => Removable.Count;

        public MaterialReport(string path, string name)
        {
            Path = path;
            Name = name;
        }
    }

    private struct MaterialPropertyEntry
    {
        public readonly string ArrayName;
        public readonly string PropertyName;

        public MaterialPropertyEntry(string arrayName, string propertyName)
        {
            ArrayName = arrayName;
            PropertyName = propertyName;
        }
    }
}
#endif

