// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/URP/LTY_多功能整合URP"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(Add,1,Alpha,10)]_Dst("BlendMode", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		[Enum(Less or Equal,4,Always,8)]_ZTestMode("ZTest", Float) = 4
		[Enum(ON,1,OFF,0)]_Zwrite("Zwrite", Float) = 0
		_SoftParticle("SoftParticle", Range( 0 , 10)) = 0
		[Header(Main_Tex)]_Main_Tex("Main_Tex", 2D) = "white" {}
		[HDR]_Main_Tex_Color("Main_Tex_Color", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_Main_Tex_A_R("Main_Tex_A_R", Float) = 0
		[Enum(Normal,0,Custom,1)]_Main_Tex_Custom_ZW("Main_Tex_Custom_ZW", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_Main_Tex_ClampSwitch("Main_Tex_ClampSwitch", Float) = 0
		_Main_Tex_Rotator("Main_Tex_Rotator", Range( 0 , 360)) = 0
		_Main_Tex_U_speed("Main_Tex_U_speed", Float) = 0
		_Main_Tex_V_speed("Main_Tex_V_speed", Float) = 0
		[Header(Remap_Tex)]_Remap_Tex("Remap_Tex", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_Remap_Tex_Followl_Main_Tex("Remap_Tex_Followl_Main_Tex", Float) = 0
		[Enum(R,0,A,1)]_Remap_Tex_A_R("Remap_Tex_A_R", Float) = 0
		_Remap_Tex_Desaturate("Remap_Tex_Desaturate", Range( 0 , 1)) = 0
		[Enum(Repeat,0,Clmap,1)]_Remap_Tex_ClampSwitch("Remap_Tex_ClampSwitch", Float) = 0
		_Remap_Tex_Rotator("Remap_Tex_Rotator", Range( 0 , 360)) = 0
		_Remap_Tex_U_speed("Remap_Tex_U_speed", Float) = 0
		_Remap_Tex_V_speed("Remap_Tex_V_speed", Float) = 0
		[Header(Mask_Tex)]_Mask_Tex("Mask_Tex", 2D) = "white" {}
		[Enum(Repeat,0,Clmap,1)]_Mask_Tex_ClampSwitch("Mask_Tex_ClampSwitch", Float) = 0
		[Enum(R,0,A,1)]_Mask_Tex_A_R("Mask_Tex_A_R", Float) = 0
		_Mask_Tex_Rotator("Mask_Tex_Rotator", Range( 0 , 360)) = 0
		_Mask_Tex_U_speed("Mask_Tex_U_speed", Float) = 0
		_Mask_Tex_V_speed("Mask_Tex_V_speed", Float) = 0
		[Header(Dissolve_Tex)]_Dissolve_Tex("Dissolve_Tex", 2D) = "white" {}
		[Toggle(_DISSOLVE_SWITCH_ON)] _Dissolve_Switch("Dissolve_Switch", Float) = 0
		[Enum(R,0,A,1)]_Dissolve_Tex_A_R("Dissolve_Tex_A_R", Float) = 0
		[Enum(OFF,0,ON,1)]_Dissolve_Tex_Custom_X("Dissolve_Tex_Custom_X", Float) = 0
		_Dissolve_Tex_Rotator("Dissolve_Tex_Rotator", Range( 0 , 360)) = 0
		_Dissolve_Tex_smooth("Dissolve_Tex_smooth", Range( 0.5 , 1)) = 0.5
		_Dissolve_Tex_power("Dissolve_Tex_power", Range( 0 , 1)) = 0
		_Dissolve_Tex_U_speed("Dissolve_Tex_U_speed", Float) = 0
		_Dissolve_Tex_V_speed("Dissolve_Tex_V_speed", Float) = 0
		[Header(Distortion_Tex)]_Distortion_Tex("Distortion_Tex", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_Distortion_Switch("Distortion_Switch", Float) = 0
		_Distortion_Tex_Power("Distortion_Tex_Power", Float) = 0
		_Distortion_Tex_U_speed("Distortion_Tex_U_speed", Float) = 0
		_Distortion_Tex_V_speed("Distortion_Tex_V_speed", Float) = 0
		[HDR][Header(Fresnel)]_Fresnel_Color("Fresnel_Color", Color) = (1,1,1,1)
		[Toggle(_FRESNEL_SWITCH_ON)] _Fresnel_Switch("Fresnel_Switch", Float) = 0
		[Enum(Fresnel,0,Bokeh,1)]_Fresnel_Bokeh("Fresnel_Bokeh", Float) = 0
		_Fresnel_scale("Fresnel_scale", Float) = 1
		_Fresnel_power("Fresnel_power", Float) = 5
		[Header(Wpo_Tex)]_WPO_Tex("WPO_Tex", 2D) = "white" {}
		[Toggle(_WPO_SWITCH_ON)] _WPO_Switch("WPO_Switch", Float) = 0
		[Enum(Normal,0,Custom,1)]_WPO_CustomSwitch_Y("WPO_CustomSwitch_Y", Float) = 0
		_WPO_tex_power("WPO_tex_power", Float) = 0
		_WPO_Tex_Direction("WPO_Tex_Direction", Vector) = (1,1,1,0)
		_WPO_Tex_U_speed("WPO_Tex_U_speed", Float) = 0
		[ASEEnd]_WPO_Tex_V_speed("WPO_Tex_V_speed", Float) = 0


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
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha [_Dst], One OneMinusSrcAlpha
			ZWrite [_Zwrite]
			ZTest [_ZTestMode]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120111
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
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
			#pragma shader_feature _WPO_SWITCH_ON
			#pragma shader_feature _FRESNEL_SWITCH_ON
			#pragma shader_feature _DISSOLVE_SWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Tex_ST;
			float4 _Mask_Tex_ST;
			float4 _Fresnel_Color;
			float4 _WPO_Tex_ST;
			float4 _WPO_Tex_Direction;
			float4 _Main_Tex_Color;
			float4 _Distortion_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float4 _Remap_Tex_ST;
			float _Dissolve_Tex_Rotator;
			float _Dissolve_Tex_A_R;
			float _Dissolve_Tex_power;
			float _Dissolve_Tex_Custom_X;
			float _Remap_Tex_U_speed;
			float _Remap_Tex_V_speed;
			float _CullMode;
			float _Remap_Tex_Rotator;
			float _Remap_Tex_ClampSwitch;
			float _Remap_Tex_Desaturate;
			float _Main_Tex_A_R;
			float _SoftParticle;
			float _Mask_Tex_U_speed;
			float _Mask_Tex_V_speed;
			float _Mask_Tex_Rotator;
			float _Mask_Tex_ClampSwitch;
			float _Remap_Tex_Followl_Main_Tex;
			float _Dissolve_Tex_V_speed;
			float _Fresnel_Bokeh;
			float _Dissolve_Tex_smooth;
			float _Zwrite;
			float _Dst;
			float _ZTestMode;
			float _WPO_tex_power;
			float _WPO_CustomSwitch_Y;
			float _WPO_Tex_U_speed;
			float _WPO_Tex_V_speed;
			float _Main_Tex_U_speed;
			float _Main_Tex_V_speed;
			float _Main_Tex_Custom_ZW;
			float _Distortion_Tex_Power;
			float _Distortion_Tex_U_speed;
			float _Distortion_Tex_V_speed;
			float _Distortion_Switch;
			float _Main_Tex_Rotator;
			float _Main_Tex_ClampSwitch;
			float _Fresnel_power;
			float _Fresnel_scale;
			float _Mask_Tex_A_R;
			float _Dissolve_Tex_U_speed;
			float _Remap_Tex_A_R;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _WPO_Tex;
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Remap_Tex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _Mask_Tex;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 temp_cast_0 = (0.0).xxxx;
				float4 texCoord395 = v.ase_texcoord1;
				texCoord395.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult398 = lerp( _WPO_tex_power , texCoord395.y , _WPO_CustomSwitch_Y);
				float2 appendResult386 = (float2(_WPO_Tex_U_speed , _WPO_Tex_V_speed));
				float2 uv_WPO_Tex = v.ase_texcoord.xy * _WPO_Tex_ST.xy + _WPO_Tex_ST.zw;
				float2 panner390 = ( 1.0 * _Time.y * appendResult386 + uv_WPO_Tex);
				#ifdef _WPO_SWITCH_ON
				float4 staticSwitch408 = ( lerpResult398 * float4( v.ase_normal , 0.0 ) * tex2Dlod( _WPO_Tex, float4( panner390, 0, 0.0) ) * _WPO_Tex_Direction );
				#else
				float4 staticSwitch408 = temp_cast_0;
				#endif
				float4 Vertex117 = staticSwitch408;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Vertex117.rgb;

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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 appendResult298 = (float2(( _Main_Tex_U_speed * _TimeParameters.x ) , ( _TimeParameters.x * _Main_Tex_V_speed )));
				float2 uv_Main_Tex = IN.ase_texcoord3.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float4 texCoord288 = IN.ase_texcoord4;
				texCoord288.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult301 = (float2(texCoord288.z , texCoord288.w));
				float2 lerpResult308 = lerp( ( frac( appendResult298 ) + uv_Main_Tex ) , ( uv_Main_Tex + appendResult301 ) , _Main_Tex_Custom_ZW);
				float2 appendResult283 = (float2(_Distortion_Tex_U_speed , _Distortion_Tex_V_speed));
				float2 uv_Distortion_Tex = IN.ase_texcoord3.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 panner286 = ( 1.0 * _Time.y * appendResult283 + uv_Distortion_Tex);
				float lerpResult309 = lerp( 0.0 , ( _Distortion_Tex_Power * (-0.5 + (tex2D( _Distortion_Tex, panner286 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) , _Distortion_Switch);
				float2 ONE214 = ( lerpResult308 + lerpResult309 );
				float cos321 = cos( ( ( _Main_Tex_Rotator * PI ) / 180.0 ) );
				float sin321 = sin( ( ( _Main_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator321 = mul( ONE214 - float2( 0.5,0.5 ) , float2x2( cos321 , -sin321 , sin321 , cos321 )) + float2( 0.5,0.5 );
				float2 lerpResult411 = lerp( rotator321 , saturate( rotator321 ) , _Main_Tex_ClampSwitch);
				float4 tex2DNode1 = tex2D( _Main_Tex, lerpResult411 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float dotResult343 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult438 = smoothstep( 0.0 , 1.0 , ( 1.0 - saturate( abs( dotResult343 ) ) ));
				float temp_output_363_0 = ( pow( smoothstepResult438 , _Fresnel_power ) * ( _Fresnel_scale * 1 ) );
				float lerpResult370 = lerp( temp_output_363_0 , ( 1.0 - temp_output_363_0 ) , _Fresnel_Bokeh);
				#ifdef _FRESNEL_SWITCH_ON
				float staticSwitch372 = lerpResult370;
				#else
				float staticSwitch372 = 1.0;
				#endif
				float2 appendResult342 = (float2(_Dissolve_Tex_U_speed , _Dissolve_Tex_V_speed));
				float2 uv_Dissolve_Tex = IN.ase_texcoord3.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float cos430 = cos( ( ( _Dissolve_Tex_Rotator * PI ) / 180.0 ) );
				float sin430 = sin( ( ( _Dissolve_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator430 = mul( uv_Dissolve_Tex - float2( 0.5,0.5 ) , float2x2( cos430 , -sin430 , sin430 , cos430 )) + float2( 0.5,0.5 );
				float2 panner346 = ( 1.0 * _Time.y * appendResult342 + rotator430);
				float4 tex2DNode353 = tex2D( _Dissolve_Tex, panner346 );
				float lerpResult417 = lerp( tex2DNode353.r , tex2DNode353.a , _Dissolve_Tex_A_R);
				float five300 = texCoord288.x;
				float lerpResult351 = lerp( _Dissolve_Tex_power , five300 , _Dissolve_Tex_Custom_X);
				float smoothstepResult368 = smoothstep( ( 1.0 - _Dissolve_Tex_smooth ) , _Dissolve_Tex_smooth , saturate( ( ( lerpResult417 + 1.0 ) - ( lerpResult351 * 2.0 ) ) ));
				#ifdef _DISSOLVE_SWITCH_ON
				float staticSwitch371 = smoothstepResult368;
				#else
				float staticSwitch371 = 1.0;
				#endif
				float4 four222 = ( staticSwitch372 * staticSwitch371 * _Fresnel_Color );
				float2 appendResult420 = (float2(_Remap_Tex_U_speed , _Remap_Tex_V_speed));
				float2 uv_Remap_Tex = IN.ase_texcoord3.xy * _Remap_Tex_ST.xy + _Remap_Tex_ST.zw;
				float2 panner421 = ( 1.0 * _Time.y * appendResult420 + uv_Remap_Tex);
				float2 temp_cast_0 = (0.0).xx;
				float2 GAM_MAIN_Move446 = appendResult301;
				float2 lerpResult448 = lerp( temp_cast_0 , GAM_MAIN_Move446 , _Remap_Tex_Followl_Main_Tex);
				float cos399 = cos( ( ( _Remap_Tex_Rotator * PI ) / 180.0 ) );
				float sin399 = sin( ( ( _Remap_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator399 = mul( ( panner421 + lerpResult448 ) - float2( 0.5,0.5 ) , float2x2( cos399 , -sin399 , sin399 , cos399 )) + float2( 0.5,0.5 );
				float2 lerpResult433 = lerp( rotator399 , saturate( rotator399 ) , _Remap_Tex_ClampSwitch);
				float4 tex2DNode406 = tex2D( _Remap_Tex, ( lerpResult309 + lerpResult433 ) );
				float3 desaturateInitialColor441 = tex2DNode406.rgb;
				float desaturateDot441 = dot( desaturateInitialColor441, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar441 = lerp( desaturateInitialColor441, desaturateDot441.xxx, _Remap_Tex_Desaturate );
				float3 appendResult425 = (float3(desaturateVar441));
				float3 Gam258 = appendResult425;
				
				float lerpResult409 = lerp( tex2DNode1.r , tex2DNode1.a , _Main_Tex_A_R);
				float Three217 = ( staticSwitch372 * _Fresnel_Color.a * staticSwitch371 );
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth393 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth393 = abs( ( screenDepth393 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _SoftParticle ) );
				float soft219 = saturate( distanceDepth393 );
				float2 appendResult332 = (float2(_Mask_Tex_U_speed , _Mask_Tex_V_speed));
				float2 uv_Mask_Tex = IN.ase_texcoord3.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
				float2 panner334 = ( 1.0 * _Time.y * appendResult332 + uv_Mask_Tex);
				float cos335 = cos( ( ( _Mask_Tex_Rotator * PI ) / 180.0 ) );
				float sin335 = sin( ( ( _Mask_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator335 = mul( panner334 - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
				float2 lerpResult413 = lerp( rotator335 , saturate( rotator335 ) , _Mask_Tex_ClampSwitch);
				float4 tex2DNode327 = tex2D( _Mask_Tex, lerpResult413 );
				float lerpResult453 = lerp( tex2DNode327.r , tex2DNode327.a , _Mask_Tex_A_R);
				float two215 = lerpResult453;
				float lerpResult432 = lerp( tex2DNode406.r , tex2DNode406.a , _Remap_Tex_A_R);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * ( _Main_Tex_Color * tex2DNode1 ) * four222 * float4( Gam258 , 0.0 ) ).rgb;
				float Alpha = ( IN.ase_color.a * _Main_Tex_Color.a * lerpResult409 * Three217 * soft219 * two215 * lerpResult432 );
				float AlphaClipThreshold = 0.5;
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
			#define ASE_SRP_VERSION 120111
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _WPO_SWITCH_ON
			#pragma shader_feature _FRESNEL_SWITCH_ON
			#pragma shader_feature _DISSOLVE_SWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Tex_ST;
			float4 _Mask_Tex_ST;
			float4 _Fresnel_Color;
			float4 _WPO_Tex_ST;
			float4 _WPO_Tex_Direction;
			float4 _Main_Tex_Color;
			float4 _Distortion_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float4 _Remap_Tex_ST;
			float _Dissolve_Tex_Rotator;
			float _Dissolve_Tex_A_R;
			float _Dissolve_Tex_power;
			float _Dissolve_Tex_Custom_X;
			float _Remap_Tex_U_speed;
			float _Remap_Tex_V_speed;
			float _CullMode;
			float _Remap_Tex_Rotator;
			float _Remap_Tex_ClampSwitch;
			float _Remap_Tex_Desaturate;
			float _Main_Tex_A_R;
			float _SoftParticle;
			float _Mask_Tex_U_speed;
			float _Mask_Tex_V_speed;
			float _Mask_Tex_Rotator;
			float _Mask_Tex_ClampSwitch;
			float _Remap_Tex_Followl_Main_Tex;
			float _Dissolve_Tex_V_speed;
			float _Fresnel_Bokeh;
			float _Dissolve_Tex_smooth;
			float _Zwrite;
			float _Dst;
			float _ZTestMode;
			float _WPO_tex_power;
			float _WPO_CustomSwitch_Y;
			float _WPO_Tex_U_speed;
			float _WPO_Tex_V_speed;
			float _Main_Tex_U_speed;
			float _Main_Tex_V_speed;
			float _Main_Tex_Custom_ZW;
			float _Distortion_Tex_Power;
			float _Distortion_Tex_U_speed;
			float _Distortion_Tex_V_speed;
			float _Distortion_Switch;
			float _Main_Tex_Rotator;
			float _Main_Tex_ClampSwitch;
			float _Fresnel_power;
			float _Fresnel_scale;
			float _Mask_Tex_A_R;
			float _Dissolve_Tex_U_speed;
			float _Remap_Tex_A_R;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _WPO_Tex;
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _Mask_Tex;
			sampler2D _Remap_Tex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 temp_cast_0 = (0.0).xxxx;
				float4 texCoord395 = v.ase_texcoord1;
				texCoord395.xy = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult398 = lerp( _WPO_tex_power , texCoord395.y , _WPO_CustomSwitch_Y);
				float2 appendResult386 = (float2(_WPO_Tex_U_speed , _WPO_Tex_V_speed));
				float2 uv_WPO_Tex = v.ase_texcoord.xy * _WPO_Tex_ST.xy + _WPO_Tex_ST.zw;
				float2 panner390 = ( 1.0 * _Time.y * appendResult386 + uv_WPO_Tex);
				#ifdef _WPO_SWITCH_ON
				float4 staticSwitch408 = ( lerpResult398 * float4( v.ase_normal , 0.0 ) * tex2Dlod( _WPO_Tex, float4( panner390, 0, 0.0) ) * _WPO_Tex_Direction );
				#else
				float4 staticSwitch408 = temp_cast_0;
				#endif
				float4 Vertex117 = staticSwitch408;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord4.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Vertex117.rgb;

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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 appendResult298 = (float2(( _Main_Tex_U_speed * _TimeParameters.x ) , ( _TimeParameters.x * _Main_Tex_V_speed )));
				float2 uv_Main_Tex = IN.ase_texcoord2.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float4 texCoord288 = IN.ase_texcoord3;
				texCoord288.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult301 = (float2(texCoord288.z , texCoord288.w));
				float2 lerpResult308 = lerp( ( frac( appendResult298 ) + uv_Main_Tex ) , ( uv_Main_Tex + appendResult301 ) , _Main_Tex_Custom_ZW);
				float2 appendResult283 = (float2(_Distortion_Tex_U_speed , _Distortion_Tex_V_speed));
				float2 uv_Distortion_Tex = IN.ase_texcoord2.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 panner286 = ( 1.0 * _Time.y * appendResult283 + uv_Distortion_Tex);
				float lerpResult309 = lerp( 0.0 , ( _Distortion_Tex_Power * (-0.5 + (tex2D( _Distortion_Tex, panner286 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) , _Distortion_Switch);
				float2 ONE214 = ( lerpResult308 + lerpResult309 );
				float cos321 = cos( ( ( _Main_Tex_Rotator * PI ) / 180.0 ) );
				float sin321 = sin( ( ( _Main_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator321 = mul( ONE214 - float2( 0.5,0.5 ) , float2x2( cos321 , -sin321 , sin321 , cos321 )) + float2( 0.5,0.5 );
				float2 lerpResult411 = lerp( rotator321 , saturate( rotator321 ) , _Main_Tex_ClampSwitch);
				float4 tex2DNode1 = tex2D( _Main_Tex, lerpResult411 );
				float lerpResult409 = lerp( tex2DNode1.r , tex2DNode1.a , _Main_Tex_A_R);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float dotResult343 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult438 = smoothstep( 0.0 , 1.0 , ( 1.0 - saturate( abs( dotResult343 ) ) ));
				float temp_output_363_0 = ( pow( smoothstepResult438 , _Fresnel_power ) * ( _Fresnel_scale * 1 ) );
				float lerpResult370 = lerp( temp_output_363_0 , ( 1.0 - temp_output_363_0 ) , _Fresnel_Bokeh);
				#ifdef _FRESNEL_SWITCH_ON
				float staticSwitch372 = lerpResult370;
				#else
				float staticSwitch372 = 1.0;
				#endif
				float2 appendResult342 = (float2(_Dissolve_Tex_U_speed , _Dissolve_Tex_V_speed));
				float2 uv_Dissolve_Tex = IN.ase_texcoord2.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float cos430 = cos( ( ( _Dissolve_Tex_Rotator * PI ) / 180.0 ) );
				float sin430 = sin( ( ( _Dissolve_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator430 = mul( uv_Dissolve_Tex - float2( 0.5,0.5 ) , float2x2( cos430 , -sin430 , sin430 , cos430 )) + float2( 0.5,0.5 );
				float2 panner346 = ( 1.0 * _Time.y * appendResult342 + rotator430);
				float4 tex2DNode353 = tex2D( _Dissolve_Tex, panner346 );
				float lerpResult417 = lerp( tex2DNode353.r , tex2DNode353.a , _Dissolve_Tex_A_R);
				float five300 = texCoord288.x;
				float lerpResult351 = lerp( _Dissolve_Tex_power , five300 , _Dissolve_Tex_Custom_X);
				float smoothstepResult368 = smoothstep( ( 1.0 - _Dissolve_Tex_smooth ) , _Dissolve_Tex_smooth , saturate( ( ( lerpResult417 + 1.0 ) - ( lerpResult351 * 2.0 ) ) ));
				#ifdef _DISSOLVE_SWITCH_ON
				float staticSwitch371 = smoothstepResult368;
				#else
				float staticSwitch371 = 1.0;
				#endif
				float Three217 = ( staticSwitch372 * _Fresnel_Color.a * staticSwitch371 );
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth393 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth393 = abs( ( screenDepth393 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _SoftParticle ) );
				float soft219 = saturate( distanceDepth393 );
				float2 appendResult332 = (float2(_Mask_Tex_U_speed , _Mask_Tex_V_speed));
				float2 uv_Mask_Tex = IN.ase_texcoord2.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
				float2 panner334 = ( 1.0 * _Time.y * appendResult332 + uv_Mask_Tex);
				float cos335 = cos( ( ( _Mask_Tex_Rotator * PI ) / 180.0 ) );
				float sin335 = sin( ( ( _Mask_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator335 = mul( panner334 - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
				float2 lerpResult413 = lerp( rotator335 , saturate( rotator335 ) , _Mask_Tex_ClampSwitch);
				float4 tex2DNode327 = tex2D( _Mask_Tex, lerpResult413 );
				float lerpResult453 = lerp( tex2DNode327.r , tex2DNode327.a , _Mask_Tex_A_R);
				float two215 = lerpResult453;
				float2 appendResult420 = (float2(_Remap_Tex_U_speed , _Remap_Tex_V_speed));
				float2 uv_Remap_Tex = IN.ase_texcoord2.xy * _Remap_Tex_ST.xy + _Remap_Tex_ST.zw;
				float2 panner421 = ( 1.0 * _Time.y * appendResult420 + uv_Remap_Tex);
				float2 temp_cast_0 = (0.0).xx;
				float2 GAM_MAIN_Move446 = appendResult301;
				float2 lerpResult448 = lerp( temp_cast_0 , GAM_MAIN_Move446 , _Remap_Tex_Followl_Main_Tex);
				float cos399 = cos( ( ( _Remap_Tex_Rotator * PI ) / 180.0 ) );
				float sin399 = sin( ( ( _Remap_Tex_Rotator * PI ) / 180.0 ) );
				float2 rotator399 = mul( ( panner421 + lerpResult448 ) - float2( 0.5,0.5 ) , float2x2( cos399 , -sin399 , sin399 , cos399 )) + float2( 0.5,0.5 );
				float2 lerpResult433 = lerp( rotator399 , saturate( rotator399 ) , _Remap_Tex_ClampSwitch);
				float4 tex2DNode406 = tex2D( _Remap_Tex, ( lerpResult309 + lerpResult433 ) );
				float lerpResult432 = lerp( tex2DNode406.r , tex2DNode406.a , _Remap_Tex_A_R);
				

				float Alpha = ( IN.ase_color.a * _Main_Tex_Color.a * lerpResult409 * Three217 * soft219 * two215 * lerpResult432 );
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
	
	CustomEditor "LTY_ShaderGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;277;-2998.344,-1601.401;Inherit;False;1344.04;453.14;UV流动;17;308;306;305;302;301;300;298;297;293;289;288;287;285;284;443;446;465;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;276;-3004.946,-1143.765;Inherit;False;1363.104;498.9412;扭曲;15;310;309;307;304;303;299;292;286;283;282;281;280;278;457;458;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;336;-4033.097,437.3795;Inherit;False;2440.182;539.9002;溶解;33;346;342;340;339;217;374;371;368;367;384;364;366;360;361;357;355;417;349;351;352;347;344;348;353;416;341;430;426;428;427;429;463;464;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-2982.137,-1323.762;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;281;-2990.232,-801.7194;Inherit;False;Property;_Distortion_Tex_U_speed;Distortion_Tex_U_speed;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;426;-4012.473,816.7159;Inherit;False;Property;_Dissolve_Tex_Rotator;Dissolve_Tex_Rotator;31;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-2992.672,-726.7501;Inherit;False;Property;_Distortion_Tex_V_speed;Distortion_Tex_V_speed;40;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;301;-2746.481,-1244.668;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;428;-4013.727,890.405;Inherit;False;Constant;_Float13;Float 13;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;427;-3785.89,822.5604;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;465;-2563.128,-1180.862;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;283;-2761.389,-789.2109;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;380;-2645.585,990.184;Inherit;False;2230.076;510.9691;Gam;30;406;431;442;432;258;425;441;433;435;434;399;461;450;421;460;462;420;396;391;459;419;389;448;418;385;451;447;449;381;476;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;429;-3581.36,827.6313;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;458;-2611.134,-879.364;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;378;-3814.854,-150.4367;Inherit;False;2203.762;580.8257;菲尼尔;23;438;222;375;373;372;369;370;437;436;365;363;362;359;356;354;358;350;345;343;338;337;440;439;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-2068.261,-1221.425;Inherit;False;GAM_MAIN_Move;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;337;-3801.412,58.3049;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;451;-2423.49,1289.231;Inherit;False;Constant;_Float14;Float 14;54;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-2993.48,-1081.163;Inherit;False;0;292;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;457;-2767.974,-938.0294;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-2641.586,1332.917;Inherit;False;446;GAM_MAIN_Move;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;464;-3469.769,714.5999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-2944.959,-1393.85;Inherit;False;Property;_Main_Tex_V_speed;Main_Tex_V_speed;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;287;-2938.566,-1466.115;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-2944.966,-1538.257;Inherit;False;Property;_Main_Tex_U_speed;Main_Tex_U_speed;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;338;-3796.799,-101.4572;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;381;-2258.491,1210.566;Inherit;False;Property;_Remap_Tex_Rotator;Remap_Tex_Rotator;18;0;Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;449;-2635.152,1413.84;Inherit;False;Property;_Remap_Tex_Followl_Main_Tex;Remap_Tex_Followl_Main_Tex;14;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-2691.157,-1520.45;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;-4016.331,619.3238;Inherit;False;Property;_Dissolve_Tex_U_speed;Dissolve_Tex_U_speed;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-4024.446,708.5041;Inherit;False;Property;_Dissolve_Tex_V_speed;Dissolve_Tex_V_speed;35;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;463;-3779.769,693.5999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2691.335,-1418.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;286;-2672.053,-1077.006;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;341;-3990.308,495.4476;Inherit;False;0;353;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;385;-1973.169,1281.531;Inherit;False;Constant;_Float12;Float 12;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2640.778,1165.462;Inherit;False;Property;_Remap_Tex_U_speed;Remap_Tex_U_speed;19;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;389;-2009.005,1211.771;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;448;-2284.289,1308.933;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-2639.893,1238.641;Inherit;False;Property;_Remap_Tex_V_speed;Remap_Tex_V_speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;343;-3632.246,-111.2643;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;278;-2316.67,-912.8144;Inherit;False;250.2743;263.226;映射;1;296;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;345;-3511.218,-108.0165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;298;-2544.448,-1491.251;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;430;-3767.982,498.9272;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;396;-1810.418,1262.918;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;292;-2501.396,-1105.782;Inherit;True;Property;_Distortion_Tex;Distortion_Tex;36;1;[Header];Create;True;1;Distortion_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;391;-2568.245,1031.97;Inherit;False;0;406;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;459;-2053.545,1207.278;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;420;-2396.364,1196.357;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;342;-3722.916,624.2188;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;297;-2548.713,-1402.201;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;346;-3555.99,503.1738;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-2770.076,-1321.417;Inherit;False;five;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;296;-2251.354,-832.7675;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;350;-3374.849,-109.0945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;443;-2419.229,-1477.481;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;311;-3804.278,-629.8517;Inherit;False;1804.608;470.3787;MASK;17;215;327;413;414;325;335;324;334;331;332;333;323;322;330;329;452;453;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;462;-1719.546,1196.278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;460;-2192.546,1167.279;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;421;-2349.207,1044.887;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-2205.119,-994.6426;Inherit;False;Property;_Distortion_Tex_Power;Distortion_Tex_Power;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;353;-3368.6,468.483;Inherit;True;Property;_Dissolve_Tex;Dissolve_Tex;27;1;[Header];Create;True;1;Dissolve_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;304;-2036.803,-726.1957;Inherit;False;Property;_Distortion_Switch;Distortion_Switch;37;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;-3236.652,652.801;Inherit;False;Property;_Dissolve_Tex_A_R;Dissolve_Tex_A_R;29;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-3413.464,790.8551;Inherit;False;300;five;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-3410.201,-30.82156;Inherit;False;Constant;_RimMin;RimMin;46;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-3771.76,-395.7793;Inherit;False;Property;_Mask_Tex_V_speed;Mask_Tex_V_speed;26;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-3407.194,50.36541;Inherit;False;Constant;_RinMax;RinMax;47;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;-2271.222,-1467.394;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-2041.886,-860.3583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2375.935,-1241.67;Inherit;False;Property;_Main_Tex_Custom_ZW;Main_Tex_Custom_ZW;8;1;[Enum];Create;False;0;2;Normal;0;Custom;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-3753.508,745.8126;Inherit;False;Property;_Dissolve_Tex_power;Dissolve_Tex_power;33;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-2263.272,-1347.513;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-1983.567,-942.4549;Inherit;False;Constant;_Float4;Float 4;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;-3469.378,890.2977;Inherit;False;Property;_Dissolve_Tex_Custom_X;Dissolve_Tex_Custom_X;30;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-3770.411,-470.8815;Inherit;False;Property;_Mask_Tex_U_speed;Mask_Tex_U_speed;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;356;-3214.303,-102.1749;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;461;-2024.545,1164.279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;450;-2138.118,1042.852;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-3765.975,-325.7947;Inherit;False;Property;_Mask_Tex_Rotator;Mask_Tex_Rotator;24;0;Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-3214.908,863.3678;Inherit;False;Constant;_Float7;Float 7;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;308;-2033.979,-1467.467;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;351;-3234.978,749.1977;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;312;-1992.634,-631.6931;Inherit;False;353.1464;462.3351;旋转;6;319;318;316;317;320;321;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;323;-3767.229,-251.1057;Inherit;False;Constant;_Float11;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;332;-3564.128,-453.428;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;309;-1854.461,-868.8378;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;333;-3574.369,-318.2846;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;349;-3046.223,669.5835;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-3116.516,143.7743;Inherit;False;Property;_Fresnel_power;Fresnel_power;45;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;438;-3042.372,-102.5467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;331;-3774.49,-595.0944;Inherit;False;0;327;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;379;-4038.124,985.776;Inherit;False;1357.064;513.0515;顶点偏移;17;117;408;405;404;397;402;398;401;392;395;390;394;386;387;382;383;456;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;399;-1982.796,1041.787;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;417;-2967.53,495.3727;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;-3117.441,228.9818;Inherit;False;Property;_Fresnel_scale;Fresnel_scale;44;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-3366.821,-285.1875;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-1754.733,-1106.798;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-4019.97,1337.638;Inherit;False;Property;_WPO_Tex_U_speed;WPO_Tex_U_speed;51;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-1991.336,-426.3635;Inherit;False;Property;_Main_Tex_Rotator;Main_Tex_Rotator;10;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-3065.048,748.7742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;334;-3491.824,-590.861;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;355;-2780.357,492.9502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;359;-2839.178,-0.1377404;Inherit;False;1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;362;-2839.638,-94.73124;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;434;-1789.223,1127.729;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-1828.661,1391.364;Inherit;False;Property;_Remap_Tex_ClampSwitch;Remap_Tex_ClampSwitch;17;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-4020.07,1417.905;Inherit;False;Property;_WPO_Tex_V_speed;WPO_Tex_V_speed;52;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-2682.291,-88.52399;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;386;-3819.563,1351.923;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;318;-1945.801,-271.8814;Inherit;False;Constant;_Float6;Float 6;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;360;-2672.912,492.6289;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;387;-4015.871,1207.07;Inherit;False;0;397;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;361;-2817.052,752.7044;Inherit;False;Property;_Dissolve_Tex_smooth;Dissolve_Tex_smooth;32;0;Create;True;0;0;0;False;0;False;0.5;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;335;-3315.981,-590.5401;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;317;-1807.319,-472.5045;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;433;-1640.485,1051.195;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-1595.006,-1038.089;Inherit;False;ONE;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;476;-1414.547,1056.547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;320;-1758.598,-284.0762;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-3580.795,1020.401;Inherit;False;Property;_WPO_tex_power;WPO_tex_power;49;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;366;-2543.004,491.4722;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-1978.921,-596.9757;Inherit;False;214;ONE;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;325;-3147.291,-490.8478;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;390;-3678.016,1328.524;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-3676.302,1136.529;Inherit;False;Property;_WPO_CustomSwitch_Y;WPO_CustomSwitch_Y;48;1;[Enum];Create;True;0;2;Normal;0;Custom;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;437;-2406.976,-57.97628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;384;-2471.202,843.675;Inherit;False;864.7548;118.4831;软粒子;4;400;393;388;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;364;-2546.315,578.2346;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-2524.07,74.15598;Inherit;False;Property;_Fresnel_Bokeh;Fresnel_Bokeh;43;1;[Enum];Create;True;0;2;Fresnel;0;Bokeh;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;414;-3240.689,-419.8793;Inherit;False;Property;_Mask_Tex_ClampSwitch;Mask_Tex_ClampSwitch;22;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;436;-2537.125,-9.627012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;395;-4008.534,1029.139;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;401;-3424.758,1148.736;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;402;-3235.426,1315.685;Inherit;False;Property;_WPO_Tex_Direction;WPO_Tex_Direction;50;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;413;-2961.542,-581.2285;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;368;-2409.182,551.9802;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;406;-1276.948,1031.885;Inherit;True;Property;_Remap_Tex;Remap_Tex;13;1;[Header];Create;False;1;Remap_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;397;-3516.793,1298.851;Inherit;True;Property;_WPO_Tex;WPO_Tex;46;1;[Header];Create;True;1;Wpo_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;272;-1519.365,-574.176;Inherit;False;317.8248;263.5372;Clamp;2;314;411;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-2390.737,477.1368;Inherit;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-2348.08,-109.8452;Inherit;False;Constant;_Float9;Float 9;35;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;442;-1410.709,1379.211;Inherit;False;Property;_Remap_Tex_Desaturate;Remap_Tex_Desaturate;16;0;Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;398;-3395.739,1029.807;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;370;-2354.374,-39.74646;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2457.605,883.2485;Inherit;False;Property;_SoftParticle;SoftParticle;4;0;Create;False;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;321;-1819.908,-592.9556;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;314;-1498.292,-478.201;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;372;-2097.755,-82.22703;Inherit;False;Property;_Fresnel_Switch;Fresnel_Switch;42;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;405;-3082.053,1070.546;Inherit;False;Constant;_Float5;Float 5;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;393;-2176.349,868.8671;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;327;-2778.896,-603.2476;Inherit;True;Property;_Mask_Tex;Mask_Tex;21;1;[Header];Create;True;1;Mask_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;441;-960.3836,1038.185;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-2664.242,-405.5811;Inherit;False;Property;_Mask_Tex_A_R;Mask_Tex_A_R;23;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;373;-2382.336,172.6049;Inherit;False;Property;_Fresnel_Color;Fresnel_Color;41;2;[HDR];[Header];Create;True;1;Fresnel;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;371;-2169.855,542.6441;Inherit;False;Property;_Dissolve_Switch;Dissolve_Switch;28;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;-1521.403,-214.0435;Inherit;False;Property;_Main_Tex_ClampSwitch;Main_Tex_ClampSwitch;9;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-3084.891,1153.761;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;411;-1346.54,-529.9504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;408;-2945.351,1125.468;Inherit;False;Property;_WPO_Switch;WPO_Switch;47;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-1887.078,498.9161;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;400;-1931.391,890.4071;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-1788.698,-75.74274;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;453;-2394.517,-570.3816;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;425;-768.143,1038.969;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-1040,-176;Inherit;False;Property;_Main_Tex_A_R;Main_Tex_A_R;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-1651.099,-59.50719;Inherit;False;four;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;-692.8089,-329.4375;Inherit;False;468.0941;422.9443;ALPHA模式连到不透明度，ADD模式连到Emission;5;137;218;216;220;257;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;2;-1373.281,-753.3946;Inherit;False;Property;_Main_Tex_Color;Main_Tex_Color;6;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1.319508,1.319508,1.319508,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;456;-2750.186,1300.194;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-2183.766,-576.2316;Inherit;False;two;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1788.901,882.9451;Inherit;False;soft;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1167.583,-557.4451;Inherit;True;Property;_Main_Tex;Main_Tex;5;1;[Header];Create;False;1;Main_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-1790.037,699.8013;Inherit;False;Three;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-598.0679,1035.221;Inherit;False;Gam;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;431;-975.3214,1242.979;Inherit;False;Property;_Remap_Tex_A_R;Remap_Tex_A_R;15;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-669.8455,-233.2664;Inherit;False;258;Gam;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;409;-843.8145,-337.8983;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;-803.1,-641.7573;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;432;-765.6511,1118.276;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-675.0829,13.15239;Inherit;False;215;two;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-670.8891,-67.81808;Inherit;False;219;soft;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-2871.313,1410.971;Inherit;False;Vertex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-672.8101,-144.2242;Inherit;False;217;Three;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-508.6807,-524.9042;Inherit;False;222;four;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;3;-1332.854,-925.3873;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-350.4396,-259.8481;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-197.0443,-206.2741;Inherit;False;117;Vertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;142;235.069,-383.7109;Inherit;False;Property;_CullMode;CullMode;1;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-147.4585,-631.1379;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;475;241.5474,-204.5479;Inherit;False;Property;_Zwrite;Zwrite;3;1;[Enum];Create;False;0;2;ON;1;OFF;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;228.5842,-468.7425;Inherit;False;Property;_Dst;BlendMode;0;1;[Enum];Create;False;0;2;Add;1;Alpha;10;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;477;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;478;5.423859,-468.2598;Float;False;True;-1;2;LTY_ShaderGUI;0;13;A201-Shader/URP/LTY_多功能整合URP;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullMode;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;True;True;2;5;False;;10;True;_Dst;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;True;_Zwrite;True;3;True;_ZTestMode;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638393316110075182;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638393316092849708;  Use Shadow Threshold;0;0;Receive Shadows;0;638393316099640498;GPU Instancing;0;638393316102216753;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;False;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;479;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;480;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;481;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;482;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;483;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;484;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;485;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;486;5.423859,-468.2598;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;238;239.8492,-297.8818;Inherit;False;Property;_ZTestMode;ZTest;2;1;[Enum];Create;False;0;2;Less or Equal;4;Always;8;0;True;0;False;4;4;0;0;0;1;FLOAT;0
WireConnection;301;0;288;3
WireConnection;301;1;288;4
WireConnection;427;0;426;0
WireConnection;465;0;301;0
WireConnection;283;0;281;0
WireConnection;283;1;280;0
WireConnection;429;0;427;0
WireConnection;429;1;428;0
WireConnection;458;0;283;0
WireConnection;446;0;465;0
WireConnection;457;0;458;0
WireConnection;464;0;429;0
WireConnection;293;0;284;0
WireConnection;293;1;287;0
WireConnection;463;0;464;0
WireConnection;289;0;287;0
WireConnection;289;1;285;0
WireConnection;286;0;282;0
WireConnection;286;2;457;0
WireConnection;389;0;381;0
WireConnection;448;0;451;0
WireConnection;448;1;447;0
WireConnection;448;2;449;0
WireConnection;343;0;338;0
WireConnection;343;1;337;0
WireConnection;345;0;343;0
WireConnection;298;0;293;0
WireConnection;298;1;289;0
WireConnection;430;0;341;0
WireConnection;430;2;463;0
WireConnection;396;0;389;0
WireConnection;396;1;385;0
WireConnection;292;1;286;0
WireConnection;459;0;448;0
WireConnection;420;0;419;0
WireConnection;420;1;418;0
WireConnection;342;0;340;0
WireConnection;342;1;339;0
WireConnection;346;0;430;0
WireConnection;346;2;342;0
WireConnection;300;0;288;1
WireConnection;296;0;292;1
WireConnection;350;0;345;0
WireConnection;443;0;298;0
WireConnection;462;0;396;0
WireConnection;460;0;459;0
WireConnection;421;0;391;0
WireConnection;421;2;420;0
WireConnection;353;1;346;0
WireConnection;305;0;443;0
WireConnection;305;1;297;0
WireConnection;307;0;299;0
WireConnection;307;1;296;0
WireConnection;302;0;297;0
WireConnection;302;1;301;0
WireConnection;356;0;350;0
WireConnection;461;0;462;0
WireConnection;450;0;421;0
WireConnection;450;1;460;0
WireConnection;308;0;305;0
WireConnection;308;1;302;0
WireConnection;308;2;306;0
WireConnection;351;0;348;0
WireConnection;351;1;347;0
WireConnection;351;2;344;0
WireConnection;332;0;330;0
WireConnection;332;1;329;0
WireConnection;309;0;303;0
WireConnection;309;1;307;0
WireConnection;309;2;304;0
WireConnection;333;0;322;0
WireConnection;438;0;356;0
WireConnection;438;1;439;0
WireConnection;438;2;440;0
WireConnection;399;0;450;0
WireConnection;399;2;461;0
WireConnection;417;0;353;1
WireConnection;417;1;353;4
WireConnection;417;2;416;0
WireConnection;324;0;333;0
WireConnection;324;1;323;0
WireConnection;310;0;308;0
WireConnection;310;1;309;0
WireConnection;357;0;351;0
WireConnection;357;1;352;0
WireConnection;334;0;331;0
WireConnection;334;2;332;0
WireConnection;355;0;417;0
WireConnection;355;1;349;0
WireConnection;359;0;358;0
WireConnection;362;0;438;0
WireConnection;362;1;354;0
WireConnection;434;0;399;0
WireConnection;363;0;362;0
WireConnection;363;1;359;0
WireConnection;386;0;383;0
WireConnection;386;1;382;0
WireConnection;360;0;355;0
WireConnection;360;1;357;0
WireConnection;335;0;334;0
WireConnection;335;2;324;0
WireConnection;317;0;316;0
WireConnection;433;0;399;0
WireConnection;433;1;434;0
WireConnection;433;2;435;0
WireConnection;214;0;310;0
WireConnection;476;0;309;0
WireConnection;476;1;433;0
WireConnection;320;0;317;0
WireConnection;320;1;318;0
WireConnection;366;0;360;0
WireConnection;325;0;335;0
WireConnection;390;0;387;0
WireConnection;390;2;386;0
WireConnection;437;0;363;0
WireConnection;364;0;361;0
WireConnection;436;0;363;0
WireConnection;413;0;335;0
WireConnection;413;1;325;0
WireConnection;413;2;414;0
WireConnection;368;0;366;0
WireConnection;368;1;364;0
WireConnection;368;2;361;0
WireConnection;406;1;476;0
WireConnection;397;1;390;0
WireConnection;398;0;392;0
WireConnection;398;1;395;2
WireConnection;398;2;394;0
WireConnection;370;0;437;0
WireConnection;370;1;436;0
WireConnection;370;2;365;0
WireConnection;321;0;319;0
WireConnection;321;2;320;0
WireConnection;314;0;321;0
WireConnection;372;1;369;0
WireConnection;372;0;370;0
WireConnection;393;0;388;0
WireConnection;327;1;413;0
WireConnection;441;0;406;0
WireConnection;441;1;442;0
WireConnection;371;1;367;0
WireConnection;371;0;368;0
WireConnection;404;0;398;0
WireConnection;404;1;401;0
WireConnection;404;2;397;0
WireConnection;404;3;402;0
WireConnection;411;0;321;0
WireConnection;411;1;314;0
WireConnection;411;2;412;0
WireConnection;408;1;405;0
WireConnection;408;0;404;0
WireConnection;374;0;372;0
WireConnection;374;1;373;4
WireConnection;374;2;371;0
WireConnection;400;0;393;0
WireConnection;375;0;372;0
WireConnection;375;1;371;0
WireConnection;375;2;373;0
WireConnection;453;0;327;1
WireConnection;453;1;327;4
WireConnection;453;2;452;0
WireConnection;425;0;441;0
WireConnection;222;0;375;0
WireConnection;456;0;408;0
WireConnection;215;0;453;0
WireConnection;219;0;400;0
WireConnection;1;1;411;0
WireConnection;217;0;374;0
WireConnection;258;0;425;0
WireConnection;409;0;1;1
WireConnection;409;1;1;4
WireConnection;409;2;410;0
WireConnection;474;0;2;0
WireConnection;474;1;1;0
WireConnection;432;0;406;1
WireConnection;432;1;406;4
WireConnection;432;2;431;0
WireConnection;117;0;456;0
WireConnection;137;0;3;4
WireConnection;137;1;2;4
WireConnection;137;2;409;0
WireConnection;137;3;218;0
WireConnection;137;4;220;0
WireConnection;137;5;216;0
WireConnection;137;6;432;0
WireConnection;4;0;3;0
WireConnection;4;1;474;0
WireConnection;4;2;223;0
WireConnection;4;3;257;0
WireConnection;478;2;4;0
WireConnection;478;3;137;0
WireConnection;478;5;118;0
ASEEND*/
//CHKSM=567BA3C98F805AE55059702113032842DBC46C89