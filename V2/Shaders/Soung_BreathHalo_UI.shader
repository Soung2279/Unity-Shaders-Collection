// 修改于2026.4.11
Shader "Soung/UI/BreathHalo_UI"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1

        _MainTex("贴图", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 1

        [Header(Breath)]
        _BreathFreq("呼吸频率(次/秒)", Range(0.1, 10)) = 1.0
        _MinAlpha("最低透明度", Range(0, 1)) = 0.0
        _MaxAlpha("最高透明度", Range(0, 1)) = 1.0

        // ---- Unity Mask / RectMask2D 所需属性，由 Unity 自动写入，不需要手动修改 ----
        [HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask("Color Mask", Float) = 15
        [HideInInspector][Toggle(UNITY_UI_ALPHACLIP)]_UseUIAlphaClip("Use Alpha Clip", Float) = 0
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

        // Mask 组件通过 Stencil 进行遮罩，由 Unity 在运行时写入参数
        Stencil
        {
            Ref       [_Stencil]
            Comp      [_StencilComp]
            Pass      [_StencilOp]
            ReadMask  [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull      [_CullingMode]
        Lighting   Off
        ZWrite     Off
        ZTest      [unity_GUIZTestMode]
        Blend      SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        ColorMask  [_ColorMask]

        Pass
        {
            Name "Default"

            CGPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            // RectMask2D 裁剪 keyword，由 RectMask2D 组件在运行时开启
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            // AlphaClip keyword，配合 Mask 组件边缘使用
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct a2v
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos   : SV_POSITION;
                float2 uv        : TEXCOORD0;
                float4 color     : COLOR;
                float4 canvasPos : TEXCOORD1; // Canvas 空间坐标，供 UnityGet2DClipping 裁剪使用
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float  _SwitchP;
            float  _BreathFreq;
            float  _MinAlpha;
            float  _MaxAlpha;
            float4 _ClipRect; // 由 RectMask2D 自动写入，表示裁剪矩形范围（Canvas 世界空间）

            v2f VERT(a2v v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // 保存原始顶点坐标（Canvas 世界空间），用于 RectMask2D 范围判断
                o.canvasPos = v.vertex;
                o.clipPos   = UnityObjectToClipPos(v.vertex);
                o.uv        = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.color     = v.color;

                return o;
            }

            fixed4 FRAG(v2f IN) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 采样贴图
                fixed4 texSample = tex2D(_MainTex, IN.uv);
                float  texAlpha  = lerp(texSample.r, texSample.a, _SwitchP);

                // 呼吸曲线：(1 - cos(t * freq * 2π)) / 2  =>  0 → 1 → 0 无缝循环
                float t          = _Time.y * _BreathFreq * 6.28318530718;
                float breathAlpha = (1.0 - cos(t)) * 0.5;
                // 映射到 [_MinAlpha, _MaxAlpha] 区间
                breathAlpha = lerp(_MinAlpha, _MaxAlpha, breathAlpha);

                float finalAlpha  = breathAlpha * texAlpha * _BaseColor.a * IN.color.a;
                fixed3 finalColor = texSample.rgb * _BaseColor.rgb * IN.color.rgb;

                fixed4 color = fixed4(finalColor, saturate(finalAlpha));

                // RectMask2D 软裁剪：UnityGet2DClipping 返回 0~1 的遮罩权重
                #ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(IN.canvasPos.xy, _ClipRect);
                #endif

                // AlphaClip：配合 Mask 组件硬边缘裁剪
                #ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
                #endif

                return color;
            }
            ENDCG
        }
    }
}
