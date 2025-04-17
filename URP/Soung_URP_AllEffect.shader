// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Soung/URP/特效/全功能通用FullFX"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(ON,1,OFF,0)]_Zwrite("深度写入", Float) = 0
		[Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1
		[Header(SoftParticle)]_SoftParticle("软粒子", Range( 0 , 20)) = 0
		[Header(MainTex)]_MainTex("主贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_MainTexP("主帖图通道", Float) = 0
		[HDR]_MainColor("主帖图颜色", Color) = (1,1,1,1)
		[IntRange]_MainTexRotator("主帖图旋转", Range( 0 , 360)) = 0
		_MainTexHue("主帖图色相变换", Range( 0 , 1)) = 0
		_MainTexSaturation("主帖图饱和度", Range( 0 , 1.5)) = 1
		[Enum(Material,0,Custom1xy,1)]_MainTexFlowMode("主帖图流动模式", Float) = 0
		[Enum(Repeat,0,Clamp,1)]_MainTexClamp("主帖图重铺模式", Float) = 0
		[Enum(Local,0,Polar,1)]_MainTexUVMode("主帖图UV模式", Float) = 0
		_MainTexPolarSets("主帖图Polar中心与缩放", Vector) = (0.5,0.5,1,1)
		_MainTexUspeed("主帖图U速率", Float) = 0
		_MainTexVspeed("主帖图V速率", Float) = 0
		[Header(NoiseTex)][Enum(OFF,0,ON,1)]_NoiseSwitch("扭曲开关", Float) = 0
		_NoiseTex("扭曲贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_NoiseTexP("扭曲贴图通道", Float) = 0
		_NoisePower("扭曲强度", Range( 0 , 1)) = 0
		_NoiseTexUspeed("扭曲U速率", Float) = 0
		_NoiseTexVspeed("扭曲V速率", Float) = 0
		[Header(GamTex)][Enum(OFF,0,ON,1)]_GamTexSwitch("颜色叠加开关", Float) = 0
		_GamTex("颜色叠加贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_GamTexP("颜色叠加通道", Float) = 0
		[IntRange]_GamTexRotator("颜色叠加旋转", Range( 0 , 360)) = 0
		_GamTexDesaturate("颜色叠加去色", Range( 0 , 1)) = 1
		[Enum(Repeat,0,Clmap,1)]_GamTexClamp("颜色叠加重铺模式", Float) = 0
		[Enum(OFF,0,ON,1)]_GamTexFollowMainTex("颜色叠加跟随主贴图流动", Float) = 0
		_GamTexUspeed("颜色叠加U速率", Float) = 0
		_GamTexVspeed("颜色叠加V速率", Float) = 0
		[Enum(Notuse,0,Use,1)]_GamAlphaMode("颜色叠加Alpha模式", Float) = 0
		[Header(ProgramMask)][Enum(ON,0,OFF,1)]_ProMaskSwitch("程序遮罩开关", Float) = 0
		[KeywordEnum(UP,DOWN,LEFT,RIGHT)] _ProMaskDir("程序遮罩方向", Float) = 0
		_ProMaskRange("程序遮罩范围", Range( 1 , 8)) = 1
		[Header(MaskTex)][Enum(OFF,0,ON,1)]_MaskSwitch("遮罩开关", Float) = 0
		_MaskTex("遮罩贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_MaskTexP("遮罩贴图通道", Float) = 0
		[IntRange]_MaskTexRotator("遮罩贴图旋转", Range( 0 , 360)) = 0
		[Enum(OFF,0,ON,1)]_OneMinusMask("反相遮罩", Float) = 0
		[Enum(Repeat,0,Clamp,1)]_MaskTexClamp("遮罩贴图重铺模式", Float) = 0
		_MaskTexUspeed("遮罩U速度", Float) = 0
		_MaskTexVspeed("遮罩V速度", Float) = 0
		[Header(MaskTexPlus)][Enum(OFF,0,ON,1)]_MaskTexPlusSwitch("额外遮罩开关", Float) = 0
		[Toggle]_MaskPlusUsePro("额外遮罩使用程序", Float) = 0
		_MaskTexPlus("额外遮罩", 2D) = "white" {}
		[Enum(R,0,A,1)]_MaskTexPlusP("额外遮罩通道", Float) = 0
		[IntRange]_MaskTexPlusRotator("额外遮罩旋转", Range( 0 , 360)) = 0
		[Enum(Repeat,0,Clamp,1)]_MaskTexPlusClamp("额外遮罩重铺模式", Float) = 0
		_MaskTexPlusUspeed("额外遮罩U速度", Float) = 0
		_MaskTexPlusVspeed("额外遮罩V速度", Float) = 0
		[Header(Liuguang)][Enum(OFF,0,ON,1)]_LiuguangSwitch("流光开关", Float) = 0
		_LiuguangTex("流光贴图", 2D) = "black" {}
		[Enum(R,0,A,1)]_LiuguangTexP("流光纹理通道", Float) = 0
		[IntRange]_LiuguangTexRotator("流光纹理旋转", Range( 0 , 360)) = 0
		[Toggle]_UseLGTexColor("是否禁用流光自身颜色", Float) = 1
		[HDR]_LiuguangColor("流光颜色", Color) = (0,0,0,1)
		[KeywordEnum(Local,Polar,Screen)] _LiuguangTexUVmode("流光UV模式", Float) = 0
		_LiuguangPolarScale("流光Polar中心与缩放", Vector) = (0.5,0.5,1,1)
		_LiuguangScreenTilingOffset("流光Screen重铺与偏移", Vector) = (1,1,0,0)
		_LiuguangUSpeed("流光U速率", Float) = 0
		_LiuguangVSpeed("流光V速率", Float) = 0
		[Header(DissolveTex)][Enum(OFF,0,ON,1)]_DissolveTexSwitch("溶解开关", Float) = 0
		_DissolveTex("溶解贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_DissolveTexP("溶解贴图通道", Float) = 0
		[IntRange]_DissolveTexRotator("溶解贴图旋转", Range( 0 , 360)) = 0
		_DissolveSmooth("溶解平滑度", Range( 0 , 1)) = 0
		_DissolvePower("溶解进度", Range( 0 , 2)) = 0.3787051
		[Enum(Material,0,Custom1z,1)]_DissolveMode("溶解控制模式", Float) = 0
		[Enum(Soft,0,Edge,1)]_DissolveEdgeSwitch("溶解边缘模式", Float) = 0
		[HDR]_DissolveEdgeColor("溶解边缘颜色", Color) = (1,0.4109318,0,1)
		_DissolveEdgeWide("溶解边缘宽度", Range( 0 , 1)) = 0.1420648
		_DissolveTexUspeed("溶解U速度", Float) = 0
		_DissolveTexVspeed("溶解V速度", Float) = 0
		[Header(DissloveTexPath)][Enum(OFF,0,ON,1)]_DissolveTexPlusSwitch("定向溶解开关", Float) = 0
		[Toggle]_DissolveTexPlusUsePro("定向溶解使用程序遮罩", Float) = 0
		_DissolveTexPlus("定向溶解贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_DissolveTexPlusP("定向溶解通道", Float) = 0
		[IntRange]_DissolveTexPlusRotator("定向溶解旋转", Range( 0 , 360)) = 0
		_DissolveTexPlusPower("定向溶解强度", Range( 1 , 7)) = 1
		[Enum(Material,0,Custome2xy,1)]_DissolveTexPlusFlowMode("定向溶解流动模式", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_DissolveTexPlusClamp("定向溶解重铺模式", Float) = 0
		_DissolveTexPlusUspeed("定向溶解U速度", Float) = 0
		_DissolveTexPlusVspeed("定向溶解V速度", Float) = 0
		[Header(VertexTex)][Enum(OFF,0,ON,1)]_VertexSwitch("顶点偏移开关", Float) = 0
		_VertexTex("顶点偏移贴图", 2D) = "white" {}
		[IntRange]_VertexTexRotator("顶点偏移旋转", Range( 0 , 360)) = 0
		[Enum(Material,0,Custom1w,1)]_VertexMode("顶点偏移模式", Float) = 0
		_VertexPower("顶点偏移强度", Float) = 0
		_VertexTexDir("顶点偏移轴向", Vector) = (1,1,1,0)
		_VertexTexUspeed("顶点偏移U速率", Float) = 0
		_VertexTexVspeed("顶点偏移V速率", Float) = 0
		[Header(Fresnel)][Enum(OFF,0,ON,1)]_FresnelSwitch("菲涅尔开关", Float) = 0
		[HDR]_FresnelColor("菲涅尔颜色", Color) = (1,1,1,1)
		[Enum(Fresnel,0,Bokeh,1)]_FresnelMode("菲涅尔模式", Float) = 0
		[Enum(Mult,0,Add,1)]_FresnelColorMode("菲涅尔颜色模式", Float) = 0
		[Enum(Notuse,0,Use,1)]_FresnelAlphaMode("菲涅尔Alpha模式", Float) = 0
		_FresnelSet("菲涅尔强度/边缘/范围", Vector) = (0,1,5,0)


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
			Tags { "LightMode"="VFX" }

			Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
			ZWrite [_Zwrite]
			ZTest [_ZTestMode]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			

			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 140011
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			
			#if ASE_SRP_VERSION >=140010
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#endif
		

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma shader_feature_local _PROMASKDIR_UP _PROMASKDIR_DOWN _PROMASKDIR_LEFT _PROMASKDIR_RIGHT
			#pragma shader_feature_local _LIUGUANGTEXUVMODE_LOCAL _LIUGUANGTEXUVMODE_POLAR _LIUGUANGTEXUVMODE_SCREEN


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
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTexPlus_ST;
			float4 _GamTex_ST;
			float4 _LiuguangPolarScale;
			float4 _LiuguangTex_ST;
			float4 _MainTexPolarSets;
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float4 _NoiseTex_ST;
			float4 _LiuguangColor;
			float4 _FresnelColor;
			float4 _MainColor;
			float4 _FresnelSet;
			float4 _VertexTexDir;
			float4 _DissolveEdgeColor;
			float4 _DissolveTex_ST;
			float4 _LiuguangScreenTilingOffset;
			float4 _VertexTex_ST;
			float4 _MaskTexPlus_ST;
			float _DissolveTexSwitch;
			float _FresnelSwitch;
			float _FresnelColorMode;
			float _LiuguangUSpeed;
			float _LiuguangVSpeed;
			float _DissolveEdgeWide;
			float _DissolveTexPlusPower;
			float _LiuguangTexRotator;
			float _DissolveTexPlusSwitch;
			float _DissolveTexPlusUsePro;
			float _FresnelMode;
			float _DissolveEdgeSwitch;
			float _MainTexP;
			float _UseLGTexColor;
			float _GamTexP;
			float _SoftParticle;
			float _MaskTexPlusSwitch;
			float _MaskPlusUsePro;
			float _MaskTexPlusP;
			float _MaskTexPlusClamp;
			float _MaskTexPlusRotator;
			float _MaskTexPlusVspeed;
			float _LiuguangTexP;
			float _MaskTexPlusUspeed;
			float _OneMinusMask;
			float _MaskTexP;
			float _MaskTexClamp;
			float _MaskTexRotator;
			float _MaskTexVspeed;
			float _MaskTexUspeed;
			float _ProMaskSwitch;
			float _LiuguangSwitch;
			float _MaskSwitch;
			float _ProMaskRange;
			float _BlendMode;
			float _DissolveTexPlusClamp;
			float _MainTexUVMode;
			float _MainTexVspeed;
			float _MainTexUspeed;
			float _NoiseSwitch;
			float _NoisePower;
			float _NoiseTexP;
			float _NoiseTexVspeed;
			float _NoiseTexUspeed;
			float _MainTexFlowMode;
			float _MainTexHue;
			float _VertexTexRotator;
			float _VertexTexVspeed;
			float _VertexTexUspeed;
			float _VertexMode;
			float _VertexPower;
			float _CullingMode;
			float _Zwrite;
			float _ZTestMode;
			float _VertexSwitch;
			float _MainTexRotator;
			float _MainTexClamp;
			float _MainTexSaturation;
			float _DissolveTexPlusRotator;
			float _GamAlphaMode;
			float _DissolveTexPlusFlowMode;
			float _DissolveTexPlusVspeed;
			float _DissolveTexPlusUspeed;
			float _DissolveTexP;
			float _DissolveTexRotator;
			float _DissolveTexVspeed;
			float _DissolveTexUspeed;
			float _DissolveSmooth;
			float _DissolveMode;
			float _DissolvePower;
			float _GamTexSwitch;
			float _GamTexDesaturate;
			float _GamTexClamp;
			float _GamTexRotator;
			float _GamTexFollowMainTex;
			float _GamTexVspeed;
			float _GamTexUspeed;
			float _DissolveTexPlusP;
			float _FresnelAlphaMode;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _GamTex;
			sampler2D _DissolveTex;
			sampler2D _DissolveTexPlus;
			sampler2D _LiuguangTex;
			sampler2D _MaskTex;
			sampler2D _MaskTexPlus;


			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
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
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float Toggle067 = 0.0;
				float4 temp_cast_0 = (Toggle067).xxxx;
				float4 texCoord8 = input.texcoord1;
				texCoord8.xy = input.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1w12 = texCoord8.w;
				float lerpResult139 = lerp( _VertexPower , custom1w12 , _VertexMode);
				float2 appendResult135 = (float2(_VertexTexUspeed , _VertexTexVspeed));
				float2 uv_VertexTex = input.texcoord.xy * _VertexTex_ST.xy + _VertexTex_ST.zw;
				float2 panner137 = ( 1.0 * _Time.y * appendResult135 + uv_VertexTex);
				float Rotator18014 = 180.0;
				float cos394 = cos( ( ( _VertexTexRotator * PI ) / Rotator18014 ) );
				float sin394 = sin( ( ( _VertexTexRotator * PI ) / Rotator18014 ) );
				float2 rotator394 = mul( panner137 - float2( 0.5,0.5 ) , float2x2( cos394 , -sin394 , sin394 , cos394 )) + float2( 0.5,0.5 );
				float4 lerpResult154 = lerp( temp_cast_0 , ( lerpResult139 * float4( input.normalOS , 0.0 ) * tex2Dlod( _VertexTex, float4( rotator394, 0, 0.0) ).r * _VertexTexDir ) , _VertexSwitch);
				float4 VertexTexOffset157 = lerpResult154;
				
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord9.xyz = ase_normalWS;
				
				output.ase_texcoord6.xy = input.texcoord.xy;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord8 = input.texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.zw = 0;
				output.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexTexOffset157.xyz;

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

				float Toggle067 = 0.0;
				float2 appendResult54 = (float2(_NoiseTexUspeed , _NoiseTexVspeed));
				float2 uv_NoiseTex = input.ase_texcoord6.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner50 = ( 1.0 * _Time.y * appendResult54 + uv_NoiseTex);
				float4 tex2DNode17 = tex2D( _NoiseTex, panner50 );
				float lerpResult63 = lerp( tex2DNode17.r , tex2DNode17.a , _NoiseTexP);
				float lerpResult60 = lerp( Toggle067 , ( (-0.5 + (lerpResult63 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * _NoisePower ) , _NoiseSwitch);
				float2 appendResult34 = (float2(_MainTexUspeed , _MainTexVspeed));
				float2 uv_MainTex = input.ase_texcoord6.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult24 = (float2(_MainTexPolarSets.x , _MainTexPolarSets.y));
				float2 temp_output_34_0_g3 = ( uv_MainTex - appendResult24 );
				float2 break39_g3 = temp_output_34_0_g3;
				float2 appendResult50_g3 = (float2(( _MainTexPolarSets.z * ( length( temp_output_34_0_g3 ) * 2.0 ) ) , ( ( atan2( break39_g3.x , break39_g3.y ) * ( 1.0 / TWO_PI ) ) * _MainTexPolarSets.w )));
				float2 lerpResult27 = lerp( uv_MainTex , appendResult50_g3 , _MainTexUVMode);
				float2 panner35 = ( 1.0 * _Time.y * appendResult34 + lerpResult27);
				float4 texCoord8 = input.ase_texcoord7;
				texCoord8.xy = input.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1x9 = texCoord8.x;
				float custom1y10 = texCoord8.y;
				float2 appendResult31 = (float2(custom1x9 , custom1y10));
				float2 lerpResult443 = lerp( panner35 , ( lerpResult27 + appendResult31 ) , _MainTexFlowMode);
				float Rotator18014 = 180.0;
				float cos42 = cos( ( ( _MainTexRotator * PI ) / Rotator18014 ) );
				float sin42 = sin( ( ( _MainTexRotator * PI ) / Rotator18014 ) );
				float2 rotator42 = mul( ( lerpResult60 + lerpResult443 ) - float2( 0.5,0.5 ) , float2x2( cos42 , -sin42 , sin42 , cos42 )) + float2( 0.5,0.5 );
				float2 lerpResult40 = lerp( rotator42 , saturate( rotator42 ) , _MainTexClamp);
				float4 tex2DNode15 = tex2D( _MainTex, lerpResult40 );
				float3 hsvTorgb107 = RGBToHSV( tex2DNode15.rgb );
				float3 hsvTorgb106 = HSVToRGB( float3(( _MainTexHue + hsvTorgb107.x ),( hsvTorgb107.y * _MainTexSaturation ),hsvTorgb107.z) );
				float4 MainTexColor113 = ( _MainColor * float4( hsvTorgb106 , 0.0 ) );
				float Toggle168 = 1.0;
				float3 temp_cast_2 = (Toggle168).xxx;
				float2 appendResult82 = (float2(_GamTexUspeed , _GamTexVspeed));
				float2 uv_GamTex = input.ase_texcoord6.xy * _GamTex_ST.xy + _GamTex_ST.zw;
				float2 panner85 = ( 1.0 * _Time.y * appendResult82 + uv_GamTex);
				float2 temp_cast_3 = (Toggle067).xx;
				float2 MainTexUV120 = lerpResult443;
				float2 lerpResult78 = lerp( temp_cast_3 , MainTexUV120 , _GamTexFollowMainTex);
				float cos102 = cos( ( ( _GamTexRotator * PI ) / Rotator18014 ) );
				float sin102 = sin( ( ( _GamTexRotator * PI ) / Rotator18014 ) );
				float2 rotator102 = mul( ( panner85 + lerpResult78 ) - float2( 0.5,0.5 ) , float2x2( cos102 , -sin102 , sin102 , cos102 )) + float2( 0.5,0.5 );
				float2 lerpResult89 = lerp( rotator102 , saturate( rotator102 ) , _GamTexClamp);
				float4 tex2DNode101 = tex2D( _GamTex, ( lerpResult60 + lerpResult89 ) );
				float3 desaturateInitialColor91 = tex2DNode101.rgb;
				float desaturateDot91 = dot( desaturateInitialColor91, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar91 = lerp( desaturateInitialColor91, desaturateDot91.xxx, _GamTexDesaturate );
				float3 appendResult92 = (float3(desaturateVar91));
				float3 lerpResult352 = lerp( temp_cast_2 , appendResult92 , _GamTexSwitch);
				float3 GamColor103 = lerpResult352;
				float3 temp_cast_6 = (Toggle168).xxx;
				float custom1z11 = texCoord8.z;
				float lerpResult330 = lerp( _DissolvePower , custom1z11 , _DissolveMode);
				float DissolveValue334 = lerpResult330;
				float2 appendResult323 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
				float2 uv_DissolveTex = input.ase_texcoord6.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 panner317 = ( 1.0 * _Time.y * appendResult323 + uv_DissolveTex);
				float cos328 = cos( ( ( _DissolveTexRotator * PI ) / Rotator18014 ) );
				float sin328 = sin( ( ( _DissolveTexRotator * PI ) / Rotator18014 ) );
				float2 rotator328 = mul( panner317 - float2( 0.5,0.5 ) , float2x2( cos328 , -sin328 , sin328 , cos328 )) + float2( 0.5,0.5 );
				float4 tex2DNode302 = tex2D( _DissolveTex, rotator328 );
				float lerpResult276 = lerp( tex2DNode302.r , tex2DNode302.a , _DissolveTexP);
				float2 appendResult263 = (float2(_DissolveTexPlusUspeed , _DissolveTexPlusVspeed));
				float4 texCoord384 = input.ase_texcoord8;
				texCoord384.xy = input.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float custom2x385 = texCoord384.x;
				float custom2y386 = texCoord384.y;
				float2 appendResult264 = (float2(custom2x385 , custom2y386));
				float2 lerpResult265 = lerp( appendResult263 , ( appendResult263 + appendResult264 ) , _DissolveTexPlusFlowMode);
				float2 uv_DissolveTexPlus = input.ase_texcoord6.xy * _DissolveTexPlus_ST.xy + _DissolveTexPlus_ST.zw;
				float2 panner267 = ( 1.0 * _Time.y * lerpResult265 + uv_DissolveTexPlus);
				float cos316 = cos( ( ( _DissolveTexPlusRotator * PI ) / Rotator18014 ) );
				float sin316 = sin( ( ( _DissolveTexPlusRotator * PI ) / Rotator18014 ) );
				float2 rotator316 = mul( panner267 - float2( 0.5,0.5 ) , float2x2( cos316 , -sin316 , sin316 , cos316 )) + float2( 0.5,0.5 );
				float2 lerpResult272 = lerp( rotator316 , saturate( rotator316 ) , _DissolveTexPlusClamp);
				float4 tex2DNode303 = tex2D( _DissolveTexPlus, lerpResult272 );
				float lerpResult275 = lerp( tex2DNode303.r , tex2DNode303.a , _DissolveTexPlusP);
				float2 texCoord406 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined( _PROMASKDIR_UP )
				float staticSwitch425 = ( 1.0 - texCoord406.y );
				#elif defined( _PROMASKDIR_DOWN )
				float staticSwitch425 = texCoord406.y;
				#elif defined( _PROMASKDIR_LEFT )
				float staticSwitch425 = texCoord406.x;
				#elif defined( _PROMASKDIR_RIGHT )
				float staticSwitch425 = ( 1.0 - texCoord406.x );
				#else
				float staticSwitch425 = ( 1.0 - texCoord406.y );
				#endif
				float smoothstepResult409 = smoothstep( 0.0 , _ProMaskRange , staticSwitch425);
				float lerpResult438 = lerp( saturate( ( smoothstepResult409 * ( _ProMaskRange / 0.4 ) ) ) , Toggle067 , _ProMaskSwitch);
				float ProMask431 = lerpResult438;
				float lerpResult432 = lerp( lerpResult275 , ProMask431 , _DissolveTexPlusUsePro);
				float lerpResult278 = lerp( lerpResult276 , lerpResult432 , _DissolveTexPlusSwitch);
				float temp_output_283_0 = saturate( ( ( lerpResult278 + ( lerpResult276 / _DissolveTexPlusPower ) ) / 2.0 ) );
				float smoothstepResult286 = smoothstep( ( DissolveValue334 - _DissolveSmooth ) , DissolveValue334 , temp_output_283_0);
				float4 temp_cast_7 = (smoothstepResult286).xxxx;
				float4 lerpResult299 = lerp( temp_cast_7 , ( smoothstepResult286 + ( _DissolveEdgeColor * ( step( ( DissolveValue334 - _DissolveEdgeWide ) , temp_output_283_0 ) - step( DissolveValue334 , temp_output_283_0 ) ) ) ) , _DissolveEdgeSwitch);
				float3 appendResult301 = (float3(lerpResult299.rgb));
				float3 lerpResult356 = lerp( temp_cast_6 , appendResult301 , _DissolveTexSwitch);
				float3 DissolveColor304 = lerpResult356;
				float4 temp_output_338_0 = ( MainTexColor113 * float4( GamColor103 , 0.0 ) * input.ase_color * float4( DissolveColor304 , 0.0 ) );
				float4 temp_cast_10 = (Toggle168).xxxx;
				float3 ase_normalWS = input.ase_texcoord9.xyz;
				float fresnelNdotV124 = dot( ase_normalWS, WorldViewDirection );
				float fresnelNode124 = ( _FresnelSet.x + _FresnelSet.y * pow( 1.0 - fresnelNdotV124, _FresnelSet.z ) );
				float temp_output_126_0 = saturate( fresnelNode124 );
				float lerpResult127 = lerp( temp_output_126_0 , ( 1.0 - temp_output_126_0 ) , _FresnelMode);
				float4 lerpResult245 = lerp( temp_cast_10 , ( _FresnelColor * lerpResult127 ) , _FresnelSwitch);
				float4 FresnelColor132 = lerpResult245;
				float4 lerpResult347 = lerp( ( temp_output_338_0 * FresnelColor132 ) , ( temp_output_338_0 + FresnelColor132 ) , _FresnelColorMode);
				float4 temp_cast_13 = (Toggle067).xxxx;
				float2 appendResult210 = (float2(_LiuguangUSpeed , _LiuguangVSpeed));
				float2 uv_LiuguangTex = input.ase_texcoord6.xy * _LiuguangTex_ST.xy + _LiuguangTex_ST.zw;
				float cos240 = cos( ( ( _LiuguangTexRotator * PI ) / Rotator18014 ) );
				float sin240 = sin( ( ( _LiuguangTexRotator * PI ) / Rotator18014 ) );
				float2 rotator240 = mul( uv_LiuguangTex - float2( 0.5,0.5 ) , float2x2( cos240 , -sin240 , sin240 , cos240 )) + float2( 0.5,0.5 );
				float2 appendResult227 = (float2(_LiuguangPolarScale.x , _LiuguangPolarScale.y));
				float2 temp_output_34_0_g4 = ( uv_LiuguangTex - appendResult227 );
				float2 break39_g4 = temp_output_34_0_g4;
				float2 appendResult50_g4 = (float2(( _LiuguangPolarScale.z * ( length( temp_output_34_0_g4 ) * 2.0 ) ) , ( ( atan2( break39_g4.x , break39_g4.y ) * ( 1.0 / TWO_PI ) ) * _LiuguangPolarScale.w )));
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ScreenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult225 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 appendResult226 = (float2(_LiuguangScreenTilingOffset.x , _LiuguangScreenTilingOffset.y));
				float2 appendResult228 = (float2(_LiuguangScreenTilingOffset.z , _LiuguangScreenTilingOffset.w));
				#if defined( _LIUGUANGTEXUVMODE_LOCAL )
				float2 staticSwitch239 = rotator240;
				#elif defined( _LIUGUANGTEXUVMODE_POLAR )
				float2 staticSwitch239 = appendResult50_g4;
				#elif defined( _LIUGUANGTEXUVMODE_SCREEN )
				float2 staticSwitch239 = (appendResult225*appendResult226 + appendResult228);
				#else
				float2 staticSwitch239 = rotator240;
				#endif
				float2 panner215 = ( 1.0 * _Time.y * appendResult210 + staticSwitch239);
				float4 tex2DNode196 = tex2D( _LiuguangTex, panner215 );
				float3 appendResult200 = (float3(tex2DNode196.r , tex2DNode196.g , tex2DNode196.b));
				float lerpResult197 = lerp( tex2DNode196.r , tex2DNode196.a , _LiuguangTexP);
				float4 lerpResult204 = lerp( ( float4( ( appendResult200 * lerpResult197 ) , 0.0 ) * _LiuguangColor ) , ( lerpResult197 * _LiuguangColor ) , _UseLGTexColor);
				float4 lerpResult220 = lerp( temp_cast_13 , lerpResult204 , _LiuguangSwitch);
				float4 LiuguangColor223 = lerpResult220;
				
				float lerpResult104 = lerp( tex2DNode15.r , tex2DNode15.a , _MainTexP);
				float MainTexAlpha114 = ( _MainColor.a * lerpResult104 );
				float lerpResult357 = lerp( Toggle168 , (lerpResult299).a , _DissolveTexSwitch);
				float DissolveAlpha305 = lerpResult357;
				float2 appendResult162 = (float2(_MaskTexUspeed , _MaskTexVspeed));
				float2 uv_MaskTex = input.ase_texcoord6.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 panner160 = ( 1.0 * _Time.y * appendResult162 + uv_MaskTex);
				float cos161 = cos( ( ( _MaskTexRotator * PI ) / Rotator18014 ) );
				float sin161 = sin( ( ( _MaskTexRotator * PI ) / Rotator18014 ) );
				float2 rotator161 = mul( panner160 - float2( 0.5,0.5 ) , float2x2( cos161 , -sin161 , sin161 , cos161 )) + float2( 0.5,0.5 );
				float2 lerpResult172 = lerp( rotator161 , saturate( rotator161 ) , _MaskTexClamp);
				float4 tex2DNode158 = tex2D( _MaskTex, lerpResult172 );
				float lerpResult171 = lerp( tex2DNode158.r , tex2DNode158.a , _MaskTexP);
				float smoothstepResult383 = smoothstep( 1.0 , -1.0 , lerpResult171);
				float lerpResult380 = lerp( lerpResult171 , smoothstepResult383 , _OneMinusMask);
				float lerpResult247 = lerp( Toggle168 , lerpResult380 , _MaskSwitch);
				float MaskTexAlpha193 = lerpResult247;
				float2 appendResult180 = (float2(_MaskTexPlusUspeed , _MaskTexPlusVspeed));
				float2 uv_MaskTexPlus = input.ase_texcoord6.xy * _MaskTexPlus_ST.xy + _MaskTexPlus_ST.zw;
				float2 panner181 = ( 1.0 * _Time.y * appendResult180 + uv_MaskTexPlus);
				float cos186 = cos( ( ( _MaskTexPlusRotator * PI ) / Rotator18014 ) );
				float sin186 = sin( ( ( _MaskTexPlusRotator * PI ) / Rotator18014 ) );
				float2 rotator186 = mul( panner181 - float2( 0.5,0.5 ) , float2x2( cos186 , -sin186 , sin186 , cos186 )) + float2( 0.5,0.5 );
				float2 lerpResult190 = lerp( rotator186 , saturate( rotator186 ) , _MaskTexPlusClamp);
				float4 tex2DNode187 = tex2D( _MaskTexPlus, lerpResult190 );
				float lerpResult188 = lerp( tex2DNode187.r , tex2DNode187.a , _MaskTexPlusP);
				float lerpResult435 = lerp( lerpResult188 , ProMask431 , _MaskPlusUsePro);
				float lerpResult241 = lerp( Toggle168 , lerpResult435 , _MaskTexPlusSwitch);
				float MaskTexPlusAlpha194 = lerpResult241;
				float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth399 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth399 = abs( ( screenDepth399 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _SoftParticle ) );
				float SoftParticleAlpha402 = saturate( distanceDepth399 );
				float temp_output_365_0 = ( MainTexAlpha114 * input.ase_color.a * DissolveAlpha305 * MaskTexAlpha193 * MaskTexPlusAlpha194 * SoftParticleAlpha402 );
				float lerpResult93 = lerp( tex2DNode101.r , tex2DNode101.a , _GamTexP);
				float lerpResult355 = lerp( Toggle168 , lerpResult93 , _GamTexSwitch);
				float GamAlpha123 = lerpResult355;
				float lerpResult371 = lerp( temp_output_365_0 , ( temp_output_365_0 * GamAlpha123 ) , _GamAlphaMode);
				float FresnelAlpha389 = ( _FresnelColor.a * lerpResult127 );
				float lerpResult392 = lerp( lerpResult371 , ( lerpResult371 * FresnelAlpha389 ) , _FresnelAlphaMode);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = (( lerpResult347 + LiuguangColor223 )).rgb;
				float Alpha = saturate( lerpResult392 );
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

			

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 140011
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma vertex vert
			#pragma fragment frag

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _PROMASKDIR_UP _PROMASKDIR_DOWN _PROMASKDIR_LEFT _PROMASKDIR_RIGHT


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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTexPlus_ST;
			float4 _GamTex_ST;
			float4 _LiuguangPolarScale;
			float4 _LiuguangTex_ST;
			float4 _MainTexPolarSets;
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float4 _NoiseTex_ST;
			float4 _LiuguangColor;
			float4 _FresnelColor;
			float4 _MainColor;
			float4 _FresnelSet;
			float4 _VertexTexDir;
			float4 _DissolveEdgeColor;
			float4 _DissolveTex_ST;
			float4 _LiuguangScreenTilingOffset;
			float4 _VertexTex_ST;
			float4 _MaskTexPlus_ST;
			float _DissolveTexSwitch;
			float _FresnelSwitch;
			float _FresnelColorMode;
			float _LiuguangUSpeed;
			float _LiuguangVSpeed;
			float _DissolveEdgeWide;
			float _DissolveTexPlusPower;
			float _LiuguangTexRotator;
			float _DissolveTexPlusSwitch;
			float _DissolveTexPlusUsePro;
			float _FresnelMode;
			float _DissolveEdgeSwitch;
			float _MainTexP;
			float _UseLGTexColor;
			float _GamTexP;
			float _SoftParticle;
			float _MaskTexPlusSwitch;
			float _MaskPlusUsePro;
			float _MaskTexPlusP;
			float _MaskTexPlusClamp;
			float _MaskTexPlusRotator;
			float _MaskTexPlusVspeed;
			float _LiuguangTexP;
			float _MaskTexPlusUspeed;
			float _OneMinusMask;
			float _MaskTexP;
			float _MaskTexClamp;
			float _MaskTexRotator;
			float _MaskTexVspeed;
			float _MaskTexUspeed;
			float _ProMaskSwitch;
			float _LiuguangSwitch;
			float _MaskSwitch;
			float _ProMaskRange;
			float _BlendMode;
			float _DissolveTexPlusClamp;
			float _MainTexUVMode;
			float _MainTexVspeed;
			float _MainTexUspeed;
			float _NoiseSwitch;
			float _NoisePower;
			float _NoiseTexP;
			float _NoiseTexVspeed;
			float _NoiseTexUspeed;
			float _MainTexFlowMode;
			float _MainTexHue;
			float _VertexTexRotator;
			float _VertexTexVspeed;
			float _VertexTexUspeed;
			float _VertexMode;
			float _VertexPower;
			float _CullingMode;
			float _Zwrite;
			float _ZTestMode;
			float _VertexSwitch;
			float _MainTexRotator;
			float _MainTexClamp;
			float _MainTexSaturation;
			float _DissolveTexPlusRotator;
			float _GamAlphaMode;
			float _DissolveTexPlusFlowMode;
			float _DissolveTexPlusVspeed;
			float _DissolveTexPlusUspeed;
			float _DissolveTexP;
			float _DissolveTexRotator;
			float _DissolveTexVspeed;
			float _DissolveTexUspeed;
			float _DissolveSmooth;
			float _DissolveMode;
			float _DissolvePower;
			float _GamTexSwitch;
			float _GamTexDesaturate;
			float _GamTexClamp;
			float _GamTexRotator;
			float _GamTexFollowMainTex;
			float _GamTexVspeed;
			float _GamTexUspeed;
			float _DissolveTexPlusP;
			float _FresnelAlphaMode;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveTex;
			sampler2D _DissolveTexPlus;
			sampler2D _MaskTex;
			sampler2D _MaskTexPlus;
			sampler2D _GamTex;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float Toggle067 = 0.0;
				float4 temp_cast_0 = (Toggle067).xxxx;
				float4 texCoord8 = input.ase_texcoord1;
				texCoord8.xy = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1w12 = texCoord8.w;
				float lerpResult139 = lerp( _VertexPower , custom1w12 , _VertexMode);
				float2 appendResult135 = (float2(_VertexTexUspeed , _VertexTexVspeed));
				float2 uv_VertexTex = input.ase_texcoord.xy * _VertexTex_ST.xy + _VertexTex_ST.zw;
				float2 panner137 = ( 1.0 * _Time.y * appendResult135 + uv_VertexTex);
				float Rotator18014 = 180.0;
				float cos394 = cos( ( ( _VertexTexRotator * PI ) / Rotator18014 ) );
				float sin394 = sin( ( ( _VertexTexRotator * PI ) / Rotator18014 ) );
				float2 rotator394 = mul( panner137 - float2( 0.5,0.5 ) , float2x2( cos394 , -sin394 , sin394 , cos394 )) + float2( 0.5,0.5 );
				float4 lerpResult154 = lerp( temp_cast_0 , ( lerpResult139 * float4( input.normalOS , 0.0 ) * tex2Dlod( _VertexTex, float4( rotator394, 0, 0.0) ).r * _VertexTexDir ) , _VertexSwitch);
				float4 VertexTexOffset157 = lerpResult154;
				
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord6.xyz = ase_normalWS;
				
				output.ase_texcoord3.xy = input.ase_texcoord.xy;
				output.ase_texcoord4 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_texcoord5 = input.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.zw = 0;
				output.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexTexOffset157.xyz;

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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;

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
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord2 = input.ase_texcoord2;
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
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float Toggle067 = 0.0;
				float2 appendResult54 = (float2(_NoiseTexUspeed , _NoiseTexVspeed));
				float2 uv_NoiseTex = input.ase_texcoord3.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner50 = ( 1.0 * _Time.y * appendResult54 + uv_NoiseTex);
				float4 tex2DNode17 = tex2D( _NoiseTex, panner50 );
				float lerpResult63 = lerp( tex2DNode17.r , tex2DNode17.a , _NoiseTexP);
				float lerpResult60 = lerp( Toggle067 , ( (-0.5 + (lerpResult63 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * _NoisePower ) , _NoiseSwitch);
				float2 appendResult34 = (float2(_MainTexUspeed , _MainTexVspeed));
				float2 uv_MainTex = input.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult24 = (float2(_MainTexPolarSets.x , _MainTexPolarSets.y));
				float2 temp_output_34_0_g3 = ( uv_MainTex - appendResult24 );
				float2 break39_g3 = temp_output_34_0_g3;
				float2 appendResult50_g3 = (float2(( _MainTexPolarSets.z * ( length( temp_output_34_0_g3 ) * 2.0 ) ) , ( ( atan2( break39_g3.x , break39_g3.y ) * ( 1.0 / TWO_PI ) ) * _MainTexPolarSets.w )));
				float2 lerpResult27 = lerp( uv_MainTex , appendResult50_g3 , _MainTexUVMode);
				float2 panner35 = ( 1.0 * _Time.y * appendResult34 + lerpResult27);
				float4 texCoord8 = input.ase_texcoord4;
				texCoord8.xy = input.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1x9 = texCoord8.x;
				float custom1y10 = texCoord8.y;
				float2 appendResult31 = (float2(custom1x9 , custom1y10));
				float2 lerpResult443 = lerp( panner35 , ( lerpResult27 + appendResult31 ) , _MainTexFlowMode);
				float Rotator18014 = 180.0;
				float cos42 = cos( ( ( _MainTexRotator * PI ) / Rotator18014 ) );
				float sin42 = sin( ( ( _MainTexRotator * PI ) / Rotator18014 ) );
				float2 rotator42 = mul( ( lerpResult60 + lerpResult443 ) - float2( 0.5,0.5 ) , float2x2( cos42 , -sin42 , sin42 , cos42 )) + float2( 0.5,0.5 );
				float2 lerpResult40 = lerp( rotator42 , saturate( rotator42 ) , _MainTexClamp);
				float4 tex2DNode15 = tex2D( _MainTex, lerpResult40 );
				float lerpResult104 = lerp( tex2DNode15.r , tex2DNode15.a , _MainTexP);
				float MainTexAlpha114 = ( _MainColor.a * lerpResult104 );
				float Toggle168 = 1.0;
				float custom1z11 = texCoord8.z;
				float lerpResult330 = lerp( _DissolvePower , custom1z11 , _DissolveMode);
				float DissolveValue334 = lerpResult330;
				float2 appendResult323 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
				float2 uv_DissolveTex = input.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 panner317 = ( 1.0 * _Time.y * appendResult323 + uv_DissolveTex);
				float cos328 = cos( ( ( _DissolveTexRotator * PI ) / Rotator18014 ) );
				float sin328 = sin( ( ( _DissolveTexRotator * PI ) / Rotator18014 ) );
				float2 rotator328 = mul( panner317 - float2( 0.5,0.5 ) , float2x2( cos328 , -sin328 , sin328 , cos328 )) + float2( 0.5,0.5 );
				float4 tex2DNode302 = tex2D( _DissolveTex, rotator328 );
				float lerpResult276 = lerp( tex2DNode302.r , tex2DNode302.a , _DissolveTexP);
				float2 appendResult263 = (float2(_DissolveTexPlusUspeed , _DissolveTexPlusVspeed));
				float4 texCoord384 = input.ase_texcoord5;
				texCoord384.xy = input.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float custom2x385 = texCoord384.x;
				float custom2y386 = texCoord384.y;
				float2 appendResult264 = (float2(custom2x385 , custom2y386));
				float2 lerpResult265 = lerp( appendResult263 , ( appendResult263 + appendResult264 ) , _DissolveTexPlusFlowMode);
				float2 uv_DissolveTexPlus = input.ase_texcoord3.xy * _DissolveTexPlus_ST.xy + _DissolveTexPlus_ST.zw;
				float2 panner267 = ( 1.0 * _Time.y * lerpResult265 + uv_DissolveTexPlus);
				float cos316 = cos( ( ( _DissolveTexPlusRotator * PI ) / Rotator18014 ) );
				float sin316 = sin( ( ( _DissolveTexPlusRotator * PI ) / Rotator18014 ) );
				float2 rotator316 = mul( panner267 - float2( 0.5,0.5 ) , float2x2( cos316 , -sin316 , sin316 , cos316 )) + float2( 0.5,0.5 );
				float2 lerpResult272 = lerp( rotator316 , saturate( rotator316 ) , _DissolveTexPlusClamp);
				float4 tex2DNode303 = tex2D( _DissolveTexPlus, lerpResult272 );
				float lerpResult275 = lerp( tex2DNode303.r , tex2DNode303.a , _DissolveTexPlusP);
				float2 texCoord406 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined( _PROMASKDIR_UP )
				float staticSwitch425 = ( 1.0 - texCoord406.y );
				#elif defined( _PROMASKDIR_DOWN )
				float staticSwitch425 = texCoord406.y;
				#elif defined( _PROMASKDIR_LEFT )
				float staticSwitch425 = texCoord406.x;
				#elif defined( _PROMASKDIR_RIGHT )
				float staticSwitch425 = ( 1.0 - texCoord406.x );
				#else
				float staticSwitch425 = ( 1.0 - texCoord406.y );
				#endif
				float smoothstepResult409 = smoothstep( 0.0 , _ProMaskRange , staticSwitch425);
				float lerpResult438 = lerp( saturate( ( smoothstepResult409 * ( _ProMaskRange / 0.4 ) ) ) , Toggle067 , _ProMaskSwitch);
				float ProMask431 = lerpResult438;
				float lerpResult432 = lerp( lerpResult275 , ProMask431 , _DissolveTexPlusUsePro);
				float lerpResult278 = lerp( lerpResult276 , lerpResult432 , _DissolveTexPlusSwitch);
				float temp_output_283_0 = saturate( ( ( lerpResult278 + ( lerpResult276 / _DissolveTexPlusPower ) ) / 2.0 ) );
				float smoothstepResult286 = smoothstep( ( DissolveValue334 - _DissolveSmooth ) , DissolveValue334 , temp_output_283_0);
				float4 temp_cast_0 = (smoothstepResult286).xxxx;
				float4 lerpResult299 = lerp( temp_cast_0 , ( smoothstepResult286 + ( _DissolveEdgeColor * ( step( ( DissolveValue334 - _DissolveEdgeWide ) , temp_output_283_0 ) - step( DissolveValue334 , temp_output_283_0 ) ) ) ) , _DissolveEdgeSwitch);
				float lerpResult357 = lerp( Toggle168 , (lerpResult299).a , _DissolveTexSwitch);
				float DissolveAlpha305 = lerpResult357;
				float2 appendResult162 = (float2(_MaskTexUspeed , _MaskTexVspeed));
				float2 uv_MaskTex = input.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 panner160 = ( 1.0 * _Time.y * appendResult162 + uv_MaskTex);
				float cos161 = cos( ( ( _MaskTexRotator * PI ) / Rotator18014 ) );
				float sin161 = sin( ( ( _MaskTexRotator * PI ) / Rotator18014 ) );
				float2 rotator161 = mul( panner160 - float2( 0.5,0.5 ) , float2x2( cos161 , -sin161 , sin161 , cos161 )) + float2( 0.5,0.5 );
				float2 lerpResult172 = lerp( rotator161 , saturate( rotator161 ) , _MaskTexClamp);
				float4 tex2DNode158 = tex2D( _MaskTex, lerpResult172 );
				float lerpResult171 = lerp( tex2DNode158.r , tex2DNode158.a , _MaskTexP);
				float smoothstepResult383 = smoothstep( 1.0 , -1.0 , lerpResult171);
				float lerpResult380 = lerp( lerpResult171 , smoothstepResult383 , _OneMinusMask);
				float lerpResult247 = lerp( Toggle168 , lerpResult380 , _MaskSwitch);
				float MaskTexAlpha193 = lerpResult247;
				float2 appendResult180 = (float2(_MaskTexPlusUspeed , _MaskTexPlusVspeed));
				float2 uv_MaskTexPlus = input.ase_texcoord3.xy * _MaskTexPlus_ST.xy + _MaskTexPlus_ST.zw;
				float2 panner181 = ( 1.0 * _Time.y * appendResult180 + uv_MaskTexPlus);
				float cos186 = cos( ( ( _MaskTexPlusRotator * PI ) / Rotator18014 ) );
				float sin186 = sin( ( ( _MaskTexPlusRotator * PI ) / Rotator18014 ) );
				float2 rotator186 = mul( panner181 - float2( 0.5,0.5 ) , float2x2( cos186 , -sin186 , sin186 , cos186 )) + float2( 0.5,0.5 );
				float2 lerpResult190 = lerp( rotator186 , saturate( rotator186 ) , _MaskTexPlusClamp);
				float4 tex2DNode187 = tex2D( _MaskTexPlus, lerpResult190 );
				float lerpResult188 = lerp( tex2DNode187.r , tex2DNode187.a , _MaskTexPlusP);
				float lerpResult435 = lerp( lerpResult188 , ProMask431 , _MaskPlusUsePro);
				float lerpResult241 = lerp( Toggle168 , lerpResult435 , _MaskTexPlusSwitch);
				float MaskTexPlusAlpha194 = lerpResult241;
				float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth399 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth399 = abs( ( screenDepth399 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _SoftParticle ) );
				float SoftParticleAlpha402 = saturate( distanceDepth399 );
				float temp_output_365_0 = ( MainTexAlpha114 * input.ase_color.a * DissolveAlpha305 * MaskTexAlpha193 * MaskTexPlusAlpha194 * SoftParticleAlpha402 );
				float2 appendResult82 = (float2(_GamTexUspeed , _GamTexVspeed));
				float2 uv_GamTex = input.ase_texcoord3.xy * _GamTex_ST.xy + _GamTex_ST.zw;
				float2 panner85 = ( 1.0 * _Time.y * appendResult82 + uv_GamTex);
				float2 temp_cast_1 = (Toggle067).xx;
				float2 MainTexUV120 = lerpResult443;
				float2 lerpResult78 = lerp( temp_cast_1 , MainTexUV120 , _GamTexFollowMainTex);
				float cos102 = cos( ( ( _GamTexRotator * PI ) / Rotator18014 ) );
				float sin102 = sin( ( ( _GamTexRotator * PI ) / Rotator18014 ) );
				float2 rotator102 = mul( ( panner85 + lerpResult78 ) - float2( 0.5,0.5 ) , float2x2( cos102 , -sin102 , sin102 , cos102 )) + float2( 0.5,0.5 );
				float2 lerpResult89 = lerp( rotator102 , saturate( rotator102 ) , _GamTexClamp);
				float4 tex2DNode101 = tex2D( _GamTex, ( lerpResult60 + lerpResult89 ) );
				float lerpResult93 = lerp( tex2DNode101.r , tex2DNode101.a , _GamTexP);
				float lerpResult355 = lerp( Toggle168 , lerpResult93 , _GamTexSwitch);
				float GamAlpha123 = lerpResult355;
				float lerpResult371 = lerp( temp_output_365_0 , ( temp_output_365_0 * GamAlpha123 ) , _GamAlphaMode);
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
				float3 ase_normalWS = input.ase_texcoord6.xyz;
				float fresnelNdotV124 = dot( ase_normalWS, ase_viewDirWS );
				float fresnelNode124 = ( _FresnelSet.x + _FresnelSet.y * pow( 1.0 - fresnelNdotV124, _FresnelSet.z ) );
				float temp_output_126_0 = saturate( fresnelNode124 );
				float lerpResult127 = lerp( temp_output_126_0 , ( 1.0 - temp_output_126_0 ) , _FresnelMode);
				float FresnelAlpha389 = ( _FresnelColor.a * lerpResult127 );
				float lerpResult392 = lerp( lerpResult371 , ( lerpResult371 * FresnelAlpha389 ) , _FresnelAlphaMode);
				

				float Alpha = saturate( lerpResult392 );
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
	
	CustomEditor "ShaderGUI_AllEffect"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;2;1573.086,43.6048;Inherit;False;844;348;Comment;8;386;385;384;8;12;11;10;9;自定义顶点流;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;336;-737.5387,1306.065;Inherit;False;4205.961;1109.065;Comment;14;350;305;358;357;304;356;301;300;298;299;297;253;252;335;溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;384;2002.176,150.0594;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;252;-720.9559,1892.347;Inherit;False;2096.913;499.5304;定向溶解;21;434;274;262;316;296;273;272;271;270;269;268;267;266;265;259;261;260;264;263;258;257;定向溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;385;2213.176,83.05939;Inherit;False;custom2x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;2212.176,161.0594;Inherit;False;custom2y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;430;3.211463,-727.3674;Inherit;False;1598.151;367.7855;Comment;14;439;431;438;440;422;417;424;409;429;423;425;406;421;428;程序方向遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;1487.644,472.8367;Inherit;False;371;306;Comment;6;65;14;13;66;67;68;计算常量;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-687.9774,2076.402;Inherit;False;Property;_DissolveTexPlusUspeed;定向溶解U速度;83;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;258;-688.7816,2152.924;Inherit;False;Property;_DissolveTexPlusVspeed;定向溶解V速度;84;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-685.6444,2234.179;Inherit;False;385;custom2x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-684.6444,2309.178;Inherit;False;386;custom2y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;263;-522.1884,2102.381;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;264;-520.6444,2257.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;1496.644,515.8368;Inherit;False;Constant;_RotatorDivide;RotatorDivide;67;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;406;21.71243,-668.6774;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;1663.644,515.8368;Inherit;False;Rotator180;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;428;235.2112,-685.3674;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;421;237.2113,-568.6684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;266;-372.644,2178.179;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-416.6441,2020.18;Inherit;False;Property;_DissolveTexPlusFlowMode;定向溶解流动模式;81;1;[Enum];Create;False;0;2;Material;0;Custome2xy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-261.3205,2221.245;Inherit;False;Property;_DissolveTexPlusRotator;定向溶解旋转;79;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;259;-700.0134,1954.621;Inherit;False;0;303;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;423;388.2074,-523.7523;Inherit;False;Property;_ProMaskRange;程序遮罩范围;35;0;Create;False;0;0;0;False;0;False;1;8;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;489.2112,-448.3672;Inherit;False;Constant;_RangeDivide;RangeDivide;96;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;265;-238.6442,2103.18;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;268;-1.277496,2226.687;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;0.7674103,2295.685;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;425;383.2074,-669.7524;Inherit;False;Property;_ProMaskDir;程序遮罩方向;34;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;4;UP;DOWN;LEFT;RIGHT;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;335;144.3549,1387.597;Inherit;False;785.5632;475.5096;溶解UV;10;318;328;324;322;321;323;320;319;317;325;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;72;-4275.755,-1107.648;Inherit;False;4247.797;935.8044;Comment;11;116;105;15;71;49;22;21;47;48;118;120;主帖图;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;409;649.5967,-664.9203;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;424;655.207,-470.7523;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;267;-77.04555,1963.994;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;270;175.5542,2226.896;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;1500.748,591.0295;Inherit;False;Constant;_EmptyValue;EmptyValue;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;-4253.658,-1057.92;Inherit;False;736;416;极坐标UV选择;6;28;27;26;25;24;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;417;801.0314,-665.3845;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;316;295.4721,1964.123;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;321;159.2196,1550.657;Inherit;False;Property;_DissolveTexUspeed;溶解U速度;73;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;158.8665,1625.761;Inherit;False;Property;_DissolveTexVspeed;溶解V速度;74;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;318;153.2347,1705.575;Inherit;False;Property;_DissolveTexRotator;溶解贴图旋转;66;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;1663.748,592.0295;Inherit;False;Toggle0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;-4153.268,-565.9125;Inherit;False;1491.218;358.8629;扭曲主贴图;14;61;69;60;58;57;56;64;63;17;50;54;53;52;51;扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;271;498.4477,2021.946;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;273;465.2046,2092.383;Inherit;False;Property;_DissolveTexPlusClamp;定向溶解重铺模式;82;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;418.352,1780.454;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;319;417.8388,1711.085;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;323;298.496,1569.111;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;324;349.4488,1437.863;Inherit;False;0;302;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;1586.086,149.6049;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;23;-4242.639,-892.4101;Inherit;False;Property;_MainTexPolarSets;主帖图Polar中心与缩放;14;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;439;1089.897,-532.2805;Inherit;False;Property;_ProMaskSwitch;程序遮罩开关;33;2;[Header];[Enum];Create;False;1;ProgramMask;2;ON;0;OFF;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;422;929.2072,-665.7524;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;1085.897,-609.2805;Inherit;False;67;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3493.556,-934.0414;Inherit;False;832.0342;355.4722;UV流动选择;10;37;35;34;33;32;31;30;29;444;443;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-4143.554,-375.868;Inherit;False;Property;_NoiseTexUspeed;扭曲U速率;21;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-4141.994,-300.899;Inherit;False;Property;_NoiseTexVspeed;扭曲V速率;22;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;253;948.0878,1360.514;Inherit;False;1531.266;768.7034;溶解边缘;20;302;295;287;286;285;284;283;282;281;280;279;278;277;276;256;254;303;275;432;433;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;272;645.9639,1964.527;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;317;568.0441,1442.488;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;320;600.2244,1710.346;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;438;1257.897,-665.2805;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;1803.086,160.6049;Inherit;False;custom1y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;1804.086,86.60478;Inherit;False;custom1x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-4236.381,-1016.516;Inherit;False;0;15;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;24;-4026.338,-847.11;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-3830.652,-718.9203;Inherit;False;Property;_MainTexUVMode;主帖图UV模式;13;1;[Enum];Create;False;0;2;Local;0;Polar;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3476.685,-811.8186;Inherit;False;Property;_MainTexVspeed;主帖图V速率;16;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-4144.802,-503.3107;Inherit;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-3477.692,-890.2253;Inherit;False;Property;_MainTexUspeed;主帖图U速率;15;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-4004.705,-353.3591;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;328;747.0543,1442.173;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;303;790.3352,1936.171;Inherit;True;Property;_DissolveTexPlus;定向溶解贴图;77;0;Create;False;1;DissolvePath;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;274;775.2192,2126.76;Inherit;False;Property;_DissolveTexPlusP;定向溶解通道;78;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;25;-3886.045,-863.8961;Inherit;False;Polar Coordinates;-1;;3;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.GetLocalVarNode;30;-3482,-656.5954;Inherit;False;10;custom1y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-3482,-732.5956;Inherit;False;9;custom1x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;1402.211,-669.3674;Inherit;False;ProMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;50;-3870.371,-498.1538;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;329;1889.812,475.3026;Inherit;False;634;287.0001;Comment;5;334;333;332;331;330;溶解控制模式;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;1805.086,236.6048;Inherit;False;custom1z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;1090.886,1604.697;Inherit;False;Property;_DissolveTexP;溶解贴图通道;65;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;302;945.11,1415.231;Inherit;True;Property;_DissolveTex;溶解贴图;64;0;Create;False;1;Disslove;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;275;1077.213,2013.279;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;981.3861,2135.7;Inherit;True;431;ProMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;1076.086,1937.7;Inherit;False;Property;_DissolveTexPlusUsePro;定向溶解使用程序遮罩;76;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;27;-3661.089,-887.808;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-3317.101,-852.5953;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-3311,-713.5954;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;175;-2613.694,278.3324;Inherit;False;2109.583;521.1466;Comment;23;380;170;158;248;193;247;249;174;173;172;171;161;166;165;167;164;160;162;169;168;159;381;383;遮罩贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;331;1907.634,525.6694;Inherit;False;Property;_DissolvePower;溶解进度;68;0;Create;False;0;0;0;False;0;False;0.3787051;0.084;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;2005.634,603.6692;Inherit;False;11;custom1z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;333;2017.687,682.0157;Inherit;False;Property;_DissolveMode;溶解控制模式;69;1;[Enum];Create;False;0;2;Material;0;Custom1z;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-3701.729,-527.6721;Inherit;True;Property;_NoiseTex;扭曲贴图;18;0;Create;False;1;NoiseTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;64;-3574.273,-337.1901;Inherit;False;Property;_NoiseTexP;扭曲贴图通道;19;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;276;1251.56,1491.746;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;1247.127,1608.881;Inherit;False;Property;_DissolveTexPlusPower;定向溶解强度;80;0;Create;False;0;0;0;False;0;False;1;1;1;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;295;1252.623,1416.627;Inherit;False;Property;_DissolveTexPlusSwitch;定向溶解开关;75;2;[Header];[Enum];Create;False;1;DissloveTexPath;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;432;1228.631,2012.217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;35;-3122.049,-888.8575;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;444;-2950.76,-785.884;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3124.697,-682.6385;Inherit;False;Property;_MainTexFlowMode;主帖图流动模式;11;1;[Enum];Create;False;0;2;Material;0;Custom1xy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-3410.274,-449.1897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2616.521,-448.9882;Inherit;False;2291.57;678.5944;Gam;31;355;352;353;354;103;123;93;94;92;95;91;101;90;89;96;88;102;122;79;77;97;78;100;121;85;82;80;99;98;75;87;颜色叠加;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-2507.844,450.2195;Inherit;False;Property;_MaskTexUspeed;遮罩U速度;42;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2506.844,524.2197;Inherit;False;Property;_MaskTexVspeed;遮罩V速度;43;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-2600.844,604.2197;Inherit;False;Property;_MaskTexRotator;遮罩贴图旋转;39;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2614.313,809.4218;Inherit;False;2112.177;473.6987;Comment;23;177;189;242;187;194;241;243;188;185;192;178;179;191;190;186;184;183;182;181;180;436;437;435;额外遮罩贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;278;1499.341,1491.951;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;281;1644.078,1590.434;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;330;2181.687,531.0159;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;443;-2810.91,-890.924;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;47;-2523.413,-945.0746;Inherit;False;737;233;贴图旋转;5;45;46;44;43;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;56;-3263.676,-448.9159;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-2588.534,-268.4725;Inherit;False;Property;_GamTexUspeed;颜色叠加U速率;30;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2586.002,-189.8355;Inherit;False;Property;_GamTexVspeed;颜色叠加V速率;31;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;159;-2582.935,325.8149;Inherit;False;0;158;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;162;-2369.844,473.2195;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;164;-2338.844,610.2197;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-2320.845,677.2197;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-2541.464,1052.309;Inherit;False;Property;_MaskTexPlusVspeed;额外遮罩V速度;51;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-2543.464,979.309;Inherit;False;Property;_MaskTexPlusUspeed;额外遮罩U速度;50;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-2601.464,1135.309;Inherit;False;Property;_MaskTexPlusRotator;额外遮罩旋转;48;1;[IntRange];Create;False;0;0;0;False;0;False;0;180;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;254;1630.224,1802.724;Inherit;False;828.6348;290.9063;Comment;7;294;293;292;291;290;289;288;溶解亮边;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;279;1761.99,1589.912;Inherit;False;Constant;_Disdivide;Disdivide;38;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;1764.297,1492.312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;2330.688,525.0159;Inherit;False;DissolveValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3354.441,-282.792;Inherit;False;Property;_NoisePower;扭曲强度;20;0;Create;False;0;0;0;False;0;False;0;0.026;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-2631.008,-694.8137;Inherit;False;MainTexUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-3089.208,-450.5069;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-2969.563,-478.0643;Inherit;False;67;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2514.413,-863.0746;Inherit;False;Property;_MainTexRotator;主帖图旋转;8;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-2587.458,-391.3065;Inherit;False;0;101;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;82;-2426.477,-245.1193;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-2587.604,63.08957;Inherit;False;Property;_GamTexRotator;颜色叠加旋转;26;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;160;-2241.843,332.2195;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;165;-2162.843,612.2197;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;180;-2370.464,1004.309;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;182;-2339.464,1141.309;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-2321.464,1208.309;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;280;1907.434,1492.018;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;1651.943,2016.858;Inherit;False;Property;_DissolveEdgeWide;溶解边缘宽度;72;0;Create;False;0;0;0;False;0;False;0.1420648;0.16;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;1529.24,1718.919;Inherit;False;334;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2966.125,-399.3438;Inherit;False;Property;_NoiseSwitch;扭曲开关;17;2;[Header];[Enum];Create;False;1;NoiseTex;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2584.261,-20.63617;Inherit;False;Property;_GamTexFollowMainTex;颜色叠加跟随主贴图流动;29;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-2405.4,-123.3238;Inherit;False;67;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-2586.695,-97.55964;Inherit;False;120;MainTexUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;177;-2583.554,856.9043;Inherit;False;0;187;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;60;-2808.786,-472.986;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;44;-2253.413,-858.0746;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-2242.413,-787.0748;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;85;-2299.32,-386.5896;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;78;-2236.402,-117.5435;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;77;-2325.118,67.29465;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2312.4,138.6761;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;161;-2051.843,386.2195;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;181;-2242.463,863.309;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;184;-2163.463,1143.309;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;283;2110.42,1491.565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;288;1923.599,1873.405;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-2641.121,-906.8802;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;43;-2077.413,-857.0746;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-2083.233,-387.6246;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-2140.532,66.44138;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1860.823,439.9246;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-1909.823,509.9247;Inherit;False;Property;_MaskTexClamp;遮罩贴图重铺模式;41;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;186;-2052.463,917.3087;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;285;1709.025,1723.608;Inherit;False;Property;_DissolveSmooth;溶解平滑度;67;0;Create;False;0;0;0;False;0;False;0;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;289;2065.502,1874.186;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;290;2070.305,1973.42;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1773.411,-948.0746;Inherit;False;334;248;贴图重铺;3;39;40;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;42;-1959.989,-906.4545;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;102;-1960.911,-387.6895;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;172;-1724.823,387.9246;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;191;-1861.443,971.0139;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-1910.443,1041.014;Inherit;False;Property;_MaskTexPlusClamp;额外遮罩重铺模式;49;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;284;1977.698,1705.126;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;291;2193.784,1873.899;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;293;1717.695,1844.269;Inherit;False;Property;_DissolveEdgeColor;溶解边缘颜色;71;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4109318,0,1;0,1.622214,4.924578,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SaturateNode;88;-1780.338,-328.7475;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1822.776,-253.1122;Inherit;False;Property;_GamTexClamp;颜色叠加重铺模式;28;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;190;-1725.443,919.0137;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;292;2328.335,1847.753;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;286;2246.058,1490.271;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;158;-1576.657,357.978;Inherit;True;Property;_MaskTex;遮罩贴图;37;0;Create;False;1;MaskTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;170;-1445.728,548.2197;Inherit;False;Property;_MaskTexP;遮罩贴图通道;38;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1766.738,-791.4259;Inherit;False;Property;_MainTexClamp;主帖图重铺模式;12;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;-1753.403,-858.7511;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;403;1.752869,-328.0783;Inherit;False;838;148;Comment;4;402;401;399;400;软粒子;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;133;-4060.295,-127.5874;Inherit;False;1408.511;439.1216;Comment;14;130;244;132;245;246;131;127;128;126;125;124;129;388;389;菲涅尔;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;40;-1586.733,-906.7237;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;89;-1646.599,-387.2816;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;297;2506.885,1545.929;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;298;2503.772,1638.215;Inherit;False;Property;_DissolveEdgeSwitch;溶解边缘模式;70;1;[Enum];Create;False;0;2;Soft;0;Edge;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;187;-1578.098,889.0668;Inherit;True;Property;_MaskTexPlus;额外遮罩;46;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;171;-1290.729,435.2195;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-1577.169,1078.309;Inherit;False;Property;_MaskTexPlusP;额外遮罩通道;47;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;1499.748,670.0294;Inherit;False;Constant;_BaseValue;BaseValue;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;-1115.641,-1061.352;Inherit;False;1071.814;585.9072;色相变换/拆分通道;11;113;115;114;117;112;111;108;109;106;107;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1500.66,-410.9296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;125;-4046.168,105.2261;Inherit;False;Property;_FresnelSet;菲涅尔强度/边缘/范围;98;0;Create;False;0;0;0;False;0;False;0,1,5,0;0,1,5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;299;2658.87,1491.882;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;15;-1423.98,-958.4839;Inherit;True;Property;_MainTex;主贴图;5;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;105;-1268.39,-770.7513;Inherit;False;Property;_MainTexP;主帖图通道;6;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-1120.859,558.318;Inherit;False;Property;_OneMinusMask;反相遮罩;40;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;383;-1141.859,442.318;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;16.95117,-262.4691;Inherit;False;Property;_SoftParticle;软粒子;4;1;[Header];Create;False;1;SoftParticle;0;0;False;0;False;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;188;-1292.379,967.9808;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;-1209.424,1111.06;Inherit;False;Property;_MaskPlusUsePro;额外遮罩使用程序;45;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-1413.424,1087.06;Inherit;True;431;ProMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;1664.748,666.0294;Inherit;False;Toggle1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;104;-1110.39,-865.8765;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1255.434,-128.4976;Inherit;False;Property;_GamTexP;颜色叠加通道;25;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;116;-1327.39,-673.7513;Inherit;False;Property;_MainColor;主帖图颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.FresnelNode;124;-3839.467,86.1177;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;-4377.222,353.5098;Inherit;False;1730.321;724.9023;顶点偏移;22;394;398;396;395;397;137;136;135;148;147;153;149;156;157;154;150;155;141;139;146;144;138;顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;300;2887.903,1581.469;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;2887.028,1418.868;Inherit;False;68;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;-1383.145,-403.5915;Inherit;True;Property;_GamTex;颜色叠加贴图;24;0;Create;False;1;GamTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;350;2946.317,1654.429;Inherit;False;Property;_DissolveTexSwitch;溶解开关;63;2;[Header];[Enum];Create;False;1;DissolveTex;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-1300.757,358.6512;Inherit;False;68;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1262.757,551.6512;Inherit;False;Property;_MaskSwitch;遮罩开关;36;2;[Header];[Enum];Create;False;1;MaskTex;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;380;-982.9165,435.1851;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;399;279.5511,-281.9691;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;435;-1134.424,968.0596;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-991.54,1076.818;Inherit;False;Property;_MaskTexPlusSwitch;额外遮罩开关;44;2;[Header];[Enum];Create;False;1;MaskTexPlus;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-1164.808,888.8583;Inherit;False;68;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-934.3892,-570.8762;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;93;-1074.764,-302.2005;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-3609.608,85.17873;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-907.9871,-329.8008;Inherit;False;68;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;357;3114.381,1584.646;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-903.8174,-247.2963;Inherit;False;Property;_GamTexSwitch;颜色叠加开关;23;2;[Header];[Enum];Create;False;1;GamTex;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;247;-837.757,411.6512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-4356.611,735.6393;Inherit;False;Property;_VertexTexUspeed;顶点偏移U速率;91;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-4356.711,810.9064;Inherit;False;Property;_VertexTexVspeed;顶点偏移V速率;92;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;397;-4183.248,856.9989;Inherit;False;Property;_VertexTexRotator;顶点偏移旋转;87;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;401;512.7528,-281.0784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;241;-854.918,944.5913;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;364;-311.6406,529.4839;Inherit;False;1085.74;504.0843;ALLAlpha;14;392;393;373;391;371;390;372;367;370;369;368;365;366;405;最终输出透明度;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-801.3892,-574.8762;Inherit;False;MainTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-3472.546,217.0399;Inherit;False;Property;_FresnelMode;菲涅尔模式;95;1;[Enum];Create;False;0;2;Fresnel;0;Bokeh;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;128;-3476.739,146.8471;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;355;-699.9871,-289.8008;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;3265.395,1579.147;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-694.1956,406.0776;Inherit;False;MaskTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-4195.205,757.9243;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;136;-4353.512,612.0715;Inherit;False;0;149;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;395;-3923.696,860.4438;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;398;-3912.964,926.3538;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;642.7528,-286.0784;Inherit;False;SoftParticleAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-710.5091,932.6885;Inherit;False;MaskTexPlusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;-3322.739,85.84724;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;130;-3377.739,-85.1529;Inherit;False;Property;_FresnelColor;菲涅尔颜色;94;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;1805.086,313.6047;Inherit;False;custom1w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-533.3506,-302.6621;Inherit;False;GamAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;346;-499.1227,265.0579;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;137;-4063.659,733.5253;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;396;-3745.867,861.6213;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;-285.8657,575.6542;Inherit;False;114;MainTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;368;-281.5139,656.0172;Inherit;False;305;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;-283.5139,731.0172;Inherit;False;193;MaskTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;-301.5139,812.0172;Inherit;False;194;MaskTexPlusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;-289.9668,891.0291;Inherit;False;402;SoftParticleAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-3690.903,471.7221;Inherit;False;Property;_VertexPower;顶点偏移强度;89;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-3689.41,616.8499;Inherit;False;Property;_VertexMode;顶点偏移模式;88;1;[Enum];Create;False;0;2;Material;0;Custom1w;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-3700.482,543.9944;Inherit;False;12;custom1w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;388;-3009.943,166.0802;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;394;-3630.141,736.5759;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;-98.8657,581.6542;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-94.5139,780.0172;Inherit;False;123;GamAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;138;-3332.865,562.0569;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;139;-3506.846,475.1279;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;150;-3325.533,891.0058;Inherit;False;Property;_VertexTexDir;顶点偏移轴向;90;0;Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;149;-3452.901,707.1718;Inherit;True;Property;_VertexTex;顶点偏移贴图;86;0;Create;False;1;VertexTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;389;-2863.275,160.9728;Inherit;False;FresnelAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;76.48624,607.0172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;48.48621,701.0172;Inherit;False;Property;_GamAlphaMode;颜色叠加Alpha模式;32;1;[Enum];Create;False;0;2;Notuse;0;Use;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-3131.999,474.0818;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-3167.482,398.9944;Inherit;False;67;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-3126.482,618.9944;Inherit;False;Property;_VertexSwitch;顶点偏移开关;85;2;[Header];[Enum];Create;False;1;VertexTex;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;390;86.78494,816.9182;Inherit;False;389;FresnelAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;371;236.4863,582.0172;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;154;-2994.482,449.9944;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;195;-3987.496,1302.56;Inherit;False;3230.073;934.3901;liuguang;19;210;209;208;215;224;218;202;203;201;199;196;200;198;197;204;220;222;221;223;流光;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;391;386.2653,638.4202;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;378.2653,738.4202;Float;False;Property;_FresnelAlphaMode;菲涅尔Alpha模式;97;1;[Enum];Create;False;0;2;Notuse;0;Use;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;337;-312.035,4.305458;Inherit;False;1083.834;493.3175;ALLColor;11;343;348;360;342;347;345;359;338;339;341;340;最终输出颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;3;1398.506,46.82633;Inherit;False;139;357;Comment;4;7;6;5;4;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-2846.156,445.624;Inherit;False;VertexTexOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;224;-3972.716,1359.505;Inherit;False;1056.535;855.266;UV模式;16;237;236;229;228;226;225;238;235;240;233;234;239;232;231;230;227;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;392;538.6276,583.4583;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;106;-558.3887,-913.8765;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-681.389,-802.8765;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-370.3885,-666.8767;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-244.3885,-669.8766;Inherit;False;MainTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;107;-879.3892,-937.8765;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-677.389,-986.8765;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;91;-1075.495,-398.2916;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-1367.822,-208.2654;Inherit;False;Property;_GamTexDesaturate;颜色叠加去色;27;0;Create;False;0;2;OFF;0;ON;1;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-902.2552,-398.5075;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-3156.739,61.84716;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;197;-2104.883,1489.95;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-1941.109,1370.054;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;200;-2105.594,1370.279;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-2297.437,1532.231;Inherit;False;Property;_LiuguangTexP;流光纹理通道;54;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;201;-2153.285,1607.92;Inherit;False;Property;_LiuguangColor;流光颜色;57;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;10.20196,5.255553,0,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-1815.356,1369.538;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;-1927.356,1589.541;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;227;-3551.018,1713.374;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;230;-3419.324,1689.242;Inherit;False;Polar Coordinates;-1;;4;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.SimpleDivideOpNode;231;-3509.41,1535.471;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;232;-3685.41,1535.471;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;234;-3681.139,1408.962;Inherit;False;0;196;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;215;-2609.696,1369.35;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;208;-2900.959,1417.475;Inherit;False;Property;_LiuguangUSpeed;流光U速率;61;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-2898.308,1493.578;Inherit;False;Property;_LiuguangVSpeed;流光V速率;62;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;210;-2757.676,1439.929;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-3684.671,1604.64;Inherit;False;14;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;240;-3390.77,1487.608;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-3950.411,1530.471;Inherit;False;Property;_LiuguangTexRotator;流光纹理旋转;55;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;238;-3778.02,1684.374;Inherit;False;Property;_LiuguangPolarScale;流光Polar中心与缩放;59;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;225;-3538.998,1885.945;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;226;-3540.022,2023.892;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;228;-3539.303,2122.031;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;229;-3393.257,1885.894;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;236;-3757.096,1856.844;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;237;-3754.122,2025.093;Inherit;False;Property;_LiuguangScreenTilingOffset;流光Screen重铺与偏移;60;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;246;-3176.004,-19.70556;Inherit;False;68;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;245;-3012.004,39.29445;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;204;-1512.07,1466.621;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-1447.74,1389.874;Inherit;False;67;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;220;-1148.557,1440.343;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-997.7401,1435.874;Inherit;False;LiuguangColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;301;2889.788,1491.776;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-945.3892,-785.8766;Inherit;False;Property;_MainTexSaturation;主帖图饱和度;10;0;Create;False;0;0;0;False;0;False;1;1;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-940.3892,-1016.876;Inherit;False;Property;_MainTexHue;主帖图色相变换;9;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;1411.2,88.907;Inherit;False;Property;_BlendMode;混合模式;3;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;1414.163,327.1013;Inherit;False;Property;_Zwrite;深度写入;1;1;[Enum];Create;False;0;2;ON;1;OFF;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;1412.685,167.9385;Inherit;False;Property;_CullingMode;剔除模式;0;2;[Header];[Enum];Create;False;1;Setting;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-538.1793,-402.2556;Inherit;False;GamColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;352;-701.3312,-411.0697;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;356;3113.423,1468.714;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;3260.615,1464.065;Inherit;False;DissolveColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-3150.004,156.2945;Inherit;False;Property;_FresnelSwitch;菲涅尔开关;93;2;[Header];[Enum];Create;False;1;Fresnel;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-1287.557,1528.343;Inherit;False;Property;_LiuguangSwitch;流光开关;52;2;[Header];[Enum];Create;False;1;Liuguang;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;239;-3154.35,1661.113;Inherit;True;Property;_LiuguangTexUVmode;流光UV模式;58;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Local;Polar;Screen;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-1729.356,1589.54;Inherit;False;Property;_UseLGTexColor;是否禁用流光自身颜色;56;1;[Toggle];Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;196;-2429.49,1341.464;Inherit;True;Property;_LiuguangTex;流光贴图;53;0;Create;False;1;LiuguangTex;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-2860.497,33.87361;Inherit;False;FresnelColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;-290.6589,75.97475;Inherit;False;113;MainTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-275.6588,151.975;Inherit;False;103;GamColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;339;-286.1184,227.7332;Inherit;False;304;DissolveColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;-109.8992,80.24641;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;359;92.71454,82.73471;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;345;95.23224,176.9852;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;347;248.1193,82.43515;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;342;-272.0265,306.1198;Inherit;False;132;FresnelColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;348;85.83984,270.4044;Inherit;False;Property;_FresnelColorMode;菲涅尔颜色模式;96;1;[Enum];Create;False;0;2;Mult;0;Add;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;72.43695,345.9959;Inherit;False;223;LiuguangColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;561.8766,81.39325;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;387;805.755,343.2707;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;797.9306,151.3688;Inherit;False;157;VertexTexOffset;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;361;800.8766,72.59808;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;1413.465,246.7674;Inherit;False;Property;_ZTestMode;深度测试;2;1;[Enum];Create;False;0;2;Less or Equal;4;Always;8;0;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;445;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;447;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;448;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;449;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;450;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;451;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;452;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;453;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;454;1177.512,67.63899;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;446;1094.512,73.63899;Float;False;True;-1;3;ShaderGUI_AllEffect;0;13;Soung/Effect/FullFx;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;True;True;2;5;False;;10;True;_BlendMode;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;True;_Zwrite;True;3;True;_ZTestMode;True;True;0;False;;0;False;;True;1;LightMode=VFX;False;False;0;;0;0;Standard;25;Surface;1;638773650683795960;  Blend;0;0;Two Sided;1;0;Alpha Clipping;0;638774315136596766;  Use Shadow Threshold;0;0;Forward Only;0;0;Cast Shadows;0;638773651324644612;Receive Shadows;0;638773650716082029;GPU Instancing;1;0;LOD CrossFade;0;638773650799799806;Built-in Fog;0;638773650803605686;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;False;False;False;False;False;;False;0
WireConnection;385;0;384;1
WireConnection;386;0;384;2
WireConnection;263;0;257;0
WireConnection;263;1;258;0
WireConnection;264;0;260;0
WireConnection;264;1;261;0
WireConnection;14;0;13;0
WireConnection;428;0;406;2
WireConnection;421;0;406;1
WireConnection;266;0;263;0
WireConnection;266;1;264;0
WireConnection;265;0;263;0
WireConnection;265;1;266;0
WireConnection;265;2;296;0
WireConnection;268;0;269;0
WireConnection;425;1;428;0
WireConnection;425;0;406;2
WireConnection;425;2;406;1
WireConnection;425;3;421;0
WireConnection;409;0;425;0
WireConnection;409;2;423;0
WireConnection;424;0;423;0
WireConnection;424;1;429;0
WireConnection;267;0;259;0
WireConnection;267;2;265;0
WireConnection;270;0;268;0
WireConnection;270;1;262;0
WireConnection;417;0;409;0
WireConnection;417;1;424;0
WireConnection;316;0;267;0
WireConnection;316;2;270;0
WireConnection;67;0;65;0
WireConnection;271;0;316;0
WireConnection;319;0;318;0
WireConnection;323;0;321;0
WireConnection;323;1;322;0
WireConnection;422;0;417;0
WireConnection;272;0;316;0
WireConnection;272;1;271;0
WireConnection;272;2;273;0
WireConnection;317;0;324;0
WireConnection;317;2;323;0
WireConnection;320;0;319;0
WireConnection;320;1;325;0
WireConnection;438;0;422;0
WireConnection;438;1;440;0
WireConnection;438;2;439;0
WireConnection;10;0;8;2
WireConnection;9;0;8;1
WireConnection;24;0;23;1
WireConnection;24;1;23;2
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;328;0;317;0
WireConnection;328;2;320;0
WireConnection;303;1;272;0
WireConnection;25;1;26;0
WireConnection;25;2;24;0
WireConnection;25;3;23;3
WireConnection;25;4;23;4
WireConnection;431;0;438;0
WireConnection;50;0;51;0
WireConnection;50;2;54;0
WireConnection;11;0;8;3
WireConnection;302;1;328;0
WireConnection;275;0;303;1
WireConnection;275;1;303;4
WireConnection;275;2;274;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;27;2;28;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;17;1;50;0
WireConnection;276;0;302;1
WireConnection;276;1;302;4
WireConnection;276;2;256;0
WireConnection;432;0;275;0
WireConnection;432;1;434;0
WireConnection;432;2;433;0
WireConnection;35;0;27;0
WireConnection;35;2;34;0
WireConnection;444;0;27;0
WireConnection;444;1;31;0
WireConnection;63;0;17;1
WireConnection;63;1;17;4
WireConnection;63;2;64;0
WireConnection;278;0;276;0
WireConnection;278;1;432;0
WireConnection;278;2;295;0
WireConnection;281;0;276;0
WireConnection;281;1;277;0
WireConnection;330;0;331;0
WireConnection;330;1;332;0
WireConnection;330;2;333;0
WireConnection;443;0;35;0
WireConnection;443;1;444;0
WireConnection;443;2;37;0
WireConnection;56;0;63;0
WireConnection;162;0;168;0
WireConnection;162;1;169;0
WireConnection;164;0;166;0
WireConnection;282;0;278;0
WireConnection;282;1;281;0
WireConnection;334;0;330;0
WireConnection;120;0;443;0
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;82;0;98;0
WireConnection;82;1;99;0
WireConnection;160;0;159;0
WireConnection;160;2;162;0
WireConnection;165;0;164;0
WireConnection;165;1;167;0
WireConnection;180;0;178;0
WireConnection;180;1;179;0
WireConnection;182;0;185;0
WireConnection;280;0;282;0
WireConnection;280;1;279;0
WireConnection;60;0;69;0
WireConnection;60;1;57;0
WireConnection;60;2;61;0
WireConnection;44;0;45;0
WireConnection;85;0;80;0
WireConnection;85;2;82;0
WireConnection;78;0;121;0
WireConnection;78;1;75;0
WireConnection;78;2;100;0
WireConnection;77;0;97;0
WireConnection;161;0;160;0
WireConnection;161;2;165;0
WireConnection;181;0;177;0
WireConnection;181;2;180;0
WireConnection;184;0;182;0
WireConnection;184;1;183;0
WireConnection;283;0;280;0
WireConnection;288;0;287;0
WireConnection;288;1;294;0
WireConnection;71;0;60;0
WireConnection;71;1;443;0
WireConnection;43;0;44;0
WireConnection;43;1;46;0
WireConnection;87;0;85;0
WireConnection;87;1;78;0
WireConnection;79;0;77;0
WireConnection;79;1;122;0
WireConnection;173;0;161;0
WireConnection;186;0;181;0
WireConnection;186;2;184;0
WireConnection;289;0;288;0
WireConnection;289;1;283;0
WireConnection;290;0;287;0
WireConnection;290;1;283;0
WireConnection;42;0;71;0
WireConnection;42;2;43;0
WireConnection;102;0;87;0
WireConnection;102;2;79;0
WireConnection;172;0;161;0
WireConnection;172;1;173;0
WireConnection;172;2;174;0
WireConnection;191;0;186;0
WireConnection;284;0;287;0
WireConnection;284;1;285;0
WireConnection;291;0;289;0
WireConnection;291;1;290;0
WireConnection;88;0;102;0
WireConnection;190;0;186;0
WireConnection;190;1;191;0
WireConnection;190;2;192;0
WireConnection;292;0;293;0
WireConnection;292;1;291;0
WireConnection;286;0;283;0
WireConnection;286;1;284;0
WireConnection;286;2;287;0
WireConnection;158;1;172;0
WireConnection;39;0;42;0
WireConnection;40;0;42;0
WireConnection;40;1;39;0
WireConnection;40;2;41;0
WireConnection;89;0;102;0
WireConnection;89;1;88;0
WireConnection;89;2;96;0
WireConnection;297;0;286;0
WireConnection;297;1;292;0
WireConnection;187;1;190;0
WireConnection;171;0;158;1
WireConnection;171;1;158;4
WireConnection;171;2;170;0
WireConnection;90;0;60;0
WireConnection;90;1;89;0
WireConnection;299;0;286;0
WireConnection;299;1;297;0
WireConnection;299;2;298;0
WireConnection;15;1;40;0
WireConnection;383;0;171;0
WireConnection;188;0;187;1
WireConnection;188;1;187;4
WireConnection;188;2;189;0
WireConnection;68;0;66;0
WireConnection;104;0;15;1
WireConnection;104;1;15;4
WireConnection;104;2;105;0
WireConnection;124;1;125;1
WireConnection;124;2;125;2
WireConnection;124;3;125;3
WireConnection;300;0;299;0
WireConnection;101;1;90;0
WireConnection;380;0;171;0
WireConnection;380;1;383;0
WireConnection;380;2;381;0
WireConnection;399;0;400;0
WireConnection;435;0;188;0
WireConnection;435;1;436;0
WireConnection;435;2;437;0
WireConnection;117;0;116;4
WireConnection;117;1;104;0
WireConnection;93;0;101;1
WireConnection;93;1;101;4
WireConnection;93;2;94;0
WireConnection;126;0;124;0
WireConnection;357;0;358;0
WireConnection;357;1;300;0
WireConnection;357;2;350;0
WireConnection;247;0;249;0
WireConnection;247;1;380;0
WireConnection;247;2;248;0
WireConnection;401;0;399;0
WireConnection;241;0;243;0
WireConnection;241;1;435;0
WireConnection;241;2;242;0
WireConnection;114;0;117;0
WireConnection;128;0;126;0
WireConnection;355;0;354;0
WireConnection;355;1;93;0
WireConnection;355;2;353;0
WireConnection;305;0;357;0
WireConnection;193;0;247;0
WireConnection;135;0;147;0
WireConnection;135;1;148;0
WireConnection;395;0;397;0
WireConnection;402;0;401;0
WireConnection;194;0;241;0
WireConnection;127;0;126;0
WireConnection;127;1;128;0
WireConnection;127;2;129;0
WireConnection;12;0;8;4
WireConnection;123;0;355;0
WireConnection;137;0;136;0
WireConnection;137;2;135;0
WireConnection;396;0;395;0
WireConnection;396;1;398;0
WireConnection;388;0;130;4
WireConnection;388;1;127;0
WireConnection;394;0;137;0
WireConnection;394;2;396;0
WireConnection;365;0;366;0
WireConnection;365;1;346;4
WireConnection;365;2;368;0
WireConnection;365;3;369;0
WireConnection;365;4;370;0
WireConnection;365;5;405;0
WireConnection;139;0;144;0
WireConnection;139;1;153;0
WireConnection;139;2;146;0
WireConnection;149;1;394;0
WireConnection;389;0;388;0
WireConnection;372;0;365;0
WireConnection;372;1;367;0
WireConnection;141;0;139;0
WireConnection;141;1;138;0
WireConnection;141;2;149;1
WireConnection;141;3;150;0
WireConnection;371;0;365;0
WireConnection;371;1;372;0
WireConnection;371;2;373;0
WireConnection;154;0;155;0
WireConnection;154;1;141;0
WireConnection;154;2;156;0
WireConnection;391;0;371;0
WireConnection;391;1;390;0
WireConnection;157;0;154;0
WireConnection;392;0;371;0
WireConnection;392;1;391;0
WireConnection;392;2;393;0
WireConnection;106;0;109;0
WireConnection;106;1;111;0
WireConnection;106;2;107;3
WireConnection;111;0;107;2
WireConnection;111;1;112;0
WireConnection;115;0;116;0
WireConnection;115;1;106;0
WireConnection;113;0;115;0
WireConnection;107;0;15;0
WireConnection;109;0;108;0
WireConnection;109;1;107;1
WireConnection;91;0;101;0
WireConnection;91;1;95;0
WireConnection;92;0;91;0
WireConnection;131;0;130;0
WireConnection;131;1;127;0
WireConnection;197;0;196;1
WireConnection;197;1;196;4
WireConnection;197;2;199;0
WireConnection;198;0;200;0
WireConnection;198;1;197;0
WireConnection;200;0;196;1
WireConnection;200;1;196;2
WireConnection;200;2;196;3
WireConnection;203;0;198;0
WireConnection;203;1;201;0
WireConnection;202;0;197;0
WireConnection;202;1;201;0
WireConnection;227;0;238;1
WireConnection;227;1;238;2
WireConnection;230;1;234;0
WireConnection;230;2;227;0
WireConnection;230;3;238;3
WireConnection;230;4;238;4
WireConnection;231;0;232;0
WireConnection;231;1;233;0
WireConnection;232;0;235;0
WireConnection;215;0;239;0
WireConnection;215;2;210;0
WireConnection;210;0;208;0
WireConnection;210;1;209;0
WireConnection;240;0;234;0
WireConnection;240;2;231;0
WireConnection;225;0;236;1
WireConnection;225;1;236;2
WireConnection;226;0;237;1
WireConnection;226;1;237;2
WireConnection;228;0;237;3
WireConnection;228;1;237;4
WireConnection;229;0;225;0
WireConnection;229;1;226;0
WireConnection;229;2;228;0
WireConnection;245;0;246;0
WireConnection;245;1;131;0
WireConnection;245;2;244;0
WireConnection;204;0;203;0
WireConnection;204;1;202;0
WireConnection;204;2;218;0
WireConnection;220;0;222;0
WireConnection;220;1;204;0
WireConnection;220;2;221;0
WireConnection;223;0;220;0
WireConnection;301;0;299;0
WireConnection;103;0;352;0
WireConnection;352;0;354;0
WireConnection;352;1;92;0
WireConnection;352;2;353;0
WireConnection;356;0;358;0
WireConnection;356;1;301;0
WireConnection;356;2;350;0
WireConnection;304;0;356;0
WireConnection;239;1;240;0
WireConnection;239;0;230;0
WireConnection;239;2;229;0
WireConnection;196;1;215;0
WireConnection;132;0;245;0
WireConnection;338;0;340;0
WireConnection;338;1;341;0
WireConnection;338;2;346;0
WireConnection;338;3;339;0
WireConnection;359;0;338;0
WireConnection;359;1;342;0
WireConnection;345;0;338;0
WireConnection;345;1;342;0
WireConnection;347;0;359;0
WireConnection;347;1;345;0
WireConnection;347;2;348;0
WireConnection;360;0;347;0
WireConnection;360;1;343;0
WireConnection;387;0;392;0
WireConnection;361;0;360;0
WireConnection;446;2;361;0
WireConnection;446;3;387;0
WireConnection;446;5;363;0
ASEEND*/
//CHKSM=E79D30391A9D462D22FE4057CF6F495BAFDFB8BA