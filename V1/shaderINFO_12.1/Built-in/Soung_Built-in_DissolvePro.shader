// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/进阶功能/多功能溶解"
{
	Properties
	{
		[Header(Settings)][Enum(OFF,0,ON,1)]_ZWrite("深度写入", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 10
		[Header(MainTex)]_MainTex("主帖图", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_MainTexP("主帖图通道", Float) = 0
		[IntRange]_MainTexRotate("主帖图旋转", Range( 0 , 360)) = 0
		[KeywordEnum(Local,Polar,Screen)] _MainTexUVmode("主帖图UV模式", Float) = 0
		_MainTexScreenTilingOffset("主帖图Screen重铺与偏移", Vector) = (1,1,0,0)
		_MainTexPolarScale("主帖图Polar中心与缩放", Vector) = (0.5,0.5,1,1)
		[Enum(Material,0,Custom1xy,1)]_MainTexFlowMode("主帖图流动模式", Float) = 0
		[Enum(Repeat,0,Clamp,1)]_MainTexClamp("主帖图重铺模式", Float) = 0
		_MainTexUspeed("主帖图U速度", Float) = 0
		_MainTexVspeed("主帖图V速度", Float) = 0
		[Toggle]_BackTexEnable("使用双面颜色", Float) = 0
		_BackTex("背面帖图", 2D) = "white" {}
		[HDR]_BackColor("背面颜色", Color) = (0.2216981,0.4811057,1,1)
		[Enum(R,0,A,1)]_BackTexP("背面帖图通道", Float) = 0
		[IntRange]_BackTexRotate("背面旋转", Range( 0 , 360)) = 0
		[KeywordEnum(Local,Polar,Screen)] _BackTexUVmode("背面帖图UV模式", Float) = 0
		_BackTexScreenTilingOffset("背面Screen重铺与偏移", Vector) = (1,1,0,0)
		_BackTexPolarScale("背面Polar中心与缩放", Vector) = (0.5,0.5,1,1)
		_BackTexUspeed("背面U速度", Float) = 0
		_BackTexVspeed("背面V速度", Float) = 0
		[Header(Mask)]_MaskTex("遮罩贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_MaskTexP("遮罩贴图通道", Float) = 0
		[IntRange]_MaskTexRotate("遮罩贴图旋转", Range( 0 , 360)) = 0
		[Enum(Material,0,Custom2wz,1)]_MaskFlowMode("遮罩流动模式", Float) = 0
		[Toggle]_MaskInfBackTex("背面受遮罩影响", Float) = 0
		_MaskUspeed("遮罩U速度", Float) = 0
		_MaskVspeed("遮罩V速度", Float) = 0
		[Header(Noise)]_NoiseTex("扰动贴图", 2D) = "white" {}
		_NoisePower("扰动强度", Range( 0 , 1)) = 0
		[Enum(Material,0,Custom1w,1)]_NoisePowerMode("扰动强度控制模式", Float) = 0
		[Toggle]_NoiseInfDissolve("扰动是否影响正面溶解", Float) = 0
		_NoiseUspeed("扰动U速度", Float) = 0
		_NoiseVspeed("扰动V速度", Float) = 0
		_BackNoiseTex("背面扰动贴图", 2D) = "white" {}
		_BackNoiseValue("背面扰动强度", Range( 0 , 1)) = 0
		_BackNoiseUspeed("背面扰动U速度", Float) = 0
		_BackNoiseVspeed("背面扰动V速度", Float) = 0
		[Header(EnableDissolve)][Toggle]_FlowmapEnable("启用Flowmap溶解", Float) = 0
		[Toggle]_DissolveEdgeEnable("启用溶解描边", Float) = 0
		[Toggle]_DissolvePlusEnable("启用定向溶解", Float) = 0
		[Header(FlowMap (UseRnG))]_FlowMap("FlowMap贴图", 2D) = "white" {}
		[IntRange]_FlowMapRotate("Flowmap旋转", Range( 0 , 360)) = 0
		[Header(Disslove)]_DissolveTex("溶解贴图", 2D) = "white" {}
		[IntRange]_DissolveTexRotate("溶解贴图旋转", Range( 0 , 360)) = 0
		[Enum(R,0,A,1)]_DissolveTexP("溶解贴图通道", Float) = 0
		_DissolveSmooth("溶解平滑度", Range( 0 , 1)) = 0
		_DissolveTexUspeed("溶解U速度", Float) = 0
		_DissolveTexVspeed("溶解V速度", Float) = 0
		[Enum(Material,0,Custom1z,1)]_DissolveMode("溶解控制模式", Float) = 0
		_DissolvePower("溶解进度", Range( 0 , 2)) = 0.3787051
		[HDR]_DissloveEdgeColor("溶解边缘颜色", Color) = (1,0.4109318,0,1)
		_DissolveEdgeWide("溶解边缘宽度", Range( 0 , 1)) = 0.1420648
		[Header(DissolvePath)]_DissolveTexPlus("定向溶解贴图", 2D) = "white" {}
		[IntRange]_DissolveTexPlusRotate("定向溶解旋转", Range( 0 , 360)) = 0
		[Enum(R,0,A,1)]_DissolveTexPlusP("定向溶解通道", Float) = 0
		_DissolveTexPlusPower("定向溶解强度", Range( 1 , 7)) = 1
		_DissolveTexPlusUspeed("定向溶解U速度", Float) = 0
		_DissolveTexPlusVspeed("定向溶解V速度", Float) = 0
		[Enum(Material,0,Custome2xy,1)]_DissolveTexPlusFlowMode("定向溶解流动模式", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_DissolveTexPlusClamp("定向溶解重铺模式", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha [_BlendMode]
		AlphaToMask Off
		Cull [_CullingMode]
		ColorMask RGBA
		ZWrite [_ZWrite]
		ZTest LEqual
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
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _MAINTEXUVMODE_LOCAL _MAINTEXUVMODE_POLAR _MAINTEXUVMODE_SCREEN
			#pragma shader_feature_local _BACKTEXUVMODE_LOCAL _BACKTEXUVMODE_POLAR _BACKTEXUVMODE_SCREEN


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullingMode;
			uniform float _BlendMode;
			uniform float _ZWrite;
			uniform float4 _MainColor;
			uniform sampler2D _MainTex;
			uniform float _MainTexUspeed;
			uniform float _MainTexVspeed;
			uniform float4 _MainTex_ST;
			uniform float _MainTexRotate;
			uniform float4 _MainTexPolarScale;
			uniform float4 _MainTexScreenTilingOffset;
			uniform float _MainTexFlowMode;
			uniform float _MainTexClamp;
			uniform sampler2D _FlowMap;
			uniform float4 _FlowMap_ST;
			uniform float _FlowMapRotate;
			uniform float _DissolvePower;
			uniform float _DissolveMode;
			uniform sampler2D _NoiseTex;
			uniform float _NoiseUspeed;
			uniform float _NoiseVspeed;
			uniform float4 _NoiseTex_ST;
			uniform float _NoisePower;
			uniform float _NoisePowerMode;
			uniform float _DissolveSmooth;
			uniform sampler2D _DissolveTex;
			uniform float _DissolveTexUspeed;
			uniform float _DissolveTexVspeed;
			uniform float4 _DissolveTex_ST;
			uniform float _DissolveTexRotate;
			uniform float _NoiseInfDissolve;
			uniform float _FlowmapEnable;
			uniform float _DissolveTexP;
			uniform sampler2D _DissolveTexPlus;
			uniform float _DissolveTexPlusUspeed;
			uniform float _DissolveTexPlusVspeed;
			uniform float _DissolveTexPlusFlowMode;
			uniform float4 _DissolveTexPlus_ST;
			uniform float _DissolveTexPlusRotate;
			uniform float _DissolveTexPlusClamp;
			uniform float _DissolveTexPlusP;
			uniform float _DissolvePlusEnable;
			uniform float _DissolveTexPlusPower;
			uniform float4 _DissloveEdgeColor;
			uniform float _DissolveEdgeWide;
			uniform float _DissolveEdgeEnable;
			uniform float _MainTexP;
			uniform sampler2D _MaskTex;
			uniform float _MaskUspeed;
			uniform float _MaskVspeed;
			uniform float4 _MaskTex_ST;
			uniform float _MaskTexRotate;
			uniform float _MaskFlowMode;
			uniform float _MaskTexP;
			uniform float4 _BackColor;
			uniform sampler2D _BackTex;
			uniform float _BackTexUspeed;
			uniform float _BackTexVspeed;
			uniform float4 _BackTex_ST;
			uniform float _BackTexRotate;
			uniform float4 _BackTexPolarScale;
			uniform float4 _BackTexScreenTilingOffset;
			uniform sampler2D _BackNoiseTex;
			uniform float _BackNoiseUspeed;
			uniform float _BackNoiseVspeed;
			uniform float4 _BackNoiseTex_ST;
			uniform float _BackNoiseValue;
			uniform float _BackTexP;
			uniform float _MaskInfBackTex;
			uniform float _BackTexEnable;
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
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_color = v.color;
				o.ase_texcoord4 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
			
			fixed4 frag (v2f i , bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult13 = (float2(_MainTexUspeed , _MainTexVspeed));
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float RotatorValue260 = 180.0;
				float cos9 = cos( ( ( _MainTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin9 = sin( ( ( _MainTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator9 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos9 , -sin9 , sin9 , cos9 )) + float2( 0.5,0.5 );
				float2 appendResult50 = (float2(_MainTexPolarScale.x , _MainTexPolarScale.y));
				float2 CenteredUV15_g1 = ( uv_MainTex - appendResult50 );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * _MainTexPolarScale.z * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / 6.28318548202515 ) * _MainTexPolarScale.w )));
				float4 screenPos = i.ase_texcoord2;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult16 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 appendResult18 = (float2(_MainTexScreenTilingOffset.x , _MainTexScreenTilingOffset.y));
				float2 appendResult19 = (float2(_MainTexScreenTilingOffset.z , _MainTexScreenTilingOffset.w));
				#if defined(_MAINTEXUVMODE_LOCAL)
				float2 staticSwitch43 = rotator9;
				#elif defined(_MAINTEXUVMODE_POLAR)
				float2 staticSwitch43 = appendResult23_g1;
				#elif defined(_MAINTEXUVMODE_SCREEN)
				float2 staticSwitch43 = (appendResult16*appendResult18 + appendResult19);
				#else
				float2 staticSwitch43 = rotator9;
				#endif
				float2 panner35 = ( 1.0 * _Time.y * appendResult13 + staticSwitch43);
				float4 texCoord52 = i.ase_texcoord3;
				texCoord52.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float custom1x53 = texCoord52.x;
				float custom1y54 = texCoord52.y;
				float2 appendResult59 = (float2(custom1x53 , custom1y54));
				float2 lerpResult60 = lerp( panner35 , ( panner35 + appendResult59 ) , _MainTexFlowMode);
				float2 lerpResult45 = lerp( lerpResult60 , saturate( lerpResult60 ) , _MainTexClamp);
				float2 uv_FlowMap = i.ase_texcoord1.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float cos247 = cos( ( ( _FlowMapRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin247 = sin( ( ( _FlowMapRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator247 = mul( uv_FlowMap - float2( 0.5,0.5 ) , float2x2( cos247 , -sin247 , sin247 , cos247 )) + float2( 0.5,0.5 );
				float4 tex2DNode234 = tex2D( _FlowMap, rotator247 );
				float2 appendResult198 = (float2(tex2DNode234.r , tex2DNode234.g));
				float2 FlowmapUV427 = appendResult198;
				float custom1z55 = texCoord52.z;
				float lerpResult252 = lerp( _DissolvePower , custom1z55 , _DissolveMode);
				float DissolveValue253 = lerpResult252;
				float2 lerpResult197 = lerp( lerpResult45 , FlowmapUV427 , DissolveValue253);
				float FlowmapEnable481 = 0.0;
				float2 lerpResult331 = lerp( lerpResult45 , lerpResult197 , FlowmapEnable481);
				float2 appendResult335 = (float2(_NoiseUspeed , _NoiseVspeed));
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner338 = ( 1.0 * _Time.y * appendResult335 + uv_NoiseTex);
				float NoiseUV344 = tex2D( _NoiseTex, panner338 ).r;
				float2 temp_cast_0 = (NoiseUV344).xx;
				float custom1w56 = texCoord52.w;
				float lerpResult350 = lerp( _NoisePower , custom1w56 , _NoisePowerMode);
				float NoiseValue352 = lerpResult350;
				float2 lerpResult340 = lerp( lerpResult331 , temp_cast_0 , NoiseValue352);
				float4 tex2DNode6 = tex2D( _MainTex, lerpResult340 );
				float4 MainTexColor66 = ( _MainColor * tex2DNode6 );
				float2 appendResult118 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 panner126 = ( 1.0 * _Time.y * appendResult118 + uv_DissolveTex);
				float cos130 = cos( ( ( _DissolveTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin130 = sin( ( ( _DissolveTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator130 = mul( panner126 - float2( 0.5,0.5 ) , float2x2( cos130 , -sin130 , sin130 , cos130 )) + float2( 0.5,0.5 );
				float2 temp_cast_1 = (NoiseUV344).xx;
				float2 lerpResult347 = lerp( rotator130 , temp_cast_1 , NoiseValue352);
				float2 lerpResult342 = lerp( rotator130 , lerpResult347 , _NoiseInfDissolve);
				float2 lerpResult474 = lerp( lerpResult342 , FlowmapUV427 , DissolveValue253);
				float FlowmapEnable479 = _FlowmapEnable;
				float2 lerpResult477 = lerp( lerpResult342 , lerpResult474 , FlowmapEnable479);
				float4 tex2DNode141 = tex2D( _DissolveTex, lerpResult477 );
				float lerpResult144 = lerp( tex2DNode141.r , tex2DNode141.a , _DissolveTexP);
				float2 appendResult104 = (float2(_DissolveTexPlusUspeed , _DissolveTexPlusVspeed));
				float4 texCoord272 = i.ase_texcoord4;
				texCoord272.xy = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float custom2x275 = texCoord272.x;
				float custom2y274 = texCoord272.y;
				float2 appendResult268 = (float2(custom2x275 , custom2y274));
				float2 lerpResult270 = lerp( appendResult104 , ( appendResult104 + appendResult268 ) , _DissolveTexPlusFlowMode);
				float2 uv_DissolveTexPlus = i.ase_texcoord1.xy * _DissolveTexPlus_ST.xy + _DissolveTexPlus_ST.zw;
				float2 panner123 = ( 1.0 * _Time.y * lerpResult270 + uv_DissolveTexPlus);
				float cos125 = cos( ( ( _DissolveTexPlusRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin125 = sin( ( ( _DissolveTexPlusRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator125 = mul( panner123 - float2( 0.5,0.5 ) , float2x2( cos125 , -sin125 , sin125 , cos125 )) + float2( 0.5,0.5 );
				float2 lerpResult136 = lerp( rotator125 , saturate( rotator125 ) , _DissolveTexPlusClamp);
				float4 tex2DNode138 = tex2D( _DissolveTexPlus, lerpResult136 );
				float lerpResult145 = lerp( tex2DNode138.r , tex2DNode138.a , _DissolveTexPlusP);
				float lerpResult146 = lerp( lerpResult144 , lerpResult145 , _DissolvePlusEnable);
				float temp_output_156_0 = saturate( ( ( lerpResult146 + ( lerpResult144 / _DissolveTexPlusPower ) ) / 2.0 ) );
				float smoothstepResult165 = smoothstep( ( DissolveValue253 - _DissolveSmooth ) , DissolveValue253 , temp_output_156_0);
				float4 temp_cast_2 = (smoothstepResult165).xxxx;
				float4 lerpResult174 = lerp( temp_cast_2 , ( smoothstepResult165 + ( _DissloveEdgeColor * ( step( ( DissolveValue253 - _DissolveEdgeWide ) , temp_output_156_0 ) - step( DissolveValue253 , temp_output_156_0 ) ) ) ) , _DissolveEdgeEnable);
				float3 appendResult182 = (float3(lerpResult174.rgb));
				float3 DissolveColor186 = appendResult182;
				float lerpResult30 = lerp( tex2DNode6.r , tex2DNode6.a , _MainTexP);
				float MainTexAlpha65 = ( _MainColor.a * lerpResult30 );
				float DissolveAlpha188 = (lerpResult174).a;
				float2 appendResult448 = (float2(_MaskUspeed , _MaskVspeed));
				float2 uv_MaskTex = i.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float cos447 = cos( ( ( _MaskTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin447 = sin( ( ( _MaskTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator447 = mul( uv_MaskTex - float2( 0.5,0.5 ) , float2x2( cos447 , -sin447 , sin447 , cos447 )) + float2( 0.5,0.5 );
				float2 panner446 = ( 1.0 * _Time.y * appendResult448 + rotator447);
				float custom2z276 = texCoord272.z;
				float custom2w273 = texCoord272.w;
				float2 appendResult449 = (float2(custom2z276 , custom2w273));
				float2 lerpResult456 = lerp( panner446 , ( panner446 + appendResult449 ) , _MaskFlowMode);
				float4 tex2DNode444 = tex2D( _MaskTex, lerpResult456 );
				float lerpResult464 = lerp( tex2DNode444.r , tex2DNode444.a , _MaskTexP);
				float MaskTexAlpha466 = lerpResult464;
				float4 appendResult70 = (float4((( MainTexColor66 * i.ase_color * float4( DissolveColor186 , 0.0 ) )).rgb , ( MainTexAlpha65 * i.ase_color.a * DissolveAlpha188 * MaskTexAlpha466 )));
				float2 appendResult372 = (float2(_BackTexUspeed , _BackTexVspeed));
				float2 uv_BackTex = i.ase_texcoord1.xy * _BackTex_ST.xy + _BackTex_ST.zw;
				float cos386 = cos( ( ( _BackTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float sin386 = sin( ( ( _BackTexRotate * UNITY_PI ) / RotatorValue260 ) );
				float2 rotator386 = mul( uv_BackTex - float2( 0.5,0.5 ) , float2x2( cos386 , -sin386 , sin386 , cos386 )) + float2( 0.5,0.5 );
				float2 appendResult367 = (float2(_BackTexPolarScale.x , _BackTexPolarScale.y));
				float2 CenteredUV15_g2 = ( uv_BackTex - appendResult367 );
				float2 break17_g2 = CenteredUV15_g2;
				float2 appendResult23_g2 = (float2(( length( CenteredUV15_g2 ) * _BackTexPolarScale.z * 2.0 ) , ( atan2( break17_g2.x , break17_g2.y ) * ( 1.0 / 6.28318548202515 ) * _BackTexPolarScale.w )));
				float2 appendResult363 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 appendResult366 = (float2(_BackTexScreenTilingOffset.x , _BackTexScreenTilingOffset.y));
				float2 appendResult369 = (float2(_BackTexScreenTilingOffset.z , _BackTexScreenTilingOffset.w));
				#if defined(_BACKTEXUVMODE_LOCAL)
				float2 staticSwitch407 = rotator386;
				#elif defined(_BACKTEXUVMODE_POLAR)
				float2 staticSwitch407 = appendResult23_g2;
				#elif defined(_BACKTEXUVMODE_SCREEN)
				float2 staticSwitch407 = (appendResult363*appendResult366 + appendResult369);
				#else
				float2 staticSwitch407 = rotator386;
				#endif
				float2 panner373 = ( 1.0 * _Time.y * appendResult372 + staticSwitch407);
				float2 lerpResult388 = lerp( panner373 , FlowmapUV427 , DissolveValue253);
				float2 lerpResult408 = lerp( panner373 , lerpResult388 , FlowmapEnable479);
				float2 appendResult412 = (float2(_BackNoiseUspeed , _BackNoiseVspeed));
				float2 uv_BackNoiseTex = i.ase_texcoord1.xy * _BackNoiseTex_ST.xy + _BackNoiseTex_ST.zw;
				float2 panner414 = ( 1.0 * _Time.y * appendResult412 + uv_BackNoiseTex);
				float BackNoiseUV417 = tex2D( _BackNoiseTex, panner414 ).r;
				float2 temp_cast_5 = (BackNoiseUV417).xx;
				float2 lerpResult416 = lerp( lerpResult408 , temp_cast_5 , _BackNoiseValue);
				float4 tex2DNode404 = tex2D( _BackTex, lerpResult416 );
				float4 BackTexColor402 = ( _BackColor * tex2DNode404 );
				float lerpResult399 = lerp( tex2DNode404.r , tex2DNode404.a , _BackTexP);
				float BackTexAlpha401 = ( _BackColor.a * lerpResult399 );
				float lerpResult470 = lerp( 1.0 , MaskTexAlpha466 , _MaskInfBackTex);
				float4 appendResult441 = (float4((( BackTexColor402 * i.ase_color * float4( DissolveColor186 , 0.0 ) )).rgb , ( DissolveAlpha188 * BackTexAlpha401 * i.ase_color.a * lerpResult470 )));
				float4 switchResult357 = (((ase_vface>0)?(appendResult70):(appendResult441)));
				float4 lerpResult431 = lerp( appendResult70 , switchResult357 , _BackTexEnable);
				
				
				finalColor = lerpResult431;
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
Node;AmplifyShaderEditor.CommentaryNode;465;-3314.284,1766.147;Inherit;False;2181.73;381.5807;Comment;20;466;464;463;444;447;445;461;462;459;458;457;456;455;446;452;448;454;451;449;453;遮罩贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;443;-5553.81,655.6369;Inherit;False;4426.031;1062.505;Comment;7;174;167;170;181;135;78;77;溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;440;-1101.607,426.6277;Inherit;False;599.6998;435.3;BackAlpha;7;439;470;469;468;434;436;471;背面透明度输出;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;438;-1010.849,-652.937;Inherit;False;404;342;BackColor;3;435;437;433;背面颜色输出;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-4713.607,-526.4317;Inherit;False;3527.408;1147.464;Comment;22;351;352;353;350;349;341;345;340;331;27;33;6;28;66;65;31;30;193;51;63;339;481;主帖图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;339;-3524.519,247.0927;Inherit;False;980.3552;354.4597;扰动贴图;7;344;333;338;334;335;336;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;200.1665,517.4552;Inherit;False;373;125;Comment;2;260;42;旋转常量;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;249;612.317,526.3206;Inherit;False;634;287.0001;Comment;5;253;254;250;251;252;溶解控制模式;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;73;-1142.385,120.0972;Inherit;False;395.4969;288.4505;FrontAlpha;4;467;356;74;68;正面透明度输出;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;71;-1142.463,-288.5863;Inherit;False;391.3733;390.8399;FrontColor;4;75;355;72;67;正面颜色输出;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-3532.464,-474.3471;Inherit;False;1087.664;331.5901;主帖图流动控制;13;47;46;45;11;60;61;36;58;37;59;35;13;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;196.4982,144.2801;Inherit;False;861.6326;349.0175;Comment;10;273;276;274;275;55;53;54;56;272;52;自定义数据流;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-4688.91,-474.2793;Inherit;False;1145.041;915.4491;UV模式;17;8;43;20;19;49;50;9;39;38;40;18;17;15;16;44;248;261;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;4;198,-0.5;Inherit;False;389;119;Comment;3;3;1;2;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/进阶功能/多功能溶解;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_ZWrite;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;2;336,40.5;Inherit;False;Property;_CullingMode;剔除模式;1;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;211,39.5;Inherit;False;Property;_BlendMode;混合模式;2;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;459,39.5;Inherit;False;Property;_ZWrite;深度写入;0;2;[Header];[Enum];Create;False;1;Settings;2;OFF;0;ON;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-5238.573,700.0959;Inherit;False;1516.498;491.9106;溶解UV;22;477;474;475;472;342;347;343;354;346;130;262;80;118;103;112;128;117;107;126;478;479;480;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-5527.174,1207.149;Inherit;False;1967.278;496.4054;定向溶解;22;145;140;138;134;136;132;125;120;98;111;271;123;269;270;268;104;263;266;265;82;97;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;135;-3528.511,842.6315;Inherit;False;1531.266;768.7034;溶解边缘;16;143;256;165;157;163;156;149;147;153;330;146;142;144;141;139;150;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;150;-2879.374,1298.841;Inherit;False;828.6348;290.9063;Comment;7;154;162;164;160;159;158;155;溶解亮边;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;-1559.04,926.8813;Inherit;False;413.0406;265.3306;分离A通道;4;188;186;184;182;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;193;-3531.215,-116.5489;Inherit;False;1245.337;351.4762;Flowmap扭曲主UV;11;427;197;264;255;245;243;244;247;234;198;428;FlowMap溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;252;904.192,582.0338;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;630.1387,576.6873;Inherit;False;Property;_DissolvePower;溶解进度;53;0;Create;False;0;0;0;False;0;False;0.3787051;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;728.1389,654.6873;Inherit;False;55;custom1z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;740.1917,733.0338;Inherit;False;Property;_DissolveMode;溶解控制模式;52;1;[Enum];Create;False;0;2;Material;0;Custom1z;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;1053.192,576.0338;Inherit;False;DissolveValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;215.9405,562.9548;Inherit;False;Constant;_RotatorFloat;RotatorFloat;11;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;437.4982,413.2802;Inherit;False;custom1w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;438.4982,262.2801;Inherit;False;custom1y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;440.4982,187.2801;Inherit;False;custom1x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;437.4982,338.2801;Inherit;False;custom1z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;275;857.0557,190.7457;Inherit;False;custom2x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;374.6791,562.1249;Inherit;False;RotatorValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;358;-4691.437,-1546.396;Inherit;False;3164.693;985.8967;Comment;17;401;402;405;430;418;404;406;403;400;399;416;408;383;361;360;359;482;背面主帖图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;359;-3575.777,-931.0271;Inherit;False;980.3552;354.4597;扰动贴图;7;417;415;414;413;412;411;410;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;360;-3572.734,-1349.98;Inherit;False;486.0638;201.9901;主帖图流动控制;4;381;382;373;372;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;361;-4666.739,-1494.244;Inherit;False;1076.035;913.766;UV模式;16;407;368;365;364;387;362;397;386;385;384;371;370;369;367;366;363;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;383;-3200.002,-1170.625;Inherit;False;351.0815;223.4835;Flowmap扭曲主UV;3;429;396;388;FlowMap溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;431;-147.1324,-0.4648438;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;126;-4805.396,755.0428;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-5219.205,1018.13;Inherit;False;Property;_DissolveTexRotate;溶解贴图旋转;47;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;117;-4955.601,1023.64;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;128;-4773.216,1022.901;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-5214.22,863.212;Inherit;False;Property;_DissolveTexUspeed;溶解U速度;50;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-5214.573,938.3156;Inherit;False;Property;_DissolveTexVspeed;溶解V速度;51;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;118;-5074.944,881.6661;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-5023.991,750.4177;Inherit;False;0;141;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;139;-3385.712,1086.814;Inherit;False;Property;_DissolveTexP;溶解贴图通道;48;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4955.088,1093.009;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-5494.195,1391.204;Inherit;False;Property;_DissolveTexPlusUspeed;定向溶解U速度;60;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-5494.999,1467.727;Inherit;False;Property;_DissolveTexPlusVspeed;定向溶解V速度;61;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-5506.231,1270.723;Inherit;False;0;138;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;265;-5491.862,1548.982;Inherit;False;275;custom2x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-5490.862,1623.982;Inherit;False;274;custom2y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-4805.45,1610.489;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;-5328.406,1417.183;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;268;-5326.862,1571.982;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;270;-5044.862,1417.982;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;269;-5178.862,1492.982;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;123;-4883.263,1278.796;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;111;-4807.495,1541.49;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-5067.538,1536.048;Inherit;False;Property;_DissolveTexPlusRotate;定向溶解旋转;57;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;120;-4630.663,1541.699;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;132;-4307.771,1336.748;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;136;-4160.255,1279.329;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-4341.014,1407.185;Inherit;False;Property;_DissolveTexPlusClamp;定向溶解重铺模式;63;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-3880.997,1437.563;Inherit;False;Property;_DissolveTexPlusP;定向溶解通道;58;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;-3714.004,1279.081;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;144;-3225.038,973.8628;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-3229.471,1090.998;Inherit;False;Property;_DissolveTexPlusPower;定向溶解强度;59;0;Create;False;0;0;0;False;0;False;1;0;1;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;146;-2977.257,974.0679;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-2714.608,1072.029;Inherit;False;Constant;_Disdivide;Disdivide;38;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;-2569.164,974.1349;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-2832.519,1072.551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;149;-2712.3,974.4288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;156;-2366.175,973.6819;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;163;-2498.9,1187.243;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-2767.573,1205.725;Inherit;False;Property;_DissolveSmooth;溶解平滑度;49;0;Create;False;0;0;0;False;0;False;0;0.542;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;165;-2230.537,974.3878;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;-2947.359,1206.036;Inherit;False;253;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;155;-2585.999,1369.522;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;158;-2444.095,1370.303;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;159;-2439.292,1469.537;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;160;-2315.811,1370.016;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-2181.26,1343.87;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;162;-2791.903,1340.386;Inherit;False;Property;_DissloveEdgeColor;溶解边缘颜色;54;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4109318,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;154;-2857.654,1512.975;Inherit;False;Property;_DissolveEdgeWide;溶解边缘宽度;55;0;Create;False;0;0;0;False;0;False;0.1420648;0.542;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-3223.975,898.7441;Inherit;False;Property;_DissolvePlusEnable;启用定向溶解;43;1;[Toggle];Create;False;1;DissloveTexPlus;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;-4614.698,879.6846;Inherit;False;344;NoiseUV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-4617.737,959.1381;Inherit;False;352;NoiseValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;271;-5222.862,1334.982;Inherit;False;Property;_DissolveTexPlusFlowMode;定向溶解流动模式;62;1;[Enum];Create;False;0;2;Material;0;Custome2xy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-4397.332,-424.8225;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-4256.191,96.16081;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;15;-4474.288,67.0605;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;17;-4482.314,240.3095;Inherit;False;Property;_MainTexScreenTilingOffset;主帖图Screen重铺与偏移;8;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;18;-4257.216,234.1091;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;50;-4267.212,-120.4107;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;49;-4494.212,-149.4107;Inherit;False;Property;_MainTexPolarScale;主帖图Polar中心与缩放;9;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;19;-4256.497,332.2514;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;20;-4110.45,96.10941;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;8;-4135.517,-144.5423;Inherit;False;Polar Coordinates;-1;;1;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-3367.49,-396.0138;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;35;-3232.702,-419.9086;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-3188.504,-302.2514;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-3352.265,-301.7302;Inherit;False;53;custom1x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-3353.504,-225.2516;Inherit;False;54;custom1y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-3058.377,-325.8436;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;60;-2884.226,-418.7093;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;45;-2596.676,-417.6417;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;46;-2729.253,-365.27;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3517.79,-346.8149;Inherit;False;Property;_MainTexVspeed;主帖图V速度;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3518.49,-422.7139;Inherit;False;Property;_MainTexUspeed;主帖图U速度;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-4225.603,-298.3137;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;38;-4401.603,-298.3137;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-4666.604,-303.3137;Inherit;False;Property;_MainTexRotate;主帖图旋转;6;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;234;-2988.977,-63.5153;Inherit;True;Property;_FlowMap;FlowMap贴图;44;1;[Header];Create;False;1;FlowMap (UseRnG);0;0;False;0;False;-1;None;bf94bd6749b849f449616591848750c9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;244;-3282.092,13.34489;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;243;-3495.125,-41.96486;Inherit;False;0;234;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;245;-3460.092,83.34491;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-3721.093,78.34491;Inherit;False;Property;_FlowMapRotate;Flowmap旋转;45;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-4400.864,-229.1443;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-3455.144,152.9185;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;30;-1659.262,-14.68466;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1511.001,-38.73742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1375.304,-43.1703;Inherit;False;MainTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1376.304,-142.1702;Inherit;False;MainTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1509.877,-137.7332;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-1948.82,-92.14159;Inherit;True;Property;_MainTex;主帖图;3;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;33;-1864.463,-267.3258;Inherit;False;Property;_MainColor;主颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1813.262,96.31491;Inherit;False;Property;_MainTexP;主帖图通道;5;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;43;-3791.438,-172.6716;Inherit;True;Property;_MainTexUVmode;主帖图UV模式;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Local;Polar;Screen;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;331;-2246.62,-417.0863;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-3474.805,510.0326;Inherit;False;Property;_NoiseVspeed;扰动V速度;36;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-3475.805,432.0327;Inherit;False;Property;_NoiseUspeed;扰动U速度;35;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;335;-3339.805,457.0326;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;334;-3511.696,312.8491;Inherit;False;0;333;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;338;-3210.805,318.0328;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;340;-2101.834,-62.45751;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-2268.797,-43.31793;Inherit;False;344;NoiseUV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-2524.877,253.1824;Inherit;False;Property;_NoisePower;扰动强度;32;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;-2425.374,328.1257;Inherit;False;56;custom1w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;350;-2248.374,258.1257;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;353;-2273.374,34.12573;Inherit;False;352;NoiseValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;352;-2100.371,253.1257;Inherit;False;NoiseValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;351;-2438.374,403.1257;Inherit;False;Property;_NoisePowerMode;扰动强度控制模式;33;1;[Enum];Create;False;0;2;Material;0;Custom1w;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-3060.226,-229.7099;Inherit;False;Property;_MainTexFlowMode;主帖图流动模式;10;1;[Enum];Create;False;0;2;Material;0;Custom1xy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2768.231,-297.6602;Inherit;False;Property;_MainTexClamp;主帖图重铺模式;11;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;363;-4234.021,-923.8036;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;366;-4235.045,-785.8552;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;367;-4245.041,-1140.375;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;369;-4234.326,-687.7134;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;370;-4088.28,-923.855;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;371;-4113.347,-1164.507;Inherit;False;Polar Coordinates;-1;;2;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;384;-4203.433,-1318.278;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;385;-4379.433,-1318.278;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;-4378.694,-1249.109;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;362;-4375.162,-1444.787;Inherit;False;0;404;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;387;-4644.434,-1323.278;Inherit;False;Property;_BackTexRotate;背面旋转;18;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;364;-4452.118,-952.904;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;365;-4449.145,-782.6547;Inherit;False;Property;_BackTexScreenTilingOffset;背面Screen重铺与偏移;20;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;368;-4472.042,-1169.375;Inherit;False;Property;_BackTexPolarScale;背面Polar中心与缩放;21;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;372;-3410.961,-1279.647;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;373;-3276.173,-1303.542;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-3552.96,-1303.347;Inherit;False;Property;_BackTexUspeed;背面U速度;22;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-3552.26,-1227.448;Inherit;False;Property;_BackTexVspeed;背面V速度;23;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;197;-2441.978,-71.51531;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;-2607.527,-51.87469;Inherit;False;427;FlowmapUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;198;-2706.977,32.48438;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;427;-2576.16,45.44786;Inherit;False;FlowmapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;388;-3006.793,-1124.523;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-3180.781,-1027.783;Inherit;False;253;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-3178.323,-1104.905;Inherit;False;427;FlowmapUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;407;-3848.374,-1192.636;Inherit;True;Property;_BackTexUVmode;背面帖图UV模式;19;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Local;Polar;Screen;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;408;-2797.009,-1304.712;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;416;-2467.069,-1244.52;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;399;-2019.494,-1196.747;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;400;-1871.232,-1220.8;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-1870.108,-1319.796;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;404;-2310.055,-1274.204;Inherit;True;Property;_BackTex;背面帖图;15;0;Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;418;-2647.029,-1225.381;Inherit;False;417;BackNoiseUV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;405;-2224.698,-1449.389;Inherit;False;Property;_BackColor;背面颜色;16;1;[HDR];Create;False;0;0;0;False;0;False;0.2216981,0.4811057,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;-1736.535,-1324.233;Inherit;False;BackTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;401;-1735.535,-1225.233;Inherit;False;BackTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;414;-3262.065,-860.087;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;415;-3089.047,-888.8644;Inherit;True;Property;_BackNoiseTex;背面扰动贴图;37;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;413;-3562.955,-865.2708;Inherit;False;0;415;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;67;-1128,-244.3984;Inherit;False;66;MainTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1131.402,173.0038;Inherit;False;65;MainTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-945.8945,177.4515;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-944.4639,-239.5864;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,1;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;75;-1129.036,-75.97173;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;356;-1128.197,252.9216;Inherit;False;188;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;-991.6207,-608.209;Inherit;False;402;BackTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;437;-811.251,-603.8184;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;357;-395.944,24.88999;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;432;-322.3831,243.3991;Inherit;False;Property;_BackTexEnable;使用双面颜色;14;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-539.8663,-240.3476;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;69;-733.8663,-245.3476;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;441;-538.3071,48.22787;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;442;-732.3069,43.22789;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-1967.393,1032.021;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-1970.506,1124.307;Inherit;False;Property;_DissolveEdgeEnable;启用溶解描边;42;1;[Toggle];Create;False;0;2;Disslove;0;MiaoBian;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;174;-1815.408,977.9742;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;184;-1542.375,1067.561;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;-1540.49,977.8681;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;854.0557,341.7455;Inherit;False;custom2z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;855.0557,265.7456;Inherit;False;custom2y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;273;854.0557,416.7457;Inherit;False;custom2w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;453;-2524.312,1838.962;Inherit;False;Property;_MaskUspeed;遮罩U速度;29;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;454;-2524.261,1907.117;Inherit;False;Property;_MaskVspeed;遮罩V速度;30;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;459;-3294.576,1949.033;Inherit;False;Property;_MaskTexRotate;遮罩贴图旋转;26;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;462;-3029.576,2023.034;Inherit;False;260;RotatorValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;461;-2857.576,1954.033;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;464;-1495.072,1883.447;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;467;-1130.477,329.2408;Inherit;False;466;MaskTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-1088.095,467.3761;Inherit;False;188;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;-1088.075,546.5551;Inherit;False;401;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-747.347,467.9109;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;468;-1084.477,625.2408;Inherit;False;466;MaskTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;470;-898.4767,629.2408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;-1035.477,697.2408;Inherit;False;Constant;_IntAlpha;IntAlpha;66;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;406;-2173.496,-1085.748;Inherit;False;Property;_BackTexP;背面帖图通道;17;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;411;-3561.065,-744.0867;Inherit;False;Property;_BackNoiseUspeed;背面扰动U速度;39;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-3560.065,-668.0866;Inherit;False;Property;_BackNoiseVspeed;背面扰动V速度;40;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;412;-3400.065,-715.0867;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-2732.624,-1150.099;Inherit;False;Property;_BackNoiseValue;背面扰动强度;38;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;444;-1787.508,1806.1;Inherit;True;Property;_MaskTex;遮罩贴图;24;1;[Header];Create;False;1;Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;141;-3514.488,896.3476;Inherit;True;Property;_DissolveTex;溶解贴图;46;1;[Header];Create;False;1;Disslove;0;0;False;0;False;-1;99f1f74d3939f974ab9fd2a55d2df3ea;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;138;-4011.883,1249.973;Inherit;True;Property;_DissolveTexPlus;定向溶解贴图;56;1;[Header];Create;False;1;DissolvePath;0;0;False;0;False;-1;473abd245ec141a4abe8aec5e9cd233c;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;333;-3037.788,289.2552;Inherit;True;Property;_NoiseTex;扰动贴图;31;1;[Header];Create;False;1;Noise;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-1405.663,972.1571;Inherit;False;DissolveColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-1336.883,1068.239;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;343;-4446.556,982.6617;Inherit;False;Property;_NoiseInfDissolve;扰动是否影响正面溶解;34;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;347;-4448.375,858.6392;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-2885.046,134.761;Inherit;False;253;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;209.4982,249.2801;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;272;641.2095,250.2839;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;342;-4225.114,835.299;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;-4238.927,954.3944;Inherit;False;427;FlowmapUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;475;-4245.35,1029.927;Inherit;False;253;DissolveValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;474;-4058.763,935.2583;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;477;-3872.914,837.285;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;480;-4053.244,1053.095;Inherit;False;479;FlowmapEnable;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;479;-4282.244,1109.095;Inherit;False;FlowmapEnable;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;481;-2437.284,-358.1277;Inherit;False;FlowmapEnable;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;478;-4472.97,1108.251;Inherit;False;Property;_FlowmapEnable;启用Flowmap溶解;41;2;[Header];[Toggle];Create;False;1;EnableDissolve;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;482;-3023.353,-1260.646;Inherit;False;479;FlowmapEnable;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;417;-2801.057,-865.4376;Inherit;False;BackNoiseUV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;344;-2749.797,312.6821;Inherit;False;NoiseUV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;466;-1340.816,1878.993;Inherit;False;MaskTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;471;-1069.477,773.2408;Inherit;False;Property;_MaskInfBackTex;背面受遮罩影响;28;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;463;-1656.073,1993.447;Inherit;False;Property;_MaskTexP;遮罩贴图通道;25;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;458;-3034.576,1954.033;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;445;-2947.834,1830.907;Inherit;False;0;444;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;456;-1937.36,1835.655;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;448;-2383.405,1859.811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;446;-2246.405,1834.811;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;452;-2550.405,2058.81;Inherit;False;273;custom2w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;449;-2380.405,2006.811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-2548.405,1985.811;Inherit;False;276;custom2z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;455;-2081.26,1931.117;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;457;-2087.361,2022.655;Inherit;False;Property;_MaskFlowMode;遮罩流动模式;27;1;[Enum];Create;False;0;2;Material;0;Custom2wz;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;9;-4106.963,-346.1771;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;447;-2722.62,1836.19;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;125;-4510.746,1278.925;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;130;-4626.386,754.7277;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;247;-3164.719,-34.01792;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;386;-4084.793,-1366.141;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;355;-1127.011,-168.3686;Inherit;False;186;DissolveColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;-996.5601,-528.9681;Inherit;False;186;DissolveColor;1;0;OBJECT;;False;1;FLOAT3;0
WireConnection;0;0;431;0
WireConnection;252;0;251;0
WireConnection;252;1;250;0
WireConnection;252;2;254;0
WireConnection;253;0;252;0
WireConnection;56;0;52;4
WireConnection;54;0;52;2
WireConnection;53;0;52;1
WireConnection;55;0;52;3
WireConnection;275;0;272;1
WireConnection;260;0;42;0
WireConnection;431;0;70;0
WireConnection;431;1;357;0
WireConnection;431;2;432;0
WireConnection;126;0;80;0
WireConnection;126;2;118;0
WireConnection;117;0;107;0
WireConnection;128;0;117;0
WireConnection;128;1;262;0
WireConnection;118;0;112;0
WireConnection;118;1;103;0
WireConnection;104;0;95;0
WireConnection;104;1;97;0
WireConnection;268;0;265;0
WireConnection;268;1;266;0
WireConnection;270;0;104;0
WireConnection;270;1;269;0
WireConnection;270;2;271;0
WireConnection;269;0;104;0
WireConnection;269;1;268;0
WireConnection;123;0;82;0
WireConnection;123;2;270;0
WireConnection;111;0;98;0
WireConnection;120;0;111;0
WireConnection;120;1;263;0
WireConnection;132;0;125;0
WireConnection;136;0;125;0
WireConnection;136;1;132;0
WireConnection;136;2;134;0
WireConnection;145;0;138;1
WireConnection;145;1;138;4
WireConnection;145;2;140;0
WireConnection;144;0;141;1
WireConnection;144;1;141;4
WireConnection;144;2;139;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;146;2;143;0
WireConnection;153;0;149;0
WireConnection;153;1;330;0
WireConnection;147;0;144;0
WireConnection;147;1;142;0
WireConnection;149;0;146;0
WireConnection;149;1;147;0
WireConnection;156;0;153;0
WireConnection;163;0;256;0
WireConnection;163;1;157;0
WireConnection;165;0;156;0
WireConnection;165;1;163;0
WireConnection;165;2;256;0
WireConnection;155;0;256;0
WireConnection;155;1;154;0
WireConnection;158;0;155;0
WireConnection;158;1;156;0
WireConnection;159;0;256;0
WireConnection;159;1;156;0
WireConnection;160;0;158;0
WireConnection;160;1;159;0
WireConnection;164;0;162;0
WireConnection;164;1;160;0
WireConnection;16;0;15;1
WireConnection;16;1;15;2
WireConnection;18;0;17;1
WireConnection;18;1;17;2
WireConnection;50;0;49;1
WireConnection;50;1;49;2
WireConnection;19;0;17;3
WireConnection;19;1;17;4
WireConnection;20;0;16;0
WireConnection;20;1;18;0
WireConnection;20;2;19;0
WireConnection;8;1;44;0
WireConnection;8;2;50;0
WireConnection;8;3;49;3
WireConnection;8;4;49;4
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;35;0;43;0
WireConnection;35;2;13;0
WireConnection;59;0;37;0
WireConnection;59;1;58;0
WireConnection;36;0;35;0
WireConnection;36;1;59;0
WireConnection;60;0;35;0
WireConnection;60;1;36;0
WireConnection;60;2;61;0
WireConnection;45;0;60;0
WireConnection;45;1;46;0
WireConnection;45;2;47;0
WireConnection;46;0;60;0
WireConnection;40;0;38;0
WireConnection;40;1;261;0
WireConnection;38;0;39;0
WireConnection;234;1;247;0
WireConnection;244;0;245;0
WireConnection;244;1;264;0
WireConnection;245;0;248;0
WireConnection;30;0;6;1
WireConnection;30;1;6;4
WireConnection;30;2;27;0
WireConnection;31;0;33;4
WireConnection;31;1;30;0
WireConnection;65;0;31;0
WireConnection;66;0;28;0
WireConnection;28;0;33;0
WireConnection;28;1;6;0
WireConnection;6;1;340;0
WireConnection;43;1;9;0
WireConnection;43;0;8;0
WireConnection;43;2;20;0
WireConnection;331;0;45;0
WireConnection;331;1;197;0
WireConnection;331;2;481;0
WireConnection;335;0;336;0
WireConnection;335;1;337;0
WireConnection;338;0;334;0
WireConnection;338;2;335;0
WireConnection;340;0;331;0
WireConnection;340;1;345;0
WireConnection;340;2;353;0
WireConnection;350;0;341;0
WireConnection;350;1;349;0
WireConnection;350;2;351;0
WireConnection;352;0;350;0
WireConnection;363;0;364;1
WireConnection;363;1;364;2
WireConnection;366;0;365;1
WireConnection;366;1;365;2
WireConnection;367;0;368;1
WireConnection;367;1;368;2
WireConnection;369;0;365;3
WireConnection;369;1;365;4
WireConnection;370;0;363;0
WireConnection;370;1;366;0
WireConnection;370;2;369;0
WireConnection;371;1;362;0
WireConnection;371;2;367;0
WireConnection;371;3;368;3
WireConnection;371;4;368;4
WireConnection;384;0;385;0
WireConnection;384;1;397;0
WireConnection;385;0;387;0
WireConnection;372;0;382;0
WireConnection;372;1;381;0
WireConnection;373;0;407;0
WireConnection;373;2;372;0
WireConnection;197;0;45;0
WireConnection;197;1;428;0
WireConnection;197;2;255;0
WireConnection;198;0;234;1
WireConnection;198;1;234;2
WireConnection;427;0;198;0
WireConnection;388;0;373;0
WireConnection;388;1;429;0
WireConnection;388;2;396;0
WireConnection;407;1;386;0
WireConnection;407;0;371;0
WireConnection;407;2;370;0
WireConnection;408;0;373;0
WireConnection;408;1;388;0
WireConnection;408;2;482;0
WireConnection;416;0;408;0
WireConnection;416;1;418;0
WireConnection;416;2;430;0
WireConnection;399;0;404;1
WireConnection;399;1;404;4
WireConnection;399;2;406;0
WireConnection;400;0;405;4
WireConnection;400;1;399;0
WireConnection;403;0;405;0
WireConnection;403;1;404;0
WireConnection;404;1;416;0
WireConnection;402;0;403;0
WireConnection;401;0;400;0
WireConnection;414;0;413;0
WireConnection;414;2;412;0
WireConnection;415;1;414;0
WireConnection;74;0;68;0
WireConnection;74;1;75;4
WireConnection;74;2;356;0
WireConnection;74;3;467;0
WireConnection;72;0;67;0
WireConnection;72;1;75;0
WireConnection;72;2;355;0
WireConnection;437;0;433;0
WireConnection;437;1;75;0
WireConnection;437;2;435;0
WireConnection;357;0;70;0
WireConnection;357;1;441;0
WireConnection;70;0;69;0
WireConnection;70;3;74;0
WireConnection;69;0;72;0
WireConnection;441;0;442;0
WireConnection;441;3;439;0
WireConnection;442;0;437;0
WireConnection;170;0;165;0
WireConnection;170;1;164;0
WireConnection;174;0;165;0
WireConnection;174;1;170;0
WireConnection;174;2;167;0
WireConnection;184;0;174;0
WireConnection;182;0;174;0
WireConnection;276;0;272;3
WireConnection;274;0;272;2
WireConnection;273;0;272;4
WireConnection;461;0;458;0
WireConnection;461;1;462;0
WireConnection;464;0;444;1
WireConnection;464;1;444;4
WireConnection;464;2;463;0
WireConnection;439;0;436;0
WireConnection;439;1;434;0
WireConnection;439;2;75;4
WireConnection;439;3;470;0
WireConnection;470;0;469;0
WireConnection;470;1;468;0
WireConnection;470;2;471;0
WireConnection;412;0;411;0
WireConnection;412;1;410;0
WireConnection;444;1;456;0
WireConnection;141;1;477;0
WireConnection;138;1;136;0
WireConnection;333;1;338;0
WireConnection;186;0;182;0
WireConnection;188;0;184;0
WireConnection;347;0;130;0
WireConnection;347;1;346;0
WireConnection;347;2;354;0
WireConnection;342;0;130;0
WireConnection;342;1;347;0
WireConnection;342;2;343;0
WireConnection;474;0;342;0
WireConnection;474;1;472;0
WireConnection;474;2;475;0
WireConnection;477;0;342;0
WireConnection;477;1;474;0
WireConnection;477;2;480;0
WireConnection;479;0;478;0
WireConnection;417;0;415;1
WireConnection;344;0;333;1
WireConnection;466;0;464;0
WireConnection;458;0;459;0
WireConnection;456;0;446;0
WireConnection;456;1;455;0
WireConnection;456;2;457;0
WireConnection;448;0;453;0
WireConnection;448;1;454;0
WireConnection;446;0;447;0
WireConnection;446;2;448;0
WireConnection;449;0;451;0
WireConnection;449;1;452;0
WireConnection;455;0;446;0
WireConnection;455;1;449;0
WireConnection;9;0;44;0
WireConnection;9;2;40;0
WireConnection;447;0;445;0
WireConnection;447;2;461;0
WireConnection;125;0;123;0
WireConnection;125;2;120;0
WireConnection;130;0;126;0
WireConnection;130;2;128;0
WireConnection;247;0;243;0
WireConnection;247;2;244;0
WireConnection;386;0;362;0
WireConnection;386;2;384;0
ASEEND*/
//CHKSM=D0F50A4688E4D2ACD03F761D719190F51CFBFD36