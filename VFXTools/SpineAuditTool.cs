using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor.Presets;

// Made by Copilot, 2026.5.22, Using Claude Sonnet 4.6
// Spine 资源检测工具 — 检测图集尺寸(过大/非POT) 及 材质Shader(URP SRP合批兼容性)

#if UNITY_EDITOR
public class SpineAuditTool : EditorWindow
{
    // ============================================================
    // 常量
    // ============================================================
    private const string URP_SPINE_SHADER_PREFIX = "Universal Render Pipeline/Spine/";
    private const string DEFAULT_FIX_SHADER = "Universal Render Pipeline/Spine/Skeleton";

    // ============================================================
    // 配置字段
    // ============================================================
    private DefaultAsset scanFolder;
    private int maxAllowedSize = 2048;     // 仅用于检测判定，不作为修复参数
    private Preset texImportPreset;         // 修复时应用到图集 TextureImporter 的预设
    private bool showPassedItems = false;

    // ============================================================
    // 扫描结果
    // ============================================================
    private List<SpineEntry> allEntries = new List<SpineEntry>();
    private Vector2 scrollPos;
    private bool hasScanned = false;

    // ============================================================
    // 样式 (延迟初始化)
    // ============================================================
    private GUIStyle styleError;
    private GUIStyle styleOk;
    private GUIStyle styleWarn;
    private GUIStyle styleBoldHeader;
    private GUIStyle styleEntryTitleError;
    private GUIStyle styleEntryTitleOk;
    private GUIStyle styleWrappedLabel;
    private GUIStyle stylePath;
    private bool stylesInited = false;

    // ============================================================
    // 数据模型
    // ============================================================
    private class SpineEntry
    {
        public string folderPath;   // Assets/... (相对路径)
        public string spineName;

        // 材质问题
        public string matPath;
        public Material material;
        public bool wrongShader;
        public string currentShaderName;

        // 图集纹理问题 (每个 atlas page 一条)
        public List<TexPageIssue> texIssues = new List<TexPageIssue>();

        public bool HasIssue => wrongShader || texIssues.Count > 0;
    }

    private class TexPageIssue
    {
        public string texPath;          // Assets/...
        public int declaredWidth;
        public int declaredHeight;
        public bool isNonPOT;
        public bool isTooLarge;
        public TextureImporter importer;
    }

    // ============================================================
    // 入口
    // ============================================================
    [MenuItem("TATools/Tools/工具 - Spine 资源检测")]
    public static void ShowWindow()
    {
        var win = GetWindow<SpineAuditTool>("Spine 资源检测");
        win.minSize = new Vector2(480, 360);
    }

    // ============================================================
    // OnGUI
    // ============================================================
    private void OnGUI()
    {
        InitStyles();
        DrawHeader();
        if (hasScanned)
            DrawResults();
    }

    private void InitStyles()
    {
        if (stylesInited) return;
        stylesInited = true;

        styleError = new GUIStyle(EditorStyles.label)
        {
            normal = { textColor = new Color(0.95f, 0.35f, 0.35f) },
            richText = true
        };
        styleOk = new GUIStyle(EditorStyles.label)
        {
            normal = { textColor = new Color(0.35f, 0.85f, 0.35f) },
            richText = true
        };
        styleWarn = new GUIStyle(EditorStyles.label)
        {
            normal = { textColor = new Color(1f, 0.78f, 0.2f) },
            richText = true
        };
        styleBoldHeader = new GUIStyle(EditorStyles.boldLabel) { fontSize = 14 };
        styleEntryTitleError = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 13,
            richText = true,
            wordWrap = true,
            normal = { textColor = styleError.normal.textColor }
        };
        styleEntryTitleOk = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 13,
            richText = true,
            wordWrap = true,
            normal = { textColor = styleOk.normal.textColor }
        };
        styleWrappedLabel = new GUIStyle(EditorStyles.label)
        {
            richText = true,
            wordWrap = true
        };
        stylePath = new GUIStyle(EditorStyles.miniLabel)
        {
            wordWrap = true
        };
    }

    // ============================================================
    // 顶部配置区
    // ============================================================
    private void DrawHeader()
    {
        EditorGUILayout.Space(6);
        EditorGUILayout.LabelField("Spine 资源检测工具", styleBoldHeader);
        EditorGUILayout.Space(2);
        EditorGUILayout.HelpBox(
            "扫描指定文件夹内所有 Spine 资源，检测以下问题并提供一键修复：\n" +
            "• 材质未使用 URP Spine Shader（不支持 SRP 合批）\n" +
            "• 图集纹理尺寸超限（宽/高 > 最大允许尺寸）\n" +
            "• 图集纹理尺寸非二次幂（Non-Power-Of-Two）",
            MessageType.Info);

        EditorGUILayout.Space(6);

        scanFolder = (DefaultAsset)EditorGUILayout.ObjectField(
            new GUIContent("扫描文件夹", "将递归扫描该文件夹下所有 Spine atlas.txt"),
            scanFolder, typeof(DefaultAsset), false);

        maxAllowedSize = EditorGUILayout.IntField(
            new GUIContent("检测阈值尺寸 (px)", "宽或高超过此值即标记为「过大」，仅用于检测，不影响修复"),
            maxAllowedSize);

        texImportPreset = (Preset)EditorGUILayout.ObjectField(
            new GUIContent("图集导入预设", "修复时将此 Preset 整体应用到图集的 TextureImporter（非POT问题仍需手动操作）"),
            texImportPreset, typeof(Preset), false);

        showPassedItems = EditorGUILayout.Toggle("显示无问题项", showPassedItems);

        EditorGUILayout.Space(6);

        using (new EditorGUI.DisabledScope(scanFolder == null))
        {
            if (GUILayout.Button("开 始 扫 描", GUILayout.Height(32)))
                RunScan();
        }

        using (new EditorGUI.DisabledScope(scanFolder == null || texImportPreset == null))
        {
            if (GUILayout.Button(new GUIContent(
                    "批量应用预设到全部图集",
                    "无需检测，直接将图集导入预设应用到指定文件夹下所有 Spine 图集纹理"),
                GUILayout.Height(28)))
                ApplyPresetToAll();
        }

        if (hasScanned)
        {
            int issueCount = allEntries.Count(e => e.HasIssue);
            EditorGUILayout.Space(4);

            using (new EditorGUILayout.HorizontalScope())
            {
                if (issueCount > 0)
                {
                    EditorGUILayout.LabelField(
                        $"发现 {issueCount} 个问题 Spine（共 {allEntries.Count} 个）", styleError);
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("仅修复 Shader", GUILayout.Width(100), GUILayout.Height(22)))
                        FixShadersOnly();
                    if (GUILayout.Button("一键修复全部", GUILayout.Width(100), GUILayout.Height(22)))
                        FixAll();
                }
                else
                {
                    EditorGUILayout.LabelField(
                        $"全部通过 ✓（共 {allEntries.Count} 个）", styleOk);
                }
            }
        }

        EditorGUILayout.Space(4);
        DrawHorizontalLine();
    }

    // ============================================================
    // 结果列表
    // ============================================================
    private void DrawResults()
    {
        if (allEntries.Count == 0)
        {
            EditorGUILayout.HelpBox(
                "未在所选文件夹中找到任何 Spine 资源（需含 .atlas.txt 文件）。",
                MessageType.Warning);
            return;
        }

        var display = showPassedItems
            ? allEntries
            : allEntries.Where(e => e.HasIssue).ToList();

        if (!showPassedItems && display.Count == 0)
        {
            EditorGUILayout.HelpBox("所有检测项均通过，无问题。", MessageType.None);
            return;
        }

        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            GUILayout.Label($"结果列表：显示 {display.Count} / {allEntries.Count}", EditorStyles.miniLabel);
            GUILayout.FlexibleSpace();
            GUILayout.Label("每个问题独立分块显示，长路径会自动换行", EditorStyles.miniLabel);
        }

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        foreach (var entry in display)
            DrawEntry(entry);

        EditorGUILayout.EndScrollView();
    }

    private void DrawEntry(SpineEntry entry)
    {
        bool hasIssue = entry.HasIssue;
        using (new EditorGUILayout.VerticalScope(GUI.skin.box))
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                string icon = hasIssue ? "⚠" : "✓";
                GUIStyle nameStyle = hasIssue ? styleEntryTitleError : styleEntryTitleOk;
                EditorGUILayout.LabelField($"{icon} {entry.spineName}", nameStyle, GUILayout.ExpandWidth(true));

                if (GUILayout.Button("定位文件夹", GUILayout.Width(76)))
                    PingAsset(entry.folderPath);

                using (new EditorGUI.DisabledScope(!hasIssue))
                {
                    if (GUILayout.Button("修复此项", GUILayout.Width(76)))
                    {
                        FixEntry(entry);
                        AssetDatabase.SaveAssets();
                        RunScan();
                        GUIUtility.ExitGUI();
                    }
                }
            }

            EditorGUILayout.LabelField(entry.folderPath, stylePath);
            EditorGUILayout.Space(3);

            if (entry.wrongShader)
                DrawShaderIssue(entry);

            foreach (var tex in entry.texIssues.ToList())
            {
                DrawTexIssue(tex, entry);
                EditorGUILayout.Space(3);
            }

            if (!hasIssue)
                EditorGUILayout.HelpBox("所有检测项通过", MessageType.None);
        }

        EditorGUILayout.Space(4);
    }

    private void DrawShaderIssue(SpineEntry entry)
    {
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField("材质 Shader 不支持 SRP 合批", styleError);
            EditorGUILayout.LabelField($"当前 Shader：{entry.currentShaderName}", styleWrappedLabel);
            EditorGUILayout.LabelField($"材质路径：{entry.matPath}", stylePath);

            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.FlexibleSpace();
                if (entry.material != null && GUILayout.Button("选中材质", GUILayout.Width(90)))
                    Selection.activeObject = entry.material;
                if (GUILayout.Button("修复 Shader", GUILayout.Width(90)))
                {
                    FixShader(entry);
                    AssetDatabase.SaveAssets();
                    RunScan();
                    GUIUtility.ExitGUI();
                }
            }
        }
    }

    private void DrawTexIssue(TexPageIssue tex, SpineEntry entry)
    {
        string texName = Path.GetFileName(tex.texPath);
        var issues = new List<string>();
        if (tex.isTooLarge)
            issues.Add($"尺寸超限：{tex.declaredWidth}×{tex.declaredHeight} > {maxAllowedSize}");
        if (tex.isNonPOT)
            issues.Add($"非二次幂：{tex.declaredWidth}×{tex.declaredHeight}");

        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField($"图集：{texName}", styleWarn);
            EditorGUILayout.LabelField("问题：" + string.Join("；", issues), styleWrappedLabel);
            EditorGUILayout.LabelField("路径：" + tex.texPath, stylePath);

            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("选中贴图", GUILayout.Width(90)))
                {
                    var texAsset = AssetDatabase.LoadAssetAtPath<Texture2D>(tex.texPath);
                    if (texAsset != null) Selection.activeObject = texAsset;
                }
                using (new EditorGUI.DisabledScope(!tex.isTooLarge))
                {
                    if (GUILayout.Button("修复尺寸", GUILayout.Width(90)))
                    {
                        if (FixTextureTooLarge(tex))
                        {
                            entry.texIssues.Remove(tex);
                            RunScan();
                        }
                        GUIUtility.ExitGUI();
                    }
                }
                using (new EditorGUI.DisabledScope(!tex.isNonPOT))
                {
                    if (GUILayout.Button("修复非POT", GUILayout.Width(90)))
                    {
                        if (FixTextureNonPOT(tex))
                        {
                            entry.texIssues.Remove(tex);
                            RunScan();
                        }
                        GUIUtility.ExitGUI();
                    }
                }
            }
        }
    }

    // ============================================================
    // 扫描逻辑
    // ============================================================
    private void RunScan()
    {
        allEntries.Clear();
        hasScanned = false;

        string folderRelPath = AssetDatabase.GetAssetPath(scanFolder);
        if (string.IsNullOrEmpty(folderRelPath))
        {
            EditorUtility.DisplayDialog("错误", "无法获取所选文件夹路径，请确保选择的是项目内的文件夹。", "确定");
            return;
        }

        // 查找所有 atlas.txt（Spine 格式）
        string[] textAssetGuids = AssetDatabase.FindAssets("t:TextAsset", new[] { folderRelPath });
        var atlasPaths = textAssetGuids
            .Select(g => AssetDatabase.GUIDToAssetPath(g))
            .Where(p => p.EndsWith(".atlas.txt", System.StringComparison.OrdinalIgnoreCase))
            .OrderBy(p => p)
            .ToArray();

        try
        {
            for (int i = 0; i < atlasPaths.Length; i++)
            {
                float progress = (float)i / atlasPaths.Length;
                EditorUtility.DisplayProgressBar("Spine 资源检测", $"正在检测 {Path.GetFileName(atlasPaths[i])}...", progress);

                var entry = BuildEntry(atlasPaths[i]);
                if (entry != null)
                    allEntries.Add(entry);
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }

        hasScanned = true;
        Repaint();
    }

    private SpineEntry BuildEntry(string atlasPath)
    {
        string dir = Path.GetDirectoryName(atlasPath).Replace('\\', '/');

        // 只处理直接在此目录（或其子目录）内的 mat 文件
        string[] matGuids = AssetDatabase.FindAssets("t:Material", new[] { dir });
        string matPath = matGuids
            .Select(g => AssetDatabase.GUIDToAssetPath(g))
            .FirstOrDefault(p => string.Equals(
                Path.GetDirectoryName(p).Replace('\\', '/'), dir,
                System.StringComparison.OrdinalIgnoreCase));

        if (matPath == null) return null;   // 不是标准 Spine 文件夹

        string spineName = Path.GetFileNameWithoutExtension(atlasPath);
        // 去掉 .atlas 后缀 (atlas.txt -> 文件名含 .atlas)
        if (spineName.EndsWith(".atlas", System.StringComparison.OrdinalIgnoreCase))
            spineName = spineName.Substring(0, spineName.Length - 6);

        var entry = new SpineEntry
        {
            folderPath = dir,
            spineName = spineName,
            matPath = matPath,
        };

        // --- 检测材质 Shader ---
        Material mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        if (mat != null)
        {
            entry.material = mat;
            string shaderName = mat.shader != null ? mat.shader.name : "(null)";
            entry.currentShaderName = shaderName;
            entry.wrongShader = !shaderName.StartsWith(URP_SPINE_SHADER_PREFIX,
                System.StringComparison.OrdinalIgnoreCase);
        }

        // --- 检测图集纹理 ---
        TextAsset atlasAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(atlasPath);
        if (atlasAsset != null)
            ParseAtlasPages(atlasAsset.text, dir, entry);

        return entry;
    }

    /// <summary>
    /// 解析 atlas.txt 中所有 page 块，提取纹理文件名及声明尺寸。
    /// Spine atlas 格式：不含前导空格且末尾是图片扩展名的行 = 新页文件名；
    /// 紧随其后数行内出现 "size: W,H" = 该页尺寸。
    /// </summary>
    private void ParseAtlasPages(string atlasText, string dir, SpineEntry entry)
    {
        string[] lines = atlasText.Split('\n');

        for (int i = 0; i < lines.Length; i++)
        {
            string raw = lines[i].TrimEnd('\r');
            if (string.IsNullOrEmpty(raw)) continue;
            if (raw[0] == ' ' || raw[0] == '\t') continue;   // 缩进行 = region 属性
            if (!IsImageFilename(raw.Trim())) continue;        // 非图片文件名行

            string imageName = raw.Trim();
            int w = 0, h = 0;

            // 向后最多扫描 6 行找 size:
            for (int j = i + 1; j < lines.Length && j <= i + 6; j++)
            {
                string sline = lines[j].TrimEnd('\r').Trim();
                if (!sline.StartsWith("size:")) continue;

                string[] parts = sline.Substring(5).Trim().Split(',');
                if (parts.Length >= 2)
                {
                    int.TryParse(parts[0].Trim(), out w);
                    int.TryParse(parts[1].Trim(), out h);
                }
                break;
            }

            if (w <= 0 || h <= 0) continue;

            string texPath = dir + "/" + imageName;
            var importer = AssetImporter.GetAtPath(texPath) as TextureImporter;
            if (importer == null) continue;   // 纹理不在 AssetDatabase 中

            // 实际 GPU 尺寸受 maxTextureSize 限制，用有效尺寸判断是否超限
            int effectiveW = Mathf.Min(w, importer.maxTextureSize);
            int effectiveH = Mathf.Min(h, importer.maxTextureSize);
            bool tooLarge = effectiveW > maxAllowedSize || effectiveH > maxAllowedSize;

            // 若 npotScale 已设置为非 None，Unity 导入时会自动缩放到 POT，不再视为问题
            bool nonPOT = (!IsPowerOfTwo(w) || !IsPowerOfTwo(h))
                          && importer.npotScale == TextureImporterNPOTScale.None;

            if (nonPOT || tooLarge)
            {
                entry.texIssues.Add(new TexPageIssue
                {
                    texPath = texPath,
                    declaredWidth = w,
                    declaredHeight = h,
                    isNonPOT = nonPOT,
                    isTooLarge = tooLarge,
                    importer = importer,
                });
            }
        }
    }

    // ============================================================
    // 修复逻辑
    // ============================================================
    private void ApplyPresetToAll()
    {
        string folderRelPath = AssetDatabase.GetAssetPath(scanFolder);
        if (string.IsNullOrEmpty(folderRelPath)) return;

        // 收集所有 atlas.txt 引用的图集纹理路径（去重）
        string[] textAssetGuids = AssetDatabase.FindAssets("t:TextAsset", new[] { folderRelPath });
        var atlasPaths = textAssetGuids
            .Select(g => AssetDatabase.GUIDToAssetPath(g))
            .Where(p => p.EndsWith(".atlas.txt", System.StringComparison.OrdinalIgnoreCase))
            .ToArray();

        var texPaths = new HashSet<string>();
        foreach (string atlasPath in atlasPaths)
        {
            string dir = Path.GetDirectoryName(atlasPath).Replace('\\', '/');
            TextAsset atlasAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(atlasPath);
            if (atlasAsset == null) continue;

            foreach (string line in atlasAsset.text.Split('\n'))
            {
                string raw = line.TrimEnd('\r');
                if (string.IsNullOrEmpty(raw) || raw[0] == ' ' || raw[0] == '\t') continue;
                if (!IsImageFilename(raw.Trim())) continue;
                texPaths.Add(dir + "/" + raw.Trim());
            }
        }

        if (texPaths.Count == 0)
        {
            EditorUtility.DisplayDialog("未找到图集", "所选文件夹中未检测到任何 Spine 图集纹理。", "确定");
            return;
        }

        bool confirm = EditorUtility.DisplayDialog(
            "批量应用预设",
            $"将对 {texPaths.Count} 张图集纹理应用预设：\n{AssetDatabase.GetAssetPath(texImportPreset)}\n\n此操作会覆盖所有图集的 TextureImporter 设置，是否继续？",
            "确认应用", "取消");
        if (!confirm) return;

        int success = 0;
        int index = 0;
        try
        {
            foreach (string texPath in texPaths)
            {
                EditorUtility.DisplayProgressBar(
                    "批量应用预设",
                    $"({index + 1}/{texPaths.Count}) {Path.GetFileName(texPath)}",
                    (float)index / texPaths.Count);

                var importer = AssetImporter.GetAtPath(texPath) as TextureImporter;
                if (importer == null || !texImportPreset.CanBeAppliedTo(importer))
                {
                    Debug.LogWarning($"[SpineAudit] 预设不兼容，已跳过: {texPath}");
                    index++;
                    continue;
                }

                Undo.RecordObject(importer, "SpineAudit: Batch Apply Preset");
                texImportPreset.ApplyTo(importer);
                importer.SaveAndReimport();
                success++;
                index++;
            }
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }

        AssetDatabase.SaveAssets();
        if (hasScanned) RunScan();  // 若已有扫描结果则刷新
        EditorUtility.DisplayDialog(
            "批量应用完成",
            $"成功应用: {success} / {texPaths.Count} 张图集纹理。",
            "确定");
    }

    private void FixShadersOnly()
    {
        var targets = allEntries.Where(e => e.wrongShader).ToList();
        if (targets.Count == 0)
        {
            EditorUtility.DisplayDialog("无需修复", "所有材质 Shader 均已通过检测。", "确定");
            return;
        }

        foreach (var entry in targets)
            FixShader(entry);

        AssetDatabase.SaveAssets();
        RunScan();
        EditorUtility.DisplayDialog("修复完成", $"已修复 {targets.Count} 个材质的 Shader，图集导入设置未做任何变动。", "确定");
    }

    private void FixAll()
    {
        bool hasTexIssues = allEntries.Any(e => e.texIssues.Any(t => t.isTooLarge));
        bool skipTexFix = false;

        if (hasTexIssues && texImportPreset == null)
        {
            bool cont = EditorUtility.DisplayDialog(
                "未指定图集导入预设",
                "存在图集尺寸超限问题，但尚未指定「图集导入预设」，将跳过图集修复。\n\n继续仅修复材质 Shader？",
                "继续", "取消");
            if (!cont) return;
            skipTexFix = true;
        }

        int count = 0;
        foreach (var entry in allEntries.Where(e => e.HasIssue).ToList())
        {
            if (entry.wrongShader)
                FixShader(entry);

            if (!skipTexFix)
            {
                foreach (var tex in entry.texIssues.Where(t => t.isTooLarge).ToList())
                    ApplyPresetToTexture(tex);
            }
            count++;
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        RunScan();
        EditorUtility.DisplayDialog("修复完成", $"已处理 {count} 个有问题的 Spine 资源，请核查结果。", "确定");
    }

    private void FixEntry(SpineEntry entry)
    {
        if (entry.wrongShader)
            FixShader(entry);

        // 仅处理尺寸超限；非二次幂问题须由人工判断后手动修复
        foreach (var tex in entry.texIssues.Where(t => t.isTooLarge).ToList())
            FixTextureTooLarge(tex);
    }

    private void FixShader(SpineEntry entry)
    {
        if (entry.material == null) return;

        Shader urpShader = Shader.Find(DEFAULT_FIX_SHADER);
        if (urpShader == null)
        {
            Debug.LogError($"[SpineAudit] 找不到 Shader: {DEFAULT_FIX_SHADER}，请确认 URP Spine Shader 已导入。");
            EditorUtility.DisplayDialog("修复失败",
                $"找不到 Shader:\n{DEFAULT_FIX_SHADER}\n请确认项目中已正确导入 Spine URP Shader 包。", "确定");
            return;
        }

        // 先完整保存旧 Shader 的所有属性值，换 Shader 后逐一回写
        // 这样可确保颜色、Fill、贴图偏移等参数在 Shader 替换后保持不变
        var savedProps = SaveMaterialProperties(entry.material);

        Undo.RecordObject(entry.material, "SpineAudit: Fix Shader");
        // 换 Shader：Unity 此时会将新 Shader 独有属性初始化为其默认值，这是预期行为。
        entry.material.shader = urpShader;
        // 将旧 Shader 的属性值回写到新 Shader 中同名的属性，保证颜色、Fill 等参数不变。
        // 新 Shader 独有的属性不在 savedProps 中，保持 Unity 赋予的默认值，这也是预期行为。
        RestoreMaterialProperties(entry.material, savedProps);
        EditorUtility.SetDirty(entry.material);

        entry.wrongShader = false;
        entry.currentShaderName = DEFAULT_FIX_SHADER;

        Debug.Log($"[SpineAudit] 已修复材质 Shader: {entry.matPath}");
    }

    // ---- 材质属性 Save / Restore ----

    private struct MatPropData
    {
        public string name;
        public ShaderUtil.ShaderPropertyType type;
        public Color colorVal;
        public Vector4 vectorVal;
        public float floatVal;
        public int intVal;
        public Texture texVal;
        public Vector2 texOffset;
        public Vector2 texScale;
    }

    /// <summary>
    /// 遍历材质当前 Shader 的所有属性并记录其当前值。
    /// </summary>
    private static List<MatPropData> SaveMaterialProperties(Material mat)
    {
        var result = new List<MatPropData>();
        Shader shader = mat.shader;
        int count = ShaderUtil.GetPropertyCount(shader);
        for (int i = 0; i < count; i++)
        {
            var d = new MatPropData
            {
                name = ShaderUtil.GetPropertyName(shader, i),
                type = ShaderUtil.GetPropertyType(shader, i),
            };

            switch (d.type)
            {
                case ShaderUtil.ShaderPropertyType.Color:
                    d.colorVal = mat.GetColor(d.name);
                    break;
                case ShaderUtil.ShaderPropertyType.Vector:
                    d.vectorVal = mat.GetVector(d.name);
                    break;
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:
                    d.floatVal = mat.GetFloat(d.name);
                    break;
                case ShaderUtil.ShaderPropertyType.TexEnv:
                    d.texVal    = mat.GetTexture(d.name);
                    d.texOffset = mat.GetTextureOffset(d.name);
                    d.texScale  = mat.GetTextureScale(d.name);
                    break;
#if UNITY_2021_1_OR_NEWER
                case ShaderUtil.ShaderPropertyType.Int:
                    d.intVal = mat.GetInt(d.name);
                    break;
#endif
            }
            result.Add(d);
        }
        return result;
    }

    /// <summary>
    /// 将保存的属性值回写到材质（仅写入新 Shader 中同名属性，跳过不存在的）。
    /// </summary>
    private static void RestoreMaterialProperties(Material mat, List<MatPropData> props)
    {
        foreach (var d in props)
        {
            if (!mat.HasProperty(d.name)) continue;

            switch (d.type)
            {
                case ShaderUtil.ShaderPropertyType.Color:
                    mat.SetColor(d.name, d.colorVal);
                    break;
                case ShaderUtil.ShaderPropertyType.Vector:
                    mat.SetVector(d.name, d.vectorVal);
                    break;
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:
                    mat.SetFloat(d.name, d.floatVal);
                    break;
                case ShaderUtil.ShaderPropertyType.TexEnv:
                    mat.SetTexture(d.name, d.texVal);
                    mat.SetTextureOffset(d.name, d.texOffset);
                    mat.SetTextureScale(d.name, d.texScale);
                    break;
#if UNITY_2021_1_OR_NEWER
                case ShaderUtil.ShaderPropertyType.Int:
                    mat.SetInt(d.name, d.intVal);
                    break;
#endif
            }
        }
    }

    private bool FixTextureTooLarge(TexPageIssue tex)
    {
        bool ok = ApplyPresetToTexture(tex);
        if (ok) Debug.Log($"[SpineAudit] 已对图集应用预设（尺寸修复）: {tex.texPath}");
        return ok;
    }

    private bool ApplyPresetToTexture(TexPageIssue tex)
    {
        if (texImportPreset == null)
        {
            EditorUtility.DisplayDialog("未指定预设",
                "请先在「图集导入预设」字段中指定一个 TextureImporter Preset。", "确定");
            return false;
        }
        if (tex.importer == null) return false;
        if (!texImportPreset.CanBeAppliedTo(tex.importer))
        {
            EditorUtility.DisplayDialog("预设类型不兼容",
                "所选 Preset 无法应用到 TextureImporter，请确认使用的是 Texture 类型的 Preset。", "确定");
            return false;
        }

        Undo.RecordObject(tex.importer, "SpineAudit: Apply Preset");
        texImportPreset.ApplyTo(tex.importer);
        tex.importer.SaveAndReimport();

        tex.isTooLarge = false;
        tex.isNonPOT = false;
        return true;
    }

    private bool FixTextureNonPOT(TexPageIssue tex)
    {
        if (tex.importer == null) return false;

        bool proceed = EditorUtility.DisplayDialog(
            "修复非二次幂图集",
            $"将对以下图集应用导入预设（请确认预设中已正确设置 Non-Power of 2 选项）：\n{tex.texPath}\n\n" +
            "建议先在 Spine 编辑器中重新导出 POT 尺寸的图集，以确保像素坐标对齐精度。\n\n" +
            "是否继续应用预设？",
            "继续修复", "取消");

        if (!proceed) return false;

        bool ok = ApplyPresetToTexture(tex);
        if (ok) Debug.Log($"[SpineAudit] 已对图集应用预设（非POT修复）: {tex.texPath}");
        return ok;
    }

    // ============================================================
    // 工具方法
    // ============================================================
    private static bool IsImageFilename(string name)
    {
        return name.EndsWith(".png", System.StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".jpg", System.StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".jpeg", System.StringComparison.OrdinalIgnoreCase)
            || name.EndsWith(".webp", System.StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

    private static void PingAsset(string assetPath)
    {
        var obj = AssetDatabase.LoadAssetAtPath<Object>(assetPath);
        if (obj != null) EditorGUIUtility.PingObject(obj);
    }

    private static void DrawHorizontalLine()
    {
        var rect = EditorGUILayout.GetControlRect(false, 1f);
        EditorGUI.DrawRect(rect, new Color(0.45f, 0.45f, 0.45f, 0.6f));
        EditorGUILayout.Space(2);
    }
}
#endif
