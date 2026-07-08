using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;

#if UNITY_EDITOR
namespace Game.Editor.VFXTools.Monitoring
{
public class RenderTextureUsageMonitorWindow : EditorWindow
{
    private const string MenuPath = "TATools/VFXTools/Monitoring/RenderTexture用量监控";
    private const int MaxHistory = 120;

    private readonly List<RenderTextureEntry> entries = new List<RenderTextureEntry>();
    private readonly List<float> totalHistory = new List<float>();
    private Vector2 scroll;
    private string nameFilter = "";
    private bool monitoring;
    private bool sortByMemory = true;
    private bool onlyCreated = true;
    private float updateInterval = 0.5f;
    private float nextUpdateTime;
    private long totalMemoryBytes;
    private int createdCount;

    [MenuItem(MenuPath, false, 140)]
    public static void Open()
    {
        var window = GetWindow<RenderTextureUsageMonitorWindow>("RT 用量监控");
        window.minSize = new Vector2(760f, 420f);
    }

    private void OnEnable()
    {
        EditorApplication.update += OnEditorUpdate;
    }

    private void OnDisable()
    {
        EditorApplication.update -= OnEditorUpdate;
    }

    private void OnEditorUpdate()
    {
        if (!monitoring) return;
        if (!EditorApplication.isPlaying)
        {
            monitoring = false;
            Repaint();
            return;
        }

        float now = (float)EditorApplication.timeSinceStartup;
        if (now < nextUpdateTime) return;
        nextUpdateTime = now + updateInterval;
        Collect();
        Repaint();
    }

    private void OnGUI()
    {
        EditorGUILayout.Space(4);
        EditorGUILayout.LabelField("运行时 RenderTexture 用量监控", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("进入 Play Mode 后实时扫描当前内存中的 RenderTexture，并使用 Profiler.GetRuntimeMemorySizeLong 统计占用。", MessageType.Info);

        using (new EditorGUILayout.HorizontalScope())
        {
            using (new EditorGUI.DisabledScope(!EditorApplication.isPlaying))
            {
                if (!monitoring)
                {
                    if (GUILayout.Button("开始监控", GUILayout.Height(26), GUILayout.Width(100)))
                    {
                        monitoring = true;
                        nextUpdateTime = 0f;
                        Collect();
                    }
                }
                else
                {
                    if (GUILayout.Button("停止监控", GUILayout.Height(26), GUILayout.Width(100)))
                        monitoring = false;
                }
            }

            if (GUILayout.Button("手动刷新", GUILayout.Height(26), GUILayout.Width(80)))
                Collect();

            GUILayout.FlexibleSpace();
            GUILayout.Label(EditorApplication.isPlaying ? (monitoring ? "● 监控中" : "○ 已停止") : "● 未进入 Play 模式", EditorStyles.miniLabel);
        }

        if (!EditorApplication.isPlaying)
            EditorGUILayout.HelpBox("请进入 Play Mode 后开始监控。", MessageType.Warning);

        EditorGUI.BeginChangeCheck();
        updateInterval = EditorGUILayout.Slider("刷新间隔 (秒)", updateInterval, 0.1f, 5f);
        onlyCreated = EditorGUILayout.Toggle("只显示已创建 RT", onlyCreated);
        nameFilter = EditorGUILayout.TextField("名称过滤", nameFilter);
        if (EditorGUI.EndChangeCheck()) ApplySort();

        EditorGUILayout.Space(4);
        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            EditorGUILayout.LabelField($"总占用: {FormatBytes(totalMemoryBytes)}", EditorStyles.boldLabel);
            EditorGUILayout.LabelField($"RenderTexture: {entries.Count} 个    已创建: {createdCount} 个");
        }

        if (totalHistory.Count > 1)
            DrawGraph("总占用历史", totalHistory, Color.cyan);

        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            GUILayout.Label("状态", GUILayout.Width(58f));
            GUILayout.Label("名称", GUILayout.Width(260f));
            GUILayout.Label("尺寸", GUILayout.Width(110f));
            GUILayout.Label("格式", GUILayout.Width(150f));
            GUILayout.Label("AA", GUILayout.Width(34f));
            GUILayout.Label("占用", GUILayout.Width(86f));
            bool newMem = GUILayout.Toggle(sortByMemory, "按内存", EditorStyles.toolbarButton, GUILayout.Width(64));
            if (newMem != sortByMemory)
            {
                sortByMemory = newMem;
                ApplySort();
            }
        }

        string filter = nameFilter.Trim();
        scroll = EditorGUILayout.BeginScrollView(scroll);
        foreach (RenderTextureEntry entry in entries)
        {
            if (onlyCreated && !entry.isCreated) continue;
            if (!string.IsNullOrEmpty(filter) && entry.name.IndexOf(filter, StringComparison.OrdinalIgnoreCase) < 0) continue;

            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
            {
                GUILayout.Label(entry.isCreated ? "Created" : "Idle", GUILayout.Width(58f));
                if (GUILayout.Button(new GUIContent(entry.name, entry.name), EditorStyles.linkLabel, GUILayout.Width(260f)))
                    Selection.activeObject = entry.renderTexture;
                GUILayout.Label($"{entry.width}x{entry.height}x{entry.depth}", GUILayout.Width(110f));
                GUILayout.Label(entry.format, GUILayout.Width(150f));
                GUILayout.Label(entry.antiAliasing.ToString(), GUILayout.Width(34f));
                GUILayout.Label(FormatBytes(entry.memoryBytes), GUILayout.Width(86f));
                GUILayout.FlexibleSpace();
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void Collect()
    {
        entries.Clear();
        totalMemoryBytes = 0;
        createdCount = 0;

        RenderTexture[] renderTextures = Resources.FindObjectsOfTypeAll<RenderTexture>();
        for (int i = 0; i < renderTextures.Length; i++)
        {
            RenderTexture rt = renderTextures[i];
            if (rt == null) continue;

            bool isCreated = rt.IsCreated();
            long memoryBytes = Profiler.GetRuntimeMemorySizeLong(rt);
            totalMemoryBytes += memoryBytes;
            if (isCreated) createdCount++;

            entries.Add(new RenderTextureEntry
            {
                renderTexture = rt,
                name = string.IsNullOrEmpty(rt.name) ? "<Unnamed RenderTexture>" : rt.name,
                width = rt.width,
                height = rt.height,
                depth = rt.volumeDepth,
                format = rt.format.ToString(),
                antiAliasing = rt.antiAliasing,
                memoryBytes = memoryBytes,
                isCreated = isCreated
            });
        }

        ApplySort();
        AddHistory(totalMemoryBytes / (1024f * 1024f));
    }

    private void ApplySort()
    {
        if (sortByMemory)
            entries.Sort((a, b) => b.memoryBytes.CompareTo(a.memoryBytes));
        else
            entries.Sort((a, b) => string.Compare(a.name, b.name, StringComparison.OrdinalIgnoreCase));
    }

    private void AddHistory(float value)
    {
        totalHistory.Add(value);
        if (totalHistory.Count > MaxHistory)
            totalHistory.RemoveAt(0);
    }

    private static string FormatBytes(long bytes)
    {
        if (bytes >= 1024L * 1024 * 1024) return $"{bytes / (1024f * 1024 * 1024):F2} GB";
        if (bytes >= 1024 * 1024) return $"{bytes / (1024f * 1024):F2} MB";
        if (bytes >= 1024) return $"{bytes / 1024f:F1} KB";
        return $"{bytes} B";
    }

    private static void DrawGraph(string title, List<float> values, Color color)
    {
        EditorGUILayout.LabelField(title, EditorStyles.boldLabel);
        Rect rect = GUILayoutUtility.GetRect(EditorGUIUtility.currentViewWidth - 40f, 60f);
        float max = 0f;
        for (int i = 0; i < values.Count; i++)
            if (values[i] > max) max = values[i];
        if (Mathf.Approximately(max, 0f)) max = 1f;

        UnityEditor.Handles.BeginGUI();
        UnityEditor.Handles.color = Color.gray;
        UnityEditor.Handles.DrawLine(new Vector3(rect.x, rect.y), new Vector3(rect.x, rect.y + rect.height));
        UnityEditor.Handles.DrawLine(new Vector3(rect.x, rect.y + rect.height), new Vector3(rect.x + rect.width, rect.y + rect.height));
        UnityEditor.Handles.color = color;
        float stepX = rect.width / (values.Count - 1);
        for (int i = 0; i < values.Count - 1; i++)
        {
            float n1 = values[i] / max;
            float n2 = values[i + 1] / max;
            UnityEditor.Handles.DrawLine(
                new Vector3(rect.x + i * stepX, rect.y + rect.height - n1 * rect.height),
                new Vector3(rect.x + (i + 1) * stepX, rect.y + rect.height - n2 * rect.height));
        }
        UnityEditor.Handles.EndGUI();

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("0 MB");
            GUILayout.FlexibleSpace();
            GUILayout.Label($"Max: {max:F2} MB");
        }
    }

    private struct RenderTextureEntry
    {
        public RenderTexture renderTexture;
        public string name;
        public int width;
        public int height;
        public int depth;
        public string format;
        public int antiAliasing;
        public long memoryBytes;
        public bool isCreated;
    }
}
}

#endif
