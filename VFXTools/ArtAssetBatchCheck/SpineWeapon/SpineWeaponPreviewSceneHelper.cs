using System.Collections.Generic;
using System.Linq;
using Game.Battle;
using Game.Share;
using Spine.Unity;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public static class SpineWeaponPreviewSceneHelper
    {
        private const string PreviewRootName = "__SpineWeaponPreviewRoot";
        private const string DefaultWeaponBone = "weapon_r";
        private static readonly List<PreviewInstance> Instances = new();
        private static readonly List<SceneObjectState> SceneObjectStates = new();
        private static Scene _previewScene;
        private static GameObject _previewRoot;
        private static GUIStyle _labelStyle;
        private static bool _sceneGuiRegistered;
        private static int _currentWeaponId;
        private static SpineWeaponPreviewData.WeaponPreviewData _currentWeapon;

        public class SceneObjectState
        {
            public GameObject GameObject;
            public bool WasActive;
        }

        public class PreviewInstance
        {
            public int HeroId;
            public string HeroName;
            public int ModelGroupId;
            public GameObject Root;
            public ActorRender ActorRender;
            public SkeletonAnimation Skeleton;
            public Transform WeaponRoot;
            public readonly List<GameObject> WeaponRoots = new();
        }

        public static bool HasPreview => Instances.Count > 0;
        public static int CurrentWeaponId => _currentWeaponId;
        public static bool ShowBoundaries { get; set; } = true;
        public static bool ShowLabels { get; set; } = true;

        public static void OpenPreviewScene(SpineWeaponPreviewConfig config)
        {
            if (_previewScene.IsValid() && _previewScene.isLoaded)
            {
                EnsurePreviewRoot();
                ApplyConfig(config);
                EnsureSceneGuiHook();
                return;
            }

            if (EditorApplication.isPlaying)
            {
                _previewScene = SceneManager.CreateScene("SpineWeaponPreview");
            }
            else
            {
                _previewScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            }

            SceneManager.SetActiveScene(_previewScene);
            _previewRoot = new GameObject(PreviewRootName);
            SceneManager.MoveGameObjectToScene(_previewRoot, _previewScene);
            ApplyConfig(config);
            EnsureSceneGuiHook();
        }

        public static void GenerateHeroes(SpineWeaponPreviewData.Database db, SpineWeaponPreviewConfig config,
            SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            OpenPreviewScene(config);
            if (EditorApplication.isPlaying)
            {
                EnsureExclusivePreviewPlayModeScene();
            }
            else
            {
                PrepareSceneIsolation();
            }

            ClearPreviewObjects();

            var count = db.Heroes.Count;
            var spawnedCount = 0;
            var missingPrefabCount = 0;
            var invalidPrefabCount = 0;
            for (int i = 0; i < count; i++)
            {
                var hero = db.Heroes[i];
                var prefab = SpineWeaponPreviewData.LoadGameAssetPrefab("Prefab/Actor/" + hero.actorModelRes);
                if (prefab == null)
                {
                    missingPrefabCount++;
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 英雄Prefab缺失：config={SpineWeaponPreviewData.HeroJsonPath},{SpineWeaponPreviewData.ActorJsonPath}; heroId={hero.id}; actorId={hero.actorId}; modelRes={hero.actorModelRes}; assetPath={SpineWeaponPreviewData.ToGameAssetPath("Prefab/Actor/" + hero.actorModelRes)}");
                    continue;
                }

                var root = InstantiatePrefab(prefab);
                root.name = $"Hero_{hero.id}";
                root.transform.SetParent(_previewRoot.transform, true);
                root.transform.position = GetGridPosition(Instances.Count, config);
                root.transform.Find("TargetDriect")?.gameObject.SetActive(false);

                var actorRender = root.GetComponent<ActorRender>();
                if (actorRender != null && actorRender.AvatarAnimator == null)
                {
                    actorRender.SendMessage("Awake", SendMessageOptions.DontRequireReceiver);
                }

                var skeleton = actorRender != null ? actorRender.Animator : root.GetComponentInChildren<SkeletonAnimation>(true);
                var weaponRoot = actorRender != null ? actorRender.WeaponRoot : root.transform.Find("Spine/WeaponRoot");
                if (skeleton == null || weaponRoot == null)
                {
                    invalidPrefabCount++;
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 英雄Prefab结构不完整：heroId={hero.id}; actorId={hero.actorId}; assetPath={SpineWeaponPreviewData.ToGameAssetPath("Prefab/Actor/" + hero.actorModelRes)}; missing={(skeleton == null ? "SkeletonAnimation " : string.Empty)}{(weaponRoot == null ? "WeaponRoot" : string.Empty)}");
                    DestroyObject(root);
                    continue;
                }

                skeleton.Initialize(true);
                Instances.Add(new PreviewInstance
                {
                    HeroId = hero.id,
                    HeroName = hero.DisplayName,
                    ModelGroupId = hero.modelGroupId > 0 ? hero.modelGroupId : 1001,
                    Root = root,
                    ActorRender = actorRender,
                    Skeleton = skeleton,
                    WeaponRoot = weaponRoot
                });
                spawnedCount++;
            }

            Debug.Log($"[SpineWeaponPreview][AssetCheck] 英雄生成完成：配置来源={SpineWeaponPreviewData.HeroJsonPath},{SpineWeaponPreviewData.ActorJsonPath}; 配置英雄数={count}; 成功={spawnedCount}; Prefab缺失={missingPrefabCount}; 结构异常={invalidPrefabCount}");

            ApplyWeapon(weapon, config.defaultWeaponQuality);
            PlayAnimation(config.defaultAnimation);
            FramePreview(config);
            SceneView.RepaintAll();
        }

        public static void RebindFromScene(SpineWeaponPreviewData.Database db, SpineWeaponPreviewConfig config)
        {
            ApplyConfig(config);
            Instances.Clear();
            _previewRoot = GameObject.Find(PreviewRootName);
            if (_previewRoot == null)
            {
                return;
            }

            _previewScene = _previewRoot.scene;
            foreach (Transform child in _previewRoot.transform)
            {
                if (!TryParseHeroId(child.name, out var heroId) || !db.HeroById.TryGetValue(heroId, out var hero))
                {
                    continue;
                }

                var actorRender = child.GetComponent<ActorRender>();
                if (actorRender != null && actorRender.AvatarAnimator == null)
                {
                    actorRender.SendMessage("Awake", SendMessageOptions.DontRequireReceiver);
                }

                var skeleton = actorRender != null ? actorRender.Animator : child.GetComponentInChildren<SkeletonAnimation>(true);
                var weaponRoot = actorRender != null ? actorRender.WeaponRoot : child.Find("Spine/WeaponRoot");
                if (skeleton == null || weaponRoot == null)
                {
                    continue;
                }

                Instances.Add(new PreviewInstance
                {
                    HeroId = heroId,
                    HeroName = hero.DisplayName,
                    ModelGroupId = hero.modelGroupId > 0 ? hero.modelGroupId : 1001,
                    Root = child.gameObject,
                    ActorRender = actorRender,
                    Skeleton = skeleton,
                    WeaponRoot = weaponRoot
                });
            }

            EnsureSceneGuiHook();
            FramePreview(config);
        }

        public static void ApplyWeapon(SpineWeaponPreviewData.WeaponPreviewData weapon, int quality)
        {
            if (weapon == null)
            {
                return;
            }

            if (Instances.Count == 0)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 切换武器失败：当前没有可预览的英雄实例；weaponId={weapon.id}; weapon={weapon.DisplayName}");
                return;
            }

            _currentWeapon = weapon;
            _currentWeaponId = weapon.id;
            if (string.IsNullOrEmpty(weapon.playerModelRes))
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器未配置 PlayerModelRes：config={SpineWeaponPreviewData.EquipJsonPath}; weaponId={weapon.id}; weapon={weapon.DisplayName}; 将保留英雄Prefab默认SkeletonData");
            }

            foreach (var instance in Instances)
            {
                ApplyPlayerSkeleton(instance, weapon);
                ClearWeapon(instance);
                SpawnWeapon(instance, weapon, quality);
            }

            Debug.Log($"[SpineWeaponPreview][AssetCheck] 武器刷新完成：weapon={weapon.DisplayName}; weaponId={weapon.id}; res={weapon.FirstRes}; 英雄实例={Instances.Count}");

            SceneView.RepaintAll();
        }

        public static void PlayAnimation(string animationKey)
        {
            if (string.IsNullOrEmpty(animationKey))
            {
                animationKey = "idle";
            }

            if (Instances.Count == 0)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 播放动画失败：当前没有可预览的英雄实例；requestedAnimation={animationKey}");
                return;
            }

            var resolved = ResolveAnimationName(_currentWeapon, animationKey);
            var missingAnimationCount = 0;
            foreach (var instance in Instances)
            {
                if (!PlaySkeletonAnimation(instance.Skeleton, resolved, true,
                        $"heroId={instance.HeroId}; weaponId={_currentWeapon?.id ?? 0}; requested={animationKey}; resolved={resolved}"))
                {
                    missingAnimationCount++;
                }

                for (int i = 0; i < instance.WeaponRoots.Count; i++)
                {
                    var weaponSkeleton = instance.WeaponRoots[i].GetComponentInChildren<SkeletonAnimation>(true);
                    PlaySkeletonAnimation(weaponSkeleton, "idle", true,
                        $"weaponIdle; heroId={instance.HeroId}; weaponId={_currentWeapon?.id ?? 0}; weaponPart={i}");
                }
            }

            if (missingAnimationCount > 0)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 动画缺失汇总：requested={animationKey}; resolved={resolved}; 缺失英雄数={missingAnimationCount}/{Instances.Count}; weaponId={_currentWeapon?.id ?? 0}; weapon={_currentWeapon?.DisplayName}");
            }
        }

        public static void ClosePreviewScene()
        {
            var scenesToClose = new HashSet<Scene>();
            ClearPreviewObjects();
            DestroyPreviewRoots(scenesToClose);

            if (_previewScene.IsValid() && _previewScene.isLoaded)
            {
                scenesToClose.Add(_previewScene);
            }

            if (!EditorApplication.isPlayingOrWillChangePlaymode)
            {
                ClosePreviewScenes(scenesToClose);
            }

            RestoreSceneIsolation();

            _previewScene = default;
            _previewRoot = null;
            _currentWeapon = null;
            _currentWeaponId = 0;
            RemoveSceneGuiHook();
        }

        public static void ClearPreviewScene()
        {
            ClosePreviewScene();
        }

        public static void PrepareEmptyPlayModeStartScene()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                return;
            }

            const string scenePath = "Assets/Editor/VFXTools/ArtAssetBatchCheck/SpineWeapon/SpineWeaponPreviewPlayMode.unity";
            var sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>(scenePath);
            if (sceneAsset == null)
            {
                var previousActiveScene = SceneManager.GetActiveScene();
                var tempScene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
                EditorSceneManager.SaveScene(tempScene, scenePath);
                EditorSceneManager.CloseScene(tempScene, true);
                if (previousActiveScene.IsValid() && previousActiveScene.isLoaded)
                {
                    SceneManager.SetActiveScene(previousActiveScene);
                }

                sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>(scenePath);
            }

            EditorSceneManager.playModeStartScene = sceneAsset;
            Debug.Log($"[SpineWeaponPreview] PlayMode预览将从临时空场景启动：{scenePath}");
        }

        public static void ClearPlayModeStartScene()
        {
            const string scenePath = "Assets/Editor/VFXTools/ArtAssetBatchCheck/SpineWeapon/SpineWeaponPreviewPlayMode.unity";
            if (EditorSceneManager.playModeStartScene != null && AssetDatabase.GetAssetPath(EditorSceneManager.playModeStartScene) == scenePath)
            {
                EditorSceneManager.playModeStartScene = null;
            }
        }

        private static void EnsureExclusivePreviewPlayModeScene()
        {
            if (!EditorApplication.isPlaying || !_previewScene.IsValid() || !_previewScene.isLoaded)
            {
                return;
            }

            SceneManager.SetActiveScene(_previewScene);
            var unloadedSceneCount = 0;
            for (int i = SceneManager.sceneCount - 1; i >= 0; i--)
            {
                var scene = SceneManager.GetSceneAt(i);
                if (!scene.isLoaded || scene == _previewScene)
                {
                    continue;
                }

                SceneManager.UnloadSceneAsync(scene);
                unloadedSceneCount++;
            }

            var destroyedDontDestroyOnLoadCount = DestroyDontDestroyOnLoadRoots();
            if (unloadedSceneCount > 0 || destroyedDontDestroyOnLoadCount > 0)
            {
                Debug.Log($"[SpineWeaponPreview] PlayMode预览隔离：卸载场景 {unloadedSceneCount} 个，清理DontDestroyOnLoad对象 {destroyedDontDestroyOnLoadCount} 个。");
            }
        }

        private static int DestroyDontDestroyOnLoadRoots()
        {
            var probe = new GameObject("__SpineWeaponPreviewDDOLProbe");
            Object.DontDestroyOnLoad(probe);
            var dontDestroyOnLoadScene = probe.scene;
            var roots = dontDestroyOnLoadScene.GetRootGameObjects();
            var count = 0;
            foreach (var root in roots)
            {
                if (root == null || root == probe || root.name == PreviewRootName)
                {
                    continue;
                }

                DestroyObject(root);
                count++;
            }

            DestroyObject(probe);
            return count;
        }

        private static void PrepareSceneIsolation()
        {
            if (SceneObjectStates.Count > 0)
            {
                return;
            }

            for (int i = 0; i < SceneManager.sceneCount; i++)
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
                Debug.Log($"[SpineWeaponPreview] 预览隔离：已临时禁用场景对象 {SceneObjectStates.Count} 个，退出预览后会还原。");
            }
        }

        private static void RestoreSceneIsolation()
        {
            if (SceneObjectStates.Count == 0)
            {
                return;
            }

            var restoredCount = 0;
            for (int i = SceneObjectStates.Count - 1; i >= 0; i--)
            {
                var state = SceneObjectStates[i];
                if (state.GameObject == null)
                {
                    continue;
                }

                state.GameObject.SetActive(state.WasActive);
                restoredCount++;
            }

            SceneObjectStates.Clear();
            Debug.Log($"[SpineWeaponPreview] 预览隔离：已还原场景对象 {restoredCount} 个。");
        }

        private static void DestroyPreviewRoots(HashSet<Scene> scenesToClose)
        {
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                if (!scene.isLoaded)
                {
                    continue;
                }

                foreach (var root in scene.GetRootGameObjects())
                {
                    if (root.name != PreviewRootName)
                    {
                        continue;
                    }

                    scenesToClose.Add(scene);
                    DestroyObject(root);
                }
            }
        }

        private static void ClosePreviewScenes(HashSet<Scene> scenesToClose)
        {
            foreach (var scene in scenesToClose)
            {
                if (!scene.IsValid() || !scene.isLoaded || !string.IsNullOrEmpty(scene.path))
                {
                    continue;
                }

                if (SceneManager.sceneCount <= 1)
                {
                    continue;
                }

                if (SceneManager.GetActiveScene() == scene)
                {
                    SetFallbackActiveScene(scene);
                }

                EditorSceneManager.CloseScene(scene, true);
            }
        }

        private static void SetFallbackActiveScene(Scene closingScene)
        {
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                if (scene != closingScene && scene.isLoaded)
                {
                    SceneManager.SetActiveScene(scene);
                    return;
                }
            }
        }

        private static void ApplyConfig(SpineWeaponPreviewConfig config)
        {
            ShowBoundaries = config == null || config.showBoundaries;
            ShowLabels = config == null || config.showLabels;
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
                SceneManager.MoveGameObjectToScene(_previewRoot, _previewScene);
            }
        }

        private static GameObject InstantiatePrefab(GameObject prefab)
        {
            if (EditorApplication.isPlaying)
            {
                var go = Object.Instantiate(prefab);
                SceneManager.MoveGameObjectToScene(go, _previewScene);
                return go;
            }

            return (GameObject)PrefabUtility.InstantiatePrefab(prefab, _previewScene);
        }

        private static Vector3 GetGridPosition(int index, SpineWeaponPreviewConfig config)
        {
            var spacing = config != null ? Mathf.Max(1, config.previewSpacing) : 5;
            var perRow = config != null ? Mathf.Max(1, config.prefabsPerRow) : 8;
            var row = index / perRow;
            var col = index % perRow;
            return new Vector3(col * spacing, -row * spacing, 0f);
        }

        private static void ClearPreviewObjects()
        {
            foreach (var instance in Instances)
            {
                if (instance.Root != null)
                {
                    DestroyObject(instance.Root);
                }
            }

            Instances.Clear();
        }

        private static void ApplyPlayerSkeleton(PreviewInstance instance, SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            if (instance.Skeleton == null || string.IsNullOrEmpty(weapon.playerModelRes))
            {
                return;
            }

            var runtimePath = GameConst.GetPlayerModelRealPath(instance.ModelGroupId, weapon.playerModelRes);
            var skeletonData = SpineWeaponPreviewData.LoadGameAsset<SkeletonDataAsset>(runtimePath);
            if (skeletonData == null)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 玩家SkeletonData缺失：config={SpineWeaponPreviewData.EquipJsonPath}; heroId={instance.HeroId}; modelGroupId={instance.ModelGroupId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; playerModelRes={weapon.playerModelRes}; assetPath={SpineWeaponPreviewData.ToGameAssetPath(runtimePath)}");
                return;
            }

            var scaleX = instance.Skeleton.Skeleton != null ? instance.Skeleton.Skeleton.ScaleX : 1f;
            instance.Skeleton.skeletonDataAsset = skeletonData;
            instance.Skeleton.Initialize(true);
            if (instance.Skeleton.Skeleton != null)
            {
                instance.Skeleton.Skeleton.ScaleX = scaleX;
            }
        }

        private static void SpawnWeapon(PreviewInstance instance, SpineWeaponPreviewData.WeaponPreviewData weapon, int quality)
        {
            var partCount = GetRenderPartCount(weapon);
            if (partCount <= 0)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器配置无可挂载部件：config={SpineWeaponPreviewData.EquipJsonPath}; heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; resCount={weapon.res?.Count ?? 0}; slotsCount={weapon.slots?.Count ?? 0}");
                return;
            }

            for (int i = 0; i < partCount; i++)
            {
                var res = GetIndexedString(weapon.res, i);
                if (string.IsNullOrEmpty(res))
                {
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器部件Res为空：config={SpineWeaponPreviewData.EquipJsonPath}; heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; partIndex={i}");
                    continue;
                }

                var prefabPath = SpineWeaponPreviewData.ToGameAssetPath("Prefab/Equip/" + res + ".prefab");
                var prefab = SpineWeaponPreviewData.LoadGameAssetPrefab("Prefab/Equip/" + res + ".prefab");
                if (prefab == null)
                {
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器Prefab缺失：config={SpineWeaponPreviewData.EquipJsonPath}; heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; partIndex={i}; res={res}; assetPath={prefabPath}");
                    continue;
                }

                var followRoot = new GameObject(partCount > 1 ? $"WeaponRoot_{i}" : "WeaponRoot");
                followRoot.transform.SetParent(instance.WeaponRoot, false);
                var weaponObj = Object.Instantiate(prefab, followRoot.transform);
                weaponObj.name = partCount > 1 ? $"Weapon_{i}" : "Weapon";
                weaponObj.transform.localPosition = GetWeaponLocalPosition(weapon);
                weaponObj.transform.localRotation = Quaternion.identity;

                var follower = followRoot.AddComponent<BoneFollower>();
                follower.skeletonRenderer = instance.Skeleton;
                follower.followZPosition = false;
                follower.followLocalScale = true;
                var followBone = GetIndexedString(weapon.slots, i, DefaultWeaponBone);
                if (instance.Skeleton.Skeleton == null || instance.Skeleton.Skeleton.Data == null)
                {
                    instance.Skeleton.Initialize(true);
                }

                if (instance.Skeleton.Skeleton?.Data?.FindBone(followBone) == null)
                {
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器挂点骨骼缺失：config={SpineWeaponPreviewData.EquipJsonPath}; heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; partIndex={i}; res={res}; bone={followBone}; playerModelRes={weapon.playerModelRes}");
                }
                else
                {
                    follower.SetBone(followBone);
                }

                var weaponSkeleton = weaponObj.GetComponentInChildren<SkeletonAnimation>(true);
                if (weaponSkeleton == null)
                {
                    Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 武器Prefab缺少SkeletonAnimation：heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; partIndex={i}; assetPath={prefabPath}");
                }

                PlaySkeletonAnimation(weaponSkeleton, "idle", true,
                    $"weaponIdle; heroId={instance.HeroId}; weaponId={weapon.id}; weapon={weapon.DisplayName}; partIndex={i}; assetPath={prefabPath}");
                RefreshStarNodesByQuality(weaponObj.transform, quality);

                if (i > 0)
                {
                    DisableGameplayComponents(weaponObj);
                }

                instance.WeaponRoots.Add(followRoot);
            }
        }

        private static void ClearWeapon(PreviewInstance instance)
        {
            for (int i = 0; i < instance.WeaponRoots.Count; i++)
            {
                if (instance.WeaponRoots[i] != null)
                {
                    DestroyObject(instance.WeaponRoots[i]);
                }
            }

            instance.WeaponRoots.Clear();
        }

        private static int GetRenderPartCount(SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            if (weapon?.res == null || weapon.slots == null)
            {
                return 0;
            }

            return Mathf.Min(weapon.res.Count, weapon.slots.Count);
        }

        private static Vector3 GetWeaponLocalPosition(SpineWeaponPreviewData.WeaponPreviewData weapon)
        {
            if (weapon.slotOffset == null || weapon.slotOffset.Count != 2)
            {
                return new Vector3(0f, 0f, 0.5f);
            }

            return new Vector3(weapon.slotOffset[0] / 100f, weapon.slotOffset[1] / 100f, 0.5f);
        }

        private static string ResolveAnimationName(SpineWeaponPreviewData.WeaponPreviewData weapon, string animationKey)
        {
            if (weapon == null)
            {
                return animationKey;
            }

            return animationKey switch
            {
                "idle" => string.IsNullOrEmpty(weapon.idleAnim) ? "idle" : weapon.idleAnim,
                "run" => string.IsNullOrEmpty(weapon.runAnim) ? "run" : weapon.runAnim,
                "dead" => string.IsNullOrEmpty(weapon.deadAnim) ? "dead" : weapon.deadAnim,
                "atk" or "attack" or "attack1" => GetIndexedString(weapon.normalAttackAnims, 0, "attack1"),
                "attack2" => GetIndexedString(weapon.normalAttackAnims, 1, GetIndexedString(weapon.normalAttackAnims, 0, "attack1")),
                "attack3" => GetIndexedString(weapon.normalAttackAnims, 2, GetIndexedString(weapon.normalAttackAnims, 0, "attack1")),
                "skill" or "skill1" => GetIndexedString(weapon.skillAnims, 0, "skill1"),
                "skill2" => GetIndexedString(weapon.skillAnims, 1, GetIndexedString(weapon.skillAnims, 0, "skill1")),
                "skill3" => GetIndexedString(weapon.skillAnims, 2, GetIndexedString(weapon.skillAnims, 0, "skill1")),
                _ => animationKey
            };
        }

        private static string GetIndexedString(List<string> values, int index, string fallback = null)
        {
            if (values == null || values.Count == 0)
            {
                return fallback;
            }

            if (index >= 0 && index < values.Count && !string.IsNullOrEmpty(values[index]))
            {
                return values[index];
            }

            return !string.IsNullOrEmpty(values[0]) ? values[0] : fallback;
        }

        private static bool PlaySkeletonAnimation(SkeletonAnimation skeleton, string animationName, bool loop, string context)
        {
            if (skeleton == null)
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 播放动画失败：SkeletonAnimation为空；animation={animationName}; {context}");
                return false;
            }

            if (string.IsNullOrEmpty(animationName))
            {
                Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] 播放动画失败：动画名为空；{context}");
                return false;
            }

            skeleton.Initialize(false);
            if (skeleton.Skeleton == null || skeleton.Skeleton.Data == null || skeleton.AnimationState == null)
            {
                skeleton.Initialize(true);
            }

            if (skeleton.Skeleton?.Data?.FindAnimation(animationName) != null)
            {
                skeleton.AnimationState.SetAnimation(0, animationName, loop);
                return true;
            }

            Debug.LogWarning($"[SpineWeaponPreview][AssetCheck] Spine动画缺失：animation={animationName}; skeletonData={skeleton.skeletonDataAsset?.name}; {context}");
            if (animationName != "idle" && skeleton.Skeleton?.Data?.FindAnimation("idle") != null)
            {
                skeleton.AnimationState.SetAnimation(0, "idle", true);
            }

            return false;
        }

        private static void DisableGameplayComponents(GameObject weaponObject)
        {
            foreach (var collider in weaponObject.GetComponentsInChildren<Collider2D>(true))
            {
                collider.enabled = false;
            }

            var firePos = weaponObject.GetComponentInChildren<ActorWeaponFirePos>(true);
            if (firePos != null)
            {
                firePos.enabled = false;
            }
        }

        private static void RefreshStarNodesByQuality(Transform weaponTransform, int weaponQuality)
        {
            if (weaponTransform == null)
            {
                return;
            }

            var allTransforms = weaponTransform.GetComponentsInChildren<Transform>(true);
            foreach (var trans in allTransforms)
            {
                if (!TryGetStarNodeLevel(trans.name, out var starLevel))
                {
                    continue;
                }

                trans.gameObject.SetActive(starLevel > 0 && starLevel <= weaponQuality);
            }
        }

        private static bool TryGetStarNodeLevel(string nodeName, out int starLevel)
        {
            starLevel = 0;
            return !string.IsNullOrEmpty(nodeName)
                   && nodeName.StartsWith("star_")
                   && int.TryParse(nodeName.Substring("star_".Length), out starLevel);
        }

        private static bool TryParseHeroId(string objectName, out int heroId)
        {
            heroId = 0;
            if (string.IsNullOrEmpty(objectName) || !objectName.StartsWith("Hero_"))
            {
                return false;
            }

            return int.TryParse(objectName.Substring("Hero_".Length), out heroId);
        }

        private static void FramePreview(SpineWeaponPreviewConfig config)
        {
            if (Instances.Count == 0)
            {
                return;
            }

            var spacing = config != null ? Mathf.Max(1, config.previewSpacing) : 5;
            var bounds = new Bounds(Instances[0].Root.transform.position, Vector3.one);
            for (int i = 1; i < Instances.Count; i++)
            {
                bounds.Encapsulate(Instances[i].Root.transform.position);
            }

            bounds.Expand(Vector3.one * spacing);
            var view = SceneView.lastActiveSceneView;
            if (view != null)
            {
                view.pivot = bounds.center;
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
            if (Event.current.type != EventType.Repaint || Instances.Count == 0 || (!ShowBoundaries && !ShowLabels))
            {
                return;
            }

            var previousColor = Handles.color;
            foreach (var instance in Instances)
            {
                if (instance.Root == null)
                {
                    continue;
                }

                if (ShowBoundaries)
                {
                    DrawBoundary(instance.Root.transform.position);
                }

                if (ShowLabels)
                {
                    Handles.Label(instance.Root.transform.position + Vector3.up * 1.2f, $"{instance.HeroName}\nID: {instance.HeroId}", GetLabelStyle());
                }
            }

            Handles.color = previousColor;
        }

        private static void DrawBoundary(Vector3 center)
        {
            var halfSize = 1.75f;
            var corners = new[]
            {
                new Vector3(center.x - halfSize, center.y - halfSize, center.z),
                new Vector3(center.x + halfSize, center.y - halfSize, center.z),
                new Vector3(center.x + halfSize, center.y + halfSize, center.z),
                new Vector3(center.x - halfSize, center.y + halfSize, center.z)
            };
            Handles.DrawSolidRectangleWithOutline(corners, new Color(0f, 0.75f, 1f, 0.05f),
                new Color(0f, 0.75f, 1f, 0.6f));
        }

        private static GUIStyle GetLabelStyle()
        {
            return _labelStyle ??= new GUIStyle(EditorStyles.boldLabel)
            {
                alignment = TextAnchor.MiddleCenter,
                normal = { textColor = EditorGUIUtility.isProSkin ? new Color(0.6f, 0.9f, 1f) : Color.blue }
            };
        }

        private static void DestroyObject(Object obj)
        {
            if (obj == null)
            {
                return;
            }

            if (EditorApplication.isPlaying)
            {
                Object.Destroy(obj);
            }
            else
            {
                Object.DestroyImmediate(obj);
            }
        }
    }
}
