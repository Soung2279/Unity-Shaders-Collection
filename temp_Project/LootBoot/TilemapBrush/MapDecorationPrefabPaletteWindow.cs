using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.EditorTools;
using UnityEditor.Tilemaps;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace GameFramework.Editor
{
    public class MapDecorationPrefabPaletteWindow : EditorWindow
    {
        private const string DefaultPrefabRoot = "Assets/Art/Tiles/PrefabBrushPrefabs";
        private const string DefaultBrushRoot = "Assets/Art/Tiles/PrefabBrushes";

        private readonly List<PaletteTheme> _themes = new List<PaletteTheme>();
        private readonly List<PaletteItem> _visibleItems = new List<PaletteItem>();
        private readonly List<GameObject> _paintTargets = new List<GameObject>();

        private string _prefabRoot = DefaultPrefabRoot;
        private string _brushRoot = DefaultBrushRoot;
        private string _searchText = string.Empty;
        private int _themeIndex;
        private float _cellSize = 82f;
        private Vector3 _anchor = new Vector3(0.5f, 0.5f, 0.5f);
        private Vector2 _scroll;
        private GameObjectBrush _multiBrush;
        private int _dragStartIndex = -1;
        private int _dragEndIndex = -1;
        private bool _isDragging;
        private string _activeInfo = string.Empty;

        [MenuItem("Window/2D/装饰物 Prefab Palette", false, 92)]
        public static void OpenWindow()
        {
            var window = GetWindow<MapDecorationPrefabPaletteWindow>("装饰物Prefab Palette");
            window.minSize = new Vector2(680, 500);
            window.Show();
        }

        private void OnEnable()
        {
            ScanThemes();
        }

        private void OnDisable()
        {
            if (_multiBrush != null)
                DestroyImmediate(_multiBrush);
        }

        private void OnGUI()
        {
            DrawToolbar();
            DrawThemeBar();
            DrawPaintTargetBar();
            DrawBrushToolBar();
            DrawPaletteGrid();
            DrawStatusBar();
        }

        private void DrawToolbar()
        {
            EditorGUILayout.LabelField("资源路径", EditorStyles.boldLabel);
            _prefabRoot = EditorGUILayout.TextField("Prefab目录", _prefabRoot);
            _brushRoot = EditorGUILayout.TextField("PrefabBrush目录", _brushRoot);

            EditorGUILayout.BeginHorizontal();
            _searchText = EditorGUILayout.TextField("搜索", _searchText);
            _cellSize = EditorGUILayout.Slider("格子大小", _cellSize, 56f, 128f, GUILayout.Width(260));
            if (GUILayout.Button("返回瓦片模式", GUILayout.Width(110)))
                ReturnToTileMode();
            if (GUILayout.Button("刷新", GUILayout.Width(72)))
                ScanThemes();
            EditorGUILayout.EndHorizontal();

            _anchor = EditorGUILayout.Vector3Field("Brush Anchor", _anchor);
        }

        private void DrawThemeBar()
        {
            if (_themes.Count == 0)
            {
                EditorGUILayout.HelpBox("未找到装饰Prefab。请先用“装饰物 Prefab Brush 生成器”生成Prefab，或在PrefabBrush目录下放入带Prefab引用的PrefabBrush。", MessageType.Info);
                return;
            }

            var names = _themes.Select(t => $"{t.Name} ({t.Items.Count})").ToArray();
            _themeIndex = Mathf.Clamp(_themeIndex, 0, names.Length - 1);
            _themeIndex = EditorGUILayout.Popup("主题", _themeIndex, names);
        }


        private void DrawPaintTargetBar()
        {
            RefreshPaintTargets();
            if (_paintTargets.Count == 0)
            {
                EditorGUILayout.HelpBox("当前场景中没有可用的Tilemap/Grid绘制目标。", MessageType.Info);
                return;
            }

            var currentTarget = GridPaintingState.scenePaintTarget;
            var currentIndex = Mathf.Max(0, _paintTargets.IndexOf(currentTarget));
            var names = _paintTargets.Select(GetPaintTargetDisplayName).ToArray();
            EditorGUI.BeginChangeCheck();
            var selectedIndex = EditorGUILayout.Popup("绘制目标", currentIndex, names);
            if (EditorGUI.EndChangeCheck() && selectedIndex >= 0 && selectedIndex < _paintTargets.Count)
                GridPaintingState.scenePaintTarget = _paintTargets[selectedIndex];
        }

        private void RefreshPaintTargets()
        {
            _paintTargets.Clear();
            foreach (var target in GridPaintingState.validTargets)
            {
                if (target == null)
                    continue;
                if (target.GetComponent<Tilemap>() == null)
                    continue;
                _paintTargets.Add(target);
            }
        }

        private static string GetPaintTargetDisplayName(GameObject target)
        {
            if (target == null)
                return "None";

            return target.name;
        }

        private void DrawBrushToolBar()
        {
            using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
            {
                GUILayout.Label("工具", GUILayout.Width(34));
                DrawBrushToolButton<SelectTool>("选择");
                DrawBrushToolButton<MoveTool>("移动");
                DrawBrushToolButton<PaintTool>("画笔");
                DrawBrushToolButton<BoxTool>("框填充");
                DrawBrushToolButton<PickingTool>("吸管");
                DrawBrushToolButton<EraseTool>("擦除");
                DrawBrushToolButton<FillTool>("填充");
            }
        }

        private static void DrawBrushToolButton<TTool>(string label) where TTool : EditorTool
        {
            var icon = GetToolIcon<TTool>();
            var content = new GUIContent(label, icon, icon != null ? label : string.Empty);
            var isActive = IsActiveTilemapTool<TTool>();
            if (GUILayout.Toggle(isActive, content, EditorStyles.toolbarButton) && !isActive)
                SetActiveTilemapTool<TTool>();
        }

        private static void SetActiveTilemapTool<TTool>() where TTool : EditorTool
        {
            var method = typeof(TilemapEditorTool).GetMethod(
                "SetActiveEditorTool",
                System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            method?.Invoke(null, new object[] { typeof(TTool) });
            RepaintGridPaintPaletteWindow();
            SceneView.RepaintAll();
        }

        private static bool IsActiveTilemapTool<TTool>() where TTool : EditorTool
        {
            var method = typeof(TilemapEditorTool).GetMethod(
                "IsActive",
                System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            return method != null && (bool)method.Invoke(null, new object[] { typeof(TTool) });
        }

        private static Texture GetToolIcon<TTool>() where TTool : EditorTool
        {
            var tool = CreateInstance<TTool>();
            try
            {
                return tool.toolbarIcon?.image;
            }
            finally
            {
                DestroyImmediate(tool);
            }
        }

        private void DrawPaletteGrid()
        {
            if (_themes.Count == 0)
                return;

            BuildVisibleItems();

            var viewWidth = Mathf.Max(1f, position.width - 24f);
            var stepX = _cellSize;
            var stepY = _cellSize + 20f;
            var columns = Mathf.Max(1, Mathf.FloorToInt(viewWidth / stepX));
            var rows = Mathf.CeilToInt(_visibleItems.Count / (float)columns);
            var contentHeight = Mathf.Max(stepY, rows * stepY + 8f);

            _scroll = EditorGUILayout.BeginScrollView(_scroll);
            var contentRect = GUILayoutUtility.GetRect(viewWidth, contentHeight);
            DrawItems(contentRect, columns, stepX, stepY);
            HandleMouse(contentRect, columns, stepX, stepY);
            EditorGUILayout.EndScrollView();
        }

        private void DrawItems(Rect contentRect, int columns, float stepX, float stepY)
        {
            for (var i = 0; i < _visibleItems.Count; i++)
            {
                var rect = GetCellRect(contentRect, i, columns, stepX, stepY);
                var item = _visibleItems[i];
                var selected = IsIndexInDragSelection(i, columns);

                if (selected)
                    EditorGUI.DrawRect(new Rect(rect.x - 2f, rect.y - 2f, rect.width + 4f, rect.height + 4f), new Color(0.24f, 0.48f, 0.9f, 0.75f));

                GUI.Box(rect, GUIContent.none);
                var preview = GetPreview(item.Prefab);
                if (preview != null)
                    GUI.DrawTexture(new Rect(rect.x + 5f, rect.y + 5f, rect.width - 10f, rect.height - 10f), preview, ScaleMode.ScaleToFit);

                var labelRect = new Rect(rect.x, rect.yMax + 2f, rect.width, 18f);
                GUI.Label(labelRect, item.Name, EditorStyles.centeredGreyMiniLabel);
            }
        }

        private void HandleMouse(Rect contentRect, int columns, float stepX, float stepY)
        {
            var e = UnityEngine.Event.current;
            if (e.button != 0)
                return;

            var index = GetIndexAtMouse(contentRect, columns, stepX, stepY, e.mousePosition);
            if (e.type == EventType.MouseDown && index >= 0)
            {
                _dragStartIndex = index;
                _dragEndIndex = index;
                _isDragging = true;
                e.Use();
                Repaint();
            }
            else if (e.type == EventType.MouseDrag && _isDragging)
            {
                if (index >= 0)
                    _dragEndIndex = index;
                e.Use();
                Repaint();
            }
            else if (e.type == EventType.MouseUp && _isDragging)
            {
                if (index >= 0)
                    _dragEndIndex = index;
                ApplySelection(columns);
                _isDragging = false;
                e.Use();
                Repaint();
            }
        }

        private void DrawStatusBar()
        {
            EditorGUILayout.Space(4);
            EditorGUILayout.HelpBox("在此窗口单击或框选装饰物，会自动切换当前Grid Brush；随后直接在Scene中的目标Tilemap/Grid上刷Prefab。", MessageType.None);
            if (!string.IsNullOrEmpty(_activeInfo))
                EditorGUILayout.LabelField("当前选择", _activeInfo, EditorStyles.miniBoldLabel);
        }

        private Rect GetCellRect(Rect contentRect, int index, int columns, float stepX, float stepY)
        {
            var col = index % columns;
            var row = index / columns;
            return new Rect(contentRect.x + col * stepX + 4f, contentRect.y + row * stepY + 4f, _cellSize - 8f, _cellSize - 8f);
        }

        private int GetIndexAtMouse(Rect contentRect, int columns, float stepX, float stepY, Vector2 mousePosition)
        {
            for (var i = 0; i < _visibleItems.Count; i++)
            {
                if (GetCellRect(contentRect, i, columns, stepX, stepY).Contains(mousePosition))
                    return i;
            }
            return -1;
        }

        private bool IsIndexInDragSelection(int index, int columns)
        {
            if (_dragStartIndex < 0 || _dragEndIndex < 0 || (!_isDragging && index != _dragEndIndex))
                return false;

            GetSelectionBounds(columns, out var minCol, out var maxCol, out var minRow, out var maxRow);
            var col = index % columns;
            var row = index / columns;
            return col >= minCol && col <= maxCol && row >= minRow && row <= maxRow;
        }

        private void ApplySelection(int columns)
        {
            if (_dragStartIndex < 0 || _dragEndIndex < 0)
                return;

            GetSelectionBounds(columns, out var minCol, out var maxCol, out var minRow, out var maxRow);
            var selected = new List<SelectedCell>();
            for (var row = minRow; row <= maxRow; row++)
            {
                for (var col = minCol; col <= maxCol; col++)
                {
                    var index = row * columns + col;
                    if (index >= 0 && index < _visibleItems.Count)
                        selected.Add(new SelectedCell(_visibleItems[index], col - minCol, maxRow - row));
                }
            }

            if (selected.Count == 0)
                return;

            if (selected.Count == 1)
                ActivateSingleBrush(selected[0].Item);
            else
                ActivateMultiBrush(selected, maxCol - minCol + 1, maxRow - minRow + 1);
        }

        private void GetSelectionBounds(int columns, out int minCol, out int maxCol, out int minRow, out int maxRow)
        {
            var startCol = _dragStartIndex % columns;
            var endCol = _dragEndIndex % columns;
            var startRow = _dragStartIndex / columns;
            var endRow = _dragEndIndex / columns;
            minCol = Mathf.Min(startCol, endCol);
            maxCol = Mathf.Max(startCol, endCol);
            minRow = Mathf.Min(startRow, endRow);
            maxRow = Mathf.Max(startRow, endRow);
        }

        private void ActivateSingleBrush(PaletteItem item)
        {
            var brush = item.Brush != null ? item.Brush : CreateOrUpdatePrefabBrush(item);
            var serializedObject = new SerializedObject(brush);
            var anchorProperty = serializedObject.FindProperty("m_Anchor");
            if (anchorProperty != null)
                anchorProperty.vector3Value = _anchor;
            serializedObject.ApplyModifiedPropertiesWithoutUndo();
            EditorUtility.SetDirty(brush);

            GridPaintingState.gridBrush = brush;
            RepaintGridPaintPaletteWindow();
            _activeInfo = item.Name + " / Prefab Brush";
        }

        private void ActivateMultiBrush(List<SelectedCell> selected, int width, int height)
        {
            if (_multiBrush == null)
            {
                _multiBrush = CreateInstance<GameObjectBrush>();
                _multiBrush.hideFlags = HideFlags.HideAndDontSave;
                _multiBrush.name = "Decoration Prefab Multi Brush";
            }

            _multiBrush.m_Anchor = _anchor;
            _multiBrush.Reset();
            _multiBrush.Init(new Vector3Int(width, height, 1), Vector3Int.zero);
            foreach (var cell in selected)
            {
                var pos = new Vector3Int(cell.X, cell.Y, 0);
                _multiBrush.SetGameObject(pos, cell.Item.Prefab);
                _multiBrush.SetScale(pos, Vector3.one);
                _multiBrush.SetOffset(pos, Vector3.zero);
                _multiBrush.SetOrientation(pos, Quaternion.identity);
            }

            GridPaintingState.gridBrush = _multiBrush;
            RepaintGridPaintPaletteWindow();
            _activeInfo = selected.Count + " objects / GameObject Brush";
        }

        private static void ReturnToTileMode()
        {
            var stateType = typeof(GridPaintingState);
            var defaultBrushProperty = stateType.GetProperty(
                "defaultBrush",
                System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            var defaultBrush = defaultBrushProperty?.GetValue(null) as GridBrushBase;
            if (defaultBrush != null)
                GridPaintingState.gridBrush = defaultBrush;

            SetActiveTilemapTool<PaintTool>();
            EditorApplication.ExecuteMenuItem("Window/2D/Tile Palette");
            RepaintGridPaintPaletteWindow();
        }

        private static void RepaintGridPaintPaletteWindow()
        {
            var method = typeof(GridPaintingState).GetMethod(
                "RepaintGridPaintPaletteWindow",
                System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            method?.Invoke(null, null);
        }

        private PrefabBrush CreateOrUpdatePrefabBrush(PaletteItem item)
        {
            var themeFolder = CombineAssetPath(_brushRoot, CurrentTheme.Name);
            EnsureFolder(themeFolder);
            var brushPath = CombineAssetPath(themeFolder, item.Name + "_PrefabBrush.asset");
            var brush = AssetDatabase.LoadAssetAtPath<PrefabBrush>(brushPath);
            if (brush == null)
            {
                brush = CreateInstance<PrefabBrush>();
                AssetDatabase.CreateAsset(brush, brushPath);
            }

            var serializedObject = new SerializedObject(brush);
            var prefabProperty = serializedObject.FindProperty("m_Prefab");
            var anchorProperty = serializedObject.FindProperty("m_Anchor");
            if (prefabProperty != null)
                prefabProperty.objectReferenceValue = item.Prefab;
            if (anchorProperty != null)
                anchorProperty.vector3Value = _anchor;
            serializedObject.ApplyModifiedPropertiesWithoutUndo();
            EditorUtility.SetDirty(brush);
            AssetDatabase.SaveAssets();
            item.Brush = brush;
            return brush;
        }

        private void BuildVisibleItems()
        {
            _visibleItems.Clear();
            var search = _searchText.Trim().ToLowerInvariant();
            foreach (var item in CurrentTheme.Items)
            {
                if (!string.IsNullOrEmpty(search) && !item.Name.ToLowerInvariant().Contains(search))
                    continue;
                _visibleItems.Add(item);
            }
        }

        private PaletteTheme CurrentTheme => _themes[Mathf.Clamp(_themeIndex, 0, _themes.Count - 1)];

        private void ScanThemes()
        {
            _themes.Clear();
            var themeMap = new Dictionary<string, PaletteTheme>();

            if (AssetDatabase.IsValidFolder(_prefabRoot))
            {
                var prefabGuids = AssetDatabase.FindAssets("t:Prefab", new[] { _prefabRoot });
                foreach (var guid in prefabGuids)
                {
                    var prefabPath = AssetDatabase.GUIDToAssetPath(guid);
                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
                    if (prefab == null)
                        continue;

                    var themeName = GetThemeName(_prefabRoot, prefabPath);
                    var name = Path.GetFileNameWithoutExtension(prefabPath);
                    var brushPath = CombineAssetPath(CombineAssetPath(_brushRoot, themeName), name + "_PrefabBrush.asset");
                    AddPaletteItem(themeMap, themeName, name, prefab, AssetDatabase.LoadAssetAtPath<GridBrushBase>(brushPath));
                }
            }

            if (AssetDatabase.IsValidFolder(_brushRoot))
            {
                ScanBrushAssets(themeMap, "t:PrefabBrush");
                ScanBrushAssets(themeMap, "t:PrefabRandomBrush");
            }

            foreach (var theme in themeMap.Values)
            {
                theme.Items.Sort((a, b) => string.CompareOrdinal(a.Name, b.Name));
                _themes.Add(theme);
            }
            _themes.Sort((a, b) => string.CompareOrdinal(a.Name, b.Name));
            _themeIndex = Mathf.Clamp(_themeIndex, 0, Mathf.Max(0, _themes.Count - 1));
        }

        private void ScanBrushAssets(Dictionary<string, PaletteTheme> themeMap, string filter)
        {
            var brushGuids = AssetDatabase.FindAssets(filter, new[] { _brushRoot });
            foreach (var guid in brushGuids)
            {
                var brushPath = AssetDatabase.GUIDToAssetPath(guid);
                var brush = AssetDatabase.LoadAssetAtPath<GridBrushBase>(brushPath);
                var prefab = GetPreviewPrefabFromBrush(brush);
                if (prefab == null)
                    continue;

                var themeName = GetThemeName(_brushRoot, brushPath);
                var name = Path.GetFileNameWithoutExtension(brushPath);
                if (name.EndsWith("_PrefabBrush", StringComparison.Ordinal))
                    name = name.Substring(0, name.Length - "_PrefabBrush".Length);
                if (name.EndsWith("_PrefabRandomBrush", StringComparison.Ordinal))
                    name = name.Substring(0, name.Length - "_PrefabRandomBrush".Length);
                AddPaletteItem(themeMap, themeName, name, prefab, brush);
            }
        }

        private static string GetThemeName(string root, string assetPath)
        {
            var relative = assetPath.Substring(root.TrimEnd('/').Length).TrimStart('/');
            return relative.Contains("/") ? relative.Substring(0, relative.IndexOf('/')) : "Default";
        }

        private static GameObject GetPreviewPrefabFromBrush(GridBrushBase brush)
        {
            if (brush == null)
                return null;

            var serializedObject = new SerializedObject(brush);
            var prefabProperty = serializedObject.FindProperty("m_Prefab");
            if (prefabProperty != null)
                return prefabProperty.objectReferenceValue as GameObject;

            var prefabsProperty = serializedObject.FindProperty("m_Prefabs");
            if (prefabsProperty == null || !prefabsProperty.isArray || prefabsProperty.arraySize == 0)
                return null;

            for (var i = 0; i < prefabsProperty.arraySize; i++)
            {
                var prefab = prefabsProperty.GetArrayElementAtIndex(i).objectReferenceValue as GameObject;
                if (prefab != null)
                    return prefab;
            }
            return null;
        }

        private static void AddPaletteItem(Dictionary<string, PaletteTheme> themeMap, string themeName, string name, GameObject prefab, GridBrushBase brush)
        {
            if (!themeMap.TryGetValue(themeName, out var theme))
            {
                theme = new PaletteTheme(themeName);
                themeMap.Add(themeName, theme);
            }

            var prefabPath = AssetDatabase.GetAssetPath(prefab);
            var existing = theme.Items.FirstOrDefault(i => AssetDatabase.GetAssetPath(i.Prefab) == prefabPath);
            if (existing != null)
            {
                if (existing.Brush == null)
                    existing.Brush = brush;
                return;
            }

            theme.Items.Add(new PaletteItem
            {
                Name = name,
                Prefab = prefab,
                Brush = brush
            });
        }

        private static Texture GetPreview(GameObject prefab)
        {
            var preview = AssetPreview.GetAssetPreview(prefab);
            return preview != null ? preview : AssetPreview.GetMiniThumbnail(prefab);
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
            var current = "Assets";
            for (var i = 1; i < parts.Length; i++)
            {
                var next = current + "/" + parts[i];
                if (!AssetDatabase.IsValidFolder(next))
                    AssetDatabase.CreateFolder(current, parts[i]);
                current = next;
            }
        }

        private class PaletteTheme
        {
            public readonly string Name;
            public readonly List<PaletteItem> Items = new List<PaletteItem>();

            public PaletteTheme(string name)
            {
                Name = name;
            }
        }

        private class PaletteItem
        {
            public string Name;
            public GameObject Prefab;
            public GridBrushBase Brush;
        }

        private readonly struct SelectedCell
        {
            public readonly PaletteItem Item;
            public readonly int X;
            public readonly int Y;

            public SelectedCell(PaletteItem item, int x, int y)
            {
                Item = item;
                X = x;
                Y = y;
            }
        }
    }
}
