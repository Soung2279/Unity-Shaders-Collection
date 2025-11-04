// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/额外热扭曲"
{
	Properties
	{
		[Header(Normal)]
		[Normal]_NormalTex("法线贴图", 2D) = "bump" {}
		_NormalScale("法线缩放", Float) = 1
		_NormalTexU("法线U速率", Float) = 0
		_NormalTexV("法线V速率", Float) = 0
		[Header(Distortion)]
		_DistortionTex("扭曲贴图", 2D) = "white" {}
		_DistortionIndensity("扭曲强度", Float) = 0
		_DistortionU("扭曲U速率", Float) = 0
		_DistortionV("扭曲V速率", Float) = 0
		[Header(Mask)]
		_AlphaTex("遮罩贴图", 2D) = "white" {}
		_AlphaTexU("遮罩U速率", Float) = 0
		_AlphaTexV("遮罩V速率", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		GrabPass{ }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Lambert keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float4 screenPos;
			half2 uv_texcoord;
			half2 uv2_texcoord2;
			float4 vertexColor : COLOR;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform half _NormalScale;
		uniform sampler2D _NormalTex;
		uniform half _NormalTexU;
		uniform half _NormalTexV;
		uniform float4 _NormalTex_ST;
		uniform sampler2D _DistortionTex;
		uniform float4 _DistortionTex_ST;
		uniform half _DistortionU;
		uniform half _DistortionV;
		uniform half _DistortionIndensity;
		uniform sampler2D _AlphaTex;
		uniform half _AlphaTexU;
		uniform half _AlphaTexV;
		uniform float4 _AlphaTex_ST;


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


		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult4 = (half2(_NormalTexU , _NormalTexV));
			float2 uv0_NormalTex = i.uv_texcoord * _NormalTex_ST.xy + _NormalTex_ST.zw;
			float2 uv0_DistortionTex = i.uv_texcoord * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
			float2 staticSwitch34 = uv0_DistortionTex;
			float2 appendResult38 = (half2(_DistortionU , _DistortionV));
			float3 desaturateInitialColor31 = tex2D( _DistortionTex, ( staticSwitch34 + ( appendResult38 * _Time.y ) ) ).rgb;
			float desaturateDot31 = dot( desaturateInitialColor31, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar31 = lerp( desaturateInitialColor31, desaturateDot31.xxx, 1.0 );
			float3 lerpResult29 = lerp( half3( ( ( appendResult4 * _Time.y ) + uv0_NormalTex ) ,  0.0 ) , desaturateVar31 , _DistortionIndensity);
			float4 screenColor132 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xy + (UnpackScaleNormal( tex2D( _NormalTex, lerpResult29.xy ), _NormalScale )).xy ));
			half4 ScreenGrab137 = screenColor132;
			o.Emission = ScreenGrab137.rgb;
			float2 appendResult143 = (half2(_AlphaTexU , _AlphaTexV));
			float2 uv0_AlphaTex = i.uv_texcoord * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
			float3 desaturateInitialColor147 = tex2D( _AlphaTex, ( ( appendResult143 * _Time.y ) + uv0_AlphaTex ) ).rgb;
			float desaturateDot147 = dot( desaturateInitialColor147, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar147 = lerp( desaturateInitialColor147, desaturateDot147.xxx, 1.0 );
			o.Alpha = ( (desaturateVar147).x * i.vertexColor.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
7;1;1906;1021;2397.172;92.59129;1.531561;True;True
Node;AmplifyShaderEditor.CommentaryNode;43;-3071.948,-223.713;Float;False;1193.903;518.8007;UV扭曲贴图;11;39;40;38;42;37;36;35;34;33;32;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-3023.548,82.38759;Half;False;Property;_DistortionU;DistortionU;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-3021.948,160.3876;Half;False;Property;_DistortionV;DistortionV;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;9;-2568.906,308.9374;Float;False;686.261;371.7072;UV_Panner;7;3;2;4;5;7;8;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;42;-2850.349,185.0878;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-2851.648,88.88756;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3021.948,-42.41261;Float;False;0;32;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-3021.946,-156.8128;Float;False;1;32;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-2515.906,435.9377;Half;False;Property;_NormalTexV;NormalTexV;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2518.906,358.9375;Half;False;Property;_NormalTexU;NormalTexU;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2696.948,88.88759;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-2334.906,361.9375;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-2501.945,-147.7128;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;5;-2336.369,453.3448;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-2174.906,361.9375;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2395.468,519.6447;Float;False;0;126;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-2381.045,-173.713;Float;True;Property;_DistortionTex;DistortionTex;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;139;-1893.651,778.1923;Float;False;686.261;371.7072;UV_Panner;7;146;145;144;143;142;141;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1840.651,905.1926;Half;False;Property;_AlphaTexV;AlphaTexV;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;31;-2082.044,-169.813;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2049.209,683.7081;Half;False;Property;_DistortionIndensity;DistortionIndensity;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-1843.651,828.1924;Half;False;Property;_AlphaTexU;AlphaTexU;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-2036.644,362.3605;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;142;-1661.114,922.5997;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;143;-1659.651,831.1924;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1843.7,377.8755;Half;False;Property;_NormalScale;NormalScale;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;-1767.044,203.5875;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-1499.651,831.1924;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;126;-1601.173,174.9005;Float;True;Property;_NormalTex;NormalTex;0;1;[Normal];Create;True;0;0;False;0;None;3ba24382ebbb24d4db01d889d26a2ce6;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;127;-1541.153,12.59344;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;-1720.213,988.8996;Float;False;0;135;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;129;-1168.472,102.5003;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;-1361.389,831.6154;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;130;-1192.181,178.8687;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-956.066,162.6009;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;135;-1188.77,801.8403;Float;True;Property;_AlphaTex;AlphaTex;9;0;Create;True;0;0;False;0;None;d1ea54bfbbf3b1a4282c4a983fed2253;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;132;-833.6913,158.201;Float;False;Global;_ScreenGrab0;Screen Grab 0;-1;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;147;-880.9258,823.2826;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;148;-707.8595,815.6248;Float;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-643.5339,10.02318;Half;False;ScreenGrab;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;150;-677.2294,890.671;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;136;-634.3446,85.06972;Float;False;137;ScreenGrab;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-499.5682,815.6245;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-286.2681,179.8125;Half;False;True;2;Half;ASEMaterialInspector;0;0;Lambert;fx_distortion;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;12;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;0;39;0
WireConnection;38;1;40;0
WireConnection;34;1;36;0
WireConnection;34;0;35;0
WireConnection;37;0;38;0
WireConnection;37;1;42;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;33;0;34;0
WireConnection;33;1;37;0
WireConnection;7;0;4;0
WireConnection;7;1;5;0
WireConnection;32;1;33;0
WireConnection;31;0;32;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;143;0;141;0
WireConnection;143;1;140;0
WireConnection;29;0;8;0
WireConnection;29;1;31;0
WireConnection;29;2;30;0
WireConnection;145;0;143;0
WireConnection;145;1;142;0
WireConnection;126;1;29;0
WireConnection;126;5;125;0
WireConnection;129;0;127;0
WireConnection;146;0;145;0
WireConnection;146;1;144;0
WireConnection;130;0;126;0
WireConnection;131;0;129;0
WireConnection;131;1;130;0
WireConnection;135;1;146;0
WireConnection;132;0;131;0
WireConnection;147;0;135;0
WireConnection;148;0;147;0
WireConnection;137;0;132;0
WireConnection;149;0;148;0
WireConnection;149;1;150;4
WireConnection;0;2;136;0
WireConnection;0;9;149;0
ASEEND*/
//CHKSM=30531F4566D07A4917F8227135BFD18C4374A031