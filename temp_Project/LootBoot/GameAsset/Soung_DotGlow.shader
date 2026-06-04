//修改于2026.4.10
Shader "Soung/Effect/DotGlow"
{
    Properties
    {
        [KeywordEnum(Dot,Glow)] _dotorglow("光点状/光晕状", Float) = 0
        [HDR]_EnhancedColor("颜色", Color) = (1,1,1,1)
        [Toggle(_USE_CUSTOM_VERTEX)] _EnableCustomVertex("Custom1.xyzw控制参数", Float) = 0
        // 勾选后：Custom2.xyzw -> 主颜色RGBA（覆盖_EnhancedColor）
        // 粒子系统 Renderer -> Custom Vertex Streams 中添加 Custom2.xyzw
        [Toggle(_USE_CUSTOM2_COLOR)] _EnableCustom2Color("Custom2.xyzw控制主颜色", Float) = 0
        _MaskPow("光点范围", Range( 5 , 50)) = 10
        _DotPwr("光点亮度", Range( 0 , 5)) = 1
        _MaskSub("光晕范围", Range( 0.5 , 1)) = 0.5
        _GlowPwr("光晕亮度", Range( 0 , 20)) = 20
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "UniversalMaterialType"="Unlit"
        }

        Cull Off
        Blend One One, One OneMinusSrcAlpha
        ZWrite Off
        ZTest LEqual
        Offset 0 , 0
        ColorMask RGBA

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _EnhancedColor;
            float _MaskPow;
            float _DotPwr;
            float _MaskSub;
            float _GlowPwr;
        CBUFFER_END

        struct a2v
        {
            float4 vertex : POSITION;
            float4 ase_color : COLOR;
            float4 ase_texcoord : TEXCOORD0;
            float4 ase_texcoord1 : TEXCOORD1;  // Custom1.xyzw
            float4 ase_texcoord2 : TEXCOORD2;  // Custom2.xyzw
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        
        struct v2f
        {
            float4 clipPos : SV_POSITION;
            float4 ase_color : COLOR;
            float4 ase_texcoord3 : TEXCOORD0;
            float4 customData : TEXCOORD1;   // Custom1.xyzw
            float4 customColor2 : TEXCOORD2; // Custom2.xyzw
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };
        ENDHLSL

        Pass
        {
            Name "Universal2D"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma shader_feature_local _DOTORGLOW_DOT _DOTORGLOW_GLOW
            #pragma shader_feature_local _USE_CUSTOM_VERTEX
            #pragma shader_feature_local _USE_CUSTOM2_COLOR
            #pragma multi_compile_instancing

            v2f VERT(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.ase_color = v.ase_color;
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                o.ase_texcoord3.zw = 0;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);

                o.customData   = v.ase_texcoord1;
                o.customColor2 = v.ase_texcoord2;
                o.clipPos = positionCS;

                return o;
            }

            half4 FRAG(v2f IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 缓存颜色值
                half4 vertexColor = IN.ase_color;
                #if defined(_USE_CUSTOM2_COLOR)
                    half3 enhancedColorRGB = IN.customColor2.rgb;
                    half  enhancedColorA   = IN.customColor2.a;
                #else
                    half3 enhancedColorRGB = _EnhancedColor.rgb;
                    half  enhancedColorA   = _EnhancedColor.a;
                #endif

                // 自定义顶点流参数 (Custom1.xyzw → MaskPow, DotPwr, MaskSub, GlowPwr)
                float finalMaskPow = _MaskPow;
                float finalDotPwr = _DotPwr;
                float finalMaskSub = _MaskSub;
                float finalGlowPwr = _GlowPwr;
                #if defined(_USE_CUSTOM_VERTEX)
                    finalMaskPow *= IN.customData.x;
                    finalDotPwr  *= IN.customData.y;
                    finalMaskSub *= IN.customData.z;
                    finalGlowPwr *= IN.customData.w;
                #endif

                half2 texCoord29 = IN.ase_texcoord3.xy * float2(1,1) + float2(0,0);
                half temp_output_32_0 = abs((1.0 - distance(texCoord29, half2(0.5,0.5))));
                
                #if defined(_DOTORGLOW_DOT)
                    half staticSwitch69 = saturate(pow(temp_output_32_0, finalMaskPow) * finalDotPwr);
                #elif defined(_DOTORGLOW_GLOW)
                    half staticSwitch69 = saturate((temp_output_32_0 - finalMaskSub) * finalGlowPwr);
                #else
                    half staticSwitch69 = saturate(pow(temp_output_32_0, finalMaskPow) * finalDotPwr);
                #endif

                // 计算最终颜色和透明度
                float3 Color = (vertexColor.rgb * staticSwitch69 * enhancedColorRGB * vertexColor.a);
                float Alpha = saturate(vertexColor.a * enhancedColorA);

                return float4(Color, Alpha);
            }
            ENDHLSL
        }
    }
}