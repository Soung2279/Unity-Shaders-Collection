//made by Soung, 2025.11.10
Shader "Soung/Skybox/Procedural"
{
    Properties
    {
        [Header(Aurora Settings)]
        _AuroraHeight ("极光高度", Range(-1, 1)) = 0.0
        _AuroraIntensity ("极光强度", Range(0, 5)) = 1.0
        _WaveStrength ("波浪扭曲", Range(0, 0.5)) = 0.1
        _NoiseScale ("噪声缩放", Range(0.1, 5)) = 1.0
        _NoiseOctaves ("噪声细节", Range(1, 6)) = 4

        [Header(Aurora Colors)]
        [HDR] _AuroraColor1 ("极光偏色1", Color) = (0.0, 1.0, 0.5, 1.0)
        [HDR] _AuroraColor2 ("极光偏色2", Color) = (1.0, 0.0, 1.0, 1.0)
        _ColorMix ("颜色混合", Range(0, 1)) = 0.5

        [Header(Star Settings)]
        _StarIntensity ("星星强度", Range(0, 5)) = 1.0
        _StarDensity ("星星密度", Range(0, 1)) = 0.04
        _StarSharpness ("星星锐度", Range(10, 200)) = 70.0
        _StarTwinkleSpeed ("星星闪烁速度", Range(0, 5)) = 2.5
        [HDR] _StarColor ("星星颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _StarColorVariation ("星星颜色变化", Range(0, 1)) = 0.2
        
        [Header(Skybox)]
        [IntRange] _Rotation ("天空球旋转", Range(0, 360)) = 0.0
        _ScrollSpeed ("扰动速度", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #include "UnityCG.cginc"

            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            CBUFFER_START(UnityPerMaterial)
                half _AuroraHeight;
                half _AuroraIntensity;
                half _WaveStrength;
                half _NoiseScale;
                int _NoiseOctaves;
                half4 _AuroraColor1;
                half4 _AuroraColor2;
                half _ColorMix;
                half _StarIntensity;
                half _StarDensity;
                half _StarSharpness;
                half _StarTwinkleSpeed;
                half4 _StarColor;
                half _StarColorVariation;
                int _Rotation;
                half _ScrollSpeed;
            CBUFFER_END
            
            #define TAU 6.2831853071

            float2 rotate2D(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotMatrix = float2x2(c, -s, s, c);
                uv -= 0.5;
                uv = mul(rotMatrix, uv);
                uv += 0.5;
                return uv;
            }
            
            float hash(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }
            
            float3 hash3(float2 p)
            {
                float3 p3 = frac(float3(p.xyx) * float3(443.897, 441.423, 437.195));
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.xxy + p3.yzz) * p3.zyx);
            }
            
            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                
                // 平滑插值
                f = f * f * (3.0 - 2.0 * f);
                
                // 四个角的随机值
                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));
                
                // 双线性插值
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }
            
            // 分形布朗运动 (FBM) - 多层噪声叠加
            float fbm(float2 p, int octaves)
            {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                // 使用传入的 int 参数，避免精度问题
                for(int i = 0; i < octaves; i++)
                {
                    value += amplitude * valueNoise(p * frequency);
                    frequency *= 2.0;
                    amplitude *= 0.5;
                }
                
                return value;
            }
            
            // Simplex-like 噪声（更平滑）
            float smoothNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                
                // 五次平滑插值
                f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
                
                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));
                
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }
            
            // 流动噪声 - 用于极光的动态效果
            float flowNoise(float2 p, float time)
            {
                float2 offset1 = float2(time * 0.3, time * 0.2);
                float2 offset2 = float2(-time * 0.4, time * 0.25);
                
                float noise1 = smoothNoise(p + offset1);
                float noise2 = smoothNoise(p * 1.3 + offset2);
                
                return (noise1 + noise2) * 0.5;
            }

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(VertexOutput i) : SV_Target
            {
                float2 uv = i.uv;
                uv = rotate2D(uv, _Rotation * UNITY_PI / 180.0);
                
                // 应用高度偏移
                float2 adjustedUV = uv;
                adjustedUV.y = uv.y + _AuroraHeight;
                
                // 时间计算
                float time = _Time.y * _ScrollSpeed;
                
                // 生成程序化噪声（替代第一张纹理）
                float2 noiseUV1 = adjustedUV * _NoiseScale * 0.25;
                float noise1 = flowNoise(noiseUV1, time * 0.5);
                
                // 生成第二层噪声（替代第二张纹理）
                float2 noiseUV2 = adjustedUV * _NoiseScale * 0.25 + float2(0.0, time * 0.02 + noise1 * 0.02);
                float noise2 = fbm(noiseUV2, _NoiseOctaves);
                float d = noise2 * 2.0 - 1.0;
                
                // 波浪效果
                float v = adjustedUV.y + d * _WaveStrength;
                v = 1.0 - abs(v * 2.0 - 1.0);
                v = pow(v, 2.0 + sin((time * 0.2 + d * 0.25) * TAU) * 0.5);
                
                // 极光颜色混合 (输出用 half3)
                half3 color = half3(0.0, 0.0, 0.0);
                
                float x = (1.0 - adjustedUV.x * 0.75);
                float y = 1.0 - abs(adjustedUV.y * 2.0 - 1.0);
                
                // 使用自定义颜色
                half3 auroraColor1 = _AuroraColor1.rgb * x * 0.5;
                half3 auroraColor2 = _AuroraColor2.rgb * y;
                half3 auroraColor = lerp(auroraColor1, auroraColor2, _ColorMix * y);
                
                // 添加噪声变化到颜色
                float colorVariation = noise1 * 0.3 + 0.7;
                auroraColor *= colorVariation;
                
                color += auroraColor * v * _AuroraIntensity;
                
                // 星星效果
                float2 starUV = i.uv * 100.0;
                float2 starID = floor(starUV);
                float2 starLocal = frac(starUV);
                
                // 使用 hash 生成星星位置和颜色
                float starRandom1 = hash(starID);
                float starRandom2 = hash(starID + float2(13.45, 27.89));
                float3 starColorRandom = hash3(starID);
                
                // 控制星星密度
                float starThreshold = 1.0 - _StarDensity;
                float starAppear = step(starThreshold, starRandom1);
                
                // 星星位置偏移
                float2 starPos = (starLocal - 0.5) + (float2(starRandom1, starRandom2) - 0.5) * 0.8;
                float starDist = length(starPos);
                
                // 星星闪烁
                float twinkle = sin(time * _StarTwinkleSpeed + starRandom2 * TAU) * 0.5 + 0.5;
                twinkle = pow(twinkle, 4.0);
                
                // 星星形状
                float star = 1.0 - smoothstep(0.0, 0.05, starDist);
                star = pow(star, _StarSharpness * 0.1);
                
                // 星星颜色计算
                half3 finalStarColor = _StarColor.rgb;
                finalStarColor = lerp(finalStarColor, 
                                     finalStarColor * starColorRandom, 
                                     _StarColorVariation);
                
                // 应用星星效果（带颜色）
                float starValue = star * starAppear * lerp(0.5, 1.0, twinkle);
                color += finalStarColor * starValue * (1.0 - v * 0.8) * _StarIntensity;
                
                // 添加微弱的背景渐变
                float gradient = smoothstep(-0.5, 1.0, adjustedUV.y);
                color += half3(0.01, 0.02, 0.05) * gradient * (1.0 - v);
                
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Skybox/Procedural"
}

