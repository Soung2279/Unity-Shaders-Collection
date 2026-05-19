Shader "Soung/Effect/SpRaymarchBackground"
{
    Properties
    {
        _TimeScale ("时间速度", Float) = 1.0
        _Brightness ("亮度", Float) = 1.0
        _ToneMapDiv ("Tonemap分母", Float) = 20000.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Tags { "LightMode"="SRPDefaultUnlit" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _TimeScale;
                float _Brightness;
                float _ToneMapDiv;
            CBUFFER_END

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }

            float2x2 BuildHappyAccidentMat(float4 v)
            {
                return float2x2(cos(v.x), cos(v.y), cos(v.z), cos(v.w));
            }

            half4 frag(Varyings i) : SV_Target
            {
                float2 iResolution = _ScreenParams.xy;
                float iTime = _Time.y * _TimeScale;

                float2 C = i.uv * iResolution;
                float z = frac(dot(C, sin(C))) - 0.5;
                float d = 0.0;

                float4 o = 0.0;
                float4 O = 0.0;
                float4 p = 0.0;

                [loop]
                for (int iter = 0; iter < 77; iter++)
                {
                    float2 r = iResolution;
                    float3 rayDir = normalize(float3(C - 0.5 * r, r.y));

                    p = float4(z * rayDir, 0.1 * iTime);
                    p.z += iTime;

                    O = p;

                    p.xy = mul(p.xy, BuildHappyAccidentMat(2.0 + O.z + float4(0.0, 11.0, 33.0, 0.0)));
                    p.xy = mul(p.xy, BuildHappyAccidentMat(O + float4(0.0, 11.0, 33.0, 0.0)));

                    O = (1.0 + sin(0.5 * O.z + length(p - O) + float4(0.0, 4.0, 3.0, 6.0)))
                        / (0.5 + 2.0 * dot(O.xy, O.xy));

                    p = abs(frac(p) - 0.5);

                    d = abs(min(length(p.xy) - 0.125, min(p.x, p.y) + 1e-3)) + 1e-3;

                    o += O.w / d * O;
                    z += 0.6 * d;
                }

                float4 col = tanh(o / max(_ToneMapDiv, 1.0));
                col.rgb *= _Brightness;
                col.a = 1.0;
                return col;
            }
            ENDHLSL
        }
    }
}