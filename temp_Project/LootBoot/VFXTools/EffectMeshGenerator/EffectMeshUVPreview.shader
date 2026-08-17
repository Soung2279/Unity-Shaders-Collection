Shader "VFX/Utility/EffectMeshUVPreview"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _UseTexture ("Use Texture", Float) = 0
        _UVOffset ("UV Offset", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            ZWrite Off
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _UseTexture;
                float4 _UVOffset;
            CBUFFER_END
            struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; float4 color : COLOR; };
            struct Varyings { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; float alpha : TEXCOORD1; };
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex) + _UVOffset.xy;
                output.alpha = input.color.a;
                return output;
            }
            half4 frag(Varyings input) : SV_Target
            {
                half2 checkerUv = floor(input.uv * 10.0);
                half checker = fmod(checkerUv.x + checkerUv.y, 2.0);
                half3 checkerColor = lerp(half3(0.18, 0.22, 0.27), half3(0.32, 0.38, 0.45), checker);
                half4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, frac(input.uv));
                half3 color = lerp(checkerColor, textureColor.rgb, _UseTexture);
                half alpha = saturate(input.alpha * lerp(0.72, textureColor.a, _UseTexture));
                return half4(color, alpha);
            }
            ENDHLSL
        }
    }
}
