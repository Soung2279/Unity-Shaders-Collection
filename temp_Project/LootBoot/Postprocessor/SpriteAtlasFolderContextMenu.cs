using System;
using System.Collections.Generic;
using GameFramework.Editor;
using UnityEditor;
using UnityEngine;

public static class SpriteAtlasFolderContextMenu
{
    private const string MenuPath = "Assets/图集/将文件夹打包为图集";

    [MenuItem(MenuPath, false, 2000)]
    private static void CreateAtlasesFromSelectedFolders()
    {
        var folderPaths = GetSelectedFolderPaths();
        var recordedFolders = new List<string>();
        int createdCount = 0;
        int skippedCount = 0;
        int belowThresholdCount = 0;
        var emptyFolders = new List<string>();

        foreach (var folderPath in folderPaths)
        {
            int spriteCount = EditorSpriteSaveInfo.GetSpriteCount(folderPath);
            if (spriteCount == 0)
            {
                emptyFolders.Add(folderPath);
                continue;
            }

            if (!EditorSpriteSaveInfo.MeetsMinimumSpriteCount(folderPath, out spriteCount, out int minimumCount))
            {
                recordedFolders.Add(folderPath);
                belowThresholdCount++;
                Debug.LogWarning($"右键生成图集已跳过，Sprite数量低于配置门槛: {folderPath}（当前={spriteCount}，最低={minimumCount}）");
                continue;
            }

            string atlasName = EditorSpriteSaveInfo.GetContextFolderAtlasName(folderPath);
            string atlasPath = $"{folderPath}/{atlasName}.spriteatlasv2";
            bool overwrite = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(atlasPath) == null ||
                             EditorUtility.DisplayDialog("图集已存在", $"{atlasPath}\n\n是否覆盖？", "覆盖", "跳过");
            if (!overwrite)
            {
                recordedFolders.Add(folderPath);
                skippedCount++;
                continue;
            }

            if (EditorSpriteSaveInfo.CreateFolderAtlas(folderPath, true))
            {
                createdCount++;
                recordedFolders.Add(folderPath);
            }
            else
                skippedCount++;
        }

        int addedDirectoryCount = EditorSpriteSaveInfo.AddAtlasScanDirectories(recordedFolders);
        if (createdCount > 0)
            UnityEditor.U2D.SpriteAtlasUtility.PackAllAtlases(EditorUserBuildSettings.activeBuildTarget);

        if (emptyFolders.Count > 0)
        {
            string folderList = string.Join("\n", emptyFolders);
            EditorUtility.DisplayDialog("未生成图集", $"以下文件夹中没有任何Sprite，未执行图集生成，也未加入扫描目录：\n\n{folderList}", "确定");
        }

        Debug.Log($"右键文件夹生成图集完成：生成={createdCount}，空目录跳过={emptyFolders.Count}，已存在/失败={skippedCount}，低于门槛跳过={belowThresholdCount}，新增扫描目录={addedDirectoryCount}");
    }

    [MenuItem(MenuPath, true)]
    private static bool ValidateCreateAtlasesFromSelectedFolders()
    {
        return GetSelectedFolderPaths().Count > 0;
    }

    private static List<string> GetSelectedFolderPaths()
    {
        var paths = new HashSet<string>(StringComparer.Ordinal);
        foreach (var guid in Selection.assetGUIDs)
        {
            var path = AssetDatabase.GUIDToAssetPath(guid)?.Replace("\\", "/");
            if (AssetDatabase.IsValidFolder(path) && path != "Assets")
                paths.Add(path);
        }

        var result = new List<string>(paths);
        result.Sort(StringComparer.Ordinal);
        return result;
    }
}
