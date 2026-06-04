using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.U2D;
using UnityEngine;
using UnityEngine.U2D;
using Object = UnityEngine.Object;

namespace GameFramework.Editor
{
    /// <summary>
    /// 图集导入管线。
    /// </summary>
    public class SpritePostprocessor : AssetPostprocessor
    {
        static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            foreach (var s in importedAssets)
            {
                EditorSpriteSaveInfo.OnImportSprite(s);
            }

            foreach (var s in deletedAssets)
            {
                EditorSpriteSaveInfo.OnDeleteSprite(s);
            }

            foreach (var s in movedFromAssetPaths)
            {
                EditorSpriteSaveInfo.OnDeleteSprite(s);
            }

            foreach (var s in movedAssets)
            {
                EditorSpriteSaveInfo.OnImportSprite(s);
            }
        }
    }

    public static class EditorSpriteSaveInfo
    {
        private const string ConfigAssetPath = "Assets/Editor/Postprocessor/SpriteAtlasConfig.asset";

        private static readonly List<string> _dirtyAtlasList = new List<string>();
        private static readonly Dictionary<string, List<string>> _allASprites = new Dictionary<string, List<string>>();
        private static readonly Dictionary<string, string> _uiAtlasMap = new Dictionary<string, string>();
        private static bool _isInit = false;
        private static bool m_dirty = false;

        private static SpriteAtlasConfig _config;

        /// <summary>
        /// 由配置窗口调用，注入当前配置
        /// </summary>
        public static void SetConfig(SpriteAtlasConfig config)
        {
            _config = config;
        }

        /// <summary>
        /// 获取当前配置（优先使用注入的，否则从固定路径加载）
        /// </summary>
        public static SpriteAtlasConfig GetConfig()
        {
            if (_config == null)
            {
                _config = AssetDatabase.LoadAssetAtPath<SpriteAtlasConfig>(ConfigAssetPath);
            }
            return _config;
        }

        public static void Init()
        {
            if (_isInit)
            {
                return;
            }

            EditorApplication.update -= CheckDirty;
            EditorApplication.update += CheckDirty;

            _allASprites.Clear();
            _dirtyAtlasList.Clear();
            _uiAtlasMap.Clear();

            var cfg = GetConfig();
            if (cfg == null)
            {
                _isInit = true;
                return;
            }

            // 在扫描目录下搜索所有已有 .spriteatlasv2 文件
            var atlasScanRoots = cfg.atlasScanDirs != null && cfg.atlasScanDirs.Length > 0 ? cfg.atlasScanDirs : cfg.autoImportWatchDirs;
            foreach (var watchDir in atlasScanRoots)
            {
                if (!AssetDatabase.IsValidFolder(watchDir))
                    continue;

                string[] findAssets = AssetDatabase.FindAssets("t:SpriteAtlas", new[] { watchDir });
                foreach (var findAsset in findAssets)
                {
                    var path = AssetDatabase.GUIDToAssetPath(findAsset);
                    SpriteAtlas sa = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(path);
                    if (sa == null)
                    {
                        Debug.LogError($"加载图集数据{path}失败");
                        continue;
                    }

                    string atlasName = Path.GetFileNameWithoutExtension(path);
                    var objects = sa.GetPackables();
                    foreach (var o in objects)
                    {
                        if (!_allASprites.TryGetValue(atlasName, out var list))
                        {
                            list = new List<string>();
                            _allASprites.Add(atlasName, list);
                        }

                        list.Add(AssetDatabase.GetAssetPath(o));
                    }
                }
            }

            _isInit = true;
        }

        public static void CheckDirty()
        {
            if (m_dirty)
            {
                m_dirty = false;

                AssetDatabase.Refresh();
                float lastProgress = -1;
                for (int i = 0; i < _dirtyAtlasList.Count; i++)
                {
                    string atlasName = _dirtyAtlasList[i];
                    Debug.Log("更新图集 : " + atlasName);
                    var curProgress = (float)i / _dirtyAtlasList.Count;
                    if (curProgress > lastProgress + 0.01f)
                    {
                        lastProgress = curProgress;
                        var progressText = $"当前进度：{i}/{_dirtyAtlasList.Count} {atlasName}";
                        bool cancel = EditorUtility.DisplayCancelableProgressBar("刷新图集" + atlasName, progressText, curProgress);
                        if (cancel)
                        {
                            break;
                        }
                    }

                    SaveAtlas(atlasName);
                }

                EditorUtility.ClearProgressBar();
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                _dirtyAtlasList.Clear();
            }
        }

        public static void OnImportSprite(string assetPath)
        {
            var cfg = GetConfig();
            if (cfg == null)
                return;

            if (!cfg.enableAutoImport)
                return;

            if (!cfg.IsPathWatched(assetPath))
                return;

            TextureImporter ti = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            if (ti == null)
                return;

            bool modify = false;

            // 自动修正导入设置
            if (cfg.autoFixTextureType)
            {
                if (ti.textureType != TextureImporterType.Sprite)
                {
                    ti.textureType = TextureImporterType.Sprite;
                    modify = true;
                }
            }

            if (cfg.autoClearPackingTag)
            {
                if (!string.IsNullOrEmpty(ti.spritePackingTag))
                {
                    ti.spritePackingTag = string.Empty;
                    modify = true;
                }
            }

            if (cfg.autoDisablePhysicsShape)
            {
                var setting = new TextureImporterSettings();
                ti.ReadTextureSettings(setting);
                if (setting.spriteGenerateFallbackPhysicsShape)
                {
                    setting.spriteGenerateFallbackPhysicsShape = false;
                    ti.SetTextureSettings(setting);
                    modify = true;
                }
            }

            if (cfg.autoSetAlphaIsTransparency)
            {
                if (!ti.alphaIsTransparency)
                {
                    ti.alphaIsTransparency = true;
                    modify = true;
                }
            }

            if (modify)
            {
                ti.SaveAndReimport();
            }

            if (ti.textureType == TextureImporterType.Sprite)
            {
                OnProcessSprite(assetPath);
            }
        }

        public static string GetSpritePath(string assetPath)
        {
            string path = assetPath.Substring(0, assetPath.LastIndexOf(".", StringComparison.Ordinal));
            path = path.Replace("Assets/AssetRaw/", "");
            return path;
        }

        /// <summary>
        /// 根据文件路径，返回图集名称。优先匹配目录级规则，否则按目录整体打包。
        /// </summary>
        public static string GetPackageTag(string fullName)
        {
            var cfg = GetConfig();
            if (cfg != null && cfg.packMode == SpriteAtlasPackMode.FolderReference)
                return GetFolderPackageTag(Path.GetDirectoryName(fullName)?.Replace("\\", "/"));

            return GetPrefixRulePackageTag(fullName);
        }

        private static string GetFolderPackageTag(string folderPath)
        {
            var cfg = GetConfig();
            string marker = cfg != null ? cfg.pathMarker : "UIRaw";
            if (string.IsNullOrEmpty(marker) || string.IsNullOrEmpty(folderPath))
                return "";

            folderPath = folderPath.Replace("\\", "/");
            int idx = folderPath.LastIndexOf(marker, StringComparison.Ordinal);
            if (idx == -1)
                return "";

            return "Atlas_" + folderPath.Substring(idx + marker.Length).Trim('/').Replace("/", "_");
        }

        private static string GetFolderAtlasPath(string folderPath)
        {
            string atlasName = GetFolderPackageTag(folderPath);
            if (string.IsNullOrEmpty(atlasName))
                return "";

            return folderPath.Replace("\\", "/") + "/" + atlasName + ".spriteatlasv2";
        }

        private static string GetPrefixRulePackageTag(string fullName)
        {
            var cfg = GetConfig();
            string marker = cfg != null ? cfg.pathMarker : "UIRaw";
            if (string.IsNullOrEmpty(marker))
                return "";

            fullName = fullName.Replace("\\", "/");
            int idx = fullName.LastIndexOf(marker, StringComparison.Ordinal);
            if (idx == -1)
            {
                return "";
            }

            var atlasPath = fullName.Substring(idx + marker.Length).Trim('/');
            int lastSlash = atlasPath.LastIndexOf("/", StringComparison.Ordinal);
            if (lastSlash < 0)
                return "";

            string dirPart = "Atlas_" + atlasPath.Substring(0, lastSlash).Replace("/", "_");
            string fileName = Path.GetFileNameWithoutExtension(fullName);

            // 检查该目录是否有打包规则
            var rule = cfg.FindRuleForPath(fullName);
            if (rule != null && rule.prefixes != null)
            {
                // 按长度降序排列，长前缀优先匹配（避免 "monster_" 抢先匹配 "monster_boss_01"）
                var sortedPrefixes = new List<string>(rule.prefixes);
                sortedPrefixes.Sort((a, b) => (b?.Length ?? 0).CompareTo(a?.Length ?? 0));
                foreach (var prefix in sortedPrefixes)
                {
                    if (!string.IsNullOrEmpty(prefix) && fileName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    {
                        string prefixClean = prefix.Trim('_');
                        return $"{dirPart}_{prefixClean}";
                    }
                }
            }

            // 无规则或无匹配，整目录打包
            return dirPart;
        }

        public static void OnProcessSprite(string assetPath)
        {
            if (!assetPath.StartsWith("Assets"))
            {
                return;
            }

            var cfg = GetConfig();
            Init();

            var spriteName = Path.GetFileNameWithoutExtension(assetPath);
            var spritePath = GetSpritePath(assetPath);
            if (!_uiAtlasMap.TryGetValue(spriteName, out string oldAssetPath) || spritePath == oldAssetPath)
            {
                _uiAtlasMap[spriteName] = spritePath;
                m_dirty = true;
            }
            else
            {
                Debug.LogError($"有重名的图片：{spriteName}\n旧图集：{oldAssetPath}\n新图集：{spritePath} ");
                _uiAtlasMap[spriteName] = spritePath;
                m_dirty = true;
            }

            string atlasName = GetPackageTag(assetPath);
            if (string.IsNullOrEmpty(atlasName))
            {
                return;
            }

            // 检查排除规则
            var rule = cfg.FindRuleForPath(assetPath);
            if (rule != null && rule.IsFileExcluded(Path.GetFileNameWithoutExtension(assetPath)))
            {
                return;
            }

            if (!_allASprites.TryGetValue(atlasName, out var ret))
            {
                ret = new List<string>();
                _allASprites.Add(atlasName, ret);
            }

            if (!ret.Contains(assetPath))
            {
                ret.Add(assetPath);
                m_dirty = true;
                if (!_dirtyAtlasList.Contains(atlasName))
                {
                    _dirtyAtlasList.Add(atlasName);
                }
            }
        }

        public static void OnDeleteSprite(string assetPath)
        {
            var cfg = GetConfig();
            if (cfg == null)
                return;

            if (!cfg.enableAutoImport)
                return;

            if (!cfg.IsPathWatched(assetPath))
                return;

            Init();
            string atlasName = GetPackageTag(assetPath);
            if (!_allASprites.TryGetValue(atlasName, out var ret))
            {
                return;
            }

            // 改成文件名的匹配
            if (!ret.Exists(s => Path.GetFileName(s) == Path.GetFileName(assetPath)))
            {
                return;
            }

            var spriteName = Path.GetFileNameWithoutExtension(assetPath);
            if (_uiAtlasMap.ContainsKey(spriteName))
            {
                _uiAtlasMap.Remove(spriteName);
                m_dirty = true;
            }

            ret.Remove(assetPath);
            m_dirty = true;
            if (!_dirtyAtlasList.Contains(atlasName))
            {
                _dirtyAtlasList.Add(atlasName);
            }
        }

        #region 更新图集

        public static void ClearExistingAtlases()
        {
            var cfg = GetConfig();
            if (cfg == null || cfg.atlasScanDirs == null)
                return;

            int count = 0;
            foreach (var scanDir in cfg.atlasScanDirs)
            {
                if (!AssetDatabase.IsValidFolder(scanDir))
                    continue;

                var guids = AssetDatabase.FindAssets("t:SpriteAtlas", new[] { scanDir });
                foreach (var guid in guids)
                {
                    var path = AssetDatabase.GUIDToAssetPath(guid);
                    if (!path.EndsWith(".spriteatlasv2", StringComparison.OrdinalIgnoreCase))
                        continue;

                    if (AssetDatabase.DeleteAsset(path))
                        count++;
                }
            }

            _allASprites.Clear();
            _dirtyAtlasList.Clear();
            _uiAtlasMap.Clear();
            _isInit = false;
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"已清除图集数量: {count}");
        }

        public static void SaveAtlas(string atlasName)
        {
            SaveAtlas(atlasName, false);
        }

        private static void SaveAtlas(string atlasName, bool useFolderReference)
        {
            var cfg = GetConfig();

            if (!_allASprites.TryGetValue(atlasName, out var list) || list.Count == 0)
            {
                DeleteAtlasByName(atlasName);
                return;
            }

            list.Sort(StringComparer.Ordinal);

            // 图集文件保存在sprite所在目录下
            var path = GetAtlasPath(atlasName, list);
            string atlasDir = Path.GetDirectoryName(path).Replace("\\", "/");

            // 确保目录存在
            if (!AssetDatabase.IsValidFolder(atlasDir))
            {
                var parts = atlasDir.Split('/');
                var currentPath = parts[0];
                for (int i = 1; i < parts.Length; i++)
                {
                    var parentPath = currentPath;
                    currentPath += "/" + parts[i];
                    if (!AssetDatabase.IsValidFolder(currentPath))
                        AssetDatabase.CreateFolder(parentPath, parts[i]);
                }
            }

            // 删除旧文件
            var existing = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(path);
            if (existing != null)
                AssetDatabase.DeleteAsset(path);

            var atlas = new SpriteAtlasAsset();

            // 添加sprite
            List<Object> spriteList = new List<Object>();
            foreach (var s in list)
            {
                var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(s);
                if (sprite != null)
                    spriteList.Add(sprite);
            }

            if (spriteList.Count > 0)
            {
                if (useFolderReference)
                {
                    var folder = AssetDatabase.LoadAssetAtPath<Object>(atlasDir);
                    if (folder != null)
                        atlas.Add(new[] { folder });
                }
                else
                {
                    atlas.Add(spriteList.ToArray());
                }
            }

            SpriteAtlasAsset.Save(atlas, path);
            AssetDatabase.Refresh();

            ApplyAtlasImporterSettings(path, cfg);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            NormalizeAtlasTextFiles(path);
        }

        private static string GetAtlasPath(string atlasName, List<string> list)
        {
            string firstPath = list[0].Replace("\\", "/");
            int lastSlash = firstPath.LastIndexOf('/');
            string atlasDir = lastSlash > 0 ? firstPath.Substring(0, lastSlash) : firstPath;
            return $"{atlasDir}/{atlasName}.spriteatlasv2";
        }

        private static string GetAtlasPathForFolder(string folderPath)
        {
            folderPath = folderPath.Replace("\\", "/");
            return $"{folderPath}/{GetFolderPackageTag(folderPath)}.spriteatlasv2";
        }

        private static void SaveFolderAtlas(string folderPath)
        {
            var cfg = GetConfig();
            folderPath = folderPath.Replace("\\", "/");
            string atlasName = GetFolderPackageTag(folderPath);
            if (string.IsNullOrEmpty(atlasName))
                return;

            var path = GetAtlasPathForFolder(folderPath);
            var existing = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(path);
            if (existing != null)
                AssetDatabase.DeleteAsset(path);

            var folder = AssetDatabase.LoadAssetAtPath<Object>(folderPath);
            if (folder == null)
            {
                Debug.LogError($"加载图集文件夹失败: {folderPath}");
                return;
            }

            var atlas = new SpriteAtlasAsset();
            atlas.Add(new[] { folder });
            SpriteAtlasAsset.Save(atlas, path);
            AssetDatabase.Refresh();
            ApplyAtlasImporterSettings(path, cfg);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            NormalizeAtlasTextFiles(path);
        }

        private static bool IsFolderAtlasChanged(string folderPath, SpriteAtlasConfig cfg)
        {
            var path = GetAtlasPathForFolder(folderPath);
            if (IsAtlasImporterSettingsChanged(path, cfg))
                return true;

            var atlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(path);
            if (atlas == null)
                return true;

            var packables = atlas.GetPackables();
            if (packables.Length != 1)
                return true;

            return AssetDatabase.GetAssetPath(packables[0]).Replace("\\", "/") != folderPath.Replace("\\", "/");
        }

        private static bool IsAtlasPackablesEqual(string path, List<string> spritePaths)
        {
            var atlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(path);
            if (atlas == null)
                return false;

            var packables = atlas.GetPackables();
            if (packables.Length != spritePaths.Count)
                return false;

            var paths = new List<string>(packables.Length);
            foreach (var packable in packables)
            {
                paths.Add(AssetDatabase.GetAssetPath(packable).Replace("\\", "/"));
            }
            paths.Sort(StringComparer.Ordinal);

            for (int i = 0; i < spritePaths.Count; i++)
            {
                if (paths[i] != spritePaths[i].Replace("\\", "/"))
                    return false;
            }

            return true;
        }

        private static bool IsAtlasImporterSettingsChanged(string path, SpriteAtlasConfig cfg)
        {
            var importer = AssetImporter.GetAtPath(path) as SpriteAtlasImporter;
            if (importer == null)
                return true;

            var packingSetting = importer.packingSettings;
            if (packingSetting.padding != (cfg != null ? cfg.padding : 4)) return true;
            if (packingSetting.enableRotation != (cfg != null ? cfg.enableRotation : true)) return true;
            if (packingSetting.enableTightPacking != (cfg != null ? cfg.enableTightPacking : false)) return true;
            if (packingSetting.enableAlphaDilation != (cfg != null ? cfg.enableAlphaDilation : false)) return true;

            var textureSetting = importer.textureSettings;
            if (textureSetting.readable != (cfg != null ? cfg.readable : false)) return true;
            if (textureSetting.generateMipMaps != (cfg != null ? cfg.generateMipMaps : false)) return true;
            if (textureSetting.sRGB != (cfg != null ? cfg.sRGB : true)) return true;
            if (textureSetting.filterMode != (cfg != null ? cfg.filterMode : FilterMode.Bilinear)) return true;
            if (!importer.includeInBuild) return true;

            return false;
        }

        private static void ApplyAtlasImporterSettings(string path, SpriteAtlasConfig cfg)
        {
            var importer = AssetImporter.GetAtPath(path) as SpriteAtlasImporter;
            if (importer == null)
            {
                Debug.LogError($"加载图集Importer失败: {path}");
                return;
            }

            var packingSetting = importer.packingSettings;
            packingSetting.padding = cfg != null ? cfg.padding : 4;
            packingSetting.enableRotation = cfg != null ? cfg.enableRotation : true;
            packingSetting.enableTightPacking = cfg != null ? cfg.enableTightPacking : false;
            packingSetting.enableAlphaDilation = cfg != null ? cfg.enableAlphaDilation : false;
            importer.packingSettings = packingSetting;

            var textureSetting = importer.textureSettings;
            textureSetting.readable = cfg != null ? cfg.readable : false;
            textureSetting.generateMipMaps = cfg != null ? cfg.generateMipMaps : false;
            textureSetting.sRGB = cfg != null ? cfg.sRGB : true;
            textureSetting.filterMode = cfg != null ? cfg.filterMode : FilterMode.Bilinear;
            importer.textureSettings = textureSetting;

            importer.includeInBuild = true;
            AssetDatabase.WriteImportSettingsIfDirty(path);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        private static void NormalizeAtlasTextFiles(string atlasPath)
        {
            NormalizeTextLineEndings(atlasPath);
            NormalizeTextLineEndings(atlasPath + ".meta");
        }

        private static void NormalizeTextLineEndings(string assetPath)
        {
            string fullPath = Path.IsPathRooted(assetPath)
                ? assetPath
                : Path.GetFullPath(Path.Combine(Path.GetDirectoryName(Application.dataPath), assetPath));
            if (!File.Exists(fullPath))
                return;

            string text = File.ReadAllText(fullPath);
            string normalized = text.Replace("\r\n", "\n").Replace("\r", "\n");
            if (text == normalized)
                return;

            File.WriteAllText(fullPath, normalized, new System.Text.UTF8Encoding(false));
        }

        private static void DeleteAtlasByName(string atlasName)
        {
            var cfg = GetConfig();
            if (cfg == null) return;

            var searchDirs = cfg.atlasScanDirs != null && cfg.atlasScanDirs.Length > 0 ? cfg.atlasScanDirs : cfg.autoImportWatchDirs;
            foreach (var watchDir in searchDirs)
            {
                if (!AssetDatabase.IsValidFolder(watchDir))
                    continue;

                string[] guids = AssetDatabase.FindAssets($"{atlasName} t:SpriteAtlas", new[] { watchDir });
                foreach (var guid in guids)
                {
                    var p = AssetDatabase.GUIDToAssetPath(guid);
                    if (Path.GetFileNameWithoutExtension(p) == atlasName)
                    {
                        AssetDatabase.DeleteAsset(p);
                        return;
                    }
                }
            }
        }

        #endregion

        #region 重新生成图集

        private static readonly Dictionary<string, List<string>> m_tempAllASprites = new Dictionary<string, List<string>>();

        /// <summary>
        /// 由配置窗口调用，执行全量图集重生成
        /// </summary>
        public static void ForceGenAtlas()
        {
            var cfg = GetConfig();
            if (cfg == null || cfg.atlasScanDirs == null || cfg.atlasScanDirs.Length == 0)
            {
                EditorUtility.DisplayDialog("错误", "未配置扫描目录", "确定");
                return;
            }

            // 强制重新扫描已有图集，确保对比的是最新状态
            _isInit = false;
            Init();

            if (cfg.packMode == SpriteAtlasPackMode.FolderReference)
            {
                ForceGenFolderReferenceAtlases(cfg);
                return;
            }

            List<string> needSaveAtlas = new List<string>();
            m_tempAllASprites.Clear();

            foreach (var scanDir in cfg.atlasScanDirs)
            {
                if (string.IsNullOrEmpty(scanDir) || !AssetDatabase.IsValidFolder(scanDir))
                {
                    Debug.LogWarning($"扫描目录不存在或无效: {scanDir}");
                    continue;
                }

                var findAssets = AssetDatabase.FindAssets("t:sprite", new[] { scanDir });
                foreach (var findAsset in findAssets)
                {
                    var path = AssetDatabase.GUIDToAssetPath(findAsset);
                    var atlasName = GetPackageTag(path);
                    if (string.IsNullOrEmpty(atlasName))
                        continue;

                    // 检查排除规则
                    var rule = cfg.FindRuleForPath(path);
                    if (rule != null && rule.IsFileExcluded(Path.GetFileNameWithoutExtension(path)))
                        continue;

                    if (!m_tempAllASprites.TryGetValue(atlasName, out var spriteList))
                    {
                        spriteList = new List<string>();
                        m_tempAllASprites[atlasName] = spriteList;
                    }

                    if (!spriteList.Contains(path))
                    {
                        spriteList.Add(path);
                    }
                }
            }

            foreach (var kv in m_tempAllASprites)
            {
                kv.Value.Sort(StringComparer.Ordinal);
            }

            // 过滤：sprite数低于门槛的不生成图集
            int minCount = cfg != null ? cfg.minSpriteCount : 1;
            var toRemove = new List<string>();
            foreach (var kv in m_tempAllASprites)
            {
                if (kv.Value.Count < minCount)
                    toRemove.Add(kv.Key);
            }
            foreach (var key in toRemove)
            {
                m_tempAllASprites.Remove(key);
                if (_allASprites.ContainsKey(key))
                {
                    _allASprites.Remove(key);
                    DeleteAtlasByName(key);
                }
            }

            // 有变化的才刷
            var iter = m_tempAllASprites.GetEnumerator();
            while (iter.MoveNext())
            {
                bool needSave = false;
                var atlasName = iter.Current.Key;
                var newSpritesList = iter.Current.Value;

                if (_allASprites.TryGetValue(atlasName, out var existSprites))
                {
                    if (existSprites.Count != newSpritesList.Count)
                    {
                        needSave = true;
                    }
                    else
                    {
                        for (int i = 0; i < newSpritesList.Count; i++)
                        {
                            if (!existSprites.Contains(newSpritesList[i]))
                            {
                                needSave = true;
                                break;
                            }
                        }
                    }
                }
                else
                {
                    needSave = true;
                    _allASprites.Add(atlasName, new List<string>());
                }

                if (!needSave && IsAtlasImporterSettingsChanged(GetAtlasPath(atlasName, newSpritesList), cfg))
                {
                    needSave = true;
                }

                if (!needSave && !IsAtlasPackablesEqual(GetAtlasPath(atlasName, newSpritesList), newSpritesList))
                {
                    needSave = true;
                }

                if (needSave)
                {
                    _allASprites[atlasName].Clear();
                    _allASprites[atlasName].AddRange(newSpritesList);
                }

                if (needSave && !needSaveAtlas.Contains(atlasName))
                {
                    needSaveAtlas.Add(atlasName);
                }
            }

            iter.Dispose();
            foreach (var atlas in needSaveAtlas)
            {
                Debug.LogFormat("Gen atlas:{0}", atlas);
                SaveAtlas(atlas, cfg.packMode == SpriteAtlasPackMode.FolderReference);
            }

            CleanupGeneratedAtlases(cfg, m_tempAllASprites);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            SpriteAtlasUtility.PackAllAtlases(EditorUserBuildSettings.activeBuildTarget);
            Debug.Log("Gen end");
        }

        private static void ForceGenFolderReferenceAtlases(SpriteAtlasConfig cfg)
        {
            var validAtlases = new Dictionary<string, List<string>>();
            int minCount = cfg != null ? cfg.minSpriteCount : 1;

            foreach (var scanDir in cfg.atlasScanDirs)
            {
                if (string.IsNullOrEmpty(scanDir) || !AssetDatabase.IsValidFolder(scanDir))
                {
                    Debug.LogWarning($"扫描目录不存在或无效: {scanDir}");
                    continue;
                }

                var findAssets = AssetDatabase.FindAssets("t:sprite", new[] { scanDir });
                if (findAssets.Length < minCount)
                    continue;

                string atlasName = GetFolderPackageTag(scanDir);
                if (string.IsNullOrEmpty(atlasName))
                    continue;

                validAtlases[atlasName] = new List<string> { scanDir };
                if (IsFolderAtlasChanged(scanDir, cfg))
                {
                    Debug.LogFormat("Gen atlas:{0}", atlasName);
                    SaveFolderAtlas(scanDir);
                }
            }

            CleanupGeneratedAtlases(cfg, validAtlases);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            SpriteAtlasUtility.PackAllAtlases(EditorUserBuildSettings.activeBuildTarget);
            Debug.Log("Gen end");
        }

        private static void CleanupGeneratedAtlases(SpriteAtlasConfig cfg, Dictionary<string, List<string>> validAtlases)
        {
            if (cfg == null || cfg.atlasScanDirs == null)
                return;

            var valid = new HashSet<string>(validAtlases.Keys);
            foreach (var scanDir in cfg.atlasScanDirs)
            {
                if (!AssetDatabase.IsValidFolder(scanDir))
                    continue;

                var guids = AssetDatabase.FindAssets("t:SpriteAtlas", new[] { scanDir });
                foreach (var guid in guids)
                {
                    var path = AssetDatabase.GUIDToAssetPath(guid);
                    var atlasName = Path.GetFileNameWithoutExtension(path);
                    if (atlasName.EndsWith("_Atlas", StringComparison.Ordinal) && !valid.Contains(atlasName))
                    {
                        AssetDatabase.DeleteAsset(path);
                    }
                }
            }
        }

        #endregion
    }
}