Shader "A201-Shader/URP/混合因子消融_X7PartDiss"
{
   Properties
	{
	   [Gamma][HDR]_Color("原色(RGBA)", Color) = (1,1,1,1)
	   _MainTex("主贴图(A通道遮罩)", 2D) = "white" {}
		//[Gamma][HDR]_Color1("消融色(RGBA)", Color) = (1,1,1,1)
		//_Intencity("补一个颜色的控制强度",float) = 1
		//_DissolveTex("消融贴图", 2D) = "white" {}
		_DissolveSpeed("颜色消融速度(xyzw)", Vector) = (0.7, 0.1, 0, 0)
	   [Toggle(SHAPEDISSOLVE_SOFT)]SHAPEDISSOLVE_SOFT("软边消融", float) = 0
		_DissolveTex2("形状消融贴图", 2D) = "white" {}
		_DissolveTex("形状消融贴图2", 2D) = "white" {}
		_DissolveThreshold("颜色消融阀值", Range(0,1)) = 0.16
		///_FlowDir("形状消融控制(xy速度+w消融阀值)", Vector) = (0.45, 0.1, 0, 0)
	   [Toggle(PARTICLE_CONTROL_CURVE)]_ParticleControlCurve("粒子系统曲线控制(x通道控制消融阈值)", Float) = 0
	   [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("颜色混合因子", Float) = 5
	   [Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("背景混合因子", Float) = 10
	   [Enum(Off, 0, On, 1)]_ZWrite("深度写入", Float) = 0
	    [Toggle(SOFTPAR_ON)]_Float ("是否开启深度(软粒子)", Float ) = 0
		_SoftParticleFade ("软粒子效果", Range(0.001,0.999)) = 0.5
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("正反面剔除模式", Float) = 0
	}

	   SubShader
		{
		   Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
			Pass
			{
				ZWrite[_ZWrite]
				Blend[_SrcFactor][_DstFactor]
				Cull[_Cull] 
				Lighting Off

				HLSLPROGRAM
				#pragma vertex vert
				#pragma fragment frag
			
				#pragma shader_feature _ SHAPEDISSOLVE_SOFT
				#pragma shader_feature _ SOFTPAR_ON
				#pragma shader_feature _ PARTICLE_CONTROL_CURVE

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			    TEXTURE2D (_MainTex);
				SAMPLER(sampler_MainTex);
				TEXTURE2D (_DissolveTex);
				SAMPLER(sampler_DissolveTex);
				TEXTURE2D (_DissolveTex2);
				SAMPLER(sampler_DissolveTex2);
				CBUFFER_START(UnityPerMaterial)
				half4 _MainTex_ST;
				half4 _Color;
				half4 _Color1;
				half4 _DissolveTex_ST;
				half _DissolveThreshold;
				half4 _DissolveSpeed;

				half4 _DissolveTex2_ST;
				half4 _FlowDir;
				half _Cutoff;
				//half _Intencity;
			    half _SoftParticleFade;
				CBUFFER_END

				#include "SoftParticleFade.hlsl"
				struct appdata
				{
					half4 vertex : POSITION;
					half4 color : COLOR;
					half2 uv : TEXCOORD0;
#if PARTICLE_CONTROL_CURVE
					half4 uv2 : TEXCOORD1;
#endif
				};

				struct v2f
				{
					half4 vertex : POSITION;
					half4 color : COLOR;
					half2 uv : TEXCOORD0;
#if PARTICLE_CONTROL_CURVE
					half4 uv2 : TEXCOORD1;
#endif
					SOFT_PARTICLE_POS(2)
				};

				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = TransformObjectToHClip(v.vertex.xyz);
					o.color = v.color;
					o.uv = v.uv;
#if PARTICLE_CONTROL_CURVE
					o.uv2 = v.uv2;
#endif
					TRANSFORM_SOFT_PARTICLE_POS(o);
					return o;
				}
			
				half4 frag(v2f i) : COLOR
				{
					//_Color1 *= _Intencity;
					half dissolveThreshold2 = _DissolveThreshold;
					half2 offset = 0;
				#if PARTICLE_CONTROL_CURVE
					//mainOffset.xy = i.uv2.zy;
					// mainOffset = i.uv2.z;
					dissolveThreshold2 = i.uv2.x;
					offset = i.uv2.yz;
				#endif
					half shapeVal = SAMPLE_TEXTURE2D(_DissolveTex2, sampler_DissolveTex2,TRANSFORM_TEX(i.uv,_DissolveTex2) + _Time.y * _DissolveSpeed.xy).r;
					half shapeVal2 = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex,TRANSFORM_TEX(i.uv,_DissolveTex) + _Time.y * _DissolveSpeed.zw).r;
					shapeVal *= shapeVal2;
					// clip(shapeVal - dissolveThreshold2); 
					half shapeFac; //相当于clip
					#if SHAPEDISSOLVE_SOFT
						//shapeFac = smoothstep(saturate(dissolveThreshold2), 1, shapeVal);
						shapeFac = saturate((shapeVal  - dissolveThreshold2) / (dissolveThreshold2));//shapeVal - dissolveThreshold2为可视像素溶解值
						//shapeFac = smoothstep(saturate(dissolveThreshold2), 1, shapeVal) / dissolveThreshold2;
					#else
						shapeFac = step(saturate(dissolveThreshold2), shapeVal);
					#endif

					half4 texCol = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, TRANSFORM_TEX(i.uv, _MainTex) + offset);
					//half2 dissolveUV = TRANSFORM_TEX(i.uv, _DissolveTex);
					//half colorToStep = 0.5 * (SAMPLE_TEXTURE2D(_DissolveTex,sampler_DissolveTex, dissolveUV * 1.23 + _Time.y * half2(0.7, 0.1) * _DissolveSpeed) + SAMPLE_TEXTURE2D(_DissolveTex,sampler_DissolveTex, dissolveUV + _Time.y * half2(0.3, -0.5) * _DissolveSpeed));
					half4 color =  _Color * texCol * i.color;
					
					// color.a *=  i.color.a;
					

					color.a *= shapeFac;
					APPLY_SOFT_PARTICLE(i.projPos, color);
					return color;
				}
				ENDHLSL 
			}

		}
}
