// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/特殊制作/全面后处理_黑白色散放射屏幕扭曲_post"
{
	Properties
	{
		[KeywordEnum(ref,radialblur,heibai,pingmuxiaoguo,sesan)] _Keyword1("功能", Float) = 0
		[Header(______________________________________________________________________)][Header(ref)]_NoiseTex("扭曲贴图（法线）", 2D) = "white" {}
		_NoiseNormalIntensity("法线强度", Float) = 1
		_NoisePanner("扭曲贴图流动", Vector) = (0,0,0,0)
		_NoiseMask("扭曲遮罩", 2D) = "white" {}
		_MaskIntensity("遮罩强度", Float) = 1
		[Header(______________________________________________________________________)][Header(RadialBlur)]_ScreenCenter("径向模糊中心", Vector) = (0.5,0.5,0,0)
		[KeywordEnum(4Blur,8Blur,12Blur)] _BlurDivission("径向模糊细分", Float) = 0
		_RadialBlur("径向模糊强度", Float) = 1
		[Header(______________________________________________________________________)][Header(heibai)]_Float8("黑白范围", Range( 0 , 1)) = 0
		_Float9("黑白过渡", Range( 0 , 1)) = 0
		[HDR]_Color0("颜色2", Color) = (1,1,1,1)
		[HDR]_Color1("颜色1", Color) = (0,0,0,1)
		[Toggle(_KEYWORD0_ON)] _Keyword0("黑白切换", Float) = 0
		_PolarCenter("放射贴图极坐标中心", Vector) = (0.5,0.5,0,0)
		_TextureSample01("放射贴图01", 2D) = "white" {}
		_Vector0("放射贴图极坐标UV01", Vector) = (1,1,0,0)
		_Vector1("放射贴图流动01", Vector) = (0,0,0,0)
		_TextureSample02("放射贴图02", 2D) = "black" {}
		_Vector2("放射贴图极坐标UV02", Vector) = (1,1,0,0)
		_Vector3("放射贴图流动02", Vector) = (0,0,0,0)
		_Float10("放射强度", Range( 0 , 1)) = 0
		_RadialLineMaskOffest("放射线遮罩大小", Float) = 0.05
		_RadialLineMask("放射线遮罩对比度", Float) = 1
		_Float13("Y轴震动强度", Float) = 0
		_Float11("X轴震动频率", Float) = 60
		_Float12("X轴震动强度", Float) = 0
		_Float14("Y轴震动频率", Float) = 60
		_Float15("整体震动强度", Float) = 1
		[Header(______________________________________________________________________)][Header(post)]_ScreenTex("屏幕贴图", 2D) = "white" {}
		_ScreenTexUV("屏幕贴图UV", Vector) = (1,1,0,0)
		[HDR]_ScreenTexColor("屏幕颜色", Color) = (1,1,1,1)
		_ScreenTexScale("屏幕强度", Float) = 1
		_ScreenTexPanner("屏幕贴图UV流动", Vector) = (0,0,0,0)
		[Toggle][Enum(Off,0,On,1)]_ScreenTexPolarOnOff("屏幕贴图是否开启极坐标", Float) = 1
		_ScreenTexPolarUV("屏幕贴图极坐标UV", Vector) = (1,1,0,0)
		_ScreenTexMask("屏幕贴图遮罩", 2D) = "white" {}
		[Toggle][Enum(R,0,A,1)]_Float16("通道", Float) = 0
		_ScreenMaskUV("屏幕遮罩UV", Vector) = (1,1,0,0)
		_ScreenTexMaskAlpha("屏幕贴图遮罩透明度", Float) = 1
		[Toggle(_SCREENTEXALPHA_ON)] _ScreenTexAlpha("Alpha通道是否受屏幕贴图影响", Float) = 0
		[Header(______________________________________________________________________)][Header(sesan)]_rgb("色散强度", Float) = 0
		_RadialLineMaskOffest1("色散遮罩大小", Float) = 0
		_RadialLineMask1("色散遮罩对比度", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_local _KEYWORD1_REF _KEYWORD1_RADIALBLUR _KEYWORD1_HEIBAI _KEYWORD1_PINGMUXIAOGUO _KEYWORD1_SESAN
		#pragma shader_feature_local _BLURDIVISSION_4BLUR _BLURDIVISSION_8BLUR _BLURDIVISSION_12BLUR
		#pragma shader_feature_local _KEYWORD0_ON
		#pragma shader_feature_local _SCREENTEXALPHA_ON
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _NoiseTex;
		uniform float2 _NoisePanner;
		uniform float4 _NoiseTex_ST;
		uniform float _NoiseNormalIntensity;
		uniform sampler2D _NoiseMask;
		uniform float4 _NoiseMask_ST;
		uniform float _MaskIntensity;
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
		uniform float2 _Vector1;
		uniform float2 _PolarCenter;
		uniform float2 _Vector0;
		uniform sampler2D _TextureSample02;
		uniform float2 _Vector3;
		uniform float2 _Vector2;
		uniform float _RadialLineMaskOffest;
		uniform float _RadialLineMask;
		uniform float _Float10;
		uniform sampler2D _ScreenTex;
		uniform float2 _ScreenTexPanner;
		uniform float2 _ScreenTexPolarUV;
		uniform float _ScreenTexPolarOnOff;
		uniform float4 _ScreenTexUV;
		uniform float4 _ScreenTexColor;
		uniform float _ScreenTexScale;
		uniform sampler2D _ScreenTexMask;
		uniform float4 _ScreenMaskUV;
		uniform float _Float16;
		uniform float _ScreenTexMaskAlpha;
		uniform float _rgb;
		uniform float _RadialLineMaskOffest1;
		uniform float _RadialLineMask1;


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


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float2 panner10 = ( 1.0 * _Time.y * _NoisePanner + uv_NoiseTex);
			float temp_output_13_0 = ( i.vertexColor.a * _NoiseNormalIntensity );
			float3 tex2DNode9 = UnpackScaleNormal( tex2D( _NoiseTex, panner10 ), temp_output_13_0 );
			float4 screenColor47 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + tex2DNode9.r ).xy);
			float4 appendResult227 = (float4((screenColor47).rgb , 0.0));
			float2 uv_NoiseMask = i.uv_texcoord * _NoiseMask_ST.xy + _NoiseMask_ST.zw;
			float3 desaturateInitialColor22 = tex2D( _NoiseMask, uv_NoiseMask ).rgb;
			float desaturateDot22 = dot( desaturateInitialColor22, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar22 = lerp( desaturateInitialColor22, desaturateDot22.xxx, 1.0 );
			float4 appendResult250 = (float4((appendResult227).xyz , ( (desaturateVar22).x * _MaskIntensity )));
			float4 ref252 = appendResult250;
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
			float4 appendResult120 = (float4((( staticSwitch109 / staticSwitch116 )).rgb , 1.0));
			float4 blur264 = appendResult120;
			float mulTime172 = _Time.y * _Float11;
			float mulTime178 = _Time.y * _Float14;
			float2 appendResult183 = (float2(( sin( mulTime172 ) * _Float12 * _Float15 ) , ( sin( mulTime178 ) * _Float13 * _Float15 )));
			float2 zhendongg271 = appendResult183;
			float4 screenColor274 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( zhendongg271, 0.0 , 0.0 ) ).xy);
			float3 desaturateInitialColor147 = screenColor274.rgb;
			float desaturateDot147 = dot( desaturateInitialColor147, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar147 = lerp( desaturateInitialColor147, desaturateDot147.xxx, 1.0 );
			float2 CenteredUV15_g6 = ( ase_grabScreenPosNorm.xy - _PolarCenter );
			float2 break17_g6 = CenteredUV15_g6;
			float2 appendResult23_g6 = (float2(( length( CenteredUV15_g6 ) * _Vector0.x * 2.0 ) , ( atan2( break17_g6.x , break17_g6.y ) * ( 1.0 / 6.28318548202515 ) * _Vector0.y )));
			float2 panner164 = ( 1.0 * _Time.y * _Vector1 + appendResult23_g6);
			float3 desaturateInitialColor167 = tex2D( _TextureSample01, panner164 ).rgb;
			float desaturateDot167 = dot( desaturateInitialColor167, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar167 = lerp( desaturateInitialColor167, desaturateDot167.xxx, 1.0 );
			float2 CenteredUV15_g5 = ( ase_grabScreenPosNorm.xy - _PolarCenter );
			float2 break17_g5 = CenteredUV15_g5;
			float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * _Vector2.x * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / 6.28318548202515 ) * _Vector2.y )));
			float2 panner280 = ( 1.0 * _Time.y * _Vector3 + appendResult23_g5);
			float3 desaturateInitialColor283 = tex2D( _TextureSample02, panner280 ).rgb;
			float desaturateDot283 = dot( desaturateInitialColor283, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar283 = lerp( desaturateInitialColor283, desaturateDot283.xxx, 1.0 );
			float2 temp_output_295_0 = ( ( i.uv_texcoord - _PolarCenter ) * 2.0 );
			float2 temp_output_297_0 = ( temp_output_295_0 * temp_output_295_0 );
			float lerpResult166 = lerp( (desaturateVar147).x , ( ( (desaturateVar167).x + (desaturateVar283).x ) * pow( saturate( ( ( (temp_output_297_0).x + (temp_output_297_0).y ) - _RadialLineMaskOffest ) ) , _RadialLineMask ) ) , _Float10);
			float smoothstepResult149 = smoothstep( _Float8 , ( _Float8 + _Float9 ) , lerpResult166);
			#ifdef _KEYWORD0_ON
				float staticSwitch157 = ( 1.0 - smoothstepResult149 );
			#else
				float staticSwitch157 = smoothstepResult149;
			#endif
			float4 lerpResult153 = lerp( _Color1 , _Color0 , saturate( staticSwitch157 ));
			float4 heibai260 = lerpResult153;
			float2 appendResult201 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float2 CenteredUV15_g7 = ( appendResult201 - float2( 0.5,0.5 ) );
			float2 break17_g7 = CenteredUV15_g7;
			float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * _ScreenTexPolarUV.x * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / 6.28318548202515 ) * _ScreenTexPolarUV.y )));
			float2 lerpResult214 = lerp( appendResult201 , appendResult23_g7 , _ScreenTexPolarOnOff);
			float2 appendResult221 = (float2(_ScreenTexUV.x , _ScreenTexUV.y));
			float2 appendResult222 = (float2(_ScreenTexUV.z , _ScreenTexUV.w));
			float2 panner198 = ( 1.0 * _Time.y * _ScreenTexPanner + (lerpResult214*appendResult221 + appendResult222));
			float4 break209 = ( tex2D( _ScreenTex, panner198 ) * _ScreenTexColor * _ScreenTexScale );
			float3 appendResult210 = (float3(break209.r , break209.g , break209.b));
			float2 appendResult241 = (float2(_ScreenMaskUV.x , _ScreenMaskUV.y));
			float2 appendResult242 = (float2(_ScreenMaskUV.z , _ScreenMaskUV.w));
			float4 tex2DNode203 = tex2D( _ScreenTexMask, (appendResult201*appendResult241 + appendResult242) );
			float lerpResult307 = lerp( tex2DNode203.r , tex2DNode203.a , _Float16);
			float temp_output_206_0 = ( lerpResult307 * _ScreenTexMaskAlpha );
			#ifdef _SCREENTEXALPHA_ON
				float staticSwitch211 = ( break209.a * temp_output_206_0 );
			#else
				float staticSwitch211 = temp_output_206_0;
			#endif
			float4 appendResult193 = (float4(appendResult210 , staticSwitch211));
			float4 post245 = appendResult193;
			float4 myUV129 = temp_output_78_0;
			float4 temp_output_137_0 = ( myUV129 - float4( 0,0,0,0 ) );
			float4 screenColor125 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( temp_output_137_0 + float4( 0,0,0,0 ) ).xy);
			float4 temp_output_139_0 = ( myBlur98 * _rgb );
			float4 temp_output_138_0 = ( temp_output_137_0 - temp_output_139_0 );
			float4 screenColor131 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( temp_output_138_0 + float4( 0,0,0,0 ) ).xy);
			float4 screenColor132 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( temp_output_138_0 - temp_output_139_0 ) + float4( 0,0,0,0 ) ).xy);
			float2 temp_output_311_0 = ( ( i.uv_texcoord - float2( 0.5,0.5 ) ) * 2.0 );
			float2 temp_output_312_0 = ( temp_output_311_0 * temp_output_311_0 );
			float4 appendResult135 = (float4(screenColor125.r , screenColor131.g , screenColor132.b , pow( saturate( ( ( (temp_output_312_0).x + (temp_output_312_0).y ) - _RadialLineMaskOffest1 ) ) , _RadialLineMask1 )));
			float4 sesan256 = appendResult135;
			#if defined(_KEYWORD1_REF)
				float4 staticSwitch239 = ref252;
			#elif defined(_KEYWORD1_RADIALBLUR)
				float4 staticSwitch239 = blur264;
			#elif defined(_KEYWORD1_HEIBAI)
				float4 staticSwitch239 = heibai260;
			#elif defined(_KEYWORD1_PINGMUXIAOGUO)
				float4 staticSwitch239 = post245;
			#elif defined(_KEYWORD1_SESAN)
				float4 staticSwitch239 = sesan256;
			#else
				float4 staticSwitch239 = ref252;
			#endif
			o.Emission = staticSwitch239.xyz;
			#if defined(_KEYWORD1_REF)
				float staticSwitch244 = (ref252).w;
			#elif defined(_KEYWORD1_RADIALBLUR)
				float staticSwitch244 = (blur264).w;
			#elif defined(_KEYWORD1_HEIBAI)
				float staticSwitch244 = (heibai260).a;
			#elif defined(_KEYWORD1_PINGMUXIAOGUO)
				float staticSwitch244 = (post245).w;
			#elif defined(_KEYWORD1_SESAN)
				float staticSwitch244 = (sesan256).w;
			#else
				float staticSwitch244 = (ref252).w;
			#endif
			o.Alpha = staticSwitch244;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
1941;53;1920;1001;-684.5477;3812.785;1.006854;True;False
Node;AmplifyShaderEditor.CommentaryNode;123;-3320.724,-571.7028;Inherit;False;4194.564;2906.639;径向模糊;49;264;120;121;122;115;109;116;119;118;113;117;112;114;111;90;88;87;110;86;81;85;82;50;107;76;83;80;84;106;105;104;102;103;101;100;97;96;99;79;98;77;78;55;56;51;58;49;144;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;49;-3110.249,-503.6335;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;144;-3296.32,-350.7478;Inherit;False;Property;_ScreenCenter;径向模糊中心;7;1;[Header];Create;False;2;______________________________________________________________________;RadialBlur;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;56;-2806.725,-222.8567;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2825.724,-82.85672;Inherit;False;Property;_RadialBlur;径向模糊强度;9;0;Create;False;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2773.724,-371.8557;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2563.438,-330.9187;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-2427.898,-507.1749;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-2182.898,-311.1748;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;184;-4272.134,2374.133;Inherit;False;1504.189;601.5623;震屏;13;172;174;177;176;175;178;179;180;182;181;183;188;271;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-3320.745,-2292.007;Inherit;False;3715.746;1679.389;黑白闪;49;170;150;151;304;305;288;280;283;281;282;279;278;260;153;156;155;159;157;158;149;152;166;289;148;303;147;169;274;302;167;301;273;161;272;164;298;160;165;300;299;297;295;292;275;296;293;163;146;277;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-2419.658,198.2541;Inherit;False;myBlur;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-4222.134,2438.423;Inherit;False;Property;_Float11;X轴震动频率;26;0;Create;False;0;0;0;False;0;False;60;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-2198.621,-91.94388;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-4236.947,2721.696;Inherit;False;Property;_Float14;Y轴震动频率;28;0;Create;False;0;0;0;False;0;False;60;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;275;-3107.018,-1517.126;Inherit;False;Property;_PolarCenter;放射贴图极坐标中心;15;0;Create;False;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-2168.502,136.1691;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-2580.703,753.2122;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;178;-3977.926,2708.407;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;-3984.114,2430.133;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;292;-3223.594,-1033.401;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;174;-3680.137,2426.423;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-2169.027,382.2994;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-3604.135,2575.423;Inherit;False;Property;_Float12;X轴震动强度;27;0;Create;False;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;179;-3675.95,2709.696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;293;-2981.126,-1036.092;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-3537.938,2681.594;Inherit;False;Property;_Float15;整体震动强度;29;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-3584.948,2860.696;Inherit;False;Property;_Float13;Y轴震动强度;25;0;Create;False;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-2913.126,-922.0919;Inherit;False;Constant;_Float1;Float 1;42;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-3283.133,2487.423;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;146;-3103.882,-2081.34;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;277;-3163.187,-1335.769;Inherit;False;Property;_Vector2;放射贴图极坐标UV02;20;0;Create;False;0;0;0;False;0;False;1,1;0.1,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;163;-3133.061,-1731.325;Inherit;False;Property;_Vector0;放射贴图极坐标UV01;17;0;Create;False;0;0;0;False;0;False;1,1;0.1,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-2133.906,648.5932;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-3244.946,2771.696;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-2729.126,-1031.092;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;165;-2730.106,-1599.224;Inherit;False;Property;_Vector1;放射贴图流动01;18;0;Create;False;0;0;0;False;0;False;0,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;278;-2752.974,-1203.461;Inherit;False;Property;_Vector3;放射贴图流动02;21;0;Create;False;0;0;0;False;0;False;0,0;-0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2138.502,897.9172;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;279;-2810.558,-1397.902;Inherit;False;Polar Coordinates;-1;;5;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;160;-2766.432,-1815.457;Inherit;False;Polar Coordinates;-1;;6;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;183;-2928.944,2556.838;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;297;-2494.162,-1029.264;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;202;-3395.409,-3802.457;Inherit;False;3703.177;1420.654;屏幕效果;31;192;211;200;201;203;197;199;190;191;196;207;206;210;209;189;198;213;214;212;219;220;221;222;240;241;242;243;193;245;306;307;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2497.642,1605.81;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;271;-2981.332,2794.254;Inherit;False;zhendongg;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;299;-2290.162,-1024.264;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;164;-2503.207,-1770.524;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;200;-3314.597,-3744.442;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;300;-2271.162,-885.2643;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;280;-2533.332,-1374.969;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-2107.285,1126.645;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;201;-3062.392,-3702.82;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;143;-2630.001,2359.81;Inherit;False;2400.395;1283.26;色散;29;136;256;135;131;320;132;125;185;186;187;318;319;317;142;138;316;315;139;314;313;137;140;141;130;312;311;309;310;308;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;272;-2656.465,-1979.744;Inherit;False;271;zhendongg;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-2160.718,1475.802;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;197;-3181.689,-3450.469;Inherit;False;Property;_ScreenTexPolarUV;屏幕贴图极坐标UV;36;0;Create;False;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;298;-2032.162,-986.2643;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-1877.858,-752.9448;Inherit;False;Property;_RadialLineMaskOffest;放射线遮罩大小;23;0;Create;False;0;0;0;False;0;False;0.05;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;161;-2303.23,-1783.869;Inherit;True;Property;_TextureSample01;放射贴图01;16;0;Create;False;0;0;0;False;0;False;-1;None;8099576c56323284f968338e126f6dcd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;281;-2333.329,-1395.314;Inherit;True;Property;_TextureSample02;放射贴图02;19;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2151.564,1698.118;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;196;-2830.386,-3630.213;Inherit;False;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;308;-2622.224,3208.917;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;283;-2036.642,-1391.325;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;220;-2633.472,-3318.619;Inherit;False;Property;_ScreenTexUV;屏幕贴图UV;31;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;301;-1686.161,-983.2643;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;-2399.465,-2096.744;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;48;764.3871,-3825.482;Inherit;False;2940.886;1402.522;热扭曲;23;227;252;22;250;251;23;234;26;24;25;218;18;40;47;8;9;5;13;10;11;14;15;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DesaturateOpNode;167;-1981.517,-1783.881;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2931.373,-3315.958;Inherit;False;Property;_ScreenTexPolarOnOff;屏幕贴图是否开启极坐标;35;2;[Toggle];[Enum];Create;False;0;2;Off;0;On;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-2259.756,3360.226;Inherit;False;Constant;_Float0;Float 0;42;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;240;-2819.556,-2851.309;Inherit;False;Property;_ScreenMaskUV;屏幕遮罩UV;39;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;14;1118.299,-3118.365;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;878.111,-3395.896;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;1128.318,-2902.546;Inherit;False;Property;_NoiseNormalIntensity;法线强度;3;0;Create;False;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-2097.947,1864.202;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;169;-1786.05,-1804.927;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;282;-1898.166,-1587.315;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;302;-1369.161,-979.2643;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;-2396.033,-3298.619;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;221;-2435.033,-3448.619;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;214;-2525.247,-3703.499;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;310;-2327.756,3246.226;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-1363.892,-765.7502;Inherit;False;Property;_RadialLineMask;放射线遮罩对比度;24;0;Create;False;0;0;0;False;0;False;1;1.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;274;-2086.408,-2100.898;Inherit;False;Global;_GrabScreen16;Grab Screen 16;38;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;12;849.8939,-3138.719;Inherit;False;Property;_NoisePanner;扭曲贴图流动;4;0;Create;False;0;0;0;False;0;False;0,0;0.25,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;241;-2558.689,-2866.007;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;81;-1891.553,120.9191;Inherit;False;Global;_GrabScreen5;Grab Screen 5;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2235.713,-581.7067;Inherit;False;myUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;242;-2529.689,-2767.008;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;82;-1910.711,357.6422;Inherit;False;Global;_GrabScreen6;Grab Screen 6;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-1652.714,-1691.72;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;85;-1892.937,1067.797;Inherit;False;Global;_GrabScreen9;Grab Screen 9;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;199;-2247.319,-3512.363;Inherit;False;Property;_ScreenTexPanner;屏幕贴图UV流动;34;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenColorNode;80;-1903.621,-96.94388;Inherit;False;Global;_GrabScreen4;Grab Screen 4;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;147;-1755.737,-2089.601;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;219;-2292.033,-3664.619;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;-2075.757,3251.226;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;10;1183.687,-3387.237;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;76;-1910.899,-305.1748;Inherit;False;Global;_GrabScreen3;Grab Screen 3;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;303;-1045.991,-973.0802;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;83;-1907.94,586.6982;Inherit;False;Global;_GrabScreen7;Grab Screen 7;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;50;-1892.852,-502.5059;Inherit;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;84;-1892.085,834.6072;Inherit;False;Global;_GrabScreen8;Grab Screen 8;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;1375.792,-3119.9;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-2087.484,2045.979;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1663.457,-1376.504;Inherit;False;Property;_Float8;黑白范围;10;1;[Header];Create;False;2;______________________________________________________________________;heibai;0;0;False;0;False;0;0.093;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-1486.612,-1747.14;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-1665.735,-1279.691;Inherit;False;Property;_Float9;黑白过渡;11;0;Create;False;0;0;0;False;0;False;0;0.218;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;5;1233.146,-3723.329;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;170;-1633.774,-1531.296;Inherit;False;Property;_Float10;放射强度;22;0;Create;False;0;0;0;False;0;False;0;0.496;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1551.689,-239.2129;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;148;-1445.334,-2070.881;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;87;-1869.756,1576.708;Inherit;False;Global;_GrabScreen11;Grab Screen 11;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;88;-1834.891,1839.226;Inherit;False;Global;_GrabScreen12;Grab Screen 12;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;130;-2612.272,2413.111;Inherit;False;129;myUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1517.15,591.1023;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;90;-1824.028,2050.481;Inherit;False;Global;_GrabScreen14;Grab Screen 14;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;140;-2603.001,2871.833;Inherit;False;98;myBlur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;243;-2586.221,-3044.682;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-1840.793,3253.054;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;86;-1869.574,1311.982;Inherit;False;Global;_GrabScreen10;Grab Screen 10;5;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;1499.036,-3371.957;Inherit;True;Property;_NoiseTex;扭曲贴图（法线）;2;1;[Header];Create;False;2;______________________________________________________________________;ref;0;0;False;0;False;-1;None;bd53ca3218ae027419b4fe93a155ece1;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;198;-2072.932,-3658.416;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-2595.635,3019.809;Inherit;False;Property;_rgb;色散强度;42;1;[Header];Create;False;2;______________________________________________________________________;sesan;0;0;False;0;False;0;3.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;313;-1636.793,3258.054;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;1778.202,-3732.158;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;166;-1256.74,-1632.759;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-1945.089,-2754.838;Inherit;False;Property;_Float16;通道;38;2;[Toggle];[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;203;-2269.654,-2935.906;Inherit;True;Property;_ScreenTexMask;屏幕贴图遮罩;37;0;Create;False;0;0;0;False;0;False;-1;None;cb066a62d9bffac41a6ab8bc9922065f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2347.917,2884.51;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;972.1879,-2770.334;Inherit;False;0;18;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;314;-1617.793,3397.054;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-1294.168,-1322.528;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1280.771,193.5041;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;190;-1789.734,-3445.498;Inherit;False;Property;_ScreenTexColor;屏幕颜色;32;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-1382.431,1701.862;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;-2193.973,2431.158;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;189;-1877.247,-3664.582;Inherit;True;Property;_ScreenTex;屏幕贴图;30;1;[Header];Create;False;2;______________________________________________________________________;post;0;0;False;0;False;-1;None;cb066a62d9bffac41a6ab8bc9922065f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;-1771.871,-3221.326;Inherit;False;Property;_ScreenTexScale;屏幕强度;33;0;Create;False;0;0;0;False;0;False;1;4.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;149;-1102.75,-1432.715;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-883.7043,256.9961;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;307;-1794.089,-2930.838;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-1224.489,3529.373;Inherit;False;Property;_RadialLineMaskOffest1;色散遮罩大小;43;0;Create;False;0;0;0;False;0;False;0;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1188.567,1143.911;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-895.6898,14.01814;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;47;2275.046,-3756.452;Inherit;False;Global;_GrabScreen1;Grab Screen 1;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;118;-892.3459,119.9621;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;315;-1378.793,3296.054;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;-2101.212,2673.053;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-1407.904,-3369.86;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;18;1263.947,-2796.847;Inherit;True;Property;_NoiseMask;扭曲遮罩;5;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;207;-1668.744,-2505.992;Inherit;False;Property;_ScreenTexMaskAlpha;屏幕贴图遮罩透明度;40;0;Create;False;0;0;0;False;0;False;1;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;317;-1032.791,3299.054;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;109;-969.6718,-419.1889;Inherit;False;Property;_BlurDivission;径向模糊细分;8;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;2396.298,-3496.14;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;158;-852.7081,-1392.211;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1235.423,-2772.158;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;116;-669.0552,15.19709;Inherit;False;Property;_Keyword0;Keyword 0;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;4Blur;8Blur;12Blur;Reference;109;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;22;1602.48,-2778.667;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;209;-1229.807,-3353.99;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;142;-2109.457,2925.311;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;-1888.318,2444.759;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-916.3141,-3154.649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;157;-665.239,-1536.495;Inherit;True;Property;_Keyword0;黑白切换;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;187;-1902.599,2960.674;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;-543.6656,-305.6089;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-710.5226,3516.568;Inherit;False;Property;_RadialLineMask1;色散遮罩对比度;44;0;Create;False;0;0;0;False;0;False;1;6.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;227;2690.401,-3386.589;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;26;1912.941,-2526.24;Inherit;False;Property;_MaskIntensity;遮罩强度;6;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;318;-715.7917,3303.054;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;1796.693,-2781.417;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;186;-1846.075,2651.507;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;159;-419.9585,-1565.529;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;210;-895.446,-3369.399;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;211;-840.6212,-2839.179;Inherit;False;Property;_ScreenTexAlpha;Alpha通道是否受屏幕贴图影响;41;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;125;-1675.996,2405.384;Inherit;False;Global;_GrabScreen2;Grab Screen 2;7;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-369.6543,40.01602;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;131;-1701.019,2660.484;Inherit;False;Global;_GrabScreen13;Grab Screen 13;7;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;2236.417,-2828.904;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;155;-810.6256,-1961.808;Inherit;False;Property;_Color0;颜色2;12;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;121;-375.1578,-256.7348;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;320;-392.6216,3309.238;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;156;-829.3848,-2166.126;Inherit;False;Property;_Color1;颜色1;13;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;132;-1707.171,2920.879;Inherit;False;Global;_GrabScreen15;Grab Screen 15;7;0;Create;True;0;0;0;False;0;False;Instance;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;251;2979.613,-3337.495;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1352.147,2573.913;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;250;3184.766,-2907.272;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;153;-408.7163,-1966.51;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;193;-527.3445,-2970.014;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;-113.9153,-176.1387;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-236.0862,-2953.015;Inherit;False;post;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;53.70004,-1714.446;Inherit;False;heibai;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;3453.955,-2844.827;Inherit;False;ref;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;220.4907,-167.7331;Inherit;False;blur;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1035.791,2657.647;Inherit;False;sesan;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;3161.794,2163.952;Inherit;False;256;sesan;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;3122.077,1757.175;Inherit;False;260;heibai;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;3115.197,1489.06;Inherit;False;252;ref;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;3112.526,1925.804;Inherit;True;245;post;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;3176.966,1583.548;Inherit;False;264;blur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;2699.797,916.1506;Inherit;False;252;ref;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;255;3455.197,1489.06;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;2629.222,1359.92;Inherit;False;256;sesan;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;2623.078,1228.224;Inherit;False;245;post;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;267;3421.966,1569.548;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;2613.68,1032.819;Inherit;False;264;blur;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;2628.428,1134.61;Inherit;False;260;heibai;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;249;3412.625,1919.004;Inherit;True;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;259;3434.794,2138.952;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;270;3464,1746.393;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;239;3210.072,999.8994;Inherit;False;Property;_Keyword1;功能;1;0;Create;False;0;0;0;False;0;False;1;0;0;True;;KeywordEnum;5;ref;radialblur;heibai;pingmuxiaoguo;sesan;Create;True;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;2237.396,-3180.666;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1499.081,2931.913;Inherit;False;Constant;_Float7;Float 7;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;244;3950.113,1541.606;Inherit;False;Property;_Keyword2;功能;1;0;Create;False;0;0;0;False;0;False;1;0;0;True;;KeywordEnum;4;ref;radialblur;heibai;pingmuxiaoguo;Reference;239;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;234;1820.934,-3348.02;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;238;5121.638,1378.331;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;post;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;49;0
WireConnection;51;1;144;0
WireConnection;55;0;51;0
WireConnection;55;1;56;0
WireConnection;55;2;58;0
WireConnection;78;0;49;0
WireConnection;78;1;55;0
WireConnection;77;0;78;0
WireConnection;77;1;55;0
WireConnection;98;0;55;0
WireConnection;79;0;77;0
WireConnection;79;1;55;0
WireConnection;96;0;79;0
WireConnection;96;1;55;0
WireConnection;178;0;182;0
WireConnection;172;0;175;0
WireConnection;174;0;172;0
WireConnection;97;0;96;0
WireConnection;97;1;99;0
WireConnection;179;0;178;0
WireConnection;293;0;292;0
WireConnection;293;1;275;0
WireConnection;177;0;174;0
WireConnection;177;1;176;0
WireConnection;177;2;188;0
WireConnection;100;0;97;0
WireConnection;100;1;99;0
WireConnection;180;0;179;0
WireConnection;180;1;181;0
WireConnection;180;2;188;0
WireConnection;295;0;293;0
WireConnection;295;1;296;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;279;1;146;0
WireConnection;279;2;275;0
WireConnection;279;3;277;1
WireConnection;279;4;277;2
WireConnection;160;1;146;0
WireConnection;160;2;275;0
WireConnection;160;3;163;1
WireConnection;160;4;163;2
WireConnection;183;0;177;0
WireConnection;183;1;180;0
WireConnection;297;0;295;0
WireConnection;297;1;295;0
WireConnection;271;0;183;0
WireConnection;299;0;297;0
WireConnection;164;0;160;0
WireConnection;164;2;165;0
WireConnection;300;0;297;0
WireConnection;280;0;279;0
WireConnection;280;2;278;0
WireConnection;102;0;101;0
WireConnection;102;1;99;0
WireConnection;201;0;200;1
WireConnection;201;1;200;2
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;298;0;299;0
WireConnection;298;1;300;0
WireConnection;161;1;164;0
WireConnection;281;1;280;0
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;196;1;201;0
WireConnection;196;3;197;1
WireConnection;196;4;197;2
WireConnection;283;0;281;0
WireConnection;301;0;298;0
WireConnection;301;1;305;0
WireConnection;273;0;146;0
WireConnection;273;1;272;0
WireConnection;167;0;161;0
WireConnection;106;0;105;0
WireConnection;106;1;103;0
WireConnection;169;0;167;0
WireConnection;282;0;283;0
WireConnection;302;0;301;0
WireConnection;222;0;220;3
WireConnection;222;1;220;4
WireConnection;221;0;220;1
WireConnection;221;1;220;2
WireConnection;214;0;201;0
WireConnection;214;1;196;0
WireConnection;214;2;213;0
WireConnection;310;0;308;0
WireConnection;274;0;273;0
WireConnection;241;0;240;1
WireConnection;241;1;240;2
WireConnection;81;0;96;0
WireConnection;129;0;78;0
WireConnection;242;0;240;3
WireConnection;242;1;240;4
WireConnection;82;0;97;0
WireConnection;288;0;169;0
WireConnection;288;1;282;0
WireConnection;85;0;102;0
WireConnection;80;0;79;0
WireConnection;147;0;274;0
WireConnection;219;0;214;0
WireConnection;219;1;221;0
WireConnection;219;2;222;0
WireConnection;311;0;310;0
WireConnection;311;1;309;0
WireConnection;10;0;11;0
WireConnection;10;2;12;0
WireConnection;76;0;77;0
WireConnection;303;0;302;0
WireConnection;303;1;304;0
WireConnection;83;0;100;0
WireConnection;50;0;78;0
WireConnection;84;0;101;0
WireConnection;13;0;14;4
WireConnection;13;1;15;0
WireConnection;107;0;106;0
WireConnection;107;1;103;0
WireConnection;289;0;288;0
WireConnection;289;1;303;0
WireConnection;110;0;50;0
WireConnection;110;1;76;0
WireConnection;110;2;80;0
WireConnection;110;3;81;0
WireConnection;148;0;147;0
WireConnection;87;0;105;0
WireConnection;88;0;106;0
WireConnection;111;0;82;0
WireConnection;111;1;83;0
WireConnection;111;2;84;0
WireConnection;111;3;85;0
WireConnection;90;0;107;0
WireConnection;243;0;201;0
WireConnection;243;1;241;0
WireConnection;243;2;242;0
WireConnection;312;0;311;0
WireConnection;312;1;311;0
WireConnection;86;0;104;0
WireConnection;9;1;10;0
WireConnection;9;5;13;0
WireConnection;198;0;219;0
WireConnection;198;2;199;0
WireConnection;313;0;312;0
WireConnection;8;0;5;0
WireConnection;8;1;9;1
WireConnection;166;0;148;0
WireConnection;166;1;289;0
WireConnection;166;2;170;0
WireConnection;203;1;243;0
WireConnection;139;0;140;0
WireConnection;139;1;141;0
WireConnection;314;0;312;0
WireConnection;152;0;150;0
WireConnection;152;1;151;0
WireConnection;112;0;110;0
WireConnection;112;1;111;0
WireConnection;114;0;86;0
WireConnection;114;1;87;0
WireConnection;114;2;88;0
WireConnection;114;3;90;0
WireConnection;137;0;130;0
WireConnection;189;1;198;0
WireConnection;149;0;166;0
WireConnection;149;1;150;0
WireConnection;149;2;152;0
WireConnection;307;0;203;1
WireConnection;307;1;203;4
WireConnection;307;2;306;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;47;0;8;0
WireConnection;315;0;313;0
WireConnection;315;1;314;0
WireConnection;138;0;137;0
WireConnection;138;1;139;0
WireConnection;192;0;189;0
WireConnection;192;1;190;0
WireConnection;192;2;191;0
WireConnection;18;1;24;0
WireConnection;317;0;315;0
WireConnection;317;1;316;0
WireConnection;109;1;110;0
WireConnection;109;0;112;0
WireConnection;109;2;113;0
WireConnection;40;0;47;0
WireConnection;158;0;149;0
WireConnection;206;0;307;0
WireConnection;206;1;207;0
WireConnection;116;1;117;0
WireConnection;116;0;118;0
WireConnection;116;2;119;0
WireConnection;22;0;18;0
WireConnection;209;0;192;0
WireConnection;142;0;138;0
WireConnection;142;1;139;0
WireConnection;185;0;137;0
WireConnection;212;0;209;3
WireConnection;212;1;206;0
WireConnection;157;1;149;0
WireConnection;157;0;158;0
WireConnection;187;0;142;0
WireConnection;115;0;109;0
WireConnection;115;1;116;0
WireConnection;227;0;40;0
WireConnection;318;0;317;0
WireConnection;23;0;22;0
WireConnection;186;0;138;0
WireConnection;159;0;157;0
WireConnection;210;0;209;0
WireConnection;210;1;209;1
WireConnection;210;2;209;2
WireConnection;211;1;206;0
WireConnection;211;0;212;0
WireConnection;125;0;185;0
WireConnection;131;0;186;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;121;0;115;0
WireConnection;320;0;318;0
WireConnection;320;1;319;0
WireConnection;132;0;187;0
WireConnection;251;0;227;0
WireConnection;135;0;125;1
WireConnection;135;1;131;2
WireConnection;135;2;132;3
WireConnection;135;3;320;0
WireConnection;250;0;251;0
WireConnection;250;3;25;0
WireConnection;153;0;156;0
WireConnection;153;1;155;0
WireConnection;153;2;159;0
WireConnection;193;0;210;0
WireConnection;193;3;211;0
WireConnection;120;0;121;0
WireConnection;120;3;122;0
WireConnection;245;0;193;0
WireConnection;260;0;153;0
WireConnection;252;0;250;0
WireConnection;264;0;120;0
WireConnection;256;0;135;0
WireConnection;255;0;254;0
WireConnection;267;0;266;0
WireConnection;249;0;248;0
WireConnection;259;0;258;0
WireConnection;270;0;268;0
WireConnection;239;1;253;0
WireConnection;239;0;265;0
WireConnection;239;2;261;0
WireConnection;239;3;246;0
WireConnection;239;4;257;0
WireConnection;218;0;234;0
WireConnection;218;1;13;0
WireConnection;244;1;255;0
WireConnection;244;0;267;0
WireConnection;244;2;270;0
WireConnection;244;3;249;0
WireConnection;244;4;259;0
WireConnection;234;0;9;1
WireConnection;238;2;239;0
WireConnection;238;9;244;0
ASEEND*/
//CHKSM=DB4462247E69A799D0DEBC00FB9EA0CD87E1ABFC