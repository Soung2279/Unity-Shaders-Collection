using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.ParticleMaterial
{
    public enum MaterialAssetCheckSeverity
    {
        Warning,
        Error
    }

    public class MaterialAssetCheckIssue
    {
        public MaterialAssetCheckSeverity Severity;
        public string CheckName;
        public string Message;
        public string AssetPath;
        public string MaterialName;
        public string ShaderName;
    }

    public class MaterialAssetCheckReport
    {
        public DateTime CreatedAt;
        public int MaterialCount;
        public int ErrorCount;
        public int WarningCount;
        public readonly List<MaterialAssetCheckIssue> Issues = new();

        public static string GetReasonKey(MaterialAssetCheckIssue issue)
        {
            return issue == null ? string.Empty : $"{issue.CheckName}|{issue.Message}";
        }

        public string ToText()
        {
            var builder = new StringBuilder();
            builder.AppendLine("材质球资源检查报告");
            builder.AppendLine($"生成时间: {CreatedAt:yyyy-MM-dd HH:mm:ss}");
            builder.AppendLine($"材质数: {MaterialCount}");
            builder.AppendLine($"错误: {ErrorCount}");
            builder.AppendLine($"警告: {WarningCount}");
            builder.AppendLine();

            if (Issues.Count == 0)
            {
                builder.AppendLine("未发现材质贴图缺失或Shader异常。");
                return builder.ToString();
            }

            foreach (var group in Issues.GroupBy(GetReasonKey).OrderByDescending(group => group.Any(issue => issue.Severity == MaterialAssetCheckSeverity.Error)).ThenBy(group => group.Key))
            {
                var first = group.First();
                builder.AppendLine($"问题原因: {first.CheckName} - {first.Message}");
                builder.AppendLine($"数量: {group.Count()}");
                foreach (var issue in group.OrderBy(issue => issue.AssetPath))
                {
                    builder.AppendLine($"  [{issue.Severity}] Material={issue.MaterialName}; Shader={issue.ShaderName}; Asset={issue.AssetPath}");
                }

                builder.AppendLine();
            }

            return builder.ToString();
        }
    }

    public static class MaterialAssetChecker
    {
        private static readonly string[] TextureProperties = { "_MainTex", "_BaseMap", "_BaseTex" };

        public static MaterialAssetCheckReport Run(IReadOnlyList<string> folders, IReadOnlyList<string> textureCheckSkippedShaders)
        {
            var report = new MaterialAssetCheckReport
            {
                CreatedAt = DateTime.Now
            };

            var guids = CollectMaterialGuids(folders);
            try
            {
                for (int i = 0; i < guids.Count; i++)
                {
                    if (EditorUtility.DisplayCancelableProgressBar("材质球资源检查", $"检查 {i + 1}/{guids.Count}", guids.Count == 0 ? 1f : i / (float)guids.Count))
                    {
                        break;
                    }

                    var path = AssetDatabase.GUIDToAssetPath(guids[i]);
                    if (IsModelEmbeddedMaterialPath(path))
                    {
                        continue;
                    }

                    var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                    if (material == null)
                    {
                        continue;
                    }

                    report.MaterialCount++;
                    CheckMaterial(report, material, path, textureCheckSkippedShaders);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            Finish(report);
            return report;
        }

        private static List<string> CollectMaterialGuids(IReadOnlyList<string> folders)
        {
            var guids = new List<string>();
            if (folders == null || folders.Count == 0)
            {
                guids.AddRange(AssetDatabase.FindAssets("t:Material", new[] { "Assets" }));
                return guids.Distinct().ToList();
            }

            foreach (var folder in folders)
            {
                if (!string.IsNullOrEmpty(folder) && AssetDatabase.IsValidFolder(folder))
                {
                    guids.AddRange(AssetDatabase.FindAssets("t:Material", new[] { folder }));
                }
            }

            return guids.Distinct().ToList();
        }

        private static void CheckMaterial(MaterialAssetCheckReport report, Material material, string path, IReadOnlyList<string> textureCheckSkippedShaders)
        {
            var shaderName = material.shader != null ? material.shader.name : string.Empty;
            if (!IsTextureCheckSkipped(shaderName, textureCheckSkippedShaders) && !HasAnyTexture(material, TextureProperties))
            {
                AddIssue(report, MaterialAssetCheckSeverity.Error, "主贴图缺失", "_MainTex / _BaseMap / _BaseTex 均为空或属性不存在", path, material.name, shaderName);
            }

            if (IsAbnormalShader(shaderName))
            {
                AddIssue(report, MaterialAssetCheckSeverity.Error, "Shader异常", "Shader为 Hidden / Error / Fallback 类型", path, material.name, shaderName);
            }
        }

        private static bool IsModelEmbeddedMaterialPath(string path)
        {
            var extension = Path.GetExtension(path);
            return string.Equals(extension, ".fbx", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".obj", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".dae", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".blend", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".3ds", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".max", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".ma", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".mb", StringComparison.OrdinalIgnoreCase)
                   || string.Equals(extension, ".c4d", StringComparison.OrdinalIgnoreCase);
        }

        private static bool HasAnyTexture(Material material, params string[] propertyNames)
        {
            foreach (var propertyName in propertyNames)
            {
                if (material.HasProperty(propertyName) && material.GetTexture(propertyName) != null)
                {
                    return true;
                }
            }

            return false;
        }

        private static bool IsTextureCheckSkipped(string shaderName, IReadOnlyList<string> skippedShaders)
        {
            if (string.IsNullOrEmpty(shaderName) || skippedShaders == null)
            {
                return false;
            }

            return skippedShaders.Any(skipped => string.Equals(skipped, shaderName, StringComparison.OrdinalIgnoreCase));
        }

        private static bool IsAbnormalShader(string shaderName)
        {
            return string.IsNullOrEmpty(shaderName)
                   || shaderName.StartsWith("Hidden/", StringComparison.OrdinalIgnoreCase)
                   || shaderName.IndexOf("Error", StringComparison.OrdinalIgnoreCase) >= 0
                   || shaderName.IndexOf("Fallback", StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static void AddIssue(MaterialAssetCheckReport report, MaterialAssetCheckSeverity severity, string checkName,
            string message, string assetPath, string materialName, string shaderName)
        {
            report.Issues.Add(new MaterialAssetCheckIssue
            {
                Severity = severity,
                CheckName = checkName,
                Message = message,
                AssetPath = assetPath,
                MaterialName = materialName,
                ShaderName = shaderName
            });
        }

        private static void Finish(MaterialAssetCheckReport report)
        {
            report.ErrorCount = report.Issues.Count(issue => issue.Severity == MaterialAssetCheckSeverity.Error);
            report.WarningCount = report.Issues.Count(issue => issue.Severity == MaterialAssetCheckSeverity.Warning);
        }
    }

    public class MaterialAssetCheckReportWindow : EditorWindow
    {
        private MaterialAssetCheckReport _report;
        private Vector2 _issueScroll;
        private Vector2 _textScroll;
        private string _reportText;
        private GUIStyle _errorHeaderStyle;
        private GUIStyle _warningHeaderStyle;
        private GUIStyle _errorLabelStyle;
        private GUIStyle _warningLabelStyle;

        public static void ShowReport(MaterialAssetCheckReport report)
        {
            var window = GetWindow<MaterialAssetCheckReportWindow>("材质球资源检查报告");
            window.minSize = new Vector2(900, 600);
            window.SetReport(report);
            window.Show();
            window.Focus();
        }

        private void SetReport(MaterialAssetCheckReport report)
        {
            _report = report;
            _reportText = report?.ToText() ?? string.Empty;
        }

        private void OnGUI()
        {
            if (_report == null)
            {
                EditorGUILayout.HelpBox("暂无报告。", MessageType.Info);
                return;
            }

            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField($"材质 {_report.MaterialCount} | 错误 {_report.ErrorCount} | 警告 {_report.WarningCount}", EditorStyles.boldLabel);
                if (GUILayout.Button("导出检查报告", GUILayout.Width(120)))
                {
                    ExportReport();
                }
            }

            var listHeight = Mathf.Max(260f, position.height - 330f);
            using (var scroll = new EditorGUILayout.ScrollViewScope(_issueScroll, GUILayout.Height(listHeight)))
            {
                _issueScroll = scroll.scrollPosition;
                if (_report.Issues.Count == 0)
                {
                    EditorGUILayout.HelpBox("未发现材质贴图缺失或Shader异常。", MessageType.Info);
                }
                else
                {
                    DrawGroupedIssues();
                }
            }

            EditorGUILayout.Space(6f);
            EditorGUILayout.LabelField("检查报告预览", EditorStyles.boldLabel);
            using (var scroll = new EditorGUILayout.ScrollViewScope(_textScroll, EditorStyles.helpBox, GUILayout.MinHeight(180)))
            {
                _textScroll = scroll.scrollPosition;
                EditorGUILayout.SelectableLabel(_reportText, EditorStyles.wordWrappedLabel, GUILayout.ExpandHeight(true));
            }
        }

        private void DrawGroupedIssues()
        {
            EnsureStyles();
            var groups = _report.Issues
                .GroupBy(MaterialAssetCheckReport.GetReasonKey)
                .OrderByDescending(group => group.Any(issue => issue.Severity == MaterialAssetCheckSeverity.Error))
                .ThenBy(group => group.First().CheckName)
                .ThenBy(group => group.First().Message);

            foreach (var group in groups)
            {
                var first = group.First();
                var severity = group.Any(issue => issue.Severity == MaterialAssetCheckSeverity.Error)
                    ? MaterialAssetCheckSeverity.Error
                    : MaterialAssetCheckSeverity.Warning;

                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    EditorGUILayout.LabelField($"{first.CheckName}  ({group.Count()}项)", GetHeaderStyle(severity));
                    EditorGUILayout.LabelField(first.Message, GetLabelStyle(severity));
                    EditorGUILayout.Space(3f);

                    foreach (var issue in group.OrderBy(issue => issue.AssetPath))
                    {
                        DrawIssue(issue);
                    }
                }
            }
        }

        private void DrawIssue(MaterialAssetCheckIssue issue)
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField($"Material: {issue.MaterialName}    Shader: {issue.ShaderName}", GetLabelStyle(issue.Severity));
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUI.BeginDisabledGroup(string.IsNullOrEmpty(issue.AssetPath));
                    if (GUILayout.Button(string.IsNullOrEmpty(issue.MaterialName) ? "定位材质" : issue.MaterialName, EditorStyles.linkLabel, GUILayout.Width(260)))
                    {
                        PingAsset(issue.AssetPath);
                    }
                    EditorGUI.EndDisabledGroup();

                    EditorGUILayout.SelectableLabel(issue.AssetPath ?? string.Empty, EditorStyles.textField, GUILayout.Height(EditorGUIUtility.singleLineHeight));
                }
            }
        }

        private void ExportReport()
        {
            var fileName = $"MaterialAssetCheckReport_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
            var path = EditorUtility.SaveFilePanel("导出检查报告", Application.dataPath, fileName, "txt");
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            File.WriteAllText(path, _reportText, Encoding.UTF8);
            if (path.Replace('\\', '/').StartsWith(Application.dataPath.Replace('\\', '/')))
            {
                AssetDatabase.Refresh();
            }

            Debug.Log($"[MaterialAssetCheck] 检查报告已导出：{path}");
        }

        private void EnsureStyles()
        {
            _errorHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = Color.red } };
            _warningHeaderStyle ??= new GUIStyle(EditorStyles.boldLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
            _errorLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = Color.red } };
            _warningLabelStyle ??= new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
        }

        private GUIStyle GetHeaderStyle(MaterialAssetCheckSeverity severity)
        {
            EnsureStyles();
            return severity == MaterialAssetCheckSeverity.Error ? _errorHeaderStyle : _warningHeaderStyle;
        }

        private GUIStyle GetLabelStyle(MaterialAssetCheckSeverity severity)
        {
            EnsureStyles();
            return severity == MaterialAssetCheckSeverity.Error ? _errorLabelStyle : _warningLabelStyle;
        }

        private static void PingAsset(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return;
            }

            var asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
            if (asset == null)
            {
                Debug.LogWarning($"[MaterialAssetCheck] 定位失败，资产不存在：{assetPath}");
                return;
            }

            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }
    }
}
