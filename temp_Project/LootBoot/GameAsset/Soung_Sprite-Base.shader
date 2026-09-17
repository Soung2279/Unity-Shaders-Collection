Shader "Soung/2D/SpriteBase"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        [HDR] _BaseColor("基础填充色(_BaseColor)", Color) = (1,1,1,1)
        _BaseColorPhase("填充进度(_BaseColorPhase)", Range(0,1)) = 0

        // SpriteRenderer legacy compatibility properties.
        [HideInInspector] _Color("Tint", Color) = (1,1,1,1)
        [HideInInspector] PixelSnap("Pixel Snap", Float) = 0
        [HideInInspector] _RendererColor("Renderer Color", Color) = (1,1,1,1)
        [HideInInspector] _Flip("Flip", Vector) = (1,1,1,1)
        [HideInInspector] _AlphaTex("External Alpha", 2D) = "white" {}
        [HideInInspector] _EnableExternalAlpha("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            Tags { "LightMode"="Universal2D" }

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex UnlitVertex
            #pragma fragment UnlitFragment

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _BaseColor;
                half _BaseColorPhase;
            CBUFFER_END

            float4 _Color;
            half4 _RendererColor;

            Varyings UnlitVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color * _Color * _RendererColor;
                return output;
            }

            half4 UnlitFragment(Varyings input) : SV_Target
            {
                half4 spriteColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half finalAlpha = spriteColor.a * input.color.a;
                if (finalAlpha <= 0.01h)
                    discard;

                half3 filledRgb = lerp(spriteColor.rgb, _BaseColor.rgb, _BaseColorPhase);
                return half4(filledRgb * input.color.rgb, finalAlpha);
            }
            ENDHLSL
        }
    }

    Fallback "Sprites/Default"
}
