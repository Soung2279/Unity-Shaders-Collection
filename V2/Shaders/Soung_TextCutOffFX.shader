Shader "Soung/Effect/TextCutOffFX"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _CutCenter ("Cut Center", Vector) = (0,0,0,0)
        _CutAngle ("Cut Angle", Float) = 0
        _CutOffset ("Cut Offset", Float) = 0
        _Side ("Side", Float) = 1

        _Gap ("Gap", Float) = 0
        _CutProgress ("Cut Progress", Range(0,1)) = 1

        _EdgeWidth ("Edge Width", Float) = 0.03
        [HDR]_EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeIntensity ("Edge Intensity", Range(0,4)) = 0

        _Alpha ("Alpha", Range(0,1)) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;

            float4 _CutCenter;
            float _CutAngle;
            float _CutOffset;
            float _Side;
            float _Gap;
            float _CutProgress;

            float _EdgeWidth;
            fixed4 _EdgeColor;
            float _EdgeIntensity;
            float _Alpha;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float2 localPos : TEXCOORD1;
            };

            float2 Rotate90(float2 v)
            {
                return float2(-v.y, v.x);
            }

            v2f vert(appdata v)
            {
                v2f o;

                float rad = radians(_CutAngle);
                float2 slashDir = normalize(float2(cos(rad), sin(rad)));
                float2 cutNormal = Rotate90(slashDir);

                float d = dot(v.vertex.xy - _CutCenter.xy, cutNormal) - _CutOffset;

                // 两半沿切线法线方向稍微分开
                float2 gapOffset = cutNormal * _Side * _Gap * _CutProgress;

                float4 pos = v.vertex;
                pos.xy += gapOffset;

                o.pos = UnityObjectToClipPos(pos);
                o.uv = v.uv;
                o.color = v.color * _Color;
                o.localPos = v.vertex.xy;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                col.a *= _Alpha;

                float rad = radians(_CutAngle);
                float2 slashDir = normalize(float2(cos(rad), sin(rad)));
                float2 cutNormal = Rotate90(slashDir);

                float d = dot(i.localPos - _CutCenter.xy, cutNormal) - _CutOffset;

                // 裁掉另一侧
                if (d * _Side < 0)
                    discard;

                // 切口发光
                float edge = 1.0 - smoothstep(0.0, _EdgeWidth, abs(d));
                edge *= _EdgeIntensity * _CutProgress;

                col.rgb = lerp(col.rgb, _EdgeColor.rgb, saturate(edge));
                col.a = max(col.a, edge * _EdgeColor.a);

                return col;
            }
            ENDCG
        }
    }
}