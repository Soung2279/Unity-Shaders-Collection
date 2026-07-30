using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 单个目录的图集打包规则——按文件名前缀拆分图集
/// </summary>
[System.Serializable]
public class AtlasDirectoryRule
{
    [Tooltip("目标目录路径（如 Assets/GameAsset/Sprite/Monster）")]
    public string directoryPath;

    [Tooltip("文件名前缀列表，每个前缀生成一个独立图集")]
    public string[] prefixes;

    [Tooltip("排除文件（文件名不含后缀，完全匹配）")]
    public string[] excludeFiles;

    /// <summary>
    /// 判断文件名（不含后缀）是否应被排除</summary>
    public bool IsFileExcluded(string fileNameWithoutExtension)
    {
        if (excludeFiles == null) return false;
        foreach (var ex in excludeFiles)
        {
            if (!string.IsNullOrEmpty(ex) && fileNameWithoutExtension.Equals(ex, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
    }
}

public enum SpriteAtlasPackMode
{
    PrefixRules = 0,
    FolderReference = 1,
}

/// <summary>
/// Sprite图集自动打包管线配置（ScriptableObject）
/// 存放路径: Assets/Editor/Postprocessor/SpriteAtlasConfig.asset
/// </summary>
public class SpriteAtlasConfig : ScriptableObject
{
    [Header("路径")]
    [Tooltip("自动扫描的根目录列表。点击自动扫描时，会添加每个根目录下最多两层的子目录")]
    public string[] autoScanRootDirs = new string[]
    {
        "Assets/GameAsset/Sprite",
    };

    [Tooltip("手动重生成时的Sprite扫描目录列表")]
    public string[] atlasScanDirs = new string[]
    {
        "Assets/GameAsset/UIRaw/Atlas",
    };

    [Tooltip("自动导入监听目录列表（只有这些目录下的资源才会被Postprocessor处理）")]
    public string[] autoImportWatchDirs = new string[]
    {
        "Assets/GameAsset/UIRaw",
    };

    [Tooltip("路径标记：GetPackageTag在路径中查找此标记来截取图集名")]
    public string pathMarker = "UIRaw";

    [Tooltip("图集打包方式：按前缀规则拆分，或直接引用整个扫描文件夹")]
    public SpriteAtlasPackMode packMode = SpriteAtlasPackMode.PrefixRules;

    [Header("目录级打包规则")]
    [Tooltip("针对特定目录按文件名前缀拆分为多个图集（未匹配到的图片仍按目录打包为一个图集）")]
    public AtlasDirectoryRule[] directoryRules;

    [Header("图集生成门槛")]
    [Tooltip("目录中的Sprite数量低于此值时跳过生成。0表示不限制")]
    [Min(0)]
    public int minSpriteCount = 1;

    [Header("导入自动修正")]
    [Tooltip("总开关：关闭后不对任何图片自动应用导入设置")]
    public bool enableAutoImport = true;

    [Space(4)]
    [Tooltip("导入时自动将非Sprite纹理设为Sprite类型")]
    public bool autoFixTextureType = true;

    [Tooltip("导入时自动清除旧的spritePackingTag")]
    public bool autoClearPackingTag = true;

    [Tooltip("导入时自动关闭generateFallbackPhysicsShape")]
    public bool autoDisablePhysicsShape = true;

    [Tooltip("导入时自动设置alphaIsTransparency（影响图集边缘透明处理）")]
    public bool autoSetAlphaIsTransparency = true;

    [Header("图集Packing设置")]
    public bool enableRotation = true;
    public bool enableTightPacking = false;
    public bool enableAlphaDilation = false;
    [Range(0, 8)]
    public int padding = 4;

    [Header("图集Texture设置")]
    public bool readable = false;
    public bool generateMipMaps = false;
    public bool sRGB = true;
    public FilterMode filterMode = FilterMode.Bilinear;

    /// <summary>
    /// 根据资源路径查找该目录的打包规则（匹配directoryPath等于资源所在目录）</summary>
    public AtlasDirectoryRule FindRuleForPath(string assetPath)
    {
        if (directoryRules == null) return null;
        string dir = System.IO.Path.GetDirectoryName(assetPath).Replace("\\", "/");
        foreach (var rule in directoryRules)
        {
            if (rule != null && rule.directoryPath != null &&
                rule.directoryPath.Replace("\\", "/") == dir)
            {
                return rule;
            }
        }
        return null;
    }

    /// <summary>
    /// 判断给定路径是否在任一监听目录下
    /// </summary>
    public bool IsPathWatched(string assetPath)
    {
        foreach (var dir in autoImportWatchDirs)
        {
            if (!string.IsNullOrEmpty(dir) && assetPath.StartsWith(dir, StringComparison.Ordinal))
                return true;
        }
        return false;
    }
}
