// 材质相似性分析器已合并到 VFXToolsWindow（见 AssetReferenceFinder.cs）
// 合并日期: 2026.3.27, 使用 Claude Sonnet 4.6
//
// 此文件保留为占位符，功能入口：工具/VFXTools/VFX综合工具箱 → "材质复用" 标签页

#if false // ---- 已合并，暂停编译 ----
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class MaterialSimilarityAnalyzer : EditorWindow
{
    private string targetDirectory = "Assets/VFX/Materials";
    private Vector2 scrollPosition;
    private List<MaterialGroup> materialGroups = new List<MaterialGroup>();
    private bool isAnalyzing = false;
    
    [System.Serializable]
    public class MaterialInfo
    {
        public Material material;
        public string path;
        public Dictionary<string, string> textures = new Dictionary<string, string>();
        public List<string> referencedBy = new List<string>();
        public bool isReferencesExpanded = false; // 新增：控制引用列表展开状态
    }
    
    [System.Serializable]
    public class MaterialGroup
    {
        public List<MaterialInfo> materials = new List<MaterialInfo>();
        public string shaderName;
        public bool isSimilar;
        public bool isExpanded = false;
    }
    
    [MenuItem("工具/VFXTools/特效材质复用分析器")]
    public static void ShowWindow()
    {
        var window = GetWindow<MaterialSimilarityAnalyzer>("检查材质相似度, 指出重复的材质供优化");
        window.titleContent = new GUIContent("相似材质分析", EditorGUIUtility.IconContent("ParticleSystem Icon").image);
    }
    
    void OnGUI()
    {
        GUILayout.Label("材质相似性分析器", EditorStyles.boldLabel);
        EditorGUILayout.Space();
        
        targetDirectory = EditorGUILayout.TextField("目标目录", targetDirectory);
        EditorGUILayout.Space();
        
        GUI.enabled = !isAnalyzing;
        if (GUILayout.Button(isAnalyzing ? "分析中..." : "开始分析材质", GUILayout.Height(30)))
        {
            AnalyzeMaterials();
        }
        GUI.enabled = true;
        
        EditorGUILayout.Space();
        
        if (materialGroups.Count > 0)
        {
            DisplayResults();
        }
    }
    
    private void AnalyzeMaterials()
    {
        isAnalyzing = true;
        materialGroups.Clear();
        
        try
        {
            EditorUtility.DisplayProgressBar("分析材质", "正在查找材质文件...", 0f);
            
            List<MaterialInfo> allMaterials = FindAllMaterials();
            if (allMaterials.Count == 0)
            {
                EditorUtility.DisplayDialog("警告", $"在目录 {targetDirectory} 中未找到材质文件", "确定");
                return;
            }
            
            EditorUtility.DisplayProgressBar("分析材质", "正在分析材质属性...", 0.3f);
            AnalyzeMaterialProperties(allMaterials);
            
            EditorUtility.DisplayProgressBar("分析材质", "正在查找引用关系...", 0.6f);
            FindMaterialReferences(allMaterials);
            
            EditorUtility.DisplayProgressBar("分析材质", "正在分组材质...", 0.8f);
            GroupMaterials(allMaterials);
            
            Debug.Log($"材质分析完成：共分析 {allMaterials.Count} 个材质，发现 {materialGroups.Count} 个分组");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            isAnalyzing = false;
            Repaint();
        }
    }
    
    private List<MaterialInfo> FindAllMaterials()
    {
        List<MaterialInfo> materials = new List<MaterialInfo>();
        
        if (!Directory.Exists(targetDirectory))
        {
            Debug.LogWarning($"目录不存在: {targetDirectory}");
            return materials;
        }
        
        string[] materialGuids = AssetDatabase.FindAssets("t:Material", new[] { targetDirectory });
        
        foreach (string guid in materialGuids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
            
            if (material != null)
            {
                materials.Add(new MaterialInfo
                {
                    material = material,
                    path = path
                });
            }
        }
        
        return materials;
    }
    
    private void AnalyzeMaterialProperties(List<MaterialInfo> materials)
    {
        foreach (var materialInfo in materials)
        {
            Material mat = materialInfo.material;
            if (mat?.shader == null) continue;
            
            Shader shader = mat.shader;
            int propertyCount = ShaderUtil.GetPropertyCount(shader);
            
            for (int i = 0; i < propertyCount; i++)
            {
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                
                if (mat.HasProperty(propertyName))
                {
                    try
                    {
                        Texture tex = mat.GetTexture(propertyName);
                        materialInfo.textures[propertyName] = tex != null ? AssetDatabase.GetAssetPath(tex) : "null";
                    }
                    catch
                    {
                        // 忽略非纹理属性
                    }
                }
            }
        }
    }
    
    private void FindMaterialReferences(List<MaterialInfo> materials)
    {
        // 查找预制体引用
        string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
        
        for (int i = 0; i < prefabGuids.Length; i++)
        {
            if (i % 50 == 0)
            {
                float progress = 0.6f + 0.2f * ((float)i / prefabGuids.Length);
                EditorUtility.DisplayProgressBar("分析材质", $"正在查找引用关系 ({i}/{prefabGuids.Length})", progress);
            }
            
            string prefabPath = AssetDatabase.GUIDToAssetPath(prefabGuids[i]);
            CheckPrefabForMaterialReferences(prefabPath, materials);
        }
        
        // 查找场景引用
        string[] sceneGuids = AssetDatabase.FindAssets("t:Scene");
        foreach (string guid in sceneGuids)
        {
            string scenePath = AssetDatabase.GUIDToAssetPath(guid);
            CheckSceneForMaterialReferences(scenePath, materials);
        }
    }
    
    private void CheckPrefabForMaterialReferences(string prefabPath, List<MaterialInfo> materials)
    {
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
        if (prefab == null) return;
        
        Renderer[] renderers = prefab.GetComponentsInChildren<Renderer>(true);
        
        foreach (Renderer renderer in renderers)
        {
            foreach (Material mat in renderer.sharedMaterials)
            {
                if (mat == null) continue;
                
                var materialInfo = materials.FirstOrDefault(m => m.material == mat);
                if (materialInfo != null && !materialInfo.referencedBy.Contains(prefabPath))
                {
                    materialInfo.referencedBy.Add(prefabPath);
                }
            }
        }
    }
    
    private void CheckSceneForMaterialReferences(string scenePath, List<MaterialInfo> materials)
    {
        string[] dependencies = AssetDatabase.GetDependencies(scenePath, false);
        
        foreach (string dependency in dependencies)
        {
            var materialInfo = materials.FirstOrDefault(m => m.path == dependency);
            if (materialInfo != null && !materialInfo.referencedBy.Contains(scenePath))
            {
                materialInfo.referencedBy.Add(scenePath);
            }
        }
    }
    
    private void GroupMaterials(List<MaterialInfo> materials)
    {
        materialGroups.Clear();
        
        var shaderGroups = materials.GroupBy(m => m.material.shader.name);
        
        foreach (var shaderGroup in shaderGroups)
        {
            string shaderName = shaderGroup.Key;
            List<MaterialInfo> shaderMaterials = shaderGroup.ToList();
            
            var similarGroups = FindSimilarMaterials(shaderMaterials);
            
            // 仅添加相似材质组（2个或以上的材质）
            foreach (var similarGroup in similarGroups.Where(g => g.Count > 1))
            {
                // 按引用数量降序排列，引用最多的排在首位
                similarGroup.Sort((a, b) => b.referencedBy.Count.CompareTo(a.referencedBy.Count));
                
                materialGroups.Add(new MaterialGroup
                {
                    materials = similarGroup,
                    shaderName = $"{shaderName} - 相似组 ({similarGroup.Count}个)",
                    isSimilar = true
                });
            }
        }
        
        // 按相似组数量从高到低排序
        materialGroups.Sort((a, b) => b.materials.Count.CompareTo(a.materials.Count));
    }
    
    private List<List<MaterialInfo>> FindSimilarMaterials(List<MaterialInfo> materials)
    {
        List<List<MaterialInfo>> groups = new List<List<MaterialInfo>>();
        List<MaterialInfo> processed = new List<MaterialInfo>();
        
        foreach (var material in materials)
        {
            if (processed.Contains(material)) continue;
            
            List<MaterialInfo> similarGroup = new List<MaterialInfo> { material };
            processed.Add(material);
            
            foreach (var otherMaterial in materials)
            {
                if (processed.Contains(otherMaterial)) continue;
                
                if (AreTexturesSimilar(material, otherMaterial))
                {
                    similarGroup.Add(otherMaterial);
                    processed.Add(otherMaterial);
                }
            }
            
            groups.Add(similarGroup);
        }
        
        return groups;
    }
    
    private bool AreTexturesSimilar(MaterialInfo mat1, MaterialInfo mat2)
    {
        if (mat1.textures.Count == 0 && mat2.textures.Count == 0) return false;
        if (mat1.textures.Count != mat2.textures.Count) return false;
        
        foreach (var kvp in mat1.textures)
        {
            if (!mat2.textures.ContainsKey(kvp.Key) || mat2.textures[kvp.Key] != kvp.Value)
                return false;
        }
        
        return true;
    }
    
    private Color GetGroupColor(int materialCount)
    {
        if (materialCount >= 10)
            return Color.red;
        else if (materialCount >= 5)
            return new Color(128,128,0);
        else
            return new Color(128,128,128);
    }
    
    private void DisplayResults()
    {
        EditorGUILayout.LabelField($"分析结果 (共{materialGroups.Count}组)", EditorStyles.boldLabel);
        
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
        
        foreach (var group in materialGroups)
        {
            GUIStyle groupStyle = new GUIStyle(EditorStyles.foldout)
            {
                fontStyle = FontStyle.Bold
            };
            groupStyle.normal.textColor = GetGroupColor(group.materials.Count);
            
            string warningIcon = "";
            if (group.materials.Count >= 10)
                warningIcon = "- ///严重重复/// -";
            else if (group.materials.Count >= 5)
                warningIcon = "- ///中度重复/// -";
            else
                warningIcon = "- ///轻度重复/// -";

            string groupTitle = group.shaderName + warningIcon;
            
            // 修改这里：使用可点击的区域包围整个标题
            Rect foldoutRect = GUILayoutUtility.GetRect(new GUIContent(groupTitle), groupStyle);
            group.isExpanded = EditorGUI.Foldout(foldoutRect, group.isExpanded, groupTitle, true, groupStyle);
            
            if (group.isExpanded)
            {
                EditorGUI.indentLevel++;
                foreach (var materialInfo in group.materials)
                {
                    DisplayMaterialInfo(materialInfo);
                }
                EditorGUI.indentLevel--;
                EditorGUILayout.Space();
            }
        }
        
        EditorGUILayout.EndScrollView();
        DisplayStatistics();
    }
    
    private void DisplayMaterialInfo(MaterialInfo materialInfo)
    {
        EditorGUILayout.BeginVertical(GUI.skin.box);
        EditorGUILayout.BeginHorizontal();
        
        EditorGUILayout.ObjectField("", materialInfo.material, typeof(Material), false, GUILayout.Width(200));
        
        EditorGUILayout.BeginVertical();
        EditorGUILayout.LabelField(materialInfo.material.name, EditorStyles.boldLabel);
        EditorGUILayout.LabelField(materialInfo.path, EditorStyles.miniLabel);
        EditorGUILayout.LabelField($"引用数量: {materialInfo.referencedBy.Count}", EditorStyles.miniLabel);
        EditorGUILayout.EndVertical();
        
        if (GUILayout.Button("定位", GUILayout.Width(50)))
        {
            EditorGUIUtility.PingObject(materialInfo.material);
            Selection.activeObject = materialInfo.material;
        }
        
        EditorGUILayout.EndHorizontal();
        
        // 修改引用列表显示逻辑，添加折叠功能
        if (materialInfo.referencedBy.Count > 0)
        {
            EditorGUI.indentLevel++;
            
            // 使用 Foldout 控制引用列表的展开/收拢
            string foldoutLabel = $"引用列表 ({materialInfo.referencedBy.Count}个)";
            materialInfo.isReferencesExpanded = EditorGUILayout.Foldout(
                materialInfo.isReferencesExpanded, 
                foldoutLabel, 
                EditorStyles.foldout
            );
            
            // 只有在展开状态下才显示引用列表
            if (materialInfo.isReferencesExpanded)
            {
                foreach (string reference in materialInfo.referencedBy)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("• " + Path.GetFileName(reference), EditorStyles.miniLabel);
                    
                    if (GUILayout.Button("查看", EditorStyles.miniButton, GUILayout.Width(40)))
                    {
                        Object referencedObject = AssetDatabase.LoadAssetAtPath<Object>(reference);
                        if (referencedObject != null)
                        {
                            EditorGUIUtility.PingObject(referencedObject);
                            Selection.activeObject = referencedObject;
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            
            EditorGUI.indentLevel--;
        }
        
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
    }
    
    private void DisplayStatistics()
    {
        EditorGUILayout.Space();
        int duplicateMaterials = materialGroups.Sum(g => g.materials.Count);
        int severeGroups = materialGroups.Count(g => g.materials.Count >= 10);
        int moderateGroups = materialGroups.Count(g => g.materials.Count >= 5 && g.materials.Count < 10);
        int lightGroups = materialGroups.Count(g => g.materials.Count < 5);
        
        string statsText = $"统计信息:\n" +
                          $"• 相似材质组: {materialGroups.Count}\n" +
                          $"• 🔴 严重重复组 (≥10个): {severeGroups}\n" +
                          $"• 🟡 中度重复组 (5-9个): {moderateGroups}\n" +
                          $"• 🔵 轻度重复组 (2-4个): {lightGroups}\n" +
                          $"• 可优化材质数: {duplicateMaterials}\n" +
                          $"• 潜在节省: {duplicateMaterials - materialGroups.Count} 个材质";

        MessageType messageType = severeGroups > 0 ? MessageType.Error : 
                                 moderateGroups > 0 ? MessageType.Warning : MessageType.Info;

        
        
        EditorGUILayout.HelpBox(statsText, messageType);
    }
}
#endif // ---- 已合并 ----