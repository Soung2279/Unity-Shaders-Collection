// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/后期效果/全面屏幕后处理"
{
	Properties
	{
		[KeywordEnum(Ref,Radialblur,BlacknWhite,ScreenEffect,Sesan)] _Keyword1("功能", Float) = 0
		[Header(______________________________________________________________________)][Header(Ref)]_NoiseTex("热扭曲贴图（法线）", 2D) = "white" {}
		_NoiseNormalIntensity("扭曲强度", Float) = 1
		_NoiseMask("热扭曲遮罩", 2D) = "white" {}
		_RefnoiseU("热扭曲U速度", Float) = 0
		_RefnoiseV("热扭曲V速度", Float) = 0
		[Enum(R,0,A,1)]_NoiseMaskP("热扭曲遮罩通道", Float) = 0
		[Header(______________________________________________________________________)][Header(RadialBlur)]_ScreenCenter("径向模糊中心", Vector) = (0.5,0.5,0,0)
		[KeywordEnum(4Blur,8Blur,12Blur)] _BlurDivission("径向模糊细分", Float) = 0
		_RadialBlur("径向模糊强度", Float) = 1
		[HDR][Header(______________________________________________________________________)][Header(BlacknWhite)]_Color1("颜色1", Color) = (0,0,0,1)
		[HDR]_Color0("颜色2", Color) = (1,1,1,1)
		[Toggle(_KEYWORD0_ON)] _Keyword0("黑白切换", Float) = 0
		_Float8("黑白范围", Range( 0 , 1)) = 0
		_Float9("黑白过渡", Range( 0 , 1)) = 0
		[NoScaleOffset]_TextureSample01("放射贴图01", 2D) = "white" {}
		_BNWPolarFlow1("放射1极坐标重铺与流动", Vector) = (1,1,0.5,0.5)
		[NoScaleOffset]_TextureSample02("放射贴图02", 2D) = "black" {}
		_BNWPolarFlow2("放射2极坐标重铺与流动", Vector) = (1,1,0.5,0.5)
		_PolarCenter("放射极坐标中心", Vector) = (0.5,0.5,0,0)
		_Float10("放射强度", Range( 0 , 1)) = 0
		_Float11("X轴震动频率", Float) = 60
		_Float14("Y轴震动频率", Float) = 60
		_Float12("X轴震动强度", Float) = 0
		_Float13("Y轴震动强度", Float) = 0
		_Float15("整体震动强度", Float) = 1
		[Header(______________________________________________________________________)][Header(ScreenEffect)][NoScaleOffset]_ScreenTex("屏幕贴图", 2D) = "white" {}
		[HDR]_ScreenTexColor("屏幕颜色", Color) = (1,1,1,1)
		_ScreenTexUV("屏幕重铺与偏移", Vector) = (1,1,0,0)
		[Enum(Screen,0,Polar,1)]_ScreenTexPolarOnOff("屏幕UV模式", Float) = 0
		_ScreenTexPolarU("屏幕极坐标缩放", Float) = 1
		_ScreenTexPolarV("屏幕极坐标长度", Float) = 1
		_ScreenTexUP("屏幕U方向流动", Float) = 0
		_ScreenTexVP("屏幕V方向流动", Float) = 0
		[Enum(Tex,0,Program,1)]_ScreenMaskMode("屏幕遮罩模式", Float) = 0
		[NoScaleOffset]_ScreenTexMask("屏幕遮罩贴图", 2D) = "white" {}
		[Toggle][Enum(R,0,A,1)]_ScreenMaskP("屏幕遮罩通道", Float) = 0
		_DistrScreen("屏幕扰动贴图", 2D) = "black" {}
		_NoiseIntScreen("屏幕扰动强度", Range( 0 , 1)) = 0.06342169
		_NoiseU("屏幕扰动U速率", Float) = 1
		_NoiseV("屏幕扰动V速率", Float) = 1
		[Header(______________________________________________________________________)][Header(Sesan)]_rgb("色散强度", Float) = 0
		[Header(______________________________________________________________________)][Header(GlobalMask)]_PrgMaskOffest("程序遮罩大小", Range( 0 , 1)) = 0.35
		_PrgMaskM("程序遮罩过渡", Float) = 1
		[Toggle]_pgmask_sw("程序遮罩反向", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		GrabPass{ }

		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"
			#pragma multi_compile_local _KEYWORD1_REF _KEYWORD1_RADIALBLUR _KEYWORD1_BLACKNWHITE _KEYWORD1_SCREENEFFECT _KEYWORD1_SESAN
			#pragma shader_feature_local _BLURDIVISSION_4BLUR _BLURDIVISSION_8BLUR _BLURDIVISSION_12BLUR
			#pragma shader_feature_local _KEYWORD0_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform sampler2D _NoiseTex;
			uniform float _RefnoiseU;
			uniform float _RefnoiseV;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseNormalIntensity;
			uniform float2 _ScreenCenter;
			uniform float _RadialBlur;
			uniform float4 _Color1;
			uniform float4 _Color0;
			uniform float _Float8;
			uniform float _Float9;
			uniform float _Float11;
			uniform float _Float12;
			uniform float _Float15;
			uniform float _Float14;
			uniform float _Float13;
			uniform sampler2D _TextureSample01;
			uniform float4 _BNWPolarFlow1;
			uniform float2 _PolarCenter;
			uniform sampler2D _TextureSample02;
			uniform float4 _BNWPolarFlow2;
			uniform float _PrgMaskOffest;
			uniform float _PrgMaskM;
			uniform float _pgmask_sw;
			uniform float _Float10;
			uniform sampler2D _ScreenTex;
			uniform float _ScreenTexUP;
			uniform float _ScreenTexVP;
			uniform float _ScreenTexPolarU;
			uniform float _ScreenTexPolarV;
			uniform float _ScreenTexPolarOnOff;
			uniform float4 _ScreenTexUV;
			uniform sampler2D _DistrScreen;
			uniform float _NoiseU;
			uniform float _NoiseV;
			uniform float4 _DistrScreen_ST;
			uniform float _NoiseIntScreen;
			uniform float4 _ScreenTexColor;
			uniform sampler2D _ScreenTexMask;
			uniform float _ScreenMaskP;
			uniform float _ScreenMaskMode;
			uniform float _rgb;
			uniform sampler2D _NoiseMask;
			uniform float4 _NoiseMask_ST;
			uniform float _NoiseMaskP;
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
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
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
				float4 screenPos = i.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult347 = (float2(_RefnoiseU , _RefnoiseV));
				float2 uv_NoiseTex = i.ase_texcoord2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner10 = ( 1.0 * _Time.y * appendResult347 + uv_NoiseTex);
				float4 screenColor47 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + UnpackScaleNormal( tex2D( _NoiseTex, panner10 ), ( i.ase_color.a * _NoiseNormalIntensity ) ).r ).xy);
				float4 RefColor252 = screenColor47;
				float4 temp_output_55_0 = ( ( ase_grabScreenPosNorm - float4( _ScreenCenter, 0.0 , 0.0 ) ) * 0.01 * _RadialBlur );
				float4 temp_output_78_0 = ( ase_grabScreenPosNorm - temp_output_55_0 );
				float4 screenColor50 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_78_0.xy);
				float4 temp_output_77_0 = ( temp_output_78_0 - temp_output_55_0 );
				float4 screenColor76 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_77_0.xy);
				float4 temp_output_79_0 = ( temp_output_77_0 - temp_output_55_0 );
				float4 screenColor80 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_79_0.xy);
				float4 temp_output_96_0 = ( temp_output_79_0 - temp_output_55_0 );
				float4 screenColor81 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_96_0.xy);
				float4 temp_output_110_0 = ( screenColor50 + screenColor76 + screenColor80 + screenColor81 );
				float4 myBlur98 = temp_output_55_0;
				float4 temp_output_97_0 = ( temp_output_96_0 - myBlur98 );
				float4 screenColor82 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_97_0.xy);
				float4 temp_output_100_0 = ( temp_output_97_0 - myBlur98 );
				float4 screenColor83 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_100_0.xy);
				float4 temp_output_101_0 = ( temp_output_100_0 - myBlur98 );
				float4 screenColor84 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_101_0.xy);
				float4 temp_output_102_0 = ( temp_output_101_0 - myBlur98 );
				float4 screenColor85 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_102_0.xy);
				float4 temp_output_112_0 = ( temp_output_110_0 + ( screenColor82 + screenColor83 + screenColor84 + screenColor85 ) );
				float4 temp_output_104_0 = ( temp_output_102_0 - myBlur98 );
				float4 screenColor86 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_104_0.xy);
				float4 temp_output_105_0 = ( temp_output_104_0 - myBlur98 );
				float4 screenColor87 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_105_0.xy);
				float4 temp_output_106_0 = ( temp_output_105_0 - myBlur98 );
				float4 screenColor88 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_106_0.xy);
				float4 screenColor90 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( temp_output_106_0 - myBlur98 ).xy);
				#if defined(_BLURDIVISSION_4BLUR)
				float4 staticSwitch109 = temp_output_110_0;
				#elif defined(_BLURDIVISSION_8BLUR)
				float4 staticSwitch109 = temp_output_112_0;
				#elif defined(_BLURDIVISSION_12BLUR)
				float4 staticSwitch109 = ( temp_output_112_0 + ( screenColor86 + screenColor87 + screenColor88 + screenColor90 ) );
				#else
				float4 staticSwitch109 = temp_output_110_0;
				#endif
				#if defined(_BLURDIVISSION_4BLUR)
				float staticSwitch116 = 4.0;
				#elif defined(_BLURDIVISSION_8BLUR)
				float staticSwitch116 = 8.0;
				#elif defined(_BLURDIVISSION_12BLUR)
				float staticSwitch116 = 12.0;
				#else
				float staticSwitch116 = 4.0;
				#endif
				float4 blur264 = ( staticSwitch109 / staticSwitch116 );
				float mulTime172 = _Time.y * _Float11;
				float mulTime178 = _Time.y * _Float14;
				float2 appendResult183 = (float2(( sin( mulTime172 ) * _Float12 * _Float15 ) , ( sin( mulTime178 ) * _Float13 * _Float15 )));
				float2 zhendongg271 = appendResult183;
				float4 screenColor274 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( zhendongg271, 0.0 , 0.0 ) ).xy);
				float3 desaturateInitialColor147 = screenColor274.rgb;
				float desaturateDot147 = dot( desaturateInitialColor147, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar147 = lerp( desaturateInitialColor147, desaturateDot147.xxx, 1.0 );
				float2 appendResult349 = (float2(_BNWPolarFlow1.z , _BNWPolarFlow1.w));
				float2 CenteredUV15_g6 = ( ase_grabScreenPosNorm.xy - _PolarCenter );
				float2 break17_g6 = CenteredUV15_g6;
				float2 appendResult23_g6 = (float2(( length( CenteredUV15_g6 ) * _BNWPolarFlow1.x * 2.0 ) , ( atan2( break17_g6.x , break17_g6.y ) * ( 1.0 / 6.28318548202515 ) * _BNWPolarFlow1.y )));
				float2 panner164 = ( 1.0 * _Time.y * appendResult349 + appendResult23_g6);
				float3 desaturateInitialColor167 = tex2D( _TextureSample01, panner164 ).rgb;
				float desaturateDot167 = dot( desaturateInitialColor167, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar167 = lerp( desaturateInitialColor167, desaturateDot167.xxx, 1.0 );
				float2 appendResult351 = (float2(_BNWPolarFlow2.z , _BNWPolarFlow2.w));
				float2 CenteredUV15_g5 = ( ase_grabScreenPosNorm.xy - _PolarCenter );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * _BNWPolarFlow2.x * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / 6.28318548202515 ) * _BNWPolarFlow2.y )));
				float2 panner280 = ( 1.0 * _Time.y * appendResult351 + appendResult23_g5);
				float3 desaturateInitialColor283 = tex2D( _TextureSample02, panner280 ).rgb;
				float desaturateDot283 = dot( desaturateInitialColor283, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar283 = lerp( desaturateInitialColor283, desaturateDot283.xxx, 1.0 );
				float2 texCoord353 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_355_0 = ( ( texCoord353 - float2( 0.5,0.5 ) ) * 2.0 );
				float2 temp_output_357_0 = ( temp_output_355_0 * temp_output_355_0 );
				float temp_output_366_0 = pow( saturate( ( ( (temp_output_357_0).x + (temp_output_357_0).y ) - (-1.0 + (_PrgMaskOffest - 0.0) * (2.0 - -1.0) / (1.0 - 0.0)) ) ) , _PrgMaskM );
				float lerpResult376 = lerp( temp_output_366_0 , ( 1.0 - temp_output_366_0 ) , _pgmask_sw);
				float chengxuMASK375 = lerpResult376;
				float lerpResult166 = lerp( (desaturateVar147).x , ( ( (desaturateVar167).x + (desaturateVar283).x ) * chengxuMASK375 ) , _Float10);
				float smoothstepResult149 = smoothstep( _Float8 , ( _Float8 + _Float9 ) , lerpResult166);
				#ifdef _KEYWORD0_ON
				float staticSwitch157 = ( 1.0 - smoothstepResult149 );
				#else
				float staticSwitch157 = smoothstepResult149;
				#endif
				float4 lerpResult153 = lerp( _Color1 , _Color0 , saturate( staticSwitch157 ));
				float4 BlacknWhiteColor260 = lerpResult153;
				float2 appendResult331 = (float2(_ScreenTexUP , _ScreenTexVP));
				float2 appendResult201 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 CenteredUV15_g7 = ( appendResult201 - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * _ScreenTexPolarU * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / 6.28318548202515 ) * _ScreenTexPolarV )));
				float2 lerpResult214 = lerp( appendResult201 , appendResult23_g7 , _ScreenTexPolarOnOff);
				float2 appendResult221 = (float2(_ScreenTexUV.x , _ScreenTexUV.y));
				float2 appendResult222 = (float2(_ScreenTexUV.z , _ScreenTexUV.w));
				float2 appendResult337 = (float2(_NoiseU , _NoiseV));
				float2 uv_DistrScreen = i.ase_texcoord2.xy * _DistrScreen_ST.xy + _DistrScreen_ST.zw;
				float2 panner338 = ( 1.0 * _Time.y * appendResult337 + uv_DistrScreen);
				float NoiseT340 = tex2D( _DistrScreen, panner338 ).r;
				float2 temp_cast_63 = (NoiseT340).xx;
				float2 lerpResult343 = lerp( (lerpResult214*appendResult221 + appendResult222) , temp_cast_63 , _NoiseIntScreen);
				float2 panner198 = ( 1.0 * _Time.y * appendResult331 + lerpResult343);
				float4 tex2DNode203 = tex2D( _ScreenTexMask, appendResult201 );
				float lerpResult307 = lerp( tex2DNode203.r , tex2DNode203.a , _ScreenMaskP);
				float lerpResult368 = lerp( lerpResult307 , chengxuMASK375 , _ScreenMaskMode);
				float4 ScreenEffectColor245 = ( ( tex2D( _ScreenTex, panner198 ) * _ScreenTexColor ) * lerpResult368 );
				float4 myUV129 = temp_output_78_0;
				float4 screenColor125 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,myUV129.xy);
				float4 temp_output_139_0 = ( myBlur98 * _rgb );
				float4 temp_output_138_0 = ( myUV129 - temp_output_139_0 );
				float4 screenColor131 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_138_0.xy);
				float4 screenColor132 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( temp_output_138_0 - temp_output_139_0 ).xy);
				float4 appendResult135 = (float4(screenColor125.r , screenColor131.g , screenColor132.b , 1.0));
				float4 sesan256 = appendResult135;
				#if defined(_KEYWORD1_REF)
				float4 staticSwitch239 = RefColor252;
				#elif defined(_KEYWORD1_RADIALBLUR)
				float4 staticSwitch239 = blur264;
				#elif defined(_KEYWORD1_BLACKNWHITE)
				float4 staticSwitch239 = BlacknWhiteColor260;
				#elif defined(_KEYWORD1_SCREENEFFECT)
				float4 staticSwitch239 = ScreenEffectColor245;
				#elif defined(_KEYWORD1_SESAN)
				float4 staticSwitch239 = sesan256;
				#else
				float4 staticSwitch239 = RefColor252;
				#endif
				float2 uv_NoiseMask = i.ase_texcoord2.xy * _NoiseMask_ST.xy + _NoiseMask_ST.zw;
				float4 tex2DNode18 = tex2D( _NoiseMask, uv_NoiseMask );
				float lerpResult323 = lerp( tex2DNode18.r , tex2DNode18.a , _NoiseMaskP);
				float RefAlpha387 = lerpResult323;
				float BlacknWhiteAlpha396 = ( _Color0.a * _Color1.a );
				float ScreenEffectAlpha399 = ( _ScreenTexColor.a * lerpResult368 );
				#if defined(_KEYWORD1_REF)
				float staticSwitch392 = RefAlpha387;
				#elif defined(_KEYWORD1_RADIALBLUR)
				float staticSwitch392 = 1.0;
				#elif defined(_KEYWORD1_BLACKNWHITE)
				float staticSwitch392 = BlacknWhiteAlpha396;
				#elif defined(_KEYWORD1_SCREENEFFECT)
				float staticSwitch392 = ScreenEffectAlpha399;
				#elif defined(_KEYWORD1_SESAN)
				float staticSwitch392 = 1.0;
				#else
				float staticSwitch392 = RefAlpha387;
				#endif
				float4 appendResult391 = (float4((staticSwitch239).rgb , staticSwitch392));
				
				
				finalColor = appendResult391;
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
Node;AmplifyShaderEditor.CommentaryNode;143;-280.4662,-1039.805;Inherit;False;1076.872;581.5052;色散;11;256;135;142;132;138;130;139;141;131;125;140;色散;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;202;-3332.111,-2740.805;Inherit;False;2236.765;677.9592;极坐标流动;31;374;245;332;368;369;306;307;203;192;190;189;341;219;344;343;198;331;330;329;222;221;220;213;328;327;196;214;201;200;398;399;屏幕效果;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;367;-3292.274,-3245.623;Inherit;False;2160.665;446.373;程序遮罩;18;377;364;363;375;378;376;366;353;362;360;361;365;354;359;358;357;356;355;程序遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;123;-3317.977,-1040.496;Inherit;False;3013.402;2142.849;径向模糊;46;264;115;116;119;118;117;109;113;103;114;107;90;106;88;105;87;86;104;99;102;85;84;101;111;83;100;82;97;98;81;96;76;80;79;50;77;129;55;58;56;78;51;49;144;112;110;径向模糊;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;184;-289.786,-374.4092;Inherit;False;1109.013;338.1116;震屏;13;271;183;180;181;188;176;177;174;179;178;182;172;175;震屏;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-3320.994,-2024.637;Inherit;False;3312.418;932.1506;黑白闪;39;275;385;260;156;155;153;157;159;158;149;152;151;150;170;166;289;288;169;282;283;167;281;280;164;350;351;349;348;279;161;160;273;148;147;274;272;146;395;396;黑白放射;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1056.43,-3024.441;Inherit;False;1368.776;971.583;扭曲屏幕;18;252;387;9;324;15;14;13;347;11;10;346;345;24;18;323;47;8;5;热扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1548.942,-708.0057;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1278.024,-275.2887;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;5;-786.0748,-2973.209;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-253.0212,-2967.038;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;47;-52.67822,-2972.032;Inherit;False;Global;_GrabScreen1;Grab Screen 1;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;323;-494.5583,-2244.367;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-799.1743,-2321.528;Inherit;True;Property;_NoiseMask;热扭曲遮罩;4;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1009.494,-2296.609;Inherit;False;0;18;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;200;-3307.047,-2687.111;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;201;-3089.842,-2658.489;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;214;-2685.697,-2660.168;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;196;-2937.836,-2558.882;Inherit;False;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;327;-3259.829,-2516.831;Inherit;False;Property;_ScreenTexPolarU;屏幕极坐标缩放;31;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-3260.829,-2440.831;Inherit;False;Property;_ScreenTexPolarV;屏幕极坐标长度;32;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2941.823,-2413.627;Inherit;False;Property;_ScreenTexPolarOnOff;屏幕UV模式;30;1;[Enum];Create;False;0;2;Screen;0;Polar;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;220;-2685.921,-2539.288;Inherit;False;Property;_ScreenTexUV;屏幕重铺与偏移;29;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;221;-2507.483,-2545.288;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;-2508.483,-2442.288;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-2349.828,-2497.831;Inherit;False;Property;_ScreenTexUP;屏幕U方向流动;33;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-2348.828,-2417.831;Inherit;False;Property;_ScreenTexVP;屏幕V方向流动;34;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;331;-2185.829,-2470.831;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;333;24.91677,-1442.793;Inherit;False;989;345;UV流动;7;340;339;338;337;336;335;334;扰动贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;337;208.4056,-1244.555;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;338;359.0415,-1369.039;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;198;-1881.592,-2652.429;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;343;-2043.818,-2655.527;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;219;-2330.483,-2688.288;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-2230.531,-2571.06;Inherit;False;340;NoiseT;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;190;-1628.393,-2490.511;Inherit;False;Property;_ScreenTexColor;屏幕颜色;28;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-1420.563,-2509.874;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;336;52.3648,-1374.636;Inherit;False;0;339;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;345;-1048.39,-2648.463;Inherit;False;Property;_RefnoiseU;热扭曲U速度;5;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;346;-1046.39,-2569.463;Inherit;False;Property;_RefnoiseV;热扭曲V速度;6;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;10;-773.5335,-2798.117;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1033.11,-2802.776;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;347;-902.3895,-2646.463;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-608.4289,-2487.78;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;14;-771.9217,-2584.245;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;-2915.082,-3162.56;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-3055.083,-3064.56;Inherit;False;Constant;_Float1;Float 1;42;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-2708.112,-3163.732;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;358;-2490.111,-3120.732;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;-2297.11,-3171.732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;354;-3060.084,-3162.56;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;365;-2494.673,-3197.98;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;361;-2351.818,-3041.456;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;360;-2173.109,-3171.732;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;362;-2044.109,-3170.732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;353;-3274.553,-3162.869;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;307;-2437.281,-2260.494;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;340;816.9144,-1373.792;Inherit;False;NoiseT;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2894.488,-2217.185;Inherit;False;Property;_ScreenMaskP;屏幕遮罩通道;37;2;[Toggle];[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-1820.885,-2193.919;Inherit;False;Property;_ScreenMaskMode;屏幕遮罩模式;35;1;[Enum];Create;False;0;2;Tex;0;Program;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;368;-1500.885,-2260.919;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;-1330.595,-2283.727;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;146;-3004.949,-1962.865;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;272;-2726.532,-1871.268;Inherit;False;271;zhendongg;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;274;-2421.475,-1961.422;Inherit;False;Global;_GrabScreen16;Grab Screen 16;38;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;147;-2251.804,-1957.125;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;148;-2081.401,-1962.406;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;-2542.532,-1955.268;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;160;-2713.499,-1731.982;Inherit;False;Polar Coordinates;-1;;6;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;279;-2706.904,-1435.8;Inherit;False;Polar Coordinates;-1;;5;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;348;-3014.044,-1667.943;Inherit;False;Property;_BNWPolarFlow1;放射1极坐标重铺与流动;17;0;Create;False;0;0;0;False;0;False;1,1,0.5,0.5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;349;-2622.287,-1588.518;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;351;-2618.287,-1291.518;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;350;-3010.287,-1371.518;Inherit;False;Property;_BNWPolarFlow2;放射2极坐标重铺与流动;19;0;Create;False;0;0;0;False;0;False;1,1,0.5,0.5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;164;-2429.274,-1731.049;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;280;-2425.576,-1434.353;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DesaturateOpNode;167;-1968.583,-1755.406;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DesaturateOpNode;283;-1960.597,-1458.857;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;282;-1794.486,-1464.119;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;169;-1806.116,-1759.452;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-1579.78,-1608.245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-1433.678,-1608.665;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;166;-1220.806,-1632.284;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-1494.801,-1237.216;Inherit;False;Property;_Float9;黑白过渡;15;0;Create;False;0;0;0;False;0;False;0;0.218;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-1195.234,-1256.053;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;149;-1046.816,-1330.24;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;158;-879.7738,-1259.736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;159;-491.0241,-1329.054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;153;-365.1039,-1423.873;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;155;-840.923,-1515.853;Inherit;False;Property;_Color0;颜色2;12;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;144;-3302.573,-826.5407;Inherit;False;Property;_ScreenCenter;径向模糊中心;8;1;[Header];Create;False;2;______________________________________________________________________;RadialBlur;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GrabScreenPosition;49;-3137.502,-976.4264;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2896.977,-845.6486;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-2534.151,-968.9678;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2897.978,-748.6495;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2899.977,-671.6494;Inherit;False;Property;_RadialBlur;径向模糊强度;10;0;Create;False;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2678.691,-846.7116;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-2238.151,-871.9677;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;50;-1852.105,-978.2988;Inherit;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-2091.874,-702.7365;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;80;-1945.874,-707.7365;Inherit;False;Global;_GrabScreen4;Grab Screen 4;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;76;-2074.152,-876.9677;Inherit;False;Global;_GrabScreen3;Grab Screen 3;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-1982.755,-530.6236;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;81;-1839.806,-533.8735;Inherit;False;Global;_GrabScreen5;Grab Screen 5;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-2243.587,-538.5286;Inherit;False;myBlur;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-1934.28,-357.4934;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;82;-1789.964,-362.1507;Inherit;False;Global;_GrabScreen6;Grab Screen 6;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-1823.517,-176.1859;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;83;-1678.123,-180.9473;Inherit;False;Global;_GrabScreen7;Grab Screen 7;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1374.309,10.67243;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-1770.198,4.465419;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;84;-1625.45,1.09184;Inherit;False;Global;_GrabScreen8;Grab Screen 8;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;85;-1539.997,194.9351;Inherit;False;Global;_GrabScreen9;Grab Screen 9;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-1688.538,199.8522;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-2133.912,-86.08828;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-1618.887,377.2025;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;86;-1451.3,372.0259;Inherit;False;Global;_GrabScreen10;Grab Screen 10;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;87;-1340.122,557.1929;Inherit;False;Global;_GrabScreen11;Grab Screen 11;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-1515.556,563.7192;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;88;-1235.051,738.8661;Inherit;False;Global;_GrabScreen12;Grab Screen 12;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-1416.625,745.5504;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;90;-1125.706,914.8279;Inherit;False;Global;_GrabScreen14;Grab Screen 14;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-1311.162,921.3261;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-986.209,539.711;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1775.119,758.2595;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-993.115,150.7324;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;109;-1004.78,-716.9101;Inherit;False;Property;_BlurDivission;径向模糊细分;9;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-927.4641,-528.1617;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-927.3226,-452.1108;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-927.2216,-373.794;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;116;-792.6415,-526.9843;Inherit;False;Property;_Keyword0;Keyword 0;9;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Reference;109;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;-642.6985,-712.2047;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-524.7624,-716.5258;Inherit;False;blur;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;-121.4136,-319.9348;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-272.246,-222.3725;Inherit;False;Property;_Float14;Y轴震动频率;23;0;Create;False;0;0;0;False;0;False;60;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;178;-119.2256,-217.6615;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;179;49.74997,-217.3725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;174;46.56296,-320.6448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;352.5666,-321.6448;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;180.5649,-292.6448;Inherit;False;Property;_Float12;X轴震动强度;24;0;Create;False;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;182.7619,-211.4745;Inherit;False;Property;_Float15;整体震动强度;26;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;189.7519,-128.3717;Inherit;False;Property;_Float13;Y轴震动强度;25;0;Create;False;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;351.7536,-189.3723;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;183;490.756,-257.2299;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;366;-1905.081,-3172.985;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;376;-1477.538,-3172.204;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;378;-1668.038,-3109.103;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;375;-1327.642,-3175.645;Inherit;False;chengxuMASK;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-269.6383,-724.4629;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;125;281.4752,-993.5712;Inherit;False;Global;_GrabScreen2;Grab Screen 2;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;131;279.1483,-813.2465;Inherit;False;Global;_GrabScreen13;Grab Screen 13;7;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-83.55424,-719.7856;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-71.3429,-992.2885;Inherit;False;129;myUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;139.151,-809.2427;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;132;278.9964,-634.8516;Inherit;False;Global;_GrabScreen15;Grab Screen 15;7;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;142;145.9057,-628.9848;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;475.7971,-821.7598;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;602.1448,-825.4447;Inherit;False;sesan;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-1787.349,-1301.872;Inherit;False;375;chengxuMASK;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;275;-3198.371,-1515.376;Inherit;False;Property;_PolarCenter;放射极坐标中心;20;0;Create;False;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;364;-2168.84,-3057.218;Inherit;False;Property;_PrgMaskM;程序遮罩过渡;44;0;Create;False;0;0;0;False;0;False;1;1.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;334;40.36502,-1176.676;Inherit;False;Property;_NoiseV;屏幕扰动V速率;41;0;Create;False;0;0;0;False;0;False;1;-0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;335;41.36502,-1250.676;Inherit;False;Property;_NoiseU;屏幕扰动U速率;40;0;Create;False;0;0;0;False;0;False;1;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;-2353.425,-2338.317;Inherit;False;Property;_NoiseIntScreen;屏幕扰动强度;39;0;Create;False;0;0;0;False;0;False;0.06342169;0.103;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;203;-2728.197,-2338.363;Inherit;True;Property;_ScreenTexMask;屏幕遮罩贴图;36;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;281;-2248.031,-1463.872;Inherit;True;Property;_TextureSample02;放射贴图02;18;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;161;-2250.297,-1760.394;Inherit;True;Property;_TextureSample01;放射贴图01;16;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-769.9026,-2412.426;Inherit;False;Property;_NoiseNormalIntensity;扭曲强度;3;0;Create;False;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-678.6988,-2134.689;Inherit;False;Property;_NoiseMaskP;热扭曲遮罩通道;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1497.523,-1312.029;Inherit;False;Property;_Float8;黑白范围;14;0;Create;False;2;______________________________________________________________________;heibai;0;0;False;0;False;0;0.093;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;156;-632.3171,-1519.96;Inherit;False;Property;_Color1;颜色1;11;2;[HDR];[Header];Create;False;2;______________________________________________________________________;BlacknWhite;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-531.1851,-2827.837;Inherit;True;Property;_NoiseTex;热扭曲贴图（法线）;2;1;[Header];Create;False;2;______________________________________________________________________;Ref;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;189;-1714.906,-2681.595;Inherit;True;Property;_ScreenTex;屏幕贴图;27;2;[Header];[NoScaleOffset];Create;False;2;______________________________________________________________________;ScreenEffect;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;141;-235.2723,-649.4868;Inherit;False;Property;_rgb;色散强度;42;1;[Header];Create;False;2;______________________________________________________________________;Sesan;0;0;False;0;False;0;3.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-2623.806,-2952.413;Inherit;False;Property;_PrgMaskOffest;程序遮罩大小;43;1;[Header];Create;False;2;______________________________________________________________________;GlobalMask;2;Glo;0;Option2;1;0;False;0;False;0.35;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;48.26392,-1917.588;Inherit;False;264;blur;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;49.01191,-1839.797;Inherit;False;260;BlacknWhiteColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;48.66178,-1759.183;Inherit;False;245;ScreenEffectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;48.80585,-1680.487;Inherit;False;256;sesan;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;46.38084,-1993.256;Inherit;False;252;RefColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;339;535.1223,-1397.918;Inherit;True;Property;_DistrScreen;屏幕扰动贴图;38;0;Create;False;1;NoiseTex;0;0;False;0;False;-1;None;7e8dfd0c9de33d446b68aa25b33d466f;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;116.0432,-2967.393;Inherit;False;RefColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;239;294.6549,-1889.507;Inherit;True;Property;_Keyword1;功能;1;0;Create;False;0;0;0;False;0;False;1;0;0;True;;KeywordEnum;5;Ref;Radialblur;BlacknWhite;ScreenEffect;Sesan;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;387;-333.0785,-2248.612;Inherit;False;RefAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;271;620.3682,-261.8143;Inherit;False;zhendongg;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-273.433,-324.6448;Inherit;False;Property;_Float11;X轴震动频率;22;0;Create;False;2;______________________________________________________________________;Shake;0;0;False;0;False;60;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2239.966,-1008.5;Inherit;False;myUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-1500.84,-1388.821;Inherit;False;Property;_Float10;放射强度;21;0;Create;False;0;0;0;False;0;False;0;0.496;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;157;-719.3047,-1334.02;Inherit;True;Property;_Keyword0;黑白切换;13;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-207.3577,-1428.23;Inherit;False;BlacknWhiteColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;-367.7229,-1523.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;396;-235.7783,-1528.549;Inherit;False;BlacknWhiteAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-1290.693,-2171.646;Inherit;False;ScreenEffectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-1818.52,-2282.663;Inherit;False;375;chengxuMASK;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-1412.688,-2400.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;399;-1285.688,-2402.55;Inherit;False;ScreenEffectAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;390;610.6862,-1890.989;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;382.9913,-2204.78;Inherit;False;387;RefAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;418.4963,-2131.032;Inherit;False;Constant;_Float0;Float 0;46;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;340.5049,-2054.605;Inherit;False;396;BlacknWhiteAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;342.8442,-1981.03;Inherit;False;399;ScreenEffectAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;392;609.2261,-2154.729;Inherit;True;Property;_Keyword1;功能;1;0;Create;False;0;0;0;False;0;False;1;0;0;True;;KeywordEnum;5;Ref;Radialblur;BlacknWhite;ScreenEffect;Sesan;Reference;239;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;391;914.6862,-1888.989;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;321;1130.69,-1887.144;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/全面屏幕后处理;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1659.338,-2888.203;Inherit;False;Property;_pgmask_sw;程序遮罩反向;45;1;[Toggle];Create;False;0;2;In;0;Out;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
WireConnection;110;0;50;0
WireConnection;110;1;76;0
WireConnection;110;2;80;0
WireConnection;110;3;81;0
WireConnection;112;0;110;0
WireConnection;112;1;111;0
WireConnection;8;0;5;0
WireConnection;8;1;9;1
WireConnection;47;0;8;0
WireConnection;323;0;18;1
WireConnection;323;1;18;4
WireConnection;323;2;324;0
WireConnection;18;1;24;0
WireConnection;201;0;200;1
WireConnection;201;1;200;2
WireConnection;214;0;201;0
WireConnection;214;1;196;0
WireConnection;214;2;213;0
WireConnection;196;1;201;0
WireConnection;196;3;327;0
WireConnection;196;4;328;0
WireConnection;221;0;220;1
WireConnection;221;1;220;2
WireConnection;222;0;220;3
WireConnection;222;1;220;4
WireConnection;331;0;329;0
WireConnection;331;1;330;0
WireConnection;337;0;335;0
WireConnection;337;1;334;0
WireConnection;338;0;336;0
WireConnection;338;2;337;0
WireConnection;198;0;343;0
WireConnection;198;2;331;0
WireConnection;343;0;219;0
WireConnection;343;1;341;0
WireConnection;343;2;344;0
WireConnection;219;0;214;0
WireConnection;219;1;221;0
WireConnection;219;2;222;0
WireConnection;192;0;189;0
WireConnection;192;1;190;0
WireConnection;10;0;11;0
WireConnection;10;2;347;0
WireConnection;347;0;345;0
WireConnection;347;1;346;0
WireConnection;13;0;14;4
WireConnection;13;1;15;0
WireConnection;355;0;354;0
WireConnection;355;1;356;0
WireConnection;357;0;355;0
WireConnection;357;1;355;0
WireConnection;358;0;357;0
WireConnection;359;0;365;0
WireConnection;359;1;358;0
WireConnection;354;0;353;0
WireConnection;365;0;357;0
WireConnection;361;0;363;0
WireConnection;360;0;359;0
WireConnection;360;1;361;0
WireConnection;362;0;360;0
WireConnection;307;0;203;1
WireConnection;307;1;203;4
WireConnection;307;2;306;0
WireConnection;340;0;339;1
WireConnection;368;0;307;0
WireConnection;368;1;374;0
WireConnection;368;2;369;0
WireConnection;332;0;192;0
WireConnection;332;1;368;0
WireConnection;274;0;273;0
WireConnection;147;0;274;0
WireConnection;148;0;147;0
WireConnection;273;0;146;0
WireConnection;273;1;272;0
WireConnection;160;1;146;0
WireConnection;160;2;275;0
WireConnection;160;3;348;1
WireConnection;160;4;348;2
WireConnection;279;1;146;0
WireConnection;279;2;275;0
WireConnection;279;3;350;1
WireConnection;279;4;350;2
WireConnection;349;0;348;3
WireConnection;349;1;348;4
WireConnection;351;0;350;3
WireConnection;351;1;350;4
WireConnection;164;0;160;0
WireConnection;164;2;349;0
WireConnection;280;0;279;0
WireConnection;280;2;351;0
WireConnection;167;0;161;0
WireConnection;283;0;281;0
WireConnection;282;0;283;0
WireConnection;169;0;167;0
WireConnection;288;0;169;0
WireConnection;288;1;282;0
WireConnection;289;0;288;0
WireConnection;289;1;385;0
WireConnection;166;0;148;0
WireConnection;166;1;289;0
WireConnection;166;2;170;0
WireConnection;152;0;150;0
WireConnection;152;1;151;0
WireConnection;149;0;166;0
WireConnection;149;1;150;0
WireConnection;149;2;152;0
WireConnection;158;0;149;0
WireConnection;159;0;157;0
WireConnection;153;0;156;0
WireConnection;153;1;155;0
WireConnection;153;2;159;0
WireConnection;51;0;49;0
WireConnection;51;1;144;0
WireConnection;78;0;49;0
WireConnection;78;1;55;0
WireConnection;55;0;51;0
WireConnection;55;1;56;0
WireConnection;55;2;58;0
WireConnection;77;0;78;0
WireConnection;77;1;55;0
WireConnection;50;0;78;0
WireConnection;79;0;77;0
WireConnection;79;1;55;0
WireConnection;80;0;79;0
WireConnection;76;0;77;0
WireConnection;96;0;79;0
WireConnection;96;1;55;0
WireConnection;81;0;96;0
WireConnection;98;0;55;0
WireConnection;97;0;96;0
WireConnection;97;1;99;0
WireConnection;82;0;97;0
WireConnection;100;0;97;0
WireConnection;100;1;99;0
WireConnection;83;0;100;0
WireConnection;111;0;82;0
WireConnection;111;1;83;0
WireConnection;111;2;84;0
WireConnection;111;3;85;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;84;0;101;0
WireConnection;85;0;102;0
WireConnection;102;0;101;0
WireConnection;102;1;99;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;86;0;104;0
WireConnection;87;0;105;0
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;88;0;106;0
WireConnection;106;0;105;0
WireConnection;106;1;103;0
WireConnection;90;0;107;0
WireConnection;107;0;106;0
WireConnection;107;1;103;0
WireConnection;114;0;86;0
WireConnection;114;1;87;0
WireConnection;114;2;88;0
WireConnection;114;3;90;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;109;1;110;0
WireConnection;109;0;112;0
WireConnection;109;2;113;0
WireConnection;116;1;117;0
WireConnection;116;0;118;0
WireConnection;116;2;119;0
WireConnection;115;0;109;0
WireConnection;115;1;116;0
WireConnection;264;0;115;0
WireConnection;172;0;175;0
WireConnection;178;0;182;0
WireConnection;179;0;178;0
WireConnection;174;0;172;0
WireConnection;177;0;174;0
WireConnection;177;1;176;0
WireConnection;177;2;188;0
WireConnection;180;0;179;0
WireConnection;180;1;181;0
WireConnection;180;2;188;0
WireConnection;183;0;177;0
WireConnection;183;1;180;0
WireConnection;366;0;362;0
WireConnection;366;1;364;0
WireConnection;376;0;366;0
WireConnection;376;1;378;0
WireConnection;376;2;377;0
WireConnection;378;0;366;0
WireConnection;375;0;376;0
WireConnection;125;0;130;0
WireConnection;131;0;138;0
WireConnection;139;0;140;0
WireConnection;139;1;141;0
WireConnection;138;0;130;0
WireConnection;138;1;139;0
WireConnection;132;0;142;0
WireConnection;142;0;138;0
WireConnection;142;1;139;0
WireConnection;135;0;125;1
WireConnection;135;1;131;2
WireConnection;135;2;132;3
WireConnection;256;0;135;0
WireConnection;203;1;201;0
WireConnection;281;1;280;0
WireConnection;161;1;164;0
WireConnection;9;1;10;0
WireConnection;9;5;13;0
WireConnection;189;1;198;0
WireConnection;339;1;338;0
WireConnection;252;0;47;0
WireConnection;239;1;253;0
WireConnection;239;0;265;0
WireConnection;239;2;261;0
WireConnection;239;3;246;0
WireConnection;239;4;257;0
WireConnection;387;0;323;0
WireConnection;271;0;183;0
WireConnection;129;0;78;0
WireConnection;157;1;149;0
WireConnection;157;0;158;0
WireConnection;260;0;153;0
WireConnection;395;0;155;4
WireConnection;395;1;156;4
WireConnection;396;0;395;0
WireConnection;245;0;332;0
WireConnection;398;0;190;4
WireConnection;398;1;368;0
WireConnection;399;0;398;0
WireConnection;390;0;239;0
WireConnection;392;1;388;0
WireConnection;392;0;393;0
WireConnection;392;2;397;0
WireConnection;392;3;400;0
WireConnection;392;4;393;0
WireConnection;391;0;390;0
WireConnection;391;3;392;0
WireConnection;321;0;391;0
ASEEND*/
//CHKSM=120E50698B50D4641142DEE017AC9DF0D5116890