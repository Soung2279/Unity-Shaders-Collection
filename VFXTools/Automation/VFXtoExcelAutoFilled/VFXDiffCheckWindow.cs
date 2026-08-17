using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

#if UNITY_EDITOR
namespace Game.Editor.VFXTools.Automation.VFXtoExcelAutoFilled
{
/// <summary>
/// VFX 差异检查窗口。
/// 列出 Excel 缓存中资源路径在当前工程无法找到的配置行，
/// 允许逐行拖入新预制体补充路径，最后批量覆盖写回 Excel。
/// </summary>
public class VFXDiffCheckWindow : EditorWindow
{
    private const string PATH_PREFIX = "Assets/GameAsset/Effect/";

    // ── 外部依赖 ──────────────────────────────────────────────
    private string cachePath  = "";
    private string excelPath  = "";
    private string scriptPath = "";

    // ── 刷新状态提示 ──────────────────────────────────────────
    private string refreshStatus = "";

    // ── 差异行数据 ────────────────────────────────────────────
    private List<LootBootVFXtoExcel.VFXRowData> diffRows     = new List<LootBootVFXtoExcel.VFXRowData>();
    private GameObject[] prefabFields;       // 每行 ObjectField 的当前预制体
    private string[]     overrideResources;  // 从预制体提取的新资源路径（null = 未设置）
    private string[]     overrideVfxTypes;   // 检测到与原记录不一致的新特效类型（null = 无变更）

    // ── 滚动 ──────────────────────────────────────────────────
    private Vector2 scrollPos;
    private int selectedRowIndex = -1;

    // ── 样式（OnGUI 内延迟初始化）────────────────────────────
    private GUIStyle cellStyle;
    private GUIStyle headerStyle;
    private GUIStyle normalRowStyle;
    private GUIStyle altRowStyle;

    // ── 布局常量 ──────────────────────────────────────────────
    private const float ROW_HEIGHT    = 22f;
    private const float MIN_COL_WIDTH = 30f;

    // 仅保留：ID / 名称 / 类型 / 资源路径 / 备注 / 拖入新预制体（6 列）
    private float[] colWidths = { 50f, 190f, 65f, 310f, 200f, 230f };

    private int   resizingCol    = -1;
    private float resizeStartX;
    private float resizeStartWidth;

    private static readonly string[] COL_NAMES =
        { "ID", "名称", "类型", "资源路径（缺失 / 已补充）", "备注", "拖入新预制体" };

    private static readonly string[] VFX_TYPE_LABELS = { "Spine", "粒子", "复合" };

    private static readonly Color[] VFX_TYPE_COLORS = {
        new Color(0.75f, 0.50f, 1.00f),
        new Color(0.30f, 0.90f, 1.00f),
        new Color(1.00f, 0.80f, 0.25f),
    };

    // ── 静态入口 ──────────────────────────────────────────────
    internal static void Open(
        string cachePath,
        string excelPath,
        string scriptPath,
        List<LootBootVFXtoExcel.VFXRowData> rows)
    {
        var win = GetWindow<VFXDiffCheckWindow>("VFX 差异检查");
        win.cachePath        = cachePath;
        win.excelPath        = excelPath;
        win.scriptPath       = scriptPath;
        win.diffRows         = rows;
        win.prefabFields     = new GameObject[rows.Count];
        win.overrideResources = new string[rows.Count];
        win.overrideVfxTypes  = new string[rows.Count];
        win.scrollPos        = Vector2.zero;
        win.selectedRowIndex = -1;
        win.minSize          = new Vector2(900f, 480f);
        win.Show();
        win.Focus();
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

        headerStyle = new GUIStyle(cellStyle) { fontStyle = FontStyle.Bold };
        headerStyle.normal.textColor = EditorGUIUtility.isProSkin
            ? new Color(0.90f, 0.90f, 0.90f)
            : new Color(0.10f, 0.10f, 0.10f);

        normalRowStyle = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.22f, 0.22f, 0.22f) : new Color(0.84f, 0.84f, 0.84f));
        altRowStyle = MakeRowStyle(EditorGUIUtility.isProSkin
            ? new Color(0.26f, 0.26f, 0.26f) : new Color(0.91f, 0.91f, 0.91f));
    }

    private static GUIStyle MakeRowStyle(Color color)
    {
        var tex = new Texture2D(1, 1) { hideFlags = HideFlags.DontSave };
        tex.SetPixel(0, 0, color);
        tex.Apply();
        var s = new GUIStyle(GUIStyle.none);
        s.normal.background = tex;
        return s;
    }

    // ── OnGUI ─────────────────────────────────────────────────
    private void OnGUI()
    {
        InitStyles();

        int modifiedCount = 0;
        if (overrideResources != null)
            foreach (var r in overrideResources)
                if (!string.IsNullOrEmpty(r)) modifiedCount++;

        // ── 工具栏 ────────────────────────────────────────────
        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            string labelText = diffRows.Count > 0
                ? $"共 {diffRows.Count} 条路径缺失  |  已补充 {modifiedCount} 条"
                : "所有资源路径均存在，无差异";
            GUILayout.Label(labelText, EditorStyles.toolbarButton);
            if (!string.IsNullOrEmpty(refreshStatus))
            {
                var statusStyle = new GUIStyle(EditorStyles.miniLabel);
                statusStyle.normal.textColor = refreshStatus.StartsWith("✔")
                    ? new Color(0.2f, 0.85f, 0.2f) : new Color(1f, 0.4f, 0.4f);
                GUILayout.Label(refreshStatus, statusStyle);
            }
            GUILayout.FlexibleSpace();

            Color savedBg = GUI.backgroundColor;

            // ── 自动补充路径 ──────────────────────────────────
            bool canAutoFill = diffRows.Count > 0;
            GUI.enabled = canAutoFill;
            GUI.backgroundColor = canAutoFill
                ? new Color(1.00f, 0.75f, 0.20f)
                : new Color(0.5f, 0.5f, 0.5f);
            if (GUILayout.Button(new GUIContent("自动补充路径",
                "按缓存资源路径中的预制体名（最后一段）在工程中搜索，\n仅唯一匹配时自动填入新路径；同名多个或找不到的行保持不变。"),
                EditorStyles.toolbarButton, GUILayout.Width(84f)))
                AutoFillMissingPaths();
            GUI.enabled = true;

            // ── 保存差异修改 ──────────────────────────────────
            bool canSave = modifiedCount > 0;
            GUI.enabled = canSave;
            GUI.backgroundColor = canSave
                ? new Color(0.35f, 0.85f, 0.35f)
                : new Color(0.5f, 0.5f, 0.5f);
            if (GUILayout.Button("保存差异修改", EditorStyles.toolbarButton, GUILayout.Width(100f)))
                SaveAllOverrides();
            GUI.enabled = true;

            using (new EditorGUI.DisabledScope(selectedRowIndex < 0 || selectedRowIndex >= diffRows.Count))
            {
                if (GUILayout.Button("查看详情", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                    OpenSelectedRowDetail();
            }

            GUI.backgroundColor = new Color(0.35f, 0.75f, 1f);
            if (GUILayout.Button("刷新缓存", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                RefreshCacheManual();
            GUI.backgroundColor = savedBg;
        }

        if (diffRows.Count == 0)
        {
            EditorGUILayout.HelpBox("所有资源路径均可在当前工程中找到，无差异！", MessageType.Info);
            return;
        }

        float tableWidth = GetTotalTableWidth();
        scrollPos = GUILayout.BeginScrollView(scrollPos, true, true, GUILayout.ExpandHeight(true));
        DrawHeader(tableWidth);
        for (int i = 0; i < diffRows.Count; i++)
            DrawRow(i, tableWidth);
        GUILayout.EndScrollView();
    }

    // ── 表头 ──────────────────────────────────────────────────
    private void DrawHeader(float tableWidth)
    {
        Rect rect = GUILayoutUtility.GetRect(tableWidth, ROW_HEIGHT, GUILayout.Width(tableWidth), GUILayout.Height(ROW_HEIGHT));
        EditorGUI.DrawRect(rect, EditorGUIUtility.isProSkin
            ? new Color(0.16f, 0.16f, 0.16f)
            : new Color(0.68f, 0.68f, 0.68f));

        float x = rect.x;
        for (int c = 0; c < COL_NAMES.Length; c++)
        {
            EditorGUI.LabelField(new Rect(x, rect.y, colWidths[c], ROW_HEIGHT), COL_NAMES[c], headerStyle);
            x += colWidths[c];
            if (c < COL_NAMES.Length - 1)
            {
                EditorGUI.DrawRect(
                    new Rect(x - 0.5f, rect.y + 2f, 1f, ROW_HEIGHT - 4f),
                    EditorGUIUtility.isProSkin ? new Color(0.4f, 0.4f, 0.4f) : new Color(0.5f, 0.5f, 0.5f));
                HandleColumnResize(new Rect(x - 3.5f, rect.y, 7f, ROW_HEIGHT), c);
            }
        }
    }

    // ── 行绘制 ────────────────────────────────────────────────
    private void DrawRow(int index, float tableWidth)
    {
        var  row         = diffRows[index];
        bool hasOverride = !string.IsNullOrEmpty(overrideResources?[index]);

        Rect rowRect = GUILayoutUtility.GetRect(tableWidth, ROW_HEIGHT, GUILayout.Width(tableWidth), GUILayout.Height(ROW_HEIGHT));
        GUI.Box(rowRect, GUIContent.none, index % 2 == 0 ? normalRowStyle : altRowStyle);
        if (selectedRowIndex == index)
            EditorGUI.DrawRect(rowRect, new Color(0.25f, 0.55f, 1f, 0.18f));
        if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && rowRect.Contains(Event.current.mousePosition))
        {
            selectedRowIndex = index;
            Repaint();
        }

        float x = rowRect.x;

        // 0 ID
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[0], ROW_HEIGHT), row.id, cellStyle);
        x += colWidths[0];
        // 1 名称（SelectableLabel：双击可全选文字进行复制）
        EditorGUI.SelectableLabel(new Rect(x, rowRect.y, colWidths[1], ROW_HEIGHT), row.name, cellStyle);
        x += colWidths[1];
        // 2 类型（overrideVfxTypes[index] 非空代表检测到类型已变更）
        DrawTypeCell(new Rect(x, rowRect.y, colWidths[2], ROW_HEIGHT), row.vfxType, overrideVfxTypes?[index]);
        x += colWidths[2];
        // 3 资源路径（红 = 缺失；橙 = 已补充待保存）
        string showResource = hasOverride ? overrideResources[index] : row.resource;
        Color  resColor     = hasOverride
            ? new Color(1.00f, 0.78f, 0.20f)   // 橙：已补充
            : new Color(1.00f, 0.35f, 0.35f);   // 红：缺失
        DrawColoredTextCell(new Rect(x, rowRect.y, colWidths[3], ROW_HEIGHT), showResource, resColor);
        x += colWidths[3];
        // 4 备注
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[4], ROW_HEIGHT), row.remark, cellStyle);
        x += colWidths[4];

        // 5 拖入新预制体（ObjectField）
        EditorGUI.BeginChangeCheck();
        var newPrefab = (GameObject)EditorGUI.ObjectField(
            new Rect(x + 2f, rowRect.y + 2f, colWidths[5] - 4f, ROW_HEIGHT - 4f),
            prefabFields[index], typeof(GameObject), false);
        if (EditorGUI.EndChangeCheck())
        {
            prefabFields[index] = newPrefab;
            if (newPrefab != null)
            {
                string ap  = AssetDatabase.GetAssetPath(newPrefab);
                string rel = ap.StartsWith(PATH_PREFIX) ? ap.Substring(PATH_PREFIX.Length) : ap;
                if (rel.EndsWith(".prefab"))
                    rel = rel.Substring(0, rel.Length - ".prefab".Length);
                overrideResources[index] = rel;
                // 检测新预制体类型，与原行记录对比，不一致则同步标记
                int detectedType = LootBootVFXtoExcel.DetectVFXType(newPrefab);
                int.TryParse(diffRows[index].vfxType, out int origType);
                overrideVfxTypes[index] = (detectedType != origType)
                    ? detectedType.ToString() : null;
            }
            else
            {
                overrideResources[index] = null;
                overrideVfxTypes[index]  = null;
            }
            Repaint();
        }
    }

    private float GetTotalTableWidth()
    {
        float total = 0f;
        for (int i = 0; i < colWidths.Length; i++)
            total += colWidths[i];
        return total;
    }

    private void OpenSelectedRowDetail()
    {
        if (selectedRowIndex < 0 || selectedRowIndex >= diffRows.Count)
            return;

        var row = diffRows[selectedRowIndex];
        var sb = new StringBuilder();
        sb.AppendLine($"ID: {row.id}");
        sb.AppendLine($"名称: {row.name}");
        sb.AppendLine($"类型: {GetTypeLabel(row.vfxType)} ({row.vfxType})");
        sb.AppendLine($"资源路径: {row.resource}");
        if (!string.IsNullOrEmpty(row.remark))
            sb.AppendLine($"备注: {row.remark}");
        if (!string.IsNullOrEmpty(overrideResources?[selectedRowIndex]))
            sb.AppendLine($"补充路径: {overrideResources[selectedRowIndex]}");
        if (!string.IsNullOrEmpty(overrideVfxTypes?[selectedRowIndex]))
            sb.AppendLine($"新类型: {GetTypeLabel(overrideVfxTypes[selectedRowIndex])} ({overrideVfxTypes[selectedRowIndex]})");

        VFXDiffDetailWindow.Open($"VFX 差异详情 - {row.id}", sb.ToString());
    }

    private class VFXDiffDetailWindow : EditorWindow
    {
        private string detailText;
        private Vector2 detailScroll;

        public static void Open(string title, string text)
        {
            var win = CreateInstance<VFXDiffDetailWindow>();
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

    // ── 单元格绘制辅助 ────────────────────────────────────────
    private void DrawColoredTextCell(Rect rect, string text, Color color)
    {
        Color saved = GUI.contentColor;
        GUI.contentColor = color;
        EditorGUI.LabelField(rect, text, cellStyle);
        GUI.contentColor = saved;
    }

    private void DrawTypeCell(Rect rect, string vfxTypeStr, string overrideTypeStr = null)
    {
        bool   hasOverride   = !string.IsNullOrEmpty(overrideTypeStr);
        string effectiveType = hasOverride ? overrideTypeStr : vfxTypeStr;

        if (!int.TryParse(effectiveType, out int t) || t < 0 || t >= VFX_TYPE_LABELS.Length)
        { EditorGUI.LabelField(rect, effectiveType, cellStyle); return; }

        Color saved = GUI.contentColor;
        // 类型被覆写时用橙色提示，否则用默认类型颜色
        GUI.contentColor = hasOverride ? new Color(1.00f, 0.78f, 0.20f) : VFX_TYPE_COLORS[t];
        string label   = hasOverride ? $"\u2192{VFX_TYPE_LABELS[t]}" : VFX_TYPE_LABELS[t];
        string tooltip = hasOverride
            ? $"类型已变更：{GetTypeLabel(vfxTypeStr)} \u2192 {VFX_TYPE_LABELS[t]}"
            : VFX_TYPE_LABELS[t];
        EditorGUI.LabelField(
            new Rect(rect.x + 2f, rect.y, rect.width - 2f, rect.height),
            new GUIContent(label, tooltip), cellStyle);
        GUI.contentColor = saved;
    }

    private static string GetTypeLabel(string vfxTypeStr)
    {
        if (int.TryParse(vfxTypeStr, out int t) && t >= 0 && t < VFX_TYPE_LABELS.Length)
            return VFX_TYPE_LABELS[t];
        return string.IsNullOrEmpty(vfxTypeStr) ? "?" : vfxTypeStr;
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

    // ── 批量保存 ──────────────────────────────────────────────
    private void SaveAllOverrides()
    {
        int modifiedCount = 0;
        for (int i = 0; i < overrideResources.Length; i++)
            if (!string.IsNullOrEmpty(overrideResources[i])) modifiedCount++;

        if (modifiedCount == 0)
        {
            EditorUtility.DisplayDialog("无修改", "没有任何行填入了新的预制体路径。", "确定");
            return;
        }

        int typeChangedCount = 0;
        if (overrideVfxTypes != null)
            for (int j = 0; j < overrideVfxTypes.Length; j++)
                if (!string.IsNullOrEmpty(overrideVfxTypes[j])) typeChangedCount++;
        string typeChangeNote = typeChangedCount > 0
            ? $"\n其中 {typeChangedCount} 条将同时更新特效类型。"
            : "";
        bool confirmed = EditorUtility.DisplayDialog(
            "确认保存差异修改",
            $"即将修改 {modifiedCount} 条记录的资源路径，确认执行？{typeChangeNote}",
            "确认", "取消");
        if (!confirmed) return;

        // ── 预检：尝试以写模式打开 Excel，若被占用立即提示 ──────
        try
        {
            using (var fs = new FileStream(excelPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
            { /* 能打开说明未被占用，立即释放 */ }
        }
        catch (IOException)
        {
            EditorUtility.DisplayDialog("无法保存",
                "Excel 文件正被其他程序占用（如 Excel 已打开），\n请先关闭 Excel 后再保存。",
                "确定");
            return;
        }

        var savedIndices = new HashSet<int>();
        string tempJson = Path.GetTempFileName();
        try
        {
            var batch = new StringBuilder();
            batch.Append("[");
            bool first = true;
            for (int i = 0; i < diffRows.Count; i++)
            {
                if (string.IsNullOrEmpty(overrideResources[i])) continue;

                var row = diffRows[i];
                if (!first) batch.Append(",");
                first = false;

                batch.Append("{");
                batch.Append($"\"rowIndex\":{IntFieldToJson(row.rowIndex)},");
                batch.Append($"\"id\":{IntFieldToJson(row.id)},");
                batch.Append($"\"name\":\"{EscapeJson(row.name)}\",");
                batch.Append($"\"resource\":\"{EscapeJson(overrideResources[i])}\",");
                batch.Append($"\"vfxType\":{IntFieldToJson(!string.IsNullOrEmpty(overrideVfxTypes?[i]) ? overrideVfxTypes[i] : row.vfxType)},");
                batch.Append($"\"rangeSize\":{IntFieldToJson(row.rangeSize)},");
                batch.Append($"\"scaleFactor\":{IntFieldToJson(row.scaleFactor)},");
                batch.Append($"\"attachPoint\":{IntFieldToJson(row.attachPoint)},");
                batch.Append($"\"rotationRule\":{IntFieldToJson(row.rotationRule)},");
                batch.Append($"\"soundId\":{IntFieldToJson(row.soundId)},");
                batch.Append($"\"isHit\":{IntFieldToJson(row.isHit)},");
                batch.Append($"\"remark\":\"{EscapeJson(row.remark)}\"");
                batch.Append("}");

                savedIndices.Add(i);
            }
            batch.Append("]");

            File.WriteAllText(tempJson, batch.ToString(), new UTF8Encoding(false));
            var psi = BuildPsi(scriptPath, $"--overwrite-batch \"{excelPath}\" \"{tempJson}\"");
            using (var proc = Process.Start(psi))
            {
                if (proc == null)
                {
                    EditorUtility.DisplayDialog("保存失败", "启动 Python 进程失败（返回 null），请确认 Python 已正确安装。", "确定");
                    return;
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
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            EditorUtility.DisplayDialog("保存失败", ex.Message, "确定");
            return;
        }
        finally
        {
            if (File.Exists(tempJson)) File.Delete(tempJson);
        }

        // 从列表移除已成功保存的行
        var newDiff          = new List<LootBootVFXtoExcel.VFXRowData>();
        var newPrefabs       = new List<GameObject>();
        var newOverrides     = new List<string>();
        var newTypeOverrides = new List<string>();
        for (int i = 0; i < diffRows.Count; i++)
        {
            if (savedIndices.Contains(i)) continue;
            newDiff.Add(diffRows[i]);
            newPrefabs.Add(prefabFields[i]);
            newOverrides.Add(overrideResources[i]);
            newTypeOverrides.Add(overrideVfxTypes != null && i < overrideVfxTypes.Length ? overrideVfxTypes[i] : null);
        }
        diffRows          = newDiff;
        prefabFields      = newPrefabs.ToArray();
        overrideResources = newOverrides.ToArray();
        overrideVfxTypes  = newTypeOverrides.ToArray();

        EditorUtility.DisplayDialog("保存完成",
            $"成功修改 {savedIndices.Count} 条记录。\n\n数据已写入 Excel，请点击工具栏「刷新缓存」使全表预览同步。",
            "确定");

        if (diffRows.Count == 0)
            Close();
        else
            Repaint();
    }

    // ── 自动补充路径 ──────────────────────────────────────────
    /// <summary>
    /// 对每条缺失行，提取原资源路径最后一段作为预制体名，在工程中全局搜索；
    /// 唯一匹配时自动填入新路径，多个同名或找不到的行保持不变。
    /// </summary>
    private void AutoFillMissingPaths()
    {
        int filled = 0, notFound = 0, ambiguous = 0, typeMismatch = 0;

        for (int i = 0; i < diffRows.Count; i++)
        {
            // 已手动填入的行跳过，不覆盖
            if (!string.IsNullOrEmpty(overrideResources[i])) continue;

            string resource = diffRows[i].resource ?? "";
            if (string.IsNullOrEmpty(resource)) { notFound++; continue; }

            // 取路径最后一段作为预制体名（省略 .prefab 后缀）
            int lastSlash = resource.LastIndexOf('/');
            string prefabName = lastSlash >= 0
                ? resource.Substring(lastSlash + 1)
                : resource;
            if (string.IsNullOrEmpty(prefabName)) { notFound++; continue; }

            // 全局搜索同名预制体（FindAssets 可能返回前缀匹配，需精确过滤）
            string[] guids = AssetDatabase.FindAssets($"t:Prefab {prefabName}");
            var exactMatches = new List<string>();
            foreach (string guid in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                string assetName = Path.GetFileNameWithoutExtension(assetPath);
                if (string.Equals(assetName, prefabName, StringComparison.Ordinal))
                    exactMatches.Add(assetPath);
            }

            if (exactMatches.Count == 1)
            {
                string ap  = exactMatches[0];
                string rel = ap.StartsWith(PATH_PREFIX) ? ap.Substring(PATH_PREFIX.Length) : ap;
                if (rel.EndsWith(".prefab"))
                    rel = rel.Substring(0, rel.Length - ".prefab".Length);
                overrideResources[i] = rel;
                filled++;
                // 同步检测新预制体类型是否与原记录一致
                var foundPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(ap);
                if (foundPrefab != null)
                {
                    int detectedType = LootBootVFXtoExcel.DetectVFXType(foundPrefab);
                    int.TryParse(diffRows[i].vfxType, out int origType);
                    if (detectedType != origType)
                    {
                        overrideVfxTypes[i] = detectedType.ToString();
                        typeMismatch++;
                    }
                }
            }
            else if (exactMatches.Count == 0)
                notFound++;
            else
                ambiguous++;
        }

        if (filled > 0) Repaint();

        string typeMismatchNote = typeMismatch > 0
            ? $"\n• 类型与原记录不一致（已标橙更新）  {typeMismatch} 条"
            : "";
        string msg = $"自动补充完成：\n• 成功匹配  {filled} 条（已标橙，可继续确认后保存）\n• 未找到预制体  {notFound} 条\n• 同名预制体有多个（已跳过）  {ambiguous} 条{typeMismatchNote}";
        EditorUtility.DisplayDialog("自动补充路径", msg, "确定");
    }

    // ── 手动刷新缓存 ────────────────────────────────────
    /// <summary>
    /// 重新从 Excel 导出全量缓存，并将刷新后的数据同步到已打开的全表预览窗口。
    /// </summary>
    private void RefreshCacheManual()
    {
        if (!File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("刷新失败", $"Excel 文件不存在：\n{excelPath}", "确定");
            return;
        }
        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("刷新失败", $"找不到 Python 脚本：\n{scriptPath}", "确定");
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
                    string msg = string.IsNullOrWhiteSpace(stderr) ? stdout : stderr;
                    EditorUtility.DisplayDialog("刷新失败",
                        string.IsNullOrWhiteSpace(msg)
                            ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                            : msg.Trim(),
                        "确定");
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            EditorUtility.DisplayDialog("刷新失败", ex.Message, "确定");
            return;
        }

        // 缓存已更新，同步到已打开的全表预览窗口
        VFXTablePreviewWindow.RequestRefreshIfOpen();
        string excelTime = File.Exists(excelPath)
            ? File.GetLastWriteTime(excelPath).ToString("MM-dd HH:mm:ss")
            : "";
        refreshStatus = string.IsNullOrEmpty(excelTime)
            ? "✔ 缓存已刷新"
            : $"✔ Excel {excelTime}";
        Repaint();
        EditorUtility.DisplayDialog("刷新完成", "缓存已重新生成，全表预览已同步。", "确定");
    }

    // ── 工具方法 ──────────────────────────────────────────────
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

    private static string IntFieldToJson(string s) =>
        string.IsNullOrWhiteSpace(s) ? "null" : (int.TryParse(s.Trim(), out int v) ? v.ToString() : "null");

    private static string EscapeJson(string s) =>
        (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"")
                 .Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
}
}

#endif
