using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

// Made by Copilot, 2026.5.23, Using Claude Sonnet 4.6
// 贴图 Crunch 压缩检测工具 — 扫描项目中所有开启了 Crunch 压缩的贴图导入设置

#if UNITY_EDITOR
public class TextureCrunchFinder : EditorWindow
{
    // ============================================================
    // 平台名称（与 BuildTargetGroup 对应的字符串，TextureImporter 使用）
    // ============================================================
    private static readonly string[] PLATFORM_NAMES =
    {
        "Default",
        "Standalone",
        "Android",
        "iPhone",
        "WebGL",
    };

    // ============================================================
    // 配置字段
    // ============================================================
    private DefaultAsset scanFolder;
    private string scanFolderPath = "Assets/";

    // 平台过滤（多选）
    private bool[] platformFilter = { true, true, true, true, true };

    // 结果过滤
    private string searchFilter = "";

    // ============================================================
    // 扫描结果
    // ============================================================
    private List<CrunchEntry> results = new List<CrunchEntry>();
    private Vector2 scrollPos;
    private bool hasScanned = false;
    private bool isScanning = false;
    private int totalScanned = 0;

    // ============================================================
    // 样式（延迟初始化）
    // ============================================================
    private GUIStyle styleRed;
    private GUIStyle styleBold;
    private GUIStyle styleHeader;
    private bool stylesInited = false;

    // ============================================================
    // 数据模型
    // ============================================================
    private class CrunchEntry
    {
        public string assetPath;
        public Texture2D texture;
        public List<string> crunchedPlatforms = new List<string>();   // 哪些平台开了 Crunch
        public List<int> crunchQuality = new List<int>();             // 对应平台的质量值
    }

    // ============================================================
    // 入口
    // ============================================================
    [MenuItem("TATools/贴图 Crunch 压缩检测")]
    public static void ShowWindow()
    {
        var win = GetWindow<TextureCrunchFinder>("Crunch 压缩检测");
        win.minSize = new Vector2(720, 480);
    }

    // ============================================================
    // 样式初始化
    // ============================================================
    private void InitStyles()
    {
        if (stylesInited) return;

        styleRed = new GUIStyle(EditorStyles.label)
        {
            normal = { textColor = new Color(0.9f, 0.2f, 0.2f) },
            fontStyle = FontStyle.Bold
        };

        styleBold = new GUIStyle(EditorStyles.label)
        {
            fontStyle = FontStyle.Bold
        };

        styleHeader = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 13,
            normal = { textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black }
        };

        stylesInited = true;
    }

    // ============================================================
    // GUI
    // ============================================================
    void OnGUI()
    {
        InitStyles();

        EditorGUILayout.Space(6);
        EditorGUILayout.LabelField("贴图 Crunch 压缩检测工具", styleHeader);
        EditorGUILayout.LabelField("扫描指定目录下所有贴图，列出开启了 Crunch 压缩的导入设置。", EditorStyles.wordWrappedMiniLabel);
        EditorGUILayout.Space(4);

        // --- 扫描目录 ---
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("扫描目录", GUILayout.Width(70));
        var newFolder = (DefaultAsset)EditorGUILayout.ObjectField(scanFolder, typeof(DefaultAsset), false, GUILayout.Width(220));
        if (newFolder != scanFolder)
        {
            scanFolder = newFolder;
            scanFolderPath = scanFolder != null ? AssetDatabase.GetAssetPath(scanFolder) : "Assets/";
        }
        EditorGUILayout.LabelField(scanFolderPath, EditorStyles.miniLabel);
        EditorGUILayout.EndHorizontal();

        // --- 平台过滤 ---
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("检测平台", GUILayout.Width(70));
        for (int i = 0; i < PLATFORM_NAMES.Length; i++)
        {
            platformFilter[i] = GUILayout.Toggle(platformFilter[i], PLATFORM_NAMES[i], GUILayout.Width(90));
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(6);

        // --- 操作按钮 ---
        EditorGUI.BeginDisabledGroup(isScanning);
        if (GUILayout.Button("开始扫描", GUILayout.Height(28)))
        {
            RunScan();
        }
        EditorGUI.EndDisabledGroup();

        if (isScanning)
        {
            EditorGUILayout.HelpBox("扫描中，请稍候...", MessageType.Info);
            return;
        }

        if (!hasScanned) return;

        EditorGUILayout.Space(4);

        // --- 统计摘要 ---
        DrawSummary();

        EditorGUILayout.Space(4);

        // --- 搜索框 ---
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("搜索路径", GUILayout.Width(60));
        searchFilter = EditorGUILayout.TextField(searchFilter, GUILayout.ExpandWidth(true));
        if (GUILayout.Button("清除", GUILayout.Width(46)))
            searchFilter = "";
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(2);

        // --- 结果列表 ---
        DrawResultList();
    }

    // ============================================================
    // 统计摘要
    // ============================================================
    private void DrawSummary()
    {
        int total = results.Count;
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.LabelField($"共扫描贴图：{totalScanned} 张     开启 Crunch：{total} 张", styleBold);

        if (total > 0)
        {
            // 按平台分组统计
            var perPlatform = new Dictionary<string, int>();
            foreach (var e in results)
            {
                foreach (var p in e.crunchedPlatforms)
                {
                    if (!perPlatform.ContainsKey(p)) perPlatform[p] = 0;
                    perPlatform[p]++;
                }
            }
            string platStat = string.Join("  |  ", perPlatform.Select(kv => $"{kv.Key}: {kv.Value}"));
            EditorGUILayout.LabelField("按平台：" + platStat, EditorStyles.miniLabel);
        }

        EditorGUILayout.Space(2);

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("导出到 CSV", GUILayout.Width(120)))
            ExportCSV();
        if (GUILayout.Button("全部选中", GUILayout.Width(100)))
            SelectAllResults();
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.EndVertical();
    }

    // ============================================================
    // 结果列表
    // ============================================================
    private void DrawResultList()
    {
        // 表头
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        EditorGUILayout.LabelField("贴图路径", EditorStyles.toolbarButton, GUILayout.ExpandWidth(true));
        EditorGUILayout.LabelField("开启 Crunch 的平台（质量）", EditorStyles.toolbarButton, GUILayout.Width(280));
        EditorGUILayout.LabelField("定位", EditorStyles.toolbarButton, GUILayout.Width(46));
        EditorGUILayout.EndHorizontal();

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        var filtered = string.IsNullOrEmpty(searchFilter)
            ? results
            : results.Where(e => e.assetPath.IndexOf(searchFilter, System.StringComparison.OrdinalIgnoreCase) >= 0).ToList();

        foreach (var entry in filtered)
        {
            EditorGUILayout.BeginHorizontal();

            // 路径（点击选中资源）
            if (GUILayout.Button(entry.assetPath, EditorStyles.miniLabel, GUILayout.ExpandWidth(true)))
                EditorGUIUtility.PingObject(entry.texture);

            // 平台+质量
            string platQual = string.Join(", ", entry.crunchedPlatforms
                .Select((p, i) => $"{p}(Q{entry.crunchQuality[i]})"));
            EditorGUILayout.LabelField(platQual, styleRed, GUILayout.Width(280));

            // 定位按钮
            if (GUILayout.Button("→", GUILayout.Width(26)))
            {
                Selection.activeObject = entry.texture;
                EditorGUIUtility.PingObject(entry.texture);
            }

            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.EndScrollView();

        if (filtered.Count == 0 && !string.IsNullOrEmpty(searchFilter))
            EditorGUILayout.HelpBox("没有符合过滤条件的结果。", MessageType.None);
    }

    // ============================================================
    // 扫描逻辑
    // ============================================================
    private void RunScan()
    {
        results.Clear();
        hasScanned = false;
        isScanning = true;
        totalScanned = 0;
        Repaint();

        try
        {
            // 获取目录下所有贴图 GUID
            string[] guids = AssetDatabase.FindAssets("t:Texture2D", new[] { scanFolderPath });
            totalScanned = guids.Length;

            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);

                if (EditorUtility.DisplayCancelableProgressBar(
                        "扫描贴图 Crunch 压缩",
                        path,
                        (float)i / guids.Length))
                {
                    break;
                }

                var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer == null) continue;

                var entry = CheckCrunch(path, importer);
                if (entry != null)
                    results.Add(entry);
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
            isScanning = false;
            hasScanned = true;
            Repaint();
        }
    }

    // ============================================================
    // 检查单张贴图的 Crunch 设置
    // ============================================================
    private CrunchEntry CheckCrunch(string path, TextureImporter importer)
    {
        var entry = new CrunchEntry
        {
            assetPath = path,
            texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path)
        };

        for (int i = 0; i < PLATFORM_NAMES.Length; i++)
        {
            if (!platformFilter[i]) continue;

            TextureImporterPlatformSettings settings;
            if (PLATFORM_NAMES[i] == "Default")
            {
                // Default 平台设置直接从 importer 读
                settings = importer.GetDefaultPlatformTextureSettings();
            }
            else
            {
                settings = importer.GetPlatformTextureSettings(PLATFORM_NAMES[i]);
                // 若该平台没有单独覆盖，overridden == false，跳过
                if (!settings.overridden) continue;
            }

            if (settings.crunchedCompression)
            {
                entry.crunchedPlatforms.Add(PLATFORM_NAMES[i]);
                entry.crunchQuality.Add(settings.compressionQuality);
            }
        }

        return entry.crunchedPlatforms.Count > 0 ? entry : null;
    }

    // ============================================================
    // 导出 CSV
    // ============================================================
    private void ExportCSV()
    {
        string savePath = EditorUtility.SaveFilePanel("保存 CSV", "", "CrunchTextures", "csv");
        if (string.IsNullOrEmpty(savePath)) return;

        var sb = new System.Text.StringBuilder();
        sb.AppendLine("贴图路径,开启Crunch的平台,压缩质量");

        foreach (var e in results)
        {
            for (int i = 0; i < e.crunchedPlatforms.Count; i++)
            {
                sb.AppendLine($"\"{e.assetPath}\",{e.crunchedPlatforms[i]},{e.crunchQuality[i]}");
            }
        }

        System.IO.File.WriteAllText(savePath, sb.ToString(), System.Text.Encoding.UTF8);
        EditorUtility.RevealInFinder(savePath);
        Debug.Log($"[CrunchFinder] CSV 已导出: {savePath}");
    }

    // ============================================================
    // 全部选中
    // ============================================================
    private void SelectAllResults()
    {
        var objs = results
            .Where(e => e.texture != null)
            .Select(e => e.texture as Object)
            .ToArray();
        Selection.objects = objs;
    }
}
#endif
