// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VFX/PandaShaderSampleURPV1.1"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(UnityEngine.Rendering.BlendMode)]_Scr("Scr", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		_VTOTex("VTOTex", 2D) = "black" {}
		[Toggle]_VTOTexAR("VTOTexAR", Float) = 1
		[Toggle]_MainTexVMirror("MainTexVMirror", Float) = 0
		[Toggle]_RefactionMaskTexVMirror("RefactionMaskTexVMirror", Float) = 0
		[Toggle]_RefactionTexVMirror("RefactionTexVMirror", Float) = 0
		[Toggle]_DistortTexVMirror("DistortTexVMirror", Float) = 0
		[Toggle]_MaskTexVMirror("MaskTexVMirror", Float) = 0
		[Toggle]_DissolvePlusTexVMirror("DissolvePlusTexVMirror", Float) = 0
		[Toggle]_VTOTexVMirror("VTOTexVMirror", Float) = 0
		[Toggle]_DissolveTexVMirror("DissolveTexVMirror", Float) = 0
		[Toggle]_MainTexVClamp("MainTexVClamp", Float) = 0
		[Toggle]_DissolveTexVClamp("DissolveTexVClamp", Float) = 0
		[Toggle]_MaskTexVClamp("MaskTexVClamp", Float) = 0
		[Toggle]_DissolvePlusTexVClamp("DissolvePlusTexVClamp", Float) = 0
		[Toggle]_VTOTexVClamp("VTOTexVClamp", Float) = 0
		[Toggle]_MainTexUClamp("MainTexUClamp", Float) = 0
		[Toggle]_VTOTexUMirror("VTOTexUMirror", Float) = 0
		[Toggle]_DissolvePlusTexUMirror("DissolvePlusTexUMirror", Float) = 0
		[Toggle]_DissolveTexUMirror("DissolveTexUMirror", Float) = 0
		[Toggle]_MaskTexUMirror("MaskTexUMirror", Float) = 0
		[Toggle]_RefactionTexUMirror("RefactionTexUMirror", Float) = 0
		[Toggle]_RefactionMaskTexUMirror("RefactionMaskTexUMirror", Float) = 0
		[Toggle]_DistortTexUMirror("DistortTexUMirror", Float) = 0
		[Toggle]_MainTexUMirror("MainTexUMirror", Float) = 0
		[Toggle]_MaskTexUClamp("MaskTexUClamp", Float) = 0
		[Toggle]_VTOTexUClamp("VTOTexUClamp", Float) = 0
		[Toggle]_DissolvePlusTexUClamp("DissolvePlusTexUClamp", Float) = 0
		[Toggle]_DissolveTexUClamp("DissolveTexUClamp", Float) = 0
		[Toggle]_MainTexAR("MainTexAR", Float) = 0
		[Toggle]_MainTexUVClip("MainTexUVClip", Float) = 1
		[Toggle]_DissolveTexUVClip("DissolveTexUVClip", Float) = 1
		[Toggle]_DissolvePlusTexUVClip("DissolvePlusTexUVClip", Float) = 1
		[Toggle]_VTOTexUVClip("VTOTexUVClip", Float) = 1
		[Toggle]_MaskTexUVClip("MaskTexUVClip", Float) = 1
		[HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		_VTOTexUSpeed("VTOTexUSpeed", Float) = 0
		_MainTexDesaturate("MainTexDesaturate", Range( 0 , 1)) = 0
		_DissolvePlusTexRotator("DissolvePlusTexRotator", Range( 0 , 1)) = 0
		_VTOTexRotator("VTOTexRotator", Range( 0 , 1)) = 0
		_DissolveTexRotator("DissolveTexRotator", Range( 0 , 1)) = 0
		_MaskTexRotator("MaskTexRotator", Range( 0 , 1)) = 0
		_RefactionFactor("RefactionFactor", Range( 0 , 1)) = 0
		_DistortTexRotator("DistortTexRotator", Range( 0 , 1)) = 0
		_RefactionMaskTexRotator("RefactionMaskTexRotator", Range( 0 , 1)) = 0
		_RefactionTexRotator("RefactionTexRotator", Range( 0 , 1)) = 0
		_MainTexCAFator("MainTexCAFator", Range( 0 , 0.1)) = 0
		_MainTexRotator("MainTexRotator", Range( 0 , 1)) = 0
		_MainTexUSpeed("MainTexUSpeed", Float) = 0
		_MainTexVSpeed("MainTexVSpeed", Float) = 0
		_VTOTexVSpeed("VTOTexVSpeed", Float) = 0
		[Toggle]_CustomMainTexUOffset("CustomMainTexUOffset", Float) = 0
		[Toggle]_CustomMainTexVOffset("CustomMainTexVOffset", Float) = 0
		[Toggle(_FMASKTEX_ON)] _FMaskTex("FMaskTex", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[Toggle]_MaskTexAR("MaskTexAR", Float) = 1
		_MaskTexUSpeed("MaskTexUSpeed", Float) = 0
		_MaskTexVSpeed("MaskTexVSpeed", Float) = 0
		[Toggle(_FDISTORTTEX_ON)] _FDistortTex("FDistortTex", Float) = 0
		_DistortTex("DistortTex", 2D) = "white" {}
		_RefactionTex("RefactionTex", 2D) = "white" {}
		_RefactionMaskTex("RefactionMaskTex", 2D) = "white" {}
		[Toggle]_RefactionMaskTexAR("RefactionMaskTexAR", Float) = 1
		[Toggle]_RefactionTexAR("RefactionTexAR", Float) = 1
		[Toggle]_DistortTexAR("DistortTexAR", Float) = 1
		_DistortFactor("DistortFactor", Range( 0 , 1)) = 0
		_DistortTexUSpeed("DistortTexUSpeed", Float) = 0
		_RefactionMaskTexUSpeed("RefactionMaskTexUSpeed", Float) = 0
		_RefactionTexUSpeed("RefactionTexUSpeed", Float) = 0
		_DistortTexVSpeed("DistortTexVSpeed", Float) = 0
		_RefactionTexVSpeed("RefactionTexVSpeed", Float) = 0
		_RefactionMaskTexVSpeed("RefactionMaskTexVSpeed", Float) = 0
		[Toggle]_DistortMainTex("DistortMainTex", Float) = 0
		[Toggle]_DistortMaskTex("DistortMaskTex", Float) = 0
		[Toggle]_DistortDissolveTex("DistortDissolveTex", Float) = 0
		[Toggle(_FDISSOLVETEX_ON)] _FDissolveTex("FDissolveTex", Float) = 0
		_DissolvePlusTex("DissolvePlusTex", 2D) = "black" {}
		_DissolveTex("DissolveTex", 2D) = "white" {}
		[Toggle]_DissolveTexAR("DissolveTexAR", Float) = 1
		[Toggle]_DissolvePlusTexAR("DissolvePlusTexAR", Float) = 1
		[HDR]_DissolveColor("DissolveColor", Color) = (1,1,1,1)
		[Toggle]_CustomDissolve("CustomDissolve", Float) = 0
		_DissolveFactor("DissolveFactor", Range( 0 , 1)) = 0
		_DissolveSoft("DissolveSoft", Range( 0 , 1)) = 0.1
		_DissolveWide("DissolveWide", Range( 0 , 1)) = 0.05
		_DissolvePlusTexUSpeed("DissolvePlusTexUSpeed", Float) = 0
		_DissolveTexUSpeed("DissolveTexUSpeed", Float) = 0
		_DissolvePlusTexVSpeed("DissolvePlusTexVSpeed", Float) = 0
		_DissolveTexVSpeed("DissolveTexVSpeed", Float) = 0
		_MainAlpha("MainAlpha", Range( 0 , 10)) = 1
		[Toggle(_FFNL_ON)] _FFnl("FFnl", Float) = 0
		[HDR]_FnlColor("FnlColor", Color) = (1,1,1,1)
		_FnlScale("FnlScale", Range( 0 , 2)) = 0
		[Toggle(_FDEPTH_ON)] _FDepth("FDepth", Float) = 0
		_FnlPower("FnlPower", Range( 1 , 10)) = 1
		[Toggle]_ReFnl("ReFnl", Float) = 0
		[Enum(Alpha,0,Add,1)]_BlendMode("BlendMode", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4
		_DepthFade("DepthFade", Range( 0 , 10)) = 1
		[Toggle(_IFVTO_ON)] _IfVTO("IfVTO", Float) = 0
		[Toggle]_CustomVTO("CustomVTO", Float) = 0
		_VTOScale("VTOScale", Float) = 1
		[Toggle(_FDISSOLVEPLUSTEX_ON)] _FDissolvePlusTex("FDissolvePlusTex", Float) = 0
		_DissolvePlusIntensity("DissolvePlusIntensity", Range( 0 , 1)) = 0.5
		[IntRange]_DissolveTexUOffsetC("DissolveTexUOffsetC", Range( 1 , 8)) = 1
		[IntRange]_DissolvePlusTexUOffsetC("DissolvePlusTexUOffsetC", Range( 1 , 8)) = 1
		[IntRange]_DissolveTexVOffsetC("DissolveTexVOffsetC", Range( 1 , 8)) = 1
		[IntRange]_DissolvePlusTexVOffsetC("DissolvePlusTexVOffsetC", Range( 1 , 8)) = 1
		[IntRange]_MaskTexUOffsetC("MaskTexUOffsetC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_MainTexUOffsetC("MainTexUOffsetC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_MainTexVOffsetC("MainTexVOffsetC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_VTOScaleC("VTOScaleC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_DissolveFactorC("DissolveFactorC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_DistortFactorC("DistortFactorC", Range( 1 , 8)) = 1
		[IntRange][Enum(none,0,Custom1x,1,Custom1y,2,Custom1z,3,Custom1w,4,Custom2x,5,Custom2y,6,Custom2z,7,Custom2w,8)]_RefactionFactorC("RefactionFactorC", Range( 1 , 8)) = 1
		[Toggle]_CustomDissolveTexUOffset("CustomDissolveTexUOffset", Float) = 0
		[Toggle]_CustomDissolvePlusTexUOffset("CustomDissolvePlusTexUOffset", Float) = 0
		[Toggle]_CustomMaskTexUOffset("CustomMaskTexUOffset", Float) = 0
		[Toggle]_CustomDissolveTexVOffset("CustomDissolveTexVOffset", Float) = 0
		[Toggle]_CustomDissolvePlusTexVOffset("CustomDissolvePlusTexVOffset", Float) = 0
		[Toggle]_CustomMaskTexVOffset("CustomMaskTexVOffset", Float) = 0
		[IntRange]_MaskTexVOffsetC("MaskTexVOffsetC", Range( 1 , 8)) = 1
		[Toggle]_CustomRefactionFactor("CustomRefactionFactor", Float) = 0
		[Toggle]_CustomDistortFactor("CustomDistortFactor", Float) = 0
		[Toggle]_DistortUIntensity("DistortUIntensity", Float) = 1
		[Toggle]_DistortVIntensity("DistortVIntensity", Float) = 1
		[Toggle]_RefactionRemap("RefactionRemap", Float) = 0
		[Toggle]_DistortRemap("DistortRemap", Float) = 0
		_MainTexRefine("MainTexRefine", Vector) = (1,1,1,0)
		[Toggle]_MainTexDetail("MainTexDetail", Float) = 0
		[Toggle]_RefactionTexDetail("RefactionTexDetail", Float) = 0
		[Toggle]_RefactionMaskTexDetail("RefactionMaskTexDetail", Float) = 0
		[Toggle]_MaskTexDetail("MaskTexDetail", Float) = 0
		[Toggle]_DissolveTexDetail("DissolveTexDetail", Float) = 0
		[Toggle]_DistortTexDetail("DistortTexDetail", Float) = 0
		[Toggle]_DissolvePlusTexDetail("DissolvePlusTexDetail", Float) = 0
		[Toggle(_IFREFACTIONMASK_ON)] _IfRefactionMask("IfRefactionMask", Float) = 0
		[Toggle]_VTOTexDetail("VTOTexDetail", Float) = 0
		[Toggle(_IFREFACTION_ON)] _IfRefaction("IfRefaction", Float) = 0
		[Toggle]_RefactionMaskTexVClamp("RefactionMaskTexVClamp", Float) = 0
		[Toggle]_RefactionMaskTexUClamp("RefactionMaskTexUClamp", Float) = 0
		[Toggle]_RefactionMaskTexUVClip("RefactionMaskTexUVClip", Float) = 0
		_SB("SB", Float) = 0
		[Enum(Off,0,Mask,8,Clip,3)]_SBCompare("SBCompare", Float) = 0
		_AlphaClip("AlphaClip", Range( 0 , 1)) = 0
		[ASEEnd][Enum(RGBA,14,A,0)]_MainRGBA("MainRGBA", Float) = 14


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
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull [_CullMode]
		AlphaToMask Off

		Stencil
		{
			Ref [_SB]
			CompFront [_SBCompare]
			PassFront Replace
			FailFront Keep
			ZFailFront Keep
			CompBack [_SBCompare]
			PassBack Replace
			FailBack Keep
			ZFailBack Keep
		}

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
			Name "Refaction"
			Tags { "LightMode"="PandaPass" "Queue"="Overlay" }

			Blend [_Scr] [_Dst]
			Cull [_CullMode]
			ZWrite Off
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#pragma shader_feature_local _IFREFACTION_ON
			#pragma shader_feature_local _IFREFACTIONMASK_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _PandaGrabTex;
			sampler2D _RefactionTex;
			sampler2D _RefactionMaskTex;


			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float UVClamp21_g149( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g148( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g150( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord4 = v.ase_texcoord;
				o.ase_texcoord5 = v.ase_texcoord1;
				o.ase_texcoord6 = v.ase_texcoord2;

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

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float4 temp_cast_0 = (0.0).xxxx;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float UVClip21_g149 = 1.0;
				float UClamp21_g149 = 0.0;
				float VClamp21_g149 = 0.0;
				float UMirror21_g149 = _RefactionTexUMirror;
				float VMirror21_g149 = _RefactionTexVMirror;
				float2 appendResult4_g149 = (float2(_RefactionTexUSpeed , _RefactionTexVSpeed));
				float2 uv_RefactionTex = IN.ase_texcoord4.xy * _RefactionTex_ST.xy + _RefactionTex_ST.zw;
				float cos38_g149 = cos( ( _RefactionTexRotator * ( 2.0 * PI ) ) );
				float sin38_g149 = sin( ( _RefactionTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g149 = mul( uv_RefactionTex - float2( 0.5,0.5 ) , float2x2( cos38_g149 , -sin38_g149 , sin38_g149 , cos38_g149 )) + float2( 0.5,0.5 );
				float2 panner5_g149 = ( 1.0 * _Time.y * appendResult4_g149 + rotator38_g149);
				float2 break22_g149 = panner5_g149;
				float U21_g149 = break22_g149.x;
				float V21_g149 = break22_g149.y;
				float F21_g149 = 0.0;
				float localUVClamp21_g149 = UVClamp21_g149( UVClip21_g149 , UClamp21_g149 , VClamp21_g149 , UMirror21_g149 , VMirror21_g149 , U21_g149 , V21_g149 , F21_g149 );
				float2 appendResult44_g149 = (float2(U21_g149 , V21_g149));
				float4 tex2DNode7_g149 = tex2D( _RefactionTex, appendResult44_g149 );
				float temp_output_739_20 = ( F21_g149 * ( _RefactionTexAR == 0.0 ? tex2DNode7_g149.a : tex2DNode7_g149.r ) );
				float Num5_g148 = _RefactionFactorC;
				float4 texCoord1_g148 = IN.ase_texcoord4;
				texCoord1_g148.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g148 = texCoord1_g148.z;
				float c1y5_g148 = texCoord1_g148.w;
				float4 texCoord2_g148 = IN.ase_texcoord5;
				texCoord2_g148.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g148 = texCoord2_g148.x;
				float c1w5_g148 = texCoord2_g148.y;
				float c2x5_g148 = texCoord2_g148.z;
				float c2y5_g148 = texCoord2_g148.w;
				float4 texCoord3_g148 = IN.ase_texcoord6;
				texCoord3_g148.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g148 = texCoord3_g148.x;
				float c2w5_g148 = texCoord3_g148.y;
				float F5_g148 = 0.0;
				float localCustomChanelSwitch5_g148 = CustomChanelSwitch5_g148( Num5_g148 , c1x5_g148 , c1y5_g148 , c1z5_g148 , c1w5_g148 , c2x5_g148 , c2y5_g148 , c2z5_g148 , c2w5_g148 , F5_g148 );
				float UVClip21_g150 = _RefactionMaskTexUVClip;
				float UClamp21_g150 = _RefactionMaskTexUClamp;
				float VClamp21_g150 = _RefactionMaskTexVClamp;
				float UMirror21_g150 = _RefactionMaskTexUMirror;
				float VMirror21_g150 = _RefactionMaskTexVMirror;
				float2 appendResult4_g150 = (float2(_RefactionMaskTexUSpeed , _RefactionMaskTexVSpeed));
				float2 uv_RefactionMaskTex = IN.ase_texcoord4.xy * _RefactionMaskTex_ST.xy + _RefactionMaskTex_ST.zw;
				float cos38_g150 = cos( ( _RefactionMaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g150 = sin( ( _RefactionMaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g150 = mul( uv_RefactionMaskTex - float2( 0.5,0.5 ) , float2x2( cos38_g150 , -sin38_g150 , sin38_g150 , cos38_g150 )) + float2( 0.5,0.5 );
				float2 panner5_g150 = ( 1.0 * _Time.y * appendResult4_g150 + rotator38_g150);
				float2 break22_g150 = panner5_g150;
				float U21_g150 = break22_g150.x;
				float V21_g150 = break22_g150.y;
				float F21_g150 = 0.0;
				float localUVClamp21_g150 = UVClamp21_g150( UVClip21_g150 , UClamp21_g150 , VClamp21_g150 , UMirror21_g150 , VMirror21_g150 , U21_g150 , V21_g150 , F21_g150 );
				float2 appendResult44_g150 = (float2(U21_g150 , V21_g150));
				float4 tex2DNode7_g150 = tex2D( _RefactionMaskTex, appendResult44_g150 );
				#ifdef _IFREFACTIONMASK_ON
				float staticSwitch781 = ( F21_g150 * ( _RefactionMaskTexAR == 0.0 ? tex2DNode7_g150.a : tex2DNode7_g150.r ) );
				#else
				float staticSwitch781 = 1.0;
				#endif
				#ifdef _IFREFACTION_ON
				float4 staticSwitch726 = tex2D( _PandaGrabTex, ( ase_grabScreenPosNorm + ( (( _RefactionRemap )?( (-0.5 + (temp_output_739_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_739_20 )) * (( _CustomRefactionFactor )?( ( F5_g148 * 0.2 ) ):( ( _RefactionFactor * 0.2 ) )) * staticSwitch781 ) ).xy );
				#else
				float4 staticSwitch726 = temp_cast_0;
				#endif
				
				#ifdef _IFREFACTION_ON
				float staticSwitch728 = 1.0;
				#else
				float staticSwitch728 = 0.0;
				#endif
				

				float3 Color = staticSwitch726.rgb;
				float Alpha = staticSwitch728;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" "Queue"="Transparent" }

			Blend [_Scr] [_Dst], One OneMinusSrcAlpha
			ZWrite Off
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask [_MainRGBA]

			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch390;

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

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float Scr106 = _Scr;
				float4 break30_g143 = _MainTexRefine;
				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord3.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord3;
				texCoord1_g147.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord4;
				texCoord2_g147.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord5;
				texCoord3_g147.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord3;
				texCoord1_g119.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord4;
				texCoord2_g119.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord5;
				texCoord3_g119.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord3;
				texCoord1_g118.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord4;
				texCoord2_g118.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord5;
				texCoord3_g118.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float temp_output_48_0_g143 = _MainTexCAFator;
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float2 temp_cast_0 = (temp_output_48_0_g143).xx;
				float3 appendResult51_g143 = (float3(tex2D( _MainTex, ( appendResult44_g143 + temp_output_48_0_g143 ) ).r , tex2DNode7_g143.g , tex2D( _MainTex, ( appendResult44_g143 - temp_cast_0 ) ).b));
				float3 desaturateInitialColor27_g143 = appendResult51_g143;
				float desaturateDot27_g143 = dot( desaturateInitialColor27_g143, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar27_g143 = lerp( desaturateInitialColor27_g143, desaturateDot27_g143.xxx, 1.0 );
				float lerpResult34_g143 = lerp( ( break30_g143.x * desaturateVar27_g143.x ) , ( break30_g143.y * pow( desaturateVar27_g143.x , break30_g143.z ) ) , break30_g143.w);
				float3 desaturateInitialColor36_g143 = ( lerpResult34_g143 * ( F21_g143 * appendResult51_g143 ) );
				float desaturateDot36_g143 = dot( desaturateInitialColor36_g143, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar36_g143 = lerp( desaturateInitialColor36_g143, desaturateDot36_g143.xxx, _MainTexDesaturate );
				float4 MainTexColor215 = ( _MainColor * float4( desaturateVar36_g143 , 0.0 ) );
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord3;
				texCoord1_g151.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord4;
				texCoord2_g151.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord5;
				texCoord3_g151.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_272_0 = (-temp_output_277_0 + (( temp_output_275_0 + _DissolveWide ) - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord3;
				texCoord1_g152.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord4;
				texCoord2_g152.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord5;
				texCoord3_g152.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord3;
				texCoord1_g102.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord4;
				texCoord2_g102.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord5;
				texCoord3_g102.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord3.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord3;
				texCoord1_g104.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord4;
				texCoord2_g104.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord5;
				texCoord3_g104.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord3;
				texCoord1_g103.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord4;
				texCoord2_g103.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord5;
				texCoord3_g103.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult264 = smoothstep( temp_output_272_0 , ( temp_output_272_0 + temp_output_277_0 ) , staticSwitch415);
				float Alpha337 = _MainAlpha;
				float4 lerpResult223 = lerp( MainTexColor215 , _DissolveColor , ( _DissolveColor.a * ( 1.0 - smoothstepResult264 ) * Alpha337 ));
				#ifdef _FDISSOLVETEX_ON
				float4 staticSwitch298 = lerpResult223;
				#else
				float4 staticSwitch298 = MainTexColor215;
				#endif
				float4 temp_cast_2 = (0.0).xxxx;
				float Refnl339 = _ReFnl;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float4 FnlMainColor286 = ( _FnlColor * temp_output_283_0 * _FnlColor.a );
				float4 temp_cast_3 = (0.0).xxxx;
				#ifdef _FFNL_ON
				float4 staticSwitch300 = ( Refnl339 == 0.0 ? FnlMainColor286 : temp_cast_3 );
				#else
				float4 staticSwitch300 = temp_cast_2;
				#endif
				float4 MainColor98 = ( IN.ase_color * ( staticSwitch298 + staticSwitch300 ) );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord3;
				texCoord1_g113.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord4;
				texCoord2_g113.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord5;
				texCoord3_g113.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord3;
				texCoord1_g114.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord4;
				texCoord2_g114.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord5;
				texCoord3_g114.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Scr106 == 5.0 ? MainColor98 : ( MainColor98 * MainAlpha97 ) ).rgb;
				float Alpha = MainAlpha97;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
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
			AlphaToMask Off

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_texcoord4 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch390;

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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord2.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord2;
				texCoord1_g147.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord3;
				texCoord2_g147.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord4;
				texCoord3_g147.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord2;
				texCoord1_g119.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord3;
				texCoord2_g119.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord4;
				texCoord3_g119.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord2;
				texCoord1_g118.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord3;
				texCoord2_g118.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord4;
				texCoord3_g118.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord2;
				texCoord1_g113.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord3;
				texCoord2_g113.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord4;
				texCoord3_g113.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord2;
				texCoord1_g114.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord3;
				texCoord2_g114.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord4;
				texCoord3_g114.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float Alpha337 = _MainAlpha;
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord2;
				texCoord1_g151.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord3;
				texCoord2_g151.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord4;
				texCoord3_g151.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord2.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord2;
				texCoord1_g152.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord3;
				texCoord2_g152.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord4;
				texCoord3_g152.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord2;
				texCoord1_g102.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord3;
				texCoord2_g102.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord4;
				texCoord3_g102.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord2.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord2;
				texCoord1_g104.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord3;
				texCoord2_g104.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord4;
				texCoord3_g104.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord2;
				texCoord1_g103.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord3;
				texCoord2_g103.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord4;
				texCoord3_g103.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float Refnl339 = _ReFnl;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				

				float Alpha = MainAlpha97;
				float AlphaClipThreshold = _AlphaClip;

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

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord3.xyz = ase_worldPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch390;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord;
				texCoord1_g147.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord1;
				texCoord2_g147.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord2;
				texCoord3_g147.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord;
				texCoord1_g119.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord1;
				texCoord2_g119.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord2;
				texCoord3_g119.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord;
				texCoord1_g118.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord1;
				texCoord2_g118.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord2;
				texCoord3_g118.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord;
				texCoord1_g113.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord1;
				texCoord2_g113.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord2;
				texCoord3_g113.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord;
				texCoord1_g114.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord1;
				texCoord2_g114.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord2;
				texCoord3_g114.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float Alpha337 = _MainAlpha;
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord;
				texCoord1_g151.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord1;
				texCoord2_g151.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord2;
				texCoord3_g151.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord;
				texCoord1_g152.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord1;
				texCoord2_g152.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord2;
				texCoord3_g152.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord;
				texCoord1_g102.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord1;
				texCoord2_g102.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord2;
				texCoord3_g102.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord;
				texCoord1_g104.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord1;
				texCoord2_g104.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord2;
				texCoord3_g104.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord;
				texCoord1_g103.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord1;
				texCoord2_g103.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord2;
				texCoord3_g103.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float Refnl339 = _ReFnl;
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				

				surfaceDescription.Alpha = MainAlpha97;
				surfaceDescription.AlphaClipThreshold = _AlphaClip;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			float4 _SelectionID;


			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord3.xyz = ase_worldPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch390;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord;
				texCoord1_g147.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord1;
				texCoord2_g147.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord2;
				texCoord3_g147.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord;
				texCoord1_g119.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord1;
				texCoord2_g119.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord2;
				texCoord3_g119.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord;
				texCoord1_g118.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord1;
				texCoord2_g118.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord2;
				texCoord3_g118.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord;
				texCoord1_g113.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord1;
				texCoord2_g113.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord2;
				texCoord3_g113.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord;
				texCoord1_g114.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord1;
				texCoord2_g114.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord2;
				texCoord3_g114.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float Alpha337 = _MainAlpha;
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord;
				texCoord1_g151.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord1;
				texCoord2_g151.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord2;
				texCoord3_g151.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord;
				texCoord1_g152.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord1;
				texCoord2_g152.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord2;
				texCoord3_g152.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord;
				texCoord1_g102.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord1;
				texCoord2_g102.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord2;
				texCoord3_g102.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord;
				texCoord1_g104.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord1;
				texCoord2_g104.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord2;
				texCoord3_g104.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord;
				texCoord1_g103.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord1;
				texCoord2_g103.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord2;
				texCoord3_g103.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float Refnl339 = _ReFnl;
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				

				surfaceDescription.Alpha = MainAlpha97;
				surfaceDescription.AlphaClipThreshold = _AlphaClip;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord4.xyz = ase_worldPos;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch390;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord1.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord1;
				texCoord1_g147.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord2;
				texCoord2_g147.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord3;
				texCoord3_g147.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord1;
				texCoord1_g119.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord2;
				texCoord2_g119.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord3;
				texCoord3_g119.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord1;
				texCoord1_g118.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord2;
				texCoord2_g118.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord3;
				texCoord3_g118.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord1;
				texCoord1_g113.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord2;
				texCoord2_g113.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord3;
				texCoord3_g113.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord1;
				texCoord1_g114.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord2;
				texCoord2_g114.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord3;
				texCoord3_g114.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float Alpha337 = _MainAlpha;
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord1;
				texCoord1_g151.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord2;
				texCoord2_g151.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord3;
				texCoord3_g151.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord1;
				texCoord1_g152.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord2;
				texCoord2_g152.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord3;
				texCoord3_g152.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord1;
				texCoord1_g102.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord2;
				texCoord2_g102.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord3;
				texCoord3_g102.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord1.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord1;
				texCoord1_g104.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord2;
				texCoord2_g104.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord3;
				texCoord3_g104.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord1;
				texCoord1_g103.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord2;
				texCoord2_g103.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord3;
				texCoord3_g103.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float Refnl339 = _ReFnl;
				float3 ase_worldPos = IN.ase_texcoord4.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV279 = dot( IN.normalWS, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				

				surfaceDescription.Alpha = MainAlpha97;
				surfaceDescription.AlphaClipThreshold = _AlphaClip;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _IFVTO_ON
			#pragma shader_feature_local _FDISTORTTEX_ON
			#pragma shader_feature_local _FMASKTEX_ON
			#pragma shader_feature_local _FDISSOLVETEX_ON
			#pragma shader_feature_local _FDISSOLVEPLUSTEX_ON
			#pragma shader_feature_local _FFNL_ON
			#pragma shader_feature_local _FDEPTH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _RefactionTex_ST;
			float4 _MainTexRefine;
			float4 _RefactionMaskTex_ST;
			float4 _VTOTex_ST;
			float4 _DistortTex_ST;
			half4 _MainColor;
			float4 _DissolvePlusTex_ST;
			float4 _MaskTex_ST;
			half4 _DissolveColor;
			half4 _FnlColor;
			float4 _DissolveTex_ST;
			float4 _MainTex_ST;
			half _DissolveTexVMirror;
			half _DissolveTexUSpeed;
			float _CustomDissolveTexUOffset;
			half _DistortDissolveTex;
			float _DissolveTexUOffsetC;
			float _CustomDissolveTexVOffset;
			float _DissolveTexVOffsetC;
			half _DissolveTexVSpeed;
			half _CullMode;
			half _DissolveTexVClamp;
			half _DissolveTexRotator;
			half _DissolveTexUClamp;
			half _DissolveTexUVClip;
			half _DissolveSoft;
			half _DissolveWide;
			float _DissolveFactorC;
			half _DissolveFactor;
			float _CustomDissolve;
			half _MainTexDesaturate;
			float _MainTexCAFator;
			half _MainTexRotator;
			float _MainTexVOffsetC;
			float _CustomMainTexVOffset;
			float _MainTexUOffsetC;
			half _DissolveTexUMirror;
			half _DissolveTexAR;
			half _DissolvePlusTexVClamp;
			half _DissolvePlusTexUClamp;
			half _MaskTexAR;
			half _MaskTexRotator;
			float _MaskTexVOffsetC;
			float _CustomMaskTexVOffset;
			float _MaskTexUOffsetC;
			float _CustomMaskTexUOffset;
			half _DistortMaskTex;
			half _MaskTexVSpeed;
			half _MaskTexUSpeed;
			half _MaskTexVMirror;
			half _MaskTexUMirror;
			half _MaskTexVClamp;
			half _MaskTexUClamp;
			half _MaskTexUVClip;
			half _MainTexAR;
			half _FnlPower;
			half _FnlScale;
			float _CustomMainTexUOffset;
			half _DissolvePlusTexUMirror;
			half _DissolvePlusTexVMirror;
			half _DissolvePlusTexUSpeed;
			half _DissolvePlusTexVSpeed;
			float _CustomDissolvePlusTexUOffset;
			half _DissolvePlusTexUVClip;
			float _DissolvePlusTexUOffsetC;
			float _DissolvePlusTexVOffsetC;
			half _DissolvePlusTexRotator;
			half _DissolvePlusTexAR;
			float _DissolvePlusIntensity;
			float _MainAlpha;
			half _ReFnl;
			float _CustomDissolvePlusTexVOffset;
			float _DistortVIntensity;
			float _CustomDistortFactor;
			float _DistortFactorC;
			half _RefactionMaskTexVMirror;
			half _RefactionMaskTexUMirror;
			float _RefactionMaskTexVClamp;
			float _RefactionMaskTexUClamp;
			float _RefactionMaskTexUVClip;
			float _RefactionFactorC;
			half _RefactionFactor;
			float _CustomRefactionFactor;
			half _RefactionTexAR;
			half _RefactionTexRotator;
			half _RefactionTexVSpeed;
			half _RefactionTexUSpeed;
			half _RefactionTexVMirror;
			half _RefactionTexUMirror;
			float _RefactionRemap;
			float _MainRGBA;
			float _SBCompare;
			float _SB;
			half _ZTest;
			float _RefactionMaskTexDetail;
			float _RefactionTexDetail;
			float _MainTexDetail;
			float _VTOTexDetail;
			float _DissolvePlusTexDetail;
			float _DissolveTexDetail;
			float _DistortTexDetail;
			float _MaskTexDetail;
			half _Dst;
			half _BlendMode;
			half _RefactionMaskTexUSpeed;
			half _RefactionMaskTexVSpeed;
			half _RefactionMaskTexRotator;
			half _RefactionMaskTexAR;
			half _DistortFactor;
			float _DepthFade;
			half _DistortTexAR;
			half _DistortTexRotator;
			half _DistortTexVSpeed;
			half _DistortTexUSpeed;
			half _DistortTexVMirror;
			half _DistortTexUMirror;
			float _DistortRemap;
			half _DistortMainTex;
			half _MainTexVSpeed;
			half _MainTexUSpeed;
			half _MainTexVMirror;
			half _MainTexUMirror;
			float _DistortUIntensity;
			half _MainTexVClamp;
			half _MainTexUVClip;
			half _Scr;
			float _VTOScaleC;
			float _VTOScale;
			float _CustomVTO;
			half _VTOTexAR;
			half _VTOTexRotator;
			half _VTOTexVSpeed;
			half _VTOTexUSpeed;
			half _VTOTexVMirror;
			half _VTOTexUMirror;
			half _VTOTexVClamp;
			half _VTOTexUClamp;
			half _VTOTexUVClip;
			half _MainTexUClamp;
			float _AlphaClip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _VTOTex;
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex;
			sampler2D _DissolvePlusTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			float UVClamp21_g144( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g117( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g146( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g147( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g119( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g118( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g143( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g113( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g114( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g142( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g151( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g152( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g102( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g140( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g104( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float CustomChanelSwitch5_g103( float Num, float c1x, float c1y, float c1z, float c1w, float c2x, float c2y, float c2z, float c2w, out float F )
			{
				 if(Num==0)
				{
				F= 0;
				}
				else if(Num==1)
				{
				F=c1x;
				}
				else if(Num==2)
				{
				F=c1y;
				}
				else if(Num==3)
				{
				F= c1z;
				}
				else if(Num==4)
				{
				F= c1w;
				}
				else if(Num==5)
				{
				F=c2x;
				}
				else if(Num==6)
				{
				F= c2y;
				}
				else if(Num==7)
				{
				F=c2z;
				}
				else if(Num==8)
				{
				F= c2w;
				}
				return 0;
			}
			
			float UVClamp21_g139( float UVClip, float UClamp, float VClamp, float UMirror, float VMirror, inout float U, inout float V, out float F )
			{
				F=1;
				if(UMirror==1)
				{
				U=-U+1;
				}
				if(VMirror==1)
				{
				V=V*(-1)+1;
				}
				if(UClamp==1&&UVClip==1)
				{
				     if(U>1||U<0)
				     {
				      F=0;
				     }
				}
				if(UClamp==1&&UVClip==0)
				{
				     if(U>1)
				     {
				      U=1;
				     }
				     if(U<0)
				     {
				      U=0;
				     }
				}
				if(VClamp==1&&UVClip==1)
				{
				     if(V>1||V<0)
				     {
				      F=0;
				     }
				}
				if(VClamp==1&&UVClip==0)
				{
				     if(V>1)
				     {
				      V=1;
				     }
				     if(V<0)
				     {
				      V=0;
				     }
				}
				return 0;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float UVClip21_g144 = _VTOTexUVClip;
				float UClamp21_g144 = _VTOTexUClamp;
				float VClamp21_g144 = _VTOTexVClamp;
				float UMirror21_g144 = _VTOTexUMirror;
				float VMirror21_g144 = _VTOTexVMirror;
				float2 appendResult4_g144 = (float2(_VTOTexUSpeed , _VTOTexVSpeed));
				float2 uv_VTOTex = v.ase_texcoord * _VTOTex_ST.xy + _VTOTex_ST.zw;
				float cos38_g144 = cos( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float sin38_g144 = sin( ( _VTOTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g144 = mul( uv_VTOTex - float2( 0.5,0.5 ) , float2x2( cos38_g144 , -sin38_g144 , sin38_g144 , cos38_g144 )) + float2( 0.5,0.5 );
				float2 panner5_g144 = ( 1.0 * _Time.y * appendResult4_g144 + rotator38_g144);
				float2 break22_g144 = panner5_g144;
				float U21_g144 = break22_g144.x;
				float V21_g144 = break22_g144.y;
				float F21_g144 = 0.0;
				float localUVClamp21_g144 = UVClamp21_g144( UVClip21_g144 , UClamp21_g144 , VClamp21_g144 , UMirror21_g144 , VMirror21_g144 , U21_g144 , V21_g144 , F21_g144 );
				float2 appendResult44_g144 = (float2(U21_g144 , V21_g144));
				float4 tex2DNode7_g144 = tex2Dlod( _VTOTex, float4( appendResult44_g144, 0, 0.0) );
				float Num5_g117 = _VTOScaleC;
				float4 texCoord1_g117 = v.ase_texcoord;
				texCoord1_g117.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g117 = texCoord1_g117.z;
				float c1y5_g117 = texCoord1_g117.w;
				float4 texCoord2_g117 = v.ase_texcoord1;
				texCoord2_g117.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g117 = texCoord2_g117.x;
				float c1w5_g117 = texCoord2_g117.y;
				float c2x5_g117 = texCoord2_g117.z;
				float c2y5_g117 = texCoord2_g117.w;
				float4 texCoord3_g117 = v.ase_texcoord2;
				texCoord3_g117.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g117 = texCoord3_g117.x;
				float c2w5_g117 = texCoord3_g117.y;
				float F5_g117 = 0.0;
				float localCustomChanelSwitch5_g117 = CustomChanelSwitch5_g117( Num5_g117 , c1x5_g117 , c1y5_g117 , c1z5_g117 , c1w5_g117 , c2x5_g117 , c2y5_g117 , c2z5_g117 , c2w5_g117 , F5_g117 );
				float3 VTO387 = ( v.ase_normal * ( F21_g144 * ( _VTOTexAR == 0.0 ? tex2DNode7_g144.a : tex2DNode7_g144.r ) ) * (( _CustomVTO )?( F5_g117 ):( _VTOScale )) );
				#ifdef _IFVTO_ON
				float3 staticSwitch390 = VTO387;
				#else
				float3 staticSwitch390 = temp_cast_0;
				#endif
				
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord4.xyz = ase_worldPos;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch390;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float UVClip21_g143 = _MainTexUVClip;
				float UClamp21_g143 = _MainTexUClamp;
				float VClamp21_g143 = _MainTexVClamp;
				float UMirror21_g143 = _MainTexUMirror;
				float VMirror21_g143 = _MainTexVMirror;
				float2 appendResult4_g143 = (float2(_MainTexUSpeed , _MainTexVSpeed));
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_3_0_g145 = uv_MainTex;
				float UVClip21_g146 = 1.0;
				float UClamp21_g146 = 0.0;
				float VClamp21_g146 = 0.0;
				float UMirror21_g146 = _DistortTexUMirror;
				float VMirror21_g146 = _DistortTexVMirror;
				float2 appendResult4_g146 = (float2(_DistortTexUSpeed , _DistortTexVSpeed));
				float2 uv_DistortTex = IN.ase_texcoord1.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float cos38_g146 = cos( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float sin38_g146 = sin( ( _DistortTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g146 = mul( uv_DistortTex - float2( 0.5,0.5 ) , float2x2( cos38_g146 , -sin38_g146 , sin38_g146 , cos38_g146 )) + float2( 0.5,0.5 );
				float2 panner5_g146 = ( 1.0 * _Time.y * appendResult4_g146 + rotator38_g146);
				float2 break22_g146 = panner5_g146;
				float U21_g146 = break22_g146.x;
				float V21_g146 = break22_g146.y;
				float F21_g146 = 0.0;
				float localUVClamp21_g146 = UVClamp21_g146( UVClip21_g146 , UClamp21_g146 , VClamp21_g146 , UMirror21_g146 , VMirror21_g146 , U21_g146 , V21_g146 , F21_g146 );
				float2 appendResult44_g146 = (float2(U21_g146 , V21_g146));
				float4 tex2DNode7_g146 = tex2D( _DistortTex, appendResult44_g146 );
				float temp_output_675_20 = ( F21_g146 * ( _DistortTexAR == 0.0 ? tex2DNode7_g146.a : tex2DNode7_g146.r ) );
				float Num5_g147 = _DistortFactorC;
				float4 texCoord1_g147 = IN.ase_texcoord1;
				texCoord1_g147.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g147 = texCoord1_g147.z;
				float c1y5_g147 = texCoord1_g147.w;
				float4 texCoord2_g147 = IN.ase_texcoord2;
				texCoord2_g147.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g147 = texCoord2_g147.x;
				float c1w5_g147 = texCoord2_g147.y;
				float c2x5_g147 = texCoord2_g147.z;
				float c2y5_g147 = texCoord2_g147.w;
				float4 texCoord3_g147 = IN.ase_texcoord3;
				texCoord3_g147.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g147 = texCoord3_g147.x;
				float c2w5_g147 = texCoord3_g147.y;
				float F5_g147 = 0.0;
				float localCustomChanelSwitch5_g147 = CustomChanelSwitch5_g147( Num5_g147 , c1x5_g147 , c1y5_g147 , c1z5_g147 , c1w5_g147 , c2x5_g147 , c2y5_g147 , c2z5_g147 , c2w5_g147 , F5_g147 );
				float2 appendResult465 = (float2(_DistortUIntensity , _DistortVIntensity));
				float2 Distort148 = ( (( _DistortRemap )?( (-0.5 + (temp_output_675_20 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ):( temp_output_675_20 )) * (( _CustomDistortFactor )?( F5_g147 ):( _DistortFactor )) * appendResult465 );
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch316 = ( _DistortMainTex == 0.0 ? temp_output_3_0_g145 : ( temp_output_3_0_g145 + Distort148 ) );
				#else
				float2 staticSwitch316 = uv_MainTex;
				#endif
				float Num5_g119 = _MainTexUOffsetC;
				float4 texCoord1_g119 = IN.ase_texcoord1;
				texCoord1_g119.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g119 = texCoord1_g119.z;
				float c1y5_g119 = texCoord1_g119.w;
				float4 texCoord2_g119 = IN.ase_texcoord2;
				texCoord2_g119.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g119 = texCoord2_g119.x;
				float c1w5_g119 = texCoord2_g119.y;
				float c2x5_g119 = texCoord2_g119.z;
				float c2y5_g119 = texCoord2_g119.w;
				float4 texCoord3_g119 = IN.ase_texcoord3;
				texCoord3_g119.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g119 = texCoord3_g119.x;
				float c2w5_g119 = texCoord3_g119.y;
				float F5_g119 = 0.0;
				float localCustomChanelSwitch5_g119 = CustomChanelSwitch5_g119( Num5_g119 , c1x5_g119 , c1y5_g119 , c1z5_g119 , c1w5_g119 , c2x5_g119 , c2y5_g119 , c2z5_g119 , c2w5_g119 , F5_g119 );
				float Num5_g118 = _MainTexVOffsetC;
				float4 texCoord1_g118 = IN.ase_texcoord1;
				texCoord1_g118.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g118 = texCoord1_g118.z;
				float c1y5_g118 = texCoord1_g118.w;
				float4 texCoord2_g118 = IN.ase_texcoord2;
				texCoord2_g118.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g118 = texCoord2_g118.x;
				float c1w5_g118 = texCoord2_g118.y;
				float c2x5_g118 = texCoord2_g118.z;
				float c2y5_g118 = texCoord2_g118.w;
				float4 texCoord3_g118 = IN.ase_texcoord3;
				texCoord3_g118.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g118 = texCoord3_g118.x;
				float c2w5_g118 = texCoord3_g118.y;
				float F5_g118 = 0.0;
				float localCustomChanelSwitch5_g118 = CustomChanelSwitch5_g118( Num5_g118 , c1x5_g118 , c1y5_g118 , c1z5_g118 , c1w5_g118 , c2x5_g118 , c2y5_g118 , c2z5_g118 , c2w5_g118 , F5_g118 );
				float2 appendResult330 = (float2((( _CustomMainTexUOffset )?( F5_g119 ):( 0.0 )) , (( _CustomMainTexVOffset )?( F5_g118 ):( 0.0 ))));
				float cos38_g143 = cos( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float sin38_g143 = sin( ( _MainTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g143 = mul( ( staticSwitch316 + appendResult330 ) - float2( 0.5,0.5 ) , float2x2( cos38_g143 , -sin38_g143 , sin38_g143 , cos38_g143 )) + float2( 0.5,0.5 );
				float2 panner5_g143 = ( 1.0 * _Time.y * appendResult4_g143 + rotator38_g143);
				float2 break22_g143 = panner5_g143;
				float U21_g143 = break22_g143.x;
				float V21_g143 = break22_g143.y;
				float F21_g143 = 0.0;
				float localUVClamp21_g143 = UVClamp21_g143( UVClip21_g143 , UClamp21_g143 , VClamp21_g143 , UMirror21_g143 , VMirror21_g143 , U21_g143 , V21_g143 , F21_g143 );
				float2 appendResult44_g143 = (float2(U21_g143 , V21_g143));
				float4 tex2DNode7_g143 = tex2D( _MainTex, appendResult44_g143 );
				float MainTexAlpha138 = ( _MainColor.a * ( F21_g143 * ( _MainTexAR == 0.0 ? tex2DNode7_g143.a : tex2DNode7_g143.r ) ) );
				float UVClip21_g142 = _MaskTexUVClip;
				float UClamp21_g142 = _MaskTexUClamp;
				float VClamp21_g142 = _MaskTexVClamp;
				float UMirror21_g142 = _MaskTexUMirror;
				float VMirror21_g142 = _MaskTexVMirror;
				float2 appendResult4_g142 = (float2(_MaskTexUSpeed , _MaskTexVSpeed));
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 temp_output_3_0_g115 = uv_MaskTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch312 = ( _DistortMaskTex == 0.0 ? temp_output_3_0_g115 : ( temp_output_3_0_g115 + Distort148 ) );
				#else
				float2 staticSwitch312 = uv_MaskTex;
				#endif
				float Num5_g113 = _MaskTexUOffsetC;
				float4 texCoord1_g113 = IN.ase_texcoord1;
				texCoord1_g113.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g113 = texCoord1_g113.z;
				float c1y5_g113 = texCoord1_g113.w;
				float4 texCoord2_g113 = IN.ase_texcoord2;
				texCoord2_g113.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g113 = texCoord2_g113.x;
				float c1w5_g113 = texCoord2_g113.y;
				float c2x5_g113 = texCoord2_g113.z;
				float c2y5_g113 = texCoord2_g113.w;
				float4 texCoord3_g113 = IN.ase_texcoord3;
				texCoord3_g113.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g113 = texCoord3_g113.x;
				float c2w5_g113 = texCoord3_g113.y;
				float F5_g113 = 0.0;
				float localCustomChanelSwitch5_g113 = CustomChanelSwitch5_g113( Num5_g113 , c1x5_g113 , c1y5_g113 , c1z5_g113 , c1w5_g113 , c2x5_g113 , c2y5_g113 , c2z5_g113 , c2w5_g113 , F5_g113 );
				float Num5_g114 = _MaskTexVOffsetC;
				float4 texCoord1_g114 = IN.ase_texcoord1;
				texCoord1_g114.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g114 = texCoord1_g114.z;
				float c1y5_g114 = texCoord1_g114.w;
				float4 texCoord2_g114 = IN.ase_texcoord2;
				texCoord2_g114.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g114 = texCoord2_g114.x;
				float c1w5_g114 = texCoord2_g114.y;
				float c2x5_g114 = texCoord2_g114.z;
				float c2y5_g114 = texCoord2_g114.w;
				float4 texCoord3_g114 = IN.ase_texcoord3;
				texCoord3_g114.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g114 = texCoord3_g114.x;
				float c2w5_g114 = texCoord3_g114.y;
				float F5_g114 = 0.0;
				float localCustomChanelSwitch5_g114 = CustomChanelSwitch5_g114( Num5_g114 , c1x5_g114 , c1y5_g114 , c1z5_g114 , c1w5_g114 , c2x5_g114 , c2y5_g114 , c2z5_g114 , c2w5_g114 , F5_g114 );
				float2 appendResult446 = (float2((( _CustomMaskTexUOffset )?( F5_g113 ):( 0.0 )) , (( _CustomMaskTexVOffset )?( F5_g114 ):( 0.0 ))));
				float cos38_g142 = cos( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float sin38_g142 = sin( ( _MaskTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g142 = mul( ( staticSwitch312 + appendResult446 ) - float2( 0.5,0.5 ) , float2x2( cos38_g142 , -sin38_g142 , sin38_g142 , cos38_g142 )) + float2( 0.5,0.5 );
				float2 panner5_g142 = ( 1.0 * _Time.y * appendResult4_g142 + rotator38_g142);
				float2 break22_g142 = panner5_g142;
				float U21_g142 = break22_g142.x;
				float V21_g142 = break22_g142.y;
				float F21_g142 = 0.0;
				float localUVClamp21_g142 = UVClamp21_g142( UVClip21_g142 , UClamp21_g142 , VClamp21_g142 , UMirror21_g142 , VMirror21_g142 , U21_g142 , V21_g142 , F21_g142 );
				float2 appendResult44_g142 = (float2(U21_g142 , V21_g142));
				float4 tex2DNode7_g142 = tex2D( _MaskTex, appendResult44_g142 );
				#ifdef _FMASKTEX_ON
				float staticSwitch291 = ( F21_g142 * ( _MaskTexAR == 0.0 ? tex2DNode7_g142.a : tex2DNode7_g142.r ) );
				#else
				float staticSwitch291 = 1.0;
				#endif
				float Alpha337 = _MainAlpha;
				float Num5_g151 = _DissolveFactorC;
				float4 texCoord1_g151 = IN.ase_texcoord1;
				texCoord1_g151.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g151 = texCoord1_g151.z;
				float c1y5_g151 = texCoord1_g151.w;
				float4 texCoord2_g151 = IN.ase_texcoord2;
				texCoord2_g151.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g151 = texCoord2_g151.x;
				float c1w5_g151 = texCoord2_g151.y;
				float c2x5_g151 = texCoord2_g151.z;
				float c2y5_g151 = texCoord2_g151.w;
				float4 texCoord3_g151 = IN.ase_texcoord3;
				texCoord3_g151.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g151 = texCoord3_g151.x;
				float c2w5_g151 = texCoord3_g151.y;
				float F5_g151 = 0.0;
				float localCustomChanelSwitch5_g151 = CustomChanelSwitch5_g151( Num5_g151 , c1x5_g151 , c1y5_g151 , c1z5_g151 , c1w5_g151 , c2x5_g151 , c2y5_g151 , c2z5_g151 , c2w5_g151 , F5_g151 );
				float temp_output_275_0 = (-_DissolveWide + ((( _CustomDissolve )?( F5_g151 ):( _DissolveFactor )) - 0.0) * (1.0 - -_DissolveWide) / (1.0 - 0.0));
				float temp_output_277_0 = ( _DissolveSoft + 0.0001 );
				float temp_output_270_0 = (-temp_output_277_0 + (temp_output_275_0 - 0.0) * (1.0 - -temp_output_277_0) / (1.0 - 0.0));
				float UVClip21_g140 = _DissolveTexUVClip;
				float UClamp21_g140 = _DissolveTexUClamp;
				float VClamp21_g140 = _DissolveTexVClamp;
				float UMirror21_g140 = _DissolveTexUMirror;
				float VMirror21_g140 = _DissolveTexVMirror;
				float2 appendResult4_g140 = (float2(_DissolveTexUSpeed , _DissolveTexVSpeed));
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 temp_output_3_0_g106 = uv_DissolveTex;
				#ifdef _FDISTORTTEX_ON
				float2 staticSwitch314 = ( _DistortDissolveTex == 0.0 ? temp_output_3_0_g106 : ( temp_output_3_0_g106 + Distort148 ) );
				#else
				float2 staticSwitch314 = uv_DissolveTex;
				#endif
				float Num5_g152 = _DissolveTexUOffsetC;
				float4 texCoord1_g152 = IN.ase_texcoord1;
				texCoord1_g152.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g152 = texCoord1_g152.z;
				float c1y5_g152 = texCoord1_g152.w;
				float4 texCoord2_g152 = IN.ase_texcoord2;
				texCoord2_g152.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g152 = texCoord2_g152.x;
				float c1w5_g152 = texCoord2_g152.y;
				float c2x5_g152 = texCoord2_g152.z;
				float c2y5_g152 = texCoord2_g152.w;
				float4 texCoord3_g152 = IN.ase_texcoord3;
				texCoord3_g152.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g152 = texCoord3_g152.x;
				float c2w5_g152 = texCoord3_g152.y;
				float F5_g152 = 0.0;
				float localCustomChanelSwitch5_g152 = CustomChanelSwitch5_g152( Num5_g152 , c1x5_g152 , c1y5_g152 , c1z5_g152 , c1w5_g152 , c2x5_g152 , c2y5_g152 , c2z5_g152 , c2w5_g152 , F5_g152 );
				float Num5_g102 = _DissolveTexVOffsetC;
				float4 texCoord1_g102 = IN.ase_texcoord1;
				texCoord1_g102.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g102 = texCoord1_g102.z;
				float c1y5_g102 = texCoord1_g102.w;
				float4 texCoord2_g102 = IN.ase_texcoord2;
				texCoord2_g102.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g102 = texCoord2_g102.x;
				float c1w5_g102 = texCoord2_g102.y;
				float c2x5_g102 = texCoord2_g102.z;
				float c2y5_g102 = texCoord2_g102.w;
				float4 texCoord3_g102 = IN.ase_texcoord3;
				texCoord3_g102.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g102 = texCoord3_g102.x;
				float c2w5_g102 = texCoord3_g102.y;
				float F5_g102 = 0.0;
				float localCustomChanelSwitch5_g102 = CustomChanelSwitch5_g102( Num5_g102 , c1x5_g102 , c1y5_g102 , c1z5_g102 , c1w5_g102 , c2x5_g102 , c2y5_g102 , c2z5_g102 , c2w5_g102 , F5_g102 );
				float2 appendResult479 = (float2((( _CustomDissolveTexUOffset )?( F5_g152 ):( 0.0 )) , (( _CustomDissolveTexVOffset )?( F5_g102 ):( 0.0 ))));
				float cos38_g140 = cos( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float sin38_g140 = sin( ( _DissolveTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g140 = mul( ( staticSwitch314 + appendResult479 ) - float2( 0.5,0.5 ) , float2x2( cos38_g140 , -sin38_g140 , sin38_g140 , cos38_g140 )) + float2( 0.5,0.5 );
				float2 panner5_g140 = ( 1.0 * _Time.y * appendResult4_g140 + rotator38_g140);
				float2 break22_g140 = panner5_g140;
				float U21_g140 = break22_g140.x;
				float V21_g140 = break22_g140.y;
				float F21_g140 = 0.0;
				float localUVClamp21_g140 = UVClamp21_g140( UVClip21_g140 , UClamp21_g140 , VClamp21_g140 , UMirror21_g140 , VMirror21_g140 , U21_g140 , V21_g140 , F21_g140 );
				float2 appendResult44_g140 = (float2(U21_g140 , V21_g140));
				float4 tex2DNode7_g140 = tex2D( _DissolveTex, appendResult44_g140 );
				float temp_output_677_20 = ( F21_g140 * ( _DissolveTexAR == 0.0 ? tex2DNode7_g140.a : tex2DNode7_g140.r ) );
				float UVClip21_g139 = _DissolvePlusTexUVClip;
				float UClamp21_g139 = _DissolvePlusTexUClamp;
				float VClamp21_g139 = _DissolvePlusTexVClamp;
				float UMirror21_g139 = _DissolvePlusTexUMirror;
				float VMirror21_g139 = _DissolvePlusTexVMirror;
				float2 appendResult4_g139 = (float2(_DissolvePlusTexUSpeed , _DissolvePlusTexVSpeed));
				float2 uv_DissolvePlusTex = IN.ase_texcoord1.xy * _DissolvePlusTex_ST.xy + _DissolvePlusTex_ST.zw;
				float Num5_g104 = _DissolvePlusTexUOffsetC;
				float4 texCoord1_g104 = IN.ase_texcoord1;
				texCoord1_g104.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g104 = texCoord1_g104.z;
				float c1y5_g104 = texCoord1_g104.w;
				float4 texCoord2_g104 = IN.ase_texcoord2;
				texCoord2_g104.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g104 = texCoord2_g104.x;
				float c1w5_g104 = texCoord2_g104.y;
				float c2x5_g104 = texCoord2_g104.z;
				float c2y5_g104 = texCoord2_g104.w;
				float4 texCoord3_g104 = IN.ase_texcoord3;
				texCoord3_g104.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g104 = texCoord3_g104.x;
				float c2w5_g104 = texCoord3_g104.y;
				float F5_g104 = 0.0;
				float localCustomChanelSwitch5_g104 = CustomChanelSwitch5_g104( Num5_g104 , c1x5_g104 , c1y5_g104 , c1z5_g104 , c1w5_g104 , c2x5_g104 , c2y5_g104 , c2z5_g104 , c2w5_g104 , F5_g104 );
				float Num5_g103 = _DissolvePlusTexVOffsetC;
				float4 texCoord1_g103 = IN.ase_texcoord1;
				texCoord1_g103.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float c1x5_g103 = texCoord1_g103.z;
				float c1y5_g103 = texCoord1_g103.w;
				float4 texCoord2_g103 = IN.ase_texcoord2;
				texCoord2_g103.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float c1z5_g103 = texCoord2_g103.x;
				float c1w5_g103 = texCoord2_g103.y;
				float c2x5_g103 = texCoord2_g103.z;
				float c2y5_g103 = texCoord2_g103.w;
				float4 texCoord3_g103 = IN.ase_texcoord3;
				texCoord3_g103.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float c2z5_g103 = texCoord3_g103.x;
				float c2w5_g103 = texCoord3_g103.y;
				float F5_g103 = 0.0;
				float localCustomChanelSwitch5_g103 = CustomChanelSwitch5_g103( Num5_g103 , c1x5_g103 , c1y5_g103 , c1z5_g103 , c1w5_g103 , c2x5_g103 , c2y5_g103 , c2z5_g103 , c2w5_g103 , F5_g103 );
				float2 appendResult497 = (float2((( _CustomDissolvePlusTexUOffset )?( F5_g104 ):( 0.0 )) , (( _CustomDissolvePlusTexVOffset )?( F5_g103 ):( 0.0 ))));
				float cos38_g139 = cos( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float sin38_g139 = sin( ( _DissolvePlusTexRotator * ( 2.0 * PI ) ) );
				float2 rotator38_g139 = mul( ( uv_DissolvePlusTex + appendResult497 ) - float2( 0.5,0.5 ) , float2x2( cos38_g139 , -sin38_g139 , sin38_g139 , cos38_g139 )) + float2( 0.5,0.5 );
				float2 panner5_g139 = ( 1.0 * _Time.y * appendResult4_g139 + rotator38_g139);
				float2 break22_g139 = panner5_g139;
				float U21_g139 = break22_g139.x;
				float V21_g139 = break22_g139.y;
				float F21_g139 = 0.0;
				float localUVClamp21_g139 = UVClamp21_g139( UVClip21_g139 , UClamp21_g139 , VClamp21_g139 , UMirror21_g139 , VMirror21_g139 , U21_g139 , V21_g139 , F21_g139 );
				float2 appendResult44_g139 = (float2(U21_g139 , V21_g139));
				float4 tex2DNode7_g139 = tex2D( _DissolvePlusTex, appendResult44_g139 );
				float lerpResult413 = lerp( temp_output_677_20 , ( F21_g139 * ( _DissolvePlusTexAR == 0.0 ? tex2DNode7_g139.a : tex2DNode7_g139.r ) ) , _DissolvePlusIntensity);
				#ifdef _FDISSOLVEPLUSTEX_ON
				float staticSwitch415 = lerpResult413;
				#else
				float staticSwitch415 = temp_output_677_20;
				#endif
				float smoothstepResult256 = smoothstep( temp_output_270_0 , ( temp_output_270_0 + temp_output_277_0 ) , staticSwitch415);
				float DissolveAlpha212 = smoothstepResult256;
				#ifdef _FDISSOLVETEX_ON
				float staticSwitch299 = DissolveAlpha212;
				#else
				float staticSwitch299 = 1.0;
				#endif
				float Refnl339 = _ReFnl;
				float3 ase_worldPos = IN.ase_texcoord4.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV279 = dot( IN.normalWS, ase_worldViewDir );
				float fresnelNode279 = ( 0.0 + _FnlScale * pow( 1.0 - fresnelNdotV279, _FnlPower ) );
				float temp_output_283_0 = saturate( fresnelNode279 );
				float ReFnlAlpha318 = ( 1.0 - temp_output_283_0 );
				#ifdef _FFNL_ON
				float staticSwitch319 = ( Refnl339 == 0.0 ? 1.0 : ReFnlAlpha318 );
				#else
				float staticSwitch319 = 1.0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth375 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth375 = abs( ( screenDepth375 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				#ifdef _FDEPTH_ON
				float staticSwitch378 = saturate( distanceDepth375 );
				#else
				float staticSwitch378 = 1.0;
				#endif
				float MainAlpha97 = saturate( ( MainTexAlpha138 * staticSwitch291 * IN.ase_color.a * Alpha337 * staticSwitch299 * staticSwitch319 * staticSwitch378 ) );
				

				surfaceDescription.Alpha = MainAlpha97;
				surfaceDescription.AlphaClipThreshold = _AlphaClip;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "SampleGUIURP"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Hidden/InternalErrorShader"
}
