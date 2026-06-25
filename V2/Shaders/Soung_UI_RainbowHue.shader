// 2026.5.19 created by Soung
// UI 彩虹色散 + 色相自动偏移 Shader — 仅用于 UI Canvas
// 功能模块：色相自动偏移 | 彩虹色散 | RectMask2D 软裁剪 | Mask 模板测试

Shader "Soung/UI/RainbowHue"
{
    Properties
    {
        [Header(Setting)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0

        [Header(Main)]
        _MainTex("主贴图 (RGBA)", 2D) = "white" {}
        [HDR]_MainColor("主颜色", Color) = (1,1,1,1)

        [Header(HueShift)]
        [Toggle(_HUESHIFT_ON)]_HueShiftEnable("启用色相自动偏移", Float) = 1
        _HueShiftSpeed("色相偏移速度", Float) = 0.25

        [Header(Rainbow)]
        [Toggle(_RAINBOW_ON)]_RainbowEnable("启用彩虹色散", Float) = 1
        _RainbowPolarParams("极坐标参数 (轴心X Y  段数Z  径向层数W)", Vector) = (0.5, 0.5, 4, 0)
        _RainbowSpeed("彩虹旋转速度", Float) = 0.25
        _RainbowSaturation("彩虹饱和度", Range(0, 1)) = 0.85
        _RainbowBrightness("彩虹亮度", Range(0, 2)) = 1.0
        _RainbowBlend("彩虹混合强度", Range(0, 1)) = 0.45

        // ── Unity UI 内置属性（由 Mask / RectMask2D 系统自动设置，勿删）──
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
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

        // Mask 组件模板测试配置
        Stencil
        {
            Ref       [_Stencil]
            Comp      [_StencilComp]
            Pass      [_StencilOp]
            ReadMask  [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull      [_CullingMode]
        Lighting  Off
        ZWrite    Off
        ZTest     [unity_GUIZTestMode]
        Blend     SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            // RectMask2D 软裁剪 & Mask 硬裁剪关键字（由 Unity UI 系统设置）
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #pragma shader_feature_local _HUESHIFT_ON
            #pragma shader_feature_local _RAINBOW_ON

            // ─── 顶点输入 ───────────────────────────────────────────────
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // ─── 顶点到片元 ─────────────────────────────────────────────
            struct v2f
            {
                float4 vertex        : SV_POSITION;
                fixed4 color         : COLOR;
                float2 texcoord      : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;  // UnityGet2DClipping 使用 xy 分量
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ─── 材质参数 ───────────────────────────────────────────────
            sampler2D _MainTex;
            float4    _MainTex_ST;
            fixed4    _MainColor;

            float _HueShiftSpeed;

            float4 _RainbowPolarParams;   // xy=轴心UV  z=段数  w=径向层数
            float  _RainbowSpeed;
            float  _RainbowSaturation;
            float  _RainbowBrightness;
            float  _RainbowBlend;

            float4 _ClipRect;             // 由 RectMask2D 系统自动设置

            // ─── 工具函数：RGB ↔ HSV ────────────────────────────────────

            // RGB → HSV（输出：H∈[0,1]  S∈[0,1]  V∈[0,1]）
            float3 RGBToHSV(float3 c)
            {
                float4 k = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float  d = q.x - min(q.w, q.y);
                float  e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            // HSV → RGB
            float3 HSVToRGB(float3 c)
            {
                float4 k = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + k.xyz) * 6.0 - k.www);
                return c.z * lerp(k.xxx, saturate(p - k.xxx), c.y);
            }

            // ─── 顶点着色器 ─────────────────────────────────────────────
            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // worldPosition.xy 用于 RectMask2D 裁剪
                o.worldPosition = v.vertex;
                o.vertex        = UnityObjectToClipPos(o.worldPosition);
                o.texcoord      = TRANSFORM_TEX(v.texcoord, _MainTex);
                // 顶点色与主颜色在顶点阶段合并，减少 fragment 运算量
                o.color         = v.color * _MainColor;
                return o;
            }

            // ─── 片元着色器 ─────────────────────────────────────────────
            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;

                // ─────────────────────────────────────────────────────────
                // 1. 主贴图采样
                // ─────────────────────────────────────────────────────────
                half4 mainSample = tex2D(_MainTex, uv);
                float3 baseColor = mainSample.rgb * IN.color.rgb;
                float  alpha     = mainSample.a * IN.color.a;

                // ─────────────────────────────────────────────────────────
                // 2. 色相自动偏移
                //    将采样颜色转到 HSV 空间，对 H 分量施加时间偏移，
                //    再转回 RGB，实现全局色相随时间循环变化。
                // ─────────────────────────────────────────────────────────
                #if defined(_HUESHIFT_ON)
                    float3 hsv = RGBToHSV(baseColor);
                    hsv.x      = frac(hsv.x + _Time.y * _HueShiftSpeed);
                    baseColor  = HSVToRGB(hsv);
                #endif

                // ─────────────────────────────────────────────────────────
                // 3. 彩虹色散
                //    以极坐标角度为色相，随时间旋转，产生棱镜分光效果。
                //    _RainbowBlend 控制与基础色的混合比例。
                // ─────────────────────────────────────────────────────────
                #if defined(_RAINBOW_ON)
                    float2 rainbowUV  = uv - _RainbowPolarParams.xy;
                    float  polarAngle = atan2(rainbowUV.y, rainbowUV.x) * (1.0 / (2.0 * UNITY_PI)) + 0.5;
                    float  polarRadius = length(rainbowUV);
                    float  hue = frac(
                        polarAngle     * _RainbowPolarParams.z
                        + polarRadius  * _RainbowPolarParams.w
                        + _Time.y      * _RainbowSpeed
                    );
                    float3 rainbow = HSVToRGB(float3(hue, _RainbowSaturation, _RainbowBrightness));
                    baseColor = lerp(baseColor, baseColor * rainbow, _RainbowBlend);
                #endif

                // ─────────────────────────────────────────────────────────
                // 4. RectMask2D 软裁剪
                //    UnityGet2DClipping 返回 [0,1] 权重；像素在裁剪矩形外
                //    时权重为 0，在矩形内时为 1，边缘处按软化距离平滑过渡。
                // ─────────────────────────────────────────────────────────
                #if defined(UNITY_UI_CLIP_RECT)
                    alpha *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                // ─────────────────────────────────────────────────────────
                // 5. Mask 硬裁剪（配合模板测试使用）
                // ─────────────────────────────────────────────────────────
                #if defined(UNITY_UI_ALPHACLIP)
                    clip(alpha - 0.001);
                #endif

                return fixed4(baseColor, alpha);
            }
            ENDCG
        }
    }

    FallBack Off
}
