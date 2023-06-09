// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/后期处理/视差地裂"
{
	Properties
	{
		[Header(MainTex......e(OvO)e)][NoScaleOffset]MainTex2("主贴图", 2D) = "white" {}
		[KeywordEnum(R,A)] _Keyword4("主帖图通道", Float) = 1
		[Toggle(_KEYWORD23)] _Keyword23("主帖图Clamp", Float) = 0
		_Vector2("主贴图Tiling And Offset", Vector) = (1,1,0,0)
		[HDR]_Color3("主帖图颜色", Color) = (1,1,1,1)
		_Float64("主帖图旋转", Range( 0 , 360)) = 0
		[Toggle]_Float65("主帖图极坐标开关", Float) = 0
		_Float4("主贴图U方向速度", Float) = 0
		_Float5("主贴图V方向速度", Float) = 0
		[Header(AddTex......e(OvO)e)][Toggle(_KEYWORD7_ON)] _Keyword7("开启流动纹理", Float) = 0
		[NoScaleOffset]AddTex2("流动纹理图", 2D) = "white" {}
		[Toggle(_KEYWORD24)] _Keyword24("叠加纹理Clamp", Float) = 0
		_Vector8("流动纹理图Tiling And Offset", Vector) = (1,1,0,0)
		[HDR]_Color6("流动纹理图颜色", Color) = (1,1,1,1)
		_Float76("流动纹理图旋转", Range( 0 , 360)) = 0
		[Toggle]_Float77("流动纹理图极坐标开关", Float) = 0
		_Float18("流动纹理图U方向速度", Float) = 0
		_Float19("流动纹理图V方向速度", Float) = 0
		_edge("流动纹理范围", Range( 0 , 1)) = 0
		[Header(MaskTex......e(OvO)e)][Toggle(_KEYWORD6_ON)] _Keyword6("开启遮罩", Float) = 0
		[NoScaleOffset]MaskTex2("遮罩贴图", 2D) = "white" {}
		[KeywordEnum(R,A)] _Keyword3("遮罩通道", Float) = 1
		[Toggle(_KEYWORD25)] _Keyword25("遮罩01Clamp", Float) = 0
		_Vector3("遮罩01Tiling And Offset", Vector) = (1,1,0,0)
		_Float66("遮罩旋转", Range( 0 , 360)) = 0
		[Toggle]_Float67("遮罩极坐标开关", Float) = 0
		_Float7("遮罩贴图U方向速度", Float) = 0
		_Float6("遮罩贴图V方向速度", Float) = 0
		[Header(NoiseTex......e(OvO)e)][Toggle(_KEYWORD10_ON)] _Keyword10("开启扰动", Float) = 0
		[NoScaleOffset]NoiseTex2("扰动纹理图", 2D) = "white" {}
		[KeywordEnum(R,A)] _Keyword2("扰动纹理通道", Float) = 1
		[Toggle(_KEYWORD27)] _Keyword27("扰动纹理Clamp", Float) = 0
		_Vector5("扰动图Tiling And Offset", Vector) = (1,1,0,0)
		_Float70("扰动图旋转", Range( 0 , 360)) = 0
		[Toggle]_Float71("扰动图极坐标开关", Float) = 0
		_Float11("扰动U方向速度", Float) = 0
		_Float10("扰动V方向速度", Float) = 0
		_Float12("扰动强度", Range( 0 , 1)) = 0
		[Toggle]_Float8("扰动是否影响主帖图", Float) = 0
		[Toggle]_Float24("扰动是否影响流动纹理", Float) = 0
		[Toggle]_Float9("扰动是否影响遮罩", Float) = 0
		[Header(Header(DepthTex......e(OvO)e))]_DepthTex1("深度图", 2D) = "white" {}
		_DepthIntensity1("强度", Range( 0 , 1)) = 0
		[Toggle]_Float47("扰动是否影响溶解", Float) = 0
		[Header(Dissolve......e(OvO)e)][Toggle(_KEYWORD14_ON)] _Keyword14("开启溶解", Float) = 0
		[KeywordEnum(ON,OFF)] _Keyword29("粒子透明度控制溶解", Float) = 1
		[NoScaleOffset]DissolveTex4("溶解纹理图", 2D) = "white" {}
		[KeywordEnum(R,A)] _Keyword12("溶解通道", Float) = 1
		[Toggle(_KEYWORD32)] _Keyword32("溶解图Clamp", Float) = 0
		_Vector10("溶解图Tiling And Offset", Vector) = (1,1,0,0)
		_Float79("溶解图旋转", Range( 0 , 360)) = 0
		[Toggle]_Float80("溶解极坐标开关", Float) = 0
		_Float45("溶解U方向速度", Float) = 0
		_Float46("溶解V方向速度", Float) = 0
		_DIssolveInstensity4("溶解强度", Range( 0 , 1)) = 0
		_Float22("溶解软硬度", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha [_BlendMode1]
		AlphaToMask Off
		Cull [_CullMode1]
		ColorMask [_ColorMask1]
		ZWrite [_ZWrite1]
		ZTest [_ZTest1]
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _KEYWORD23
			#pragma shader_feature_local _KEYWORD10_ON
			#pragma shader_feature_local _KEYWORD2_R _KEYWORD2_A
			#pragma shader_feature_local _KEYWORD27
			#pragma shader_feature_local _KEYWORD7_ON
			#pragma shader_feature_local _KEYWORD24
			#pragma shader_feature_local _KEYWORD6_ON
			#pragma shader_feature_local _KEYWORD3_R _KEYWORD3_A
			#pragma shader_feature_local _KEYWORD25
			#pragma shader_feature_local _KEYWORD4_R _KEYWORD4_A
			#pragma shader_feature_local _KEYWORD14_ON
			#pragma shader_feature_local _KEYWORD12_R _KEYWORD12_A
			#pragma shader_feature_local _KEYWORD32
			#pragma shader_feature_local _KEYWORD29_ON _KEYWORD29_OFF


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color3;
			uniform sampler2D MainTex2;
			uniform float _Float4;
			uniform float _Float5;
			uniform sampler2D _DepthTex1;
			uniform float _DepthIntensity1;
			uniform float4 _DepthTex1_ST;
			uniform float _Float65;
			uniform float _Float64;
			uniform float4 _Vector2;
			uniform sampler2D NoiseTex2;
			uniform float _Float11;
			uniform float _Float10;
			uniform float _Float71;
			uniform float _Float70;
			uniform float4 _Vector5;
			uniform float _Float12;
			uniform float _Float8;
			uniform float4 _Color6;
			uniform sampler2D AddTex2;
			uniform float _Float18;
			uniform float _Float19;
			uniform float _Float77;
			uniform float _Float76;
			uniform float4 _Vector8;
			uniform float _Float24;
			uniform float _edge;
			uniform sampler2D MaskTex2;
			uniform float _Float7;
			uniform float _Float6;
			uniform float _Float67;
			uniform float _Float66;
			uniform float4 _Vector3;
			uniform float _Float9;
			uniform float _Float22;
			uniform sampler2D DissolveTex4;
			uniform float _Float45;
			uniform float _Float46;
			uniform float _Float80;
			uniform float _Float79;
			uniform float4 _Vector10;
			uniform float _Float47;
			uniform float _DIssolveInstensity4;
			inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
			{
				float3 result = 0;
				int stepIndex = 0;
				int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
				float layerHeight = 1.0 / numSteps;
				float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
				uvs.xy += refPlane * plane;
				float2 deltaTex = -plane * layerHeight;
				float2 prevTexOffset = 0;
				float prevRayZ = 1.0f;
				float prevHeight = 0.0f;
				float2 currTexOffset = deltaTex;
				float currRayZ = 1.0f - layerHeight;
				float currHeight = 0.0f;
				float intersection = 0;
				float2 finalTexOffset = 0;
				while ( stepIndex < numSteps + 1 )
				{
				 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
				 	if ( currHeight > currRayZ )
				 	{
				 	 	stepIndex = numSteps + 1;
				 	}
				 	else
				 	{
				 	 	stepIndex++;
				 	 	prevTexOffset = currTexOffset;
				 	 	prevRayZ = currRayZ;
				 	 	prevHeight = currHeight;
				 	 	currTexOffset += deltaTex;
				 	 	currRayZ -= layerHeight;
				 	}
				}
				int sectionSteps = 2;
				int sectionIndex = 0;
				float newZ = 0;
				float newHeight = 0;
				while ( sectionIndex < sectionSteps )
				{
				 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
				 	finalTexOffset = prevTexOffset + intersection * deltaTex;
				 	newZ = prevRayZ - intersection * layerHeight;
				 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
				 	if ( newHeight > newZ )
				 	{
				 	 	currTexOffset = finalTexOffset;
				 	 	currHeight = newHeight;
				 	 	currRayZ = newZ;
				 	 	deltaTex = intersection * deltaTex;
				 	 	layerHeight = intersection * layerHeight;
				 	}
				 	else
				 	{
				 	 	prevTexOffset = finalTexOffset;
				 	 	prevHeight = newHeight;
				 	 	prevRayZ = newZ;
				 	 	deltaTex = ( 1 - intersection ) * deltaTex;
				 	 	layerHeight = ( 1 - intersection ) * layerHeight;
				 	}
				 	sectionIndex++;
				}
				return uvs.xy + finalTexOffset;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_color = v.color;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult93 = (float2(_Float4 , _Float5));
				float2 texCoord7 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 OffsetPOM11 = POM( _DepthTex1, texCoord7, ddx(texCoord7), ddy(texCoord7), ase_worldNormal, ase_worldViewDir, ase_tanViewDir, 128, 128, _DepthIntensity1, 0, _DepthTex1_ST.xy, float2(0,0), 0 );
				float2 Depth12 = OffsetPOM11;
				float2 CenteredUV15_g30 = ( Depth12 - float2( 0.5,0.5 ) );
				float2 break17_g30 = CenteredUV15_g30;
				float2 appendResult23_g30 = (float2(( length( CenteredUV15_g30 ) * 1.0 * 2.0 ) , ( atan2( break17_g30.x , break17_g30.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 lerpResult77 = lerp( Depth12 , appendResult23_g30 , _Float65);
				float cos86 = cos( ( ( _Float64 / 180.0 ) * UNITY_PI ) );
				float sin86 = sin( ( ( _Float64 / 180.0 ) * UNITY_PI ) );
				float2 rotator86 = mul( lerpResult77 - float2( 0.5,0.5 ) , float2x2( cos86 , -sin86 , sin86 , cos86 )) + float2( 0.5,0.5 );
				float2 appendResult87 = (float2(_Vector2.x , _Vector2.y));
				float2 appendResult83 = (float2(_Vector2.z , _Vector2.w));
				float2 panner102 = ( 1.0 * _Time.y * appendResult93 + (rotator86*appendResult87 + appendResult83));
				float2 clampResult107 = clamp( panner102 , float2( 0,0 ) , float2( 1,1 ) );
				#ifdef _KEYWORD23
				float2 staticSwitch112 = clampResult107;
				#else
				float2 staticSwitch112 = panner102;
				#endif
				float2 appendResult26 = (float2(_Float11 , _Float10));
				float2 CenteredUV15_g21 = ( Depth12 - float2( 0.5,0.5 ) );
				float2 break17_g21 = CenteredUV15_g21;
				float2 appendResult23_g21 = (float2(( length( CenteredUV15_g21 ) * 1.0 * 2.0 ) , ( atan2( break17_g21.x , break17_g21.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 lerpResult19 = lerp( Depth12 , appendResult23_g21 , _Float71);
				float cos25 = cos( ( ( _Float70 / 180.0 ) * UNITY_PI ) );
				float sin25 = sin( ( ( _Float70 / 180.0 ) * UNITY_PI ) );
				float2 rotator25 = mul( lerpResult19 - float2( 0.5,0.5 ) , float2x2( cos25 , -sin25 , sin25 , cos25 )) + float2( 0.5,0.5 );
				float2 appendResult24 = (float2(_Vector5.x , _Vector5.y));
				float2 appendResult22 = (float2(_Vector5.z , _Vector5.w));
				float2 panner28 = ( 1.0 * _Time.y * appendResult26 + (rotator25*appendResult24 + appendResult22));
				float2 clampResult29 = clamp( panner28 , float2( 0,0 ) , float2( 1,1 ) );
				#ifdef _KEYWORD27
				float2 staticSwitch30 = clampResult29;
				#else
				float2 staticSwitch30 = panner28;
				#endif
				float4 tex2DNode36 = tex2D( NoiseTex2, staticSwitch30 );
				#if defined(_KEYWORD2_R)
				float staticSwitch39 = tex2DNode36.r;
				#elif defined(_KEYWORD2_A)
				float staticSwitch39 = tex2DNode36.a;
				#else
				float staticSwitch39 = tex2DNode36.a;
				#endif
				float lerpResult43 = lerp( 0.0 , staticSwitch39 , _Float12);
				#ifdef _KEYWORD10_ON
				float staticSwitch53 = lerpResult43;
				#else
				float staticSwitch53 = 0.0;
				#endif
				float NoiseTex58 = staticSwitch53;
				float4 tex2DNode119 = tex2D( MainTex2, ( staticSwitch112 + ( NoiseTex58 * _Float8 ) ) );
				float4 MainTexRGB126 = ( _Color3 * tex2DNode119 );
				float2 appendResult82 = (float2(_Float18 , _Float19));
				float2 CenteredUV15_g29 = ( Depth12 - float2( 0.5,0.5 ) );
				float2 break17_g29 = CenteredUV15_g29;
				float2 appendResult23_g29 = (float2(( length( CenteredUV15_g29 ) * 1.0 * 2.0 ) , ( atan2( break17_g29.x , break17_g29.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 lerpResult61 = lerp( Depth12 , appendResult23_g29 , _Float77);
				float cos76 = cos( ( ( _Float76 / 180.0 ) * UNITY_PI ) );
				float sin76 = sin( ( ( _Float76 / 180.0 ) * UNITY_PI ) );
				float2 rotator76 = mul( lerpResult61 - float2( 0.5,0.5 ) , float2x2( cos76 , -sin76 , sin76 , cos76 )) + float2( 0.5,0.5 );
				float2 appendResult70 = (float2(_Vector8.x , _Vector8.y));
				float2 appendResult69 = (float2(_Vector8.z , _Vector8.w));
				float2 panner88 = ( 1.0 * _Time.y * appendResult82 + (rotator76*appendResult70 + appendResult69));
				float2 clampResult96 = clamp( panner88 , float2( 0,0 ) , float2( 1,1 ) );
				#ifdef _KEYWORD24
				float2 staticSwitch101 = clampResult96;
				#else
				float2 staticSwitch101 = panner88;
				#endif
				float2 appendResult50 = (float2(_Float7 , _Float6));
				float2 texCoord32 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g27 = ( texCoord32 - float2( 0.5,0.5 ) );
				float2 break17_g27 = CenteredUV15_g27;
				float2 appendResult23_g27 = (float2(( length( CenteredUV15_g27 ) * 1.0 * 2.0 ) , ( atan2( break17_g27.x , break17_g27.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 lerpResult37 = lerp( texCoord32 , appendResult23_g27 , _Float67);
				float cos45 = cos( ( ( _Float66 / 180.0 ) * UNITY_PI ) );
				float sin45 = sin( ( ( _Float66 / 180.0 ) * UNITY_PI ) );
				float2 rotator45 = mul( lerpResult37 - float2( 0.5,0.5 ) , float2x2( cos45 , -sin45 , sin45 , cos45 )) + float2( 0.5,0.5 );
				float2 appendResult42 = (float2(_Vector3.x , _Vector3.y));
				float2 appendResult48 = (float2(_Vector3.z , _Vector3.w));
				float2 panner57 = ( 1.0 * _Time.y * appendResult50 + (rotator45*appendResult42 + appendResult48));
				float2 clampResult62 = clamp( panner57 , float2( 0,0 ) , float2( 1,1 ) );
				#ifdef _KEYWORD25
				float2 staticSwitch75 = clampResult62;
				#else
				float2 staticSwitch75 = panner57;
				#endif
				float4 tex2DNode89 = tex2D( MaskTex2, ( staticSwitch75 + ( NoiseTex58 * _Float9 ) ) );
				#if defined(_KEYWORD3_R)
				float staticSwitch91 = tex2DNode89.r;
				#elif defined(_KEYWORD3_A)
				float staticSwitch91 = tex2DNode89.a;
				#else
				float staticSwitch91 = tex2DNode89.a;
				#endif
				#ifdef _KEYWORD6_ON
				float staticSwitch97 = staticSwitch91;
				#else
				float staticSwitch97 = 1.0;
				#endif
				float MaskTex01105 = staticSwitch97;
				float smoothstepResult144 = smoothstep( _edge , 1.0 , ( ( 1.0 - tex2D( _DepthTex1, Depth12 ).r ) * MaskTex01105 ));
				#ifdef _KEYWORD7_ON
				float4 staticSwitch124 = ( ( _Color6 * tex2D( AddTex2, ( staticSwitch101 + ( NoiseTex58 * _Float24 ) ) ) ) * smoothstepResult144 );
				#else
				float4 staticSwitch124 = float4( 0,0,0,0 );
				#endif
				float4 AddTex127 = staticSwitch124;
				#if defined(_KEYWORD4_R)
				float staticSwitch121 = tex2DNode119.r;
				#elif defined(_KEYWORD4_A)
				float staticSwitch121 = tex2DNode119.a;
				#else
				float staticSwitch121 = tex2DNode119.a;
				#endif
				float MainTexAlp129 = staticSwitch121;
				float2 appendResult185 = (float2(_Float45 , _Float46));
				float2 texCoord172 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g28 = ( texCoord172 - float2( 0.5,0.5 ) );
				float2 break17_g28 = CenteredUV15_g28;
				float2 appendResult23_g28 = (float2(( length( CenteredUV15_g28 ) * 1.0 * 2.0 ) , ( atan2( break17_g28.x , break17_g28.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 lerpResult177 = lerp( texCoord172 , appendResult23_g28 , _Float80);
				float cos180 = cos( ( ( _Float79 / 180.0 ) * UNITY_PI ) );
				float sin180 = sin( ( ( _Float79 / 180.0 ) * UNITY_PI ) );
				float2 rotator180 = mul( lerpResult177 - float2( 0.5,0.5 ) , float2x2( cos180 , -sin180 , sin180 , cos180 )) + float2( 0.5,0.5 );
				float2 appendResult179 = (float2(_Vector10.x , _Vector10.y));
				float2 appendResult181 = (float2(_Vector10.z , _Vector10.w));
				float2 panner186 = ( 1.0 * _Time.y * appendResult185 + (rotator180*appendResult179 + appendResult181));
				float2 clampResult189 = clamp( panner186 , float2( 0,0 ) , float2( 1,1 ) );
				#ifdef _KEYWORD32
				float2 staticSwitch190 = clampResult189;
				#else
				float2 staticSwitch190 = panner186;
				#endif
				float4 tex2DNode197 = tex2D( DissolveTex4, ( staticSwitch190 + ( NoiseTex58 * _Float47 ) ) );
				#if defined(_KEYWORD12_R)
				float staticSwitch198 = tex2DNode197.r;
				#elif defined(_KEYWORD12_A)
				float staticSwitch198 = tex2DNode197.a;
				#else
				float staticSwitch198 = tex2DNode197.a;
				#endif
				float DissloveTex200 = staticSwitch198;
				#if defined(_KEYWORD29_ON)
				float staticSwitch157 = ( 1.0 - i.ase_color.a );
				#elif defined(_KEYWORD29_OFF)
				float staticSwitch157 = 1.0;
				#else
				float staticSwitch157 = 1.0;
				#endif
				float smoothstepResult162 = smoothstep( 0.0 , _Float22 , ( ( DissloveTex200 + 1.0 ) + ( -2.0 * (-0.1 + (_DIssolveInstensity4 - 0.0) * (1.01 - -0.1) / (1.0 - 0.0)) * staticSwitch157 ) ));
				#ifdef _KEYWORD14_ON
				float staticSwitch167 = ( smoothstepResult162 - 2.0 );
				#else
				float staticSwitch167 = 1.0;
				#endif
				float DissolveSoft199 = saturate( ( 2.0 + staticSwitch167 ) );
				float4 appendResult138 = (float4((( i.ase_color * ( MainTexRGB126 + AddTex127 ) )).rgb , ( i.ase_color.a * MainTexAlp129 * MaskTex01105 * DissolveSoft199 )));
				
				
				finalColor = appendResult138;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;146;2866.966,1787.568;Inherit;False;2229.403;769.1849;Comment;8;5;6;9;8;7;10;11;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;2916.966,2013.245;Inherit;True;Property;_DepthTex1;深度图;41;1;[Header];Create;False;1;Header(DepthTex......e(OvO)e);0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;3445.134,2017.454;Inherit;False;DepthTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;3874.552,2368.753;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;10;3857.552,2222.753;Inherit;False;Property;_DepthIntensity1;强度;42;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;3759.237,2023.971;Inherit;False;6;DepthTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;3869.406,1837.568;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;11;4471.226,1983.862;Inherit;False;0;128;False;;128;False;;2;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;4872.368,1975.619;Inherit;False;Depth;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1729.819,-2317;Inherit;False;3949.695;1064.67;NoiseTex;25;58;53;47;43;40;39;36;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;扰动纹理;0.2169811,0.01763334,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1702.901,-2059.838;Inherit;False;12;Depth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1585.819,-1709;Inherit;False;Property;_Float70;扰动图旋转;33;0;Create;False;0;0;0;False;0;False;0;5.93;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;-1425.819,-1965.001;Inherit;False;Polar Coordinates;-1;;21;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1457.819,-1805;Inherit;False;Property;_Float71;扰动图极坐标开关;34;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-1313.819,-1693;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;20;-1201.819,-1709;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;18;-1327.219,-1549;Inherit;False;Property;_Vector5;扰动图Tiling And Offset;32;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;19;-1153.819,-2029.001;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-705.8188,-1869.001;Inherit;False;Property;_Float11;扰动U方向速度;35;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-1025.819,-1565;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-1009.819,-1421;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;25;-961.8188,-2029.001;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-705.8188,-1725;Inherit;False;Property;_Float10;扰动V方向速度;36;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;27;-721.8188,-2029.001;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-481.8198,-1885.001;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;28;-353.8159,-2013.001;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;147;-2717.615,2992.973;Inherit;False;4914.083;3324.334;Dissolve;22;201;189;184;181;180;179;178;177;176;175;174;173;172;171;157;155;153;152;151;150;149;148;溶解;0,0.1077135,0.1411765,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;29;-225.8159,-2173;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;2;-1801.643,1522.945;Inherit;False;3841.605;1137.633;MaskTex;27;105;97;92;91;89;79;75;71;65;62;60;57;50;49;48;46;45;44;42;41;38;37;35;34;33;32;31;遮罩纹理;0.2075472,0.1183208,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-1797.583,1796.816;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-2550.558,3303.783;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;30;-129.8159,-2013.001;Inherit;False;Property;_Keyword27;扰动纹理Clamp;31;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-2479.117,3623.248;Inherit;False;Property;_Float79;溶解图旋转;50;0;Create;False;0;0;0;False;0;False;0;5.93;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1673.643,2210.945;Inherit;False;Property;_Float66;遮罩旋转;24;0;Create;False;0;0;0;False;0;False;0;5.93;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;34;-1385.643,2210.945;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;35;-1555.692,1878.652;Inherit;False;Polar Coordinates;-1;;27;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;173;-2312.348,3365.895;Inherit;False;Polar Coordinates;-1;;28;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-2354.537,3523.344;Inherit;False;Property;_Float80;溶解极坐标开关;51;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;174;-2204.406,3629.785;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;478.1841,-2029.001;Inherit;True;Property;NoiseTex2;扰动纹理图;29;1;[NoScaleOffset];Create;False;2;NoiseTex......e(OvO)e.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................;.;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-1545.643,2098.945;Inherit;False;Property;_Float67;遮罩极坐标开关;25;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;41;-1273.643,2210.945;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;37;-1225.643,1874.945;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;38;-1401.643,2370.945;Inherit;False;Property;_Vector3;遮罩01Tiling And Offset;23;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;176;-2216.106,3787.154;Inherit;False;Property;_Vector10;溶解图Tiling And Offset;49;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;739.7839,-1604.035;Inherit;False;Property;_Float12;扰动强度;37;0;Create;False;0;0;0;False;0;False;0;0.316;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;39;814.1841,-1981.001;Inherit;False;Property;_Keyword2;扰动纹理通道;30;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;R;A;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;148;-1421.874,3248.467;Inherit;False;2847.584;606.5452;Comment;12;200;198;197;193;191;190;188;187;186;185;183;182;溶解图;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;177;-2039.156,3301.395;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;178;-2092.906,3627.726;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;-1907.856,3909.477;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-809.6421,2210.945;Inherit;False;Property;_Float6;遮罩贴图V方向速度;27;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-1113.642,2338.945;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;45;-1033.643,1890.945;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-1097.642,2482.945;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-1421.857,3513.541;Inherit;False;Property;_Float45;溶解U方向速度;52;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-825.6421,2098.945;Inherit;False;Property;_Float7;遮罩贴图U方向速度;26;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;1137.41,-1962.7;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;180;-1844.178,3302.682;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;47;1449.798,-1919.03;Inherit;False;Constant;_Float31;Float 31;47;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-1421.857,3641.539;Inherit;False;Property;_Float46;溶解V方向速度;53;0;Create;False;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;179;-1918.856,3758.477;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;184;-1591.128,3310.962;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;49;-777.6421,1890.945;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;3;-1766.756,-1022.367;Inherit;False;4504.154;1021.018;AddTex;36;127;124;120;117;115;114;111;110;109;108;103;101;100;99;98;96;95;90;88;82;81;76;70;69;68;67;64;63;61;56;55;54;52;51;144;145;叠加纹理;0.1981132,0,0.1807262,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;53;1639.699,-2000.829;Inherit;False;Property;_Keyword10;开启扰动;28;0;Create;False;0;0;0;False;1;Header(NoiseTex......e(OvO)e);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;50;-585.6421,2114.945;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;185;-1181.857,3513.541;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;186;-1058.758,3327.141;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;57;-473.6421,1906.945;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1736.146,-865.3974;Inherit;False;12;Depth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1670.756,-510.3672;Inherit;False;Property;_Float76;流动纹理图旋转;14;0;Create;False;0;0;0;False;0;False;0;5.93;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;1966.185,-1997.001;Inherit;False;NoiseTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;54;-1382.756,-494.3672;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;62;-313.6421,2002.945;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-281.6421,2242.945;Inherit;False;Property;_Float9;扰动是否影响遮罩;40;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;4;-1799.725,163.2212;Inherit;False;4098.821;1132.375;MainTex;28;129;126;122;121;119;118;116;113;112;107;106;104;102;94;93;87;86;85;84;83;80;78;77;74;73;72;66;59;主帖图;0.02761025,0.1037736,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-281.6421,2146.945;Inherit;False;58;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;189;-865.8013,3208.164;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;56;-1494.756,-766.3672;Inherit;False;Polar Coordinates;-1;;29;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1542.756,-606.3672;Inherit;False;Property;_Float77;流动纹理图极坐标开关;15;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-911.0582,3599.14;Inherit;False;Property;_Float47;扰动是否影响溶解;43;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-911.0582,3503.141;Inherit;False;58;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-1790.08,422.9959;Inherit;False;12;Depth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1751.725,771.2213;Inherit;False;Property;_Float64;主帖图旋转;5;0;Create;False;0;0;0;False;0;False;0;5.93;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-73.64209,2162.945;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;-1222.756,-830.3672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;64;-1286.756,-494.3672;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;75;-185.6421,1890.945;Inherit;False;Property;_Keyword25;遮罩01Clamp;22;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;63;-1398.756,-334.3673;Inherit;False;Property;_Vector8;流动纹理图Tiling And Offset;12;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-687.0582,3503.141;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;190;-748.2358,3323.419;Inherit;False;Property;_Keyword32;溶解图Clamp;48;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;76;-1030.756,-830.3672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-694.7559,-606.3672;Inherit;False;Property;_Float18;流动纹理图U方向速度;16;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1623.725,659.2213;Inherit;False;Property;_Float65;主帖图极坐标开关;6;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;-1094.756,-222.3673;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;396.3579,1771.945;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-694.7559,-494.3672;Inherit;False;Property;_Float19;流动纹理图V方向速度;17;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;74;-1575.725,499.2212;Inherit;False;Polar Coordinates;-1;;30;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-1463.725,771.2213;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-1110.756,-366.3673;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-495.0582,3327.141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-454.7559,-590.3672;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;78;-1479.725,931.2213;Inherit;False;Property;_Vector2;主贴图Tiling And Offset;3;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;81;-774.7559,-814.3672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;77;-1303.725,435.2212;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;80;-1351.725,771.2213;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;723.3579,1676.945;Inherit;True;Property;MaskTex2;遮罩贴图;20;1;[NoScaleOffset];Create;False;2;MaskTex......e(OvO)e.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................;.;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;197;416.9438,3295.141;Inherit;True;Property;DissolveTex4;溶解纹理图;46;1;[NoScaleOffset];Create;False;2;Dissolve......e(OvO)e.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................;.;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;198;726.0045,3315.69;Inherit;True;Property;_Keyword12;溶解通道;47;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;R;A;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;151;-1689.077,5762.81;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;84;-871.7241,707.2213;Inherit;False;Property;_Float4;主贴图U方向速度;7;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-1175.725,1043.221;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;86;-1111.725,435.2212;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-1191.725,899.2213;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;88;-406.7561,-814.3672;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-855.7241,787.2213;Inherit;False;Property;_Float5;主贴图V方向速度;8;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;1222.358,1906.945;Inherit;False;Constant;_Float14;Float 14;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;91;1132.358,1746.945;Inherit;False;Property;_Keyword3;遮罩通道;21;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;R;A;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;97;1414.358,1682.945;Inherit;False;Property;_Keyword6;开启遮罩;19;0;Create;False;0;0;0;False;1;Header(MaskTex......e(OvO)e);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-679.7241,723.2213;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;579.394,-504.2265;Inherit;False;6;DepthTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-214.7561,-526.3672;Inherit;False;58;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;96;-182.7561,-798.3672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;581.321,-390.9608;Inherit;False;12;Depth;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;94;-855.7241,435.2212;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;152;-1397.038,5853.318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1671.228,6040.538;Inherit;False;Constant;_Float59;Float 57;84;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;149;-847.7486,5137.952;Inherit;False;2449.427;1013.979;Dissolve;15;199;169;168;167;166;165;164;163;162;161;160;159;158;156;154;溶解效果;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-230.7561,-430.3672;Inherit;False;Property;_Float24;扰动是否影响流动纹理;39;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;1336.105,3318.047;Inherit;False;DissloveTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1727.428,5207.863;Inherit;False;Property;_DIssolveInstensity4;溶解强度;54;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;101;-70.7561,-926.3672;Inherit;False;Property;_Keyword24;叠加纹理Clamp;11;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-855.5384,5219.914;Inherit;False;200;DissloveTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;1685.152,1676.807;Inherit;False;MaskTex01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-790.7485,5474.202;Inherit;False;Constant;_Float20;Float 1;31;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;157;-1181.685,5842.364;Inherit;False;Property;_Keyword29;粒子透明度控制溶解;45;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;ON;OFF;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;102;-487.7241,451.2212;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-817.7955,5596.69;Inherit;False;Constant;_Float17;Float 0;31;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;103;931.636,-502.2433;Inherit;True;Property;_TextureSample0;Texture Sample 0;47;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-6.756104,-526.3672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;155;-1127.602,5648.584;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.1;False;4;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-575.7485,5409.952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-407.7241,707.2213;Inherit;False;Property;_Float8;扰动是否影响主帖图;38;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-407.7241,611.2213;Inherit;False;58;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;114;1253.592,-478.6553;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;107;-295.7229,451.2212;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-565.3803,5707.042;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;1111.736,-247.6411;Inherit;False;105;MaskTex01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;121.2439,-782.3672;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;112;-215.7241,307.2212;Inherit;False;Property;_Keyword23;主帖图Clamp;2;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;110;583.2439,-797.1238;Inherit;True;Property;AddTex2;流动纹理图;10;1;[NoScaleOffset];Create;False;2;AddTex......e(OvO)e.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................;.;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;1438.12,-415.8202;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;1450.359,-254.5466;Inherit;False;Property;_edge;流动纹理范围;18;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;109;599.2439,-1006.367;Inherit;False;Property;_Color6;流动纹理图颜色;13;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;4.649013,4.649013,4.649013,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-321.0506,5384.051;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-312.0868,5753.561;Inherit;False;Property;_Float22;溶解软硬度;55;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-215.7241,627.2213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;1107.244,-828.3672;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;144;1646.176,-406.0323;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;510.2564,5599.952;Inherit;False;Constant;_Float23;Float 2;48;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-39.7229,435.2212;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;162;124.2475,5394.351;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;164;656.2565,5505.952;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;1819.865,-789.7934;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;118;617.207,194.3448;Inherit;False;Property;_Color3;主帖图颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;119;328.2771,419.2212;Inherit;True;Property;MainTex2;主贴图;0;2;[Header];[NoScaleOffset];Create;False;1;MainTex......e(OvO)e;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;165;656.2565,5425.952;Inherit;False;Constant;_Float26;Float 3;48;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;124;2013.131,-808.3839;Inherit;False;Property;_Keyword7;开启流动纹理;9;0;Create;False;0;0;0;False;1;Header(AddTex......e(OvO)e);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;166;882.2574,5363.952;Inherit;False;Constant;_Float27;Float 23;48;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;167;832.2565,5473.952;Inherit;False;Property;_Keyword14;开启溶解;44;0;Create;False;0;0;0;False;1;Header(Dissolve......e(OvO)e);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;1117.411,379.5085;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;2291.023,-778.8169;Inherit;False;AddTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;2089.276,358.2212;Inherit;False;MainTexRGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;1131.676,5454.517;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;169;1320.362,5453.372;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;121;938.9199,563.6011;Inherit;False;Property;_Keyword4;主帖图通道;1;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;R;A;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;3157.202,-864.9349;Inherit;False;126;MainTexRGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;3164.85,-678.4333;Inherit;False;127;AddTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;128;3384.346,-1200.613;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;1576.803,5449.224;Inherit;False;DissolveSoft;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;2072.713,734.2212;Inherit;False;MainTexAlp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;3495.047,-805.3438;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;3417.595,-10.95641;Inherit;False;199;DissolveSoft;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;3410.732,-272.2896;Inherit;False;129;MainTexAlp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;3659.346,-942.6129;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;3423.54,-151.4953;Inherit;False;105;MaskTex01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;3772.047,-614.3437;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;136;3861.047,-925.3435;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;138;4087.907,-847.4042;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;4355.115,-887.995;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/后期处理/视差地裂;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode1;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullMode1;True;True;True;True;True;True;0;True;_ColorMask1;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;True;_ZWrite1;True;3;True;_ZTest1;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;6;0;5;0
WireConnection;11;0;7;0
WireConnection;11;1;9;0
WireConnection;11;2;10;0
WireConnection;11;3;8;0
WireConnection;12;0;11;0
WireConnection;16;1;14;0
WireConnection;15;0;13;0
WireConnection;20;0;15;0
WireConnection;19;0;14;0
WireConnection;19;1;16;0
WireConnection;19;2;17;0
WireConnection;24;0;18;1
WireConnection;24;1;18;2
WireConnection;22;0;18;3
WireConnection;22;1;18;4
WireConnection;25;0;19;0
WireConnection;25;2;20;0
WireConnection;27;0;25;0
WireConnection;27;1;24;0
WireConnection;27;2;22;0
WireConnection;26;0;21;0
WireConnection;26;1;23;0
WireConnection;28;0;27;0
WireConnection;28;2;26;0
WireConnection;29;0;28;0
WireConnection;30;1;28;0
WireConnection;30;0;29;0
WireConnection;34;0;31;0
WireConnection;35;1;32;0
WireConnection;173;1;172;0
WireConnection;174;0;171;0
WireConnection;36;1;30;0
WireConnection;41;0;34;0
WireConnection;37;0;32;0
WireConnection;37;1;35;0
WireConnection;37;2;33;0
WireConnection;39;1;36;1
WireConnection;39;0;36;4
WireConnection;177;0;172;0
WireConnection;177;1;173;0
WireConnection;177;2;175;0
WireConnection;178;0;174;0
WireConnection;181;0;176;3
WireConnection;181;1;176;4
WireConnection;42;0;38;1
WireConnection;42;1;38;2
WireConnection;45;0;37;0
WireConnection;45;2;41;0
WireConnection;48;0;38;3
WireConnection;48;1;38;4
WireConnection;43;1;39;0
WireConnection;43;2;40;0
WireConnection;180;0;177;0
WireConnection;180;2;178;0
WireConnection;179;0;176;1
WireConnection;179;1;176;2
WireConnection;184;0;180;0
WireConnection;184;1;179;0
WireConnection;184;2;181;0
WireConnection;49;0;45;0
WireConnection;49;1;42;0
WireConnection;49;2;48;0
WireConnection;53;1;47;0
WireConnection;53;0;43;0
WireConnection;50;0;44;0
WireConnection;50;1;46;0
WireConnection;185;0;182;0
WireConnection;185;1;183;0
WireConnection;186;0;184;0
WireConnection;186;2;185;0
WireConnection;57;0;49;0
WireConnection;57;2;50;0
WireConnection;58;0;53;0
WireConnection;54;0;52;0
WireConnection;62;0;57;0
WireConnection;189;0;186;0
WireConnection;56;1;51;0
WireConnection;71;0;65;0
WireConnection;71;1;60;0
WireConnection;61;0;51;0
WireConnection;61;1;56;0
WireConnection;61;2;55;0
WireConnection;64;0;54;0
WireConnection;75;1;57;0
WireConnection;75;0;62;0
WireConnection;191;0;187;0
WireConnection;191;1;188;0
WireConnection;190;1;186;0
WireConnection;190;0;189;0
WireConnection;76;0;61;0
WireConnection;76;2;64;0
WireConnection;69;0;63;3
WireConnection;69;1;63;4
WireConnection;79;0;75;0
WireConnection;79;1;71;0
WireConnection;74;1;66;0
WireConnection;72;0;59;0
WireConnection;70;0;63;1
WireConnection;70;1;63;2
WireConnection;193;0;190;0
WireConnection;193;1;191;0
WireConnection;82;0;68;0
WireConnection;82;1;67;0
WireConnection;81;0;76;0
WireConnection;81;1;70;0
WireConnection;81;2;69;0
WireConnection;77;0;66;0
WireConnection;77;1;74;0
WireConnection;77;2;73;0
WireConnection;80;0;72;0
WireConnection;89;1;79;0
WireConnection;197;1;193;0
WireConnection;198;1;197;1
WireConnection;198;0;197;4
WireConnection;83;0;78;3
WireConnection;83;1;78;4
WireConnection;86;0;77;0
WireConnection;86;2;80;0
WireConnection;87;0;78;1
WireConnection;87;1;78;2
WireConnection;88;0;81;0
WireConnection;88;2;82;0
WireConnection;91;1;89;1
WireConnection;91;0;89;4
WireConnection;97;1;92;0
WireConnection;97;0;91;0
WireConnection;93;0;84;0
WireConnection;93;1;85;0
WireConnection;96;0;88;0
WireConnection;94;0;86;0
WireConnection;94;1;87;0
WireConnection;94;2;83;0
WireConnection;152;0;151;4
WireConnection;200;0;198;0
WireConnection;101;1;88;0
WireConnection;101;0;96;0
WireConnection;105;0;97;0
WireConnection;157;1;152;0
WireConnection;157;0;153;0
WireConnection;102;0;94;0
WireConnection;102;2;93;0
WireConnection;103;0;99;0
WireConnection;103;1;98;0
WireConnection;100;0;90;0
WireConnection;100;1;95;0
WireConnection;155;0;150;0
WireConnection;158;0;201;0
WireConnection;158;1;156;0
WireConnection;114;0;103;1
WireConnection;107;0;102;0
WireConnection;159;0;154;0
WireConnection;159;1;155;0
WireConnection;159;2;157;0
WireConnection;108;0;101;0
WireConnection;108;1;100;0
WireConnection;112;1;102;0
WireConnection;112;0;107;0
WireConnection;110;1;108;0
WireConnection;117;0;114;0
WireConnection;117;1;111;0
WireConnection;161;0;158;0
WireConnection;161;1;159;0
WireConnection;113;0;106;0
WireConnection;113;1;104;0
WireConnection;115;0;109;0
WireConnection;115;1;110;0
WireConnection;144;0;117;0
WireConnection;144;1;145;0
WireConnection;116;0;112;0
WireConnection;116;1;113;0
WireConnection;162;0;161;0
WireConnection;162;2;160;0
WireConnection;164;0;162;0
WireConnection;164;1;163;0
WireConnection;120;0;115;0
WireConnection;120;1;144;0
WireConnection;119;1;116;0
WireConnection;124;0;120;0
WireConnection;167;1;165;0
WireConnection;167;0;164;0
WireConnection;122;0;118;0
WireConnection;122;1;119;0
WireConnection;127;0;124;0
WireConnection;126;0;122;0
WireConnection;168;0;166;0
WireConnection;168;1;167;0
WireConnection;169;0;168;0
WireConnection;121;1;119;1
WireConnection;121;0;119;4
WireConnection;199;0;169;0
WireConnection;129;0;121;0
WireConnection;135;0;130;0
WireConnection;135;1;131;0
WireConnection;134;0;128;0
WireConnection;134;1;135;0
WireConnection;137;0;128;4
WireConnection;137;1;133;0
WireConnection;137;2;123;0
WireConnection;137;3;202;0
WireConnection;136;0;134;0
WireConnection;138;0;136;0
WireConnection;138;3;137;0
WireConnection;0;0;138;0
ASEEND*/
//CHKSM=8515C7518B3A6C8F6D216E110D188B32C450641F