Shader "Soung/Effect/LitLeafWaves"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 2
        _MainColor("贴图颜色", Color)= (1,1,1,1)
        _MainTex("贴图", 2D) = "white" {}
        _SpecularValue("物体光滑度", Range(0, 1)) = 1.0
        _Strength("摇摆幅度", Float) = 1
        _Speed("摇摆速度", Float) = 3

        // Alpha剔除相关属性
        _AlphaCutoff("Alpha剔除阈值", Range(0.0, 1.0)) = 0.5

        //无缝替换原shader(Model_Lit)的亮度补偿值
        _MultValue("亮度", float) = 0.85

        //_Contrast("对比度", Range( 0 , 2)) = 1    //对比度属性

        [HDR]_EmissionCol("自发光颜色", Color) = (0,0,0,0)
    }

    SubShader
    {

        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
        }

        HLSLINCLUDE

        //引入共用的库文件
        //若Pass块有单独引用的库, 需在Pass中单独加入
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //材质在CBUFFER中引用以支持SRP Batch
        //此处存放共用属性, 若Pass块有单独使用属性, 需另加CBUFFER
        CBUFFER_START(UnityPerMaterial)
            half4 _MainColor;
            float4 _MainTex_ST;
            half _SpecularValue;
            half4 _EmissionCol;
            float _MultValue;
            float _CullingMode;
            float _Speed;
            float _Strength;
            half _AlphaCutoff;

            //float _Contrast;  //对比度
        CBUFFER_END
        ENDHLSL

        Pass
        {

            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }


            Cull [_CullingMode]
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
            ColorMask RGBA

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            // 添加alpha测试关键字
            #pragma shader_feature_local _ALPHATEST_ON

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS: TEXCOORD2;

                // 光照计算相关的值, 移到顶点着色器中节省性能
                half3 diffuse : COLOR0; // 漫反射强度
                half3 specular : COLOR1; // 镜面反射强度
            };


            //计算对比度的方法
            //float4 CalculateContrast( float contrastValue, float4 colorTarget )
            //{
            //	float t = 0.5 * ( 1.0 - contrastValue );
            //	return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
            //}

            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MainTex);

            //逐顶点光照计算
            Varyings vert(Attributes v)
            {

                Varyings o;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionWS = TransformObjectToWorld(v.positionOS);

                float stage1 = dot(v.positionOS, float3(0, 1, 0)) * _Strength;
                float stage2 = sin(dot(v.positionOS, float3(1, 0, 0)) * _Strength + _Time.y * _Speed);
                float3 stage3 = stage1 * stage2 * float3(0.001, 0, 0.001);
                o.positionCS = TransformObjectToHClip(v.positionOS + stage3);

                // 光照计算移到顶点着色器
                half3 normalDir = normalize(o.normalWS);
                half3 lightDir = normalize(_MainLightPosition.xyz); // 主光源方向

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - o.positionWS); // 视角方向
                half3 halfnormalDir = normalize(lightDir + viewDir); // 半程向量

                // 漫反射：漫反射强度计算
                o.diffuse = _MainLightColor.rgb * saturate(dot(normalDir, lightDir));

                //半兰伯特光照模型, 但使用了环境光就不需要提亮了.神奇的光照魔法
                //要使用此项, 在片元着色器中注释掉环境光相关代码.
                //o.diffuse = _MainLightColor.rgb * saturate(dot(n, l) * 0.5 + 0.5);

                // 镜面反射：高光强度计算
                half smoothness = exp(10 * _SpecularValue + 1);
                o.specular = _MainLightColor.rgb * pow(saturate(dot(normalDir, halfnormalDir)), smoothness);

                return o;
            }


            //片元着色
            half4 frag(Varyings i) : SV_Target
            {
                //贴图颜色采样
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half3 baseCol = texColor.rgb;
                half alpha = texColor.a * _MainColor.a;

                // Alpha剔除测试
                clip(alpha - _AlphaCutoff);

                //固有色
                half3 albedo = baseCol * _MainColor.rgb;

                //对固有色添加对比度调整, 有需要再使用. 使用时注释掉上一排固有色
                //half3 albedo = BaseColor * _MainColor;

                //环境光, 禁用后物体只受场景定向光照, 整体会变黑.
                //虽然每个像素都会计算固定值, 但不建议注释掉.
                half3 ambient = _GlossyEnvironmentColor.rgb;

                // 漫反射和镜面反射已经在顶点着色器中计算, 直接取值
                half3 diffuse = i.diffuse;
                half3 specular = i.specular;

                // 自发光
                half3 emission = _EmissionCol.rgb;

                //输出最终颜色
                return half4(albedo * (ambient + diffuse + specular) * _MultValue + emission, 1);

                //不使用环境光的着色, 整体会变黑.
                //return half4(albedo * (diffuse + specular) + emission, 1);
            }
            ENDHLSL
        }

        // 添加ShadowCaster Pass以支持阴影投射
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_CullingMode]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #pragma shader_feature_local _ALPHATEST_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        // 添加DepthOnly Pass
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_CullingMode]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma shader_feature_local _ALPHATEST_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}