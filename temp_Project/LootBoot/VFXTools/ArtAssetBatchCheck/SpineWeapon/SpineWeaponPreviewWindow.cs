using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public class SpineWeaponPreviewWindow : EditorWindow
    {
        private const string PendingWeaponPrefsKey = "SpineWeaponPreview.PendingWeaponId";
        private const string PendingAnimationPrefsKey = "SpineWeaponPreview.PendingAnimation";
        private const string PendingQualityPrefsKey = "SpineWeaponPreview.PendingQuality";
        private const string PendingRebindPrefsKey = "SpineWeaponPreview.PendingRebind";
        private const string PendingCleanupPrefsKey = "SpineWeaponPreview.PendingCleanup";
        private const string PendingAssetCheckPrefsKey = "SpineWeaponPreview.PendingAssetCheck";

        private SpineWeaponPreviewConfig _config;
        private SpineWeaponPreviewData.Database _database;
        private string[] _weaponNames = Array.Empty<string>();
        private int[] _weaponIds = Array.Empty<int>();
        private string[] _animationOptions = Array.Empty<string>();
        private int _selectedWeaponIndex;
        private int _selectedAnimationIndex;
        private Vector2 _scroll;

        public static void Open()
        {
            ArtAssetBatchCheckWindow.Open(1);
        }

        private void OnEnable()
        {
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            LoadData(false);
            TryRunPendingAssetCheck();
            TryRestorePendingPreview();
        }

        private void OnDisable()
        {
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
        }

        private void OnGUI()
        {
            DrawToolGUI();
        }

        public void DrawToolGUI()
        {
            if (_config == null || _database == null)
            {
                LoadData(false);
            }

            using (var scroll = new EditorGUILayout.ScrollViewScope(_scroll))
            {
                _scroll = scroll.scrollPosition;
                DrawConfig();
                EditorGUILayout.Space(8f);
                DrawActions();
                EditorGUILayout.Space(8f);
                DrawInfo();
            }
        }

        private void DrawConfig()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("预览设置", EditorStyles.boldLabel);

                EditorGUI.BeginChangeCheck();
                _config.previewSpacing = EditorGUILayout.IntSlider("排列间隔", _config.previewSpacing, 1, 100);
                _config.prefabsPerRow = EditorGUILayout.IntSlider("每行数量", _config.prefabsPerRow, 1, 30);
                _config.showBoundaries = EditorGUILayout.Toggle("显示边框", _config.showBoundaries);
                _config.showLabels = EditorGUILayout.Toggle("显示标签", _config.showLabels);
                _config.defaultWeaponQuality = EditorGUILayout.IntSlider("武器星级预览", _config.defaultWeaponQuality, 1, 16);
                if (EditorGUI.EndChangeCheck())
                {
                    _config.Save();
                }

                EditorGUILayout.Space(4f);
                if (_weaponNames.Length == 0)
                {
                    EditorGUILayout.HelpBox("没有读取到武器配置。", MessageType.Warning);
                }
                else
                {
                    var nextWeaponIndex = EditorGUILayout.Popup("手持武器", _selectedWeaponIndex, _weaponNames);
                    if (nextWeaponIndex != _selectedWeaponIndex)
                    {
                        _selectedWeaponIndex = nextWeaponIndex;
                        _config.defaultWeaponId = _weaponIds[_selectedWeaponIndex];
                        _config.Save();
                        AutoRefreshWeaponAndAnimation("下拉切换武器");
                    }
                }

                if (_animationOptions.Length == 0)
                {
                    _animationOptions = new[] { "idle", "run", "dead", "attack1", "attack2", "attack3", "skill1", "skill2", "skill3", "ui_wearequip" };
                }

                var nextAnimIndex = EditorGUILayout.Popup("预览动画", _selectedAnimationIndex, _animationOptions);
                if (nextAnimIndex != _selectedAnimationIndex)
                {
                    _selectedAnimationIndex = nextAnimIndex;
                    _config.defaultAnimation = _animationOptions[_selectedAnimationIndex];
                    _config.Save();
                    AutoRefreshAnimation("下拉切换动画");
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
                    if (GUILayout.Button("重新读取配置", GUILayout.Height(32), GUILayout.MinWidth(120)))
                    {
                        LoadData(true);
                    }

                    GUILayout.Space(6f);
                    if (GUILayout.Button("生成/刷新角色", GUILayout.Height(32), GUILayout.MinWidth(130)))
                    {
                        GeneratePreview();
                    }

                    GUILayout.Space(6f);
                    if (GUILayout.Button("一键检查资源缺失", GUILayout.Height(32), GUILayout.MinWidth(150)))
                    {
                        RequestAssetCheck();
                    }
                }

                EditorGUILayout.Space(6f);
                using (new EditorGUILayout.HorizontalScope())
                {
                    if (!EditorApplication.isPlaying)
                    {
                        if (GUILayout.Button("进入 PlayMode 预览", GUILayout.Height(34), GUILayout.MinWidth(170)))
                        {
                            GenerateAndEnterPlayMode();
                        }
                    }
                    else
                    {
                        EditorGUILayout.HelpBox("当前处于PlayMode，Spine动画会正常播放。", MessageType.Info);
                    }

                    GUILayout.Space(6f);
                    if (GUILayout.Button("结束预览", GUILayout.Height(34), GUILayout.Width(120)))
                    {
                        EndPreview();
                    }
                }

                if (!EditorApplication.isPlaying)
                {
                    EditorGUILayout.HelpBox("提示：切换上方武器或动画下拉菜单会自动刷新当前预览。静态排布可直接生成；如需正确播放Spine动画，请进入 PlayMode。", MessageType.Info);
                }
            }
        }

        private void DrawInfo()
        {
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField("读取结果", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("英雄数量", _database?.Heroes.Count.ToString() ?? "0");
                EditorGUILayout.LabelField("武器数量", _database?.Weapons.Count.ToString() ?? "0");
                EditorGUILayout.LabelField("当前武器", GetSelectedWeapon()?.DisplayName ?? "无");
                EditorGUILayout.LabelField("当前动画", GetSelectedAnimation());
            }
        }

        private void LoadData(bool forceReload)
        {
            _config = SpineWeaponPreviewConfig.LoadOrCreate();
            _database = SpineWeaponPreviewData.Load(forceReload);
            BuildWeaponOptions();
            BuildAnimationOptions();
            Repaint();
        }

        private void BuildWeaponOptions()
        {
            if (_database == null)
            {
                _weaponNames = Array.Empty<string>();
                _weaponIds = Array.Empty<int>();
                _selectedWeaponIndex = 0;
                return;
            }

            _weaponNames = _database.Weapons.Select(w => w.DisplayName).ToArray();
            _weaponIds = _database.Weapons.Select(w => w.id).ToArray();
            _selectedWeaponIndex = Mathf.Max(0, Array.IndexOf(_weaponIds, _config.defaultWeaponId));
            if (_selectedWeaponIndex >= _weaponIds.Length)
            {
                _selectedWeaponIndex = 0;
            }
        }

        private void BuildAnimationOptions()
        {
            _animationOptions = _config.animationOptions == null || _config.animationOptions.Length == 0
                ? new[] { "idle", "run", "dead", "attack1", "attack2", "attack3", "skill1", "skill2", "skill3", "ui_wearequip" }
                : _config.animationOptions;
            if (Array.IndexOf(_animationOptions, "ui_wearequip") < 0)
            {
                Array.Resize(ref _animationOptions, _animationOptions.Length + 1);
                _animationOptions[_animationOptions.Length - 1] = "ui_wearequip";
                _config.animationOptions = _animationOptions;
                _config.Save();
            }
            _selectedAnimationIndex = Mathf.Max(0, Array.IndexOf(_animationOptions, _config.defaultAnimation));
            if (_selectedAnimationIndex >= _animationOptions.Length)
            {
                _selectedAnimationIndex = 0;
            }
        }

        private SpineWeaponPreviewData.WeaponPreviewData GetSelectedWeapon()
        {
            if (_database == null || _weaponIds.Length == 0 || _selectedWeaponIndex < 0 || _selectedWeaponIndex >= _weaponIds.Length)
            {
                return null;
            }

            return _database.WeaponById.TryGetValue(_weaponIds[_selectedWeaponIndex], out var weapon) ? weapon : null;
        }

        private string GetSelectedAnimation()
        {
            if (_animationOptions.Length == 0 || _selectedAnimationIndex < 0 || _selectedAnimationIndex >= _animationOptions.Length)
            {
                return "idle";
            }

            return _animationOptions[_selectedAnimationIndex];
        }

        private void AutoRefreshWeaponAndAnimation(string operation)
        {
            var weapon = GetSelectedWeapon();
            if (weapon == null)
            {
                LogPreviewOperation(operation, null, GetSelectedAnimation());
                return;
            }

            if (!SpineWeaponPreviewSceneHelper.HasPreview)
            {
                GeneratePreview();
                return;
            }

            var animation = GetSelectedAnimation();
            SpineWeaponPreviewSceneHelper.ApplyWeapon(weapon, _config.defaultWeaponQuality);
            SpineWeaponPreviewSceneHelper.PlayAnimation(animation);
            LogPreviewOperation(operation, weapon, animation);
        }

        private void AutoRefreshAnimation(string operation)
        {
            if (!SpineWeaponPreviewSceneHelper.HasPreview)
            {
                GeneratePreview();
                return;
            }

            var animation = GetSelectedAnimation();
            SpineWeaponPreviewSceneHelper.PlayAnimation(animation);
            LogPreviewOperation(operation, GetSelectedWeapon(), animation);
        }

        private void RequestAssetCheck()
        {
            if (EditorApplication.isPlaying)
            {
                RunAssetCheck();
                return;
            }

            EditorPrefs.SetBool(PendingAssetCheckPrefsKey, true);
            EditorApplication.EnterPlaymode();
        }

        private void TryRunPendingAssetCheck()
        {
            if (!EditorApplication.isPlaying || !EditorPrefs.GetBool(PendingAssetCheckPrefsKey, false))
            {
                return;
            }

            EditorPrefs.DeleteKey(PendingAssetCheckPrefsKey);
            RunAssetCheck();
        }

        private void RunAssetCheck()
        {
            LoadData(true);
            var report = SpineWeaponAssetChecker.Run(_database);
            SpineWeaponAssetCheckReportWindow.ShowReport(report);
            Debug.Log($"[SpineWeaponPreview][AssetCheck] 一键检查完成：英雄={report.HeroCount}; 武器={report.WeaponCount}; 组合={report.CombinationCount}; 错误={report.ErrorCount}; 警告={report.WarningCount}");
        }

        private void GeneratePreview()
        {
            var weapon = GetSelectedWeapon();
            if (weapon == null)
            {
                EditorUtility.DisplayDialog("Spine预览", "请选择有效武器。", "确定");
                return;
            }

            SpineWeaponPreviewSceneHelper.GenerateHeroes(_database, _config, weapon);
            var animation = GetSelectedAnimation();
            SpineWeaponPreviewSceneHelper.PlayAnimation(animation);
            LogPreviewOperation("生成/刷新角色", weapon, animation);
        }

        private void LogPreviewOperation(string operation, object weaponObject, string animation)
        {
            if (weaponObject == null)
            {
                Debug.Log($"[SpineWeaponPreview] {operation}: 未选择有效武器；配置来源=Assets/GameAsset/Config/Tables/json/Equip.json, Assets/GameAsset/Config/Tables/json/Language.json");
                return;
            }

            var weaponType = weaponObject.GetType();
            var displayName = weaponType.GetProperty("DisplayName")?.GetValue(weaponObject) as string;
            var id = weaponType.GetField("id")?.GetValue(weaponObject);
            var nameId = weaponType.GetField("nameId")?.GetValue(weaponObject);
            var firstRes = weaponType.GetProperty("FirstRes")?.GetValue(weaponObject) as string;
            var playerModelRes = weaponType.GetField("playerModelRes")?.GetValue(weaponObject) as string;
            Debug.Log(
                $"[SpineWeaponPreview] {operation}: " +
                $"配置来源=Assets/GameAsset/Config/Tables/json/Equip.json, Assets/GameAsset/Config/Tables/json/Language.json; " +
                $"读取武器=\"{displayName}\"; 武器ID={id}; Name语言ID={nameId}; " +
                $"Res={firstRes}; PlayerModelRes={playerModelRes}; 当前动画={animation}");
        }

        private void GenerateAndEnterPlayMode()
        {
            var weapon = GetSelectedWeapon();
            if (weapon == null)
            {
                EditorUtility.DisplayDialog("Spine预览", "请选择有效武器。", "确定");
                return;
            }

            SpineWeaponPreviewSceneHelper.ClearPreviewScene();
            SpineWeaponPreviewSceneHelper.PrepareEmptyPlayModeStartScene();
            EditorPrefs.SetInt(PendingWeaponPrefsKey, weapon.id);
            EditorPrefs.SetInt(PendingQualityPrefsKey, _config.defaultWeaponQuality);
            EditorPrefs.SetString(PendingAnimationPrefsKey, GetSelectedAnimation());
            EditorPrefs.SetBool(PendingRebindPrefsKey, true);
            EditorApplication.EnterPlaymode();
        }

        private void EndPreview()
        {
            if (EditorApplication.isPlaying)
            {
                EditorPrefs.SetBool(PendingCleanupPrefsKey, true);
                EditorPrefs.DeleteKey(PendingRebindPrefsKey);
                SpineWeaponPreviewSceneHelper.ClearPreviewScene();
                SpineWeaponPreviewSceneHelper.ClearPlayModeStartScene();
                EditorApplication.ExitPlaymode();
                return;
            }

            SpineWeaponPreviewSceneHelper.ClearPreviewScene();
            SpineWeaponPreviewSceneHelper.ClearPlayModeStartScene();
            EditorPrefs.DeleteKey(PendingRebindPrefsKey);
            EditorPrefs.DeleteKey(PendingCleanupPrefsKey);
        }

        private void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.EnteredPlayMode)
            {
                TryRunPendingAssetCheck();
                TryRestorePendingPreview();
            }
            else if (state == PlayModeStateChange.ExitingPlayMode)
            {
                if (EditorPrefs.GetBool(PendingRebindPrefsKey, false) || SpineWeaponPreviewSceneHelper.HasPreview)
                {
                    SpineWeaponPreviewSceneHelper.ClearPreviewScene();
                    SpineWeaponPreviewSceneHelper.ClearPlayModeStartScene();
                    EditorPrefs.DeleteKey(PendingCleanupPrefsKey);
                    EditorPrefs.DeleteKey(PendingRebindPrefsKey);
                }
            }
            else if (state == PlayModeStateChange.EnteredEditMode)
            {
                if (EditorPrefs.GetBool(PendingCleanupPrefsKey, false) || EditorPrefs.GetBool(PendingRebindPrefsKey, false))
                {
                    SpineWeaponPreviewSceneHelper.ClearPreviewScene();
                    SpineWeaponPreviewSceneHelper.ClearPlayModeStartScene();
                    EditorPrefs.DeleteKey(PendingCleanupPrefsKey);
                    EditorPrefs.DeleteKey(PendingRebindPrefsKey);
                }

                LoadData(false);
            }
        }

        private void TryRestorePendingPreview()
        {
            if (!EditorApplication.isPlaying || !EditorPrefs.GetBool(PendingRebindPrefsKey, false))
            {
                return;
            }

            LoadData(false);
            var weaponId = EditorPrefs.GetInt(PendingWeaponPrefsKey, _config.defaultWeaponId);
            _database.WeaponById.TryGetValue(weaponId, out var weapon);
            SpineWeaponPreviewSceneHelper.RebindFromScene(_database, _config);
            if (!SpineWeaponPreviewSceneHelper.HasPreview && weapon != null)
            {
                SpineWeaponPreviewSceneHelper.GenerateHeroes(_database, _config, weapon);
            }
            else if (weapon != null)
            {
                SpineWeaponPreviewSceneHelper.ApplyWeapon(weapon, EditorPrefs.GetInt(PendingQualityPrefsKey, _config.defaultWeaponQuality));
            }

            SpineWeaponPreviewSceneHelper.PlayAnimation(EditorPrefs.GetString(PendingAnimationPrefsKey, _config.defaultAnimation));
        }
    }
}
