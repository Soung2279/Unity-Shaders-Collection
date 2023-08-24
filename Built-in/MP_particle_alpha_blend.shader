Shader "A201-Shader/基本效果/基础AlphaBlend模式_AlphaBlend" 
{
	Properties 
	{
		_TintColor ("颜色", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("贴图", 2D) = "white" {}
		//_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off
		//ColorMask RGB

		Pass 
		{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t 
			{
				half4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				half4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				//#ifdef SOFTPARTICLES_ON
				//half4 projPos : TEXCOORD2;
				//#endif
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			half4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				//#ifdef SOFTPARTICLES_ON
				//o.projPos = ComputeScreenPos (o.vertex);
				//COMPUTE_EYEDEPTH(o.projPos.z);
				//#endif
				o.color = v.color * _TintColor;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			//sampler2D_half _CameraDepthTexture;
			//half _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{
				//#ifdef SOFTPARTICLES_ON
				//half sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				//half partZ = i.projPos.z;
				//half fade = saturate (_InvFade * (sceneZ-partZ));
				//i.color.a *= fade;
				//#endif
				
				fixed4 col = 2.0 * i.color * tex2D(_MainTex, i.texcoord);
				//fixed newAlpha = clamp(col.a,0.0,1.0);
				//col.a = newAlpha;
				col = clamp(col,fixed4(0,0,0,0),fixed4(1,1,1,1));
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG 
		}
	}	
}
