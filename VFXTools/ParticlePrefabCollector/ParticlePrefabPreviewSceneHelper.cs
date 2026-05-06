using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game.Editor.ParticlePrefabCollector
{
    /// <summary>
    /// 用于粒子Prefab批量预览的临时场景管理工具。
    /// </summary>
    public static class ParticlePrefabPreviewSceneHelper
    {
        private static Scene _previewScene;

        private static readonly List<GameObject> SpawnedPrefabs = new();

        // Track ParticleSystems that were non-looping at spawn time
        private static readonly List<ParticleSystem> InitialNonLoopParticles = new();
        private static bool _sceneGuiRegistered;
        private static GUIStyle _labelStyle;
        private static Texture2D _labelBackgroundTexture;

        private const int PrefabsPerRow = 10;

        // Configurable spacing, default 10; synced with config asset
        private static float _previewSpacing = 10f;
        private static ParticlePrefabPreviewConfig _configObj;
        private static bool _saveScheduled;

        private const string ConfigAssetPath =
            "Assets/Editor/VFXTools/ParticlePrefabCollector/ParticlePrefabPreviewConfig.asset";

        public static bool ShowBoundaries { get; set; } = true;
        public static bool ShowLabels { get; set; } = true;
        public static bool LoopAll { get; set; }
        public static bool VerticalLayout { get; private set; } // false -> XZ plane (default), true -> XY plane

        public static void OpenPreviewScene()
        {
            if (_previewScene.IsValid() && _previewScene.isLoaded) return;
            _previewScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            SceneManager.SetActiveScene(_previewScene);
            // Load config and apply
            LoadOrCreateConfigObject();
            ApplyConfigToToggles();
            ApplyConfigToSpacing();
            ApplyConfigToLooping();
            ApplyConfigToLayout();
            EnsureSceneGuiHook();
        }

        public static void ClosePreviewScene()
        {
            if (_previewScene.IsValid() && _previewScene.isLoaded)
            {
                EditorSceneManager.CloseScene(_previewScene, true);
                _previewScene = default;
            }

            SpawnedPrefabs.Clear();
            RemoveSceneGuiHook();
        }

        private static void ClearPreviewObjects()
        {
            foreach (var go in SpawnedPrefabs)
            {
                if (go) Object.DestroyImmediate(go);
            }

            SpawnedPrefabs.Clear();
            InitialNonLoopParticles.Clear();
        }

        public static void SpawnPrefabs(List<GameObject> prefabs)
        {
            ClearPreviewObjects();
            if (!_previewScene.IsValid() || !_previewScene.isLoaded) return;
            var count = prefabs.Count;
            for (var i = 0; i < count; i++)
            {
                var prefab = prefabs[i];
                if (!prefab) continue;
                var go = (GameObject)PrefabUtility.InstantiatePrefab(prefab, _previewScene);
                var row = i / PrefabsPerRow;
                var col = i % PrefabsPerRow;
                // XY plane: X across, Y down
                go.transform.position = VerticalLayout
                    ? new Vector3(col * _previewSpacing, -row * _previewSpacing, 0)
                    :
                    // XZ plane: X across, Z back
                    new Vector3(col * _previewSpacing, 0, -row * _previewSpacing);

                SpawnedPrefabs.Add(go);

                // Collect initially non-looping particle systems for selective control
                foreach (var ps in go.GetComponentsInChildren<ParticleSystem>(true))
                {
                    try
                    {
                        var main = ps.main;
                        if (!main.loop)
                        {
                            InitialNonLoopParticles.Add(ps);
                        }
                    }
                    catch
                    {
                        /* ignore malformed components */
                    }
                }
            }

            // If config requires looping, enforce it and restart playback
            if (LoopAll)
            {
                ApplyLoopingToSpawned(true, true);
            }

            // 自动聚焦到所有对象中心
            if (SpawnedPrefabs.Count > 0)
            {
                // 计算排布宽度和深度
                var rowCount = (count + PrefabsPerRow - 1) / PrefabsPerRow;
                var colCount = count > PrefabsPerRow ? PrefabsPerRow : count;
                var centerX = (colCount - 1) * _previewSpacing / 2f;
                Vector3 center;
                if (VerticalLayout)
                {
                    var centerY = -(rowCount - 1) * _previewSpacing / 2f;
                    center = new Vector3(centerX, centerY, 0);
                }
                else
                {
                    var centerZ = -(rowCount - 1) * _previewSpacing / 2f;
                    center = new Vector3(centerX, 0, centerZ);
                }

                var view = SceneView.lastActiveSceneView;
                if (view)
                {
                    view.pivot = center;
                    var bounds = new Bounds(SpawnedPrefabs[0].transform.position, Vector3.one);
                    for (int i = 1; i < SpawnedPrefabs.Count; i++)
                    {
                        bounds.Encapsulate(SpawnedPrefabs[i].transform.position);
                    }

                    bounds.Expand(new Vector3(_previewSpacing, _previewSpacing, _previewSpacing));
                    view.Frame(bounds, false);
                    view.Repaint();
                }
            }

            EnsureSceneGuiHook();
        }

        public static void PlayAllParticles()
        {
            foreach (var go in SpawnedPrefabs)
            {
                if (!go) continue;
                foreach (var ps in go.GetComponentsInChildren<ParticleSystem>(true))
                {
                    ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                    ps.Play(true);
                }
            }
        }

        public static List<GameObject> GetSpawnedPrefabs()
        {
            return SpawnedPrefabs;
        }

        public static int GetPreviewSpacingInt()
        {
            return Mathf.RoundToInt(_previewSpacing);
        }

        public static void OpenControlWindow()
        {
            var type = System.Type.GetType("Game.Editor.ParticlePrefabCollector.ParticlePrefabPreviewControlWindow");
            if (type != null)
            {
                var window = EditorWindow.GetWindow(type);
                window.titleContent = new GUIContent("Particle Preview");
                window.Show();
                window.Focus();
            }
            else
            {
                Debug.LogWarning("ParticlePrefabPreviewControlWindow 类型未找到，已跳过打开控制窗口。");
            }
        }

        private static void LoadOrCreateConfigObject()
        {
            _configObj = AssetDatabase.LoadAssetAtPath<ParticlePrefabPreviewConfig>(ConfigAssetPath);
            if (_configObj == null)
            {
                _configObj =
                    ScriptableObject.CreateInstance<ParticlePrefabPreviewConfig>();
                if (_configObj != null)
                {
                    AssetDatabase.CreateAsset(_configObj, ConfigAssetPath);
                    AssetDatabase.SaveAssets();
                }
            }
        }

        private static void ApplyConfigToToggles()
        {
            if (_configObj == null)
                return;

            ShowBoundaries = _configObj.showBoundaries;
            ShowLabels = _configObj.showLabels;
        }

        private static void ApplyConfigToSpacing()
        {
            if (_configObj == null)
                return;

            _previewSpacing = Mathf.Clamp(_configObj.previewSpacing, 1, 100);
        }

        private static void ApplyConfigToLooping()
        {
            if (_configObj == null)
                return;

            LoopAll = _configObj.loopAllParticles;
        }

        private static void ApplyConfigToLayout()
        {
            if (_configObj == null)
                return;

            VerticalLayout = _configObj.verticalLayout;
        }

        public static void PersistTogglesToConfig()
        {
            if (_configObj == null)
            {
                LoadOrCreateConfigObject();
            }

            if (_configObj == null)
                return;

            _configObj.showBoundaries = ShowBoundaries;
            _configObj.showLabels = ShowLabels;
            MarkConfigDirty(false);
        }

        public static void PersistLoopAllToConfig()
        {
            if (_configObj == null)
            {
                LoadOrCreateConfigObject();
            }

            if (_configObj == null)
                return;

            _configObj.loopAllParticles = LoopAll;
            MarkConfigDirty(false);
        }

        public static void ApplyLoopingToSpawned(bool enable, bool restartOnEnable)
        {
            if (InitialNonLoopParticles.Count == 0) return;
            // Clean up null/destroyed references
            for (int i = InitialNonLoopParticles.Count - 1; i >= 0; i--)
            {
                if (InitialNonLoopParticles[i] == null)
                    InitialNonLoopParticles.RemoveAt(i);
            }

            foreach (var ps in InitialNonLoopParticles)
            {
                if (!ps) continue;
                var main = ps.main;
                main.loop = enable;
                if (enable && restartOnEnable)
                {
                    ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                    ps.Play(true);
                }
            }
        }

        public static void PersistSpacingToConfigAndRelayout(int newSpacing)
        {
            if (_configObj == null)
            {
                LoadOrCreateConfigObject();
            }

            if (_configObj == null)
                return;

            var clamped = Mathf.Clamp(newSpacing, 1, 100);
            _configObj.previewSpacing = clamped;
            MarkConfigDirty(true);

            // Update runtime field and relayout
            _previewSpacing = clamped;
            RelayoutSpawnedPrefabs();
            SceneView.RepaintAll();
        }

        public static void PersistVerticalLayoutToConfigAndRelayout(bool vertical)
        {
            if (_configObj == null)
            {
                LoadOrCreateConfigObject();
            }

            if (_configObj == null)
                return;

            _configObj.verticalLayout = vertical;
            MarkConfigDirty(true);

            VerticalLayout = vertical;
            RelayoutSpawnedPrefabs();
            SceneView.RepaintAll();
        }

        private static void MarkConfigDirty(bool flushImmediately)
        {
            if (_configObj == null)
                return;

            EditorUtility.SetDirty(_configObj);

            if (flushImmediately)
            {
                AssetDatabase.SaveAssetIfDirty(_configObj);
                return;
            }

            if (_saveScheduled)
                return;

            _saveScheduled = true;
            EditorApplication.delayCall += FlushDeferredSave;
        }

        private static void FlushDeferredSave()
        {
            EditorApplication.delayCall -= FlushDeferredSave;
            _saveScheduled = false;
            if (_configObj)
            {
                AssetDatabase.SaveAssetIfDirty(_configObj);
            }
        }

        private static void RelayoutSpawnedPrefabs()
        {
            if (SpawnedPrefabs.Count == 0) return;
            for (int i = 0; i < SpawnedPrefabs.Count; i++)
            {
                var go = SpawnedPrefabs[i];
                if (!go) continue;
                var row = i / PrefabsPerRow;
                var col = i % PrefabsPerRow;
                go.transform.position = VerticalLayout
                    ? new Vector3(col * _previewSpacing, -row * _previewSpacing, 0)
                    : new Vector3(col * _previewSpacing, 0, -row * _previewSpacing);
            }

            // Reframe view to fit new layout
            var view = SceneView.lastActiveSceneView;
            if (view && SpawnedPrefabs.Count > 0)
            {
                var count = SpawnedPrefabs.Count;
                var rowCount = (count + PrefabsPerRow - 1) / PrefabsPerRow;
                var colCount = count > PrefabsPerRow ? PrefabsPerRow : count;
                var centerX = (colCount - 1) * _previewSpacing / 2f;
                Vector3 center;
                if (VerticalLayout)
                {
                    var centerY = -(rowCount - 1) * _previewSpacing / 2f;
                    center = new Vector3(centerX, centerY, 0);
                }
                else
                {
                    var centerZ = -(rowCount - 1) * _previewSpacing / 2f;
                    center = new Vector3(centerX, 0, centerZ);
                }

                view.pivot = center;

                var bounds = new Bounds(SpawnedPrefabs[0].transform.position, Vector3.one);
                for (int i = 1; i < SpawnedPrefabs.Count; i++)
                {
                    if (SpawnedPrefabs[i])
                        bounds.Encapsulate(SpawnedPrefabs[i].transform.position);
                }

                bounds.Expand(new Vector3(_previewSpacing, _previewSpacing, _previewSpacing));
                view.Frame(bounds, false);
                view.Repaint();
            }
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
            if (Event.current.type != EventType.Repaint)
            {
                return;
            }

            if (!_previewScene.IsValid() || !_previewScene.isLoaded)
            {
                return;
            }

            if (SpawnedPrefabs.Count == 0)
            {
                return;
            }

            if (!ShowBoundaries && !ShowLabels)
            {
                return;
            }

            var previousColor = Handles.color;
            var previousZTest = Handles.zTest;
            Handles.zTest = UnityEngine.Rendering.CompareFunction.Always;

            foreach (var go in SpawnedPrefabs)
            {
                if (!go) continue;

                if (ShowBoundaries)
                {
                    DrawBoundary(go);
                }

                if (ShowLabels)
                {
                    DrawLabel(go);
                }
            }

            Handles.color = previousColor;
            Handles.zTest = previousZTest;
        }

        private static void DrawBoundary(GameObject go)
        {
            var center = go.transform.position;
            var halfSize = _previewSpacing * 0.5f;
            Vector3[] corners;
            if (VerticalLayout)
            {
                // XY plane rectangle
                corners = new[]
                {
                    new Vector3(center.x - halfSize, center.y - halfSize, 0f),
                    new Vector3(center.x + halfSize, center.y - halfSize, 0f),
                    new Vector3(center.x + halfSize, center.y + halfSize, 0f),
                    new Vector3(center.x - halfSize, center.y + halfSize, 0f)
                };
            }
            else
            {
                // XZ plane rectangle
                corners = new[]
                {
                    new Vector3(center.x - halfSize, 0f, center.z - halfSize),
                    new Vector3(center.x + halfSize, 0f, center.z - halfSize),
                    new Vector3(center.x + halfSize, 0f, center.z + halfSize),
                    new Vector3(center.x - halfSize, 0f, center.z + halfSize)
                };
            }

            var fillColor = new Color(0f, 0.75f, 1f, 0.05f);
            var outlineColor = new Color(0f, 0.75f, 1f, 0.6f);
            Handles.DrawSolidRectangleWithOutline(corners, fillColor, outlineColor);
        }

        private static void DrawLabel(GameObject go)
        {
            var basePosition = go.transform.position;
            Vector3 groundPosition;
            Vector3 labelOffset;
            if (VerticalLayout)
            {
                groundPosition = new Vector3(basePosition.x, basePosition.y, 0f);
                labelOffset = Vector3.forward * 0.25f * _previewSpacing + Vector3.up * 0.25f;
            }
            else
            {
                groundPosition = new Vector3(basePosition.x, basePosition.y, basePosition.z);
                labelOffset = Vector3.back * 0.25f * _previewSpacing + Vector3.up * 0.25f;
            }

            var labelPosition = groundPosition + labelOffset;

            Handles.color = new Color(1f, 1f, 1f, 0.35f);
            Handles.DrawLine(groundPosition, labelPosition);
            Handles.Label(labelPosition, go.name, GetLabelStyle());
        }

        private static GUIStyle GetLabelStyle()
        {
            if (_labelStyle != null)
            {
                return _labelStyle;
            }

            var style = new GUIStyle(EditorStyles.boldLabel)
            {
                alignment = TextAnchor.MiddleCenter,
                fontSize = 8,
                fontStyle = FontStyle.Bold,
                padding = new RectOffset(6, 6, 2, 2),
                normal =
                {
                    textColor = EditorGUIUtility.isProSkin ? new Color(0.6f, 0.9f, 1f) : new Color(0.1f, 0.2f, 0.6f),
                    background = GetLabelBackgroundTexture()
                }
            };

            _labelStyle = style;
            return _labelStyle;
        }

        private static Texture2D GetLabelBackgroundTexture()
        {
            if (_labelBackgroundTexture)
            {
                return _labelBackgroundTexture;
            }

            var tex = new Texture2D(1, 1)
            {
                hideFlags = HideFlags.HideAndDontSave,
                name = "ParticlePreviewLabelBg"
            };
            var color = EditorGUIUtility.isProSkin ? new Color(0f, 0f, 0f, 0.6f) : new Color(1f, 1f, 1f, 0.7f);
            tex.SetPixel(0, 0, color);
            tex.Apply();
            _labelBackgroundTexture = tex;
            return _labelBackgroundTexture;
        }
    }
}