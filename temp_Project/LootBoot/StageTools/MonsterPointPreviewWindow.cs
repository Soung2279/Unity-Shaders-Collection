using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Spine.Unity;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

namespace Game.Editor.StageTools
{
    public sealed class MonsterPointPreviewWindow : EditorWindow
    {
        private const string WindowTitle = "怪物点位预览";
        private const string DefaultExcelDirectory = "D:/WorkFoldersDoc/Excel";
        private const string ExcelDirectoryPrefKey = "MonsterPointPreview.ExcelDirectory";
        private const string QueryScriptRelativePath = "Assets/Editor/StageTools/monster_point_query.py";
        private const string QueryExecutableRelativePath = "Assets/Editor/StageTools/monster_point_query.exe";
        private const string FormationPrefabDirectory = "Assets/GameAsset/Prefab/Stage/PointSpawn";
        private const string ActorPrefabDirectory = "Assets/GameAsset/Prefab/Actor";
        private const float ResourcePreviewHeight = 190f;
        private const float ResourcePreviewGap = 6f;

        // SceneView 浮窗布局。
        private const float SceneCardWidth = 210f;
        private const float SceneCardImageSize = 30f;
        private const int SceneCardMaxVisibleMonsters = 4;
        // 点位与卡片左上角之间的间距。
        private const float SceneCardAnchorGap = 10f;

        private const string USED_POINT_COLOR_HEX = "#FF5A50";

        private static readonly Color PreviewButtonColor = new Color(0.32f, 0.56f, 0.90f, 1f);
        private static readonly Color RefreshButtonColor = new Color(0.25f, 0.70f, 0.43f, 1f);
        private static readonly Color CachedColor = new Color(0.34f, 0.72f, 0.43f, 1f);
        private static readonly Color MissingColor = new Color(0.94f, 0.68f, 0.20f, 1f);
        private static readonly Color ErrorColor = new Color(0.88f, 0.35f, 0.32f, 1f);
        private static MonsterPointPreviewWindow sceneOverlayWindow;

        [SerializeField] private string excelDirectory = DefaultExcelDirectory;
        [SerializeField] private Vector2 scrollPosition;
        [SerializeField] private bool showTechnicalDetails;
        [SerializeField] private bool showSceneOverlay = true;
        [SerializeField] private int sceneOverlayFontSize = 12;
        [SerializeField] private float sceneOverlayBackgroundAlpha = 0.6f;

        private readonly Dictionary<string, PointCacheEntry> cache =
            new Dictionary<string, PointCacheEntry>(StringComparer.Ordinal);
        private readonly Dictionary<string, StagePointPoolCache> stagePointPools =
            new Dictionary<string, StagePointPoolCache>(StringComparer.Ordinal);

        private GUIStyle wrappedLabel;
        private GUIStyle headerStyle;
        private GUIStyle monsterCardButtonStyle;
        private GUIStyle redFoldoutStyle;
        private GUIStyle pointPoolValueStyle;
        private GUIStyle pointPoolLegendStyle;
        // GUIStyle 在类型构造阶段创建会触发 set_rawName 异常，因此只能置空并在 GUI 上下文中惰性创建。
        private GUIStyle sceneOverlayBoxStyle;
        private GUIStyle sceneOverlayTitleStyle;
        private GUIStyle sceneOverlaySmallStyle;
        private Texture2D sceneOverlayBoxTexture;
        private int sceneOverlayStyleFontSize = -1;
        private float sceneOverlayStyleAlpha = -1f;
        private readonly Dictionary<string, SpinePrefabPreview> spinePreviews =
            new Dictionary<string, SpinePrefabPreview>(StringComparer.OrdinalIgnoreCase);
        private bool isBusy;
        private string cacheSource = string.Empty;
        private string[] cacheHashes = Array.Empty<string>();
        private readonly Dictionary<string, Vector2> sceneCardScroll = new Dictionary<string, Vector2>();
        private string statusMessage = "请在 Stage 预制体模式中选择一个五位数点位。";
        private MessageType statusType = MessageType.Info;

        [MenuItem("TATools/关卡工具/怪物点位预览", false, 10)]
        public static void OpenWindow()
        {
            var window = GetWindow<MonsterPointPreviewWindow>();
            window.titleContent = new GUIContent(WindowTitle, EditorGUIUtility.IconContent("d_Search Icon").image);
            window.minSize = new Vector2(620f, 480f);
            window.Show();
        }

        private void OnEnable()
        {
            excelDirectory = EditorPrefs.GetString(ExcelDirectoryPrefKey, DefaultExcelDirectory);
            Selection.selectionChanged -= OnSelectionChanged;
            PrefabStage.prefabStageOpened -= OnPrefabStageChanged;
            PrefabStage.prefabStageClosing -= OnPrefabStageChanged;
            Selection.selectionChanged += OnSelectionChanged;
            PrefabStage.prefabStageOpened += OnPrefabStageChanged;
            PrefabStage.prefabStageClosing += OnPrefabStageChanged;
            sceneOverlayWindow = this;
            SceneView.duringSceneGui -= DrawSceneOverlay;
            SceneView.duringSceneGui += DrawSceneOverlay;
            // 预制体增删点位后，点位池的标红状态需要立即重算重绘。
            EditorApplication.hierarchyChanged -= OnHierarchyChanged;
            EditorApplication.hierarchyChanged += OnHierarchyChanged;
            cacheSource = StageToolsIO.NormalizeDirectory(excelDirectory);
            LoadCache();
            UpdateStatusFromSelection();
        }

        private void OnDisable()
        {
            Selection.selectionChanged -= OnSelectionChanged;
            PrefabStage.prefabStageOpened -= OnPrefabStageChanged;
            PrefabStage.prefabStageClosing -= OnPrefabStageChanged;
            SceneView.duringSceneGui -= DrawSceneOverlay;
            EditorApplication.hierarchyChanged -= OnHierarchyChanged;
            if (sceneOverlayWindow == this)
                sceneOverlayWindow = FindOtherOverlayWindow(this);
            EditorApplication.update -= OnAssetPreviewUpdate;
            DisposeSpinePreviews();
            DisposeSceneOverlayResources();
        }

        /// <summary>预制体层级变化时刷新窗口，保证点位池标红状态与当前预制体一致。</summary>
        private void OnHierarchyChanged()
        {
            Repaint();
        }

        private void DisposeSceneOverlayResources()
        {
            if (sceneOverlayBoxTexture != null)
            {
                DestroyImmediate(sceneOverlayBoxTexture);
                sceneOverlayBoxTexture = null;
            }
            sceneOverlayStyleAlpha = -1f;
        }

        /// <summary>多个预览窗口同时打开时，只保留一个窗口负责绘制场景浮窗。</summary>
        private static MonsterPointPreviewWindow FindOtherOverlayWindow(MonsterPointPreviewWindow exclude)
        {
            foreach (MonsterPointPreviewWindow window in Resources.FindObjectsOfTypeAll<MonsterPointPreviewWindow>())
            {
                if (window != null && window != exclude)
                    return window;
            }
            return null;
        }

        private void OnSelectionChanged()
        {
            UpdateStatusFromSelection();
            Repaint();
            SceneView.RepaintAll();
        }

        private void OnPrefabStageChanged(PrefabStage unused)
        {
            UpdateStatusFromSelection();
            Repaint();
            SceneView.RepaintAll();
        }

        private void OnGUI()
        {
            EnsureCacheSource();
            EnsureStyles();
            DrawHeader();
            EditorGUILayout.Space(6f);
            DrawContext();
            EditorGUILayout.Space(6f);
            DrawActions();
            EditorGUILayout.Space(6f);
            DrawStatus();
            EditorGUILayout.Space(6f);
            DrawSelectedPointResult();
        }

        private void EnsureStyles()
        {
            if (wrappedLabel == null)
                wrappedLabel = new GUIStyle(EditorStyles.label) { wordWrap = true };
            if (headerStyle == null)
                headerStyle = new GUIStyle(EditorStyles.boldLabel) { fontSize = 15 };
            if (monsterCardButtonStyle == null)
            {
                monsterCardButtonStyle = new GUIStyle(EditorStyles.miniButton)
                {
                    alignment = TextAnchor.MiddleCenter,
                    wordWrap = true,
                    clipping = TextClipping.Clip,
                    fontSize = 10,
                    padding = new RectOffset(3, 3, 2, 2),
                };
            }
            if (redFoldoutStyle == null)
            {
                redFoldoutStyle = new GUIStyle(EditorStyles.foldout);
                redFoldoutStyle.normal.textColor = new Color(0.88f, 0.18f, 0.16f, 1f);
                redFoldoutStyle.onNormal.textColor = new Color(0.95f, 0.28f, 0.24f, 1f);
                redFoldoutStyle.hover.textColor = Color.white;
                redFoldoutStyle.onHover.textColor = Color.white;
            }
            if (pointPoolValueStyle == null)
            {
                // 富文本用于给已使用的点位 ID 单独着色。
                pointPoolValueStyle = new GUIStyle(EditorStyles.label) { wordWrap = true, richText = true };
            }
            if (pointPoolLegendStyle == null)
            {
                pointPoolLegendStyle = new GUIStyle(EditorStyles.miniLabel) { wordWrap = true, richText = true };
            }
        }

        private void DrawHeader()
        {
            EditorGUILayout.LabelField("Stage 怪物点位快速预览", headerStyle);
            EditorGUILayout.LabelField(
                "按关卡 ID 与五位数点位查询 MonsterSpawnType → MonsterSpawns → MonsterFormation → Actor。",
                wrappedLabel);

            EditorGUI.BeginDisabledGroup(isBusy);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Excel 目录");
            EditorGUI.BeginChangeCheck();
            string newDirectory = EditorGUILayout.TextField(excelDirectory);
            if (EditorGUI.EndChangeCheck())
            {
                ChangeDirectory(newDirectory);
            }
            if (GUILayout.Button("选择", GUILayout.Width(54f)))
            {
                string selected = EditorUtility.OpenFolderPanel("选择配置表目录", excelDirectory, "");
                if (!string.IsNullOrEmpty(selected))
                {
                    ChangeDirectory(selected);
                }
            }
            EditorGUILayout.EndHorizontal();
            EditorGUI.EndDisabledGroup();
        }

        private void ChangeDirectory(string directory)
        {
            excelDirectory = directory.Trim();
            EditorPrefs.SetString(ExcelDirectoryPrefKey, excelDirectory);
            EnsureCacheSource();
        }

        private void EnsureCacheSource()
        {
            string source = StageToolsIO.NormalizeDirectory(excelDirectory);
            if (string.Equals(source, cacheSource, StringComparison.OrdinalIgnoreCase)) return;
            MonsterPointEditWindow.InvalidateDraftsForSourceChange(cacheSource, source);
            cacheSource = source;
            cacheHashes = Array.Empty<string>();
            cache.Clear();
            stagePointPools.Clear();
            DisposeSpinePreviews();
            LoadCache();
            SetStatus("数据源已切换，请重新预览或刷新。", MessageType.Info);
            SceneView.RepaintAll();
        }

        private void DrawContext()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string error;
            bool hasStage = TryGetStageContext(stage, out stageId, out error);
            GameObject selected = Selection.activeGameObject;
            bool isSelectedPoint = selected != null && IsFiveDigitPointName(selected.name);

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("当前上下文", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("Prefab", stage == null ? "未进入 Prefab Mode" : stage.assetPath);
                EditorGUILayout.LabelField("关卡 ID", hasStage ? stageId.ToString() : "-");
                EditorGUILayout.LabelField("选中对象", selected == null ? "未选择" : GetHierarchyPath(selected.transform));
                EditorGUILayout.LabelField("点位 ID", isSelectedPoint ? selected.name : "-");

                int cachedCount = hasStage ? cache.Keys.Count(key => key.StartsWith(MakeCacheStagePrefix(stage.assetPath, stageId), StringComparison.Ordinal)) : 0;
                EditorGUILayout.LabelField("本关缓存", cachedCount + " 个点位");
                DrawPointPool(stage, stageId, hasStage);
            }
        }

        private void DrawPointPool(PrefabStage stage, int stageId, bool hasStage)
        {
            if (!hasStage || stage == null)
            {
                EditorGUILayout.LabelField("可用点位池", "-", wrappedLabel);
                return;
            }

            StagePointPoolCache pool;
            string poolKey = MakeCacheStagePrefix(stage.assetPath, stageId);
            if (!stagePointPools.TryGetValue(poolKey, out pool) || pool == null || pool.pointIds == null)
            {
                EditorGUILayout.LabelField("可用点位池", "尚未查询，请先点击“一键刷新当前预制体”。", wrappedLabel);
                return;
            }

            // 已使用集合在绘制时实时取自当前预制体，缓存刷新或预制体改动后标红状态会同步更新。
            string[] used = GetCurrentPrefabPointIds(stage);
            var usedSet = new HashSet<string>(used, StringComparer.Ordinal);
            string[] ordered = pool.pointIds.OrderBy(pointId => pointId, StringComparer.Ordinal).ToArray();

            DrawRichTextRow("已用点位", used.Length + " 个：<color=" + USED_POINT_COLOR_HEX + ">"
                + string.Join(" ", used) + "</color>");
            string[] available = ordered.Where(id => !usedSet.Contains(id)).ToArray();
            DrawRichTextRow("可用点位", available.Length + " 个：" + string.Join(" ", available));

            int usedInPool = ordered.Count(pointId => usedSet.Contains(pointId));
            EditorGUILayout.LabelField(
                "　",
                "表格登记 " + ordered.Length + " 个，其中已用 " + usedInPool + " 个，尚未使用 " + available.Length + " 个。",
                pointPoolLegendStyle);

            // 预制体已使用、但表格未登记的点位。
            string[] notInTable = used
                .Where(pointId => !pool.pointIds.Contains(pointId, StringComparer.Ordinal))
                .OrderBy(pointId => pointId, StringComparer.Ordinal)
                .ToArray();
            if (notInTable.Length > 0)
                EditorGUILayout.LabelField("注意", notInTable.Length + " 个已用点位不在表格中（" + string.Join(", ", notInTable) + "）", wrappedLabel);
        }

        /// <summary>绘制带富文本颜色的“标签 + 值”行，值会按需换行。</summary>
        private void DrawRichTextRow(string label, string value)
        {
            if (pointPoolValueStyle == null)
                return;

            float width = Mathf.Max(60f, EditorGUIUtility.currentViewWidth - EditorGUIUtility.labelWidth - 24f);
            float height = pointPoolValueStyle.CalcHeight(new GUIContent(value), width);
            Rect row = EditorGUILayout.GetControlRect(false, Mathf.Max(EditorGUIUtility.singleLineHeight, height));

            Rect labelRect = new Rect(row.x, row.y, EditorGUIUtility.labelWidth - 4f, row.height);
            GUI.Label(labelRect, label, EditorStyles.label);
            Rect valueRect = new Rect(row.x + EditorGUIUtility.labelWidth, row.y, row.width - EditorGUIUtility.labelWidth, row.height);
            GUI.Label(valueRect, value, pointPoolValueStyle);
        }

        private void DrawActions()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string stageError;
            bool hasStage = TryGetStageContext(stage, out stageId, out stageError);
            GameObject selected = Selection.activeGameObject;
            bool canPreview = Selection.gameObjects.Length == 1 && hasStage && selected != null && IsFiveDigitPointName(selected.name) && IsInsidePrefabStage(selected, stage);
            bool canRefresh = hasStage && stage != null && stage.prefabContentsRoot != null;

            EditorGUILayout.BeginHorizontal();
            using (new EditorGUI.DisabledScope(isBusy || !canPreview))
            {
                if (DrawColoredButton("预览选中点位", PreviewButtonColor, GUILayout.Height(30f)))
                    QuerySelectedPoint(stageId, selected.name);
            }
            using (new EditorGUI.DisabledScope(isBusy || !canPreview))
            {
                if (DrawColoredButton("修改此点位", new Color(0.86f, 0.42f, 0.12f, 1f), GUILayout.Height(30f)))
                    OpenEditWindowForSelectedPoint(stageId, selected);
            }
            EditorGUILayout.EndHorizontal();

            using (new EditorGUI.DisabledScope(isBusy || !canRefresh))
            {
                if (DrawColoredButton("一键刷新当前预制体", RefreshButtonColor, GUILayout.Height(30f)))
                    RefreshCurrentPrefab(stage, stageId);
            }

            EditorGUI.BeginChangeCheck();
            showSceneOverlay = EditorGUILayout.ToggleLeft("在 SceneView 绘制点位浮窗（一键刷新后显示怪物名 + 数量 + 预览快照）", showSceneOverlay);
            if (EditorGUI.EndChangeCheck())
                SceneView.RepaintAll();

            using (new EditorGUI.DisabledScope(!showSceneOverlay))
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUI.BeginChangeCheck();
                    sceneOverlayFontSize = EditorGUILayout.IntSlider("浮窗字体大小", sceneOverlayFontSize, 6, 24);
                    GUILayout.Label("px", EditorStyles.miniLabel, GUILayout.Width(20f));
                    if (EditorGUI.EndChangeCheck())
                        SceneView.RepaintAll();
                }
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUI.BeginChangeCheck();
                    sceneOverlayBackgroundAlpha = EditorGUILayout.Slider("浮窗底板不透明度", sceneOverlayBackgroundAlpha, 0.05f, 1f);
                    if (EditorGUI.EndChangeCheck())
                        SceneView.RepaintAll();
                }
            }

            if (isBusy)
                EditorGUILayout.LabelField("正在读取 Excel，请稍候……", EditorStyles.miniLabel);
        }

        private async void OpenEditWindowForSelectedPoint(int stageId, GameObject selected)
        {
            if (selected == null || !IsFiveDigitPointName(selected.name))
                return;

            MonsterPointEditWindow window = GetWindow<MonsterPointEditWindow>();
            window.titleContent = new GUIContent("怪物点位配置草稿", EditorGUIUtility.IconContent("d_editicon.sml").image);
            window.minSize = new Vector2(720f, 560f);
            window.Show();
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            await window.LoadPointFromPreview(stage == null ? string.Empty : stage.assetPath, stageId, selected.name, excelDirectory);
        }

        private void DrawStatus()
        {
            if (!string.IsNullOrEmpty(statusMessage))
                EditorGUILayout.HelpBox(statusMessage, statusType);
        }

        private void DrawSelectedPointResult()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string error;
            GameObject selected = Selection.activeGameObject;
            if (!TryGetStageContext(stage, out stageId, out error) || selected == null || !IsFiveDigitPointName(selected.name))
                return;

            string key = MakeCacheKey(stage.assetPath, stageId, selected.name);
            PointCacheEntry entry;
            if (!cache.TryGetValue(key, out entry))
            {
                DrawStateLabel("当前点位尚未缓存，请点击“预览选中点位”。", MissingColor);
                return;
            }

            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                DrawStateLabel(entry.success ? "已缓存" : "查询异常", entry.success ? CachedColor : ErrorColor);
                EditorGUILayout.LabelField("Stage / 点位", stageId + " / " + entry.pointId);
                EditorGUILayout.LabelField("缓存时间", entry.cachedAt);

                if (!string.IsNullOrEmpty(entry.error))
                    EditorGUILayout.HelpBox(entry.error, entry.success ? MessageType.Warning : MessageType.Error);

                if (!entry.success || entry.spawnRows == null || entry.spawnRows.Length == 0)
                {
                    EditorGUILayout.LabelField("没有可展示的刷怪配置。", EditorStyles.miniLabel);
                }
                else
                {
                    for (int rowIndex = 0; rowIndex < entry.spawnRows.Length; rowIndex++)
                        DrawSpawnRow(entry.spawnRows[rowIndex], rowIndex);
                }

                showTechnicalDetails = EditorGUILayout.Foldout(showTechnicalDetails, "查看原始数据", true, redFoldoutStyle);
                if (showTechnicalDetails)
                {
                    using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                    {
                        DrawRawData(entry);
                    }
                }
            }
            EditorGUILayout.EndScrollView();
        }

        private void DrawSceneOverlay(SceneView sceneView)
        {
            if (sceneOverlayWindow != this || sceneView == null)
                return;
            if (!showSceneOverlay)
                return;

            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string error;
            if (!TryGetStageContext(stage, out stageId, out error))
                return;

            EnsureSceneOverlayStyles();
            // 点位的 Transform 只查找一次，避免在每个 SceneView 事件里重复做层级遍历。
            var pointTransforms = new Dictionary<string, Transform>(StringComparer.Ordinal);
            foreach (Transform transform in stage.prefabContentsRoot.GetComponentsInChildren<Transform>(true))
            {
                if (IsFiveDigitPointName(transform.name) && !pointTransforms.ContainsKey(transform.name))
                    pointTransforms[transform.name] = transform;
            }

            Handles.BeginGUI();
            try
            {
                string[] pointIds = GetCurrentPrefabPointIds(stage);
                foreach (string pointId in pointIds)
                {
                    Transform point;
                    if (!pointTransforms.TryGetValue(pointId, out point) || point == null)
                        continue;

                    Vector3 screenPosition = sceneView.camera.WorldToScreenPoint(point.position);
                    if (screenPosition.z < 0f)
                        continue;

                    Vector2 guiPosition = HandleUtility.WorldToGUIPoint(point.position);
                    // 点位不在当前视野内时不绘制浮窗，避免卡片被钳制到视图边缘而失去对应关系。
                    if (!IsPointInsideSceneView(sceneView, guiPosition))
                        continue;

                    PointCacheEntry entry;
                    cache.TryGetValue(MakeCacheKey(stage.assetPath, stageId, pointId), out entry);
                    DrawScenePointCard(sceneView, guiPosition, pointId, entry);
                }
            }
            finally
            {
                Handles.EndGUI();
            }
        }

        private void EnsureSceneOverlayStyles()
        {
            if (sceneOverlaySmallStyle == null)
                sceneOverlaySmallStyle = new GUIStyle(EditorStyles.label)
                {
                    clipping = TextClipping.Clip,
                    wordWrap = false,
                    alignment = TextAnchor.MiddleLeft,
                };
            if (sceneOverlayTitleStyle == null)
                sceneOverlayTitleStyle = new GUIStyle(EditorStyles.boldLabel)
                {
                    clipping = TextClipping.Clip,
                    wordWrap = false,
                    alignment = TextAnchor.MiddleLeft,
                };
            if (sceneOverlayBoxStyle == null)
            {
                // 必须是副本：直接改内置共享样式会污染全局 Editor 外观。
                GUIStyle source = GUI.skin == null ? null : GUI.skin.box;
                sceneOverlayBoxStyle = source == null ? new GUIStyle(EditorStyles.helpBox) : new GUIStyle(source);
                sceneOverlayBoxStyle.padding = new RectOffset(2, 2, 2, 2);
            }

            int fontSize = Mathf.Clamp(sceneOverlayFontSize, 6, 24);
            if (sceneOverlayStyleFontSize != fontSize)
            {
                sceneOverlayStyleFontSize = fontSize;
                sceneOverlaySmallStyle.fontSize = fontSize;
                sceneOverlayTitleStyle.fontSize = fontSize;
            }

            float alpha = Mathf.Clamp(sceneOverlayBackgroundAlpha, 0.05f, 1f);
            if (sceneOverlayBoxTexture == null || !Mathf.Approximately(sceneOverlayStyleAlpha, alpha))
            {
                sceneOverlayStyleAlpha = alpha;
                if (sceneOverlayBoxTexture != null)
                    DestroyImmediate(sceneOverlayBoxTexture);
                sceneOverlayBoxTexture = new Texture2D(1, 1, TextureFormat.RGBA32, false)
                {
                    hideFlags = HideFlags.HideAndDontSave,
                };
                sceneOverlayBoxTexture.SetPixel(0, 0, new Color(0.12f, 0.12f, 0.15f, alpha));
                sceneOverlayBoxTexture.Apply();
                sceneOverlayBoxStyle.normal.background = sceneOverlayBoxTexture;
            }
        }

        /// <summary>
        /// 判断点位的 GUI 坐标是否落在场景视图可绘制区域内。
        /// 边界取相机视口（camera.pixelRect），而不是 sceneView.position：
        /// 后者包含顶部工具栏，会让底部一条窄带内的点位被误判为可见。
        /// </summary>
        internal static bool IsPointInsideSceneView(SceneView sceneView, Vector2 guiPosition)
        {
            if (sceneView == null)
                return false;
            Camera camera = sceneView.camera;
            if (camera == null)
                return false;

            float scale = EditorGUIUtility.pixelsPerPoint;
            if (scale <= 0f)
                scale = 1f;
            Vector2 viewport = camera.pixelRect.size / scale;

            return guiPosition.x >= 0f && guiPosition.y >= 0f
                && guiPosition.x <= viewport.x && guiPosition.y <= viewport.y;
        }

        /// <summary>
        /// 计算浮窗矩形：锚点为卡片左上角，以点位为原点向右下方展开。
        /// GUI 坐标 Y 轴向下，因此卡片顶边位于点位下方一个间距处。
        /// 超出场景视图边界时回推，保证整张卡片可见。
        /// </summary>
        internal static Rect ComputeSceneCardRect(Vector2 pointPosition, float cardWidth, float cardHeight, Vector2 viewSize)
        {
            Rect rect = new Rect(
                pointPosition.x + SceneCardAnchorGap,
                pointPosition.y + SceneCardAnchorGap,
                cardWidth,
                cardHeight);

            float maxWidth = Mathf.Max(cardWidth, viewSize.x - SceneCardAnchorGap);
            float maxHeight = Mathf.Max(cardHeight, viewSize.y - SceneCardAnchorGap);
            rect.x = Mathf.Clamp(rect.x, 4f, maxWidth - cardWidth);
            rect.y = Mathf.Clamp(rect.y, 4f, maxHeight - cardHeight);
            return rect;
        }

        private void DrawScenePointCard(SceneView sceneView, Vector2 pointPosition, string pointId, PointCacheEntry entry)
        {
            int fontSize = Mathf.Clamp(sceneOverlayFontSize, 6, 24);
            float cardWidth = SceneCardWidth;
            float imageSize = Mathf.Clamp(fontSize * 1.9f, 16f, SceneCardImageSize);
            float rowHeight = Mathf.Max(imageSize + 8f, fontSize * 2.2f + 10f);
            float headerHeight = fontSize + 12f;
            float padding = 5f;
            float textLeft = padding + imageSize + 5f;

            MonsterData[] monsters = entry == null || !entry.success
                ? Array.Empty<MonsterData>()
                : CollectSceneMonsters(entry);
            int visibleCount = Mathf.Min(monsters.Length, SceneCardMaxVisibleMonsters);
            float cardHeight = headerHeight + Mathf.Max(1, visibleCount) * rowHeight + padding * 2f;
            Rect rect = ComputeSceneCardRect(pointPosition, cardWidth, cardHeight, sceneView.position.size);

            GUI.Box(rect, GUIContent.none, sceneOverlayBoxStyle);
            GUI.Label(new Rect(rect.x + padding, rect.y + padding - 1f, cardWidth - padding * 2f, headerHeight - 4f), "点位 " + pointId, sceneOverlayTitleStyle);
            if (entry == null)
            {
                GUI.Label(new Rect(rect.x + padding, rect.y + headerHeight, cardWidth - padding * 2f, rowHeight), "未查询", sceneOverlaySmallStyle);
                return;
            }
            if (!entry.success)
            {
                GUI.Label(new Rect(rect.x + padding, rect.y + headerHeight, cardWidth - padding * 2f, cardHeight - headerHeight), "查询异常", sceneOverlaySmallStyle);
                return;
            }
            if (monsters.Length == 0)
            {
                GUI.Label(new Rect(rect.x + padding, rect.y + headerHeight, cardWidth - padding * 2f, rowHeight), "无怪物配置", sceneOverlaySmallStyle);
                return;
            }

            Rect viewport = new Rect(rect.x + padding, rect.y + headerHeight,
                cardWidth - padding * 2f, cardHeight - headerHeight - padding);
            Vector2 cardScroll;
            sceneCardScroll.TryGetValue(pointId, out cardScroll);
            cardScroll = GUI.BeginScrollView(viewport, cardScroll,
                new Rect(0f, 0f, viewport.width - 16f, monsters.Length * rowHeight));
            sceneCardScroll[pointId] = cardScroll;
            for (int index = 0; index < monsters.Length; index++)
            {
                Rect row = new Rect(0f, index * rowHeight, viewport.width - 16f, rowHeight);
                DrawSceneMonsterRow(row, monsters[index], imageSize, textLeft, fontSize);
            }
            GUI.EndScrollView();
        }

        /// <summary>保留每个波次和候选的怪物及数量，不将随机候选相加或去重。</summary>
        private static MonsterData[] CollectSceneMonsters(PointCacheEntry entry)
        {
            if (entry == null || entry.spawnRows == null)
                return Array.Empty<MonsterData>();

            var ordered = new List<MonsterData>();

            foreach (SpawnRowData row in entry.spawnRows)
            {
                if (row == null || row.formationVariants == null)
                    continue;
                foreach (FormationVariantData formation in row.formationVariants)
                {
                    if (formation == null || formation.monsters == null)
                        continue;
                    foreach (MonsterData monster in formation.monsters)
                    {
                        if (monster == null)
                            continue;
                        ordered.Add(new MonsterData
                        {
                            actorId = monster.actorId, actorName = monster.actorName,
                            modelResource = monster.modelResource, count = monster.count,
                            context = entry.spawnRows.Length > 1 || row.formationVariants.Length > 1
                                ? "波" + row.waveIndex + " / 候选" + formation.groupId : string.Empty,
                        });
                    }
                }
            }
            return ordered.ToArray();
        }

        private void DrawSceneMonsterRow(Rect rect, MonsterData monster, float imageSize, float textLeft, int fontSize)
        {
            if (monster == null)
                return;

            // 复用窗口内已有的怪物预览实现：Spine 走 SpinePrefabPreview，Sprite 走 AssetPreview。
            string assetPath = GetActorPrefabPath(monster.modelResource);
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
            Rect imageRect = new Rect(rect.x, rect.y + (rect.height - imageSize) * 0.5f, imageSize, imageSize);
            DrawMonsterAssetPreview(imageRect, prefab, assetPath);

            string name = string.IsNullOrEmpty(monster.actorName) ? "Actor " + monster.actorId : monster.actorName;
            float textWidth = Mathf.Max(20f, rect.width - textLeft);
            float lineHeight = fontSize + 3f;
            GUI.Label(new Rect(rect.x + textLeft, rect.y, textWidth, lineHeight), name, sceneOverlaySmallStyle);
            GUI.Label(new Rect(rect.x + textLeft, rect.y + lineHeight, textWidth, lineHeight), "× " + monster.count + " " + monster.context, sceneOverlaySmallStyle);
        }

        private void DrawSpawnRow(SpawnRowData row, int rowIndex)
        {
            if (row == null)
                return;

            EditorGUILayout.Space(4f);
            string waveTitle = row.waveIndex > 0 ? "波次 " + row.waveIndex : "刷怪配置 " + (rowIndex + 1);
            EditorGUILayout.LabelField(waveTitle, EditorStyles.boldLabel);

            if (row.formationVariants == null || row.formationVariants.Length == 0)
            {
                EditorGUILayout.LabelField("未找到 MonsterFormation 配置。", EditorStyles.miniLabel);
                return;
            }

            foreach (FormationVariantData formation in row.formationVariants)
            {
                if (formation == null)
                    continue;

                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    EditorGUILayout.LabelField("阵型", string.IsNullOrEmpty(formation.formationPrefab) ? "-" : formation.formationPrefab);
                    if (!string.IsNullOrEmpty(formation.description))
                        EditorGUILayout.LabelField("说明", formation.description, wrappedLabel);

                    EditorGUILayout.LabelField("怪物", EditorStyles.boldLabel);
                    if (formation.monsters == null || formation.monsters.Length == 0)
                    {
                        EditorGUILayout.LabelField("无怪物数据", EditorStyles.miniLabel);
                    }
                    else
                    {
                        foreach (MonsterData monster in formation.monsters)
                        {
                            if (monster == null)
                                continue;
                            string name = string.IsNullOrEmpty(monster.actorName) ? "未找到 Actor" : monster.actorName;
                            EditorGUILayout.LabelField("  " + name, "ID " + monster.actorId + "    × " + monster.count);
                        }
                    }

                    DrawResourcePreviews(formation);
                }
            }
        }

        private void DrawRawData(PointCacheEntry entry)
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("原始数据字段", EditorStyles.boldLabel, GUILayout.Width(140f));
            EditorGUILayout.LabelField("原始数据值", EditorStyles.boldLabel, GUILayout.MinWidth(180f));
            EditorGUILayout.LabelField("来源", EditorStyles.boldLabel, GUILayout.Width(160f));
            EditorGUILayout.EndHorizontal();

            string spawnTypeIds = entry.spawnTypeIds == null
                ? "-"
                : string.Join(", ", entry.spawnTypeIds.Select(value => value.ToString()).ToArray());
            DrawRawDataRow("MonsterSpawnType.ID", spawnTypeIds, "MonsterSpawnType");

            if (entry.spawnRows == null)
                return;

            foreach (SpawnRowData row in entry.spawnRows)
            {
                if (row == null)
                    continue;
                DrawRawDataRow("MonsterSpawns.ID", row.spawnId.ToString(), "MonsterSpawns");
                DrawRawDataRow("PointGroup", row.pointGroupRaw, "MonsterSpawns");
                DrawRawDataRow("FormationGroup", row.formationRaw, "MonsterSpawns");
                if (row.formationVariants == null)
                    continue;

                foreach (FormationVariantData formation in row.formationVariants)
                {
                    if (formation == null)
                        continue;
                    DrawRawDataRow("组合 GroupID", formation.groupId.ToString(), "MonsterFormation");
                    DrawRawDataRow("MonsterGroup", formation.monsterGroupRaw, "MonsterFormation");
                    if (formation.monsters == null)
                        continue;
                    foreach (MonsterData monster in formation.monsters)
                    {
                        if (monster != null && !string.IsNullOrEmpty(monster.modelResource))
                            DrawRawDataRow("Actor " + monster.actorId + " 资源", monster.modelResource, "Actor");
                    }
                }
            }
        }

        private void DrawRawDataRow(string fieldName, string value, string source)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(fieldName, wrappedLabel, GUILayout.Width(140f));
            EditorGUILayout.LabelField(string.IsNullOrEmpty(value) ? "-" : value, wrappedLabel, GUILayout.MinWidth(180f));
            EditorGUILayout.LabelField("来源：" + source, wrappedLabel, GUILayout.Width(160f));
            EditorGUILayout.EndHorizontal();
        }


        private static void DrawStateLabel(string text, Color color)
        {
            Color previous = GUI.backgroundColor;
            GUI.backgroundColor = color;
            EditorGUILayout.LabelField(text, EditorStyles.helpBox);
            GUI.backgroundColor = previous;
        }

        private static bool DrawColoredButton(string text, Color color, params GUILayoutOption[] options)
        {
            Color previous = GUI.backgroundColor;
            GUI.backgroundColor = color;
            bool clicked = GUILayout.Button(text, options);
            GUI.backgroundColor = previous;
            return clicked;
        }

        private void DrawResourcePreviews(FormationVariantData formation)
        {
            EditorGUILayout.Space(4f);
            EditorGUILayout.LabelField("资源预览", EditorStyles.boldLabel);

            Rect rowRect = EditorGUILayout.GetControlRect(false, ResourcePreviewHeight);
            float panelWidth = Mathf.Max(120f, (rowRect.width - ResourcePreviewGap) * 0.5f);
            Rect formationRect = new Rect(rowRect.x, rowRect.y, panelWidth, rowRect.height);
            Rect monstersRect = new Rect(formationRect.xMax + ResourcePreviewGap, rowRect.y, rowRect.width - panelWidth - ResourcePreviewGap, rowRect.height);

            DrawFormationPreviewPanel(formationRect, formation);
            DrawMonsterPreviewPanel(monstersRect, formation.monsters);
        }

        private void DrawFormationPreviewPanel(Rect rect, FormationVariantData formation)
        {
            GUI.Box(rect, GUIContent.none, EditorStyles.helpBox);
            GUI.Label(new Rect(rect.x + 6f, rect.y + 4f, rect.width - 12f, 18f), "阵型画面", EditorStyles.boldLabel);

            string assetPath = GetFormationPrefabPath(formation.formationPrefab);
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
            Rect previewRect = new Rect(rect.x + 6f, rect.y + 24f, rect.width - 12f, rect.height - 50f);
            DrawAssetPreview(previewRect, prefab, "未找到阵型 Prefab\n" + assetPath);

            Rect footerRect = new Rect(rect.x + 6f, rect.yMax - 23f, rect.width - 12f, 19f);
            if (GUI.Button(footerRect, string.IsNullOrEmpty(formation.formationPrefab) ? "-" : formation.formationPrefab))
                PingAsset(prefab);
        }

        private void DrawMonsterPreviewPanel(Rect rect, MonsterData[] monsters)
        {
            GUI.Box(rect, GUIContent.none, EditorStyles.helpBox);
            GUI.Label(new Rect(rect.x + 6f, rect.y + 4f, rect.width - 12f, 18f), "怪物资源", EditorStyles.boldLabel);

            MonsterData[] validMonsters = monsters == null
                ? Array.Empty<MonsterData>()
                : monsters.Where(monster => monster != null).ToArray();
            if (validMonsters.Length == 0)
            {
                GUI.Label(new Rect(rect.x + 8f, rect.y + 28f, rect.width - 16f, rect.height - 36f), "没有怪物资源", EditorStyles.centeredGreyMiniLabel);
                return;
            }

            Rect contentRect = new Rect(rect.x + 6f, rect.y + 24f, rect.width - 12f, rect.height - 30f);
            float cellWidth = contentRect.width / validMonsters.Length;
            for (int i = 0; i < validMonsters.Length; i++)
            {
                MonsterData monster = validMonsters[i];
                Rect cellRect = new Rect(contentRect.x + cellWidth * i, contentRect.y, cellWidth, contentRect.height);
                if (i > 0)
                    EditorGUI.DrawRect(new Rect(cellRect.x, cellRect.y + 2f, 1f, cellRect.height - 4f), new Color(0f, 0f, 0f, 0.28f));

                string assetPath = GetActorPrefabPath(monster.modelResource);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
                const float labelHeight = 46f;
                Rect previewRect = new Rect(cellRect.x + 4f, cellRect.y, cellRect.width - 8f, cellRect.height - labelHeight - 4f);
                DrawMonsterAssetPreview(previewRect, prefab, assetPath);

                string name = string.IsNullOrEmpty(monster.actorName) ? "Actor " + monster.actorId : monster.actorName;
                Rect labelRect = new Rect(cellRect.x + 3f, cellRect.yMax - labelHeight, cellRect.width - 6f, labelHeight - 2f);
                var labelContent = new GUIContent(name + "  ×" + monster.count + "\nID " + monster.actorId, assetPath);
                if (GUI.Button(labelRect, labelContent, monsterCardButtonStyle))
                    PingAsset(prefab);
            }
        }

        private void DrawMonsterAssetPreview(Rect rect, GameObject prefab, string assetPath)
        {
            if (prefab == null)
            {
                DrawAssetPreview(rect, null, "未找到怪物 Prefab");
                return;
            }

            SkeletonAnimation sourceSkeleton = prefab.GetComponentInChildren<SkeletonAnimation>(true);
            if (sourceSkeleton == null)
            {
                DrawAssetPreview(rect, prefab, "未找到怪物 Prefab");
                return;
            }

            SpinePrefabPreview preview;
            if (!spinePreviews.TryGetValue(assetPath, out preview) || preview == null)
            {
                preview = SpinePrefabPreview.Create(sourceSkeleton);
                if (preview != null)
                    spinePreviews[assetPath] = preview;
            }

            EditorGUI.DrawRect(rect, new Color(0.12f, 0.12f, 0.12f, 1f));
            if (preview == null)
            {
                GUI.Label(rect, "Spine 预览初始化失败", EditorStyles.centeredGreyMiniLabel);
                return;
            }

            preview.Draw(rect);
        }

        private void DrawAssetPreview(Rect rect, Object asset, string missingMessage)
        {
            EditorGUI.DrawRect(rect, new Color(0.12f, 0.12f, 0.12f, 1f));
            if (asset == null)
            {
                GUI.Label(rect, missingMessage, EditorStyles.centeredGreyMiniLabel);
                return;
            }

            Texture2D preview = AssetPreview.GetAssetPreview(asset);
            if (preview == null)
                preview = AssetPreview.GetMiniThumbnail(asset);
            if (preview != null)
            {
                GUI.DrawTexture(rect, preview, ScaleMode.ScaleToFit, true);
                if (AssetPreview.IsLoadingAssetPreview(asset.GetInstanceID()))
                    QueueAssetPreviewRepaint();
            }
            else
            {
                GUI.Label(rect, "正在生成预览……", EditorStyles.centeredGreyMiniLabel);
                QueueAssetPreviewRepaint();
            }
        }

        private void QueueAssetPreviewRepaint()
        {
            EditorApplication.update -= OnAssetPreviewUpdate;
            EditorApplication.update += OnAssetPreviewUpdate;
        }

        private void OnAssetPreviewUpdate()
        {
            Repaint();
            if (!AssetPreview.IsLoadingAssetPreviews())
                EditorApplication.update -= OnAssetPreviewUpdate;
        }

        private void DisposeSpinePreviews()
        {
            foreach (SpinePrefabPreview preview in spinePreviews.Values)
                preview?.Dispose();
            spinePreviews.Clear();
        }

        internal static string GetFormationPrefabPath(string formationName)
        {
            if (string.IsNullOrWhiteSpace(formationName))
                return string.Empty;
            return FormationPrefabDirectory + "/" + formationName.Trim() + ".prefab";
        }

        internal static string GetActorPrefabPath(string modelResource)
        {
            if (string.IsNullOrWhiteSpace(modelResource))
                return string.Empty;
            string normalized = modelResource.Trim().Replace('\\', '/');
            if (normalized.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase))
                return normalized;
            return ActorPrefabDirectory + "/" + normalized.TrimStart('/');
        }

        private static void PingAsset(Object asset)
        {
            if (asset == null)
                return;
            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }

        private void QuerySelectedPoint(int stageId, string pointId)
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            _ = QueryPoints(stage == null ? string.Empty : stage.assetPath, stageId, new[] { pointId }, false);
        }

        private void RefreshCurrentPrefab(PrefabStage stage, int stageId)
        {
            string[] pointIds = GetCurrentPrefabPointIds(stage);

            _ = QueryPoints(stage.assetPath, stageId, pointIds, true);
        }

        private async Task QueryPoints(string stagePath, int stageId, IReadOnlyCollection<string> pointIds, bool isFullRefresh)
        {
            if (isBusy) return;
            EnsureCacheSource();
            isBusy = true;
            Repaint();
            try
            {
                QueryResult result = await RunQuery(stageId, pointIds);
                if (this == null) return;
                if (result == null)
                    throw new InvalidOperationException("查询脚本没有返回有效数据。");
                if (!result.success)
                    throw new InvalidOperationException(result.error);

                UpdateStagePointPool(stagePath, stageId, result.stagePointIds);

                int successCount = 0;
                int errorCount = 0;
                string cachedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                foreach (PointQueryData item in result.items ?? Array.Empty<PointQueryData>())
                {
                    PointCacheEntry entry = PointCacheEntry.FromQuery(item, cachedAt, stagePath);
                    cache[MakeCacheKey(stagePath, stageId, entry.pointId)] = entry;
                    if (entry.success)
                        successCount++;
                    else
                        errorCount++;
                }

                if (isFullRefresh)
                    RemoveStaleStageCacheEntries(stagePath, stageId, pointIds);

                if (isFullRefresh)
                {
                    SetStatus(
                        string.Format("刷新完成：共缓存 {0} 个五位数点位，成功 {1}，异常 {2}。", pointIds.Count, successCount, errorCount),
                        errorCount == 0 ? MessageType.Info : MessageType.Warning);
                }
                else
                {
                    SetStatus(
                        errorCount == 0 ? "点位查询完成，结果已缓存。" : "点位已缓存，但查询链路存在异常。",
                        errorCount == 0 ? MessageType.Info : MessageType.Warning);
                }
                try { SaveCache(); }
                catch (Exception cacheException)
                { SetStatus("查询已完成，但缓存落盘失败：" + cacheException.Message, MessageType.Warning); }
            }
            catch (Exception exception)
            {
                InvalidateStage(stagePath, stageId, "本次刷新失败，旧数据已失效：" + exception.Message);
                try { SaveCache(); } catch (Exception) { }
                SetStatus("查询失败：" + exception.Message, MessageType.Error);
                Debug.LogError("[怪物点位预览] " + exception);
            }
            finally
            {
                isBusy = false;
                if (this != null) Repaint();
                SceneView.RepaintAll();
            }
        }

        internal static string[] GetCurrentPrefabPointIds(PrefabStage stage)
        {
            if (stage == null || stage.prefabContentsRoot == null)
                return Array.Empty<string>();
            return stage.prefabContentsRoot
                .GetComponentsInChildren<Transform>(true)
                .Where(transform => IsFiveDigitPointName(transform.name))
                .Select(transform => transform.name)
                .Distinct(StringComparer.Ordinal)
                .OrderBy(value => value, StringComparer.Ordinal)
                .ToArray();
        }

        private void UpdateStagePointPool(string stagePath, int stageId, string[] pointIds)
        {
            if (string.IsNullOrEmpty(stagePath) || pointIds == null)
                return;
            stagePointPools[MakeCacheStagePrefix(stagePath, stageId)] = new StagePointPoolCache
            {
                stagePath = stagePath,
                stageId = stageId,
                pointIds = pointIds
                    .Where(pointId => IsFiveDigitPointName(pointId))
                    .Distinct(StringComparer.Ordinal)
                    .OrderBy(pointId => pointId, StringComparer.Ordinal)
                    .ToArray(),
            };
        }

        private void RemoveStaleStageCacheEntries(string stagePath, int stageId, IReadOnlyCollection<string> refreshedPointIds)
        {
            var validKeys = new HashSet<string>(
                refreshedPointIds.Select(pointId => MakeCacheKey(stagePath, stageId, pointId)),
                StringComparer.Ordinal);
            string stagePrefix = MakeCacheStagePrefix(stagePath, stageId);
            string[] staleKeys = cache.Keys
                .Where(key => key.StartsWith(stagePrefix, StringComparison.Ordinal) && !validKeys.Contains(key))
                .ToArray();
            foreach (string staleKey in staleKeys)
                cache.Remove(staleKey);
        }

        private async Task<QueryResult> RunQuery(int stageId, IReadOnlyCollection<string> pointIds)
        {
            ValidateExcelFiles();
            string source = StageToolsIO.NormalizeDirectory(excelDirectory);
            string[] beforeHashes = await Task.Run(() => StageToolsIO.ReadHashes(source));

            string projectRoot = Path.GetFullPath(Path.Combine(Application.dataPath, ".."));
            string scriptPath = Path.Combine(projectRoot, QueryScriptRelativePath);
            string executablePath = Path.Combine(projectRoot, QueryExecutableRelativePath);
            bool useExecutable = File.Exists(executablePath);
            if (!useExecutable && !File.Exists(scriptPath))
                throw new FileNotFoundException("查询程序和回退脚本均不存在", executablePath);

            string tempDirectory = Path.Combine(projectRoot, "Library", "Locus", "tmp", "monster-point-preview");
            Directory.CreateDirectory(tempDirectory);
            string outputPath = Path.Combine(tempDirectory, "query-result-" + Guid.NewGuid().ToString("N") + ".json");

            string queryArguments = "--excel-dir " + StageToolsIO.Quote(source)
                + " --stage " + stageId + " --points " + StageToolsIO.Quote(string.Join(",", pointIds))
                + " --output " + StageToolsIO.Quote(outputPath);
            string arguments = useExecutable ? queryArguments
                : "-X utf8 " + StageToolsIO.Quote(scriptPath) + " " + queryArguments;

            var startInfo = new ProcessStartInfo
            {
                FileName = useExecutable ? executablePath : "python",
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = System.Text.Encoding.UTF8,
                StandardErrorEncoding = System.Text.Encoding.UTF8,
            };

            try
            {
                {
                    StageToolsIO.ProcessResult process = await StageToolsIO.RunAsync(startInfo);
                    string stdout = process.Output;
                    string stderr = process.Error;

                    if (!File.Exists(outputPath))
                    {
                        string detail = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                        throw new InvalidOperationException("查询脚本未生成结果。" + Environment.NewLine + detail.Trim());
                    }

                    string json = File.ReadAllText(outputPath, System.Text.Encoding.UTF8);
                    QueryResult result = JsonUtility.FromJson<QueryResult>(json);
                    if (process.ExitCode != 0 && (result == null || string.IsNullOrEmpty(result.error)))
                        throw new InvalidOperationException(stderr.Trim());
                    string[] afterHashes = await Task.Run(() => StageToolsIO.ReadHashes(source));
                    if (!beforeHashes.SequenceEqual(afterHashes) || !StageToolsIO.SameDirectory(source, excelDirectory))
                        throw new InvalidOperationException("查询期间配置表或目录发生变化，请重新刷新。");
                    if (result != null && result.success)
                    {
                        var returned = result.items ?? Array.Empty<PointQueryData>();
                        if (returned.Length != pointIds.Count || returned.Any(item => item == null || item.stageId != stageId)
                            || !returned.Select(item => item.pointId).OrderBy(id => id)
                                .SequenceEqual(pointIds.OrderBy(id => id)))
                            throw new InvalidOperationException("查询返回的点位集合与请求不一致。");
                        if (!cacheHashes.SequenceEqual(afterHashes))
                        {
                            foreach (PointCacheEntry entry in cache.Values)
                            { entry.success = false; entry.error = "配置表已变化，请重新刷新此点位。"; }
                            stagePointPools.Clear();
                        }
                        cacheHashes = afterHashes;
                    }
                    return result;
                }
            }
            catch (System.ComponentModel.Win32Exception exception)
            {
                throw new InvalidOperationException(
                    useExecutable
                        ? "无法启动怪物点位查询 EXE：" + executablePath
                        : "未找到查询 EXE，且无法启动 python 回退命令。",
                    exception);
            }
            finally
            {
                if (File.Exists(outputPath))
                    File.Delete(outputPath);
            }
        }

        private void ValidateExcelFiles()
        {
            if (string.IsNullOrWhiteSpace(excelDirectory) || !Directory.Exists(excelDirectory))
                throw new DirectoryNotFoundException("Excel 目录不存在：" + excelDirectory);

            string[] required = { "MonsterSpawnType.xls", "MonsterSpawns.xls", "MonsterFormation.xls", "Actor.xls" };
            foreach (string file in required)
            {
                string path = Path.Combine(excelDirectory, file);
                if (!File.Exists(path))
                    throw new FileNotFoundException("缺少配置表", path);
            }
        }

        private void UpdateStatusFromSelection()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string error;
            if (!TryGetStageContext(stage, out stageId, out error))
            {
                SetStatus(error, MessageType.Warning);
                return;
            }

            GameObject selected = Selection.activeGameObject;
            if (selected == null || !IsInsidePrefabStage(selected, stage))
            {
                SetStatus("请在当前 Stage 预制体层级中选择一个五位数点位。", MessageType.Info);
                return;
            }
            if (!IsFiveDigitPointName(selected.name))
            {
                SetStatus("当前对象不是五位数点位；可直接点击“一键刷新当前预制体”建立全量缓存。", MessageType.Info);
                return;
            }

            PointCacheEntry entry;
            if (cache.TryGetValue(MakeCacheKey(stage.assetPath, stageId, selected.name), out entry))
            {
                SetStatus(
                    entry.success ? "已从缓存加载当前点位信息。" : "当前点位存在缓存，但查询链路有异常。",
                    entry.success ? MessageType.Info : MessageType.Warning);
            }
            else
            {
                SetStatus("当前点位尚未缓存，请点击“预览选中点位”。", MessageType.Info);
            }
        }

        private static bool TryGetStageContext(PrefabStage stage, out int stageId, out string error)
        {
            stageId = 0;
            if (stage == null || stage.prefabContentsRoot == null)
            {
                error = "请先打开一个 Stage_XX 关卡预制体进入 Prefab Mode。";
                return false;
            }

            string prefabName = Path.GetFileNameWithoutExtension(stage.assetPath);
            if (!prefabName.StartsWith("Stage_", StringComparison.OrdinalIgnoreCase))
            {
                error = "当前 Prefab 不是 Stage_XX 关卡预制体：" + prefabName;
                return false;
            }

            string suffix = prefabName.Substring("Stage_".Length);
            int underscore = suffix.IndexOf('_');
            if (underscore >= 0)
                suffix = suffix.Substring(0, underscore);
            if (!int.TryParse(suffix, out stageId))
            {
                error = "无法从预制体名称解析关卡 ID：" + prefabName;
                return false;
            }

            error = string.Empty;
            return true;
        }

        private static bool IsInsidePrefabStage(GameObject gameObject, PrefabStage stage)
        {
            if (gameObject == null || stage == null || stage.prefabContentsRoot == null)
                return false;
            return gameObject.scene == stage.scene && gameObject.transform.IsChildOf(stage.prefabContentsRoot.transform);
        }

        private static bool IsFiveDigitPointName(string value)
        {
            if (string.IsNullOrEmpty(value) || value.Length != 5)
                return false;
            for (int i = 0; i < value.Length; i++)
            {
                if (value[i] < '0' || value[i] > '9')
                    return false;
            }
            return true;
        }

        private static string GetHierarchyPath(Transform transform)
        {
            if (transform == null)
                return string.Empty;
            var names = new Stack<string>();
            while (transform != null)
            {
                names.Push(transform.name);
                transform = transform.parent;
            }
            return string.Join("/", names.ToArray());
        }

        private void SetStatus(string message, MessageType type)
        {
            statusMessage = message;
            statusType = type;
        }

        private static string MakeCacheKey(string stagePath, int stageId, string pointId)
        {
            return NormalizeStagePath(stagePath) + "|" + stageId + ":" + pointId;
        }

        private static string MakeCacheStagePrefix(string stagePath, int stageId)
        {
            return NormalizeStagePath(stagePath) + "|" + stageId + ":";
        }

        private static string NormalizeStagePath(string stagePath)
        {
            return (stagePath ?? string.Empty).Replace('\\', '/').Trim();
        }

        private string GetCachePath()
        {
            string source = StageToolsIO.NormalizeDirectory(excelDirectory).ToUpperInvariant();
            using (var hash = System.Security.Cryptography.SHA256.Create())
            {
                string id = BitConverter.ToString(hash.ComputeHash(System.Text.Encoding.UTF8.GetBytes(source)))
                    .Replace("-", string.Empty);
                return Path.GetFullPath(Path.Combine(Application.dataPath, "..", "Library", "StageTools", id + ".json"));
            }
        }

        internal static void InvalidateCache()
        {
            foreach (MonsterPointPreviewWindow window in Resources.FindObjectsOfTypeAll<MonsterPointPreviewWindow>())
            {
                string path = window.GetCachePath();
                if (File.Exists(path)) File.Delete(path);
                window.cache.Clear();
                window.stagePointPools.Clear();
                window.SetStatus("怪物表已修改，旧预览缓存已清除。请重新查询或一键刷新。", MessageType.Info);
                window.Repaint();
            }
        }

        /// <summary>写表成功后刷新目标 Prefab 全部点位，并更新其他共享组合引用点位。</summary>
        internal static async Task<string> RefreshAfterExcelWrite(int configId, int groupId, string stagePath, int stageId, string pointId, string sourceDirectory, string[] targetPrefabPointIds)
        {
            MonsterPointPreviewWindow[] windows = Resources.FindObjectsOfTypeAll<MonsterPointPreviewWindow>();
            if (windows == null || windows.Length == 0)
            {
                return "预览窗口未打开；下次打开将按表格版本校验缓存。";
            }

            int refreshed = 0;
            int refreshedWindows = 0;
            var failures = new List<string>();
            foreach (MonsterPointPreviewWindow window in windows)
            {
                if (window == null || !StageToolsIO.SameDirectory(window.excelDirectory, sourceDirectory)) continue;
                while (window != null && window.isBusy) await Task.Delay(50);
                if (window == null || !StageToolsIO.SameDirectory(window.excelDirectory, sourceDirectory)) continue;
                try
                {
                    refreshed += await window.RefreshAffectedPoints(
                        configId, groupId, stagePath, stageId, pointId, targetPrefabPointIds, failures);
                    refreshedWindows++;
                }
                catch (Exception exception) { failures.Add("Excel 已提交，预览刷新失败：" + exception.Message); }
            }

            if (failures.Count > 0)
            {
                string failure = string.Join("；", failures.ToArray());
                return refreshed == 0 ? failure : "部分点位已刷新；" + failure;
            }
            return refreshedWindows == 0
                ? "没有相同数据源的预览窗口；下次打开将按表格版本校验缓存。"
                : "已整体刷新 " + Path.GetFileNameWithoutExtension(stagePath) + " 的点位缓存，并同步已有共享引用缓存。";
        }

        /// <summary>重新查询目标 Prefab 全部点位及其他 Prefab 中引用同一组合的点位。</summary>
        private async Task<int> RefreshAffectedPoints(
            int configId, int groupId, string stagePath, int stageId, string pointId, string[] targetPrefabPointIds, List<string> failures)
        {
            var targetPointSet = new HashSet<string>(targetPrefabPointIds ?? Array.Empty<string>(), StringComparer.Ordinal);
            targetPointSet.Add(pointId);
            var targets = new List<PointCacheEntry>();
            var seen = new HashSet<string>(StringComparer.Ordinal);

            // 即使预览窗口从未完整刷新过，也根据应用时的 Prefab 快照查询全部点位。
            foreach (string targetId in targetPointSet)
            {
                if (string.IsNullOrEmpty(targetId)) continue;
                if (seen.Add(MakeCacheKey(stagePath, stageId, targetId)))
                    targets.Add(new PointCacheEntry { stagePath = stagePath, stageId = stageId, pointId = targetId });
            }

            foreach (PointCacheEntry entry in cache.Values)
            {
                if (entry == null || string.IsNullOrEmpty(entry.pointId) || string.IsNullOrEmpty(entry.stagePath)
                    || IsSameStage(entry.stagePath, entry.stageId, stagePath, stageId))
                    continue;
                if (!IsAffectedEntry(entry, configId, groupId)) continue;
                if (seen.Add(MakeCacheKey(entry.stagePath, entry.stageId, entry.pointId)))
                    targets.Add(entry);
            }

            isBusy = true;
            try
            {

                int refreshed = 0;
                foreach (IGrouping<string, PointCacheEntry> group in targets.GroupBy(
                    entry => MakeCacheStagePrefix(entry.stagePath, entry.stageId),
                    StringComparer.Ordinal))
                {
                    PointCacheEntry first = group.First();
                    string[] pointIds = group.Select(entry => entry.pointId).Distinct(StringComparer.Ordinal).ToArray();
                    bool isTargetPrefab = IsSameStage(first.stagePath, first.stageId, stagePath, stageId);
                    try
                    {
                        // 等待写表或其他查询时可能增删点位；只对同一路径的目标读取实时层级。
                        // 若已切换/关闭 Prefab Mode，则继续使用提交前快照，不刷新错误的预制体。
                        PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();
                        int currentStageId;
                        string stageError;
                        if (isTargetPrefab && TryGetStageContext(currentStage, out currentStageId, out stageError)
                            && IsSameStage(currentStage.assetPath, currentStageId, stagePath, stageId))
                            pointIds = GetCurrentPrefabPointIds(currentStage);

                        QueryResult result = await RunQuery(first.stageId, pointIds);
                        if (result == null || !result.success)
                            throw new InvalidOperationException(result == null ? "查询程序没有返回结果。" : result.error);

                        UpdateStagePointPool(first.stagePath, first.stageId, result.stagePointIds);

                        if (isTargetPrefab)
                            RemoveStaleStageCacheEntries(first.stagePath, first.stageId, pointIds);

                        string cachedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                        foreach (PointQueryData item in result.items ?? Array.Empty<PointQueryData>())
                        {
                            PointCacheEntry updated = PointCacheEntry.FromQuery(item, cachedAt, first.stagePath);
                            cache[MakeCacheKey(first.stagePath, first.stageId, updated.pointId)] = updated;
                            if (updated.success) refreshed++;
                            else failures.Add("点位 " + updated.pointId + "：" + updated.error);
                        }
                    }
                    catch (Exception exception)
                    {
                        InvalidateStage(first.stagePath, first.stageId, "写表后刷新失败：" + exception.Message);
                        failures.Add("Stage " + first.stageId + " 自动刷新失败，已清除该批次缓存：" + exception.Message);
                        Debug.LogWarning("[怪物点位预览] 写表后自动刷新失败：" + exception);
                    }
                }

                try { SaveCache(); }
                catch (Exception exception) { failures.Add("Excel 已提交，但缓存落盘失败：" + exception.Message); }
                if (failures.Count > 0)
                    SetStatus("Excel 已提交，但预览刷新未全部完成：" + string.Join("；", failures), MessageType.Warning);
                else
                    SetStatus("怪物表已修改，已整体刷新 " + Path.GetFileNameWithoutExtension(stagePath)
                        + " 的点位缓存，并同步已有共享引用；成功 " + refreshed + " 个点位。", MessageType.Info);
                Repaint();
                return refreshed;
            }
            finally { isBusy = false; if (this != null) Repaint(); SceneView.RepaintAll(); }
        }

        private static bool IsSameStage(string leftPath, int leftStageId, string rightPath, int rightStageId)
        {
            return leftStageId == rightStageId
                && string.Equals(NormalizeStagePath(leftPath), NormalizeStagePath(rightPath), StringComparison.Ordinal);
        }

        private static bool IsAffectedEntry(PointCacheEntry entry, int configId, int groupId)
        {
            if (configId <= 0 || entry.spawnRows == null)
                return false;
            foreach (SpawnRowData row in entry.spawnRows)
            {
                if (row == null || row.formationVariants == null)
                    continue;
                foreach (FormationVariantData formation in row.formationVariants)
                {
                    if (formation != null && formation.configId == configId && formation.groupId == groupId)
                        return true;
                }
            }
            return false;
        }

        private static bool IsEditedPointEntry(PointCacheEntry entry, string stagePath, int stageId, string pointId)
        {
            return entry.stageId == stageId
                && string.Equals(entry.pointId, pointId, StringComparison.Ordinal)
                && !string.IsNullOrEmpty(pointId)
                && string.Equals(NormalizeStagePath(entry.stagePath), NormalizeStagePath(stagePath), StringComparison.Ordinal);
        }

        private void InvalidateStage(string stagePath, int stageId, string error)
        {
            string prefix = MakeCacheStagePrefix(stagePath, stageId);
            foreach (var pair in cache.Where(pair => pair.Key.StartsWith(prefix, StringComparison.Ordinal)))
            { pair.Value.success = false; pair.Value.error = error; pair.Value.spawnRows = null; }
            stagePointPools.Remove(prefix);
            DisposeSpinePreviews();
        }

        private void LoadCache()
        {
            cache.Clear();
            stagePointPools.Clear();
            string path = GetCachePath();
            if (!File.Exists(path))
                return;

            try
            {
                CacheFile data = JsonUtility.FromJson<CacheFile>(File.ReadAllText(path, System.Text.Encoding.UTF8));
                if (data == null || !StageToolsIO.SameDirectory(data.sourceDirectory, excelDirectory)
                    || data.tableHashes == null || !data.tableHashes.SequenceEqual(StageToolsIO.ReadHashes(excelDirectory)))
                    return;
                cacheHashes = data.tableHashes;
                foreach (PointCacheEntry item in data == null || data.items == null ? Array.Empty<PointCacheEntry>() : data.items)
                {
                    if (item != null && !string.IsNullOrEmpty(item.pointId) && !string.IsNullOrEmpty(item.stagePath))
                        cache[MakeCacheKey(item.stagePath, item.stageId, item.pointId)] = item;
                }
                foreach (StagePointPoolCache pool in data == null || data.stagePools == null ? Array.Empty<StagePointPoolCache>() : data.stagePools)
                {
                    if (pool != null && !string.IsNullOrEmpty(pool.stagePath) && pool.pointIds != null)
                        stagePointPools[MakeCacheStagePrefix(pool.stagePath, pool.stageId)] = pool;
                }
            }
            catch (Exception exception)
            {
                Debug.LogWarning("[怪物点位预览] 缓存读取失败，将使用空缓存：" + exception.Message);
            }
        }

        private void SaveCache()
        {
            string path = GetCachePath();
            string directory = Path.GetDirectoryName(path);
            if (!string.IsNullOrEmpty(directory))
                Directory.CreateDirectory(directory);

            var data = new CacheFile
            {
                sourceDirectory = StageToolsIO.NormalizeDirectory(excelDirectory),
                tableHashes = cacheHashes,
                items = cache.Values.OrderBy(item => item.stageId).ThenBy(item => item.pointId).ToArray(),
                stagePools = stagePointPools.Values
                    .OrderBy(pool => pool.stageId)
                    .ThenBy(pool => pool.stagePath, StringComparer.Ordinal)
                    .ToArray(),
            };
            string temp = path + "." + Guid.NewGuid().ToString("N") + ".tmp";
            try
            {
                File.WriteAllText(temp, JsonUtility.ToJson(data, true), System.Text.Encoding.UTF8);
                if (File.Exists(path)) File.Replace(temp, path, null);
                else File.Move(temp, path);
            }
            finally { if (File.Exists(temp)) File.Delete(temp); }
        }

        [Serializable]
        private sealed class QueryResult
        {
            public bool success;
            public string error;
            public PointQueryData[] items;
            public string[] stagePointIds;
        }

        [Serializable]
        private class PointQueryData
        {
            public int stageId;
            public string stagePath;
            public string pointId;
            public bool success;
            public string error;
            public int[] spawnTypeIds;
            public SpawnRowData[] spawnRows;
        }

        [Serializable]
        private sealed class PointCacheEntry : PointQueryData
        {
            public string cachedAt;

            public static PointCacheEntry FromQuery(PointQueryData source, string cachedAt, string stagePath)
            {
                return new PointCacheEntry
                {
                    stageId = source.stageId,
                    stagePath = stagePath,
                    pointId = source.pointId,
                    success = source.success,
                    error = source.error,
                    spawnTypeIds = source.spawnTypeIds,
                    spawnRows = source.spawnRows,
                    cachedAt = cachedAt,
                };
            }
        }

        [Serializable]
        private sealed class SpawnRowData
        {
            public int spawnId;
            public int waveIndex;
            public string pointGroupRaw;
            public string formationRaw;
            public int pointCount;
            public FormationVariantData[] formationVariants;
        }

        [Serializable]
        private sealed class FormationVariantData
        {
            public int configId;
            public int groupId;
            public string formationPrefab;
            public string monsterGroupRaw;
            public string description;
            public MonsterData[] monsters;
        }

        [Serializable]
        private sealed class MonsterData
        {
            public int actorId;
            public string actorName;
            public string modelResource;
            public int count;
            public string context;
        }

        [Serializable]
        private sealed class CacheFile
        {
            public string sourceDirectory;
            public string[] tableHashes;
            public PointCacheEntry[] items;
            public StagePointPoolCache[] stagePools;
        }

        [Serializable]
        private sealed class StagePointPoolCache
        {
            public string stagePath;
            public int stageId;
            public string[] pointIds;
        }

        internal sealed class SpinePrefabPreview : IDisposable
        {
            private readonly PreviewRenderUtility previewUtility;
            private readonly SkeletonAnimation skeleton;
            private readonly Bounds bounds;

            private SpinePrefabPreview(SkeletonAnimation source)
            {
                previewUtility = new PreviewRenderUtility(true);
                previewUtility.camera.orthographic = true;
                previewUtility.camera.nearClipPlane = 0.01f;
                previewUtility.camera.farClipPlane = 100f;
                previewUtility.camera.clearFlags = CameraClearFlags.Color;
                previewUtility.camera.backgroundColor = new Color(0.22f, 0.22f, 0.22f, 1f);

                skeleton = SkeletonAnimation.NewSkeletonAnimationGameObject(source.skeletonDataAsset, true);
                skeleton.gameObject.hideFlags = HideFlags.HideAndDontSave;
                skeleton.initialSkinName = source.initialSkinName;
                skeleton.initialFlipX = source.initialFlipX;
                skeleton.initialFlipY = source.initialFlipY;
                skeleton.Initialize(true, true);

                Spine.SkeletonData skeletonData = source.skeletonDataAsset.GetSkeletonData(false);
                string animationName = ResolvePreviewAnimation(source, skeletonData);
                if (!string.IsNullOrEmpty(animationName))
                    skeleton.AnimationState.SetAnimation(0, animationName, true);
                skeleton.Update(0f);
                skeleton.LateUpdate();

                previewUtility.AddSingleGO(skeleton.gameObject);
                skeleton.transform.position = Vector3.zero;
                skeleton.LateUpdate();

                Renderer renderer = skeleton.GetComponent<Renderer>();
                bounds = renderer != null && renderer.bounds.size.sqrMagnitude > 0.0001f
                    ? renderer.bounds
                    : new Bounds(Vector3.zero, Vector3.one * 2f);
            }

            internal static SpinePrefabPreview Create(SkeletonAnimation source)
            {
                if (source == null || source.skeletonDataAsset == null)
                    return null;
                try
                {
                    return new SpinePrefabPreview(source);
                }
                catch (Exception exception)
                {
                    Debug.LogWarning("[怪物点位预览] Spine 预览初始化失败：" + exception.Message);
                    return null;
                }
            }

            internal void Draw(Rect rect)
            {
                if (Event.current.type != EventType.Repaint)
                    return;

                float aspect = Mathf.Max(0.1f, rect.width / Mathf.Max(1f, rect.height));
                float verticalSize = Mathf.Max(0.1f, bounds.extents.y);
                float horizontalSize = Mathf.Max(0.1f, bounds.extents.x) / aspect;
                previewUtility.camera.aspect = aspect;
                previewUtility.camera.orthographicSize = Mathf.Max(verticalSize, horizontalSize) * 1.18f;
                previewUtility.camera.transform.position = new Vector3(bounds.center.x, bounds.center.y, bounds.center.z - 10f);
                previewUtility.camera.transform.rotation = Quaternion.identity;

                previewUtility.BeginPreview(rect, GUIStyle.none);
                previewUtility.camera.Render();
                Texture result = previewUtility.EndPreview();
                if (result != null)
                    GUI.DrawTexture(rect, result, ScaleMode.ScaleToFit, false);
            }

            public void Dispose()
            {
                previewUtility.Cleanup();
            }

            private static string ResolvePreviewAnimation(SkeletonAnimation source, Spine.SkeletonData data)
            {
                if (data == null)
                    return string.Empty;
                if (data.FindAnimation("idle") != null)
                    return "idle";
                if (!string.IsNullOrEmpty(source.AnimationName) && data.FindAnimation(source.AnimationName) != null)
                    return source.AnimationName;
                return data.Animations.Count > 0 ? data.Animations.Items[0].Name : string.Empty;
            }
        }
    }
}
