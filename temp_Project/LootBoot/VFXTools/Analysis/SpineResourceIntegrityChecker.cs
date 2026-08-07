using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Spine.Unity;
using UnityEditor.Rendering;

#if UNITY_EDITOR
namespace Game.Editor.VFXTools.Analysis
{
/// <summary>
/// Spine 资源完整性检查工具：遍历工程/指定文件夹内所有 SkeletonDataAsset，
/// 沿 SkeletonDataAsset -> AtlasAssetBase -> Material -> Shader/Texture 的引用链
/// 逐层检查，排查缺少材质、图集错误、Shader 丢失/未指定等问题。
/// </summary>
public class SpineResourceIntegrityChecker : EditorWindow
{
    // ============================================================
    // 配置
    // ============================================================
    private enum ScanScope { WholeProject, SelectedFolder }

    private ScanScope scanScope = ScanScope.WholeProject;
    private DefaultAsset scanFolder;

    // ============================================================
    // 扫描结果
    // ============================================================
    private readonly List<Entry> entries = new List<Entry>();
    private Vector2 scrollPos;
    private bool hasScanned;
    private bool cancelled;
    private bool showPassedItems;

    // ============================================================
    // 数据模型
    // ============================================================
    private class Issue
    {
        public enum Level { Error, Warning }

        public Level level;
        public string message;
        public UnityEngine.Object target;   // 用于定位/选中
    }

    private class Entry
    {
        public string title;
        public string path;
        public UnityEngine.Object target;
        public readonly List<Issue> issues = new List<Issue>();
        public bool HasIssue => issues.Count > 0;
    }

    // ============================================================
    // 入口
    // ============================================================
    [MenuItem("TATools/VFXTools/Analysis/Spine资源完整性检查")]
    public static void ShowWindow()
    {
        var win = GetWindow<SpineResourceIntegrityChecker>("Spine 完整性检查");
        win.minSize = new Vector2(520, 400);
    }

    // ============================================================
    // OnGUI
    // ============================================================
    private void OnGUI()
    {
        EditorGUILayout.Space(6);
        EditorGUILayout.LabelField("Spine 资源完整性检查", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox(
            "遍历所有 Spine SkeletonDataAsset，按 骨架 -> 图集 -> 材质 -> Shader/贴图 引用链检查：\n" +
            "• 骨架：skeletonJSON 缺失、版本不兼容、数据解析失败\n" +
            "• 图集：atlas 文件缺失、materials 为空/含空引用、atlas 页与材质贴图不匹配、图集解析失败\n" +
            "• 材质：缺少材质、mainTexture 缺失\n" +
            "• Shader：丢失/未指定、存在编译错误",
            MessageType.Info);

        EditorGUILayout.Space(6);

        scanScope = (ScanScope)EditorGUILayout.EnumPopup("扫描范围", scanScope);
        if (scanScope == ScanScope.SelectedFolder)
        {
            scanFolder = (DefaultAsset)EditorGUILayout.ObjectField(
                new GUIContent("扫描文件夹", "递归扫描该文件夹下的 Spine 资源"),
                scanFolder, typeof(DefaultAsset), false);
        }

        showPassedItems = EditorGUILayout.Toggle("显示无问题项", showPassedItems);

        EditorGUILayout.Space(4);

        using (new EditorGUI.DisabledScope(scanScope == ScanScope.SelectedFolder && scanFolder == null))
        {
            if (GUILayout.Button("开 始 检 查", GUILayout.Height(30)))
                RunScan();
        }

        if (hasScanned)
        {
            EditorGUILayout.Space(4);
            DrawSummary();
            DrawResults();
        }
    }

    private void DrawSummary()
    {
        int issueEntries = entries.Count(e => e.HasIssue);
        int errorCount = 0, warnCount = 0;
        foreach (var e in entries)
        foreach (var i in e.issues)
        {
            if (i.level == Issue.Level.Error) errorCount++;
            else warnCount++;
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            if (cancelled)
                EditorGUILayout.LabelField($"检查已取消（已检查 {entries.Count} 个资源，{issueEntries} 个存在问题）", EditorStyles.boldLabel);
            else if (issueEntries > 0)
                EditorGUILayout.LabelField(
                    $"发现问题：{issueEntries} 个资源 / {errorCount} 错误 / {warnCount} 警告（共检查 {entries.Count} 个）",
                    EditorStyles.boldLabel);
            else
                EditorGUILayout.LabelField($"全部通过 ✓（共检查 {entries.Count} 个 Spine 资源）", EditorStyles.boldLabel);
        }
    }

    private void DrawResults()
    {
        var display = showPassedItems ? entries : entries.Where(e => e.HasIssue).ToList();
        if (display.Count == 0)
        {
            EditorGUILayout.HelpBox("无问题资源。", MessageType.None);
            return;
        }

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        foreach (var entry in display)
        {
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                bool hasIssue = entry.HasIssue;
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUILayout.LabelField(
                        (hasIssue ? "⚠ " : "✓ ") + entry.title,
                        EditorStyles.boldLabel, GUILayout.ExpandWidth(true));

                    if (entry.target != null && GUILayout.Button("选中资源", GUILayout.Width(76)))
                    {
                        Selection.activeObject = entry.target;
                        EditorGUIUtility.PingObject(entry.target);
                    }
                }

                if (!string.IsNullOrEmpty(entry.path))
                    EditorGUILayout.LabelField(entry.path, EditorStyles.miniLabel);

                foreach (var issue in entry.issues)
                {
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        var style = issue.level == Issue.Level.Error ? MsgErrorStyle() : MsgWarnStyle();
                        EditorGUILayout.LabelField(issue.message, style, GUILayout.ExpandWidth(true));

                        if (issue.target != null && GUILayout.Button("定位", GUILayout.Width(44)))
                        {
                            Selection.activeObject = issue.target;
                            EditorGUIUtility.PingObject(issue.target);
                        }
                    }
                }

                if (!hasIssue)
                    EditorGUILayout.HelpBox("所有引用检查通过", MessageType.None);
            }
            EditorGUILayout.Space(3);
        }

        EditorGUILayout.EndScrollView();
    }

    private static GUIStyle _errorStyle;
    private static GUIStyle _warnStyle;

    private static GUIStyle MsgErrorStyle()
    {
        if (_errorStyle == null)
        {
            _errorStyle = new GUIStyle(EditorStyles.label)
            {
                normal = { textColor = new Color(0.95f, 0.35f, 0.35f) },
                wordWrap = true
            };
        }
        return _errorStyle;
    }

    private static GUIStyle MsgWarnStyle()
    {
        if (_warnStyle == null)
        {
            _warnStyle = new GUIStyle(EditorStyles.label)
            {
                normal = { textColor = new Color(1f, 0.78f, 0.2f) },
                wordWrap = true
            };
        }
        return _warnStyle;
    }

    // ============================================================
    // 扫描
    // ============================================================
    private void RunScan()
    {
        entries.Clear();
        hasScanned = false;
        cancelled = false;

        string folderPath = null;
        if (scanScope == ScanScope.SelectedFolder)
        {
            folderPath = AssetDatabase.GetAssetPath(scanFolder);
            if (string.IsNullOrEmpty(folderPath))
            {
                EditorUtility.DisplayDialog("错误", "无法获取所选文件夹路径，请选择项目内的文件夹。", "确定");
                return;
            }
        }

        entries.AddRange(Scan(folderPath, out cancelled));
        hasScanned = true;
        Repaint();
    }

    /// <summary>
    /// 无 UI 的批量扫描入口（也供控制台/自动化调用）。
    /// folderRelPath 为空表示扫描整个工程。
    /// </summary>
    public static string RunHeadlessScan(string folderRelPath)
    {
        List<Entry> result = Scan(string.IsNullOrEmpty(folderRelPath) ? null : folderRelPath, out bool cancelled);
        var sb = new StringBuilder();
        int errors = 0, warns = 0;
        foreach (var e in result)
        foreach (var i in e.issues)
        {
            if (i.level == Issue.Level.Error) errors++;
            else warns++;
        }

        sb.AppendLine($"Spine 完整性检查完成：共 {result.Count} 个资源，"
                      + $"问题资源 {result.Count(e => e.HasIssue)} 个，错误 {errors} 项，警告 {warns} 项"
                      + (cancelled ? "（已取消，结果不完整）" : ""));
        foreach (var e in result.Where(x => x.HasIssue))
        {
            sb.AppendLine($"[{e.title}] {e.path}");
            foreach (var i in e.issues)
                sb.AppendLine($"  [{(i.level == Issue.Level.Error ? "E" : "W")}] {i.message}");
        }
        return sb.ToString();
    }

    private static List<Entry> Scan(string folderRelPath, out bool wasCancelled)
    {
        var result = new List<Entry>();
        wasCancelled = false;
        string[] folders = string.IsNullOrEmpty(folderRelPath) ? new string[0] : new[] { folderRelPath };

        // 收集被骨架引用的图集，用于后续孤立检测
        var referencedAtlasIds = new HashSet<int>();

        // ---------- 1. 扫描骨架 ----------
        string[] skeletonGuids = AssetDatabase.FindAssets("t:SkeletonDataAsset", folders);
        int total = skeletonGuids.Length;
        for (int i = 0; i < total; i++)
        {
            if (EditorUtility.DisplayCancelableProgressBar(
                    "Spine 完整性检查",
                    $"检查骨架 ({i + 1}/{total})",
                    (float)i / Mathf.Max(1, total)))
            {
                wasCancelled = true;
                break;
            }

            string path = AssetDatabase.GUIDToAssetPath(skeletonGuids[i]);
            var sda = AssetDatabase.LoadAssetAtPath<SkeletonDataAsset>(path);
            if (sda == null) continue;

            var entry = new Entry
            {
                title = sda.name,
                path = path,
                target = sda
            };

            ValidateSkeleton(sda, entry.issues, referencedAtlasIds);
            result.Add(entry);
        }

        if (!wasCancelled)
        {
            // ---------- 2. 扫描孤立图集（未被任何骨架引用） ----------
            string[] atlasGuids = AssetDatabase.FindAssets("t:SpineAtlasAsset", folders)
                .Concat(AssetDatabase.FindAssets("t:SpineSpriteAtlasAsset", folders))
                .Distinct().ToArray();

            foreach (string guid in atlasGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                var aa = AssetDatabase.LoadAssetAtPath<AtlasAssetBase>(path);
                if (aa == null) continue;

                int id = aa.GetInstanceID();
                if (referencedAtlasIds.Contains(id)) continue;

                var entry = new Entry
                {
                    title = aa.name + "（未被骨架引用）",
                    path = path,
                    target = aa
                };
                entry.issues.Add(new Issue
                {
                    level = Issue.Level.Warning,
                    message = "该图集未被任何 SkeletonDataAsset 引用（孤立资源）",
                    target = aa
                });
                ValidateAtlas(aa, entry.issues);
                result.Add(entry);
            }
        }

        EditorUtility.ClearProgressBar();
        return result;
    }

    // ============================================================
    // 骨架检查
    // ============================================================
    private static void ValidateSkeleton(SkeletonDataAsset sda, List<Issue> issues, HashSet<int> referencedAtlasIds)
    {
        bool fileLevelError = false;

        // --- skeletonJSON ---
        if (sda.skeletonJSON == null)
        {
            issues.Add(IssueError("缺少骨架数据文件（skeletonJSON 为空）", sda));
            fileLevelError = true;
        }
        else
        {
            try
            {
                bool isSpine;
                string problem = null;
                var ver = SkeletonDataCompatibility.GetVersionInfo(sda.skeletonJSON, out isSpine, ref problem);
                if (!string.IsNullOrEmpty(problem))
                {
                    issues.Add(IssueError("骨架文件问题：" + problem, sda.skeletonJSON));
                    fileLevelError = true;
                }
                else if (isSpine)
                {
                    var compat = SkeletonDataCompatibility.GetCompatibilityProblemInfo(ver);
                    if (compat != null)
                    {
                        issues.Add(IssueError("骨架版本不兼容：" + compat.DescriptionString(), sda.skeletonJSON));
                        fileLevelError = true;
                    }
                }
                else
                {
                    issues.Add(IssueWarn("骨架文件未被识别为 Spine 数据（可能不是有效的 Skeleton JSON/SKEL）", sda.skeletonJSON));
                }
            }
            catch (Exception ex)
            {
                issues.Add(IssueError("骨架版本解析异常：" + ex.Message, sda.skeletonJSON));
                fileLevelError = true;
            }
        }

        // --- atlasAssets ---
        if (sda.atlasAssets == null)
        {
            issues.Add(IssueError("atlasAssets 为空引用", sda));
        }
        else
        {
            if (sda.atlasAssets.Length == 0)
                issues.Add(IssueWarn("未指定图集（atlasAssets 为空数组）", sda));

            for (int i = 0; i < sda.atlasAssets.Length; i++)
            {
                var aa = sda.atlasAssets[i];
                if (aa == null)
                {
                    issues.Add(IssueError($"atlasAssets 第 {i} 项为空引用（缺少图集）", sda));
                    continue;
                }

                referencedAtlasIds.Add(aa.GetInstanceID());
                ValidateAtlas(aa, issues);
            }
        }

        // --- 实际加载骨架 ---
        if (!fileLevelError && sda.skeletonJSON != null)
        {
            try
            {
                if (sda.GetSkeletonData(true) == null)
                    issues.Add(IssueError("骨架数据加载失败（GetSkeletonData 返回 null）", sda));
            }
            catch (Exception ex)
            {
                issues.Add(IssueError("骨架数据加载异常：" + ex.Message, sda));
            }
        }
    }

    // ============================================================
    // 图集检查
    // ============================================================
    private static void ValidateAtlas(AtlasAssetBase aa, List<Issue> issues)
    {
        var saa = aa as SpineAtlasAsset;
        if (saa != null)
        {
            ValidateSpineAtlas(saa, issues);
            return;
        }

        var ssa = aa as SpineSpriteAtlasAsset;
        if (ssa != null)
        {
            ValidateSpriteAtlas(ssa, issues);
            return;
        }

        if (aa.MaterialCount == 0)
            issues.Add(IssueError("图集未设置材质（materials 为空）", aa));
    }

    private static void ValidateSpineAtlas(SpineAtlasAsset aa, List<Issue> issues)
    {
        List<string> pageNames = null;

        if (aa.atlasFile == null)
        {
            issues.Add(IssueError("atlas 文件未指定（atlasFile 为空）", aa));
        }
        else
        {
            pageNames = ParseAtlasPageNames(aa.atlasFile.text);
            if (pageNames.Count == 0)
                issues.Add(IssueWarn("atlas 文本中未解析出任何 page（可能不是有效的 Spine atlas 格式）", aa.atlasFile));
        }

        if (aa.materials == null || aa.materials.Length == 0)
        {
            issues.Add(IssueError("缺少材质（materials 为空）", aa));
        }
        else
        {
            for (int i = 0; i < aa.materials.Length; i++)
            {
                if (aa.materials[i] == null)
                    issues.Add(IssueError($"材质列表第 {i} 项为空（缺少材质）", aa));
            }

            // 图集页 与 材质/贴图 匹配
            if (pageNames != null && pageNames.Count > 0)
            {
                foreach (string page in pageNames)
                {
                    bool matched = false;
                    foreach (var m in aa.materials)
                    {
                        if (m != null && m.mainTexture != null &&
                            string.Equals(m.mainTexture.name, page, StringComparison.OrdinalIgnoreCase))
                        {
                            matched = true;
                            break;
                        }
                    }
                    if (!matched)
                        issues.Add(IssueError($"图集页 '{page}' 没有对应的材质/贴图（page 与材质不匹配）", aa));
                }

                if (pageNames.Count != aa.materials.Length)
                    issues.Add(IssueWarn($"图集页数（{pageNames.Count}）与材质数（{aa.materials.Length}）不一致", aa));
            }

            foreach (var m in aa.materials)
            {
                if (m != null)
                    ValidateMaterial(m, issues);
            }
        }

        // 实际解析图集（捕获格式错误）
        try
        {
            if (aa.GetAtlas() == null)
                issues.Add(IssueError("图集解析失败（GetAtlas 返回 null，atlas 文本或引用无效）", aa));
        }
        catch (Exception ex)
        {
            issues.Add(IssueError("图集解析异常：" + ex.Message, aa));
        }
    }

    private static void ValidateSpriteAtlas(SpineSpriteAtlasAsset aa, List<Issue> issues)
    {
        if (aa.spriteAtlasFile == null)
            issues.Add(IssueError("SpriteAtlas 文件未指定（spriteAtlasFile 为空）", aa));

        if (aa.materials == null || aa.materials.Length == 0)
        {
            issues.Add(IssueError("缺少材质（materials 为空）", aa));
        }
        else
        {
            for (int i = 0; i < aa.materials.Length; i++)
            {
                if (aa.materials[i] == null)
                    issues.Add(IssueError($"材质列表第 {i} 项为空（缺少材质）", aa));
                else
                    ValidateMaterial(aa.materials[i], issues);
            }
        }

        try
        {
            if (aa.GetAtlas() == null)
                issues.Add(IssueError("SpriteAtlas 图集解析失败（GetAtlas 返回 null）", aa));
        }
        catch (Exception ex)
        {
            issues.Add(IssueError("SpriteAtlas 图集解析异常：" + ex.Message, aa));
        }
    }

    // ============================================================
    // 材质 / Shader 检查
    // ============================================================
    private static void ValidateMaterial(Material mat, List<Issue> issues)
    {
        Shader shader = mat.shader;
        if (shader == null)
        {
            issues.Add(IssueError($"材质 '{mat.name}' 的 Shader 丢失（未指定或引用已失效）", mat));
            return;
        }

        if (ShaderUtil.ShaderHasError(shader))
        {
            issues.Add(IssueError($"材质 '{mat.name}' 的 Shader 存在编译错误：{shader.name}", mat));
        }
        else
        {
            ShaderMessage[] msgs = ShaderUtil.GetShaderMessages(shader);
            foreach (var msg in msgs)
            {
                if (msg.severity == ShaderCompilerMessageSeverity.Error)
                    issues.Add(IssueError($"材质 '{mat.name}' 的 Shader 编译错误：{msg.message}", mat));
            }
        }

        if (mat.mainTexture == null)
            issues.Add(IssueWarn($"材质 '{mat.name}' 缺少主贴图（mainTexture 为空）", mat));
    }

    // ============================================================
    // 工具方法
    // ============================================================

    /// <summary>解析 atlas.txt 文本中所有 page 的文件名（去掉扩展名）。</summary>
    private static List<string> ParseAtlasPageNames(string atlasText)
    {
        var pages = new List<string>();
        string[] lines = atlasText.Replace("\r", "").Split('\n');
        foreach (string line in lines)
        {
            if (string.IsNullOrEmpty(line)) continue;
            if (line[0] == ' ' || line[0] == '\t') continue;   // 缩进行是 region 属性
            string trimmed = line.Trim();
            if (!IsImageFilename(trimmed)) continue;
            pages.Add(Path.GetFileNameWithoutExtension(trimmed));
        }
        return pages;
    }

    private static bool IsImageFilename(string name)
    {
        return name.EndsWith(".png", StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".webp", StringComparison.OrdinalIgnoreCase);
    }

    private static Issue IssueError(string message, UnityEngine.Object target)
    {
        return new Issue { level = Issue.Level.Error, message = message, target = target };
    }

    private static Issue IssueWarn(string message, UnityEngine.Object target)
    {
        return new Issue { level = Issue.Level.Warning, message = message, target = target };
    }
}
}
#endif
