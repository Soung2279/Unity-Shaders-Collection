using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.Utilities
{
    [CustomEditor(typeof(ParticleGroupPlayer)), CanEditMultipleObjects]
    public sealed class ParticleGroupPlayerEditor : UnityEditor.Editor
    {
        private sealed class PreviewState
        {
            public ParticleGroupPlayer Player;
            public ParticleSystem[] ParticleSystems;
            public SerializedObject[] SerializedParticles;
            public uint[] OriginalSeeds;
            public uint[] PreviewSeeds;
            public bool[] AutoRandomSeeds;
            public double PreviousTime;
            public float PlaybackTime;
            public bool Playing;
        }

        private static readonly List<PreviewState> PreviewStates = new List<PreviewState>();
        private const float OverlayWidth = 220f;
        private const float OverlayHeight = 126f;
        private const float DefaultPlaybackPrecision = 0.005f;
        private const float HighPlaybackPrecision = 0.0001f;
        private const float PlaybackFieldWidth = 50f;
        private const string HighPrecisionPrefKey = "VFXTools.ParticleGroupPlayer.HighPrecision";
        private const string ResimulatePrefKey = "VFXTools.ParticleGroupPlayer.Resimulate";
        private static readonly GUIContent StepBackContent = new GUIContent("◀", "按当前精度回退");
        private static readonly GUIContent StepForwardContent = new GUIContent("▶", "按当前精度前进");
        private static bool updateRegistered;
        private static bool sceneGuiRegistered;
        private static bool cleanupRegistered;
        private static Rect overlayRect;
        private static ParticleGroupPlayer drawingPlayer;
        private static bool draggingOverlay;
        private static Vector2 overlayDragOffset;
        private static bool draggingPlaybackTime;
        private static float playbackDragStartMouseX;
        private static float playbackDragStartValue;
        private static bool highPrecision;
        private static bool resimulate = true;

        private static float PlaybackPrecision => highPrecision ? HighPlaybackPrecision : DefaultPlaybackPrecision;
        private static float PlaybackButtonStep => PlaybackPrecision * 10f;

        private void OnEnable()
        {
            if (!sceneGuiRegistered)
            {
                SceneView.duringSceneGui += DrawSceneOverlay;
                EditorApplication.hierarchyChanged += OnHierarchyChanged;
                Selection.selectionChanged += OnSelectionChanged;
                sceneGuiRegistered = true;
                highPrecision = EditorPrefs.GetBool(HighPrecisionPrefKey, false);
                resimulate = EditorPrefs.GetBool(ResimulatePrefKey, true);
            }

            RegisterCleanupCallbacks();
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.HelpBox(
                "粒子组预览工具：通过 Scene 视图悬浮窗统一控制所有子粒子动画预览。预览状态仅存在于编辑器内存中。",
                MessageType.Info);

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("播放"))
                {
                    ForEachTarget(StartPreview, false);
                }

                if (GUILayout.Button("重新播放"))
                {
                    ForEachTarget(StartPreview, true);
                }
            }

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("暂停"))
                {
                    ForEachTarget(PausePreview);
                }

                if (GUILayout.Button("停止并清除"))
                {
                    ForEachTarget(StopPreview);
                }
            }
        }

        private static void DrawSceneOverlay(SceneView sceneView)
        {
            GameObject selectedObject = Selection.activeGameObject;
            if (!selectedObject)
            {
                return;
            }

            ParticleGroupPlayer player = selectedObject.GetComponent<ParticleGroupPlayer>();
            if (!player)
            {
                return;
            }

            Handles.BeginGUI();
            if (overlayRect.width <= 0f)
            {
                overlayRect = new Rect(
                    Mathf.Max(8f, sceneView.position.width - OverlayWidth - 18f),
                    8f,
                    OverlayWidth,
                    OverlayHeight);
            }

            overlayRect.x = Mathf.Clamp(overlayRect.x, 0f, Mathf.Max(0f, sceneView.position.width - overlayRect.width));
            overlayRect.y = Mathf.Clamp(overlayRect.y, 0f, Mathf.Max(0f, sceneView.position.height - overlayRect.height));
            drawingPlayer = player;
            GUI.Box(overlayRect, GUIContent.none, "Window");
            DrawOverlayControls(overlayRect);
            HandleOverlayDrag(overlayRect);
            drawingPlayer = null;
            Handles.EndGUI();
        }

        private static void DrawOverlayControls(Rect windowRect)
        {
            ParticleGroupPlayer player = drawingPlayer;
            PreviewState state = GetOrCreateState(player);
            float x = windowRect.x;
            float y = windowRect.y;

            GUI.Label(new Rect(x + 6f, y + 2f, OverlayWidth - 12f, 18f), "粒子", EditorStyles.boldLabel);

            Rect buttonRow = new Rect(x + 4f, y + 22f, OverlayWidth - 8f, 20f);
            float buttonWidth = buttonRow.width / 3f;
            string playButtonLabel = state.Playing ? "暂停" : "播放";
            if (GUI.Button(new Rect(buttonRow.x, buttonRow.y, buttonWidth, buttonRow.height), playButtonLabel))
            {
                TogglePreview(player);
            }

            if (GUI.Button(new Rect(buttonRow.x + buttonWidth, buttonRow.y, buttonWidth, buttonRow.height), "重启"))
            {
                StartPreview(player, true);
            }

            if (GUI.Button(new Rect(buttonRow.x + buttonWidth * 2f, buttonRow.y, buttonWidth, buttonRow.height), "停止"))
            {
                StopPreview(player);
            }

            Rect timeRow = new Rect(x + 4f, y + 48f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            Color previousContentColor = GUI.contentColor;
            if (draggingPlaybackTime)
            {
                GUI.contentColor = new Color(0.24f, 0.49f, 0.90f);
            }
            GUI.Label(new Rect(timeRow.x, timeRow.y, 58f, timeRow.height), "回放时间");
            GUI.contentColor = previousContentColor;

            Rect precisionRect = new Rect(x + 4f, y + 70f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            bool newHighPrecision = EditorGUI.ToggleLeft(precisionRect, "高精度", highPrecision);
            if (newHighPrecision != highPrecision)
            {
                highPrecision = newHighPrecision;
                EditorPrefs.SetBool(HighPrecisionPrefKey, highPrecision);
            }

            Rect resimulateRect = new Rect(x + 4f, y + 90f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            bool newResimulate = EditorGUI.ToggleLeft(resimulateRect, "重新模拟", resimulate);
            if (newResimulate != resimulate)
            {
                resimulate = newResimulate;
                EditorPrefs.SetBool(ResimulatePrefKey, resimulate);
            }

            Rect backButtonRect = new Rect(timeRow.x + 60f, timeRow.y, 24f, timeRow.height);
            if (GUI.Button(backButtonRect, StepBackContent))
            {
                ScrubPreview(state, Mathf.Max(0f, state.PlaybackTime - PlaybackButtonStep));
            }

            Rect forwardButtonRect = new Rect(backButtonRect.xMax + 2f, timeRow.y, 24f, timeRow.height);
            if (GUI.Button(forwardButtonRect, StepForwardContent))
            {
                ScrubPreview(state, state.PlaybackTime + PlaybackButtonStep);
            }

            Rect valueRect = new Rect(timeRow.xMax - PlaybackFieldWidth, timeRow.y, PlaybackFieldWidth, timeRow.height);
            float playbackScale = highPrecision ? 10000f : 1000f;
            EditorGUI.BeginChangeCheck();
            string playbackTimeText = EditorGUI.TextField(valueRect, state.PlaybackTime.ToString(highPrecision ? "F4" : "F3"));
            if (EditorGUI.EndChangeCheck() && float.TryParse(playbackTimeText, out float playbackTime))
            {
                ScrubPreview(state, Mathf.Max(0f, Mathf.Round(playbackTime * playbackScale) / playbackScale));
            }

            Rect playbackDragRect = new Rect(timeRow.x, timeRow.y, 58f, timeRow.height);
            EditorGUIUtility.AddCursorRect(playbackDragRect, MouseCursor.ResizeHorizontal);
            HandlePlaybackTimeDrag(state, playbackDragRect);
        }

        private static void HandlePlaybackTimeDrag(PreviewState state, Rect dragRect)
        {
            Event current = Event.current;
            if (current.type == EventType.MouseDown && current.button == 0 && dragRect.Contains(current.mousePosition))
            {
                draggingPlaybackTime = true;
                playbackDragStartMouseX = current.mousePosition.x;
                playbackDragStartValue = state.PlaybackTime;
                GUIUtility.hotControl = GUIUtility.GetControlID(FocusType.Passive);
                current.Use();
                return;
            }

            if (current.type == EventType.MouseDrag && current.button == 0 && draggingPlaybackTime)
            {
                //拖动时调整的时间精度
                float playbackTime = playbackDragStartValue + (current.mousePosition.x - playbackDragStartMouseX) * PlaybackPrecision;
                ScrubPreview(state, Mathf.Max(0f, playbackTime));
                current.Use();
                return;
            }

            if ((current.type == EventType.MouseUp || current.rawType == EventType.MouseUp) && draggingPlaybackTime)
            {
                draggingPlaybackTime = false;
                GUIUtility.hotControl = 0;
                current.Use();
            }
        }

        private static void HandleOverlayDrag(Rect windowRect)
        {
            Event current = Event.current;
            Rect buttonRow = new Rect(windowRect.x + 4f, windowRect.y + 22f, OverlayWidth - 8f, 20f);
            Rect timeRow = new Rect(windowRect.x + 4f, windowRect.y + 48f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            Rect precisionRow = new Rect(windowRect.x + 4f, windowRect.y + 70f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            Rect resimulateRow = new Rect(windowRect.x + 4f, windowRect.y + 90f, OverlayWidth - 8f, EditorGUIUtility.singleLineHeight);
            bool isDraggableArea = windowRect.Contains(current.mousePosition) &&
                                   !buttonRow.Contains(current.mousePosition) &&
                                   !timeRow.Contains(current.mousePosition) &&
                                   !precisionRow.Contains(current.mousePosition) &&
                                   !resimulateRow.Contains(current.mousePosition);

            if (isDraggableArea)
            {
                EditorGUIUtility.AddCursorRect(windowRect, MouseCursor.Pan);
            }

            if (current.type == EventType.MouseDown && current.button == 0 && isDraggableArea)
            {
                draggingOverlay = true;
                overlayDragOffset = current.mousePosition - overlayRect.position;
                GUIUtility.hotControl = GUIUtility.GetControlID(FocusType.Passive);
                current.Use();
                return;
            }

            if (current.type == EventType.MouseDrag && current.button == 0 && draggingOverlay)
            {
                overlayRect.position = current.mousePosition - overlayDragOffset;
                current.Use();
                return;
            }

            if ((current.type == EventType.MouseUp || current.rawType == EventType.MouseUp) && draggingOverlay)
            {
                draggingOverlay = false;
                GUIUtility.hotControl = 0;
                current.Use();
            }
        }

        private void ForEachTarget(System.Action<ParticleGroupPlayer> action)
        {
            foreach (Object targetObject in targets)
            {
                if (targetObject is ParticleGroupPlayer player)
                {
                    action(player);
                }
            }
        }

        private void ForEachTarget(System.Action<ParticleGroupPlayer, bool> action, bool value)
        {
            foreach (Object targetObject in targets)
            {
                if (targetObject is ParticleGroupPlayer player)
                {
                    action(player, value);
                }
            }
        }

        private static void TogglePreview(ParticleGroupPlayer player)
        {
            PreviewState state = GetOrCreateState(player);
            if (state.Playing)
            {
                PausePreview(player);
            }
            else
            {
                StartPreview(player, false);
            }
        }

        private static void StartPreview(ParticleGroupPlayer player, bool restart)
        {
            if (EditorUtility.IsPersistent(player))
            {
                Debug.LogWarning("请在场景或 Prefab Mode 中打开该 Prefab 后再预览粒子。", player);
                return;
            }

            PreviewState state = GetOrCreateState(player);
            if (Application.isPlaying)
            {
                if (restart)
                {
                    player.Restart();
                    state.PlaybackTime = 0f;
                }
                else
                {
                    player.Play();
                }

                state.Playing = true;
                SceneView.RepaintAll();
                return;
            }

            if (restart)
            {
                if (resimulate)
                {
                    AssignNewPreviewSeeds(state);
                }
                state.PlaybackTime = 0f;
                SimulateAtTime(state, 0f);
            }

            state.Playing = true;
            state.PreviousTime = EditorApplication.timeSinceStartup;
            if (!restart && state.PlaybackTime <= 0f)
            {
                if (resimulate)
                {
                    AssignNewPreviewSeeds(state);
                }
            }
            RegisterUpdate();
            SceneView.RepaintAll();
        }

        private static void PausePreview(ParticleGroupPlayer player)
        {
            PreviewState state = FindState(player);
            if (state != null)
            {
                state.Playing = false;
            }

            if (Application.isPlaying)
            {
                player.Pause();
            }
            if (!HasPlayingPreview())
            {
                UnregisterUpdate();
            }
            SceneView.RepaintAll();
        }

        private static void StopPreview(ParticleGroupPlayer player)
        {
            PreviewState state = FindState(player);
            if (Application.isPlaying)
            {
                player.StopAndClear();
                if (state != null)
                {
                    state.Playing = false;
                    state.PlaybackTime = 0f;
                }
                SceneView.RepaintAll();
                return;
            }

            if (state != null)
            {
                state.Playing = false;
                state.PlaybackTime = 0f;
                RestoreOriginalSeeds(state);
            }
            else
            {
                player.StopAndClear();
            }

            if (!HasPlayingPreview())
            {
                UnregisterUpdate();
            }
            SceneView.RepaintAll();
        }

        private static PreviewState GetOrCreateState(ParticleGroupPlayer player)
        {
            PreviewState state = FindState(player);
            if (state != null)
            {
                return state;
            }

            ParticleSystem[] particleSystems = player.GetComponentsInChildren<ParticleSystem>(true);
            SerializedObject[] serializedParticles = new SerializedObject[particleSystems.Length];
            uint[] originalSeeds = new uint[particleSystems.Length];
            uint[] previewSeeds = new uint[particleSystems.Length];
            bool[] autoRandomSeeds = new bool[particleSystems.Length];
            for (int i = 0; i < particleSystems.Length; i++)
            {
                SerializedObject serializedParticle = new SerializedObject(particleSystems[i]);
                serializedParticles[i] = serializedParticle;
                originalSeeds[i] = (uint)serializedParticle.FindProperty("randomSeed").longValue;
                previewSeeds[i] = particleSystems[i].randomSeed;
                autoRandomSeeds[i] = serializedParticle.FindProperty("autoRandomSeed").boolValue;
            }

            state = new PreviewState
            {
                Player = player,
                ParticleSystems = particleSystems,
                SerializedParticles = serializedParticles,
                OriginalSeeds = originalSeeds,
                PreviewSeeds = previewSeeds,
                AutoRandomSeeds = autoRandomSeeds,
                PreviousTime = EditorApplication.timeSinceStartup
            };
            PreviewStates.Add(state);
            return state;
        }

        private static PreviewState FindState(ParticleGroupPlayer player)
        {
            for (int i = 0; i < PreviewStates.Count; i++)
            {
                if (PreviewStates[i].Player == player)
                {
                    return PreviewStates[i];
                }
            }

            return null;
        }

        private static void ScrubPreview(PreviewState state, float playbackTime)
        {
            state.Playing = false;
            state.PlaybackTime = playbackTime;
            SimulateAtTime(state, playbackTime);
            if (!HasPlayingPreview())
            {
                UnregisterUpdate();
            }
            SceneView.RepaintAll();
        }

        private static void AssignNewPreviewSeeds(PreviewState state)
        {
            for (int i = 0; i < state.PreviewSeeds.Length; i++)
            {
                uint seed;
                do
                {
                    seed = (uint)Random.Range(1, int.MaxValue);
                }
                while (seed == state.PreviewSeeds[i]);

                state.PreviewSeeds[i] = seed;
            }
        }

        private static void StopAndClearParticleSystems(PreviewState state)
        {
            for (int i = 0; i < state.ParticleSystems.Length; i++)
            {
                ParticleSystem particleSystem = state.ParticleSystems[i];
                if (particleSystem)
                {
                    particleSystem.Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
                }
            }
        }

        private static void RestoreSerializedSeedSettings(PreviewState state)
        {
            for (int i = 0; i < state.SerializedParticles.Length; i++)
            {
                SerializedObject serializedParticle = state.SerializedParticles[i];
                if (serializedParticle == null || !serializedParticle.targetObject)
                {
                    continue;
                }

                serializedParticle.Update();
                serializedParticle.FindProperty("randomSeed").longValue = state.OriginalSeeds[i];
                serializedParticle.FindProperty("autoRandomSeed").boolValue = state.AutoRandomSeeds[i];
                serializedParticle.ApplyModifiedPropertiesWithoutUndo();
            }
        }

        private static void SimulateAtTime(PreviewState state, float playbackTime)
        {
            StopAndClearParticleSystems(state);

            for (int i = 0; i < state.ParticleSystems.Length; i++)
            {
                ParticleSystem particleSystem = state.ParticleSystems[i];
                if (particleSystem)
                {
                    particleSystem.randomSeed = state.PreviewSeeds[i];
                }
            }

            for (int i = 0; i < state.ParticleSystems.Length; i++)
            {
                ParticleSystem particleSystem = state.ParticleSystems[i];
                if (particleSystem && particleSystem.gameObject.activeInHierarchy)
                {
                    particleSystem.Simulate(playbackTime, false, true, false);
                }
            }

            RestoreSerializedSeedSettings(state);
        }

        private static bool HasPlayingPreview()
        {
            for (int i = 0; i < PreviewStates.Count; i++)
            {
                if (PreviewStates[i].Playing)
                {
                    return true;
                }
            }

            return false;
        }

        private static void RegisterUpdate()
        {
            if (updateRegistered)
            {
                return;
            }

            updateRegistered = true;
            EditorApplication.update += UpdatePreviews;
        }

        private static void UnregisterUpdate()
        {
            if (!updateRegistered)
            {
                return;
            }

            updateRegistered = false;
            EditorApplication.update -= UpdatePreviews;
        }

        private static void UpdatePreviews()
        {
            if (Application.isPlaying)
            {
                ClearPreviewStates();
                return;
            }

            double now = EditorApplication.timeSinceStartup;
            bool repaint = false;

            for (int stateIndex = PreviewStates.Count - 1; stateIndex >= 0; stateIndex--)
            {
                PreviewState state = PreviewStates[stateIndex];
                if (!state.Player)
                {
                    PreviewStates.RemoveAt(stateIndex);
                    continue;
                }

                float deltaTime = Mathf.Min((float)(now - state.PreviousTime), 0.05f);
                state.PreviousTime = now;
                if (!state.Playing)
                {
                    continue;
                }

                state.PlaybackTime += deltaTime;
                SimulateAtTime(state, state.PlaybackTime);
                repaint = true;
            }

            if (repaint)
            {
                SceneView.RepaintAll();
            }

            if (!HasPlayingPreview())
            {
                UnregisterUpdate();
            }
        }

        private static void RegisterCleanupCallbacks()
        {
            if (cleanupRegistered)
            {
                return;
            }

            cleanupRegistered = true;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            AssemblyReloadEvents.beforeAssemblyReload += StopAndClearPreviewStates;
        }

        private static void StopAndClearPreviewStates()
        {
            for (int i = 0; i < PreviewStates.Count; i++)
            {
                StopState(PreviewStates[i]);
            }
            ClearPreviewStates();
        }

        private static void RestoreOriginalSeeds(PreviewState state)
        {
            StopAndClearParticleSystems(state);
            RestoreSerializedSeedSettings(state);
        }

        private static void StopState(PreviewState state)
        {
            state.Playing = false;
            state.PlaybackTime = 0f;
            if (!Application.isPlaying && state.Player)
            {
                RestoreOriginalSeeds(state);
            }
        }

        private static void OnSelectionChanged()
        {
            ParticleGroupPlayer selectedPlayer = Selection.activeGameObject
                ? Selection.activeGameObject.GetComponent<ParticleGroupPlayer>()
                : null;

            for (int i = PreviewStates.Count - 1; i >= 0; i--)
            {
                if (PreviewStates[i].Player != selectedPlayer)
                {
                    StopState(PreviewStates[i]);
                    PreviewStates.RemoveAt(i);
                }
            }

            if (!HasPlayingPreview())
            {
                UnregisterUpdate();
            }
            SceneView.RepaintAll();
        }

        private static void OnHierarchyChanged()
        {
            StopAndClearPreviewStates();
            SceneView.RepaintAll();
        }

        private static void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.ExitingEditMode)
            {
                StopAndClearPreviewStates();
                return;
            }

            ClearPreviewStates();
        }

        private static void ClearPreviewStates()
        {
            PreviewStates.Clear();
            UnregisterUpdate();
        }
    }
}
