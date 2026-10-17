using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public static class SpineWeaponPreviewData
    {
        public const string HeroJsonPath = "Assets/GameAsset/Config/Tables/json/Hero.json";
        public const string ActorJsonPath = "Assets/GameAsset/Config/Tables/json/Actor.json";
        public const string EquipJsonPath = "Assets/GameAsset/Config/Tables/json/Equip.json";
        public const string EffectJsonPath = "Assets/GameAsset/Config/Tables/json/Effect.json";
        public const string LanguageJsonPath = "Assets/GameAsset/Config/Tables/json/Language.json";

        private static Database _cachedDatabase;

        [Serializable]
        public class Database
        {
            public readonly List<HeroPreviewData> Heroes = new();
            public readonly List<WeaponPreviewData> Weapons = new();
            public readonly Dictionary<int, ActorPreviewData> Actors = new();
            public readonly Dictionary<int, HeroPreviewData> HeroById = new();
            public readonly Dictionary<int, WeaponPreviewData> WeaponById = new();
            public readonly Dictionary<int, string> SimplifiedChineseById = new();
            public readonly Dictionary<int, DeathEffectPreviewData> DeathEffectsById = new();
            public readonly Dictionary<string, List<ActorPreviewData>> ActorsByPrefabPath = new(StringComparer.OrdinalIgnoreCase);
            public bool HasDeadEffectIdColumn;
        }

        [Serializable]
        public class HeroPreviewData
        {
            public int id;
            public int actorId;
            public int modelGroupId;
            public int nameId;
            public string actorModelRes;
            public string displayName;

            public string DisplayName => string.IsNullOrEmpty(displayName) ? $"英雄 {id}" : displayName;
            public string DetailedDisplayName => $"{DisplayName} ({id})";
        }

        [Serializable]
        public class ActorPreviewData
        {
            public int id;
            public string name;
            public string modelRes;
            public int deadEffectId;

            public string PrefabPath => string.IsNullOrEmpty(modelRes) ? string.Empty :
                (modelRes.StartsWith("Assets/", StringComparison.OrdinalIgnoreCase)
                    ? modelRes.Replace('\\', '/')
                    : ToGameAssetPath("Prefab/Actor/" + modelRes));
        }

        [Serializable]
        public class DeathEffectPreviewData
        {
            public int id;
            public string name;
            public string res;
            public int type;
            public GameObject Prefab;

            public string AssetPath => ToGameAssetPath("Effect/" + res + ".prefab");
        }

        [Serializable]
        public class WeaponPreviewData
        {
            public int id;
            public int nameId;
            public int equipType;
            public List<string> res = new();
            public List<string> slots = new();
            public List<int> slotOffset = new();
            public string playerModelRes;
            public string idleAnim;
            public string runAnim;
            public string deadAnim;
            public List<string> normalAttackAnims = new();
            public List<string> skillAnims = new();

            public string displayName;

            public string DisplayName => string.IsNullOrEmpty(displayName) ? $"未命名武器 {id}" : displayName;
            public string DetailedDisplayName => $"{DisplayName} ({id} / {FirstRes})";
            public string FirstRes => res != null && res.Count > 0 ? res[0] : string.Empty;
        }

        [Serializable]
        private class JsonArray<T>
        {
            public List<T> items;
        }

        [Serializable]
        private class HeroJson
        {
            public int CfgID;
            public int Name;
            public int ActorID;
            public int ModeResGroupID;
        }

        [Serializable]
        private class ActorJson
        {
            public int CfgID;
            public string Name;
            public string ModelRes;
            public int DeadEffectID;
        }

        [Serializable]
        private sealed class EffectJson
        {
            public int CfgID;
            public string Name;
            public string Res;
            public int Type;
            public int TypeN;
        }

        [Serializable]
        private class EquipJson
        {
            public int CfgID;
            public int Name;
            public int EquipType;
            public List<string> Res;
            public List<string> Slots;
            public List<int> SlotOffset;
            public string PlayerModelRes;
            public string IdleAnim;
            public string runAnim;
            public string deadAnim;
            public List<string> NormalAttackAnims;
            public List<string> SkillAnims;
        }

        [Serializable]
        private class LanguageJson
        {
            public int CfgID;
            public string CN_S;
        }

        public static Database Load(bool forceReload = false)
        {
            if (_cachedDatabase != null && !forceReload)
            {
                return _cachedDatabase;
            }

            var db = new Database();
            LoadRuntimeTables(db);
            if (db.Actors.Count == 0)
            {
                db.HasDeadEffectIdColumn = File.Exists(ActorJsonPath) && File.ReadAllText(ActorJsonPath).Contains("\"DeadEffectID\"");
                LoadActors(db);
                LoadEffects(db);
            }
            LoadLanguages(db);
            LoadHeroes(db);
            LoadWeapons(db);
            _cachedDatabase = db;
            return db;
        }

        public static void ClearCache()
        {
            _cachedDatabase = null;
        }

        private static void LoadRuntimeTables(Database db)
        {
            var table = AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/GameAsset/Config/Tables/Tables.bytes");
            if (table == null)
            {
                Debug.LogWarning("[ArtAssetBatchCheck] 未找到 Tables.bytes，死亡预览将回退读取 JSON 导出。");
                return;
            }

            try
            {
                TableManager.LoadConfig(table.bytes);
                foreach (var actor in TableManager._ActorCfgMgr.List)
                {
                    if (actor == null || string.IsNullOrEmpty(actor.ModelRes)) continue;
                    var data = new ActorPreviewData { id = actor.ID, name = actor.Name, modelRes = actor.ModelRes, deadEffectId = actor.DeadEffectID };
                    db.Actors[data.id] = data;
                    if (!db.ActorsByPrefabPath.TryGetValue(data.PrefabPath, out var actors))
                    {
                        actors = new List<ActorPreviewData>();
                        db.ActorsByPrefabPath[data.PrefabPath] = actors;
                    }
                    actors.Add(data);
                }

                var deathEffectIds = new HashSet<int>(db.Actors.Values
                    .Where(actor => actor.deadEffectId > 0)
                    .Select(actor => actor.deadEffectId));
                deathEffectIds.Add(9400);
                foreach (var effect in TableManager._EffectCfgMgr.List)
                {
                    if (effect == null || !deathEffectIds.Contains(effect.ID) || string.IsNullOrEmpty(effect.Res)) continue;
                    db.DeathEffectsById[effect.ID] = new DeathEffectPreviewData
                    {
                        id = effect.ID,
                        name = effect.Name,
                        res = effect.Res,
                        type = effect.Type,
                        Prefab = LoadGameAssetPrefab("Effect/" + effect.Res + ".prefab")
                    };
                }
                db.HasDeadEffectIdColumn = true;
            }
            catch (Exception exception)
            {
                Debug.LogError($"[ArtAssetBatchCheck] Tables.bytes解析Actor/Effect表失败：{exception.Message}");
            }
        }

        private static void LoadLanguages(Database db)
        {
            foreach (var language in LoadJsonList<LanguageJson>(LanguageJsonPath))
            {
                if (string.IsNullOrEmpty(language.CN_S))
                {
                    continue;
                }

                db.SimplifiedChineseById[language.CfgID] = language.CN_S;
            }
        }

        private static void LoadActors(Database db)
        {
            foreach (var actor in LoadJsonList<ActorJson>(ActorJsonPath))
            {
                if (string.IsNullOrEmpty(actor.ModelRes))
                {
                    continue;
                }

                var data = new ActorPreviewData
                {
                    id = actor.CfgID,
                    name = actor.Name,
                    modelRes = actor.ModelRes,
                    deadEffectId = actor.DeadEffectID
                };
                db.Actors[actor.CfgID] = data;
                if (!db.ActorsByPrefabPath.TryGetValue(data.PrefabPath, out var actors))
                {
                    actors = new List<ActorPreviewData>();
                    db.ActorsByPrefabPath[data.PrefabPath] = actors;
                }
                actors.Add(data);
            }
        }

        private static void LoadHeroes(Database db)
        {
            foreach (var hero in LoadJsonList<HeroJson>(HeroJsonPath))
            {
                if (!db.Actors.TryGetValue(hero.ActorID, out var actor) || string.IsNullOrEmpty(actor.modelRes))
                {
                    continue;
                }

                var data = new HeroPreviewData
                {
                    id = hero.CfgID,
                    actorId = hero.ActorID,
                    modelGroupId = hero.ModeResGroupID > 0 ? hero.ModeResGroupID : 1001,
                    nameId = hero.Name,
                    actorModelRes = actor.modelRes,
                    displayName = db.SimplifiedChineseById.TryGetValue(hero.Name, out var name) ? name : $"英雄 {hero.CfgID}"
                };
                db.Heroes.Add(data);
                db.HeroById[data.id] = data;
            }

            db.Heroes.Sort((a, b) => a.id.CompareTo(b.id));
        }

        private static void LoadWeapons(Database db)
        {
            foreach (var equip in LoadJsonList<EquipJson>(EquipJsonPath))
            {
                if (equip.EquipType != 1 || equip.Res == null || equip.Res.Count == 0)
                {
                    continue;
                }

                var data = new WeaponPreviewData
                {
                    id = equip.CfgID,
                    nameId = equip.Name,
                    equipType = equip.EquipType,
                    res = equip.Res ?? new List<string>(),
                    slots = equip.Slots ?? new List<string>(),
                    slotOffset = equip.SlotOffset ?? new List<int>(),
                    playerModelRes = equip.PlayerModelRes,
                    idleAnim = equip.IdleAnim,
                    runAnim = equip.runAnim,
                    deadAnim = equip.deadAnim,
                    normalAttackAnims = equip.NormalAttackAnims ?? new List<string>(),
                    skillAnims = equip.SkillAnims ?? new List<string>(),
                    displayName = db.SimplifiedChineseById.TryGetValue(equip.Name, out var name) ? name : $"未命名武器 {equip.CfgID}"
                };
                db.Weapons.Add(data);
                db.WeaponById[data.id] = data;
            }

            db.Weapons.Sort((a, b) => a.id.CompareTo(b.id));
        }

        private static void LoadEffects(Database db)
        {
            var deathEffectIds = new HashSet<int>(db.Actors.Values
                .Where(actor => actor.deadEffectId > 0)
                .Select(actor => actor.deadEffectId));
            deathEffectIds.Add(9400);
            foreach (var effect in LoadJsonList<EffectJson>(EffectJsonPath))
            {
                if (effect == null || !deathEffectIds.Contains(effect.CfgID) || string.IsNullOrEmpty(effect.Res)) continue;
                var data = new DeathEffectPreviewData
                {
                    id = effect.CfgID,
                    name = effect.Name,
                    res = effect.Res,
                    type = effect.Type != 0 ? effect.Type : effect.TypeN,
                    Prefab = LoadGameAssetPrefab("Effect/" + effect.Res + ".prefab")
                };
                db.DeathEffectsById[data.id] = data;
            }
        }

        public static List<ActorPreviewData> GetActorsForPrefab(Database db, string prefabPath)
        {
            return db != null && db.ActorsByPrefabPath.TryGetValue(prefabPath, out var actors)
                ? actors
                : new List<ActorPreviewData>();
        }

        public static DeathEffectPreviewData GetDeathEffect(Database db, int effectId)
        {
            if (db == null || effectId <= 0) return null;
            if (db.DeathEffectsById.TryGetValue(effectId, out var effect)) return effect;
            // JSON 导出版本可能遗漏新表字段；若配置键仍是可用的数字ID，就用同ID的资源Res匹配生成表中的Effect资源名。
            var effectJson = LoadJsonList<EffectJson>(EffectJsonPath).FirstOrDefault(candidate => candidate.CfgID == effectId);
            if (effectJson == null || string.IsNullOrEmpty(effectJson.Res)) return null;
            return new DeathEffectPreviewData
            {
                id = effectId,
                name = effectJson.Name,
                res = effectJson.Res,
                type = effectJson.Type != 0 ? effectJson.Type : effectJson.TypeN,
                Prefab = LoadGameAssetPrefab("Effect/" + effectJson.Res + ".prefab")
            };
        }
        private static List<T> LoadJsonList<T>(string path)
        {
            if (!File.Exists(path))
            {
                Debug.LogWarning($"Spine预览配置表不存在：{path}");
                return new List<T>();
            }

            try
            {
                var json = File.ReadAllText(path);
                var trimmed = json.TrimStart();
                if (trimmed.StartsWith("["))
                {
                    return JsonConvert.DeserializeObject<List<T>>(json) ?? new List<T>();
                }

                var dictionary = JsonConvert.DeserializeObject<Dictionary<string, T>>(json);
                return dictionary != null ? new List<T>(dictionary.Values) : new List<T>();
            }
            catch (Exception exception)
            {
                Debug.LogError($"[SpineWeaponPreview] 配置表解析失败：path={path}; error={exception.Message}");
                return new List<T>();
            }
        }

        public static GameObject LoadGameAssetPrefab(string runtimeLocation)
        {
            return AssetDatabase.LoadAssetAtPath<GameObject>(ToGameAssetPath(runtimeLocation));
        }

        public static T LoadGameAsset<T>(string runtimeLocation) where T : UnityEngine.Object
        {
            return AssetDatabase.LoadAssetAtPath<T>(ToGameAssetPath(runtimeLocation));
        }

        public static string ToGameAssetPath(string runtimeLocation)
        {
            if (string.IsNullOrEmpty(runtimeLocation))
            {
                return string.Empty;
            }

            return runtimeLocation.StartsWith("Assets/") ? runtimeLocation : "Assets/GameAsset/" + runtimeLocation;
        }
    }
}
