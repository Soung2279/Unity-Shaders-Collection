using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

public class LootBootVFXtoExcel : EditorWindow
{
    // ── 拖入的预制体 ──────────────────────────────────────────
    private GameObject droppedPrefab;

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
        { "0 - 物体原点", "1 - 物体中心点" };

    private static readonly string[] ROTATION_RULE_OPTIONS =
        { "0 - 不旋转", "1 - 旋转不翻转", "2 - 旋转并翻转" };

    // ── 滚动位置 ──────────────────────────────────────────────
    private Vector2 scrollPos;

    // ── 备注搜索关键字 ────────────────────────────────────
    private string searchKeyword = "";

    // ── Excel 路径 ────────────────────────────────────────────
    private string excelPath = "";

    // ── Python 脚本路径（固定在项目内部，与 Excel 位置无关）────────
    private string scriptPath = "";

    // ── 菜单入口 ──────────────────────────────────────────────
    [MenuItem("工具/VFXTools/VFXtoExcel自动填表工具")]
    public static void OpenWindow()
    {
        var window = GetWindow<LootBootVFXtoExcel>("VFX自动配表工具");
        window.minSize = new Vector2(420f, 520f);
        window.Show();
    }

    private void OnEnable()
    {
        if (string.IsNullOrEmpty(excelPath))
            excelPath = Path.Combine(Application.dataPath, "VFXTemp", "Effect.xls").Replace('\\', '/');

        // Python 脚本固定在项目内 VFXTools 目录，与 Excel 文件位置无关
        scriptPath = Path.Combine(Application.dataPath, "GameAsset/VFXTemp/VFXTools", "vfx_excel_tool.py").Replace('\\', '/');

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
            excelPath = EditorGUILayout.TextField(excelPath);
            if (GUILayout.Button("浏览", GUILayout.Width(44f)))
            {
                string selected = EditorUtility.OpenFilePanel("选择 Excel 文件",
                    Path.GetDirectoryName(excelPath), "xls");
                if (!string.IsNullOrEmpty(selected))
                    excelPath = selected;
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
        }
        if (newPrefab != droppedPrefab)
        {
            droppedPrefab = newPrefab;
            if (newPrefab != null)
            {
                fieldName = newPrefab.name;
                AutoFillFromPrefab(newPrefab);
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

            // ── 搜索ID / 搜索名称 按钮 ──────────
            Color savedBgQuery = GUI.backgroundColor;
            GUI.backgroundColor = new Color(0.25f, 0.55f, 1f);
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button(new GUIContent("搜索 ID",
                    "从 Excel 读取与当前 ID 匹配的行，并将全部字段填回界面。\n此操作只读取 Excel，不修改任何表中数据。"),
                    GUILayout.Height(26f)))
                    QueryById();
                if (GUILayout.Button(new GUIContent("搜索名称",
                    "从 Excel 读取与当前名称精确匹配的行，并将全部字段填回界面。\n此操作只读取 Excel，不修改任何表中数据。"),
                    GUILayout.Height(26f)))
                    QueryByName();
            }
            GUI.backgroundColor = savedBgQuery;
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
                new GUIContent("特效挂接点", "0 - 物体原点：特效跟随目标物体的 Transform 原点\n1 - 物体中心点：特效跟随目标物体的视觉中心（Renderer Bounds Center）"),
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

        EditorGUILayout.Space(6f);

        // ── 检索特效 ──────────────────────────────────────────────
        EditorGUILayout.LabelField("检索特效", EditorStyles.boldLabel);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUIUtility.labelWidth = 60f;
                searchKeyword = EditorGUILayout.TextField(
                    new GUIContent("搜索关键字", "输入关键字，将在 Excel 备注列中进行模糊搜索。"),
                    searchKeyword);
                EditorGUIUtility.labelWidth = 148f;
                Color savedBgSearch = GUI.backgroundColor;
                GUI.backgroundColor = new Color(1f, 0.9f, 0.2f);
                if (GUILayout.Button(new GUIContent("搜索特效",
                    "在 Excel 的备注列中模糊搜索输入的关键字，并在新窗口中列出所有匹配项。\n此操作只读取 Excel，不修改任何数据。"),
                    GUILayout.Width(66f)))
                    SearchByRemark();
                GUI.backgroundColor = savedBgSearch;
            }
        }

        EditorGUILayout.EndScrollView();

        EditorGUIUtility.labelWidth = savedLabelWidth;

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
    }

    /// <summary>
    /// 拖入预制体后自动填写：资源路径、原始特效范围大小、特效类型。
    /// </summary>
    private void AutoFillFromPrefab(GameObject prefab)
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

        // ── 4. id（读取 Excel 最后一行 id + 10）──────────────────
        if (File.Exists(excelPath) && File.Exists(scriptPath))
        {
            int nextId = ReadNextIdFromExcel(scriptPath, excelPath);
            if (nextId >= 0)
                fieldId = nextId.ToString();
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
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
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

            var psi = new ProcessStartInfo
            {
                FileName = "python",
                Arguments = $"\"{scriptPath}\" --overwrite \"{excelPath}\" \"{tempJson}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
            };
            psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

            using (var proc = Process.Start(psi))
            {
                string stdout = proc.StandardOutput.ReadToEnd();
                string stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (proc.ExitCode == 0)
                    EditorUtility.DisplayDialog("成功", "配置已成功覆盖写入 Excel。", "确定");
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
        var psi = new ProcessStartInfo
        {
            FileName = "python",
            Arguments = $"\"{scriptPath}\" --check-id \"{excelPath}\" {id}",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

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
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
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
                EditorUtility.DisplayDialog("成功", "配置已成功写入 Excel。", "确定");
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
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
            return;
        }
        Process.Start(new ProcessStartInfo(excelPath) { UseShellExecute = true });
    }

    /// <summary>
    /// 调用 Python 脚本，返回 null 表示成功，否则返回错误信息。
    /// </summary>
    private static string RunPythonScript(string scriptPath, string excelPath, string jsonFilePath)
    {
        var psi = new ProcessStartInfo
        {
            FileName = "python",
            Arguments = $"\"{scriptPath}\" \"{excelPath}\" \"{jsonFilePath}\"",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

        using (var proc = Process.Start(psi))
        {
            string stdout = proc.StandardOutput.ReadToEnd();
            string stderr = proc.StandardError.ReadToEnd();
            proc.WaitForExit();

            if (proc.ExitCode == 0)
                return null;

            string msg = stdout.Trim();
            if (string.IsNullOrEmpty(msg))
                msg = stderr.Trim();
            return string.IsNullOrEmpty(msg)
                ? $"Python 脚本异常退出（退出码 {proc.ExitCode}）"
                : msg;
        }
    }

    /// <summary>
    /// 从 Excel 中按 ID 查询整行数据，并将结果填回界面所有字段。
    /// </summary>
    private void QueryById()
    {
        if (string.IsNullOrWhiteSpace(fieldId) || !int.TryParse(fieldId.Trim(), out int queryId))
        {
            EditorUtility.DisplayDialog("错误", "请先在 ID 字段填入有效的整数后再执行查询。", "确定");
            return;
        }

        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
            return;
        }

        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        string json = ReadRowById(scriptPath, excelPath, queryId);

        if (json == null)
        {
            EditorUtility.DisplayDialog("查询失败", "调用 Python 脚本时发生错误，请查看控制台输出。", "确定");
            return;
        }

        if (json == "NOT_FOUND")
        {
            EditorUtility.DisplayDialog("未找到", $"Excel 中不存在 ID 为 {queryId} 的记录。", "确定");
            return;
        }

        // 解析返回的 JSON（所有字段均为字符串）
        VFXRowData row = JsonUtility.FromJson<VFXRowData>(json);
        if (row == null)
        {
            EditorUtility.DisplayDialog("解析失败", "无法解析 Python 返回的数据，请查看控制台输出。", "确定");
            return;
        }

        FillFromRowData(row);
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

    /// <summary>
    /// 从 Excel 中按名称查询整行数据，并将结果填回界面所有字段。
    /// </summary>
    private void QueryByName()
    {
        if (string.IsNullOrWhiteSpace(fieldName))
        {
            EditorUtility.DisplayDialog("错误", "请先在名称字段填入内容后再执行查询。", "确定");
            return;
        }

        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
            return;
        }

        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        string json = ReadRowByName(scriptPath, excelPath, fieldName.Trim());

        if (json == null)
        {
            EditorUtility.DisplayDialog("查询失败", "调用 Python 脚本时发生错误，请查看控制台输出。", "确定");
            return;
        }

        if (json == "NOT_FOUND")
        {
            EditorUtility.DisplayDialog("未找到", $"Excel 中不存在名称为 \"{fieldName.Trim()}\" 的记录。", "确定");
            return;
        }

        VFXRowData row = JsonUtility.FromJson<VFXRowData>(json);
        if (row == null)
        {
            EditorUtility.DisplayDialog("解析失败", "无法解析 Python 返回的数据，请查看控制台输出。", "确定");
            return;
        }

        FillFromRowData(row);
    }

    /// <summary>
    /// 调用 Python 脚本按名称读取整行数据，返回 JSON 字符串。
    /// 返回 "NOT_FOUND" 表示不存在，null 表示调用失败。
    /// </summary>
    private static string ReadRowByName(string scriptPath, string excelPath, string name)
    {
        // 通过临时 JSON 文件传递名称，避免含空格或特殊字符时的命令行转义问题
        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson,
                "{\"name\":\"" + EscapeJson(name) + "\"}",
                new UTF8Encoding(false));

            var psi = new ProcessStartInfo
            {
                FileName = "python",
                Arguments = $"\"{scriptPath}\" --get-by-name \"{excelPath}\" \"{tempJson}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
            };
            psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

            using (var proc = Process.Start(psi))
            {
                string output = proc.StandardOutput.ReadToEnd().Trim();
                proc.WaitForExit();
                if (proc.ExitCode == 0) return output;
                if (proc.ExitCode == 1) return "NOT_FOUND";
                return null;
            }
        }
        catch { return null; }
        finally
        {
            if (File.Exists(tempJson))
                File.Delete(tempJson);
        }
    }

    /// <summary>
    /// 在 Excel 备注列中模糊搜索关键字，结果在新窗口展示。
    /// </summary>
    private void SearchByRemark()
    {
        if (string.IsNullOrWhiteSpace(searchKeyword))
        {
            EditorUtility.DisplayDialog("提示", "请先在搜索关键字字段输入内容后再执行搜索。", "确定");
            return;
        }

        if (string.IsNullOrEmpty(excelPath) || !File.Exists(excelPath))
        {
            EditorUtility.DisplayDialog("错误", "Excel 文件路径无效，请检查路径设置。", "确定");
            return;
        }

        if (!File.Exists(scriptPath))
        {
            EditorUtility.DisplayDialog("错误", $"找不到 Python 脚本：\n{scriptPath}", "确定");
            return;
        }

        string json = RunPythonSearchByRemark(scriptPath, excelPath, searchKeyword);
        if (json == null)
        {
            EditorUtility.DisplayDialog("搜索失败", "调用 Python 脚本时发生错误，请查看控制台输出。", "确定");
            return;
        }

        // JsonUtility 不支持顶层数组，需包装后反序列化
        VFXRowDataList list = JsonUtility.FromJson<VFXRowDataList>("{\"items\":" + json + "}");
        if (list == null || list.items == null || list.items.Length == 0)
        {
            EditorUtility.DisplayDialog("未找到", $"备注中没有包含 \"{searchKeyword}\" 的特效记录。", "确定");
            return;
        }

        VFXSearchResultWindow.Open(new List<VFXRowData>(list.items), FillFromRowData);
    }

    /// <summary>
    /// 调用 Python 脚本按备注模糊搜索，返回 JSON 数组字符串。失败返回 null。
    /// </summary>
    private static string RunPythonSearchByRemark(string scriptPath, string excelPath, string keyword)
    {
        // 通过临时 JSON 文件传递关键字，避免命令行特殊字符转义问题
        string tempJson = Path.GetTempFileName();
        try
        {
            File.WriteAllText(tempJson,
                "{\"keyword\":\"" + EscapeJson(keyword) + "\"}",
                new UTF8Encoding(false));

            var psi = new ProcessStartInfo
            {
                FileName = "python",
                Arguments = $"\"{scriptPath}\" --search-by-remark \"{excelPath}\" \"{tempJson}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
            };
            psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

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

    /// <summary>
    /// 调用 Python 脚本按 ID 读取整行数据，返回 JSON 字符串。
    /// 返回 "NOT_FOUND" 表示不存在，null 表示调用失败。
    /// </summary>
    private static string ReadRowById(string scriptPath, string excelPath, int id)
    {
        var psi = new ProcessStartInfo
        {
            FileName = "python",
            Arguments = $"\"{scriptPath}\" --get-by-id \"{excelPath}\" {id}",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

        try
        {
            using (var proc = Process.Start(psi))
            {
                string output = proc.StandardOutput.ReadToEnd().Trim();
                proc.WaitForExit();
                // 退出码 0 = 找到，1 = 未找到，其他 = 错误
                if (proc.ExitCode == 0) return output;
                if (proc.ExitCode == 1) return "NOT_FOUND";
                return null;
            }
        }
        catch { return null; }
    }

    /// <summary>用于接收 Python --get-by-id / --search-by-remark 返回的 JSON（所有字段均为字符串）。</summary>
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

    /// <summary>用于 JsonUtility 反序列化 Python --search-by-remark 返回的 JSON 数组。</summary>
    [System.Serializable]
    private class VFXRowDataList
    {
        public VFXRowData[] items;
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
        var psi = new ProcessStartInfo
        {
            FileName = "python",
            Arguments = $"\"{scriptPath}\" --get-last-id \"{excelPath}\"",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
        };
        psi.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

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
}
