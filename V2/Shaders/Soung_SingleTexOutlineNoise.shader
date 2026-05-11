//基于 Soung/Effect/SingleTex 扩展
//新增：更大范围描边（8方向采样）+ 噪波扰动描边边缘（贴图/ValueNoise/Voronoi可选）
//修改于2026.4.11
Shader "Soung/Effect/SingleTexOutlineNoise"
{
    Properties
    {
        [Header(MainTex)]_MainTex("贴图", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 0
        [IntRange]_RotatorVal("贴图旋转", Range( 0 , 360)) = 0
        _TexScale("贴图缩放", Range( 0 , 5)) = 1

        [Header(Outline)]
        [Toggle(_USE_OUTLINE)] _EnableOutline("启用描边", Float) = 0
        _lineWidth("描边宽度 (向内裁切,仅对透明图生效)", Range(0, 0.5)) = 0

        [Header(Outline Noise Distortion)]
        _NoiseTex("噪波贴图 (NoiseTexture模式使用)", 2D) = "white" {}
        [Enum(NoiseTexture,0,ValueNoise,1,Voronoi,2)] _NoiseType("噪波类型", Float) = 1
        _NoiseScale("噪波缩放", Range(0.1, 20)) = 5
        _DistortStrength("扰动强度", Range(0, 0.1)) = 0.01
        _DistortSpeedU("扰动速率U", Range(-5, 5)) = 1
        _DistortSpeedV("扰动速率V", Range(-5, 5)) = 0
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
            Tags { "LightMode" = "SRPDefaultUnlit" }

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma multi_compile_instancing
            #pragma shader_feature_local _USE_OUTLINE

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _BlendMode;
                float _CullingMode;
                float _RotatorVal;
                float _TexScale;
                float _SwitchP;
                float _lineWidth;
                // 噪波扰动参数
                float4 _NoiseTex_ST;
                float _NoiseType;
                float _NoiseScale;
                float _DistortStrength;
                float _DistortSpeedU;
                float _DistortSpeedV;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            #if defined(_USE_OUTLINE)
                // ---- Value Noise ----
                float hashVN(float2 p)
                {
                    p = frac(p * float2(127.1, 311.7));
                    p += dot(p, p + 45.32);
                    return frac(p.x * p.y);
                }

                float valueNoiseVN(float2 uv)
                {
                    float2 i = floor(uv);
                    float2 f = frac(uv);
                    float2 u = f * f * (3.0 - 2.0 * f);
                    float a = hashVN(i);
                    float b = hashVN(i + float2(1.0, 0.0));
                    float c = hashVN(i + float2(0.0, 1.0));
                    float d = hashVN(i + float2(1.0, 1.0));
                    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
                }

                // ---- Voronoi ----
                float2 voronoiHashVO(float2 p)
                {
                    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                    return frac(sin(p) * 43758.5453);
                }

                float voronoiVO(float2 v, float time)
                {
                    float2 n = floor(v);
                    float2 f = frac(v);
                    float F1 = 8.0;
                    int i, j;
                    for (j = -1; j <= 1; j++)
                    {
                        for (i = -1; i <= 1; i++)
                        {
                            float2 g = float2(i, j);
                            float2 o = voronoiHashVO(n + g);
                            o = (sin(time + o * 6.2831) * 0.5 + 0.5);
                            float2 r = f - g - o;
                            float d = 0.5 * dot(r, r);
                            if (d < F1)
                            {
                                F1 = d;
                            }
                        }
                    }
                    return F1;
                }

                // ---- 采样噪波（贴图/ValueNoise/Voronoi）返回 [0,1] ----
                float sampleNoise(float2 noiseUV, float noiseType)
                {
                    float noiseVal;
                    if (noiseType < 0.5)
                    {
                        // 贴图噪波 (NoiseTexture)，应用 _NoiseTex 的 Tiling & Offset
                        noiseVal = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV * _NoiseTex_ST.xy + _NoiseTex_ST.zw).r;
                    }
                    else if (noiseType < 1.5)
                    {
                        // Value Noise
                        noiseVal = valueNoiseVN(noiseUV);
                    }
                    else
                    {
                        // Voronoi —— F1 范围约 [0, 0.5]，归一化到 [0, 1]
                        noiseVal = saturate(voronoiVO(noiseUV, _Time.y) * 2.0);
                    }
                    return noiseVal;
                }
            #endif

            struct a2v
            {
                float4 vertex : POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float4 ase_texcoord1 : TEXCOORD0;
                float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f VERT(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.ase_texcoord1.xy = v.ase_texcoord.xy;
                o.ase_color = v.ase_color;
                o.ase_texcoord1.zw = 0;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.clipPos = TransformWorldToHClip(positionWS);

                return o;
            }

            float4 FRAG(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float3 baseColorRGB = _BaseColor.rgb;
                float baseColorA = _BaseColor.a;
                float3 vertexColorRGB = IN.ase_color.rgb;
                float vertexColorA = IN.ase_color.a;

                float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 finalUV;

                if (abs(_RotatorVal) > 0.001)
                {
                    float angle = (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0));
                    float2x2 rotMatrix;
                    sincos(angle, rotMatrix._21, rotMatrix._11);
                    rotMatrix._12 = -rotMatrix._21;
                    rotMatrix._22 = rotMatrix._11;
                    float2 rotator51 = mul(uv_MainTex - float2(0.5, 0.5), rotMatrix) + float2(0.5, 0.5);
                    finalUV = ((rotator51 * _TexScale) + -(_TexScale * 0.5) + 0.5);
                }
                else
                {
                    finalUV = ((uv_MainTex * _TexScale) + -(_TexScale * 0.5) + 0.5);
                }

                // 主贴图采样 —— 使用干净的 finalUV，不受噪波扰动
                float4 tex2DNode1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV);

                if (tex2DNode1.a <= 0.0)
                {
                    discard;
                }

                float lerpResult5 = lerp(tex2DNode1.r, tex2DNode1.a, _SwitchP);
                float baseAlpha = lerpResult5 * baseColorA * vertexColorA;

                if (baseAlpha <= 0.001)
                {
                    discard;
                }

                float outlineAlpha = 0.0;
                #if defined(_USE_OUTLINE)
                    if (_lineWidth > 0.001)
                    {
                        // 噪波调制有效描边宽度，每个像素的裁切深度随噪波变化，自然形成波浪不规则边缘
                        float2 noiseUV = finalUV * _NoiseScale + float2(_Time.y * _DistortSpeedU, _Time.y * _DistortSpeedV);
                        float noiseVal = sampleNoise(noiseUV, _NoiseType);
                        float n = noiseVal * 2.0 - 1.0;

                        // 噪波调制后的描边宽度（clamp 防止负値导致采样翻转）
                        float lineW = max(_lineWidth + n * _DistortStrength, 0.0);
                        float lineD = lineW * 0.7071;

                        float aUp    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(0,       lineW)).a;
                        float aDown  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(0,      -lineW)).a;
                        float aLeft  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(-lineW,  0    )).a;
                        float aRight = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2( lineW,  0    )).a;
                        float aUL    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(-lineD,  lineD)).a;
                        float aUR    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2( lineD,  lineD)).a;
                        float aDL    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(-lineD, -lineD)).a;
                        float aDR    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2( lineD, -lineD)).a;

                        float mainA = tex2DNode1.a;
                        outlineAlpha = max(max(max(max(max(max(max(
                            saturate(mainA - aUp),
                            saturate(mainA - aDown)),
                            saturate(mainA - aLeft)),
                            saturate(mainA - aRight)),
                            saturate(mainA - aUL)),
                            saturate(mainA - aUR)),
                            saturate(mainA - aDL)),
                            saturate(mainA - aDR));
                    }
                #endif

                float3 finalColor = tex2DNode1.rgb;

                float3 allColor = finalColor * baseColorRGB * vertexColorRGB;

                float3 Color = allColor;

                // 描边区域透明（outlineAlpha=1 处 alpha 归零，形成噪波裁切边缘）
                float Alpha = lerpResult5 * (1.0 - outlineAlpha) * baseColorA * vertexColorA;

                return float4(Color, saturate(Alpha));
            }
            ENDHLSL
        }
    }
}
