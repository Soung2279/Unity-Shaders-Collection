Shader "Soung/UI/BlurMask"
{
    Properties
    {
        [PerRendererData] _MainTex("Captured Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _DarkIntensity("Dark Intensity", Range(0, 1)) = 0.4
        _BlurSpread("Blur Spread", Range(0, 4)) = 1.5
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
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

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                half2  texcoord : TEXCOORD0;
                fixed4 color    : COLOR;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float4    _MainTex_TexelSize;
            fixed4    _Color;
            float     _DarkIntensity;
            float     _BlurSpread;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex   = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.color    = v.color * _Color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv     = i.texcoord;
                float2 offset = _MainTex_TexelSize.xy * _BlurSpread;

                // 9-tap box blur，RT 本身已是 1/4 分辨率，texel 尺寸已放大，模糊半径足够
                fixed4 col  = tex2D(_MainTex, uv + float2(-offset.x, -offset.y));
                       col += tex2D(_MainTex, uv + float2( 0.0,      -offset.y));
                       col += tex2D(_MainTex, uv + float2( offset.x, -offset.y));
                       col += tex2D(_MainTex, uv + float2(-offset.x,  0.0));
                       col += tex2D(_MainTex, uv);
                       col += tex2D(_MainTex, uv + float2( offset.x,  0.0));
                       col += tex2D(_MainTex, uv + float2(-offset.x,  offset.y));
                       col += tex2D(_MainTex, uv + float2( 0.0,       offset.y));
                       col += tex2D(_MainTex, uv + float2( offset.x,  offset.y));
                col /= 9.0;

                // 叠加暗色蒙层
                col.rgb = lerp(col.rgb, fixed3(0.0, 0.0, 0.0), _DarkIntensity);
                col.a   = i.color.a;

                return col;
            }
            ENDCG
        }
    }
}
