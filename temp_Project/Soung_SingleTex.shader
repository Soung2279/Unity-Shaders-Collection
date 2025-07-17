//修改于2025.6.13
Shader "Soung/Effect/SingleTex"
{
    Properties
    {
        [Header(MainTex)]_MainTex("贴图", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 0
        [IntRange]_RotatorVal("贴图旋转", Range( 0 , 360)) = 0
        _TexScale("贴图缩放", Range( 0 , 5)) = 1
        [Toggle(_USE_CUSTOM_BRIGHTNESS)] _EnableCustomBrightness("Custom1.x控制亮度", Float) = 0

        [Header(DepthFade)][Toggle(_SOFT_PARTICLES_ON)] _EnableSoftParticles("启用软粒子", Float) = 0
        _DepthFade("软粒子强度", Range( 0 , 1)) = 0.1

        [Header(HSV)][Toggle(_USE_HSV_SHIFT)] _EnableHSV("启用HSV调整", Float) = 0
        _HueSwitch("色相变换", Range( 0 , 1)) = 0
        _SaturationVa("饱和度", Range( 0 , 1.5)) = 1

        [Header(Outline)]
        [Toggle(_USE_OUTLINE)] _EnableOutline("启用描边", Float) = 0
        _lineWidth("描边宽度 (向内描边,仅对透明图生效)",Range(0,0.1)) = 0
        [HDR]_lineColor("描边颜色",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "UniversalMaterialType"="Unlit"
            "LightMode"="SRPDefaultUnlit"
            //"LightMode"="VFX"
        }

        Cull [_CullingMode]
        AlphaToMask Off
        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        ZWrite Off
        ZTest LEqual
        Offset 0 , 0
        ColorMask RGBA

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        // 条件包含深度纹理
        #if defined(_SOFT_PARTICLES_ON)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #endif
        

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _BaseColor;
            float _BlendMode;
            float _CullingMode;
            float _HueSwitch;
            float _RotatorVal;
            float _TexScale;
            float _SaturationVa;
            float _SwitchP;
            float _lineWidth;
            float4 _lineColor;
            float _DepthFade;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        #if defined(_USE_HSV_SHIFT)
            float3 HSVToRGB(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }
        #endif

        //数据传入结构体
        struct a2v
        {
            float4 vertex : POSITION;
            float4 ase_texcoord : TEXCOORD0;
            float4 ase_texcoord1 : TEXCOORD1; // 添加TEXCOORD1用于接收自定义数据流
            float4 ase_color : COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };


        struct v2f
        {
            float4 clipPos : SV_POSITION;
            float4 ase_texcoord1 : TEXCOORD0;
            float4 ase_color : COLOR;
            float4 ase_texcoord2 : TEXCOORD1; // 传递自定义数据流
            #if defined(_SOFT_PARTICLES_ON)
                float4 scrPos : TEXCOORD3;
            #endif
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        ENDHLSL

        Pass
        {
            Name "Forward"

            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma multi_compile_instancing
            
            // 添加shader关键字变体
            #pragma shader_feature_local _SOFT_PARTICLES_ON
            #pragma shader_feature_local _USE_HSV_SHIFT
            #pragma shader_feature_local _USE_OUTLINE
            #pragma shader_feature_local _USE_CUSTOM_BRIGHTNESS

            //顶点计算部分
            v2f VERT(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.ase_texcoord1.xy = v.ase_texcoord.xy;
                o.ase_texcoord2 = v.ase_texcoord1; // 传递自定义顶点数据
                o.ase_color = v.ase_color;
                
                //为未使用的数据通道填充值, 避免警告
                o.ase_texcoord1.zw = 0;

                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif

                float3 vertexValue = defaultVertexValue;

                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);
                o.clipPos = positionCS;
                
                // 仅在启用软粒子时计算屏幕位置
                #if defined(_SOFT_PARTICLES_ON)
                    o.scrPos = ComputeScreenPos(positionCS);
                #endif

                return o;
            }

            float4 FRAG(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 缓存材质参数，减少寄存器压力               
                float3 baseColorRGB = _BaseColor.rgb;
                float baseColorA = _BaseColor.a;
                float3 vertexColorRGB = IN.ase_color.rgb;
                float vertexColorA = IN.ase_color.a;
                
                // 获取Custom1.x亮度控制值
                float customBrightness = 1.0;
                #if defined(_USE_CUSTOM_BRIGHTNESS)
                    customBrightness = IN.ase_texcoord2.x;
                #endif

                float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 finalUV;

                // 仅当旋转值非0时才执行旋转计算
                if (abs(_RotatorVal) > 0.001)
                {
                    float angle = (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0));
                    float2x2 rotMatrix;
                    sincos(angle, rotMatrix._21, rotMatrix._11);
                    rotMatrix._12 = -rotMatrix._21;
                    rotMatrix._22 = rotMatrix._11;
                    float2 rotator51 = mul(uv_MainTex - float2(0.5, 0.5), rotMatrix) + float2(0.5, 0.5);
                    finalUV = ((rotator51 * _TexScale) + -(_TexScale * 0.5) + 0.5);
                }
                else
                {
                    // 跳过旋转计算
                    finalUV = ((uv_MainTex * _TexScale) + -(_TexScale * 0.5) + 0.5);
                }

                float4 tex2DNode1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV);

                // 提前优化 - 丢弃透明像素
                if (tex2DNode1.a <= 0.0)
                {
                    discard;
                }

                // 计算基础alpha
                float lerpResult5 = lerp(tex2DNode1.r, tex2DNode1.a, _SwitchP);
                float baseAlpha = lerpResult5 * baseColorA * vertexColorA;

                // 透明度检查提前结束
                if (baseAlpha <= 0.001)
                {
                    discard;
                }

                // 优化描边计算，使用shader变体
                float outlineAlpha = 0.0;
                #if defined(_USE_OUTLINE)
                    if (_lineWidth > 0.001)
                    {
                        float2 offset = _lineWidth;
                        
                        // 四方向采样
                        float4 up = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(0, offset.y));
                        float4 down = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV - float2(0, offset.y));
                        float4 left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV - float2(offset.x, 0));
                        float4 right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, finalUV + float2(offset.x, 0));

                        // 优化描边计算
                        outlineAlpha = max(max(max(
                            saturate(tex2DNode1.a - up.a),
                            saturate(tex2DNode1.a - down.a)),
                            saturate(tex2DNode1.a - left.a)),
                            saturate(tex2DNode1.a - right.a));
                    }
                #endif

                // 条件HSV转换
                float3 finalColor;
                #if defined(_USE_HSV_SHIFT)
                    float3 hsvTorgb14 = RGBToHSV(tex2DNode1.rgb);
                    finalColor = HSVToRGB(float3((_HueSwitch + hsvTorgb14.x), (hsvTorgb14.y * _SaturationVa), hsvTorgb14.z));
                #else
                    finalColor = tex2DNode1.rgb;
                #endif

                // 计算最终颜色
                float3 allColor = finalColor * baseColorRGB * vertexColorRGB;
                
                // 应用亮度控制
                #if defined(_USE_CUSTOM_BRIGHTNESS)
                    allColor *= customBrightness;
                #endif
                
                float3 Color;
                
                #if defined(_USE_OUTLINE)
                    Color = lerp(allColor, _lineColor.rgb, outlineAlpha);
                #else
                    Color = allColor;
                #endif

                // 优化软粒子处理
                float softparticle = 1.0;
                #if defined(_SOFT_PARTICLES_ON)
                    if (_DepthFade > 0.001)
                    {
                        float4 screenPos = IN.scrPos / IN.scrPos.w;
                        float2 screenUV = screenPos.xy;
                        screenPos.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPos.z : screenPos.z * 0.5 + 0.5;
                        float sceneDepth = SampleSceneDepth(screenUV);
                        float linearEyeDepth = LinearEyeDepth(sceneDepth, _ZBufferParams);
                        float linearParticleDepth = LinearEyeDepth(screenPos.z, _ZBufferParams);
                        float depthDiff = linearEyeDepth - linearParticleDepth;
                        softparticle = saturate(depthDiff / _DepthFade);
                    }
                #endif

                // 简化Alpha计算
                float outlineWeight = 1.0;
                #if defined(_USE_OUTLINE)
                    outlineWeight = 1.0 - outlineAlpha + lerpResult5 * outlineAlpha;
                #endif
                
                float Alpha = min(lerpResult5, outlineWeight) * baseColorA * vertexColorA * softparticle;

                // 返回最终颜色和alpha（修复：不再将softparticle应用于颜色）
                float3 FinalColor = Color;
                return float4(FinalColor, saturate(Alpha));
            }
            ENDHLSL
        }
    }
}