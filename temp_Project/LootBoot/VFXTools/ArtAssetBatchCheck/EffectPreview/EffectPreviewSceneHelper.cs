using System;
using System.Collections.Generic;
using Coffee.UIExtensions;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.EffectPreview
{
    public static class EffectPreviewSceneHelper
    {
        private static Scene _scene;
        private static readonly List<GameObject> _objects = new List<GameObject>();
        private static readonly List<SpriteAnimation> _animations = new List<SpriteAnimation>();
        private static bool _playing;
        private static bool _hooked;
        private static int _columns = 8;
        private static float _spacing = 4f;
        private static bool _showLabels;
        private static readonly List<ParticleSystem> Particles = new List<ParticleSystem>();
        private static readonly List<GameObject> HiddenRoots = new List<GameObject>();
        private static Scene _previousScene;
        private static double _lastUpdateTime;

        static EffectPreviewSceneHelper()
        {
            AssemblyReloadEvents.beforeAssemblyReload += ClosePreviewScene;
            EditorApplication.quitting += ClosePreviewScene;
            EditorApplication.playModeStateChanged += state =>
            {
                if (state == PlayModeStateChange.ExitingEditMode) ClosePreviewScene();
            };
        }

        public static event Action<float> TickRequested;

        public static bool Generate(IList<EffectPreviewEntry> entries, int columns, float spacing, bool showLabels)
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode) return false;
            ClosePreviewScene();
            if (entries == null || entries.Count == 0) return false;
            _columns = Mathf.Max(1, columns);
            _spacing = Mathf.Max(0.5f, spacing);
            _showLabels = showLabels;
            _lastUpdateTime = EditorApplication.timeSinceStartup;
            _previousScene = SceneManager.GetActiveScene();
            _scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            for (var s = 0; s < SceneManager.sceneCount; s++)
            {
                var scene = SceneManager.GetSceneAt(s);
                if (scene == _scene || !scene.isLoaded) continue;
                foreach (var root in scene.GetRootGameObjects())
                    if (root.activeSelf) { HiddenRoots.Add(root); root.SetActive(false); }
            }
            SceneManager.SetActiveScene(_scene);
            EnsureUpdateHook();

            for (var i = 0; i < entries.Count; i++)
            {
                var entry = entries[i];
                if (entry == null || entry.Prefab == null) continue;
                var holder = new GameObject(entry.Prefab.name + " Preview", typeof(RectTransform));
                SceneManager.MoveGameObjectToScene(holder, _scene);
                holder.transform.position = new Vector3(i % _columns * _spacing, -(i / _columns) * _spacing, 0f);
                _objects.Add(holder);
                if (entry.Kind == EffectPreviewKind.UIParticle)
                {
                    var canvas = holder.AddComponent<Canvas>();
                    canvas.renderMode = RenderMode.WorldSpace;
                    ((RectTransform)holder.transform).sizeDelta = new Vector2(400, 400);
                    holder.transform.localScale = Vector3.one * 0.01f;
                }
                var instance = PrefabUtility.InstantiatePrefab(entry.Prefab, holder.transform) as GameObject;
                if (instance == null) continue;
                instance.name = entry.Prefab.name;
                instance.transform.localPosition = Vector3.zero;
                instance.SetActive(true);
                instance.hideFlags = HideFlags.DontSaveInEditor;
                foreach (var canvas in instance.GetComponentsInChildren<Canvas>(true)) canvas.renderMode = RenderMode.WorldSpace;

                foreach (var component in instance.GetComponentsInChildren<MonoBehaviour>(true))
                {
                    if (component == null) continue;
                    if (component is SpriteAnimation animation)
                    {
                        animation.ExternalUpdate = true;
                        animation.Initialize();
                        animation.Reset();
                        animation.Play();
                        _animations.Add(animation);
                    }
                    else if (!(component is UnityEngine.EventSystems.UIBehaviour))
                    {
                        component.enabled = false;
                    }
                }

                foreach (var uiParticle in instance.GetComponentsInChildren<UIParticle>(true))
                {
                    if (uiParticle == null) continue;
                    uiParticle.meshSharing = UIParticle.MeshSharing.None;
                    uiParticle.Play();
                }
                foreach (var ps in instance.GetComponentsInChildren<ParticleSystem>(true))
                {
                    var main = ps.main;
                    main.stopAction = ParticleSystemStopAction.None;
                    Particles.Add(ps);
                }
            }

            SceneView.duringSceneGui += DrawLabels;
            SceneView.lastActiveSceneView?.LookAt(new Vector3((_columns - 1) * _spacing / 2f, -(entries.Count / _columns) * _spacing / 2f, 0), Quaternion.identity, Mathf.Max(_spacing, _columns * _spacing * 0.6f));
            _playing = true;
            SceneView.RepaintAll();
            return _objects.Count > 0;
        }

        public static void Play()
        {
            _playing = true;
            foreach (var animation in _animations) if (animation) animation.Play();
            foreach (var root in _objects)
                if (root) foreach (var ui in root.GetComponentsInChildren<UIParticle>(true)) if (ui) ui.Play();
        }

        public static void Stop()
        {
            _playing = false;
            foreach (var animation in _animations) if (animation) animation.Stop();
            foreach (var root in _objects)
                if (root) foreach (var ui in root.GetComponentsInChildren<UIParticle>(true)) if (ui) ui.Stop();
        }

        public static void ClosePreviewScene()
        {
            _playing = false;
            _animations.Clear();
            Particles.Clear();
            SceneView.duringSceneGui -= DrawLabels;
            foreach (var root in _objects)
                if (root) UnityEngine.Object.DestroyImmediate(root);
            _objects.Clear();
            if (_hooked)
            {
                EditorApplication.update -= OnEditorUpdate;
                _hooked = false;
            }
            if (_scene.IsValid() && _scene.isLoaded && SceneManager.sceneCount > 1)
            {
                var fallback = default(Scene);
                for (var i = 0; i < SceneManager.sceneCount; i++)
                {
                    var candidate = SceneManager.GetSceneAt(i);
                    if (candidate != _scene && candidate.isLoaded) { fallback = candidate; break; }
                }
                EditorSceneManager.CloseScene(_scene, true);
                if (fallback.IsValid()) SceneManager.SetActiveScene(fallback);
            }
            _scene = default;
            foreach (var root in HiddenRoots) if (root) root.SetActive(true);
            HiddenRoots.Clear();
            if (_previousScene.IsValid() && _previousScene.isLoaded) SceneManager.SetActiveScene(_previousScene);
            SceneView.RepaintAll();
        }

        private static void EnsureUpdateHook()
        {
            if (_hooked) return;
            EditorApplication.update += OnEditorUpdate;
            _hooked = true;
        }

        private static void OnEditorUpdate()
        {
            if (!_playing || EditorApplication.isPlayingOrWillChangePlaymode) return;
            var now = EditorApplication.timeSinceStartup;
            var delta = Mathf.Clamp((float)(now - _lastUpdateTime), 0f, 0.05f);
            _lastUpdateTime = now;
            TickRequested?.Invoke(delta);
            SceneView.RepaintAll();
        }

        public static void Tick(float delta)
        {
            if (!_playing) return;
            foreach (var animation in _animations)
                if (animation && animation.isActiveAndEnabled) animation.Tick(delta);
            foreach (var ps in Particles)
                if (ps && ps.gameObject.activeInHierarchy) ps.Simulate(delta, false, false, false);
            Canvas.ForceUpdateCanvases();
        }

        private static void DrawLabels(SceneView view)
        {
            if (!_showLabels) return;
            foreach (var root in _objects) if (root) Handles.Label(root.transform.position, root.name);
        }

        public static bool ShowLabels => _showLabels;
    }
}
