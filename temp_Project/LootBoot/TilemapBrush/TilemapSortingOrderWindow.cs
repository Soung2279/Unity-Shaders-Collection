using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace GameFramework.Editor
{
    [Serializable]
    public class TilemapSortingOrderRule
    {
        public bool enabled = true;
        public string objectName;
        public int sortingOrder;

        public bool IsValid()
        {
            return enabled && !string.IsNullOrEmpty(objectName);
        }
    }

    public class TilemapSortingOrderConfig : ScriptableObject
    {
        [Tooltip("可填写Prefab文件路径、Prefab所在文件夹，或路径前缀")]
        public string[] prefabPathRules =
        {
            "Assets/GameAsset/Prefab/Stage"
        };

        [Tooltip("所有匹配对象统一设置到该Sorting Layer")]
        public string sortingLayerName = "Default";

        [Tooltip("按GameObject名称匹配TilemapRenderer并设置Sorting Order；Land会额外匹配SpriteRenderer")]
        public TilemapSortingOrderRule[] sortingRules =
        {
            new TilemapSortingOrderRule { objectName = "Land", sortingOrder = -10 },
            new TilemapSortingOrderRule { objectName = "Water", sortingOrder = -9 },
            new TilemapSortingOrderRule { objectName = "Ground", sortingOrder = -9 },
            new TilemapSortingOrderRule { objectName = "Way", sortingOrder = -8 },
            new TilemapSortingOrderRule { objectName = "WallUp", sortingOrder = -6 },
            new TilemapSortingOrderRule { objectName = "Mountain", sortingOrder = -4 },
            new TilemapSortingOrderRule { objectName = "ObjectDown", sortingOrder = -3 },
            new TilemapSortingOrderRule { objectName = "ObjectUp", sortingOrder = 2 },
            new TilemapSortingOrderRule { objectName = "BossWall", sortingOrder = 2 },
        };

        public TilemapSortingOrderRule FindRuleForName(string objectName)
        {
            if (sortingRules == null)
                return null;

            foreach (var rule in sortingRules)
            {
                if (rule != null && rule.IsValid() &&
                    string.Equals(rule.objectName, objectName, StringComparison.OrdinalIgnoreCase))
                {
                    return rule;
                }
            }

            return null;
        }

        public bool IsPrefabPathMatched(string prefabPath)
        {
            if (prefabPathRules == null)
                return false;

            prefabPath = NormalizePath(prefabPath);
            foreach (var rulePath in prefabPathRules)
            {
                var rule = NormalizePath(rulePath);
                if (string.IsNullOrEmpty(rule))
                    continue;

                if (rule.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase))
                {
                    if (string.Equals(prefabPath, rule, StringComparison.OrdinalIgnoreCase))
                        return true;
                }
                else if (prefabPath.StartsWith(rule.TrimEnd('/') + "/", StringComparison.OrdinalIgnoreCase) ||
                         string.Equals(prefabPath, rule, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }

        public static string NormalizePath(string path)
        {
            return string.IsNullOrEmpty(path) ? string.Empty : path.Replace("\\", "/").Trim();
        }
    }

    public class TilemapSortingOrderWindow : EditorWindow
    {
        private const string ConfigAssetPath = "Assets/Editor/TilemapBrush/TilemapSortingOrderConfig.asset";

        private TilemapSortingOrderConfig _config;
        private Vector2 _scrollPos;
        private Vector2 _matchScrollPos;
        private List<PrefabMatchItem> _matchedPrefabs = new List<PrefabMatchItem>();
        private string _duplicateRuleWarning;

        private const float MatchListHeight = 260f;
        private const float MatchRowHeight = 22f;

        private class PrefabMatchItem
        {
            public string path;
            public bool selected = true;
        }

        [MenuItem("Game Framework/Map/批量设置Tilemap层级", false, 93)]
        public static void OpenWindow()
        {
            var window = GetWindow<TilemapSortingOrderWindow>("批量设置Tilemap层级");
            window.minSize = new Vector2(680, 560);
            window.LoadConfig();
            window.Show();
        }

        private void OnEnable()
        {
            if (_config == null)
                LoadConfig();
        }

        private void OnDisable()
        {
            SaveConfig();
        }

        private void OnGUI()
        {
            if (_config == null)
            {
                EditorGUILayout.HelpBox("配置加载失败，请重新打开窗口。", MessageType.Error);
                return;
            }

            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                EditorGUILayout.HelpBox("当前处于Play Mode。可以编辑配置，但请退出Play Mode后再执行应用，避免Prefab保存风险。", MessageType.Warning);
            }

            _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
            EditorGUI.BeginChangeCheck();
            DrawPrefabPathRules();
            EditorGUILayout.Space(8);
            DrawSortingRules();
            if (EditorGUI.EndChangeCheck())
                SaveConfig();
            EditorGUILayout.Space(8);
            DrawMatchedPrefabs();
            EditorGUILayout.EndScrollView();

            EditorGUILayout.Space(6);
            DrawBottomButtons();
        }

        private void LoadConfig()
        {
            _config = AssetDatabase.LoadAssetAtPath<TilemapSortingOrderConfig>(ConfigAssetPath);
            if (_config != null)
                return;

            _config = CreateInstance<TilemapSortingOrderConfig>();
            var dir = Path.GetDirectoryName(ConfigAssetPath);
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);
            AssetDatabase.CreateAsset(_config, ConfigAssetPath);
            AssetDatabase.SaveAssets();
        }

        private void DrawPrefabPathRules()
        {
            EditorGUILayout.LabelField("Prefab匹配路径", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox("可填写单个.prefab路径、Prefab文件夹，或路径前缀。只有匹配到的Prefab会被处理。", MessageType.Info);

            if (_config.prefabPathRules == null)
                _config.prefabPathRules = new string[0];

            for (int i = 0; i < _config.prefabPathRules.Length; i++)
            {
                EditorGUILayout.BeginHorizontal();
                var rect = EditorGUILayout.GetControlRect();
                _config.prefabPathRules[i] = EditorGUI.TextField(rect, $"路径 [{i}]", _config.prefabPathRules[i]);
                HandleAssetPathDrag(rect, path =>
                {
                    _config.prefabPathRules[i] = path;
                    SaveConfig();
                });

                if (GUILayout.Button("×", GUILayout.Width(24)))
                {
                    var list = new List<string>(_config.prefabPathRules);
                    list.RemoveAt(i);
                    _config.prefabPathRules = list.ToArray();
                    GUI.FocusControl(null);
                }
                EditorGUILayout.EndHorizontal();
            }

            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(40);
            if (GUILayout.Button("+ 添加路径", GUILayout.Width(110)))
            {
                var list = new List<string>(_config.prefabPathRules);
                list.Add(string.Empty);
                _config.prefabPathRules = list.ToArray();
            }
            EditorGUILayout.EndHorizontal();
        }

        private void DrawSortingRules()
        {
            EditorGUILayout.LabelField("Tilemap名称与层级", EditorStyles.boldLabel);
            _config.sortingLayerName = EditorGUILayout.TextField("Sorting Layer", _config.sortingLayerName);
            EditorGUILayout.HelpBox("按GameObject名称精确匹配。除Land外只修改TilemapRenderer；Land单独修改SpriteRenderer。", MessageType.Info);

            if (_config.sortingRules == null)
                _config.sortingRules = new TilemapSortingOrderRule[0];

            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            GUILayout.Label("启用", GUILayout.Width(42));
            GUILayout.Label("Object Name");
            GUILayout.Label("Sorting Order", GUILayout.Width(110));
            GUILayout.Space(28);
            EditorGUILayout.EndHorizontal();

            for (int i = 0; i < _config.sortingRules.Length; i++)
            {
                if (_config.sortingRules[i] == null)
                    _config.sortingRules[i] = new TilemapSortingOrderRule();

                var rule = _config.sortingRules[i];
                EditorGUILayout.BeginHorizontal();
                rule.enabled = EditorGUILayout.Toggle(rule.enabled, GUILayout.Width(42));
                var newObjectName = EditorGUILayout.TextField(rule.objectName);
                if (newObjectName != rule.objectName)
                {
                    if (IsRuleNameUsedByOther(newObjectName, i))
                    {
                        _duplicateRuleWarning = $"已存在同名规则：{newObjectName}";
                        GUI.FocusControl(null);
                    }
                    else
                    {
                        rule.objectName = newObjectName;
                        _duplicateRuleWarning = null;
                    }
                }
                rule.sortingOrder = EditorGUILayout.IntField(rule.sortingOrder, GUILayout.Width(110));
                if (GUILayout.Button("×", GUILayout.Width(24)))
                {
                    var list = new List<TilemapSortingOrderRule>(_config.sortingRules);
                    list.RemoveAt(i);
                    _config.sortingRules = list.ToArray();
                    GUI.FocusControl(null);
                }
                EditorGUILayout.EndHorizontal();
            }

            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(40);
            if (GUILayout.Button("+ 添加名称规则", GUILayout.Width(130)))
            {
                var list = new List<TilemapSortingOrderRule>(_config.sortingRules);
                list.Add(new TilemapSortingOrderRule());
                _config.sortingRules = list.ToArray();
            }
            EditorGUILayout.EndHorizontal();

            var duplicateNames = GetDuplicateRuleNames();
            if (duplicateNames.Length > 0)
                EditorGUILayout.HelpBox("存在重复名称规则：" + string.Join(", ", duplicateNames), MessageType.Error);
            else if (!string.IsNullOrEmpty(_duplicateRuleWarning))
                EditorGUILayout.HelpBox(_duplicateRuleWarning, MessageType.Warning);
        }

        private void DrawMatchedPrefabs()
        {
            EditorGUILayout.LabelField("最近扫描结果", EditorStyles.boldLabel);
            if (_matchedPrefabs.Count == 0)
            {
                EditorGUILayout.LabelField("尚未扫描。", EditorStyles.miniLabel);
                return;
            }

            var selectedCount = _matchedPrefabs.Count(item => item.selected);
            EditorGUILayout.LabelField($"匹配Prefab数量: {_matchedPrefabs.Count}，已选择: {selectedCount}");

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("全选", GUILayout.Width(70)))
                SetAllMatchedSelection(true);
            if (GUILayout.Button("全不选", GUILayout.Width(70)))
                SetAllMatchedSelection(false);
            if (GUILayout.Button("反选", GUILayout.Width(70)))
                InvertMatchedSelection();
            GUILayout.FlexibleSpace();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            GUILayout.Label("应用", GUILayout.Width(42));
            GUILayout.Label("Prefab Path");
            EditorGUILayout.EndHorizontal();

            _matchScrollPos = EditorGUILayout.BeginScrollView(_matchScrollPos, GUILayout.Height(MatchListHeight));
            DrawVirtualizedMatchedPrefabRows();
            EditorGUILayout.EndScrollView();
        }

        private void DrawVirtualizedMatchedPrefabRows()
        {
            var contentHeight = Mathf.Max(_matchedPrefabs.Count * MatchRowHeight, MatchRowHeight);
            var contentRect = GUILayoutUtility.GetRect(0f, contentHeight, GUILayout.ExpandWidth(true));
            var visibleStart = Mathf.Max(0, Mathf.FloorToInt(_matchScrollPos.y / MatchRowHeight));
            var visibleEnd = Mathf.Min(_matchedPrefabs.Count, Mathf.CeilToInt((_matchScrollPos.y + MatchListHeight) / MatchRowHeight) + 1);

            for (int i = visibleStart; i < visibleEnd; i++)
            {
                var item = _matchedPrefabs[i];
                var rowRect = new Rect(contentRect.x, contentRect.y + i * MatchRowHeight, contentRect.width, MatchRowHeight);
                if (UnityEngine.Event.current.type == UnityEngine.EventType.Repaint && i % 2 == 1)
                    EditorGUI.DrawRect(rowRect, new Color(1f, 1f, 1f, 0.04f));

                var toggleRect = new Rect(rowRect.x + 4f, rowRect.y + 2f, 38f, rowRect.height - 4f);
                var pathRect = new Rect(rowRect.x + 46f, rowRect.y + 2f, rowRect.width - 50f, rowRect.height - 4f);
                item.selected = GUI.Toggle(toggleRect, item.selected, GUIContent.none);
                EditorGUIUtility.AddCursorRect(pathRect, MouseCursor.Link);
                if (GUI.Button(pathRect, item.path, EditorStyles.label))
                    PingPrefabAsset(item.path);
            }
        }

        private static void PingPrefabAsset(string prefabPath)
        {
            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(prefabPath);
            if (asset == null)
                return;

            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }

        private void DrawBottomButtons()
        {
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("保存配置", GUILayout.Height(34), GUILayout.Width(110)))
            {
                if (ValidateConfig())
                    SaveConfig();
            }

            if (GUILayout.Button("扫描匹配Prefab", GUILayout.Height(34), GUILayout.Width(140)))
            {
                if (!ValidateConfig())
                {
                    EditorGUILayout.EndHorizontal();
                    return;
                }

                SaveConfig();
                ScanMatchedPrefabs();
                Debug.Log($"Tilemap层级工具：匹配到 {_matchedPrefabs.Count} 个Prefab。\n" + string.Join("\n", _matchedPrefabs.Select(item => item.path)));
            }

            GUILayout.FlexibleSpace();

            using (new EditorGUI.DisabledScope(EditorApplication.isPlayingOrWillChangePlaymode))
            {
                GUI.backgroundColor = new Color(0.4f, 0.8f, 0.4f);
                if (GUILayout.Button("应用到已选择Prefab", GUILayout.Height(34), GUILayout.Width(180)))
                {
                    SaveConfig();
                    ApplyToMatchedPrefabs();
                }
                GUI.backgroundColor = Color.white;
            }
            EditorGUILayout.EndHorizontal();
        }

        private void SaveConfig()
        {
            if (_config == null || GetDuplicateRuleNames().Length > 0)
                return;

            EditorUtility.SetDirty(_config);
            AssetDatabase.SaveAssets();
        }

        private void ApplyToMatchedPrefabs()
        {
            if (!ValidateConfig())
                return;

            if (_matchedPrefabs.Count == 0)
                ScanMatchedPrefabs();

            var prefabPaths = GetSelectedMatchedPrefabPaths();
            if (prefabPaths.Count == 0)
            {
                EditorUtility.DisplayDialog("Tilemap层级", "没有选择任何Prefab。", "确定");
                return;
            }

            int changedPrefabCount = 0;
            int changedRendererCount = 0;
            var missingReport = new List<string>();

            try
            {
                for (int i = 0; i < prefabPaths.Count; i++)
                {
                    var prefabPath = prefabPaths[i];
                    if (EditorUtility.DisplayCancelableProgressBar("设置Tilemap层级", prefabPath, i / (float)prefabPaths.Count))
                        break;

                    if (ApplyToPrefab(prefabPath, out var changedCount, out var missingNames))
                    {
                        changedPrefabCount++;
                        changedRendererCount += changedCount;
                    }

                    if (missingNames.Count > 0)
                        missingReport.Add($"{prefabPath}: {string.Join(", ", missingNames)}");
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Debug.Log($"Tilemap层级工具完成：修改Prefab {changedPrefabCount} 个，Renderer {changedRendererCount} 个。" +
                      (missingReport.Count > 0 ? "\n未找到名称：\n" + string.Join("\n", missingReport) : string.Empty));
            EditorUtility.DisplayDialog("Tilemap层级", $"完成。\n修改Prefab: {changedPrefabCount}\n修改Renderer: {changedRendererCount}", "确定");
        }

        private bool ApplyToPrefab(string prefabPath, out int changedCount, out List<string> missingNames)
        {
            changedCount = 0;
            missingNames = GetEnabledRuleNames();

            GameObject root = null;
            bool hasChange = false;
            try
            {
                root = PrefabUtility.LoadPrefabContents(prefabPath);
                var tilemapRenderers = root.GetComponentsInChildren<TilemapRenderer>(true);
                if (tilemapRenderers.Length == 0)
                    return false;

                foreach (var renderer in tilemapRenderers)
                {
                    var rule = _config.FindRuleForName(renderer.gameObject.name);
                    if (rule == null)
                        continue;

                    missingNames.RemoveAll(name => string.Equals(name, rule.objectName, StringComparison.OrdinalIgnoreCase));

                    if (renderer.sortingLayerName == _config.sortingLayerName && renderer.sortingOrder == rule.sortingOrder)
                        continue;

                    renderer.sortingLayerName = _config.sortingLayerName;
                    renderer.sortingOrder = rule.sortingOrder;
                    EditorUtility.SetDirty(renderer);
                    changedCount++;
                    hasChange = true;
                }

                var spriteRenderers = root.GetComponentsInChildren<SpriteRenderer>(true);
                foreach (var renderer in spriteRenderers)
                {
                    if (!string.Equals(renderer.gameObject.name, "Land", StringComparison.OrdinalIgnoreCase))
                        continue;

                    var rule = _config.FindRuleForName(renderer.gameObject.name);
                    if (rule == null)
                        continue;

                    missingNames.RemoveAll(name => string.Equals(name, rule.objectName, StringComparison.OrdinalIgnoreCase));

                    if (renderer.sortingLayerName == _config.sortingLayerName && renderer.sortingOrder == rule.sortingOrder)
                        continue;

                    renderer.sortingLayerName = _config.sortingLayerName;
                    renderer.sortingOrder = rule.sortingOrder;
                    EditorUtility.SetDirty(renderer);
                    changedCount++;
                    hasChange = true;
                }

                if (hasChange)
                {
                    PrefabUtility.SaveAsPrefabAsset(root, prefabPath, out var success);
                    if (!success)
                        Debug.LogError($"保存Prefab失败: {prefabPath}");
                }
            }
            finally
            {
                if (root != null)
                    PrefabUtility.UnloadPrefabContents(root);
            }

            return hasChange;
        }

        private bool ValidateConfig()
        {
            if (!SortingLayerExists(_config.sortingLayerName))
            {
                EditorUtility.DisplayDialog("Tilemap层级", $"Sorting Layer不存在: {_config.sortingLayerName}", "确定");
                return false;
            }

            if (_config.sortingRules == null || !_config.sortingRules.Any(rule => rule != null && rule.IsValid()))
            {
                EditorUtility.DisplayDialog("Tilemap层级", "没有可用的名称规则。", "确定");
                return false;
            }

            var duplicateNames = GetDuplicateRuleNames();

            if (duplicateNames.Length > 0)
            {
                EditorUtility.DisplayDialog("Tilemap层级", "存在重复名称规则：\n" + string.Join("\n", duplicateNames), "确定");
                return false;
            }

            return true;
        }

        private bool IsRuleNameUsedByOther(string objectName, int currentIndex)
        {
            objectName = NormalizeRuleName(objectName);
            if (string.IsNullOrEmpty(objectName) || _config.sortingRules == null)
                return false;

            for (int i = 0; i < _config.sortingRules.Length; i++)
            {
                if (i == currentIndex || _config.sortingRules[i] == null)
                    continue;

                if (string.Equals(NormalizeRuleName(_config.sortingRules[i].objectName), objectName, StringComparison.OrdinalIgnoreCase))
                    return true;
            }

            return false;
        }

        private string[] GetDuplicateRuleNames()
        {
            if (_config.sortingRules == null)
                return Array.Empty<string>();

            return _config.sortingRules
                .Where(rule => rule != null && !string.IsNullOrWhiteSpace(rule.objectName))
                .GroupBy(rule => NormalizeRuleName(rule.objectName), StringComparer.OrdinalIgnoreCase)
                .Where(group => group.Count() > 1)
                .Select(group => group.Key)
                .ToArray();
        }

        private static string NormalizeRuleName(string objectName)
        {
            return string.IsNullOrWhiteSpace(objectName) ? string.Empty : objectName.Trim();
        }

        private static bool SortingLayerExists(string sortingLayerName)
        {
            return SortingLayer.layers.Any(layer => layer.name == sortingLayerName);
        }

        private List<string> GetEnabledRuleNames()
        {
            var names = new List<string>();
            if (_config.sortingRules == null)
                return names;

            foreach (var rule in _config.sortingRules)
            {
                if (rule != null && rule.IsValid())
                    names.Add(rule.objectName);
            }

            return names;
        }

        private void ScanMatchedPrefabs()
        {
            var previousSelection = _matchedPrefabs.ToDictionary(item => item.path, item => item.selected, StringComparer.OrdinalIgnoreCase);
            _matchedPrefabs = FindMatchingPrefabPaths()
                .Select(path => new PrefabMatchItem
                {
                    path = path,
                    selected = !previousSelection.TryGetValue(path, out var selected) || selected
                })
                .ToList();
            _matchScrollPos = Vector2.zero;
        }

        private List<string> GetSelectedMatchedPrefabPaths()
        {
            return _matchedPrefabs.Where(item => item.selected).Select(item => item.path).ToList();
        }

        private void SetAllMatchedSelection(bool selected)
        {
            foreach (var item in _matchedPrefabs)
                item.selected = selected;
        }

        private void InvertMatchedSelection()
        {
            foreach (var item in _matchedPrefabs)
                item.selected = !item.selected;
        }

        private List<string> FindMatchingPrefabPaths()
        {
            var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (_config.prefabPathRules == null)
                return result.ToList();

            foreach (var rawPath in _config.prefabPathRules)
            {
                var rulePath = TilemapSortingOrderConfig.NormalizePath(rawPath);
                if (string.IsNullOrEmpty(rulePath))
                    continue;

                if (rulePath.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase))
                {
                    if (AssetDatabase.LoadAssetAtPath<GameObject>(rulePath) != null && HasTilemapRenderer(rulePath))
                        result.Add(rulePath);
                    continue;
                }

                var searchRoot = GetSearchRoot(rulePath);
                if (string.IsNullOrEmpty(searchRoot))
                    continue;

                var guids = AssetDatabase.FindAssets("t:Prefab", new[] { searchRoot });
                foreach (var guid in guids)
                {
                    var path = AssetDatabase.GUIDToAssetPath(guid);
                    if (_config.IsPrefabPathMatched(path) && HasTilemapRenderer(path))
                        result.Add(path);
                }
            }

            var list = result.ToList();
            list.Sort(StringComparer.OrdinalIgnoreCase);
            return list;
        }

        private static bool HasTilemapRenderer(string prefabPath)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            return prefab != null && prefab.GetComponentInChildren<TilemapRenderer>(true) != null;
        }

        private static string GetSearchRoot(string rulePath)
        {
            if (AssetDatabase.IsValidFolder(rulePath))
                return rulePath;

            var dir = rulePath;
            while (!string.IsNullOrEmpty(dir) && dir != "Assets")
            {
                dir = Path.GetDirectoryName(dir)?.Replace("\\", "/");
                if (!string.IsNullOrEmpty(dir) && AssetDatabase.IsValidFolder(dir))
                    return dir;
            }

            return AssetDatabase.IsValidFolder("Assets") ? "Assets" : string.Empty;
        }

        private static void HandleAssetPathDrag(Rect dropRect, Action<string> setter)
        {
            var evt = UnityEngine.Event.current;
            if (!dropRect.Contains(evt.mousePosition))
                return;

            if (evt.type != UnityEngine.EventType.DragUpdated && evt.type != UnityEngine.EventType.DragPerform)
                return;

            string dragPath = null;
            foreach (var obj in DragAndDrop.objectReferences)
            {
                var path = AssetDatabase.GetAssetPath(obj);
                if (AssetDatabase.IsValidFolder(path) || path.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase))
                {
                    dragPath = path;
                    break;
                }
            }

            if (string.IsNullOrEmpty(dragPath))
                return;

            DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
            if (evt.type == UnityEngine.EventType.DragPerform)
            {
                DragAndDrop.AcceptDrag();
                setter(dragPath);
            }

            evt.Use();
        }
    }
}
