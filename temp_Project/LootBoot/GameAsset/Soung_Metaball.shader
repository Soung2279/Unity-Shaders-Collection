// 2026.04.16 Unity URP 融球(Metaball)粒子特效 Shader
// 用法：挂载在 Quad/Plane Mesh 上，程序化模拟2D融球边缘视觉效果
// - 支持 SRP Batcher（所有属性声明在 UnityPerMaterial CBUFFER 中）
// - 支持 GPU Instancing（#pragma multi_compile_instancing）
// - 纯程序化，无需贴图，基于 1/d^2 Metaball 势场算法
Shader "Soung/Effect/Metaballs"
{
    Properties
    {
        [Header(Setting)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullingMode ("剔除模式", Float) = 0
        [Enum(Less or Equal,4,Always,8)] _ZTestMode ("深度测试", Float) = 4

        [Header(Metaball Color)]
        [HDR] _MainColor ("主色（中心区域）", Color) = (0.8, 0.4, 1.0, 1.0)
        [HDR] _EdgeColor ("边缘颜色", Color) = (0.4, 0.1, 0.9, 0.6)
        _ColorFalloff ("内外颜色渐变幂次", Range(0.1, 5.0)) = 1.5
        [Toggle(_USE_CUSTOM_STREAM)] _UseCustomStream ("使用自定义顶点流控制颜色", Float) = 0

        [Header(Metaball Shape)]
        _ViewScale ("视野缩放", Range(0.5, 5.0)) = 1.5
        [IntRange] _BlobCount ("控制点数量(高消耗)", Range(3, 16)) = 8
        _BlobRadius ("控制点轨道半径", Range(0.05, 1.5)) = 0.35
        _OscillationStrength ("半径振荡幅度", Range(0, 1.0)) = 0.2
        _OscillationFreq ("振荡相位频率", Range(0, 5.0)) = 1.0

        [Header(Metaball Edge)]
        _Threshold ("势场阈值（越小融球越大）", Range(0.5, 50.0)) = 12.0
        _EdgeSoftness ("边缘附加柔化", Range(0.0, 10.0)) = 1.0

        [Header(Animation)]
        _AnimSpeed ("动画速度", Range(0, 5)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
        }

        Pass
        {
            Name "Universal2D"
            Tags { "LightMode" = "Universal2D" }

            Cull [_CullingMode]
            ZWrite OFF
            ZTest [_ZTestMode]
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 3.0  // 要求 GLES 3.0+ / Metal / Vulkan：fwidth() 和动态循环需要硬件导数支持
            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma shader_feature_local _USE_CUSTOM_STREAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // -------------------------------------------------------
            // SRP Batcher 要求：所有 Per-Material 属性必须在此 CBUFFER 中
            // -------------------------------------------------------
            CBUFFER_START(UnityPerMaterial)
                float4 _MainColor;
                float4 _EdgeColor;
                float  _ColorFalloff;
                float  _ViewScale;
                float  _BlobCount;
                float  _BlobRadius;
                float  _OscillationStrength;
                float  _OscillationFreq;
                float  _Threshold;
                float  _EdgeSoftness;
                float  _AnimSpeed;
                float  _UseCustomStream;
                float  _CullingMode;
                float  _ZTestMode;
            CBUFFER_END

            // -------------------------------------------------------
            // Vertex Input / Output
            // -------------------------------------------------------
            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                // Custom1.xyzw / Custom2.xyzw 由粒子系统通过自定义顶点流注入
                float4 customColor1  : TEXCOORD1;  // 主色 RGBA
                float4 customColor2  : TEXCOORD2;  // 边缘色 RGBA
                half4  color         : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS   : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float4 customColor1  : TEXCOORD1;
                float4 customColor2  : TEXCOORD2;
                half4  color         : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // -------------------------------------------------------
            // Vertex Shader
            // -------------------------------------------------------
            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.positionHCS  = TransformObjectToHClip(input.positionOS.xyz);
                output.uv           = input.uv;
                output.customColor1 = input.customColor1;
                output.customColor2 = input.customColor2;
                output.color        = input.color;
                return output;
            }

            // -------------------------------------------------------
            // Fragment Shader
            // Metaball: field = sum(1/|P-Ci|^2), iso-surface at field >= threshold
            // MAX_BLOBS: compile-time constant, runtime loop uses break to limit iterations
            // -------------------------------------------------------
            #define MAX_BLOBS 16
            #define TWO_PI    6.28318530718

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // 将 UV [0,1] 重映射到 [-ViewScale, +ViewScale]（中心化坐标系）
                float2 uv = (input.uv * 2.0 - 1.0) * _ViewScale;

                float time      = _Time.y * _AnimSpeed;
                float blobCount = _BlobCount;

                // 累积融球势场
                // 使用 [unroll] + step() 替代 [loop]+break，避免部分 Android GLES 3.0 驱动
                // 对 fragment shader 中 uniform 控制的动态循环产生兼容性问题
                float field   = 0.0;
                float radStep = TWO_PI / blobCount;   // 提到循环外，避免每次迭代重复除法
                [unroll]
                for (int k = 0; k < MAX_BLOBS; k++)
                {
                    // k < blobCount 时 active=1，否则 active=0，乘法代替 break 分支
                    float active = step((float)k, blobCount - 1.0);

                    // 控制点均匀分布在圆上，每个点做独立的半径振荡
                    float angle      = (float)k * radStep;
                    float r          = _BlobRadius + _OscillationStrength * sin(time + angle * _OscillationFreq);
                    float sinA, cosA;
                    sincos(angle, sinA, cosA);
                    float2 ctrlPoint = r * float2(sinA, cosA);

                    // 1/d^2 势场贡献，inactive 的控制点贡献归零
                    float2 d = uv - ctrlPoint;
                    field += active / max(1e-5, dot(d, d));
                }

                float fw        = fwidth(field);
                float halfRange = max(fw * 1.5, _EdgeSoftness);
                float alpha     = smoothstep(_Threshold - halfRange, _Threshold + halfRange, field);

                clip(alpha - 0.002);

                float colorT = pow(saturate((field - _Threshold) / max(0.001, _Threshold)), _ColorFalloff);

                #if defined(_USE_CUSTOM_STREAM)
                    float4 mainCol = input.customColor1;
                    float4 edgeCol = input.customColor2;
                #else
                    float4 mainCol = _MainColor;
                    float4 edgeCol = _EdgeColor;
                #endif

                half4 col;
                col.rgb = lerp(edgeCol.rgb, mainCol.rgb, colorT) * input.color.rgb;
                col.a   = lerp(edgeCol.a,   mainCol.a,   colorT) * alpha * input.color.a;

                return col;
            }

            ENDHLSL
        }
    }

    FallBack Off
}
