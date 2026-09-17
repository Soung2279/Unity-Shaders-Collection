using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using YooAsset.Editor;

public static class ShaderVariantCollector
{
    private enum ESteps
    {
        None,
        Prepare,
        CollectAllMaterial,
        CollectVariants,
        CollectSleeping,
        WaitingDone,
    }

    private const float WaitMilliseconds = 3000f;
    private const float SleepMilliseconds = 3000f;
    private static string _savePath;
    private static string _packageName;
    private static int _processMaxNum;
    private static Action _completedCallback;
    private static ShaderVariantCollectionManifest _previousManifest;
    private static SceneSetup[] _previousSceneSetup;

    private static ESteps _steps = ESteps.None;
    private static Stopwatch _elapsedTime;
    private static List<string> _allMaterials;
    private static List<GameObject> _allSpheres = new List<GameObject>(1000);


    /// <summary>
    /// 开始收集
    /// </summary>
    public static void Run(string savePath, string packageName, int processMaxNum, Action completedCallback)
    {
        if (_steps != ESteps.None)
            return;

        if (Path.HasExtension(savePath) == false)
            savePath = $"{savePath}.shadervariants";
        if (Path.GetExtension(savePath) != ".shadervariants")
            throw new System.Exception("Shader variant file extension is invalid.");
        if (string.IsNullOrEmpty(packageName))
            throw new System.Exception("Package name is null or empty !");

        // 切换到临时场景前保存并记录当前场景布局，收集结束后恢复。
        if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo() == false)
            return;
        _previousSceneSetup = EditorSceneManager.GetSceneManagerSetup();

        // 删除旧文件前保留快照，用于生成本次收集相对上一次的变化历史。
        _previousManifest = LoadManifest(savePath);

        // 注意：先删除再保存，否则ShaderVariantCollection内容将无法及时刷新
        AssetDatabase.DeleteAsset(savePath);
        EditorTools.CreateFileDirectory(savePath);
        _savePath = savePath;
        _packageName = packageName;
        _processMaxNum = processMaxNum;
        _completedCallback = completedCallback;

        // 聚焦到游戏窗口
        EditorTools.FocusUnityGameWindow();

        // 创建临时测试场景
        CreateTempScene();

        _steps = ESteps.Prepare;
        EditorApplication.update += EditorUpdate;
    }

    private static void EditorUpdate()
    {
        if (_steps == ESteps.None)
            return;

        if (_steps == ESteps.Prepare)
        {
            ShaderVariantCollectionHelper.ClearCurrentShaderVariantCollection();
            _steps = ESteps.CollectAllMaterial;
            return; //等待一帧
        }

        if (_steps == ESteps.CollectAllMaterial)
        {
            _allMaterials = GetAllMaterials();
            _steps = ESteps.CollectVariants;
            return; //等待一帧
        }

        if (_steps == ESteps.CollectVariants)
        {
            int count = Mathf.Min(_processMaxNum, _allMaterials.Count);
            List<string> range = _allMaterials.GetRange(0, count);
            _allMaterials.RemoveRange(0, count);
            CollectVariants(range);

            if (_allMaterials.Count > 0)
            {
                _elapsedTime = Stopwatch.StartNew();
                _steps = ESteps.CollectSleeping;
            }
            else
            {
                _elapsedTime = Stopwatch.StartNew();
                _steps = ESteps.WaitingDone;
            }
        }

        if (_steps == ESteps.CollectSleeping)
        {
            if (ShaderUtil.anythingCompiling)
                return;

            if (_elapsedTime.ElapsedMilliseconds > SleepMilliseconds)
            {
                DestroyAllSpheres();
                _elapsedTime.Stop();
                _steps = ESteps.CollectVariants;
            }
        }

        if (_steps == ESteps.WaitingDone)
        {
            // 注意：一定要延迟保存才会起效
            if (_elapsedTime.ElapsedMilliseconds > WaitMilliseconds)
            {
                _elapsedTime.Stop();
                _steps = ESteps.None;

                // 保存结果并创建清单
                ShaderVariantCollectionHelper.SaveCurrentShaderVariantCollection(_savePath);
                FilterSavedCollection();
                ShaderVariantCollectionManifest currentManifest = CreateManifest();
                ShaderVariantCollectionHistory.Record(_savePath, _packageName, _previousManifest, currentManifest);

                UnityEngine.Debug.Log($"搜集SVC完毕！");
                EditorApplication.update -= EditorUpdate;
                RestorePreviousScenes();
                _completedCallback?.Invoke();
            }
        }
    }
    private static void CreateTempScene()
    {
        EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
    }

    private static void RestorePreviousScenes()
    {
        DestroyAllSpheres();
        if (_previousSceneSetup == null || _previousSceneSetup.Length == 0)
            return;

        EditorSceneManager.RestoreSceneManagerSetup(_previousSceneSetup);
        _previousSceneSetup = null;
    }
    private static List<string> GetAllMaterials()
    {
        // 获取所有打包的资源
        CollectResult collectResult = AssetBundleCollectorSettingData.Setting.BeginCollect(_packageName, false, false);

        // 搜集所有材质球
        int progressValue = 0;
        HashSet<string> result = new HashSet<string>();
        foreach (var collectAssetInfo in collectResult.CollectAssets)
        {
            if (collectAssetInfo.AssetInfo.AssetType == typeof(UnityEngine.Material))
            {
                string assetPath = collectAssetInfo.AssetInfo.AssetPath;
                if (result.Contains(assetPath) == false)
                    result.Add(assetPath);
            }
            foreach(var dependAssetInfo in collectAssetInfo.DependAssets)
            {
                if (dependAssetInfo.AssetType == typeof(UnityEngine.Material))
                {
                    string assetPath = dependAssetInfo.AssetPath;
                    if (result.Contains(assetPath) == false)
                        result.Add(assetPath);
                }
            }
            EditorTools.DisplayProgressBar("搜集所有材质球", ++progressValue, collectResult.CollectAssets.Count);
        }
        EditorTools.ClearProgressBar();

        // 返回结果
        return result.ToList();
    }
    private static void CollectVariants(List<string> materials)
    {
        Camera camera = Camera.main;
        if (camera == null)
            throw new System.Exception("Not found main camera.");

        // 设置主相机
        float aspect = camera.aspect;
        int totalMaterials = materials.Count;
        float height = Mathf.Sqrt(totalMaterials / aspect) + 1;
        float width = Mathf.Sqrt(totalMaterials / aspect) * aspect + 1;
        float halfHeight = Mathf.CeilToInt(height / 2f);
        float halfWidth = Mathf.CeilToInt(width / 2f);
        camera.orthographic = true;
        camera.orthographicSize = halfHeight;
        camera.transform.position = new Vector3(0f, 0f, -10f);

        // 创建测试球体
        int xMax = (int)(width - 1);
        int x = 0, y = 0;
        int progressValue = 0;
        for (int i = 0; i < materials.Count; i++)
        {
            var material = materials[i];
            var position = new Vector3(x - halfWidth + 1f, y - halfHeight + 1f, 0f);
            var go = CreateSphere(material, position, i);
            if (go != null)
                _allSpheres.Add(go);
            if (x == xMax)
            {
                x = 0;
                y++;
            }
            else
            {
                x++;
            }
            EditorTools.DisplayProgressBar("照射所有材质球", ++progressValue, materials.Count);
        }
        EditorTools.ClearProgressBar();
    }
    private static GameObject CreateSphere(string assetPath, Vector3 position, int index)
    {
        var material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
        var shader = material.shader;
        if (shader == null)
            return null;

        var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        go.GetComponent<Renderer>().sharedMaterial = material;
        go.transform.position = position;
        go.name = $"Sphere_{index} | {material.name}";
        return go;
    }
    private static void DestroyAllSpheres()
    {
        foreach (var go in _allSpheres)
        {
            GameObject.DestroyImmediate(go);
        }
        _allSpheres.Clear();

        // 不在此处强制卸载未使用资源。UI Toolkit 的动态 FontAsset/Atlas 可能未被原生引用追踪，
        // 强制卸载会导致已打开的编辑器窗口在后续文本布局时抛 MissingReferenceException。
    }
    private static void FilterSavedCollection()
    {
        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);

        ShaderVariantCollection collection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(_savePath);
        if (collection == null)
            throw new Exception($"Failed to load ShaderVariantCollection : {_savePath}");

        using (var serializedObject = new SerializedObject(collection))
        {
            SerializedProperty shaders = serializedObject.FindProperty("m_Shaders");
            HashSet<Shader> alwaysIncludedShaders = GetAlwaysIncludedShaders();
            int hiddenShaderCount = 0;
            int alwaysIncludedShaderCount = 0;
            int ignoredVariantCount = 0;

            for (int i = shaders.arraySize - 1; i >= 0; i--)
            {
                SerializedProperty shaderEntry = shaders.GetArrayElementAtIndex(i);
                Shader shader = shaderEntry.FindPropertyRelative("first").objectReferenceValue as Shader;
                bool isHidden = shader == null || ShouldIgnoreShader(shader.name);
                bool isAlwaysIncluded = shader != null && alwaysIncludedShaders.Contains(shader);
                if (isHidden || isAlwaysIncluded)
                {
                    SerializedProperty variants = shaderEntry.FindPropertyRelative("second.variants");
                    ignoredVariantCount += variants != null ? variants.arraySize : 0;
                    if (isAlwaysIncluded)
                        alwaysIncludedShaderCount++;
                    else
                        hiddenShaderCount++;
                    shaders.DeleteArrayElementAtIndex(i);
                }
            }

            int ignoredShaderCount = hiddenShaderCount + alwaysIncludedShaderCount;
            if (ignoredShaderCount > 0)
            {
                serializedObject.ApplyModifiedProperties();
                EditorUtility.SetDirty(collection);
                AssetDatabase.SaveAssets();
            }

            UnityEngine.Debug.Log(
                $"SVC过滤完成：忽略 {ignoredShaderCount} 个Shader，{ignoredVariantCount} 个变体。" +
                $" Hidden/：{hiddenShaderCount}，Always Included：{alwaysIncludedShaderCount}。");
        }
    }

    private static HashSet<Shader> GetAlwaysIncludedShaders()
    {
        var result = new HashSet<Shader>();
        UnityEngine.Object[] graphicsSettingsAssets = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/GraphicsSettings.asset");
        UnityEngine.Object graphicsSettings = graphicsSettingsAssets.FirstOrDefault();
        if (graphicsSettings == null)
            return result;

        using (var serializedObject = new SerializedObject(graphicsSettings))
        {
            SerializedProperty shaders = serializedObject.FindProperty("m_AlwaysIncludedShaders");
            if (shaders == null || shaders.isArray == false)
                return result;

            for (int i = 0; i < shaders.arraySize; i++)
            {
                Shader shader = shaders.GetArrayElementAtIndex(i).objectReferenceValue as Shader;
                if (shader != null)
                    result.Add(shader);
            }
        }
        return result;
    }

    private static bool ShouldIgnoreShader(string shaderName)
    {
        return shaderName.StartsWith("Hidden/", StringComparison.Ordinal);
    }

    private static ShaderVariantCollectionManifest LoadManifest(string collectionPath)
    {
        ShaderVariantCollection collection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(collectionPath);
        if (collection == null)
            return null;

        try
        {
            return ShaderVariantCollectionManifest.Extract(collection);
        }
        catch (Exception exception)
        {
            UnityEngine.Debug.LogWarning($"读取上一次SVC失败，本次历史将按首次收集记录：{exception.Message}");
            return null;
        }
    }

    private static ShaderVariantCollectionManifest CreateManifest()
    {
        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);

        ShaderVariantCollection svc = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(_savePath);
        if (svc == null)
            throw new Exception($"Failed to load ShaderVariantCollection : {_savePath}");

        var wrapper = ShaderVariantCollectionManifest.Extract(svc);
        string jsonData = JsonUtility.ToJson(wrapper, true);
        string savePath = _savePath.Replace(".shadervariants", ".json");
        File.WriteAllText(savePath, jsonData);
        AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
        return wrapper;
    }
}