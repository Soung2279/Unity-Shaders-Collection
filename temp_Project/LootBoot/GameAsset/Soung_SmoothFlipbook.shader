Shader "Soung/Effect/SmoothFlipbook"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 10
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        _MainTex ("序列帧", 2D) = "white" {}
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 1
        [IntRange]_RotatorVal("贴图旋转", Range(0, 360)) = 0
        _Cols ("横向数量", Float) = 4
        _Rows ("纵向数量", Float) = 4
        _FPS ("帧率", Float) = 12
        // 混合窗口：0=硬切，0.3=仅最后30%时间平滑过渡，1=全程混合
        _Blend ("混合窗口时间", Range(0,1)) = 0.3
        // 勾选时兼容从左上角起排列的序列帧贴图（大多数情况应勾选）
        [Toggle] _FlipY ("首尾帧翻转", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        Cull [_CullingMode]
        ZWrite Off

        Pass
        {
            Tags { "LightMode" = "Universal2D" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                half4  color      : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                half4  color       : COLOR;
            };

            // -------------------------------------------------------------------
            // 纹理与采样器声明在 CBuffer 之外（SRP Batcher 规范）
            // -------------------------------------------------------------------
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);


            CBUFFER_START(UnityPerMaterial)
                float _BlendMode;
                float _CullingMode;
                float4 _BaseColor;
                float4 _MainTex_ST;
                float  _Cols;
                float  _Rows;
                float  _FPS;
                float  _Blend;
                float  _FlipY;
                float  _RotatorVal;
                float  _SwitchP;
            CBUFFER_END

            // 根据帧索引计算 atlas UV（支持 FlipY）
            float2 GetFrameUV(float2 uv, uint frameIndex)
            {
                float invCols = 1.0 / _Cols;
                float invRows = 1.0 / _Rows;
                float col = (float)(frameIndex % (uint)_Cols);
                float row = floor((float)frameIndex / _Cols);

                float2 result;
                result.x = (uv.x + col) * invCols;
                // 大多数序列帧贴图从左上角开始排列，而 Unity UV 原点在左下角，需翻转 Y
                result.y = (_FlipY > 0.5)
                    ? (uv.y + (_Rows - 1.0 - row)) * invRows
                    : (uv.y + row) * invRows;
                return result;
            }

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                float3 baseColorRGB = _BaseColor.rgb;
                float baseColorA = _BaseColor.a;
                // 贴图旋转：在 atlas 映射前对基础 UV 绕 (0.5, 0.5) 旋转
                float2 baseUV = i.uv;
                if (abs(_RotatorVal) > 0.001)
                {
                    float angle = _RotatorVal * (3.14159265 * 2.0 / 360.0);
                    float s, c;
                    sincos(angle, s, c);
                    float2x2 rotMatrix = float2x2(c, -s, s, c);
                    baseUV = mul(baseUV - 0.5, rotMatrix) + 0.5;
                }

                uint totalFrames = (uint)(_Cols * _Rows);

                float t = _Time.y * _FPS;
                float framePos = fmod(t, (float)totalFrames);

                uint frameA = (uint)framePos;
                float f = frac(framePos); // 当前帧内进度 [0, 1)

                float2 uvA = GetFrameUV(baseUV, frameA);
                half4 colA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvA);

                [branch]
                if (_Blend <= 0.001)
                {
                    half3 finalRGB = colA.rgb * baseColorRGB;
                    float blendAlpha = lerp(colA.r, colA.a, _SwitchP);
                    float finalAlpha = blendAlpha * baseColorA;
                    return half4(finalRGB, finalAlpha) * i.color;
                }

                uint frameB = (frameA + 1u) % totalFrames;
                float2 uvB = GetFrameUV(baseUV, frameB);
                half4 colB = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvB);

                // 混合仅发生在每帧末尾的 _Blend 窗口内，大部分时间为清晰单帧
                float blendStart = 1.0 - _Blend;
                float blendWeight = smoothstep(0.0, 1.0, saturate((f - blendStart) / _Blend));

                half4 col = lerp(colA, colB, blendWeight);
                half3 finalRGB = col.rgb * baseColorRGB;
                // 通道切换：R=0 使用 R 通道作为 alpha（灰度序列帧），A=1 使用 A 通道
                float blendAlpha = lerp(col.r, col.a, _SwitchP);
                float finalAlpha = blendAlpha * baseColorA;
                return half4(finalRGB, finalAlpha) * i.color;
            }
            ENDHLSL
        }
    }
}