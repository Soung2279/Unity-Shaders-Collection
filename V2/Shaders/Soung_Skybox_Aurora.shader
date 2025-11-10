//made by Soung, 2025.11.10
Shader "Soung/Skybox/Aurora"
{
    Properties
    {
        _TimeScale("时间缩放", Range(0.1, 3.0)) = 1.0
        _Exposure("曝光", Range(0.5, 3.0)) = 1.8
        _StarIntensity("星星强度", Range(0, 2)) = 1.0
        _AuroraHeight("极光高度", Range(-2, 2)) = 0.8
        _AuroraHueShift("极光色相偏移", Range(0, 1)) = 0.0
        _AuroraSaturation("极光饱和度", Range(0, 2)) = 1.0
        _AuroraSteps("极光采样次数", Range(10, 100)) = 50
        [IntRange] _Rotation("天空球旋转角度", Range(0, 360)) = 0
    }

    SubShader
    {
        Tags 
        { 
            "Queue" = "Background" 
            "RenderType" = "Background" 
            "PreviewType" = "Skybox"
            "RenderPipeline" = "UniversalPipeline"
        }
        
        Cull Off
        ZWrite Off

        Pass
        {
            Name "Skybox"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half _TimeScale;
                half _Exposure;
                half _StarIntensity;
                half _AuroraHeight;
                half _AuroraSteps;
                half _AuroraHueShift;
                half _AuroraSaturation;
                int _Rotation;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 viewDir : TEXCOORD0;
            };

            // === 3D 旋转函数（绕 Y 轴）===
            float3 rotateAroundY(float3 dir, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float3x3 rotMatrix = float3x3(
                    c,  0, s,
                    0,  1, 0,
                    -s, 0, c
                );
                return mul(rotMatrix, dir);
            }

            // === RGB 转 HSV ===
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            // === HSV 转 RGB ===
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            // === 辅助函数（内部保持 float 精度）===
            float2x2 mm2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, s, -s, c);
            }

            // 静态常量
            static const float2x2 m2 = float2x2(0.95534, 0.29552, -0.29552, 0.95534);

            float tri(float x)
            {
                return clamp(abs(frac(x) - 0.5), 0.01, 0.49);
            }

            float2 tri2(float2 p)
            {
                return float2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x)));
            }

            // 三角噪声函数（核心计算用 float）
            float triNoise2d(float2 p, float spd)
            {
                // 时间计算使用 CBUFFER 中的参数
                float time = _Time.y * _TimeScale;
                float z = 1.8;
                float z2 = 2.5;
                float rz = 0.0;

                p = mul(mm2(p.x * 0.06), p);
                float2 bp = p;

                // 固定循环次数（编译器可优化）
                for (int i = 0; i < 5; i++)
                {
                    float2 dg = tri2(bp * 1.85) * 0.75;
                    dg = mul(mm2(time * spd), dg);
                    p -= dg / z2;
                    bp *= 1.3;
                    z2 *= 0.45;
                    z *= 0.42;
                    p *= 1.21 + (rz - 1.0) * 0.02;
                    rz += tri(p.x + tri(p.y)) * z;
                    p = mul(-m2, p);
                }

                return clamp(1.0 / pow(rz * 29.0, 1.3), 0.0, 0.55);
            }

            // Hash 函数
            float hash21(float2 n)
            {
                return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
            }

            // 极光主函数（返回 half4 优化性能）
            half4 aurora(float3 ro, float3 rd)
            {
                half4 col = half4(0, 0, 0, 0);
                half4 avgCol = half4(0, 0, 0, 0);

                // 使用可调节的采样次数
                int maxSteps = (int)_AuroraSteps;
                
                for (int i = 0; i < maxSteps; i++)
                {
                    float fi = (float)i; // 转换为 float 用于计算
                    
                    float of = 0.006 * hash21(float2(fi, fi * 2.0)) * smoothstep(0.0, 15.0, fi);
                    float pt = ((_AuroraHeight + pow(fi, 1.4) * 0.002) - ro.y) / (rd.y * 2.0 + 0.4);
                    pt -= of;

                    float3 bpos = ro + pt * rd;
                    float2 p = bpos.xz;
                    float rzt = triNoise2d(p, 0.06);

                    half4 col2 = half4(0, 0, 0, rzt);
                    
                    // === 原始颜色计算 ===
                    half3 colorBase = (sin(1.0 - half3(2.15, -0.5, 1.2) + fi * 0.043) * 0.5 + 0.5);
                    
                    // === 应用色相偏移和饱和度 ===
                    // 转换到 HSV 空间
                    float3 hsv = rgb2hsv(colorBase);
                    
                    // 应用色相偏移（0-1 范围循环）
                    hsv.x = frac(hsv.x + _AuroraHueShift);
                    
                    // 应用饱和度调整
                    hsv.y *= _AuroraSaturation;
                    hsv.y = saturate(hsv.y); // 限制在 0-1
                    
                    // 转回 RGB
                    colorBase = hsv2rgb(hsv);
                    // === 色相偏移结束 ===
                    
                    col2.rgb = colorBase * rzt;
                    
                    avgCol = lerp(avgCol, col2, 0.5);
                    col += avgCol * exp2(-fi * 0.065 - 2.5) * smoothstep(0.0, 5.0, fi);
                }

                col *= clamp(rd.y * 15.0 + 0.4, 0.0, 1.0);
                return col * _Exposure;
            }

            // Hash 函数用于星星
            float3 nmzHash33(float3 q)
            {
                uint3 p = uint3(int3(q));
                p = p * uint3(374761393U, 1103515245U, 668265263U) + p.zxy + p.yzx;
                p = p.yzx * (p.zxy ^ (p >> 3U));
                return float3(p ^ (p >> 16U)) * (1.0 / float(0xffffffffU));
            }

            // 星星函数（返回 half3 优化）
            half3 stars(float3 p)
            {
                half3 c = half3(0, 0, 0);
                float res = 1024.0;

                // 固定循环 4 次
                for (int i = 0; i < 4; i++)
                {
                    float3 q = frac(p * (0.15 * res)) - 0.5;
                    float3 id = floor(p * (0.15 * res));
                    float2 rn = nmzHash33(id).xy;
                    
                    float c2 = 1.0 - smoothstep(0.0, 0.6, length(q));
                    c2 *= step(rn.x, 0.0005 + i * i * 0.001);
                    
                    half3 starColor = lerp(half3(1.0, 0.49, 0.1), half3(0.75, 0.9, 1.0), rn.y) * 0.1 + 0.9;
                    c += c2 * starColor;
                    
                    p *= 1.3;
                }

                return c * c * 0.8 * _StarIntensity;
            }

            // 背景渐变（返回 half3）
            half3 bg(float3 rd)
            {
                float sd = dot(normalize(float3(-0.5, -0.6, 0.9)), rd) * 0.5 + 0.5;
                sd = pow(sd, 5.0);
                half3 col = lerp(half3(0.05, 0.1, 0.2), half3(0.1, 0.05, 0.2), sd);
                return col * 0.63;
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                
                // URP 顶点变换
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                
                // === 应用天空球旋转 ===
                float rotAngle = radians(_Rotation);
                output.viewDir = rotateAroundY(input.texcoord, rotAngle);
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // 方向向量保持 float 精度
                float3 rd = normalize(input.viewDir);
                float3 ro = float3(0, 0, -6.7);

                // 最终颜色用 half3
                half3 col = half3(0, 0, 0);
                float3 brd = rd;
                float fade = smoothstep(0.0, 0.01, abs(brd.y)) * 0.1 + 0.9;

                // 背景渐变
                col = bg(rd) * fade;

                if (rd.y > 0)
                {
                    // 上半球：极光 + 星星
                    half4 aur = smoothstep(0.0, 1.5, aurora(ro, rd)) * fade;
                    col += stars(rd);
                    col = col * (1.0 - aur.a) + aur.rgb;
                }
                else 
                {
                    // 下半球：反射效果
                    rd.y = abs(rd.y);
                    col = bg(rd) * fade * 0.6;
                    half4 aur = smoothstep(0.0, 2.5, aurora(ro, rd));
                    col += stars(rd) * 0.1;
                    col = col * (1.0 - aur.a) + aur.rgb;

                    // 地面反射
                    float3 pos = ro + ((0.5 - ro.y) / rd.y) * rd;
                    float nz2 = triNoise2d(pos.xz * float2(0.5, 0.7), 0.0);
                    col += lerp(half3(0.2, 0.25, 0.5) * 0.08, half3(0.3, 0.3, 0.5) * 0.7, nz2 * 0.4);
                }

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Skybox/Procedural"
}