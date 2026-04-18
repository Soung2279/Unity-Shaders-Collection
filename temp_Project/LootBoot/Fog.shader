Shader "Fog/Fog"
{
    Properties
    {
        [HideInInspector] _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Density ("Density", Range(0, 1)) = 0.5
        _Speed ("Speed", Float) = 0.1
        _Scale ("Noise Scale", Float) = 1
        _Threshold ("Alpha Threshold", Range(0, 1)) = 0.2
        _Softness ("Softness", Range(0, 1)) = 0.3
    
        // 添加Stencil相关属性
        [HideInInspector] _StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "PreviewType"="Plane"
        }

        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }

        ColorMask[_ColorMask]

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest[unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };
            
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            fixed4 _Color;
            float _Density;
            float _Speed;
            float _Scale;
            float _Threshold;
            float _Softness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv;
                o.uv1 = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 movingUV = i.uv1 * _Scale + float2( _Time.y * _Speed, _Time.y * _Speed);
                fixed noise = tex2D(_NoiseTex, movingUV).r;
                noise = saturate(noise - _Density);
                float alpha = smoothstep(_Threshold, _Threshold + _Softness, noise);

                float4 color = lerp(i.color, _Color, alpha);
                float4 mask = tex2D(_MainTex, i.uv0);
                return fixed4(color.r, color.g, color.b, clamp(0, 1, 1 - mask.a));
            }
            ENDCG
        }
    }
}
