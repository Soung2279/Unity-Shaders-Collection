Shader "Soung/Geometry/ParallaxWindows"
{
    Properties
    {
        _ProjectRoomMap("室内映射图", 2D) = "white" {}
        _ProjectCameraFOV("映射视角", range(0.001,180)) = 60
        _ProjectRoomDepth("映射距离", Float) = 1.0
        _EmissionIntensity("自发光强度", Range(0, 10)) = 0
        
        _NormalMap("法线贴图", 2D) = "bump" {}
        _NormalStrength("法线强度", Range(0, 1)) = 0.5
        
        // 金属度和光滑度参数
        _Metallic("金属度", Range(0, 1)) = 0
        _Smoothness("光滑度", Range(0, 1)) = 0.5
        [HDR]_SpecularColor("高光颜色", Color) = (1, 1, 1, 1)
        
        // 高光形状贴图
        _SpecularShapeMap("高光形状贴图", 2D) = "white" {}
        [KeywordEnum(Static, FollowLight, FollowView)] _SpecularMode ("高光模式", Float) = 0
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
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS   : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float2 normalMapUV   : TEXCOORD1;
                float3 viewTS        : TEXCOORD2;
                float3 positionWS    : TEXCOORD3;
                float3 normalWS      : TEXCOORD4;
                float3 viewDirWS     : TEXCOORD5;
                float3 tangentWS     : TEXCOORD6;
                float3 bitangentWS   : TEXCOORD7;
                float2 specularMapUV : TEXCOORD8;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectRoomMap_ST;
            float4 _NormalMap_ST;
            float4 _SpecularShapeMap_ST;
            half _ProjectCameraFOV;
            half _ProjectRoomDepth;
            float _NormalStrength;
            float _Metallic;
            float _Smoothness;
            float4 _SpecularColor;
            float _SpecularMode;
            float _EmissionIntensity;
            CBUFFER_END
            
            TEXTURE2D(_ProjectRoomMap);
            SAMPLER(sampler_ProjectRoomMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SpecularShapeMap);
            SAMPLER(sampler_SpecularShapeMap);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.positionWS = positionWS;

                OUT.uv = TRANSFORM_TEX(IN.uv, _ProjectRoomMap);
                OUT.normalMapUV = TRANSFORM_TEX(IN.uv, _NormalMap);
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

            half4 PreProjectedInterior(float2 uv, float3 viewTS, half projectCameraFOV, half projectRoomDepth)
            {
                uv = frac(uv);
                viewTS = -normalize(viewTS);

                float3 pos = float3(uv * 2 - 1, projectRoomDepth);
                float3 roomSizeScale = float3(1, 1, projectRoomDepth);

                float3 id = 1.0 / viewTS;
                float3 k = abs(id) * roomSizeScale - pos * id;
                float kMin = min(min(k.x, k.y), k.z);
                pos += kMin * viewTS;
                
                float realZLength = pos.z + projectRoomDepth;
                float interp = 1 / (tan(radians(projectCameraFOV / 2)) * (2 * projectRoomDepth - realZLength) + 1);
                float2 interiorUV = pos.xy * interp;
                interiorUV = interiorUV * 0.5 + 0.5;
                 
                return SAMPLE_TEXTURE2D(_ProjectRoomMap, sampler_ProjectRoomMap, interiorUV);
            }

            float3 CalculatePBR(float3 albedo, float3 normalWS, float3 viewDirWS, float metallic, float smoothness, float4 specularShape, float2 uv)
            {
                Light mainLight = GetMainLight();
                
                float3 reflectVector = reflect(-viewDirWS, normalWS);
                
                float NdotL = saturate(dot(normalWS, mainLight.direction));
                float3 diffuse = albedo * NdotL * mainLight.color;
                
                float3 halfVector = normalize(mainLight.direction + viewDirWS);
                float NdotH = saturate(dot(normalWS, halfVector));
                float specularPower = exp2(10 * smoothness + 1);
                
                float specularMask = 1.0;
                
                if (_SpecularMode == 0) {
                    specularMask = specularShape.r;
                }
                else if (_SpecularMode == 1) {
                    float3 lightDirTS = normalize(mul(halfVector, transpose(unity_WorldToObject)));
                    
                    float2 lightMapUV = float2(
                        dot(normalize(float3(1, 0, 0)), lightDirTS) * 0.5 + 0.5,
                        dot(normalize(float3(0, 1, 0)), lightDirTS) * 0.5 + 0.5
                    );
                    
                    float4 lightDirSpecular = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, lightMapUV);
                    specularMask = lightDirSpecular.r;
                }
                else {
                    float3 reflectDirTS = normalize(mul(reflectVector, transpose(unity_WorldToObject)));
                    
                    float2 viewMapUV = float2(
                        dot(normalize(float3(1, 0, 0)), reflectDirTS) * 0.5 + 0.5,
                        dot(normalize(float3(0, 1, 0)), reflectDirTS) * 0.5 + 0.5
                    );
                    
                    float4 viewDirSpecular = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, viewMapUV);
                    specularMask = viewDirSpecular.r;
                }
                
                float3 specular = pow(NdotH, specularPower) * _SpecularColor.rgb * specularMask;
                float3 nonMetalSpecular = specular;
                float3 metalSpecular = specular * albedo;
                specular = lerp(nonMetalSpecular, metalSpecular, metallic);
                float3 ambient = SampleSH(normalWS) * albedo;
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
                half4 roomColor = PreProjectedInterior(distortedUV, IN.viewTS, _ProjectCameraFOV, _ProjectRoomDepth);
                
                // 加载高光形状贴图
                float4 specularShape = SAMPLE_TEXTURE2D(_SpecularShapeMap, sampler_SpecularShapeMap, IN.specularMapUV);
                
                // 计算PBR光照
                half3 finalColor = CalculatePBR(roomColor.rgb, normalWS, normalize(IN.viewDirWS), 
                                              _Metallic, _Smoothness, specularShape, IN.specularMapUV);
                
                // 添加自发光效果 - 直接使用室内颜色
                if (_EmissionIntensity > 0) {
                    finalColor += roomColor.rgb * _EmissionIntensity;
                }
                half alpha = roomColor.a;
                return half4(finalColor, alpha);
            }
            ENDHLSL
        }
    }
}