﻿Shader "A201-Shader/URP/原神卡通着色器_GenshinCelShaderURP"
{      
    Properties
    {
        [Header(Shader Setting)]
        [Space(5)]
        [KeywordEnum(Base,Hair,Face)] _ShaderEnum("Shader类型",int) = 0
        [Toggle] _IsNight ("In Day", int) = 0
        [Space(5)]

        [Header(High Level Setting)]
        [ToggleUI]_IsFace("Is Face? (please turn on if this is a face material)", Float) = 0

        [Header(Main Texture Setting)]
        [Space(5)]
        [MainTexture]_MainTex ("_BaseMap (Albedo)", 2D) = "black" { }
        [HDR][MainColor]_MainColor ("_BaseColor", Color) = (1, 1, 1, 1)
        _WorldLightInfluence ("World Light Influence", range(0.0, 1.0)) = 0.1
        [Toggle(ENABLE_AUTOCOLOR)] _EnableAutoColor ("Enable AutoColor", float) = 0.0
        [Space(30)]

        [Header(Bloom)]
        [Space(5)]
        [Toggle(ENABLE_BLOOM_MASK)]_EnableBloomMask ("Enable Bloom", float) = 0.0
        [NoScaleOffset]_BloomMap ("Bloom/Emission Map", 2D) = "black" { }
        _BloomFactor ("Common Bloom Factor", range(0.0, 1.0)) = 1.0

        [Header(Emission)]
        [Toggle]_EnableEmission ("Enable Emission", Float) = 0
        _Emission ("Emission", range(0.0, 20.0)) = 1.0
        [HDR]_EmissionColors ("Emission Color", color) = (0, 0, 0, 0)
        _EmissionBloomFactor ("Emission Bloom Factor", range(0.0, 10.0)) = 1.0
        [HideInInspector]_EmissionMapChannelMask ("_EmissionMapChannelMask", Vector) = (1, 1, 1, 0)
        [Space(30)]

        [Header(Shadow Setting 1)]
        [Space(5)]
        _LightMap ("LightMap", 2D) = "grey" { }
        _ShadowMultColor ("Shadow Color", color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowArea ("Shadow Area", range(0.0, 1.0)) = 0.5
        _DarkShadowMultColor ("Dark Shadow Color", color) = (0.5, 0.5, 0.5, 1)
        _DarkShadowArea ("Dark Shadow Area", range(0.0, 1.0)) = 0.5
        _DarkShadowSmooth ("Shadow Smooth", range(0.0, 1.0)) = 0.05
        [Toggle]_FixDarkShadow ("Fix Dark Shadow", float) = 1
        [Toggle]_IgnoreLightY ("Ignore Light y", float) = 0
        _FixLightY ("Fix Light y", range(-10.0, 10.0)) = 0.0

        [Toggle(ENABLE_FACE_SHADOW_MAP)]_EnableFaceShadowMap ("Enable Face Shadow Map", float) = 0
        _FaceShadowMap ("Face Shadow Map", 2D) = "white" { }
        _FaceShadowMapPow ("Face Shadow Map Pow", range(0.001, 1.0)) = 0.2
        _FaceShadowOffset ("Face Shadow Offset", range(-1.0, 1.0)) = 0.0

        [Header(Shadow Setting 2)]
        [Space(5)]
        [Toggle(ENABLE_RAMP_SHADOW)] _EnableRampShadow ("Enable Ramp Shadow", float) = 1
        _RampMap ("RampMap", 2D) = "white" {}
        _RampShadowRange ("Ramp Shadow Range", Range(0.5, 1.0)) = 0.8
        _ShadowRampLerp ("Shadow Ramp Lerp", Range(0.0, 1)) = 0.5
        _RampAOLerp ("Shadow AO Lerp", Range(0.0, 1)) = 0.5
        _CharacterIntensity ("Character Intensity", Range(0.0, 5.0)) = 0.5
        _RampIntensity ("Ramp Intensity", Range(0.0, 1.0)) = 0.5
        _LightThreshold ("Light Threshold", Range(0.0, 1.0)) = 0.5
        _BrightIntensity ("Bright  Intensity", Range(0.0, 1.0)) = 0.5
        _DarkIntensity ("Dark Intensity", Range(0.0, 1.0)) = 0.5
        _FaceDarkIntensity ("Face Dark Intensity", Range(0.0, 2.0)) = 1.0
        _ShadowColor ("Ramp Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Space(30)]
        [Header(Specular Setting)]
        [Space(5)]
        [Toggle] _EnableSpecular ("Enable Specular", int) = 1
        [Toggle(ENABLE_METAL_SPECULAR)] _EnableMetalSpecular ("Enable Metal Specular", int) = 1
        _MetalMap ("Metal Map", 2D) = "white" {}
        [HDR] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BlinnPhongSpecularGloss ("Blinn Phong Specular Gloss", Range(0.01, 10)) = 5
        _BlinnPhongSpecularIntensity ("Blinn Phong Specular Intensity", Range(0, 1)) = 1
        _StepSpecularGloss ("Step Specular Gloss", Range(0, 1)) = 0.5
        _StepSpecularIntensity ("Step Specular Intensity", Range(0, 10)) = 0.5
        _MetalSpecularGloss ("Metal Specular Gloss", Range(0, 1)) = 0.5
        _MetalSpecularIntensity ("Metal Specular Intensity", Range(0, 1)) = 1
        _SpecMulti ("Multiple Factor", range(0.1, 1.0)) = 1
        [Space(30)]

        [Header(RimLight Setting)]
        [Space(5)]
        [Toggle]_EnableLambert ("Enable Lambert", float) = 1
        [Toggle]_EnableRim ("Enable Rim", float) = 1
        [HDR]_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimSmooth ("Rim Smooth", Range(0.001, 1.0)) = 0.01
        _RimPow ("Rim Pow", Range(0.0, 10.0)) = 1.0
        [Space(5)]
        [Toggle]_EnableRimDS ("Enable Dark Side Rim", int) = 1
        [HDR]_DarkSideRimColor ("DarkSide Rim Color", Color) = (1, 1, 1, 1)
        _DarkSideRimSmooth ("DarkSide Rim Smooth", Range(0.001, 1.0)) = 0.01
        _DarkSideRimPow ("DarkSide Rim Pow", Range(0.0, 10.0)) = 1.0
        [HideInInspector][Toggle]_EnableRimOther ("Enable Other Rim", int) = 0
        [HideInInspector][HDR]_OtherRimColor ("Other Rim Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_OtherRimSmooth ("Other Rim Smooth", Range(0.001, 1.0)) = 0.01
        [HideInInspector]_OtherRimPow ("Other Rim Pow", Range(0.001, 50.0)) = 10.0
        [Space(30)]

        [Header(RimLight Setting (Screen Space))]
        [Space(5)]
        [Toggle] _EnableRims ("Enable Screen Space Rim", int) = 0
        [HDR] _RimColors ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimOffsets ("Rim Offset", Range(0, 0.5)) = 0.1    //粗细
        _RimThresholds ("Rim Threshold", Range(0, 2)) = 1  //细致程度
        [Space(30)]

        [HideInInspector][Header(Shadow mapping)]
        [HideInInspector]_ReceiveShadowMappingAmount ("_ReceiveShadowMappingAmount", Range(0, 1)) = 0.75
        [HideInInspector]_ReceiveShadowMappingPosOffset ("_ReceiveShadowMappingPosOffset (increase it if is face!)", Float) = 0

        [Header(Outline Setting)]
        [Space(5)]
        [Toggle] _EnableOutline ("Enable Outline", float) = 1
        _OutlineWidth("_OutlineWidth (World Space)", Range(0,4)) = 1
        _OutlineColor("_OutlineColor", Color) = (0.5,0.5,0.5,1)
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0,1)) = 0.0001
        [NoScaleOffset]_OutlineZOffsetMaskTex("_OutlineZOffsetMask (black is apply ZOffset)", 2D) = "black" {}
        _OutlineZOffsetMaskRemapStart("_OutlineZOffsetMaskRemapStart", Range(0,1)) = 0
        _OutlineZOffsetMaskRemapEnd("_OutlineZOffsetMaskRemapEnd", Range(0,1)) = 1

        [Header(Alpha)]
        [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("_EnableAlphaClipping", Float) = 0
        _ClipScale ("_ClipScale (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
    }


    SubShader
    {
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "UniversalMaterialType" = "Lit" "Queue" = "Geometry" }

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "NiloInvLerpRemap.hlsl"
        #include "NiloOutlineUtil.hlsl"
        #include "NiloZOffset.hlsl"

        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_HAIR _SHADERENUM_FACE

        int _IsNight;

        TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);

        TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
        TEXTURE2D(_FaceShadowMap);  SAMPLER(sampler_FaceShadowMap);
        TEXTURE2D(_RampMap);        SAMPLER(sampler_RampMap);
        TEXTURE2D(_BloomMap);       SAMPLER(sampler_BloomMap);
        TEXTURE2D(_MetalMap);       SAMPLER(sampler_MetalMap);
        TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
        sampler2D _OutlineZOffsetMaskTex;

        // 单个材质独有的参数尽量放在 CBUFFER 中，以提高性能
        // 为了确保UnityShader可以兼容SRP批处理
        CBUFFER_START(UnityPerMaterial)
            // 纹理缩放平移系数

            float   _IsFace;
            float4 _MainTex_ST;
            float4 _MainColor;
            half _WorldLightInfluence;
            float _EnableAutoColor;

            float4 _LightMap_ST;
            float4 _FaceShadowMap_ST;
            float _FaceShadowMapPow;
            float _FaceShadowOffset;

            float4 _RampMap_ST;
            float _EnableRampShadow;
            float _ShadowRampLerp;
            float _RampAOLerp;
            float _RampShadowRange;
            float _CharacterIntensity;
            float _RampIntensity;
            float _LightThreshold;
            float _BrightIntensity;
            float _DarkIntensity;
            float _FaceDarkIntensity;
            float _ShadowColor;

            float3 _ShadowMultColor;
            float _ShadowArea;
            float _DarkShadowSmooth;
            float _DarkShadowArea;
            float3 _DarkShadowMultColor;

            int _EnableSpecular;
            int _EnableMetalSpecular;
            float4 _MetalMap_ST;
            half4 _SpecularColor;
            half _BlinnPhongSpecularGloss;
            half _BlinnPhongSpecularIntensity;
            half _StepSpecularGloss;
            half _StepSpecularIntensity;
            half _MetalSpecularGloss;
            half _MetalSpecularIntensity;
            half _SpecMulti;

            float _FixDarkShadow;
            float _IgnoreLightY;
            float _FixLightY;

            float _EnableLambert;
            float _EnableRim;
            half4 _RimColor;
            float _RimSmooth;
            float _RimPow;
            float _EnableRimDS;
            half4 _DarkSideRimColor;
            float _DarkSideRimSmooth;
            float _DarkSideRimPow;
            float _EnableRimOther;
            half4 _OtherRimColor;
            float _OtherRimSmooth;
            float _OtherRimPow;

            int _EnableRims;
            half4 _RimColors;
            half _RimOffsets;
            half _RimThresholds;

            float _EnableBloomMask;
            float4 _BloomMap_ST;
            float _BloomFactor;
            float _EnableEmission;
            half4 _EmissionColors;
            float _Emission;
            float _EmissionBloomFactor;
            half _EmissionMulByBaseColor;
            half3 _EmissionMapChannelMask;

            half _ReceiveShadowMappingAmount;
            float _ReceiveShadowMappingPosOffset;

            float _EnableOutline;
            float   _OutlineWidth;
            half4   _OutlineColor;
            float   _OutlineZOffset;
            float   _OutlineZOffsetMaskRemapStart;
            float   _OutlineZOffsetMaskRemapEnd;

            float _EnableAlphaClipping;
            half _ClipScale;

        CBUFFER_END

        struct a2v
        {
            float3 positionOS: POSITION;      //顶点坐标
            half4 color: COLOR0;              //顶点色
            half3 normalOS: NORMAL;           //法线
            half4 tangentOS: TANGENT;         //切线
            float2 texcoord: TEXCOORD0;       //纹理坐标
        };

        struct v2f
        {
            float4 positionCS: POSITION;       //裁剪空间顶点坐标
            float4 color: COLOR0;              //平滑Rim所需顶点色
            float4 uv: TEXCOORD0;              //uv
            float3 positionWS: TEXCOORD1;      //世界坐标
            float3 positionVS: TEXCOORD2;
            float3 normalWS: TEXCOORD3;        //世界空间法线
            float lambert: TEXCOORD4;
            float4 shadowCoord: TEXCOORD5;
            float3 worldTangent : TEXCOORD6;    //世界空间切线
            float3 worldBiTangent : TEXCOORD7;  //世界空间副切线
        };

        float3 TransformPositionWSToOutlinePositionWS(half vertexColorAlpha, float3 positionWS, float positionVS_Z, float3 normalWS)
        {
            float outlineExpandAmount = vertexColorAlpha * _OutlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier(positionVS_Z);
            return (positionWS + normalWS * outlineExpandAmount) * _EnableOutline;
        }

        v2f OutlinePassVertex(a2v input)
        {
            v2f output = (v2f)0;
            output.color = input.color;

            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;

            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);

            // #ifdef ToonShaderIsOutline
            output.positionWS = TransformPositionWSToOutlinePositionWS(input.color.a, output.positionWS, output.positionVS.z, output.normalWS);
            // #endif

            output.positionCS = TransformWorldToHClip(output.positionWS);
            
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;

            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _MainTex);
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);

            // [Read ZOffset mask texture]
            // we can't use tex2D() in vertex shader because ddx & ddy is unknown before rasterization, 
            // so use tex2Dlod() with an explict mip level 0, put explict mip level 0 inside the 4th component of param uv)
            float outlineZOffsetMaskTexExplictMipLevel = 0;
            float outlineZOffsetMask = tex2Dlod(_OutlineZOffsetMaskTex, float4(input.texcoord,0,outlineZOffsetMaskTexExplictMipLevel)).r; //we assume it is a Black/White texture

            // [Remap ZOffset texture value]
            // flip texture read value so default black area = apply ZOffset, because usually outline mask texture are using this format(black = hide outline)
            outlineZOffsetMask = 1-outlineZOffsetMask;
            outlineZOffsetMask = invLerpClamp(_OutlineZOffsetMaskRemapStart,_OutlineZOffsetMaskRemapEnd,outlineZOffsetMask);// allow user to flip value or remap

            // [Apply ZOffset, Use remapped value as ZOffset mask]
            output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset * outlineZOffsetMask + 0.03 * _IsFace);

            return output;

        }

        v2f ToonPassVertex(a2v input)
        {
            v2f output = (v2f)0;
            output.color = input.color;

            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;

            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);
            
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;

            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _MainTex);
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            return output;
        }

        v2f ShadowCasterPassVertex(a2v input)
        {
            v2f output = (v2f)0;
            
            // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space)
            // Our compiler will strip all unused references (say you don't use view space).
            // Therefore there is more flexibility at no additional cost with this struct.
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
            
            // Similar to VertexPositionInputs, VertexNormalInputs will contain normal, tangent and bitangent
            // in world space. If not used it will be stripped.
            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            
            // Computes fog factor per-vertex.
            float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
            
            // TRANSFORM_TEX is the same as the old shader library.
            output.uv.xy = TRANSFORM_TEX(input.texcoord, _MainTex);
            
            // packing posWS.xyz & fog into a vector4
            output.positionWS = float4(vertexInput.positionWS, fogFactor);
            output.normalWS = vertexNormalInput.normalWS;
            
            #ifdef _MAIN_LIGHT_SHADOWS
                // shadow coord for the light is computed in vertex.
                // After URP 7.21, URP will always resolve shadows in light space, no more screen space resolve.
                // In this case shadowCoord will be the vertex position in light space.
                output.shadowCoord = GetShadowCoord(vertexInput);
            #endif
            
            // Here comes the flexibility of the input structs.
            // We just use the homogeneous clip position from the vertex input
            output.positionCS = vertexInput.positionCS;
            
            // ShadowCaster pass needs special process to clipPos, else shadow artifact will appear
            //--------------------------------------------------------------------------------------
            
            //see GetShadowPositionHClip() in URP/Shaders/ShadowCasterPass.hlsl
            float3 positionWS = vertexInput.positionWS;
            float3 normalWS = vertexNormalInput.normalWS;
            
            
            Light light = GetMainLight();
            float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, light.direction));
            
            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
            #endif
            output.positionCS = positionCS;
            
            //--------------------------------------------------------------------------------------
            
            return output;
        }

        half4 FragmentAlphaClip(v2f input): SV_TARGET
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            #if ENABLE_ALPHA_CLIPPING
                clip(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).b - _ClipScale);
            #endif
            return 0;
        }

        ENDHLSL

        Pass
        {
            NAME "CHARACTER_BASE"

            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero

            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            // #pragma shader_feature_local

            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
            #pragma shader_feature_local_fragment ENABLE_BLOOM_MASK
            #pragma shader_feature_local_fragment ENABLE_FACE_SHADOW_MAP
            #pragma shader_feature_local_fragment ENABLE_RAMP_SHADOW
            #pragma shader_feature_local_fragment ENABLE_METAL_SPECULAR
            #pragma vertex ToonPassVertex
            #pragma fragment ToonPassFragment

            half4 ToonPassFragment(v2f input): COLOR
            {

                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
                #if ENABLE_ALPHA_CLIPPING
                    clip(baseColor.a - _ClipScale);
                #endif

                #if ENABLE_BLOOM_MASK
                    baseColor.a = SAMPLE_TEXTURE2D(_BloomMap, sampler_BloomMap, input.uv.zw).a * baseColor.a;
                #endif

                if (!_EnableEmission)
                {
                    baseColor.a = 0;
                }

                Light mainLight =  GetMainLight();                  //获取主光源
                float4 LightColor = float4(mainLight.color.rgb, 1);     //获取主光源颜色

                half3 ShadowColor = baseColor.rgb * _ShadowMultColor;                           //亮部颜色，这里而我们选取主光源颜色作为亮部颜色
                half3 DarkShadowColor = baseColor.rgb * _DarkShadowMultColor.rgb;                   //暗部颜色，这里为了便于美术后期调整阴影颜色，我们在baseColor上叠加_DarkShadowMultColor.rgb

                float3 shadowTestPosWS = input.positionWS + mainLight.direction * _ReceiveShadowMappingPosOffset;
                #ifdef _MAIN_LIGHT_SHADOWS
                    float4 shadowCoord = TransformWorldToShadowCoord(shadowTestPosWS);
                    mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
                #endif

                half4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv.xy);

                // 计算世界空间中的光照和视角方向
                half3 lightDir = normalize(TransformObjectToWorldDir(_MainLightPosition.xyz));
                half3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
                half3 halfViewLightWS = normalize(viewDirWS + mainLight.direction.xyz);
                half3 halfDir = normalize(viewDirWS + lightDir);

                float3 V = viewDirWS;//视角方向
                half3 L = mainLight.direction;//光照
                float3 N = input.normalWS;//法线
                float3 H = normalize(V + L);//得到我们的半程向量
                float NH = saturate(dot(N,H)); 
                float NV = saturate (dot(N,V));
                float NL = saturate (dot(N,L));

                float SpecularLayerMask = LightMapColor.r;       // ⾼光类型Layer
                float ShadowAOMask = LightMapColor.g;            //ShadowAOMask
                float SpecularIntensityMask = LightMapColor.b;   //SpecularIntensityMask
                float LayerMask = LightMapColor.a;               //LayerMask Ramp类型Layer
                // return VertexColor.a;                    //描边⼤⼩
                //Ramp偏移值,值越⼤的区域 越容易"感光"(在⼀个特定的⾓度，偏移光照明暗)


                /*光照模型

                
                float rampVmove = 0.0;
                half halfLambert = max(0.0, NL) * 0.5 + 0.5;

                float rampValue = halfLambert * (1.0 / _RampShadowRange - 0.003);

                */

                //修改 加入AO

                float rampVmove = 0.0;
                half halfLambert = max(0.0, NL) * 0.5 + 0.5;
                ShadowAOMask = 1 - smoothstep(saturate(ShadowAOMask), 0.2, 0.6);             //平滑ShadowAOMask,减弱锯⻮ 
                //lerp(0.5, 1.0, ShadowAOMask)减弱影响
                #if ENABLE_RAMP_SHADOW
                    //为了将ShadowAOMask区域常暗显⽰
                    float rampValue = halfLambert  * lerp(0.5, 1.0, ShadowAOMask) * (1.0 / _RampShadowRange - 0.003);
                    
                    if (_IsNight > 0.5){
                        rampVmove += 0.5;    //如果是白天，采样上面
                    }
                    else{
                        rampVmove += 0.0;   //如果是夜晚，采样下面
                    }

                    half3 ShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.45 + rampVmove)).rgb;
                    half3 ShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.35 + rampVmove)).rgb;
                    half3 ShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.25 + rampVmove)).rgb;
                    half3 ShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.15 + rampVmove)).rgb;
                    half3 ShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.05 + rampVmove)).rgb;           

                    /*
                    Skin = 1.0
                    Silk = 0.7
                    Metal = 0.5
                    Soft = 0.3
                    Hand = 0.0
                    */


                    half3 skinRamp = step(abs(LightMapColor.a - 1),     0.015) * ShadowRamp1;  
                    float3 tightsRamp = step(abs(LightMapColor.a  - 0.7),     0.015) * ShadowRamp2;          
                    float3 softCommonRamp = step(abs(LightMapColor.a - 0.5), 0.015) * ShadowRamp3;            
                    half3 hardSilkRamp = step(abs(LightMapColor.a - 0.3),   0.015) * ShadowRamp4;            
                    half3 metalRamp = step(abs(LightMapColor.a - 0.0),       0.015) * ShadowRamp5;     

                    // 组合5个Ramp，得到最终的Ramp阴影，并根据rampValue与BaseColor结合。
                    half3 finalRamp = skinRamp + tightsRamp + metalRamp  + hardSilkRamp + softCommonRamp ;

                    /*
                    原来的分布代码
                    因为和阴影同时 出现
                    rampValue =  step(_RampShadowRange, halfLambert) ;
                    half3 RampShadowColor = lerp(finalRamp * BaseColor.rgb, BaseColor.rgb,  rampValue) ;    
                    half3 RampShadowColor = rampValue * BaseColor.rgb + (1 - rampValue) * finalRamp * BaseColor.rgb;   
                    */

                    float3 BaseMapShadowed = lerp(baseColor.rgb * finalRamp , baseColor.rgb, ShadowAOMask);              //分布Ramp 

                    BaseMapShadowed = lerp(baseColor.rgb * _ShadowMultColor.rgb, BaseMapShadowed * _DarkShadowMultColor.rgb, _ShadowRampLerp);                            //阴影强度

                    float IsBrightSide = ShadowAOMask * step(_LightThreshold, halfLambert);                             //获得亮部、暗部分布

                    float3 Diffuse = lerp(lerp(BaseMapShadowed, baseColor.rgb * finalRamp, _RampAOLerp) * _DarkIntensity ,
                    _BrightIntensity * BaseMapShadowed ,                                                                //分开亮部
                    IsBrightSide * _RampIntensity ) * _CharacterIntensity ;
                    

                    float3 finalRGB = Diffuse;

                    half3 RampShadowColor = finalRGB;

                    ShadowColor = RampShadowColor;

                #endif

                half4 FinalColor;
                FinalColor.rgb = ShadowColor;

                //根据KEYWORD决定是否使用Ramp阴影
                #if ENABLE_RAMP_SHADOW
                    FinalColor.rgb = RampShadowColor;
                #endif

                // FaceLightMap
                #if ENABLE_FACE_SHADOW_MAP

                    // 计算光照旋转偏移
                    float sinx = sin(_FaceShadowOffset);
                    float cosx = cos(_FaceShadowOffset);
                    float2x2 rotationOffset = float2x2(cosx, -sinx, sinx, cosx);
                    
                    float3 Front = unity_ObjectToWorld._12_22_32;
                    float3 Right = unity_ObjectToWorld._13_23_33;
                    float2 lightDir1 = mul(rotationOffset, mainLight.direction.xz);

                    //计算xz平面下的光照角度
                    float FrontL = dot(normalize(Front.xz), normalize(lightDir1));
                    float RightL = dot(normalize(Right.xz), normalize(lightDir1));
                    RightL = - (acos(RightL) / PI - 0.5) * 2;

                    //左右各采样一次FaceLightMap的阴影数据存于lightData
                    float2 lightData = float2(SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(input.uv.x, input.uv.y)).r,
                    SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(-input.uv.x, input.uv.y)).r);

                    //修改lightData的变化曲线，使中间大部分变化速度趋于平缓。
                    lightData = pow(abs(lightData), _FaceShadowMapPow);

                    //根据光照角度判断是否处于背光，使用正向还是反向的lightData。
                    float lightAttenuation = step(0, FrontL) * min(step(RightL, lightData.x), step(-RightL, lightData.y));
                    
                    half3 FaceColor = lerp(ShadowColor.rgb * _FaceDarkIntensity , baseColor.rgb, lightAttenuation);
                    FinalColor.rgb = FaceColor;
                #endif

                // Blinn-Phong

                //==========================================================================================
                // 高光
                half4 BlinnPhongSpecular;
                half4 MetalSpecular;
                half4 StepSpecular;
                half4 FinalSpecular;
                // ILM的R通道，灰色为裁边视角高光
                half StepMask = step(0.2, SpecularLayerMask) - step(0.8, SpecularLayerMask);
                StepSpecular = step(1 - _StepSpecularGloss, saturate(dot(input.normalWS, viewDirWS))) * _StepSpecularIntensity * StepMask;
                // ILM的R通道，白色为 Blinn-Phong + 金属高光
                half MetalMask = step(0.9, SpecularLayerMask);
                // Blinn-Phong
                BlinnPhongSpecular = pow(max(0, dot(input.normalWS, halfDir)), _BlinnPhongSpecularGloss) * _BlinnPhongSpecularIntensity * MetalMask;
                // 金属高光
                float2 MetalMapUV = mul((float3x3) UNITY_MATRIX_V, input.normalWS).xy * 0.5 + 0.5;

                float MetalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, MetalMapUV).r;

                MetalMap = step(_MetalSpecularGloss, MetalMap);

                MetalSpecular = MetalMap * _MetalSpecularIntensity * MetalMask * _EnableMetalSpecular;
                
                FinalSpecular = StepSpecular + BlinnPhongSpecular + MetalSpecular;
                FinalSpecular = lerp(0, baseColor * FinalSpecular * _SpecularColor, SpecularIntensityMask) ;
                FinalSpecular *= halfLambert * _RampShadowRange * _SpecMulti *_EnableSpecular;

                half4 SpecDiffuse;
                SpecDiffuse.rgb = FinalSpecular.rgb + FinalColor.rgb;
                SpecDiffuse.rgb *= _MainColor.rgb;
                SpecDiffuse.a = FinalSpecular.a * _BloomFactor * 10;

                //==========================================================================================
                // 屏幕空间深度等宽边缘光
                // 屏幕空间UV
                float2 RimScreenUV = float2(input.positionCS.x / _ScreenParams.x, input.positionCS.y / _ScreenParams.y);
                // 法线外扩偏移UV，把worldNormal转换到NDC空间
                float3 smoothNormal = normalize(UnpackNormalmapRGorAG(input.color));
                float3x3 tangentTransform = float3x3(input.worldTangent, input.worldBiTangent, input.normalWS);
                float3 worldRimNormal = normalize(mul(smoothNormal, tangentTransform));
                float2 RimOffsetUV = float2(mul((float3x3) UNITY_MATRIX_V, worldRimNormal).xy * _RimOffsets * 0.01 / input.positionCS.w);
                RimOffsetUV += RimScreenUV;
                
                float ScreenDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, RimScreenUV);
                float Linear01ScreenDepth = LinearEyeDepth(ScreenDepth, _ZBufferParams);
                float OffsetDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, RimOffsetUV);
                float Linear01OffsetDepth = LinearEyeDepth(OffsetDepth, _ZBufferParams);

                float diff = Linear01OffsetDepth - Linear01ScreenDepth;
                float rimMask = step(_RimThresholds * 0.1, diff);
                // 边缘光颜色的a通道用来控制边缘光强弱
                half4 RimColors = float4(rimMask * _RimColors.rgb * _RimColors.a, 1) * _EnableRims;

                // Rim Light
                float lambertF = dot(mainLight.direction, input.normalWS);
                float lambertD = max(0, -lambertF);
                lambertF = max(0, lambertF);
                float rim = 1 - saturate(dot(viewDirWS, input.normalWS));

                float rimDot = pow(rim, _RimPow);
                rimDot = _EnableLambert * lambertF * rimDot + (1 - _EnableLambert) * rimDot;
                float rimIntensity = smoothstep(0, _RimSmooth, rimDot);
                half4 Rim = _EnableRim * pow(rimIntensity, 5) * _RimColor * baseColor;
                Rim.a = _EnableRim * rimIntensity * _BloomFactor;

                rimDot = pow(rim, _DarkSideRimPow);
                rimDot = _EnableLambert * lambertD * rimDot + (1 - _EnableLambert) * rimDot;
                rimIntensity = smoothstep(0, _DarkSideRimSmooth, rimDot);
                half4 RimDS = _EnableRimDS * pow(rimIntensity, 5) * _DarkSideRimColor * baseColor;
                RimDS.a = _EnableRimDS * rimIntensity * _BloomFactor;

                // Emission & Bloom
                half4 Emission;
                Emission.rgb = _Emission * DarkShadowColor.rgb * _EmissionColors.rgb - SpecDiffuse.rgb;
                Emission.a = _EmissionBloomFactor * baseColor.a;

                half4 SpecRimEmission;
                SpecRimEmission.rgb = pow(DarkShadowColor, 1) * _Emission;
                SpecRimEmission.a = (SpecDiffuse.a + Rim.a + RimDS.a);

                FinalColor = SpecDiffuse + Rim + RimColors + Emission.a * Emission + SpecRimEmission.a * SpecRimEmission;

                FinalColor = (_WorldLightInfluence * LightColor * FinalColor + (1 - _WorldLightInfluence) * FinalColor);

                return FinalColor;
            }
            ENDHLSL

        }

        Pass
        {
            Name "CHARACTER_OUTLINE"
            Tags {  }
            Cull Front
            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // #pragma shader_feature_local ENABLE_AUTOCOLOR
            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            float4 OutlinePassFragment(v2f input): COLOR
            {
                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
                half4 FinalColor = _OutlineColor * baseColor;

                return FinalColor;
            }

            ENDHLSL

        }
        
        //this Pass copy from https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            //we don't care about color, we just write to depth
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex ShadowCasterPassVertex
            #pragma fragment ShadowCasterPassFragment        
            
            half4 ShadowCasterPassFragment(v2f input): SV_TARGET
            {
                return 0;
            }

            ENDHLSL

        }
        
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment FragmentAlphaClip
            
            ENDHLSL

        }         

        //【pass：深度】
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
        
        pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            ColorMask 0

            HLSLPROGRAM

            #pragma target 3.5
            //是否剔除的shader feature
            #pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
            //GPU需要CPU给它的数组数据
            #pragma multi_compile_instancing
            //设置LOD
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"//函数库：主要用于各种的空间变换
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"//从unity中取得我们的光照
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            //...
        }
    }
}
