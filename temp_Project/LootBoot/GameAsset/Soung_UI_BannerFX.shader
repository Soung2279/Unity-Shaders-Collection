Shader "Soung/UI/BannerFX"
{
    Properties
    {
        // Stencil（用于 Mask 组件）
        _StencilComp      ("Stencil Comparison",   Float) = 8
        _Stencil          ("Stencil ID",           Float) = 0
        _StencilOp        ("Stencil Operation",    Float) = 0
        _StencilWriteMask ("Stencil Write Mask",   Float) = 255
        _StencilReadMask  ("Stencil Read Mask",    Float) = 255
        _ColorMask        ("Color Mask",           Float) = 15

        // 颜色（每根射线在此两色之间随机取色）
        [HDR]_ColorA ("Color A", Color) = (1,0.6,0,1)
        [HDR]_ColorB ("Color B", Color) = (1,0.95,0.5,1)

        _RayCount ("射线数量", Float) = 24

        // 射线宽度范围（角度空间 0~0.5）
        _RayWidthMin ("射线宽度最小值", Float) = 0.01
        _RayWidthMax ("射线宽度最大值", Float) = 0.35

        // 射线长度范围（UV 空间单位）
        _RayLengthMin ("射线长度最小值", Float) = 0.9
        _RayLengthMax ("射线长度最大值", Float) = 2.0

        // 每根射线生命周期速度范围（值越大循环越快）
        _SpeedMin ("射线速度最小值", Float) = 0.3
        _SpeedMax ("射线速度最大值", Float) = 0.8

        // 射线方向随机程度（0=规律均匀，1=完全随机）
        _DirectionVariance ("射线方向随机程度", Range(0, 1)) = 1

        // 折射幅度（内外段角度偏移量，建议 0.05~0.3）
        _RefractAmount ("折射幅度", Float) = 0.1
        // 受折射影响的射线比例（0~1）
        _RefractChance ("受折射影响的射线比例", Range(0, 1)) = 0.5
        // 折射次数（0=直线，最多 4 次折射）
        [IntRange]_KinkCount ("折射次数", Range(0, 4)) = 1

        _CenterBrightness ("中心亮度", Float) = 2
    }

    SubShader
    {
        Tags
        {
            "Queue"             = "Transparent"
            "IgnoreProjector"   = "True"
            "RenderType"        = "Transparent"
            "PreviewType"       = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        Cull Off

        Pass
        {
            Name "Default"

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #define PI 3.14159265359

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float4 canvasPos   : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _ColorA;
            float4 _ColorB;

            float _RayCount;

            float _RayWidthMin;
            float _RayWidthMax;

            float _RayLengthMin;
            float _RayLengthMax;

            float _SpeedMin;
            float _SpeedMax;

            float _DirectionVariance;

            float _RefractAmount;
            float _RefractChance;
            float _KinkCount;

            float _CenterBrightness;

            float4 _ClipRect;

            Varyings vert(Attributes v)
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.canvasPos   = v.positionOS;
                o.positionHCS = UnityObjectToClipPos(v.positionOS);
                o.uv          = v.uv;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                // 中心化
                float2 p = uv - 0.5;

                // 宽高比修正
                p.x *= _ScreenParams.x / _ScreenParams.y;

                float radius = length(p);

                // 角度
                float angle = atan2(p.y, p.x);

                // 0~1
                float angle01 = angle / (PI * 2.0) + 0.5;

                // 射线数量
                float rayCoord = angle01 * _RayCount;

                float rayId = floor(rayCoord);

                // 每根射线随机参数
                float rand1 = frac(sin(rayId * 91.32) * 43758.5453); // 宽度
                float rand2 = frac(sin(rayId * 17.77) * 24634.6345); // 长度
                float rand3 = frac(sin(rayId * 37.51) * 91234.7812); // 相位偏移
                float rand4 = frac(sin(rayId * 53.71) * 73856.1234); // 速度
                float rand5 = frac(sin(rayId * 79.03) * 31547.8901); // 颜色

                // 提前计算速度和周期编号，供 rand6 使用
                float raySpeed = lerp(_SpeedMin, _SpeedMax, rand4);
                float cycleIdx = floor(_Time.y * raySpeed + rand3);
                // 每个生命周期结束后重新随机取得发射方向
                float rand6 = frac(sin(rayId * 13.47 + cycleIdx * 7.31) * 64321.5678);

                float rand7 = frac(sin(rayId * 43.91) * 82741.3456); // 折射方向
                float rand8 = frac(sin(rayId * 29.67) * 47293.8712); // 折射参与

                // 射线宽度（由参数范围随机）
                float width = lerp(_RayWidthMin, _RayWidthMax, rand1);

                // 每根射线在角度槽内随机偏移方向（0.1~0.9 避免贴近槽边界）
                // _DirectionVariance=0 时所有射线从槽中心发射，=1 时完全随机
                float rayDir = lerp(0.5, lerp(0.1, 0.9, rand6), _DirectionVariance);

                // 是否受折射影响（_RefractChance 控制比例）
                float isKinked = step(1.0 - _RefractChance, rand8);

                // 每个折射点的随机方向和步长种子（最多支持 4 次折射）
                float4 kinkRandDir  = float4(
                    rand7,
                    frac(sin(rayId * 67.13) * 51234.6789),
                    frac(sin(rayId * 19.83) * 91847.5623),
                    frac(sin(rayId * 71.61) * 28374.1596)
                );
                float4 kinkRandDist = float4(
                    rand8,
                    frac(sin(rayId * 83.57) * 37891.2345),
                    frac(sin(rayId * 47.29) * 64523.9871),
                    frac(sin(rayId * 31.47) * 75926.4183)
                );

                // 射线基础方向（绝对角度）
                float kinkAngle  = ((rayId + rayDir) / _RayCount - 0.5) * (PI * 2.0);
                // 角度宽度转换为世界空间
                float worldWidth = width * (PI * 2.0 / _RayCount) * radius;

                // 构建折线链并累积遮罩
                float2 segOrigin = float2(0.0, 0.0);
                float  segAngle  = kinkAngle;
                float  rayMask   = 0.0;

                // 有界折线段（_KinkCount 段，每段到下一折射点为止）
                [unroll]
                for (int ki = 0; ki < 4; ki++)
                {
                    float  active   = step(float(ki), _KinkCount - 1.0);
                    float  stepDist = lerp(0.1, 0.4, kinkRandDist[ki]);
                    float2 segDir   = float2(cos(segAngle), sin(segAngle));

                    float2 fromSeg  = p - segOrigin;
                    float  fwd      = dot(fromSeg, segDir);
                    float  perp     = abs(fromSeg.x * segDir.y - fromSeg.y * segDir.x);
                    float  segMask  = step(0.0, fwd) * step(fwd, stepDist) * step(perp, worldWidth);

                    rayMask = saturate(rayMask + segMask * active);

                    // 推进到下一折射点
                    float deltaAngle = lerp(-_RefractAmount, _RefractAmount, kinkRandDir[ki])
                                     * isKinked * active;
                    segOrigin += stepDist * segDir * active;
                    segAngle  += deltaAngle;
                }

                // 最终段（从最后折射点向外延伸，不设上界）
                {
                    float2 segDir  = float2(cos(segAngle), sin(segAngle));
                    float2 fromSeg = p - segOrigin;
                    float  fwd     = dot(fromSeg, segDir);
                    float  perp    = abs(fromSeg.x * segDir.y - fromSeg.y * segDir.x);
                    rayMask = saturate(rayMask + step(0.0, fwd) * step(perp, worldWidth));
                }

                // =========================
                // 关键：半径方向拉伸
                // =========================

                // 射线长度（由参数范围随机）
                float rayLength = lerp(_RayLengthMin, _RayLengthMax, rand2);

                // 每根射线独立速度和生命周期（0=刚出生，1=消亡）
                float life = frac(_Time.y * raySpeed + rand3);

                // 射线前端随生命周期向外推进
                float tipRadius = life * rayLength;
                float radial = step(radius, tipRadius);

                // 生命周期内透明度从 100% 线性降至 0%
                float rayAlpha = 1.0 - life;

                // 中心强化（_CenterBrightness 控制亮度强度）
                float centerBoost =
                    _CenterBrightness / (radius * 12.0 + 0.08);

                // 射线颜色强度（用于颜色插值，不含透明度）
                float intensity = rayMask * radial;

                // 每根射线在 ColorA~ColorB 渐变中随机取色
                float3 rayColor = lerp(_ColorA.rgb, _ColorB.rgb, rand5);

                // 颜色合成：射线用随机色，中心用 ColorA
                float3 col = rayColor * saturate(intensity * 2.0)
                           + _ColorA.rgb * saturate(centerBoost);
                col = saturate(col);

                // 最终透明度：射线区域用生命周期衰减，中心始终可见
                float finalAlpha = rayMask * radial * rayAlpha
                    + saturate(centerBoost);
                finalAlpha = saturate(finalAlpha);

                // RectMask2D 裁切
                #ifdef UNITY_UI_CLIP_RECT
                finalAlpha *= UnityGet2DClipping(i.canvasPos.xy, _ClipRect);
                #endif

                // Mask 组件 Alpha 裁切
                #ifdef UNITY_UI_ALPHACLIP
                clip(finalAlpha - 0.001);
                #endif

                return half4(col, finalAlpha);
            }

            ENDCG
        }
    }
}