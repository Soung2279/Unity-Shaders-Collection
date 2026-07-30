using System;
using System.IO;
using GameFramework.Editor;
using UnityEditor;
using UnityEditor.U2D;
using UnityEngine;
using UnityEngine.U2D;

/// <summary>
/// Sprite图集配置窗口 — Tab切换：重生成图集 | 自动导入处理
/// </summary>
public class SpriteAtlasConfigWindow : EditorWindow
{
    private SpriteAtlasConfig _config;
    private Vector2 _scrollPos;
    private int _tabIndex;

    private const string ConfigAssetPath = "Assets/Editor/Postprocessor/SpriteAtlasConfig.asset";

    [MenuItem("Game Framework/Atlas/重新生成UI图集", false, 90)]
    public static void OpenWindow()
    {
        var window = GetWindow<SpriteAtlasConfigWindow>("UI图集配置与重生成");
        window.minSize = new Vector2(540, 640);
        window.LoadConfig();
        window.Show();
    }

    void OnEnable()
    {
        if (_config == null)
            LoadConfig();
    }

    void LoadConfig()
    {
        _config = AssetDatabase.LoadAssetAtPath<SpriteAtlasConfig>(ConfigAssetPath);
        if (_config == null)
        {
            _config = CreateInstance<SpriteAtlasConfig>();
            string dir = Path.GetDirectoryName(ConfigAssetPath);
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);
            AssetDatabase.CreateAsset(_config, ConfigAssetPath);
            AssetDatabase.SaveAssets();
        }

        EditorSpriteSaveInfo.SetConfig(_config);
    }

    void OnGUI()
    {
        if (_config == null)
        {
            EditorGUILayout.LabelField("配置加载失败，请重新打开窗口");
            return;
        }

        EditorGUILayout.Space(4);
        string[] tabNames = { "重生成图集", "自动导入处理" };
        _tabIndex = GUILayout.Toolbar(_tabIndex, tabNames, GUILayout.Height(28));
        EditorGUILayout.Space(6);

        _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);

        switch (_tabIndex)
        {
            case 0:
                DrawRegenTab();
                break;
            case 1:
                DrawAutoImportTab();
                break;
        }

        EditorGUILayout.EndScrollView();

        EditorGUILayout.Space(8);

        // 底部按钮
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("保存配置", GUILayout.Height(36), GUILayout.Width(120)))
            SaveConfig();

        GUILayout.FlexibleSpace();

        if (_tabIndex == 0)
        {
            GUI.backgroundColor = new Color(1f, 0.65f, 0.35f);
            if (GUILayout.Button("清除已有图集", GUILayout.Height(36), GUILayout.Width(140)))
            {
                if (EditorUtility.DisplayDialog("清除已有图集", "将删除当前扫描目录中的所有 .spriteatlasv2 文件，是否继续？", "清除", "取消"))
                {
                    SaveConfig();
                    EditorSpriteSaveInfo.SetConfig(_config);
                    EditorSpriteSaveInfo.ClearExistingAtlases();
                }
            }
            GUI.backgroundColor = new Color(0.4f, 0.8f, 0.4f);
            if (GUILayout.Button("执行重生成", GUILayout.Height(36), GUILayout.Width(160)))
            {
                SaveConfig();
                EditorSpriteSaveInfo.SetConfig(_config);
                EditorSpriteSaveInfo.ForceGenAtlas();
            }
            GUI.backgroundColor = Color.white;
        }
        EditorGUILayout.EndHorizontal();
    }

    // ============================================================
    // Tab 0: 重生成图集
    // ============================================================
    void DrawRegenTab()
    {
        EditorGUILayout.LabelField("自动扫描根目录", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("可配置多个根目录；自动扫描会添加每个根目录下最多两层的子目录:", EditorStyles.miniLabel);
        DrawFolderArray(ref _config.autoScanRootDirs);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(40);
        if (GUILayout.Button("自动扫描并更新目录列表", GUILayout.Width(220)))
        {
            AutoScanSpriteDirs();
        }
        EditorGUILayout.EndHorizontal();
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        EditorGUILayout.LabelField("图集生成目录", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.HelpBox(
            "拖拽文件夹到此区域，或手动输入路径。执行重生成时会校验目录是否位于上方任一自动扫描根目录内；根目录外的目录统一使用 Atlas_父文件夹名_当前文件夹名 命名，并在实际生成后弹窗提示。",
            MessageType.Info);
        DrawFolderArray(ref _config.atlasScanDirs);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- 打包方式 ---
        EditorGUILayout.LabelField("打包方式", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.packMode = (SpriteAtlasPackMode)EditorGUILayout.EnumPopup("Pack Mode", _config.packMode);
        EditorGUILayout.HelpBox(
            _config.packMode == SpriteAtlasPackMode.FolderReference
                ? "指定文件夹目录打图集：每个扫描目录生成一张图集，图集Packable直接引用该文件夹。"
                : "按文件名前缀规则打图集：保持现有规则，每个目录可按前缀拆分多张图集。",
            MessageType.Info);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- 路径标记 ---
        EditorGUILayout.LabelField("路径标记", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.pathMarker = EditorGUILayout.TextField("pathMarker", _config.pathMarker);
        EditorGUILayout.HelpBox(
            "从图片路径中查找此标记，截取标记之后的路径来生成图集名，并统一添加 Atlas_ 前缀。\n" +
            "例：标记=\"Sprite\"，路径为 Assets/GameAsset/Sprite/Icon/Activity/icon.png\n" +
            "则图集名为 Atlas_Icon_Activity；前缀规则匹配 monster_boss_ 时为 Atlas_Icon_Monster_monster_boss",
            MessageType.Info);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- 目录级打包规则 ---
        if (_config.packMode == SpriteAtlasPackMode.PrefixRules)
        {
            DrawDirectoryRulesSection();
        }

        // --- Packing ---
        EditorGUILayout.LabelField("图集Packing设置", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.enableRotation = EditorGUILayout.Toggle("Allow Rotation（允许旋转）", _config.enableRotation);
        _config.enableTightPacking = EditorGUILayout.Toggle("Tight Packing（紧密包装）", _config.enableTightPacking);
        _config.enableAlphaDilation = EditorGUILayout.Toggle("Alpha Dilation（Alpha扩张）", _config.enableAlphaDilation);
        _config.padding = EditorGUILayout.IntSlider("Padding（填充）", _config.padding, 0, 8);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- 生成门槛 ---
        EditorGUILayout.LabelField("图集生成规则", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.minSpriteCount = Mathf.Max(0, EditorGUILayout.IntField("低于多少张Sprite时跳过", _config.minSpriteCount));
        EditorGUILayout.HelpBox(
            $"当前规则：目录内少于 {_config.minSpriteCount} 张Sprite时不生成图集。该配置同时作用于“执行重生成”和文件夹右键生成图集；设为0表示不限制。",
            MessageType.Info);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- Texture ---
        EditorGUILayout.LabelField("图集Texture设置", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.readable = EditorGUILayout.Toggle("Read/Write（纹理读取/写入）", _config.readable);
        _config.generateMipMaps = EditorGUILayout.Toggle("Generate Mip Maps（生成MipMap）", _config.generateMipMaps);
        _config.sRGB = EditorGUILayout.Toggle("sRGB", _config.sRGB);
        _config.filterMode = (FilterMode)EditorGUILayout.EnumPopup("Filter Mode（过滤模式）", _config.filterMode);
        EditorGUI.indentLevel--;
    }

    // ============================================================
    // Tab 1: 自动导入处理
    // ============================================================
    void DrawAutoImportTab()
    {
        // --- 总开关 ---
        EditorGUILayout.LabelField("总开关", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.enableAutoImport = EditorGUILayout.Toggle("启用自动导入修正", _config.enableAutoImport);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        GUI.enabled = _config.enableAutoImport;

        // --- 监听目录 ---
        EditorGUILayout.LabelField("导入监听目录", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("仅这些目录下的图片导入时会被自动处理:", EditorStyles.miniLabel);
        DrawFolderArray(ref _config.autoImportWatchDirs);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        // --- 自动修正选项 ---
        EditorGUILayout.LabelField("自动修正选项", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        _config.autoFixTextureType = EditorGUILayout.Toggle("自动设为Sprite类型", _config.autoFixTextureType);
        _config.autoClearPackingTag = EditorGUILayout.Toggle("自动清除旧PackingTag", _config.autoClearPackingTag);
        _config.autoDisablePhysicsShape = EditorGUILayout.Toggle("自动关闭PhysicsShape", _config.autoDisablePhysicsShape);
        _config.autoSetAlphaIsTransparency = EditorGUILayout.Toggle("自动设置AlphaIsTransparency", _config.autoSetAlphaIsTransparency);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);

        GUI.enabled = true;
    }

    // ============================================================
    // 公共UI组件
    // ============================================================

    void DrawFolderArray(ref string[] array)
    {
        if (array == null) array = new string[0];

        for (int i = 0; i < array.Length; i++)
        {
            EditorGUILayout.BeginHorizontal();

            var fieldRect = EditorGUILayout.GetControlRect();
            array[i] = EditorGUI.TextField(fieldRect, $"  [{i}]", array[i]);

            HandleFolderDrag(fieldRect, i, ref array);

            if (GUILayout.Button("×", GUILayout.Width(24)))
            {
                var list = new System.Collections.Generic.List<string>(array);
                list.RemoveAt(i);
                array = list.ToArray();
                GUI.FocusControl(null);
            }
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(40);
        if (GUILayout.Button("+ 添加目录", GUILayout.Width(100)))
        {
            var list = new System.Collections.Generic.List<string>(array);
            list.Add("");
            array = list.ToArray();
        }
        EditorGUILayout.EndHorizontal();
    }

    void HandleFolderDrag(Rect dropRect, int index, ref string[] array)
    {
        Event evt = Event.current;
        if (!dropRect.Contains(evt.mousePosition))
            return;

        switch (evt.type)
        {
            case EventType.DragUpdated:
            case EventType.DragPerform:
                bool hasFolder = false;
                foreach (var obj in DragAndDrop.objectReferences)
                {
                    var path = AssetDatabase.GetAssetPath(obj);
                    if (AssetDatabase.IsValidFolder(path))
                    {
                        hasFolder = true;
                        break;
                    }
                }

                if (hasFolder)
                {
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                    if (evt.type == EventType.DragPerform)
                    {
                        DragAndDrop.AcceptDrag();
                        foreach (var obj in DragAndDrop.objectReferences)
                        {
                            var path = AssetDatabase.GetAssetPath(obj);
                            if (AssetDatabase.IsValidFolder(path))
                            {
                                array[index] = path;
                                evt.Use();
                                return;
                            }
                        }
                    }
                    evt.Use();
                }
                break;
        }
    }

    void HandleFolderDrag(Rect dropRect, int index, ref AtlasDirectoryRule[] array, System.Action<int, string, AtlasDirectoryRule[]> setter)
    {
        Event evt = Event.current;
        if (!dropRect.Contains(evt.mousePosition))
            return;

        switch (evt.type)
        {
            case EventType.DragUpdated:
            case EventType.DragPerform:
                bool hasFolder = false;
                foreach (var obj in DragAndDrop.objectReferences)
                {
                    var path = AssetDatabase.GetAssetPath(obj);
                    if (AssetDatabase.IsValidFolder(path))
                    {
                        hasFolder = true;
                        break;
                    }
                }

                if (hasFolder)
                {
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                    if (evt.type == EventType.DragPerform)
                    {
                        DragAndDrop.AcceptDrag();
                        foreach (var obj in DragAndDrop.objectReferences)
                        {
                            var path = AssetDatabase.GetAssetPath(obj);
                            if (AssetDatabase.IsValidFolder(path))
                            {
                                setter(index, path, array);
                                evt.Use();
                                return;
                            }
                        }
                    }
                    evt.Use();
                }
                break;
        }
    }

    void DrawStringArray(ref string[] array, string label)
    {
        if (array == null) array = new string[0];

        for (int i = 0; i < array.Length; i++)
        {
            EditorGUILayout.BeginHorizontal();
            array[i] = EditorGUILayout.TextField($"  [{i}]", array[i]);
            if (GUILayout.Button("×", GUILayout.Width(24)))
            {
                var list = new System.Collections.Generic.List<string>(array);
                list.RemoveAt(i);
                array = list.ToArray();
                GUI.FocusControl(null);
            }
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(40);
        if (GUILayout.Button("+ 添加规则", GUILayout.Width(100)))
        {
            var list = new System.Collections.Generic.List<string>(array);
            list.Add("");
            array = list.ToArray();
        }
        EditorGUILayout.EndHorizontal();
    }

    // ============================================================
    // 目录级打包规则
    // ============================================================
    void DrawDirectoryRulesSection()
    {
        EditorGUILayout.LabelField("目录级打包规则", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.HelpBox(
            "为特定目录指定文件名前缀，每个前缀生成一个独立图集。\n" +
            "未配置规则的目录或未匹配前缀的图片，仍按整个目录打包。",
            MessageType.Info);

        if (_config.directoryRules == null)
            _config.directoryRules = new AtlasDirectoryRule[0];

        for (int i = 0; i < _config.directoryRules.Length; i++)
        {
            var rule = _config.directoryRules[i];
            if (rule == null)
            {
                rule = new AtlasDirectoryRule();
                _config.directoryRules[i] = rule;
            }

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            // 头部：规则序号 + 删除按钮
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField($"规则 [{i}]", EditorStyles.boldLabel, GUILayout.Width(60));

            var dirFieldRect = EditorGUILayout.GetControlRect();
            rule.directoryPath = EditorGUI.TextField(dirFieldRect, rule.directoryPath);
            HandleFolderDrag(dirFieldRect, i, ref _config.directoryRules, (idx, path, arr) =>
            {
                if (arr[idx] == null) arr[idx] = new AtlasDirectoryRule();
                arr[idx].directoryPath = path;
            });

            if (GUILayout.Button("× 删除规则", GUILayout.Width(80)))
            {
                var list = new System.Collections.Generic.List<AtlasDirectoryRule>(_config.directoryRules);
                list.RemoveAt(i);
                _config.directoryRules = list.ToArray();
                GUI.FocusControl(null);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
                break;
            }
            EditorGUILayout.EndHorizontal();

            // 前缀列表
            EditorGUILayout.LabelField("  文件名前缀（每个前缀生成一个图集）:", EditorStyles.miniLabel);
            EditorGUI.indentLevel++;
            DrawRulePrefixes(rule);
            EditorGUI.indentLevel--;

            // 排除文件
            EditorGUILayout.LabelField("  排除文件（文件名不含后缀，完全匹配）:", EditorStyles.miniLabel);
            EditorGUI.indentLevel++;
            DrawStringArray(ref rule.excludeFiles, "排除");
            EditorGUI.indentLevel--;

            EditorGUILayout.EndVertical();
            EditorGUILayout.Space(2);
        }

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("+ 添加规则", GUILayout.Width(120)))
        {
            var list = new System.Collections.Generic.List<AtlasDirectoryRule>(_config.directoryRules);
            list.Add(new AtlasDirectoryRule());
            _config.directoryRules = list.ToArray();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUI.indentLevel--;
        EditorGUILayout.Space(8);
    }

    void DrawRulePrefixes(AtlasDirectoryRule rule)
    {
        if (rule.prefixes == null) rule.prefixes = new string[0];

        for (int i = 0; i < rule.prefixes.Length; i++)
        {
            EditorGUILayout.BeginHorizontal();
            rule.prefixes[i] = EditorGUILayout.TextField($"  前缀 [{i}]", rule.prefixes[i]);
            if (GUILayout.Button("×", GUILayout.Width(24)))
            {
                var list = new System.Collections.Generic.List<string>(rule.prefixes);
                list.RemoveAt(i);
                rule.prefixes = list.ToArray();
            }
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(40);
        if (GUILayout.Button("+ 添加前缀", GUILayout.Width(100)))
        {
            var list = new System.Collections.Generic.List<string>(rule.prefixes);
            list.Add("");
            rule.prefixes = list.ToArray();
        }
        EditorGUILayout.EndHorizontal();
    }

    // ============================================================
    // 自动扫描
    // ============================================================
    void AutoScanSpriteDirs()
    {
        int removedCount = RemoveInvalidPaths(ref _config.atlasScanDirs);
        RemoveInvalidPaths(ref _config.autoScanRootDirs);

        if (_config.autoScanRootDirs == null || _config.autoScanRootDirs.Length == 0)
        {
            EditorUtility.DisplayDialog("提示", "请先添加至少一个有效的自动扫描根目录。", "确定");
            return;
        }

        var foundDirs = new System.Collections.Generic.HashSet<string>(StringComparer.Ordinal);
        foreach (var rootDir in _config.autoScanRootDirs)
        {
            var level1 = AssetDatabase.GetSubFolders(rootDir);
            foreach (var dir in level1)
            {
                foundDirs.Add(dir);
                foreach (var subDir in AssetDatabase.GetSubFolders(dir))
                {
                    foundDirs.Add(subDir);
                }
            }
        }

        var existing = new System.Collections.Generic.HashSet<string>(_config.atlasScanDirs ?? Array.Empty<string>(), StringComparer.Ordinal);
        existing.UnionWith(foundDirs);

        var list = new System.Collections.Generic.List<string>(existing);
        list.Sort(StringComparer.Ordinal);
        _config.atlasScanDirs = list.ToArray();
        SaveConfig();

        Debug.Log($"自动扫描完成：根目录={_config.autoScanRootDirs.Length}，新增候选={foundDirs.Count}，移除失效目录={removedCount}，当前生成目录={_config.atlasScanDirs.Length}");
    }

    static int RemoveInvalidPaths(ref string[] paths)
    {
        if (paths == null || paths.Length == 0)
        {
            paths = Array.Empty<string>();
            return 0;
        }

        var valid = new System.Collections.Generic.HashSet<string>(StringComparer.Ordinal);
        int removedCount = 0;
        foreach (var path in paths)
        {
            var normalized = path?.Trim().Replace("\\", "/");
            if (string.IsNullOrEmpty(normalized) || !AssetDatabase.IsValidFolder(normalized))
            {
                removedCount++;
                continue;
            }

            if (!valid.Add(normalized))
            {
                removedCount++;
            }
        }

        var list = new System.Collections.Generic.List<string>(valid);
        list.Sort(StringComparer.Ordinal);
        paths = list.ToArray();
        return removedCount;
    }

    // ============================================================
    // 保存
    // ============================================================
    void SaveConfig()
    {
        if (_config == null) return;
        EditorUtility.SetDirty(_config);
        AssetDatabase.SaveAssets();
        Debug.Log("SpriteAtlasConfig 已保存");
    }
}
