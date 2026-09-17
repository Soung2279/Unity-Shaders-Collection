using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public static class ShaderVariantCollectionHistory
{
    [Serializable]
    private class HistoryFile
    {
        public List<HistoryEntry> Entries = new List<HistoryEntry>();
    }

    [Serializable]
    public class HistoryEntry
    {
        public string CollectedAt;
        public string PackageName;
        public bool HadPreviousCollection;
        public int PreviousShaderCount;
        public int CurrentShaderCount;
        public int ShaderCountDelta;
        public int PreviousVariantCount;
        public int CurrentVariantCount;
        public int VariantCountDelta;
        public List<string> AddedShaders = new List<string>();
        public List<string> RemovedShaders = new List<string>();
        public List<VariantChange> AddedVariants = new List<VariantChange>();
        public List<VariantChange> RemovedVariants = new List<VariantChange>();
    }

    [Serializable]
    public class VariantChange
    {
        public string AssetPath;
        public string ShaderName;
        public int PassType;
        public string[] Keywords;
    }

    private class VariantSnapshot
    {
        public string AssetPath;
        public string ShaderName;
        public int PassType;
        public string[] Keywords;
    }

    public static bool SyncManifestFromCollection(string collectionPath, out string message)
    {
        if (Path.HasExtension(collectionPath) == false)
            collectionPath = $"{collectionPath}.shadervariants";

        ShaderVariantCollection collection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(collectionPath);
        if (collection == null)
        {
            message = $"未找到Shader变体集：{collectionPath}";
            return false;
        }

        try
        {
            ShaderVariantCollectionManifest manifest = ShaderVariantCollectionManifest.Extract(collection);
            WriteManifest(collectionPath, manifest);
            message = $"已从当前SVC刷新记录：{manifest.ShaderTotalCount} Shader / {manifest.VariantTotalCount} Variant。";
            Debug.Log($"{message}\n{Path.ChangeExtension(collectionPath, ".json")}");
            return true;
        }
        catch (Exception exception)
        {
            message = $"刷新Shader变体记录失败：{exception.Message}";
            Debug.LogError(message);
            return false;
        }
    }

    public static bool CanRestorePrevious(string collectionPath, out string reason)
    {
        HistoryEntry entry = GetLatest(collectionPath);
        if (entry == null)
        {
            reason = "没有可用的历史记录。";
            return false;
        }
        if (entry.HadPreviousCollection == false)
        {
            reason = "最新历史是首次基线，没有更早的收集结果。";
            return false;
        }
        ShaderVariantCollection collection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(collectionPath);
        if (collection == null)
        {
            reason = "当前SVC文件不存在。";
            return false;
        }

        ShaderVariantCollectionManifest currentManifest = ShaderVariantCollectionManifest.Extract(collection);
        if (currentManifest.ShaderTotalCount != entry.CurrentShaderCount
            || currentManifest.VariantTotalCount != entry.CurrentVariantCount)
        {
            reason = $"当前SVC与最新历史节点不一致：历史为 {entry.CurrentShaderCount} Shader / {entry.CurrentVariantCount} Variant，当前为 {currentManifest.ShaderTotalCount} Shader / {currentManifest.VariantTotalCount} Variant。";
            return false;
        }

        reason = null;
        return true;
    }

    public static bool RestorePrevious(string collectionPath, out string message)
    {
        if (CanRestorePrevious(collectionPath, out message) == false)
            return false;

        HistoryEntry entry = GetLatest(collectionPath);
        ShaderVariantCollection collection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(collectionPath);
        ShaderVariantCollectionManifest currentManifest = ShaderVariantCollectionManifest.Extract(collection);
        if (currentManifest.ShaderTotalCount != entry.CurrentShaderCount
            || currentManifest.VariantTotalCount != entry.CurrentVariantCount)
        {
            message = $"当前SVC与最新历史节点不一致，已取消还原。历史节点为 {entry.CurrentShaderCount} Shader / {entry.CurrentVariantCount} Variant，当前为 {currentManifest.ShaderTotalCount} Shader / {currentManifest.VariantTotalCount} Variant。";
            return false;
        }

        var variantsToRemove = BuildShaderVariants(entry.AddedVariants, out message);
        if (variantsToRemove == null)
            return false;
        var variantsToAdd = BuildShaderVariants(entry.RemovedVariants, out message);
        if (variantsToAdd == null)
            return false;

        if (variantsToRemove.Any(variant => collection.Contains(variant) == false)
            || variantsToAdd.Any(variant => collection.Contains(variant)))
        {
            message = "当前SVC的变体内容与最新历史节点不一致，已取消还原。";
            return false;
        }

        Undo.RecordObject(collection, "还原到上一次变体收集");
        foreach (var variant in variantsToRemove)
            collection.Remove(variant);
        foreach (var variant in variantsToAdd)
            collection.Add(variant);

        EditorUtility.SetDirty(collection);
        AssetDatabase.SaveAssets();
        AssetDatabase.ImportAsset(collectionPath, ImportAssetOptions.ForceUpdate);

        ShaderVariantCollection restoredCollection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(collectionPath);
        ShaderVariantCollectionManifest restoredManifest = ShaderVariantCollectionManifest.Extract(restoredCollection);
        if (restoredManifest.ShaderTotalCount != entry.PreviousShaderCount
            || restoredManifest.VariantTotalCount != entry.PreviousVariantCount)
        {
            message = $"还原后的数量与历史目标不一致：目标 {entry.PreviousShaderCount} Shader / {entry.PreviousVariantCount} Variant，实际 {restoredManifest.ShaderTotalCount} Shader / {restoredManifest.VariantTotalCount} Variant。";
            Debug.LogError(message);
            return false;
        }

        WriteManifest(collectionPath, restoredManifest);
        Record(collectionPath, "Restore", currentManifest, restoredManifest);
        message = $"已还原到上一次收集：{restoredManifest.ShaderTotalCount} Shader / {restoredManifest.VariantTotalCount} Variant。";
        return true;
    }

    private static List<ShaderVariantCollection.ShaderVariant> BuildShaderVariants(
        IEnumerable<VariantChange> changes, out string error)
    {
        var result = new List<ShaderVariantCollection.ShaderVariant>();
        foreach (VariantChange change in changes ?? Enumerable.Empty<VariantChange>())
        {
            Shader shader = AssetDatabase.LoadAssetAtPath<Shader>(change.AssetPath);
            if (shader == null)
                shader = Shader.Find(change.ShaderName);
            if (shader == null)
            {
                error = $"无法加载历史变体的Shader：{change.ShaderName} ({change.AssetPath})";
                return null;
            }

            try
            {
                result.Add(new ShaderVariantCollection.ShaderVariant(
                    shader,
                    (UnityEngine.Rendering.PassType)change.PassType,
                    NormalizeKeywords(change.Keywords)));
            }
            catch (Exception exception)
            {
                error = $"无法还原历史变体：{FormatVariant(change)}\n{exception.Message}";
                return null;
            }
        }

        error = null;
        return result;
    }

    private static void WriteManifest(string collectionPath, ShaderVariantCollectionManifest manifest)
    {
        string manifestPath = Path.ChangeExtension(collectionPath, ".json");
        File.WriteAllText(manifestPath, JsonUtility.ToJson(manifest, true));
        AssetDatabase.ImportAsset(manifestPath, ImportAssetOptions.ForceUpdate);
    }

    public static HistoryEntry GetLatest(string collectionPath)
    {
        string historyPath = Path.ChangeExtension(collectionPath, ".history.json");
        HistoryFile history = LoadHistory(historyPath);
        if (history.Entries == null || history.Entries.Count == 0)
            return null;
        return history.Entries[history.Entries.Count - 1];
    }

    public static string GetHistoryPath(string collectionPath)
    {
        return Path.ChangeExtension(collectionPath, ".history.json");
    }

    public static string FormatVariant(VariantChange change)
    {
        string keywords = change.Keywords == null || change.Keywords.Length == 0
            ? "<无关键词>"
            : string.Join(" ", change.Keywords);
        return $"{change.ShaderName} | Pass {(UnityEngine.Rendering.PassType)change.PassType} | {keywords}\n{change.AssetPath}";
    }

    public static void Record(
        string collectionPath,
        string packageName,
        ShaderVariantCollectionManifest previousManifest,
        ShaderVariantCollectionManifest currentManifest)
    {
        if (currentManifest == null)
            throw new ArgumentNullException(nameof(currentManifest));

        string historyPath = Path.ChangeExtension(collectionPath, ".history.json");
        HistoryFile history = LoadHistory(historyPath);
        HistoryEntry entry = CreateEntry(packageName, previousManifest, currentManifest);
        history.Entries.Add(entry);

        string directory = Path.GetDirectoryName(historyPath);
        if (string.IsNullOrEmpty(directory) == false)
            Directory.CreateDirectory(directory);

        File.WriteAllText(historyPath, JsonUtility.ToJson(history, true));
        AssetDatabase.ImportAsset(historyPath, ImportAssetOptions.ForceUpdate);

        Debug.Log(
            $"SVC历史记录已更新：{historyPath}\n" +
            $"Shader {entry.PreviousShaderCount} -> {entry.CurrentShaderCount} ({FormatDelta(entry.ShaderCountDelta)})，" +
            $"Variant {entry.PreviousVariantCount} -> {entry.CurrentVariantCount} ({FormatDelta(entry.VariantCountDelta)})，" +
            $"新增变体 {entry.AddedVariants.Count}，移除变体 {entry.RemovedVariants.Count}。");
    }

    private static HistoryFile LoadHistory(string historyPath)
    {
        if (File.Exists(historyPath) == false)
            return new HistoryFile();

        try
        {
            HistoryFile history = JsonUtility.FromJson<HistoryFile>(File.ReadAllText(historyPath));
            if (history == null)
                history = new HistoryFile();
            if (history.Entries == null)
                history.Entries = new List<HistoryEntry>();
            return history;
        }
        catch (Exception exception)
        {
            Debug.LogWarning($"读取SVC历史记录失败，将创建新的历史文件：{exception.Message}");
            return new HistoryFile();
        }
    }

    private static HistoryEntry CreateEntry(
        string packageName,
        ShaderVariantCollectionManifest previousManifest,
        ShaderVariantCollectionManifest currentManifest)
    {
        bool hadPreviousCollection = previousManifest != null;
        var previousVariants = BuildVariantMap(previousManifest);
        var currentVariants = BuildVariantMap(currentManifest);
        var previousShaders = BuildShaderMap(previousManifest);
        var currentShaders = BuildShaderMap(currentManifest);

        var entry = new HistoryEntry
        {
            CollectedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            PackageName = packageName,
            HadPreviousCollection = hadPreviousCollection,
            PreviousShaderCount = previousManifest?.ShaderTotalCount ?? 0,
            CurrentShaderCount = currentManifest.ShaderTotalCount,
            PreviousVariantCount = previousManifest?.VariantTotalCount ?? 0,
            CurrentVariantCount = currentManifest.VariantTotalCount,
        };
        entry.ShaderCountDelta = entry.CurrentShaderCount - entry.PreviousShaderCount;
        entry.VariantCountDelta = entry.CurrentVariantCount - entry.PreviousVariantCount;

        entry.AddedShaders = currentShaders.Keys
            .Except(previousShaders.Keys)
            .Select(key => FormatShader(currentShaders[key]))
            .OrderBy(value => value, StringComparer.Ordinal)
            .ToList();
        entry.RemovedShaders = previousShaders.Keys
            .Except(currentShaders.Keys)
            .Select(key => FormatShader(previousShaders[key]))
            .OrderBy(value => value, StringComparer.Ordinal)
            .ToList();
        entry.AddedVariants = currentVariants.Keys
            .Except(previousVariants.Keys)
            .Select(key => ToChange(currentVariants[key]))
            .OrderBy(GetSortKey, StringComparer.Ordinal)
            .ToList();
        entry.RemovedVariants = previousVariants.Keys
            .Except(currentVariants.Keys)
            .Select(key => ToChange(previousVariants[key]))
            .OrderBy(GetSortKey, StringComparer.Ordinal)
            .ToList();

        return entry;
    }

    private static Dictionary<string, ShaderVariantCollectionManifest.ShaderVariantInfo> BuildShaderMap(
        ShaderVariantCollectionManifest manifest)
    {
        if (manifest == null || manifest.ShaderVariantInfos == null)
            return new Dictionary<string, ShaderVariantCollectionManifest.ShaderVariantInfo>(StringComparer.Ordinal);

        return manifest.ShaderVariantInfos.ToDictionary(
            info => MakeShaderKey(info.AssetPath, info.ShaderName),
            info => info,
            StringComparer.Ordinal);
    }

    private static Dictionary<string, VariantSnapshot> BuildVariantMap(ShaderVariantCollectionManifest manifest)
    {
        var result = new Dictionary<string, VariantSnapshot>(StringComparer.Ordinal);
        if (manifest == null || manifest.ShaderVariantInfos == null)
            return result;

        foreach (var shaderInfo in manifest.ShaderVariantInfos)
        {
            if (shaderInfo.ShaderVariantElements == null)
                continue;

            foreach (var variant in shaderInfo.ShaderVariantElements)
            {
                string[] keywords = NormalizeKeywords(variant.Keywords);
                var snapshot = new VariantSnapshot
                {
                    AssetPath = shaderInfo.AssetPath,
                    ShaderName = shaderInfo.ShaderName,
                    PassType = (int)variant.PassType,
                    Keywords = keywords,
                };
                result[MakeVariantKey(snapshot)] = snapshot;
            }
        }
        return result;
    }

    private static VariantChange ToChange(VariantSnapshot snapshot)
    {
        return new VariantChange
        {
            AssetPath = snapshot.AssetPath,
            ShaderName = snapshot.ShaderName,
            PassType = snapshot.PassType,
            Keywords = snapshot.Keywords,
        };
    }

    private static string[] NormalizeKeywords(IEnumerable<string> keywords)
    {
        return (keywords ?? Enumerable.Empty<string>())
            .Where(keyword => string.IsNullOrEmpty(keyword) == false)
            .Distinct()
            .OrderBy(keyword => keyword, StringComparer.Ordinal)
            .ToArray();
    }

    private static string MakeVariantKey(VariantSnapshot snapshot)
    {
        return $"{MakeShaderKey(snapshot.AssetPath, snapshot.ShaderName)}|{snapshot.PassType}|{string.Join(" ", snapshot.Keywords)}";
    }

    private static string MakeShaderKey(string assetPath, string shaderName)
    {
        return $"{assetPath}|{shaderName}";
    }

    private static string FormatShader(ShaderVariantCollectionManifest.ShaderVariantInfo info)
    {
        return $"{info.ShaderName} ({info.AssetPath})";
    }

    private static string GetSortKey(VariantChange change)
    {
        return $"{change.AssetPath}|{change.ShaderName}|{change.PassType}|{string.Join(" ", change.Keywords ?? new string[0])}";
    }

    private static string FormatDelta(int delta)
    {
        return delta > 0 ? $"+{delta}" : delta.ToString();
    }
}
