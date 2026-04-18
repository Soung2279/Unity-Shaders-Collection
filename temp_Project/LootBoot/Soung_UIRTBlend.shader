// RT专用显示Shader：正确处理预乘Alpha的RenderTexture
Shader "Soung/UI/RTDisplay"
{
    Properties
    {
        [PerRendererData]_MainTex("传入RT", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)

        [HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

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
        Blend One OneMinusSrcAlpha   // 正确处理预乘Alpha
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex        : SV_POSITION;
                fixed4 color         : COLOR;
                float2 texcoord      : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float4    _ClipRect;
            fixed4    _BaseColor;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                OUT.worldPosition = v.vertex;
                OUT.vertex        = UnityObjectToClipPos(v.vertex);
                OUT.texcoord      = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.color         = v.color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                // RT内RGB已是预乘Alpha，直接采样输出即可
                fixed4 col = tex2D(_MainTex, IN.texcoord);

                // 应用颜色和亮度（HDR支持亮度>1）
                col *= _BaseColor;

                // 支持整体透明度（如CanvasGroup淡出）
                col *= IN.color.a;

                #ifdef UNITY_UI_CLIP_RECT
                    col *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                return col;
            }
            ENDCG
        }
    }
}