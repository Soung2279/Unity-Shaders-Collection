//made by Soung, 2025.11.10
Shader "Soung/Skybox/CloudSea"
{
    Properties
    {
        [Header(Cloud Sea)]
        [HDR] _TintColor("云层颜色", Color) = (1,2,6,0)
        
        _Brightness("亮度", Range(0.5, 2.0)) = 1.0
        _NoiseIntensity("噪声强度", Range(0.5, 2.0)) = 1.0
        _CloudSeaHeight("云海高度", Range(-5, 5)) = 0.0
        [Toggle] _UseEnergyBall("启用能量体", Float) = 1.0
        
        [Header(Camera Settings)]
        _TimeScale("时间缩放", Range(0.1, 2.0)) = 1.0
        _CameraSwayAmount("相机摇晃幅度", Range(0.0, 2.0)) = 1.0
        _SkyboxRotation("天空球旋转角度", Range(0, 360)) = 0
        
        [Header(Performance)]
        _RayMarchSteps("光线步进次数", Range(20, 150)) = 100
        _NoiseLayers("噪声层数", Range(2, 8)) = 6
        _NoiseStartFreq("噪声起始频率", Range(0.2, 1.0)) = 0.4
        _NoiseFreqMultiplier("噪声频率倍增", Range(1.2, 2.0)) = 1.4
        
        [Header(Aurora)]
        [Toggle] _EnableAurora("启用极光", Float) = 0.0
        _Exposure("极光曝光", Range(0.5, 3.0)) = 1.8
        _StarIntensity("星星强度", Range(0, 2)) = 1.0
        _AuroraHeight("极光高度", Range(-2, 2)) = 0.8
        _AuroraHueShift("极光色相偏移", Range(0, 1)) = 0.0
        _AuroraSteps("极光采样次数", Range(10, 50)) = 50
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Background"
            "Queue"="Background"
            "PreviewType"="Skybox"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma shader_feature _USEENERGYBALL_ON
            #pragma shader_feature _ENABLEAURORA_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _TintColor;
                half _Brightness;
                half _NoiseIntensity;
                half _CloudSeaHeight;
                half _TimeScale;
                half _CameraSwayAmount;
                half _SkyboxRotation;
                float _RayMarchSteps; //循环20-150, 使用Float精度
                half _NoiseLayers;
                half _NoiseStartFreq;
                half _NoiseFreqMultiplier;
                half _Exposure;
                half _StarIntensity;
                half _AuroraHeight;
                half _AuroraHueShift;
                half _AuroraSteps;
            CBUFFER_END

            // 2D旋转矩阵
            float2x2 rot2D(float angle)
            {
                float c = cos(angle);
                float s = sin(angle);
                return float2x2(c, -s, s, c);
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

            float2x2 mm2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, s, -s, c);
            }

            static float2x2 m2 = float2x2(0.95534, 0.29552, -0.29552, 0.95534);

            float tri(float x)
            {
                return clamp(abs(frac(x) - 0.5), 0.01, 0.49);
            }

            float2 tri2(float2 p)
            {
                return float2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x)));
            }

            float triNoise2d(float2 p, float spd)
            {
                float time = _Time.y * _TimeScale;
                float z = 1.8;
                float z2 = 2.5;
                float rz = 0.0;

                p = mul(mm2(p.x * 0.06), p);
                float2 bp = p;

                for (float i = 0.0; i < 5.0; i++)
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

            float hash21(float2 n)
            {
                return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
            }

            float4 aurora(float3 ro, float3 rd)
            {
                float4 col = float4(0, 0, 0, 0);
                float4 avgCol = float4(0, 0, 0, 0);

                for (float i = 0.0; i < _AuroraSteps; i++)
                {
                    float of = 0.006 * hash21(float2(i, i * 2.0)) * smoothstep(0.0, 15.0, i);
                    float pt = ((_AuroraHeight + pow(i, 1.4) * 0.002) - ro.y) / (rd.y * 2.0 + 0.4);
                    pt -= of;

                    float3 bpos = ro + pt * rd;
                    float2 p = bpos.xz;
                    float rzt = triNoise2d(p, 0.06);

                    float4 col2 = float4(0, 0, 0, rzt);
                    
                    // 原始颜色计算
                    float3 originalColor = (sin(1.0 - float3(2.15, -0.5, 1.2) + i * 0.043) * 0.5 + 0.5);
                    
                    // 转换到HSV空间
                    float3 hsv = rgb2hsv(originalColor);
                    
                    // 应用色相偏移（0-1范围循环）
                    hsv.x = frac(hsv.x + _AuroraHueShift);
                    
                    // 转回RGB
                    originalColor = hsv2rgb(hsv);
                    
                    col2.rgb = originalColor * rzt;
                    
                    avgCol = lerp(avgCol, col2, 0.5);
                    col += avgCol * exp2(-i * 0.065 - 2.5) * smoothstep(0.0, 5.0, i);
                }

                col *= clamp(rd.y * 15.0 + 0.4, 0.0, 1.0);
                return col * _Exposure;
            }

            float3 nmzHash33(float3 q)
            {
                uint3 p = uint3(int3(q));
                p = p * uint3(374761393U, 1103515245U, 668265263U) + p.zxy + p.yzx;
                p = p.yzx * (p.zxy ^ (p >> 3U));
                return float3(p ^ (p >> 16U)) * (1.0 / float(0xffffffffU));
            }

            float3 stars(float3 p)
            {
                float3 c = float3(0, 0, 0);
                float res = 1024.0;

                for (float i = 0.0; i < 4.0; i++)
                {
                    float3 q = frac(p * (0.15 * res)) - 0.5;
                    float3 id = floor(p * (0.15 * res));
                    float2 rn = nmzHash33(id).xy;
                    float c2 = 1.0 - smoothstep(0.0, 0.6, length(q));
                    c2 *= step(rn.x, 0.0005 + i * i * 0.001);
                    c += c2 * (lerp(float3(1.0, 0.49, 0.1), float3(0.75, 0.9, 1.0), rn.y) * 0.1 + 0.9);
                    p *= 1.3;
                }

                return c * c * 0.8 * _StarIntensity;
            }

            float3 bg(float3 rd)
            {
                float sd = dot(normalize(float3(-0.5, -0.6, 0.9)), rd) * 0.5 + 0.5;
                sd = pow(sd, 5.0);
                float3 col = lerp(float3(0.05, 0.1, 0.2), float3(0.1, 0.05, 0.2), sd);
                return col * 0.63;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                o.viewDir = v.texcoord;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _TimeScale * 0.5;
                
                // 计算相机摇晃偏移
                float2 swayOffset = float2(
                    cos(t * 0.4) * 0.3 * _CameraSwayAmount,
                    cos(t * 0.8) * 0.1 * _CameraSwayAmount
                );
                
                // 应用天空球旋转
                float3 rotatedViewDir = i.viewDir;
                float rotAngle = radians(_SkyboxRotation);
                rotatedViewDir.xz = mul(rot2D(rotAngle), rotatedViewDir.xz);
                
                // 应用相机摇晃到视角方向（影响极光）
                float3 swayedViewDir = rotatedViewDir;
                // 将2D摇晃转换为3D旋转
                swayedViewDir.xy += swayOffset * 0.3; // 缩放系数控制摇晃对极光的影响
                swayedViewDir = normalize(swayedViewDir);
                
                // 应用云海高度偏移（仅影响云层）
                float3 adjustedViewDir = rotatedViewDir;
                adjustedViewDir.y -= _CloudSeaHeight * 0.3;
                
                float2 u = adjustedViewDir.xy / (abs(adjustedViewDir.z) + 0.001);
                u *= 2.0;
                float d = 0.0;
                float a, e, s;
                float3 ep, p;
                float4 o = float4(0, 0, 0, 0);

                // 应用相机摇晃幅度到云层UV
                u += swayOffset;

                // === 优化后的云层Ray Marching ===
                float maxSteps = _RayMarchSteps;
                for (float iter = 0.0; iter < maxSteps; iter++)
                {
                    p = float3(u * d, d + t);

                    #ifdef _USEENERGYBALL_ON
                    // 启用能量体时计算能量体位置
                    ep = p - float3(
                        sin(sin(t) + t * 0.4) * 8.0,
                        sin(sin(t) + t * 0.2) * 2.0,
                        16.0 + t + cos(t) * 8.0
                    );
                    e = length(ep) - 0.1;
                    
                    float smoothFactor = smoothstep(0.0, 12.0, length(ep));
                    s = lerp(e * 0.02, 4.0 + p.y, smoothFactor);
                    #else
                    // 禁用能量体时使用固定步长
                    e = 1.0;
                    s = 4.0 + p.y;
                    #endif

                    // 动态噪声层数和频率
                    float maxFreq = _NoiseStartFreq * pow(_NoiseFreqMultiplier, _NoiseLayers - 1);
                    for (a = _NoiseStartFreq; a < maxFreq; a *= _NoiseFreqMultiplier)
                    {
                        float3 noiseCoord = p * a;
                        float3 cosVec = cos(t + 0.2 * p.z + noiseCoord);
                        s -= abs(dot(cosVec, 0.11 + p - p)) / a * _NoiseIntensity;
                    }

                    #ifdef _USEENERGYBALL_ON
                    // 启用能量体时使用原始逻辑
                    float accum = min(0.02 + 0.6 * abs(s), max(0.8 * e, 0.01));
                    d += accum;
                    float eClamped = max(e, 0.5);
                    o += 1.0 / (accum + eClamped * 2.0);
                    #else
                    // 禁用能量体时简化累积逻辑
                    float accum = 0.02 + 0.6 * abs(s);
                    accum = max(accum, 0.01);
                    d += accum;
                    o += 1.0 / (accum + 0.5);
                    #endif
                }
                
                float monnFactor = 1.0 / length(u - 0.65);
                o = tanh(_TintColor * o / 100.0 * monnFactor) * _Brightness;
                
                // === 添加完整极光效果（使用摇晃后的视角）===
                #ifdef _ENABLEAURORA_ON
                {
                    float3 rd = normalize(swayedViewDir); // 使用摇晃后的方向
                    float3 ro = float3(0, 0, -6.7);

                    float3 auroraCol = float3(0, 0, 0);
                    float3 brd = rd;
                    float fade = smoothstep(0.0, 0.01, abs(brd.y)) * 0.1 + 0.9;

                    // 背景渐变
                    auroraCol = bg(rd) * fade;

                    if (rd.y > 0)
                    {
                        // 上半球：极光 + 星星
                        float4 aur = smoothstep(0.0, 1.5, aurora(ro, rd)) * fade;
                        auroraCol += stars(rd);
                        auroraCol = auroraCol * (1.0 - aur.a) + aur.rgb;
                    }
                    else 
                    {
                        // 下半球：反射效果
                        rd.y = abs(rd.y);
                        auroraCol = bg(rd) * fade * 0.6;
                        float4 aur = smoothstep(0.0, 2.5, aurora(ro, rd));
                        auroraCol += stars(rd) * 0.1;
                        auroraCol = auroraCol * (1.0 - aur.a) + aur.rgb;

                        float3 pos = ro + ((0.5 - ro.y) / rd.y) * rd;
                        float nz2 = triNoise2d(pos.xz * float2(0.5, 0.7), 0.0);
                        auroraCol += lerp(float3(0.2, 0.25, 0.5) * 0.08, float3(0.3, 0.3, 0.5) * 0.7, nz2 * 0.4);
                    }

                    // 云层与极光混合
                    float cloudDensity = saturate((o.r + o.g + o.b) / 3.0);
                    cloudDensity = pow(cloudDensity, 0.6);
                    
                    o.rgb = lerp(auroraCol, o.rgb, cloudDensity);
                }
                #endif
                
                o.a = 1.0;
                return o;
            }
            ENDCG
        }
    }
    FallBack "Skybox/Procedural"
}
