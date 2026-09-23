using System;
using System.Collections.Generic;
using System.Linq;
using Coffee.UIExtensions;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.EffectPreview
{
    public enum EffectPreviewKind
    {
        UIParticle,
        SpriteAnimation
    }

    public sealed class EffectPreviewEntry
    {
        public string Path;
        public GameObject Prefab;
        public EffectPreviewKind Kind;
        public bool HasIssue;
        public string Issue;
    }

    public sealed class EffectPreviewWindow : EditorWindow
    {
        private const string SearchRoot = "Assets/GameAsset/Effect";
        private readonly List<EffectPreviewEntry> _entries = new List<EffectPreviewEntry>();
        private Vector2 _scroll;
        private string _filter = string.Empty;
        private int _kind;
        private bool _onlyIssues;
        private bool _showLabels = true;
        private int _columns = 8;
        private float _spacing = 4f;
        private bool _previewing;

        public static void Open() => ArtAssetBatchCheckWindow.Open(3);

        private void OnEnable()
        {
            EffectPreviewSceneHelper.TickRequested += TickPreview;
            Scan();
        }

        private void OnDisable()
        {
            EffectPreviewSceneHelper.TickRequested -= TickPreview;
            EffectPreviewSceneHelper.ClosePreviewScene();
        }

        public void DrawToolGUI()
        {
            using (var scroll = new EditorGUILayout.ScrollViewScope(_scroll))
            {
                _scroll = scroll.scrollPosition;
                DrawSettings();
                EditorGUILayout.Space(6f);
                DrawActions();
                EditorGUILayout.Space(6f);
                DrawList();
            }
        }

        private void DrawSettings()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("特效类型", EditorStyles.boldLabel);
                var nextKind = EditorGUILayout.Popup("预览对象", _kind, new[] { "UIParticle驱动特效", "SpriteAnimationEffect驱动特效" });
                if (nextKind != _kind) { _kind = nextKind; Scan(); }
                _filter = EditorGUILayout.TextField("名称过滤", _filter);
                _onlyIssues = EditorGUILayout.Toggle("仅显示有问题", _onlyIssues);
                _showLabels = EditorGUILayout.Toggle("显示标签", _showLabels);
                _columns = EditorGUILayout.IntSlider("每行数量", _columns, 1, 20);
                _spacing = EditorGUILayout.Slider("排列间隔", _spacing, 1f, 20f);
            }
        }

        private void DrawActions()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button("重新扫描", GUILayout.Height(30))) Scan();
                    var background = GUI.backgroundColor;
                    GUI.backgroundColor = new Color(0.45f, 0.85f, 0.5f);
                    if (GUILayout.Button(_previewing ? "刷新预览" : "生成批量预览", GUILayout.Height(30))) GeneratePreview();
                    if (GUILayout.Button("播放预览", GUILayout.Height(30))) EffectPreviewSceneHelper.Play();
                    GUI.backgroundColor = new Color(0.5f, 0.7f, 1f);
                    if (GUILayout.Button("停止预览", GUILayout.Height(30))) EffectPreviewSceneHelper.Stop();
                    GUI.backgroundColor = new Color(1f, 0.4f, 0.4f);
                    if (GUILayout.Button("结束预览", GUILayout.Height(30))) EndPreview();
                    GUI.backgroundColor = background;
                }

                EditorGUILayout.LabelField($"扫描路径：{SearchRoot}    数量：{GetFilteredEntries().Count()}    问题：{_entries.Count(e => e.HasIssue)}",
                    EditorStyles.miniLabel);
            }
        }

        private void DrawList()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("预制体列表", EditorStyles.boldLabel);
                foreach (var entry in GetFilteredEntries())
                {
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        EditorGUILayout.LabelField(entry.HasIssue ? "[问题]" : "[正常]", GUILayout.Width(48));
                        EditorGUILayout.ObjectField(entry.Prefab, typeof(GameObject), false);
                        if (entry.HasIssue) EditorGUILayout.LabelField(entry.Issue, EditorStyles.miniLabel);
                        if (GUILayout.Button("定位", GUILayout.Width(45))) Selection.activeObject = entry.Prefab;
                    }
                }
            }
        }

        private IEnumerable<EffectPreviewEntry> GetFilteredEntries()
        {
            var kind = _kind == 0 ? EffectPreviewKind.UIParticle : EffectPreviewKind.SpriteAnimation;
            return _entries.Where(e => e.Kind == kind && (!_onlyIssues || e.HasIssue) &&
                (string.IsNullOrEmpty(_filter) || e.Path.IndexOf(_filter, StringComparison.OrdinalIgnoreCase) >= 0));
        }

        private void Scan()
        {
            _entries.Clear();
            foreach (var guid in AssetDatabase.FindAssets("t:Prefab", new[] { SearchRoot }))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (!prefab) continue;

                var uiParticles = prefab.GetComponentsInChildren<UIParticle>(true);
                if (uiParticles.Length > 0)
                {
                    var invalid = uiParticles.Any(p => p == null || p.particles == null || p.particles.Count == 0);
                    _entries.Add(new EffectPreviewEntry { Path = path, Prefab = prefab, Kind = EffectPreviewKind.UIParticle,
                        HasIssue = invalid, Issue = invalid ? "UIParticle未关联ParticleSystem" : string.Empty });
                }

                var animations = prefab.GetComponentsInChildren<SpriteAnimation>(true);
                if (animations.Length > 0)
                {
                    var invalid = animations.Any(a => a == null || a.Renderer == null || a.Renderer.sharedMaterial == null || a.Renderer.sharedMaterial.shader == null);
                    _entries.Add(new EffectPreviewEntry { Path = path, Prefab = prefab, Kind = EffectPreviewKind.SpriteAnimation,
                        HasIssue = invalid, Issue = invalid ? "SpriteAnimation资源或材质无效" : string.Empty });
                }
            }
            Repaint();
        }

        private void GeneratePreview()
        {
            var entries = GetFilteredEntries().ToList();
            _previewing = EffectPreviewSceneHelper.Generate(entries, _columns, _spacing, _showLabels);
            Repaint();
        }

        private void TickPreview(float deltaTime)
        {
            if (_previewing) EffectPreviewSceneHelper.Tick(deltaTime);
            Repaint();
        }

        private void EndPreview()
        {
            _previewing = false;
            EffectPreviewSceneHelper.ClosePreviewScene();
            Repaint();
        }

        public static void CancelEffectPreviewLifecycle() => EffectPreviewSceneHelper.ClosePreviewScene();
    }
}
