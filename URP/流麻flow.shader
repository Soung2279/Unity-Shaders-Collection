Shader "A201-Shader/URP/URP视差流麻_Jiji"
{
    Properties
    {
        _WebSite("此Shader教程网址:www.bilibili.com/video/BV19P411x7nv/", Int) = 2023
		[Header(__________________________________________________________________________________________)]
        _MainTex ("主贴图(留空)", 2D) = "white" {}
        _NoiseTex("噪波贴图(使用粒子点噪)", 2D) = "white" {}
        _MipMap ("过滤纹理(MipMap)", 2D) = "white" {}
        _ColorGradient("颜色渐变", 2D) = "white" {}
        _Color_pow ("Color_pow", Range(0,10))  = 1.0
        
        _BaseColor("基础色",Color) = (0.5,0.5,0.5,1)
        _ShiningSpeed ("第1层流麻速度", Float) = 0.1
        _ShiningSpeed_02 ("第2层流麻速度", Float) = 0.1 
        _ShiningSpeed_03 ("第3层流麻速度", Float) = 0.1
        [HDR]_SparkleColor("流麻颜色", Color) = (1,1,1,1)
        _SparklePower ("sparkle Power", Float) = 10
        
        _NormalMap ("法线贴图", 2D) = "white" {}
        _NormalScale ("法线贴图缩放", Range(0,3)) = 1

        _SpecularColor ("高光反射(Specular)",Color) = (1,1,1,1)
        _SpecularPow ("反射强度", Range(1,150)) = 1

        _RimColor ("边缘色", Color) = (0.17,0.36,0.81,0.0)
        _RimPower ("边缘色亮度(Power)", Range (0.6,36.0)) = 8.0
        _RimIntensity ("边缘色强度(Intensity)", Range(0.0,100.0)) = 1.0

        _ParallaxMap ("视差映射(高度图)",2D) = "white" {}
        _DepthStep ("第1层流麻深度", Range(0,300)) = 20
        _DepthStep_02 ("第2层流麻深度", Range(0,300)) = 20
        _DepthStep_03 ("第3层流麻深度", Range(0,300)) = 20
        _Iteration ("迭代", Range(1,15)) = 3
        _DieValue01 ("DieValue速度", Range(0.01,1)) = 0.5
        _DieValue02 ("DieValue亮度", Range(0,5)) = 3
        _OffsetSecond ("LayerOffset第二个纹理", vector) = (0.5,0.5,0,0)
        _OffsetThird ("LayerOffset第三个纹理", vector) = (0.5,0.5,0,0)
        
         _MaskAlpha ("Alpha遮罩", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
           "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"  "RenderPipeline"="UniversalRenderPipeline"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // #include"AutoLight.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdadd_fullshadows

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS    //接受阴影 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE    //产生阴影
            #pragma multi_compile _ _SHADOWS_SOFT    //软阴影

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            sampler2D _NoiseTex, _ParallaxMap, _MipMap, _MainTex, _NormalMap,_ColorGradient,_MaskAlpha;
            sampler2D _CameraOpaqueTexture; //相机不透明物体的渲染完成的采样
            
            float4 _NoiseTex_ST, _ParallaxMap_ST, _MipMap_ST, _MainTex_ST,  _NormalMap_ST , _ColorGradient_ST,_MaskAlpha_ST;
            float4 _SpecularColor, _RimColor, _SparkleColor, _BaseColor;
            float _SpecularPow, _NoiseSize, _ShiningSpeed, _NormalScale, _ShiningSpeed_02 ,_ShiningSpeed_03;
            float _RimPower, _RimIntensity, _specsparkleRate, _rimsparkleRate, _diffsparkleRate, _SparklePower,_Color_pow;
            float _HeightFactor , _DepthStep, _Iteration,  _DieValue02, _DieValue01 ,_DepthStep_02 ,_DepthStep_03;
            float2 _OffsetSecond,_OffsetThird;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normaTangent : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
                float3 lightDir_tangent : TEXCOORD5;
                float3 viewDir_tangent : TEXCOORD6;
                float3 normalWorld : TEXCOORD7;
                // LIGHTING_COORDS(7, 8)
                // SHADOW_COORDS(7)
                // UNITY_FOG_COORDS(8)
            };

            // 计算视察偏移的UV量
            inline float2 CalculateParallaxUV(v2f i, float heightMulti, float3 normalReflect,float depthstep)
            {
                float height = tex2D(_NoiseTex, i.uv*_NoiseSize).r;
                //normalize view Dir
                float3 viewDir_tan_normalize = normalize(i.viewDir_tangent);
                float3 reflectDir = reflect( -viewDir_tan_normalize,normalReflect);  //反射出去的视线
                float2 offsetValue = depthstep *1.0 /abs(reflectDir.z)*1.0 ;
                float pixvalue = 1/612.0;  //一般取图片像素倒数 
                //偏移值
                float2 offset =  reflectDir.xy * offsetValue * pixvalue *heightMulti;
                return offset;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv; //uv1

                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
                Light mainLight = GetMainLight();
                o.lightDir = normalize(mainLight.direction); //灯光世界方向;
                o.normalWorld = TransformObjectToWorldNormal(v.normal);

                //获取切线空间数据------------------------------------------------------------------
                float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w; //模型空间副切线
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal); //模型到切线转置矩阵
                // URP 中没有 ObjSpaceLightDir
                half3 objectSpaceLightDir = TransformWorldToObjectDir(mainLight.direction.xyz);
                o.lightDir_tangent = mul(rotation, objectSpaceLightDir).xyz;
                // URP 中没有 ObjSpaceViewDir
                half3 objectSpaceViewDir = half3(TransformWorldToObject(_WorldSpaceCameraPos.xyz) - v.vertex.xyz);
                o.viewDir_tangent = normalize(mul(rotation, objectSpaceViewDir).xyz);
                //模型空间切线
                half3 objectSpaceNormal = v.normal;
                o.normaTangent =  normalize(mul(rotation, objectSpaceNormal).xyz);

                return o;
            }

            float3 GetSparkcolor(v2f i,float2 uvMipmap,float2 layerOffset,float2 flowspeed,float depthstep ,float3 tangentNormal)
            {
                float3 Sparkcolor = float3(0,0,0);
                for(int j=1;j<_Iteration+1;j++)
                {
                     float2 uvParallaxOffset = CalculateParallaxUV(i, j, tangentNormal, depthstep);  
                     float dieValue = pow(1.0/j,_DieValue01);  //控制速度衰减

                     uvMipmap = uvMipmap +  float2(0,_Time.x * 0.3/j);  //每次偏移一点点
                     half3 mipColor = tex2Dlod(_MipMap, float4(uvMipmap, 16, 0));
                    
                     float2 uvNoise = TRANSFORM_TEX(i.uv, _NoiseTex);
                     float baseMask = tex2D(_NoiseTex, uvNoise + uvParallaxOffset + layerOffset + flowspeed*dieValue).r;
                     float Mask =saturate(pow(baseMask, clamp(7-j,1,6)) );  //*5，这几个操作是让越开始的蒙版范围越小
                     Mask = step(0.3,Mask);
              
                     half3 baseColor = _SparkleColor * Mask * mipColor  ;   //颜色为后面的mipmap

                    // float baseColor_value = tex2D(_NoiseTex, i.uv *_NoiseSize + uvParallaxOffset + layerOffset + flowspeed*dieValue).a;
                    // float u_value = clamp(baseColor_value,0.01,0.99);
                    // half3 gradientColor = tex2D(_ColorGradient, float2(u_value,0.5)).rgb;  //灰度值映射到颜色
                    // half3 baseColor = _SparkleColor * Mask * gradientColor  ;   //颜色为采样灰度图映射到的色彩图

                    float die02 = pow(1.0/j,_DieValue02);  //亮度衰减幅度
                    Sparkcolor = max(Sparkcolor,baseColor * clamp(die02*5,0,5));   //外圈的颜色更亮，内圈的更暗
                }
                 return Sparkcolor;
            }
               

            float4 frag(v2f i) : SV_Target
            {
               
                
                // float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.posWorld); //阴影坐标
                // Light mainLight = GetMainLight(SHADOW_COORDS); //带阴影衰减的灯光
                Light mainLight = GetMainLight();
                
                
                float3 WS_L = normalize(mainLight.direction);
                float3 WS_N = normalize(i.normalWorld);
                float3 WS_V = normalize(_WorldSpaceCameraPos - i.posWorld);
                float3 WS_H = normalize(WS_V + WS_L);

                float2 uvNormal = TRANSFORM_TEX(i.uv, _NormalMap);
                float4 packedNormal = tex2D( _NormalMap,uvNormal);
                float3 tangentNormal;
                tangentNormal.xy = (packedNormal.xy*2-1)*_NormalScale;
                tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                // tangentNormal = normalize(tangentNormal);
                
                float2 uvMipmap = TRANSFORM_TEX(i.uv, _MipMap);
               
                // float AngleValue = 1-abs(dot(i.normalWorld,float3(0,1,0)));

                float2 speed01 = float2(0,_Time.x * _ShiningSpeed) ;
                float2 speed02 = float2(_Time.x * _ShiningSpeed*0.1,_Time.x * _ShiningSpeed_02) ;
                float2 speed03 = float2(_Time.x * _ShiningSpeed*-0.1,_Time.x * _ShiningSpeed_03) ;
                float3 Sparkcolor = (0,0,0);
                Sparkcolor += max(Sparkcolor,GetSparkcolor(i,uvMipmap,float2(0,0),speed01,_DepthStep,tangentNormal));
                Sparkcolor += max(Sparkcolor,GetSparkcolor(i,uvMipmap,_OffsetSecond,speed02,_DepthStep_02,tangentNormal));
                Sparkcolor += max(Sparkcolor,GetSparkcolor(i,uvMipmap,_OffsetThird,speed03,_DepthStep_03,tangentNormal));
               
                // float Mask2 = pow(tex2D(_NoiseTex, i.uv *_NoiseSize + uvParallaxOffset*0.5 + float2(0, _Time.x * _ShiningSpeed*0.5 )).b,5);
                // half3 baseColor2 = _BaseColor * Mask2;

                float2 uvScreenOrig = i.pos.xy / _ScreenParams.xy; //确定在深度图上的位置的采样结果（水面下不透明该点的深度值）！！！！
                float4 background = tex2D(_CameraOpaqueTexture, uvScreenOrig);
                
                
               
                // half3 albedo = background.xyz;  //弄成半透明把
                //
                // float3 halfvec_tangent = normalize(i.lightDir_tangent+i.viewDir_tangent);
                //
                // float3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;
                // float3 diffuse = (dot(tangentNormal,i.lightDir_tangent)*0.5+0.5) * albedo * mainLight.color.xyz;
                //
                // float3 Specular = pow(max(dot(tangentNormal, halfvec_tangent), 0), _SpecularPow) * _SpecularColor.xyz ;
                //
                // half4 finalColor = float4(diffuse + Specular +ambient,1);
                // finalColor += float4(Sparkcolor,1);

                float2 uvMainTex = TRANSFORM_TEX(i.uv, _MainTex);
                half3 albedo = tex2D( _MainTex, uvMainTex) * _BaseColor;

                //AlphaTest
                half alpha = tex2D( _MaskAlpha, i.uv).r;
                if(alpha <0.5)
                {
                    discard;
                }
                
                half4 finalColor = float4(Sparkcolor + albedo,1);
                return finalColor ;
            }
            ENDHLSL
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}