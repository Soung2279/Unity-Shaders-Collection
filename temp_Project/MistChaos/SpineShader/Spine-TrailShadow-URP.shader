Shader "Universal Render Pipeline/Spine/TrailShadow" {
    Properties {
        [NoScaleOffset] _MainTex("Spine图集", 2D) = "black" {}
        [Header(Settings)][Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("使用图集Alpha值", Int) = 0   //与SpineShader一致
        
        [Header(Trail Settings)]
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 10  //默认为AlphaBlend模式
        [HDR]_TrailColor("残影颜色", Color) = (1,1,1,0.5)
        _TrailAlpha("残影透明度", Range(0, 1)) = 0.5
        _TrailIntensity("残影强度", Range(0, 2)) = 1.0
        
        [Header(Distortion Settings)]
        [Toggle(_ENABLE_EDGE_DISTORTION)] _EnableEdgeDistortion("启用扰动", Int) = 0    //默认关闭扰动, 有需求再添加
        _DistortionTex("扰动纹理", 2D) = "gray" {}
        _EdgeDistortionStrength("扰动强度", Range(0, 0.1)) = 0.02
        _EdgeDistortionSpeed("扰动速度", Vector) = (1, 0.5, 0, 0)
    }

    SubShader 
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
            "Queue"="Transparent-10" //控制渲染队列始终低于Spine对象.
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "UniversalMaterialType"="Unlit"
        }

        Cull Off
        ZWrite Off
        ZTest LEqual
        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        
        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _DistortionTex_ST;
        float _BlendMode;
        half4 _TrailColor;
        half _TrailAlpha;
        half _TrailIntensity;
        half _EdgeDistortionStrength;
        half2 _EdgeDistortionSpeed;
        CBUFFER_END

        sampler2D _MainTex;
        sampler2D _DistortionTex;

        ENDHLSL

        Pass {
            Name "Forward"
            Tags{"LightMode" = "SRPDefaultUnlit"}

            HLSLPROGRAM
            #pragma multi_compile_instancing

            #pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
            #pragma shader_feature _ _ENABLE_EDGE_DISTORTION

            #pragma vertex vert
            #pragma fragment frag

            #define USE_URP
            #define fixed4 half4
            #define fixed3 half3
            #define fixed half

            #include "Include/SpineCoreShaders/Spine-Common.cginc"

            struct appdata {
                float3 pos : POSITION;
                half4 color : COLOR;
                float2 uv0 : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                half4 color : COLOR0;
                float2 uv0 : TEXCOORD0;
                float4 pos : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert(appdata v) {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 localPos = v.pos;

            #if defined(_ENABLE_EDGE_DISTORTION)
                float2 distortionUV = v.uv0 + _EdgeDistortionSpeed * _Time.y;
                float2 distortionSample = tex2Dlod(_DistortionTex, float4(distortionUV, 0, 0)).xy;
                float2 distortion = (distortionSample - 0.5) * 2.0;
                float3 distortionOffset = float3(distortion.x, distortion.y, 0) * _EdgeDistortionStrength;
                localPos += distortionOffset;
            #endif

                float3 positionWS = TransformObjectToWorld(localPos);
                o.pos = TransformWorldToHClip(positionWS);
                
                o.uv0 = v.uv0;
                o.color = PMAGammaToTargetSpace(v.color);

                return o;
            }

            half4 frag(VertexOutput i) : SV_Target {
                float4 texColor = tex2D(_MainTex, i.uv0);
                clip(texColor.a * i.color.a - 0.01);

            #if defined(_STRAIGHT_ALPHA_INPUT)
                 texColor.rgb *= texColor.a;
            #endif

                float3 baseColor = texColor.rgb * i.color.rgb;
                float baseAlpha = texColor.a * i.color.a;
                
                // 应用残影效果
                float3 trailTintedColor = lerp(baseColor, _TrailColor.rgb * baseAlpha, _TrailColor.a);
                
                // 应用残影透明度和强度
                float finalAlpha = baseAlpha * _TrailAlpha * _TrailIntensity;
                float3 finalColor = trailTintedColor;
                
                return half4(finalColor, finalAlpha);
            }
            ENDHLSL
        }
    }
}