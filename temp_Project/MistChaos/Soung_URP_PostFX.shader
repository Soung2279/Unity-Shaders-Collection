// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Soung/Post/ScreenFX"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[KeywordEnum(Heat,Blur,BlackNWhite,Screen,Chroma)] _FunctionSwitcher("功能", Float) = 0
		[Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Header(Heat)]_HeatTex("热扭曲贴图", 2D) = "black" {}
		_HeatPower("热扭曲强度", Range( 0 , 1)) = 0.01
		[Enum(Material,0,Custom1y,1)]_HeatPowerMode("热扭曲强度模式", Float) = 0
		[Enum(Local,0,Polar,1)]_HeatUVMode("热扭曲UV模式", Float) = 0
		[Enum(Local,0,Global,1)]_HeatPolarCenterMode("热扭曲极坐标原点模式", Float) = 0
		_HeatPolarSettings("热扭曲极坐标原点与偏移", Vector) = (0.5,0.5,1,1)
		_HeatUSpeed("热扭曲U速度", Float) = 0
		_HeatVSpeed("热扭曲V速度", Float) = 0
		[Enum(Program,0,Texture,1)]_HeatMaskMode("热扭曲遮罩模式", Float) = 0
		[HDR][Header(BlackNWhite)]_FlashColor("黑白闪颜色", Color) = (1,1,1,0)
		_BlackNWhiteSoft("黑白过渡", Range( 0.51 , 1)) = 0.51
		[Enum(Material,0,Custom1x,1)]_BlackNWhiteSwitch("黑白闪切换方式", Float) = 0
		_BlackNWhite("黑白闪切换", Range( 0 , 1)) = 0
		[NoScaleOffset]_RadialTex("放射线贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_RadiusMaskP("放射贴图通道", Float) = 0
		_RadialUSpeed("放射U速度", Float) = 0
		_RadialVSpeed("放射V速度", Float) = 0
		_RadialPower("放射强度", Range( 0 , 1)) = 0
		[Enum(Program,0,Texture,1)]_RadialMaskMode("放射线遮罩方式", Float) = 0
		_GlobalPolarCenter("全局极坐标原点与偏移", Vector) = (0.5,0.5,1,1)
		[Header(Mask)][NoScaleOffset]_MaskTex("遮罩贴图", 2D) = "white" {}
		_MaskTexOffset("遮罩贴图平铺与偏移", Vector) = (1,1,0,0)
		[Enum(R,0,A,1)]_MaskTexP("遮罩贴图通道", Float) = 0
		[Enum(OFF,0,ON,1)]_OneMinusMask("反相遮罩", Float) = 0
		[IntRange]_MaskTexRotator("遮罩贴图旋转", Range( 0 , 360)) = 0
		[Header(ProgramMask)]_ProgramMaskSoft("程序遮罩过渡", Range( 0 , 10)) = 3.166892
		_ProgramMaskRange("程序遮罩范围", Range( 0 , 1.5)) = 0.2667015
		[Header(Blur)]_BlurPower("径向模糊强度", Range( -1 , 2)) = 1
		[KeywordEnum(4Blur,8Blur,12Blur)] _BlurDivission("径向模糊细分", Float) = 0
		[Enum(Material,0,Custom2x,1)]_BlurPowerMode("径向模糊强度模式", Float) = 0
		[Enum(Local,0,Global,1)]_BlurCenterMode("径向模糊原点模式", Float) = 1
		_BlurCenter("径向模糊原点", Vector) = (0.5,0.5,0,0)
		[Header(Chroma)]_ChromaPower("色散强度", Range( 0 , 2)) = 1
		[Enum(Material,0,Custom1w,1)]_ChromaPowerMode("色散强度模式", Float) = 0
		[Header(Screen)][NoScaleOffset]_ScreenTex("屏幕贴图", 2D) = "black" {}
		_ScreenTexUV("屏幕贴图平铺与偏移", Vector) = (1,1,0,0)
		[HDR]_ScreenTexColor("屏幕贴图颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_ScreenTexP("屏幕贴图通道", Float) = 0
		[Enum(Local,0,Polar,1)]_ScreenModel("屏幕贴图UV模式", Float) = 1
		[Enum(Local,0,Global,1)]_ScreenPolarCenterMode("屏幕极坐标原点模式", Float) = 0
		_ScreenPolarSettings("屏幕极坐标原点与偏移", Vector) = (0.5,0.5,1,1)
		_ScreenUSpeed("屏幕贴图U速度", Float) = 0
		_ScreenVSpeed("屏幕贴图V速度", Float) = 0
		_ScreenDissolveTex("屏幕溶解贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_DissolveTexP("溶解贴图通道", Float) = 0
		[IntRange]_ScreenDissolveRotator("屏幕溶解旋转", Range( 0 , 360)) = 0
		[Enum(Material,0,Custom1z,1)]_DissolveMode("溶解控制模式", Float) = 0
		[Enum(Soft,0,Edge,1)]_DissolveEdgeSwitch("溶解边缘模式", Float) = 0
		[HDR]_DissolveEdgeColor("溶解边缘颜色", Color) = (1,0.4109318,0,1)
		_DissolveEdgeWide("溶解边缘宽度", Range( 0 , 1)) = 0.15
		_DissolveSmooth("溶解平滑度", Range( 0 , 1)) = 0
		_DissolvePower("溶解进度", Range( 0 , 2)) = 0.3787051
		_DissolveTexUspeed("溶解U速度", Float) = 0
		_DissolveTexVspeed("溶解V速度", Float) = 0


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull [_CullingMode]
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
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
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA

			

			HLSLPROGRAM

			
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ASE_VERSION 19801
            #define ASE_SRP_VERSION 140011
            #define REQUIRE_OPAQUE_TEXTURE 1


			
            #pragma multi_compile _ DOTS_INSTANCING_ON
		

			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			
            #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
		

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			

			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
		

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_local _FUNCTIONSWITCHER_HEAT _FUNCTIONSWITCHER_BLUR _FUNCTIONSWITCHER_BLACKNWHITE _FUNCTIONSWITCHER_SCREEN _FUNCTIONSWITCHER_CHROMA
			#pragma multi_compile_instancing
			#pragma shader_feature_local _BLURDIVISSION_4BLUR _BLURDIVISSION_8BLUR _BLURDIVISSION_12BLUR


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD2;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD3;
				#endif
				#if defined(LIGHTMAP_ON)
					float4 lightmapUVOrVertexSH : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenPolarSettings;
			float4 _HeatPolarSettings;
			float4 _GlobalPolarCenter;
			float4 _DissolveEdgeColor;
			float4 _FlashColor;
			float4 _ScreenTexUV;
			float4 _MaskTexOffset;
			float4 _ScreenTexColor;
			float2 _BlurCenter;
			float _CullingMode;
			float _ScreenVSpeed;
			float _ScreenPolarCenterMode;
			float _ScreenModel;
			float _ScreenTexP;
			float _DissolveMode;
			float _DissolvePower;
			float _ScreenUSpeed;
			float _DissolveSmooth;
			float _DissolveTexUspeed;
			float _DissolveTexVspeed;
			float _ScreenDissolveRotator;
			float _DissolveTexP;
			float _DissolveEdgeWide;
			float _DissolveEdgeSwitch;
			float _OneMinusMask;
			float _BlackNWhiteSwitch;
			float _RadialMaskMode;
			float _RadialPower;
			float _HeatUSpeed;
			float _HeatVSpeed;
			float _HeatPolarCenterMode;
			float _HeatUVMode;
			float _HeatPower;
			float _HeatPowerMode;
			float _ProgramMaskRange;
			float _ProgramMaskSoft;
			float _BlackNWhite;
			float _MaskTexRotator;
			float _HeatMaskMode;
			float _BlurCenterMode;
			float _BlurPower;
			float _BlurPowerMode;
			float _BlackNWhiteSoft;
			float _RadialUSpeed;
			float _RadialVSpeed;
			float _ChromaPower;
			float _MaskTexP;
			float _ChromaPowerMode;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _HeatTex;
			sampler2D _MaskTex;
			sampler2D _RadialTex;
			sampler2D _ScreenTex;
			sampler2D _ScreenDissolveTex;
			UNITY_INSTANCING_BUFFER_START(SoungPostScreenFX)
				UNITY_DEFINE_INSTANCED_PROP(float4, _HeatTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _ScreenDissolveTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _RadiusMaskP)
			UNITY_INSTANCING_BUFFER_END(SoungPostScreenFX)


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.ase_texcoord6.xy = input.texcoord.xy;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord8 = input.texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
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
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				float3 WorldPosition = input.positionWS;
				float3 WorldViewDirection = GetWorldSpaceNormalizeViewDir( WorldPosition );
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float4 GrabScreen355 = ase_positionSSNorm;
				float2 appendResult391 = (float2(_HeatUSpeed , _HeatVSpeed));
				float4 _HeatTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SoungPostScreenFX,_HeatTex_ST);
				float2 uv_HeatTex = input.ase_texcoord6.xy * _HeatTex_ST_Instance.xy + _HeatTex_ST_Instance.zw;
				float2 appendResult382 = (float2(_HeatPolarSettings.x , _HeatPolarSettings.y));
				float2 appendResult335 = (float2(_GlobalPolarCenter.x , _GlobalPolarCenter.y));
				float2 GlobalCenter360 = appendResult335;
				float2 lerpResult385 = lerp( appendResult382 , GlobalCenter360 , _HeatPolarCenterMode);
				float2 temp_output_34_0_g9 = ( uv_HeatTex - lerpResult385 );
				float2 break39_g9 = temp_output_34_0_g9;
				float2 appendResult50_g9 = (float2(( _HeatPolarSettings.z * ( length( temp_output_34_0_g9 ) * 2.0 ) ) , ( ( atan2( break39_g9.x , break39_g9.y ) * ( 1.0 / TWO_PI ) ) * _HeatPolarSettings.w )));
				float2 lerpResult387 = lerp( uv_HeatTex , appendResult50_g9 , _HeatUVMode);
				float2 panner10 = ( 1.0 * _Time.y * appendResult391 + lerpResult387);
				float4 texCoord408 = input.ase_texcoord7;
				texCoord408.xy = input.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1y409 = texCoord408.y;
				float lerpResult555 = lerp( _HeatPower , custom1y409 , _HeatPowerMode);
				float3 unpack9 = UnpackNormalScale( tex2D( _HeatTex, panner10 ), ( lerpResult555 * 0.1 ) );
				unpack9.z = lerp( 1, unpack9.z, saturate(( lerpResult555 * 0.1 )) );
				float2 texCoord292 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_295_0 = ( ( texCoord292 - GlobalCenter360 ) * 2.0 );
				float2 temp_output_297_0 = ( temp_output_295_0 * temp_output_295_0 );
				float GlobalMask340 = pow( saturate( ( ( (temp_output_297_0).x + (temp_output_297_0).y ) - _ProgramMaskRange ) ) , _ProgramMaskSoft );
				float2 temp_output_358_0 = (GrabScreen355).xy;
				float2 appendResult241 = (float2(_MaskTexOffset.x , _MaskTexOffset.y));
				float2 appendResult242 = (float2(_MaskTexOffset.z , _MaskTexOffset.w));
				float Rotator180405 = 180.0;
				float cos437 = cos( ( ( _MaskTexRotator * PI ) / Rotator180405 ) );
				float sin437 = sin( ( ( _MaskTexRotator * PI ) / Rotator180405 ) );
				float2 rotator437 = mul( (temp_output_358_0*appendResult241 + appendResult242) - float2( 0.5,0.5 ) , float2x2( cos437 , -sin437 , sin437 , cos437 )) + float2( 0.5,0.5 );
				float4 tex2DNode203 = tex2D( _MaskTex, rotator437 );
				float lerpResult307 = lerp( tex2DNode203.r , tex2DNode203.a , _MaskTexP);
				float MaskTex542 = lerpResult307;
				float lerpResult552 = lerp( GlobalMask340 , MaskTex542 , _HeatMaskMode);
				float4 VertColor534 = input.ase_color;
				float4 fetchOpaqueVal47 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( GrabScreen355 + ( unpack9.r * lerpResult552 * VertColor534 ) ).xy.xy ), 1.0 );
				float4 ref252 = fetchOpaqueVal47;
				float2 lerpResult363 = lerp( _BlurCenter , GlobalCenter360 , _BlurCenterMode);
				float4 texCoord400 = input.ase_texcoord8;
				texCoord400.xy = input.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float custom2x401 = texCoord400.x;
				float lerpResult561 = lerp( _BlurPower , custom2x401 , _BlurPowerMode);
				float4 temp_output_55_0 = ( ( GrabScreen355 - float4( lerpResult363, 0.0 , 0.0 ) ) * 0.01 * lerpResult561 );
				float4 temp_output_78_0 = ( GrabScreen355 - temp_output_55_0 );
				float4 fetchOpaqueVal50 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_78_0.xy.xy ), 1.0 );
				float4 BlurUV98 = temp_output_55_0;
				float4 temp_output_77_0 = ( temp_output_78_0 - BlurUV98 );
				float4 fetchOpaqueVal76 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_77_0.xy.xy ), 1.0 );
				float4 temp_output_79_0 = ( temp_output_77_0 - BlurUV98 );
				float4 fetchOpaqueVal80 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_79_0.xy.xy ), 1.0 );
				float4 temp_output_96_0 = ( temp_output_79_0 - BlurUV98 );
				float4 fetchOpaqueVal81 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_96_0.xy.xy ), 1.0 );
				float4 temp_output_110_0 = ( fetchOpaqueVal50 + fetchOpaqueVal76 + fetchOpaqueVal80 + fetchOpaqueVal81 );
				float4 temp_output_97_0 = ( temp_output_96_0 - BlurUV98 );
				float4 fetchOpaqueVal82 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_97_0.xy.xy ), 1.0 );
				float4 temp_output_100_0 = ( temp_output_97_0 - BlurUV98 );
				float4 fetchOpaqueVal83 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_100_0.xy.xy ), 1.0 );
				float4 temp_output_101_0 = ( temp_output_100_0 - BlurUV98 );
				float4 fetchOpaqueVal84 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_101_0.xy.xy ), 1.0 );
				float4 temp_output_102_0 = ( temp_output_101_0 - BlurUV98 );
				float4 fetchOpaqueVal85 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_102_0.xy.xy ), 1.0 );
				float4 temp_output_112_0 = ( temp_output_110_0 + ( fetchOpaqueVal82 + fetchOpaqueVal83 + fetchOpaqueVal84 + fetchOpaqueVal85 ) );
				float4 temp_output_104_0 = ( temp_output_102_0 - BlurUV98 );
				float4 fetchOpaqueVal86 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_104_0.xy.xy ), 1.0 );
				float4 temp_output_105_0 = ( temp_output_104_0 - BlurUV98 );
				float4 fetchOpaqueVal87 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_105_0.xy.xy ), 1.0 );
				float4 temp_output_106_0 = ( temp_output_105_0 - BlurUV98 );
				float4 fetchOpaqueVal88 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_106_0.xy.xy ), 1.0 );
				float4 fetchOpaqueVal90 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( temp_output_106_0 - BlurUV98 ).xy.xy ), 1.0 );
				#if defined( _BLURDIVISSION_4BLUR )
				float4 staticSwitch109 = temp_output_110_0;
				#elif defined( _BLURDIVISSION_8BLUR )
				float4 staticSwitch109 = temp_output_112_0;
				#elif defined( _BLURDIVISSION_12BLUR )
				float4 staticSwitch109 = ( temp_output_112_0 + ( fetchOpaqueVal86 + fetchOpaqueVal87 + fetchOpaqueVal88 + fetchOpaqueVal90 ) );
				#else
				float4 staticSwitch109 = temp_output_110_0;
				#endif
				#if defined( _BLURDIVISSION_4BLUR )
				float staticSwitch116 = 4.0;
				#elif defined( _BLURDIVISSION_8BLUR )
				float staticSwitch116 = 8.0;
				#elif defined( _BLURDIVISSION_12BLUR )
				float staticSwitch116 = 12.0;
				#else
				float staticSwitch116 = 4.0;
				#endif
				float4 appendResult120 = (float4((( staticSwitch109 / staticSwitch116 )).rgb , 1.0));
				float4 blur264 = appendResult120;
				float2 temp_output_333_0 = (ase_positionSSNorm).xy;
				float4 fetchOpaqueVal274 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_333_0.xy ), 1.0 );
				float2 appendResult338 = (float2(_RadialUSpeed , _RadialVSpeed));
				float2 temp_output_34_0_g10 = ( temp_output_333_0 - appendResult335 );
				float2 break39_g10 = temp_output_34_0_g10;
				float2 appendResult50_g10 = (float2(( _GlobalPolarCenter.z * ( length( temp_output_34_0_g10 ) * 2.0 ) ) , ( ( atan2( break39_g10.x , break39_g10.y ) * ( 1.0 / TWO_PI ) ) * _GlobalPolarCenter.w )));
				float2 panner164 = ( 1.0 * _Time.y * appendResult338 + appendResult50_g10);
				float4 tex2DNode161 = tex2D( _RadialTex, panner164 );
				float _RadiusMaskP_Instance = UNITY_ACCESS_INSTANCED_PROP(SoungPostScreenFX,_RadiusMaskP);
				float lerpResult343 = lerp( tex2DNode161.r , tex2DNode161.a , _RadiusMaskP_Instance);
				float lerpResult540 = lerp( GlobalMask340 , MaskTex542 , _RadialMaskMode);
				float lerpResult166 = lerp( fetchOpaqueVal274.r , ( lerpResult343 * lerpResult540 ) , _RadialPower);
				float temp_output_344_0 = ( fetchOpaqueVal274.r + lerpResult166 );
				float custom1x410 = texCoord408.x;
				float lerpResult544 = lerp( _BlackNWhite , custom1x410 , _BlackNWhiteSwitch);
				float lerpResult346 = lerp( temp_output_344_0 , ( 1.0 - temp_output_344_0 ) , lerpResult544);
				float smoothstepResult149 = smoothstep( ( 1.0 - _BlackNWhiteSoft ) , _BlackNWhiteSoft , lerpResult346);
				float4 heibai260 = ( _FlashColor * smoothstepResult149 );
				float2 appendResult375 = (float2(_ScreenUSpeed , _ScreenVSpeed));
				float2 appendResult372 = (float2(_ScreenPolarSettings.x , _ScreenPolarSettings.y));
				float2 lerpResult368 = lerp( appendResult372 , GlobalCenter360 , _ScreenPolarCenterMode);
				float2 temp_output_34_0_g7 = ( temp_output_358_0 - lerpResult368 );
				float2 break39_g7 = temp_output_34_0_g7;
				float2 appendResult50_g7 = (float2(( _ScreenPolarSettings.z * ( length( temp_output_34_0_g7 ) * 2.0 ) ) , ( ( atan2( break39_g7.x , break39_g7.y ) * ( 1.0 / TWO_PI ) ) * _ScreenPolarSettings.w )));
				float2 lerpResult214 = lerp( temp_output_358_0 , appendResult50_g7 , _ScreenModel);
				float2 appendResult221 = (float2(_ScreenTexUV.x , _ScreenTexUV.y));
				float2 appendResult222 = (float2(_ScreenTexUV.z , _ScreenTexUV.w));
				float2 panner198 = ( 1.0 * _Time.y * appendResult375 + (lerpResult214*appendResult221 + appendResult222));
				float4 tex2DNode189 = tex2D( _ScreenTex, panner198 );
				float lerpResult527 = lerp( tex2DNode189.r , tex2DNode189.a , _ScreenTexP);
				float smoothstepResult547 = smoothstep( 1.0 , -1.0 , lerpResult307);
				float lerpResult548 = lerp( lerpResult307 , smoothstepResult547 , _OneMinusMask);
				float custom1z412 = texCoord408.z;
				float lerpResult444 = lerp( _DissolvePower , custom1z412 , _DissolveMode);
				float DissolveValue445 = lerpResult444;
				float2 appendResult473 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
				float4 _ScreenDissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SoungPostScreenFX,_ScreenDissolveTex_ST);
				float2 uv_ScreenDissolveTex = input.ase_texcoord6.xy * _ScreenDissolveTex_ST_Instance.xy + _ScreenDissolveTex_ST_Instance.zw;
				float2 panner476 = ( 1.0 * _Time.y * appendResult473 + uv_ScreenDissolveTex);
				float cos478 = cos( ( ( _ScreenDissolveRotator * PI ) / Rotator180405 ) );
				float sin478 = sin( ( ( _ScreenDissolveRotator * PI ) / Rotator180405 ) );
				float2 rotator478 = mul( panner476 - float2( 0.5,0.5 ) , float2x2( cos478 , -sin478 , sin478 , cos478 )) + float2( 0.5,0.5 );
				float4 tex2DNode482 = tex2D( _ScreenDissolveTex, rotator478 );
				float lerpResult486 = lerp( tex2DNode482.r , tex2DNode482.a , _DissolveTexP);
				float temp_output_496_0 = saturate( ( lerpResult486 / 2.0 ) );
				float smoothstepResult505 = smoothstep( ( DissolveValue445 - _DissolveSmooth ) , DissolveValue445 , temp_output_496_0);
				float4 temp_cast_28 = (smoothstepResult505).xxxx;
				float4 lerpResult508 = lerp( temp_cast_28 , ( smoothstepResult505 + ( _DissolveEdgeColor * ( step( ( DissolveValue445 - _DissolveEdgeWide ) , temp_output_496_0 ) - step( DissolveValue445 , temp_output_496_0 ) ) ) ) , _DissolveEdgeSwitch);
				float3 appendResult514 = (float3(lerpResult508.rgb));
				float3 DissolveColor516 = appendResult514;
				float3 appendResult521 = (float3(( ( lerpResult527 * _ScreenTexColor ) * lerpResult548 * float4( DissolveColor516 , 0.0 ) ).rgb));
				float3 ScreenColor245 = appendResult521;
				float4 AfterBlurUV129 = temp_output_78_0;
				float custom1w420 = texCoord408.w;
				float lerpResult558 = lerp( _ChromaPower , custom1w420 , _ChromaPowerMode);
				float4 temp_output_139_0 = ( BlurUV98 * lerpResult558 );
				float4 temp_output_137_0 = ( AfterBlurUV129 - temp_output_139_0 );
				float4 fetchOpaqueVal125 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_137_0.xy.xy ), 1.0 );
				float4 temp_output_138_0 = ( temp_output_137_0 - temp_output_139_0 );
				float4 fetchOpaqueVal131 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( temp_output_138_0.xy.xy ), 1.0 );
				float4 fetchOpaqueVal132 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( temp_output_138_0 - temp_output_139_0 ).xy.xy ), 1.0 );
				float4 appendResult135 = (float4(fetchOpaqueVal125.r , fetchOpaqueVal131.g , fetchOpaqueVal132.b , GlobalMask340));
				float4 sesan256 = appendResult135;
				#if defined( _FUNCTIONSWITCHER_HEAT )
				float4 staticSwitch239 = ref252;
				#elif defined( _FUNCTIONSWITCHER_BLUR )
				float4 staticSwitch239 = blur264;
				#elif defined( _FUNCTIONSWITCHER_BLACKNWHITE )
				float4 staticSwitch239 = heibai260;
				#elif defined( _FUNCTIONSWITCHER_SCREEN )
				float4 staticSwitch239 = float4( ScreenColor245 , 0.0 );
				#elif defined( _FUNCTIONSWITCHER_CHROMA )
				float4 staticSwitch239 = sesan256;
				#else
				float4 staticSwitch239 = ref252;
				#endif
				
				float VertAlpha535 = input.ase_color.a;
				float DissolveAlpha513 = (lerpResult508).a;
				float ScreenAlpha525 = ( DissolveAlpha513 * lerpResult548 * lerpResult527 * _ScreenTexColor.a );
				#if defined( _FUNCTIONSWITCHER_HEAT )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_BLUR )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_BLACKNWHITE )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_SCREEN )
				float staticSwitch530 = ScreenAlpha525;
				#elif defined( _FUNCTIONSWITCHER_CHROMA )
				float staticSwitch530 = VertAlpha535;
				#else
				float staticSwitch530 = VertAlpha535;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch239.rgb;
				float Alpha = staticSwitch530;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
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
			ColorMask R
			AlphaToMask Off

			HLSLPROGRAM

			
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ASE_VERSION 19801
            #define ASE_SRP_VERSION 140011


			
            #pragma multi_compile _ DOTS_INSTANCING_ON
		

			#pragma vertex vert
			#pragma fragment frag

			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma multi_compile_local _FUNCTIONSWITCHER_HEAT _FUNCTIONSWITCHER_BLUR _FUNCTIONSWITCHER_BLACKNWHITE _FUNCTIONSWITCHER_SCREEN _FUNCTIONSWITCHER_CHROMA
			#pragma multi_compile_instancing


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenPolarSettings;
			float4 _HeatPolarSettings;
			float4 _GlobalPolarCenter;
			float4 _DissolveEdgeColor;
			float4 _FlashColor;
			float4 _ScreenTexUV;
			float4 _MaskTexOffset;
			float4 _ScreenTexColor;
			float2 _BlurCenter;
			float _CullingMode;
			float _ScreenVSpeed;
			float _ScreenPolarCenterMode;
			float _ScreenModel;
			float _ScreenTexP;
			float _DissolveMode;
			float _DissolvePower;
			float _ScreenUSpeed;
			float _DissolveSmooth;
			float _DissolveTexUspeed;
			float _DissolveTexVspeed;
			float _ScreenDissolveRotator;
			float _DissolveTexP;
			float _DissolveEdgeWide;
			float _DissolveEdgeSwitch;
			float _OneMinusMask;
			float _BlackNWhiteSwitch;
			float _RadialMaskMode;
			float _RadialPower;
			float _HeatUSpeed;
			float _HeatVSpeed;
			float _HeatPolarCenterMode;
			float _HeatUVMode;
			float _HeatPower;
			float _HeatPowerMode;
			float _ProgramMaskRange;
			float _ProgramMaskSoft;
			float _BlackNWhite;
			float _MaskTexRotator;
			float _HeatMaskMode;
			float _BlurCenterMode;
			float _BlurPower;
			float _BlurPowerMode;
			float _BlackNWhiteSoft;
			float _RadialUSpeed;
			float _RadialVSpeed;
			float _ChromaPower;
			float _MaskTexP;
			float _ChromaPowerMode;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _ScreenDissolveTex;
			sampler2D _MaskTex;
			sampler2D _ScreenTex;
			UNITY_INSTANCING_BUFFER_START(SoungPostScreenFX)
				UNITY_DEFINE_INSTANCED_PROP(float4, _ScreenDissolveTex_ST)
			UNITY_INSTANCING_BUFFER_END(SoungPostScreenFX)


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.ase_texcoord1;
				output.ase_texcoord4.xy = input.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord = input.ase_texcoord;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
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
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float VertAlpha535 = input.ase_color.a;
				float4 texCoord408 = input.ase_texcoord3;
				texCoord408.xy = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1z412 = texCoord408.z;
				float lerpResult444 = lerp( _DissolvePower , custom1z412 , _DissolveMode);
				float DissolveValue445 = lerpResult444;
				float2 appendResult473 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
				float4 _ScreenDissolveTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SoungPostScreenFX,_ScreenDissolveTex_ST);
				float2 uv_ScreenDissolveTex = input.ase_texcoord4.xy * _ScreenDissolveTex_ST_Instance.xy + _ScreenDissolveTex_ST_Instance.zw;
				float2 panner476 = ( 1.0 * _Time.y * appendResult473 + uv_ScreenDissolveTex);
				float Rotator180405 = 180.0;
				float cos478 = cos( ( ( _ScreenDissolveRotator * PI ) / Rotator180405 ) );
				float sin478 = sin( ( ( _ScreenDissolveRotator * PI ) / Rotator180405 ) );
				float2 rotator478 = mul( panner476 - float2( 0.5,0.5 ) , float2x2( cos478 , -sin478 , sin478 , cos478 )) + float2( 0.5,0.5 );
				float4 tex2DNode482 = tex2D( _ScreenDissolveTex, rotator478 );
				float lerpResult486 = lerp( tex2DNode482.r , tex2DNode482.a , _DissolveTexP);
				float temp_output_496_0 = saturate( ( lerpResult486 / 2.0 ) );
				float smoothstepResult505 = smoothstep( ( DissolveValue445 - _DissolveSmooth ) , DissolveValue445 , temp_output_496_0);
				float4 temp_cast_0 = (smoothstepResult505).xxxx;
				float4 lerpResult508 = lerp( temp_cast_0 , ( smoothstepResult505 + ( _DissolveEdgeColor * ( step( ( DissolveValue445 - _DissolveEdgeWide ) , temp_output_496_0 ) - step( DissolveValue445 , temp_output_496_0 ) ) ) ) , _DissolveEdgeSwitch);
				float DissolveAlpha513 = (lerpResult508).a;
				float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float4 GrabScreen355 = ase_positionSSNorm;
				float2 temp_output_358_0 = (GrabScreen355).xy;
				float2 appendResult241 = (float2(_MaskTexOffset.x , _MaskTexOffset.y));
				float2 appendResult242 = (float2(_MaskTexOffset.z , _MaskTexOffset.w));
				float cos437 = cos( ( ( _MaskTexRotator * PI ) / Rotator180405 ) );
				float sin437 = sin( ( ( _MaskTexRotator * PI ) / Rotator180405 ) );
				float2 rotator437 = mul( (temp_output_358_0*appendResult241 + appendResult242) - float2( 0.5,0.5 ) , float2x2( cos437 , -sin437 , sin437 , cos437 )) + float2( 0.5,0.5 );
				float4 tex2DNode203 = tex2D( _MaskTex, rotator437 );
				float lerpResult307 = lerp( tex2DNode203.r , tex2DNode203.a , _MaskTexP);
				float smoothstepResult547 = smoothstep( 1.0 , -1.0 , lerpResult307);
				float lerpResult548 = lerp( lerpResult307 , smoothstepResult547 , _OneMinusMask);
				float2 appendResult375 = (float2(_ScreenUSpeed , _ScreenVSpeed));
				float2 appendResult372 = (float2(_ScreenPolarSettings.x , _ScreenPolarSettings.y));
				float2 appendResult335 = (float2(_GlobalPolarCenter.x , _GlobalPolarCenter.y));
				float2 GlobalCenter360 = appendResult335;
				float2 lerpResult368 = lerp( appendResult372 , GlobalCenter360 , _ScreenPolarCenterMode);
				float2 temp_output_34_0_g7 = ( temp_output_358_0 - lerpResult368 );
				float2 break39_g7 = temp_output_34_0_g7;
				float2 appendResult50_g7 = (float2(( _ScreenPolarSettings.z * ( length( temp_output_34_0_g7 ) * 2.0 ) ) , ( ( atan2( break39_g7.x , break39_g7.y ) * ( 1.0 / TWO_PI ) ) * _ScreenPolarSettings.w )));
				float2 lerpResult214 = lerp( temp_output_358_0 , appendResult50_g7 , _ScreenModel);
				float2 appendResult221 = (float2(_ScreenTexUV.x , _ScreenTexUV.y));
				float2 appendResult222 = (float2(_ScreenTexUV.z , _ScreenTexUV.w));
				float2 panner198 = ( 1.0 * _Time.y * appendResult375 + (lerpResult214*appendResult221 + appendResult222));
				float4 tex2DNode189 = tex2D( _ScreenTex, panner198 );
				float lerpResult527 = lerp( tex2DNode189.r , tex2DNode189.a , _ScreenTexP);
				float ScreenAlpha525 = ( DissolveAlpha513 * lerpResult548 * lerpResult527 * _ScreenTexColor.a );
				#if defined( _FUNCTIONSWITCHER_HEAT )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_BLUR )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_BLACKNWHITE )
				float staticSwitch530 = VertAlpha535;
				#elif defined( _FUNCTIONSWITCHER_SCREEN )
				float staticSwitch530 = ScreenAlpha525;
				#elif defined( _FUNCTIONSWITCHER_CHROMA )
				float staticSwitch530 = VertAlpha535;
				#else
				float staticSwitch530 = VertAlpha535;
				#endif
				

				float Alpha = staticSwitch530;
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

	
	}
	
	
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;446;-3550.869,-4815.806;Inherit;False;2903.48;893.6592;ScreenDissolve;9;508;516;514;513;509;507;506;449;448;屏幕溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;403;2188.172,-3109.895;Inherit;False;397;287;Comment;6;419;407;405;418;406;404;计算常量;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;448;-3506.972,-4710.81;Inherit;False;785.5632;475.5096;溶解UV;10;517;478;477;476;474;473;472;469;468;467;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;404;2197.172,-3066.895;Inherit;False;Constant;_RotatorDivide;RotatorDivide;67;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;399;2517.615,-3472.126;Inherit;False;952;348;Comment;8;420;410;409;402;401;400;412;408;自定义顶点流;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;467;-3492.107,-4547.75;Inherit;False;Property;_DissolveTexUspeed;溶解U速度;54;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;468;-3492.46,-4472.646;Inherit;False;Property;_DissolveTexVspeed;溶解V速度;55;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;-3498.092,-4392.832;Inherit;False;Property;_ScreenDissolveRotator;屏幕溶解旋转;47;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;2375.172,-3066.895;Inherit;False;Rotator180;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;473;-3352.831,-4529.296;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;472;-3227.488,-4393.322;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;517;-3226.975,-4323.953;Inherit;False;405;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;408;2530.615,-3366.126;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;474;-3322.878,-4655.544;Inherit;False;0;482;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;440;-554.2939,-4225.269;Inherit;False;650;287.0001;Comment;5;445;444;442;443;441;溶解控制模式;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;477;-3045.103,-4394.061;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;476;-3083.283,-4655.919;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;412;2785.615,-3277.126;Inherit;False;custom1z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;449;-2696.534,-4741.244;Inherit;False;1190.247;804.4818;溶解边缘;11;505;501;498;496;518;494;492;481;482;486;450;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;478;-2904.272,-4656.234;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-536.4726,-4174.902;Inherit;False;Property;_DissolvePower;溶解进度;53;0;Create;False;0;0;0;False;0;False;0.3787051;0.084;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;442;-438.4726,-4096.902;Inherit;False;412;custom1z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;443;-426.4189,-4018.556;Inherit;False;Property;_DissolveMode;溶解控制模式;48;1;[Enum];Create;False;0;2;Material;0;Custom1z;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;171;-3539.748,-2860.106;Inherit;False;3002.723;874.6797;黑白闪;35;342;341;541;540;546;545;347;544;346;344;166;345;151;348;350;349;149;260;170;289;543;343;161;337;336;338;164;160;274;333;355;360;352;335;334;黑白闪;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;444;-262.4189,-4169.556;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;482;-2690.217,-4681.176;Inherit;True;Property;_ScreenDissolveTex;屏幕溶解贴图;45;0;Create;False;1;Disslove;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;481;-2587.44,-4486.71;Inherit;False;Property;_DissolveTexP;溶解贴图通道;46;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;202;-3538.92,-3869.567;Inherit;False;3126.59;957.7231;Screen;34;548;549;547;522;525;523;245;521;379;519;192;527;190;528;189;198;375;219;374;373;222;221;214;220;213;196;368;358;371;367;372;357;370;439;屏幕效果;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;450;-2362.494,-4295.683;Inherit;False;843.6348;341.9063;Comment;7;503;504;502;500;499;497;495;溶解亮边;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;-113.4179,-4175.556;Inherit;False;DissolveValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;486;-2399.767,-4606.661;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;492;-2230.729,-4508.495;Inherit;False;Constant;_Disdivide;Disdivide;38;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;334;-3506.516,-2440.817;Inherit;False;Property;_GlobalPolarCenter;全局极坐标原点与偏移;21;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;439;-3510.799,-3313.158;Inherit;False;2008.152;366.3953;MaskTex;9;542;307;306;203;243;242;241;240;433;遮罩贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;494;-2085.284,-4606.389;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;495;-2339.775,-4058.549;Inherit;False;Property;_DissolveEdgeWide;溶解边缘宽度;51;0;Create;False;0;0;0;False;0;False;0.15;0.16;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;335;-3296.516,-2416.817;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;352;-3467.38,-2636.631;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;518;-2504.479,-4377.488;Inherit;False;445;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;433;-2924.431,-3268.266;Inherit;False;774;266;贴图旋转;5;438;437;436;435;434;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;496;-1882.298,-4606.842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;497;-2069.119,-4225.002;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;370;-3518.449,-3694.838;Inherit;False;Property;_ScreenPolarSettings;屏幕极坐标原点与偏移;42;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-3199.911,-2531.734;Inherit;False;GlobalCenter;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-3211.278,-2714.68;Inherit;False;GrabScreen;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;498;-2283.694,-4374.799;Inherit;False;Property;_DissolveSmooth;溶解平滑度;52;0;Create;False;0;0;0;False;0;False;0;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;-2911.431,-3161.266;Inherit;False;Property;_MaskTexRotator;遮罩贴图旋转;26;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;240;-3498.283,-3192.69;Inherit;False;Property;_MaskTexOffset;遮罩贴图平铺与偏移;23;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;499;-1927.216,-4224.221;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;500;-1922.413,-4124.987;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;357;-3390.431,-3776.64;Inherit;False;355;GrabScreen;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;372;-3309.449,-3670.838;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-3294.354,-3547.057;Inherit;False;360;GlobalCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;371;-3321.449,-3461.838;Inherit;False;Property;_ScreenPolarCenterMode;屏幕极坐标原点模式;41;1;[Enum];Create;False;0;2;Local;0;Global;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;501;-2015.02,-4393.281;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;435;-2646.431,-3159.266;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-2637.431,-3085.266;Inherit;False;405;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-3281.716,-3204.839;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;242;-3279.617,-3092.739;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;502;-1798.934,-4224.508;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;503;-2275.023,-4254.138;Inherit;False;Property;_DissolveEdgeColor;溶解边缘颜色;50;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4109318,0,1;0,1.622214,4.924578,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ComponentMaskNode;358;-3196.431,-3776.64;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;368;-3099.449,-3674.838;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;505;-1746.659,-4608.136;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;504;-1660.383,-4250.654;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;434;-2474.431,-3155.266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;243;-3132.529,-3230.504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;196;-2932.813,-3672.332;Inherit;False;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.Vector4Node;220;-2714.9,-3623.738;Inherit;False;Property;_ScreenTexUV;屏幕贴图平铺与偏移;37;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;213;-2900.801,-3525.077;Inherit;False;Property;_ScreenModel;屏幕贴图UV模式;40;1;[Enum];Create;False;0;2;Local;0;Polar;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;506;-1470.441,-4553.478;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;507;-1473.554,-4461.192;Inherit;False;Property;_DissolveEdgeSwitch;溶解边缘模式;49;1;[Enum];Create;False;0;2;Soft;0;Edge;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;437;-2326.007,-3229.646;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;214;-2682.675,-3778.618;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;221;-2498.46,-3642.738;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;-2499.46,-3536.738;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-2339.449,-3645.838;Inherit;False;Property;_ScreenUSpeed;屏幕贴图U速度;43;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;374;-2338.449,-3572.838;Inherit;False;Property;_ScreenVSpeed;屏幕贴图V速度;44;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;508;-1301.456,-4609.525;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2040.794,-3062.681;Inherit;False;Property;_MaskTexP;遮罩贴图通道;24;1;[Enum];Create;False;0;2;R;0;A;1;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;219;-2355.46,-3780.738;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;375;-2165.449,-3623.838;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;203;-2136.682,-3253.289;Inherit;True;Property;_MaskTex;遮罩贴图;22;2;[Header];[NoScaleOffset];Create;False;1;Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ComponentMaskNode;509;-1062.424,-4520.938;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;307;-1859.794,-3155.681;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;198;-2114.36,-3780.535;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;513;-859.9316,-4520.26;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;528;-1731.493,-3611.76;Inherit;False;Property;_ScreenTexP;屏幕贴图通道;39;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;547;-1479.941,-3140.041;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-1453.354,-3017.965;Inherit;False;Property;_OneMinusMask;反相遮罩;25;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;189;-1934.676,-3806.701;Inherit;True;Property;_ScreenTex;屏幕贴图;36;2;[Header];[NoScaleOffset];Create;False;1;Screen;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;190;-1936.163,-3611.617;Inherit;False;Property;_ScreenTexColor;屏幕贴图颜色;38;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;527;-1543.493,-3710.76;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;522;-1036.749,-3378.554;Inherit;False;513;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;548;-1305.013,-3164.538;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;533;2611.179,-3097.161;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;523;-819.2559,-3378.74;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;535;2799.796,-3001.499;Inherit;False;VertAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-375.6342,-3868.199;Inherit;False;2524.213;1057.085;Heat;27;359;395;536;252;8;47;9;380;15;13;10;11;391;390;389;388;387;383;385;386;384;382;381;554;556;557;555;热扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;123;-3573.68,-1885.759;Inherit;False;3388.386;2222.998;Radial Blur;25;264;122;120;121;115;119;116;118;117;109;98;55;58;144;364;56;356;51;362;363;78;365;562;563;561;径向模糊;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;525;-621.1377,-3377.476;Inherit;False;ScreenAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;554;840.0314,-3102.18;Inherit;False;389.5959;267.2759;HeatMask;4;553;552;550;551;热扭曲遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;353;-559.4372,-4803.033;Inherit;False;2027.969;382.841;Radial Used;15;340;303;304;302;301;305;298;300;299;297;295;296;293;292;361;程序遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;365;-2526.673,-1815.35;Inherit;False;1118.671;2115.399;采样12次;30;113;112;110;114;111;99;77;79;96;90;107;106;88;50;105;87;104;86;81;102;85;101;84;100;83;97;82;80;76;129;径向模糊采样;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;143;-484.6483,-2738.183;Inherit;False;1664.468;740.9453;Chroma;16;141;142;256;135;366;132;131;125;139;130;137;138;140;559;560;558;色散;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;421;2191.035,-3281.905;Inherit;False;176;139;Comment;1;425;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;1209.947,-2207.571;Inherit;False;525;ScreenAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;537;1210.593,-2282.046;Inherit;False;535;VertAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;418;2200.276,-2912.701;Inherit;False;Constant;_BaseValue;BaseValue;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;2377.276,-2916.701;Inherit;False;Toggle1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-508.0251,-4567.523;Inherit;False;360;GlobalCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;292;-527.5065,-4697.785;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;293;-281.0388,-4697.476;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-336.0388,-4566.477;Inherit;False;Constant;_CountMaskValue;CountMaskValue;42;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-130.0388,-4697.476;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;297;84.92511,-4706.648;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;299;294.9261,-4750.648;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;300;295.9261,-4661.648;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;298;509.9262,-4725.648;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;434.2299,-4510.33;Inherit;False;Property;_ProgramMaskRange;程序遮罩范围;28;0;Create;False;0;0;0;False;0;False;0.2667015;0.31;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;301;734.9293,-4726.648;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-2719.854,-1764.231;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;363;-3233.959,-1663.301;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;362;-3545.959,-1534.301;Inherit;False;360;GlobalCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-3082.68,-1686.911;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;356;-3273.408,-1764.736;Inherit;False;355;GrabScreen;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-3079.681,-1588.912;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2927.394,-1612.974;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-2233.355,-1080.039;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-2230.234,-910.7453;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2227.83,-736.4217;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-2225.558,-564.8035;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-2228.046,-397.5368;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2222.892,-224.221;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-2224.275,-54.13723;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-2222.811,118.6398;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-2230.83,-1253.17;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-2231.949,-1422.283;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-2228.419,-1599.53;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-2505.032,-861.7238;Inherit;False;98;BlurUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1700.107,-860.9573;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-1690.538,-146.0476;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1714.947,-1546.809;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1527.503,-453.6419;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1531.478,-1230.936;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2484.723,-1568.565;Inherit;False;AfterBlurUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-1283.474,-1421.917;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-1283.13,-1345.973;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;116;-1124.839,-1384.738;Inherit;False;Property;_Keyword0;Keyword 0;30;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Reference;109;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1282.488,-1271.939;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;-903.4496,-1542.544;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;121;-758.9418,-1542.67;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;-541.6993,-1543.073;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-695.4382,-1464.919;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-397.2931,-1543.668;Inherit;False;blur;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;90;-2073.356,119.1418;Inherit;False;Global;_GrabScreen14;Grab Screen 14;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;88;-2073.219,-55.11331;Inherit;False;Global;_GrabScreen12;Grab Screen 12;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;87;-2075.084,-223.6311;Inherit;False;Global;_GrabScreen11;Grab Screen 11;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;86;-2078.47,-396.2315;Inherit;False;Global;_GrabScreen10;Grab Screen 10;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;85;-2078.572,-564.5817;Inherit;False;Global;_GrabScreen9;Grab Screen 9;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;84;-2080.413,-736.7316;Inherit;False;Global;_GrabScreen8;Grab Screen 8;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;83;-2081.267,-911.6403;Inherit;False;Global;_GrabScreen7;Grab Screen 7;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;82;-2086.039,-1080.696;Inherit;False;Global;_GrabScreen6;Grab Screen 6;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;81;-2085.881,-1252.42;Inherit;False;Global;_GrabScreen5;Grab Screen 5;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;80;-2087.949,-1425.283;Inherit;False;Global;_GrabScreen4;Grab Screen 4;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;76;-2085.227,-1598.514;Inherit;False;Global;_GrabScreen3;Grab Screen 3;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;50;-2083.18,-1766.844;Inherit;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;102.0396,-2526.44;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;-32.7216,-2694.335;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-162.6654,-2333.983;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;131;377.4318,-2525.309;Inherit;False;Global;_GrabScreen13;Grab Screen 13;7;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;132;380.2794,-2353.914;Inherit;False;Global;_GrabScreen15;Grab Screen 15;7;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;366;640.6958,-2412.779;Inherit;False;340;GlobalMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;824.3036,-2497.88;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;142;223.9938,-2354.482;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;382;-93.50515,-3810.36;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-95.86111,-3709.187;Inherit;False;360;GlobalCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;385;114.0039,-3809.842;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;383;275.1457,-3754.891;Inherit;False;Polar Coordinates;-1;;9;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.LerpOp;387;511.295,-3554.356;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;388;328.2947,-3506.356;Inherit;False;Property;_HeatUVMode;热扭曲UV模式;5;1;[Enum];Create;False;0;2;Local;0;Polar;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;324.2947,-3422.356;Inherit;False;Property;_HeatUSpeed;热扭曲U速度;8;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;390;325.2947,-3348.356;Inherit;False;Property;_HeatVSpeed;热扭曲V速度;9;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;391;508.295,-3402.356;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-119.5231,-3549.094;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;10;717.0538,-3553.435;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;780.6517,-3293.352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;608.3538,-3219.178;Inherit;False;Constant;_HeatPowerLow;HeatPowerLow;34;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;47;1665.715,-3474.235;Inherit;False;Global;_GrabScreen1;Grab Screen 1;5;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;8;1464.769,-3474.655;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;1926.322,-3474.025;Inherit;False;ref;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;536;1049.022,-3196.334;Inherit;False;534;VertColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;514;-1060.539,-4610.631;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;516;-919.7116,-4610.342;Inherit;False;DissolveColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;302;934.9297,-4726.648;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;303;1115.099,-4700.464;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;340;1260.146,-4698.932;Inherit;False;GlobalMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;542;-1720.171,-3258.031;Inherit;False;MaskTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-1395.333,-3635.979;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;-1421.778,-3538.126;Inherit;False;516;DissolveColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;379;-1156.87,-3636.501;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;521;-1019.05,-3636.019;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-873.1058,-3635.909;Inherit;False;ScreenColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;333;-3085.665,-2636.571;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;274;-2874.244,-2636.138;Inherit;False;Global;_GrabScreen16;Grab Screen 16;38;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;160;-3002.211,-2442.821;Inherit;False;Polar Coordinates;-1;;10;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.PannerNode;164;-2767.986,-2390.887;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;338;-2940.516,-2273.817;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;343;-2294.734,-2366.974;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;-2299.034,-2164.566;Inherit;False;542;MaskTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-1965.722,-2367.454;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-2584.068,-2493.994;Inherit;False;Property;_RadialPower;放射强度;19;0;Create;False;0;0;0;False;0;False;0;0.496;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;149;-1115.486,-2406.978;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-897.2087,-2484.104;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;348;-1301.74,-2407.776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;345;-1696.716,-2722.054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;166;-1951.795,-2609.694;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-1833.061,-2793.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;346;-1266.06,-2795.43;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;544;-1454.981,-2649.223;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-1732.114,-2648.635;Inherit;False;Property;_BlackNWhite;黑白闪切换;14;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;545;-1640.981,-2575.223;Inherit;False;410;custom1x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;546;-1635.981,-2499.223;Inherit;False;Property;_BlackNWhiteSwitch;黑白闪切换方式;13;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;540;-2114.773,-2225.501;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-2296.892,-2241.47;Inherit;False;340;GlobalMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;342;-2489.812,-2217.76;Inherit;False;InstancedProperty;_RadiusMaskP;放射贴图通道;16;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;551;864.8352,-3059.688;Inherit;False;340;GlobalMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;550;866.8793,-2986.612;Inherit;False;542;MaskTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;552;1080.616,-3059.09;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;1314.831,-3365.835;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;359;1282.702,-3473.905;Inherit;False;355;GrabScreen;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;556;237.8893,-3185.689;Inherit;False;409;custom1y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;555;418.8893,-3209.689;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;138.1779,-3265.998;Inherit;False;Property;_HeatPower;热扭曲强度;3;0;Create;False;0;0;0;False;0;False;0.01;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;557;237.8893,-3113.689;Inherit;False;Property;_HeatPowerMode;热扭曲强度模式;4;1;[Enum];Create;False;0;2;Material;0;Custom1y;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;406;2201.276,-2991.701;Inherit;False;Constant;_EmptyValue;EmptyValue;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;425;2213.213,-3227.793;Inherit;False;Property;_CullingMode;剔除模式;1;2;[Header];[Enum];Create;False;1;Setting;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;2375.276,-2990.701;Inherit;False;Toggle0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;534;2798.763,-3097.578;Inherit;False;VertColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;401;3248.705,-3426.672;Inherit;False;custom2x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;3247.705,-3348.672;Inherit;False;custom2y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;400;3001.705,-3363.672;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;409;2783.615,-3353.126;Inherit;False;custom1y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;420;2785.615,-3200.126;Inherit;False;custom1w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;558;-203.3935,-2200.528;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;560;-385.3935,-2121.528;Inherit;False;Property;_ChromaPowerMode;色散强度模式;35;1;[Enum];Create;False;0;2;Material;0;Custom1w;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;563;-3251.215,-1425.729;Inherit;False;401;custom2x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;561;-3065.215,-1449.729;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;562;-3288.215,-1353.729;Inherit;False;Property;_BlurPowerMode;径向模糊强度模式;31;1;[Enum];Create;False;0;2;Material;0;Custom2x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-368.7495,-2363.66;Inherit;False;98;BlurUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;1214.831,-2572.77;Inherit;False;260;heibai;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;1214.481,-2494.157;Inherit;False;245;ScreenColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;1218.2,-2733.23;Inherit;False;252;ref;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;1218.083,-2654.561;Inherit;False;264;blur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-1578.511,-2358.297;Inherit;False;Property;_BlackNWhiteSoft;黑白过渡;12;0;Create;False;0;0;0;False;0;False;0.51;0.218;0.51;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;530;1681.504,-2283.323;Inherit;False;Property;_Keyword2;功能;0;0;Create;False;0;0;0;False;0;False;1;0;0;True;;Toggle;2;ref;radialblur;Reference;239;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;381;-343.7185,-3781.558;Inherit;False;Property;_HeatPolarSettings;热扭曲极坐标原点与偏移;7;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;386;-98.44009,-3632.888;Inherit;False;Property;_HeatPolarCenterMode;热扭曲极坐标原点模式;6;1;[Enum];Create;False;0;2;Local;0;Global;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;541;-2299.654,-2085.466;Inherit;False;Property;_RadialMaskMode;放射线遮罩方式;20;1;[Enum];Create;False;0;2;Program;0;Texture;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;553;865.709,-2912.876;Inherit;False;Property;_HeatMaskMode;热扭曲遮罩模式;10;1;[Enum];Create;False;0;2;Program;0;Texture;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;161;-2588.501,-2414.588;Inherit;True;Property;_RadialTex;放射线贴图;15;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;7bf48800b85943741b2498d093b8ed68;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;364;-3549.959,-1747.301;Inherit;False;Property;_BlurCenterMode;径向模糊原点模式;32;1;[Enum];Create;False;0;2;Local;0;Global;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;144;-3550.276,-1662.803;Inherit;False;Property;_BlurCenter;径向模糊原点;33;0;Create;False;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;349;-1109.783,-2612.462;Inherit;False;Property;_FlashColor;黑白闪颜色;11;2;[HDR];[Header];Create;False;1;BlackNWhite;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;304;830.1993,-4511.136;Inherit;False;Property;_ProgramMaskSoft;程序遮罩过渡;27;1;[Header];Create;False;1;ProgramMask;0;0;False;0;False;3.166892;1.39;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;109;-1345.126,-1544.159;Inherit;False;Property;_BlurDivission;径向模糊细分;30;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;239;1676.602,-2642.766;Inherit;False;Property;_FunctionSwitcher;功能;0;0;Create;False;0;0;0;False;0;False;1;0;0;True;;KeywordEnum;5;Heat;Blur;BlackNWhite;Screen;Chroma;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;946.9955,-3388.61;Inherit;True;Property;_HeatTex;热扭曲贴图;2;1;[Header];Create;False;1;Heat;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;58;-3345.68,-1499.912;Inherit;False;Property;_BlurPower;径向模糊强度;29;1;[Header];Create;False;1;Blur;0;0;False;0;False;1;0.2;-1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-469.3832,-2278.684;Inherit;False;Property;_ChromaPower;色散强度;34;1;[Header];Create;False;1;Chroma;0;0;False;0;False;1;3.72;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;1214.625,-2414.461;Inherit;False;256;sesan;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;559;-387.3935,-2196.528;Inherit;False;420;custom1w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;2784.615,-3427.126;Inherit;False;custom1x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-755.7106,-2483.595;Inherit;False;heibai;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;125;373.4547,-2696.409;Inherit;False;Global;_GrabScreen2;Grab Screen 2;7;0;Create;True;0;0;0;False;0;False;Instance;274;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;966.6593,-2496.146;Inherit;False;sesan;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-229.0204,-2693.382;Inherit;False;129;AfterBlurUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-2735.122,-1546.141;Inherit;False;BlurUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-3086.516,-2291.817;Inherit;False;Property;_RadialUSpeed;放射U速度;17;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-3086.516,-2212.818;Inherit;False;Property;_RadialVSpeed;放射V速度;18;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;323;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;324;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;325;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;326;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;327;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;328;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;329;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;330;5121.638,1378.331;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;321;1483.446,-2063.247;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;322;1979.881,-2473.826;Float;False;True;-1;3;;0;13;Soung/Post/ScreenFX;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;True;True;2;5;False;;10;False;;0;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;1;LightMode=Twist;False;False;0;;0;0;Standard;25;Surface;1;638786581663575459;  Blend;0;0;Two Sided;1;0;Alpha Clipping;0;638786581677440187;  Use Shadow Threshold;0;0;Forward Only;0;0;Cast Shadows;0;638786581681993037;Receive Shadows;0;638786581685379101;GPU Instancing;0;638786581688582283;LOD CrossFade;0;638786581693938962;Built-in Fog;0;638786581691455043;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;False;False;False;False;False;;False;0
WireConnection;405;0;404;0
WireConnection;473;0;467;0
WireConnection;473;1;468;0
WireConnection;472;0;469;0
WireConnection;477;0;472;0
WireConnection;477;1;517;0
WireConnection;476;0;474;0
WireConnection;476;2;473;0
WireConnection;412;0;408;3
WireConnection;478;0;476;0
WireConnection;478;2;477;0
WireConnection;444;0;441;0
WireConnection;444;1;442;0
WireConnection;444;2;443;0
WireConnection;482;1;478;0
WireConnection;445;0;444;0
WireConnection;486;0;482;1
WireConnection;486;1;482;4
WireConnection;486;2;481;0
WireConnection;494;0;486;0
WireConnection;494;1;492;0
WireConnection;335;0;334;1
WireConnection;335;1;334;2
WireConnection;496;0;494;0
WireConnection;497;0;518;0
WireConnection;497;1;495;0
WireConnection;360;0;335;0
WireConnection;355;0;352;0
WireConnection;499;0;497;0
WireConnection;499;1;496;0
WireConnection;500;0;518;0
WireConnection;500;1;496;0
WireConnection;372;0;370;1
WireConnection;372;1;370;2
WireConnection;501;0;518;0
WireConnection;501;1;498;0
WireConnection;435;0;438;0
WireConnection;241;0;240;1
WireConnection;241;1;240;2
WireConnection;242;0;240;3
WireConnection;242;1;240;4
WireConnection;502;0;499;0
WireConnection;502;1;500;0
WireConnection;358;0;357;0
WireConnection;368;0;372;0
WireConnection;368;1;367;0
WireConnection;368;2;371;0
WireConnection;505;0;496;0
WireConnection;505;1;501;0
WireConnection;505;2;518;0
WireConnection;504;0;503;0
WireConnection;504;1;502;0
WireConnection;434;0;435;0
WireConnection;434;1;436;0
WireConnection;243;0;358;0
WireConnection;243;1;241;0
WireConnection;243;2;242;0
WireConnection;196;1;358;0
WireConnection;196;2;368;0
WireConnection;196;3;370;3
WireConnection;196;4;370;4
WireConnection;506;0;505;0
WireConnection;506;1;504;0
WireConnection;437;0;243;0
WireConnection;437;2;434;0
WireConnection;214;0;358;0
WireConnection;214;1;196;0
WireConnection;214;2;213;0
WireConnection;221;0;220;1
WireConnection;221;1;220;2
WireConnection;222;0;220;3
WireConnection;222;1;220;4
WireConnection;508;0;505;0
WireConnection;508;1;506;0
WireConnection;508;2;507;0
WireConnection;219;0;214;0
WireConnection;219;1;221;0
WireConnection;219;2;222;0
WireConnection;375;0;373;0
WireConnection;375;1;374;0
WireConnection;203;1;437;0
WireConnection;509;0;508;0
WireConnection;307;0;203;1
WireConnection;307;1;203;4
WireConnection;307;2;306;0
WireConnection;198;0;219;0
WireConnection;198;2;375;0
WireConnection;513;0;509;0
WireConnection;547;0;307;0
WireConnection;189;1;198;0
WireConnection;527;0;189;1
WireConnection;527;1;189;4
WireConnection;527;2;528;0
WireConnection;548;0;307;0
WireConnection;548;1;547;0
WireConnection;548;2;549;0
WireConnection;523;0;522;0
WireConnection;523;1;548;0
WireConnection;523;2;527;0
WireConnection;523;3;190;4
WireConnection;535;0;533;4
WireConnection;525;0;523;0
WireConnection;419;0;418;0
WireConnection;293;0;292;0
WireConnection;293;1;361;0
WireConnection;295;0;293;0
WireConnection;295;1;296;0
WireConnection;297;0;295;0
WireConnection;297;1;295;0
WireConnection;299;0;297;0
WireConnection;300;0;297;0
WireConnection;298;0;299;0
WireConnection;298;1;300;0
WireConnection;301;0;298;0
WireConnection;301;1;305;0
WireConnection;78;0;356;0
WireConnection;78;1;55;0
WireConnection;363;0;144;0
WireConnection;363;1;362;0
WireConnection;363;2;364;0
WireConnection;51;0;356;0
WireConnection;51;1;363;0
WireConnection;55;0;51;0
WireConnection;55;1;56;0
WireConnection;55;2;561;0
WireConnection;97;0;96;0
WireConnection;97;1;99;0
WireConnection;100;0;97;0
WireConnection;100;1;99;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;102;0;101;0
WireConnection;102;1;99;0
WireConnection;104;0;102;0
WireConnection;104;1;99;0
WireConnection;105;0;104;0
WireConnection;105;1;99;0
WireConnection;106;0;105;0
WireConnection;106;1;99;0
WireConnection;107;0;106;0
WireConnection;107;1;99;0
WireConnection;96;0;79;0
WireConnection;96;1;99;0
WireConnection;79;0;77;0
WireConnection;79;1;99;0
WireConnection;77;0;78;0
WireConnection;77;1;99;0
WireConnection;111;0;82;0
WireConnection;111;1;83;0
WireConnection;111;2;84;0
WireConnection;111;3;85;0
WireConnection;114;0;86;0
WireConnection;114;1;87;0
WireConnection;114;2;88;0
WireConnection;114;3;90;0
WireConnection;110;0;50;0
WireConnection;110;1;76;0
WireConnection;110;2;80;0
WireConnection;110;3;81;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;112;0;110;0
WireConnection;112;1;111;0
WireConnection;129;0;78;0
WireConnection;116;1;117;0
WireConnection;116;0;118;0
WireConnection;116;2;119;0
WireConnection;115;0;109;0
WireConnection;115;1;116;0
WireConnection;121;0;115;0
WireConnection;120;0;121;0
WireConnection;120;3;122;0
WireConnection;264;0;120;0
WireConnection;90;0;107;0
WireConnection;88;0;106;0
WireConnection;87;0;105;0
WireConnection;86;0;104;0
WireConnection;85;0;102;0
WireConnection;84;0;101;0
WireConnection;83;0;100;0
WireConnection;82;0;97;0
WireConnection;81;0;96;0
WireConnection;80;0;79;0
WireConnection;76;0;77;0
WireConnection;50;0;78;0
WireConnection;138;0;137;0
WireConnection;138;1;139;0
WireConnection;137;0;130;0
WireConnection;137;1;139;0
WireConnection;139;0;140;0
WireConnection;139;1;558;0
WireConnection;131;0;138;0
WireConnection;132;0;142;0
WireConnection;135;0;125;1
WireConnection;135;1;131;2
WireConnection;135;2;132;3
WireConnection;135;3;366;0
WireConnection;142;0;138;0
WireConnection;142;1;139;0
WireConnection;382;0;381;1
WireConnection;382;1;381;2
WireConnection;385;0;382;0
WireConnection;385;1;384;0
WireConnection;385;2;386;0
WireConnection;383;1;11;0
WireConnection;383;2;385;0
WireConnection;383;3;381;3
WireConnection;383;4;381;4
WireConnection;387;0;11;0
WireConnection;387;1;383;0
WireConnection;387;2;388;0
WireConnection;391;0;389;0
WireConnection;391;1;390;0
WireConnection;10;0;387;0
WireConnection;10;2;391;0
WireConnection;13;0;555;0
WireConnection;13;1;380;0
WireConnection;47;0;8;0
WireConnection;8;0;359;0
WireConnection;8;1;395;0
WireConnection;252;0;47;0
WireConnection;514;0;508;0
WireConnection;516;0;514;0
WireConnection;302;0;301;0
WireConnection;303;0;302;0
WireConnection;303;1;304;0
WireConnection;340;0;303;0
WireConnection;542;0;307;0
WireConnection;192;0;527;0
WireConnection;192;1;190;0
WireConnection;379;0;192;0
WireConnection;379;1;548;0
WireConnection;379;2;519;0
WireConnection;521;0;379;0
WireConnection;245;0;521;0
WireConnection;333;0;352;0
WireConnection;274;0;333;0
WireConnection;160;1;333;0
WireConnection;160;2;335;0
WireConnection;160;3;334;3
WireConnection;160;4;334;4
WireConnection;164;0;160;0
WireConnection;164;2;338;0
WireConnection;338;0;336;0
WireConnection;338;1;337;0
WireConnection;343;0;161;1
WireConnection;343;1;161;4
WireConnection;343;2;342;0
WireConnection;289;0;343;0
WireConnection;289;1;540;0
WireConnection;149;0;346;0
WireConnection;149;1;348;0
WireConnection;149;2;151;0
WireConnection;350;0;349;0
WireConnection;350;1;149;0
WireConnection;348;0;151;0
WireConnection;345;0;344;0
WireConnection;166;0;274;1
WireConnection;166;1;289;0
WireConnection;166;2;170;0
WireConnection;344;0;274;1
WireConnection;344;1;166;0
WireConnection;346;0;344;0
WireConnection;346;1;345;0
WireConnection;346;2;544;0
WireConnection;544;0;347;0
WireConnection;544;1;545;0
WireConnection;544;2;546;0
WireConnection;540;0;341;0
WireConnection;540;1;543;0
WireConnection;540;2;541;0
WireConnection;552;0;551;0
WireConnection;552;1;550;0
WireConnection;552;2;553;0
WireConnection;395;0;9;1
WireConnection;395;1;552;0
WireConnection;395;2;536;0
WireConnection;555;0;15;0
WireConnection;555;1;556;0
WireConnection;555;2;557;0
WireConnection;407;0;406;0
WireConnection;534;0;533;0
WireConnection;401;0;400;1
WireConnection;402;0;400;2
WireConnection;409;0;408;2
WireConnection;420;0;408;4
WireConnection;558;0;141;0
WireConnection;558;1;559;0
WireConnection;558;2;560;0
WireConnection;561;0;58;0
WireConnection;561;1;563;0
WireConnection;561;2;562;0
WireConnection;530;1;537;0
WireConnection;530;0;537;0
WireConnection;530;2;537;0
WireConnection;530;3;531;0
WireConnection;530;4;537;0
WireConnection;161;1;164;0
WireConnection;109;1;110;0
WireConnection;109;0;112;0
WireConnection;109;2;113;0
WireConnection;239;1;253;0
WireConnection;239;0;265;0
WireConnection;239;2;261;0
WireConnection;239;3;246;0
WireConnection;239;4;257;0
WireConnection;9;1;10;0
WireConnection;9;5;13;0
WireConnection;410;0;408;1
WireConnection;260;0;350;0
WireConnection;125;0;137;0
WireConnection;256;0;135;0
WireConnection;98;0;55;0
WireConnection;322;2;239;0
WireConnection;322;3;530;0
ASEEND*/
//CHKSM=DB023DF6A726C3B72DFB154324307A808784E247