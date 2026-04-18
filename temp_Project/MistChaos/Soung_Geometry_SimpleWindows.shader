Shader "Soung/Geometry/SimpleWindows"
{
    Properties
    {
        _ProjectRoomMap("室内映射图", 2D) = "white" {}
        _ProjectCameraFOV("映射视角", range(0.001,180)) = 60
        _ProjectRoomDepth("映射距离", Float) = 1.0
        
        [Toggle] _UseAtlas("使用图集模式", Float) = 0
        _AtlasSize("图集尺寸(xy)", Vector) = (1, 1, 0, 0)
        [IntRange]_AtlasIndex("图集序号", Range(0, 100)) = 0
        
        _NormalMap("法线贴图", 2D) = "bump" {}
        _NormalStrength("法线强度", Range(0, 1)) = 0.5
        _NoiseMap("污渍贴图", 2D) = "white" {}
        [Toggle] _UseRedAsAlpha("使用污渍贴图R通道", Float) = 0
        [HDR]_StainColor("污渍颜色", Color) = (0.8, 0.8, 0.8, 1)
        _StainIntensity("污渍强度", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS   : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float2 normalMapUV   : TEXCOORD1;
                float2 noiseMapUV    : TEXCOORD2;
                float3 viewTS        : TEXCOORD3;
                float3 positionWS    : TEXCOORD4;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectRoomMap_ST;
            float4 _NormalMap_ST;
            float4 _NoiseMap_ST;
            half _ProjectCameraFOV;
            half _ProjectRoomDepth;
            float _UseAtlas;
            float2 _AtlasSize;
            float _AtlasIndex;
            float _NormalStrength;
            float _StainIntensity;
            float4 _StainColor;
            float _UseRedAsAlpha;
            CBUFFER_END
            
            TEXTURE2D(_ProjectRoomMap);
            SAMPLER(sampler_ProjectRoomMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            // 伪随机函数
            float hash(float3 p) {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.positionWS = positionWS;  // 存储世界空间位置用于随机化

                OUT.uv = TRANSFORM_TEX(IN.uv, _ProjectRoomMap);
                OUT.normalMapUV = TRANSFORM_TEX(IN.uv, _NormalMap);
                OUT.noiseMapUV = TRANSFORM_TEX(IN.uv, _NoiseMap);

                float3 viewWS = GetWorldSpaceViewDir(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                float3x3 tangentSpaceTransform = float3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
                OUT.viewTS = mul(tangentSpaceTransform, viewWS);
                OUT.viewTS *= _ProjectRoomMap_ST.xyx;
                return OUT;
            }

            half4 PreProjectedInterior(float2 uv, float3 viewTS, half projectCameraFOV, half projectRoomDepth, float3 positionWS)
            {
                uv = frac(uv);
                viewTS = - normalize(viewTS);

                //构造一个原点在中心(0,0,0)的2x2x2的盒子，我们可以改变盒子深度（宽高也可以，但为了方面理解，这里只改变深度）
                float3 pos = float3(uv * 2 - 1, projectRoomDepth);
                float3 roomSizeScale = float3(1,1,projectRoomDepth);

                float3 id = 1.0 / viewTS;
                float3 k = abs(id) * roomSizeScale - pos * id;
                float kMin = min(min(k.x, k.y), k.z);
                pos += kMin * viewTS;
                
                float realZLength = pos.z + projectRoomDepth;
                float interp = 1 / (tan(radians(projectCameraFOV / 2)) * (2 * projectRoomDepth - realZLength) + 1);
                float2 interiorUV = pos.xy * interp;

                interiorUV = interiorUV * 0.5 + 0.5;
                
                if (_UseAtlas > 0.5) {
                    // 确定使用哪个图集索引
                    float atlasIndex = _AtlasIndex;
                    
                    // 计算行列索引
                    float2 atlasCoord;
                    atlasCoord.y = floor(atlasIndex / _AtlasSize.x);
                    atlasCoord.x = atlasIndex - (atlasCoord.y * _AtlasSize.x);
                    
                    // 翻转Y坐标以匹配Unity的纹理坐标系统
                    atlasCoord.y = _AtlasSize.y - 1 - atlasCoord.y;
                    
                    // 调整UV到对应的图集格子
                    float2 singleImageSize = 1.0 / _AtlasSize;
                    interiorUV = (atlasCoord + interiorUV) * singleImageSize;
                }
                 
                return SAMPLE_TEXTURE2D(_ProjectRoomMap, sampler_ProjectRoomMap, interiorUV);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // 采样法线贴图并计算扰动
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.normalMapUV));
                normalTS.xy *= _NormalStrength;
                normalTS = normalize(normalTS);
                
                // 计算扰动（只使用法线贴图）
                float2 distortion = normalTS.xy;
                
                // 应用扰动到基础UV
                float2 distortedUV = IN.uv + distortion;
                
                // 计算室内效果 - 在此函数内部会处理图集
                half4 roomColor = PreProjectedInterior(distortedUV, IN.viewTS, _ProjectCameraFOV, _ProjectRoomDepth, IN.positionWS);
                
                // 采样污渍贴图
                float4 stain = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, IN.noiseMapUV);
                
                // 根据设置选择使用R通道或A通道作为Alpha
                float stainAlpha = lerp(stain.a, stain.r, _UseRedAsAlpha);
                
                // 根据污渍强度混合污渍颜色和室内颜色
                float stainMask = stainAlpha * _StainIntensity;
                
                // 使用污渍贴图明暗区域和颜色参数来创建污渍效果
                half3 finalColor = lerp(roomColor.rgb, roomColor.rgb * _StainColor.rgb * stain.rgb, stainMask);
                
                return half4(finalColor, roomColor.a);
            }

            ENDHLSL
        }
    }
}