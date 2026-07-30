using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using UnityEditor;
using UnityEngine;

namespace GameFramework.Editor
{
    public class BatchAudioImportSettingsWindow : EditorWindow
    {
        private const string DefaultAudioRoot = "Assets/GameAsset/Audio";
        private const string SoundConfigPath = "Assets/GameAsset/Config/Tables/json/Sound.json";
        private const float StreamingMinSeconds = 10f;
        private const float FrequentMaxSeconds = 1.5f;
        private const float MusicVorbisQuality = 0.65f;
        private const float SfxVorbisQuality = 0.5f;
        private const float ResultListHeight = 360f;

        private static readonly HashSet<string> FrequentSoundNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "ui_click_tab_new",
            "gen_troop_step_01",
            "player_run",
            "player_attack_sword_1_new",
            "player_t01_attack_sword_1",
            "player_t01_attack_sword_2",
            "player_t02_attack_sword_1",
            "player_attack_bow_1",
            "player_attack_bow_4",
            "eft_arrow_attack",
            "eft_blow_common",
            "eft_rebound_common"
        };

        [SerializeField] private DefaultAsset audioRoot;
        [SerializeField] private string audioRootPath = DefaultAudioRoot;
        [SerializeField] private Vector2 resultScrollPosition;

        private readonly List<AudioImportItem> results = new List<AudioImportItem>();

        private enum AudioCategory
        {
            StreamingMusic,
            FrequentLowLatency,
            CompressedSfx
        }

        [Serializable]
        private sealed class SoundConfigEntry
        {
            public string AssetName;
            public int SoundGroupId;
            public bool Loop;
            public float SpatialBlend;
        }

        private sealed class AudioImportItem
        {
            public string path;
            public float lengthSeconds;
            public int channels;
            public bool hasConfig;
            public int soundGroupId;
            public AudioCategory category;
            public AudioImporterSampleSettings currentAndroidSettings;
            public AudioImporterSampleSettings currentIosSettings;
            public AudioImporterSampleSettings targetSettings;
            public bool currentForceToMono;
            public bool targetForceToMono;
            public bool selected;

            public bool NeedsChange =>
                !SampleSettingsEqual(currentAndroidSettings, targetSettings) ||
                !SampleSettingsEqual(currentIosSettings, targetSettings) ||
                currentForceToMono != targetForceToMono;
        }

        [MenuItem("Game Framework/Audio/批量设置音频导入", false, 94)]
        public static void OpenWindow()
        {
            var window = GetWindow<BatchAudioImportSettingsWindow>("批量音频导入设置");
            window.minSize = new Vector2(900f, 600f);
            window.Show();
        }

        private void OnEnable()
        {
            if (audioRoot == null && AssetDatabase.IsValidFolder(audioRootPath))
                audioRoot = AssetDatabase.LoadAssetAtPath<DefaultAsset>(audioRootPath);
        }

        private void OnGUI()
        {
            EditorGUILayout.Space(6f);
            DrawRules();
            EditorGUILayout.Space(8f);
            DrawScanRoot();
            EditorGUILayout.Space(8f);
            DrawResults();
            EditorGUILayout.Space(6f);
            DrawBottomButtons();
        }

        private static void DrawRules()
        {
            EditorGUILayout.LabelField("iOS / Android 分类规则", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(
                "分类依据优先读取 Sound.json：\n" +
                "1. Music 组或循环音频，且时长 ≥ 10 秒 → Streaming + Vorbis，Quality 0.65\n" +
                "2. 高频白名单且时长 ≤ 1.5 秒 → Decompress On Load + ADPCM\n" +
                "3. 其他音效 → Compressed In Memory + Vorbis，Quality 0.50\n\n" +
                "工具写入 Android 与 iOS 平台覆盖，保留默认平台设置与 Preload。" +
                "明确 3D 或左右声道完全相同的音效会启用 Force To Mono。" +
                "未出现在 Sound.json 的资源仅显示审计结果，不会默认勾选应用。",
                MessageType.Info);
        }

        private void DrawScanRoot()
        {
            EditorGUILayout.LabelField("扫描目录", EditorStyles.boldLabel);
            EditorGUI.BeginChangeCheck();
            var newRoot = (DefaultAsset)EditorGUILayout.ObjectField("Audio 根目录", audioRoot, typeof(DefaultAsset), false);
            if (EditorGUI.EndChangeCheck())
            {
                var newPath = newRoot == null ? string.Empty : AssetDatabase.GetAssetPath(newRoot);
                if (newRoot == null || AssetDatabase.IsValidFolder(newPath))
                {
                    audioRoot = newRoot;
                    audioRootPath = newPath;
                    results.Clear();
                }
                else
                {
                    EditorUtility.DisplayDialog("批量音频导入设置", "请选择项目中的文件夹。", "确定");
                }
            }

            if (!string.IsNullOrEmpty(audioRootPath))
                EditorGUILayout.LabelField(audioRootPath, EditorStyles.miniLabel);
        }

        private void DrawResults()
        {
            EditorGUILayout.LabelField("扫描结果", EditorStyles.boldLabel);
            if (results.Count == 0)
            {
                EditorGUILayout.LabelField("尚未扫描。", EditorStyles.miniLabel);
                return;
            }

            var selectedCount = results.Count(item => item.selected && item.hasConfig);
            var changedCount = results.Count(item => item.hasConfig && item.NeedsChange);
            var unconfiguredCount = results.Count(item => !item.hasConfig);
            EditorGUILayout.LabelField($"Audio Clip: {results.Count}，可应用修改: {changedCount}，已选择: {selectedCount}，未配置: {unconfiguredCount}");

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("仅选需修改", GUILayout.Width(90f)))
                SetSelection(item => item.hasConfig && item.NeedsChange);
            if (GUILayout.Button("全选", GUILayout.Width(60f)))
                SetSelection(item => item.hasConfig);
            if (GUILayout.Button("全不选", GUILayout.Width(70f)))
                SetSelection(item => false);
            GUILayout.FlexibleSpace();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            GUILayout.Label("应用", GUILayout.Width(42f));
            GUILayout.Label("Audio Clip", GUILayout.MinWidth(250f));
            GUILayout.Label("时长", GUILayout.Width(58f));
            GUILayout.Label("声道", GUILayout.Width(42f));
            GUILayout.Label("配置", GUILayout.Width(72f));
            GUILayout.Label("分类", GUILayout.Width(110f));
            GUILayout.Label("Android 当前", GUILayout.Width(195f));
            GUILayout.Label("iOS 当前", GUILayout.Width(195f));
            GUILayout.Label("目标", GUILayout.Width(195f));
            GUILayout.Label("Mono", GUILayout.Width(48f));
            EditorGUILayout.EndHorizontal();

            resultScrollPosition = EditorGUILayout.BeginScrollView(resultScrollPosition, GUILayout.Height(ResultListHeight));
            foreach (var item in results)
                DrawResultRow(item);
            EditorGUILayout.EndScrollView();
        }

        private static void DrawResultRow(AudioImportItem item)
        {
            EditorGUILayout.BeginHorizontal();
            using (new EditorGUI.DisabledScope(!item.hasConfig))
                item.selected = EditorGUILayout.Toggle(item.selected, GUILayout.Width(42f));

            var pathContent = new GUIContent(item.path, item.path);
            if (GUILayout.Button(pathContent, EditorStyles.label, GUILayout.MinWidth(250f)))
                PingAsset(item.path);

            GUILayout.Label($"{item.lengthSeconds:F2}s", GUILayout.Width(58f));
            GUILayout.Label(item.channels.ToString(), GUILayout.Width(42f));
            GUILayout.Label(item.hasConfig ? $"G{item.soundGroupId}" : "未配置", GUILayout.Width(72f));
            GUILayout.Label(GetCategoryLabel(item.category), GUILayout.Width(110f));
            GUILayout.Label(FormatSetting(item.currentAndroidSettings), GUILayout.Width(195f));
            GUILayout.Label(FormatSetting(item.currentIosSettings), GUILayout.Width(195f));
            GUILayout.Label(FormatSetting(item.targetSettings), GUILayout.Width(195f));
            GUILayout.Label(item.targetForceToMono ? "是" : "否", GUILayout.Width(48f));
            EditorGUILayout.EndHorizontal();
        }

        private void DrawBottomButtons()
        {
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("扫描 Audio Clip", GUILayout.Height(34f), GUILayout.Width(140f)))
                ScanAudioClips();

            GUILayout.FlexibleSpace();

            using (new EditorGUI.DisabledScope(EditorApplication.isPlayingOrWillChangePlaymode || results.All(item => !item.selected)))
            {
                GUI.backgroundColor = new Color(0.4f, 0.8f, 0.4f);
                if (GUILayout.Button("应用到已选择资源", GUILayout.Height(34f), GUILayout.Width(170f)))
                    ApplySelectedSettings();
                GUI.backgroundColor = Color.white;
            }
            EditorGUILayout.EndHorizontal();

            if (EditorApplication.isPlayingOrWillChangePlaymode)
                EditorGUILayout.HelpBox("当前处于 Play Mode。可以扫描预览，但请退出 Play Mode 后再应用导入设置。", MessageType.Warning);
        }

        private void ScanAudioClips()
        {
            if (!AssetDatabase.IsValidFolder(audioRootPath))
            {
                EditorUtility.DisplayDialog("批量音频导入设置", "请先选择有效的 Audio 根目录。", "确定");
                return;
            }

            if (!TryLoadSoundConfig(out var soundConfigByName))
                return;

            results.Clear();
            var guids = AssetDatabase.FindAssets("t:AudioClip", new[] { audioRootPath });
            Array.Sort(guids, (left, right) => string.CompareOrdinal(
                AssetDatabase.GUIDToAssetPath(left), AssetDatabase.GUIDToAssetPath(right)));

            try
            {
                for (int i = 0; i < guids.Length; i++)
                {
                    var path = AssetDatabase.GUIDToAssetPath(guids[i]);
                    if (EditorUtility.DisplayCancelableProgressBar("扫描 Audio Clip", path, i / (float)guids.Length))
                        break;

                    var clip = AssetDatabase.LoadAssetAtPath<AudioClip>(path);
                    var importer = AssetImporter.GetAtPath(path) as AudioImporter;
                    if (clip == null || importer == null)
                        continue;

                    var assetName = Path.GetFileNameWithoutExtension(path);
                    soundConfigByName.TryGetValue(assetName, out var soundConfig);
                    var category = Classify(assetName, clip.length, soundConfig);
                    var targetSettings = CreateTargetSettings(category, importer.defaultSampleSettings);
                    var targetForceToMono = importer.forceToMono || ShouldForceToMono(path, clip, soundConfig);

                    var item = new AudioImportItem
                    {
                        path = path,
                        lengthSeconds = clip.length,
                        channels = clip.channels,
                        hasConfig = soundConfig != null,
                        soundGroupId = soundConfig?.SoundGroupId ?? 0,
                        category = category,
                        currentAndroidSettings = GetEffectivePlatformSettings(importer, "Android"),
                        currentIosSettings = GetEffectivePlatformSettings(importer, "iOS"),
                        targetSettings = targetSettings,
                        currentForceToMono = importer.forceToMono,
                        targetForceToMono = targetForceToMono
                    };
                    item.selected = item.hasConfig && item.NeedsChange;
                    results.Add(item);
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            Repaint();
        }

        private void ApplySelectedSettings()
        {
            var selectedItems = results.Where(item => item.selected && item.hasConfig).ToList();
            if (selectedItems.Count == 0)
                return;

            var streamingCount = selectedItems.Count(item => item.category == AudioCategory.StreamingMusic);
            var frequentCount = selectedItems.Count(item => item.category == AudioCategory.FrequentLowLatency);
            var compressedCount = selectedItems.Count(item => item.category == AudioCategory.CompressedSfx);
            var monoCount = selectedItems.Count(item => item.targetForceToMono);
            var confirmationMessage =
                $"将重新导入 {selectedItems.Count} 个 Audio Clip，并写入 Android / iOS 平台覆盖。\n\n" +
                "批量应用规则：\n" +
                $"• 长音乐/循环（Music 或 Loop，≥ {StreamingMinSeconds:F0}s）：Streaming + Vorbis，Quality {MusicVorbisQuality:F2}，保留采样率（{streamingCount} 个）\n" +
                $"• 高频白名单（≤ {FrequentMaxSeconds:F1}s）：Decompress On Load + ADPCM，优化采样率（{frequentCount} 个）\n" +
                $"• 其他已配置音效：Compressed In Memory + Vorbis，Quality {SfxVorbisQuality:F2}，优化采样率（{compressedCount} 个）\n" +
                $"• Force To Mono：明确 3D、左右声道完全相同或原本已启用（{monoCount} 个）\n\n" +
                "默认平台设置和 Preload Audio Data 保持不变。是否继续？";

            if (!EditorUtility.DisplayDialog(
                    "批量音频导入设置",
                    confirmationMessage,
                    "应用",
                    "取消"))
            {
                return;
            }

            var changedCount = 0;
            var processedCount = 0;
            try
            {
                for (int i = 0; i < selectedItems.Count; i++)
                {
                    var item = selectedItems[i];
                    if (EditorUtility.DisplayCancelableProgressBar("应用音频导入设置", item.path, i / (float)selectedItems.Count))
                        break;

                    var importer = AssetImporter.GetAtPath(item.path) as AudioImporter;
                    if (importer == null)
                        continue;

                    var settingsChanged =
                        !importer.ContainsSampleSettingsOverride("Android") ||
                        !importer.ContainsSampleSettingsOverride("iOS") ||
                        !SampleSettingsEqual(importer.GetOverrideSampleSettings("Android"), item.targetSettings) ||
                        !SampleSettingsEqual(importer.GetOverrideSampleSettings("iOS"), item.targetSettings);
                    var monoChanged = importer.forceToMono != item.targetForceToMono;
                    if (settingsChanged || monoChanged)
                    {
                        importer.SetOverrideSampleSettings("Android", item.targetSettings);
                        importer.SetOverrideSampleSettings("iOS", item.targetSettings);
                        importer.forceToMono = item.targetForceToMono;
                        importer.SaveAndReimport();
                        changedCount++;
                    }

                    processedCount++;
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            ScanAudioClips();
            Debug.Log($"批量音频导入设置完成：处理 {processedCount} 个，修改 {changedCount} 个。");
            EditorUtility.DisplayDialog("批量音频导入设置", $"完成。\n处理: {processedCount}\n修改: {changedCount}", "确定");
        }

        private static AudioCategory Classify(string assetName, float lengthSeconds, SoundConfigEntry soundConfig)
        {
            var isMusicOrLoop = soundConfig != null && (soundConfig.SoundGroupId == 1 || soundConfig.Loop);
            if (isMusicOrLoop && lengthSeconds >= StreamingMinSeconds)
                return AudioCategory.StreamingMusic;

            if (lengthSeconds <= FrequentMaxSeconds && FrequentSoundNames.Contains(assetName))
                return AudioCategory.FrequentLowLatency;

            return AudioCategory.CompressedSfx;
        }

        private static AudioImporterSampleSettings CreateTargetSettings(
            AudioCategory category,
            AudioImporterSampleSettings defaultSettings)
        {
            var settings = defaultSettings;
            settings.sampleRateSetting = category == AudioCategory.StreamingMusic
                ? AudioSampleRateSetting.PreserveSampleRate
                : AudioSampleRateSetting.OptimizeSampleRate;

            if (category == AudioCategory.StreamingMusic)
            {
                settings.loadType = AudioClipLoadType.Streaming;
                settings.compressionFormat = AudioCompressionFormat.Vorbis;
                settings.quality = MusicVorbisQuality;
            }
            else if (category == AudioCategory.FrequentLowLatency)
            {
                settings.loadType = AudioClipLoadType.DecompressOnLoad;
                settings.compressionFormat = AudioCompressionFormat.ADPCM;
            }
            else
            {
                settings.loadType = AudioClipLoadType.CompressedInMemory;
                settings.compressionFormat = AudioCompressionFormat.Vorbis;
                settings.quality = SfxVorbisQuality;
            }

            return settings;
        }

        private static bool TryLoadSoundConfig(out Dictionary<string, SoundConfigEntry> soundConfigByName)
        {
            soundConfigByName = new Dictionary<string, SoundConfigEntry>(StringComparer.OrdinalIgnoreCase);
            if (!File.Exists(SoundConfigPath))
            {
                EditorUtility.DisplayDialog("批量音频导入设置", $"声音配置不存在：\n{SoundConfigPath}", "确定");
                return false;
            }

            try
            {
                var entries = JsonConvert.DeserializeObject<Dictionary<string, SoundConfigEntry>>(
                    File.ReadAllText(SoundConfigPath));
                if (entries == null)
                    return true;

                foreach (var entry in entries.Values)
                {
                    if (entry == null || string.IsNullOrEmpty(entry.AssetName))
                        continue;
                    soundConfigByName[entry.AssetName] = entry;
                }

                return true;
            }
            catch (Exception exception)
            {
                EditorUtility.DisplayDialog("批量音频导入设置", $"Sound.json 解析失败：\n{exception.Message}", "确定");
                return false;
            }
        }

        private static AudioImporterSampleSettings GetEffectivePlatformSettings(AudioImporter importer, string platform)
        {
            return importer.ContainsSampleSettingsOverride(platform)
                ? importer.GetOverrideSampleSettings(platform)
                : importer.defaultSampleSettings;
        }

        private static bool ShouldForceToMono(string assetPath, AudioClip clip, SoundConfigEntry soundConfig)
        {
            if (clip.channels <= 1)
                return false;
            if (soundConfig != null && soundConfig.SpatialBlend > 0f)
                return true;
            return HasIdenticalStereoChannels(assetPath);
        }

        private static bool HasIdenticalStereoChannels(string assetPath)
        {
            var bytes = File.ReadAllBytes(Path.GetFullPath(assetPath));
            if (bytes.Length < 44 || ReadFourCc(bytes, 0) != "RIFF" || ReadFourCc(bytes, 8) != "WAVE")
                return false;

            var offset = 12;
            var channels = 0;
            var bitsPerSample = 0;
            var format = 0;
            var dataOffset = 0;
            var dataLength = 0;
            while (offset + 8 <= bytes.Length)
            {
                var chunkId = ReadFourCc(bytes, offset);
                var chunkLength = BitConverter.ToInt32(bytes, offset + 4);
                var chunkDataOffset = offset + 8;
                if (chunkLength < 0 || chunkDataOffset + chunkLength > bytes.Length)
                    return false;

                if (chunkId == "fmt " && chunkLength >= 16)
                {
                    format = BitConverter.ToUInt16(bytes, chunkDataOffset);
                    channels = BitConverter.ToUInt16(bytes, chunkDataOffset + 2);
                    bitsPerSample = BitConverter.ToUInt16(bytes, chunkDataOffset + 14);
                }
                else if (chunkId == "data")
                {
                    dataOffset = chunkDataOffset;
                    dataLength = chunkLength;
                }

                offset = chunkDataOffset + chunkLength + (chunkLength & 1);
            }

            if (format != 1 || channels != 2 || dataOffset == 0 || bitsPerSample % 8 != 0)
                return false;

            var bytesPerSample = bitsPerSample / 8;
            var frameSize = bytesPerSample * 2;
            for (int frameOffset = dataOffset; frameOffset + frameSize <= dataOffset + dataLength; frameOffset += frameSize)
            {
                for (int byteIndex = 0; byteIndex < bytesPerSample; byteIndex++)
                {
                    if (bytes[frameOffset + byteIndex] != bytes[frameOffset + bytesPerSample + byteIndex])
                        return false;
                }
            }

            return true;
        }

        private static string ReadFourCc(byte[] bytes, int offset)
        {
            return new string(new[]
            {
                (char)bytes[offset],
                (char)bytes[offset + 1],
                (char)bytes[offset + 2],
                (char)bytes[offset + 3]
            });
        }

        private static bool SampleSettingsEqual(
            AudioImporterSampleSettings left,
            AudioImporterSampleSettings right)
        {
            return left.loadType == right.loadType &&
                   left.compressionFormat == right.compressionFormat &&
                   Mathf.Approximately(left.quality, right.quality) &&
                   left.sampleRateSetting == right.sampleRateSetting &&
                   left.sampleRateOverride == right.sampleRateOverride;
        }

        private void SetSelection(Func<AudioImportItem, bool> selector)
        {
            foreach (var item in results)
                item.selected = selector(item);
        }

        private static void PingAsset(string assetPath)
        {
            var asset = AssetDatabase.LoadAssetAtPath<AudioClip>(assetPath);
            if (asset == null)
                return;

            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
        }

        private static string FormatSetting(AudioImporterSampleSettings settings)
        {
            var quality = settings.compressionFormat == AudioCompressionFormat.Vorbis
                ? $" Q{settings.quality:F2}"
                : string.Empty;
            return $"{settings.loadType} + {settings.compressionFormat}{quality}";
        }

        private static string GetCategoryLabel(AudioCategory category)
        {
            switch (category)
            {
                case AudioCategory.StreamingMusic:
                    return "长音乐/循环";
                case AudioCategory.FrequentLowLatency:
                    return "短高频低延迟";
                default:
                    return "普通压缩音效";
            }
        }
    }
}
