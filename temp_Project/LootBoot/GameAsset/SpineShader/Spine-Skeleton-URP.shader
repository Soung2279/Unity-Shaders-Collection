Shader "Universal Render Pipeline/Spine/Skeleton" {
    Properties {
        [NoScaleOffset] _MainTex("Spine图集", 2D) = "black" {}
        [Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("// 启用图集Alpha值 //", Int) = 0
        [Toggle(_ZWRITE)] _ZWrite("// 启用深度写入 //", Float) = 0.0
        _Cutoff("阴影Alpha阈值", Range(0,1)) = 0.1
        
        [MaterialToggle(_TINT_BLACK_ON)]  _TintBlack("Tint Black", Float) = 0
        _Color("    Light Color", Color) = (1,1,1,1)
        _Black("    Dark Color", Color) = (0,0,0,0)

        [Toggle(_FILL_ON)] _Fill("// 启用填充色 //", Float) = 1
        [HDR]_FillColor("FillColor", Color) = (1,1,1,1)
        _FillPhase("FillPhase", Range(0, 1)) = 0

        [Toggle(_MASK_GLOW_ON)] _MaskGlow("// 启用发光 //", Float) = 0
        [NoScaleOffset] _GlowMaskTex("    发光区域", 2D) = "black" {}
        [Enum(R,0,A,1)]_SwitchGlowP("    遮罩通道切换", Float) = 0
        [HDR]_GlowColor("    发光颜色(GlowColor)", Color) = (1,1,1,1)
        _GlowIntensity("    发光强度(GlowIntensity)", Range(0, 10)) = 1
        [Toggle(_GLOW_BREATH_ON)] _GlowBreath("// 启用发光呼吸 //", Float) = 0
        _GlowBreathFreq("    呼吸频率(次/秒)", Range(0.1, 10)) = 1
        _GlowBreathMinAlpha("    最低透明度", Range(0, 1)) = 0
        _GlowBreathMaxAlpha("    最高透明度", Range(0, 1)) = 1

        [Toggle(_FLOW_GLOW_ON)] _FlowGlow("// 启用流光 //", Float) = 0
        _FlowTex("    流光纹理", 2D) = "black" {}
        [HDR]_FlowColor("    流光颜色(FlowColor)", Color) = (1,1,1,1)
        [Toggle(_USE_SCREEN_UV)] _UseScreenUV("// 使用屏幕UV //", Float) = 0
        _ScreenTex_ST("    屏幕UV的缩放与偏移", Vector) = (1, 1, 0, 0)
        _FlowSpeed("    流光速度", Vector) = (0.1, 0.1, 0, 0)
        
        [HideInInspector] _StencilRef("Stencil Reference", Float) = 1.0
        [HideInInspector] [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8
    }

    SubShader {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent" 
        }

        Cull Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Stencil {
            Ref[_StencilRef]
            Comp[_StencilComp]
            Pass Keep
        }

        Pass {
            Name "Forward"
            Tags{"LightMode" = "SRPDefaultUnlit"}

            ZWrite[_ZWrite]
            Cull Off
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma prefer_hlslcc gles

            #pragma multi_compile_instancing

            #pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
            #pragma shader_feature _TINT_BLACK_ON
            #pragma shader_feature _ZWRITE
            #pragma shader_feature _FILL_ON
            #pragma shader_feature _MASK_GLOW_ON
            #pragma shader_feature _GLOW_BREATH_ON
            #pragma shader_feature _FLOW_GLOW_ON
            #pragma shader_feature _USE_SCREEN_UV
            
            #pragma vertex vert
            #pragma fragment frag

            #undef LIGHTMAP_ON

            #define USE_URP
            #define fixed4 half4
            #define fixed3 half3
            #define fixed half
            #include "Include/Spine-Input-URP.hlsl"
            #include "Include/Spine-Skeleton-ForwardPass-URP.hlsl"

            #pragma multi_compile_local __ SPINE_ADDITIVE_EFFECTS

            ENDHLSL
         }

        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags{"LightMode" = "ShadowCaster"}

        //     ZWrite On
        //     ColorMask 0
        //     ZTest LEqual
        //     Cull Off

        //     HLSLPROGRAM
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 2.0

        //     #pragma shader_feature _ALPHATEST_ON

        //     #pragma multi_compile_instancing
        //     #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //     #pragma vertex ShadowPassVertexSkeletonLit
        //     #pragma fragment ShadowPassFragmentSkeletonLit

        //     #define USE_URP
        //     #define fixed4 half4
        //     #define fixed3 half3
        //     #define fixed half
        //     #include "Include/Spine-Input-URP.hlsl"
        //     #include "Include/Spine-SkeletonLit-ShadowCasterPass-URP.hlsl"

        //     ENDHLSL
        // }

        // Pass
        // {
        //     Name "DepthOnly"
        //     Tags{"LightMode" = "DepthOnly"}

        //     ZWrite On
        //     ColorMask R
        //     Cull Off

        //     HLSLPROGRAM
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x

        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment

        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //     #pragma multi_compile_instancing

        //     #define USE_URP
        //     #define fixed4 half4
        //     #define fixed3 half3
        //     #define fixed half
        //     #include "Include/Spine-Input-URP.hlsl"
        //     #include "Include/Spine-DepthOnlyPass-URP.hlsl"
        //     ENDHLSL
        // }
    }

    FallBack "Universal Render Pipeline/Unlit"
}
