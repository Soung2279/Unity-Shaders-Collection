// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/URP/基础PBR简化_SinC"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(AOMetallicGloss)]
		_AO("环境光AO值", Float) = 1
		_Gloss("光泽度", Float) = 1
		_Metallic("金属度", Float) = 1
		[Toggle(_EMISSIONSWITCH_ON)] _EmissionSwitch("启用自发光", Float) = 0
		[HDR]_AllColor("整体颜色", Color) = (1,1,1,1)
		[Header(Diffuse)]
		[Toggle(_ALBEDOOFF_ON)] _AlbedoOFF("关闭漫反射", Float) = 0
		_MainTex("漫反射贴图", 2D) = "white" {}
		[HDR]_MainColor("漫反射颜色", Color) = (1,1,1,1)
		_MainTexU("漫反射U方向速率", Float) = 0
		_MainTexV("漫反射贴图V方向速率", Float) = 0
		_SecTex("叠加纹理贴图", 2D) = "white" {}
		_SecTexU("叠加纹理U方向速率", Float) = 0
		_SecTexV("叠加纹理V方向速率", Float) = 0
		[Header(Normal)]
		_NormalTex("法线贴图", 2D) = "bump" {}
		_NormalTexU("法线贴图U方向速率", Float) = 0
		_NormalTexV("法线贴图V方向速率", Float) = 0
		_NormalIntensity("法线纹理强度", Float) = 1
		[Header(Opacity)]
		[Toggle]_OpacityMaskTexSwitch("启用透明度遮罩", Float) = 1
		_OpacityMaskTex("透明度遮罩贴图", 2D) = "white" {}
		_OpacityMaskTexU("透明度U方向速率", Float) = 0
		_OpacityMaskTexV("透明度V方向速率", Float) = 0
		[Toggle]_OffsetMaxTexFrequencyToOpacityMaskTex("OffsetMaxTexFrequencyToOpacityMaskTex", Float) = 0
		[Header(Alpha)]
		_AlphaTex1("Alpha遮罩", 2D) = "white" {}
		_AlphaTex1U("遮罩U方向速率", Float) = 0
		_AlphaTex1V("遮罩V方向速率", Float) = 0
		[Header(Distortion)]
		_DistortionTex("扭曲贴图", 2D) = "white" {}
		_DistortionU("扭曲U方向速率", Float) = 0
		_DistortionV("扭曲V方向速率", Float) = 0
		[Toggle(_DISTORTION2UV_ON)] _Distortion2UV("扭曲贴图UV切换", Float) = 0
		[Toggle]_SecTexDistortionUV("扭曲是否影响叠加纹理", Float) = 0
		[Toggle]_NormalTexDistortionUV("扭曲是否影响法线纹理", Float) = 0
		[Toggle]_OffsetTexDistortionUV("扭曲是否影响顶点偏移", Float) = 1
		[Header(VertexOffset)]
		_OffsetTex("顶点偏移贴图", 2D) = "white" {}
		_OffsetTexU("顶点偏移U方向速率", Float) = 0
		_OffsetTexV("顶点偏移V方向速率", Float) = 0
		_VertexOffsetIntensity("顶点偏移强度", Float) = 0
		_OffsetMaskTex("顶点偏移遮罩", 2D) = "white" {}
		_OffsetMaskTexU("顶点偏移遮罩U方向速率", Float) = 0
		_OffsetMaskTexV("顶点偏移遮罩V方向速率", Float) = 0
		[Header(Dither)]
		[Toggle]_DitherSwitch("颜色抖动开关", Float) = 1
		_DitherBias("颜色抖动数值", Float) = 0
		_MaskAddBias("抖动叠加", Float) = 0
		[Header(CubeMap)]
		_CubeMapTex("主CubeMap图", CUBE) = "white" {}
		_CubeMapIntensity("主CubeMap光照系数", Float) = 0
		_AlphaClipIntensity("Alpha裁剪强度", Float) = 1
		[ASEEnd][Toggle]_AlphaClipOn("Alpha裁剪", Float) = 1


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		

			

			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma shader_feature _DISTORTION2UV_ON
			#pragma shader_feature _ALBEDOOFF_ON
			#pragma shader_feature _EMISSIONSWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _OffsetTex;
			sampler2D _DistortionTex;
			sampler2D _OffsetMaskTex;
			samplerCUBE _CubeMapTex;
			sampler2D _NormalTex;
			sampler2D _MainTex;
			sampler2D _SecTex;
			sampler2D _OpacityMaskTex;
			sampler2D _AlphaTex1;


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half2 texCoord43 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = v.texcoord1.xyzw.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2Dlod( _DistortionTex, float4( ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2Dlod( _OffsetTex, float4( (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy, 0, 0.0) ) * tex2Dlod( _OffsetMaskTex, float4( ( texCoord52 + appendResult54 ), 0, 0.0) ) );
				
				o.ase_texcoord7.xyz = v.texcoord.xyz;
				o.ase_texcoord8.xy = v.texcoord1.xyzw.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( temp_output_79_0 * half4( v.ase_normal , 0.0 ) * _VertexOffsetIntensity ).rgb;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(positionCS);
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				half2 texCoord77 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult78 = (half2(( _NormalTexU * _TimeParameters.x ) , ( _TimeParameters.x * _NormalTexV )));
				half2 temp_output_84_0 = ( texCoord77 + appendResult78 );
				half2 texCoord20 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult93 = lerp( half3( temp_output_84_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half3 unpack102 = UnpackNormalScale( tex2D( _NormalTex, (( _NormalTexDistortionUV )?( lerpResult93 ):( half3( temp_output_84_0 ,  0.0 ) )).xy ), _NormalIntensity );
				unpack102.z = lerp( 1, unpack102.z, saturate(_NormalIntensity) );
				half3 tex2DNode102 = unpack102;
				half3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				half3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				half3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				half3 worldRefl105 = normalize( reflect( -WorldViewDirection, float3( dot( tanToWorld0, tex2DNode102 ), dot( tanToWorld1, tex2DNode102 ), dot( tanToWorld2, tex2DNode102 ) ) ) );
				half2 texCoord101 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult103 = (half2(( _MainTexU * _TimeParameters.x ) , ( _TimeParameters.x * _MainTexV )));
				half4 temp_output_122_0 = ( ( ( _CubeMapIntensity * texCUBE( _CubeMapTex, worldRefl105 ) ) + ( _MainColor * tex2D( _MainTex, ( texCoord101 + appendResult103 ) ) ) ) * _AllColor );
				#ifdef _ALBEDOOFF_ON
				float4 staticSwitch149 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch149 = temp_output_122_0;
				#endif
				
				#ifdef _EMISSIONSWITCH_ON
				float4 staticSwitch140 = temp_output_122_0;
				#else
				float4 staticSwitch140 = float4( 0,0,0,0 );
				#endif
				
				half2 texCoord143 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult138 = (half2(( _SecTexU * _TimeParameters.x ) , ( _TimeParameters.x * _SecTexV )));
				half2 temp_output_131_0 = ( texCoord143 + appendResult138 );
				half3 lerpResult128 = lerp( half3( temp_output_131_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half4 tex2DNode130 = tex2D( _SecTex, (( _SecTexDistortionUV )?( lerpResult128 ):( half3( temp_output_131_0 ,  0.0 ) )).xy );
				
				half2 texCoord43 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2D( _OffsetTex, (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy ) * tex2D( _OffsetMaskTex, ( texCoord52 + appendResult54 ) ) );
				half3 desaturateInitialColor86 = temp_output_79_0.rgb;
				half desaturateDot86 = dot( desaturateInitialColor86, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar86 = lerp( desaturateInitialColor86, desaturateDot86.xxx, 1.0 );
				half temp_output_88_0 = (desaturateVar86).x;
				half2 texCoord53 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult56 = (half2(( _OpacityMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OpacityMaskTexV )));
				half3 desaturateInitialColor82 = tex2D( _OpacityMaskTex, (( _OffsetMaxTexFrequencyToOpacityMaskTex )?( ( appendResult54 + texCoord53 ) ):( ( texCoord53 + appendResult56 ) )) ).rgb;
				half desaturateDot82 = dot( desaturateInitialColor82, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar82 = lerp( desaturateInitialColor82, desaturateDot82.xxx, 1.0 );
				half temp_output_89_0 = (desaturateVar82).x;
				half2 texCoord73 = IN.ase_texcoord7.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult75 = (half2(( _AlphaTex1U * _TimeParameters.x ) , ( _TimeParameters.x * _AlphaTex1V )));
				half3 desaturateInitialColor90 = tex2D( _AlphaTex1, ( texCoord73 + appendResult75 ) ).rgb;
				half desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
				half clampResult109 = clamp( ( _MaskAddBias + ( (( _OpacityMaskTexSwitch )?( temp_output_89_0 ):( temp_output_88_0 )) * (desaturateVar90).x ) ) , 0.0 , 1.0 );
				half temp_output_115_0 = (0.0 + (clampResult109 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
				half4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 clipScreen121 = ase_screenPosNorm.xy * _ScreenParams.xy;
				half dither121 = Dither4x4Bayer( fmod(clipScreen121.x, 4), fmod(clipScreen121.y, 4) );
				dither121 = step( dither121, ( temp_output_115_0 + _DitherBias ) );
				

				float3 BaseColor = staticSwitch149.rgb;
				float3 Normal = tex2DNode102;
				float3 Emission = staticSwitch140.rgb;
				float3 Specular = 0.5;
				float Metallic = ( tex2DNode130.b * _Metallic );
				float Smoothness = ( tex2DNode130.g * _Gloss );
				float Occlusion = ( tex2DNode130.r * _AO );
				float Alpha = (( _DitherSwitch )?( dither121 ):( temp_output_115_0 ));
				float AlphaClipThreshold = (( _AlphaClipOn )?( _AlphaClipIntensity ):( 0.0 ));
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				half4 color = UniversalFragmentPBR(
					inputData,
					BaseColor,
					Metallic,
					Specular,
					Smoothness,
					Occlusion,
					Emission,
					Alpha);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += BaseColor * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += BaseColor * transmission;
						}
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += BaseColor * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += BaseColor * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature _DISTORTION2UV_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _OffsetTex;
			sampler2D _DistortionTex;
			sampler2D _OffsetMaskTex;
			sampler2D _OpacityMaskTex;
			sampler2D _AlphaTex1;


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			float3 _LightDirection;
			#if ASE_SRP_VERSION >= 110000
				float3 _LightPosition;
			#endif

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				half2 texCoord43 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2Dlod( _DistortionTex, float4( ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2Dlod( _OffsetTex, float4( (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy, 0, 0.0) ) * tex2Dlod( _OffsetMaskTex, float4( ( texCoord52 + appendResult54 ), 0, 0.0) ) );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( temp_output_79_0 * half4( v.ase_normal , 0.0 ) * _VertexOffsetIntensity ).rgb;
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

				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				#if ASE_SRP_VERSION >= 110000
					#if _CASTING_PUNCTUAL_LIGHT_SHADOW
						float3 lightDirectionWS = normalize(_LightPosition - positionWS);
					#else
						float3 lightDirectionWS = _LightDirection;
					#endif

					float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#endif
				#else
					float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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

				half2 texCoord43 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2D( _OffsetTex, (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy ) * tex2D( _OffsetMaskTex, ( texCoord52 + appendResult54 ) ) );
				half3 desaturateInitialColor86 = temp_output_79_0.rgb;
				half desaturateDot86 = dot( desaturateInitialColor86, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar86 = lerp( desaturateInitialColor86, desaturateDot86.xxx, 1.0 );
				half temp_output_88_0 = (desaturateVar86).x;
				half2 texCoord53 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult56 = (half2(( _OpacityMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OpacityMaskTexV )));
				half3 desaturateInitialColor82 = tex2D( _OpacityMaskTex, (( _OffsetMaxTexFrequencyToOpacityMaskTex )?( ( appendResult54 + texCoord53 ) ):( ( texCoord53 + appendResult56 ) )) ).rgb;
				half desaturateDot82 = dot( desaturateInitialColor82, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar82 = lerp( desaturateInitialColor82, desaturateDot82.xxx, 1.0 );
				half temp_output_89_0 = (desaturateVar82).x;
				half2 texCoord73 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult75 = (half2(( _AlphaTex1U * _TimeParameters.x ) , ( _TimeParameters.x * _AlphaTex1V )));
				half3 desaturateInitialColor90 = tex2D( _AlphaTex1, ( texCoord73 + appendResult75 ) ).rgb;
				half desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
				half clampResult109 = clamp( ( _MaskAddBias + ( (( _OpacityMaskTexSwitch )?( temp_output_89_0 ):( temp_output_88_0 )) * (desaturateVar90).x ) ) , 0.0 , 1.0 );
				half temp_output_115_0 = (0.0 + (clampResult109 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
				float4 screenPos = IN.ase_texcoord3;
				half4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 clipScreen121 = ase_screenPosNorm.xy * _ScreenParams.xy;
				half dither121 = Dither4x4Bayer( fmod(clipScreen121.x, 4), fmod(clipScreen121.y, 4) );
				dither121 = step( dither121, ( temp_output_115_0 + _DitherBias ) );
				

				float Alpha = (( _DitherSwitch )?( dither121 ):( temp_output_115_0 ));
				float AlphaClipThreshold = (( _AlphaClipOn )?( _AlphaClipIntensity ):( 0.0 ));
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature _DISTORTION2UV_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _OffsetTex;
			sampler2D _DistortionTex;
			sampler2D _OffsetMaskTex;
			sampler2D _OpacityMaskTex;
			sampler2D _AlphaTex1;


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half2 texCoord43 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2Dlod( _DistortionTex, float4( ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2Dlod( _OffsetTex, float4( (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy, 0, 0.0) ) * tex2Dlod( _OffsetMaskTex, float4( ( texCoord52 + appendResult54 ), 0, 0.0) ) );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( temp_output_79_0 * half4( v.ase_normal , 0.0 ) * _VertexOffsetIntensity ).rgb;

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

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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

				half2 texCoord43 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2D( _OffsetTex, (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy ) * tex2D( _OffsetMaskTex, ( texCoord52 + appendResult54 ) ) );
				half3 desaturateInitialColor86 = temp_output_79_0.rgb;
				half desaturateDot86 = dot( desaturateInitialColor86, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar86 = lerp( desaturateInitialColor86, desaturateDot86.xxx, 1.0 );
				half temp_output_88_0 = (desaturateVar86).x;
				half2 texCoord53 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult56 = (half2(( _OpacityMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OpacityMaskTexV )));
				half3 desaturateInitialColor82 = tex2D( _OpacityMaskTex, (( _OffsetMaxTexFrequencyToOpacityMaskTex )?( ( appendResult54 + texCoord53 ) ):( ( texCoord53 + appendResult56 ) )) ).rgb;
				half desaturateDot82 = dot( desaturateInitialColor82, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar82 = lerp( desaturateInitialColor82, desaturateDot82.xxx, 1.0 );
				half temp_output_89_0 = (desaturateVar82).x;
				half2 texCoord73 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult75 = (half2(( _AlphaTex1U * _TimeParameters.x ) , ( _TimeParameters.x * _AlphaTex1V )));
				half3 desaturateInitialColor90 = tex2D( _AlphaTex1, ( texCoord73 + appendResult75 ) ).rgb;
				half desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
				half clampResult109 = clamp( ( _MaskAddBias + ( (( _OpacityMaskTexSwitch )?( temp_output_89_0 ):( temp_output_88_0 )) * (desaturateVar90).x ) ) , 0.0 , 1.0 );
				half temp_output_115_0 = (0.0 + (clampResult109 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
				float4 screenPos = IN.ase_texcoord3;
				half4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 clipScreen121 = ase_screenPosNorm.xy * _ScreenParams.xy;
				half dither121 = Dither4x4Bayer( fmod(clipScreen121.x, 4), fmod(clipScreen121.y, 4) );
				dither121 = step( dither121, ( temp_output_115_0 + _DitherBias ) );
				

				float Alpha = (( _DitherSwitch )?( dither121 ):( temp_output_115_0 ));
				float AlphaClipThreshold = (( _AlphaClipOn )?( _AlphaClipIntensity ):( 0.0 ));
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _DISTORTION2UV_ON
			#pragma shader_feature _ALBEDOOFF_ON
			#pragma shader_feature _EMISSIONSWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _OffsetTex;
			sampler2D _DistortionTex;
			sampler2D _OffsetMaskTex;
			samplerCUBE _CubeMapTex;
			sampler2D _NormalTex;
			sampler2D _MainTex;
			sampler2D _OpacityMaskTex;
			sampler2D _AlphaTex1;


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half2 texCoord43 = v.ase_texcoord.xyz * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2Dlod( _DistortionTex, float4( ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2Dlod( _OffsetTex, float4( (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy, 0, 0.0) ) * tex2Dlod( _OffsetMaskTex, float4( ( texCoord52 + appendResult54 ), 0, 0.0) ) );
				
				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				o.ase_texcoord3.xy = v.texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( temp_output_79_0 * half4( v.ase_normal , 0.0 ) * _VertexOffsetIntensity ).rgb;

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

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

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

				half2 texCoord77 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult78 = (half2(( _NormalTexU * _TimeParameters.x ) , ( _TimeParameters.x * _NormalTexV )));
				half2 temp_output_84_0 = ( texCoord77 + appendResult78 );
				half2 texCoord20 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult93 = lerp( half3( temp_output_84_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half3 unpack102 = UnpackNormalScale( tex2D( _NormalTex, (( _NormalTexDistortionUV )?( lerpResult93 ):( half3( temp_output_84_0 ,  0.0 ) )).xy ), _NormalIntensity );
				unpack102.z = lerp( 1, unpack102.z, saturate(_NormalIntensity) );
				half3 tex2DNode102 = unpack102;
				half3 ase_worldTangent = IN.ase_texcoord4.xyz;
				half3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 worldRefl105 = normalize( reflect( -ase_worldViewDir, float3( dot( tanToWorld0, tex2DNode102 ), dot( tanToWorld1, tex2DNode102 ), dot( tanToWorld2, tex2DNode102 ) ) ) );
				half2 texCoord101 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult103 = (half2(( _MainTexU * _TimeParameters.x ) , ( _TimeParameters.x * _MainTexV )));
				half4 temp_output_122_0 = ( ( ( _CubeMapIntensity * texCUBE( _CubeMapTex, worldRefl105 ) ) + ( _MainColor * tex2D( _MainTex, ( texCoord101 + appendResult103 ) ) ) ) * _AllColor );
				#ifdef _ALBEDOOFF_ON
				float4 staticSwitch149 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch149 = temp_output_122_0;
				#endif
				
				#ifdef _EMISSIONSWITCH_ON
				float4 staticSwitch140 = temp_output_122_0;
				#else
				float4 staticSwitch140 = float4( 0,0,0,0 );
				#endif
				
				half2 texCoord43 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2D( _OffsetTex, (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy ) * tex2D( _OffsetMaskTex, ( texCoord52 + appendResult54 ) ) );
				half3 desaturateInitialColor86 = temp_output_79_0.rgb;
				half desaturateDot86 = dot( desaturateInitialColor86, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar86 = lerp( desaturateInitialColor86, desaturateDot86.xxx, 1.0 );
				half temp_output_88_0 = (desaturateVar86).x;
				half2 texCoord53 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult56 = (half2(( _OpacityMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OpacityMaskTexV )));
				half3 desaturateInitialColor82 = tex2D( _OpacityMaskTex, (( _OffsetMaxTexFrequencyToOpacityMaskTex )?( ( appendResult54 + texCoord53 ) ):( ( texCoord53 + appendResult56 ) )) ).rgb;
				half desaturateDot82 = dot( desaturateInitialColor82, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar82 = lerp( desaturateInitialColor82, desaturateDot82.xxx, 1.0 );
				half temp_output_89_0 = (desaturateVar82).x;
				half2 texCoord73 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult75 = (half2(( _AlphaTex1U * _TimeParameters.x ) , ( _TimeParameters.x * _AlphaTex1V )));
				half3 desaturateInitialColor90 = tex2D( _AlphaTex1, ( texCoord73 + appendResult75 ) ).rgb;
				half desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
				half clampResult109 = clamp( ( _MaskAddBias + ( (( _OpacityMaskTexSwitch )?( temp_output_89_0 ):( temp_output_88_0 )) * (desaturateVar90).x ) ) , 0.0 , 1.0 );
				half temp_output_115_0 = (0.0 + (clampResult109 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
				float4 screenPos = IN.ase_texcoord7;
				half4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 clipScreen121 = ase_screenPosNorm.xy * _ScreenParams.xy;
				half dither121 = Dither4x4Bayer( fmod(clipScreen121.x, 4), fmod(clipScreen121.y, 4) );
				dither121 = step( dither121, ( temp_output_115_0 + _DitherBias ) );
				

				float3 BaseColor = staticSwitch149.rgb;
				float3 Emission = staticSwitch140.rgb;
				float Alpha = (( _DitherSwitch )?( dither121 ):( temp_output_115_0 ));
				float AlphaClipThreshold = (( _AlphaClipOn )?( _AlphaClipIntensity ):( 0.0 ));

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;

				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _DISTORTION2UV_ON
			#pragma shader_feature _ALBEDOOFF_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				half4 ase_tangent : TANGENT;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _OffsetTex;
			sampler2D _DistortionTex;
			sampler2D _OffsetMaskTex;
			samplerCUBE _CubeMapTex;
			sampler2D _NormalTex;
			sampler2D _MainTex;
			sampler2D _OpacityMaskTex;
			sampler2D _AlphaTex1;


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				half2 texCoord43 = v.ase_texcoord.xyz * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half2 texCoord20 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2Dlod( _DistortionTex, float4( ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ), 0, 0.0) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2Dlod( _OffsetTex, float4( (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy, 0, 0.0) ) * tex2Dlod( _OffsetMaskTex, float4( ( texCoord52 + appendResult54 ), 0, 0.0) ) );
				
				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				o.ase_texcoord3.xy = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( temp_output_79_0 * half4( v.ase_normal , 0.0 ) * _VertexOffsetIntensity ).rgb;

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

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				half4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
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

				half2 texCoord77 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult78 = (half2(( _NormalTexU * _TimeParameters.x ) , ( _TimeParameters.x * _NormalTexV )));
				half2 temp_output_84_0 = ( texCoord77 + appendResult78 );
				half2 texCoord20 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord23 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch24 = texCoord23;
				#else
				float2 staticSwitch24 = texCoord20;
				#endif
				half2 appendResult22 = (half2(_DistortionU , _DistortionV));
				half3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch24 + ( appendResult22 * _TimeParameters.x ) ) ).rgb;
				half desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
				half3 DistortionUV35 = desaturateVar31;
				half3 lerpResult93 = lerp( half3( temp_output_84_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half3 unpack102 = UnpackNormalScale( tex2D( _NormalTex, (( _NormalTexDistortionUV )?( lerpResult93 ):( half3( temp_output_84_0 ,  0.0 ) )).xy ), _NormalIntensity );
				unpack102.z = lerp( 1, unpack102.z, saturate(_NormalIntensity) );
				half3 tex2DNode102 = unpack102;
				half3 ase_worldTangent = IN.ase_texcoord4.xyz;
				half3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 worldRefl105 = normalize( reflect( -ase_worldViewDir, float3( dot( tanToWorld0, tex2DNode102 ), dot( tanToWorld1, tex2DNode102 ), dot( tanToWorld2, tex2DNode102 ) ) ) );
				half2 texCoord101 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult103 = (half2(( _MainTexU * _TimeParameters.x ) , ( _TimeParameters.x * _MainTexV )));
				half4 temp_output_122_0 = ( ( ( _CubeMapIntensity * texCUBE( _CubeMapTex, worldRefl105 ) ) + ( _MainColor * tex2D( _MainTex, ( texCoord101 + appendResult103 ) ) ) ) * _AllColor );
				#ifdef _ALBEDOOFF_ON
				float4 staticSwitch149 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch149 = temp_output_122_0;
				#endif
				
				half2 texCoord43 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult38 = (half2(( _OffsetTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetTexV )));
				half2 temp_output_50_0 = ( texCoord43 + appendResult38 );
				half3 lerpResult58 = lerp( half3( temp_output_50_0 ,  0.0 ) , DistortionUV35 , DistortionUV35);
				half2 texCoord52 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult54 = (half2(( _OffsetMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OffsetMaskTexV )));
				half4 temp_output_79_0 = ( tex2D( _OffsetTex, (( _OffsetTexDistortionUV )?( lerpResult58 ):( half3( temp_output_50_0 ,  0.0 ) )).xy ) * tex2D( _OffsetMaskTex, ( texCoord52 + appendResult54 ) ) );
				half3 desaturateInitialColor86 = temp_output_79_0.rgb;
				half desaturateDot86 = dot( desaturateInitialColor86, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar86 = lerp( desaturateInitialColor86, desaturateDot86.xxx, 1.0 );
				half temp_output_88_0 = (desaturateVar86).x;
				half2 texCoord53 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult56 = (half2(( _OpacityMaskTexU * _TimeParameters.x ) , ( _TimeParameters.x * _OpacityMaskTexV )));
				half3 desaturateInitialColor82 = tex2D( _OpacityMaskTex, (( _OffsetMaxTexFrequencyToOpacityMaskTex )?( ( appendResult54 + texCoord53 ) ):( ( texCoord53 + appendResult56 ) )) ).rgb;
				half desaturateDot82 = dot( desaturateInitialColor82, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar82 = lerp( desaturateInitialColor82, desaturateDot82.xxx, 1.0 );
				half temp_output_89_0 = (desaturateVar82).x;
				half2 texCoord73 = IN.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				half2 appendResult75 = (half2(( _AlphaTex1U * _TimeParameters.x ) , ( _TimeParameters.x * _AlphaTex1V )));
				half3 desaturateInitialColor90 = tex2D( _AlphaTex1, ( texCoord73 + appendResult75 ) ).rgb;
				half desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
				half clampResult109 = clamp( ( _MaskAddBias + ( (( _OpacityMaskTexSwitch )?( temp_output_89_0 ):( temp_output_88_0 )) * (desaturateVar90).x ) ) , 0.0 , 1.0 );
				half temp_output_115_0 = (0.0 + (clampResult109 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
				float4 screenPos = IN.ase_texcoord7;
				half4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 clipScreen121 = ase_screenPosNorm.xy * _ScreenParams.xy;
				half dither121 = Dither4x4Bayer( fmod(clipScreen121.x, 4), fmod(clipScreen121.y, 4) );
				dither121 = step( dither121, ( temp_output_115_0 + _DitherBias ) );
				

				float3 BaseColor = staticSwitch149.rgb;
				float Alpha = (( _DitherSwitch )?( dither121 ):( temp_output_115_0 ));
				float AlphaClipThreshold = (( _AlphaClipOn )?( _AlphaClipIntensity ):( 0.0 ));

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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
				float3 worldNormal : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if ASE_SRP_VERSION >= 110000
					return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
				#elif ASE_SRP_VERSION >= 100900
					return float4(PackNormalOctRectEncode(normalize(IN.worldNormal)), 0.0, 0.0);
				#else
					return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
		

			

			#pragma multi_compile_fragment _ _SHADOWS_SOFT

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AllColor;
			float4 _MainColor;
			float _SecTexV;
			float _Metallic;
			float _Gloss;
			float _AO;
			half _DitherSwitch;
			float _SecTexU;
			float _MaskAddBias;
			half _OffsetMaxTexFrequencyToOpacityMaskTex;
			float _OpacityMaskTexU;
			float _OpacityMaskTexV;
			float _AlphaTex1U;
			float _AlphaTex1V;
			float _DitherBias;
			half _OpacityMaskTexSwitch;
			half _SecTexDistortionUV;
			half _OffsetTexDistortionUV;
			float _MainTexV;
			float _MainTexU;
			float _NormalIntensity;
			float _NormalTexV;
			float _NormalTexU;
			half _NormalTexDistortionUV;
			float _CubeMapIntensity;
			float _VertexOffsetIntensity;
			float _OffsetMaskTexV;
			float _OffsetMaskTexU;
			float _DistortionV;
			float _DistortionU;
			float _OffsetTexV;
			float _OffsetTexU;
			half _AlphaClipOn;
			half _AlphaClipIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

					o.clipPos = positionCS;

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(positionCS);
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				

				float3 BaseColor = float3(0.5, 0.5, 0.5);
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = 0; // we don't apply fog in the gbuffer pass
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				BRDFData brdfData;
				InitializeBRDFData( BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);
				half4 color;
				color.rgb = GlobalIllumination( brdfData, inputData.bakedGI, Occlusion, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;1;-4355.941,-1305.158;Inherit;False;1207;533.7722;UV扭曲贴图;11;31;27;26;25;24;23;22;21;20;19;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-4284.941,-1008.158;Float;False;Property;_DistortionU;DistortionU;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-4284.941,-928.1582;Float;False;Property;_DistortionV;DistortionV;40;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-4305.941,-1255.158;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;22;-4108.941,-992.1582;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-4134.475,-882.0532;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-4303.105,-1137.487;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-3948.941,-992.1582;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;24;-4049.941,-1207.158;Float;False;Property;_Distortion2UV;Distortion2UV;42;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3615.083,423.2627;Inherit;False;695.9;444.1667;贴图流动;8;50;43;38;34;33;30;29;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-3796.941,-1049.158;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3537.085,751.7628;Float;False;Property;_OffsetTexV;OffsetTexV;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;28;-3565.085,683.7628;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-3644.942,-1088.158;Inherit;True;Property;_DistortionTex;DistortionTex;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-3540.085,599.7628;Float;False;Property;_OffsetTexU;OffsetTexU;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-3376.083,602.7628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3375.083,700.7628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;31;-3356.94,-1081.158;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;5;-3649.119,879.1101;Inherit;False;730.9009;442.1664;贴图流动;8;67;54;52;51;49;44;42;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;4;-3651.898,1337.356;Inherit;False;730.9009;442.1664;贴图流动;8;62;56;53;47;46;41;37;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3601.898,1511.857;Float;False;Property;_OpacityMaskTexU;OpacityMaskTexU;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-3467.983,473.2627;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;40;-3564.119,1139.609;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-3596.119,1205.609;Float;False;Property;_OffsetMaskTexV;OffsetMaskTexV;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3599.119,1053.61;Float;False;Property;_OffsetMaskTexU;OffsetMaskTexU;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-3106.824,-1087.947;Half;False;DistortionUV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3598.898,1663.856;Float;False;Property;_OpacityMaskTexV;OpacityMaskTexV;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-3214.784,634.6627;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-3566.898,1597.856;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-3375.119,1058.61;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;6;-3645.94,1794.638;Inherit;False;730.9009;442.1664;贴图流动;8;80;75;73;68;60;59;57;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-3374.119,1156.609;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2800.391,776.7594;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-3377.898,1516.857;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-3376.898,1614.856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2833.945,849.9153;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-3075.184,586.9628;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-3213.818,1090.509;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;7;-260.3221,-969.6563;Inherit;False;695.9;444.1667;贴图流动;8;84;78;77;74;69;66;64;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;-3216.599,1548.756;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-3467.018,929.1101;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-3592.94,2121.14;Float;False;Property;_AlphaTex1V;AlphaTex1V;37;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-3469.799,1387.356;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-3595.94,1969.137;Float;False;Property;_AlphaTex1U;AlphaTex1U;36;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;-2587.957,718.8745;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;57;-3560.94,2055.14;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2801.319,1315.309;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-182.3221,-641.1561;Float;False;Property;_NormalTexV;NormalTexV;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-185.3221,-793.1563;Float;False;Property;_NormalTexU;NormalTexU;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-3076.998,1501.057;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;61;-2370.621,509.213;Inherit;False;Property;_OffsetTexDistortionUV;OffsetTexDistortionUV;48;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-3370.94,2072.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-3074.219,1042.81;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;66;-210.3221,-709.1561;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-3371.94,1974.138;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-20.32214,-692.1561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-21.32214,-790.1563;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-3210.641,2006.038;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;70;-2067.806,556.3287;Inherit;True;Property;_OffsetTex;OffsetTex;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;71;-2487.563,1392.196;Half;False;Property;_OffsetMaxTexFrequencyToOpacityMaskTex;OffsetMaxTexFrequencyToOpacityMaskTex;31;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;72;-2122.447,948.0752;Inherit;True;Property;_OffsetMaskTex;OffsetMaskTex;23;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-3463.841,1844.638;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;76;-2091.381,1421.414;Inherit;True;Property;_OpacityMaskTex;OpacityMaskTex;28;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1638.224,562.6235;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-113.2222,-919.6563;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;78;139.9769,-758.2563;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-3076.241,1854.337;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DesaturateOpNode;86;-1241.352,840.5326;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;8;-1005.188,-1321.599;Inherit;False;695.9;444.1667;贴图流动;8;106;103;101;96;95;92;91;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;255.0469,-517.7947;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;81;-2060.136,1821.483;Inherit;True;Property;_AlphaTex1;AlphaTex1;35;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;82;-1243.692,1401.177;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;228.4979,-445.8062;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;279.5779,-805.9564;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-931.5161,-1146.428;Float;False;Property;_MainTexU;MainTexU;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;93;472.6941,-599.0748;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;88;-964.6931,865.7695;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;90;-1769.047,1825.076;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;89;-1069.818,1399.747;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-927.1882,-993.0981;Float;False;Property;_MainTexV;MainTexV;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;87;-955.1882,-1061.098;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-766.187,-1142.099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;9;-41.70007,424.5754;Inherit;False;718.0901;261.9537;Mask阈值加强;4;115;109;107;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;97;753.2583,-563.1571;Float;False;Property;_NormalIntensity;NormalIntensity;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-765.187,-1044.098;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;98;-1598.172,1819.646;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;94;646.5625,-784.5989;Inherit;False;Property;_NormalTexDistortionUV;NormalTexDistortionUV;45;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;99;-683.8411,1285.044;Inherit;False;Property;_OpacityMaskTexSwitch;OpacityMaskTexSwitch;27;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;8.299927,474.5754;Float;False;Property;_MaskAddBias;MaskAddBias;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;951.8285,-692.1239;Inherit;True;Property;_NormalTex;NormalTex;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;103;-604.8882,-1110.199;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-858.0881,-1271.599;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-299.6031,1385.838;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;10;-533.3052,-1811.345;Inherit;False;692.9723;355.0887;CubeMap;4;114;112;111;105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;197.7269,479.778;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;11;-290.5261,-1453.093;Inherit;False;455.9125;260.3333;贴图颜色叠加;2;116;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldReflectionVector;105;-494.4882,-1652.908;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;106;-465.2881,-1157.899;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;111;-294.2471,-1686.257;Inherit;True;Property;_CubeMapTex;CubeMapTex;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;109;314.8539,480.5802;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;108;-296.8121,-1183.239;Inherit;True;Property;_MainTex;MainTex;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;110;-240.5261,-1403.093;Float;False;Property;_MainColor;MainColor;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;112;-226.0011,-1762.345;Float;False;Property;_CubeMapIntensity;CubeMapIntensity;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;951.405,431.4117;Inherit;False;579.7141;189.3333;抖动控制;3;121;119;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-9.33313,-1752.223;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;13;356.6589,-1593.653;Inherit;False;474.3093;260.3334;总颜色叠加;2;122;118;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;113;963.7053,545.4846;Float;False;Property;_DitherBias;DitherBias;33;0;Create;True;0;0;0;False;0;False;0;-1.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-9.947144,-1396.795;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;115;460.3899,481.1956;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;212.0109,-1554.339;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;1151.207,485.0315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;118;406.6589,-1543.653;Float;False;Property;_AllColor;AllColor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-455.0361,1103.106;Float;False;Property;_VertexOffsetIntensity;VertexOffsetIntensity;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;123;-420.6631,964.3857;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;655.6359,-1537.568;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;121;1287.786,468.1118;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;16;798.5731,-238.8945;Inherit;False;414.3335;210.6666;粗糙度;2;146;144;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1111.141,-318.1149;Inherit;False;695.9;444.1667;贴图流动;8;143;141;138;137;136;133;131;127;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;3;-3461.623,-1483.613;Inherit;False;312.6667;165.6667;UV扭曲强度;1;32;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;799.5731,-20.89456;Inherit;False;413.3335;192.6667;金属度;2;148;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;800.2143,-472.0659;Inherit;False;409.3331;225.6667;AO;2;151;126;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;120;1861.63,291.2986;Half;False;Property;_AlphaClipIntensity;AlphaClipIntensity;49;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;140;872.0907,-1448.462;Float;False;Property;_EmissionSwitch;EmissionSwitch;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;1037.573,29.10544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;1037.573,-188.8946;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;150;69.19788,-85.34026;Float;False;Property;_SecTexDistortionUV;SecTexDistortionUV;46;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;149;867.9838,-1551.726;Float;False;Property;_AlbedoOFF;AlbedoOFF;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;1034.214,-422.0659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;147;-2358.776,650.7478;Float;False;Property;_OffsetTexDistortionUV;OffsetTexDistortionUV;47;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;141;-1061.141,-57.61476;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;138;-710.8411,-106.7151;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;144;848.5731,-143.8946;Float;False;Property;_Gloss;Gloss;3;0;Create;True;0;0;0;False;0;False;1;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;143;-964.041,-268.1149;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;142;628.5739,-666.2094;Float;False;Property;_NormalTexDistortionUV;NormalTexDistortionUV;43;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-1033.141,10.38513;Float;False;Property;_SecTexV;SecTexV;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;132;78.14087,-200.455;Inherit;False;Property;_SecTexDistortionUV;SecTexDistortionUV;44;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-3125.782,-1431.913;Half;False;DistortionIndeisty;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-213.1411,915.2126;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-571.2421,-154.4149;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;125;2155.561,222.392;Half;False;Property;_AlphaClipOn;AlphaClipOn;50;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;134;-713.2942,1390.573;Float;False;Property;_OpacityMaskTexSwitch;OpacityMaskTexSwitch;26;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;850.2143,-362.0659;Float;False;Property;_AO;AO;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-1036.141,-141.615;Float;False;Property;_SecTexU;SecTexU;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-3411.623,-1434.67;Float;False;Property;_DistortionIntensity;DistortionIntensity;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;393.6208,-187.7318;Inherit;True;Property;_SecTex;SecTex;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-871.1411,-40.61487;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-367.3621,58.29471;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-401.1921,127.4177;Inherit;False;35;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-872.1411,-138.615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-124.9291,9.409836;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;148;849.5731,56.10544;Float;False;Property;_Metallic;Metallic;4;0;Create;True;0;0;0;False;0;False;1;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;152;1585.152,94.64735;Inherit;False;Property;_DitherSwitch;DitherSwitch;32;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;155;1538.983,-516.4839;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;158;1538.983,-516.4839;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;157;1538.983,-516.4839;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;156;1538.983,-516.4839;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;153;1538.983,-516.4839;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;154;2537.245,26.09193;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;A201-Shader/URP/PBR简化;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;8;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;159;2537.245,86.09193;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;160;2537.245,86.09193;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;22;0;18;0
WireConnection;22;1;19;0
WireConnection;25;0;22;0
WireConnection;25;1;21;0
WireConnection;24;1;20;0
WireConnection;24;0;23;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;27;1;26;0
WireConnection;34;0;29;0
WireConnection;34;1;28;0
WireConnection;33;0;28;0
WireConnection;33;1;30;0
WireConnection;31;0;27;0
WireConnection;35;0;31;0
WireConnection;38;0;34;0
WireConnection;38;1;33;0
WireConnection;49;0;44;0
WireConnection;49;1;40;0
WireConnection;51;0;40;0
WireConnection;51;1;42;0
WireConnection;46;0;41;0
WireConnection;46;1;36;0
WireConnection;47;0;36;0
WireConnection;47;1;37;0
WireConnection;50;0;43;0
WireConnection;50;1;38;0
WireConnection;54;0;49;0
WireConnection;54;1;51;0
WireConnection;56;0;46;0
WireConnection;56;1;47;0
WireConnection;58;0;50;0
WireConnection;58;1;45;0
WireConnection;58;2;48;0
WireConnection;65;0;54;0
WireConnection;65;1;53;0
WireConnection;62;0;53;0
WireConnection;62;1;56;0
WireConnection;61;0;50;0
WireConnection;61;1;58;0
WireConnection;60;0;57;0
WireConnection;60;1;59;0
WireConnection;67;0;52;0
WireConnection;67;1;54;0
WireConnection;68;0;55;0
WireConnection;68;1;57;0
WireConnection;74;0;66;0
WireConnection;74;1;64;0
WireConnection;69;0;63;0
WireConnection;69;1;66;0
WireConnection;75;0;68;0
WireConnection;75;1;60;0
WireConnection;70;1;61;0
WireConnection;71;0;62;0
WireConnection;71;1;65;0
WireConnection;72;1;67;0
WireConnection;76;1;71;0
WireConnection;79;0;70;0
WireConnection;79;1;72;0
WireConnection;78;0;69;0
WireConnection;78;1;74;0
WireConnection;80;0;73;0
WireConnection;80;1;75;0
WireConnection;86;0;79;0
WireConnection;81;1;80;0
WireConnection;82;0;76;0
WireConnection;84;0;77;0
WireConnection;84;1;78;0
WireConnection;93;0;84;0
WireConnection;93;1;85;0
WireConnection;93;2;83;0
WireConnection;88;0;86;0
WireConnection;90;0;81;0
WireConnection;89;0;82;0
WireConnection;95;0;92;0
WireConnection;95;1;87;0
WireConnection;96;0;87;0
WireConnection;96;1;91;0
WireConnection;98;0;90;0
WireConnection;94;0;84;0
WireConnection;94;1;93;0
WireConnection;99;0;88;0
WireConnection;99;1;89;0
WireConnection;102;1;94;0
WireConnection;102;5;97;0
WireConnection;103;0;95;0
WireConnection;103;1;96;0
WireConnection;104;0;99;0
WireConnection;104;1;98;0
WireConnection;107;0;100;0
WireConnection;107;1;104;0
WireConnection;105;0;102;0
WireConnection;106;0;101;0
WireConnection;106;1;103;0
WireConnection;111;1;105;0
WireConnection;109;0;107;0
WireConnection;108;1;106;0
WireConnection;114;0;112;0
WireConnection;114;1;111;0
WireConnection;116;0;110;0
WireConnection;116;1;108;0
WireConnection;115;0;109;0
WireConnection;117;0;114;0
WireConnection;117;1;116;0
WireConnection;119;0;115;0
WireConnection;119;1;113;0
WireConnection;122;0;117;0
WireConnection;122;1;118;0
WireConnection;121;0;119;0
WireConnection;140;0;122;0
WireConnection;139;0;130;3
WireConnection;139;1;148;0
WireConnection;146;0;130;2
WireConnection;146;1;144;0
WireConnection;150;1;131;0
WireConnection;150;0;128;0
WireConnection;149;1;122;0
WireConnection;151;0;130;1
WireConnection;151;1;126;0
WireConnection;147;1;50;0
WireConnection;147;0;58;0
WireConnection;138;0;136;0
WireConnection;138;1;133;0
WireConnection;142;1;84;0
WireConnection;142;0;93;0
WireConnection;132;0;131;0
WireConnection;132;1;128;0
WireConnection;39;0;32;0
WireConnection;145;0;79;0
WireConnection;145;1;123;0
WireConnection;145;2;124;0
WireConnection;131;0;143;0
WireConnection;131;1;138;0
WireConnection;125;1;120;0
WireConnection;134;1;88;0
WireConnection;134;0;89;0
WireConnection;130;1;132;0
WireConnection;133;0;141;0
WireConnection;133;1;137;0
WireConnection;136;0;127;0
WireConnection;136;1;141;0
WireConnection;128;0;131;0
WireConnection;128;1;135;0
WireConnection;128;2;129;0
WireConnection;152;0;115;0
WireConnection;152;1;121;0
WireConnection;154;0;149;0
WireConnection;154;1;102;0
WireConnection;154;2;140;0
WireConnection;154;3;139;0
WireConnection;154;4;146;0
WireConnection;154;5;151;0
WireConnection;154;6;152;0
WireConnection;154;7;125;0
WireConnection;154;8;145;0
ASEEND*/
//CHKSM=D7A10A595E81E948990220786FAB17FE834BC44F