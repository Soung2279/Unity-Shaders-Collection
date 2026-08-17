using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace Game.Editor.VFXTools.Automation.VFXtoExcelAutoFilled
{
/// <summary>
/// VFX 特效配置全表预览窗口。
/// 从缓存 JSON 加载全量数据，支持实时搜索（ID精确 / 名称·备注·资源路径包含），
/// 点击「选择」将整行数据填回主工具窗口并关闭本窗口。
/// </summary>
public class VFXTablePreviewWindow : EditorWindow
{
    private string cachePath = "";
    private string excelPath = "";
    private string scriptPath = "";
    private Action<LootBootVFXtoExcel.VFXRowData> fillCallback;
    private int highlightId = -1;
    private bool hitOnlyMode;

    private readonly List<LootBootVFXtoExcel.VFXRowData> allRows = new List<LootBootVFXtoExcel.VFXRowData>();
    private readonly List<LootBootVFXtoExcel.VFXRowData> filteredRows = new List<LootBootVFXtoExcel.VFXRowData>();
    private readonly Dictionary<string, LootBootVFXtoExcel.VFXRowData> originalRowsByIndex = new Dictionary<string, LootBootVFXtoExcel.VFXRowData>();
    private readonly HashSet<string> modifiedCellKeys = new HashSet<string>();

    private string searchInput = "";
    private Vector2 scrollPos;
    private bool needScrollToHighlight;
    private string refreshStatus = "";

    private GUIStyle cellStyle;
    private GUIStyle richCellStyle;
    private GUIStyle headerStyle;
    private GUIStyle highlightRowStyle;
    private GUIStyle selectedRowStyle;
    private GUIStyle normalRowStyle;
    private GUIStyle altRowStyle;

    private Texture2D iconSpine;
    private Texture2D iconParticle;
    private Texture2D iconPrefab;

    private int selectedRowIndex = -1;
    private bool isEditMode;
    private bool pendingEnterEditMode;
    private string activeEditRowIndex = "";
    private int activeEditCol = -1;
    private string editBuffer = "";
    private bool focusTextEdit;
    private string activeSelectableNameRowIndex = "";

    private const float ROW_HEIGHT = 20f;
    private const float MIN_COL_WIDTH = 30f;
    private static readonly Color MODIFIED_CELL_COLOR = new Color(1f, 0.72f, 0.25f, 0.65f);

    private float[] colWidths = { 50f, 200f, 65f, 300f, 55f, 55f, 55f, 55f, 60f, 70f, 300f, 80f };

    private int resizingCol = -1;
    private float resizeStartX;
    private float resizeStartWidth;

    private static readonly string[] COL_NAMES =
        { "ID", "名称", "类型", "资源路径", "范围", "缩放", "挂接点", "旋转规则", "音效ID", "受击特效", "备注", "操作" };

    private static readonly string[] COL_TOOLTIPS =
    {
        "Excel 中的特效配置唯一 ID。",
        "特效配置名称。",
        "特效类型：Spine / 粒子 / 复合。",
        "相对 Assets/GameAsset/Effect/ 的资源路径，不包含 .prefab 后缀。",
        "特效影响半径 × 100 的整数值。",
        "特效播放缩放百分比 × 100 的整数值。",
        "特效挂接点：原点 / 中心 / 头部。",
        "旋转规则：不旋转 / 旋转 / 旋转翻转。",
        "绑定播放的音效配置 ID。",
        "是否为受击特效：0 = 非受击特效，1 = 受击特效。",
        "Excel 中的备注说明。",
        "选择填回主窗口，或定位资源。"
    };

    private static readonly string[] VFX_TYPE_LABELS = { "Spine", "粒子", "复合" };
    private static readonly string[] ATTACH_LABELS = { "原点", "中心", "头部" };
    private static readonly string[] ROTATION_LABELS = { "不旋转", "旋转", "旋转翻转" };
    private static readonly string[] IS_HIT_LABELS = { "否", "是" };

    private static readonly Color[] VFX_TYPE_COLORS = {
        new Color(0.75f, 0.50f, 1.00f),
        new Color(0.30f, 0.90f, 1.00f),
        new Color(1.00f, 0.80f, 0.25f),
    };
    private static readonly Color[] ATTACH_COLORS = {
        new Color(0.80f, 0.80f, 0.80f),
        new Color(0.35f, 1.00f, 0.50f),
        new Color(1.00f, 0.65f, 0.25f),
    };
    private static readonly Color[] ROTATION_COLORS = {
        new Color(0.80f, 0.80f, 0.80f),
        new Color(0.35f, 0.90f, 1.00f),
        new Color(1.00f, 0.50f, 0.85f),
    };
    private static readonly Color[] IS_HIT_COLORS = {
        new Color(0.75f, 0.75f, 0.75f),
        new Color(1.00f, 0.45f, 0.35f),
    };

    [Serializable]
    private class VFXRowDataWrapper
    {
        public LootBootVFXtoExcel.VFXRowData[] items;
    }

    internal static void Open(
        string cachePath,
        string excelPath,
        string scriptPath,
        Action<LootBootVFXtoExcel.VFXRowData> fillCallback,
        int highlightId = -1,
        bool hitOnlyMode = false)
    {
        string title = hitOnlyMode ? "VFX 受击检查" : "VFX 全表预览";
        var window = GetWindow<VFXTablePreviewWindow>(title);
        window.titleContent = new GUIContent(title);
        window.cachePath = cachePath;
        window.excelPath = excelPath;
        window.scriptPath = scriptPath;
        window.fillCallback = fillCallback;
        window.highlightId = highlightId;
        window.hitOnlyMode = hitOnlyMode;
        window.searchInput = "";
        window.minSize = new Vector2(990f, 480f);
        window.LoadCache();
        window.needScrollToHighlight = highlightId >= 0;
        window.Show();
        window.Focus();
    }

    private void LoadCache()
    {
        string selectedRowKey = GetSelectedRowKey();
        allRows.Clear();
        filteredRows.Clear();
        selectedRowIndex = -1;
        activeEditRowIndex = "";
        activeEditCol = -1;
        editBuffer = "";
        focusTextEdit = false;
        activeSelectableNameRowIndex = "";
        modifiedCellKeys.Clear();
        originalRowsByIndex.Clear();
        isEditMode = false;

        if (!File.Exists(cachePath))
        {
            Repaint();
            return;
        }

        try
        {
            string json = File.ReadAllText(cachePath, Encoding.UTF8);
            var wrapper = JsonUtility.FromJson<VFXRowDataWrapper>("{\"items\":" + json + "}");
            if (wrapper?.items != null)
            {
                for (int i = 0; i < wrapper.items.Length; i++)
                {
                    var row = wrapper.items[i];
                    if (row == null)
                        continue;
                    if (string.IsNullOrEmpty(row.rowIndex))
                        row.rowIndex = (5 + i).ToString();
                    allRows.Add(row);
                    originalRowsByIndex[row.rowIndex] = CloneRow(row);
                }
            }
        }
        catch (Exception e)
        {
            UnityEngine.Debug.LogWarning($"[VFXTablePreview] 缓存读取失败：{e.Message}");
        }

        ApplyFilter(selectedRowKey);

        if (pendingEnterEditMode)
        {
            pendingEnterEditMode = false;
            isEditMode = true;
            if (selectedRowIndex < 0 && filteredRows.Count > 0)
                selectedRowIndex = 0;
            EnsureSelectedRowVisible();
        }
    }

    private void ApplyFilter(string keepRowIndex = null)
    {
        filteredRows.Clear();
        string kw = searchInput.Trim().ToLowerInvariant();

        if (string.IsNullOrEmpty(kw))
        {
            foreach (var row in allRows)
            {
                if (!hitOnlyMode || row.isHit == "1")
                    filteredRows.Add(row);
            }
        }
        else
        {
            bool isInt = int.TryParse(kw, out int intKw);
            foreach (var row in allRows)
            {
                if (hitOnlyMode && row.isHit != "1")
                    continue;

                if (isInt && row.id == intKw.ToString())
                {
                    filteredRows.Add(row);
                    continue;
                }

                if ((row.name ?? "").ToLowerInvariant().Contains(kw) ||
                    (row.remark ?? "").ToLowerInvariant().Contains(kw) ||
                    (row.resource ?? "").ToLowerInvariant().Contains(kw))
                    filteredRows.Add(row);
            }
        }

        if (!string.IsNullOrEmpty(keepRowIndex))
            selectedRowIndex = FindFilteredIndexByRowIndex(keepRowIndex);
        else if (selectedRowIndex >= filteredRows.Count)
            selectedRowIndex = filteredRows.Count > 0 ? filteredRows.Count - 1 : -1;

        if (IsTextEditActive() && FindFilteredIndexByRowIndex(activeEditRowIndex) < 0)
            CancelCurrentTextEdit();
    }

    private void InitStyles()
    {
        if (cellStyle != null) return;

        cellStyle = new GUIStyle(EditorStyles.label)
        {
            clipping = TextClipping.Clip,
            alignment = TextAnchor.MiddleLeft,
            padding = new RectOffset(3, 3, 0, 0),
        };

        richCellStyle = new GUIStyle(cellStyle) { richText = true };
        headerStyle = new GUIStyle(cellStyle) { fontStyle = FontStyle.Bold };
        headerStyle.normal.textColor = EditorGUIUtility.isProSkin
            ? new Color(0.90f, 0.90f, 0.90f)
            : new Color(0.10f, 0.10f, 0.10f);

        normalRowStyle = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.22f, 0.22f, 0.22f) : new Color(0.84f, 0.84f, 0.84f));
        altRowStyle = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.26f, 0.26f, 0.26f) : new Color(0.91f, 0.91f, 0.91f));
        highlightRowStyle = MakeRowStyle(new Color(0.85f, 0.50f, 0.08f, 0.90f));
        selectedRowStyle = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.18f, 0.38f, 0.72f, 0.95f)
            : new Color(0.30f, 0.55f, 0.95f, 0.80f));

        iconParticle = EditorGUIUtility.IconContent("ParticleSystem Icon").image as Texture2D;
        iconSpine = EditorGUIUtility.IconContent("Animator Icon").image as Texture2D;
        iconPrefab = EditorGUIUtility.IconContent("Prefab Icon").image as Texture2D;
    }

    private static GUIStyle MakeRowStyle(Color color)
    {
        var tex = new Texture2D(1, 1) { hideFlags = HideFlags.DontSave };
        tex.SetPixel(0, 0, color);
        tex.Apply();
        var style = new GUIStyle(GUIStyle.none);
        style.normal.background = tex;
        return style;
    }

    private void OnGUI()
    {
        InitStyles();
        HandleKeyboard();

        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            GUILayout.Label("搜索（ID / 名称 / 备注 / 资源路径）", GUILayout.Width(220f));

            string newSearch = EditorGUILayout.TextField(searchInput, EditorStyles.toolbarSearchField);
            if (newSearch != searchInput)
            {
                if (isEditMode)
                    CommitCurrentTextEdit();
                searchInput = newSearch;
                ApplyFilter(GetSelectedRowKey());
                needScrollToHighlight = false;
                Repaint();
            }

            GUILayout.Label(hitOnlyMode
                ? $"受击特效 {filteredRows.Count} / 全部 {allRows.Count} 条"
                : $"{filteredRows.Count} / {allRows.Count} 条", GUILayout.Width(hitOnlyMode ? 150f : 80f));

            if (!string.IsNullOrEmpty(refreshStatus))
            {
                var statusStyle = new GUIStyle(EditorStyles.miniLabel);
                statusStyle.normal.textColor = refreshStatus.StartsWith("✔")
                    ? new Color(0.2f, 0.85f, 0.2f) : new Color(1f, 0.4f, 0.4f);
                GUILayout.Label(refreshStatus, statusStyle);
            }

            GUILayout.FlexibleSpace();

            if (isEditMode)
            {
                Color savedBg = GUI.backgroundColor;
                GUI.backgroundColor = new Color(0.35f, 0.85f, 0.35f);
                using (new EditorGUI.DisabledScope(!HasModifiedChanges()))
                {
                    if (GUILayout.Button("保存修改", EditorStyles.toolbarButton, GUILayout.Width(72f)))
                        SaveEditedRows();
                }

                GUI.backgroundColor = new Color(0.95f, 0.55f, 0.25f);
                if (GUILayout.Button("退出编辑模式", EditorStyles.toolbarButton, GUILayout.Width(88f)))
                    ExitEditMode();
                GUI.backgroundColor = savedBg;
            }
            else
            {
                using (new EditorGUI.DisabledScope(selectedRowIndex < 0 || selectedRowIndex >= filteredRows.Count))
                {
                    if (GUILayout.Button("查看详情", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                        OpenSelectedRowDetail();
                }

                if (GUILayout.Button("编辑模式", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                {
                    pendingEnterEditMode = true;
                    EditorApplication.delayCall += RefreshCacheAndReload;
                    GUIUtility.ExitGUI();
                }

                Color savedBg = GUI.backgroundColor;
                GUI.backgroundColor = new Color(0.35f, 0.75f, 1f);
                if (GUILayout.Button("刷新缓存", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                {
                    EditorApplication.delayCall += RefreshCacheAndReload;
                    GUIUtility.ExitGUI();
                }
                GUI.backgroundColor = savedBg;
            }
        }

        DrawHeader();

        if (needScrollToHighlight && Event.current.type == EventType.Repaint)
        {
            int idx = filteredRows.FindIndex(r => r.id == highlightId.ToString());
            if (idx >= 0)
                scrollPos.y = Mathf.Max(0f, idx * ROW_HEIGHT - position.height * 0.38f);
            needScrollToHighlight = false;
            Repaint();
        }

        Vector2 previousScrollPos = scrollPos;
        scrollPos = GUILayout.BeginScrollView(scrollPos);
        if (activeSelectableNameRowIndex.Length > 0 && !Approximately(previousScrollPos, scrollPos))
            ClearActiveNameSelection(false);

        if (allRows.Count == 0)
        {
            EditorGUILayout.HelpBox(
                File.Exists(cachePath)
                    ? "缓存文件为空，请确认 Excel 中存在数据行，然后点击「刷新缓存」。"
                    : "缓存文件尚未生成，请点击「刷新缓存」从 Excel 导出数据。",
                MessageType.Warning);
        }
        else if (filteredRows.Count == 0)
        {
            EditorGUILayout.HelpBox("没有与当前搜索条件匹配的记录。", MessageType.Info);
        }
        else
        {
            int rowCount = filteredRows.Count;
            float totalTableWidth = GetTotalTableWidth();
            float totalRowsHeight = rowCount * ROW_HEIGHT;
            Rect contentRect = GUILayoutUtility.GetRect(
                totalTableWidth, totalTableWidth, totalRowsHeight, totalRowsHeight);

            float viewportH = Mathf.Max(100f, position.height - 22f - ROW_HEIGHT);
            int firstVisible = Mathf.Max(0, Mathf.FloorToInt(scrollPos.y / ROW_HEIGHT));
            int lastVisible = Mathf.Min(rowCount - 1,
                firstVisible + Mathf.CeilToInt(viewportH / ROW_HEIGHT) + 2);

            for (int i = firstVisible; i <= lastVisible; i++)
            {
                var rowRect = new Rect(contentRect.x, contentRect.y + i * ROW_HEIGHT,
                    totalTableWidth, ROW_HEIGHT);
                DrawRow(filteredRows[i], i, rowRect);
            }
        }

        GUILayout.EndScrollView();
    }

    private void DrawHeader()
    {
        Rect rect = EditorGUILayout.GetControlRect(GUILayout.Height(ROW_HEIGHT));
        EditorGUI.DrawRect(rect, EditorGUIUtility.isProSkin
            ? new Color(0.16f, 0.16f, 0.16f)
            : new Color(0.68f, 0.68f, 0.68f));

        float x = rect.x - scrollPos.x;
        for (int c = 0; c < COL_NAMES.Length; c++)
        {
            Rect headerRect = new Rect(x, rect.y, colWidths[c], ROW_HEIGHT);
            EditorGUI.LabelField(headerRect, new GUIContent(COL_NAMES[c], COL_TOOLTIPS[c]), headerStyle);
            x += colWidths[c];

            if (c == COL_NAMES.Length - 1) continue;

            EditorGUI.DrawRect(
                new Rect(x - 0.5f, rect.y + 2f, 1f, ROW_HEIGHT - 4f),
                EditorGUIUtility.isProSkin ? new Color(0.4f, 0.4f, 0.4f) : new Color(0.5f, 0.5f, 0.5f));

            if (!isEditMode)
                HandleColumnResize(new Rect(x - 3.5f, rect.y, 7f, ROW_HEIGHT), c);
        }
    }

    private float GetTotalTableWidth()
    {
        float total = 0f;
        for (int i = 0; i < colWidths.Length; i++)
            total += colWidths[i];
        return total;
    }

    private void DrawRow(LootBootVFXtoExcel.VFXRowData row, int filteredIndex, Rect rowRect)
    {
        bool isHighlight = highlightId >= 0 && row.id == highlightId.ToString();
        bool isSelected = selectedRowIndex == filteredIndex;

        GUIStyle rowStyle = isHighlight ? highlightRowStyle
            : isSelected ? selectedRowStyle
            : (filteredIndex % 2 == 0 ? normalRowStyle : altRowStyle);

        GUI.Box(rowRect, GUIContent.none, rowStyle);
        if (IsRowModified(row.rowIndex))
            EditorGUI.DrawRect(new Rect(rowRect.x, rowRect.y + 1f, rowRect.width, rowRect.height - 2f),
                new Color(1f, 0.68f, 0.12f, 0.18f));

        if (!isEditMode)
            HandlePreviewRowClick(row, filteredIndex, rowRect);

        float x = rowRect.x;
        for (int col = 0; col <= 10; col++)
            DrawCell(row, filteredIndex, col, ref x, rowRect.y);
        DrawOperationCell(row, filteredIndex, new Rect(x, rowRect.y, colWidths[11], ROW_HEIGHT));
    }

    private void DrawCell(LootBootVFXtoExcel.VFXRowData row, int filteredIndex, int col, ref float x, float y)
    {
        Rect rect = new Rect(x, y, colWidths[col], ROW_HEIGHT);
        x += colWidths[col];

        if (isEditMode)
        {
            if (IsEnumColumn(col))
                DrawEditablePopupCell(rect, row, filteredIndex, col);
            else
                DrawEditableTextCell(rect, row, filteredIndex, col);
            return;
        }

        switch (col)
        {
            case 0:
                DrawTextCell(rect, row.id);
                break;
            case 1:
                DrawNameCell(rect, row, filteredIndex);
                break;
            case 2:
                DrawTypeCell(rect, row.vfxType);
                break;
            case 3:
                DrawTextCell(rect, row.resource);
                break;
            case 4:
                EditorGUI.LabelField(rect, row.rangeSize, cellStyle);
                break;
            case 5:
                EditorGUI.LabelField(rect, row.scaleFactor, cellStyle);
                break;
            case 6:
                DrawColoredCell(rect, row.attachPoint, ATTACH_LABELS, ATTACH_COLORS);
                break;
            case 7:
                DrawColoredCell(rect, row.rotationRule, ROTATION_LABELS, ROTATION_COLORS);
                break;
            case 8:
                EditorGUI.LabelField(rect, row.soundId, cellStyle);
                break;
            case 9:
                DrawColoredCell(rect, row.isHit, IS_HIT_LABELS, IS_HIT_COLORS);
                break;
            case 10:
                DrawTextCell(rect, row.remark);
                break;
        }
    }

    private void DrawOperationCell(LootBootVFXtoExcel.VFXRowData row, int filteredIndex, Rect rect)
    {
        Color saved = GUI.backgroundColor;

        if (isEditMode)
        {
            GUI.backgroundColor = new Color(0.35f, 0.70f, 1f);
            if (GUI.Button(new Rect(rect.x + 1f, rect.y + 1f, rect.width - 2f, rect.height - 2f), "定位"))
            {
                selectedRowIndex = filteredIndex;
                PingResource(row.resource);
                Repaint();
            }
            GUI.backgroundColor = saved;
            return;
        }

        float opW = (rect.width - 6f) * 0.5f;
        GUI.backgroundColor = highlightId >= 0 && row.id == highlightId.ToString()
            ? new Color(1f, 0.65f, 0.1f)
            : new Color(0.35f, 0.85f, 0.35f);
        if (GUI.Button(new Rect(rect.x + 1f, rect.y + 1f, opW, rect.height - 2f), "选择"))
        {
            selectedRowIndex = filteredIndex;
            fillCallback?.Invoke(row);
            Repaint();
        }

        GUI.backgroundColor = new Color(0.35f, 0.70f, 1f);
        if (GUI.Button(new Rect(rect.x + opW + 5f, rect.y + 1f, opW, rect.height - 2f), "定位"))
            PingResource(row.resource);

        GUI.backgroundColor = saved;
    }

    private void HandlePreviewRowClick(LootBootVFXtoExcel.VFXRowData row, int filteredIndex, Rect rowRect)
    {
        float opColStartX = rowRect.x;
        for (int ci = 0; ci < colWidths.Length - 1; ci++)
            opColStartX += colWidths[ci];
        var nameColRect = new Rect(rowRect.x + colWidths[0], rowRect.y, colWidths[1], ROW_HEIGHT);
        if (Event.current.type == EventType.MouseDown && Event.current.button == 0
            && new Rect(rowRect.x, rowRect.y, opColStartX - rowRect.x, ROW_HEIGHT).Contains(Event.current.mousePosition)
            && !nameColRect.Contains(Event.current.mousePosition))
        {
            if (Event.current.clickCount == 2)
                PingResource(row.resource);
            else
                selectedRowIndex = selectedRowIndex == filteredIndex ? -1 : filteredIndex;
            ClearActiveNameSelection(false);
            Event.current.Use();
            Repaint();
        }
    }

    private void DrawEditableTextCell(Rect rect, LootBootVFXtoExcel.VFXRowData row, int filteredIndex, int col)
    {
        HandleEditCellMouseDown(rect, row, filteredIndex, col, true);
        bool modified = IsCellModified(row.rowIndex, col);
        if (modified)
            DrawModifiedCellBackground(rect);

        if (IsEditingCell(row.rowIndex, col))
        {
            string controlName = GetEditControlName(row.rowIndex, col);
            GUI.SetNextControlName(controlName);
            string newValue = EditorGUI.TextField(rect, editBuffer ?? "");
            if (newValue != editBuffer)
                editBuffer = newValue;
            if (focusTextEdit && Event.current.type == EventType.Repaint)
            {
                EditorGUI.FocusTextInControl(controlName);
                focusTextEdit = false;
            }
            if (modified)
                DrawModifiedCellMarker(rect);
            return;
        }

        DrawTextCell(rect, GetCellValue(row, col));
        if (modified)
            DrawModifiedCellMarker(rect);
    }

    private void DrawEditablePopupCell(Rect rect, LootBootVFXtoExcel.VFXRowData row, int filteredIndex, int col)
    {
        HandleEditCellMouseDown(rect, row, filteredIndex, col, false);
        bool modified = IsCellModified(row.rowIndex, col);
        if (modified)
            DrawModifiedCellBackground(rect);

        string[] labels = col == 2 ? VFX_TYPE_LABELS
            : col == 6 ? ATTACH_LABELS
            : col == 7 ? ROTATION_LABELS
            : IS_HIT_LABELS;
        Color[] colors = col == 2 ? VFX_TYPE_COLORS
            : col == 6 ? ATTACH_COLORS
            : col == 7 ? ROTATION_COLORS
            : IS_HIT_COLORS;
        string currentValue = GetCellValue(row, col) ?? "";
        bool validCurrent = int.TryParse(currentValue, out int parsed) && parsed >= 0 && parsed < labels.Length;
        string[] popupLabels = validCurrent ? labels : BuildPopupLabelsWithCurrent(currentValue, labels);
        int currentIndex = validCurrent ? parsed : 0;

        EditorGUI.BeginChangeCheck();
        int newIndex = EditorGUI.Popup(rect, currentIndex, popupLabels);
        if (EditorGUI.EndChangeCheck())
        {
            if (validCurrent)
                SetCellValue(row, col, newIndex.ToString());
            else if (newIndex > 0)
                SetCellValue(row, col, (newIndex - 1).ToString());
            UpdateCellModifiedState(row, col);
            Repaint();
        }

        DrawEnumColorStrip(rect, currentValue, colors);
        if (modified)
            DrawModifiedCellMarker(rect);
    }

    private void HandleEditCellMouseDown(Rect rect, LootBootVFXtoExcel.VFXRowData row, int filteredIndex, int col, bool beginTextEditOnDoubleClick)
    {
        if (Event.current.type != EventType.MouseDown || Event.current.button != 0 || !rect.Contains(Event.current.mousePosition))
            return;

        if (IsTextEditActive() && !IsEditingCell(row.rowIndex, col))
            CommitCurrentTextEdit();

        selectedRowIndex = filteredIndex;
        EnsureSelectedRowVisible();

        if (beginTextEditOnDoubleClick && Event.current.clickCount >= 2)
        {
            BeginTextEdit(row, col);
            Event.current.Use();
        }
        else
        {
            Repaint();
        }
    }

    private void BeginTextEdit(LootBootVFXtoExcel.VFXRowData row, int col)
    {
        activeEditRowIndex = row.rowIndex;
        activeEditCol = col;
        editBuffer = GetCellValue(row, col) ?? "";
        focusTextEdit = true;
        Repaint();
    }

    private void CommitCurrentTextEdit()
    {
        if (!IsTextEditActive())
            return;

        var row = FindAllRowByRowIndex(activeEditRowIndex);
        if (row != null)
        {
            SetCellValue(row, activeEditCol, editBuffer ?? "");
            UpdateCellModifiedState(row, activeEditCol);
            ApplyFilter(activeEditRowIndex);
        }

        activeEditRowIndex = "";
        activeEditCol = -1;
        editBuffer = "";
        focusTextEdit = false;
        Repaint();
    }

    private void CancelCurrentTextEdit()
    {
        activeEditRowIndex = "";
        activeEditCol = -1;
        editBuffer = "";
        focusTextEdit = false;
        Repaint();
    }

    private void HandleKeyboard()
    {
        if (Event.current.type != EventType.KeyDown)
            return;

        if (isEditMode && (Event.current.keyCode == KeyCode.Return || Event.current.keyCode == KeyCode.KeypadEnter))
        {
            if (IsTextEditActive())
            {
                CommitCurrentTextEdit();
                Event.current.Use();
            }
            return;
        }

        if (isEditMode && Event.current.keyCode == KeyCode.Escape)
        {
            if (IsTextEditActive())
            {
                CancelCurrentTextEdit();
                Event.current.Use();
            }
            return;
        }

        if (IsTextEditActive())
            return;

        if (Event.current.keyCode == KeyCode.UpArrow)
        {
            MoveSelection(-1);
            Event.current.Use();
        }
        else if (Event.current.keyCode == KeyCode.DownArrow)
        {
            MoveSelection(1);
            Event.current.Use();
        }
    }

    private void MoveSelection(int delta)
    {
        if (filteredRows.Count == 0)
            return;

        if (selectedRowIndex < 0)
            selectedRowIndex = 0;
        else
            selectedRowIndex = Mathf.Clamp(selectedRowIndex + delta, 0, filteredRows.Count - 1);

        EnsureSelectedRowVisible();
        Repaint();
    }

    private void EnsureSelectedRowVisible()
    {
        if (selectedRowIndex < 0 || selectedRowIndex >= filteredRows.Count)
            return;

        float viewportH = Mathf.Max(100f, position.height - 22f - ROW_HEIGHT);
        float top = selectedRowIndex * ROW_HEIGHT;
        float bottom = top + ROW_HEIGHT;
        if (scrollPos.y > top)
            scrollPos.y = top;
        else if (scrollPos.y + viewportH < bottom)
            scrollPos.y = Mathf.Max(0f, bottom - viewportH);
    }

    private bool SaveEditedRows()
    {
        CommitCurrentTextEdit();
        if (!HasModifiedChanges())
            return true;

        if (!ValidateEditedRows(out string validationError))
        {
            EditorUtility.DisplayDialog("无法保存", validationError, "确定");
            return false;
        }

        var dirtyRows = GetDirtyRows();
        if (dirtyRows.Count == 0)
            return true;

        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson, BuildBatchOverwriteJson(dirtyRows), new UTF8Encoding(false));
            var psi = BuildPsi(scriptPath, $"--overwrite-batch \"{excelPath}\" \"{tempJson}\"");
            using (var proc = Process.Start(psi))
            {
                if (proc == null)
                {
                    EditorUtility.DisplayDialog("保存失败", "启动 Python 进程失败（返回 null），请确认 Python 已正确安装。", "确定");
                    return false;
                }

                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode != 0)
                {
                    string msg = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    EditorUtility.DisplayDialog("保存失败",
                        string.IsNullOrWhiteSpace(msg)
                            ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                            : msg.Trim(),
                        "确定");
                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            EditorUtility.DisplayDialog("保存失败", ex.Message, "确定");
            return false;
        }
        finally
        {
            if (File.Exists(tempJson))
                File.Delete(tempJson);
        }

        string cacheError = RefreshCacheFileOnly();
        if (!string.IsNullOrEmpty(cacheError))
        {
            EditorUtility.DisplayDialog("保存成功",
                $"已保存 {dirtyRows.Count} 条修改，但刷新缓存失败：\n{cacheError}",
                "确定");
            return true;
        }

        pendingEnterEditMode = true;
        LoadCache();
        refreshStatus = $"✔ 已保存 {dirtyRows.Count} 条";
        Repaint();
        EditorUtility.DisplayDialog("保存成功", $"已保存 {dirtyRows.Count} 条修改。", "确定");
        return true;
    }

    private void ExitEditMode()
    {
        CancelCurrentTextEdit();
        isEditMode = false;
        pendingEnterEditMode = false;
        if (HasModifiedChanges())
        {
            LoadCache();
            refreshStatus = "✔ 已放弃未保存修改";
        }
        else
        {
            Repaint();
        }
    }

    private bool ValidateEditedRows(out string error)
    {
        error = null;
        var idOwner = new Dictionary<int, string>();
        var nameOwner = new Dictionary<string, string>();

        foreach (var row in allRows)
        {
            string rowLabel = GetRowLabel(row);
            if (!TryParseRequiredInt(row.id, out int idValue))
            {
                error = $"{rowLabel} 的 ID 必须是整数。";
                return false;
            }

            if (IsCellModified(row.rowIndex, 4) && !TryParseOptionalInt(row.rangeSize, out _))
            {
                error = $"{rowLabel} 的范围必须为空或整数。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 5) && !TryParseOptionalInt(row.scaleFactor, out _))
            {
                error = $"{rowLabel} 的缩放必须为空或整数。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 8) && !TryParseOptionalInt(row.soundId, out _))
            {
                error = $"{rowLabel} 的音效ID必须为空或整数。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 9) && !TryParseEnumValue(row.isHit, IS_HIT_LABELS.Length, out _))
            {
                error = $"{rowLabel} 的受击特效标记必须为 0 或 1。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 2) && !TryParseEnumValue(row.vfxType, VFX_TYPE_LABELS.Length, out _))
            {
                error = $"{rowLabel} 的类型超出范围。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 6) && !TryParseEnumValue(row.attachPoint, ATTACH_LABELS.Length, out _))
            {
                error = $"{rowLabel} 的挂接点超出范围。";
                return false;
            }
            if (IsCellModified(row.rowIndex, 7) && !TryParseEnumValue(row.rotationRule, ROTATION_LABELS.Length, out _))
            {
                error = $"{rowLabel} 的旋转规则超出范围。";
                return false;
            }

            if (idOwner.TryGetValue(idValue, out string sameIdRow))
            {
                error = $"ID 重复：{rowLabel} 与 {sameIdRow} 的 ID 都为 {idValue}。";
                return false;
            }
            idOwner[idValue] = rowLabel;

            string name = (row.name ?? "").Trim();
            if (!string.IsNullOrEmpty(name))
            {
                if (nameOwner.TryGetValue(name, out string sameNameRow))
                {
                    error = $"名称重复：{rowLabel} 与 {sameNameRow} 的名称都为 {name}。";
                    return false;
                }
                nameOwner[name] = rowLabel;
            }
        }

        return true;
    }

    private List<LootBootVFXtoExcel.VFXRowData> GetDirtyRows()
    {
        var dirtyRows = new List<LootBootVFXtoExcel.VFXRowData>();
        foreach (var row in allRows)
        {
            if (IsRowModified(row.rowIndex))
                dirtyRows.Add(CloneRow(row));
        }

        dirtyRows.Sort((a, b) => ParseRowIndex(a.rowIndex).CompareTo(ParseRowIndex(b.rowIndex)));
        return dirtyRows;
    }

    private string BuildBatchOverwriteJson(List<LootBootVFXtoExcel.VFXRowData> rows)
    {
        var sb = new StringBuilder();
        sb.Append("[");
        for (int i = 0; i < rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append(BuildRowJson(rows[i]));
        }
        sb.Append("]");
        return sb.ToString();
    }

    private string BuildRowJson(LootBootVFXtoExcel.VFXRowData row)
    {
        var sb = new StringBuilder();
        sb.Append("{");
        sb.Append($"\"rowIndex\":{IntFieldToJson(row.rowIndex)},");
        sb.Append($"\"id\":{IntFieldToJson(row.id)},");
        sb.Append($"\"remark\":\"{EscapeJson(row.remark)}\",");
        sb.Append($"\"name\":\"{EscapeJson(row.name)}\",");
        sb.Append($"\"resource\":\"{EscapeJson(row.resource)}\",");
        sb.Append($"\"vfxType\":{IntFieldToJson(row.vfxType)},");
        sb.Append($"\"rangeSize\":{IntFieldToJson(row.rangeSize)},");
        sb.Append($"\"scaleFactor\":{IntFieldToJson(row.scaleFactor)},");
        sb.Append($"\"attachPoint\":{IntFieldToJson(row.attachPoint)},");
        sb.Append($"\"rotationRule\":{IntFieldToJson(row.rotationRule)},");
        sb.Append($"\"soundId\":{IntFieldToJson(row.soundId)},");
        sb.Append($"\"isHit\":{IntFieldToJson(row.isHit)}");
        sb.Append("}");
        return sb.ToString();
    }

    private string RefreshCacheFileOnly()
    {
        if (!File.Exists(scriptPath))
            return $"找不到 Python 脚本：{scriptPath}";
        if (!File.Exists(excelPath))
            return "Excel 文件路径无效，请先在主窗口确认路径。";

        var psi = BuildPsi(scriptPath, $"--export-all \"{excelPath}\" \"{cachePath}\"");
        try
        {
            using (var proc = Process.Start(psi))
            {
                if (proc == null)
                    return "启动 Python 进程失败（返回 null），请确认 Python 已正确安装。";

                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();
                if (proc.ExitCode != 0)
                {
                    string msg = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    return string.IsNullOrWhiteSpace(msg)
                        ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                        : msg.Trim();
                }
            }
        }
        catch (Exception ex)
        {
            return ex.Message;
        }

        return null;
    }

    private void OpenSelectedRowDetail()
    {
        if (selectedRowIndex < 0 || selectedRowIndex >= filteredRows.Count)
            return;

        var row = filteredRows[selectedRowIndex];
        var sb = new StringBuilder();
        sb.AppendLine($"ID: {row.id}");
        sb.AppendLine($"名称: {row.name}");
        sb.AppendLine($"类型: {GetLabel(row.vfxType, VFX_TYPE_LABELS)} ({row.vfxType})");
        sb.AppendLine($"资源路径: {row.resource}");
        sb.AppendLine($"范围: {row.rangeSize}");
        sb.AppendLine($"缩放: {row.scaleFactor}");
        sb.AppendLine($"挂接点: {GetLabel(row.attachPoint, ATTACH_LABELS)} ({row.attachPoint})");
        sb.AppendLine($"旋转规则: {GetLabel(row.rotationRule, ROTATION_LABELS)} ({row.rotationRule})");
        sb.AppendLine($"音效ID: {row.soundId}");
        sb.AppendLine($"受击特效: {(row.isHit == "1" ? "是" : "否")} ({row.isHit})");
        if (!string.IsNullOrEmpty(row.remark))
            sb.AppendLine($"备注: {row.remark}");

        VFXTableDetailWindow.Open($"VFX 配置详情 - {row.id}", sb.ToString());
    }

    private class VFXTableDetailWindow : EditorWindow
    {
        private string detailText;
        private Vector2 detailScroll;

        public static void Open(string title, string text)
        {
            var win = CreateInstance<VFXTableDetailWindow>();
            win.titleContent = new GUIContent(title);
            win.detailText = text;
            win.minSize = new Vector2(560f, 360f);
            win.ShowUtility();
        }

        private void OnGUI()
        {
            using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
            {
                GUILayout.Label("完整信息", EditorStyles.boldLabel);
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("复制", EditorStyles.toolbarButton, GUILayout.Width(48f)))
                    GUIUtility.systemCopyBuffer = detailText;
                if (GUILayout.Button("关闭", EditorStyles.toolbarButton, GUILayout.Width(48f)))
                    Close();
            }

            detailScroll = EditorGUILayout.BeginScrollView(detailScroll);
            detailText = EditorGUILayout.TextArea(detailText, GUILayout.ExpandHeight(true));
            EditorGUILayout.EndScrollView();
        }
    }

    private static string GetLabel(string val, string[] labels)
    {
        if (int.TryParse(val, out int i) && i >= 0 && i < labels.Length)
            return labels[i];
        return val;
    }

    private void DrawNameCell(Rect rect, LootBootVFXtoExcel.VFXRowData row, int filteredIndex)
    {
        string kw = searchInput.Trim();
        string controlName = GetNameSelectionControlName(row.rowIndex);

        if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && rect.Contains(Event.current.mousePosition))
        {
            selectedRowIndex = filteredIndex;
            activeSelectableNameRowIndex = row.rowIndex;
            Repaint();
        }

        if (string.IsNullOrEmpty(kw) && activeSelectableNameRowIndex == row.rowIndex)
        {
            GUI.SetNextControlName(controlName);
            EditorGUI.SelectableLabel(rect, row.name, cellStyle);
            return;
        }

        if (string.IsNullOrEmpty(kw))
        {
            EditorGUI.LabelField(rect, row.name, cellStyle);
            return;
        }
        EditorGUI.LabelField(rect, BuildHighlightedText(row.name, kw), richCellStyle);
    }

    private void DrawTextCell(Rect rect, string text)
    {
        string kw = searchInput.Trim();
        if (string.IsNullOrEmpty(kw))
        {
            EditorGUI.LabelField(rect, text, cellStyle);
            return;
        }
        EditorGUI.LabelField(rect, BuildHighlightedText(text, kw), richCellStyle);
    }

    private static string BuildHighlightedText(string text, string keyword)
    {
        if (string.IsNullOrEmpty(text) || string.IsNullOrEmpty(keyword)) return text;
        if (text.IndexOf('<') >= 0) return text;

        var sb = new StringBuilder();
        int pos = 0;
        while (pos < text.Length)
        {
            int found = text.IndexOf(keyword, pos, StringComparison.OrdinalIgnoreCase);
            if (found < 0)
            {
                sb.Append(text, pos, text.Length - pos);
                break;
            }
            if (found > pos)
                sb.Append(text, pos, found - pos);
            sb.Append("<color=#FF4444><b>");
            sb.Append(text, found, keyword.Length);
            sb.Append("</b></color>");
            pos = found + keyword.Length;
        }
        return sb.ToString();
    }

    private void DrawTypeCell(Rect rect, string vfxTypeStr)
    {
        if (!int.TryParse(vfxTypeStr, out int t) || t < 0 || t >= VFX_TYPE_LABELS.Length)
        {
            EditorGUI.LabelField(rect, vfxTypeStr, cellStyle);
            return;
        }

        Texture2D icon = t == 0 ? iconSpine : t == 1 ? iconParticle : iconPrefab;
        string label = VFX_TYPE_LABELS[t];

        if (icon != null)
            GUI.DrawTexture(new Rect(rect.x + 2f, rect.y + 2f, 16f, 16f), icon,
                ScaleMode.ScaleToFit, true);

        float textOffsetX = icon != null ? 20f : 0f;
        Color saved = GUI.contentColor;
        GUI.contentColor = VFX_TYPE_COLORS[t];
        EditorGUI.LabelField(
            new Rect(rect.x + textOffsetX, rect.y, rect.width - textOffsetX, rect.height),
            label, cellStyle);
        GUI.contentColor = saved;
    }

    private void DrawColoredCell(Rect rect, string valStr, string[] labels, Color[] colors)
    {
        if (!int.TryParse(valStr, out int i) || i < 0 || i >= labels.Length)
        {
            EditorGUI.LabelField(rect, valStr, cellStyle);
            return;
        }

        Color saved = GUI.contentColor;
        GUI.contentColor = i < colors.Length ? colors[i] : Color.white;
        EditorGUI.LabelField(rect, labels[i], cellStyle);
        GUI.contentColor = saved;
    }

    private void HandleColumnResize(Rect handleRect, int colIdx)
    {
        int id = GUIUtility.GetControlID(FocusType.Passive);
        EditorGUIUtility.AddCursorRect(handleRect, MouseCursor.ResizeHorizontal);

        switch (Event.current.GetTypeForControl(id))
        {
            case EventType.MouseDown:
                if (Event.current.button == 0 && handleRect.Contains(Event.current.mousePosition))
                {
                    GUIUtility.hotControl = id;
                    resizingCol = colIdx;
                    resizeStartX = Event.current.mousePosition.x;
                    resizeStartWidth = colWidths[colIdx];
                    Event.current.Use();
                }
                break;
            case EventType.MouseDrag:
                if (GUIUtility.hotControl == id)
                {
                    float delta = Event.current.mousePosition.x - resizeStartX;
                    colWidths[resizingCol] = Mathf.Max(MIN_COL_WIDTH, resizeStartWidth + delta);
                    Repaint();
                    Event.current.Use();
                }
                break;
            case EventType.MouseUp:
                if (GUIUtility.hotControl == id)
                {
                    GUIUtility.hotControl = 0;
                    resizingCol = -1;
                    Event.current.Use();
                }
                break;
        }
    }

    private static void PingResource(string resource)
    {
        if (string.IsNullOrWhiteSpace(resource))
        {
            EditorUtility.DisplayDialog("错误", "该行资源路径为空。", "确定");
            return;
        }
        string assetPath = "Assets/GameAsset/Effect/" + resource.TrimStart('/') + ".prefab";
        var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (obj != null)
        {
            Selection.activeObject = obj;
            EditorGUIUtility.PingObject(obj);
        }
        else
        {
            EditorUtility.DisplayDialog("未找到", $"找不到资源：\n{assetPath}", "确定");
        }
    }

    private static ProcessStartInfo BuildPsi(string scriptPath, string pythonArgs)
    {
        string dir = Path.GetDirectoryName(scriptPath) ?? "";
        string exePath = Path.Combine(dir, "vfx_excel_tool.exe");
        bool useExe = File.Exists(exePath);
        var psi = new ProcessStartInfo
        {
            FileName = useExe ? exePath : "python",
            Arguments = useExe ? pythonArgs : $"-X utf8 \"{scriptPath}\" {pythonArgs}",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONUTF8"] = "1";
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";
        return psi;
    }

    internal static bool IsHitOnlyWindowOpen()
    {
        var wins = Resources.FindObjectsOfTypeAll<VFXTablePreviewWindow>();
        return wins != null && wins.Length > 0 && wins[0].hitOnlyMode;
    }

    internal static void RequestRefreshIfOpen()
    {
        var wins = Resources.FindObjectsOfTypeAll<VFXTablePreviewWindow>();
        if (wins != null && wins.Length > 0)
            wins[0].RefreshCacheAndReload();
    }

    internal void RefreshCacheAndReload()
    {
        if (!File.Exists(scriptPath))
        {
            pendingEnterEditMode = false;
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        if (!File.Exists(excelPath))
        {
            pendingEnterEditMode = false;
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请先在主窗口确认路径。", "确定");
            return;
        }

        var psi = BuildPsi(scriptPath, $"--export-all \"{excelPath}\" \"{cachePath}\"");

        try
        {
            using (var proc = Process.Start(psi))
            {
                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode != 0)
                {
                    pendingEnterEditMode = false;
                    string msg = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    refreshStatus = "✖ 刷新失败";
                    EditorUtility.DisplayDialog("刷新失败",
                        string.IsNullOrWhiteSpace(msg)
                            ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                            : msg.Trim(),
                        "确定");
                    return;
                }

                int count = -1;
                string raw = stdout.Trim();
                if (raw.StartsWith("OK:") && int.TryParse(raw.Substring(3), out int n))
                    count = n;
                string excelTime = File.Exists(excelPath)
                    ? File.GetLastWriteTime(excelPath).ToString("MM-dd HH:mm:ss")
                    : "";
                string timeLabel = string.IsNullOrEmpty(excelTime) ? "" : $"  Excel {excelTime}";
                refreshStatus = count >= 0 ? $"✔ 已刷新 {count} 条{timeLabel}" : $"✔ 已刷新{timeLabel}";
            }
        }
        catch (Exception ex)
        {
            pendingEnterEditMode = false;
            refreshStatus = "✖ 刷新失败";
            EditorUtility.DisplayDialog("刷新失败",
                $"调用 Python 失败，请确认系统已安装 Python 并已加入环境变量。\n\n{ex.Message}",
                "确定");
            return;
        }

        LoadCache();
        Repaint();
    }

    private string GetSelectedRowKey()
    {
        if (selectedRowIndex < 0 || selectedRowIndex >= filteredRows.Count)
            return null;
        return filteredRows[selectedRowIndex].rowIndex;
    }

    private int FindFilteredIndexByRowIndex(string rowIndex)
    {
        if (string.IsNullOrEmpty(rowIndex))
            return -1;
        for (int i = 0; i < filteredRows.Count; i++)
        {
            if (filteredRows[i].rowIndex == rowIndex)
                return i;
        }
        return -1;
    }

    private LootBootVFXtoExcel.VFXRowData FindAllRowByRowIndex(string rowIndex)
    {
        if (string.IsNullOrEmpty(rowIndex))
            return null;
        for (int i = 0; i < allRows.Count; i++)
        {
            if (allRows[i].rowIndex == rowIndex)
                return allRows[i];
        }
        return null;
    }

    private static LootBootVFXtoExcel.VFXRowData CloneRow(LootBootVFXtoExcel.VFXRowData row)
    {
        return new LootBootVFXtoExcel.VFXRowData
        {
            rowIndex = row.rowIndex,
            id = row.id,
            remark = row.remark,
            name = row.name,
            resource = row.resource,
            vfxType = row.vfxType,
            rangeSize = row.rangeSize,
            scaleFactor = row.scaleFactor,
            attachPoint = row.attachPoint,
            rotationRule = row.rotationRule,
            soundId = row.soundId,
            isHit = row.isHit,
        };
    }

    private static string GetCellValue(LootBootVFXtoExcel.VFXRowData row, int col)
    {
        switch (col)
        {
            case 0: return row.id;
            case 1: return row.name;
            case 2: return row.vfxType;
            case 3: return row.resource;
            case 4: return row.rangeSize;
            case 5: return row.scaleFactor;
            case 6: return row.attachPoint;
            case 7: return row.rotationRule;
            case 8: return row.soundId;
            case 9: return row.isHit;
            case 10: return row.remark;
            default: return "";
        }
    }

    private static void SetCellValue(LootBootVFXtoExcel.VFXRowData row, int col, string value)
    {
        switch (col)
        {
            case 0: row.id = value; break;
            case 1: row.name = value; break;
            case 2: row.vfxType = value; break;
            case 3: row.resource = value; break;
            case 4: row.rangeSize = value; break;
            case 5: row.scaleFactor = value; break;
            case 6: row.attachPoint = value; break;
            case 7: row.rotationRule = value; break;
            case 8: row.soundId = value; break;
            case 9: row.isHit = value; break;
            case 10: row.remark = value; break;
        }
    }

    private void UpdateCellModifiedState(LootBootVFXtoExcel.VFXRowData row, int col)
    {
        string key = GetCellKey(row.rowIndex, col);
        if (originalRowsByIndex.TryGetValue(row.rowIndex, out var original) &&
            string.Equals(GetCellValue(row, col) ?? "", GetCellValue(original, col) ?? "", StringComparison.Ordinal))
            modifiedCellKeys.Remove(key);
        else
            modifiedCellKeys.Add(key);
    }

    private bool IsCellModified(string rowIndex, int col)
    {
        return modifiedCellKeys.Contains(GetCellKey(rowIndex, col));
    }

    private bool IsRowModified(string rowIndex)
    {
        for (int col = 0; col <= 10; col++)
        {
            if (IsCellModified(rowIndex, col))
                return true;
        }
        return false;
    }

    private bool HasModifiedChanges()
    {
        return modifiedCellKeys.Count > 0;
    }

    private static string GetCellKey(string rowIndex, int col)
    {
        return rowIndex + ":" + col;
    }

    private bool IsTextEditActive()
    {
        return !string.IsNullOrEmpty(activeEditRowIndex) && activeEditCol >= 0;
    }

    private bool IsEditingCell(string rowIndex, int col)
    {
        return activeEditRowIndex == rowIndex && activeEditCol == col;
    }

    private static string GetEditControlName(string rowIndex, int col)
    {
        return "VFXPreviewEdit_" + rowIndex + "_" + col;
    }

    private static string GetNameSelectionControlName(string rowIndex)
    {
        return "VFXPreviewName_" + rowIndex;
    }

    private void ClearActiveNameSelection(bool repaint = true)
    {
        if (string.IsNullOrEmpty(activeSelectableNameRowIndex))
            return;

        activeSelectableNameRowIndex = "";
        GUI.FocusControl(null);
        GUIUtility.keyboardControl = 0;
        EditorGUIUtility.editingTextField = false;
        if (repaint)
            Repaint();
    }

    private static bool Approximately(Vector2 a, Vector2 b)
    {
        return Mathf.Abs(a.x - b.x) < 0.01f && Mathf.Abs(a.y - b.y) < 0.01f;
    }

    private static bool IsEnumColumn(int col)
    {
        return col == 2 || col == 6 || col == 7 || col == 9;
    }

    private static int ParsePopupValue(string value, int optionCount)
    {
        if (int.TryParse(value, out int parsed) && parsed >= 0 && parsed < optionCount)
            return parsed;
        return 0;
    }

    private static string[] BuildPopupLabelsWithCurrent(string currentValue, string[] labels)
    {
        string currentLabel = string.IsNullOrEmpty(currentValue) ? "未配置" : $"当前：{currentValue}";
        var result = new string[labels.Length + 1];
        result[0] = currentLabel;
        for (int i = 0; i < labels.Length; i++)
            result[i + 1] = labels[i];
        return result;
    }

    private static void DrawEnumColorStrip(Rect rect, string value, Color[] colors)
    {
        if (!int.TryParse(value, out int parsed) || parsed < 0 || parsed >= colors.Length)
        {
            EditorGUI.DrawRect(new Rect(rect.x + 2f, rect.yMax - 4f, rect.width - 4f, 3f),
                new Color(0.9f, 0.9f, 0.9f, 0.85f));
            return;
        }

        Color color = colors[parsed];
        color.a = 0.9f;
        EditorGUI.DrawRect(new Rect(rect.x + 2f, rect.yMax - 4f, rect.width - 4f, 3f), color);
    }

    private static bool TryParseRequiredInt(string value, out int parsed)
    {
        return int.TryParse((value ?? "").Trim(), out parsed);
    }

    private static bool TryParseOptionalInt(string value, out int parsed)
    {
        value = (value ?? "").Trim();
        if (string.IsNullOrEmpty(value))
        {
            parsed = 0;
            return true;
        }
        return int.TryParse(value, out parsed);
    }

    private static bool TryParseEnumValue(string value, int length, out int parsed)
    {
        return int.TryParse((value ?? "").Trim(), out parsed) && parsed >= 0 && parsed < length;
    }

    private static int ParseRowIndex(string rowIndex)
    {
        return int.TryParse(rowIndex, out int parsed) ? parsed : int.MaxValue;
    }

    private static string GetRowLabel(LootBootVFXtoExcel.VFXRowData row)
    {
        string id = string.IsNullOrEmpty(row.id) ? "<空ID>" : row.id;
        string name = string.IsNullOrEmpty(row.name) ? "<空名称>" : row.name;
        return $"行 {id}（{name}）";
    }

    private static void DrawModifiedCellBackground(Rect rect)
    {
        EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.y + 1f, rect.width - 2f, rect.height - 2f), MODIFIED_CELL_COLOR);
    }

    private static void DrawModifiedCellMarker(Rect rect)
    {
        EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.y + 1f, 4f, rect.height - 2f), new Color(1f, 0.38f, 0f, 1f));
        EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.yMax - 4f, rect.width - 2f, 3f), new Color(1f, 0.38f, 0f, 1f));
    }

    private static string IntFieldToJson(string s)
    {
        return string.IsNullOrWhiteSpace(s) ? "null" : (int.TryParse(s.Trim(), out int v) ? v.ToString() : "null");
    }

    private static string EscapeJson(string s)
    {
        return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
    }
}
}
