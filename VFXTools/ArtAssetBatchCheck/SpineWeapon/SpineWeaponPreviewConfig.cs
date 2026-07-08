using System.IO;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon
{
    public class SpineWeaponPreviewConfig : ScriptableObject
    {
        public bool showBoundaries = true;
        public bool showLabels = true;
        [Range(1, 100)] public int previewSpacing = 5;
        [Range(1, 30)] public int prefabsPerRow = 8;
        public int defaultWeaponId = 10100011;
        public int defaultWeaponQuality = 2;
        public string defaultAnimation = "idle";
        public string[] animationOptions = { "idle", "run", "dead", "attack1", "attack2", "attack3", "skill1", "skill2", "skill3" };

        private const string DefaultAssetPath =
            "Assets/Editor/VFXTools/ArtAssetBatchCheck/SpineWeapon/SpineWeaponPreviewConfig.asset";

        public static SpineWeaponPreviewConfig LoadOrCreate()
        {
            var cfg = AssetDatabase.LoadAssetAtPath<SpineWeaponPreviewConfig>(DefaultAssetPath);
            if (cfg == null)
            {
                EnsureFolder(Path.GetDirectoryName(DefaultAssetPath)?.Replace('\\', '/'));
                cfg = CreateInstance<SpineWeaponPreviewConfig>();
                AssetDatabase.CreateAsset(cfg, DefaultAssetPath);
                AssetDatabase.SaveAssets();
            }

            return cfg;
        }

        public void Save()
        {
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssetIfDirty(this);
        }

        private static void EnsureFolder(string folder)
        {
            if (string.IsNullOrEmpty(folder) || AssetDatabase.IsValidFolder(folder))
            {
                return;
            }

            var parent = Path.GetDirectoryName(folder)?.Replace('\\', '/');
            if (!string.IsNullOrEmpty(parent))
            {
                EnsureFolder(parent);
            }

            var folderName = Path.GetFileName(folder);
            if (!string.IsNullOrEmpty(parent) && !string.IsNullOrEmpty(folderName) && !AssetDatabase.IsValidFolder(folder))
            {
                AssetDatabase.CreateFolder(parent, folderName);
            }
        }
    }
}
