using System.Collections.Generic;
using UnityEngine;

namespace Game.Editor.ParticlePrefabCollector
{
    
    [System.Serializable]
    public class ParticlePrefabScanResult : ScriptableObject
    {
        public List<string> prefabPaths = new();
        public List<string> scanFolders = new();
        public System.DateTime ScanTime;
    }
}
