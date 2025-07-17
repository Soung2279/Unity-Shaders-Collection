Shader "Soung/Geometry/ParallaxWindows"
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
        [Toggle] _UseRedAsAlpha("使用污渣贴图R通道", Float) = 0
        [HDR]_StainColor("污渊颜色", Color) = (0.8, 0.8, 0.8, 1)
        _StainIntensity("污渍强度", Range(0, 1)) = 0.5
        
        // 金属度和光滑度参数
        _Metallic("金属度", Range(0, 1)) = 0
        _Smoothness("光滑度", Range(0, 1)) = 0.5
        _SpecularIntensity("高光强度", Range(0, 1)) = 0.5
        [HDR]_SpecularColor("高光颜色", Color) = (1, 1, 1, 1)
        
        // 高光形状贴图
        _SpecularShapeMap("高光形状贴图", 2D) = "white" {}
        _SpecularShapeStrength("高光形状强度", Range(0, 1)) = 1.0
        [KeywordEnum(Static, FollowLight, FollowView)] _SpecularMode ("高光模式", Float) = 0
        
        // 自发光控制
        [HDR]_EmissionColor("自发光颜色", Color) = (1, 1, 1, 1)
        _EmissionIntensity("自发光强度", Range(0, 10)) = 0
        [Toggle] _UseRoomColorForEmission("使用室内颜色作为自发光", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"}
        
        ZWrite On

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
                float3 normalWS      : TEXCOORD5;
                float3 viewDirWS     : TEXCOORD6;
                float3 tangentWS     : TEXCOORD7; // 只传递切线，不传递整个TBN矩阵
                float3 bitangentWS   : TEXCOORD8; // 额外传递副切线
                float2 specularMapUV : TEXCOORD9; // 高光贴图UV
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectRoomMap_ST;
            float4 _NormalMap_ST;
            float4 _NoiseMap_ST;
            float4 _SpecularShapeMap_ST;
            half _ProjectCameraFOV;
            half _ProjectRoomDepth;
            float _UseAtlas;
            float2 _AtlasSize;
            float _AtlasIndex;
            float _NormalStrength;
            float _StainIntensity;
            float4 _StainColor;
            float _UseRedAsAlpha;
            float _Metallic;
            float _Smoothness;
            float _SpecularIntensity;
            float4 _SpecularColor;
            float _SpecularShapeStrength;
            float _SpecularMode;
            float4 _EmissionColor;
            float _EmissionIntensity;
            float _UseRoomColorForEmission;
            CBUFFER_END
            
            TEXTURE2D(_ProjectRoomMap);
            SAMPLER(sampler_ProjectRoomMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);
            TEXTURE2D(_SpecularShapeMap);
            SAMPLER(sampler_SpecularShapeMap);


            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.positionWS = positionWS;  // 存储世界空间位置

                OUT.uv = TRANSFORM_TEX(IN.uv, _ProjectRoomMap);
                OUT.normalMapUV = TRANSFORM_TEX(IN.uv, _NormalMap);
                OUT.noiseMapUV = TRANSFORM_TEX(IN.uv, _NoiseMap);
                OUT.specularMapUV = TRANSFORM_TEX(IN.uv, _SpecularShapeMap);

                OUT.viewDirWS = GetWorldSpaceViewDir(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = normalInput.normalWS;
                
                OUT.tangentWS = normalInput.tangentWS;
                OUT.bitangentWS = normalInput.bitangentWS;

                float3x3 tangentSpaceTransform = float3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
                OUT.viewTS = mul(tangentSpaceTransform, OUT.viewDirWS);
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

            // 计算修改后的PBR光照模型，包含高光形状贴图
            float3 CalculatePBR(float3 albedo, float3 normalWS, float3 viewDirWS, float metallic, float smoothness, float4 specularShape, float2 uv)
            {
                Light mainLight = GetMainLight();
                
                // 计算反射方向
                float3 reflectVector = reflect(-viewDirWS, normalWS);
                
                // 基础光照计算
                float NdotL = saturate(dot(normalWS, mainLight.direction));
                float3 diffuse = albedo * NdotL * mainLight.color;
                
                // 高光计算
                float3 halfVector = normalize(mainLight.direction + viewDirWS);
                float NdotH = saturate(dot(normalWS, halfVector));
                float specularPower = exp2(10 * smoothness + 1);
                
                // 使用高光形状贴图修改高光
                float specularMask = 1.0;
                
                // 根据高光模式选择不同的映射方式
                if (_SpecularMode == 0) { // Static 静态模式
                    // 直接使用UV坐标采样高光形状贴图
                    specularMask = specularShape.r * _SpecularShapeStrength;
                }
                else if (_SpecularMode == 1) { // FollowLight 随光源移动
                    // 将光源半向量转换到切线空间
                    float3 lightDirTS = normalize(mul(halfVector, transpose(unity_WorldToObject)));
                    
                    // 映射到UV空间
                    float2 lightMapUV = float2(
                        dot(normalize(float3(1, 0, 0)), lightDirTS) * 0.5 + 0.5,
                        dot(normalize(float3(0, 1, 0)), lightDirTS) * 0.5 + 0.5
                    );
                    
                    // 采样高光形状贴图
                    float4 lightDirSpecular = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, lightMapUV);
                    specularMask = lightDirSpecular.r * _SpecularShapeStrength;
                }
                else { // FollowView 随视角移动
                    // 将视线方向转换到切线空间
                    float3 viewDirTS = normalize(mul(viewDirWS, transpose(unity_WorldToObject)));
                    
                    // 映射到UV空间 - 这里使用视线方向的反射向量可以获得更好的效果
                    float3 reflectDirTS = normalize(mul(reflectVector, transpose(unity_WorldToObject)));
                    
                    float2 viewMapUV = float2(
                        dot(normalize(float3(1, 0, 0)), reflectDirTS) * 0.5 + 0.5,
                        dot(normalize(float3(0, 1, 0)), reflectDirTS) * 0.5 + 0.5
                    );
                    
                    // 采样高光形状贴图
                    float4 viewDirSpecular = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, viewMapUV);
                    specularMask = viewDirSpecular.r * _SpecularShapeStrength;
                }
                
                float3 specular = pow(NdotH, specularPower) * _SpecularColor.rgb * _SpecularIntensity * specularMask;
                
                // 混合金属度
                float3 nonMetalSpecular = specular;
                float3 metalSpecular = specular * albedo;
                specular = lerp(nonMetalSpecular, metalSpecular, metallic);
                
                // 添加环境光和反射探针
                float3 ambient = SampleSH(normalWS) * albedo;
                
                // 最终光照结果
                float3 finalColor = diffuse + specular + ambient;
                
                return finalColor;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // 法线贴图
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.normalMapUV));
                normalTS.xy *= _NormalStrength;
                normalTS = normalize(normalTS);
                
                // 重建TBN矩阵并转换法线到世界空间
                float3x3 TBN = float3x3(
                    normalize(IN.tangentWS), 
                    normalize(IN.bitangentWS), 
                    normalize(IN.normalWS)
                );
                float3 normalWS = normalize(mul(normalTS, TBN));
                
                // 扭曲UV
                float2 distortion = normalTS.xy;
                float2 distortedUV = IN.uv + distortion;
                
                // 室内投影
                half4 roomColor = PreProjectedInterior(distortedUV, IN.viewTS, _ProjectCameraFOV, _ProjectRoomDepth, IN.positionWS);
                
                // 污渍贴图
                float4 stain = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, IN.noiseMapUV);
                float stainAlpha = lerp(stain.a, stain.r, _UseRedAsAlpha);
                float stainMask = stainAlpha * _StainIntensity;
                
                // 应用污渍效果
                half3 baseColor = lerp(roomColor.rgb, roomColor.rgb * _StainColor.rgb * stain.rgb, stainMask);
                
                // 加载高光形状贴图
                float4 specularShape = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, IN.specularMapUV);
                
                // 计算PBR光照，包括高光形状贴图
                float actualMetallic = _Metallic * (1.0 - stainMask); // 污渍区域降低金属度
                float actualSmoothness = _Smoothness * (1.0 - stainMask * 0.8); // 污渍区域降低光滑度
                
                half3 finalColor = CalculatePBR(baseColor, normalWS, normalize(IN.viewDirWS), 
                                              actualMetallic, actualSmoothness, specularShape, IN.specularMapUV);
                
                // 添加自发光效果
                if (_EmissionIntensity > 0) {
                    // 根据设置选择使用室内颜色或自定义颜色作为自发光基础
                    half3 emissionBase = lerp(_EmissionColor.rgb, roomColor.rgb, _UseRoomColorForEmission);
                    
                    // 应用自发光效果 - 被污渍影响的区域自发光较弱
                    half3 emission = emissionBase * _EmissionIntensity * (1.0 - stainMask * 0.7);
                    
                    // 将自发光添加到最终颜色
                    finalColor += emission;
                }
                
                half alpha = roomColor.a;
                
                return half4(finalColor, alpha);
            }

            ENDHLSL
        }
    }
}