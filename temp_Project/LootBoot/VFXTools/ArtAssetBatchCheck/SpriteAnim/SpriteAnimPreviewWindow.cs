using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    /// <summary>序列帧动画检查页签：扫描 ActorSpriteAnimator 预制体、展示检查结果并批量预览。</summary>
    public class SpriteAnimPreviewWindow : EditorWindow
    {
        private const string DefaultAnimationOptionLabel = "(各Prefab默认动画)";

        private static readonly Color ButtonColorGreen = new Color(0.32f, 0.72f, 0.36f);
        private static readonly Color ButtonColorPlaying = new Color(0.95f, 0.72f, 0.22f);
        private static readonly Color ButtonColorStop = new Color(0.38f, 0.62f, 0.92f);
        private static readonly Color ButtonColorEnd = new Color(0.86f, 0.30f, 0.30f);

        private SpriteAnimCheckConfig _config;
        private SpriteAnimCheckResult _result;
        private string[] _animationOptions = { DefaultAnimationOptionLabel };
        private int _selectedAnimationIndex;
        private Vector2 _scroll;
        private readonly Dictionary<string, bool> _foldouts = new Dictionary<string, bool>(StringComparer.Ordinal);
        private bool _showOnlyIssueEntries;
        private bool _previewPlaying;
        private double _lastPreviewTime;

        public static void Open()
        {
            ArtAssetBatchCheckWindow.Open(2);
        }

        /// <summary>主窗口关闭时结束预览生命周期。</summary>
        public static void CancelSpriteAnimPreviewLifecycle()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                return;
            }

            SpriteAnimPreviewSceneHelper.ClosePreviewScene();
        }

        private void OnEnable()
        {
            EnsureConfig();
            EditorApplication.update -= OnEditorUpdate;
            EditorApplication.update += OnEditorUpdate;
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            AssemblyReloadEvents.beforeAssemblyReload -= OnBeforeAssemblyReload;
            AssemblyReloadEvents.beforeAssemblyReload += OnBeforeAssemblyReload;
            EditorApplication.quitting -= OnEditorQuitting;
            EditorApplication.quitting += OnEditorQuitting;
        }

        private void OnDisable()
        {
            EditorApplication.update -= OnEditorUpdate;
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
            AssemblyReloadEvents.beforeAssemblyReload -= OnBeforeAssemblyReload;
            EditorApplication.quitting -= OnEditorQuitting;
            _previewPlaying = false;

            // 关闭工具窗口时结束预览并还原场景对象；编译/资源刷新过程中不做场景操作
            if (!EditorApplication.isPlayingOrWillChangePlaymode && !EditorApplication.isCompiling &&
                !EditorApplication.isUpdating && SpriteAnimPreviewSceneHelper.HasPreview)
            {
                SpriteAnimPreviewSceneHelper.ClosePreviewScene();
            }
        }

        /// <summary>进入播放模式前结束预览并还原被临时禁用的场景对象，避免影响实际战斗场景。</summary>
        private void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state != PlayModeStateChange.ExitingEditMode)
            {
                return;
            }

            _previewPlaying = false;
            if (SpriteAnimPreviewSceneHelper.HasPreview)
            {
                SpriteAnimPreviewSceneHelper.ClosePreviewScene();
            }
            else
            {
                SpriteAnimPreviewSceneHelper.RestoreSceneIsolation();
            }
        }

        /// <summary>脚本重载前还原场景对象，避免预览的临时禁用状态残留到重载之后。</summary>
        private void OnBeforeAssemblyReload()
        {
            _previewPlaying = false;
            SpriteAnimPreviewSceneHelper.EndPreviewKeepingScene();
        }

        private void OnEditorQuitting()
        {
            SpriteAnimPreviewSceneHelper.RestoreSceneIsolation();
        }

        private void OnGUI()
        {
            DrawToolGUI();
        }

        public void DrawToolGUI()
        {
            EnsureConfig();

            using (var scroll = new EditorGUILayout.ScrollViewScope(_scroll))
            {
                _scroll = scroll.scrollPosition;
                DrawCheckSetting();
                EditorGUILayout.Space(8f);
                DrawActions();
                EditorGUILayout.Space(8f);
                DrawResults();
            }
        }

        private void EnsureConfig()
        {
            if (_config == null)
            {
                _config = SpriteAnimCheckConfig.LoadOrCreate();
            }
        }

        private void DrawCheckSetting()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("检查设置", EditorStyles.boldLabel);
                EditorGUILayout.HelpBox(
                    "扫描目录下所有预制体，仅检查挂有 ActorSpriteAnimator 的预制体（其余跳过）。\n" +
                    "检查项：缺失 Sprite 渲染主体 / 丢失脚本、动画配置（空帧、重名、默认动画缺失、帧率为0）、\n" +
                    "序列帧资源（帧丢失、重复帧、编号不连续、命名不一致）、贴图导入（PixelPerUnit 不一致）、源目录一致性。",
                    MessageType.Info);

                EditorGUI.BeginChangeCheck();
                using (new EditorGUILayout.HorizontalScope())
                {
                    _config.prefabRootFolder = EditorGUILayout.TextField("预制体目录", _config.prefabRootFolder);
                    if (GUILayout.Button("浏览", GUILayout.Width(50)))
                    {
                        var selected = EditorUtility.OpenFolderPanel("选择预制体目录", Application.dataPath, string.Empty);
                        if (!string.IsNullOrEmpty(selected))
                        {
                            var dataPath = Application.dataPath.Replace('\\', '/');
                            selected = selected.Replace('\\', '/');
                            if (selected.StartsWith(dataPath, StringComparison.Ordinal))
                            {
                                _config.prefabRootFolder = "Assets" + selected.Substring(dataPath.Length);
                            }
                            else
                            {
                                EditorUtility.DisplayDialog("路径错误", "请选择 Assets 目录内的文件夹。", "确定");
                            }
                        }
                    }
                }

                _config.checkSourceFolderConsistency = EditorGUILayout.ToggleLeft("校验源目录一致性（未收集帧 / 动作未配置）", _config.checkSourceFolderConsistency);
                _config.checkPixelsPerUnit = EditorGUILayout.ToggleLeft("校验序列帧 PixelPerUnit 一致", _config.checkPixelsPerUnit);
                _config.checkMissingScripts = EditorGUILayout.ToggleLeft("检查预制体丢失的脚本引用", _config.checkMissingScripts);
                if (EditorGUI.EndChangeCheck())
                {
                    _config.Save();
                }
            }
        }

        private void DrawActions()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("操作", EditorStyles.boldLabel);
                EditorGUILayout.Space(4f);

                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button("扫描并检查资源", GUILayout.Height(32), GUILayout.MinWidth(150)))
                    {
                        RunScan();
                    }

                    GUILayout.Space(6f);
                    using (new EditorGUI.DisabledScope(_result == null))
                    {
                        if (GUILayout.Button("查看检查报告", GUILayout.Height(32), GUILayout.MinWidth(130)))
                        {
                            SpriteAnimAssetCheckReportWindow.ShowReport(_result?.Report);
                        }
                    }
                }

                EditorGUILayout.Space(6f);
                EditorGUILayout.LabelField("批量预览", EditorStyles.boldLabel);

                EditorGUI.BeginChangeCheck();
                _config.previewSpacing = EditorGUILayout.Slider("排列间隔", _config.previewSpacing, 0.5f, 50f);
                _config.prefabsPerRow = EditorGUILayout.IntSlider("每行数量", _config.prefabsPerRow, 1, 30);
                _config.showBoundaries = EditorGUILayout.Toggle("显示边框", _config.showBoundaries);
                _config.showLabels = EditorGUILayout.Toggle("显示标签", _config.showLabels);
                _config.showPivots = EditorGUILayout.Toggle("显示轴心", _config.showPivots);
                _showOnlyIssueEntries = EditorGUILayout.Toggle("仅预览有问题的预制体", _showOnlyIssueEntries);
                if (EditorGUI.EndChangeCheck())
                {
                    _config.Save();
                    // 轴心绘制为纯显示项，预览中切换立即生效
                    SpriteAnimPreviewSceneHelper.ShowPivots = _config.showPivots;
                    if (SpriteAnimPreviewSceneHelper.HasPreview)
                    {
                        SceneView.RepaintAll();
                    }
                }

                var nextAnimationIndex = EditorGUILayout.Popup("预览动画", _selectedAnimationIndex, _animationOptions);
                if (nextAnimationIndex != _selectedAnimationIndex)
                {
                    _selectedAnimationIndex = nextAnimationIndex;
                    _config.previewAnimation = GetSelectedAnimation();
                    _config.Save();
                    if (SpriteAnimPreviewSceneHelper.HasPreview)
                    {
                        SpriteAnimPreviewSceneHelper.ApplyAnimation(GetSelectedAnimation());
                    }
                }

                EditorGUILayout.Space(4f);
                var hasPreview = SpriteAnimPreviewSceneHelper.HasPreview;
                using (new EditorGUILayout.HorizontalScope())
                {
                    using (new EditorGUI.DisabledScope(_result == null || _result.Entries.Count == 0))
                    {
                        if (DrawStateButton(hasPreview ? "刷新预览" : "生成批量预览",
                                hasPreview ? ButtonColorGreen : Color.white,
                                GUILayout.Height(34), GUILayout.MinWidth(140)))
                        {
                            GeneratePreview(GetPreviewEntries());
                        }
                    }

                    GUILayout.Space(6f);
                    using (new EditorGUI.DisabledScope(!hasPreview))
                    {
                        if (DrawStateButton(_previewPlaying ? "暂停预览" : "播放预览",
                                _previewPlaying ? ButtonColorPlaying : ButtonColorGreen,
                                GUILayout.Height(34), GUILayout.MinWidth(110)))
                        {
                            _previewPlaying = !_previewPlaying;
                            _lastPreviewTime = 0d;
                        }

                        GUILayout.Space(6f);
                        if (DrawStateButton("停止预览", ButtonColorStop, GUILayout.Height(34), GUILayout.MinWidth(110)))
                        {
                            _previewPlaying = false;
                            SpriteAnimPreviewSceneHelper.ApplyAnimation(GetSelectedAnimation());
                            SceneView.RepaintAll();
                        }

                        GUILayout.Space(6f);
                        if (DrawStateButton("结束预览", ButtonColorEnd, GUILayout.Height(34), GUILayout.MinWidth(110)))
                        {
                            _previewPlaying = false;
                            SpriteAnimPreviewSceneHelper.ClosePreviewScene();
                        }
                    }
                }

                if (!EditorApplication.isPlaying)
                {
                    EditorGUILayout.HelpBox("预览使用临时预览场景：进入预览时会临时禁用当前场景中的所有对象（结束预览时还原），并关闭预制体上的其余逻辑组件；编辑模式下即可播放序列帧。", MessageType.Info);
                }
            }
        }

        private void DrawResults()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("检查结果", EditorStyles.boldLabel);
                if (_result == null)
                {
                    EditorGUILayout.LabelField("尚未扫描。点击「扫描并检查资源」开始检查。", EditorStyles.miniLabel);
                    return;
                }

                var report = _result.Report;
                EditorGUILayout.LabelField(
                    $"预制体 {report.PrefabChecked}/{report.PrefabTotal}（跳过无脚本 {report.PrefabSkipped}） | " +
                    $"动画 {report.AnimationCount} | 序列帧 {report.FrameCount}");
                var summaryStyle = new GUIStyle(EditorStyles.boldLabel);
                if (report.ErrorCount > 0)
                {
                    summaryStyle.normal.textColor = Color.red;
                }
                else if (report.WarningCount > 0)
                {
                    summaryStyle.normal.textColor = new Color(1f, 0.58f, 0f);
                }

                EditorGUILayout.LabelField($"错误 {report.ErrorCount} | 警告 {report.WarningCount}" +
                                           (_result.Cancelled ? "（扫描被取消，结果不完整）" : string.Empty), summaryStyle);

                var entries = _showOnlyIssueEntries
                    ? _result.Entries.Where(entry => entry.HasIssue).ToList()
                    : _result.Entries;
                EditorGUILayout.LabelField($"列表显示 {entries.Count} / {_result.Entries.Count} 个预制体", EditorStyles.miniLabel);

                foreach (var entry in entries)
                {
                    DrawEntry(entry);
                }
            }
        }

        private void DrawEntry(SpriteAnimActorEntry entry)
        {
            var key = entry.PrefabPath;
            if (!_foldouts.TryGetValue(key, out var expanded))
            {
                expanded = entry.HasIssue;
                _foldouts[key] = expanded;
            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    var title = $"{GetStatusIcon(entry)} {entry.PrefabName}   动画 {entry.AnimationCount} / 帧 {entry.FrameCount}";
                    _foldouts[key] = EditorGUILayout.Foldout(expanded, title, true);
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("定位", GUILayout.Width(48)))
                    {
                        SpriteAnimAssetCheckReportWindow.PingAsset(entry.PrefabPath);
                    }

                    if (GUILayout.Button("预览此Prefab", GUILayout.Width(96)))
                    {
                        GeneratePreview(new List<SpriteAnimActorEntry> { entry });
                    }
                }

                if (!_foldouts[key])
                {
                    return;
                }

                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.LabelField("预制体路径", entry.PrefabPath, EditorStyles.miniLabel);
                    EditorGUILayout.LabelField("源目录", string.IsNullOrEmpty(entry.SourceFolder) ? "(空)" : entry.SourceFolder, EditorStyles.miniLabel);
                    EditorGUILayout.LabelField("默认动画", string.IsNullOrEmpty(entry.DefaultAnimation) ? "(空)" : entry.DefaultAnimation, EditorStyles.miniLabel);
                    EditorGUILayout.LabelField("动画列表", entry.AnimationNames.Count == 0 ? "(无)" : string.Join(", ", entry.AnimationNames), EditorStyles.miniLabel);

                    if (!entry.HasIssue)
                    {
                        EditorGUILayout.HelpBox("检查通过", MessageType.None);
                        return;
                    }

                    foreach (var issue in entry.Issues)
                    {
                        var style = issue.Severity == SpriteAnimCheckSeverity.Error
                            ? new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = Color.red } }
                            : new GUIStyle(EditorStyles.wordWrappedLabel) { normal = { textColor = new Color(1f, 0.58f, 0f) } };
                        using (new EditorGUILayout.HorizontalScope())
                        {
                            EditorGUILayout.LabelField($"[{issue.CheckName}] {issue.Message} - {issue.Detail}", style);
                            if (GUILayout.Button("定位", GUILayout.Width(48)))
                            {
                                SpriteAnimAssetCheckReportWindow.PingAsset(issue.AssetPath);
                            }
                        }
                    }
                }
            }
        }

        private static string GetStatusIcon(SpriteAnimActorEntry entry)
        {
            if (entry.HasError)
            {
                return "✖";
            }

            return entry.HasWarning ? "⚠" : "✓";
        }

        private void RunScan()
        {
            EnsureConfig();
            _config.Save();
            _foldouts.Clear();

            _result = SpriteAnimAssetChecker.Run(_config);
            BuildAnimationOptions();

            var report = _result.Report;
            Debug.Log($"[SpriteAnimCheck] 检查完成：目录={report.RootFolder}; 预制体={report.PrefabChecked}/{report.PrefabTotal}; " +
                      $"跳过(无ActorSpriteAnimator)={report.PrefabSkipped}; 动画={report.AnimationCount}; 序列帧={report.FrameCount}; " +
                      $"错误={report.ErrorCount}; 警告={report.WarningCount}");

            Repaint();
        }

        private void BuildAnimationOptions()
        {
            var options = new List<string> { DefaultAnimationOptionLabel };
            if (_result != null)
            {
                options.AddRange(_result.AnimationNames);
            }

            _animationOptions = options.ToArray();
            var configured = string.IsNullOrEmpty(_config.previewAnimation) ? DefaultAnimationOptionLabel : _config.previewAnimation;
            _selectedAnimationIndex = Mathf.Max(0, Array.IndexOf(_animationOptions, configured));
        }

        private string GetSelectedAnimation()
        {
            if (_animationOptions.Length == 0)
            {
                return string.Empty;
            }

            _selectedAnimationIndex = Mathf.Clamp(_selectedAnimationIndex, 0, _animationOptions.Length - 1);
            var selected = _animationOptions[_selectedAnimationIndex];
            return selected == DefaultAnimationOptionLabel ? string.Empty : selected;
        }

        private List<SpriteAnimActorEntry> GetPreviewEntries()
        {
            if (_result == null)
            {
                return new List<SpriteAnimActorEntry>();
            }

            return _showOnlyIssueEntries
                ? _result.Entries.Where(entry => entry.HasIssue).ToList()
                : _result.Entries.ToList();
        }

        private void GeneratePreview(List<SpriteAnimActorEntry> entries)
        {
            if (entries == null || entries.Count == 0)
            {
                EditorUtility.DisplayDialog("序列帧预览", "没有可预览的预制体，请先扫描或调整过滤条件。", "确定");
                return;
            }

            _config.Save();
            var spawned = SpriteAnimPreviewSceneHelper.Generate(entries, _config, GetSelectedAnimation());
            if (spawned == 0)
            {
                EditorUtility.DisplayDialog("序列帧预览",
                    "没有成功生成预览对象。\n请确认预制体包含 ActorSpriteAnimator；若当前场景未保存（未命名场景），请先保存场景后重试。", "确定");
                return;
            }

            _previewPlaying = true;
            _lastPreviewTime = 0d;
            SceneView.RepaintAll();
            Repaint();
        }

        /// <summary>带底色的按钮：底色用于表达该操作当前所处的状态。</summary>
        private static bool DrawStateButton(string label, Color background, params GUILayoutOption[] options)
        {
            var previous = GUI.backgroundColor;
            GUI.backgroundColor = background;
            var clicked = GUILayout.Button(label, options);
            GUI.backgroundColor = previous;
            return clicked;
        }

        private void OnEditorUpdate()
        {
            if (!_previewPlaying || !SpriteAnimPreviewSceneHelper.HasPreview)
            {
                return;
            }

            var now = EditorApplication.timeSinceStartup;
            var delta = _lastPreviewTime <= 0d ? 0d : now - _lastPreviewTime;
            _lastPreviewTime = now;
            SpriteAnimPreviewSceneHelper.Tick((float)Mathf.Clamp((float)delta, 0f, 0.1f));
            SceneView.RepaintAll();
        }
    }
}
