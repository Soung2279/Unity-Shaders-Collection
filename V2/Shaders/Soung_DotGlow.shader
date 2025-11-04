//修改于2025.5.28
Shader "Soung/Effect/DotGlow"
{
    Properties
    {
        //无用贴图, 避免UI警告用
        [HideInInspector]_MainTex("贴图", 2D) = "white" {}
        [KeywordEnum(Dot,Glow)] _dotorglow("光点状/光晕状", Float) = 0
        [HDR]_EnhancedColor("颜色", Color) = (1,1,1,1)
        _MaskPow("光点范围", Range( 5 , 50)) = 10
        _DotPwr("光点亮度", Range( 0 , 5)) = 1
        _MaskSub("光晕范围", Range( 0.5 , 1)) = 0.5
        _GlowPwr("光晕亮度", Range( 0 , 20)) = 20
        [Header(DepthFade)][Toggle(_SOFT_PARTICLES_ON)] _EnableSoftParticles("启用软粒子", Float) = 0
        _DepthFade("软粒子强度", Range( 0 , 1)) = 0.05
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

        // 条件包含深度纹理
        #if defined(_SOFT_PARTICLES_ON)
            #define REQUIRE_DEPTH_TEXTURE 1
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #endif

        CBUFFER_START(UnityPerMaterial)
            float4 _EnhancedColor;
            float _MaskPow;
            float _DotPwr;
            float _MaskSub;
            float _GlowPwr;
            float _DepthFade;
        CBUFFER_END

        struct a2v
        {
            float4 vertex : POSITION;
            float4 ase_color : COLOR;
            float4 ase_texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        
        struct v2f
        {
            float4 clipPos : SV_POSITION;
            float4 ase_color : COLOR;
            float4 ase_texcoord3 : TEXCOORD0;
            #if defined(_SOFT_PARTICLES_ON)
                float4 scrPos : TEXCOORD1;
            #endif
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };
        ENDHLSL

        Pass
        {
            Name "Forward"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma shader_feature_local _DOTORGLOW_DOT _DOTORGLOW_GLOW
            #pragma shader_feature_local_fragment _SOFT_PARTICLES_ON
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

                o.clipPos = positionCS;
                
                // 仅在需要软粒子时计算屏幕位置
                #if defined(_SOFT_PARTICLES_ON)
                    o.scrPos = ComputeScreenPos(positionCS);
                #endif

                return o;
            }

            half4 FRAG(v2f IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 缓存颜色值
                half4 vertexColor = IN.ase_color;
                half3 enhancedColorRGB = _EnhancedColor.rgb;
                half enhancedColorA = _EnhancedColor.a;

                half2 texCoord29 = IN.ase_texcoord3.xy * float2(1,1) + float2(0,0);
                half temp_output_32_0 = abs((1.0 - distance(texCoord29, half2(0.5,0.5))));
                
                #if defined(_DOTORGLOW_DOT)
                    half staticSwitch69 = saturate(pow(temp_output_32_0, _MaskPow) * _DotPwr);
                #elif defined(_DOTORGLOW_GLOW)
                    half staticSwitch69 = saturate((temp_output_32_0 - _MaskSub) * _GlowPwr);
                #else
                    half staticSwitch69 = saturate(pow(temp_output_32_0, _MaskPow) * _DotPwr);
                #endif

                // 软粒子计算
                float softparticle = 1.0;
                
                #if defined(_SOFT_PARTICLES_ON)
                    if (_DepthFade > 0.001)
                    {
                        float4 screenPos = IN.scrPos / IN.scrPos.w;
                        float2 screenUV = screenPos.xy;
                        screenPos.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPos.z : screenPos.z * 0.5 + 0.5;
                        float sceneDepth = SampleSceneDepth(screenUV);
                        float linearEyeDepth = LinearEyeDepth(sceneDepth, _ZBufferParams);
                        float linearParticleDepth = LinearEyeDepth(screenPos.z, _ZBufferParams);
                        float depthDiff = linearEyeDepth - linearParticleDepth;
                        softparticle = saturate(depthDiff / _DepthFade);
                    }
                #endif
                
                // 计算最终颜色和透明度
                float3 Color = (vertexColor.rgb * staticSwitch69 * enhancedColorRGB * vertexColor.a * softparticle);
                float Alpha = (vertexColor.a * enhancedColorA * softparticle);

                return float4(Color, Alpha);
            }
            ENDHLSL
        }
    }
}