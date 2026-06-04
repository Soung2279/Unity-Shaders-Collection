// 2026.5.14 created by Soung
// 钻石质感 Shader — 适用于粒子系统 Quad (URP Universal2D)
// 功能模块：MatCap 球面反射 | 彩虹色散 | RGB 色差 | Voronoi 闪光 | 边缘光

Shader "Soung/Effect/Diamond"
{
    Properties
    {
        [Header(Setting)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(ON,1,OFF,0)]_Zwrite("深度写入", Float) = 0
        [Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
        [Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 10

        [Header(Main)]
        _MainTex("主贴图 (RGB=底色 A=遮罩)", 2D) = "white" {}
        [HDR]_MainColor("主颜色", Color) = (1,1,1,1)

        [Header(MatCap)]
        [Toggle(_MATCAP_ON)]_MatCapEnable("启用 MatCap 球面反射", Float) = 1
        _MatCapTex("MatCap 贴图 (钻石球面烘焙图)", 2D) = "white" {}
        _MatCapIntensity("MatCap 强度", Range(0, 3)) = 1.0
        _MatCapRotateSpeed("MatCap 旋转速度 (动态模拟视角偏移)", Float) = 0.15
        [Enum(Add,0,MultiplyBrighten,1)]_MatCapBlendMode("MatCap 混合模式", Float) = 0

        [Header(Rainbow)]
        [Toggle(_RAINBOW_ON)]_RainbowEnable("启用彩虹色散", Float) = 1
        _RainbowPolarParams("极坐标参数 (轴心X Y  段数Z  层数W)", Vector) = (0.5, 0.5, 4, 0)
        _RainbowSpeed("彩虹旋转速度", Float) = 0.25
        _RainbowSaturation("彩虹饱和度", Range(0, 1)) = 0.85
        _RainbowBrightness("彩虹亮度", Range(0, 2)) = 1.0
        _RainbowBlend("彩虹混合强度", Range(0, 1)) = 0.45

        [Header(Sparkle)]
        [Toggle(_SPARKLE_ON)]_SparkleEnable("启用闪光高光", Float) = 1
        _SparkleTex("闪光噪声贴图 (推荐 Voronoi 噪声)", 2D) = "white" {}
        _SparkleTile("闪光噪声缩放倍数", Float) = 4.0
        _SparkleSpeedU("闪光 U 滚动速度", Float) = 0.13
        _SparkleSpeedV("闪光 V 滚动速度", Float) = 0.07
        _SparklePower("闪光锐化程度 (越大越集中)", Range(1, 24)) = 9
        _SparkleIntensity("闪光亮度", Range(0, 6)) = 2.5
        [HDR]_SparkleColor("闪光颜色", Color) = (1,1,1,1)
        _SparkleFlickerSpeed("闪光闪烁速度", Float) = 2.5

        [Header(Rim)]
        [Toggle(_RIM_ON)]_RimEnable("启用边缘光", Float) = 1
        _RimPower("边缘光集中度 (越小越宽)", Range(0.1, 8)) = 2.5
        _RimIntensity("边缘光强度", Range(0, 4)) = 1.2
        [HDR]_RimColor("边缘光颜色", Color) = (0.6,0.85,1,1)
    }

    SubShader
    {
        LOD 0

        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "UniversalMaterialType"="Unlit"
        }

        Cull [_CullingMode]
        AlphaToMask Off

        Pass
        {
            Name "Universal2D"
            Tags { "LightMode" = "Universal2D" }

            Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
            ZWrite [_Zwrite]
            ZTest [_ZTestMode]
            Offset 0, 0
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma multi_compile_instancing

            #pragma shader_feature_local _MATCAP_ON
            #pragma shader_feature_local _RAINBOW_ON
            #pragma shader_feature_local _SPARKLE_ON
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local UNITY_UI_CLIP_RECT
            #pragma shader_feature_local UNITY_UI_ALPHACLIP

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _MainColor;
                float4 _MatCapTex_ST;
                float4 _SparkleTex_ST;
                float4 _SparkleColor;
                float4 _RimColor;

                float _MatCapIntensity;
                float _MatCapRotateSpeed;
                float _MatCapBlendMode;

                float4 _RainbowPolarParams;  // xy=轴心UV  z=段数  w=层数
                float _RainbowSpeed;
                float _RainbowSaturation;
                float _RainbowBrightness;
                float _RainbowBlend;

                float _SparkleTile;
                float _SparkleSpeedU;
                float _SparkleSpeedV;
                float _SparklePower;
                float _SparkleIntensity;
                float _SparkleFlickerSpeed;

                float _RimPower;
                float _RimIntensity;

                // UI RectMask2D（由系统自动设置，无需在 Properties 中声明）
                float4 _ClipRect;
                float _UIMaskSoftnessX;
                float _UIMaskSoftnessY;
            CBUFFER_END

            TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
            TEXTURE2D(_MatCapTex);  SAMPLER(sampler_MatCapTex);
            TEXTURE2D(_SparkleTex); SAMPLER(sampler_SparkleTex);

            // HSV -> RGB 转换（用于彩虹色计算）
            float3 HSVToRGB(float3 c)
            {
                float4 k = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + k.xyz) * 6.0 - k.www);
                return c.z * lerp(k.xxx, saturate(p - k.xxx), c.y);
            }

            struct a2v
            {
                float4 vertex    : POSITION;
                float4 texcoord  : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;  // Custom1.xyzw（保留，便于后续扩展）
                float4 texcoord2 : TEXCOORD2;  // Custom2.xyzw（保留）
                float4 color     : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos  : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float2 worldPos : TEXCOORD1;  // UI RectMask2D 裁剪用世界坐标
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f VERT(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.uv      = v.texcoord.xy;
                o.color   = v.color;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.worldPos = positionWS.xy;
                o.clipPos  = TransformWorldToHClip(positionWS);
                return o;
            }

            float4 FRAG(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float2 uv         = IN.uv;
                float2 uvMain     = uv * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 centeredUV = uv - 0.5;  // [-0.5, 0.5] 居中坐标

                // ─────────────────────────────────────────────────────────
                // 1. 主贴图采样
                // ─────────────────────────────────────────────────────────
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvMain);

                // 基础透明度剔除
                float alpha = mainSample.a * _MainColor.a * IN.color.a;
                clip(alpha - 0.001);

                float3 baseColor = mainSample.rgb * _MainColor.rgb * IN.color.rgb;

                // ─────────────────────────────────────────────────────────
                // 2. MatCap 球面反射
                //    以 UV 作为"伪法线"，对 MatCap 贴图进行采样。
                //    缓慢旋转中心坐标模拟视角微动，产生动态折射感。
                // ─────────────────────────────────────────────────────────
                #if defined(_MATCAP_ON)
                    float mcAngle = _Time.y * _MatCapRotateSpeed;
                    float mcCos   = cos(mcAngle);
                    float mcSin   = sin(mcAngle);
                    float2 mcRotUV = float2(
                        centeredUV.x * mcCos - centeredUV.y * mcSin,
                        centeredUV.x * mcSin + centeredUV.y * mcCos
                    );
                    // 将 [-0.5, 0.5] 旋转后坐标映射到 [0, 1]
                    float2 matcapUV  = saturate(mcRotUV + 0.5);
                    float3 matcapRGB = SAMPLE_TEXTURE2D(_MatCapTex, sampler_MatCapTex, matcapUV).rgb;
                    matcapRGB *= _MatCapIntensity;

                    // mode=0：叠加（Add），mode=1：乘法提亮（MultiplyBrighten）
                    float3 matcapAdd = baseColor + matcapRGB;
                    float3 matcapMul = baseColor * (1.0 + matcapRGB);
                    baseColor = lerp(matcapAdd, matcapMul, _MatCapBlendMode);
                #endif

                // ─────────────────────────────────────────────────────────
                // 3. 彩虹色散
                //    以极坐标角度为色相，随时间旋转，产生棱镜分光效果。
                // ─────────────────────────────────────────────────────────
                #if defined(_RAINBOW_ON)
                    float2 rainbowUV  = uv - _RainbowPolarParams.xy;
                    float polarAngle  = atan2(rainbowUV.y, rainbowUV.x) * (1.0 / TWO_PI) + 0.5;
                    float polarRadius = length(rainbowUV);
                    float hue         = frac(polarAngle * _RainbowPolarParams.z
                                            + polarRadius * _RainbowPolarParams.w
                                            + _Time.y * _RainbowSpeed);
                    float3 rainbow    = HSVToRGB(float3(hue, _RainbowSaturation, _RainbowBrightness));
                    baseColor         = lerp(baseColor, baseColor * rainbow, _RainbowBlend);
                #endif

                // ─────────────────────────────────────────────────────────
                // 4. 闪光高光（Voronoi Sparkle）
                //    滚动噪声贴图，配合 pow 收窄高光点，sin 波闪烁。
                // ─────────────────────────────────────────────────────────
                #if defined(_SPARKLE_ON)
                    float2 sparkleUV    = uv * _SparkleTile + _Time.y * float2(_SparkleSpeedU, _SparkleSpeedV);
                    float  sparkleNoise = SAMPLE_TEXTURE2D(_SparkleTex, sampler_SparkleTex, sparkleUV).r;
                    sparkleNoise = pow(saturate(sparkleNoise), _SparklePower);

                    // 每个像素有独立相位的闪烁波，让高光点此起彼伏
                    float flicker = 0.5 + 0.5 * sin(_Time.y * _SparkleFlickerSpeed
                                    + uv.x * 6.2832 + uv.y * 4.7124);
                    sparkleNoise *= flicker;

                    // 仅在主贴图 alpha 范围内叠加闪光
                    baseColor += sparkleNoise * _SparkleColor.rgb * _SparkleIntensity * mainSample.a;
                #endif

                // ─────────────────────────────────────────────────────────
                // 5. 边缘光（Rim）
                //    以 UV 距中心的距离模拟菲涅尔效果，让钻石边缘发光。
                // ─────────────────────────────────────────────────────────
                #if defined(_RIM_ON)
                    float dist   = saturate(length(centeredUV) * 2.0);
                    float rimMask = pow(dist, _RimPower);
                    baseColor += rimMask * _RimColor.rgb * _RimIntensity * mainSample.a;
                #endif

                // ─────────────────────────────────────────────────────────
                // 6. UI RectMask2D 裁剪
                //    软裁剪：计算像素到裁剪矩形各边的距离并线性衰减 alpha。
                //    硬裁剪（UNITY_UI_ALPHACLIP）：配合 Mask 模板测试使用。
                // ─────────────────────────────────────────────────────────
                #if defined(UNITY_UI_CLIP_RECT)
                    float2 rectSoftness = max(float2(_UIMaskSoftnessX, _UIMaskSoftnessY), float2(1e-5, 1e-5));
                    float2 rectDist = (_ClipRect.zw - _ClipRect.xy
                                      - abs(IN.worldPos * 2.0 - _ClipRect.zw - _ClipRect.xy))
                                      / rectSoftness;
                    alpha *= saturate(rectDist.x) * saturate(rectDist.y);
                #endif

                #if defined(UNITY_UI_ALPHACLIP)
                    clip(alpha - 0.001);
                #endif

                return float4(baseColor, alpha);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
