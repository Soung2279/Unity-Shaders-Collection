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
/// 显示特效备注搜索结果的弹出窗口。
/// 顶部提供搜索栏可直接再次搜索，每条结果展示 ID、特效类型、名称与备注（自动换行，关键字标红），点击"选择"可将整行数据填回主工具窗口。
/// </summary>
public class VFXSearchResultWindow : EditorWindow
{
    private List<LootBootVFXtoExcel.VFXRowData> results;
    private Action<LootBootVFXtoExcel.VFXRowData> onSelected;
    private string keyword = "";
    private string searchInput = "";
    private string excelPath = "";
    private string scriptPath = "";
    private Vector2 scrollPos;
    private GUIStyle remarkStyle;
    private GUIStyle nameFieldStyle;
    private int selectedIndex = -1;

    private static readonly string[] VFX_TYPE_LABELS =
        { "Spine特效", "粒子特效", "复合特效" };

    internal static void Open(
        List<LootBootVFXtoExcel.VFXRowData> results,
        Action<LootBootVFXtoExcel.VFXRowData> onSelected,
        string keyword = "",
        string excelPath = "",
        string scriptPath = "")
    {
        var window = CreateInstance<VFXSearchResultWindow>();
        window.titleContent = new GUIContent("特效搜索结果");
        window.results = results;
        window.onSelected = onSelected;
        window.keyword = keyword;
        window.searchInput = keyword;
        window.excelPath = excelPath;
        window.scriptPath = scriptPath;
        window.minSize = new Vector2(380f, 360f);
        window.ShowUtility();
    }

    private void OnGUI()
    {
        // 延迟初始化样式（GUIStyle 必须在 OnGUI 内创建）
        if (remarkStyle == null)
        {
            remarkStyle = new GUIStyle(EditorStyles.label);
            remarkStyle.wordWrap = true;
            remarkStyle.richText = true;
        }

        if (nameFieldStyle == null)
        {
            nameFieldStyle = new GUIStyle(EditorStyles.textField);
            nameFieldStyle.fontStyle = FontStyle.Bold;
        }

        // ── 顶部搜索栏 ────────────────────────────────────────
        EditorGUILayout.Space(4f);
        using (new EditorGUILayout.HorizontalScope())
        {
            float savedLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 60f;
            searchInput = EditorGUILayout.TextField(
                new GUIContent("搜索关键字", "输入关键字，在 Excel 备注列中进行模糊搜索。"),
                searchInput);
            EditorGUIUtility.labelWidth = savedLabelWidth;

            Color savedBg = GUI.backgroundColor;
            GUI.backgroundColor = new Color(1f, 0.9f, 0.2f);
            bool doSearch = GUILayout.Button("搜索特效", GUILayout.Width(76f));
            GUI.backgroundColor = savedBg;

            if (doSearch)
                DoSearch();
        }

        // 按 Enter 键也触发搜索
        if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.Return)
        {
            DoSearch();
            Event.current.Use();
        }

        EditorGUILayout.Space(4f);

        // ── 结果区域 ──────────────────────────────────────────
        if (results == null || results.Count == 0)
        {
            EditorGUILayout.HelpBox("没有找到匹配的特效。", MessageType.Info);
            return;
        }

        EditorGUILayout.LabelField($"共找到 {results.Count} 条结果，点击「选择」填回配置", EditorStyles.boldLabel);
        EditorGUILayout.Space(4f);

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        for (int i = 0; i < results.Count; i++)
        {
            LootBootVFXtoExcel.VFXRowData row = results[i];
            bool isSelected = selectedIndex == i;
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                // ID + 特效类型 标签（同一行）
                string typeLabel = "";
                if (int.TryParse(row.vfxType, out int vt) && vt >= 0 && vt < VFX_TYPE_LABELS.Length)
                    typeLabel = VFX_TYPE_LABELS[vt];
                EditorGUILayout.LabelField($"ID: {row.id}    [{typeLabel}]", EditorStyles.miniLabel);

                // 名称（TextField，可双击全选复制，粗体）
                EditorGUILayout.TextField(row.name, nameFieldStyle);

                // 备注（自动换行，关键字标红）
                if (!string.IsNullOrEmpty(row.remark))
                    EditorGUILayout.LabelField(HighlightKeyword(row.remark, keyword), remarkStyle);

                // 选择按钮
                Color saved = GUI.backgroundColor;
                GUI.backgroundColor = isSelected ? new Color(0.2f, 0.75f, 0.2f) : new Color(0.35f, 0.85f, 0.35f);
                if (GUILayout.Button(isSelected ? "✓ 已填回" : "选择", GUILayout.Height(22f)))
                {
                    onSelected?.Invoke(row);
                    selectedIndex = i;
                    Repaint();
                }
                GUI.backgroundColor = saved;
            }
            EditorGUILayout.Space(2f);
        }

        EditorGUILayout.EndScrollView();
    }

    /// <summary>
    /// 执行搜索并刷新结果列表。
    /// </summary>
    private void DoSearch()
    {
        string kw = searchInput.Trim();
        if (string.IsNullOrEmpty(kw))
        {
            EditorUtility.DisplayDialog("提示", "请先输入搜索关键字。", "确定");
            return;
        }

        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效。", "确定");
            return;
        }

        if (string.IsNullOrEmpty(scriptPath) || !File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", "找不到 Python 脚本。", "确定");
            return;
        }

        string json = RunPythonSearchByRemark(scriptPath, excelPath, kw);
        if (json == null)
        {
            EditorUtility.DisplayDialog("搜索失败", "调用 Python 脚本时发生错误，请查看控制台输出。", "确定");
            return;
        }

        // JsonUtility 不支持顶层数组，需包装后反序列化
        var list = JsonUtility.FromJson<VFXRowDataList>("{\"items\":" + json + "}");
        keyword = kw;
        selectedIndex = -1;
        scrollPos = Vector2.zero;

        if (list == null || list.items == null || list.items.Length == 0)
        {
            results = new List<LootBootVFXtoExcel.VFXRowData>();
        }
        else
        {
            results = new List<LootBootVFXtoExcel.VFXRowData>(list.items);
        }

        Repaint();
    }

    [System.Serializable]
    private class VFXRowDataList
    {
        public LootBootVFXtoExcel.VFXRowData[] items;
    }

    /// <summary>调用 Python 脚本按备注模糊搜索，返回 JSON 数组字符串。失败返回 null。</summary>
    private static string RunPythonSearchByRemark(string scriptPath, string excelPath, string keyword)
    {
        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson,
                "{\"keyword\":\"" + EscapeJson(keyword) + "\"}",
                new UTF8Encoding(false));

            var psi = BuildPsi(scriptPath, $"--search-by-remark \"{excelPath}\" \"{tempJson}\"");

            using (var proc = Process.Start(psi))
            {
                string output = proc.StandardOutput.ReadToEnd().Trim();
                proc.WaitForExit();
                return proc.ExitCode == 0 ? output : null;
            }
        }
        catch { return null; }
        finally
        {
            if (File.Exists(tempJson))
                File.Delete(tempJson);
        }
    }

    /// <summary>构建子进程启动配置。同目录存在 vfx_excel_tool.exe 则直接调用，否则回退到 python + 脚本路径。</summary>
    private static ProcessStartInfo BuildPsi(string scriptPath, string pythonArgs)
    {
        string dir     = System.IO.Path.GetDirectoryName(scriptPath) ?? "";
        string exePath = System.IO.Path.Combine(dir, "vfx_excel_tool.exe");
        bool   useExe  = System.IO.File.Exists(exePath);
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

    private static string EscapeJson(string s)
    {
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
    }

    /// <summary>
    /// 将文本中所有匹配关键字的片段用红色富文本包裹（大小写不敏感）。
    /// </summary>
    private static string HighlightKeyword(string text, string kw)
    {
        if (string.IsNullOrEmpty(kw)) return EscapeRichText(text);

        var sb = new System.Text.StringBuilder();
        int searchFrom = 0;
        int kwLen = kw.Length;
        string textLower = text.ToLower();
        string kwLower   = kw.ToLower();

        while (searchFrom < text.Length)
        {
            int idx = textLower.IndexOf(kwLower, searchFrom, StringComparison.Ordinal);
            if (idx < 0)
            {
                sb.Append(EscapeRichText(text.Substring(searchFrom)));
                break;
            }
            // 匹配前的普通文本
            if (idx > searchFrom)
                sb.Append(EscapeRichText(text.Substring(searchFrom, idx - searchFrom)));
            // 匹配片段标红
            sb.Append("<color=red>");
            sb.Append(EscapeRichText(text.Substring(idx, kwLen)));
            sb.Append("</color>");
            searchFrom = idx + kwLen;
        }
        return sb.ToString();
    }

    /// <summary>转义 Unity 富文本中的特殊字符（< > &）。</summary>
    private static string EscapeRichText(string s)
    {
        return s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;");
    }
}
}
