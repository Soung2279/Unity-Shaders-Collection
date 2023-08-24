Shader "A201-Shader/个人制作/简易生长效果_GrowTest"
{
    Properties
    {
        _MainTex ("纹理", 2D) = "white" {}
        _MaskClipValue("MaskClipValue",Float) = 0
        _Exand("Exand",Float) = -4.6
        _Grow("生长度",Range(0,1)) = 1
        _GrowMin("GrowMin",Range(-2,2)) = 0
        _GrowMax("GrowMax",Range(-2,2)) = 1.15
        _EndMin("EndMin",Range(-2,2)) = 0.6
        _EndMax("EndMax",Range(-2,2)) = 1
        _Scale("Scale",Float) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float _MaskClipValue;
            float _Exand;
            float _Grow;
            float _GrowMax;
            float _GrowMin;
            float _EndMax;
            float _EndMin;
            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                float wight_expand = smoothstep(_GrowMin,_GrowMax,(v.texcoord.y - _Grow));
                float wight_end = smoothstep(_EndMin,_EndMax,v.texcoord.y);
                float wight_combined = max(wight_expand,wight_end);
                float3 vertex_offset = v.normal * _Exand * 0.1 * wight_combined;
                float3 vertex_scale = v.normal * _Scale * 0.1;
                float3 final_offset = vertex_offset + vertex_scale;
                v.vertex.xyz = v.vertex.xyz + final_offset;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(-(i.uv.y - _Grow));
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
