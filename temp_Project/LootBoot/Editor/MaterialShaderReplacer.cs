using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 材质 Shader 批量替换工具
/// 将项目中所有使用 Source Shader 的材质替换为 Target Shader，
/// 并保留两者共有（同名同类型）的属性值，其余属性忽略。
/// </summary>
public class MaterialShaderReplacer : EditorWindow
{
    [MenuItem("Tools/材质Shader批量替换")]
    public static void OpenWindow()
    {
        var window = GetWindow<MaterialShaderReplacer>("材质Shader批量替换");
        window.minSize = new Vector2(500, 400);
    }

    private Shader sourceShader;
    private Shader targetShader;
    private readonly List<string> foundMaterialPaths = new List<string>();
    private Vector2 scrollPos;
    private bool hasScanned = false;

    private void OnGUI()
    {
        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("Shader 批量替换", EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        EditorGUI.BeginChangeCheck();
        sourceShader = (Shader)EditorGUILayout.ObjectField("Source Shader (A)", sourceShader, typeof(Shader), false);
        targetShader = (Shader)EditorGUILayout.ObjectField("Target Shader (B)", targetShader, typeof(Shader), false);
        if (EditorGUI.EndChangeCheck())
        {
            hasScanned = false;
            foundMaterialPaths.Clear();
        }

        EditorGUILayout.Space(8);

        using (new EditorGUI.DisabledScope(sourceShader == null || targetShader == null))
        {
            if (GUILayout.Button("扫描使用 Source Shader 的材质", GUILayout.Height(28)))
                ScanMaterials();
        }

        if (hasScanned)
        {
            EditorGUILayout.Space(4);
            EditorGUILayout.LabelField($"找到 {foundMaterialPaths.Count} 个材质", EditorStyles.miniLabel);

            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.MaxHeight(220));
            foreach (var path in foundMaterialPaths)
                EditorGUILayout.LabelField(path, EditorStyles.miniLabel);
            EditorGUILayout.EndScrollView();

            EditorGUILayout.Space(8);

            using (new EditorGUI.DisabledScope(foundMaterialPaths.Count == 0))
            {
                GUI.backgroundColor = new Color(1f, 0.6f, 0.4f);
                if (GUILayout.Button($"执行替换（共 {foundMaterialPaths.Count} 个材质）", GUILayout.Height(32)))
                {
                    if (EditorUtility.DisplayDialog(
                        "确认执行",
                        $"将把 {foundMaterialPaths.Count} 个材质的 Shader 从\n\"{sourceShader.name}\"\n替换为\n\"{targetShader.name}\"\n\n共有属性值将被保留，建议提前做好版本控制。",
                        "执行", "取消"))
                    {
                        ExecuteReplacement();
                    }
                }
                GUI.backgroundColor = Color.white;
            }
        }
    }

    private void ScanMaterials()
    {
        foundMaterialPaths.Clear();
        hasScanned = true;

        string[] guids = AssetDatabase.FindAssets("t:Material", new[] { "Assets" });
        int total = guids.Length;

        for (int i = 0; i < total; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (EditorUtility.DisplayCancelableProgressBar("扫描材质", path, (float)i / total))
            {
                EditorUtility.ClearProgressBar();
                foundMaterialPaths.Clear();
                hasScanned = false;
                return;
            }

            var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (mat != null && mat.shader == sourceShader)
                foundMaterialPaths.Add(path);
        }

        EditorUtility.ClearProgressBar();
        Repaint();
    }

    private void ExecuteReplacement()
    {
        // 预先构建 Source Shader 属性名->类型 的查找表
        var sourcePropTypes = BuildShaderPropertyMap(sourceShader);

        // 枚举 Target Shader 的所有属性
        int targetPropCount = ShaderUtil.GetPropertyCount(targetShader);

        int total = foundMaterialPaths.Count;
        int successCount = 0;

        AssetDatabase.StartAssetEditing();
        try
        {
            for (int i = 0; i < total; i++)
            {
                string path = foundMaterialPaths[i];
                EditorUtility.DisplayProgressBar("替换Shader", path, (float)i / total);

                var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (mat == null) continue;

                // Step 1：快照——读取目标Shader中共有属性的当前值
                var snapshot = TakeSnapshot(mat, sourcePropTypes, targetShader, targetPropCount);

                // Step 2：切换 Shader（会重置属性到默认值）
                mat.shader = targetShader;

                // Step 3：写回快照值
                ApplySnapshot(mat, snapshot);

                EditorUtility.SetDirty(mat);
                successCount++;
            }
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
            EditorUtility.ClearProgressBar();
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log($"[MaterialShaderReplacer] 替换完成：{successCount}/{total} 个材质已从 \"{sourceShader.name}\" 替换为 \"{targetShader.name}\"");
        EditorUtility.DisplayDialog("完成", $"成功替换 {successCount} 个材质。", "确定");
    }

    // ────────────────────────────────────────────────────────────
    //  快照结构体：按类型分别存储各属性值
    // ────────────────────────────────────────────────────────────

    private struct PropertySnapshot
    {
        public Dictionary<string, float> floats;
        public Dictionary<string, Color> colors;
        public Dictionary<string, Vector4> vectors;
        public Dictionary<string, Texture> textures;
        public Dictionary<string, int> ints;
    }

    /// <summary>
    /// 读取材质中与 targetShader 共有（且在 sourcePropTypes 中存在、同类型）的属性值快照。
    /// </summary>
    private static PropertySnapshot TakeSnapshot(
        Material mat,
        Dictionary<string, ShaderUtil.ShaderPropertyType> sourcePropTypes,
        Shader targetShader,
        int targetPropCount)
    {
        var snapshot = new PropertySnapshot
        {
            floats = new Dictionary<string, float>(),
            colors = new Dictionary<string, Color>(),
            vectors = new Dictionary<string, Vector4>(),
            textures = new Dictionary<string, Texture>(),
            ints = new Dictionary<string, int>()
        };

        for (int i = 0; i < targetPropCount; i++)
        {
            string propName = ShaderUtil.GetPropertyName(targetShader, i);
            var targetType = ShaderUtil.GetPropertyType(targetShader, i);

            // 必须在 Source Shader 中存在，且类型一致
            if (!sourcePropTypes.TryGetValue(propName, out var sourceType))
                continue;
            if (sourceType != targetType)
                continue;

            switch (targetType)
            {
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:
                    snapshot.floats[propName] = mat.GetFloat(propName);
                    break;
                case ShaderUtil.ShaderPropertyType.Color:
                    snapshot.colors[propName] = mat.GetColor(propName);
                    break;
                case ShaderUtil.ShaderPropertyType.Vector:
                    snapshot.vectors[propName] = mat.GetVector(propName);
                    break;
                case ShaderUtil.ShaderPropertyType.TexEnv:
                    snapshot.textures[propName] = mat.GetTexture(propName);
                    break;
#if UNITY_2021_1_OR_NEWER
                case ShaderUtil.ShaderPropertyType.Int:
                    snapshot.ints[propName] = mat.GetInt(propName);
                    break;
#endif
            }
        }

        return snapshot;
    }

    /// <summary>
    /// 将快照值写回材质。此时材质已切换到 targetShader。
    /// </summary>
    private static void ApplySnapshot(Material mat, PropertySnapshot snapshot)
    {
        foreach (var kv in snapshot.floats)
            mat.SetFloat(kv.Key, kv.Value);

        foreach (var kv in snapshot.colors)
            mat.SetColor(kv.Key, kv.Value);

        foreach (var kv in snapshot.vectors)
            mat.SetVector(kv.Key, kv.Value);

        foreach (var kv in snapshot.textures)
            mat.SetTexture(kv.Key, kv.Value);

        foreach (var kv in snapshot.ints)
            mat.SetInt(kv.Key, kv.Value);
    }

    /// <summary>
    /// 构建 Shader 的属性名 → 属性类型 查找表。
    /// </summary>
    private static Dictionary<string, ShaderUtil.ShaderPropertyType> BuildShaderPropertyMap(Shader shader)
    {
        int count = ShaderUtil.GetPropertyCount(shader);
        var map = new Dictionary<string, ShaderUtil.ShaderPropertyType>(count);
        for (int i = 0; i < count; i++)
        {
            string name = ShaderUtil.GetPropertyName(shader, i);
            map[name] = ShaderUtil.GetPropertyType(shader, i);
        }
        return map;
    }
}
