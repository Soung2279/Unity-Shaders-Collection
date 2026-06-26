using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

/// <summary>
/// VFX 特效配置全表预览窗口。
/// 从缓存 JSON 加载全量数据，支持实时搜索（ID精确 / 名称·备注·资源路径包含），
/// 点击「选择」将整行数据填回主工具窗口并关闭本窗口。
/// </summary>
public class VFXTablePreviewWindow : EditorWindow
{
    // ── 外部依赖 ──────────────────────────────────────────────
    private string cachePath  = "";
    private string excelPath  = "";
    private string scriptPath = "";
    private Action<LootBootVFXtoExcel.VFXRowData> fillCallback;
    private int highlightId = -1;

    // ── 数据 ──────────────────────────────────────────────────
    private List<LootBootVFXtoExcel.VFXRowData> allRows      = new List<LootBootVFXtoExcel.VFXRowData>();
    private List<LootBootVFXtoExcel.VFXRowData> filteredRows = new List<LootBootVFXtoExcel.VFXRowData>();

    // ── 搜索 / 滚动 ───────────────────────────────────────────
    private string  searchInput           = "";
    private Vector2 scrollPos;
    private bool    needScrollToHighlight = false;    private string  refreshStatus         = "";  // 刷新缓存后展示的状态提示
    // ── 样式（OnGUI 内延迟初始化）────────────────────────────
    private GUIStyle cellStyle;
    private GUIStyle richCellStyle;      // richText 版本，用于搜索关键词高亮
    private GUIStyle headerStyle;
    private GUIStyle highlightRowStyle;
    private GUIStyle selectedRowStyle;   // 点击选中行
    private GUIStyle normalRowStyle;
    private GUIStyle altRowStyle;

    // ── VFX 类型图标缓存 ──────────────────────────────────────
    private Texture2D iconSpine;
    private Texture2D iconParticle;
    private Texture2D iconPrefab;

    // ── 点击选中状态 ──────────────────────────────────────────
    private int selectedRowIndex = -1;

    // ── 布局常量 ──────────────────────────────────────────────
    private const float ROW_HEIGHT    = 20f;
    private const float MIN_COL_WIDTH = 30f;

    // 各列当前宽度（可拖动调整）；操作列 76px 容纳「选择」+「定位」两个按钮
    private float[] colWidths = { 50f, 150f, 58f, 240f, 45f, 50f, 58f, 60f, 50f, 200f, 76f };

    // 列宽拖动状态
    private int   resizingCol    = -1;
    private float resizeStartX;
    private float resizeStartWidth;

    private static readonly string[] COL_NAMES =
        { "ID", "名称", "类型", "资源路径", "范围", "缩放", "挂接点", "旋转规则", "音效ID", "备注", "操作" };

    private static readonly string[] VFX_TYPE_LABELS   = { "Spine", "粒子", "复合" };
    private static readonly string[] ATTACH_LABELS     = { "原点", "中心", "头部" };
    private static readonly string[] ROTATION_LABELS   = { "不旋转", "旋转", "旋转翻转" };

    // ── 枚举值显示颜色 ────────────────────────────────────────
    private static readonly Color[] VFX_TYPE_COLORS = {
        new Color(0.75f, 0.50f, 1.00f),  // 0 Spine:    紫
        new Color(0.30f, 0.90f, 1.00f),  // 1 粒子:     青
        new Color(1.00f, 0.80f, 0.25f),  // 2 复合:     金
    };
    private static readonly Color[] ATTACH_COLORS = {
        new Color(0.80f, 0.80f, 0.80f),  // 0 原点:     灰
        new Color(0.35f, 1.00f, 0.50f),  // 1 中心:     绿
        new Color(1.00f, 0.65f, 0.25f),  // 2 头部:     橙
    };
    private static readonly Color[] ROTATION_COLORS = {
        new Color(0.80f, 0.80f, 0.80f),  // 0 不旋转:   灰
        new Color(0.35f, 0.90f, 1.00f),  // 1 旋转:     青
        new Color(1.00f, 0.50f, 0.85f),  // 2 旋转翻转: 粉
    };

    // ── JsonUtility 反序列化包装 ──────────────────────────────
    [Serializable]
    private class VFXRowDataWrapper
    {
        public LootBootVFXtoExcel.VFXRowData[] items;
    }

    // ── 静态入口 ──────────────────────────────────────────────
    /// <summary>
    /// 打开（或聚焦到已有）全表预览窗口。
    /// </summary>
    /// <param name="highlightId">需要高亮并自动滚动定位的行 ID；-1 表示不高亮。</param>
    internal static void Open(
        string cachePath,
        string excelPath,
        string scriptPath,
        Action<LootBootVFXtoExcel.VFXRowData> fillCallback,
        int highlightId = -1)
    {
        var window = GetWindow<VFXTablePreviewWindow>("VFX 全表预览");
        window.cachePath    = cachePath;
        window.excelPath    = excelPath;
        window.scriptPath   = scriptPath;
        window.fillCallback = fillCallback;
        window.highlightId  = highlightId;
        window.searchInput  = "";
        window.minSize      = new Vector2(990f, 480f);
        window.LoadCache();
        window.needScrollToHighlight = (highlightId >= 0);
        window.Show();
        window.Focus();
    }

    // ── 数据加载 / 过滤 ───────────────────────────────────────
    private void LoadCache()
    {
        allRows.Clear();
        filteredRows.Clear();
        selectedRowIndex = -1;

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
                allRows.AddRange(wrapper.items);
        }
        catch (Exception e)
        {
            UnityEngine.Debug.LogWarning($"[VFXTablePreview] 缓存读取失败：{e.Message}");
        }

        ApplyFilter();
    }

    private void ApplyFilter()
    {
        filteredRows.Clear();
        string kw = searchInput.Trim().ToLowerInvariant();

        if (string.IsNullOrEmpty(kw))
        {
            filteredRows.AddRange(allRows);
            return;
        }

        bool isInt = int.TryParse(kw, out int intKw);
        foreach (var row in allRows)
        {
            // ID 精确匹配
            if (isInt && row.id == intKw.ToString())
            {
                filteredRows.Add(row);
                continue;
            }
            // 名称 / 备注 / 资源路径 包含匹配
            if (row.name.ToLowerInvariant().Contains(kw)     ||
                row.remark.ToLowerInvariant().Contains(kw)   ||
                row.resource.ToLowerInvariant().Contains(kw))
                filteredRows.Add(row);
        }
    }

    // ── 样式初始化 ────────────────────────────────────────────
    private void InitStyles()
    {
        if (cellStyle != null) return;

        cellStyle = new GUIStyle(EditorStyles.label)
        {
            clipping  = TextClipping.Clip,
            alignment = TextAnchor.MiddleLeft,
            padding   = new RectOffset(3, 3, 0, 0),
        };

        richCellStyle = new GUIStyle(cellStyle) { richText = true };
        headerStyle = new GUIStyle(cellStyle) { fontStyle = FontStyle.Bold };
        headerStyle.normal.textColor = EditorGUIUtility.isProSkin
            ? new Color(0.90f, 0.90f, 0.90f)
            : new Color(0.10f, 0.10f, 0.10f);

        normalRowStyle   = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.22f, 0.22f, 0.22f) : new Color(0.84f, 0.84f, 0.84f));
        altRowStyle      = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.26f, 0.26f, 0.26f) : new Color(0.91f, 0.91f, 0.91f));
        highlightRowStyle = MakeRowStyle(new Color(0.85f, 0.50f, 0.08f, 0.90f));
        selectedRowStyle  = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.18f, 0.38f, 0.72f, 0.95f)
            : new Color(0.30f, 0.55f, 0.95f, 0.80f));

        iconParticle = EditorGUIUtility.IconContent("ParticleSystem Icon").image as Texture2D;
        iconSpine    = EditorGUIUtility.IconContent("Animator Icon").image as Texture2D;
        iconPrefab   = EditorGUIUtility.IconContent("Prefab Icon").image as Texture2D;
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

    // ── OnGUI ─────────────────────────────────────────────────
    private void OnGUI()
    {
        InitStyles();

        // ── 工具栏 ────────────────────────────────────────────
        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            GUILayout.Label("搜索（ID / 名称 / 备注 / 资源路径）", GUILayout.Width(220f));

            string newSearch = EditorGUILayout.TextField(searchInput, EditorStyles.toolbarSearchField);
            if (newSearch != searchInput)
            {
                searchInput      = newSearch;
                selectedRowIndex = -1;
                ApplyFilter();
                needScrollToHighlight = false;
                Repaint();
            }

            GUILayout.Label($"{filteredRows.Count} / {allRows.Count} 条", GUILayout.Width(80f));

            if (!string.IsNullOrEmpty(refreshStatus))
            {
                var statusStyle = new GUIStyle(EditorStyles.miniLabel);
                statusStyle.normal.textColor = refreshStatus.StartsWith("✔")
                    ? new Color(0.2f, 0.85f, 0.2f) : new Color(1f, 0.4f, 0.4f);
                GUILayout.Label(refreshStatus, statusStyle);
            }

            GUILayout.FlexibleSpace();

            using (new EditorGUI.DisabledScope(selectedRowIndex < 0 || selectedRowIndex >= filteredRows.Count))
            {
                if (GUILayout.Button("查看详情", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                    OpenSelectedRowDetail();
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

        // ── 固定表头（不进入 ScrollView）─────────────────────
        DrawHeader();

        // ── 滚动定位到高亮行 ──────────────────────────────────
        // 在 Repaint 阶段可以安全地修改 scrollPos，再次 Repaint 生效
        if (needScrollToHighlight && Event.current.type == EventType.Repaint)
        {
            int idx = filteredRows.FindIndex(r => r.id == highlightId.ToString());
            if (idx >= 0)
                scrollPos.y = Mathf.Max(0f, idx * ROW_HEIGHT - position.height * 0.38f);
            needScrollToHighlight = false;
            Repaint();
        }

        // ── 可滚动数据区 ──────────────────────────────────────
        scrollPos = GUILayout.BeginScrollView(scrollPos);

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

            // ── 虚拟滚动：只绘制视口内可见的行，布局只占用一个固定 Rect，避免 GUILayout 控件数在滚动时变化。
            // 工具栏 ~22px + 表头 ROW_HEIGHT，其余为滚动视口
            float viewportH = Mathf.Max(100f, position.height - 22f - ROW_HEIGHT);
            int firstVisible = Mathf.Max(0, Mathf.FloorToInt(scrollPos.y / ROW_HEIGHT));
            int lastVisible  = Mathf.Min(rowCount - 1,
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
            EditorGUI.LabelField(new Rect(x, rect.y, colWidths[c], ROW_HEIGHT), COL_NAMES[c], headerStyle);
            x += colWidths[c];

            // 最后一列不绘制分割线
            if (c == COL_NAMES.Length - 1) continue;

            // 分割线（1px）
            EditorGUI.DrawRect(
                new Rect(x - 0.5f, rect.y + 2f, 1f, ROW_HEIGHT - 4f),
                EditorGUIUtility.isProSkin ? new Color(0.4f, 0.4f, 0.4f) : new Color(0.5f, 0.5f, 0.5f));

            // 拖动句柄（7px，覆盖分割线左右各 3.5px）
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

    private void DrawRow(LootBootVFXtoExcel.VFXRowData row, int index, Rect rowRect)
    {
        bool isHighlight = highlightId >= 0 && row.id == highlightId.ToString();
        bool isSelected  = selectedRowIndex == index;

        GUIStyle rowStyle = isHighlight ? highlightRowStyle
            : isSelected    ? selectedRowStyle
            : (index % 2 == 0 ? normalRowStyle : altRowStyle);

        GUI.Box(rowRect, GUIContent.none, rowStyle);

        // ── 行点击选中（排除操作列和名称列，名称列留给 SelectableLabel）──
        float opColStartX = rowRect.x;
        for (int ci = 0; ci < colWidths.Length - 1; ci++) opColStartX += colWidths[ci];
        // 名称列区域（第 1 列，紧跟 ID 列之后）
        var nameColRect = new Rect(rowRect.x + colWidths[0], rowRect.y, colWidths[1], ROW_HEIGHT);
        if (Event.current.type == EventType.MouseDown && Event.current.button == 0
            && new Rect(rowRect.x, rowRect.y, opColStartX - rowRect.x, ROW_HEIGHT)
               .Contains(Event.current.mousePosition)
            && !nameColRect.Contains(Event.current.mousePosition))
        {
            if (Event.current.clickCount == 2)
                PingResource(row.resource);
            else
                selectedRowIndex = (selectedRowIndex == index) ? -1 : index;
            Event.current.Use();
            Repaint();
        }

        // ── 数据列 ───────────────────────────────────────────
        float x = rowRect.x;

        // 0 ID
        DrawTextCell(new Rect(x, rowRect.y, colWidths[0], ROW_HEIGHT), row.id);
        x += colWidths[0];
        // 1 名称（无搜索时用 SelectableLabel，支持双击全选复制）
        DrawNameCell(new Rect(x, rowRect.y, colWidths[1], ROW_HEIGHT), row.name);
        x += colWidths[1];
        // 2 类型（图标 + 彩色）
        DrawTypeCell(new Rect(x, rowRect.y, colWidths[2], ROW_HEIGHT), row.vfxType);
        x += colWidths[2];
        // 3 资源路径
        DrawTextCell(new Rect(x, rowRect.y, colWidths[3], ROW_HEIGHT), row.resource);
        x += colWidths[3];
        // 4 范围
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[4], ROW_HEIGHT), row.rangeSize, cellStyle);
        x += colWidths[4];
        // 5 缩放
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[5], ROW_HEIGHT), row.scaleFactor, cellStyle);
        x += colWidths[5];
        // 6 挂接点（彩色）
        DrawColoredCell(new Rect(x, rowRect.y, colWidths[6], ROW_HEIGHT),
            row.attachPoint, ATTACH_LABELS, ATTACH_COLORS);
        x += colWidths[6];
        // 7 旋转规则（彩色）
        DrawColoredCell(new Rect(x, rowRect.y, colWidths[7], ROW_HEIGHT),
            row.rotationRule, ROTATION_LABELS, ROTATION_COLORS);
        x += colWidths[7];
        // 8 音效ID
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[8], ROW_HEIGHT), row.soundId, cellStyle);
        x += colWidths[8];
        // 9 备注
        DrawTextCell(new Rect(x, rowRect.y, colWidths[9], ROW_HEIGHT), row.remark);
        x += colWidths[9];

        // ── 操作列：「选择」+「定位」────────────────────────
        float opW  = (colWidths[colWidths.Length - 1] - 6f) * 0.5f;
        Color saved = GUI.backgroundColor;

        GUI.backgroundColor = isHighlight ? new Color(1f, 0.65f, 0.1f) : new Color(0.35f, 0.85f, 0.35f);
        if (GUI.Button(new Rect(x + 1f, rowRect.y + 1f, opW, ROW_HEIGHT - 2f), "选择"))
        {
            selectedRowIndex = index;
            fillCallback?.Invoke(row);
            Repaint();
        }

        GUI.backgroundColor = new Color(0.35f, 0.70f, 1f);
        if (GUI.Button(new Rect(x + opW + 5f, rowRect.y + 1f, opW, ROW_HEIGHT - 2f), "定位"))
            PingResource(row.resource);

        GUI.backgroundColor = saved;
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

    private static string GetLabelWithValue(string val, string[] labels)
    {
        if (int.TryParse(val, out int i) && i >= 0 && i < labels.Length)
            return $"{labels[i]}（{val}）";
        return val;
    }

    /// <summary>绘制名称列：无搜索时使用 SelectableLabel（可双击复制），搜索时高亮。</summary>
    private void DrawNameCell(Rect rect, string text)
    {
        string kw = searchInput.Trim();
        if (string.IsNullOrEmpty(kw))
        {
            EditorGUI.SelectableLabel(rect, text, cellStyle);
            return;
        }
        EditorGUI.LabelField(rect, BuildHighlightedText(text, kw), richCellStyle);
    }

    /// <summary>绘制文字列，搜索激活时用红色加粗富文本高亮匹配关键词。</summary>
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

    /// <summary>
    /// 将 text 中所有大小写不敏感匹配 keyword 的子串包裹为红色加粗富文本。
    /// 若文本含有 &lt; 字符则原样返回，避免富文本解析混乱。
    /// </summary>
    private static string BuildHighlightedText(string text, string keyword)
    {
        if (string.IsNullOrEmpty(text) || string.IsNullOrEmpty(keyword)) return text;
        if (text.IndexOf('<') >= 0) return text;

        var sb  = new StringBuilder();
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

    /// <summary>绘制类型列：图标（原色）+ 彩色标签文字。</summary>
    private void DrawTypeCell(Rect rect, string vfxTypeStr)
    {
        if (!int.TryParse(vfxTypeStr, out int t) || t < 0 || t >= VFX_TYPE_LABELS.Length)
        {
            EditorGUI.LabelField(rect, vfxTypeStr, cellStyle);
            return;
        }

        Texture2D icon  = t == 0 ? iconSpine : t == 1 ? iconParticle : iconPrefab;
        string    label = VFX_TYPE_LABELS[t];

        // 图标原色绘制
        if (icon != null)
            GUI.DrawTexture(new Rect(rect.x + 2f, rect.y + 2f, 16f, 16f), icon,
                ScaleMode.ScaleToFit, true);

        // 文字彩色绘制
        float textOffsetX = icon != null ? 20f : 0f;
        Color saved       = GUI.contentColor;
        GUI.contentColor  = VFX_TYPE_COLORS[t];
        EditorGUI.LabelField(
            new Rect(rect.x + textOffsetX, rect.y, rect.width - textOffsetX, rect.height),
            label, cellStyle);
        GUI.contentColor = saved;
    }

    /// <summary>绘制带颜色区分的枚举值列（只显示标签，不含括号值）。</summary>
    private void DrawColoredCell(Rect rect, string valStr, string[] labels, Color[] colors)
    {
        if (!int.TryParse(valStr, out int i) || i < 0 || i >= labels.Length)
        {
            EditorGUI.LabelField(rect, valStr, cellStyle);
            return;
        }

        Color saved      = GUI.contentColor;
        GUI.contentColor = i < colors.Length ? colors[i] : Color.white;
        EditorGUI.LabelField(rect, labels[i], cellStyle);
        GUI.contentColor = saved;
    }

    // ── 列宽拖动 ──────────────────────────────────────────────
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
                    resizingCol      = colIdx;
                    resizeStartX     = Event.current.mousePosition.x;
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

    // ── 资源定位 ──────────────────────────────────────────────
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

    // ── 刷新缓存 ──────────────────────────────────────────────
    /// <summary>构建子进程启动配置。同目录存在 vfx_excel_tool.exe 则直接调用，否则回退到 python 命令。</summary>
    private static ProcessStartInfo BuildPsi(string scriptPath, string pythonArgs)
    {
        string dir     = Path.GetDirectoryName(scriptPath) ?? "";
        string exePath = Path.Combine(dir, "vfx_excel_tool.exe");
        bool   useExe  = File.Exists(exePath);
        var psi = new ProcessStartInfo
        {
            FileName               = useExe ? exePath : "python",
            Arguments              = useExe ? pythonArgs : $"-X utf8 \"{scriptPath}\" {pythonArgs}",
            UseShellExecute        = false,
            RedirectStandardOutput = true,
            RedirectStandardError  = true,
            CreateNoWindow         = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding  = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONUTF8"] = "1";
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";
        return psi;
    }

    /// <summary>
    /// 若预览窗口已打开，立即刷新缓存并重新加载数据。
    /// 可由外部（如差异检查窗口）在写入 Excel 后调用。
    /// </summary>
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
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        if (!File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请先在主窗口确认路径。", "确定");
            return;
        }

        var psi = BuildPsi(scriptPath, $"--export-all \"{excelPath}\" \"{cachePath}\"");

        try
        {
            using (var proc = Process.Start(psi))
            {
                // 同时读取 stdout 和 stderr，防止缓冲区死锁
                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode != 0)
                {
                    string msg = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    refreshStatus = "✖ 刷新失败";
                    EditorUtility.DisplayDialog("刷新失败",
                        string.IsNullOrWhiteSpace(msg)
                            ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                            : msg.Trim(),
                        "确定");
                    return;
                }

                // 解析行数，stdout 格式："OK:123"
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
            refreshStatus = "✖ 刷新失败";
            EditorUtility.DisplayDialog("刷新失败",
                $"调用 Python 失败，请确认系统已安装 Python 并已加入环境变量。\n\n{ex.Message}",
                "确定");
            return;
        }

        LoadCache();
        Repaint();
    }
}
