using System.IO;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.SpriteAnim
{
    /// <summary>序列帧动画检查的持久化配置。</summary>
    public class SpriteAnimCheckConfig : ScriptableObject
    {
        [Header("检查范围")]
        [Tooltip("扫描该目录下所有预制体，缺少 ActorSpriteAnimator 的预制体会被跳过。")]
        public string prefabRootFolder = "Assets/GameAsset/Prefab/Actor/Monster";

        [Header("检查项")]
        public bool checkSourceFolderConsistency = true;
        public bool checkPixelsPerUnit = true;
        public bool checkMissingScripts = true;

        [Header("预览")]
        public bool showBoundaries = true;
        public bool showLabels = true;
        [Tooltip("在 SceneView 中绘制每个预览预制体的轴心（ActorSpriteAnimator.pivot）。")]
        public bool showPivots;
        [Range(0.5f, 50f)] public float previewSpacing = 4f;
        [Range(1, 30)] public int prefabsPerRow = 10;
        [Tooltip("为空表示各预制体播放自己的默认动画。")]
        public string previewAnimation = string.Empty;

        private const string DefaultAssetPath =
            "Assets/Editor/VFXTools/ArtAssetBatchCheck/SpriteAnim/SpriteAnimCheckConfig.asset";

        public static SpriteAnimCheckConfig LoadOrCreate()
        {
            var cfg = AssetDatabase.LoadAssetAtPath<SpriteAnimCheckConfig>(DefaultAssetPath);
            if (cfg == null)
            {
                EnsureFolder(Path.GetDirectoryName(DefaultAssetPath)?.Replace('\\', '/'));
                cfg = CreateInstance<SpriteAnimCheckConfig>();
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
