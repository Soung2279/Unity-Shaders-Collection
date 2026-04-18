Shader "Soung/UI/ZhuanchangSquare"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _WaveProgress ("转场进度(_WaveProgress)", Range(0, 1)) = 0.1
        [HDR]_Color1 ("方格边缘色", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR]_Color2 ("整体颜色", Color) = (0.5, 0.75, 1.0, 1.0)
        _GridScale ("方格缩放", Float) = 10.0
        _AlphaMultiplier ("整体亮度", Range(0, 1)) = 1

        
        [Header(Wave Direction)]
        [Int]_WaveAngle ("转场角度", Range(0, 360)) = 270
        _WaveSpread ("转场填充速度", Range(0, 1)) = 1
        _WaveIntensity ("转场渐变强度", Range(0, 2)) = 1.0
        _WaveSharpness ("方格锐利度", Range(0, 1)) = 0.2
        
        [Header(Resolution Settings)]
        [Toggle] _UseScreenResolution ("使用屏幕UV", Float) = 1
        _CustomResolutionX ("自定义分辨率X", Float) = 1920
        _CustomResolutionY ("自定义分辨率Y", Float) = 1080
        
        // UI必需的属性
        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask ("Color Mask", Float) = 15
    }
    
    SubShader
    {
        Tags 
        { 
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        
        // UI遮罩支持
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            Name "Default"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color1;
                float4 _Color2;
                float _GridScale;
                float _WaveProgress;
                float _AlphaMultiplier;
                float _WaveAngle;
                float _WaveSpread;
                float _WaveIntensity;
                float _WaveSharpness;
                float _UseScreenResolution;
                float _CustomResolutionX;
                float _CustomResolutionY;
            CBUFFER_END
            
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionHCS);
                
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target
            {
                float2 fragCoord;
                float2 iResolution;
                
                // 根据设置选择使用屏幕分辨率还是自定义分辨率
                if (_UseScreenResolution > 0.5)
                {
                    // 使用屏幕分辨率
                    iResolution = _ScreenParams.xy;
                    fragCoord = input.screenPos.xy / input.screenPos.w * iResolution;
                }
                else
                {
                    // 使用自定义分辨率
                    iResolution = float2(_CustomResolutionX, _CustomResolutionY);
                    // 将UV映射到自定义分辨率
                    fragCoord = input.uv * iResolution;
                }
                
                // 首先计算波纹方向（在旋转之前）
                float aspect = iResolution.y / iResolution.x;
                float2 originalUV = fragCoord.xy / iResolution.x;
                originalUV -= float2(0.5, 0.5 * aspect);
                
                // 计算波纹传播方向
                float waveAngleRad = radians(_WaveAngle);
                float2 waveDirection = float2(cos(waveAngleRad), sin(waveAngleRad));
                
                // 计算当前像素在波纹方向上的投影距离
                float waveDistance = dot(originalUV, waveDirection);
                
                // 现在进行方格的旋转变换
                float2 uv = originalUV;
                float rot = radians(45.0);
                float2x2 m = float2x2(cos(rot), -sin(rot), sin(rot), cos(rot));
                uv = mul(m, uv);
                uv += float2(0.5, 0.5 * aspect);
                uv.y += 0.5 * (1.0 - aspect);
                
                // 方格图案计算
                float2 pos = _GridScale * uv;
                float2 rep = frac(pos);
                float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
                
                // 将WaveProgress从0-1范围重新映射到0-0.63范围
                float remappedProgress = _WaveProgress * 0.63;
                
                // 使用重新映射的进度值替换时间
                float waveDelay = waveDistance * _WaveSpread;
                float wavePhase = remappedProgress * 6.28318 + waveDelay; // 6.28318 = 2*PI，完整周期
                
                // 创建更明显的波纹效果
                float waveEffect = sin(wavePhase) * 0.5 + 0.5;
                
                // 使用smoothstep创建更锐利的波纹边缘
                float waveThreshold = 0.5 + sin(wavePhase) * 0.3;
                waveEffect = smoothstep(waveThreshold - (1.0 - _WaveSharpness) * 0.5, 
                                       waveThreshold + (1.0 - _WaveSharpness) * 0.5, 
                                       waveEffect);
                
                // 原始edge计算（保持兼容性）
                float edge = (wavePhase) * 0.5;
                edge = 2.0 * frac(edge * 0.5);
                
                float value = frac(dist * 2.0);
                
                // 结合原始逻辑和新的波纹效果
                float originalEffect = lerp(value, 1.0 - value, step(1.0, edge));
                float enhancedEffect = lerp(value, 1.0 - value, waveEffect);
                
                // 混合原始效果和增强效果
                value = lerp(originalEffect, enhancedEffect, _WaveIntensity);
                
                edge = pow(abs(1.0 - edge), 2.0);
                value = smoothstep(edge - 0.05, edge, 0.95 * value);
                
                // 基于波纹距离添加额外值
                value += abs(waveDistance) * 0.1;
                
                float4 fragColor = lerp(_Color1, _Color2, value);
                fragColor.a = saturate(_AlphaMultiplier * clamp(value, 0.0, 1.0));
                
                // 应用UI颜色
                fragColor *= input.color;
                
                return fragColor;
            }
            ENDHLSL
        }
    }
}