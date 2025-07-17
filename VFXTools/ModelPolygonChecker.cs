using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class ModelPolygonChecker : EditorWindow
{
    private int thresholdPolygonCount = 10000; // 面数阈值，超过此值的模型将被列出
    private int displayCount = 10; // 显示的高面数模型数量
    private List<ModelInfo> highPolyModels = new List<ModelInfo>();
    private Vector2 scrollPosition;
    private bool isScanning = false;
    private Dictionary<string, List<string>> modelReferences = new Dictionary<string, List<string>>();
    private bool[] foldoutStates;
    
    [MenuItem("工具/VFXTools/模型面数检查器")]
    static void ShowWindow()
    {
        GetWindow<ModelPolygonChecker>("模型面数检查器");
    }

    public class ModelInfo
    {
        public string path;
        public string name;
        public int triangleCount;
        public int vertexCount;
    }

    void OnGUI()
    {
        GUILayout.Label("模型面数检查工具", EditorStyles.boldLabel);
        
        EditorGUILayout.Space();
        
        thresholdPolygonCount = EditorGUILayout.IntField("面数阈值", thresholdPolygonCount);
        displayCount = EditorGUILayout.IntField("显示数量", displayCount);
        
        EditorGUILayout.Space();
        
        if (GUILayout.Button("扫描项目中的模型") && !isScanning)
        {
            isScanning = true;
            highPolyModels.Clear();
            modelReferences.Clear();
            EditorApplication.delayCall += () => {
                ScanModels();
                FindModelReferences();
                isScanning = false;
                // 初始化折叠状态数组
                foldoutStates = new bool[highPolyModels.Count];
            };
        }

        EditorGUILayout.Space();
        
        if (isScanning)
        {
            EditorGUILayout.HelpBox("正在扫描中...", MessageType.Info);
        }
        else if (highPolyModels.Count > 0)
        {
            GUILayout.Label($"面数超过 {thresholdPolygonCount} 的模型（显示前 {displayCount} 个）：", EditorStyles.boldLabel);
            
            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
            
            for (int i = 0; i < Mathf.Min(displayCount, highPolyModels.Count); i++)
            {
                ModelInfo model = highPolyModels[i];
                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                
                GUILayout.Label($"名称: {model.name}", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("三角形数量:", model.triangleCount.ToString("N0"));
                EditorGUILayout.LabelField("顶点数量:", model.vertexCount.ToString("N0"));
                EditorGUILayout.LabelField("路径:", model.path);
                
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("定位模型", GUILayout.Width(100)))
                {
                    Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(model.path);
                    EditorGUIUtility.PingObject(Selection.activeObject);
                }

                // 导出引用列表按钮
                if (modelReferences.ContainsKey(model.path) && modelReferences[model.path].Count > 0)
                {
                    if (GUILayout.Button("导出引用列表", GUILayout.Width(120)))
                    {
                        string savePath = EditorUtility.SaveFilePanel("保存引用列表", "", model.name + "_引用列表", "txt");
                        if (!string.IsNullOrEmpty(savePath))
                        {
                            ExportReferences(savePath, model.path, model.name);
                        }
                    }
                }
                EditorGUILayout.EndHorizontal();

                // 显示引用信息
                if (modelReferences.ContainsKey(model.path))
                {
                    var references = modelReferences[model.path];
                    
                    if (references.Count == 0)
                    {
                        EditorGUILayout.HelpBox("此模型在场景和预制体中没有被引用", MessageType.Info);
                    }
                    else
                    {
                        if (foldoutStates == null || i >= foldoutStates.Length)
                        {
                            foldoutStates = new bool[highPolyModels.Count];
                        }
                        
                        foldoutStates[i] = EditorGUILayout.Foldout(foldoutStates[i], $"引用列表 ({references.Count}个引用)", true);
                        
                        if (foldoutStates[i])
                        {
                            EditorGUI.indentLevel++;
                            foreach (var reference in references)
                            {
                                EditorGUILayout.BeginHorizontal();
                                EditorGUILayout.LabelField(reference);
                                
                                if (GUILayout.Button("定位", GUILayout.Width(60)))
                                {
                                    Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(reference);
                                    EditorGUIUtility.PingObject(Selection.activeObject);
                                }
                                EditorGUILayout.EndHorizontal();
                            }
                            EditorGUI.indentLevel--;
                        }
                    }
                }
                
                EditorGUILayout.EndVertical();
                EditorGUILayout.Space();
            }
            
            EditorGUILayout.EndScrollView();
        }
    }

    void ScanModels()
    {
        string[] modelPaths = AssetDatabase.FindAssets("t:Model")
            .Select(guid => AssetDatabase.GUIDToAssetPath(guid))
            .ToArray();
        
        List<ModelInfo> allModels = new List<ModelInfo>();
        
        foreach (string path in modelPaths)
        {
            ModelImporter modelImporter = AssetImporter.GetAtPath(path) as ModelImporter;
            if (modelImporter == null) continue;
            
            // 加载模型资源
            GameObject modelObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (modelObj == null) continue;
            
            // 获取模型的所有网格
            Mesh[] meshes = GetAllMeshesFromModel(modelObj);
            
            int totalTriangles = 0;
            int totalVertices = 0;
            
            foreach (Mesh mesh in meshes)
            {
                if (mesh != null)
                {
                    totalTriangles += mesh.triangles.Length / 3;
                    totalVertices += mesh.vertexCount;
                }
            }
            
            // 如果面数超过阈值，添加到高面模型列表
            if (totalTriangles >= thresholdPolygonCount)
            {
                allModels.Add(new ModelInfo
                {
                    path = path,
                    name = Path.GetFileNameWithoutExtension(path),
                    triangleCount = totalTriangles,
                    vertexCount = totalVertices
                });
            }
        }
        
        // 按面数从高到低排序
        highPolyModels = allModels.OrderByDescending(m => m.triangleCount).ToList();
        
        Debug.Log($"扫描完成：发现 {highPolyModels.Count} 个高面数模型（面数 >= {thresholdPolygonCount}）");
    }

    void FindModelReferences()
    {
        EditorUtility.DisplayProgressBar("查找引用", "正在查找模型引用...", 0f);

        // 初始化每个高面数模型的引用列表
        foreach (var model in highPolyModels)
        {
            modelReferences[model.path] = new List<string>();
        }

        try
        {
            // 查找所有预制体
            string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
            for (int i = 0; i < prefabGuids.Length; i++)
            {
                string prefabPath = AssetDatabase.GUIDToAssetPath(prefabGuids[i]);
                CheckForReferences(prefabPath);
                
                float progress = (float)i / prefabGuids.Length;
                EditorUtility.DisplayProgressBar("查找引用", $"正在查找引用: {prefabPath}", progress);
            }

            // 查找所有场景
            string[] sceneGuids = AssetDatabase.FindAssets("t:Scene");
            for (int i = 0; i < sceneGuids.Length; i++)
            {
                string scenePath = AssetDatabase.GUIDToAssetPath(sceneGuids[i]);
                CheckForReferences(scenePath);
                
                float progress = (float)i / sceneGuids.Length;
                EditorUtility.DisplayProgressBar("查找引用", $"正在查找引用: {scenePath}", progress);
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }

        Debug.Log("模型引用查找完成");
    }

    void CheckForReferences(string assetPath)
    {
        // 对于每个高面数模型，检查它是否被这个资源引用
        foreach (var model in highPolyModels)
        {
            Object modelAsset = AssetDatabase.LoadAssetAtPath<Object>(model.path);
            if (modelAsset == null) continue;

            // 查找依赖关系
            string[] dependencies = AssetDatabase.GetDependencies(assetPath, false);
            if (dependencies.Contains(model.path))
            {
                if (!modelReferences[model.path].Contains(assetPath))
                {
                    modelReferences[model.path].Add(assetPath);
                }
            }
        }
    }

    private Mesh[] GetAllMeshesFromModel(GameObject model)
    {
        List<Mesh> meshes = new List<Mesh>();
        
        // 获取当前游戏对象的网格过滤器组件
        MeshFilter[] meshFilters = model.GetComponentsInChildren<MeshFilter>(true);
        foreach (MeshFilter meshFilter in meshFilters)
        {
            if (meshFilter.sharedMesh != null)
            {
                meshes.Add(meshFilter.sharedMesh);
            }
        }
        
        // 获取当前游戏对象的骨骼蒙皮网格组件
        SkinnedMeshRenderer[] skinnedMeshRenderers = model.GetComponentsInChildren<SkinnedMeshRenderer>(true);
        foreach (SkinnedMeshRenderer renderer in skinnedMeshRenderers)
        {
            if (renderer.sharedMesh != null)
            {
                meshes.Add(renderer.sharedMesh);
            }
        }
        
        return meshes.ToArray();
    }

    // 导出引用列表到文本文件
    private void ExportReferences(string savePath, string modelPath, string modelName)
    {
        if (modelReferences.ContainsKey(modelPath))
        {
            using (StreamWriter writer = new StreamWriter(savePath))
            {
                writer.WriteLine($"模型: {modelName}");
                writer.WriteLine($"路径: {modelPath}");
                writer.WriteLine($"引用数量: {modelReferences[modelPath].Count}");
                writer.WriteLine("==================================");
                
                foreach (var reference in modelReferences[modelPath])
                {
                    writer.WriteLine(reference);
                }
            }
            
            Debug.Log($"引用列表已导出到: {savePath}");
        }
    }
}
