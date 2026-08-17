Shader "VFX/Utility/EffectMeshPreview"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _UseTexture ("Use Texture", Float) = 0
        _UseSideColor ("Use Side Color", Float) = 1
        _UVOffset ("UV Offset", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "Preview"
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            ZWrite On
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _UseTexture;
                float _UseSideColor;
                float4 _UVOffset;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex) + _UVOffset.xy;
                output.color = input.color;
                return output;
            }
            half4 frag(Varyings input, bool isFrontFace : SV_IsFrontFace) : SV_Target
            {
                half4 textureColor = lerp(half4(1, 1, 1, 1), SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, frac(input.uv)), _UseTexture);
                half3 sideColor = isFrontFace ? half3(0.08, 0.85, 0.22) : half3(0.95, 0.12, 0.08);
                sideColor = lerp(half3(1, 1, 1), sideColor, _UseSideColor);
                half alpha = saturate(textureColor.a * _BaseColor.a * input.color.a);
                return half4(textureColor.rgb * _BaseColor.rgb * sideColor, alpha);
            }
            ENDHLSL
        }
    }
}
