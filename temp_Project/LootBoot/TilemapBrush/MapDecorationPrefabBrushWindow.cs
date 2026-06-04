using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Tilemaps;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Tilemaps;

namespace GameFramework.Editor
{
    public class MapDecorationPrefabBrushWindow : EditorWindow
    {
        private const string DefaultPaletteRoot = "Assets/Art/Tiles/Palette";
        private const string DefaultPrefabRoot = "Assets/Art/Tiles/PrefabBrushPrefabs";
        private const string DefaultBrushRoot = "Assets/Art/Tiles/PrefabBrushes";

        private readonly List<ThemeData> _themes = new List<ThemeData>();
        private readonly Dictionary<string, bool> _selectionCache = new Dictionary<string, bool>();

        private string _paletteRoot = DefaultPaletteRoot;
        private string _prefabRoot = DefaultPrefabRoot;
        private string _brushRoot = DefaultBrushRoot;
        private string _includeKeywords = "tree,stone,rock,zhalan,barrier,zhuangshi,flower,cao";
        private string _excludeKeywords = "way,road,land,hill,mountain,water,ice";
        private string _searchText = string.Empty;
        private string _sortingLayerName = "Default";
        private int _sortingOrder = 2;
        private int _themeIndex;
        private bool _showSelectedOnly;
        private bool _overwriteExistingPrefabs;
        private bool _createPrefabBrushAssets = true;
        private Vector3 _brushAnchor = new Vector3(0.5f, 0.5f, 0.5f);
        private Vector2 _scrollPos;

        [MenuItem("Game Framework/Map/装饰物 Prefab Brush 生成器", false, 91)]
        public static void OpenWindow()
        {
            var window = GetWindow<MapDecorationPrefabBrushWindow>("装饰物PrefabBrush生成器");
            window.minSize = new Vector2(900, 620);
            window.Show();
        }

        private void OnEnable()
        {
            if (_themes.Count == 0)
                ScanPalettes();
        }

        private void OnGUI()
        {
            DrawPathSettings();
            EditorGUILayout.Space(6);
            DrawKeywordTools();
            EditorGUILayout.Space(6);
            DrawThemeSelector();
            EditorGUILayout.Space(6);
            DrawGenerateSettings();
            EditorGUILayout.Space(6);
            DrawTileList();
            EditorGUILayout.Space(6);
            DrawGenerateButtons();
        }

        private void DrawPathSettings()
        {
            EditorGUILayout.LabelField("资源路径", EditorStyles.boldLabel);
            _paletteRoot = EditorGUILayout.TextField("Palette Root", _paletteRoot);
            _prefabRoot = EditorGUILayout.TextField("Prefab输出目录", _prefabRoot);
            _brushRoot = EditorGUILayout.TextField("PrefabBrush输出目录", _brushRoot);

            EditorGUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("重新扫描Palette", GUILayout.Width(140)))
                ScanPalettes();
            EditorGUILayout.EndHorizontal();
        }

        private void DrawKeywordTools()
        {
            EditorGUILayout.LabelField("批量勾选规则", EditorStyles.boldLabel);
            _includeKeywords = EditorGUILayout.TextField("包含关键字", _includeKeywords);
            _excludeKeywords = EditorGUILayout.TextField("排除关键字", _excludeKeywords);

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("按关键字勾选当前主题", GUILayout.Height(26)))
                ApplyKeywordsToTheme(CurrentTheme);
            if (GUILayout.Button("按关键字勾选所有主题", GUILayout.Height(26)))
                ApplyKeywordsToAllThemes();
            if (GUILayout.Button("当前主题全选", GUILayout.Height(26)))
                SetThemeSelection(CurrentTheme, true);
            if (GUILayout.Button("当前主题全不选", GUILayout.Height(26)))
                SetThemeSelection(CurrentTheme, false);
            EditorGUILayout.EndHorizontal();
        }

        private void DrawThemeSelector()
        {
            EditorGUILayout.LabelField("主题", EditorStyles.boldLabel);
            if (_themes.Count == 0)
            {
                EditorGUILayout.HelpBox("未扫描到Palette。", MessageType.Warning);
                return;
            }

            var names = _themes.Select(t => $"{t.Name}  ({t.SelectedCount}/{t.Items.Count})").ToArray();
            _themeIndex = Mathf.Clamp(_themeIndex, 0, names.Length - 1);
            _themeIndex = EditorGUILayout.Popup("当前主题", _themeIndex, names);

            EditorGUILayout.BeginHorizontal();
            _searchText = EditorGUILayout.TextField("搜索", _searchText);
            _showSelectedOnly = EditorGUILayout.ToggleLeft("只显示已勾选", _showSelectedOnly, GUILayout.Width(120));
            EditorGUILayout.EndHorizontal();
        }

        private void DrawGenerateSettings()
        {
            EditorGUILayout.LabelField("生成设置", EditorStyles.boldLabel);
            _sortingLayerName = EditorGUILayout.TextField("Sorting Group Layer", _sortingLayerName);
            _sortingOrder = EditorGUILayout.IntField("Sorting Group Order", _sortingOrder);
            _brushAnchor = EditorGUILayout.Vector3Field("PrefabBrush Anchor", _brushAnchor);
            _overwriteExistingPrefabs = EditorGUILayout.Toggle("覆盖已有Prefab", _overwriteExistingPrefabs);
            _createPrefabBrushAssets = EditorGUILayout.Toggle("生成PrefabBrush资源", _createPrefabBrushAssets);
        }

        private void DrawTileList()
        {
            var theme = CurrentTheme;
            if (theme == null)
                return;

            EditorGUILayout.LabelField($"{theme.Name} Tile列表", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            GUILayout.Label("选", GUILayout.Width(24));
            GUILayout.Label("Tile", GUILayout.Width(190));
            GUILayout.Label("Sprite", GUILayout.Width(190));
            GUILayout.Label("Palette坐标", GUILayout.Width(100));
            GUILayout.Label("路径");
            EditorGUILayout.EndHorizontal();

            _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
            foreach (var item in GetVisibleItems(theme))
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUI.BeginChangeCheck();
                item.Selected = EditorGUILayout.Toggle(item.Selected, GUILayout.Width(24));
                if (EditorGUI.EndChangeCheck())
                    _selectionCache[item.TilePath] = item.Selected;

                using (new EditorGUI.DisabledScope(true))
                {
                    EditorGUILayout.ObjectField(item.TileBase, typeof(TileBase), false, GUILayout.Width(190));
                    EditorGUILayout.ObjectField(item.Sprite, typeof(Sprite), false, GUILayout.Width(190));
                }

                GUILayout.Label(item.FirstPosition.ToString(), GUILayout.Width(100));
                GUILayout.Label(item.TilePath, EditorStyles.miniLabel);
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }

        private void DrawGenerateButtons()
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("生成当前主题", GUILayout.Height(36), GUILayout.Width(160)))
                GenerateThemes(new[] { CurrentTheme });
            if (GUILayout.Button("生成所有已勾选主题", GUILayout.Height(36), GUILayout.Width(180)))
                GenerateThemes(_themes.Where(t => t.SelectedCount > 0));
            EditorGUILayout.EndHorizontal();
        }

        private ThemeData CurrentTheme
        {
            get
            {
                if (_themes.Count == 0)
                    return null;
                _themeIndex = Mathf.Clamp(_themeIndex, 0, _themes.Count - 1);
                return _themes[_themeIndex];
            }
        }

        private IEnumerable<TileItem> GetVisibleItems(ThemeData theme)
        {
            var search = _searchText.Trim().ToLowerInvariant();
            foreach (var item in theme.Items)
            {
                if (_showSelectedOnly && !item.Selected)
                    continue;

                if (!string.IsNullOrEmpty(search) &&
                    !item.Name.ToLowerInvariant().Contains(search) &&
                    !item.TilePath.ToLowerInvariant().Contains(search))
                {
                    continue;
                }

                yield return item;
            }
        }

        private void ScanPalettes()
        {
            SaveSelectionCache();
            _themes.Clear();

            if (!AssetDatabase.IsValidFolder(_paletteRoot))
                return;

            var paletteGuids = AssetDatabase.FindAssets("t:Prefab", new[] { _paletteRoot });
            foreach (var guid in paletteGuids)
            {
                var palettePath = AssetDatabase.GUIDToAssetPath(guid);
                if (!palettePath.EndsWith("_Palette.prefab", StringComparison.OrdinalIgnoreCase) ||
                    palettePath.EndsWith("_Decoration_Palette.prefab", StringComparison.OrdinalIgnoreCase))
                    continue;

                var palette = AssetDatabase.LoadAssetAtPath<GameObject>(palettePath);
                if (palette == null)
                    continue;

                var tilemap = palette.GetComponentInChildren<Tilemap>();
                if (tilemap == null)
                    continue;

                var theme = new ThemeData
                {
                    Name = Path.GetFileNameWithoutExtension(palettePath).Replace("_Palette", string.Empty),
                    PalettePath = palettePath
                };

                var itemMap = new Dictionary<string, TileItem>();
                foreach (var pos in tilemap.cellBounds.allPositionsWithin)
                {
                    var tileBase = tilemap.GetTile(pos);
                    if (tileBase == null)
                        continue;

                    var tilePath = AssetDatabase.GetAssetPath(tileBase);
                    if (string.IsNullOrEmpty(tilePath))
                        continue;

                    if (!itemMap.TryGetValue(tilePath, out var item))
                    {
                        var tile = tileBase as Tile;
                        var sprite = tile != null ? tile.sprite : GetSpriteBySerializedTile(tileBase);
                        if (sprite == null)
                            continue;

                        item = new TileItem
                        {
                            Name = tileBase.name,
                            TilePath = tilePath,
                            TileBase = tileBase,
                            Sprite = sprite,
                            FirstPosition = pos,
                            Selected = GetCachedSelection(tilePath)
                        };
                        itemMap.Add(tilePath, item);
                        theme.Items.Add(item);
                    }

                    item.Positions.Add(pos);
                }

                theme.Items.Sort(CompareTileItemsByPosition);
                _themes.Add(theme);
            }

            _themes.Sort((a, b) => string.CompareOrdinal(a.Name, b.Name));
            _themeIndex = Mathf.Clamp(_themeIndex, 0, Mathf.Max(0, _themes.Count - 1));
        }

        private static Sprite GetSpriteBySerializedTile(TileBase tileBase)
        {
            var serializedObject = new SerializedObject(tileBase);
            var spriteProperty = serializedObject.FindProperty("m_Sprite");
            return spriteProperty != null ? spriteProperty.objectReferenceValue as Sprite : null;
        }

        private void SaveSelectionCache()
        {
            foreach (var theme in _themes)
            {
                foreach (var item in theme.Items)
                    _selectionCache[item.TilePath] = item.Selected;
            }
        }

        private bool GetCachedSelection(string tilePath)
        {
            return _selectionCache.TryGetValue(tilePath, out var selected) && selected;
        }

        private static int CompareTileItemsByPosition(TileItem a, TileItem b)
        {
            var y = -a.FirstPosition.y.CompareTo(b.FirstPosition.y);
            if (y != 0)
                return y;
            return a.FirstPosition.x.CompareTo(b.FirstPosition.x);
        }

        private void ApplyKeywordsToAllThemes()
        {
            foreach (var theme in _themes)
                ApplyKeywordsToTheme(theme);
        }

        private void ApplyKeywordsToTheme(ThemeData theme)
        {
            if (theme == null)
                return;

            foreach (var item in theme.Items)
            {
                item.Selected = MatchesKeywords(item);
                _selectionCache[item.TilePath] = item.Selected;
            }
        }

        private void SetThemeSelection(ThemeData theme, bool selected)
        {
            if (theme == null)
                return;

            foreach (var item in theme.Items)
            {
                item.Selected = selected;
                _selectionCache[item.TilePath] = selected;
            }
        }

        private bool MatchesKeywords(TileItem item)
        {
            var text = (item.Name + " " + item.TilePath).ToLowerInvariant();
            var includeKeywords = SplitKeywords(_includeKeywords);
            var excludeKeywords = SplitKeywords(_excludeKeywords);

            if (excludeKeywords.Any(text.Contains))
                return false;

            return includeKeywords.Count > 0 && includeKeywords.Any(text.Contains);
        }

        private static List<string> SplitKeywords(string keywords)
        {
            return keywords.Split(new[] { ',', ';', '，', '；', ' ' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(k => k.Trim().ToLowerInvariant())
                .Where(k => !string.IsNullOrEmpty(k))
                .Distinct()
                .ToList();
        }

        private void GenerateThemes(IEnumerable<ThemeData> themes)
        {
            var validThemes = themes.Where(t => t != null && t.SelectedCount > 0).ToList();
            if (validThemes.Count == 0)
            {
                EditorUtility.DisplayDialog("装饰物PrefabBrush生成器", "没有勾选任何Tile。", "确定");
                return;
            }

            EnsureFolder(_prefabRoot);
            if (_createPrefabBrushAssets)
                EnsureFolder(_brushRoot);
            var generatedPrefabs = 0;
            var generatedBrushes = 0;
            var items = validThemes.SelectMany(t => t.SelectedItems.Select(i => new GenerateContext(t, i))).ToList();

            try
            {
                for (var i = 0; i < items.Count; i++)
                {
                    var context = items[i];
                    var progress = items.Count == 0 ? 1f : (float)i / items.Count;
                    if (EditorUtility.DisplayCancelableProgressBar("生成装饰物PrefabBrush", context.Item.Name, progress))
                        break;

                    var prefab = CreateOrLoadPrefab(context.Theme, context.Item, out var prefabCreatedOrUpdated);
                    if (prefab == null)
                        continue;

                    if (prefabCreatedOrUpdated)
                        generatedPrefabs++;

                    if (_createPrefabBrushAssets && CreateOrUpdatePrefabBrush(context.Theme, context.Item, prefab))
                        generatedBrushes++;
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            EditorUtility.DisplayDialog(
                "装饰物PrefabBrush生成器",
                $"完成。\nPrefab生成/更新：{generatedPrefabs}\nPrefabBrush生成/更新：{generatedBrushes}",
                "确定");
        }

        private GameObject CreateOrLoadPrefab(ThemeData theme, TileItem item, out bool createdOrUpdated)
        {
            createdOrUpdated = false;
            var themeFolder = CombineAssetPath(_prefabRoot, theme.Name);
            EnsureFolder(themeFolder);

            var prefabPath = CombineAssetPath(themeFolder, GetPrefabFileName(theme, item));
            var existingPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if (existingPrefab != null && !_overwriteExistingPrefabs)
                return existingPrefab;

            var temp = new GameObject(item.Name);
            var sortingGroup = temp.AddComponent<SortingGroup>();
            sortingGroup.sortingLayerName = _sortingLayerName;
            sortingGroup.sortingOrder = _sortingOrder;

            var spriteRenderer = temp.AddComponent<SpriteRenderer>();
            spriteRenderer.sprite = item.Sprite;
            spriteRenderer.sortingLayerName = _sortingLayerName;
            spriteRenderer.sortingOrder = 0;

            var tile = item.TileBase as Tile;
            if (tile != null)
                spriteRenderer.color = tile.color;

            var prefab = PrefabUtility.SaveAsPrefabAsset(temp, prefabPath);
            DestroyImmediate(temp);
            createdOrUpdated = prefab != null;
            return prefab;
        }

        private bool CreateOrUpdatePrefabBrush(ThemeData theme, TileItem item, GameObject prefab)
        {
            var themeFolder = CombineAssetPath(_brushRoot, theme.Name);
            EnsureFolder(themeFolder);

            var brushPath = CombineAssetPath(themeFolder, Path.GetFileNameWithoutExtension(GetPrefabFileName(theme, item)) + "_PrefabBrush.asset");
            var brush = AssetDatabase.LoadAssetAtPath<PrefabBrush>(brushPath);
            if (brush == null)
            {
                brush = CreateInstance<PrefabBrush>();
                AssetDatabase.CreateAsset(brush, brushPath);
            }

            var serializedObject = new SerializedObject(brush);
            var prefabProperty = serializedObject.FindProperty("m_Prefab");
            var anchorProperty = serializedObject.FindProperty("m_Anchor");
            if (prefabProperty == null)
                return false;

            prefabProperty.objectReferenceValue = prefab;
            if (anchorProperty != null)
                anchorProperty.vector3Value = _brushAnchor;

            serializedObject.ApplyModifiedPropertiesWithoutUndo();
            EditorUtility.SetDirty(brush);
            return true;
        }

        private string GetPrefabFileName(ThemeData theme, TileItem item)
        {
            var duplicateNameCount = theme.Items.Count(i => i.Name == item.Name);
            var baseName = duplicateNameCount > 1
                ? Path.GetFileName(Path.GetDirectoryName(item.TilePath)) + "_" + item.Name
                : item.Name;

            return SanitizeFileName(baseName) + ".prefab";
        }

        private static string SanitizeFileName(string fileName)
        {
            foreach (var invalidChar in Path.GetInvalidFileNameChars())
                fileName = fileName.Replace(invalidChar, '_');
            return fileName.Replace('/', '_').Replace('\\', '_');
        }

        private static string CombineAssetPath(string left, string right)
        {
            return left.TrimEnd('/', '\\') + "/" + right.TrimStart('/', '\\');
        }

        private static void EnsureFolder(string folderPath)
        {
            folderPath = folderPath.Replace('\\', '/').TrimEnd('/');
            if (AssetDatabase.IsValidFolder(folderPath))
                return;

            var parts = folderPath.Split('/');
            if (parts.Length == 0 || parts[0] != "Assets")
                throw new InvalidOperationException("只支持Assets目录下的输出路径：" + folderPath);

            var current = "Assets";
            for (var i = 1; i < parts.Length; i++)
            {
                var next = current + "/" + parts[i];
                if (!AssetDatabase.IsValidFolder(next))
                    AssetDatabase.CreateFolder(current, parts[i]);
                current = next;
            }
        }

        private class ThemeData
        {
            public string Name;
            public string PalettePath;
            public readonly List<TileItem> Items = new List<TileItem>();
            public IEnumerable<TileItem> SelectedItems => Items.Where(i => i.Selected);
            public int SelectedCount => Items.Count(i => i.Selected);
        }

        private class TileItem
        {
            public string Name;
            public string TilePath;
            public TileBase TileBase;
            public Sprite Sprite;
            public Vector3Int FirstPosition;
            public bool Selected;
            public readonly List<Vector3Int> Positions = new List<Vector3Int>();
        }

        private readonly struct GenerateContext
        {
            public readonly ThemeData Theme;
            public readonly TileItem Item;

            public GenerateContext(ThemeData theme, TileItem item)
            {
                Theme = theme;
                Item = item;
            }
        }
    }
}
