// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "A201-Shader/基本效果/AddUI模式_addUI" {
Properties {
	_TintColor ("主颜色", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("主贴图", 2D) = "white" {}
	_ColorStrength ("颜色强度", Float) = 1.0
	_InvFade ("顶点平滑度", Range(0.01,3.0)) = 1.0

	//-------------------add----------------------
	_MinX ("X向最小值", Float) = -10
	_MaxX ("X向最大值", Float) = 10
	_MinY ("Y向最小值", Float) = -10
	_MaxY ("Y向最大值", Float) = 10
	//-------------------add----------------------
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	AlphaTest Greater .01
	ColorMask RGB
	Cull Off 
	Lighting Off 
	ZWrite Off 
	Fog { Mode Off}
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			fixed _ColorStrength;
			
			//-------------------add----------------------
			float _MinX;
            float _MaxX;
            float _MinY;
            float _MaxY;
            //-------------------add----------------------

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD1;
				#endif
				//-------------------add----------------------
				float3 vpos : TEXCOORD2;
				//-------------------add----------------------
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				//-------------------add----------------------
				//o.vpos = v.vertex.xyz;
				//-------------------add----------------------
				o.vertex = UnityObjectToClipPos(v.vertex);
				//-------------------add----------------------
				o.vpos = o.vertex.xyz;
				//-------------------add----------------------
				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			sampler2D _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : COLOR
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos))));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				//-------------------add----------------------		
				fixed4 c =2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord) * _ColorStrength;
				if ((i.vpos.x < _MinX || i.vpos.x > _MaxX || i.vpos.y < _MinY || i.vpos.y > _MaxY))
				{
					c.a = 0;
				}
				// c.rgb *= c.a;
                return c;
                //-------------------add----------------------
			}
			ENDCG 
		}
	}	
}
}
