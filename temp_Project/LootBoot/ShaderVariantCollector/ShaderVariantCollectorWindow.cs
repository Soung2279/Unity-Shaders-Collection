#if UNITY_2019_4_OR_NEWER
using System;
using System.Linq;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
using YooAsset.Editor;

public class ShaderVariantCollectorWindow : EditorWindow
{
    [MenuItem("Tools/着色器变种收集器", false, 100)]
    public static void OpenWindow()
    {
        ShaderVariantCollectorWindow window = GetWindow<ShaderVariantCollectorWindow>("着色器变种收集工具", true);
        window.minSize = new Vector2(800, 600);
    }

    private Button _collectButton;
    private TextField _collectOutputField;
    private Label _currentShaderCountField;
    private Label _currentVariantCountField;
    private SliderInt _processCapacitySlider;
    private PopupField<string> _packageField;
    private Label _historySummary;
    private ScrollView _historyDetails;
    private Button _refreshHistoryButton;
    private Button _restoreHistoryButton;
    private Button _pingHistoryButton;

    private List<string> _packageNames;
    private string _currentPackageName;

    public void CreateGUI()
    {
        try
        {
            VisualElement root = this.rootVisualElement;
            root.Clear();
            root.style.flexGrow = 1;

            var visualAsset = UxmlLoader.LoadWindowUXML<ShaderVariantCollectorWindow>();
            if (visualAsset == null)
                return;

            visualAsset.CloneTree(root);

            // 包裹名称列表
            _packageNames = GetBuildPackageNames();
            _currentPackageName = _packageNames[0];

            // 文件输出目录
            _collectOutputField = root.Q<TextField>("CollectOutput");
            _collectOutputField.SetValueWithoutNotify(ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName));
            _collectOutputField.RegisterValueChangedCallback(evt =>
            {
                ShaderVariantCollectorSetting.SetFileSavePath(_currentPackageName, _collectOutputField.value);
                RefreshHistory();
            });

            // 收集的包裹
            var packageContainer = root.Q("PackageContainer");
            if (_packageNames.Count > 0)
            {
                int defaultIndex = GetDefaultPackageIndex(_currentPackageName);
                _packageField = new PopupField<string>(_packageNames, defaultIndex);
                _packageField.label = "Package";
                _packageField.style.width = 350;
                _packageField.RegisterValueChangedCallback(evt =>
                {
                    _currentPackageName = _packageField.value;
                    _collectOutputField.SetValueWithoutNotify(ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName));
                    _processCapacitySlider.SetValueWithoutNotify(ShaderVariantCollectorSetting.GeProcessCapacity(_currentPackageName));
                    RefreshHistory();
                });
                packageContainer.Add(_packageField);
            }
            else
            {
                _packageField = new PopupField<string>();
                _packageField.label = "Package";
                _packageField.style.width = 350;
                packageContainer.Add(_packageField);
            }

            // 容器值
            _processCapacitySlider = root.Q<SliderInt>("ProcessCapacity");
            _processCapacitySlider.SetValueWithoutNotify(ShaderVariantCollectorSetting.GeProcessCapacity(_currentPackageName));
#if !UNITY_2020_3_OR_NEWER
            _processCapacitySlider.label = $"Capacity ({_processCapacitySlider.value})";
            _processCapacitySlider.RegisterValueChangedCallback(evt =>
            {
                ShaderVariantCollectorSetting.SetProcessCapacity(_currentPackageName, _processCapacitySlider.value);
                _processCapacitySlider.label = $"Capacity ({_processCapacitySlider.value})";
            });
#else
            _processCapacitySlider.RegisterValueChangedCallback(evt =>
            {
                ShaderVariantCollectorSetting.SetProcessCapacity(_currentPackageName, _processCapacitySlider.value);
            });
#endif

            _currentShaderCountField = root.Q<Label>("CurrentShaderCount");
            _currentVariantCountField = root.Q<Label>("CurrentVariantCount");

            // 变种收集按钮
            _collectButton = root.Q<Button>("CollectButton");
            _collectButton.clicked += CollectButton_clicked;

            _historySummary = root.Q<Label>("HistorySummary");
            _historyDetails = root.Q<ScrollView>("HistoryDetails");
            _refreshHistoryButton = root.Q<Button>("RefreshHistoryButton");
            _restoreHistoryButton = root.Q<Button>("RestoreHistoryButton");
            _pingHistoryButton = root.Q<Button>("PingHistoryButton");
            _refreshHistoryButton.clicked += RefreshManifestFromCollection;
            _restoreHistoryButton.clicked += RestorePreviousCollection;
            _pingHistoryButton.clicked += PingHistoryFile;
            RefreshHistory();
        }
        catch (Exception e)
        {
            Debug.LogError(e.ToString());
        }
    }
    private void Update()
    {
        if (_currentShaderCountField != null)
        {
            int currentShaderCount = ShaderVariantCollectionHelper.GetCurrentShaderVariantCollectionShaderCount();
            _currentShaderCountField.text = $"全局记录器 · Shader {currentShaderCount}";
        }

        if (_currentVariantCountField != null)
        {
            int currentVariantCount = ShaderVariantCollectionHelper.GetCurrentShaderVariantCollectionVariantCount();
            _currentVariantCountField.text = $"Variant {currentVariantCount}（非最终写入数）";
        }
    }

    private void CollectButton_clicked()
    {
        string savePath = ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName);
        int processCapacity = _processCapacitySlider.value;
        ShaderVariantCollector.Run(savePath, _currentPackageName, processCapacity, RefreshHistory);
    }

    private void RefreshManifestFromCollection()
    {
        if (string.IsNullOrEmpty(_currentPackageName))
            return;

        string collectionPath = ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName);
        if (ShaderVariantCollectionHistory.SyncManifestFromCollection(collectionPath, out string message))
        {
            ShowNotification(new GUIContent(message));
            RefreshHistory();
        }
        else
        {
            EditorUtility.DisplayDialog("刷新失败", message, "确定");
            RefreshHistory();
        }
    }

    private void RefreshHistory()
    {
        if (_historySummary == null || _historyDetails == null || string.IsNullOrEmpty(_currentPackageName))
            return;

        _historyDetails.Clear();
        string collectionPath = ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName);
        ShaderVariantCollectionHistory.HistoryEntry entry = ShaderVariantCollectionHistory.GetLatest(collectionPath);
        if (entry == null)
        {
            _historySummary.text = $"暂无历史记录\n{ShaderVariantCollectionHistory.GetHistoryPath(collectionPath)}";
            _restoreHistoryButton?.SetEnabled(false);
            AddHistoryLabel("完成一次收集后，这里会显示与上一次SVC的差异。", false);
            return;
        }

        _restoreHistoryButton?.SetEnabled(ShaderVariantCollectionHistory.CanRestorePrevious(collectionPath, out _));

        _historySummary.text =
            $"时间：{entry.CollectedAt}    Package：{entry.PackageName}\n" +
            $"Shader：{entry.PreviousShaderCount} → {entry.CurrentShaderCount} ({FormatDelta(entry.ShaderCountDelta)})    " +
            $"Variant：{entry.PreviousVariantCount} → {entry.CurrentVariantCount} ({FormatDelta(entry.VariantCountDelta)})\n" +
            $"新增 Shader {entry.AddedShaders.Count}，移除 Shader {entry.RemovedShaders.Count}，" +
            $"新增变体 {entry.AddedVariants.Count}，移除变体 {entry.RemovedVariants.Count}";

        AddDiffSection(true, entry.AddedShaders, entry.AddedVariants);
        AddDiffSection(false, entry.RemovedShaders, entry.RemovedVariants);
        if (!entry.HadPreviousCollection)
            AddHistoryLabel("首次基线：本条记录从空集合建立，不代表本次新增了全部功能。", false);
    }

    [SerializeField] private bool _addedExpanded = true;
    [SerializeField] private bool _removedExpanded = true;

    private void AddDiffSection(bool added, List<string> shaders,
        List<ShaderVariantCollectionHistory.VariantChange> variants)
    {
        shaders = shaders ?? new List<string>();
        variants = variants ?? new List<ShaderVariantCollectionHistory.VariantChange>();
        string sign = added ? "+" : "−";
        var color = added
            ? (EditorGUIUtility.isProSkin ? new Color(0.45f, 0.88f, 0.58f) : new Color(0.08f, 0.40f, 0.18f))
            : (EditorGUIUtility.isProSkin ? new Color(1f, 0.52f, 0.52f) : new Color(0.70f, 0.12f, 0.12f));
        var foldout = new Foldout
        {
            text = $"{sign} {(added ? "新增" : "移除")}   ·   {shaders.Count} Shader / {variants.Count} 变体",
            value = added ? _addedExpanded : _removedExpanded,
            name = added ? "AddedDiff" : "RemovedDiff"
        };
        foldout.style.color = color;
        foldout.style.marginBottom = 10;
        foldout.RegisterValueChangedCallback(evt =>
        {
            if (added) _addedExpanded = evt.newValue;
            else _removedExpanded = evt.newValue;
        });
        _historyDetails.Add(foldout);
        if (shaders.Count == 0 && variants.Count == 0)
            AddDiffRow(foldout, "无变化", color, false);
        foreach (string shader in shaders)
            AddDiffRow(foldout, $"{sign} Shader  {shader}", color, true);
        foreach (var group in variants.GroupBy(v => new { v.AssetPath, v.ShaderName }))
        {
            AddDiffRow(foldout, $"@@ {group.Key.ShaderName}   ·   {group.Count()} 变体\n{group.Key.AssetPath}", color, true);
            foreach (var variant in group)
            {
                string keywords = variant.Keywords == null || variant.Keywords.Length == 0
                    ? "<无关键词>" : string.Join("  ", variant.Keywords);
                AddDiffRow(foldout, $"{sign} Pass {(UnityEngine.Rendering.PassType)variant.PassType} ({variant.PassType})\n    {keywords}", color, false);
            }
        }
    }

    private static void AddDiffRow(VisualElement parent, string text, Color color, bool header)
    {
        var label = new Label(text) { tooltip = text };
        label.style.whiteSpace = WhiteSpace.Normal;
        label.style.color = color;
        label.style.backgroundColor = new Color(color.r, color.g, color.b, header ? 0.15f : 0.07f);
        label.style.borderLeftWidth = 3;
        label.style.borderLeftColor = color;
        label.style.paddingLeft = 10;
        label.style.paddingRight = 8;
        label.style.paddingTop = 6;
        label.style.paddingBottom = 6;
        label.style.marginTop = header ? 6 : 1;
        if (header) label.style.unityFontStyleAndWeight = FontStyle.Bold;
        parent.Add(label);
    }

    private void AddHistoryLabel(string text, bool isHeader)
    {
        var label = new Label(text);
        label.style.whiteSpace = WhiteSpace.Normal;
        label.style.marginBottom = isHeader ? 3 : 6;
        if (isHeader)
        {
            label.style.unityFontStyleAndWeight = FontStyle.Bold;
            label.style.marginTop = 8;
        }
        _historyDetails.Add(label);
    }

    private void RestorePreviousCollection()
    {
        if (string.IsNullOrEmpty(_currentPackageName))
            return;

        string collectionPath = ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName);
        if (ShaderVariantCollectionHistory.CanRestorePrevious(collectionPath, out string reason) == false)
        {
            EditorUtility.DisplayDialog("无法还原", reason, "确定");
            RefreshHistory();
            return;
        }

        ShaderVariantCollectionHistory.HistoryEntry entry = ShaderVariantCollectionHistory.GetLatest(collectionPath);
        bool confirmed = EditorUtility.DisplayDialog(
            "还原到上一次收集",
            $"将把当前SVC还原为最新历史节点的上一次状态：\n\n" +
            $"Shader：{entry.CurrentShaderCount} → {entry.PreviousShaderCount}\n" +
            $"Variant：{entry.CurrentVariantCount} → {entry.PreviousVariantCount}\n\n" +
            "还原操作也会追加到历史记录。是否继续？",
            "还原",
            "取消");
        if (confirmed == false)
            return;

        if (ShaderVariantCollectionHistory.RestorePrevious(collectionPath, out string message))
        {
            ShowNotification(new GUIContent(message));
            RefreshHistory();
        }
        else
        {
            EditorUtility.DisplayDialog("还原失败", message, "确定");
            RefreshHistory();
        }
    }

    private void PingHistoryFile()
    {
        if (string.IsNullOrEmpty(_currentPackageName))
            return;
        string collectionPath = ShaderVariantCollectorSetting.GeFileSavePath(_currentPackageName);
        string historyPath = ShaderVariantCollectionHistory.GetHistoryPath(collectionPath);
        UnityEngine.Object historyAsset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(historyPath);
        if (historyAsset != null)
        {
            EditorGUIUtility.PingObject(historyAsset);
            Selection.activeObject = historyAsset;
        }
        else
        {
            ShowNotification(new GUIContent("尚未生成历史文件"));
        }
    }

    private static string FormatDelta(int delta)
    {
        return delta > 0 ? $"+{delta}" : delta.ToString();
    }

    // 构建包裹相关
    private int GetDefaultPackageIndex(string packageName)
    {
        for (int index = 0; index < _packageNames.Count; index++)
        {
            if (_packageNames[index] == packageName)
            {
                return index;
            }
        }
        return 0;
    }
    private List<string> GetBuildPackageNames()
    {
        List<string> result = new List<string>();
        foreach (var package in AssetBundleCollectorSettingData.Setting.Packages)
        {
            result.Add(package.PackageName);
        }
        return result;
    }
}
#endif