Shader "Soung/Effect/SpTeleportBackground"
{
    Properties
    {
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 10
        _Brightness ("亮度", Float) = 1.0
        [HDR]_LineColor ("粒子线颜色", Color) = (1, 1, 1, 1)
        _Progress ("动画进度(0-1)", Range(0, 1)) = 0.0
        [Toggle]_UseCustom1Progress ("使用顶点流Custom1.x进度", Float) = 0
        [Toggle]_UseLocalUV ("使用本地UV", Float) = 0
        _ScreenUV_ST ("屏幕UV TilingOffset(xy/zw)", Vector) = (1, 1, 0, 0)
        _RayCount ("光线数量", Range(1, 80)) = 80
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha

        Pass
        {
            Tags { "LightMode"="SRPDefaultUnlit" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define FLARE 1

            static const float TAU = 6.28318;
            static const float NUM_SLICES = 125.0;
            static const float MAX_SLICE_OFFSET = 0.4;
            static const float T_MAX = 2.0;
            static const float T_JUMP = 0.75;
            static const float JUMP_SPEED = 15.0;

            static const float3 blue_col = float3(0.3, 0.3, 0.5);
            static const float3 white_col = float3(0.85, 0.85, 0.9);
            static const float3 flare_col = float3(0.9, 0.9, 1.4);

            CBUFFER_START(UnityPerMaterial)
                float _Brightness;
                float4 _LineColor;
                float _Progress;
                float _UseCustom1Progress;
                float _UseLocalUV;
                float4 _ScreenUV_ST;
                float _RayCount;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 custom1 : TEXCOORD1;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float custom1x : TEXCOORD2;
                float4 vertexColor : COLOR;
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.screenPos = ComputeScreenPos(o.positionHCS);
                o.uv = v.uv;
                o.custom1x = v.custom1.x;
                o.vertexColor = v.color;
                return o;
            }

            float rand(float2 co)
            {
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }

            float sdLine(float2 p, float2 a, float2 b, float ring)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h) - ring;
            }

            float3 lensflare(float3 uv, float3 pos, float flare_size, float ang_offset)
            {
                float z = uv.z / max(length(uv.xy), 1e-5);
                float2 main = uv.xy - pos.xy;
                float dist = length(main);
                float num_points = 2.71;
                float disk_size = 0.2;
                float inv_size = 1.0 / max(flare_size, 1e-4);
                float ang = atan2(main.y, main.x) + ang_offset;
                float fade = (z < 0.0) ? -z : 1.0;

                float f0 = 1.0 / (dist * inv_size + 1.0);
                f0 = f0 + f0 * (0.1 * sin((sin(ang * 2.0 + pos.x) * 4.0 - cos(ang * 3.0 + pos.y)) * num_points) + disk_size);

                if (z < 0.0)
                {
                    return clamp(lerp(float3(f0, f0, f0), float3(0.0, 0.0, 0.0), 0.75 * fade), 0.0, 1.0);
                }

                return float3(f0, f0, f0);
            }

            float3 cc(float3 color, float factor, float factor2)
            {
                float w = color.x + color.y + color.z;
                return lerp(color, float3(w, w, w) * factor, w * factor2);
            }

            half4 frag(Varyings i) : SV_Target
            {
                float2 resolution = _ScreenParams.xy;
                float2 screenUV = i.screenPos.xy / max(i.screenPos.w, 1e-5);
                screenUV = screenUV * _ScreenUV_ST.xy + _ScreenUV_ST.zw;
                float2 uv01 = (_UseLocalUV > 0.5) ? i.uv : screenUV;
                float2 fragCoord = uv01 * resolution;

                float progress = (_UseCustom1Progress > 0.5) ? i.custom1x : _Progress;
                float t = saturate(progress);

                float2 p = (2.0 * fragCoord.xy - resolution.xy) / min(resolution.x, resolution.y);
                p += float2(0.0, -0.2);
                float3 v = float3(p, 1.0);

                float fade = clamp(lerp(0.1, 1.1, t * 2.0), 0.0, 2.0);
                float3 color = 0.0;
                int rayCount = clamp((int)round(_RayCount), 1, 80);
                float rayRatio = (float)rayCount / 80.0;
                float dynamicSlices = lerp(20.0, NUM_SLICES, rayRatio);

                [loop]
                for (int layer = 0; layer < 80; layer++)
                {
                    if (layer >= rayCount)
                    {
                        break;
                    }

                    float iLayer = (float)layer;
                    float3 trail_color = 0.0;

                    float angle = atan2(v.y, v.x) / 3.14159265 / 2.0 + 0.13 * iLayer;
                    float slice = floor(angle * dynamicSlices);
                    float slice_fract = frac(angle * dynamicSlices);

                    float slice_offset = MAX_SLICE_OFFSET * rand(float2(slice, 4.0 + iLayer * 25.0)) - (MAX_SLICE_OFFSET * 0.5);
                    float dist = 10.0 * rand(float2(slice, 1.0 + iLayer * 10.0)) - 5.0;

                    float z = dist * v.z / max(length(v.xy), 1e-4);
                    float f = sign(dist);
                    if (abs(f) < 1e-5)
                    {
                        f = 1.0;
                    }

                    float fspeed = f * (0.1 * rand(float2(slice, 1.0 + iLayer * 10.0)) + iLayer * 0.01);
                    float fjump_speed = f * JUMP_SPEED;

                    float trail_start = 10.0 * rand(float2(slice, 0.0 + iLayer * 10.0)) - 5.0;
                    trail_start -= lerp(0.0, fjump_speed, smoothstep(T_JUMP, 1.0, t));
                    float trail_end = trail_start - t * fspeed;

                    float trail_x = smoothstep(trail_start, trail_end, z);
                    trail_color = lerp(blue_col, white_col, trail_x);
                    trail_color *= _LineColor.rgb;

                    float h = sdLine(
                        float2(slice_fract + slice_offset, z),
                        float2(0.5, trail_start),
                        float2(0.5, trail_end),
                        lerp(0.0, 0.015, t * z)
                    );

                    float threshold = 0.09;
                    h = (h < 0.01) ? 1.0 : 0.85 * smoothstep(threshold, 0.0, abs(h));
                    trail_color *= fade * h;
                    color = max(color, trail_color);
                }

            #if defined(FLARE)
                float flare_size = lerp(0.0, 0.1, smoothstep(0.35, T_JUMP + 0.2, t));
                flare_size += lerp(0.0, 20.0, smoothstep(T_JUMP + 0.05, 1.0, t));
                int flareCount = clamp((int)round(lerp(1.0, 6.0, rayRatio)), 1, 6);
                float3 flareAcc = 0.0;
                [loop]
                for (int fi = 0; fi < 6; fi++)
                {
                    if (fi >= flareCount)
                    {
                        break;
                    }

                    float ff = (float)fi;
                    float w = (ff + 1.0) / (float)flareCount;
                    float a = TAU * w + t * 0.35;
                    float2 offset = 0.02 * (1.0 - rayRatio + 0.25) * float2(cos(a), sin(a));
                    float size = flare_size * lerp(0.65, 1.0, w);
                    flareAcc += lensflare(v, float3(offset, 0.0), size, t + ff * 0.17);
                }

                float3 flare = flare_col * (flareAcc / (float)flareCount);
                color += cc(flare, 0.5, 0.1);
                color += lerp(0.0, 1.0, smoothstep(T_JUMP + 0.1, 1.0, t));
            #else
                color += lerp(0.0, 1.0, smoothstep(T_JUMP, 1.0, t));
            #endif

                color *= _Brightness;
                color *= i.vertexColor.rgb;
                float outAlpha = saturate(i.vertexColor.a * _LineColor.a);
                return half4(color, outAlpha);
            }
            ENDHLSL
        }
    }
}
