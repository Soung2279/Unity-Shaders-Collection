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
/// VFX 范围大小检查窗口。
/// 列出 Excel 范围大小与预制体 Collider2D 推算半径不一致的配置，并支持批量写回修复。
/// </summary>
public class VFXRangeSizeCheckWindow : EditorWindow
{
    private string cachePath = "";
    private string excelPath = "";
    private string scriptPath = "";
    private List<LootBootVFXtoExcel.RangeSizeMismatch> mismatches = new List<LootBootVFXtoExcel.RangeSizeMismatch>();
    private int checkedCount;
    private int noColliderCount;
    private int unconfiguredRangeCount;
    private int invalidRangeCount;

    private Vector2 scrollPos;
    private int selectedRowIndex = -1;
    private readonly Dictionary<string, string> pendingRangeSizes = new Dictionary<string, string>();
    private string activeEditRowIndex = "";
    private string editBuffer = "";
    private bool focusRangeEdit;

    private GUIStyle cellStyle;
    private GUIStyle headerStyle;
    private GUIStyle normalRowStyle;
    private GUIStyle altRowStyle;

    private const float ROW_HEIGHT = 22f;
    private const float MIN_COL_WIDTH = 30f;
    private float[] colWidths = { 50f, 300f, 70f, 75f, 300f, 280f, 70f, 70f };
    private static readonly string[] COL_NAMES = { "ID", "名称", "表格范围", "Collider", "资源路径", "Collider 信息", "还原", "操作" };

    private int resizingCol = -1;
    private float resizeStartX;
    private float resizeStartWidth;

    internal static void Open(
        string cachePath,
        string excelPath,
        string scriptPath,
        List<LootBootVFXtoExcel.RangeSizeMismatch> mismatches,
        int checkedCount,
        int noColliderCount,
        int unconfiguredRangeCount,
        int invalidRangeCount)
    {
        var win = GetWindow<VFXRangeSizeCheckWindow>("VFX 范围检查");
        win.cachePath = cachePath;
        win.excelPath = excelPath;
        win.scriptPath = scriptPath;
        win.mismatches = mismatches ?? new List<LootBootVFXtoExcel.RangeSizeMismatch>();
        win.checkedCount = checkedCount;
        win.noColliderCount = noColliderCount;
        win.unconfiguredRangeCount = unconfiguredRangeCount;
        win.invalidRangeCount = invalidRangeCount;
        win.scrollPos = Vector2.zero;
        win.selectedRowIndex = -1;
        win.pendingRangeSizes.Clear();
        win.activeEditRowIndex = "";
        win.editBuffer = "";
        win.focusRangeEdit = false;
        win.minSize = new Vector2(900f, 480f);
        win.Show();
        win.Focus();
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

    private void OnGUI()
    {
        InitStyles();
        HandleKeyboard();

        int modifiedCount = pendingRangeSizes.Count;
        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            GUILayout.Label($"不匹配 {mismatches.Count} 条 | 待保存 {modifiedCount} 条 | 已检查 {checkedCount} 条 | 无 Collider {noColliderCount} 条 | 未配置范围 {unconfiguredRangeCount} 条 | 非整数 {invalidRangeCount} 条", EditorStyles.toolbarButton);
            GUILayout.FlexibleSpace();

            using (new EditorGUI.DisabledScope(mismatches.Count == 0))
            {
                Color savedBg = GUI.backgroundColor;
                GUI.backgroundColor = new Color(1.00f, 0.75f, 0.20f);
                if (GUILayout.Button(new GUIContent("修复全部", "先把所有不匹配行标记为 Collider2D 推算值，不立即写入 Excel。"), EditorStyles.toolbarButton, GUILayout.Width(76f)))
                    StageAllFixes();
                if (GUILayout.Button(new GUIContent("修复非空", "只标记原表格范围大小非空的不匹配行，不立即写入 Excel。"), EditorStyles.toolbarButton, GUILayout.Width(76f)))
                    StageNonEmptyFixes();
                if (GUILayout.Button(new GUIContent("修复Circle", "只标记原表格范围非空、且匹配到 CircleCollider2D 的不匹配行，不立即写入 Excel。"), EditorStyles.toolbarButton, GUILayout.Width(82f)))
                    StageNonEmptyCircleFixes();
                GUI.backgroundColor = savedBg;
            }

            using (new EditorGUI.DisabledScope(modifiedCount == 0))
            {
                Color savedBg = GUI.backgroundColor;
                GUI.backgroundColor = new Color(0.35f, 0.85f, 0.35f);
                if (GUILayout.Button(new GUIContent("保存修改", "将待保存的范围大小批量写入 Excel。"), EditorStyles.toolbarButton, GUILayout.Width(76f)))
                    SavePendingChanges();
                GUI.backgroundColor = savedBg;
            }

            using (new EditorGUI.DisabledScope(selectedRowIndex < 0 || selectedRowIndex >= mismatches.Count))
            {
                if (GUILayout.Button("查看详情", EditorStyles.toolbarButton, GUILayout.Width(64f)))
                    OpenSelectedRowDetail();
            }
        }

        if (mismatches.Count == 0)
        {
            EditorGUILayout.HelpBox("当前没有范围大小不匹配的配置。", MessageType.Info);
            return;
        }

        float tableWidth = GetTotalTableWidth();
        DrawHeader(tableWidth);
        scrollPos = GUILayout.BeginScrollView(scrollPos, true, true, GUILayout.ExpandHeight(true));
        for (int i = 0; i < mismatches.Count; i++)
            DrawRow(i, tableWidth);
        GUILayout.EndScrollView();
    }

    private void DrawHeader(float tableWidth)
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
            if (c < COL_NAMES.Length - 1)
            {
                EditorGUI.DrawRect(
                    new Rect(x - 0.5f, rect.y + 2f, 1f, ROW_HEIGHT - 4f),
                    EditorGUIUtility.isProSkin ? new Color(0.4f, 0.4f, 0.4f) : new Color(0.5f, 0.5f, 0.5f));
                HandleColumnResize(new Rect(x - 3.5f, rect.y, 7f, ROW_HEIGHT), c);
            }
        }
    }

    private void DrawRow(int index, float tableWidth)
    {
        var item = mismatches[index];
        var row = item.row;
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
        EditorGUI.LabelField(new Rect(x, rowRect.y, colWidths[0], ROW_HEIGHT), row.id, cellStyle);
        x += colWidths[0];
        EditorGUI.SelectableLabel(new Rect(x, rowRect.y, colWidths[1], ROW_HEIGHT), row.name, cellStyle);
        x += colWidths[1];
        DrawRangeEditCell(new Rect(x, rowRect.y, colWidths[2], ROW_HEIGHT), item, index);
        x += colWidths[2];
        DrawColoredTextCell(new Rect(x, rowRect.y, colWidths[3], ROW_HEIGHT), item.expectedRangeSize.ToString(), new Color(0.35f, 0.95f, 0.45f));
        x += colWidths[3];
        Rect resourceRect = new Rect(x, rowRect.y, colWidths[4], ROW_HEIGHT);
        EditorGUI.LabelField(resourceRect, row.resource, cellStyle);
        if (Event.current.type == EventType.MouseDown && Event.current.button == 0
            && Event.current.clickCount >= 2 && resourceRect.Contains(Event.current.mousePosition))
        {
            selectedRowIndex = index;
            PingPrefab(item.assetPath);
            Event.current.Use();
            Repaint();
        }
        x += colWidths[4];
        DrawColliderInfoCell(new Rect(x, rowRect.y, colWidths[5], ROW_HEIGHT), item.colliderInfo);
        x += colWidths[5];

        bool modified = IsPendingModified(item);
        Color savedBg = GUI.backgroundColor;
        bool savedEnabled = GUI.enabled;
        GUI.backgroundColor = modified ? new Color(1f, 0.86f, 0.35f) : new Color(0.55f, 0.55f, 0.55f);
        GUI.enabled = modified;
        if (GUI.Button(new Rect(x + 2f, rowRect.y + 2f, colWidths[6] - 4f, ROW_HEIGHT - 4f), "还原"))
        {
            RevertPendingRangeSize(item);
            Repaint();
        }
        GUI.enabled = savedEnabled;
        GUI.backgroundColor = savedBg;
        x += colWidths[6];

        if (GUI.Button(new Rect(x + 2f, rowRect.y + 2f, colWidths[7] - 4f, ROW_HEIGHT - 4f), "定位"))
            PingPrefab(item.assetPath);
    }

    private void DrawColoredTextCell(Rect rect, string text, Color color)
    {
        Color saved = GUI.contentColor;
        GUI.contentColor = color;
        EditorGUI.LabelField(rect, text, cellStyle);
        GUI.contentColor = saved;
    }

    private void DrawColliderInfoCell(Rect rect, string colliderInfo)
    {
        Color color = GetColliderColor(colliderInfo);
        Texture icon = GetColliderIcon(colliderInfo);
        Rect iconRect = new Rect(rect.x + 2f, rect.y + 3f, 16f, 16f);
        if (icon != null)
            GUI.DrawTexture(iconRect, icon, ScaleMode.ScaleToFit, true);
        else
            EditorGUI.DrawRect(new Rect(iconRect.x + 3f, iconRect.y + 3f, 10f, 10f), color);

        Color saved = GUI.contentColor;
        GUI.contentColor = color;
        EditorGUI.LabelField(new Rect(rect.x + 21f, rect.y, rect.width - 21f, rect.height), colliderInfo, cellStyle);
        GUI.contentColor = saved;
    }

    private static Color GetColliderColor(string colliderInfo)
    {
        if ((colliderInfo ?? "").StartsWith("CircleCollider2D", StringComparison.Ordinal))
            return new Color(0.35f, 0.95f, 0.45f);
        if ((colliderInfo ?? "").StartsWith("BoxCollider2D", StringComparison.Ordinal))
            return new Color(0.35f, 0.75f, 1f);
        if ((colliderInfo ?? "").StartsWith("PolygonCollider2D", StringComparison.Ordinal))
            return new Color(1f, 0.72f, 0.25f);
        return Color.white;
    }

    private static Texture GetColliderIcon(string colliderInfo)
    {
        if ((colliderInfo ?? "").StartsWith("CircleCollider2D", StringComparison.Ordinal))
            return EditorGUIUtility.IconContent("CircleCollider2D Icon").image;
        if ((colliderInfo ?? "").StartsWith("BoxCollider2D", StringComparison.Ordinal))
            return EditorGUIUtility.IconContent("BoxCollider2D Icon").image;
        if ((colliderInfo ?? "").StartsWith("PolygonCollider2D", StringComparison.Ordinal))
            return EditorGUIUtility.IconContent("PolygonCollider2D Icon").image;
        return null;
    }

    private void DrawRangeEditCell(Rect rect, LootBootVFXtoExcel.RangeSizeMismatch item, int index)
    {
        string rowKey = item.row.rowIndex;
        string displayValue = GetPendingRangeSize(item);
        bool modified = IsPendingModified(item);

        if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && rect.Contains(Event.current.mousePosition))
        {
            selectedRowIndex = index;
            if (Event.current.clickCount >= 2)
            {
                BeginRangeEdit(item);
                Event.current.Use();
            }
            Repaint();
        }

        if (modified)
            EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.y + 1f, rect.width - 2f, rect.height - 2f), new Color(1f, 0.72f, 0.25f, 0.72f));

        if (activeEditRowIndex == rowKey)
        {
            string controlName = GetEditControlName(rowKey);
            GUI.SetNextControlName(controlName);
            string newValue = EditorGUI.TextField(rect, editBuffer ?? "");
            if (newValue != editBuffer)
                editBuffer = newValue;
            if (focusRangeEdit && Event.current.type == EventType.Repaint)
            {
                EditorGUI.FocusTextInControl(controlName);
                focusRangeEdit = false;
            }
        }
        else
        {
            Color color = modified
                ? (EditorGUIUtility.isProSkin ? Color.white : new Color(0.08f, 0.08f, 0.08f))
                : new Color(1f, 0.38f, 0.28f);
            DrawColoredTextCell(rect, string.IsNullOrEmpty(displayValue) ? "<空>" : displayValue, color);
        }

        if (modified)
        {
            EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.y + 1f, 4f, rect.height - 2f), new Color(0.1f, 0.45f, 1f, 1f));
            EditorGUI.DrawRect(new Rect(rect.x + 1f, rect.yMax - 4f, rect.width - 2f, 3f), new Color(0.1f, 0.45f, 1f, 1f));
        }
    }

    private void BeginRangeEdit(LootBootVFXtoExcel.RangeSizeMismatch item)
    {
        CommitRangeEdit();
        activeEditRowIndex = item.row.rowIndex;
        editBuffer = GetPendingRangeSize(item);
        focusRangeEdit = true;
    }

    private void CommitRangeEdit()
    {
        if (string.IsNullOrEmpty(activeEditRowIndex))
            return;

        var item = FindMismatchByRowIndex(activeEditRowIndex);
        if (item != null)
            SetPendingRangeSize(item, editBuffer ?? "");

        activeEditRowIndex = "";
        editBuffer = "";
        focusRangeEdit = false;
        Repaint();
    }

    private void CancelRangeEdit()
    {
        activeEditRowIndex = "";
        editBuffer = "";
        focusRangeEdit = false;
        Repaint();
    }

    private void HandleKeyboard()
    {
        if (Event.current.type != EventType.KeyDown)
            return;

        if (Event.current.keyCode == KeyCode.Return || Event.current.keyCode == KeyCode.KeypadEnter)
        {
            CommitRangeEdit();
            Event.current.Use();
        }
        else if (Event.current.keyCode == KeyCode.Escape)
        {
            CancelRangeEdit();
            Event.current.Use();
        }
    }

    private void StageAllFixes()
    {
        CommitRangeEdit();
        for (int i = 0; i < mismatches.Count; i++)
            SetPendingRangeSize(mismatches[i], mismatches[i].expectedRangeSize.ToString());
        Repaint();
    }

    private void StageNonEmptyFixes()
    {
        CommitRangeEdit();
        for (int i = 0; i < mismatches.Count; i++)
        {
            if (!string.IsNullOrWhiteSpace(mismatches[i].currentRangeSize))
                SetPendingRangeSize(mismatches[i], mismatches[i].expectedRangeSize.ToString());
        }
        Repaint();
    }

    private void StageNonEmptyCircleFixes()
    {
        CommitRangeEdit();
        for (int i = 0; i < mismatches.Count; i++)
        {
            if (!string.IsNullOrWhiteSpace(mismatches[i].currentRangeSize) && IsCircleCollider(mismatches[i]))
                SetPendingRangeSize(mismatches[i], mismatches[i].expectedRangeSize.ToString());
        }
        Repaint();
    }

    private string GetPendingRangeSize(LootBootVFXtoExcel.RangeSizeMismatch item)
    {
        return pendingRangeSizes.TryGetValue(item.row.rowIndex, out string value)
            ? value
            : item.currentRangeSize;
    }

    private void SetPendingRangeSize(LootBootVFXtoExcel.RangeSizeMismatch item, string value)
    {
        string normalized = (value ?? "").Trim();
        string original = (item.currentRangeSize ?? "").Trim();
        if (normalized == original)
            pendingRangeSizes.Remove(item.row.rowIndex);
        else
            pendingRangeSizes[item.row.rowIndex] = normalized;
    }

    private void RevertPendingRangeSize(LootBootVFXtoExcel.RangeSizeMismatch item)
    {
        if (activeEditRowIndex == item.row.rowIndex)
            CancelRangeEdit();
        pendingRangeSizes.Remove(item.row.rowIndex);
    }

    private bool IsPendingModified(LootBootVFXtoExcel.RangeSizeMismatch item)
    {
        return pendingRangeSizes.ContainsKey(item.row.rowIndex);
    }

    private static bool IsCircleCollider(LootBootVFXtoExcel.RangeSizeMismatch item)
    {
        return (item?.colliderInfo ?? "").StartsWith("CircleCollider2D", StringComparison.Ordinal);
    }

    private LootBootVFXtoExcel.RangeSizeMismatch FindMismatchByRowIndex(string rowIndex)
    {
        for (int i = 0; i < mismatches.Count; i++)
        {
            if (mismatches[i].row.rowIndex == rowIndex)
                return mismatches[i];
        }
        return null;
    }

    private static string GetEditControlName(string rowIndex)
    {
        return "VFXRangeEdit_" + rowIndex;
    }

    private void OpenSelectedRowDetail()
    {
        if (selectedRowIndex < 0 || selectedRowIndex >= mismatches.Count)
            return;

        var item = mismatches[selectedRowIndex];
        var row = item.row;
        string detail =
            $"ID: {row.id}\n" +
            $"名称: {row.name}\n" +
            $"资源路径: {row.resource}\n" +
            $"表格范围大小: {item.currentRangeSize}\n" +
            $"待保存范围大小: {GetPendingRangeSize(item)}\n" +
            $"Collider 推算范围: {item.expectedRangeSize}\n" +
            $"Collider: {item.colliderInfo}\n" +
            $"Prefab: {item.assetPath}\n";
        EditorUtility.DisplayDialog($"范围检查详情 - {row.id}", detail, "确定");
    }

    private void SavePendingChanges()
    {
        CommitRangeEdit();
        if (pendingRangeSizes.Count == 0)
            return;

        foreach (var kv in pendingRangeSizes)
        {
            if (!int.TryParse(kv.Value, out _))
            {
                var item = FindMismatchByRowIndex(kv.Key);
                string name = item?.row?.name ?? kv.Key;
                EditorUtility.DisplayDialog("无法保存", $"{name} 的范围大小必须是整数。", "确定");
                return;
            }
        }

        bool confirmed = EditorUtility.DisplayDialog(
            "确认保存修改",
            $"即将把 {pendingRangeSizes.Count} 条配置的范围大小写入 Excel。\n\n请确认 Excel 文件未被打开。",
            "保存", "取消");
        if (!confirmed) return;

        try
        {
            using (var fs = new FileStream(excelPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
            { }
        }
        catch (IOException)
        {
            EditorUtility.DisplayDialog("无法保存", "Excel 文件正被其他程序占用（如 Excel 已打开），\n请先关闭 Excel 后再保存。", "确定");
            return;
        }

        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson, BuildBatchOverwriteJson(), new UTF8Encoding(false));
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

        RefreshCacheFileOnly();
        VFXTablePreviewWindow.RequestRefreshIfOpen();
        int fixedCount = pendingRangeSizes.Count;
        ApplySavedChangesToRows();
        pendingRangeSizes.Clear();
        Repaint();
        EditorUtility.DisplayDialog("保存完成", $"已保存 {fixedCount} 条范围大小修改。", "确定");
    }

    private string BuildBatchOverwriteJson()
    {
        var batch = new StringBuilder();
        batch.Append("[");
        bool first = true;
        for (int i = 0; i < mismatches.Count; i++)
        {
            var item = mismatches[i];
            if (!pendingRangeSizes.TryGetValue(item.row.rowIndex, out string pendingValue))
                continue;

            if (!first) batch.Append(",");
            first = false;
            var row = item.row;
            batch.Append("{");
            batch.Append($"\"rowIndex\":{IntFieldToJson(row.rowIndex)},");
            batch.Append($"\"id\":{IntFieldToJson(row.id)},");
            batch.Append($"\"name\":\"{EscapeJson(row.name)}\",");
            batch.Append($"\"resource\":\"{EscapeJson(row.resource)}\",");
            batch.Append($"\"vfxType\":{IntFieldToJson(row.vfxType)},");
            batch.Append($"\"rangeSize\":{IntFieldToJson(pendingValue)},");
            batch.Append($"\"scaleFactor\":{IntFieldToJson(row.scaleFactor)},");
            batch.Append($"\"attachPoint\":{IntFieldToJson(row.attachPoint)},");
            batch.Append($"\"rotationRule\":{IntFieldToJson(row.rotationRule)},");
            batch.Append($"\"soundId\":{IntFieldToJson(row.soundId)},");
            batch.Append($"\"remark\":\"{EscapeJson(row.remark)}\"");
            batch.Append("}");
        }
        batch.Append("]");
        return batch.ToString();
    }

    private void ApplySavedChangesToRows()
    {
        for (int i = 0; i < mismatches.Count; i++)
        {
            var item = mismatches[i];
            if (pendingRangeSizes.TryGetValue(item.row.rowIndex, out string value))
            {
                item.row.rangeSize = value;
                item.currentRangeSize = value;
            }
        }
    }

    private void RefreshCacheFileOnly()
    {
        var psi = BuildPsi(scriptPath, $"--export-all \"{excelPath}\" \"{cachePath}\"");
        try
        {
            using (var proc = Process.Start(psi))
            {
                proc?.WaitForExit();
            }
        }
        catch { }
    }

    private float GetTotalTableWidth()
    {
        float total = 0f;
        for (int i = 0; i < colWidths.Length; i++)
            total += colWidths[i];
        return total;
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

    private static void PingPrefab(string assetPath)
    {
        var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (obj == null)
        {
            EditorUtility.DisplayDialog("未找到", $"找不到资源：\n{assetPath}", "确定");
            return;
        }

        Selection.activeObject = obj;
        EditorGUIUtility.PingObject(obj);
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

    private static string IntFieldToJson(string s) =>
        string.IsNullOrWhiteSpace(s) ? "null" : (int.TryParse(s.Trim(), out int v) ? v.ToString() : "null");

    private static string EscapeJson(string s) =>
        (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"")
                 .Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
}
}

#endif
