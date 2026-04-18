//修改于2026.4.10
Shader "Soung/Effect/BreathHalo"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1

        _MainTex("贴图", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 1

        [Header(Breath)]
        _BreathFreq("呼吸频率(次/秒)", Range(0.1, 10)) = 1.0
        _MinAlpha("最低透明度", Range(0, 1)) = 0.0
        _MaxAlpha("最高透明度", Range(0, 1)) = 1.0
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

        Cull [_CullingMode]
        AlphaToMask Off
        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        ZWrite Off
        ZTest LEqual
        Offset 0 , 0
        ColorMask RGBA

        Pass
        {
            Name "Universal2D"
            Tags { "LightMode" = "Universal2D" }

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _SwitchP;
                float _BreathFreq;
                float _MinAlpha;
                float _MaxAlpha;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct a2v
            {
                float4 vertex   : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos  : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f VERT(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.color = v.color;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.clipPos = TransformWorldToHClip(positionWS);

                return o;
            }

            float4 FRAG(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 采样贴图
                float4 texSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float texAlpha = lerp(texSample.r, texSample.a, _SwitchP);

                // 呼吸曲线：(1 - cos(t * freq * 2π)) / 2  =>  0 → 1 → 0 无缝循环
                float t = _Time.y * _BreathFreq * 6.28318530718;
                float breathAlpha = (1.0 - cos(t)) * 0.5;
                // 映射到 [_MinAlpha, _MaxAlpha] 区间
                breathAlpha = lerp(_MinAlpha, _MaxAlpha, breathAlpha);

                float finalAlpha = breathAlpha * texAlpha * _BaseColor.a * IN.color.a;
                float3 finalColor = texSample.rgb * _BaseColor.rgb * IN.color.rgb;

                return float4(finalColor, saturate(finalAlpha));
            }
            ENDHLSL
        }
    }
}
