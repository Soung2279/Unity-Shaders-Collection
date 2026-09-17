using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    /// <summary>
    /// 序列帧批量预览：在独立的临时预览场景中按网格摆放预制体，
    /// 关闭其它游戏逻辑组件后，由窗口逐帧驱动 ActorSpriteAnimator 播放序列帧。
    /// </summary>
    public static class SpriteAnimPreviewSceneHelper
    {
        private const string PreviewRootName = "__SpriteAnimPreviewRoot";
        private const string PreviewSceneName = "SpriteAnimPreview";

        private static Scene _previewScene;
        private static GameObject _previewRoot;
        private static readonly List<PreviewInstance> Instances = new List<PreviewInstance>();
        private static readonly List<SceneObjectState> SceneObjectStates = new List<SceneObjectState>();
        private static bool _sceneGuiRegistered;
        private static GUIStyle _labelStyle;
        private static GUIStyle _pivotLabelStyle;
        private static readonly Color PivotColor = new Color(1f, 0.92f, 0.16f);
        private static float _cellSize = 4f;
        private static int _columns = 10;

        public sealed class SceneObjectState
        {
            public GameObject GameObject;
            public bool WasActive;
        }

        public sealed class PreviewInstance
        {
            public string PrefabName;
            public string PrefabPath;
            public string DefaultAnimation;
            public GameObject Root;
            public ActorSpriteAnimator Animator;
            public SpriteRenderer Renderer;
            public bool HasIssue;
        }

        public static bool HasPreview => Instances.Count > 0;
        public static int InstanceCount => Instances.Count;
        public static bool HasIsolatedSceneObjects => SceneObjectStates.Count > 0;
        public static bool ShowBoundaries { get; set; } = true;
        public static bool ShowLabels { get; set; } = true;
        public static bool ShowPivots { get; set; }

        public static int Generate(IList<SpriteAnimActorEntry> entries, SpriteAnimCheckConfig config, string animationName)
        {
            if (entries == null || entries.Count == 0)
            {
                return 0;
            }

            _cellSize = Mathf.Max(0.5f, config != null ? config.previewSpacing : 4f);
            _columns = Mathf.Max(1, config != null ? config.prefabsPerRow : 10);
            ShowBoundaries = config == null || config.showBoundaries;
            ShowLabels = config == null || config.showLabels;
            ShowPivots = config != null && config.showPivots;

            if (!OpenPreviewScene())
            {
                return 0;
            }

            PrepareSceneIsolation();
            ClearPreviewObjects();
            PurgePreviewRootChildren();

            var spawned = 0;
            foreach (var entry in entries)
            {
                if (entry?.Prefab == null)
                {
                    continue;
                }

                var instance = Spawn(entry, spawned);
                if (instance == null)
                {
                    continue;
                }

                Instances.Add(instance);
                spawned++;
            }

            ApplyAnimation(animationName);
            FramePreview();
            SceneView.RepaintAll();
            Debug.Log($"[SpriteAnimCheck][Preview] 批量预览生成完成：请求 {entries.Count} 个，成功 {spawned} 个，动画={GetAnimationLabel(animationName)}");
            return spawned;
        }

        /// <summary>把指定动画应用到全部预览实例；animationName 为空时使用各自默认动画。</summary>
        public static void ApplyAnimation(string animationName)
        {
            foreach (var instance in Instances)
            {
                if (instance.Animator == null)
                {
                    continue;
                }

                var target = string.IsNullOrEmpty(animationName) ? instance.DefaultAnimation : animationName;
                instance.Animator.ClearAllActionState(false);
                if (string.IsNullOrEmpty(target) || instance.Animator.Play(target, 0, 1f, true, 0f, null, true) > 0f)
                {
                    continue;
                }

                var fallback = instance.Animator.Animations?.FirstOrDefault(definition =>
                    definition != null && definition.frames != null && definition.frames.Length > 0);
                if (fallback != null)
                {
                    instance.Animator.Play(fallback.name, 0, 1f, true, 0f, null, true);
                }
            }

            SceneView.RepaintAll();
        }

        /// <summary>逐帧驱动预览动画（编辑模式由窗口调用，运行时可继续使用）。</summary>
        public static void Tick(float deltaTime)
        {
            if (deltaTime <= 0f)
            {
                return;
            }

            for (var i = 0; i < Instances.Count; i++)
            {
                var animator = Instances[i].Animator;
                if (animator == null)
                {
                    continue;
                }

                animator.UpdateAnimation(deltaTime);
            }
        }

        public static void ClosePreviewScene()
        {
            ClearPreviewObjects();
            RestoreSceneIsolation();
            RemoveSceneGuiHook();

            if (_previewRoot != null)
            {
                Object.DestroyImmediate(_previewRoot);
                _previewRoot = null;
            }

            var scene = _previewScene;
            _previewScene = default;
            if (!scene.IsValid() || !scene.isLoaded || EditorApplication.isPlayingOrWillChangePlaymode ||
                SceneManager.sceneCount <= 1)
            {
                return;
            }

            var fallback = default(Scene);
            for (var i = 0; i < SceneManager.sceneCount; i++)
            {
                var candidate = SceneManager.GetSceneAt(i);
                if (candidate != scene && candidate.isLoaded)
                {
                    fallback = candidate;
                    break;
                }
            }

            EditorSceneManager.CloseScene(scene, true);
            if (fallback.IsValid() && fallback.isLoaded)
            {
                SceneManager.SetActiveScene(fallback);
            }
        }

        public static void ClearPreviewScene()
        {
            ClosePreviewScene();
        }

        private static bool OpenPreviewScene()
        {
            if (_previewScene.IsValid() && _previewScene.isLoaded)
            {
                EnsurePreviewRoot();
                EnsureSceneGuiHook();
                return true;
            }

            // 复用上一次（例如脚本重载前）遗留的同名预览场景，避免重复创建空场景
            var existingScene = SceneManager.GetSceneByName(PreviewSceneName);
            if (existingScene.IsValid() && existingScene.isLoaded)
            {
                _previewScene = existingScene;
            }
            else
            {
                try
                {
                    _previewScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
                }
                catch (System.Exception exception)
                {
                    // 未保存的未命名场景会阻止创建附加场景，需提示用户先保存当前场景
                    _previewScene = default;
                    Debug.LogError($"[SpriteAnimCheck][Preview] 无法创建临时预览场景：{exception.Message}");
                    return false;
                }
            }

            SceneManager.SetActiveScene(_previewScene);
            EnsurePreviewRoot();
            EnsureSceneGuiHook();
            return true;
        }

        private static void EnsurePreviewRoot()
        {
            if (_previewRoot != null)
            {
                return;
            }

            _previewRoot = GameObject.Find(PreviewRootName);
            if (_previewRoot == null)
            {
                _previewRoot = new GameObject(PreviewRootName);
            }

            if (_previewRoot.scene != _previewScene)
            {
                SceneManager.MoveGameObjectToScene(_previewRoot, _previewScene);
            }
        }

        private static PreviewInstance Spawn(SpriteAnimActorEntry entry, int index)
        {
            var root = PrefabUtility.InstantiatePrefab(entry.Prefab) as GameObject;
            if (root == null)
            {
                return null;
            }

            root.hideFlags = HideFlags.DontSaveInEditor;
            root.name = entry.PrefabName;
            SceneManager.MoveGameObjectToScene(root, _previewScene);
            root.transform.SetParent(_previewRoot.transform, true);
            root.transform.SetPositionAndRotation(GetGridPosition(index), Quaternion.identity);

            DisableGameplayComponents(root);

            var animator = root.GetComponentInChildren<ActorSpriteAnimator>(true);
            if (animator == null)
            {
                Object.DestroyImmediate(root);
                Debug.LogWarning($"[SpriteAnimCheck][Preview] 预制体缺少 ActorSpriteAnimator，已跳过：{entry.PrefabPath}");
                return null;
            }

            animator.ClearAllActionState(true);
            animator.RefreshCurrentFrame();

            return new PreviewInstance
            {
                PrefabName = entry.PrefabName,
                PrefabPath = entry.PrefabPath,
                DefaultAnimation = string.IsNullOrEmpty(entry.DefaultAnimation) ? "idle" : entry.DefaultAnimation,
                Root = root,
                Animator = animator,
                Renderer = animator.Renderer,
                HasIssue = entry.HasIssue
            };
        }

        /// <summary>预览只需要 SpriteRenderer + ActorSpriteAnimator，其余组件关闭以避免编辑器内副作用。</summary>
        private static void DisableGameplayComponents(GameObject root)
        {
            foreach (var behaviour in root.GetComponentsInChildren<MonoBehaviour>(true))
            {
                if (behaviour == null || behaviour is ActorSpriteAnimator)
                {
                    continue;
                }

                behaviour.enabled = false;
            }

            foreach (var collider in root.GetComponentsInChildren<Collider2D>(true))
            {
                collider.enabled = false;
            }

            foreach (var collider in root.GetComponentsInChildren<Collider>(true))
            {
                collider.enabled = false;
            }
        }

        private static Vector3 GetGridPosition(int index)
        {
            var column = index % _columns;
            var row = index / _columns;
            return new Vector3(column * _cellSize, -row * _cellSize, 0f);
        }

        /// <summary>
        /// 进入预览前临时禁用当前场景（不含预览场景）内的所有根对象，避免当前场景内容干扰预览；
        /// 记录原始激活状态，结束预览时完整还原。
        /// </summary>
        private static void PrepareSceneIsolation()
        {
            if (SceneObjectStates.Count > 0)
            {
                return;
            }

            for (var i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                if (!scene.isLoaded || (_previewScene.IsValid() && scene == _previewScene))
                {
                    continue;
                }

                foreach (var root in scene.GetRootGameObjects())
                {
                    if (root == null || root.name == PreviewRootName || !root.activeSelf)
                    {
                        continue;
                    }

                    SceneObjectStates.Add(new SceneObjectState
                    {
                        GameObject = root,
                        WasActive = true
                    });
                    root.SetActive(false);
                }
            }

            if (SceneObjectStates.Count > 0)
            {
                Debug.Log($"[SpriteAnimCheck][Preview] 预览隔离：已临时禁用当前场景对象 {SceneObjectStates.Count} 个，结束预览后还原。");
            }
        }

        /// <summary>还原预览前被临时禁用的场景对象（幂等，可重复调用）。</summary>
        public static void RestoreSceneIsolation()
        {
            if (SceneObjectStates.Count == 0)
            {
                return;
            }

            var restored = 0;
            for (var i = SceneObjectStates.Count - 1; i >= 0; i--)
            {
                var state = SceneObjectStates[i];
                if (state.GameObject == null)
                {
                    continue;
                }

                state.GameObject.SetActive(state.WasActive);
                restored++;
            }

            SceneObjectStates.Clear();
            Debug.Log($"[SpriteAnimCheck][Preview] 预览隔离：已还原场景对象 {restored} 个。");
        }

        /// <summary>脚本重载等场景下结束预览：还原场景对象并清理预览实例，但不关闭预览场景。</summary>
        public static void EndPreviewKeepingScene()
        {
            ClearPreviewObjects();
            RestoreSceneIsolation();
        }

        private static void ClearPreviewObjects()
        {
            for (var i = 0; i < Instances.Count; i++)
            {
                var root = Instances[i].Root;
                if (root != null)
                {
                    Object.DestroyImmediate(root);
                }
            }

            Instances.Clear();
        }

        private static void PurgePreviewRootChildren()
        {
            if (_previewRoot == null)
            {
                return;
            }

            for (var i = _previewRoot.transform.childCount - 1; i >= 0; i--)
            {
                Object.DestroyImmediate(_previewRoot.transform.GetChild(i).gameObject);
            }
        }

        private static void FramePreview()
        {
            var sceneView = SceneView.lastActiveSceneView;
            if (sceneView == null)
            {
                return;
            }

            var hasBounds = false;
            var bounds = new Bounds(Vector3.zero, Vector3.one);
            foreach (var instance in Instances)
            {
                if (instance.Root == null)
                {
                    continue;
                }

                foreach (var renderer in instance.Root.GetComponentsInChildren<Renderer>(true))
                {
                    if (!hasBounds)
                    {
                        bounds = renderer.bounds;
                        hasBounds = true;
                    }
                    else
                    {
                        bounds.Encapsulate(renderer.bounds);
                    }
                }
            }

            if (!hasBounds)
            {
                return;
            }

            var size = bounds.size;
            size.z = Mathf.Max(size.z, 1f);
            bounds.size = size;
            sceneView.Frame(bounds, false);
        }

        private static string GetAnimationLabel(string animationName)
        {
            return string.IsNullOrEmpty(animationName) ? "(各Prefab默认动画)" : animationName;
        }

        private static void EnsureSceneGuiHook()
        {
            if (_sceneGuiRegistered)
            {
                return;
            }

            SceneView.duringSceneGui += OnSceneGui;
            _sceneGuiRegistered = true;
        }

        private static void RemoveSceneGuiHook()
        {
            if (!_sceneGuiRegistered)
            {
                return;
            }

            SceneView.duringSceneGui -= OnSceneGui;
            _sceneGuiRegistered = false;
        }

        private static void OnSceneGui(SceneView sceneView)
        {
            if (Event.current == null || Event.current.type != EventType.Repaint || Instances.Count == 0)
            {
                return;
            }

            foreach (var instance in Instances)
            {
                if (instance.Root == null)
                {
                    continue;
                }

                if (!TryGetInstanceBounds(instance.Root, out var bounds))
                {
                    continue;
                }

                if (ShowBoundaries)
                {
                    Handles.color = instance.HasIssue
                        ? new Color(1f, 0.3f, 0.3f, 0.65f)
                        : new Color(0.4f, 0.9f, 0.4f, 0.5f);
                    Handles.DrawWireCube(bounds.center, bounds.size);
                }

                if (ShowLabels)
                {
                    var label = (instance.HasIssue ? "⚠ " : string.Empty) + instance.PrefabName;
                    Handles.Label(new Vector3(bounds.center.x, bounds.max.y, bounds.center.z), label, GetLabelStyle());
                }

                if (ShowPivots)
                {
                    DrawPivotMarker(instance);
                }
            }
        }

        /// <summary>绘制单个预览预制体的轴心标记（与 ActorSpriteAnimatorEditor 的 Pivot 标记一致）。</summary>
        private static void DrawPivotMarker(PreviewInstance instance)
        {
            if (instance.Animator == null)
            {
                return;
            }

            var anchor = instance.Animator.GetPivotAnchorWorldPosition();
            var size = HandleUtility.GetHandleSize(anchor) * 0.12f;
            var forward = SceneView.currentDrawingSceneView != null
                ? SceneView.currentDrawingSceneView.camera.transform.forward
                : Vector3.forward;

            Handles.color = PivotColor;
            Handles.DrawWireDisc(anchor, forward, size);
            Handles.DrawLine(anchor - Vector3.right * size, anchor + Vector3.right * size);
            Handles.DrawLine(anchor - Vector3.up * size, anchor + Vector3.up * size);
            Handles.Label(anchor + Vector3.up * size, "Pivot", GetPivotLabelStyle());
        }

        private static bool TryGetInstanceBounds(GameObject root, out Bounds bounds)
        {
            bounds = default;
            var hasBounds = false;
            foreach (var renderer in root.GetComponentsInChildren<Renderer>(true))
            {
                if (!hasBounds)
                {
                    bounds = renderer.bounds;
                    hasBounds = true;
                }
                else
                {
                    bounds.Encapsulate(renderer.bounds);
                }
            }

            return hasBounds;
        }

        private static GUIStyle GetPivotLabelStyle()
        {
            if (_pivotLabelStyle == null)
            {
                _pivotLabelStyle = new GUIStyle(EditorStyles.miniLabel)
                {
                    alignment = TextAnchor.LowerCenter,
                    normal = { textColor = PivotColor }
                };
            }

            return _pivotLabelStyle;
        }

        private static GUIStyle GetLabelStyle()
        {
            if (_labelStyle == null)
            {
                _labelStyle = new GUIStyle(EditorStyles.boldLabel)
                {
                    alignment = TextAnchor.LowerCenter,
                    normal = { textColor = Color.white }
                };
            }

            return _labelStyle;
        }
    }
}
