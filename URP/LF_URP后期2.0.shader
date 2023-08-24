// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/后期处理/URP后期2.0"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Float20("色阶黑", Float) = 0
		_Float19("色阶白", Float) = 1
		_Float28("暗角强度", Float) = 0
		_Float36("暗角阈值", Range( 0 , 1)) = 0
		_Float6("中心位置U", Range( -0.5 , 0.5)) = 0
		_Float7("中心位置V", Range( -0.5 , 0.5)) = 0
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_TextureSample1("Mask", 2D) = "white" {}
		[Enum(R,0,A,1)]_Float30("Mask通道", Float) = 3
		[Toggle]_Float24("OneMinusMask", Float) = 0
		_MaskPower1("MaskPower", Float) = 1
		_Float9("Msak强度", Float) = 1
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_Float11("色散强度", Float) = 0
		[Enum(Material,0,Custom1y,1)]_Float17("色散控制方式", Float) = 0
		_Float5("模糊缩放", Float) = 0
		[Enum(Material,0,Custom1x,1)]_Float18("模糊控制方式", Float) = 0
		_Float8("色散模糊比重", Range( 0 , 1)) = 1
		_Float27("放射纹理强度", Float) = 0
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Toggle][Space(10) ]_Float4("黑白闪开关", Float) = 0
		[Enum(Material,0,Custom1w,1)]_Float10("黑白闪开关控制方式", Float) = 0
		_Color0("黑白闪颜色1", Color) = (1,1,1,1)
		_Color1("黑白闪颜色2", Color) = (0,0,0,1)
		[Toggle]_Float33("黑白切换", Float) = 0
		[Enum(Material,0,ParticleAlphy,1)]_Float34("黑白切换控制方式", Float) = 0
		_TextureSample0("黑白闪纹理", 2D) = "white" {}
		[Enum(U,0,V,1)]_Float31("极坐标方向", Float) = 0
		[Enum(Material,0,Custom1z,1)]_Float32("黑白闪流动控制方式", Float) = 0
		_Float21("黑白闪纹理强度", Range( 0 , 1)) = 0
		[HideInInspector]_TextureSample0_ST("_TextureSample0_ST", Vector) = (10,0.4,0,0)
		_Float2("黑白范围", Range( 0 , 1)) = 1
		_Float3("黑白过度", Range( 0 , 0.1)) = 0
		[HideInInspector]_TextureSample1_ST("_TextureSample1_ST", Vector) = (1,1,0,0)
		[Header(______________________________________________________________________________________________________________________________)][Enum(Partercal,0,Material,1)][Space(10) ]_Float25("震屏测试(Custom2xy_UV震频,zw_UV振幅)", Float) = 1
		_Float15("U震频测试(随数值变化往复震动)", Float) = 0
		_Float14("U振幅测试", Range( 0 , 1)) = 0
		_Float12("V振频测试(随数值变化往复震动)", Float) = 0
		_Float13("V振幅测试", Range( 0 , 1)) = 0
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_TextureSample2("肌理图", 2D) = "white" {}
		_Float26("旋转肌理图", Range( 0 , 1)) = 0
		[ASEEnd]_Float23("肌理强度", Range( -1 , 1)) = 0
		[HideInInspector]_TextureSample2_ST("_TextureSample2_ST", Vector) = (1,1,0,0)

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent+1000" }
		
		Cull Off
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

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
			Tags { "LightMode"="Grab" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999

			
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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color1;
			float4 _TextureSample1_ST;
			float4 _TextureSample2_ST;
			float4 _TextureSample0_ST;
			float4 _Color0;
			float _Float18;
			float _Float11;
			float _Float17;
			float _Float8;
			float _Float36;
			float _Float2;
			float _Float3;
			float _Float21;
			float _Float33;
			float _Float34;
			float _Float4;
			float _Float10;
			float _Float5;
			float _Float9;
			float _Float24;
			float _Float20;
			float _Float28;
			float _Float26;
			float _Float23;
			float _Float15;
			float _Float12;
			float _Float14;
			float _MaskPower1;
			float _Float13;
			float _Float6;
			float _Float7;
			float _Float31;
			float _Float32;
			float _Float27;
			float _Float30;
			float _Float25;
			float _Float19;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _TextureSample2;
			sampler2D _AfterPostProcessTexture;
			sampler2D _TextureSample0;
			sampler2D _TextureSample1;


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
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord4 = v.ase_texcoord2;
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				o.ase_texcoord6 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
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

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
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
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult439 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult393 = (float2(( ase_screenPosNorm.x * ( _ScreenParams.x / _ScreenParams.y ) ) , ase_screenPosNorm.y));
				float cos449 = cos( ( _Float26 * PI ) );
				float sin449 = sin( ( _Float26 * PI ) );
				float2 rotator449 = mul( appendResult393 - float2( 0,0 ) , float2x2( cos449 , -sin449 , sin449 , cos449 )) + float2( 0,0 );
				float2 appendResult287 = (float2(_TextureSample2_ST.x , _TextureSample2_ST.y));
				float2 appendResult288 = (float2(_TextureSample2_ST.z , _TextureSample2_ST.w));
				float4 tex2DNode278 = tex2D( _TextureSample2, (rotator449*appendResult287 + appendResult288) );
				float4 temp_cast_0 = (( tex2DNode278.r * _Float23 )).xxxx;
				float4 texCoord147 = IN.ase_texcoord4;
				texCoord147.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult218 = (float4(_Float15 , _Float12 , _Float14 , _Float13));
				float4 lerpResult333 = lerp( texCoord147 , appendResult218 , _Float25);
				float4 break224 = lerpResult333;
				float2 appendResult421 = (float2(( sin( break224.x ) * break224.z * 0.5 ) , ( sin( break224.y ) * break224.w * 0.5 )));
				float2 clampResult422 = clamp( appendResult421 , float2( -1,-1 ) , float2( 1,1 ) );
				float2 zhenpingUV409 = ((ase_grabScreenPosNorm).xy*1.0 + clampResult422);
				float2 appendResult65 = (float2(_Float6 , _Float7));
				float2 jizuobiaoUV274 = ( zhenpingUV409 - appendResult65 );
				float2 texCoord257 = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break245 = float2( 1,0 );
				float cos248 = cos( ( length( (texCoord257*2.0 + -1.0) ) * break245.y ) );
				float sin248 = sin( ( length( (texCoord257*2.0 + -1.0) ) * break245.y ) );
				float2 rotator248 = mul( jizuobiaoUV274 - float2( 0.5,0.5 ) , float2x2( cos248 , -sin248 , sin248 , cos248 )) + float2( 0.5,0.5 );
				float2 temp_output_262_0 = (rotator248*2.0 + -1.0);
				float2 break255 = temp_output_262_0;
				float temp_output_261_0 = ( ( atan2( break255.y , break255.x ) / ( 2.0 * PI ) ) + 0.5 );
				float temp_output_258_0 = pow( length( temp_output_262_0 ) , break245.x );
				float2 appendResult253 = (float2(temp_output_261_0 , temp_output_258_0));
				float2 appendResult247 = (float2(temp_output_258_0 , temp_output_261_0));
				float2 lerpResult373 = lerp( appendResult253 , appendResult247 , _Float31);
				float2 appendResult154 = (float2(_TextureSample0_ST.z , _TextureSample0_ST.w));
				float4 texCoord150 = IN.ase_texcoord6;
				texCoord150.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult153 = (float2(_TextureSample0_ST.z , texCoord150.z));
				float2 lerpResult376 = lerp( appendResult154 , appendResult153 , _Float32);
				float4 appendResult155 = (float4(_TextureSample0_ST.xy , lerpResult376));
				float4 break242 = appendResult155;
				float2 appendResult252 = (float2(break242.x , break242.y));
				float2 appendResult241 = (float2(break242.z , break242.w));
				float2 appendResult243 = (float2((lerpResult373*appendResult252 + appendResult241).x , 0.0));
				float jizuobiaowenli423 = tex2D( _TextureSample0, appendResult243 ).r;
				float2 temp_cast_2 = (jizuobiaowenli423).xx;
				float2 appendResult166 = (float2(_TextureSample1_ST.x , _TextureSample1_ST.y));
				float2 appendResult167 = (float2(_TextureSample1_ST.z , _TextureSample1_ST.w));
				float4 tex2DNode130 = tex2D( _TextureSample1, (zhenpingUV409*appendResult166 + appendResult167) );
				float lerpResult365 = lerp( tex2DNode130.r , tex2DNode130.a , _Float30);
				float lerpResult400 = lerp( lerpResult365 , ( 1.0 - lerpResult365 ) , _Float24);
				float mask173 = saturate( ( pow( lerpResult400 , _MaskPower1 ) * _Float9 ) );
				float2 lerpResult429 = lerp( zhenpingUV409 , temp_cast_2 , ( _Float27 * 0.01 * mask173 ));
				float2 jizuobiaopianyi433 = lerpResult429;
				half2 fangsheUV74 = ( jizuobiaopianyi433 - (float2( 0,0 ) + (appendResult65 - float2( -0.5,-0.5 )) * (float2( 1,1 ) - float2( 0,0 )) / (float2( 0.5,0.5 ) - float2( -0.5,-0.5 ))) );
				float4 texCoord144 = IN.ase_texcoord6;
				texCoord144.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult387 = lerp( _Float5 , texCoord144.x , _Float18);
				float2 temp_output_51_0 = ( fangsheUV74 * float2( 0.01,0.01 ) * lerpResult387 );
				float2 temp_output_72_0 = ( jizuobiaopianyi433 - temp_output_51_0 );
				float4 tex2DNode295 = tex2D( _AfterPostProcessTexture, temp_output_72_0 );
				float4 texCoord186 = IN.ase_texcoord6;
				texCoord186.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult385 = lerp( _Float11 , texCoord186.y , _Float17);
				float2 temp_output_189_0 = ( lerpResult385 * float2( 0.01,0.01 ) * fangsheUV74 );
				float2 temp_output_190_0 = ( jizuobiaopianyi433 - temp_output_189_0 );
				float2 temp_output_191_0 = ( temp_output_190_0 - temp_output_189_0 );
				float4 appendResult60 = (float4(tex2D( _AfterPostProcessTexture, temp_output_190_0 ).r , tex2D( _AfterPostProcessTexture, temp_output_191_0 ).g , tex2D( _AfterPostProcessTexture, ( temp_output_191_0 - temp_output_189_0 ) ).b , 1.0));
				float2 temp_output_80_0 = ( temp_output_72_0 - temp_output_51_0 );
				float2 temp_output_81_0 = ( temp_output_80_0 - temp_output_51_0 );
				float2 temp_output_96_0 = ( temp_output_81_0 - temp_output_51_0 );
				float2 temp_output_97_0 = ( temp_output_96_0 - temp_output_51_0 );
				float2 temp_output_98_0 = ( temp_output_97_0 - temp_output_51_0 );
				float2 temp_output_99_0 = ( temp_output_98_0 - temp_output_51_0 );
				float2 temp_output_100_0 = ( temp_output_99_0 - temp_output_51_0 );
				float2 temp_output_101_0 = ( temp_output_100_0 - temp_output_51_0 );
				float2 temp_output_103_0 = ( temp_output_101_0 - temp_output_51_0 );
				float2 temp_output_102_0 = ( temp_output_103_0 - temp_output_51_0 );
				float2 temp_output_105_0 = ( temp_output_102_0 - temp_output_51_0 );
				float2 temp_output_104_0 = ( temp_output_105_0 - temp_output_51_0 );
				float2 temp_output_107_0 = ( temp_output_104_0 - temp_output_51_0 );
				float2 temp_output_106_0 = ( temp_output_107_0 - temp_output_51_0 );
				float2 temp_output_109_0 = ( temp_output_106_0 - temp_output_51_0 );
				float2 temp_output_112_0 = ( temp_output_109_0 - temp_output_51_0 );
				float2 temp_output_113_0 = ( temp_output_112_0 - temp_output_51_0 );
				float2 temp_output_115_0 = ( temp_output_113_0 - temp_output_51_0 );
				float4 appendResult123 = (float4(( ( ( tex2DNode295 + tex2D( _AfterPostProcessTexture, temp_output_80_0 ) + tex2D( _AfterPostProcessTexture, temp_output_81_0 ) + tex2D( _AfterPostProcessTexture, temp_output_96_0 ) + tex2D( _AfterPostProcessTexture, temp_output_97_0 ) + tex2D( _AfterPostProcessTexture, temp_output_98_0 ) + tex2D( _AfterPostProcessTexture, temp_output_99_0 ) + tex2D( _AfterPostProcessTexture, temp_output_100_0 ) + tex2D( _AfterPostProcessTexture, temp_output_101_0 ) + tex2D( _AfterPostProcessTexture, temp_output_103_0 ) ) + ( tex2D( _AfterPostProcessTexture, temp_output_102_0 ) + tex2D( _AfterPostProcessTexture, temp_output_105_0 ) + tex2D( _AfterPostProcessTexture, temp_output_104_0 ) + tex2D( _AfterPostProcessTexture, temp_output_107_0 ) + tex2D( _AfterPostProcessTexture, temp_output_106_0 ) + tex2D( _AfterPostProcessTexture, temp_output_109_0 ) + tex2D( _AfterPostProcessTexture, temp_output_112_0 ) + tex2D( _AfterPostProcessTexture, temp_output_113_0 ) + tex2D( _AfterPostProcessTexture, temp_output_115_0 ) + tex2D( _AfterPostProcessTexture, ( temp_output_115_0 - temp_output_51_0 ) ) ) ) / 20.0 ).rgb , 1.0));
				float4 lerpResult128 = lerp( appendResult60 , appendResult123 , _Float8);
				float4 lerpResult131 = lerp( tex2DNode295 , lerpResult128 , mask173);
				float4 mohu194 = lerpResult131;
				float3 desaturateInitialColor25 = mohu194.xyz;
				float desaturateDot25 = dot( desaturateInitialColor25, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar25 = lerp( desaturateInitialColor25, desaturateDot25.xxx, 1.0 );
				float temp_output_27_0 = (desaturateVar25).x;
				float lerpResult233 = lerp( 1.0 , jizuobiaowenli423 , _Float21);
				float lerpResult181 = lerp( temp_output_27_0 , lerpResult233 , mask173);
				float smoothstepResult11 = smoothstep( _Float2 , ( _Float2 + _Float3 ) , ( temp_output_27_0 + ( temp_output_27_0 * lerpResult181 ) ));
				float lerpResult378 = lerp( _Float33 , IN.ase_color.a , _Float34);
				float lerpResult32 = lerp( smoothstepResult11 , ( 1.0 - smoothstepResult11 ) , lerpResult378);
				float4 lerpResult15 = lerp( _Color0 , _Color1 , lerpResult32);
				float4 texCoord425 = IN.ase_texcoord6;
				texCoord425.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult381 = lerp( _Float4 , texCoord425.w , _Float10);
				float4 lerpResult225 = lerp( mohu194 , lerpResult15 , lerpResult381);
				float4 temp_cast_7 = (_Float20).xxxx;
				float4 temp_cast_8 = (_Float19).xxxx;
				float4 lerpResult283 = lerp( temp_cast_0 , (temp_cast_7 + (lerpResult225 - float4( 0,0,0,0 )) * (temp_cast_8 - temp_cast_7) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) , saturate( ( tex2DNode278.r + _Float23 ) ));
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( pow( (1.0 + (distance( appendResult439 , float2( 0.5,0.5 ) ) - 0.0) * (0.0 - 1.0) / (( 1.0 - _Float36 ) - 0.0)) , _Float28 ) * lerpResult283 ).rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color1;
			float4 _TextureSample1_ST;
			float4 _TextureSample2_ST;
			float4 _TextureSample0_ST;
			float4 _Color0;
			float _Float18;
			float _Float11;
			float _Float17;
			float _Float8;
			float _Float36;
			float _Float2;
			float _Float3;
			float _Float21;
			float _Float33;
			float _Float34;
			float _Float4;
			float _Float10;
			float _Float5;
			float _Float9;
			float _Float24;
			float _Float20;
			float _Float28;
			float _Float26;
			float _Float23;
			float _Float15;
			float _Float12;
			float _Float14;
			float _MaskPower1;
			float _Float13;
			float _Float6;
			float _Float7;
			float _Float31;
			float _Float32;
			float _Float27;
			float _Float30;
			float _Float25;
			float _Float19;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				
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

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
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
			
			#if defined(TESSELLATION_ON)
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

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

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
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color1;
			float4 _TextureSample1_ST;
			float4 _TextureSample2_ST;
			float4 _TextureSample0_ST;
			float4 _Color0;
			float _Float18;
			float _Float11;
			float _Float17;
			float _Float8;
			float _Float36;
			float _Float2;
			float _Float3;
			float _Float21;
			float _Float33;
			float _Float34;
			float _Float4;
			float _Float10;
			float _Float5;
			float _Float9;
			float _Float24;
			float _Float20;
			float _Float28;
			float _Float26;
			float _Float23;
			float _Float15;
			float _Float12;
			float _Float14;
			float _MaskPower1;
			float _Float13;
			float _Float6;
			float _Float7;
			float _Float31;
			float _Float32;
			float _Float27;
			float _Float30;
			float _Float25;
			float _Float19;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
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

			#if defined(TESSELLATION_ON)
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

				
				float Alpha = 1;
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
Version=18912
0;0;1920;1019;1125.592;584.2808;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;448;1215.553,-826.0242;Inherit;False;890.0149;312.6121;暗角;8;445;444;443;442;441;440;439;438;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;277;-3574.049,-644.6473;Inherit;False;2372.565;482.3597; 震屏;20;334;418;421;413;422;414;2;409;420;417;416;419;333;224;147;205;207;210;203;218;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;160;-3150.844,500.2955;Inherit;False;3089.073;3926.05;色散模糊;58;52;144;51;72;80;81;96;97;110;120;122;129;124;121;123;128;131;114;98;99;100;101;103;102;105;104;107;106;109;112;113;115;111;73;174;295;296;297;298;299;300;301;302;303;304;305;306;307;308;312;313;314;315;316;317;388;387;412;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;289;-595.1241,-130.7973;Inherit;False;1871.854;600.1165;肌理;17;288;287;286;281;278;285;395;394;282;391;393;389;392;390;449;450;451;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;272;-2877.125,-1510.355;Inherit;False;3182.125;518.736;极坐标;35;377;153;154;8;150;376;155;267;245;259;275;246;236;257;260;263;258;243;423;6;253;373;252;261;262;237;247;242;256;374;244;241;239;248;255;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;140;-1185.668,-908.265;Inherit;False;1744.32;761.6495;黑白闪;28;23;28;11;379;34;30;14;13;235;424;234;233;29;31;181;177;15;32;16;383;382;425;380;378;381;195;27;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;276;-3501.865,-149.8065;Inherit;False;1264.625;584.4983;中心偏移;16;433;429;274;65;411;435;62;63;64;434;74;431;432;430;428;427;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;193;-2168.929,-146.4858;Inherit;False;1559.412;630.3956;色散;14;60;188;186;192;191;190;189;310;309;385;386;311;436;437;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;178;-3300.495,-975.2911;Inherit;False;2083.046;322.7746;Mask;17;167;166;366;398;400;401;133;165;410;365;130;164;399;142;132;173;402;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-2189.933,694.4026;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;313;-1750.236,4087.303;Inherit;True;Property;_TextureSample20;Texture Sample 20;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-1110.938,1139.126;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-1954.2,1888.667;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1984.2,1677.142;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-1958.218,3127.224;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;387;-2632.891,1025.366;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1050.529,1293.115;Inherit;False;Property;_Float8;色散模糊比重;15;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2408.468,764.531;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0.01,0.01;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;-941.3282,1013.086;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;317;-1774.12,2573.504;Inherit;True;Property;_TextureSample24;Texture Sample 24;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;243;-356.0923,-1327.024;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-206.8126,-1366.753;Inherit;True;Property;_TextureSample0;黑白闪纹理;23;0;Create;False;0;0;0;False;0;False;-1;None;2ec6e1532acb1254f9f3797b5d82db44;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;304;-1745.315,2332.177;Inherit;True;Property;_TextureSample11;Texture Sample 11;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;131;-243.7721,728.1776;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;295;-1858.179,656.0292;Inherit;True;Global;_AfterPostProcessTexture;_AfterPostProcessTexture;40;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;306;-1792.741,3134.336;Inherit;True;Property;_TextureSample13;Texture Sample 13;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-936.3095,1133.802;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;299;-1791.849,1423.085;Inherit;True;Property;_TextureSample6;Texture Sample 6;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;257;-2846.852,-1420.657;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-1129.497,1005.594;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;236;-2619.465,-1418.14;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-2283.798,-1436.949;Inherit;False;274;jizuobiaoUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;253;-1091.32,-1465.672;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-1986.674,1226.774;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;-1965.299,3474.696;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1333.418,2546.186;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-1956.674,1438.3;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-409.5116,979.1448;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;315;-1762.789,3692.139;Inherit;True;Property;_TextureSample22;Texture Sample 22;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;388;-2916.668,1246.983;Inherit;False;Property;_Float18;模糊控制方式;14;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;312;-1750.688,4199.092;Inherit;True;Property;_TextureSample19;Texture Sample 19;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-24.45774,719.3594;Inherit;False;mohu;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;-1954.141,838.848;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-1983.715,4065.675;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;314;-1780.895,3885.381;Inherit;True;Property;_TextureSample21;Texture Sample 21;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;431;-3244.572,83.11942;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;434;-2624.473,-66.38035;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1293.191,1009.231;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-1968.117,2780.788;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-1993.348,4217.503;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2965.327,959.1124;Inherit;False;Property;_Float5;模糊缩放;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;263;-1566.03,-1348.6;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;-810.4099,1016.846;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;2;-2238.715,-529.6484;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;316;-1800.95,2989.175;Inherit;True;Property;_TextureSample23;Texture Sample 23;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-1935.642,2982.417;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;305;-1777.475,2785.074;Inherit;True;Property;_TextureSample12;Texture Sample 12;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-1986.267,3870.031;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;297;-1747.486,1031.258;Inherit;True;Property;_TextureSample4;Texture Sample 4;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-1955.666,3322.868;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;117.0809,-1345.892;Inherit;False;jizuobiaowenli;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;245;-2393.959,-1285.453;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-1670.399,-900.8158;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-1329.033,-1203.623;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;255;-1664.204,-1448.082;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;258;-1333.69,-1307.186;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;244;-1519.204,-1451.082;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;164;-2843.692,-905.1436;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-1956.026,2209.568;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;242;-1101.803,-1201.052;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;301;-1783.758,1838.815;Inherit;True;Property;_TextureSample8;Texture Sample 8;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;241;-880.0314,-1154.114;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;239;-697.8506,-1328.701;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;442;1601.568,-761.0242;Inherit;False;2;0;FLOAT2;0.5,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;413;-1985.411,-478.3803;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;248;-2091.005,-1386.644;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;443;1784.568,-596.0241;Inherit;False;Property;_Float28;暗角强度;2;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-3448.669,157.2202;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;438;1232.553,-776.0242;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;2129.913,-307.9202;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;441;1570.827,-646.4122;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;439;1469.568,-768.0242;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;440;1259.827,-593.4122;Inherit;False;Property;_Float36;暗角阈值;3;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;247;-1083.077,-1371.175;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-3233.366,-253.5867;Inherit;False;Property;_Float25;震屏测试(Custom2xy_UV震频,zw_UV振幅);31;2;[Header];[Enum];Create;False;1;______________________________________________________________________________________________________________________________;2;Partercal;0;Material;1;0;False;1;Space(10) ;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;451;-375.4916,200.9191;Inherit;False;Property;_Float26;旋转肌理图;37;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;278;547.4868,-40.61064;Inherit;True;Property;_TextureSample2;肌理图;36;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;285;353.601,-11.72905;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;165;-3279.363,-849.9816;Inherit;False;Property;_TextureSample1_ST;_TextureSample1_ST;30;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;267;-2588.192,-1285.985;Inherit;False;Constant;_Vector3;Vector 3;35;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;374;-1109.39,-1274.936;Inherit;False;Property;_Float31;极坐标方向;24;1;[Enum];Create;False;0;2;U;0;V;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;-3076.753,-914.827;Inherit;False;409;zhenpingUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;376;-1541.617,-1180.959;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;150;-2835.901,-1180.734;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;298;-1745.505,1213.454;Inherit;True;Property;_TextureSample5;Texture Sample 5;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;142;-1541.096,-902.4807;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-2023.562,-1108.209;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1780.747,-1081.958;Inherit;False;Property;_Float32;黑白闪流动控制方式;25;1;[Enum];Create;False;0;2;Material;0;Custom1z;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;246;-2425.016,-1418.635;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;-3378.469,-14.37949;Inherit;False;423;jizuobiaowenli;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;262;-1898.411,-1387.625;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;300;-1770.796,1630.695;Inherit;True;Property;_TextureSample7;Texture Sample 7;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;237;-507.5171,-1330.032;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;167;-3042.959,-750.5533;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-1991.415,3728.486;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-1408.833,-901.5778;Inherit;False;mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;8;-2260.959,-1228.549;Inherit;False;Property;_TextureSample0_ST;_TextureSample0_ST;27;1;[HideInInspector];Create;False;0;0;0;False;0;False;10,0.4,0,0;30,0.4,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;399;-2158.725,-837.5374;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;260;-1691.272,-1304.552;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;427;-3353.771,-110.5793;Inherit;False;409;zhenpingUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-1976.776,2038.424;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;261;-1259.907,-1450.782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;256;-1390.207,-1450.082;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;252;-876.5214,-1305.368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;303;-1735.311,2162.847;Inherit;True;Property;_TextureSample10;Texture Sample 10;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;365;-2325.645,-898.7244;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;402;-1813.867,-897.9911;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-625.9973,968.3058;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-1922.208,2586.878;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;449;136.7076,-35.68084;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-2620.199,146.033;Inherit;False;jizuobiaoUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-761.5256,116.0983;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-1501.437,-56.81304;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;309;-1141.971,275.0348;Inherit;True;Property;_TextureSample16;Texture Sample 16;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;435;-2882.037,247.7906;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;2;FLOAT2;0.5,0.5;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-2266.26,-1349.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-1345.44,97.43155;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;395;1092.317,178.6203;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-2099.045,-34.58498;Inherit;False;Property;_Float11;色散强度;11;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-2082.021,250.2689;Inherit;False;Property;_Float17;色散控制方式;12;1;[Enum];Create;False;0;2;Material;0;Custom1y;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-1163.93,-806.8636;Inherit;False;194;mohu;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-2422.917,-73.33616;Half;False;fangsheUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;310;-1148.78,92.81969;Inherit;True;Property;_TextureSample17;Texture Sample 17;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;381;359.7252,-360.8229;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;166;-3046.974,-840.1501;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-1838.775,124.4086;Inherit;False;74;fangsheUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;307;-1795.329,3300.728;Inherit;True;Property;_TextureSample14;Texture Sample 14;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;16;26.73634,-640.7651;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;302;-1749.425,2031.677;Inherit;True;Property;_TextureSample9;Texture Sample 9;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-1652.617,-23.77729;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0.01,0.01;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1086.699,-317.5574;Inherit;False;Property;_Float2;黑白范围;28;0;Create;False;0;0;0;False;0;False;1;0.655;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-714.2914,-296.4837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-1086.302,-656.4102;Inherit;False;Constant;_Float22;Float 22;34;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;-3032.21,1041.225;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;382;187.4887,-417.3859;Inherit;False;Property;_Float4;黑白闪开关;17;2;[Header];[Toggle];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-3554.503,-512.605;Inherit;False;Property;_Float15;U震频测试(随数值变化往复震动);32;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;412;-2421.654,654.626;Inherit;False;433;jizuobiaopianyi;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-2979.506,623.9093;Inherit;False;74;fangsheUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;192;-1315.44,308.9566;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;283;1304.187,-255.5541;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;287;-129.1561,254.1237;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-3411.62,348.2349;Inherit;False;Property;_Float7;中心位置V;5;0;Create;False;0;0;0;False;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;394;927.2416,176.0205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;286;-524.1252,273.5826;Inherit;False;Property;_TextureSample2_ST;_TextureSample2_ST;39;1;[HideInInspector];Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;282;537.0048,241.6402;Inherit;False;Property;_Float23;肌理强度;38;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;393;-86.65604,-62.72879;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;225;839.3356,-491.6484;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;27;-811.1209,-809.379;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;391;-358.3563,111.4712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;433;-2882.373,-50.14769;Inherit;False;jizuobiaopianyi;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;229;1071.122,-479.108;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;1,1,1,1;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;-233.5563,-93.92885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;385;-1831.437,-19.79293;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;-1811.573,-104.6846;Inherit;False;433;jizuobiaopianyi;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;910.9625,-19.84981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;390;-552.0563,90.67123;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;232;830.1223,-374.107;Inherit;False;Property;_Float20;色阶黑;0;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;186;-2121.656,62.98188;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;231;818.1223,-262.1065;Inherit;False;Property;_Float19;色阶白;1;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;389;-574.1561,-90.02885;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;32;233.6891,-671.4832;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;288;-115.156,343.1234;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DesaturateOpNode;25;-992.2376,-804.3632;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-3544.768,-250.4598;Inherit;False;Property;_Float13;V振幅测试;35;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;409;-1396.816,-450.3758;Inherit;False;zhenpingUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1799.046,-773.1957;Inherit;False;Property;_Float9;Msak强度;10;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3405.62,255.2345;Inherit;False;Property;_Float6;中心位置U;4;0;Create;False;0;0;0;False;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-222.0997,-866.98;Inherit;False;Property;_Color1;黑白闪颜色2;20;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;28.3742,-857.6399;Inherit;False;Property;_Color0;黑白闪颜色1;19;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;197;618.597,-698.6054;Inherit;False;194;mohu;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-1176.653,-491.0856;Inherit;False;Property;_Float21;黑白闪纹理强度;26;0;Create;False;0;0;0;False;0;False;0;0.84;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-3561.017,-418.3958;Inherit;False;Property;_Float12;V振频测试(随数值变化往复震动);34;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1110.799,-232.4574;Inherit;False;Property;_Float3;黑白过度;29;0;Create;False;0;0;0;False;0;False;0;0.0628;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;218;-3221.729,-417.3526;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-3449.971,85.72037;Inherit;False;Property;_Float27;放射纹理强度;16;0;Create;False;0;0;0;False;0;False;0;3.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;373;-876.3893,-1432.937;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;296;-1761.444,848.3954;Inherit;True;Property;_TextureSample3;Texture Sample 3;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;34;-332.5226,-448.7091;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;379;-224.4298,-550.09;Inherit;False;Property;_Float33;黑白切换;21;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;-2393.538,-285.1124;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;444;1749.827,-759.4122;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-2031.626,-1199.451;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;308;-1783.987,3452.971;Inherit;True;Property;_TextureSample15;Texture Sample 15;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;425;-49.87839,-422.0964;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;233;-840.3687,-620.8506;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;115.5112,-245.5841;Inherit;False;Property;_Float10;黑白闪开关控制方式;18;1;[Enum];Create;False;0;2;Material;0;Custom1w;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;-3068.459,239.5778;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-1924.141,1050.373;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;130;-2658.82,-928.6397;Inherit;True;Property;_TextureSample1;Mask;6;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;-1;None;8c4a7fca2884fab419769ccc0355c0c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-1954.683,2385.25;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-2866.91,149.3548;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;15;386.9319,-748.0498;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;11;-224.9848,-678.8261;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-362.5193,-781.4708;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-3555.552,-331.609;Inherit;False;Property;_Float14;U振幅测试;33;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;417;-2588.538,-364.1124;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;411;-3090.967,138.1547;Inherit;False;409;zhenpingUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-353.459,-262.4684;Inherit;False;Property;_Float34;黑白切换控制方式;22;1;[Enum];Create;False;0;2;Material;0;ParticleAlphy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;224;-2742.674,-429.558;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;418;-2410.374,-459.4407;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;420;-2640.473,-243.0348;Inherit;False;Constant;_Float16;Float 16;39;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;366;-2516.949,-739.3978;Inherit;False;Property;_Float30;Mask通道;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-956.2712,-402.1875;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;429;-3073.476,-39.66197;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;416;-2565.483,-497.8315;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;-3252.214,-605.255;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;398;-2204.741,-757.6666;Inherit;False;Property;_Float24;OneMinusMask;8;1;[Toggle];Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;421;-2238.194,-348.7364;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-506.9701,-684.8469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;-1115.113,-576.9324;Inherit;False;423;jizuobiaowenli;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;333;-2934.498,-542.5941;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;378;35.14931,-567.7101;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;311;-1151.716,-114.2962;Inherit;True;Property;_TextureSample18;Texture Sample 18;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;295;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;450;-68.69227,89.11913;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;414;-1782.754,-414.0182;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;422;-2083.538,-347.3923;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;400;-1981.721,-896.588;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;445;1972.568,-709.0242;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2.53;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;401;-1990.227,-772.9918;Inherit;False;Property;_MaskPower1;MaskPower;9;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;181;-669.504,-650.7016;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;294;1155.623,-752.777;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;292;1155.623,-752.777;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;290;1465.842,-213.586;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;291;2283.99,-311.5463;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;LF/URP后期2.0;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=1000;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Grab;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;293;1155.623,-752.777;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;72;0;412;0
WireConnection;72;1;51;0
WireConnection;313;1;115;0
WireConnection;99;0;98;0
WireConnection;99;1;51;0
WireConnection;98;0;97;0
WireConnection;98;1;51;0
WireConnection;107;0;104;0
WireConnection;107;1;51;0
WireConnection;387;0;52;0
WireConnection;387;1;144;1
WireConnection;387;2;388;0
WireConnection;51;0;73;0
WireConnection;51;2;387;0
WireConnection;121;0;120;0
WireConnection;121;1;122;0
WireConnection;317;1;102;0
WireConnection;243;0;237;0
WireConnection;6;1;243;0
WireConnection;304;1;103;0
WireConnection;131;0;295;0
WireConnection;131;1;128;0
WireConnection;131;2;174;0
WireConnection;295;1;72;0
WireConnection;306;1;107;0
WireConnection;299;1;97;0
WireConnection;120;0;110;0
WireConnection;120;1;111;0
WireConnection;236;0;257;0
WireConnection;253;0;261;0
WireConnection;253;1;258;0
WireConnection;96;0;81;0
WireConnection;96;1;51;0
WireConnection;109;0;106;0
WireConnection;109;1;51;0
WireConnection;111;0;317;0
WireConnection;111;1;305;0
WireConnection;111;2;316;0
WireConnection;111;3;306;0
WireConnection;111;4;307;0
WireConnection;111;5;308;0
WireConnection;111;6;315;0
WireConnection;111;7;314;0
WireConnection;111;8;313;0
WireConnection;111;9;312;0
WireConnection;97;0;96;0
WireConnection;97;1;51;0
WireConnection;315;1;112;0
WireConnection;312;1;114;0
WireConnection;194;0;131;0
WireConnection;80;0;72;0
WireConnection;80;1;51;0
WireConnection;115;0;113;0
WireConnection;115;1;51;0
WireConnection;314;1;113;0
WireConnection;431;0;430;0
WireConnection;431;2;432;0
WireConnection;434;0;433;0
WireConnection;434;1;435;0
WireConnection;110;0;295;0
WireConnection;110;1;296;0
WireConnection;110;2;297;0
WireConnection;110;3;298;0
WireConnection;110;4;299;0
WireConnection;110;5;300;0
WireConnection;110;6;301;0
WireConnection;110;7;302;0
WireConnection;110;8;303;0
WireConnection;110;9;304;0
WireConnection;105;0;102;0
WireConnection;105;1;51;0
WireConnection;114;0;115;0
WireConnection;114;1;51;0
WireConnection;123;0;121;0
WireConnection;123;3;124;0
WireConnection;316;1;104;0
WireConnection;104;0;105;0
WireConnection;104;1;51;0
WireConnection;305;1;105;0
WireConnection;113;0;112;0
WireConnection;113;1;51;0
WireConnection;297;1;81;0
WireConnection;106;0;107;0
WireConnection;106;1;51;0
WireConnection;423;0;6;1
WireConnection;245;0;267;0
WireConnection;132;0;402;0
WireConnection;132;1;133;0
WireConnection;155;0;8;0
WireConnection;155;2;376;0
WireConnection;255;0;262;0
WireConnection;258;0;260;0
WireConnection;258;1;245;0
WireConnection;244;0;255;1
WireConnection;244;1;255;0
WireConnection;164;0;410;0
WireConnection;164;1;166;0
WireConnection;164;2;167;0
WireConnection;101;0;100;0
WireConnection;101;1;51;0
WireConnection;242;0;155;0
WireConnection;301;1;99;0
WireConnection;241;0;242;2
WireConnection;241;1;242;3
WireConnection;239;0;373;0
WireConnection;239;1;252;0
WireConnection;239;2;241;0
WireConnection;442;0;439;0
WireConnection;413;0;2;0
WireConnection;248;0;275;0
WireConnection;248;2;259;0
WireConnection;447;0;445;0
WireConnection;447;1;283;0
WireConnection;441;0;440;0
WireConnection;439;0;438;1
WireConnection;439;1;438;2
WireConnection;247;0;258;0
WireConnection;247;1;261;0
WireConnection;278;1;285;0
WireConnection;285;0;449;0
WireConnection;285;1;287;0
WireConnection;285;2;288;0
WireConnection;376;0;154;0
WireConnection;376;1;153;0
WireConnection;376;2;377;0
WireConnection;298;1;96;0
WireConnection;142;0;132;0
WireConnection;153;0;8;3
WireConnection;153;1;150;3
WireConnection;246;0;236;0
WireConnection;262;0;248;0
WireConnection;300;1;98;0
WireConnection;237;0;239;0
WireConnection;167;0;165;3
WireConnection;167;1;165;4
WireConnection;112;0;109;0
WireConnection;112;1;51;0
WireConnection;173;0;142;0
WireConnection;399;0;365;0
WireConnection;260;0;262;0
WireConnection;100;0;99;0
WireConnection;100;1;51;0
WireConnection;261;0;256;0
WireConnection;256;0;244;0
WireConnection;256;1;263;0
WireConnection;252;0;242;0
WireConnection;252;1;242;1
WireConnection;303;1;101;0
WireConnection;365;0;130;1
WireConnection;365;1;130;4
WireConnection;365;2;366;0
WireConnection;402;0;400;0
WireConnection;402;1;401;0
WireConnection;128;0;60;0
WireConnection;128;1;123;0
WireConnection;128;2;129;0
WireConnection;102;0;103;0
WireConnection;102;1;51;0
WireConnection;449;0;393;0
WireConnection;449;2;450;0
WireConnection;274;0;62;0
WireConnection;60;0;311;1
WireConnection;60;1;310;2
WireConnection;60;2;309;3
WireConnection;190;0;437;0
WireConnection;190;1;189;0
WireConnection;309;1;192;0
WireConnection;435;0;65;0
WireConnection;259;0;246;0
WireConnection;259;1;245;1
WireConnection;191;0;190;0
WireConnection;191;1;189;0
WireConnection;395;0;394;0
WireConnection;74;0;434;0
WireConnection;310;1;191;0
WireConnection;381;0;382;0
WireConnection;381;1;425;4
WireConnection;381;2;383;0
WireConnection;166;0;165;1
WireConnection;166;1;165;2
WireConnection;307;1;106;0
WireConnection;16;0;11;0
WireConnection;302;1;100;0
WireConnection;189;0;385;0
WireConnection;189;2;436;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;192;0;191;0
WireConnection;192;1;189;0
WireConnection;283;0;281;0
WireConnection;283;1;229;0
WireConnection;283;2;395;0
WireConnection;287;0;286;1
WireConnection;287;1;286;2
WireConnection;394;0;278;1
WireConnection;394;1;282;0
WireConnection;393;0;392;0
WireConnection;393;1;389;2
WireConnection;225;0;197;0
WireConnection;225;1;15;0
WireConnection;225;2;381;0
WireConnection;27;0;25;0
WireConnection;391;0;390;1
WireConnection;391;1;390;2
WireConnection;433;0;429;0
WireConnection;229;0;225;0
WireConnection;229;3;232;0
WireConnection;229;4;231;0
WireConnection;392;0;389;1
WireConnection;392;1;391;0
WireConnection;385;0;188;0
WireConnection;385;1;186;2
WireConnection;385;2;386;0
WireConnection;281;0;278;1
WireConnection;281;1;282;0
WireConnection;32;0;11;0
WireConnection;32;1;16;0
WireConnection;32;2;378;0
WireConnection;288;0;286;3
WireConnection;288;1;286;4
WireConnection;25;0;195;0
WireConnection;409;0;414;0
WireConnection;218;0;210;0
WireConnection;218;1;203;0
WireConnection;218;2;207;0
WireConnection;218;3;205;0
WireConnection;373;0;253;0
WireConnection;373;1;247;0
WireConnection;373;2;374;0
WireConnection;296;1;80;0
WireConnection;419;0;417;0
WireConnection;419;1;224;3
WireConnection;419;2;420;0
WireConnection;444;0;442;0
WireConnection;444;2;441;0
WireConnection;154;0;8;3
WireConnection;154;1;8;4
WireConnection;308;1;109;0
WireConnection;233;0;235;0
WireConnection;233;1;424;0
WireConnection;233;2;234;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;81;0;80;0
WireConnection;81;1;51;0
WireConnection;130;1;164;0
WireConnection;103;0;101;0
WireConnection;103;1;51;0
WireConnection;62;0;411;0
WireConnection;62;1;65;0
WireConnection;15;0;23;0
WireConnection;15;1;28;0
WireConnection;15;2;32;0
WireConnection;11;0;14;0
WireConnection;11;1;29;0
WireConnection;11;2;30;0
WireConnection;14;0;27;0
WireConnection;14;1;13;0
WireConnection;417;0;224;1
WireConnection;224;0;333;0
WireConnection;418;0;416;0
WireConnection;418;1;224;2
WireConnection;418;2;420;0
WireConnection;429;0;427;0
WireConnection;429;1;428;0
WireConnection;429;2;431;0
WireConnection;416;0;224;0
WireConnection;421;0;418;0
WireConnection;421;1;419;0
WireConnection;13;0;27;0
WireConnection;13;1;181;0
WireConnection;333;0;147;0
WireConnection;333;1;218;0
WireConnection;333;2;334;0
WireConnection;378;0;379;0
WireConnection;378;1;34;4
WireConnection;378;2;380;0
WireConnection;311;1;190;0
WireConnection;450;0;451;0
WireConnection;414;0;413;0
WireConnection;414;2;422;0
WireConnection;422;0;421;0
WireConnection;400;0;365;0
WireConnection;400;1;399;0
WireConnection;400;2;398;0
WireConnection;445;0;444;0
WireConnection;445;1;443;0
WireConnection;181;0;27;0
WireConnection;181;1;233;0
WireConnection;181;2;177;0
WireConnection;291;2;447;0
ASEEND*/
//CHKSM=8E7E99B2457584D79ECF815B1B9196A36FDB2FD3