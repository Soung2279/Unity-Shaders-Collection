// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SinCourse/URP_Blend简化"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_GradientTex("GradientTex", 2D) = "white" {}
		_GradientTexU("GradientTexU", Float) = 0
		_GradientTexV("GradientTexV", Float) = 0
		[Toggle]_DistortionInfluenceGradient("DistortionInfluenceGradient", Float) = 0
		[Toggle]_DepthFade("DepthFade", Float) = 0
		_DepthFadeIndensity("DepthFadeIndensity", Float) = 1
		_MainPower("MainPower", Float) = 1
		_OpacityPower("OpacityPower", Float) = 1
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_Indensity("Indensity", Float) = 1
		_Opacity("Opacity", Float) = 1
		_DistortionTex("DistortionTex", 2D) = "white" {}
		[Toggle]_Distortion2UV("Distortion2UV", Float) = 0
		_DistortionU("DistortionU", Float) = 0
		_DistortionV("DistortionV", Float) = 0
		_DistortionIndensity("DistortionIndensity", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		_MainU("MainU", Float) = 0
		_MainV("MainV", Float) = 0
		_AlphaTex("AlphaTex", 2D) = "white" {}
		[Toggle]_AlphaTexUV2("AlphaTexUV2", Float) = 0
		_AlphaU("AlphaU", Float) = 0
		_AlphaV("AlphaV", Float) = 0
		[Toggle]_SoftDissolveSwitch("SoftDissolveSwitch", Float) = 0
		[Toggle]_DistortionInfluenceSoft("DistortionInfluenceSoft", Float) = 0
		_SoftDissolveTex("SoftDissolveTex", 2D) = "white" {}
		[Toggle]_VertexColorInfluenceSoftDissolve("VertexColorInfluenceSoftDissolve", Float) = 0
		[Toggle]_CustomDataUV2XInfluenceSoftDissolve("CustomDataUV2XInfluenceSoftDissolve", Float) = 0
		_CustomDataUV2X_Indensity("CustomDataUV2X_Indensity", Float) = 1
		_DissolveTexPlusValue("DissolveTexPlusValue", Float) = 0
		_SoftDissolveTexU("SoftDissolveTexU", Float) = 0
		_SoftDissolveTexV("SoftDissolveTexV", Float) = 0
		_SoftDissolveIndensity("SoftDissolveIndensity", Range( 0 , 1.05)) = 0
		_SoftDissolveSoft("SoftDissolveSoft", Float) = 0
		_LineRange("LineRange", Float) = 0.5
		_LineWidth("LineWidth", Float) = 0.1
		[HDR]_LineColor("LineColor", Color) = (1,1,1,1)
		_LineIndensity("LineIndensity", Float) = 1
		_AlphaTex2("AlphaTex2", 2D) = "white" {}
		_Alpha2U("Alpha2U", Float) = 0
		_Alpha2V("Alpha2V", Float) = 0
		_AlphaTex3("AlphaTex3", 2D) = "white" {}
		_Alpha3U("Alpha3U", Float) = 0
		_Alpha3V("Alpha3V", Float) = 0
		_AlphaTex4("AlphaTex4", 2D) = "white" {}
		_Alpha4U("Alpha4U", Float) = 0
		_Alpha4V("Alpha4V", Float) = 0
		_AlphaTex5("AlphaTex5", 2D) = "white" {}
		_Alpha5U("Alpha5U", Float) = 0
		_Alpha5V("Alpha5V", Float) = 0
		[Toggle]_DistortionInfluenceOffset("DistortionInfluenceOffset", Float) = 0
		_VertexOffsetTex("VertexOffsetTex", 2D) = "white" {}
		_VertexOffsetTexU("VertexOffsetTexU", Float) = 0
		_VertexOffsetTexV("VertexOffsetTexV", Float) = 0
		_VertexOffsetIndensity("VertexOffsetIndensity", Float) = 0

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _GradientTex;
			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _AlphaTex2;
			sampler2D _AlphaTex3;
			sampler2D _AlphaTex4;
			sampler2D _AlphaTex5;
			sampler2D _SoftDissolveTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _VertexOffsetIndensity;
			float _DistortionInfluenceOffset;
			float _VertexOffsetTexU;
			float _VertexOffsetTexV;
			float4 _VertexOffsetTex_ST;
			float _Distortion2UV;
			float4 _DistortionTex_ST;
			float _DistortionU;
			float _DistortionV;
			float _DistortionIndensity;
			float _DistortionInfluenceGradient;
			float _GradientTexU;
			float _GradientTexV;
			float4 _GradientTex_ST;
			float _MainU;
			float _MainV;
			float4 _MainTex_ST;
			float4 _Color;
			float _AlphaU;
			float _AlphaV;
			float _AlphaTexUV2;
			float4 _AlphaTex_ST;
			float _Alpha2U;
			float _Alpha2V;
			float4 _AlphaTex2_ST;
			float _Alpha3U;
			float _Alpha3V;
			float4 _AlphaTex3_ST;
			float _Alpha4U;
			float _Alpha4V;
			float4 _AlphaTex4_ST;
			float _Alpha5U;
			float _Alpha5V;
			float4 _AlphaTex5_ST;
			float _MainPower;
			float _Indensity;
			float _SoftDissolveSoft;
			float _DistortionInfluenceSoft;
			float _SoftDissolveTexU;
			float _SoftDissolveTexV;
			float4 _SoftDissolveTex_ST;
			float _DissolveTexPlusValue;
			float _VertexColorInfluenceSoftDissolve;
			float _CustomDataUV2XInfluenceSoftDissolve;
			float _CustomDataUV2X_Indensity;
			float _SoftDissolveIndensity;
			float _LineRange;
			float _LineWidth;
			float4 _LineColor;
			float _LineIndensity;
			float _DepthFade;
			float _SoftDissolveSwitch;
			float _OpacityPower;
			float _Opacity;
			float _DepthFadeIndensity;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult154 = (float2(_VertexOffsetTexU , _VertexOffsetTexV));
				float2 uv0_VertexOffsetTex = v.ase_texcoord * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_169_0 = ( ( appendResult154 * _TimeParameters.x ) + uv0_VertexOffsetTex );
				float2 uv0_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv1_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 appendResult33 = (float2(_DistortionU , _DistortionV));
				float3 desaturateInitialColor43 = tex2Dlod( _DistortionTex, float4( ( (( _Distortion2UV )?( uv1_DistortionTex ):( uv0_DistortionTex )) + ( appendResult33 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				float desaturateDot43 = dot( desaturateInitialColor43, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar43 = lerp( desaturateInitialColor43, desaturateDot43.xxx, 1.0 );
				float3 DistortionUV49 = desaturateVar43;
				float DistortionIndeisty48 = _DistortionIndensity;
				float3 lerpResult172 = lerp( float3( temp_output_169_0 ,  0.0 ) , DistortionUV49 , DistortionIndeisty48);
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3 = v.ase_texcoord;
				o.ase_texcoord4.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( _VertexOffsetIndensity * ( tex2Dlod( _VertexOffsetTex, float4( (( _DistortionInfluenceOffset )?( lerpResult172 ):( float3( temp_output_169_0 ,  0.0 ) )).xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a ).rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 appendResult147 = (float2(_GradientTexU , _GradientTexV));
				float2 uv0_GradientTex = IN.ase_texcoord3 * _GradientTex_ST.xy + _GradientTex_ST.zw;
				float2 temp_output_162_0 = ( ( appendResult147 * _TimeParameters.x ) + uv0_GradientTex );
				float2 uv0_DistortionTex = IN.ase_texcoord3.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv1_DistortionTex = IN.ase_texcoord4.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 appendResult33 = (float2(_DistortionU , _DistortionV));
				float3 desaturateInitialColor43 = tex2D( _DistortionTex, ( (( _Distortion2UV )?( uv1_DistortionTex ):( uv0_DistortionTex )) + ( appendResult33 * _TimeParameters.x ) ) ).rgb;
				float desaturateDot43 = dot( desaturateInitialColor43, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar43 = lerp( desaturateInitialColor43, desaturateDot43.xxx, 1.0 );
				float3 DistortionUV49 = desaturateVar43;
				float DistortionIndeisty48 = _DistortionIndensity;
				float3 lerpResult165 = lerp( float3( temp_output_162_0 ,  0.0 ) , DistortionUV49 , DistortionIndeisty48);
				float2 appendResult107 = (float2(_MainU , _MainV));
				float2 uv0_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 lerpResult132 = lerp( float3( ( ( appendResult107 * _TimeParameters.x ) + uv0_MainTex ) ,  0.0 ) , desaturateVar43 , _DistortionIndensity);
				float4 tex2DNode144 = tex2D( _MainTex, lerpResult132.xy );
				float2 appendResult82 = (float2(_AlphaU , _AlphaV));
				float2 uv0_AlphaTex = IN.ase_texcoord3.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv1_AlphaTex = IN.ase_texcoord4.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult84 = (float2(_Alpha2U , _Alpha2V));
				float2 uv0_AlphaTex2 = IN.ase_texcoord3.xy * _AlphaTex2_ST.xy + _AlphaTex2_ST.zw;
				float2 appendResult90 = (float2(_Alpha3U , _Alpha3V));
				float2 uv0_AlphaTex3 = IN.ase_texcoord3.xy * _AlphaTex3_ST.xy + _AlphaTex3_ST.zw;
				float2 appendResult88 = (float2(_Alpha4U , _Alpha4V));
				float2 uv0_AlphaTex4 = IN.ase_texcoord3.xy * _AlphaTex4_ST.xy + _AlphaTex4_ST.zw;
				float2 appendResult94 = (float2(_Alpha5U , _Alpha5V));
				float2 uv0_AlphaTex5 = IN.ase_texcoord3.xy * _AlphaTex5_ST.xy + _AlphaTex5_ST.zw;
				float3 desaturateInitialColor139 = ( tex2D( _AlphaTex, ( ( appendResult82 * _TimeParameters.x ) + (( _AlphaTexUV2 )?( uv1_AlphaTex ):( uv0_AlphaTex )) ) ) * tex2D( _AlphaTex2, ( ( appendResult84 * _TimeParameters.x ) + uv0_AlphaTex2 ) ) * tex2D( _AlphaTex3, ( ( appendResult90 * _TimeParameters.x ) + uv0_AlphaTex3 ) ) * tex2D( _AlphaTex4, ( ( appendResult88 * _TimeParameters.x ) + uv0_AlphaTex4 ) ) * tex2D( _AlphaTex5, ( ( appendResult94 * _TimeParameters.x ) + uv0_AlphaTex5 ) ) ).rgb;
				float desaturateDot139 = dot( desaturateInitialColor139, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar139 = lerp( desaturateInitialColor139, desaturateDot139.xxx, 1.0 );
				float temp_output_151_0 = (desaturateVar139).x;
				float3 temp_cast_7 = (_MainPower).xxx;
				float2 appendResult44 = (float2(_SoftDissolveTexU , _SoftDissolveTexV));
				float2 uv0_SoftDissolveTex = IN.ase_texcoord3.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_53_0 = ( ( appendResult44 * _TimeParameters.x ) + uv0_SoftDissolveTex );
				float3 lerpResult54 = lerp( float3( temp_output_53_0 ,  0.0 ) , DistortionUV49 , DistortionIndeisty48);
				float3 desaturateInitialColor63 = ( tex2D( _SoftDissolveTex, (( _DistortionInfluenceSoft )?( lerpResult54 ):( float3( temp_output_53_0 ,  0.0 ) )).xy ) + _DissolveTexPlusValue ).rgb;
				float desaturateDot63 = dot( desaturateInitialColor63, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar63 = lerp( desaturateInitialColor63, desaturateDot63.xxx, 0.0 );
				float4 uv059 = IN.ase_texcoord3;
				uv059.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_65_0 = ( uv059.z * _CustomDataUV2X_Indensity );
				float clampResult115 = clamp( ( (( ( desaturateVar63 * (( _VertexColorInfluenceSoftDissolve )?( IN.ase_color.a ):( 1.0 )) ) * (( _CustomDataUV2XInfluenceSoftDissolve )?( temp_output_65_0 ):( 1.0 )) )).x + 1.0 + ( _SoftDissolveIndensity * -2.0 ) ) , 0.0 , 1.0 );
				float smoothstepResult125 = smoothstep( ( 1.0 - _SoftDissolveSoft ) , _SoftDissolveSoft , clampResult115);
				float DissolveLine168 = ( step( smoothstepResult125 , _LineRange ) - step( ( _LineWidth + smoothstepResult125 ) , _LineRange ) );
				
				float temp_output_157_0 = ( ( tex2DNode144.a * _Color.a * IN.ase_color.a ) * temp_output_151_0 );
				float temp_output_164_0 = pow( temp_output_157_0 , _OpacityPower );
				float temp_output_176_0 = ( temp_output_164_0 * smoothstepResult125 );
				float OpacityGroup166 = temp_output_157_0;
				float temp_output_200_0 = ( ( (( _SoftDissolveSwitch )?( temp_output_176_0 ):( temp_output_164_0 )) + ( DissolveLine168 * OpacityGroup166 ) ) * _Opacity );
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth192 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth192 = abs( ( screenDepth192 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult193 = clamp( distanceDepth192 , 0.0 , 1.0 );
				float temp_output_203_0 = ( temp_output_200_0 * clampResult193 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( float4( ( ( (tex2D( _GradientTex, (( _DistortionInfluenceGradient )?( lerpResult165 ):( float3( temp_output_162_0 ,  0.0 ) )).xy )).rgb * pow( ( (tex2DNode144).rgb * (_Color).rgb * (IN.ase_color).rgb * temp_output_151_0 ) , temp_cast_7 ) ) * _Indensity ) , 0.0 ) + ( DissolveLine168 * _LineColor * _LineIndensity ) ).rgb;
				float Alpha = (( _DepthFade )?( temp_output_203_0 ):( temp_output_200_0 ));
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _AlphaTex2;
			sampler2D _AlphaTex3;
			sampler2D _AlphaTex4;
			sampler2D _AlphaTex5;
			sampler2D _SoftDissolveTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _VertexOffsetIndensity;
			float _DistortionInfluenceOffset;
			float _VertexOffsetTexU;
			float _VertexOffsetTexV;
			float4 _VertexOffsetTex_ST;
			float _Distortion2UV;
			float4 _DistortionTex_ST;
			float _DistortionU;
			float _DistortionV;
			float _DistortionIndensity;
			float _DistortionInfluenceGradient;
			float _GradientTexU;
			float _GradientTexV;
			float4 _GradientTex_ST;
			float _MainU;
			float _MainV;
			float4 _MainTex_ST;
			float4 _Color;
			float _AlphaU;
			float _AlphaV;
			float _AlphaTexUV2;
			float4 _AlphaTex_ST;
			float _Alpha2U;
			float _Alpha2V;
			float4 _AlphaTex2_ST;
			float _Alpha3U;
			float _Alpha3V;
			float4 _AlphaTex3_ST;
			float _Alpha4U;
			float _Alpha4V;
			float4 _AlphaTex4_ST;
			float _Alpha5U;
			float _Alpha5V;
			float4 _AlphaTex5_ST;
			float _MainPower;
			float _Indensity;
			float _SoftDissolveSoft;
			float _DistortionInfluenceSoft;
			float _SoftDissolveTexU;
			float _SoftDissolveTexV;
			float4 _SoftDissolveTex_ST;
			float _DissolveTexPlusValue;
			float _VertexColorInfluenceSoftDissolve;
			float _CustomDataUV2XInfluenceSoftDissolve;
			float _CustomDataUV2X_Indensity;
			float _SoftDissolveIndensity;
			float _LineRange;
			float _LineWidth;
			float4 _LineColor;
			float _LineIndensity;
			float _DepthFade;
			float _SoftDissolveSwitch;
			float _OpacityPower;
			float _Opacity;
			float _DepthFadeIndensity;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult154 = (float2(_VertexOffsetTexU , _VertexOffsetTexV));
				float2 uv0_VertexOffsetTex = v.ase_texcoord * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_169_0 = ( ( appendResult154 * _TimeParameters.x ) + uv0_VertexOffsetTex );
				float2 uv0_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv1_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 appendResult33 = (float2(_DistortionU , _DistortionV));
				float3 desaturateInitialColor43 = tex2Dlod( _DistortionTex, float4( ( (( _Distortion2UV )?( uv1_DistortionTex ):( uv0_DistortionTex )) + ( appendResult33 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				float desaturateDot43 = dot( desaturateInitialColor43, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar43 = lerp( desaturateInitialColor43, desaturateDot43.xxx, 1.0 );
				float3 DistortionUV49 = desaturateVar43;
				float DistortionIndeisty48 = _DistortionIndensity;
				float3 lerpResult172 = lerp( float3( temp_output_169_0 ,  0.0 ) , DistortionUV49 , DistortionIndeisty48);
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord;
				o.ase_texcoord3.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( _VertexOffsetIndensity * ( tex2Dlod( _VertexOffsetTex, float4( (( _DistortionInfluenceOffset )?( lerpResult172 ):( float3( temp_output_169_0 ,  0.0 ) )).xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a ).rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult107 = (float2(_MainU , _MainV));
				float2 uv0_MainTex = IN.ase_texcoord2 * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv0_DistortionTex = IN.ase_texcoord2.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv1_DistortionTex = IN.ase_texcoord3.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 appendResult33 = (float2(_DistortionU , _DistortionV));
				float3 desaturateInitialColor43 = tex2D( _DistortionTex, ( (( _Distortion2UV )?( uv1_DistortionTex ):( uv0_DistortionTex )) + ( appendResult33 * _TimeParameters.x ) ) ).rgb;
				float desaturateDot43 = dot( desaturateInitialColor43, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar43 = lerp( desaturateInitialColor43, desaturateDot43.xxx, 1.0 );
				float3 lerpResult132 = lerp( float3( ( ( appendResult107 * _TimeParameters.x ) + uv0_MainTex ) ,  0.0 ) , desaturateVar43 , _DistortionIndensity);
				float4 tex2DNode144 = tex2D( _MainTex, lerpResult132.xy );
				float2 appendResult82 = (float2(_AlphaU , _AlphaV));
				float2 uv0_AlphaTex = IN.ase_texcoord2.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv1_AlphaTex = IN.ase_texcoord3.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult84 = (float2(_Alpha2U , _Alpha2V));
				float2 uv0_AlphaTex2 = IN.ase_texcoord2.xy * _AlphaTex2_ST.xy + _AlphaTex2_ST.zw;
				float2 appendResult90 = (float2(_Alpha3U , _Alpha3V));
				float2 uv0_AlphaTex3 = IN.ase_texcoord2.xy * _AlphaTex3_ST.xy + _AlphaTex3_ST.zw;
				float2 appendResult88 = (float2(_Alpha4U , _Alpha4V));
				float2 uv0_AlphaTex4 = IN.ase_texcoord2.xy * _AlphaTex4_ST.xy + _AlphaTex4_ST.zw;
				float2 appendResult94 = (float2(_Alpha5U , _Alpha5V));
				float2 uv0_AlphaTex5 = IN.ase_texcoord2.xy * _AlphaTex5_ST.xy + _AlphaTex5_ST.zw;
				float3 desaturateInitialColor139 = ( tex2D( _AlphaTex, ( ( appendResult82 * _TimeParameters.x ) + (( _AlphaTexUV2 )?( uv1_AlphaTex ):( uv0_AlphaTex )) ) ) * tex2D( _AlphaTex2, ( ( appendResult84 * _TimeParameters.x ) + uv0_AlphaTex2 ) ) * tex2D( _AlphaTex3, ( ( appendResult90 * _TimeParameters.x ) + uv0_AlphaTex3 ) ) * tex2D( _AlphaTex4, ( ( appendResult88 * _TimeParameters.x ) + uv0_AlphaTex4 ) ) * tex2D( _AlphaTex5, ( ( appendResult94 * _TimeParameters.x ) + uv0_AlphaTex5 ) ) ).rgb;
				float desaturateDot139 = dot( desaturateInitialColor139, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar139 = lerp( desaturateInitialColor139, desaturateDot139.xxx, 1.0 );
				float temp_output_151_0 = (desaturateVar139).x;
				float temp_output_157_0 = ( ( tex2DNode144.a * _Color.a * IN.ase_color.a ) * temp_output_151_0 );
				float temp_output_164_0 = pow( temp_output_157_0 , _OpacityPower );
				float2 appendResult44 = (float2(_SoftDissolveTexU , _SoftDissolveTexV));
				float2 uv0_SoftDissolveTex = IN.ase_texcoord2.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_53_0 = ( ( appendResult44 * _TimeParameters.x ) + uv0_SoftDissolveTex );
				float3 DistortionUV49 = desaturateVar43;
				float DistortionIndeisty48 = _DistortionIndensity;
				float3 lerpResult54 = lerp( float3( temp_output_53_0 ,  0.0 ) , DistortionUV49 , DistortionIndeisty48);
				float3 desaturateInitialColor63 = ( tex2D( _SoftDissolveTex, (( _DistortionInfluenceSoft )?( lerpResult54 ):( float3( temp_output_53_0 ,  0.0 ) )).xy ) + _DissolveTexPlusValue ).rgb;
				float desaturateDot63 = dot( desaturateInitialColor63, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar63 = lerp( desaturateInitialColor63, desaturateDot63.xxx, 0.0 );
				float4 uv059 = IN.ase_texcoord2;
				uv059.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_65_0 = ( uv059.z * _CustomDataUV2X_Indensity );
				float clampResult115 = clamp( ( (( ( desaturateVar63 * (( _VertexColorInfluenceSoftDissolve )?( IN.ase_color.a ):( 1.0 )) ) * (( _CustomDataUV2XInfluenceSoftDissolve )?( temp_output_65_0 ):( 1.0 )) )).x + 1.0 + ( _SoftDissolveIndensity * -2.0 ) ) , 0.0 , 1.0 );
				float smoothstepResult125 = smoothstep( ( 1.0 - _SoftDissolveSoft ) , _SoftDissolveSoft , clampResult115);
				float temp_output_176_0 = ( temp_output_164_0 * smoothstepResult125 );
				float DissolveLine168 = ( step( smoothstepResult125 , _LineRange ) - step( ( _LineWidth + smoothstepResult125 ) , _LineRange ) );
				float OpacityGroup166 = temp_output_157_0;
				float temp_output_200_0 = ( ( (( _SoftDissolveSwitch )?( temp_output_176_0 ):( temp_output_164_0 )) + ( DissolveLine168 * OpacityGroup166 ) ) * _Opacity );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth192 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth192 = abs( ( screenDepth192 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult193 = clamp( distanceDepth192 , 0.0 , 1.0 );
				float temp_output_203_0 = ( temp_output_200_0 * clampResult193 );
				
				float Alpha = (( _DepthFade )?( temp_output_203_0 ):( temp_output_200_0 ));
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=17800
1920;12;1920;1017;2454.179;688.2977;1.810916;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-6792.185,-1220.082;Inherit;False;1207;533.7722;UV扭曲贴图;11;43;41;39;38;37;36;35;34;33;32;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-6721.185,-843.0826;Float;False;Property;_DistortionV;DistortionV;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-6721.185,-923.0825;Float;False;Property;_DistortionU;DistortionU;17;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-6570.718,-796.9771;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-6545.185,-907.0825;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-6742.185,-1170.083;Inherit;False;1;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-6742.185,-1058.083;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;215;-6418.788,-1228.194;Inherit;False;Property;_Distortion2UV;Distortion2UV;16;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-6385.185,-907.0825;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;2;-8490.995,1941.063;Inherit;False;751.5742;379.1072;软溶解流动;7;53;50;47;45;44;42;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-6233.185,-964.0826;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;3;-5671.224,-295.879;Inherit;False;312.6667;165.6667;UV扭曲强度;1;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;41;-6081.185,-1003.083;Inherit;True;Property;_DistortionTex;DistortionTex;14;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-8440.996,1994.923;Float;False;Property;_SoftDissolveTexU;SoftDissolveTexU;39;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-8437.996,2071.923;Float;False;Property;_SoftDissolveTexV;SoftDissolveTexV;40;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;-8215.002,2085.67;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;43;-5793.184,-996.0826;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-8212.539,1993.063;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-5621.224,-245.879;Float;False;Property;_DistortionIndensity;DistortionIndensity;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-8049.541,1991.063;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-5333.114,-108.9991;Float;False;DistortionIndeisty;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-5534.666,-998.2323;Float;False;DistortionUV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;4;-7709.068,1955.095;Inherit;False;730.8218;342.6487;扭曲贴图影响软溶解;4;55;54;52;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-8217.369,2157.17;Inherit;False;0;57;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-7895.422,2004.657;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-7695.749,2111.388;Inherit;False;49;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-7696.686,2181.032;Inherit;False;48;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-7469.15,2063.264;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;221;-7247.685,1843.514;Inherit;False;Property;_DistortionInfluenceSoft;DistortionInfluenceSoft;31;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;6;-6937.082,1920.972;Inherit;False;2176.837;720.1458;软溶解;15;125;116;115;106;101;96;91;83;80;79;77;67;63;61;57;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;5;-7352.015,2321.448;Inherit;False;377;165;粒子CustomDataUV1X溶解贴图强度补充;1;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-7546.916,2872.806;Inherit;False;956.9551;406.9375;粒子CustomDataUV1X影响软溶解;5;68;65;64;60;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-7302.015,2371.448;Float;False;Property;_DissolveTexPlusValue;DissolveTexPlusValue;38;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;-6887.082,1970.972;Inherit;True;Property;_SoftDissolveTex;SoftDissolveTex;32;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;7;-7535.325,2512.204;Inherit;False;571.4299;331.4985;顶点颜色/粒子颜色影响软溶解;3;66;62;58;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-7489.707,3089.502;Float;False;Property;_CustomDataUV2X_Indensity;CustomDataUV2X_Indensity;37;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;62;-7485.325,2641.702;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;59;-7496.916,2928.52;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-6579.472,2073.447;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-7452.513,2562.204;Float;False;Constant;_Float1;Float 1;50;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;9;-6317.211,103.3005;Inherit;False;1701.067;1756.287;一堆Alpha;40;151;139;135;131;130;129;128;124;120;119;117;114;113;112;104;103;102;100;99;97;94;93;90;89;88;87;86;84;82;81;78;76;75;74;73;72;71;70;69;220;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;222;-6822.161,2580.844;Inherit;False;Property;_VertexColorInfluenceSoftDissolve;VertexColorInfluenceSoftDissolve;34;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-7194.707,2995.502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;63;-6446.449,2073.741;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-7194.11,2922.806;Float;False;Constant;_Float3;Float 3;50;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-6265.386,2079.646;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-6249.613,165.9184;Float;False;Property;_AlphaU;AlphaU;26;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;10;-6056.19,-681.556;Inherit;False;697.1188;379.1068;主贴图流动;7;127;123;122;107;105;95;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;223;-6908.576,2793.857;Inherit;False;Property;_CustomDataUV2XInfluenceSoftDissolve;CustomDataUV2XInfluenceSoftDissolve;36;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-6254.252,819.05;Float;False;Property;_Alpha3U;Alpha3U;51;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-6267.211,1500.881;Float;False;Property;_Alpha5U;Alpha5U;57;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-6256.984,566.333;Float;False;Property;_Alpha2V;Alpha2V;49;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-6263.681,1243.586;Float;False;Property;_Alpha4V;Alpha4V;55;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-6259.984,489.334;Float;False;Property;_Alpha2U;Alpha2U;48;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-6246.613,242.9186;Float;False;Property;_AlphaV;AlphaV;27;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-6264.211,1577.88;Float;False;Property;_Alpha5V;Alpha5V;58;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-6251.252,896.0501;Float;False;Property;_Alpha3V;Alpha3V;52;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-6266.681,1166.587;Float;False;Property;_Alpha4U;Alpha4U;54;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-6093.211,1520.881;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;89;-6120.447,614.74;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-6080.252,839.05;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;87;-6127.143,1291.993;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-6119.879,2082.323;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-6168.997,2343.29;Float;False;Property;_SoftDissolveIndensity;SoftDissolveIndensity;41;0;Create;True;0;0;False;0;0;0;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-6041.997,2424.29;Float;False;Constant;_Float2;Float 2;33;0;Create;True;0;0;False;0;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-6006.19,-619.156;Float;False;Property;_MainU;MainU;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;88;-6092.681,1186.587;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;86;-6110.076,291.3258;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-6003.191,-542.1563;Float;False;Property;_MainV;MainV;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;97;-6127.675,1626.287;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;93;-6114.716,944.4571;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;98;-6544.176,323.6256;Inherit;False;0;130;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;84;-6085.984,509.334;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-6075.613,185.9184;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;92;-6544.042,436.688;Inherit;False;1;130;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-6539.746,641.64;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;105;-5834.653,-536.9491;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-5917.252,837.05;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;220;-5998.826,361.9835;Inherit;False;Property;_AlphaTexUV2;AlphaTexUV2;25;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-5922.984,507.334;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-5873.997,2348.29;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-5912.613,183.9184;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;109;-6580.694,1326.407;Inherit;False;0;124;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;110;-6554.311,1659.42;Inherit;False;0;129;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;-5880.997,2278.29;Float;False;Constant;_Float0;Float 0;33;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-5832.19,-629.556;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-5929.68,1184.587;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;83;-5974.772,2068.369;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;108;-6565.25,1030.574;Inherit;False;0;131;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-5930.211,1518.881;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-5669.19,-631.556;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-5764.724,503.757;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-5771.418,1181.01;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-5723.067,2213.708;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-5758.991,833.473;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-5771.95,1515.304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-5358.726,2316.116;Float;False;Property;_SoftDissolveSoft;SoftDissolveSoft;42;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;122;-5835.953,-465.4492;Inherit;False;0;144;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-5754.353,180.3414;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;12;-4187.483,2046.175;Inherit;False;1191.28;539.6665;软溶解描边;7;168;156;153;150;146;142;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;115;-5601.71,2213.503;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-5515.072,-617.9618;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;130;-5624.039,153.3008;Inherit;True;Property;_AlphaTex;AlphaTex;23;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;116;-5166.779,2256.056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;124;-5642.407,1147.947;Inherit;True;Property;_AlphaTex4;AlphaTex4;53;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;128;-5628.887,483.306;Inherit;True;Property;_AlphaTex2;AlphaTex2;47;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;131;-5629.057,805.615;Inherit;True;Property;_AlphaTex3;AlphaTex3;50;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;129;-5633.905,1491.475;Inherit;True;Property;_AlphaTex5;AlphaTex5;56;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;125;-5016.243,2230.318;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;15;-5074.118,-192.2146;Inherit;False;467.8296;259.9428;顶点颜色;2;178;138;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-4137.483,2096.175;Float;False;Property;_LineWidth;LineWidth;44;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-5198.374,430.0389;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;17;-5082.672,-792.3533;Inherit;False;589.6357;280.6944;主贴图;2;177;144;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;132;-5258.099,-726.0594;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;16;-5079.747,-484.8526;Inherit;False;500.3463;260.3333;主颜色;2;175;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;140;-5029.747,-434.8525;Float;False;Property;_Color;Color;11;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;139;-5038.276,429.2809;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;138;-5024.118,-137.6051;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;144;-5032.672,-741.6589;Inherit;True;Property;_MainTex;MainTex;20;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;146;-3951.892,2317.811;Float;False;Property;_LineRange;LineRange;43;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-3969.484,2097.175;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-2494.617,517.967;Inherit;False;1859.316;500.0784;顶点偏移;13;204;201;197;194;191;189;169;161;160;155;154;145;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2444.617,686.01;Float;False;Property;_VertexOffsetTexU;VertexOffsetTexU;62;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2441.618,763.009;Float;False;Property;_VertexOffsetTexV;VertexOffsetTexV;63;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-4321.947,-169.2384;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;150;-3723.36,2344.421;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;153;-3735.484,2096.175;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;18;-3960.689,-198.3936;Inherit;False;421.5405;220.2608;总Opacity Power;2;164;158;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;151;-4858.81,423.7931;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-3910.689,-93.79964;Float;False;Property;_OpacityPower;OpacityPower;10;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-4142.369,-147.1366;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;156;-3481.483,2159.175;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;155;-2231.963,774.09;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-2229.5,681.484;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3293.868,89.50601;Inherit;False;455.077;243.3826;描边alpha;3;179;174;171;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;209;-3461.729,-214.0997;Inherit;False;537.0822;256.2446;软溶解开关;2;211;176;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;164;-3721.814,-148.3935;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-3964.129,37.40234;Float;False;OpacityGroup;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-2233.263,845.59;Inherit;False;0;189;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-2066.5,679.484;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-3279.87,2161.485;Float;False;DissolveLine;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2167.552,1042.946;Inherit;False;730.8218;342.6487;扭曲贴图影响顶点偏移;5;182;172;170;167;218;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-3237.758,139.7075;Inherit;False;168;DissolveLine;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-3412.305,-86.15743;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2683.671,58.56915;Inherit;False;751.9431;208;深度消隐;3;193;192;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-3243.868,217.8886;Inherit;False;166;OpacityGroup;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2155.169,1268.883;Inherit;False;48;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-2154.231,1199.239;Inherit;False;49;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;-1929.733,680.064;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-3007.792,139.506;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-2302.972,-179.469;Inherit;False;366.5849;221.009;总Opacity;2;200;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;219;-3218.428,-301.1214;Inherit;False;Property;_SoftDissolveSwitch;SoftDissolveSwitch;29;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-2633.671,130.7636;Float;False;Property;_DepthFadeIndensity;DepthFadeIndensity;8;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;172;-1927.633,1151.115;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;192;-2370.886,117.3595;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;218;-1651.032,1231.06;Inherit;False;Property;_DistortionInfluenceOffset;DistortionInfluenceOffset;60;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;-2759.328,-140.629;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-2252.973,-74.12618;Float;False;Property;_Opacity;Opacity;13;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;191;-1483.103,839.045;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;-2111.722,-129.4687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;193;-2108.394,108.5692;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;189;-1588.167,646.5861;Inherit;True;Property;_VertexOffsetTex;VertexOffsetTex;61;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;19;-4530.099,-1184.428;Inherit;False;843.4887;320.6486;扭曲贴图影响软溶解;4;173;165;163;159;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1276.215,651.0861;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;197;-1264.64,797.983;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;201;-1379.621,567.967;Float;False;Property;_VertexOffsetIndensity;VertexOffsetIndensity;64;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-1854.592,-74.60885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;11;-5273.263,-1180.949;Inherit;False;719.1189;379.1068;渐变叠加贴图流动;7;162;152;149;147;141;137;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-4182.207,-568.7933;Inherit;False;400.7943;216.4848;总MainPower;2;186;180;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-3673.361,-1183.402;Inherit;False;584.2609;280;渐变叠加贴图;2;190;184;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-3025.708,-611.3427;Inherit;False;235.3334;165.6667;总Indensity;1;196;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;212;-1659.913,-210.9698;Inherit;False;315.3334;189.3333;深度消隐开关;1;213;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2572.489,-784.9575;Inherit;False;593.2806;524.3915;描边叠加;5;208;205;202;198;195;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;216;-4065.789,-1280.195;Inherit;False;Property;_DistortionInfluenceGradient;DistortionInfluenceGradient;5;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-4864.263,-1130.949;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;175;-4822.067,-433.2066;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-4344.487,-535.8021;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;-5027.263,-1128.949;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-5223.264,-1126.549;Float;False;Property;_GradientTexU;GradientTexU;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-2522.489,-620.9651;Inherit;False;168;DissolveLine;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;190;-3331.766,-1126.886;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;178;-4848.956,-142.2146;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;184;-3622.361,-1133.402;Inherit;True;Property;_GradientTex;GradientTex;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;196;-2975.708,-561.3427;Float;False;Property;_Indensity;Indensity;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;177;-4735.704,-742.3533;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;217;-1588.142,-18.48976;Inherit;False;Property;_DepthFade;DepthFade;7;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;208;-2135.206,-734.9575;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;68;-7051.96,2923.511;Float;False;Property;_CustomDataUV2XInfluenceSoftDissolve;CustomDataUV2XInfluenceSoftDissolve;35;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;182;-1751.347,1077.901;Float;False;Property;_DistortionInfluenceOffset;DistortionInfluenceOffset;59;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;162;-4710.144,-1117.355;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;141;-5029.726,-1036.342;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;38;-6486.185,-1122.083;Float;False;Property;_Distortion2UV;Distortion2UV;15;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-5033.057,-966.8727;Inherit;False;0;184;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;211;-3223.979,-164.0996;Float;False;Property;_SoftDissolveSwitch;SoftDissolveSwitch;28;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-4479.16,-1049.09;Inherit;False;49;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;102;-6252.442,367.4877;Float;False;Property;_AlphaTexUV2;AlphaTexUV2;24;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;186;-3964.08,-518.7933;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;-2929.778,-725.5483;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-2301.623,-573.5287;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-4144.392,-448.1751;Float;False;Property;_MainPower;MainPower;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;55;-7311.863,2004.051;Float;False;Property;_DistortionInfluenceSoft;DistortionInfluenceSoft;30;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;173;-4070.676,-1114.927;Float;False;Property;_DistortionInfluenceGradient;DistortionInfluenceGradient;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-2719.703,-730.9456;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;165;-4252.563,-1097.214;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;198;-2540.218,-546.0905;Float;False;Property;_LineColor;LineColor;45;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1076.038,620.38;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-4480.098,-979.4457;Inherit;False;48;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-5220.265,-1049.549;Float;False;Property;_GradientTexV;GradientTexV;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-2499.8,-376.2324;Float;False;Property;_LineIndensity;LineIndensity;46;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;66;-7288.896,2564.042;Float;False;Property;_VertexColorInfluenceSoftDissolve;VertexColorInfluenceSoftDissolve;33;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;213;-1611.213,-160.9695;Float;False;Property;_DepthFade;DepthFade;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;232;-771.0934,-55.19758;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;233;-771.0934,-55.19758;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;231;-771.0934,-55.19758;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;SinCourse/URP_Blend简化;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;230;-771.0934,-55.19758;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;234;-771.0934,-55.19758;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;33;0;32;0
WireConnection;33;1;31;0
WireConnection;215;0;35;0
WireConnection;215;1;36;0
WireConnection;37;0;33;0
WireConnection;37;1;34;0
WireConnection;39;0;215;0
WireConnection;39;1;37;0
WireConnection;41;1;39;0
WireConnection;43;0;41;0
WireConnection;44;0;42;0
WireConnection;44;1;40;0
WireConnection;47;0;44;0
WireConnection;47;1;45;0
WireConnection;48;0;46;0
WireConnection;49;0;43;0
WireConnection;53;0;47;0
WireConnection;53;1;50;0
WireConnection;54;0;53;0
WireConnection;54;1;51;0
WireConnection;54;2;52;0
WireConnection;221;0;53;0
WireConnection;221;1;54;0
WireConnection;57;1;221;0
WireConnection;61;0;57;0
WireConnection;61;1;56;0
WireConnection;222;0;58;0
WireConnection;222;1;62;4
WireConnection;65;0;59;3
WireConnection;65;1;60;0
WireConnection;63;0;61;0
WireConnection;67;0;63;0
WireConnection;67;1;222;0
WireConnection;223;0;64;0
WireConnection;223;1;65;0
WireConnection;94;0;75;0
WireConnection;94;1;81;0
WireConnection;90;0;78;0
WireConnection;90;1;71;0
WireConnection;80;0;67;0
WireConnection;80;1;223;0
WireConnection;88;0;70;0
WireConnection;88;1;74;0
WireConnection;84;0;76;0
WireConnection;84;1;69;0
WireConnection;82;0;72;0
WireConnection;82;1;73;0
WireConnection;104;0;90;0
WireConnection;104;1;93;0
WireConnection;220;0;98;0
WireConnection;220;1;92;0
WireConnection;103;0;84;0
WireConnection;103;1;89;0
WireConnection;96;0;79;0
WireConnection;96;1;77;0
WireConnection;99;0;82;0
WireConnection;99;1;86;0
WireConnection;107;0;95;0
WireConnection;107;1;85;0
WireConnection;112;0;88;0
WireConnection;112;1;87;0
WireConnection;83;0;80;0
WireConnection;100;0;94;0
WireConnection;100;1;97;0
WireConnection;123;0;107;0
WireConnection;123;1;105;0
WireConnection;117;0;103;0
WireConnection;117;1;111;0
WireConnection;120;0;112;0
WireConnection;120;1;109;0
WireConnection;101;0;83;0
WireConnection;101;1;91;0
WireConnection;101;2;96;0
WireConnection;113;0;104;0
WireConnection;113;1;108;0
WireConnection;114;0;100;0
WireConnection;114;1;110;0
WireConnection;119;0;99;0
WireConnection;119;1;220;0
WireConnection;115;0;101;0
WireConnection;127;0;123;0
WireConnection;127;1;122;0
WireConnection;130;1;119;0
WireConnection;116;0;106;0
WireConnection;124;1;120;0
WireConnection;128;1;117;0
WireConnection;131;1;113;0
WireConnection;129;1;114;0
WireConnection;125;0;115;0
WireConnection;125;1;116;0
WireConnection;125;2;106;0
WireConnection;135;0;130;0
WireConnection;135;1;128;0
WireConnection;135;2;131;0
WireConnection;135;3;124;0
WireConnection;135;4;129;0
WireConnection;132;0;127;0
WireConnection;132;1;43;0
WireConnection;132;2;46;0
WireConnection;139;0;135;0
WireConnection;144;1;132;0
WireConnection;142;0;134;0
WireConnection;142;1;125;0
WireConnection;148;0;144;4
WireConnection;148;1;140;4
WireConnection;148;2;138;4
WireConnection;150;0;125;0
WireConnection;150;1;146;0
WireConnection;153;0;142;0
WireConnection;153;1;146;0
WireConnection;151;0;139;0
WireConnection;157;0;148;0
WireConnection;157;1;151;0
WireConnection;156;0;150;0
WireConnection;156;1;153;0
WireConnection;154;0;145;0
WireConnection;154;1;143;0
WireConnection;164;0;157;0
WireConnection;164;1;158;0
WireConnection;166;0;157;0
WireConnection;161;0;154;0
WireConnection;161;1;155;0
WireConnection;168;0;156;0
WireConnection;176;0;164;0
WireConnection;176;1;125;0
WireConnection;169;0;161;0
WireConnection;169;1;160;0
WireConnection;179;0;171;0
WireConnection;179;1;174;0
WireConnection;219;0;164;0
WireConnection;219;1;176;0
WireConnection;172;0;169;0
WireConnection;172;1;167;0
WireConnection;172;2;170;0
WireConnection;192;0;181;0
WireConnection;218;0;169;0
WireConnection;218;1;172;0
WireConnection;188;0;219;0
WireConnection;188;1;179;0
WireConnection;200;0;188;0
WireConnection;200;1;187;0
WireConnection;193;0;192;0
WireConnection;189;1;218;0
WireConnection;194;0;189;0
WireConnection;194;1;191;0
WireConnection;203;0;200;0
WireConnection;203;1;193;0
WireConnection;216;0;162;0
WireConnection;216;1;165;0
WireConnection;149;0;147;0
WireConnection;149;1;141;0
WireConnection;175;0;140;0
WireConnection;183;0;177;0
WireConnection;183;1;175;0
WireConnection;183;2;178;0
WireConnection;183;3;151;0
WireConnection;147;0;136;0
WireConnection;147;1;137;0
WireConnection;190;0;184;0
WireConnection;178;0;138;0
WireConnection;184;1;216;0
WireConnection;177;0;144;0
WireConnection;217;0;200;0
WireConnection;217;1;203;0
WireConnection;208;0;206;0
WireConnection;208;1;205;0
WireConnection;68;1;64;0
WireConnection;68;0;65;0
WireConnection;182;1;169;0
WireConnection;182;0;172;0
WireConnection;162;0;149;0
WireConnection;162;1;152;0
WireConnection;38;1;35;0
WireConnection;38;0;36;0
WireConnection;211;1;164;0
WireConnection;211;0;176;0
WireConnection;102;1;98;0
WireConnection;102;0;92;0
WireConnection;186;0;183;0
WireConnection;186;1;180;0
WireConnection;199;0;190;0
WireConnection;199;1;186;0
WireConnection;205;0;202;0
WireConnection;205;1;198;0
WireConnection;205;2;195;0
WireConnection;55;1;53;0
WireConnection;55;0;54;0
WireConnection;173;1;162;0
WireConnection;173;0;165;0
WireConnection;206;0;199;0
WireConnection;206;1;196;0
WireConnection;165;0;162;0
WireConnection;165;1;163;0
WireConnection;165;2;159;0
WireConnection;204;0;201;0
WireConnection;204;1;194;0
WireConnection;204;2;197;4
WireConnection;66;1;58;0
WireConnection;66;0;62;4
WireConnection;213;1;200;0
WireConnection;213;0;203;0
WireConnection;231;2;208;0
WireConnection;231;3;217;0
WireConnection;231;5;204;0
ASEEND*/
//CHKSM=D4798C0DC0A0085E625EEA1F2696D59043237791