using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.ParticleMaterial
{
    /// <summary>
    /// 粒子预览工具配置（可拓展更多偏好字段）。
    /// </summary>
    public class ParticlePrefabPreviewConfig : ScriptableObject
    {
        [Header("显示开关")] public bool showBoundaries = true;
        public bool showLabels = true;

        [Header("预览参数")] [Range(1, 100)] public int previewSpacing = 10;

        [Header("播放设置")] public bool loopAllParticles;

        [Header("布局设置")] public bool verticalLayout; // false: XZ 平面；true: XY 平面

#if UNITY_EDITOR
        private const string DefaultAssetPath =
            "Assets/Editor/VFXTools/ArtAssetBatchCheck/ParticleMaterial/ParticlePrefabPreviewConfig.asset";

        public static ParticlePrefabPreviewConfig LoadOrCreate()
        {
            var cfg = AssetDatabase.LoadAssetAtPath<ParticlePrefabPreviewConfig>(DefaultAssetPath);
            if (cfg == null)
            {
                cfg = CreateInstance<ParticlePrefabPreviewConfig>();
                AssetDatabase.CreateAsset(cfg, DefaultAssetPath);
                AssetDatabase.SaveAssets();
            }

            return cfg;
        }

        public void Save()
        {
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
        }
#endif
    }
}