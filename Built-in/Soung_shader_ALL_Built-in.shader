// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特效全功能通用"
{
	Properties
	{
		[Enum(Additive,1,AlphaBlend,10)]_Dst("混合模式", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("剔除模式", Float) = 0
		[Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
		[Enum(ON,1,OFF,0)]_Zwrite("深度写入", Float) = 0
		_SoftParticle("软粒子", Range( 0 , 10)) = 0
		[Header(Main_Tex)]_Main_Tex("主帖图", 2D) = "white" {}
		[HDR]_Main_Tex_Color("主帖图颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_Main_Tex_A_R("主帖图通道", Float) = 0
		[Enum(Normal,0,Custom1zw,1)]_Main_Tex_Custom_ZW("主帖图UV流动方式", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_Main_Tex_ClampSwitch("主帖图重铺模式", Float) = 0
		[IntRange]_Main_Tex_Rotator("主帖图旋转", Range( 0 , 360)) = 0
		_Main_Tex_U_speed("主帖图U方向速率", Float) = 0
		_Main_Tex_V_speed("主帖图V方向速率", Float) = 0
		[Header(Remap_Tex)]_Remap_Tex("颜色叠加贴图", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_Remap_Tex_Followl_Main_Tex("跟随主贴图一次性UV移动", Float) = 0
		[Enum(R,0,A,1)]_Remap_Tex_A_R("颜色叠加贴图", Float) = 0
		_Remap_Tex_Desaturate("颜色贴图去色", Range( 0 , 1)) = 0
		[Enum(Repeat,0,Clmap,1)]_Remap_Tex_ClampSwitch("颜色叠加重铺模式", Float) = 0
		[IntRange]_Remap_Tex_Rotator("颜色叠加旋转", Range( 0 , 360)) = 0
		_Remap_Tex_U_speed("颜色叠加U方向速率", Float) = 0
		_Remap_Tex_V_speed("颜色叠加V方向速率", Float) = 0
		[Header(Mask_Tex)]_Mask_Tex("遮罩贴图", 2D) = "white" {}
		[Enum(Repeat,0,Clmap,1)]_Mask_Tex_ClampSwitch("遮罩贴图重铺模式", Float) = 0
		[Enum(R,0,A,1)]_Mask_Tex_A_R("遮罩贴图通道", Float) = 0
		[IntRange]_Mask_Tex_Rotator("遮罩贴图旋转", Range( 0 , 360)) = 0
		_Mask_Tex_U_speed("遮罩贴图U方向速率", Float) = 0
		_Mask_Tex_V_speed("遮罩贴图V方向速率", Float) = 0
		[Header(Mask_Tex2)]_Mask_Tex2("遮罩贴图2", 2D) = "white" {}
		[Enum(Repeat,0,Clmap,1)]_Mask_Tex_ClampSwitch2("遮罩贴图2重铺模式", Float) = 0
		[Enum(R,0,A,1)]_Mask_Tex_A_R2("遮罩贴图2通道", Float) = 0
		[IntRange]_Mask_Tex_Rotator2("遮罩贴图2旋转", Range( 0 , 360)) = 0
		_Mask_Tex_U_speed2("遮罩2U方向速率", Float) = 0
		_Mask_Tex_V_speed2("遮罩2V方向速率", Float) = 0
		[Header(Liuguang_Tex)]_LiuguangTex("流光纹理", 2D) = "white" {}
		[Toggle(_LGTEXSWITCH_ON)] _LGTexSwitch("流光开关", Float) = 0
		[Enum(R,0,A,1)]_LiuguangTex_P("流光纹理通道", Float) = 0
		[IntRange]_LG_Tex_Rotator("流光纹理旋转", Range( 0 , 360)) = 0
		[HDR]_LGColor("流光颜色", Color) = (1,1,1,1)
		[Toggle]_UseLGTexColor("是否禁用纹理自身颜色", Float) = 1
		_LGTex_U_Speed("流光U方向速率", Float) = 0
		_LGTex_V_Speed("流光V方向速率", Float) = 0
		[Header(Dissolve_Tex)]_Dissolve_Tex("溶解贴图", 2D) = "white" {}
		[Toggle(_DISSOLVE_SWITCH_ON)] _Dissolve_Switch("溶解开关", Float) = 0
		[Enum(R,0,A,1)]_Dissolve_Tex_A_R("溶解贴图通道", Float) = 0
		[Enum(OFF,0,ON,1)]_Dissolve_Tex_Custom_X("是否Custom1x控制溶解", Float) = 0
		[IntRange]_Dissolve_Tex_Rotator("溶解贴图旋转", Range( 0 , 360)) = 0
		_Dissolve_Tex_smooth("溶解平滑度", Range( 0.5 , 1)) = 0.5
		_Dissolve_Tex_power("溶解进度", Range( 0 , 1)) = 0
		_Dissolve_Tex_U_speed("溶解U方向速率", Float) = 0
		_Dissolve_Tex_V_speed("溶解V方向速率", Float) = 0
		[Header(Distortion_Tex)]_Distortion_Tex("扭曲贴图", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_Distortion_Switch("是否启用扭曲", Float) = 0
		_Distortion_Tex_Power("扭曲强度", Float) = 0
		_Distortion_Tex_U_speed("扭曲U方向速率", Float) = 0
		_Distortion_Tex_V_speed("扭曲V方向速率", Float) = 0
		[HDR][Header(Fresnel)]_Fresnel_Color("菲涅尔颜色", Color) = (1,1,1,1)
		[Toggle(_FRESNEL_SWITCH_ON)] _Fresnel_Switch("菲涅尔开关", Float) = 0
		[Enum(Fresnel,0,Bokeh,1)]_Fresnel_Bokeh("菲涅尔模式", Float) = 0
		_Fresnel_scale("菲涅尔亮度", Float) = 1
		_Fresnel_power("菲涅尔强度", Float) = 5
		[Header(Wpo_Tex)]_WPO_Tex("顶点偏移贴图", 2D) = "white" {}
		[Toggle(_WPO_SWITCH_ON)] _WPO_Switch("顶点偏移开关", Float) = 0
		[Enum(Normal,0,Custom1y,1)]_WPO_CustomSwitch_Y("顶点偏移模式", Float) = 0
		_WPO_tex_power("顶点偏移强度", Float) = 0
		_WPO_Tex_Direction("顶点偏移轴向", Vector) = (1,1,1,0)
		_WPO_Tex_U_speed("顶点偏移U方向速率", Float) = 0
		[ASEEnd]_WPO_Tex_V_speed("顶点偏移V方向速率", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.5
		ENDCG
		Blend SrcAlpha [_Dst]
		AlphaToMask Off
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite [_Zwrite]
		ZTest [_ZTestMode]
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
			#pragma shader_feature _WPO_SWITCH_ON
			#pragma shader_feature _LGTEXSWITCH_ON
			#pragma shader_feature _FRESNEL_SWITCH_ON
			#pragma shader_feature _DISSOLVE_SWITCH_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _Dst;
			uniform float _CullMode;
			uniform float _Zwrite;
			uniform float _ZTestMode;
			uniform float _WPO_tex_power;
			uniform float _WPO_CustomSwitch_Y;
			uniform sampler2D _WPO_Tex;
			uniform float _WPO_Tex_U_speed;
			uniform float _WPO_Tex_V_speed;
			uniform float4 _WPO_Tex_ST;
			uniform float4 _WPO_Tex_Direction;
			uniform sampler2D _LiuguangTex;
			uniform float _LGTex_U_Speed;
			uniform float _LGTex_V_Speed;
			uniform float4 _LiuguangTex_ST;
			uniform float _LG_Tex_Rotator;
			uniform float _LiuguangTex_P;
			uniform float4 _LGColor;
			uniform float _UseLGTexColor;
			uniform float4 _Main_Tex_Color;
			uniform sampler2D _Main_Tex;
			uniform float _Main_Tex_U_speed;
			uniform float _Main_Tex_V_speed;
			uniform float4 _Main_Tex_ST;
			uniform float _Main_Tex_Custom_ZW;
			uniform float _Distortion_Tex_Power;
			uniform sampler2D _Distortion_Tex;
			uniform float _Distortion_Tex_U_speed;
			uniform float _Distortion_Tex_V_speed;
			uniform float4 _Distortion_Tex_ST;
			uniform float _Distortion_Switch;
			uniform float _Main_Tex_Rotator;
			uniform float _Main_Tex_ClampSwitch;
			uniform float _Fresnel_power;
			uniform float _Fresnel_scale;
			uniform float _Fresnel_Bokeh;
			uniform float _Dissolve_Tex_smooth;
			uniform sampler2D _Dissolve_Tex;
			uniform float _Dissolve_Tex_U_speed;
			uniform float _Dissolve_Tex_V_speed;
			uniform float4 _Dissolve_Tex_ST;
			uniform float _Dissolve_Tex_Rotator;
			uniform float _Dissolve_Tex_A_R;
			uniform float _Dissolve_Tex_power;
			uniform float _Dissolve_Tex_Custom_X;
			uniform float4 _Fresnel_Color;
			uniform sampler2D _Remap_Tex;
			uniform float _Remap_Tex_U_speed;
			uniform float _Remap_Tex_V_speed;
			uniform float4 _Remap_Tex_ST;
			uniform float _Remap_Tex_Followl_Main_Tex;
			uniform float _Remap_Tex_Rotator;
			uniform float _Remap_Tex_ClampSwitch;
			uniform float _Remap_Tex_Desaturate;
			uniform float _Main_Tex_A_R;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _SoftParticle;
			uniform sampler2D _Mask_Tex;
			uniform float _Mask_Tex_U_speed;
			uniform float _Mask_Tex_V_speed;
			uniform float4 _Mask_Tex_ST;
			uniform float _Mask_Tex_Rotator;
			uniform float _Mask_Tex_ClampSwitch;
			uniform float _Mask_Tex_A_R;
			uniform float _Remap_Tex_A_R;
			uniform sampler2D _Mask_Tex2;
			uniform float _Mask_Tex_U_speed2;
			uniform float _Mask_Tex_V_speed2;
			uniform float4 _Mask_Tex2_ST;
			uniform float _Mask_Tex_Rotator2;
			uniform float _Mask_Tex_ClampSwitch2;
			uniform float _Mask_Tex_A_R2;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

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
				
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				o.ase_texcoord2 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord3.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = Vertex117.rgb;
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
				float4 temp_cast_0 = (0.0).xxxx;
				float2 appendResult509 = (float2(_LGTex_U_Speed , _LGTex_V_Speed));
				float2 uv_LiuguangTex = i.ase_texcoord1.xy * _LiuguangTex_ST.xy + _LiuguangTex_ST.zw;
				float2 panner514 = ( 1.0 * _Time.y * appendResult509 + uv_LiuguangTex);
				float cos510 = cos( ( ( _LG_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin510 = sin( ( ( _LG_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float2 rotator510 = mul( panner514 - float2( 0.5,0.5 ) , float2x2( cos510 , -sin510 , sin510 , cos510 )) + float2( 0.5,0.5 );
				float4 tex2DNode521 = tex2D( _LiuguangTex, rotator510 );
				float3 appendResult537 = (float3(tex2DNode521.r , tex2DNode521.g , tex2DNode521.b));
				float lerpResult523 = lerp( tex2DNode521.r , tex2DNode521.a , _LiuguangTex_P);
				float4 lerpResult528 = lerp( ( float4( ( appendResult537 * lerpResult523 ) , 0.0 ) * _LGColor ) , ( lerpResult523 * _LGColor ) , _UseLGTexColor);
				#ifdef _LGTEXSWITCH_ON
				float4 staticSwitch532 = lerpResult528;
				#else
				float4 staticSwitch532 = temp_cast_0;
				#endif
				float4 liuguang524 = staticSwitch532;
				float2 appendResult298 = (float2(( _Main_Tex_U_speed * _Time.y ) , ( _Time.y * _Main_Tex_V_speed )));
				float2 uv_Main_Tex = i.ase_texcoord1.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float4 texCoord288 = i.ase_texcoord2;
				texCoord288.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult301 = (float2(texCoord288.z , texCoord288.w));
				float2 lerpResult308 = lerp( ( frac( appendResult298 ) + uv_Main_Tex ) , ( uv_Main_Tex + appendResult301 ) , _Main_Tex_Custom_ZW);
				float2 appendResult283 = (float2(_Distortion_Tex_U_speed , _Distortion_Tex_V_speed));
				float2 uv_Distortion_Tex = i.ase_texcoord1.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 panner286 = ( 1.0 * _Time.y * appendResult283 + uv_Distortion_Tex);
				float lerpResult309 = lerp( 0.0 , ( _Distortion_Tex_Power * (-0.5 + (tex2D( _Distortion_Tex, panner286 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) , _Distortion_Switch);
				float2 ONE214 = ( lerpResult308 + lerpResult309 );
				float cos321 = cos( ( ( _Main_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin321 = sin( ( ( _Main_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float2 rotator321 = mul( ONE214 - float2( 0.5,0.5 ) , float2x2( cos321 , -sin321 , sin321 , cos321 )) + float2( 0.5,0.5 );
				float2 lerpResult411 = lerp( rotator321 , saturate( rotator321 ) , _Main_Tex_ClampSwitch);
				float4 tex2DNode1 = tex2D( _Main_Tex, lerpResult411 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
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
				float2 uv_Dissolve_Tex = i.ase_texcoord1.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float cos430 = cos( ( ( _Dissolve_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin430 = sin( ( ( _Dissolve_Tex_Rotator * UNITY_PI ) / 180.0 ) );
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
				float2 uv_Remap_Tex = i.ase_texcoord1.xy * _Remap_Tex_ST.xy + _Remap_Tex_ST.zw;
				float2 panner421 = ( 1.0 * _Time.y * appendResult420 + uv_Remap_Tex);
				float2 temp_cast_2 = (0.0).xx;
				float2 GAM_MAIN_Move446 = appendResult301;
				float2 lerpResult448 = lerp( temp_cast_2 , GAM_MAIN_Move446 , _Remap_Tex_Followl_Main_Tex);
				float cos399 = cos( ( ( _Remap_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin399 = sin( ( ( _Remap_Tex_Rotator * UNITY_PI ) / 180.0 ) );
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
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth393 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth393 = abs( ( screenDepth393 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _SoftParticle ) );
				float soft219 = saturate( distanceDepth393 );
				float2 appendResult332 = (float2(_Mask_Tex_U_speed , _Mask_Tex_V_speed));
				float2 uv_Mask_Tex = i.ase_texcoord1.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
				float2 panner334 = ( 1.0 * _Time.y * appendResult332 + uv_Mask_Tex);
				float cos335 = cos( ( ( _Mask_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin335 = sin( ( ( _Mask_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float2 rotator335 = mul( panner334 - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
				float2 lerpResult413 = lerp( rotator335 , saturate( rotator335 ) , _Mask_Tex_ClampSwitch);
				float4 tex2DNode327 = tex2D( _Mask_Tex, lerpResult413 );
				float lerpResult453 = lerp( tex2DNode327.r , tex2DNode327.a , _Mask_Tex_A_R);
				float two215 = lerpResult453;
				float lerpResult432 = lerp( tex2DNode406.r , tex2DNode406.a , _Remap_Tex_A_R);
				float2 appendResult490 = (float2(_Mask_Tex_U_speed2 , _Mask_Tex_V_speed2));
				float2 uv_Mask_Tex2 = i.ase_texcoord1.xy * _Mask_Tex2_ST.xy + _Mask_Tex2_ST.zw;
				float2 panner492 = ( 1.0 * _Time.y * appendResult490 + uv_Mask_Tex2);
				float cos493 = cos( ( ( _Mask_Tex_Rotator2 * UNITY_PI ) / 180.0 ) );
				float sin493 = sin( ( ( _Mask_Tex_Rotator2 * UNITY_PI ) / 180.0 ) );
				float2 rotator493 = mul( panner492 - float2( 0.5,0.5 ) , float2x2( cos493 , -sin493 , sin493 , cos493 )) + float2( 0.5,0.5 );
				float2 lerpResult495 = lerp( rotator493 , saturate( rotator493 ) , _Mask_Tex_ClampSwitch2);
				float4 tex2DNode498 = tex2D( _Mask_Tex2, lerpResult495 );
				float lerpResult496 = lerp( tex2DNode498.r , tex2DNode498.a , _Mask_Tex_A_R2);
				float mask2503 = lerpResult496;
				float4 appendResult552 = (float4(( liuguang524 + ( i.ase_color * ( _Main_Tex_Color * tex2DNode1 ) * four222 * float4( Gam258 , 0.0 ) ) ).rgb , ( i.ase_color.a * _Main_Tex_Color.a * lerpResult409 * Three217 * soft219 * two215 * lerpResult432 * mask2503 )));
				
				
				finalColor = (appendResult552).xyzw;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "Soung_ShaderGUI_Built_in"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;277;-2998.344,-1601.401;Inherit;False;1344.04;453.14;UV流动;17;308;306;305;302;301;300;298;297;293;289;288;287;285;284;443;446;465;主帖图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;276;-3004.946,-1143.765;Inherit;False;1363.104;498.9412;扭曲;15;310;309;307;304;303;299;292;286;283;282;281;280;278;457;458;扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;336;-4033.097,437.3795;Inherit;False;2440.182;539.9002;溶解;33;346;342;340;339;217;374;371;368;367;384;364;366;360;361;357;355;417;349;351;352;347;344;348;353;416;341;430;426;428;427;429;463;464;软溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;301;-2746.481,-1244.668;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;427;-3785.89,822.5604;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;465;-2563.128,-1180.862;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;283;-2761.389,-789.2109;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;380;-2645.585,990.184;Inherit;False;2230.076;510.9691;Gam;30;406;431;442;432;258;425;441;433;435;434;399;461;450;421;460;462;420;396;391;459;419;389;448;418;385;451;447;449;381;476;颜色叠加;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;429;-3581.36,827.6313;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;458;-2611.134,-879.364;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;378;-3814.854,-150.4367;Inherit;False;2203.762;580.8257;菲尼尔;23;438;222;375;373;372;369;370;437;436;365;363;362;359;356;354;358;350;345;343;338;337;440;439;菲涅尔边缘;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-2068.261,-1221.425;Inherit;False;GAM_MAIN_Move;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;451;-2423.49,1289.231;Inherit;False;Constant;_Float14;Float 14;54;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-2993.48,-1081.163;Inherit;False;0;292;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;457;-2767.974,-938.0294;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-2641.586,1332.917;Inherit;False;446;GAM_MAIN_Move;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;464;-3469.769,714.5999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;287;-2938.566,-1466.115;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-2691.157,-1520.45;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;463;-3779.769,693.5999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2691.335,-1418.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;286;-2672.053,-1077.006;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;341;-3990.308,495.4476;Inherit;False;0;353;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;385;-1973.169,1281.531;Inherit;False;Constant;_Float12;Float 12;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;389;-2009.005,1211.771;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;448;-2284.289,1308.933;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;278;-2316.67,-912.8144;Inherit;False;250.2743;263.226;映射;1;296;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;430;-3767.982,498.9272;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;396;-1810.418,1262.918;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;391;-2568.245,1031.97;Inherit;False;0;406;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;459;-2053.545,1207.278;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;420;-2396.364,1196.357;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;342;-3722.916,624.2188;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;297;-2548.713,-1402.201;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;346;-3555.99,503.1738;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-2770.076,-1321.417;Inherit;False;five;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;296;-2251.354,-832.7675;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;311;-3804.278,-629.8517;Inherit;False;1804.608;470.3787;MASK;17;215;327;413;414;325;335;324;334;331;332;333;323;322;330;329;452;453;遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;462;-1719.546,1196.278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;460;-2192.546,1167.279;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;421;-2349.207,1044.887;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-3413.464,790.8551;Inherit;False;300;five;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;-2271.222,-1467.394;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-2041.886,-860.3583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-2263.272,-1347.513;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-1983.567,-942.4549;Inherit;False;Constant;_Float4;Float 4;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;461;-2024.545,1164.279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;450;-2138.118,1042.852;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;308;-2033.979,-1467.467;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;351;-3234.978,749.1977;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;312;-1992.634,-631.6931;Inherit;False;353.1464;462.3351;旋转;6;319;318;316;317;320;321;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;309;-1854.461,-868.8378;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;379;-4038.124,985.776;Inherit;False;1357.064;513.0515;顶点偏移;17;117;408;405;404;397;402;398;401;392;395;390;394;386;387;382;383;456;顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;399;-1982.796,1041.787;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;417;-2967.53,495.3727;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-1754.733,-1106.798;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-3065.048,748.7742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;355;-2780.357,492.9502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;434;-1789.223,1127.729;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;386;-3819.563,1351.923;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;360;-2672.912,492.6289;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;387;-4015.871,1207.07;Inherit;False;0;397;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;317;-1807.319,-472.5045;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;433;-1640.485,1051.195;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;476;-1414.547,1056.547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;320;-1758.598,-284.0762;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;366;-2543.004,491.4722;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-1978.921,-596.9757;Inherit;False;214;ONE;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;390;-3678.016,1328.524;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;384;-2471.202,843.675;Inherit;False;864.7548;118.4831;软粒子;4;400;393;388;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;364;-2546.315,578.2346;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;401;-3424.758,1148.736;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;368;-2409.182,551.9802;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;272;-1519.365,-574.176;Inherit;False;317.8248;263.5372;Clamp;2;314;411;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-2390.737,477.1368;Inherit;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-2348.08,-109.8452;Inherit;False;Constant;_Float9;Float 9;35;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;398;-3395.739,1029.807;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;321;-1819.908,-592.9556;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;314;-1498.292,-478.201;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;405;-3082.053,1070.546;Inherit;False;Constant;_Float5;Float 5;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;393;-2176.349,868.8671;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;441;-960.3836,1038.185;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-3084.891,1153.761;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;411;-1346.54,-529.9504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-1887.078,498.9161;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;400;-1931.391,890.4071;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-1788.698,-75.74274;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;425;-768.143,1038.969;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-1651.099,-59.50719;Inherit;False;four;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;-684.8089,-336.3669;Inherit;False;473.0941;444.9443;ALPHA模式连到不透明度，ADD模式连到Emission;6;506;218;220;216;257;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;456;-2750.186,1300.194;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1788.901,882.9451;Inherit;False;soft;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-1790.037,699.8013;Inherit;False;Three;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-598.0679,1035.221;Inherit;False;Gam;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;409;-843.8145,-337.8983;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;-803.1,-641.7573;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;432;-765.6511,1118.276;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-2871.313,1410.971;Inherit;False;Vertex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;3;-1332.854,-925.3873;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-342.4396,-266.7775;Inherit;False;8;8;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-2944.966,-1538.257;Inherit;False;Property;_Main_Tex_U_speed;主帖图U方向速率;11;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-2944.959,-1393.85;Inherit;False;Property;_Main_Tex_V_speed;主帖图V方向速率;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-2981.137,-1319.762;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;298;-2544.448,-1495.251;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;443;-2420.229,-1479.481;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2324.935,-1245.67;Inherit;False;Property;_Main_Tex_Custom_ZW;主帖图UV流动方式;8;1;[Enum];Create;False;0;2;Normal;0;Custom1zw;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-2990.232,-801.7194;Inherit;False;Property;_Distortion_Tex_U_speed;扭曲U方向速率;53;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;292;-2501.396,-1105.782;Inherit;True;Property;_Distortion_Tex;扭曲贴图;50;1;[Header];Create;False;1;Distortion_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;299;-2205.119,-994.6426;Inherit;False;Property;_Distortion_Tex_Power;扭曲强度;52;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-2036.803,-726.1957;Inherit;False;Property;_Distortion_Switch;是否启用扭曲;51;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-1595.006,-1038.089;Inherit;False;ONE;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;2;-1373.281,-753.3946;Inherit;False;Property;_Main_Tex_Color;主帖图颜色;6;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1167.583,-557.4451;Inherit;True;Property;_Main_Tex;主帖图;5;1;[Header];Create;False;1;Main_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;412;-1521.403,-214.0435;Inherit;False;Property;_Main_Tex_ClampSwitch;主帖图重铺模式;9;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-1039,-176;Inherit;False;Property;_Main_Tex_A_R;主帖图通道;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-1991.336,-426.3635;Inherit;False;Property;_Main_Tex_Rotator;主帖图旋转;10;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-2524.07,74.15598;Inherit;False;Property;_Fresnel_Bokeh;菲涅尔模式;57;1;[Enum];Create;False;0;2;Fresnel;0;Bokeh;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;373;-2382.336,172.6049;Inherit;False;Property;_Fresnel_Color;菲涅尔颜色;55;2;[HDR];[Header];Create;False;1;Fresnel;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;318;-1945.801,-271.8814;Inherit;False;Constant;_Float6;Float 6;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;-4016.331,619.3238;Inherit;False;Property;_Dissolve_Tex_U_speed;溶解U方向速率;48;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-4024.446,708.5041;Inherit;False;Property;_Dissolve_Tex_V_speed;溶解V方向速率;49;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;428;-4013.727,890.405;Inherit;False;Constant;_Float13;Float 13;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;426;-4012.473,816.7159;Inherit;False;Property;_Dissolve_Tex_Rotator;溶解贴图旋转;45;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-3753.508,745.8126;Inherit;False;Property;_Dissolve_Tex_power;溶解进度;47;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;-3469.378,890.2977;Inherit;False;Property;_Dissolve_Tex_Custom_X;是否Custom1x控制溶解;44;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-3214.908,863.3678;Inherit;False;Constant;_Float7;Float 7;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;349;-3046.223,668.5835;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;-3236.652,652.801;Inherit;False;Property;_Dissolve_Tex_A_R;溶解贴图通道;43;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-2817.052,752.7044;Inherit;False;Property;_Dissolve_Tex_smooth;溶解平滑度;46;0;Create;False;0;0;0;False;0;False;0.5;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2457.605,884.2485;Inherit;False;Property;_SoftParticle;软粒子;4;0;Create;False;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;371;-2170.855,542.6441;Inherit;False;Property;_Dissolve_Switch;溶解开关;42;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-3580.795,1020.401;Inherit;False;Property;_WPO_tex_power;顶点偏移强度;63;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;395;-4008.534,1029.139;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;394;-3676.302,1136.529;Inherit;False;Property;_WPO_CustomSwitch_Y;顶点偏移模式;62;1;[Enum];Create;False;0;2;Normal;0;Custom1y;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-4019.97,1337.638;Inherit;False;Property;_WPO_Tex_U_speed;顶点偏移U方向速率;65;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-4020.07,1417.905;Inherit;False;Property;_WPO_Tex_V_speed;顶点偏移V方向速率;66;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;397;-3516.793,1298.851;Inherit;True;Property;_WPO_Tex;顶点偏移贴图;60;1;[Header];Create;False;1;Wpo_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;402;-3235.426,1315.685;Inherit;False;Property;_WPO_Tex_Direction;顶点偏移轴向;64;0;Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;408;-2945.351,1125.468;Inherit;False;Property;_WPO_Switch;顶点偏移开关;61;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;431;-975.3214,1242.979;Inherit;False;Property;_Remap_Tex_A_R;颜色叠加贴图;15;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;442;-1410.709,1379.211;Inherit;False;Property;_Remap_Tex_Desaturate;颜色贴图去色;16;0;Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-1828.661,1391.364;Inherit;False;Property;_Remap_Tex_ClampSwitch;颜色叠加重铺模式;17;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-2258.491,1210.566;Inherit;False;Property;_Remap_Tex_Rotator;颜色叠加旋转;18;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2645.778,1164.462;Inherit;False;Property;_Remap_Tex_U_speed;颜色叠加U方向速率;19;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-2639.893,1238.641;Inherit;False;Property;_Remap_Tex_V_speed;颜色叠加V方向速率;20;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;449;-2635.152,1413.84;Inherit;False;Property;_Remap_Tex_Followl_Main_Tex;跟随主贴图一次性UV移动;14;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;353;-3368.6,468.483;Inherit;True;Property;_Dissolve_Tex;溶解贴图;41;1;[Header];Create;False;1;Dissolve_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;406;-1276.948,1031.885;Inherit;True;Property;_Remap_Tex;颜色叠加贴图;13;1;[Header];Create;False;1;Remap_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;323;-3767.229,-251.1057;Inherit;False;Constant;_Float11;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;332;-3564.128,-453.428;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;331;-3774.49,-595.0944;Inherit;False;0;327;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;334;-3491.824,-590.861;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;335;-3315.981,-590.5401;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;325;-3147.291,-490.8478;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;413;-2961.542,-581.2285;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;453;-2394.517,-570.3816;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-2992.672,-726.7501;Inherit;False;Property;_Distortion_Tex_V_speed;扭曲V方向速率;54;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-2664.242,-405.5811;Inherit;False;Property;_Mask_Tex_A_R;遮罩贴图通道;23;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;327;-2778.896,-603.2476;Inherit;True;Property;_Mask_Tex;遮罩贴图;21;1;[Header];Create;False;1;Mask_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;330;-3770.411,-470.8815;Inherit;False;Property;_Mask_Tex_U_speed;遮罩贴图U方向速率;25;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-3771.76,-395.7793;Inherit;False;Property;_Mask_Tex_V_speed;遮罩贴图V方向速率;26;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-3765.975,-326.7947;Inherit;False;Property;_Mask_Tex_Rotator;遮罩贴图旋转;24;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;414;-3240.689,-419.8793;Inherit;False;Property;_Mask_Tex_ClampSwitch;遮罩贴图重铺模式;22;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-2183.766,-576.2316;Inherit;False;two;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;333;-3500.369,-321.2846;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-3292.821,-265.1875;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;488;-1455.79,178.3044;Inherit;False;1617.908;474.2787;MASK2;17;503;496;497;498;502;494;495;493;490;492;505;504;489;501;500;499;491;第二套遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-650.8891,-137.7475;Inherit;False;219;soft;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-652.8101,-214.1535;Inherit;False;217;Three;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;506;-652.6088,19.01023;Inherit;False;503;mask2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-650.0829,-57.77696;Inherit;False;215;two;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-651.8455,-290.1957;Inherit;False;258;Gam;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;491;-1435.102,220.8616;Inherit;False;0;498;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;507;-1534.693,-1664.691;Inherit;False;2281.229;512.0997;liuguang;23;513;510;514;515;518;524;532;533;528;529;530;525;526;537;522;550;523;521;512;508;509;517;516;流光;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-479.6807,-613.9042;Inherit;False;222;four;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;372;-2099.258,-82.22703;Inherit;False;Property;_Fresnel_Switch;菲涅尔开关;56;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;521;-875.6127,-1625.787;Inherit;True;Property;_LiuguangTex;流光纹理;33;1;[Header];Create;False;1;Liuguang_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;523;-551.0053,-1477.301;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;550;-387.2307,-1597.197;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;522;-743.5593,-1435.02;Inherit;False;Property;_LiuguangTex_P;流光纹理通道;35;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;537;-551.7165,-1596.972;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;526;-583.4078,-1355.331;Inherit;False;Property;_LGColor;流光颜色;37;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-326.4786,-1376.71;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;530;-245.4785,-1597.713;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;528;91.52139,-1596.713;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;533;187.33,-1374.791;Inherit;False;Constant;_Float0;Float 0;67;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;532;335.9969,-1593.486;Inherit;False;Property;_LGTexSwitch;流光开关;34;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;524;550.511,-1592.902;Inherit;False;liuguang;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;516;-1511.926,-1478.921;Inherit;False;Property;_LGTex_U_Speed;流光U方向速率;39;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;517;-1512.275,-1402.818;Inherit;False;Property;_LGTex_V_Speed;流光V方向速率;40;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;509;-1341.643,-1456.467;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;508;-1509.744,-1248.145;Inherit;False;Constant;_Float16;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;512;-1240.884,-1322.324;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;-1512.49,-1326.834;Inherit;False;Property;_LG_Tex_Rotator;流光纹理旋转;36;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;515;-1515.005,-1602.134;Inherit;False;0;521;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;514;-1228.339,-1596.901;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;513;-1059.336,-1270.227;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;510;-1054.496,-1596.58;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;499;-1436.023,343.0743;Inherit;False;Property;_Mask_Tex_U_speed2;遮罩2U方向速率;31;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;500;-1436.372,418.1765;Inherit;False;Property;_Mask_Tex_V_speed2;遮罩2V方向速率;32;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;501;-1437.587,494.1611;Inherit;False;Property;_Mask_Tex_Rotator2;遮罩贴图2旋转;30;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;489;-1438.841,569.8499;Inherit;False;Constant;_Float15;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;504;-1169.981,499.6712;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;505;-957.434,550.7681;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;492;-1155.436,225.095;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;490;-1259.74,366.5278;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;493;-978.5941,225.416;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;495;-634.1548,225.5275;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;494;-784.904,278.108;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;502;-842.3019,349.0765;Inherit;False;Property;_Mask_Tex_ClampSwitch2;遮罩贴图2重铺模式;28;1;[Enum];Create;False;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;498;-488.7085,224.2085;Inherit;True;Property;_Mask_Tex2;遮罩贴图2;27;1;[Header];Create;False;1;Mask_Tex2;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;497;-487.655,414.9746;Inherit;False;Property;_Mask_Tex_A_R2;遮罩贴图2通道;29;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;496;-176.0298,301.0744;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;503;-28.57886,296.1243;Inherit;False;mask2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;338;-3799.799,-102.4572;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;337;-3802.412,54.3049;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;343;-3631.246,-96.2643;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;345;-3516.218,-97.0165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;350;-3403.849,-97.0945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;356;-3276.303,-97.1749;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-3616.201,3.17844;Inherit;False;Constant;_RimMin;RimMin;46;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-3615.194,83.36541;Inherit;False;Constant;_RinMax;RinMax;47;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;438;-3124.372,-96.5467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;359;-2957.178,-2.13774;Inherit;False;1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;362;-2957.638,-96.73124;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-3129.516,25.77431;Inherit;False;Property;_Fresnel_power;菲涅尔强度;59;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;-3132.441,105.9818;Inherit;False;Property;_Fresnel_scale;菲涅尔亮度;58;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;436;-2688.125,-12.62701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-2817.291,-96.52399;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;437;-2554.976,-64.97628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;370;-2416.374,-38.74646;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;529;-130.4782,-1372.711;Inherit;False;Property;_UseLGTexColor;是否禁用纹理自身颜色;38;1;[Toggle];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-294.9444,-493.0741;Inherit;False;117;Vertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-296.3586,-659.9378;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;534;-179.8843,-755.0404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;-347.4138,-759.4771;Inherit;False;524;liuguang;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;551;320.4237,-646.0598;Float;False;True;-1;2;Soung_ShaderGUI_Built_in;100;5;A201-Shader/Built-in/特效全功能通用;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_Dst;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_Zwrite;True;3;True;_ZTestMode;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ComponentMaskNode;553;126.3957,-651.3615;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;552;-24.40425,-646.1611;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-131.6158,-313.1425;Inherit;False;Property;_Dst;混合模式;0;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-130.131,-234.1108;Inherit;False;Property;_CullMode;剔除模式;1;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;475;-128.6526,-74.94788;Inherit;False;Property;_Zwrite;深度写入;3;1;[Enum];Create;False;0;2;ON;1;OFF;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-129.3508,-155.2818;Inherit;False;Property;_ZTestMode;深度测试;2;1;[Enum];Create;False;0;2;Less or Equal;4;Always;8;0;True;0;False;4;4;0;0;0;1;FLOAT;0
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
WireConnection;430;0;341;0
WireConnection;430;2;463;0
WireConnection;396;0;389;0
WireConnection;396;1;385;0
WireConnection;459;0;448;0
WireConnection;420;0;419;0
WireConnection;420;1;418;0
WireConnection;342;0;340;0
WireConnection;342;1;339;0
WireConnection;346;0;430;0
WireConnection;346;2;342;0
WireConnection;300;0;288;1
WireConnection;296;0;292;1
WireConnection;462;0;396;0
WireConnection;460;0;459;0
WireConnection;421;0;391;0
WireConnection;421;2;420;0
WireConnection;305;0;443;0
WireConnection;305;1;297;0
WireConnection;307;0;299;0
WireConnection;307;1;296;0
WireConnection;302;0;297;0
WireConnection;302;1;301;0
WireConnection;461;0;462;0
WireConnection;450;0;421;0
WireConnection;450;1;460;0
WireConnection;308;0;305;0
WireConnection;308;1;302;0
WireConnection;308;2;306;0
WireConnection;351;0;348;0
WireConnection;351;1;347;0
WireConnection;351;2;344;0
WireConnection;309;0;303;0
WireConnection;309;1;307;0
WireConnection;309;2;304;0
WireConnection;399;0;450;0
WireConnection;399;2;461;0
WireConnection;417;0;353;1
WireConnection;417;1;353;4
WireConnection;417;2;416;0
WireConnection;310;0;308;0
WireConnection;310;1;309;0
WireConnection;357;0;351;0
WireConnection;357;1;352;0
WireConnection;355;0;417;0
WireConnection;355;1;349;0
WireConnection;434;0;399;0
WireConnection;386;0;383;0
WireConnection;386;1;382;0
WireConnection;360;0;355;0
WireConnection;360;1;357;0
WireConnection;317;0;316;0
WireConnection;433;0;399;0
WireConnection;433;1;434;0
WireConnection;433;2;435;0
WireConnection;476;0;309;0
WireConnection;476;1;433;0
WireConnection;320;0;317;0
WireConnection;320;1;318;0
WireConnection;366;0;360;0
WireConnection;390;0;387;0
WireConnection;390;2;386;0
WireConnection;364;0;361;0
WireConnection;368;0;366;0
WireConnection;368;1;364;0
WireConnection;368;2;361;0
WireConnection;398;0;392;0
WireConnection;398;1;395;2
WireConnection;398;2;394;0
WireConnection;321;0;319;0
WireConnection;321;2;320;0
WireConnection;314;0;321;0
WireConnection;393;0;388;0
WireConnection;441;0;406;0
WireConnection;441;1;442;0
WireConnection;404;0;398;0
WireConnection;404;1;401;0
WireConnection;404;2;397;0
WireConnection;404;3;402;0
WireConnection;411;0;321;0
WireConnection;411;1;314;0
WireConnection;411;2;412;0
WireConnection;374;0;372;0
WireConnection;374;1;373;4
WireConnection;374;2;371;0
WireConnection;400;0;393;0
WireConnection;375;0;372;0
WireConnection;375;1;371;0
WireConnection;375;2;373;0
WireConnection;425;0;441;0
WireConnection;222;0;375;0
WireConnection;456;0;408;0
WireConnection;219;0;400;0
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
WireConnection;137;7;506;0
WireConnection;298;0;293;0
WireConnection;298;1;289;0
WireConnection;443;0;298;0
WireConnection;292;1;286;0
WireConnection;214;0;310;0
WireConnection;1;1;411;0
WireConnection;371;1;367;0
WireConnection;371;0;368;0
WireConnection;397;1;390;0
WireConnection;408;1;405;0
WireConnection;408;0;404;0
WireConnection;353;1;346;0
WireConnection;406;1;476;0
WireConnection;332;0;330;0
WireConnection;332;1;329;0
WireConnection;334;0;331;0
WireConnection;334;2;332;0
WireConnection;335;0;334;0
WireConnection;335;2;324;0
WireConnection;325;0;335;0
WireConnection;413;0;335;0
WireConnection;413;1;325;0
WireConnection;413;2;414;0
WireConnection;453;0;327;1
WireConnection;453;1;327;4
WireConnection;453;2;452;0
WireConnection;327;1;413;0
WireConnection;215;0;453;0
WireConnection;333;0;322;0
WireConnection;324;0;333;0
WireConnection;324;1;323;0
WireConnection;372;1;369;0
WireConnection;372;0;370;0
WireConnection;521;1;510;0
WireConnection;523;0;521;1
WireConnection;523;1;521;4
WireConnection;523;2;522;0
WireConnection;550;0;537;0
WireConnection;550;1;523;0
WireConnection;537;0;521;1
WireConnection;537;1;521;2
WireConnection;537;2;521;3
WireConnection;525;0;523;0
WireConnection;525;1;526;0
WireConnection;530;0;550;0
WireConnection;530;1;526;0
WireConnection;528;0;530;0
WireConnection;528;1;525;0
WireConnection;528;2;529;0
WireConnection;532;1;533;0
WireConnection;532;0;528;0
WireConnection;524;0;532;0
WireConnection;509;0;516;0
WireConnection;509;1;517;0
WireConnection;512;0;518;0
WireConnection;514;0;515;0
WireConnection;514;2;509;0
WireConnection;513;0;512;0
WireConnection;513;1;508;0
WireConnection;510;0;514;0
WireConnection;510;2;513;0
WireConnection;504;0;501;0
WireConnection;505;0;504;0
WireConnection;505;1;489;0
WireConnection;492;0;491;0
WireConnection;492;2;490;0
WireConnection;490;0;499;0
WireConnection;490;1;500;0
WireConnection;493;0;492;0
WireConnection;493;2;505;0
WireConnection;495;0;493;0
WireConnection;495;1;494;0
WireConnection;495;2;502;0
WireConnection;494;0;493;0
WireConnection;498;1;495;0
WireConnection;496;0;498;1
WireConnection;496;1;498;4
WireConnection;496;2;497;0
WireConnection;503;0;496;0
WireConnection;343;0;338;0
WireConnection;343;1;337;0
WireConnection;345;0;343;0
WireConnection;350;0;345;0
WireConnection;356;0;350;0
WireConnection;438;0;356;0
WireConnection;438;1;439;0
WireConnection;438;2;440;0
WireConnection;359;0;358;0
WireConnection;362;0;438;0
WireConnection;362;1;354;0
WireConnection;436;0;363;0
WireConnection;363;0;362;0
WireConnection;363;1;359;0
WireConnection;437;0;363;0
WireConnection;370;0;437;0
WireConnection;370;1;436;0
WireConnection;370;2;365;0
WireConnection;4;0;3;0
WireConnection;4;1;474;0
WireConnection;4;2;223;0
WireConnection;4;3;257;0
WireConnection;534;0;531;0
WireConnection;534;1;4;0
WireConnection;551;0;553;0
WireConnection;551;1;118;0
WireConnection;553;0;552;0
WireConnection;552;0;534;0
WireConnection;552;3;137;0
ASEEND*/
//CHKSM=DFC5E60D8FB42F1E7E8E4B029F3D558AAC70FD68