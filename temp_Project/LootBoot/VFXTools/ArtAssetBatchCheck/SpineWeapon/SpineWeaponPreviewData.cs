using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public static class SpineWeaponPreviewData
    {
        public const string HeroJsonPath = "Assets/GameAsset/Config/Tables/json/Hero.json";
        public const string ActorJsonPath = "Assets/GameAsset/Config/Tables/json/Actor.json";
        public const string EquipJsonPath = "Assets/GameAsset/Config/Tables/json/Equip.json";
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
            LoadLanguages(db);
            LoadActors(db);
            LoadHeroes(db);
            LoadWeapons(db);
            _cachedDatabase = db;
            return db;
        }

        public static void ClearCache()
        {
            _cachedDatabase = null;
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

                db.Actors[actor.CfgID] = new ActorPreviewData
                {
                    id = actor.CfgID,
                    name = actor.Name,
                    modelRes = actor.ModelRes
                };
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

        private static List<T> LoadJsonList<T>(string path)
        {
            if (!File.Exists(path))
            {
                Debug.LogWarning($"Spine预览配置表不存在：{path}");
                return new List<T>();
            }

            var json = File.ReadAllText(path);
            var wrapper = JsonUtility.FromJson<JsonArray<T>>($"{{\"items\":{json}}}");
            return wrapper?.items ?? new List<T>();
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
