// ─────────────────────────────────────────────────────────────────────────────
// Spine Skeleton - 扰动描边（Distortion Outline）
//
// 原理：
//   顶点阶段 — 整个 Spine 网格在 clip-space 沿径向外扩 _OutlineWidth 像素，
//              同时叠加逐顶点 sin 扰动（X/Y 两轴独立相位），产生波动 / 呼吸效果。
//   片元阶段 — 采样原始 UV 的 alpha；alpha >= _ThresholdEnd（角色本体内部）
//              被丢弃，仅保留轮廓环区域，以 _OutlineColor 上色。
// ─────────────────────────────────────────────────────────────────────────────
Shader "Universal Render Pipeline/Spine/Outline/Skeleton-DistortOutline" {
    Properties {
        [NoScaleOffset] _MainTex("Main Texture", 2D) = "black" {}

        [Header(Outline)]
        [HDR]_OutlineColor("描边颜色", Color) = (1, 1, 0, 1)
        _OutlineWidth("描边宽度 (pixels)", Range(0, 16)) = 3.0
        _ThresholdEnd("Alpha 阈值", Range(0, 1)) = 0.25        _OutlineSmoothness("Outline Smoothness", Range(0, 1)) = 1.0
        _OutlineReferenceTexWidth("Reference Texture Width", Int) = 1024
        [Header(Fire Color)]
        [HDR]_FireInnerColor("内焰颜色", Color) = (1, 0.64, 0, 1)
        [HDR]_FireOuterColor("外焰颜色", Color) = (1, 0, 0, 1)
        _FireOuterWidth("外焰宽度", Range(0, 1)) = 0.0
        _FireEdgeWidth("描边宽度 (颜色过渡)", Range(0, 1)) = 0.0

        [Header(Fire Noise Layer1)]
        _NoiseTimeSpeed1("细节1流动强度 (建议默认)", Float) = 2
        _NoiseScale1("细节1缩放", Float) = 5.09
        _TillSpeed1("细节1 Tiling(XY) Speed(ZW)", Vector) = (2, 1, 0, -1)

        [Header(Fire Noise Layer2)]
        _NoiseTimeSpeed2("细节2流动强度 (建议默认)", Float) = 0.6
        _NoiseScale2("细节2缩放", Float) = 3
        _TillSpeed2("细节2 Tiling(XY) Speed(ZW)", Vector) = (2, 1, 0, -0.7)

        [Header(Dissolve)]
        _DissolveAmount("火焰溶解", Range(0, 2)) = 0
        _FireBodySize("火焰主体大小 (不溶解部分)", Range(0, 10)) = 1
        _DissolveMul("整体溶解倍增 (建议默认)", Range(0, 1)) = 0.1

        [HideInInspector] _StencilRef("Stencil Reference", Float) = 1.0
        [HideInInspector] [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
    }

    SubShader {
        Tags {
            "RenderPipeline"  = "UniversalPipeline"
            "Queue"           = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType"      = "Transparent"
        }

        Cull Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Stencil {
            Ref  [_StencilRef]
            Comp [_StencilComp]
            Pass Keep
        }

        Pass {
            Name "DistortOutline"

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma multi_compile_instancing

            #pragma vertex   vertDistortOutline
            #pragma fragment fragDistortOutline

            #define USE_URP
            #define fixed4 half4
            #define fixed3 half3
            #define fixed  half

            #include "../Include/Spine-DistortOutline-Pass-URP.hlsl"
            ENDHLSL
        }
    }

    FallBack "Universal Render Pipeline/Unlit"
}
