Shader "Fog/DrawMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BrushTex ("Brush", 2D) = "white" {}
        _BrushSize ("BrushSize", float) = 0.1
        _UVPosition ("UV Position", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "PreviewType"="Plane"
        }
        
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            sampler2D _BrushTex;
            float _BrushSize;
            float2 _UVPosition;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 originalColor = tex2D(_MainTex, i.uv);
                float2 uvOffset = i.uv - _UVPosition;
                float distance = length(uvOffset);

                if (distance < _BrushSize)
                {
                    float2 brushUV = uvOffset / _BrushSize * 0.5 + 0.5;
                    float4 brushColor = tex2D(_BrushTex, brushUV);

                    float a = max(brushColor.a, originalColor.a);
                    return fixed4(1, 1, 1, a);
                }

                return originalColor;
            }
            ENDCG
        }
    }
}
