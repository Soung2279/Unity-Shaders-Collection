using UnityEngine;
using UnityEditor;

public class ParticleSystemSpawner : EditorWindow
{
    [SerializeField]
    private GameObject particleSystemPrefab;
    
    [MenuItem("工具/VFXTools/空特效生成")]
    public static void ShowWindow()
    {
        var window = GetWindow<ParticleSystemSpawner>("一键生成空特效");
        window.titleContent = new GUIContent("一键生成空特效", EditorGUIUtility.IconContent("ParticleSystem Icon").image);
    }
    
    private void OnGUI()
    {
        GUILayout.Label("SampleVFX Spawner", EditorStyles.boldLabel);
        
        EditorGUILayout.Space();
        
        // 预制体选择字段
        particleSystemPrefab = (GameObject)EditorGUILayout.ObjectField(
            "模板预制体", 
            particleSystemPrefab, 
            typeof(GameObject), 
            false
        );
        
        EditorGUILayout.Space();
        
        // 生成按钮
        GUI.enabled = particleSystemPrefab != null;
        if (GUILayout.Button("一键生成空特效", GUILayout.Height(30)))
        {
            SpawnParticleSystem();
        }
        GUI.enabled = true;
        
        if (particleSystemPrefab == null)
        {
            EditorGUILayout.HelpBox("请先选择一个模板预制体", MessageType.Warning);
        }
    }
    
    private void SpawnParticleSystem()
    {
        if (particleSystemPrefab == null)
        {
            Debug.LogWarning("请先选择模板预制体！");
            return;
        }
        
        // 先实例化预制体
        GameObject tempInstance = PrefabUtility.InstantiatePrefab(particleSystemPrefab) as GameObject;
        
        if (tempInstance != null)
        {
            // 创建一个全新的GameObject
            GameObject newGameObject = new GameObject(particleSystemPrefab.name);
            
            // 复制Transform属性
            newGameObject.transform.position = tempInstance.transform.position;
            newGameObject.transform.rotation = tempInstance.transform.rotation;
            newGameObject.transform.localScale = tempInstance.transform.localScale;
            
            // 复制所有组件
            Component[] components = tempInstance.GetComponents<Component>();
            foreach (Component comp in components)
            {
                if (comp is Transform) continue; // 跳过Transform组件
                
                // 复制组件到新的GameObject
                UnityEditorInternal.ComponentUtility.CopyComponent(comp);
                UnityEditorInternal.ComponentUtility.PasteComponentAsNew(newGameObject);
            }
            
            // 递归复制子对象
            CopyChildren(tempInstance.transform, newGameObject.transform);
            
            // 删除临时实例
            DestroyImmediate(tempInstance);
            
            // 设置为层级最下层（最后一个子对象）
            newGameObject.transform.SetAsLastSibling();
            
            // 注册撤销操作
            Undo.RegisterCreatedObjectUndo(newGameObject, "Create New VFX GameObject");
            
            // 选中新创建的对象
            Selection.activeGameObject = newGameObject;
            
            // 延迟进入重命名状态
            EditorApplication.delayCall += () =>
            {
                // 确保Hierarchy窗口获得焦点
                EditorApplication.ExecuteMenuItem("Window/General/Hierarchy");
                
                // 进入重命名状态
                EditorApplication.delayCall += () =>
                {
                    var hierarchyWindow = EditorWindow.GetWindow(System.Type.GetType("UnityEditor.SceneHierarchyWindow,UnityEditor"));
                    if (hierarchyWindow != null)
                    {
                        hierarchyWindow.SendEvent(EditorGUIUtility.CommandEvent("Rename"));
                    }
                };
            };
            
            Debug.Log($"成功生成新的空特效GameObject: {newGameObject.name}");
        }
        else
        {
            Debug.LogError("无法实例化模板预制体！");
        }
    }
    
    private void CopyChildren(Transform source, Transform destination)
    {
        for (int i = 0; i < source.childCount; i++)
        {
            Transform child = source.GetChild(i);
            
            // 创建新的子对象
            GameObject newChild = new GameObject(child.name);
            newChild.transform.SetParent(destination);
            
            // 复制Transform属性
            newChild.transform.localPosition = child.localPosition;
            newChild.transform.localRotation = child.localRotation;
            newChild.transform.localScale = child.localScale;
            
            // 复制所有组件
            Component[] components = child.GetComponents<Component>();
            foreach (Component comp in components)
            {
                if (comp is Transform) continue; // 跳过Transform组件
                
                // 复制组件到新的子对象
                UnityEditorInternal.ComponentUtility.CopyComponent(comp);
                UnityEditorInternal.ComponentUtility.PasteComponentAsNew(newChild);
            }
            
            // 递归处理子对象的子对象
            if (child.childCount > 0)
            {
                CopyChildren(child, newChild.transform);
            }
        }
    }
}