Shader "Hidden/MobileFog"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FogGradient ("Fog Gradient", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        ZTest Always ZWrite Off Cull Off
        
        Pass
        {
            Name "MobileFog"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ _USE_FAST_MODE
            #pragma multi_compile_local _ _USE_GRADIENT_COLOR
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_FogGradient);
            SAMPLER(sampler_FogGradient);
            
            // 雾效参数
            float _FogDensity;
            float _FogStart;
            float _FogEnd;
            float _HeightFogDensity;
            float _HeightFogBase;
            float _HeightFogRange;
            float4 _FogColor;
            float4 _FogColorNear;
            float4 _FogColorFar;
            float _GradientDistance;
            float _UseGradientColor;
            float _Intensity;
            float _UseFastMode;
            
            // 噪波参数
            float _NoiseScale;
            float _NoiseIntensity;
            float _NoiseSpeed;
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                
                // 计算视图向量，用于重建世界坐标
                float4 clipPos = float4(input.uv * 2.0 - 1.0, 1.0, 1.0);
                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                output.viewVector = viewPos.xyz / viewPos.w;
                
                return output;
            }
            
            // 简单的2D噪波函数
            float random(float2 st) 
            {
                return frac(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }
            
            // Perlin噪波近似
            float noise(float2 st) 
            {
                float2 i = floor(st);
                float2 f = frac(st);
                
                // 四个角的随机值
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));
                
                // 平滑插值
                float2 u = f * f * (3.0 - 2.0 * f);
                
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }
            
            // 分形噪波
            float fbm(float2 st, int octaves) 
            {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                for (int i = 0; i < octaves; i++) 
                {
                    value += amplitude * noise(st * frequency);
                    amplitude *= 0.5;
                    frequency *= 2.0;
                }
                return value;
            }
            
            // 根据距离获取雾的颜色
            float3 GetFogColor(float depth)
            {
                if (_UseGradientColor > 0.5)
                {
                    // 计算距离插值因子 (0=近处, 1=远处)
                    float distanceFactor = saturate((depth - _FogStart) / max(_GradientDistance, 0.001));
                    
                    // 在近处和远处颜色之间插值
                    return lerp(_FogColorNear.rgb, _FogColorFar.rgb, distanceFactor);
                }
                else
                {
                    // 使用固定颜色
                    return _FogColor.rgb;
                }
            }
            
            // 从渐变贴图采样颜色（可选的高级功能）
            float3 GetFogColorFromTexture(float depth)
            {
                // 将深度映射到0-1范围
                float t = saturate((depth - _FogStart) / max(_GradientDistance, 0.001));
                return SAMPLE_TEXTURE2D_LOD(_FogGradient, sampler_FogGradient, float2(t, 0.5), 0).rgb;
            }
            
            // 计算基础深度雾（不受高度影响）
            float CalculateDepthFog(float depth)
            {
                return saturate((depth - _FogStart) / max(_FogEnd - _FogStart, 0.001)) * _FogDensity;
            }
            
            // 计算基础深度雾（精确模式）
            float CalculateDepthFogPrecise(float depth)
            {
                return 1.0 - exp(-_FogDensity * max(depth - _FogStart, 0.0));
            }
            
            // 计算带噪波的高度因子（0-1，用于调节深度雾密度）
            float CalculateHeightFactorWithNoise(float height, float3 worldPos)
            {
                // 基础高度计算
                float heightOffset = height - _HeightFogBase;
                
                // 添加基于世界坐标的噪波扰动
                float2 noiseCoord = worldPos.xz * _NoiseScale + _Time.y * _NoiseSpeed;
                
                // 生成多层噪波
                float heightNoise = fbm(noiseCoord, 3) * 2.0 - 1.0; // -1 到 1
                float detailNoise = fbm(noiseCoord * 3.0, 2) * 0.5; // 细节噪波
                
                // 组合噪波
                float combinedNoise = (heightNoise + detailNoise * 0.3) * _NoiseIntensity;
                
                // 将噪波应用到高度偏移
                float noisyHeightOffset = heightOffset + combinedNoise;
                
                // 计算标准化高度，使用更平滑的过渡
                float normalizedHeight = noisyHeightOffset / max(_HeightFogRange, 0.001);
                
                // 使用更自然的衰减曲线 (高度越低值越大，高度越高值越小)
                float heightFactor = 1.0 / (1.0 + exp(normalizedHeight * 4.0 - 2.0)); // sigmoid函数
                
                return heightFactor;
            }
            
            // 快速雾效计算（移动端优化）
            float CalculateFogFast(float depth, float height, float3 worldPos)
            {
                // 计算独立的深度雾
                float depthFog = CalculateDepthFog(depth);
                
                // 计算高度调节因子 (0-1)
                float heightFactor = CalculateHeightFactorWithNoise(height, worldPos);
                
                // 计算独立的高度雾
                float heightFog = _HeightFogDensity * heightFactor;
                
                // 深度雾受高度影响：高度越低，深度雾越浓
                float heightInfluencedDepthFog = depthFog * lerp(0.1, 1.0, heightFactor);
                
                // 组合两种雾效：使用加法混合，但避免过饱和
                float combinedFog = heightInfluencedDepthFog + heightFog;
                
                return saturate(combinedFog);
            }
            
            // 高质量雾效计算
            float CalculateFogPrecise(float depth, float height, float3 worldPos)
            {
                // 计算独立的指数深度雾
                float depthFog = CalculateDepthFogPrecise(depth);
                
                // 计算带噪波的平滑高度调节因子
                float heightFactor = CalculateHeightFactorWithNoise(height, worldPos);
                heightFactor = smoothstep(0.0, 1.0, heightFactor);
                
                // 计算独立的高度雾
                float heightFog = _HeightFogDensity * heightFactor;
                
                // 深度雾受高度影响：使用更平滑的过渡
                float heightInfluencedDepthFog = depthFog * lerp(0.1, 1.0, heightFactor);
                
                // 使用更自然的组合方式：乘法混合避免过度叠加
                float combinedFog = 1.0 - (1.0 - heightInfluencedDepthFog) * (1.0 - heightFog);
                
                return saturate(combinedFog);
            }
            
            float4 frag(Varyings input) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                
                // 采样深度并转换为线性深度
                float depth = SampleSceneDepth(input.uv);
                float linearDepth = LinearEyeDepth(depth, _ZBufferParams);
                
                // 重建世界坐标以获取高度信息
                float3 worldPos = _WorldSpaceCameraPos + input.viewVector * linearDepth;
                float height = worldPos.y;
                
                // 根据设置选择计算模式
                float fogFactor;
                if (_UseFastMode > 0.5)
                {
                    fogFactor = CalculateFogFast(linearDepth, height, worldPos);
                }
                else
                {
                    fogFactor = CalculateFogPrecise(linearDepth, height, worldPos);
                }
                
                // 应用强度控制
                fogFactor *= _Intensity;
                
                // 根据距离获取雾的颜色
                float3 fogColor = GetFogColor(linearDepth);
                
                // 混合原色和雾色
                float3 finalColor = lerp(color.rgb, fogColor, fogFactor);
                
                return float4(finalColor, color.a);
            }
            ENDHLSL
        }
    }
    
    Fallback Off
}