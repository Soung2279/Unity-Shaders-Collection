Shader "A201-Shader/URP/简易描边_Outline"
{
	Properties
	{
//		[Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("颜色混合因子", float) = 1
//        [Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("背景混合因子", float) = 0
		
		_MainTex ("贴图1", 2D) = "white" {}
		[HDR]_MainCol ("色调",Color) = (1,1,1,1)
		_MainTex2 ("贴图2", 2D) = "white" {}
		[HDR]_MainCol2 ("色调",Color) = (1,1,1,1)
		_OutLine("描边长度",float) = 0.02
		_OutLineCol("描边颜色",Color) = (0,0,0,1)
		
		
	}


	SubShader
	{

       Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"  "Queue" = "Transparent"}

		Blend SrcAlpha OneMinusSrcAlpha
       HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
	    TEXTURE2D(_MainTex);
		SAMPLER(sampler_MainTex);
       	    TEXTURE2D(_MainTex2);
		SAMPLER(sampler_MainTex2);
	    
	    CBUFFER_START(UnityPerMaterial)
	    half4 _MainTex_ST;
		float4 _MainCol;
       	half4 _MainTex2_ST;
		float4 _MainCol2;
		float _OutLine;
		float4 _OutLineCol;
        CBUFFER_END
					struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
        	    UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 posW :TEXCOORD1;
				float4 normal : TEXCOORD7;			
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};


		
			
	

			v2f vert (appdata v)
			{
				v2f o;
			 	UNITY_SETUP_INSTANCE_ID(v);	
				o.pos = TransformObjectToHClip(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
            	o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex2);
            	o.posW = TransformObjectToWorld(v.vertex.xyz);

				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.uv.xy);
				half4 col2 = SAMPLE_TEXTURE2D(_MainTex2, sampler_MainTex2,i.uv.zw);
				col *= _MainCol;
				col2 *= _MainCol2;
				half4 finalCol = col + col2;
				finalCol.a = saturate(finalCol.a);
				return finalCol;
			}

		    v2f vertLine(appdata v)
			{
				v2f o;
				float4 viewPos = mul(UNITY_MATRIX_MV,v.vertex);
				float3 viewNor = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
				float3 offset = normalize(viewNor) * _OutLine;
				viewPos.xyz += offset;
				o.pos = mul(UNITY_MATRIX_P,viewPos);
				return o;
			}
		float4 fragLine(v2f i) :SV_Target{
			return _OutLineCol;
		}
		ENDHLSL

		Pass
		{
			Tags { "LightMode" = "SRPDefaultUnlit"}
			// on
			zwrite on
			cull front
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing


			




			ENDHLSL
		}
		pass{
			Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "LightMode" = "UniversalForward" "Queue" = "Transparent"}
			zwrite off
			cull back
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			ENDHLSL
			}
		
		pass
		{
			Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "LightMode" = "LightWeightForward" "Queue" = "Transparent"}
			zwrite off
			cull front
			HLSLPROGRAM
			#pragma vertex vertLine
			#pragma fragment fragLine
			#pragma multi_compile_instancing
			ENDHLSL
			
			}
		//投影
		
	}
	//CustomEditor "Scarecrow.SimpleShaderGUI"
}
