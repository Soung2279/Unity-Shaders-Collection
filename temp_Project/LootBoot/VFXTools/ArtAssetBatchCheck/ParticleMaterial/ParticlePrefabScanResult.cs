using System.Collections.Generic;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck.ParticleMaterial
{
    
    [System.Serializable]
    public class ParticlePrefabScanResult : ScriptableObject
    {
        public List<string> prefabPaths = new();
        public List<string> scanFolders = new();
        public System.DateTime ScanTime;
        public List<string> materialPaths = new();
        public List<string> materialScanFolders = new();
        public List<string> materialTextureCheckSkippedShaders = new();
        public System.DateTime MaterialScanTime;
    }
}
