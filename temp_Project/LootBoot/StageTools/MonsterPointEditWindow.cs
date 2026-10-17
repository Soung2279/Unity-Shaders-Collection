using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Spine.Unity;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace Game.Editor.StageTools
{
    /// <summary>
    /// 单点怪物配置草稿窗口。只允许预览窗口创建一次性草稿，校验来源后写回 Excel，不修改 Prefab。
    /// </summary>
    public sealed class MonsterPointEditWindow : EditorWindow
    {
        private const string DefaultExcelDirectory = "D:/WorkFoldersDoc/Excel";
        private const string ExcelDirectoryPrefKey = "MonsterPointPreview.ExcelDirectory";
        private const string QueryScriptRelativePath = "Assets/Editor/StageTools/monster_point_query.py";
        private const string QueryExecutableRelativePath = "Assets/Editor/StageTools/monster_point_query.exe";
        private const string ExcelWriteScriptRelativePath = "Assets/Editor/StageTools/monster_point_excel_write.ps1";
        private const float PreviewHeight = 176f;

        private static readonly string[] SubTypeNames = { "普通", "精英", "Boss" };
        private static readonly int[] SubTypeValues = { 1, 2, 3 };
        private static readonly string[] AttackTypeNames = { "近战", "远程" };
        private static readonly int[] AttackTypeValues = { 1, 2 };
        private static readonly Color DraftColor = new Color(0.94f, 0.68f, 0.20f, 1f);
        private static readonly Color ActiveModeColor = new Color(0.25f, 0.70f, 0.43f, 1f);
        private static readonly Color InactiveModeColor = new Color(0.34f, 0.34f, 0.34f, 1f);
        private static readonly Color TargetPointColor = new Color(0.78f, 0.16f, 0.14f, 1f);

        [SerializeField] private string excelDirectory = DefaultExcelDirectory;
        [SerializeField] private Vector2 scrollPosition;
        [SerializeField] private string formationInput = string.Empty;
        [SerializeField] private string descriptionInput = string.Empty;
        [SerializeField] private InputMode inputMode = InputMode.Direct;

        private readonly List<ActorCandidate> actorCandidates = new List<ActorCandidate>();
        private readonly List<MonsterDraft> monsterDrafts = new List<MonsterDraft>();
        private readonly Dictionary<string, MonsterPointPreviewWindow.SpinePrefabPreview> spinePreviews =
            new Dictionary<string, MonsterPointPreviewWindow.SpinePrefabPreview>(StringComparer.OrdinalIgnoreCase);

        private string[] formationOptions = Array.Empty<string>();
        private int loadedStageId;
        private string loadedStagePath = string.Empty;
        private string loadedPointId = string.Empty;
        private int loadedWaveIndex;
        private string loadedDescription = string.Empty;
        private string descriptionAutoPrefix = string.Empty;
        private bool descriptionManuallyEdited;
        private int loadedConfigId;
        private int loadedGroupId;
        private string loadedFormationRaw = string.Empty;
        private string loadedMonsterGroupRaw = string.Empty;
        private string loadedExcelDirectory = string.Empty;
        private string loadedPrefabPath = string.Empty;
        private int loadedPointInstanceId;
        private string[] loadedTableHashes = Array.Empty<string>();
        private ReferenceData[] loadedReferences = Array.Empty<ReferenceData>();
        private bool hasLoadedPoint;
        private bool draftChanged;
        private bool isBusy;
        private bool windowEnabled;
        private int draftGeneration;
        private string statusMessage = "请选择一个五位数点位，然后读取配置。";
        private MessageType statusType = MessageType.Info;
        private GUIStyle headerStyle;
        private GUIStyle wrappedLabel;
        private GUIStyle cardButtonStyle;

        [MenuItem("TATools/关卡工具/怪物点位配置草稿", false, 11)]
        public static void OpenWindow()
        {
            var window = GetWindow<MonsterPointEditWindow>();
            window.titleContent = new GUIContent("怪物点位配置草稿", EditorGUIUtility.IconContent("d_editicon.sml").image);
            window.minSize = new Vector2(720f, 560f);
            window.Show();
        }

        private void OnEnable()
        {
            windowEnabled = true;
            excelDirectory = EditorPrefs.GetString(ExcelDirectoryPrefKey, DefaultExcelDirectory);
            Selection.selectionChanged -= OnSelectionChanged;
            Selection.selectionChanged += OnSelectionChanged;
            ClearDraft("请从预览窗口点击修改此点位创建草稿。");
            RefreshFormationOptions();
            UpdateSelectionStatus();
        }

        private void OnDisable()
        {
            windowEnabled = false;
            ClearDraft("窗口已关闭，草稿已清空。");
            Selection.selectionChanged -= OnSelectionChanged;
            DisposeSpinePreviews();
        }

        private void OnSelectionChanged()
        {
            if (!isBusy) UpdateSelectionStatus();
            Repaint();
        }

        private void OnGUI()
        {
            EnsureStyles();
            if (isBusy)
            {
                EditorGUILayout.HelpBox(statusMessage, MessageType.Info);
                return;
            }
            DrawHeader();
            EditorGUILayout.Space(6f);
            DrawSelectionContext();
            EditorGUILayout.Space(6f);
            EditorGUILayout.HelpBox("草稿只能通过预览窗口的“修改此点位”创建。应用成功后草稿会自动清空。", MessageType.Info);
            EditorGUILayout.Space(5f);
            EditorGUILayout.HelpBox(statusMessage, statusType);

            if (!hasLoadedPoint)
                return;

            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
            DrawLoadedSummary();
            EditorGUILayout.Space(6f);
            DrawInputModeSwitcher();
            EditorGUILayout.Space(6f);
            DrawFormationEditor();
            EditorGUILayout.Space(6f);
            DrawMonsterEditor();
            EditorGUILayout.Space(6f);
            DrawDraftPreview();
            EditorGUILayout.Space(8f);
            DrawApplyButton();
            EditorGUILayout.Space(8f);
            EditorGUILayout.HelpBox("当前仅编辑内存草稿。点击“应用到 Excel”后，只修改 MonsterFormation 的 C、D、F 列，并自动生成备份；应用前要求当前选中点位与当前修改点位一致。", MessageType.Info);
            EditorGUILayout.EndScrollView();
        }

        private void DrawApplyButton()
        {
            bool formationValid = IsFormationInputValid();
            bool monstersValid = monsterDrafts.Count > 0
                && monsterDrafts.All(draft => draft != null && draft.actorId > 0 && draft.count > 0 && FindActor(draft.actorId) != null);
            bool pointMatched = IsSelectedPointMatchingDraft();
            // 点位不一致时保留按钮可点击，以便弹窗告知用户具体原因。
            bool canApply = !isBusy && hasLoadedPoint && draftChanged && monstersValid && formationValid;
            using (new EditorGUI.DisabledScope(!canApply))
            {
                Color previous = GUI.backgroundColor;
                GUI.backgroundColor = new Color(0.86f, 0.42f, 0.12f, 1f);
                if (GUILayout.Button(isBusy ? "正在应用……" : "应用到 Excel（仅当前点位）", GUILayout.Height(34f)))
                    ApplyDraftToExcel();
                GUI.backgroundColor = previous;
            }
            if (draftChanged && !formationValid)
                EditorGUILayout.HelpBox("当前阵型名称无效：必须是 PointSpawn 中存在的 Prefab。", MessageType.Error);
            else if (draftChanged && !monstersValid)
                EditorGUILayout.HelpBox("当前怪物配置无效：Actor ID 必须存在于 Actor 表，数量必须大于 0。", MessageType.Error);
            else if (draftChanged && !pointMatched)
                EditorGUILayout.HelpBox(BuildPointMismatchMessage(), MessageType.Warning);
            if (!draftChanged)
                EditorGUILayout.LabelField("请先修改阵型、怪物种类或数量后再应用。", EditorStyles.miniLabel);
        }

        private void EnsureStyles()
        {
            if (headerStyle == null)
                headerStyle = new GUIStyle(EditorStyles.boldLabel) { fontSize = 15 };
            if (wrappedLabel == null)
                wrappedLabel = new GUIStyle(EditorStyles.label) { wordWrap = true };
            if (cardButtonStyle == null)
            {
                cardButtonStyle = new GUIStyle(EditorStyles.miniButton)
                {
                    alignment = TextAnchor.MiddleCenter,
                    wordWrap = true,
                    clipping = TextClipping.Clip,
                    fontSize = 10,
                    padding = new RectOffset(3, 3, 2, 2),
                };
            }
        }

        private void DrawHeader()
        {
            EditorGUILayout.LabelField("Stage 怪物点位配置草稿", headerStyle);
            EditorGUILayout.LabelField("一次只读取和编辑一个点位；应用修改前必须选中当前修改点位。", wrappedLabel);

            EditorGUILayout.LabelField("Excel 数据源（由预览窗口指定）", excelDirectory, wrappedLabel);
        }

        private void DrawSelectionContext()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int selectedStageId;
            string selectedPointId;
            string selectionError;
            bool hasSelectedPoint = TryGetSelectedPoint(out selectedStageId, out selectedPointId, out selectionError);
            int stageId;
            string error;
            bool validStage = TryGetStageContext(stage, out stageId, out error);
            bool pointMatched = hasSelectedPoint && MatchesLoadedPoint(selectedStageId, selectedPointId);

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("当前选择", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("Prefab", stage == null ? "未进入 Prefab Mode" : stage.assetPath);
                EditorGUILayout.LabelField("关卡 ID", validStage ? stageId.ToString() : "-");
                EditorGUILayout.LabelField("选中数量", Selection.gameObjects.Length.ToString());
                DrawPointField("当前选中点位", hasSelectedPoint ? selectedPointId : "-", pointMatched);
                if (hasLoadedPoint)
                    DrawPointField("当前修改点位", "Stage " + loadedStageId + " / " + loadedPointId, true);
                if (hasLoadedPoint && !pointMatched)
                {
                    string mismatch = hasSelectedPoint
                        ? "选中点位 Stage " + selectedStageId + " / " + selectedPointId + " 与当前修改点位不一致，应用修改会被拒绝。"
                        : "当前没有有效选中的点位，应用修改会被拒绝。";
                    EditorGUILayout.HelpBox(mismatch, MessageType.Warning);
                }
            }
        }

        private static string GetCurrentStagePath()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            return stage == null || string.IsNullOrEmpty(stage.assetPath) ? string.Empty : stage.assetPath;
        }

        private void DrawLoadedSummary()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                Color previous = GUI.backgroundColor;
                GUI.backgroundColor = DraftColor;
                EditorGUILayout.LabelField(draftChanged ? "草稿已修改（尚未保存）" : "草稿与当前表格查询结果一致", EditorStyles.helpBox);
                GUI.backgroundColor = previous;
                EditorGUILayout.LabelField("Stage / 点位", loadedStageId + " / " + loadedPointId);
                DrawPointBanner("当前修改点位：Stage " + loadedStageId + " / " + loadedPointId);
                EditorGUILayout.LabelField("波次", loadedWaveIndex.ToString());
                if (!string.IsNullOrEmpty(loadedDescription))
                    EditorGUILayout.LabelField("原说明", loadedDescription, wrappedLabel);
                EditorGUILayout.Space(4f);
                DrawDescriptionEditor();
            }
        }

        private void DrawDescriptionEditor()
        {
            EditorGUILayout.LabelField("点位描述（MonsterFormation F 列）", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            EditorGUI.BeginChangeCheck();
            string changedDescription = EditorGUILayout.TextArea(descriptionInput, GUILayout.MinHeight(42f));
            if (EditorGUI.EndChangeCheck())
            {
                descriptionInput = changedDescription;
                descriptionManuallyEdited = true;
                MarkDraftChanged();
            }

            Color previous = GUI.backgroundColor;
            GUI.backgroundColor = descriptionManuallyEdited ? new Color(0.86f, 0.58f, 0.20f, 1f) : ActiveModeColor;
            if (GUILayout.Button(descriptionManuallyEdited ? "恢复自动" : "重新生成", GUILayout.Width(78f), GUILayout.Height(42f)))
            {
                descriptionManuallyEdited = false;
                RefreshDescriptionFromDraft();
                MarkDraftChanged();
            }
            GUI.backgroundColor = previous;
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.LabelField(
                descriptionManuallyEdited
                    ? "当前为手动描述，修改阵型或怪物不会覆盖文本。"
                    : "当前为自动描述：B=包围、F=分散、J=聚集；不符合 B/F/J+数字规则的阵型会保留原文本。",
                EditorStyles.miniLabel);
        }

        private void DrawInputModeSwitcher()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("参数输入方式", EditorStyles.boldLabel);
                EditorGUILayout.BeginHorizontal();
                if (DrawModeButton("直接输入 ID", inputMode == InputMode.Direct))
                    inputMode = InputMode.Direct;
                if (DrawModeButton("分类下拉选择", inputMode == InputMode.Dropdown))
                    inputMode = InputMode.Dropdown;
                EditorGUILayout.EndHorizontal();
            }
        }

        private bool DrawModeButton(string label, bool active)
        {
            Color previous = GUI.backgroundColor;
            GUI.backgroundColor = active ? ActiveModeColor : InactiveModeColor;
            bool clicked = GUILayout.Button(label, GUILayout.Height(28f));
            GUI.backgroundColor = previous;
            return clicked;
        }

        private void DrawPointField(string label, string value, bool highlighted)
        {
            Rect row = EditorGUILayout.GetControlRect();
            Rect labelRect = new Rect(row.x, row.y, EditorGUIUtility.labelWidth - 4f, row.height);
            Rect valueRect = new Rect(row.x + EditorGUIUtility.labelWidth, row.y, row.width - EditorGUIUtility.labelWidth, row.height);
            GUI.Label(labelRect, label);
            if (highlighted)
                EditorGUI.DrawRect(valueRect, new Color(TargetPointColor.r, TargetPointColor.g, TargetPointColor.b, 0.72f));
            Color previous = GUI.color;
            if (highlighted)
                GUI.color = Color.white;
            GUI.Label(new Rect(valueRect.x + 5f, valueRect.y, valueRect.width - 5f, valueRect.height), value, highlighted ? EditorStyles.boldLabel : EditorStyles.label);
            GUI.color = previous;
        }

        private void DrawPointBanner(string text)
        {
            Color previousBackground = GUI.backgroundColor;
            Color previousColor = GUI.color;
            GUI.backgroundColor = TargetPointColor;
            GUI.color = Color.white;
            EditorGUILayout.LabelField(text, EditorStyles.helpBox);
            GUI.backgroundColor = previousBackground;
            GUI.color = previousColor;
        }

        private void DrawFormationEditor()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("阵型", EditorStyles.boldLabel);
                if (inputMode == InputMode.Direct)
                {
                    EditorGUI.BeginChangeCheck();
                    string directInput = EditorGUILayout.TextField(new GUIContent("阵型名称", "例如 J001"), formationInput);
                    if (EditorGUI.EndChangeCheck())
                    {
                        formationInput = directInput.Trim();
                        RefreshDescriptionFromDraft();
                        MarkDraftChanged();
                    }
                }
                else
                {
                    int selectedIndex = Array.FindIndex(formationOptions, value => string.Equals(value, formationInput, StringComparison.OrdinalIgnoreCase));
                    int popupIndex = Mathf.Max(0, selectedIndex + 1);
                    string[] displayed = new[] { "请选择阵型…" }.Concat(formationOptions).ToArray();
                    EditorGUI.BeginChangeCheck();
                    popupIndex = EditorGUILayout.Popup("阵型 Prefab", popupIndex, displayed);
                    if (EditorGUI.EndChangeCheck() && popupIndex > 0)
                    {
                        formationInput = formationOptions[popupIndex - 1];
                        RefreshDescriptionFromDraft();
                        MarkDraftChanged();
                    }
                }

                string formationPath = MonsterPointPreviewWindow.GetFormationPrefabPath(formationInput);
                GameObject formationPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(formationPath);
                EditorGUILayout.ObjectField("阵型 Prefab", formationPrefab, typeof(GameObject), false);
                if (!string.IsNullOrEmpty(formationInput) && formationPrefab == null)
                    EditorGUILayout.HelpBox("PointSpawn 中找不到阵型：" + formationInput, MessageType.Warning);
            }
        }

        private void DrawMonsterEditor()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("怪物种类与数量", EditorStyles.boldLabel);
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("新增怪物", GUILayout.Width(82f)))
                {
                    monsterDrafts.Add(CreateDefaultMonsterDraft());
                    RefreshDescriptionFromDraft();
                    MarkDraftChanged();
                }
                EditorGUILayout.EndHorizontal();

                if (monsterDrafts.Count == 0)
                    EditorGUILayout.HelpBox("当前草稿没有怪物。请点击“新增怪物”。", MessageType.Warning);

                for (int i = 0; i < monsterDrafts.Count; i++)
                    DrawMonsterDraft(monsterDrafts[i], i);
            }
        }

        private void DrawMonsterDraft(MonsterDraft draft, int index)
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("怪物 " + (index + 1), EditorStyles.boldLabel);
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("移除", GUILayout.Width(52f)))
                {
                    monsterDrafts.RemoveAt(index);
                    RefreshDescriptionFromDraft();
                    MarkDraftChanged();
                    GUIUtility.ExitGUI();
                }
                EditorGUILayout.EndHorizontal();

                if (inputMode == InputMode.Direct)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUI.BeginChangeCheck();
                    int actorId = EditorGUILayout.IntField("Actor ID", draft.actorId);
                    if (EditorGUI.EndChangeCheck())
                    {
                        draft.actorId = Mathf.Max(0, actorId);
                        ApplyActorCandidate(draft, FindActor(draft.actorId), false);
                        RefreshDescriptionFromDraft();
                        MarkDraftChanged();
                    }

                    EditorGUI.BeginChangeCheck();
                    int count = EditorGUILayout.IntField("数量", draft.count);
                    if (EditorGUI.EndChangeCheck())
                    {
                        draft.count = Mathf.Max(0, count);
                        RefreshDescriptionFromDraft();
                        MarkDraftChanged();
                    }
                    EditorGUILayout.EndHorizontal();
                }
                else
                {
                    DrawMonsterDropdownFields(draft);
                    EditorGUI.BeginChangeCheck();
                    int count = EditorGUILayout.IntField("数量", draft.count);
                    if (EditorGUI.EndChangeCheck())
                    {
                        draft.count = Mathf.Max(0, count);
                        RefreshDescriptionFromDraft();
                        MarkDraftChanged();
                    }
                }

                ActorCandidate resolved = FindActor(draft.actorId);
                if (resolved == null)
                {
                    EditorGUILayout.HelpBox("Actor 表中找不到可配置怪物 ID：" + draft.actorId, MessageType.Warning);
                }
                else
                {
                    EditorGUILayout.LabelField("当前怪物", resolved.actorName + "（" + GetSubTypeName(resolved.subType) + " / " + GetAttackTypeName(resolved.attackType) + "）");
                    GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(MonsterPointPreviewWindow.GetActorPrefabPath(resolved.modelResource));
                    EditorGUILayout.ObjectField("怪物 Prefab", prefab, typeof(GameObject), false);
                }
            }
        }

        private void DrawMonsterDropdownFields(MonsterDraft draft)
        {
            EditorGUILayout.BeginHorizontal();
            int subIndex = Mathf.Max(0, Array.IndexOf(SubTypeValues, draft.subType));
            int attackIndex = Mathf.Max(0, Array.IndexOf(AttackTypeValues, draft.attackType));

            EditorGUI.BeginChangeCheck();
            subIndex = EditorGUILayout.Popup("单位子类型", subIndex, SubTypeNames);
            if (EditorGUI.EndChangeCheck())
            {
                draft.subType = SubTypeValues[subIndex];
                SelectFirstFilteredActor(draft);
                RefreshDescriptionFromDraft();
                MarkDraftChanged();
            }

            EditorGUI.BeginChangeCheck();
            attackIndex = EditorGUILayout.Popup("攻击类型", attackIndex, AttackTypeNames);
            if (EditorGUI.EndChangeCheck())
            {
                draft.attackType = AttackTypeValues[attackIndex];
                SelectFirstFilteredActor(draft);
                RefreshDescriptionFromDraft();
                MarkDraftChanged();
            }
            EditorGUILayout.EndHorizontal();

            List<ActorCandidate> filtered = GetFilteredActors(draft.subType, draft.attackType);
            string[] actorNames = filtered.Select(actor => actor.actorId + "  " + actor.actorName).ToArray();
            int actorIndex = filtered.FindIndex(actor => actor.actorId == draft.actorId);
            int shownIndex = Mathf.Max(0, actorIndex + 1);
            string[] displayed = new[] { filtered.Count == 0 ? "该分类没有候选怪物" : "请选择怪物…" }.Concat(actorNames).ToArray();
            using (new EditorGUI.DisabledScope(filtered.Count == 0))
            {
                EditorGUI.BeginChangeCheck();
                shownIndex = EditorGUILayout.Popup("怪物", shownIndex, displayed);
                if (EditorGUI.EndChangeCheck() && shownIndex > 0)
                {
                    ApplyActorCandidate(draft, filtered[shownIndex - 1], true);
                    RefreshDescriptionFromDraft();
                    MarkDraftChanged();
                }
            }
        }

        private void DrawDraftPreview()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("草稿预览", EditorStyles.boldLabel);
                Rect row = EditorGUILayout.GetControlRect(false, PreviewHeight);
                float gap = 6f;
                float half = (row.width - gap) * 0.5f;
                DrawFormationPreview(new Rect(row.x, row.y, half, row.height));
                DrawMonsterPreviews(new Rect(row.x + half + gap, row.y, half, row.height));
            }
        }

        private void DrawFormationPreview(Rect rect)
        {
            GUI.Box(rect, GUIContent.none, EditorStyles.helpBox);
            GUI.Label(new Rect(rect.x + 6f, rect.y + 4f, rect.width - 12f, 18f), "阵型画面", EditorStyles.boldLabel);
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(MonsterPointPreviewWindow.GetFormationPrefabPath(formationInput));
            DrawAssetPreview(new Rect(rect.x + 6f, rect.y + 24f, rect.width - 12f, rect.height - 30f), prefab, "未找到阵型 Prefab");
        }

        private void DrawMonsterPreviews(Rect rect)
        {
            GUI.Box(rect, GUIContent.none, EditorStyles.helpBox);
            GUI.Label(new Rect(rect.x + 6f, rect.y + 4f, rect.width - 12f, 18f), "怪物资源", EditorStyles.boldLabel);
            MonsterDraft[] valid = monsterDrafts.Where(draft => FindActor(draft.actorId) != null).ToArray();
            if (valid.Length == 0)
            {
                GUI.Label(new Rect(rect.x + 8f, rect.y + 28f, rect.width - 16f, rect.height - 36f), "没有可预览的怪物", EditorStyles.centeredGreyMiniLabel);
                return;
            }

            Rect content = new Rect(rect.x + 6f, rect.y + 24f, rect.width - 12f, rect.height - 30f);
            float width = content.width / valid.Length;
            for (int i = 0; i < valid.Length; i++)
            {
                MonsterDraft draft = valid[i];
                ActorCandidate actor = FindActor(draft.actorId);
                Rect cell = new Rect(content.x + width * i, content.y, width, content.height);
                string path = MonsterPointPreviewWindow.GetActorPrefabPath(actor.modelResource);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                const float footer = 44f;
                DrawMonsterAssetPreview(new Rect(cell.x + 3f, cell.y, cell.width - 6f, cell.height - footer), prefab, path);
                GUI.Button(new Rect(cell.x + 2f, cell.yMax - footer, cell.width - 4f, footer - 2f), actor.actorName + " ×" + draft.count + "\nID " + actor.actorId, cardButtonStyle);
            }
        }

        private void DrawMonsterAssetPreview(Rect rect, GameObject prefab, string path)
        {
            if (prefab == null)
            {
                DrawAssetPreview(rect, null, "未找到怪物 Prefab");
                return;
            }

            SkeletonAnimation skeleton = prefab.GetComponentInChildren<SkeletonAnimation>(true);
            if (skeleton == null)
            {
                DrawAssetPreview(rect, prefab, "无法生成预览");
                return;
            }

            MonsterPointPreviewWindow.SpinePrefabPreview preview;
            if (!spinePreviews.TryGetValue(path, out preview) || preview == null)
            {
                preview = MonsterPointPreviewWindow.SpinePrefabPreview.Create(skeleton);
                if (preview != null)
                    spinePreviews[path] = preview;
            }

            EditorGUI.DrawRect(rect, new Color(0.12f, 0.12f, 0.12f, 1f));
            if (preview == null)
                GUI.Label(rect, "Spine 预览初始化失败", EditorStyles.centeredGreyMiniLabel);
            else
                preview.Draw(rect);
        }

        private void DrawAssetPreview(Rect rect, UnityEngine.Object asset, string missing)
        {
            EditorGUI.DrawRect(rect, new Color(0.12f, 0.12f, 0.12f, 1f));
            if (asset == null)
            {
                GUI.Label(rect, missing, EditorStyles.centeredGreyMiniLabel);
                return;
            }

            Texture2D texture = AssetPreview.GetAssetPreview(asset) ?? AssetPreview.GetMiniThumbnail(asset);
            if (texture != null)
                GUI.DrawTexture(rect, texture, ScaleMode.ScaleToFit, true);
            else
                GUI.Label(rect, "正在生成预览……", EditorStyles.centeredGreyMiniLabel);
            if (AssetPreview.IsLoadingAssetPreviews())
                Repaint();
        }

        internal async Task LoadPointFromPreview(string stagePath, int stageId, string pointId, string sourceDirectory)
        {
            if (isBusy || string.IsNullOrEmpty(pointId)) return;
            if (draftChanged && !EditorUtility.DisplayDialog("替换草稿", "丢弃当前未提交草稿？", "丢弃", "取消")) return;
            ClearDraft("正在读取新草稿……");
            int selectedStage;
            string selectedPoint, error;
            if (!TryGetSelectedPoint(out selectedStage, out selectedPoint, out error)
                || selectedStage != stageId || selectedPoint != pointId || GetCurrentStagePath() != stagePath)
            { statusMessage = "预览目标与当前选中点位不一致，未创建草稿。"; return; }
            loadedPointInstanceId = Selection.activeGameObject.GetInstanceID();
            excelDirectory = sourceDirectory ?? string.Empty;
            await LoadSelectedPoint(stagePath, stageId, pointId);
        }

        private async Task LoadSelectedPoint(string stagePath, int stageId, string pointId)
        {
            int generation = draftGeneration;
            isBusy = true;
            Repaint();
            try
            {
                string source = StageToolsIO.NormalizeDirectory(excelDirectory);
                string[] hashes = await Task.Run(() => StageToolsIO.ReadHashes(source));
                QueryResponse response = await RunQuery(stageId, pointId);
                string[] afterHashes = await Task.Run(() => StageToolsIO.ReadHashes(source));
                if (this == null || !windowEnabled || generation != draftGeneration) return;
                if (!hashes.SequenceEqual(afterHashes) || !StageToolsIO.SameDirectory(source, excelDirectory))
                    throw new InvalidOperationException("读取期间配置表或目录发生变化，请重新创建草稿。");
                loadedExcelDirectory = source;
                loadedTableHashes = hashes;
                loadedPrefabPath = stagePath;
                if (response == null || !response.success)
                    throw new InvalidOperationException(response == null ? "查询程序没有返回结果。" : response.error);
                PointQueryData item = response.items == null ? null : response.items.FirstOrDefault();
                if (item == null || !item.success)
                    throw new InvalidOperationException(item == null ? "没有点位查询结果。" : item.error);
                if (response.items.Length != 1 || item.stageId != stageId || item.pointId != pointId)
                    throw new InvalidOperationException("查询返回的关卡/点位与请求不一致，未创建草稿。");
                if (item.spawnRows == null || item.spawnRows.Length == 0)
                    throw new InvalidOperationException("点位没有可编辑的 MonsterFormation 配置。");
                if (item.spawnRows.Length > 1)
                    throw new InvalidOperationException("点位对应多个波次配置，当前编辑窗口不允许默认选择。请先在预览窗口确认具体波次后再编辑。");
                SpawnRowData row = item.spawnRows[0];
                if (row.formationVariants == null || row.formationVariants.Length != 1)
                    throw new InvalidOperationException("点位对应多个或零个 MonsterFormation 配置，当前编辑窗口不允许默认选择。");
                FormationData formation = row.formationVariants[0];

                actorCandidates.Clear();
                if (response.actorCandidates != null)
                    actorCandidates.AddRange(response.actorCandidates.Where(actor => actor != null));

                loadedStageId = stageId;
                loadedStagePath = string.IsNullOrEmpty(stagePath) ? GetCurrentStagePath() : stagePath;
                loadedPointId = pointId;
                loadedWaveIndex = row.waveIndex;
                loadedDescription = formation.description ?? string.Empty;
                descriptionInput = loadedDescription;
                descriptionAutoPrefix = string.Empty;
                descriptionManuallyEdited = false;
                loadedConfigId = formation.configId;
                loadedGroupId = formation.groupId;
                loadedFormationRaw = formation.formationPrefab ?? string.Empty;
                loadedMonsterGroupRaw = formation.monsterGroupRaw ?? string.Empty;
                loadedReferences = formation.references ?? Array.Empty<ReferenceData>();
                formationInput = formation.formationPrefab ?? string.Empty;
                monsterDrafts.Clear();
                foreach (MonsterData monster in formation.monsters ?? Array.Empty<MonsterData>())
                {
                    ActorCandidate actor = FindActor(monster.actorId);
                    monsterDrafts.Add(new MonsterDraft
                    {
                        actorId = monster.actorId,
                        count = monster.count,
                        subType = actor == null ? 1 : actor.subType,
                        attackType = actor == null ? 1 : actor.attackType,
                    });
                }
                // 每次创建草稿默认自动生成描述；用户直接编辑文本后才切换为手动。
                RefreshDescriptionFromDraft();

                hasLoadedPoint = true;
                if (!IsSelectedPointMatchingDraft())
                    throw new InvalidOperationException("读取期间选择或 Prefab 已变化，请重新点击修改此点位。"
                        + " 当前=" + GetCurrentStagePath() + "/" + (Selection.activeGameObject == null
                            ? "无" : Selection.activeGameObject.name + "#" + Selection.activeGameObject.GetInstanceID())
                        + " 草稿=" + loadedPrefabPath + "/" + loadedPointId + "#" + loadedPointInstanceId);
                draftChanged = !string.Equals(descriptionInput, loadedDescription, StringComparison.Ordinal);
                DisposeSpinePreviews();
                statusMessage = "已读取点位配置并创建内存草稿。";
                statusType = MessageType.Info;
            }
            catch (Exception exception)
            {
                ClearDraft("读取失败：" + exception.Message);
                statusType = MessageType.Error;
                Debug.LogError("[怪物点位配置草稿] " + exception);
            }
            finally
            {
                isBusy = false;
                if (this != null) Repaint();
            }
        }

        private async void ApplyDraftToExcel()
        {
            if (isBusy || !hasLoadedPoint || !draftChanged)
                return;

            if (!IsSelectedPointMatchingDraft())
            {
                string reason = BuildPointMismatchMessage();
                statusMessage = "应用已阻止：" + reason;
                statusType = MessageType.Warning;
                EditorUtility.DisplayDialog("无法应用修改", reason, "确定");
                return;
            }

            if (!IsFormationInputValid() || monsterDrafts.Count == 0 || monsterDrafts.Any(draft => draft == null || draft.actorId <= 0 || draft.count <= 0 || FindActor(draft.actorId) == null))
            {
                EditorUtility.DisplayDialog("无法应用修改", "当前阵型或怪物配置无效，请修正后再应用。", "确定");
                return;
            }

            string monsterGroup = string.Join("|", monsterDrafts.Select(draft => draft.actorId + ":" + draft.count));
            string impact = BuildImpactSummary();
            bool confirmed = EditorUtility.DisplayDialog(
                "确认应用修改",
                "数据源：" + loadedExcelDirectory + "\nPrefab：" + loadedPrefabPath + "\n" +
                "目标：Stage " + loadedStageId + " / 点位 " + loadedPointId + "\n\n" +
                "阵型：" + loadedFormationRaw + " → " + formationInput + "\n" +
                "怪物：" + loadedMonsterGroupRaw + " → " + monsterGroup + "\n" +
                "描述：" + loadedDescription + " → " + descriptionInput + "\n\n" +
                impact,
                "应用", "取消");
            if (!confirmed) return;
            try { await ApplyConfirmedDraft(); }
            catch (Exception exception)
            {
                statusMessage = "应用已阻止：" + exception.Message;
                statusType = MessageType.Warning;
            }
        }

        /// <summary>确认后仍复核唯一目标；提交请求一旦生成不再读取当前选择。</summary>
        private async Task ApplyConfirmedDraft()
        {
            if (isBusy || !hasLoadedPoint || !draftChanged || !IsSelectedPointMatchingDraft())
                throw new InvalidOperationException("草稿与当前数据源、Prefab 或点位对象不一致，已拒绝提交。");
            if (!IsFormationInputValid() || monsterDrafts.Count == 0
                || monsterDrafts.Any(draft => draft.actorId <= 0 || draft.count <= 0 || FindActor(draft.actorId) == null))
                throw new InvalidOperationException("阵型或怪物草稿无效。");
            string monsterGroup = string.Join("|", monsterDrafts.Select(draft => draft.actorId + ":" + draft.count));
            isBusy = true;
            statusMessage = "正在写入 Excel 并复核（需要启动本机 Excel，通常 3~6 秒）……";
            statusType = MessageType.Info;
            Repaint();
            var writeWatch = System.Diagnostics.Stopwatch.StartNew();
            try
            {
                ValidateExcelFiles();
                var request = new ExcelWriteRequest
                {
                    excelPath = Path.Combine(loadedExcelDirectory, "MonsterFormation.xls"),
                    configId = loadedConfigId,
                    groupId = loadedGroupId,
                    expectedFormation = loadedFormationRaw,
                    expectedMonsterGroup = loadedMonsterGroupRaw,
                    expectedDescription = loadedDescription,
                    newFormation = formationInput.Trim(),
                    newMonsterGroup = monsterGroup,
                    newDescription = descriptionInput,
                    sourceHash = loadedTableHashes[2],
                    tableHashes = loadedTableHashes.ToArray(),
                };
                int targetConfig = loadedConfigId, targetGroup = loadedGroupId, targetStage = loadedStageId;
                string targetPoint = loadedPointId, targetPath = loadedStagePath, source = loadedExcelDirectory;
                // 写表期间可能切换或关闭 Prefab Mode，保留提交目标的完整点位快照。
                string[] targetPointIds = MonsterPointPreviewWindow.GetCurrentPrefabPointIds(PrefabStageUtility.GetCurrentPrefabStage());
                ExcelWriteResponse result = await RunExcelWrite(request);
                if (result == null || !result.success)
                    throw new InvalidOperationException(result == null ? "写入程序没有返回结果。" : result.error);

                writeWatch.Stop();
                ClearDraft("已应用到 Excel，草稿已清空。请从预览窗口重新点击修改此点位。");
                string refreshMessage;
                try
                {
                    refreshMessage = await MonsterPointPreviewWindow.RefreshAfterExcelWrite(
                        targetConfig, targetGroup, targetPath, targetStage, targetPoint, source, targetPointIds);
                }
                catch (Exception refreshException)
                {
                    refreshMessage = "Excel 已提交，但预览刷新/缓存保存失败：" + refreshException.Message;
                }
                if (this == null) return;
                statusMessage = "Excel 已提交，草稿已清空。" + refreshMessage + " 备份：" + result.backupPath;
                statusType = MessageType.Info;
            }
            catch (Exception exception)
            {
                writeWatch.Stop();
                ClearDraft("提交未完成，请从预览窗口重新查询并创建草稿。");
                statusMessage = "提交未确认，请重新查询表格状态（耗时 " + (writeWatch.ElapsedMilliseconds / 1000.0).ToString("0.0") + " 秒）：" + exception.Message;
                statusType = MessageType.Error;
                Debug.LogError("[怪物点位配置草稿] " + exception);
                // 异步失败保留在窗口状态，避免后台弹窗阻塞 Editor。
            }
            finally
            {
                isBusy = false;
                if (this != null) Repaint();
            }
        }

        private bool IsFormationInputValid()
        {
            if (string.IsNullOrWhiteSpace(formationInput))
                return false;
            string path = MonsterPointPreviewWindow.GetFormationPrefabPath(formationInput.Trim());
            return AssetDatabase.LoadAssetAtPath<GameObject>(path) != null;
        }

        /// <summary>获取当前在 Stage 预制体模式中唯一选中的五位数点位。</summary>
        private static bool TryGetSelectedPoint(out int stageId, out string pointId, out string error)
        {
            stageId = 0;
            pointId = string.Empty;
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            if (!TryGetStageContext(stage, out stageId, out error))
                return false;
            if (Selection.gameObjects.Length != 1)
            {
                error = "必须且只能选择一个点位；当前选择数量为 " + Selection.gameObjects.Length + "。";
                return false;
            }
            GameObject selected = Selection.activeGameObject;
            if (selected == null || !IsInsidePrefabStage(selected, stage) || !IsFiveDigitPointName(selected.name))
            {
                error = "请选择当前 Stage 预制体内名称为五位数字的单个点位。";
                return false;
            }
            if (stage.prefabContentsRoot.GetComponentsInChildren<Transform>(true)
                .Count(node => node.name == selected.name) != 1)
            { error = "当前 Prefab 存在同名点位，无法确定唯一目标。"; return false; }
            pointId = selected.name;
            error = string.Empty;
            return true;
        }

        /// <summary>应用修改前要求“当前选中点位”与“当前修改点位”一致。</summary>
        private bool IsSelectedPointMatchingDraft()
        {
            int stageId;
            string pointId;
            string error;
            return TryGetSelectedPoint(out stageId, out pointId, out error) && MatchesLoadedPoint(stageId, pointId);
        }

        private bool MatchesLoadedPoint(int stageId, string pointId)
        {
            return hasLoadedPoint
                && Selection.activeGameObject != null
                && Selection.activeGameObject.GetInstanceID() == loadedPointInstanceId
                && StageToolsIO.SameDirectory(excelDirectory, loadedExcelDirectory)
                && string.Equals(GetCurrentStagePath(), loadedPrefabPath, StringComparison.Ordinal)
                && stageId == loadedStageId
                && !string.IsNullOrEmpty(pointId)
                && string.Equals(pointId, loadedPointId, StringComparison.Ordinal);
        }

        private string BuildPointMismatchMessage()
        {
            int stageId;
            string pointId;
            string error;
            if (!TryGetSelectedPoint(out stageId, out pointId, out error))
            {
                return "应用修改已拒绝：当前没有有效选中的点位。\n" + error
                    + "\n\n请先在 Stage 预制体模式中选中当前修改点位（Stage " + loadedStageId + " / " + loadedPointId + "）后再应用。";
            }

            return "应用修改已拒绝：当前选中点位与当前修改点位不一致。\n\n"
                + "当前选中点位：Stage " + stageId + " / " + pointId + "\n"
                + "当前修改点位：Stage " + loadedStageId + " / " + loadedPointId + "\n\n"
                + "请重新选中当前修改点位，或从预览窗口重新创建草稿后再应用。";
        }

        private string BuildImpactSummary()
        {
            if (loadedReferences == null || loadedReferences.Length <= 1)
                return "当前组合未发现其他 MonsterSpawns 引用。";
            string[] references = loadedReferences
                .Select(reference => "Stage " + reference.stageId + " / Spawn " + reference.spawnId)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToArray();
            return "注意：该 MonsterFormation 组合还被 " + references.Length + " 条配置引用：" +
                string.Join(", ", references) + "。修改后这些引用都会使用新配置。";
        }

        private async Task<ExcelWriteResponse> RunExcelWrite(ExcelWriteRequest request)
        {
            string root = Path.GetFullPath(Path.Combine(Application.dataPath, ".."));
            string script = Path.Combine(root, ExcelWriteScriptRelativePath);
            if (!File.Exists(script))
                throw new FileNotFoundException("安全写表脚本不存在", script);

            string tempDirectory = Path.Combine(root, "Library", "Locus", "tmp", "monster-point-edit");
            Directory.CreateDirectory(tempDirectory);
            string requestPath = Path.Combine(tempDirectory, "write-request-" + Guid.NewGuid().ToString("N") + ".json");
            string outputPath = Path.Combine(tempDirectory, "write-result-" + Guid.NewGuid().ToString("N") + ".json");
            File.WriteAllText(requestPath, JsonUtility.ToJson(request, true), System.Text.Encoding.UTF8);
            try
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = ResolvePowerShellExecutable(),
                    Arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + script + "\" -RequestPath \"" + requestPath + "\" -OutputPath \"" + outputPath + "\" -ExpectedSourceHash \"" + request.sourceHash + "\"",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    StandardOutputEncoding = System.Text.Encoding.UTF8,
                    StandardErrorEncoding = System.Text.Encoding.UTF8,
                };
                {
                    StageToolsIO.ProcessResult process = await StageToolsIO.RunAsync(startInfo);
                    string stdout = process.Output;
                    string stderr = process.Error;
                    if (!File.Exists(outputPath))
                        throw new InvalidOperationException(string.IsNullOrWhiteSpace(stderr) ? stdout : stderr);
                    ExcelWriteResponse result = JsonUtility.FromJson<ExcelWriteResponse>(File.ReadAllText(outputPath, System.Text.Encoding.UTF8));
                    if (result == null)
                        throw new InvalidOperationException("安全写表程序返回结果无法解析。" + stderr);
                    if (process.ExitCode != 0 && string.IsNullOrEmpty(result.error))
                        result.error = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    return result;
                }
            }
            finally
            {
                if (File.Exists(requestPath)) File.Delete(requestPath);
                if (File.Exists(outputPath)) File.Delete(outputPath);
            }
        }

        private static string ResolvePowerShellExecutable()
        {
            // 优先 PowerShell 7：已验证兼容，且启动与执行明显快于 Windows PowerShell 5.1。
            string pwsh = FindOnPath("pwsh.exe");
            if (string.IsNullOrEmpty(pwsh))
            {
                string programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
                string installed = Path.Combine(programFiles, "PowerShell", "7", "pwsh.exe");
                if (File.Exists(installed))
                    pwsh = installed;
            }
            if (!string.IsNullOrEmpty(pwsh))
                return pwsh;

            string systemDirectory = Environment.GetFolderPath(Environment.SpecialFolder.System);
            string windowsPowerShell = Path.Combine(systemDirectory, "WindowsPowerShell", "v1.0", "powershell.exe");
            if (File.Exists(windowsPowerShell))
                return windowsPowerShell;
            return "powershell.exe";
        }

        private static string FindOnPath(string fileName)
        {
            string path = Environment.GetEnvironmentVariable("PATH");
            if (string.IsNullOrEmpty(path))
                return string.Empty;
            foreach (string segment in path.Split(Path.PathSeparator))
            {
                if (string.IsNullOrWhiteSpace(segment))
                    continue;
                string candidate;
                try
                {
                    candidate = Path.Combine(segment.Trim().Trim('"'), fileName);
                }
                catch (ArgumentException)
                {
                    continue;
                }
                if (File.Exists(candidate))
                    return candidate;
            }
            return string.Empty;
        }

        private async Task<QueryResponse> RunQuery(int stageId, string pointId)
        {
            ValidateExcelFiles();
            string root = Path.GetFullPath(Path.Combine(Application.dataPath, ".."));
            string executable = Path.Combine(root, QueryExecutableRelativePath);
            string script = Path.Combine(root, QueryScriptRelativePath);
            bool useExecutable = File.Exists(executable);
            if (!useExecutable && !File.Exists(script))
                throw new FileNotFoundException("查询程序不存在", executable);

            string tempDirectory = Path.Combine(root, "Library", "Locus", "tmp", "monster-point-edit");
            Directory.CreateDirectory(tempDirectory);
            string output = Path.Combine(tempDirectory, "query-" + Guid.NewGuid().ToString("N") + ".json");
            string queryArguments = "--excel-dir " + StageToolsIO.Quote(excelDirectory)
                + " --stage " + stageId + " --points " + StageToolsIO.Quote(pointId)
                + " --output " + StageToolsIO.Quote(output) + " --include-actors";

            var startInfo = new ProcessStartInfo
            {
                FileName = useExecutable ? executable : "python",
                Arguments = useExecutable ? queryArguments : "-X utf8 " + StageToolsIO.Quote(script) + " " + queryArguments,
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
                    if (!File.Exists(output))
                        throw new InvalidOperationException("查询程序未生成结果：" + (string.IsNullOrWhiteSpace(stderr) ? stdout : stderr));
                    QueryResponse result = JsonUtility.FromJson<QueryResponse>(File.ReadAllText(output, System.Text.Encoding.UTF8));
                    if (process.ExitCode != 0 && (result == null || string.IsNullOrEmpty(result.error)))
                        throw new InvalidOperationException(stderr);
                    return result;
                }
            }
            catch (Win32Exception exception)
            {
                throw new InvalidOperationException(useExecutable ? "无法启动查询 EXE。" : "无法启动 Python 回退命令。", exception);
            }
            finally
            {
                if (File.Exists(output))
                    File.Delete(output);
            }
        }

        private void ValidateExcelFiles()
        {
            if (!Directory.Exists(excelDirectory))
                throw new DirectoryNotFoundException("Excel 目录不存在：" + excelDirectory);
            foreach (string name in new[] { "MonsterSpawnType.xls", "MonsterSpawns.xls", "MonsterFormation.xls", "Actor.xls" })
            {
                string path = Path.Combine(excelDirectory, name);
                if (!File.Exists(path))
                    throw new FileNotFoundException("缺少配置表", path);
            }
        }

        private void UpdateSelectionStatus()
        {
            PrefabStage stage = PrefabStageUtility.GetCurrentPrefabStage();
            int stageId;
            string error;
            if (!TryGetStageContext(stage, out stageId, out error))
            {
                statusMessage = error;
                statusType = MessageType.Warning;
                return;
            }
            if (Selection.gameObjects.Length != 1)
            {
                statusMessage = "必须且只能选择一个点位；当前选择数量为 " + Selection.gameObjects.Length + "。";
                statusType = MessageType.Warning;
                return;
            }
            GameObject selected = Selection.activeGameObject;
            if (selected == null || !IsInsidePrefabStage(selected, stage) || !IsFiveDigitPointName(selected.name))
            {
                statusMessage = "请选择当前 Stage Prefab 内名称为五位数字的单个点位。";
                statusType = MessageType.Warning;
                return;
            }
            if (hasLoadedPoint && (loadedStageId != stageId || loadedPointId != selected.name))
            {
                statusMessage = draftChanged
                    ? "已选择其他点位。当前未保存草稿仍属于 " + loadedPointId + "；请从预览窗口重新创建草稿。"
                    : "已选择点位 " + selected.name + "，请从预览窗口点击修改此点位创建草稿。";
                statusType = draftChanged ? MessageType.Warning : MessageType.Info;
            }
            else if (!hasLoadedPoint)
            {
                statusMessage = "已选择点位 " + selected.name + "，请从预览窗口点击修改此点位创建草稿。";
                statusType = MessageType.Info;
            }
        }

        private void RefreshFormationOptions()
        {
            string[] guids = AssetDatabase.FindAssets("t:Prefab", new[] { "Assets/GameAsset/Prefab/Stage/PointSpawn" });
            formationOptions = guids
                .Select(AssetDatabase.GUIDToAssetPath)
                .Select(Path.GetFileNameWithoutExtension)
                .Where(name => !string.IsNullOrEmpty(name))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
                .ToArray();
        }

        private List<ActorCandidate> GetFilteredActors(int subType, int attackType)
        {
            return actorCandidates
                .Where(actor => actor.subType == subType && actor.attackType == attackType)
                .OrderBy(actor => actor.actorId)
                .ToList();
        }

        private ActorCandidate FindActor(int actorId)
        {
            return actorCandidates.FirstOrDefault(actor => actor.actorId == actorId);
        }

        private void ApplyActorCandidate(MonsterDraft draft, ActorCandidate actor, bool setFilters)
        {
            if (actor == null)
                return;
            draft.actorId = actor.actorId;
            if (setFilters)
            {
                draft.subType = actor.subType;
                draft.attackType = actor.attackType;
            }
        }

        private void SelectFirstFilteredActor(MonsterDraft draft)
        {
            ActorCandidate first = GetFilteredActors(draft.subType, draft.attackType).FirstOrDefault();
            if (first != null)
                draft.actorId = first.actorId;
        }

        private MonsterDraft CreateDefaultMonsterDraft()
        {
            ActorCandidate first = actorCandidates.FirstOrDefault(actor => actor.subType == 1 && actor.attackType == 1)
                ?? actorCandidates.FirstOrDefault();
            return new MonsterDraft
            {
                actorId = first == null ? 0 : first.actorId,
                count = 1,
                subType = first == null ? 1 : first.subType,
                attackType = first == null ? 1 : first.attackType,
            };
        }

        private void ClearDraft(string message)
        {
            draftGeneration++;
            hasLoadedPoint = false;
            draftChanged = false;
            loadedStageId = loadedWaveIndex = loadedConfigId = loadedGroupId = loadedPointInstanceId = 0;
            loadedStagePath = loadedPrefabPath = loadedPointId = loadedExcelDirectory = string.Empty;
            loadedFormationRaw = loadedMonsterGroupRaw = loadedDescription = string.Empty;
            formationInput = descriptionInput = descriptionAutoPrefix = string.Empty;
            descriptionManuallyEdited = false;
            scrollPosition = Vector2.zero;
            loadedTableHashes = Array.Empty<string>();
            loadedReferences = Array.Empty<ReferenceData>();
            actorCandidates.Clear();
            monsterDrafts.Clear();
            DisposeSpinePreviews();
            statusMessage = message;
            statusType = MessageType.Info;
        }

        /// <summary>预览数据源切换时使旧草稿及正在读取的旧请求失效。</summary>
        internal static void InvalidateDraftsForSourceChange(string previousSource, string currentSource)
        {
            if (StageToolsIO.SameDirectory(previousSource, currentSource)) return;
            foreach (var window in Resources.FindObjectsOfTypeAll<MonsterPointEditWindow>())
            {
                if (!StageToolsIO.SameDirectory(window.excelDirectory, previousSource)) continue;
                window.ClearDraft("预览数据源已切换，请重新点击修改此点位。已确认的提交仍使用原目标。");
                window.Repaint();
            }
        }

        private void MarkDraftChanged()
        {
            draftChanged = true;
            DisposeSpinePreviews();
        }

        private void RefreshDescriptionFromDraft()
        {
            if (descriptionManuallyEdited)
                return;
            string prefix;
            if (!TryGetFormationDescriptionPrefix(formationInput, out prefix))
            {
                // 阵型命名不符合约定时，忽略自动文本匹配，恢复读取时的原始描述。
                descriptionAutoPrefix = string.Empty;
                descriptionInput = loadedDescription;
                return;
            }

            descriptionAutoPrefix = prefix;
            descriptionInput = prefix + "——" + string.Join("；", monsterDrafts.Select(BuildMonsterDescription));
        }

        private string BuildMonsterDescription(MonsterDraft draft)
        {
            ActorCandidate actor = FindActor(draft.actorId);
            string name = actor == null || string.IsNullOrEmpty(actor.actorName)
                ? draft.actorId.ToString()
                : actor.actorName;
            return name + "+" + draft.count;
        }

        private static bool TryGetFormationDescriptionPrefix(string formationName, out string descriptionPrefix)
        {
            descriptionPrefix = string.Empty;
            if (string.IsNullOrEmpty(formationName))
                return false;

            string normalized = formationName.Trim();
            int numberStart = 1;
            if (normalized.Length <= numberStart)
                return false;

            char code = char.ToUpperInvariant(normalized[0]);
            if (code != 'B' && code != 'F' && code != 'J')
                return false;
            for (int i = numberStart; i < normalized.Length; i++)
            {
                if (!char.IsDigit(normalized[i]))
                    return false;
            }

            descriptionPrefix = code == 'B' ? "包围" : code == 'F' ? "分散" : "聚集";
            return true;
        }

        private void DisposeSpinePreviews()
        {
            foreach (MonsterPointPreviewWindow.SpinePrefabPreview preview in spinePreviews.Values)
                preview?.Dispose();
            spinePreviews.Clear();
        }

        private static string GetSubTypeName(int value)
        {
            int index = Array.IndexOf(SubTypeValues, value);
            return index >= 0 ? SubTypeNames[index] : "未知";
        }

        private static string GetAttackTypeName(int value)
        {
            int index = Array.IndexOf(AttackTypeValues, value);
            return index >= 0 ? AttackTypeNames[index] : "未知";
        }

        private static bool TryGetStageContext(PrefabStage stage, out int stageId, out string error)
        {
            stageId = 0;
            if (stage == null || stage.prefabContentsRoot == null)
            {
                error = "请先打开 Stage_XX 关卡预制体进入 Prefab Mode。";
                return false;
            }
            string name = Path.GetFileNameWithoutExtension(stage.assetPath);
            if (!name.StartsWith("Stage_", StringComparison.OrdinalIgnoreCase))
            {
                error = "当前 Prefab 不是 Stage_XX 关卡预制体。";
                return false;
            }
            string suffix = name.Substring("Stage_".Length);
            int separator = suffix.IndexOf('_');
            if (separator >= 0)
                suffix = suffix.Substring(0, separator);
            if (!int.TryParse(suffix, out stageId))
            {
                error = "无法从 Prefab 名称解析关卡 ID。";
                return false;
            }
            error = string.Empty;
            return true;
        }

        private static bool IsInsidePrefabStage(GameObject gameObject, PrefabStage stage)
        {
            return gameObject != null && stage != null && stage.prefabContentsRoot != null
                && gameObject.scene == stage.scene && gameObject.transform.IsChildOf(stage.prefabContentsRoot.transform);
        }

        private static bool IsFiveDigitPointName(string value)
        {
            return !string.IsNullOrEmpty(value) && value.Length == 5 && value.All(c => c >= '0' && c <= '9');
        }

        private enum InputMode
        {
            Direct,
            Dropdown,
        }

        [Serializable]
        private sealed class ExcelWriteRequest
        {
            public string excelPath;
            public int configId;
            public int groupId;
            public string expectedFormation;
            public string expectedMonsterGroup;
            public string expectedDescription;
            public string newFormation;
            public string newMonsterGroup;
            public string newDescription;
            public string sourceHash;
            public string[] tableHashes;
        }

        [Serializable]
        private sealed class ExcelWriteResponse
        {
            public bool success;
            public string error;
            public string backupPath;
            public int rowNumber;
            public string oldFormation;
            public string oldMonsterGroup;
            public string oldDescription;
            public string newFormation;
            public string newMonsterGroup;
            public string newDescription;
        }

        [Serializable]
        private sealed class QueryResponse
        {
            public bool success;
            public string error;
            public PointQueryData[] items;
            public ActorCandidate[] actorCandidates;
        }

        [Serializable]
        private sealed class PointQueryData
        {
            public int stageId;
            public string pointId;
            public bool success;
            public string error;
            public SpawnRowData[] spawnRows;
        }

        [Serializable]
        private sealed class SpawnRowData
        {
            public int waveIndex;
            public FormationData[] formationVariants;
        }

        [Serializable]
        private sealed class FormationData
        {
            public int configId;
            public int groupId;
            public string formationPrefab;
            public string monsterGroupRaw;
            public string description;
            public MonsterData[] monsters;
            public ReferenceData[] references;
        }

        [Serializable]
        private sealed class ReferenceData
        {
            public int stageId;
            public int spawnId;
            public int waveIndex;
            public string pointGroupRaw;
            public string formationRaw;
        }

        [Serializable]
        private sealed class MonsterData
        {
            public int actorId;
            public int count;
        }

        [Serializable]
        private sealed class ActorCandidate
        {
            public int actorId;
            public string actorName;
            public string modelResource;
            public int subType;
            public int attackType;
        }

        private sealed class MonsterDraft
        {
            public int actorId;
            public int count;
            public int subType = 1;
            public int attackType = 1;
        }
    }
}
