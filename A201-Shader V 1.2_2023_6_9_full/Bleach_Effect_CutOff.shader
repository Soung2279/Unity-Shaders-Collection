// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "A201-Shader/基本效果/简易溶解_CutOff" {
	Properties {
		_Color ("主颜色", Color) = (1,1,1,1)
		_MainTex ("贴图", 2D) = "white" {}
		_Cutoff ("Alpha 剔除度", Range(0,1)) = 0.5
	}

	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off	
		cull off ZWrite on

		Pass {  
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
			
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _Cutoff;
			
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.texcoord) * _Color * i.color;
					clip(col.a - _Cutoff);
					return col;
				}
			ENDCG
		}
	}
}