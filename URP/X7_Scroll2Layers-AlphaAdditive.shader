// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "A201-Shader/URP/叠加纹理_X7Additive" 
{
	Properties {
		_MainTex ("基础纹理", 2D) = "white" {}
		_DetailTex ("叠加纹理", 2D) = "white" {}
		_ScrollX ("基础纹理X方向流动速率", Float) = 1.0
		_ScrollY ("基础纹理Y方向流动速率", Float) = 0.0
		_Scroll2X ("叠加纹理X方向流动速率", Float) = 1.0
		_Scroll2Y ("叠加纹理Y方向流动速率", Float) = 0.0
		_Color("基础色", Color) = (1,1,1,1)
	
		_MMultiplier ("纹理混合度", Float) = 2.0
			[Toggle(_SOFTPARTICLES_ON)] _SoftParticles("开启软粒子", Float) = 0
	_InvFade ("软粒子强度", Range(0.01,3.0)) = 1.0
	}

	
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "LightMode"="UniversalForward" }
	
		LOD 100

	

		Pass 
		{	
			Blend SrcAlpha One
			ColorMask RGB
			Cull Off Lighting Off ZWrite Off 
			//Fog { Color (0,0,0,0) }

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma shader_feature_local _SOFTPARTICLES_ON
					#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

			
			sampler2D _MainTex;
			sampler2D _DetailTex;
			
            CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _ScrollY;
			float _Scroll2X;
			float _Scroll2Y;
			float _MMultiplier;
		    float4 _Color;
			float _InvFade;
		   CBUFFER_END
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
		   	
				float4 color : TEXCOORD2;
		   		#ifdef _SOFTPARTICLES_ON
				float4 projPos : TEXCOORD3;
				#endif
			};
			struct VertIn {
	        	float4 vertex : POSITION;
	        	float2 texcoord : TEXCOORD0;
	        	float4 color : COLOR;

	        };
		
			v2f vert (VertIn v)
			{
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.texcoord.xy,_MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
				o.uv1 = TRANSFORM_TEX(v.texcoord.xy,_DetailTex) + frac(float2(_Scroll2X, _Scroll2Y) * _Time);
				#ifdef _SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos(o.pos);
				o.projPos.z = - mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0))).z;
				#endif
				o.color = _MMultiplier * _Color * v.color;

				return o;
			}
			float4 frag (v2f i) : COLOR
			{
				float4 o;
				float4 tex = tex2D (_MainTex, i.uv0);
				float4 tex2 = tex2D (_DetailTex, i.uv1);
			#ifdef _SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth(SampleSceneDepth( i.projPos.xy / i.projPos.w),_ZBufferParams);
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));		
				i.color.a *= fade;
			#endif
				
				o = tex * tex2 * i.color;
						
				return o;
			}
		ENDHLSL 
		}	
	}
	FallBack OFF
}
