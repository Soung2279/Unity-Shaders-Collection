using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.ParticleMaterial
{
    public class ParticlePrefabCollectorWindow : EditorWindow
    {
        private const string PendingParticlePreviewPrefsKey = "ParticlePrefabPreview.Pending";
        private const string PendingParticlePreviewPathsPrefsKey = "ParticlePrefabPreview.Paths";
        private const string PendingParticlePreviewPagePrefsKey = "ParticlePrefabPreview.Page";
        private const char PendingPathSeparator = '\n';

        private static ParticlePrefabCollectorWindow _instance;

        private class Entry
        {
            public string PrefabPath;
            public string PrefabName;
            public GameObject PrefabAsset;
        }

        private class MaterialEntry
        {
            public string MaterialPath;
            public string MaterialName;
            public Material MaterialAsset;
            public bool HasIssue;
            public string IssueText;
        }

        private enum ToolMode
        {
            ParticlePrefab,
            Material
        }

        private enum SortColumn
        {
            Name,
            Path
        }

        private const string ScanResultAssetPath =
            "Assets/Editor/VFXTools/ArtAssetBatchCheck/ParticleMaterial/ParticlePrefabScanResult.asset";
        private const int PreviewPageSize = 100;
        private const float FolderFieldHeight = 22f;

        private readonly List<Entry> _entries = new();
        private readonly List<Entry> _cachedFiltered = new();
        private readonly List<MaterialEntry> _materialEntries = new();
        private readonly List<MaterialEntry> _cachedMaterialFiltered = new();
        private readonly HashSet<string> _previewSelected = new();
        private readonly HashSet<string> _materialPreviewSelected = new();

        private ParticlePrefabScanResult _scanResultSo;
        private ToolMode _toolMode;
        private ToolMode _previewToolMode;
        private SortColumn _sortColumn = SortColumn.Name;
        private bool _sortAscending = true;
        private bool _filterCacheDirty = true;
        private bool _materialFilterCacheDirty = true;
        private Vector2 _scroll;
        private Vector2 _folderScroll;
        private string _search = string.Empty;
        private int _currentPage;
        private int _pageSize = 40;
        private int _totalPages = 1;

        private string _scanTimeStr = string.Empty;
        private string _materialScanTimeStr = string.Empty;
        private List<string> _scanFolders = new();
        private List<string> _materialScanFolders = new();
        private List<string> _materialTextureCheckSkippedShaders = new();
        private List<DefaultAsset> _folderAssets = new();
        private List<DefaultAsset> _materialFolderAssets = new();
        private bool _foldersDirty;
        private bool _materialFoldersDirty;
        private bool _materialShaderSkipDirty;
        private bool _showMaterialShaderSkipConfig;
        private Vector2 _materialShaderSkipScroll;
        private bool _showMaterialColliders;

        private bool _isScanning;
        private bool _scanningMaterials;
        private float _scanProgress;
        private List<string> _pendingGuids = new();
        private int _scanCursor;

        private bool _isPreviewing;
        private List<string> _previewTargets;
        private List<string> _materialPreviewTargets;
        private int _previewPage;
        private bool _previewSelectAll;
        private bool _previewSelectPartial;

        public static void Open()
        {
            ArtAssetBatchCheckWindow.Open(0);
        }

        public static void ImportFromExternalAnalyzer(IEnumerable<string> prefabPaths)
        {
            if (prefabPaths == null)
            {
                EditorUtility.DisplayDialog("导入失败", "没有可导入的预制体路径", "确定");
                return;
            }

            var normalizedPaths = prefabPaths
                .Where(path => !string.IsNullOrWhiteSpace(path))
                .Select(path => path.Replace('\\', '/'))
                .Distinct()
                .ToList();

            if (normalizedPaths.Count == 0)
            {
                EditorUtility.DisplayDialog("导入失败", "没有可导入的预制体路径", "确定");
                return;
            }

            Open();
            if (_instance == null)
            {
                EditorUtility.DisplayDialog("导入失败", "预览器窗口尚未初始化，请重试", "确定");
                return;
            }

            _instance.ImportExternalPrefabPathsInternal(normalizedPaths);
        }

        private void OnEnable()
        {
            _instance = this;
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            LoadOrCreateScanResult();
            TryRestorePendingParticlePreview();
        }

        private void OnDisable()
        {
            StopScan();
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
            if (ReferenceEquals(_instance, this))
            {
                _instance = null;
            }

            if (!EditorApplication.isPlayingOrWillChangePlaymode &&
                (_isPreviewing || EditorPrefs.GetBool(PendingParticlePreviewPrefsKey, false)))
            {
                _isPreviewing = false;
                ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
                ParticlePrefabPreviewSceneHelper.ClearPlayModeStartScene();
                ClearPendingParticlePreviewState();
            }
        }

        private void LoadOrCreateScanResult()
        {
            _scanResultSo = AssetDatabase.LoadAssetAtPath<ParticlePrefabScanResult>(ScanResultAssetPath);
            if (_scanResultSo == null)
            {
                _scanResultSo = CreateInstance<ParticlePrefabScanResult>();
                _scanResultSo.scanFolders.Add("Assets");
                _scanResultSo.materialScanFolders.Add("Assets");
                AssetDatabase.CreateAsset(_scanResultSo, ScanResultAssetPath);
                AssetDatabase.SaveAssets();
            }

            if (_scanResultSo.scanFolders.Count == 0)
            {
                _scanResultSo.scanFolders.Add("Assets");
            }

            if (_scanResultSo.materialScanFolders.Count == 0)
            {
                _scanResultSo.materialScanFolders.Add("Assets");
            }

            if (_scanResultSo.materialTextureCheckSkippedShaders == null)
            {
                _scanResultSo.materialTextureCheckSkippedShaders = new List<string>();
            }

            _scanFolders = new List<string>(_scanResultSo.scanFolders);
            _materialScanFolders = new List<string>(_scanResultSo.materialScanFolders);
            _materialTextureCheckSkippedShaders = new List<string>(_scanResultSo.materialTextureCheckSkippedShaders);
            _folderAssets = _scanFolders.Select(path =>
                !string.IsNullOrEmpty(path) ? AssetDatabase.LoadAssetAtPath<DefaultAsset>(path) : null).ToList();
            _materialFolderAssets = _materialScanFolders.Select(path =>
                !string.IsNullOrEmpty(path) ? AssetDatabase.LoadAssetAtPath<DefaultAsset>(path) : null).ToList();
            LoadScanResultToEntries();
            LoadMaterialScanResultToEntries();
        }

        private void LoadScanResultToEntries()
        {
            _entries.Clear();
            _previewSelected.Clear();
            foreach (var path in _scanResultSo.prefabPaths)
            {
                var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (!go) continue;
                _entries.Add(new Entry
                {
                    PrefabPath = path,
                    PrefabName = Path.GetFileNameWithoutExtension(path),
                    PrefabAsset = go
                });
            }

            _scanTimeStr = _scanResultSo.ScanTime.ToString("yyyy-MM-dd HH:mm:ss");
            _filterCacheDirty = true;
        }

        private void LoadMaterialScanResultToEntries()
        {
            _materialEntries.Clear();
            _materialPreviewSelected.Clear();
            foreach (var path in _scanResultSo.materialPaths)
            {
                if (IsModelEmbeddedMaterialPath(path)) continue;
                var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (!material) continue;
                _materialEntries.Add(CreateMaterialEntry(path, material));
            }

            _materialScanTimeStr = _scanResultSo.MaterialScanTime.ToString("yyyy-MM-dd HH:mm:ss");
            _materialFilterCacheDirty = true;
        }

        private void SaveScanResultFromEntries()
        {
            if (_scanResultSo == null) return;
            _scanResultSo.prefabPaths = _entries.Select(e => e.PrefabPath).ToList();
            _scanResultSo.ScanTime = DateTime.Now;
            _scanResultSo.scanFolders = new List<string>(_scanFolders);
            EditorUtility.SetDirty(_scanResultSo);
            AssetDatabase.SaveAssets();
            _scanTimeStr = _scanResultSo.ScanTime.ToString("yyyy-MM-dd HH:mm:ss");
        }

        private void SaveMaterialScanResultFromEntries()
        {
            if (_scanResultSo == null) return;
            _scanResultSo.materialPaths = _materialEntries.Select(e => e.MaterialPath).ToList();
            _scanResultSo.MaterialScanTime = DateTime.Now;
            _scanResultSo.materialScanFolders = new List<string>(_materialScanFolders);
            EditorUtility.SetDirty(_scanResultSo);
            AssetDatabase.SaveAssets();
            _materialScanTimeStr = _scanResultSo.MaterialScanTime.ToString("yyyy-MM-dd HH:mm:ss");
        }

        private void SaveMaterialShaderSkipConfig()
        {
            if (_scanResultSo == null) return;
            _materialTextureCheckSkippedShaders = _materialTextureCheckSkippedShaders
                .Where(shaderName => !string.IsNullOrWhiteSpace(shaderName))
                .Select(shaderName => shaderName.Trim())
                .Distinct()
                .ToList();
            _scanResultSo.materialTextureCheckSkippedShaders = new List<string>(_materialTextureCheckSkippedShaders);
            EditorUtility.SetDirty(_scanResultSo);
            AssetDatabase.SaveAssets();
            _materialShaderSkipDirty = false;
            RefreshMaterialEntriesIssueState();
        }

        private void OnGUI()
        {
            DrawToolGUI();
        }

        public void DrawToolGUI()
        {
            DrawModeTabs();
            if (_toolMode == ToolMode.Material)
            {
                DrawFolderSection(_materialScanFolders, _materialFolderAssets, ref _materialFoldersDirty,
                    "材质扫描路径 (仅扫描以下文件夹下的Material，含子目录)");
                DrawMaterialToolbar();
                GUILayout.Space(4);
                GUILayout.BeginVertical(GUI.skin.box);
                GUILayout.Label("材质球检查列表", EditorStyles.boldLabel);
                if (!string.IsNullOrEmpty(_materialScanTimeStr))
                {
                    GUILayout.Label($"上次扫描时间：{_materialScanTimeStr}", EditorStyles.miniLabel);
                }

                DrawMaterialEntries(GetScrollHeight());
                GUILayout.EndVertical();
                DrawPagingBar();
                DrawScanProgressBar();
                return;
            }

            DrawFolderSection(_scanFolders, _folderAssets, ref _foldersDirty, "扫描路径 (仅扫描以下文件夹下的Prefab)");
            DrawToolbar();
            GUILayout.Space(4);
            GUILayout.BeginVertical(GUI.skin.box);
            GUILayout.Label("Prefab 粒子效果列表", EditorStyles.boldLabel);
            if (!string.IsNullOrEmpty(_scanTimeStr))
            {
                GUILayout.Label($"上次扫描时间：{_scanTimeStr}", EditorStyles.miniLabel);
            }

            DrawEntries(GetScrollHeight());
            GUILayout.EndVertical();
            DrawPagingBar();
            DrawScanProgressBar();
        }

        private void DrawModeTabs()
        {
            GUILayout.BeginHorizontal(EditorStyles.toolbar);
            var newMode = (ToolMode)GUILayout.Toolbar((int)_toolMode,
                new[] { "粒子Prefab预览", "材质球批量检查" }, EditorStyles.toolbarButton);
            if (newMode != _toolMode)
            {
                _toolMode = newMode;
                _currentPage = 0;
                _filterCacheDirty = true;
                _materialFilterCacheDirty = true;
            }
            GUILayout.EndHorizontal();
        }

        private void DrawFolderSection(List<string> folders, List<DefaultAsset> folderAssets, ref bool foldersDirty,
            string title)
        {
            GUILayout.BeginVertical(GUI.skin.box);
            GUILayout.Label(title, EditorStyles.boldLabel);
            _folderScroll = GUILayout.BeginScrollView(_folderScroll, GUILayout.Height(GetFolderSectionHeight(folders)));
            int removeIdx = -1;
            for (int i = 0; i < folders.Count; i++)
            {
                GUILayout.BeginHorizontal();
                var oldAsset = i < folderAssets.Count ? folderAssets[i] : null;
                var newAsset = (DefaultAsset)EditorGUILayout.ObjectField(oldAsset, typeof(DefaultAsset), false);
                string newPath = newAsset ? AssetDatabase.GetAssetPath(newAsset) : string.Empty;
                if (newPath != folders[i])
                {
                    folders[i] = newPath;
                    if (i < folderAssets.Count) folderAssets[i] = newAsset;
                    else folderAssets.Add(newAsset);
                    foldersDirty = true;
                }

                if (GUILayout.Button("-", GUILayout.Width(24))) removeIdx = i;
                GUILayout.EndHorizontal();
            }

            if (removeIdx >= 0 && folders.Count > 1)
            {
                folders.RemoveAt(removeIdx);
                if (removeIdx < folderAssets.Count) folderAssets.RemoveAt(removeIdx);
                foldersDirty = true;
            }

            GUILayout.EndScrollView();
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("+", GUILayout.Width(28)))
            {
                folders.Add("Assets");
                folderAssets.Add(AssetDatabase.LoadAssetAtPath<DefaultAsset>("Assets"));
                foldersDirty = true;
            }

            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label(foldersDirty ? "* 未保存的路径更改" : "路径已保存", EditorStyles.miniLabel, GUILayout.Width(140));
            GUILayout.FlexibleSpace();
            GUI.enabled = foldersDirty;
            if (GUILayout.Button("保存路径设置", GUILayout.Width(120)))
            {
                if (_toolMode == ToolMode.Material)
                {
                    _scanResultSo.materialScanFolders = new List<string>(_materialScanFolders);
                    _materialFoldersDirty = false;
                }
                else
                {
                    _scanResultSo.scanFolders = new List<string>(_scanFolders);
                    _foldersDirty = false;
                }

                EditorUtility.SetDirty(_scanResultSo);
                AssetDatabase.SaveAssets();
                foldersDirty = false;
            }

            GUI.enabled = true;
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();
        }

        private float GetFolderSectionHeight(List<string> folders)
        {
            var allFolderHeight = folders != null ? FolderFieldHeight * Mathf.Min(folders.Count, 5) : 0f;
            return allFolderHeight + 20f;
        }

        private void DrawToolbar()
        {
            GUILayout.BeginHorizontal(EditorStyles.helpBox);
            DrawSearchField();

            EditorGUI.BeginDisabledGroup(_isScanning || _isPreviewing);
            if (GUILayout.Button("重新收集", GUILayout.Width(90)))
            {
                if (EditorUtility.DisplayDialog("准备重新收集",
                        "重新收集将扫描所有配置路径下的Prefab，需要等待一段时间，是否继续？", "继续", "取消"))
                {
                    StartScan(false);
                }
            }
            EditorGUI.EndDisabledGroup();

            var selectedCount = string.IsNullOrEmpty(_search)
                ? _previewSelected.Count
                : GetFilteredEntriesCached().Count(e => _previewSelected.Contains(e.PrefabPath));
            DrawPreviewButton(selectedCount, ToolMode.ParticlePrefab);
            GUILayout.FlexibleSpace();
            GUILayout.Label($"共 {_entries.Count} 个Prefab", GUILayout.Width(120));
            GUILayout.EndHorizontal();
        }

        private void DrawMaterialToolbar()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            var showColliders = EditorGUILayout.ToggleLeft("显示 Collider", _showMaterialColliders, GUILayout.Width(120));
            if (showColliders != _showMaterialColliders)
            {
                _showMaterialColliders = showColliders;
                ParticlePrefabPreviewSceneHelper.SetMaterialCollidersVisible(_showMaterialColliders);
            }
            EditorGUILayout.EndVertical();

            DrawMaterialShaderSkipSection();

            GUILayout.BeginHorizontal(EditorStyles.helpBox);
            DrawSearchField();

            EditorGUI.BeginDisabledGroup(_isScanning || _isPreviewing);
            if (GUILayout.Button("一键检查缺失", GUILayout.Width(110)))
            {
                RunMaterialAssetCheck();
            }

            GUILayout.Space(4f);
            if (GUILayout.Button("检查材质", GUILayout.Width(90)))
            {
                if (EditorUtility.DisplayDialog("准备检查材质",
                        "将扫描所有配置路径下的Material并检查贴图/Shader，需要等待一段时间，是否继续？", "继续", "取消"))
                {
                    StartScan(true);
                }
            }
            EditorGUI.EndDisabledGroup();

            var selectedCount = string.IsNullOrEmpty(_search)
                ? _materialPreviewSelected.Count
                : GetFilteredMaterialEntriesCached().Count(e => _materialPreviewSelected.Contains(e.MaterialPath));
            DrawPreviewButton(selectedCount, ToolMode.Material);
            GUILayout.FlexibleSpace();
            var issueCount = _materialEntries.Count(e => e.HasIssue);
            GUILayout.Label($"共 {_materialEntries.Count} 个Material / 异常 {issueCount}", GUILayout.Width(180));
            GUILayout.EndHorizontal();
        }

        private void DrawMaterialShaderSkipSection()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    _showMaterialShaderSkipConfig = EditorGUILayout.Foldout(_showMaterialShaderSkipConfig,
                        $"主贴图缺失检查 - 跳过Shader ({_materialTextureCheckSkippedShaders.Count})", true);
                    GUILayout.FlexibleSpace();
                    GUILayout.Label(_materialShaderSkipDirty ? "* 未保存" : "已保存", EditorStyles.miniLabel, GUILayout.Width(60));
                    GUI.enabled = _materialShaderSkipDirty;
                    if (GUILayout.Button("保存Shader配置", GUILayout.Width(120)))
                    {
                        SaveMaterialShaderSkipConfig();
                    }
                    GUI.enabled = true;
                }

                if (!_showMaterialShaderSkipConfig)
                {
                    return;
                }

                using (new EditorGUILayout.HorizontalScope())
                {
                    var shader = (Shader)EditorGUILayout.ObjectField("添加Shader", null, typeof(Shader), false);
                    if (shader != null && !_materialTextureCheckSkippedShaders.Contains(shader.name))
                    {
                        _materialTextureCheckSkippedShaders.Add(shader.name);
                        _materialShaderSkipDirty = true;
                    }
                }

                var removeIndex = -1;
                using (var scroll = new EditorGUILayout.ScrollViewScope(_materialShaderSkipScroll, GUILayout.MaxHeight(140f)))
                {
                    _materialShaderSkipScroll = scroll.scrollPosition;
                    for (int i = 0; i < _materialTextureCheckSkippedShaders.Count; i++)
                    {
                        using (new EditorGUILayout.HorizontalScope())
                        {
                            var next = EditorGUILayout.TextField(_materialTextureCheckSkippedShaders[i]);
                            if (next != _materialTextureCheckSkippedShaders[i])
                            {
                                _materialTextureCheckSkippedShaders[i] = next;
                                _materialShaderSkipDirty = true;
                            }

                            if (GUILayout.Button("-", GUILayout.Width(24)))
                            {
                                removeIndex = i;
                            }
                        }
                    }
                }

                if (removeIndex >= 0)
                {
                    _materialTextureCheckSkippedShaders.RemoveAt(removeIndex);
                    _materialShaderSkipDirty = true;
                }
            }
        }

        private void DrawSearchField()
        {
            GUI.enabled = !_isScanning;
            var iconRect = GUILayoutUtility.GetRect(18, 18, GUILayout.Width(18));
            var icon = EditorGUIUtility.IconContent("Search Icon");
            GUI.Label(iconRect, icon);
            var newSearch = GUILayout.TextField(_search, GUILayout.MinWidth(160), GUILayout.ExpandWidth(true));
            if (!string.Equals(newSearch, _search))
            {
                _search = newSearch;
                _filterCacheDirty = true;
                _materialFilterCacheDirty = true;
                _currentPage = 0;
            }
            GUI.enabled = true;
        }

        private void DrawPreviewButton(int selectedCount, ToolMode previewMode)
        {
            if (!_isPreviewing)
            {
                GUI.enabled = selectedCount > 0;
                if (GUILayout.Button("预览", GUILayout.Width(90)))
                {
                    _isPreviewing = true;
                    _previewToolMode = previewMode;
                    _previewPage = 0;
                    BuildPreviewTargets(previewMode);
                    if (previewMode == ToolMode.ParticlePrefab && !EditorApplication.isPlaying)
                    {
                        RequestParticlePlayModePreview();
                    }
                    else
                    {
                        ShowPreviewScene();
                        ParticlePrefabPreviewSceneHelper.OpenControlWindow();
                    }
                }
                GUI.enabled = true;
            }
            else
            {
                GUILayout.Label("预览中… 请使用“Particle Preview”控制窗口进行操作", EditorStyles.miniLabel);
            }
        }

        private void RunMaterialAssetCheck()
        {
            var report = MaterialAssetChecker.Run(_materialScanFolders, _materialTextureCheckSkippedShaders);
            MaterialAssetCheckReportWindow.ShowReport(report);
            Debug.Log($"[MaterialAssetCheck] 一键检查完成：材质={report.MaterialCount}; 错误={report.ErrorCount}; 警告={report.WarningCount}");
        }

        private void BuildPreviewTargets(ToolMode previewMode)
        {
            if (previewMode == ToolMode.Material)
            {
                _materialPreviewTargets = string.IsNullOrEmpty(_search)
                    ? _materialPreviewSelected.ToList()
                    : _materialPreviewSelected
                        .Where(path => GetFilteredMaterialEntriesCached().Any(e => e.MaterialPath == path))
                        .ToList();
                return;
            }

            _previewTargets = string.IsNullOrEmpty(_search)
                ? _previewSelected.ToList()
                : _previewSelected
                    .Where(path => GetFilteredEntriesCached().Any(e => e.PrefabPath == path))
                    .ToList();
        }

        private void RequestParticlePlayModePreview()
        {
            var paths = _previewTargets ?? new List<string>();
            EditorPrefs.SetString(PendingParticlePreviewPathsPrefsKey, string.Join(PendingPathSeparator.ToString(), paths));
            EditorPrefs.SetInt(PendingParticlePreviewPagePrefsKey, _previewPage);
            EditorPrefs.SetBool(PendingParticlePreviewPrefsKey, true);
            ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
            ParticlePrefabPreviewSceneHelper.PrepareEmptyPlayModeStartScene();
            EditorApplication.EnterPlaymode();
        }

        private void TryRestorePendingParticlePreview()
        {
            if (!EditorApplication.isPlaying || !EditorPrefs.GetBool(PendingParticlePreviewPrefsKey, false))
            {
                return;
            }

            _previewTargets = EditorPrefs.GetString(PendingParticlePreviewPathsPrefsKey, string.Empty)
                .Split(new[] { PendingPathSeparator }, StringSplitOptions.RemoveEmptyEntries)
                .Where(path => AssetDatabase.LoadAssetAtPath<GameObject>(path) != null)
                .ToList();
            _previewPage = Mathf.Max(0, EditorPrefs.GetInt(PendingParticlePreviewPagePrefsKey, 0));
            _previewToolMode = ToolMode.ParticlePrefab;
            _isPreviewing = _previewTargets.Count > 0;
            if (!_isPreviewing)
            {
                Debug.LogWarning("[ParticlePrefabPreview] 进入PlayMode后没有读取到有效的粒子Prefab路径，预览已取消。");
                ClearPendingParticlePreviewState();
                return;
            }

            ShowPreviewScene();
            ParticlePrefabPreviewSceneHelper.OpenControlWindow();
            Repaint();
        }

        private void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.EnteredPlayMode)
            {
                TryRestorePendingParticlePreview();
            }
            else if (state == PlayModeStateChange.ExitingPlayMode)
            {
                ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
            }
            else if (state == PlayModeStateChange.EnteredEditMode && EditorPrefs.GetBool(PendingParticlePreviewPrefsKey, false))
            {
                _isPreviewing = false;
                _previewTargets = null;
                ParticlePrefabPreviewSceneHelper.ClearPlayModeStartScene();
                ClearPendingParticlePreviewState();
                Repaint();
            }
        }

        private static void ClearPendingParticlePreviewState()
        {
            EditorPrefs.DeleteKey(PendingParticlePreviewPrefsKey);
            EditorPrefs.DeleteKey(PendingParticlePreviewPathsPrefsKey);
            EditorPrefs.DeleteKey(PendingParticlePreviewPagePrefsKey);
        }

        private void DrawEntries(float scrollHeight)
        {
            var filtered = GetFilteredEntriesCached();
            DrawListHeader(filtered.Count, filtered.Count(e => _previewSelected.Contains(e.PrefabPath)),
                () => { foreach (var e in filtered) _previewSelected.Add(e.PrefabPath); },
                () => { foreach (var e in filtered) _previewSelected.Remove(e.PrefabPath); },
                "Prefab");

            _scroll = GUILayout.BeginScrollView(_scroll, false, false, GUILayout.Height(scrollHeight));
            GetPageRange(filtered.Count, out var start, out var end);
            for (int i = start; i < end; i++)
            {
                var e = filtered[i];
                GUILayout.BeginVertical(GUI.skin.box);
                GUILayout.BeginHorizontal();
                DrawSelectionToggle(_previewSelected, e.PrefabPath);
                EditorGUI.BeginDisabledGroup(true);
                EditorGUILayout.ObjectField(e.PrefabAsset, typeof(GameObject), false, GUILayout.Width(180f));
                EditorGUI.EndDisabledGroup();
                EditorGUILayout.SelectableLabel(e.PrefabPath, EditorStyles.wordWrappedMiniLabel,
                    GUILayout.MinHeight(EditorGUIUtility.singleLineHeight * 2));
                GUILayout.EndHorizontal();
                GUILayout.EndVertical();
            }
            GUILayout.EndScrollView();
        }

        private void DrawMaterialEntries(float scrollHeight)
        {
            var filtered = GetFilteredMaterialEntriesCached();
            DrawListHeader(filtered.Count, filtered.Count(e => _materialPreviewSelected.Contains(e.MaterialPath)),
                () => { foreach (var e in filtered) _materialPreviewSelected.Add(e.MaterialPath); },
                () => { foreach (var e in filtered) _materialPreviewSelected.Remove(e.MaterialPath); },
                "Material");

            _scroll = GUILayout.BeginScrollView(_scroll, false, false, GUILayout.Height(scrollHeight));
            GetPageRange(filtered.Count, out var start, out var end);
            for (int i = start; i < end; i++)
            {
                var e = filtered[i];
                GUILayout.BeginVertical(GUI.skin.box);
                GUILayout.BeginHorizontal();
                DrawSelectionToggle(_materialPreviewSelected, e.MaterialPath);
                EditorGUI.BeginDisabledGroup(true);
                EditorGUILayout.ObjectField(e.MaterialAsset, typeof(Material), false, GUILayout.Width(160f));
                EditorGUI.EndDisabledGroup();

                using (new EditorGUILayout.VerticalScope())
                {
                    var oldColor = GUI.contentColor;
                    if (e.HasIssue) GUI.contentColor = Color.red;
                    EditorGUILayout.SelectableLabel(e.MaterialPath, EditorStyles.wordWrappedMiniLabel,
                        GUILayout.MinHeight(EditorGUIUtility.singleLineHeight * 2));
                    GUI.contentColor = oldColor;

                    var shaderName = e.MaterialAsset != null && e.MaterialAsset.shader != null ? e.MaterialAsset.shader.name : "<missing shader>";
                    EditorGUILayout.LabelField($"Shader: {shaderName}", EditorStyles.miniLabel);
                    if (e.HasIssue)
                    {
                        EditorGUILayout.HelpBox(e.IssueText, MessageType.Error);
                    }
                }

                GUILayout.EndHorizontal();
                GUILayout.EndVertical();
            }
            GUILayout.EndScrollView();
        }

        private void DrawListHeader(int filteredCount, int selectedCount, Action selectAll, Action deselectAll, string nameLabel)
        {
            _previewSelectAll = selectedCount == filteredCount && filteredCount > 0;
            _previewSelectPartial = selectedCount > 0 && selectedCount < filteredCount;
            GUILayout.BeginHorizontal();
            GUILayout.Space(5f);
            var toggleRect = GUILayoutUtility.GetRect(18f, 18f, GUILayout.Width(18f));
            var icon = _previewSelectPartial ? "-" : _previewSelectAll ? "✓" : string.Empty;
            var style = new GUIStyle(EditorStyles.miniButton)
            {
                alignment = TextAnchor.MiddleCenter,
                fontSize = 8,
            };
            EditorGUI.BeginDisabledGroup(_isPreviewing);
            if (GUI.Button(toggleRect, icon, style))
            {
                if (_previewSelectPartial || !_previewSelectAll) selectAll();
                else deselectAll();
            }
            EditorGUI.EndDisabledGroup();

            DrawSortLabel(nameLabel, SortColumn.Name, 180f);
            DrawSortLabel("路径", SortColumn.Path, EditorGUIUtility.currentViewWidth - 260f);
            GUILayout.EndHorizontal();
        }

        private void DrawSelectionToggle(HashSet<string> selected, string path)
        {
            var sel = selected.Contains(path);
            EditorGUI.BeginDisabledGroup(_isPreviewing);
            var newSel = GUILayout.Toggle(sel, GUIContent.none, GUILayout.Width(22f));
            EditorGUI.EndDisabledGroup();
            if (newSel == sel) return;
            if (newSel) selected.Add(path);
            else selected.Remove(path);
        }

        private void DrawSortLabel(string label, SortColumn column, float width)
        {
            string icon = _sortColumn == column ? (_sortAscending ? " ▲" : " ▼") : string.Empty;
            var style = new GUIStyle(EditorStyles.label)
            {
                fontStyle = FontStyle.Bold,
                alignment = TextAnchor.MiddleLeft,
                fixedHeight = 22,
                padding = new RectOffset(4, 4, 0, 0)
            };
            var rect = GUILayoutUtility.GetRect(new GUIContent(label + icon), style, GUILayout.Width(width));
            if (rect.Contains(Event.current.mousePosition))
            {
                EditorGUIUtility.AddCursorRect(rect, MouseCursor.Link);
            }

            if (GUI.Button(rect, label + icon, style))
            {
                if (_sortColumn == column) _sortAscending = !_sortAscending;
                else
                {
                    _sortColumn = column;
                    _sortAscending = true;
                }

                _filterCacheDirty = true;
                _materialFilterCacheDirty = true;
            }
        }

        private void DrawPagingBar()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("每页:", GUILayout.Width(40));
            _pageSize = EditorGUILayout.IntField(_pageSize, GUILayout.Width(50));
            if (_pageSize < 5) _pageSize = 5;
            GUILayout.Space(20);
            GUI.enabled = _currentPage > 0;
            if (GUILayout.Button("上一页", GUILayout.Width(70))) _currentPage--;
            GUI.enabled = _currentPage < _totalPages - 1;
            if (GUILayout.Button("下一页", GUILayout.Width(70))) _currentPage++;
            GUI.enabled = true;
            GUILayout.Label($"第 {_currentPage + 1} / {_totalPages} 页", GUILayout.Width(120));
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();
        }

        private void DrawScanProgressBar()
        {
            if (!_isScanning) return;
            GUILayout.BeginHorizontal();
            var r = GUILayoutUtility.GetRect(200, 18, GUILayout.ExpandWidth(true));
            var label = _scanningMaterials ? "检查材质" : "扫描Prefab";
            EditorGUI.ProgressBar(r, _scanProgress, $"{label}: {_scanCursor}/{_pendingGuids.Count}");
            GUILayout.EndHorizontal();
        }

        private void GetPageRange(int count, out int start, out int end)
        {
            _totalPages = Mathf.Max(1, Mathf.CeilToInt(count / (float)_pageSize));
            if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
            start = _currentPage * _pageSize;
            end = Mathf.Min(start + _pageSize, count);
        }

        private float GetScrollHeight()
        {
            var paging = 36f;
            var progress = 26f;
            var top = 196f + GetFolderSectionHeight(_toolMode == ToolMode.Material ? _materialScanFolders : _scanFolders);
            if (_toolMode == ToolMode.Material)
            {
                top += _showMaterialShaderSkipConfig ? 190f : 42f;
            }

            var h = position.height - top - paging - progress;
            return Mathf.Max(80f, h);
        }

        private void StartScan(bool materials)
        {
            StopScan();
            _scanningMaterials = materials;
            _currentPage = 0;
            _pendingGuids = new List<string>();
            var folders = materials ? _materialScanFolders : _scanFolders;
            foreach (var folder in folders)
            {
                if (!string.IsNullOrEmpty(folder) && AssetDatabase.IsValidFolder(folder))
                {
                    _pendingGuids.AddRange(AssetDatabase.FindAssets(materials ? "t:Material" : "t:Prefab", new[] { folder }));
                }
            }

            _pendingGuids = _pendingGuids.Distinct().ToList();
            _scanCursor = 0;
            _scanProgress = 0f;
            _isScanning = true;
            if (materials)
            {
                _materialEntries.Clear();
                _materialPreviewSelected.Clear();
                _materialFilterCacheDirty = true;
            }
            else
            {
                _entries.Clear();
                _previewSelected.Clear();
                _filterCacheDirty = true;
            }

            EditorApplication.update += UpdateScan;
        }

        private void StopScan()
        {
            _isScanning = false;
            EditorApplication.update -= UpdateScan;
            _pendingGuids.Clear();
            _scanCursor = 0;
            _scanProgress = 0f;
        }

        private void UpdateScan()
        {
            if (!_isScanning) return;
            const int perFrame = 5;
            var processed = 0;
            var existingParticlePaths = _scanningMaterials ? null : new HashSet<string>(_entries.Select(e => e.PrefabPath));
            var existingMaterialPaths = _scanningMaterials ? new HashSet<string>(_materialEntries.Select(e => e.MaterialPath)) : null;

            while (_scanCursor < _pendingGuids.Count && processed < perFrame)
            {
                var path = AssetDatabase.GUIDToAssetPath(_pendingGuids[_scanCursor++]);
                if (_scanningMaterials)
                {
                    if (IsModelEmbeddedMaterialPath(path))
                    {
                        processed++;
                        continue;
                    }

                    if (!existingMaterialPaths.Contains(path))
                    {
                        var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                        if (material)
                        {
                            existingMaterialPaths.Add(path);
                            _materialEntries.Add(CreateMaterialEntry(path, material));
                        }
                    }
                }
                else if (!existingParticlePaths.Contains(path))
                {
                    var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                    if (go && go.GetComponentInChildren<ParticleSystem>(true))
                    {
                        existingParticlePaths.Add(path);
                        _entries.Add(new Entry
                        {
                            PrefabPath = path,
                            PrefabName = Path.GetFileNameWithoutExtension(path),
                            PrefabAsset = go
                        });
                    }
                }

                processed++;
            }

            _scanProgress = _pendingGuids.Count == 0 ? 1f : _scanCursor / (float)_pendingGuids.Count;
            if (_scanCursor >= _pendingGuids.Count)
            {
                var wasScanningMaterials = _scanningMaterials;
                StopScan();
                if (wasScanningMaterials) SaveMaterialScanResultFromEntries();
                else SaveScanResultFromEntries();
            }

            if (processed > 0)
            {
                _filterCacheDirty = true;
                _materialFilterCacheDirty = true;
            }

            Repaint();
        }

        private MaterialEntry CreateMaterialEntry(string path, Material material)
        {
            AnalyzeMaterial(material, _materialTextureCheckSkippedShaders, out var hasIssue, out var issueText);
            return new MaterialEntry
            {
                MaterialPath = path,
                MaterialName = Path.GetFileNameWithoutExtension(path),
                MaterialAsset = material,
                HasIssue = hasIssue,
                IssueText = issueText
            };
        }

        private static void AnalyzeMaterial(Material material, IReadOnlyList<string> textureCheckSkippedShaders, out bool hasIssue, out string issueText)
        {
            var issues = new List<string>();
            var shaderName = material.shader ? material.shader.name : string.Empty;
            if (!IsTextureCheckSkipped(shaderName, textureCheckSkippedShaders) && !HasAnyTexture(material, "_MainTex", "_BaseMap", "_BaseTex"))
            {
                issues.Add("MainTex/BaseMap/BaseTex为空");
            }

            if (shaderName.StartsWith("Hidden/", StringComparison.OrdinalIgnoreCase) ||
                shaderName.IndexOf("Error", StringComparison.OrdinalIgnoreCase) >= 0 ||
                shaderName.IndexOf("Fallback", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                issues.Add($"Shader异常: {shaderName}");
            }

            hasIssue = issues.Count > 0;
            issueText = string.Join("; ", issues);
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
                if (material.HasProperty(propertyName) && material.GetTexture(propertyName))
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

        private void RefreshMaterialEntriesIssueState()
        {
            foreach (var entry in _materialEntries)
            {
                if (entry.MaterialAsset == null)
                {
                    continue;
                }

                AnalyzeMaterial(entry.MaterialAsset, _materialTextureCheckSkippedShaders, out entry.HasIssue, out entry.IssueText);
            }

            _materialFilterCacheDirty = true;
            Repaint();
        }

        private void ShowPreviewScene()
        {
            if (_previewToolMode == ToolMode.Material)
            {
                var all = _materialPreviewTargets ?? _materialPreviewSelected.ToList();
                var paths = GetPreviewPagePaths(all);
                var materials = new List<MaterialPreviewItem>();
                foreach (var path in paths)
                {
                    var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                    if (!material) continue;
                    AnalyzeMaterial(material, _materialTextureCheckSkippedShaders, out var hasIssue, out var issueText);
                    materials.Add(new MaterialPreviewItem
                    {
                        Material = material,
                        HasIssue = hasIssue,
                        IssueText = issueText
                    });
                }

                ParticlePrefabPreviewSceneHelper.OpenPreviewScene();
                ParticlePrefabPreviewSceneHelper.SpawnMaterials(materials, _showMaterialColliders);
                Selection.objects = ParticlePrefabPreviewSceneHelper.GetSpawnedPrefabs()
                    .Where(go => go)
                    .Cast<UnityEngine.Object>()
                    .ToArray();
                return;
            }

            var prefabPaths = GetPreviewPagePaths(_previewTargets ?? _previewSelected.ToList());
            var prefabs = prefabPaths.Select(AssetDatabase.LoadAssetAtPath<GameObject>).Where(go => go).ToList();
            ParticlePrefabPreviewSceneHelper.OpenPreviewScene();
            ParticlePrefabPreviewSceneHelper.SpawnPrefabs(prefabs);
            Selection.objects = ParticlePrefabPreviewSceneHelper.GetSpawnedPrefabs()
                .Where(go => go)
                .Cast<UnityEngine.Object>()
                .ToArray();
        }

        private List<string> GetPreviewPagePaths(List<string> all)
        {
            var maxPage = Mathf.Max(0, Mathf.CeilToInt(all.Count / (float)PreviewPageSize) - 1);
            if (_previewPage > maxPage) _previewPage = maxPage;
            var start = _previewPage * PreviewPageSize;
            var end = Mathf.Min(start + PreviewPageSize, all.Count);
            return all.GetRange(start, end - start);
        }

        public static void CancelParticlePreviewLifecycle()
        {
            if (_instance != null)
            {
                _instance._isPreviewing = false;
                _instance._previewTargets = null;
                _instance._materialPreviewTargets = null;
            }

            ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
            ParticlePrefabPreviewSceneHelper.ClearPlayModeStartScene();
            ClearPendingParticlePreviewState();
        }

        public static void EndPreviewFromControl()
        {
            if (_instance == null || !_instance._isPreviewing) return;
            _instance._isPreviewing = false;
            ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
            _instance._previewTargets = null;
            _instance._materialPreviewTargets = null;
            if (EditorPrefs.GetBool(PendingParticlePreviewPrefsKey, false))
            {
                ParticlePrefabPreviewSceneHelper.ClearPlayModeStartScene();
                ClearPendingParticlePreviewState();
                if (EditorApplication.isPlaying)
                {
                    EditorApplication.ExitPlaymode();
                }
            }
            _instance.Repaint();
        }

        public static void NextPageFromControl()
        {
            if (_instance == null || !_instance._isPreviewing) return;
            var all = _instance.GetActivePreviewTargets();
            if (all.Count == 0) return;
            var maxPage = Mathf.Max(0, Mathf.CeilToInt(all.Count / (float)PreviewPageSize) - 1);
            _instance._previewPage = _instance._previewPage >= maxPage ? 0 : _instance._previewPage + 1;
            EditorPrefs.SetInt(PendingParticlePreviewPagePrefsKey, _instance._previewPage);
            _instance.ShowPreviewScene();
        }

        public static void PrevPageFromControl()
        {
            if (_instance == null || !_instance._isPreviewing) return;
            var all = _instance.GetActivePreviewTargets();
            if (all.Count == 0) return;
            var maxPage = Mathf.Max(0, Mathf.CeilToInt(all.Count / (float)PreviewPageSize) - 1);
            _instance._previewPage = _instance._previewPage <= 0 ? maxPage : _instance._previewPage - 1;
            EditorPrefs.SetInt(PendingParticlePreviewPagePrefsKey, _instance._previewPage);
            _instance.ShowPreviewScene();
        }

        public static void GetPageInfo(out int currentPage, out int maxPage, out int startIdx, out int endIdx,
            out int total)
        {
            currentPage = 0;
            maxPage = 0;
            startIdx = 0;
            endIdx = 0;
            total = 0;
            if (_instance == null || !_instance._isPreviewing) return;
            var all = _instance.GetActivePreviewTargets();
            total = all.Count;
            maxPage = Mathf.Max(0, Mathf.CeilToInt(total / (float)PreviewPageSize) - 1);
            currentPage = Mathf.Clamp(_instance._previewPage, 0, maxPage);
            startIdx = total == 0 ? 0 : currentPage * PreviewPageSize + 1;
            endIdx = Mathf.Min((currentPage + 1) * PreviewPageSize, total);
        }

        private List<string> GetActivePreviewTargets()
        {
            return _previewToolMode == ToolMode.Material
                ? _materialPreviewTargets ?? _materialPreviewSelected.ToList()
                : _previewTargets ?? _previewSelected.ToList();
        }

        private List<Entry> GetFilteredEntriesCached()
        {
            if (!_filterCacheDirty) return _cachedFiltered;
            _cachedFiltered.Clear();
            foreach (var e in _entries)
            {
                if (string.IsNullOrEmpty(_search) ||
                    e.PrefabPath.IndexOf(_search, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    _cachedFiltered.Add(e);
                }
            }

            SortEntries(_cachedFiltered, e => e.PrefabName, e => e.PrefabPath);
            _filterCacheDirty = false;
            return _cachedFiltered;
        }

        private List<MaterialEntry> GetFilteredMaterialEntriesCached()
        {
            if (!_materialFilterCacheDirty) return _cachedMaterialFiltered;
            _cachedMaterialFiltered.Clear();
            foreach (var e in _materialEntries)
            {
                if (string.IsNullOrEmpty(_search) ||
                    e.MaterialPath.IndexOf(_search, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    e.IssueText.IndexOf(_search, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    _cachedMaterialFiltered.Add(e);
                }
            }

            SortEntries(_cachedMaterialFiltered, e => e.MaterialName, e => e.MaterialPath);
            _materialFilterCacheDirty = false;
            return _cachedMaterialFiltered;
        }

        private void SortEntries<T>(List<T> list, Func<T, string> nameGetter, Func<T, string> pathGetter)
        {
            Comparison<T> comparison = _sortColumn == SortColumn.Name
                ? (a, b) => string.Compare(nameGetter(a), nameGetter(b), StringComparison.Ordinal)
                : (a, b) => string.Compare(pathGetter(a), pathGetter(b), StringComparison.Ordinal);
            if (!_sortAscending)
            {
                list.Sort((a, b) => comparison(b, a));
                return;
            }

            list.Sort(comparison);
        }

        private void ImportExternalPrefabPathsInternal(List<string> prefabPaths)
        {
            if (_isPreviewing)
            {
                _isPreviewing = false;
                ParticlePrefabPreviewSceneHelper.ClosePreviewScene();
            }

            var existingPathSet = new HashSet<string>(_entries.Select(e => e.PrefabPath));
            _previewSelected.Clear();
            var addedCount = 0;
            var selectedCount = 0;
            var invalidCount = 0;

            foreach (var path in prefabPaths)
            {
                var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (!go || go.GetComponentInChildren<ParticleSystem>(true) == null)
                {
                    invalidCount++;
                    continue;
                }

                if (!existingPathSet.Contains(path))
                {
                    _entries.Add(new Entry
                    {
                        PrefabPath = path,
                        PrefabName = Path.GetFileNameWithoutExtension(path),
                        PrefabAsset = go
                    });
                    existingPathSet.Add(path);
                    addedCount++;
                }

                if (_previewSelected.Add(path)) selectedCount++;
            }

            _toolMode = ToolMode.ParticlePrefab;
            _previewPage = 0;
            _currentPage = 0;
            _search = string.Empty;
            _filterCacheDirty = true;
            SaveScanResultFromEntries();
            Repaint();

            EditorUtility.DisplayDialog(
                "导入完成",
                $"已同步到特效批量预览器\n新增到列表：{addedCount} 个\n已选中可预览：{selectedCount} 个\n无效或非粒子Prefab：{invalidCount} 个",
                "确定");
        }
    }
}
