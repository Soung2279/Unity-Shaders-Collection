using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR
namespace Game.Editor.VFXTools.Preview.VFXPresetSpawn
{
public class ParticleSystemSpawner : EditorWindow
{
    // ===================== 枚举 & 数据结构 =====================

    public enum FunctionType { 弹体, 受击, 爆炸, 拖尾 }
    public enum AttributeType { 冰, 火, 毒, 电, 无属性 }
    public enum WeaponType { 通用, 刀剑, 枪棍, 法器, 弓弩 }

    [System.Serializable]
    public class VFXPresetData
    {
        public string function;
        public string attribute;
        public string weapon;
        public string prefabName;
        public string prefabPath;
    }

    [System.Serializable]
    private class VFXPresetList
    {
        public List<VFXPresetData> presets = new List<VFXPresetData>();
    }

    [System.Serializable]
    public class VFXPresetEntry
    {
        public FunctionType function;
        public AttributeType attribute;
        public WeaponType weapon;
        public GameObject prefab;
    }

    // ===================== 常量 =====================

    private static readonly string[] TAB_NAMES = { "空特效生成", "预设特效生成" };
    private const string DEFAULT_JSON_PATH = "Assets/Editor/VFXTools/Preview/VFXPresetSpawn/VFXPresets.json";

    // ===================== 字段 =====================

    [SerializeField] private int selectedTab;
    [SerializeField] private GameObject particleSystemPrefab;
    [SerializeField] private FunctionType selectedFunction;
    [SerializeField] private AttributeType selectedAttribute;
    [SerializeField] private WeaponType selectedWeapon;
    [SerializeField] private string jsonConfigPath = DEFAULT_JSON_PATH;
    [SerializeField] private bool showPresetConfig = true;
    [SerializeField] private List<VFXPresetEntry> presetEntries = new List<VFXPresetEntry>();
    // 缓存匹配到的预制体引用（序列化，等同于 Tab1 的 particleSystemPrefab）
    [SerializeField] private GameObject cachedMatchedPrefab;

    private Vector2 presetScrollPos;
    private VFXPresetList loadedPresets;

    // ===================== 菜单入口 =====================

    [MenuItem("TATools/VFXTools/Preview/预设特效生成")]
    public static void ShowWindow()
    {
        var window = GetWindow<ParticleSystemSpawner>("生成预设特效");
        window.titleContent = new GUIContent("生成预设特效", EditorGUIUtility.IconContent("ParticleSystem Icon").image);
    }

    private void OnEnable()
    {
        LoadJsonConfig();
        UpdateCachedMatchedPrefab();
    }

    // ===================== OnGUI =====================

        private void OnGUI()
        {
            selectedTab = GUILayout.Toolbar(selectedTab, TAB_NAMES);
            EditorGUILayout.Space(4);

            if (selectedTab == 0)
                DrawEmptyVFXTab();
            else
                DrawPresetVFXTab();
        }

    // ===================== Tab 1：空特效生成 =====================

    private void DrawEmptyVFXTab()
    {
        GUILayout.Label("SampleVFX Spawner", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        particleSystemPrefab = (GameObject)EditorGUILayout.ObjectField(
            "模板预制体",
            particleSystemPrefab,
            typeof(GameObject),
            false
        );

        EditorGUILayout.Space();

        GUI.enabled = particleSystemPrefab != null;
        if (GUILayout.Button("一键生成空特效", GUILayout.Height(30)))
            SpawnParticleSystem(particleSystemPrefab);
        GUI.enabled = true;

        if (particleSystemPrefab == null)
            EditorGUILayout.HelpBox("请先选择一个模板预制体", MessageType.Warning);
    }

    // ===================== Tab 2：预设特效生成 =====================

    private void DrawPresetVFXTab()
    {
        GUILayout.Label("预设特效生成", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        EditorGUI.BeginChangeCheck();
        selectedFunction  = (FunctionType)EditorGUILayout.EnumPopup("功能", selectedFunction);
        GUI.backgroundColor = GetAttributeColor(selectedAttribute);
        selectedAttribute = (AttributeType)EditorGUILayout.EnumPopup("属性", selectedAttribute);
        GUI.backgroundColor = Color.white;
        selectedWeapon    = (WeaponType)EditorGUILayout.EnumPopup("武器", selectedWeapon);
        if (EditorGUI.EndChangeCheck())
            UpdateCachedMatchedPrefab();

        EditorGUILayout.Space();

        GUI.enabled = cachedMatchedPrefab != null;
        if (GUILayout.Button("生成预设特效", GUILayout.Height(30)))
            SpawnParticleSystem(cachedMatchedPrefab);
        GUI.enabled = true;

        if (cachedMatchedPrefab == null)
            EditorGUILayout.HelpBox(
                $"未找到匹配的预设：{selectedFunction} / {selectedAttribute} / {selectedWeapon}",
                MessageType.Warning);
        else
            EditorGUILayout.HelpBox($"已匹配预制体：{cachedMatchedPrefab.name}", MessageType.Info);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField(string.Empty, GUI.skin.horizontalSlider);

        showPresetConfig = EditorGUILayout.Foldout(showPresetConfig, "预设配置", true, EditorStyles.foldoutHeader);
        if (showPresetConfig)
            DrawPresetConfig();
    }

    private void UpdateCachedMatchedPrefab()
    {
        cachedMatchedPrefab = FindPrefabFromJson(selectedFunction, selectedAttribute, selectedWeapon);
    }

    private static Color GetAttributeColor(AttributeType attr)
    {
        switch (attr)
        {
            case AttributeType.冰:   return new Color(0.45f, 0.75f, 1.00f);
            case AttributeType.火:   return new Color(1.00f, 0.55f, 0.20f);
            case AttributeType.毒:   return new Color(0.70f, 0.35f, 0.95f);
            case AttributeType.电:   return new Color(0.40f, 0.90f, 0.40f);
            case AttributeType.无属性: return new Color(0.70f, 0.70f, 0.70f);
            default:                  return Color.white;
        }
    }

        private void DrawPresetConfig()
        {
            EditorGUILayout.Space();

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("配置文件", EditorStyles.boldLabel);
                jsonConfigPath = EditorGUILayout.TextField("路径", jsonConfigPath);
                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button("浏览"))
                    {
                        string absPath = EditorUtility.OpenFilePanel("选择JSON配置文件", Application.dataPath, "json");
                        if (!string.IsNullOrEmpty(absPath))
                            jsonConfigPath = "Assets" + absPath.Substring(Application.dataPath.Length).Replace('\\', '/');
                    }
                    if (GUILayout.Button("重新加载"))
                        LoadJsonConfig();
                    if (GUILayout.Button("打开配置文件"))
                        OpenJsonFile();
                }
            }

            EditorGUILayout.Space();
            GUILayout.Label("预设条目 (编辑后点击[保存到JSON]) ", EditorStyles.boldLabel);

            presetScrollPos = EditorGUILayout.BeginScrollView(presetScrollPos, GUILayout.MaxHeight(360));

            for (int i = 0; i < presetEntries.Count; i++)
            {
                VFXPresetEntry entry = presetEntries[i];
                bool removed = false;

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUILayout.LabelField($"#{i + 1}", EditorStyles.miniLabel, GUILayout.Width(34));
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("删除", EditorStyles.miniButton, GUILayout.Width(48)))
                        removed = true;
                }

                using (new EditorGUILayout.HorizontalScope())
                {
                    entry.function = (FunctionType)EditorGUILayout.EnumPopup("功能", entry.function);
                    GUI.backgroundColor = GetAttributeColor(entry.attribute);
                    entry.attribute = (AttributeType)EditorGUILayout.EnumPopup("属性", entry.attribute);
                    GUI.backgroundColor = Color.white;
                    entry.weapon = (WeaponType)EditorGUILayout.EnumPopup("武器", entry.weapon);
                }
                entry.prefab = (GameObject)EditorGUILayout.ObjectField("预制体", entry.prefab, typeof(GameObject), false);

                EditorGUILayout.EndVertical();

                if (removed)
                {
                    presetEntries.RemoveAt(i);
                    i--;
                }
            }

            EditorGUILayout.EndScrollView();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("添加预设"))
                presetEntries.Add(new VFXPresetEntry());
            if (GUILayout.Button("保存到JSON", GUILayout.Width(120)))
                SaveToJson();
            EditorGUILayout.EndHorizontal();
        }

    // ===================== JSON 操作 =====================

    private void LoadJsonConfig()
    {
        if (!File.Exists(jsonConfigPath))
        {
            loadedPresets = new VFXPresetList();
            presetEntries.Clear();
            return;
        }

        try
        {
            string json = File.ReadAllText(jsonConfigPath);
            loadedPresets = JsonUtility.FromJson<VFXPresetList>(json) ?? new VFXPresetList();
            SyncJsonToEntries();
        }
        catch (System.Exception e)
        {
            Debug.LogError($"[VFXPresets] 读取配置文件失败: {e.Message}");
            loadedPresets = new VFXPresetList();
        }
        UpdateCachedMatchedPrefab();
    }

    private void SaveToJson()
    {
        var list = new VFXPresetList();
        foreach (VFXPresetEntry entry in presetEntries)
        {
            if (entry.prefab == null) continue;
            list.presets.Add(new VFXPresetData
            {
                function   = entry.function.ToString(),
                attribute  = entry.attribute.ToString(),
                weapon     = entry.weapon.ToString(),
                prefabName = entry.prefab.name,
                prefabPath = AssetDatabase.GetAssetPath(entry.prefab)
            });
        }

        string dir = Path.GetDirectoryName(jsonConfigPath);
        if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
            Directory.CreateDirectory(dir);

        File.WriteAllText(jsonConfigPath, JsonUtility.ToJson(list, true));
        AssetDatabase.Refresh();
        loadedPresets = list;
        UpdateCachedMatchedPrefab();
        Debug.Log($"[VFXPresets] 配置已保存到：{jsonConfigPath}");
    }

    private void SyncJsonToEntries()
    {
        presetEntries.Clear();
        if (loadedPresets == null) return;

        foreach (VFXPresetData data in loadedPresets.presets)
        {
            var entry = new VFXPresetEntry();
            if (System.Enum.TryParse(data.function,  out FunctionType  func))   entry.function  = func;
            if (System.Enum.TryParse(data.attribute, out AttributeType attr))   entry.attribute = attr;
            if (System.Enum.TryParse(data.weapon,    out WeaponType    weapon)) entry.weapon    = weapon;
            if (!string.IsNullOrEmpty(data.prefabPath))
                entry.prefab = AssetDatabase.LoadAssetAtPath<GameObject>(data.prefabPath);
            presetEntries.Add(entry);
        }
    }

    private GameObject FindPrefabFromJson(FunctionType func, AttributeType attr, WeaponType weapon)
    {
        if (loadedPresets == null || loadedPresets.presets == null) return null;

        string funcStr   = func.ToString();
        string attrStr   = attr.ToString();
        string weaponStr = weapon.ToString();

        foreach (VFXPresetData preset in loadedPresets.presets)
        {
            if (preset.function == funcStr && preset.attribute == attrStr && preset.weapon == weaponStr)
            {
                if (!string.IsNullOrEmpty(preset.prefabPath))
                    return AssetDatabase.LoadAssetAtPath<GameObject>(preset.prefabPath);
            }
        }
        return null;
    }

    private void OpenJsonFile()
    {
        if (!File.Exists(jsonConfigPath))
        {
            if (EditorUtility.DisplayDialog("配置文件不存在",
                    $"配置文件 {jsonConfigPath} 不存在，是否新建？", "新建", "取消"))
                SaveToJson();
            return;
        }
        EditorUtility.OpenWithDefaultApp(jsonConfigPath);
    }

    // ===================== 核心生成逻辑 =====================

    private void SpawnParticleSystem(GameObject prefab)
    {
        if (prefab == null)
        {
            Debug.LogWarning("请先选择模板预制体！");
            return;
        }

        // 实例化预制体到场景，再完全解除预制体连接，保证与预制体100%一致
        GameObject instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;

        if (instance == null)
        {
            Debug.LogError("无法实例化模板预制体！");
            return;
        }

        PrefabUtility.UnpackPrefabInstance(instance, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);

        instance.transform.SetAsLastSibling();

        Undo.RegisterCreatedObjectUndo(instance, "Create New VFX GameObject");

        Selection.activeGameObject = instance;

        TriggerHierarchyRename();

        Debug.Log($"成功生成新的空特效GameObject: {instance.name}");
    }

    private static void TriggerHierarchyRename()
    {
        EditorApplication.delayCall += () =>
        {
            System.Type type = System.Type.GetType("UnityEditor.SceneHierarchyWindow,UnityEditor");
            if (type == null) return;

            Object[] windows = Resources.FindObjectsOfTypeAll(type);
            if (windows == null || windows.Length == 0)
            {
                EditorApplication.ExecuteMenuItem("Window/General/Hierarchy");
                windows = Resources.FindObjectsOfTypeAll(type);
            }

            if (windows == null || windows.Length == 0) return;

            EditorWindow hierarchyWindow = windows[0] as EditorWindow;
            if (hierarchyWindow == null) return;

            hierarchyWindow.Focus();

            EditorApplication.delayCall += () =>
            {
                // 通过反射调用内部 RenameGO 方法，直接进入重命名状态
                var method = type.GetMethod("RenameGO",
                    System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                method?.Invoke(hierarchyWindow, null);
            };
        };
    }
}
}

#endif