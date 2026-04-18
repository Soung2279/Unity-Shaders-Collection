Shader "Universal Render Pipeline/Spine/Skeleton" {
    Properties {
        //修改时间:2025.11.17
        //使用SRPDefaultUnlit
        [NoScaleOffset] _MainTex("Spine图集", 2D) = "black" {}
        [Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("// 启用图集Alpha值 //", Int) = 0
        [Toggle(_ZWRITE)] _ZWrite("// 启用深度写入 //", Float) = 0.0
        _Cutoff("阴影Alpha阈值", Range(0,1)) = 0.1
        
        [MaterialToggle(_TINT_BLACK_ON)]  _TintBlack("Tint Black", Float) = 0
        _Color("    Light Color", Color) = (1,1,1,1)
        _Black("    Dark Color", Color) = (0,0,0,0)

        [Toggle(_FILL_ON)] _Fill("// 启用填充色 //", Float) = 0
        [HDR]_FillColor("    填充颜色", Color) = (1,1,1,1)
        _FillPhase("    填充进度", Range(0, 1)) = 0

        [Toggle(_MASK_GLOW_ON)] _MaskGlow("// 启用发光 //", Float) = 0
        [NoScaleOffset] _GlowMaskTex("发光遮罩", 2D) = "black" {}
        [Enum(R,0,A,1)]_SwitchGlowP("    遮罩通道切换", Float) = 0
        [HDR]_GlowColor("    发光颜色(GlowColor)", Color) = (1,1,1,1)
        _GlowIntensity("    发光强度(GlowIntensity)", Range(0, 10)) = 1
        [Toggle] _UseEdgeExpand("    启用边缘扩展", Float) = 0
        _EdgeExpandRadius("    扩展半径(像素)", Range(0, 20)) = 5
        _EdgeExpandSamples("    采样数量", Range(4, 16)) = 8
        _EdgeFeather("    边缘羽化强度", Range(0, 1)) = 0.5

        [Toggle(_FLOW_GLOW_ON)] _FlowGlow("// 启用区域流光 //", Float) = 0
        _FlowTex("    流光纹理", 2D) = "black" {}
        [Toggle(_USE_SCREEN_UV)] _UseScreenUV("// 使用屏幕UV //", Float) = 0
        _ScreenTex_ST("    屏幕UV的缩放与偏移", Vector) = (1, 1, 0, 0)
        _FlowSpeed("    流光速度", Vector) = (0.1, 0.1, 0, 0)
        
        [Toggle(_GLOBAL_MASK_ON)] _GlobalMask("使用全局遮罩", Float) = 0
        [NoScaleOffset] _GlobalMaskTex("全局遮罩", 2D) = "white" {}
        [Enum(R,0,A,1)]_SwitchP("    贴图通道切换", Float) = 0
        _MaskStatus("    遮罩状态(MaskStatus)", Range(0, 1)) = 1
        
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
            #pragma exclude_renderers d3d11_9x

            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
            #pragma shader_feature _TINT_BLACK_ON
            #pragma shader_feature _ZWRITE
            #pragma shader_feature _FILL_ON
            #pragma shader_feature _MASK_GLOW_ON
            #pragma shader_feature _FLOW_GLOW_ON
            #pragma shader_feature _USE_SCREEN_UV
            #pragma shader_feature _GLOBAL_MASK_ON
            
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

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ColorMask 0
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile_instancing
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertexSkeletonLit
            #pragma fragment ShadowPassFragmentSkeletonLit

            #define USE_URP
            #define fixed4 half4
            #define fixed3 half3
            #define fixed half
            #include "Include/Spine-Input-URP.hlsl"
            #include "Include/Spine-SkeletonLit-ShadowCasterPass-URP.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask R
            Cull Off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma multi_compile_instancing

            #define USE_URP
            #define fixed4 half4
            #define fixed3 half3
            #define fixed half
            #include "Include/Spine-Input-URP.hlsl"
            #include "Include/Spine-DepthOnlyPass-URP.hlsl"
            ENDHLSL
        }
    }

    FallBack "Universal Render Pipeline/Unlit"
}
