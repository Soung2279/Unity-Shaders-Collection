using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace GameFramework.Editor
{
    public class TileSpritePivotToolWindow : EditorWindow
    {
        private const string DefaultRoot = "Assets/Art/Sprite/Map";

        private readonly List<SpriteItem> _items = new List<SpriteItem>();
        private readonly List<SpriteItem> _visibleItems = new List<SpriteItem>();
        private readonly Dictionary<string, bool> _selectionCache = new Dictionary<string, bool>();

        private string _rootPath = DefaultRoot;
        private string _searchText = string.Empty;
        private string _excludeKeywords = string.Empty;
        private Vector2 _listScroll;
        private Vector2 _inspectorScroll;
        private int _activeIndex = -1;
        private Vector2 _batchPivot = new Vector2(0.5f, 0f);
        private bool _showSelectedOnly;

        [MenuItem("Window/2D/Tile Sprite Pivot Tool", false, 93)]
        public static void OpenWindow()
        {
            var window = GetWindow<TileSpritePivotToolWindow>("Tile Sprite Pivot Tool");
            window.minSize = new Vector2(980f, 640f);
            window.Show();
        }

        private void OnEnable()
        {
            if (_items.Count == 0)
                ScanRoot();
        }

        private void OnGUI()
        {
            DrawTopBar();
            RefreshVisibleItems();
            EditorGUILayout.Space(6f);
            DrawBatchBar();
            EditorGUILayout.Space(6f);

            using (new EditorGUILayout.HorizontalScope())
            {
                DrawListPanel();
                DrawInspectorPanel();
            }
        }

        private void DrawTopBar()
        {
            EditorGUILayout.LabelField("扫描范围", EditorStyles.boldLabel);
            _rootPath = EditorGUILayout.TextField("Root", _rootPath);

            using (new EditorGUILayout.HorizontalScope())
            {
                _searchText = EditorGUILayout.TextField("搜索", _searchText);
                _showSelectedOnly = EditorGUILayout.ToggleLeft("只显示勾选", _showSelectedOnly, GUILayout.Width(90f));
                if (GUILayout.Button("从当前选择带入", GUILayout.Width(120f)))
                    ApplyRootFromSelection();
                if (GUILayout.Button("扫描", GUILayout.Width(80f)))
                    ScanRoot();
                if (GUILayout.Button("保存全部修改", GUILayout.Width(120f)))
                    SaveDirtyItems(GetDirtyItems());
            }

            EditorGUILayout.HelpBox("只处理 Sprite 导入模式为 Single 的贴图。左侧勾选用于批量应用，右侧可点击预览图直接设置轴心。X/Y 为 0~1 归一化坐标，左下角是 (0,0)。", MessageType.Info);
            if (!string.IsNullOrEmpty(_excludeKeywords))
                EditorGUILayout.LabelField("排除关键字", _excludeKeywords, EditorStyles.miniLabel);
        }

        private void DrawBatchBar()
        {
            EditorGUILayout.LabelField("批量设置", EditorStyles.boldLabel);
            using (new EditorGUILayout.HorizontalScope())
            {
                _batchPivot = EditorGUILayout.Vector2Field("批量Pivot", _batchPivot);
                _batchPivot.x = Mathf.Clamp01(_batchPivot.x);
                _batchPivot.y = Mathf.Clamp01(_batchPivot.y);

                if (GUILayout.Button("应用到勾选", GUILayout.Width(100f)))
                    ApplyBatchPivotToSelected(_batchPivot);
                if (GUILayout.Button("激活项 -> 勾选", GUILayout.Width(110f)))
                    ApplyActivePivotToSelected();
                if (GUILayout.Button("当前全部勾选", GUILayout.Width(100f)))
                    SetAllVisibleSelected(true);
                if (GUILayout.Button("当前全部取消", GUILayout.Width(100f)))
                    SetAllVisibleSelected(false);
            }
        }

        private void DrawListPanel()
        {
            using (new EditorGUILayout.VerticalScope(GUILayout.Width(430f)))
            {
                EditorGUILayout.LabelField($"Sprite 列表 ({_visibleItems.Count}/{_items.Count})", EditorStyles.boldLabel);
                using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
                {
                    GUILayout.Label("选", GUILayout.Width(24f));
                    GUILayout.Label("名称", GUILayout.Width(160f));
                    GUILayout.Label("Pivot", GUILayout.Width(100f));
                    GUILayout.Label("状态", GUILayout.Width(50f));
                    GUILayout.Label("移除", GUILayout.Width(42f));
                    GUILayout.Label("路径");
                }

                _listScroll = EditorGUILayout.BeginScrollView(_listScroll);
                var rowHeight = EditorGUIUtility.singleLineHeight + 4f;
                var totalHeight = _visibleItems.Count * rowHeight;
                var contentRect = GUILayoutUtility.GetRect(0f, totalHeight, GUILayout.ExpandWidth(true));
                var viewRect = new Rect(_listScroll.x, _listScroll.y, position.width, Mathf.Max(1f, position.height - 220f));
                var startIndex = Mathf.Max(0, Mathf.FloorToInt(viewRect.yMin / rowHeight));
                var endIndex = Mathf.Min(_visibleItems.Count, Mathf.CeilToInt(viewRect.yMax / rowHeight) + 1);

                for (var i = startIndex; i < endIndex; i++)
                {
                    var item = _visibleItems[i];
                    var rowRect = new Rect(contentRect.x, contentRect.y + i * rowHeight, contentRect.width, rowHeight);
                    var toggleRect = new Rect(rowRect.x, rowRect.y + 1f, 24f, EditorGUIUtility.singleLineHeight);
                    var nameRect = new Rect(rowRect.x + 24f, rowRect.y + 1f, 160f, EditorGUIUtility.singleLineHeight);
                    var pivotRect = new Rect(rowRect.x + 184f, rowRect.y + 1f, 100f, EditorGUIUtility.singleLineHeight);
                    var stateRect = new Rect(rowRect.x + 284f, rowRect.y + 1f, 50f, EditorGUIUtility.singleLineHeight);
                    var removeRect = new Rect(rowRect.x + 334f, rowRect.y + 1f, 42f, EditorGUIUtility.singleLineHeight);
                    var pathRect = new Rect(rowRect.x + 378f, rowRect.y + 1f, Mathf.Max(100f, rowRect.width - 378f), EditorGUIUtility.singleLineHeight);

                    if (_items.IndexOf(item) == _activeIndex)
                        EditorGUI.DrawRect(new Rect(rowRect.x, rowRect.y, rowRect.width, rowRect.height - 1f), new Color(0.2f, 0.35f, 0.7f, 0.28f));
                    if (item.IsDirty)
                        EditorGUI.DrawRect(new Rect(rowRect.x, rowRect.y, rowRect.width, rowRect.height - 1f), new Color(0.45f, 0.12f, 0.12f, 0.35f));

                    var oldSelected = item.Selected;
                    item.Selected = EditorGUI.Toggle(toggleRect, item.Selected);
                    if (oldSelected != item.Selected)
                        _selectionCache[item.AssetPath] = item.Selected;

                    if (GUI.Button(nameRect, item.Name, EditorStyles.label))
                        _activeIndex = _items.IndexOf(item);

                    EditorGUI.LabelField(pivotRect, $"{item.Pivot.x:0.###}, {item.Pivot.y:0.###}");
                    EditorGUI.LabelField(stateRect, item.IsDirty ? "已修改" : "原样");
                    if (GUI.Button(removeRect, "移除"))
                    {
                        RemoveItem(item);
                        GUIUtility.ExitGUI();
                    }
                    EditorGUI.LabelField(pathRect, item.AssetPath, EditorStyles.miniLabel);
                }
                EditorGUILayout.EndScrollView();
            }
        }

        private void RemoveItem(SpriteItem item)
        {
            var index = _items.IndexOf(item);
            if (index < 0)
                return;

            _items.RemoveAt(index);
            _visibleItems.Remove(item);

            if (_activeIndex == index)
                _activeIndex = _items.Count == 0 ? -1 : Mathf.Clamp(index, 0, _items.Count - 1);
            else if (_activeIndex > index)
                _activeIndex--;
        }

        private void DrawInspectorPanel()
        {
            using (new EditorGUILayout.VerticalScope())
            {
                var activeItem = GetActiveItem();
                if (activeItem == null)
                {
                    EditorGUILayout.HelpBox("请选择一个 Sprite。", MessageType.Info);
                    return;
                }

                EditorGUILayout.LabelField(activeItem.Name, EditorStyles.boldLabel);
                EditorGUILayout.LabelField(activeItem.AssetPath, EditorStyles.miniLabel);

                _inspectorScroll = EditorGUILayout.BeginScrollView(_inspectorScroll);
                DrawPreview(activeItem);
                EditorGUILayout.Space(8f);
                DrawActivePivotControls(activeItem);
                EditorGUILayout.Space(8f);
                DrawSingleItemButtons(activeItem);
                EditorGUILayout.EndScrollView();
            }
        }

        private void DrawPreview(SpriteItem item)
        {
            var previewSize = Mathf.Min(position.width - 500f, 420f);
            previewSize = Mathf.Max(220f, previewSize);
            var previewRect = GUILayoutUtility.GetRect(previewSize, previewSize, GUILayout.ExpandWidth(false));
            EditorGUI.DrawRect(previewRect, new Color(0.18f, 0.18f, 0.18f));
            DrawChecker(previewRect);

            var sprite = item.Sprite;
            var texture = sprite != null ? sprite.texture : null;
            if (texture == null)
                return;

            var texRect = sprite.textureRect;
            var uv = new Rect(texRect.x / texture.width, texRect.y / texture.height, texRect.width / texture.width, texRect.height / texture.height);
            GUI.DrawTextureWithTexCoords(previewRect, texture, uv, true);

            var pivotPos = new Vector2(
                previewRect.x + previewRect.width * item.Pivot.x,
                previewRect.y + previewRect.height * (1f - item.Pivot.y));

            Handles.BeginGUI();
            var color = Handles.color;
            Handles.color = Color.red;
            Handles.DrawLine(new Vector3(previewRect.xMin, pivotPos.y), new Vector3(previewRect.xMax, pivotPos.y));
            Handles.DrawLine(new Vector3(pivotPos.x, previewRect.yMin), new Vector3(pivotPos.x, previewRect.yMax));
            Handles.color = Color.yellow;
            Handles.DrawSolidDisc(pivotPos, Vector3.forward, 4f);
            Handles.color = color;
            Handles.EndGUI();

            var e = UnityEngine.Event.current;
            if ((e.type == EventType.MouseDown || e.type == EventType.MouseDrag) && e.button == 0 && previewRect.Contains(e.mousePosition))
            {
                item.Pivot = GetPivotFromMouse(previewRect, e.mousePosition);
                e.Use();
                Repaint();
            }
        }

        private void DrawActivePivotControls(SpriteItem item)
        {
            EditorGUILayout.LabelField("当前轴心", EditorStyles.boldLabel);
            EditorGUI.BeginChangeCheck();
            var pivot = EditorGUILayout.Vector2Field("Pivot", item.Pivot);
            pivot.x = Mathf.Clamp01(pivot.x);
            pivot.y = Mathf.Clamp01(pivot.y);
            if (EditorGUI.EndChangeCheck())
                item.Pivot = pivot;

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("中心 0.5,0.5"))
                    item.Pivot = new Vector2(0.5f, 0.5f);
                if (GUILayout.Button("底中 0.5,0"))
                    item.Pivot = new Vector2(0.5f, 0f);
                if (GUILayout.Button("左下 0,0"))
                    item.Pivot = new Vector2(0f, 0f);
                if (GUILayout.Button("右下 1,0"))
                    item.Pivot = new Vector2(1f, 0f);
            }
        }

        private void DrawSingleItemButtons(SpriteItem item)
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("保存当前 Sprite", GUILayout.Height(28f)))
                    SaveDirtyItems(new List<SpriteItem> { item });
                if (GUILayout.Button("恢复当前 Sprite", GUILayout.Height(28f)))
                    ReloadItem(item);
            }
        }

        private void ApplyRootFromSelection()
        {
            foreach (var obj in Selection.objects)
            {
                var path = AssetDatabase.GetAssetPath(obj);
                if (AssetDatabase.IsValidFolder(path))
                {
                    _rootPath = path;
                    return;
                }

                if (!string.IsNullOrEmpty(path))
                {
                    var dir = Path.GetDirectoryName(path)?.Replace('\\', '/');
                    if (!string.IsNullOrEmpty(dir) && AssetDatabase.IsValidFolder(dir))
                    {
                        _rootPath = dir;
                        return;
                    }
                }
            }
        }

        private void ScanRoot()
        {
            SaveSelectionCache();
            _items.Clear();
            _activeIndex = -1;

            if (!AssetDatabase.IsValidFolder(_rootPath))
                return;

            _excludeKeywords = LoadExcludeKeywords();
            var guids = AssetDatabase.FindAssets("t:Texture2D", new[] { _rootPath });
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var lowerPath = path.ToLowerInvariant();
                var lowerName = Path.GetFileNameWithoutExtension(path).ToLowerInvariant();
                if (ContainsExcludedKeyword(lowerName) || ContainsExcludedKeyword(lowerPath))
                    continue;

                var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer == null)
                    continue;
                if (importer.textureType != TextureImporterType.Sprite)
                    continue;
                if (importer.spriteImportMode != SpriteImportMode.Single)
                    continue;

                var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(path);
                if (sprite == null)
                    continue;

                var pivot = ReadPivot(importer);
                _items.Add(new SpriteItem(path, Path.GetFileNameWithoutExtension(path), sprite, pivot, GetCachedSelection(path)));
            }

            _items.Sort((a, b) => string.CompareOrdinal(a.AssetPath, b.AssetPath));
            if (_items.Count > 0)
                _activeIndex = 0;
        }

        private void RefreshVisibleItems()
        {
            _visibleItems.Clear();
            var search = _searchText.Trim().ToLowerInvariant();
            foreach (var item in _items)
            {
                if (_showSelectedOnly && !item.Selected)
                    continue;
                if (!string.IsNullOrEmpty(search) &&
                    !item.Name.ToLowerInvariant().Contains(search) &&
                    !item.AssetPath.ToLowerInvariant().Contains(search))
                {
                    continue;
                }
                _visibleItems.Add(item);
            }
        }

        private string LoadExcludeKeywords()
        {
            var path = "Assets/Editor/TilemapBrush/MapDecorationPrefabBrushWindow.cs";
            if (!File.Exists(path))
                return string.Empty;

            var text = File.ReadAllText(path);
            var marker = "private string _excludeKeywords = \"";
            var start = text.IndexOf(marker, StringComparison.Ordinal);
            if (start < 0)
                return string.Empty;
            start += marker.Length;
            var end = text.IndexOf('"', start);
            if (end <= start)
                return string.Empty;
            return text.Substring(start, end - start);
        }

        private bool ContainsExcludedKeyword(string text)
        {
            if (string.IsNullOrEmpty(_excludeKeywords))
                return false;

            var parts = _excludeKeywords.Split(new[] { ',', ';', '，', '；', ' ' }, StringSplitOptions.RemoveEmptyEntries);
            for (var i = 0; i < parts.Length; i++)
            {
                var keyword = parts[i].Trim().ToLowerInvariant();
                if (!string.IsNullOrEmpty(keyword) && text.Contains(keyword))
                    return true;
            }
            return false;
        }

        private List<SpriteItem> GetDirtyItems()
        {
            var results = new List<SpriteItem>();
            foreach (var item in _items)
            {
                if (item.IsDirty)
                    results.Add(item);
            }
            return results;
        }

        private SpriteItem GetActiveItem()
        {
            if (_activeIndex < 0 || _activeIndex >= _items.Count)
                return null;
            return _items[_activeIndex];
        }

        private void ApplyBatchPivotToSelected(Vector2 pivot)
        {
            foreach (var item in _items)
            {
                if (item.Selected)
                    item.Pivot = pivot;
            }
        }

        private void ApplyActivePivotToSelected()
        {
            var active = GetActiveItem();
            if (active == null)
                return;

            foreach (var item in _items)
            {
                if (item.Selected)
                    item.Pivot = active.Pivot;
            }
        }

        private void SetAllVisibleSelected(bool selected)
        {
            foreach (var item in _visibleItems)
            {
                item.Selected = selected;
                _selectionCache[item.AssetPath] = selected;
            }
        }

        private void SaveDirtyItems(List<SpriteItem> items)
        {
            if (items.Count == 0)
            {
                EditorUtility.DisplayDialog("Tile Sprite Pivot Tool", "没有需要保存的 Sprite。", "确定");
                return;
            }

            try
            {
                for (var i = 0; i < items.Count; i++)
                {
                    var item = items[i];
                    var progress = (float)i / items.Count;
                    if (EditorUtility.DisplayCancelableProgressBar("保存 Sprite Pivot", item.Name, progress))
                        break;
                    SaveItem(item);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            foreach (var item in items)
                ReloadItem(item);
        }

        private static void SaveItem(SpriteItem item)
        {
            var importer = AssetImporter.GetAtPath(item.AssetPath) as TextureImporter;
            if (importer == null)
                return;

            var settings = new TextureImporterSettings();
            importer.ReadTextureSettings(settings);
            settings.spriteAlignment = (int)SpriteAlignment.Custom;
            importer.SetTextureSettings(settings);
            importer.spritePivot = item.Pivot;
            importer.SaveAndReimport();
        }

        private static void ReloadItem(SpriteItem item)
        {
            var importer = AssetImporter.GetAtPath(item.AssetPath) as TextureImporter;
            if (importer == null)
                return;
            item.Sprite = AssetDatabase.LoadAssetAtPath<Sprite>(item.AssetPath);
            item.SavedPivot = ReadPivot(importer);
            item.Pivot = item.SavedPivot;
        }

        private void SaveSelectionCache()
        {
            foreach (var item in _items)
                _selectionCache[item.AssetPath] = item.Selected;
        }

        private bool GetCachedSelection(string assetPath)
        {
            return _selectionCache.TryGetValue(assetPath, out var selected) && selected;
        }

        private static Vector2 ReadPivot(TextureImporter importer)
        {
            var settings = new TextureImporterSettings();
            importer.ReadTextureSettings(settings);
            return settings.spriteAlignment == (int)SpriteAlignment.Custom
                ? importer.spritePivot
                : AlignmentToPivot((SpriteAlignment)settings.spriteAlignment);
        }

        private static Vector2 AlignmentToPivot(SpriteAlignment alignment)
        {
            switch (alignment)
            {
                case SpriteAlignment.Center: return new Vector2(0.5f, 0.5f);
                case SpriteAlignment.TopLeft: return new Vector2(0f, 1f);
                case SpriteAlignment.TopCenter: return new Vector2(0.5f, 1f);
                case SpriteAlignment.TopRight: return new Vector2(1f, 1f);
                case SpriteAlignment.LeftCenter: return new Vector2(0f, 0.5f);
                case SpriteAlignment.RightCenter: return new Vector2(1f, 0.5f);
                case SpriteAlignment.BottomLeft: return new Vector2(0f, 0f);
                case SpriteAlignment.BottomCenter: return new Vector2(0.5f, 0f);
                case SpriteAlignment.BottomRight: return new Vector2(1f, 0f);
                default: return new Vector2(0.5f, 0.5f);
            }
        }

        private static Vector2 GetPivotFromMouse(Rect rect, Vector2 mousePosition)
        {
            var x = Mathf.InverseLerp(rect.xMin, rect.xMax, mousePosition.x);
            var y = 1f - Mathf.InverseLerp(rect.yMin, rect.yMax, mousePosition.y);
            return new Vector2(Mathf.Clamp01(x), Mathf.Clamp01(y));
        }

        private static void DrawChecker(Rect rect)
        {
            var cell = 16f;
            var c0 = new Color(0.24f, 0.24f, 0.24f);
            var c1 = new Color(0.3f, 0.3f, 0.3f);
            var cols = Mathf.CeilToInt(rect.width / cell);
            var rows = Mathf.CeilToInt(rect.height / cell);
            for (var y = 0; y < rows; y++)
            {
                for (var x = 0; x < cols; x++)
                {
                    var color = ((x + y) & 1) == 0 ? c0 : c1;
                    EditorGUI.DrawRect(new Rect(rect.x + x * cell, rect.y + y * cell, cell, cell), color);
                }
            }
        }

        private class SpriteItem
        {
            public readonly string AssetPath;
            public readonly string Name;
            public bool Selected;
            public Sprite Sprite;
            public Vector2 Pivot;
            public Vector2 SavedPivot;

            public bool IsDirty => Vector2.Distance(Pivot, SavedPivot) > 0.0001f;

            public SpriteItem(string assetPath, string name, Sprite sprite, Vector2 pivot, bool selected)
            {
                AssetPath = assetPath;
                Name = name;
                Sprite = sprite;
                Pivot = pivot;
                SavedPivot = pivot;
                Selected = selected;
            }
        }
    }
}
