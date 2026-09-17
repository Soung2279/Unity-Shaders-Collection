#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

/// <summary>
/// Material inspector for the project's customized Spine URP Skeleton shader.
/// Keeps all shader properties on the material so SRP Batcher and GPU Instancing behavior is unchanged.
/// </summary>
public sealed class ShaderGUI_SpineSkeletonURP : ShaderGUI
{
    private static bool s_BaseFoldout = true;
    private static bool s_TintFoldout;
    private static bool s_FillFoldout = true;
    private static bool s_GlowFoldout;
    private static bool s_FlowFoldout;
    private static bool s_AdvancedFoldout;

    private MaterialProperty _mainTex;
    private MaterialProperty _baseColor;
    private MaterialProperty _baseColorPhase;
    private MaterialProperty _straightAlphaInput;
    private MaterialProperty _zWrite;
    private MaterialProperty _cutoff;
    private MaterialProperty _tintBlack;
    private MaterialProperty _color;
    private MaterialProperty _black;
    private MaterialProperty _fill;
    private MaterialProperty _fillColor;
    private MaterialProperty _fillPhase;
    private MaterialProperty _maskGlow;
    private MaterialProperty _glowMaskTex;
    private MaterialProperty _switchGlowP;
    private MaterialProperty _glowColor;
    private MaterialProperty _glowIntensity;
    private MaterialProperty _glowBreath;
    private MaterialProperty _glowBreathFreq;
    private MaterialProperty _glowBreathMinAlpha;
    private MaterialProperty _glowBreathMaxAlpha;
    private MaterialProperty _flowGlow;
    private MaterialProperty _flowTex;
    private MaterialProperty _flowColor;
    private MaterialProperty _useScreenUV;
    private MaterialProperty _screenTexST;
    private MaterialProperty _flowSpeed;
    private MaterialProperty _stencilRef;
    private MaterialProperty _stencilComp;

    private MaterialEditor _materialEditor;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _materialEditor = materialEditor;
        FindProperties(properties);

        EditorGUILayout.LabelField("Spine Skeleton URP", EditorStyles.foldoutHeader);
        EditorGUILayout.HelpBox(
            "定制Spine Shader // 基础色控制对象buff状态、填充色控制受击闪白",
            MessageType.None);

        DrawSection(ref s_BaseFoldout, "基础设置 | Base", BaseResetProperties, () => DrawBase(materialEditor));
        DrawSection(ref s_FillFoldout, "填充色 | Fill", FillResetProperties, () => DrawFill(materialEditor));
        DrawSection(ref s_GlowFoldout, "遮罩发光 | Mask Glow", GlowResetProperties, () => DrawGlow(materialEditor));
        DrawSection(ref s_FlowFoldout, "流光 | Flow Glow", FlowResetProperties, () => DrawFlow(materialEditor));
        DrawSection(ref s_TintFoldout, "Spine 双色着色 | Tint Black", TintResetProperties, () => DrawTint(materialEditor));
        DrawSection(ref s_AdvancedFoldout, "高级设置 | Advanced", AdvancedResetProperties, () => DrawAdvanced(materialEditor));
    }

    private void FindProperties(MaterialProperty[] properties)
    {
        _mainTex = FindProperty("_MainTex", properties);
        _baseColor = FindProperty("_BaseColor", properties);
        _baseColorPhase = FindProperty("_BaseColorPhase", properties);
        _straightAlphaInput = FindProperty("_StraightAlphaInput", properties);
        _zWrite = FindProperty("_ZWrite", properties);
        _cutoff = FindProperty("_Cutoff", properties);
        _tintBlack = FindProperty("_TintBlack", properties);
        _color = FindProperty("_Color", properties);
        _black = FindProperty("_Black", properties);
        _fill = FindProperty("_Fill", properties);
        _fillColor = FindProperty("_FillColor", properties);
        _fillPhase = FindProperty("_FillPhase", properties);
        _maskGlow = FindProperty("_MaskGlow", properties);
        _glowMaskTex = FindProperty("_GlowMaskTex", properties);
        _switchGlowP = FindProperty("_SwitchGlowP", properties);
        _glowColor = FindProperty("_GlowColor", properties);
        _glowIntensity = FindProperty("_GlowIntensity", properties);
        _glowBreath = FindProperty("_GlowBreath", properties);
        _glowBreathFreq = FindProperty("_GlowBreathFreq", properties);
        _glowBreathMinAlpha = FindProperty("_GlowBreathMinAlpha", properties);
        _glowBreathMaxAlpha = FindProperty("_GlowBreathMaxAlpha", properties);
        _flowGlow = FindProperty("_FlowGlow", properties);
        _flowTex = FindProperty("_FlowTex", properties);
        _flowColor = FindProperty("_FlowColor", properties);
        _useScreenUV = FindProperty("_UseScreenUV", properties);
        _screenTexST = FindProperty("_ScreenTex_ST", properties);
        _flowSpeed = FindProperty("_FlowSpeed", properties);
        _stencilRef = FindProperty("_StencilRef", properties);
        _stencilComp = FindProperty("_StencilComp", properties);
    }

    private static readonly string[] BaseResetProperties =
    {
        "_MainTex", "_BaseColor", "_BaseColorPhase", "_Cutoff"
    };

    private static readonly string[] TintResetProperties = { "_Color", "_Black" };
    private static readonly string[] FillResetProperties = { "_FillColor", "_FillPhase" };
    private static readonly string[] GlowResetProperties =
    {
        "_GlowMaskTex", "_SwitchGlowP", "_GlowColor", "_GlowIntensity",
        "_GlowBreathFreq", "_GlowBreathMinAlpha", "_GlowBreathMaxAlpha"
    };

    private static readonly string[] FlowResetProperties =
    {
        "_FlowTex", "_FlowColor", "_FlowSpeed", "_ScreenTex_ST"
    };

    private static readonly string[] AdvancedResetProperties = { "_StencilRef", "_StencilComp" };

    private void DrawSection(
        ref bool foldout,
        string title,
        string[] resetProperties,
        System.Action drawContent)
    {
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.BeginHorizontal();
        foldout = EditorGUILayout.Foldout(foldout, title, true, EditorStyles.foldoutHeader);
        if (GUILayout.Button(new GUIContent("还原参数", "将本组参数恢复为 Shader 默认值"), GUILayout.Width(90f)))
            ResetGroup(resetProperties);
        EditorGUILayout.EndHorizontal();
        if (foldout)
        {
            EditorGUI.indentLevel++;
            drawContent();
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndVertical();
    }

    private void DrawBase(MaterialEditor editor)
    {
        editor.TexturePropertySingleLine(
            new GUIContent("Spine 图集", "Spine Atlas 使用的主纹理。"),
            _mainTex);
        editor.ShaderProperty(
            _baseColor,
            new GUIContent("基础填充色", "常驻填充颜色。用于实现属性Buff状态变色"));
        editor.ShaderProperty(
            _baseColorPhase,
            new GUIContent("基础填充进度", "0 保留原色，1 完全变色。"));
        editor.ShaderProperty(
            _straightAlphaInput,
            new GUIContent("使用图集Alpha", "图集为Straight Alpha 时启用；PMA 图集保持关闭。设置错误可能产生黑边或亮边。"));
        editor.ShaderProperty(
            _zWrite,
            new GUIContent("写入深度", "启用深度写入，并使用下方阈值裁剪低 Alpha 像素。"));

        using (new EditorGUI.DisabledScope(!IsEnabled(_zWrite)))
        {
            editor.ShaderProperty(
                _cutoff,
                new GUIContent("深度裁剪阈值", "仅在写入深度时生效。Alpha 低于该值的像素不会写入。"));
        }
    }

    private void DrawTint(MaterialEditor editor)
    {
        editor.ShaderProperty(
            _tintBlack,
            new GUIContent("启用 Tint Black", "启用 Spine 双色着色。要求 SkeletonRenderer 输出 Tint Black 顶点数据（UV2/UV3）。"));

        using (new EditorGUI.DisabledScope(!IsEnabled(_tintBlack)))
        {
            editor.ShaderProperty(
                _color,
                new GUIContent("亮部颜色", "Tint Black 模式的亮部乘色，不等同于材质整体基础色。"));
            editor.ShaderProperty(
                _black,
                new GUIContent("暗部颜色", "Tint Black 模式的暗部颜色，用于 Spine Slot 的双色着色。"));
        }

        if (!IsEnabled(_tintBlack))
            EditorGUILayout.HelpBox("关闭时，亮部颜色和暗部颜色不参与当前 Shader 输出。", MessageType.Info);
    }

    private void DrawFill(MaterialEditor editor)
    {
        editor.ShaderProperty(
            _fill,
            new GUIContent("启用填充色", "填充色。用于实现受击闪白效果"));

        using (new EditorGUI.DisabledScope(!IsEnabled(_fill)))
        {
            editor.ShaderProperty(_fillColor, new GUIContent("填充颜色", "覆盖混合使用的目标颜色"));
            editor.ShaderProperty(_fillPhase, new GUIContent("填充进度", "0 保留原色，1 完全填色。"));
        }
    }

    private void DrawGlow(MaterialEditor editor)
    {
        editor.ShaderProperty(
            _maskGlow,
            new GUIContent("启用遮罩发光", "额外采样发光遮罩并叠加发光颜色。"));

        using (new EditorGUI.DisabledScope(!IsEnabled(_maskGlow)))
        {
            editor.TexturePropertySingleLine(new GUIContent("发光遮罩", "控制发光生效区域的纹理。"), _glowMaskTex);
            editor.ShaderProperty(_switchGlowP, new GUIContent("遮罩通道", "选择发光遮罩纹理的 R 或 A 通道。"));
            editor.ShaderProperty(_glowColor, new GUIContent("发光颜色", "叠加到基础颜色的 HDR 发光色。"));
            editor.ShaderProperty(_glowIntensity, new GUIContent("发光强度", "发光颜色的亮度倍数。"));
            editor.ShaderProperty(_glowBreath, new GUIContent("启用呼吸", "按时间在最小与最大透明度之间周期变化。"));

            using (new EditorGUI.DisabledScope(!IsEnabled(_glowBreath)))
            {
                editor.ShaderProperty(_glowBreathFreq, new GUIContent("呼吸频率", "每秒完成的呼吸周期数。"));
                editor.ShaderProperty(_glowBreathMinAlpha, new GUIContent("最低透明度", "呼吸周期中的最低发光透明度。"));
                editor.ShaderProperty(_glowBreathMaxAlpha, new GUIContent("最高透明度", "呼吸周期中的最高发光透明度。"));
            }
        }
    }

    private void DrawFlow(MaterialEditor editor)
    {
        editor.ShaderProperty(
            _flowGlow,
            new GUIContent("启用流光", "额外采样流光纹理并叠加到 Spine 有效透明区域。"));

        using (new EditorGUI.DisabledScope(!IsEnabled(_flowGlow)))
        {
            editor.TexturePropertySingleLine(new GUIContent("流光纹理", "用于移动叠加的流光纹理。"), _flowTex);
            if (_flowTex.textureValue != null)
                editor.TextureScaleOffsetProperty(_flowTex);

            editor.ShaderProperty(_flowColor, new GUIContent("流光颜色", "流光纹理的 HDR 乘色。"));
            editor.ShaderProperty(_flowSpeed, new GUIContent("流动速度", "XY 分别控制 U、V 方向每秒移动速度。"));
            editor.ShaderProperty(_useScreenUV, new GUIContent("使用屏幕 UV", "开启时流光固定在屏幕空间；关闭时使用 Spine 图集 UV。"));

            using (new EditorGUI.DisabledScope(!IsEnabled(_useScreenUV)))
            {
                editor.ShaderProperty(_screenTexST, new GUIContent("屏幕 UV 缩放偏移", "XY 为屏幕 UV 缩放，ZW 为屏幕 UV 偏移。仅屏幕 UV 模式生效。"));
            }
        }
    }

    private void DrawAdvanced(MaterialEditor editor)
    {
        editor.ShaderProperty(
            _stencilRef,
            new GUIContent("Stencil Reference", "模板缓冲参考值，通常由 Spine 遮罩流程自动设置。"));
        editor.ShaderProperty(
            _stencilComp,
            new GUIContent("Stencil Comparison", "模板缓冲比较方式，通常保持默认 Always。"));

        editor.RenderQueueField();
        editor.EnableInstancingField();
        editor.DoubleSidedGIField();
    }

    private void ResetGroup(string[] propertyNames)
    {
        Object[] targets = _materialEditor.targets;
        Undo.RecordObjects(targets, "Reset Spine Shader Group");
        foreach (Object target in targets)
        {
            if (target is not Material material)
                continue;

            foreach (string propertyName in propertyNames)
                ResetToShaderDefault(material, propertyName);

            EditorUtility.SetDirty(material);
        }
    }

    private static void ResetToShaderDefault(Material material, string propertyName)
    {
        Shader shader = material.shader;
        int index = shader.FindPropertyIndex(propertyName);
        if (index < 0)
            return;

        switch (shader.GetPropertyType(index))
        {
            case UnityEngine.Rendering.ShaderPropertyType.Color:
                material.SetColor(propertyName, shader.GetPropertyDefaultVectorValue(index));
                break;
            case UnityEngine.Rendering.ShaderPropertyType.Vector:
                material.SetVector(propertyName, shader.GetPropertyDefaultVectorValue(index));
                break;
            case UnityEngine.Rendering.ShaderPropertyType.Float:
            case UnityEngine.Rendering.ShaderPropertyType.Range:
                material.SetFloat(propertyName, shader.GetPropertyDefaultFloatValue(index));
                break;
            case UnityEngine.Rendering.ShaderPropertyType.Texture:
                material.SetTexture(propertyName, null);
                material.SetTextureScale(propertyName, Vector2.one);
                material.SetTextureOffset(propertyName, Vector2.zero);
                break;
        }
    }

    private static bool IsEnabled(MaterialProperty property)
    {
        return property.hasMixedValue || property.floatValue > 0.5f;
    }
}
#endif
