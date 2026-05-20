using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

#if UNITY_EDITOR
public class LootBootVFXtoExcel : EditorWindow
{
    // ── Python 未找到时的统一提示（退出码 9009）────────────────
    private const string PYTHON_NOT_FOUND_MSG =
        "找不到 python 命令（退出码 9009），请确认：\n" +
        "1. Python 已安装并已加入系统 PATH\n" +
        "2. 使用 python.org 版本，而非 Windows Store 版\n" +
        "   （Store 版存根程序在 Unity 子进程中无法正常运行）\n" +
        "3. 安装后重启 Unity";

    // ── 拖入的预制体 ──────────────────────────────────────────
    private GameObject droppedPrefab;

    // ── 预制体缓存匹配结果 ────────────────────────────────────
    private VFXRowData cachedMatchedRow = null;
    private string prefabMatchWarning = "";

    // ── 10 项配置字段 ─────────────────────────────────────────
    private string fieldId = "";
    private string fieldRemark = "";
    private string fieldName = "";
    private string fieldResource = "";
    private int fieldVFXType;          // 下拉 0-2
    private string fieldRangeSize = "";
    private string fieldScaleFactor = "";
    private int fieldAttachPoint;      // 下拉 0-1
    private int fieldRotationRule;     // 下拉 0-2
    private string fieldSoundId = "";

    // ── 下拉选项 ──────────────────────────────────────────────
    private static readonly string[] VFX_TYPE_OPTIONS =
        { "0 - Spine特效", "1 - 粒子特效", "2 - 复合特效" };

    private static readonly string[] ATTACH_POINT_OPTIONS =
        { "0 - 物体原点", "1 - 物体中心点", "2 - 物体头部" };

    private static readonly string[] ROTATION_RULE_OPTIONS =
        { "0 - 不旋转", "1 - 旋转不翻转", "2 - 旋转并翻转" };

    // ── 滚动位置 ──────────────────────────────────────────────
    private Vector2 scrollPos;

    // ── Excel 路径 ────────────────────────────────────────────
    private string excelPath = "";
    private const string PREF_EXCEL_PATH = "LootBootVFXtoExcel_ExcelPath";

    // ── Python 脚本路径（固定在项目内部，与 Excel 位置无关）────────
    private string scriptPath = "";

    // ── 全量缓存 JSON 路径（与脚本同目录，固定路径）──────────────
    private string cachePath = "";

    // ── 菜单入口 ──────────────────────────────────────────────
    [MenuItem("TATools/VFXTools/VFXtoExcel自动填表工具")]
    public static void OpenWindow()
    {
        var window = GetWindow<LootBootVFXtoExcel>("VFX自动配表工具");
        window.minSize = new Vector2(420f, 520f);
        window.Show();
    }

    private void OnEnable()
    {
        excelPath = EditorPrefs.GetString(PREF_EXCEL_PATH, "");
        if (string.IsNullOrEmpty(excelPath))
            excelPath = Path.Combine(Application.dataPath, "VFXTemp", "Effect.xls").Replace('\\', '/');

        // Python 脚本固定在项目内 VFXTools 目录，与 Excel 文件位置无关
        scriptPath = Path.Combine(Application.dataPath, "Editor/VFXTools/VFXtoExcelAutoFilled", "vfx_excel_tool.py").Replace('\\', '/');
        // 缓存放在 Library/ 下，避免 Unity/Spine 将其当作资产导入
        cachePath  = Path.GetFullPath(Path.Combine(Application.dataPath, "..", "Library", "VFXTool", "vfx_cache.json")).Replace('\\', '/');

        // 设置窗口标签图标
        var iconContent = EditorGUIUtility.IconContent("ParticleSystem Icon");
        titleContent = new GUIContent("VFX自动配表工具", iconContent.image);
    }

    private void OnGUI()
    {
        float savedLabelWidth = EditorGUIUtility.labelWidth;
        EditorGUIUtility.labelWidth = 148f;

        // ── Excel 路径行 ──────────────────────────────────────
        EditorGUILayout.Space(6f);
        using (new EditorGUILayout.HorizontalScope())
        {
            EditorGUILayout.LabelField("Excel 路径", GUILayout.Width(68f));
            EditorGUI.BeginChangeCheck();
            excelPath = EditorGUILayout.TextField(excelPath);
            if (EditorGUI.EndChangeCheck())
                EditorPrefs.SetString(PREF_EXCEL_PATH, excelPath);
            if (GUILayout.Button("浏览", GUILayout.Width(44f)))
            {
                string selected = EditorUtility.OpenFilePanel("选择 Excel 文件",
                    Path.GetDirectoryName(excelPath), "xls");
                if (!string.IsNullOrEmpty(selected))
                {
                    excelPath = selected;
                    EditorPrefs.SetString(PREF_EXCEL_PATH, excelPath);
                }
            }
        }
        // ── 清除配置按钮 ──────────────────────────────────────
        Color savedBg = GUI.backgroundColor;
        GUI.backgroundColor = new Color(0.75f, 0.75f, 0.75f);
        if (GUILayout.Button(new GUIContent("清除配置",
            "清空所有已填写的配置字段并重置为默认值。\nExcel 路径保持不变。"), GUILayout.Height(24f)))
            ClearAllFields();
        GUI.backgroundColor = savedBg;

        EditorGUILayout.Space(6f);

        // ── 预制体选择（ObjectField）──────────────────────────
        GameObject newPrefab;
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField("特效预制体", EditorStyles.boldLabel);
            newPrefab = (GameObject)EditorGUILayout.ObjectField(
                droppedPrefab, typeof(GameObject), false);
            if (droppedPrefab != null)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    Color savedBtnBg = GUI.backgroundColor;
                    GUI.backgroundColor = new Color(0.35f, 0.85f, 0.35f);
                    if (GUILayout.Button(new GUIContent("添加新配置",
                        "重读预制体信息（名称、资源路径、特效类型、范围大小），并分配新 ID（末尾 ID + 10）。"),
                        GUILayout.Height(22f)))
                    {
                        prefabMatchWarning = "";
                        AutoFillFromPrefab(droppedPrefab, true);
                    }
                    GUI.backgroundColor = new Color(0.2f, 0.75f, 0.9f);
                    if (GUILayout.Button(new GUIContent("变更新配置",
                        "重读预制体信息（资源路径、特效类型、范围大小），保留当前 ID 与名称不变。"),
                        GUILayout.Height(22f)))
                    {
                        prefabMatchWarning = "";
                        AutoFillFromPrefab(droppedPrefab, false);
                    }
                    GUI.backgroundColor = new Color(1f, 0.6f, 0.15f);
                    if (GUILayout.Button(new GUIContent("读取已有配置",
                        "将界面配置项还原为缓存中该预制体对应行的数据（含 ID）。"),
                        GUILayout.Height(22f)))
                    {
                        if (cachedMatchedRow != null)
                            FillFromRowData(cachedMatchedRow);
                        else
                            EditorUtility.DisplayDialog("无法读取配置",
                                string.IsNullOrEmpty(prefabMatchWarning)
                                    ? "没有已匹配的缓存数据，无法读取配置。"
                                    : prefabMatchWarning,
                                "确定");
                    }
                    GUI.backgroundColor = savedBtnBg;
                }
            }
        }
        if (newPrefab != droppedPrefab)
        {
            droppedPrefab = newPrefab;
            if (newPrefab != null)
                DoAutoMatchFromCache(newPrefab);
            else
            {
                cachedMatchedRow   = null;
                prefabMatchWarning = "";
            }
        }

        EditorGUILayout.Space(6f);
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        // ── 基础信息 ───────────────────────────
        EditorGUILayout.LabelField("基础信息", EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            fieldId = EditorGUILayout.TextField(
                new GUIContent("ID", "特效配置唯一标识符，每条记录不允许重复。新增时会自动填入当前最大 ID + 10。\n只接受整数，留空默认写入 0。"),
                fieldId);
            fieldName = EditorGUILayout.TextField(
                new GUIContent("名称", "特效配置的唯一名称，不允许与已有记录重名。拖入预制体时自动填入预制体名称。"),
                fieldName);
            fieldVFXType = EditorGUILayout.Popup(
                new GUIContent("特效类型", "0 - Spine骨骼动画特效\n1 - 粒子系统特效\n2 - 复合特效（含 SpriteRenderer 子节点）\n拖入预制体时自动检测。"),
                fieldVFXType, VFX_TYPE_OPTIONS);

        }

        EditorGUILayout.Space(6f);

        // ── 资源路径 ──────────────────────────────────────────
        EditorGUILayout.LabelField(
            new GUIContent("资源路径", "预制体在工程中的相对路径，省略前缀 Assets/GameAsset/Effect/ 以及 .prefab 后缀。\n拖入预制体时自动填入。"),
            EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField("省略前缀 Assets/GameAsset/Effect/", EditorStyles.miniLabel);
            fieldResource = EditorGUILayout.TextArea(fieldResource, GUILayout.MinHeight(36f));
        }

        EditorGUILayout.Space(6f);

        // ── 参数配置 ──────────────────────────────────────────
        EditorGUILayout.LabelField("参数配置", EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            // 两列：范围大小 | 缩放系数
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUIUtility.labelWidth = 68f;
                fieldRangeSize = EditorGUILayout.TextField(
                    new GUIContent("范围大小", "特效影响半径 × 100 的整数值。\n例如半径 1.5 单位 → 填入 150。\n拖入预制体时从根物体 CircleCollider2D.radius 自动读取。\n只接受整数，留空默认写入 0。"),
                    fieldRangeSize);
                GUILayout.Space(8f);
                EditorGUIUtility.labelWidth = 72f;
                fieldScaleFactor = EditorGUILayout.TextField(
                    new GUIContent("缩放（×100）", "特效播放时的百分比缩放系数 × 100 的整数值。\n例如缩放 1.0 倍 → 填入 100；缩放 1.5 倍 → 填入 150。\n只接受整数，留空默认写入 0。"),
                    fieldScaleFactor);
                EditorGUIUtility.labelWidth = 148f;
            }
            fieldAttachPoint = EditorGUILayout.Popup(
                new GUIContent("特效挂接点", "0 - 物体原点：特效跟随目标物体的 Transform 原点\n1 - 物体中心点：特效跟随目标物体的视觉中心（Renderer Bounds Center）\n2 - 物体头部：特效挂载至目标物体头顶位置"),
                fieldAttachPoint, ATTACH_POINT_OPTIONS);
            fieldRotationRule = EditorGUILayout.Popup(
                new GUIContent("旋转规则", "0 - 不旋转：特效始终保持原始朝向\n1 - 旋转不翻转：特效跟随施放方向旋转，但不做镜像翻转\n2 - 旋转并翻转：特效旋转，同时根据朝向做水平镜像翻转"),
                fieldRotationRule, ROTATION_RULE_OPTIONS);
            EditorGUIUtility.labelWidth = 60f;
            fieldSoundId = EditorGUILayout.TextField(
                new GUIContent("音效 ID", "与该特效绑定播放的音效配置 ID。\n只接受整数，留空默认写入 0。"),
                fieldSoundId);
            EditorGUIUtility.labelWidth = 148f;
        }

        EditorGUILayout.Space(6f);

        // ── 备注 ──────────────────────────────────────────────
        EditorGUILayout.LabelField(new GUIContent("备注"), EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            fieldRemark = EditorGUILayout.TextArea(fieldRemark, GUILayout.MinHeight(40f));
        }

        EditorGUILayout.EndScrollView();

        EditorGUIUtility.labelWidth = savedLabelWidth;

        // ── 预制体匹配警告 ────────────────────────────────────
        if (!string.IsNullOrEmpty(prefabMatchWarning))
            EditorGUILayout.HelpBox(prefabMatchWarning, MessageType.Warning);

        // ── 操作按钮 ──────────────────────────────────────────
        GUILayout.FlexibleSpace();
        Color defaultBgColor = GUI.backgroundColor;

        using (new EditorGUILayout.HorizontalScope())
        {
            GUI.backgroundColor = new Color(0.35f, 0.85f, 0.35f);
            if (GUILayout.Button("保存配置", GUILayout.Height(32f)))
                SaveToExcel();

            GUI.backgroundColor = new Color(1f, 0.6f, 0.15f);
            if (GUILayout.Button("覆盖配置", GUILayout.Height(32f)))
                OverwriteToExcel();

            GUI.backgroundColor = defaultBgColor;
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            Color savedBgPrev = GUI.backgroundColor;
            GUI.backgroundColor = new Color(0.25f, 0.55f, 1f);
            if (GUILayout.Button(new GUIContent("预览表格",
                "打开全表预览窗口，可浏览 Excel 中所有特效配置，支持实时搜索。"),
                GUILayout.Height(26f)))
                OpenPreviewTable();

            GUI.backgroundColor = savedBgPrev;
        }

        if (GUILayout.Button("打开 Excel", GUILayout.Height(26f)))
            OpenExcel();

        EditorGUILayout.Space(4f);
    }

    /// <summary>
    /// 清空所有配置字段，恢复默认值（Excel 路径保持不变）。
    /// </summary>
    private void ClearAllFields()
    {
        droppedPrefab     = null;
        fieldId           = "";
        fieldRemark       = "";
        fieldName         = "";
        fieldResource     = "";
        fieldVFXType      = 0;
        fieldRangeSize    = "";
        fieldScaleFactor  = "";
        fieldAttachPoint  = 0;
        fieldRotationRule = 0;
        fieldSoundId      = "";
        scrollPos         = Vector2.zero;
        cachedMatchedRow   = null;
        prefabMatchWarning = "";
    }

    /// <summary>
    /// 根据预制体填写配置字段。
    /// fillIdAndName = true（新增模式）：同时填写名称与自动 ID；
    /// fillIdAndName = false（覆盖模式）：只更新资源路径、特效类型、范围大小，保持 ID 与名称不变。
    /// </summary>
    private void AutoFillFromPrefab(GameObject prefab, bool fillIdAndName)
    {
        // ── 1. 资源路径（省略 Assets/GameAsset/Effect/ 前缀）─────
        const string PATH_PREFIX = "Assets/GameAsset/Effect/";
        string fullPath = AssetDatabase.GetAssetPath(prefab);
        if (!string.IsNullOrEmpty(fullPath))
        {
            string relativePath = fullPath.StartsWith(PATH_PREFIX)
                ? fullPath.Substring(PATH_PREFIX.Length)
                : fullPath;
            // 去除 .prefab 后缀
            if (relativePath.EndsWith(".prefab"))
                relativePath = relativePath.Substring(0, relativePath.Length - ".prefab".Length);
            fieldResource = relativePath;
        }

        // ── 2. 原始特效范围大小（仅读预制体根物体上的 CircleCollider2D）──
        var col = prefab.GetComponent<CircleCollider2D>();
        if (col != null)
            fieldRangeSize = Mathf.RoundToInt(col.radius * 100f).ToString();
        // 若根物体无此组件则保持原值不变

        // ── 3. 特效类型（优先级：Spine > 粒子 > 复合）─────────────
        fieldVFXType = DetectVFXType(prefab);

        // ── 4. 名称与 ID（仅新增模式）────────────────────────────
        if (fillIdAndName)
        {
            fieldName = prefab.name;
            if (File.Exists(excelPath) && File.Exists(scriptPath))
            {
                int nextId = ReadNextIdFromExcel(scriptPath, excelPath);
                if (nextId >= 0)
                    fieldId = nextId.ToString();
            }
        }
    }

    /// <summary>
    /// 通过组件分析判断特效类型。
    /// 0 = Spine特效，1 = 粒子特效，2 = 复合特效。
    /// 判断优先级：Spine组件存在 → 0；
    /// 根物体有 SpriteRenderer → 2（复合）；
    /// 其余（全为粒子系统） → 1。
    /// </summary>
    private static int DetectVFXType(GameObject prefab)
    {
        // 检测 Spine：通过组件类型名判断，避免硬引用 Spine 程序集
        Component[] allComponents = prefab.GetComponentsInChildren<Component>(true);
        foreach (Component c in allComponents)
        {
            if (c == null) continue;
            string typeName = c.GetType().FullName ?? "";
            if (typeName.Contains("Skeleton") && typeName.StartsWith("Spine"))
                return 0;
        }

        // 检测子物体（不含根物体）是否带 SpriteRenderer（复合特效特征）
        // Spine 已在上方排除，此处无需再判断 Spine
        bool childHasSprite = false;
        foreach (Transform child in prefab.GetComponentsInChildren<Transform>(true))
        {
            if (child.gameObject == prefab) continue;
            if (child.GetComponent<SpriteRenderer>() != null)
            {
                childHasSprite = true;
                break;
            }
        }
        if (childHasSprite)
            return 2;

        // 默认认为是粒子特效
        return 1;
    }

    /// <summary>
    /// 覆盖写入：检查 id 是否已存在，二次确认后覆盖对应行。
    /// </summary>
    private void OverwriteToExcel()
    {
        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", $"Excel 文件路径无效，请检查路径设置。\n当前路径：{excelPath}", "确定");
            return;
        }

        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        // ── 第一步：查询 id 是否存在 ──────────────────────────
        if (string.IsNullOrWhiteSpace(fieldId) || !int.TryParse(fieldId.Trim(), out int overwriteId))
        {
            EditorUtility.DisplayDialog("错误", "覆盖操作需要填写有效的 ID（整数）。", "确定");
            return;
        }

        string existingName = CheckIdExists(scriptPath, excelPath, overwriteId);
        if (existingName == null)
        {
            EditorUtility.DisplayDialog("错误", "检查 ID 时发生错误，请查看控制台输出。", "确定");
            return;
        }

        if (existingName == "NOT_FOUND")
        {
            EditorUtility.DisplayDialog("未找到", $"表中不存在 ID 为 {fieldId} 的数据，无法覆盖。\n如需新增请使用「保存配置」。", "确定");
            return;
        }

        // ── 第二步：二次确认 ──────────────────────────────────
        bool confirmed = EditorUtility.DisplayDialog(
            "确认覆盖",
            $"已有 id={overwriteId}（名称：{existingName}）的数据，是否需要覆盖？",
            "覆盖", "取消");

        if (!confirmed)
            return;

        // ── 第三步：执行覆盖写入 ──────────────────────────────
        var sb = new StringBuilder();
        sb.Append("{");
        sb.Append($"\"id\":{IntFieldToJson(fieldId)},");
        sb.Append($"\"remark\":\"{EscapeJson(fieldRemark)}\",");
        sb.Append($"\"name\":\"{EscapeJson(fieldName)}\",");
        sb.Append($"\"resource\":\"{EscapeJson(fieldResource)}\",");
        sb.Append($"\"vfxType\":{fieldVFXType},");
        sb.Append($"\"rangeSize\":{IntFieldToJson(fieldRangeSize)},");
        sb.Append($"\"scaleFactor\":{IntFieldToJson(fieldScaleFactor)},");
        sb.Append($"\"attachPoint\":{fieldAttachPoint},");
        sb.Append($"\"rotationRule\":{fieldRotationRule},");
        sb.Append($"\"soundId\":{IntFieldToJson(fieldSoundId)}");
        sb.Append("}");

        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson, sb.ToString(), new UTF8Encoding(false));

            var psi = BuildPsi(scriptPath, $"--overwrite \"{excelPath}\" \"{tempJson}\"");

            using (var proc = Process.Start(psi))
            {
                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode == 0)
                {
                    EditorUtility.DisplayDialog("成功", "配置已成功覆盖写入 Excel。", "确定");
                    RefreshCache();
                    OpenPreviewTable(overwriteId);
                }
                else if (proc.ExitCode == 9009)
                {
                    EditorUtility.DisplayDialog("覆盖失败", PYTHON_NOT_FOUND_MSG, "确定");
                }
                else
                {
                    string msg = stdout.Trim();
                    if (string.IsNullOrEmpty(msg)) msg = stderr.Trim();
                    EditorUtility.DisplayDialog("覆盖失败", string.IsNullOrEmpty(msg)
                        ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）" : msg, "确定");
                }
            }
        }
        finally
        {
            if (File.Exists(tempJson))
                File.Delete(tempJson);
        }
    }

    /// <summary>
    /// 调用 Python 检查指定 id 是否存在。
    /// 返回已有行的名称字符串，"NOT_FOUND" 表示不存在，null 表示调用失败。
    /// </summary>
    private static string CheckIdExists(string scriptPath, string excelPath, int id)
    {
        var psi = BuildPsi(scriptPath, $"--check-id \"{excelPath}\" {id}");

        try
        {
            using (var proc = Process.Start(psi))
            {
                string output = proc.StandardOutput.ReadToEnd().Trim();
                proc.WaitForExit();
                return proc.ExitCode == 0 ? output : null;
            }
        }
        catch { return null; }
    }

    /// <summary>
    /// 将配置写入 Excel（通过 Python 中间脚本）。
    /// </summary>
    private void SaveToExcel()
    {
        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", $"Excel 文件路径无效，请检查路径设置。\n当前路径：{excelPath}", "确定");
            return;
        }

        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        // 构建 JSON 数据
        var sb = new StringBuilder();
        sb.Append("{");
        sb.Append($"\"id\":{IntFieldToJson(fieldId)},");
        sb.Append($"\"remark\":\"{EscapeJson(fieldRemark)}\",");
        sb.Append($"\"name\":\"{EscapeJson(fieldName)}\",");
        sb.Append($"\"resource\":\"{EscapeJson(fieldResource)}\",");
        sb.Append($"\"vfxType\":{fieldVFXType},");
        sb.Append($"\"rangeSize\":{IntFieldToJson(fieldRangeSize)},");
        sb.Append($"\"scaleFactor\":{IntFieldToJson(fieldScaleFactor)},");
        sb.Append($"\"attachPoint\":{fieldAttachPoint},");
        sb.Append($"\"rotationRule\":{fieldRotationRule},");
        sb.Append($"\"soundId\":{IntFieldToJson(fieldSoundId)}");
        sb.Append("}");

        // 写入临时 JSON 文件（避免命令行转义问题）
        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson, sb.ToString(), new UTF8Encoding(false));
            string error = RunPythonScript(scriptPath, excelPath, tempJson);
            if (error != null)
                EditorUtility.DisplayDialog("写入失败", error, "确定");
            else
            {
                EditorUtility.DisplayDialog("成功", "配置已成功写入 Excel。", "确定");
                RefreshCache();
                if (int.TryParse(fieldId.Trim(), out int savedId))
                    OpenPreviewTable(savedId);
            }
        }
        finally
        {
            if (File.Exists(tempJson))
                File.Delete(tempJson);
        }
    }

    /// <summary>
    /// 用系统默认应用打开 Excel 文件。
    /// </summary>
    private void OpenExcel()
    {
        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", $"Excel 文件路径无效，请检查路径设置。\n当前路径：{excelPath}", "确定");
            return;
        }
        Process.Start(new ProcessStartInfo(excelPath) { UseShellExecute = true });
    }

    /// <summary>
    /// 调用 Python 脚本，返回 null 表示成功，否则返回错误信息。
    /// </summary>
    private static string RunPythonScript(string scriptPath, string excelPath, string jsonFilePath)
    {
        var psi = BuildPsi(scriptPath, $"\"{excelPath}\" \"{jsonFilePath}\"");

        try
        {
            using (var proc = Process.Start(psi))
            {
                if (proc == null)
                    return "启动 Python 进程失败（返回 null），请确认 Python 已正确安装。";
                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode == 0)
                    return null;

                if (proc.ExitCode == 9009)
                    return PYTHON_NOT_FOUND_MSG;

                string msg = stdout.Trim();
                if (string.IsNullOrEmpty(msg))
                    msg = stderr.Trim();
                return string.IsNullOrEmpty(msg)
                    ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                    : msg;
            }
        }
        catch (System.Exception ex)
        {
            return $"启动 Python 进程失败，请确认 python 已安装并已加入系统 PATH（注意：Windows Store 版 Python 无法被 Unity 子进程调用，需从 python.org 重新安装）。\n详情：{ex.Message}";
        }
    }

    /// <summary>
    /// 将行数据填回界面所有字段。
    /// </summary>
    internal void FillFromRowData(VFXRowData row)
    {
        fieldId           = row.id;
        fieldRemark       = row.remark;
        fieldName         = row.name;
        fieldResource     = row.resource;
        fieldRangeSize    = row.rangeSize;
        fieldScaleFactor  = row.scaleFactor;
        fieldSoundId      = row.soundId;

        if (int.TryParse(row.vfxType, out int vt) && vt >= 0 && vt < VFX_TYPE_OPTIONS.Length)
            fieldVFXType = vt;
        if (int.TryParse(row.attachPoint, out int ap) && ap >= 0 && ap < ATTACH_POINT_OPTIONS.Length)
            fieldAttachPoint = ap;
        if (int.TryParse(row.rotationRule, out int rr) && rr >= 0 && rr < ROTATION_RULE_OPTIONS.Length)
            fieldRotationRule = rr;

        Repaint();
    }

    /// <summary>特效配置行的数据模型，供预览窗口回填及序列化使用。</summary>
    [System.Serializable]
    internal class VFXRowData
    {
        public string id;
        public string remark;
        public string name;
        public string resource;
        public string vfxType;
        public string rangeSize;
        public string scaleFactor;
        public string attachPoint;
        public string rotationRule;
        public string soundId;
    }

    /// <summary>JSON 缓存数组的包装器，供 QuickPreview 反序列化使用。</summary>
    [System.Serializable]
    private class VFXRowDataList
    {
        public VFXRowData[] items;
    }

    /// <summary>
    /// 构建子进程启动配置。若同目录存在 vfx_excel_tool.exe（PyInstaller 打包产物）则直接调用，
    /// 否则回退到 python 命令 + 脚本路径，实现无缝降级。
    /// </summary>
    private static ProcessStartInfo BuildPsi(string scriptPath, string pythonArgs)
    {
        string dir     = Path.GetDirectoryName(scriptPath) ?? "";
        string exePath = Path.Combine(dir, "vfx_excel_tool.exe");
        bool   useExe  = File.Exists(exePath);
        var psi = new ProcessStartInfo
        {
            FileName               = useExe ? exePath : "python",
            Arguments              = useExe ? pythonArgs : $"\"{scriptPath}\" {pythonArgs}",
            UseShellExecute        = false,
            RedirectStandardOutput = true,
            RedirectStandardError  = true,
            CreateNoWindow         = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding  = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";
        return psi;
    }

    private static string IntFieldToJson(string s) =>
        string.IsNullOrWhiteSpace(s) ? "null" : (int.TryParse(s.Trim(), out int v) ? v.ToString() : "null");

    private static string EscapeJson(string s)
    {
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
    }

    /// <summary>
    /// 调用 Python 脚本读取 Excel 最后一行 id + 10，失败时返回 -1。
    /// </summary>
    private static int ReadNextIdFromExcel(string scriptPath, string excelPath)
    {
        var psi = BuildPsi(scriptPath, $"--get-last-id \"{excelPath}\"");

        try
        {
            using (var proc = Process.Start(psi))
            {
                string output = proc.StandardOutput.ReadToEnd().Trim();
                proc.WaitForExit();
                if (proc.ExitCode == 0 && int.TryParse(output, out int result))
                    return result;
            }
        }
        catch { }

        return -1;
    }

    /// <summary>
    /// 将 Excel 全量数据导出为 JSON 缓存文件。
    /// 返回 null 表示成功；返回非 null 字符串表示具体失败原因。
    /// </summary>
    private string RefreshCache()
    {
        if (!File.Exists(excelPath))
            return $"Excel 文件不存在：{excelPath}";
        if (!File.Exists(scriptPath))
            return $"Python 脚本不存在：{scriptPath}";

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
                if (proc.ExitCode == 9009)
                    return PYTHON_NOT_FOUND_MSG;

                if (proc.ExitCode != 0)
                {
                    string msg = (string.IsNullOrWhiteSpace(stderr) ? stdout : stderr).Trim();
                    return string.IsNullOrEmpty(msg) ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）" : msg;
                }
                return null;
            }
        }
        catch (System.Exception ex)
        {
            return $"启动 Python 进程失败，请确认 python 已安装并已加入系统 PATH（注意：Windows Store 版 Python 无法被 Unity 子进程调用）。\n详情：{ex.Message}";
        }
    }

    /// <summary>
    /// 打开全表预览窗口。若缓存不存在则弹窗询问是否立即生成。
    /// </summary>
    /// <param name="highlightId">需高亮定位的行 ID；-1 表示不高亮。</param>
    private void OpenPreviewTable(int highlightId = -1)
    {
        if (!File.Exists(cachePath))
        {
            bool doRefresh = EditorUtility.DisplayDialog(
                "缓存不存在",
                "尚未生成数据缓存，是否立即从 Excel 导出？",
                "立即生成", "取消");
            if (!doRefresh) return;
            string cacheErr = RefreshCache();
            if (!File.Exists(cachePath))
            {
                string detail = string.IsNullOrEmpty(cacheErr)
                    ? "缓存文件未生成，原因未知。"
                    : cacheErr;
                EditorUtility.DisplayDialog("缓存生成失败", detail, "确定");
                return;
            }
        }
        VFXTablePreviewWindow.Open(cachePath, excelPath, scriptPath, FillFromRowData, highlightId);
    }

    /// <summary>
    /// 拖入预制体时，在缓存中按资源路径精确匹配：
    /// 恰好 1 条 → 自动回填所有字段并记录匹配行；0 条或多条 → 仅设置黄色警告，不改动字段。
    /// </summary>
    private void DoAutoMatchFromCache(GameObject prefab)
    {
        prefabMatchWarning = "";
        cachedMatchedRow   = null;

        if (!File.Exists(cachePath))
        {
            prefabMatchWarning = "缓存文件不存在，请先点击「预览表格」生成缓存，再拖入预制体进行匹配。";
            return;
        }

        const string PATH_PREFIX = "Assets/GameAsset/Effect/";
        string fullPath = AssetDatabase.GetAssetPath(prefab);
        if (string.IsNullOrEmpty(fullPath))
        {
            prefabMatchWarning = "无法获取预制体的资源路径，请确认预制体已保存到工程中。";
            return;
        }

        string resourcePath = fullPath.StartsWith(PATH_PREFIX)
            ? fullPath.Substring(PATH_PREFIX.Length)
            : fullPath;
        if (resourcePath.EndsWith(".prefab"))
            resourcePath = resourcePath.Substring(0, resourcePath.Length - ".prefab".Length);

        try
        {
            string json = File.ReadAllText(cachePath, Encoding.UTF8);
            VFXRowDataList list = JsonUtility.FromJson<VFXRowDataList>("{\"items\":" + json + "}");
            if (list?.items == null)
            {
                prefabMatchWarning = "缓存数据解析失败，请重新生成缓存。";
                return;
            }

            var matches = new List<VFXRowData>();
            foreach (var row in list.items)
            {
                if (row.resource == resourcePath)
                    matches.Add(row);
            }

            if (matches.Count == 0)
                prefabMatchWarning = $"未在缓存中找到匹配项（resource = \"{resourcePath}\"），可点击「添加新配置」新增。";
            else if (matches.Count > 1)
                prefabMatchWarning = $"找到 {matches.Count} 条匹配项（resource = \"{resourcePath}\"），无法自动回填，请从「预览表格」手动选择。";
            else
            {
                cachedMatchedRow = matches[0];
                FillFromRowData(cachedMatchedRow);
            }
        }
        catch (System.Exception ex)
        {
            prefabMatchWarning = $"读取缓存时出错：{ex.Message}";
        }
    }

}

#endif