// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FxClass/AlphaMask"
{
	Properties
	{
		_AlphaIntensity("Alpha强度", Float) = 0
		[HDR]_MainColor("主色调", Color) = (0.6792453,0.6792453,0.6792453,0)
		_MainTex("主贴图", 2D) = "white" {}
		_MainTexUspeed("主贴图U速度", Float) = 0
		_MianTexVspeed("主贴图V速度", Float) = 0
		_SecondTex("纹理贴图", 2D) = "white" {}
		_SecTexUspeed("纹理贴图U速度", Float) = 0
		_SecTexVspeed("纹理贴图V速度", Float) = 0
		_MaskTex("遮罩贴图", 2D) = "white" {}
		_Softedge("软粒子", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float4 _MainColor;
		uniform sampler2D _SecondTex;
		SamplerState sampler_SecondTex;
		uniform float _SecTexUspeed;
		uniform float _SecTexVspeed;
		uniform float4 _SecondTex_ST;
		uniform sampler2D _MainTex;
		SamplerState sampler_MainTex;
		uniform float _MainTexUspeed;
		uniform float _MianTexVspeed;
		uniform float4 _MainTex_ST;
		uniform sampler2D _MaskTex;
		SamplerState sampler_MaskTex;
		uniform float4 _MaskTex_ST;
		uniform float _AlphaIntensity;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Softedge;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult26 = (float2(_SecTexUspeed , _SecTexVspeed));
			float2 uv_SecondTex = i.uv_texcoord * _SecondTex_ST.xy + _SecondTex_ST.zw;
			float2 panner27 = ( 1.0 * _Time.y * appendResult26 + uv_SecondTex);
			float4 tex2DNode28 = tex2D( _SecondTex, panner27 );
			o.Emission = ( i.vertexColor * _MainColor * tex2DNode28.r ).rgb;
			float2 appendResult21 = (float2(_MainTexUspeed , _MianTexVspeed));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner18 = ( 1.0 * _Time.y * appendResult21 + uv_MainTex);
			float2 uv_MaskTex = i.uv_texcoord * _MaskTex_ST.xy + _MaskTex_ST.zw;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth31 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth31 = saturate( abs( ( screenDepth31 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Softedge ) ) );
			o.Alpha = saturate( ( tex2D( _MainTex, panner18 ).r * tex2D( _MaskTex, uv_MaskTex ).r * tex2DNode28.r * i.vertexColor.a * _AlphaIntensity * distanceDepth31 ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
28;85;1828;633;1524.308;889.041;1.685488;True;False
Node;AmplifyShaderEditor.RangedFloatNode;20;-787.0265,-599.0914;Inherit;False;Property;_MianTexVspeed;主贴图V速度;5;0;Create;False;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-787.0265,-671.0914;Inherit;False;Property;_MainTexUspeed;主贴图U速度;4;0;Create;False;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-798.7428,-335.6298;Inherit;False;Property;_SecTexVspeed;纹理贴图V速度;8;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-799.7428,-403.6298;Inherit;False;Property;_SecTexUspeed;纹理贴图U速度;7;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-648.0265,-669.0914;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-727.0265,-787.0915;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-723.4428,-528.0298;Inherit;False;0;28;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;26;-645.7428,-399.6298;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;27;-504.7427,-453.6299;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-440.1078,13.33092;Inherit;False;Property;_Softedge;软粒子;10;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;18;-507.0264,-723.0915;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-328.0001,-752.6846;Inherit;True;Property;_MainTex;主贴图;3;0;Create;False;0;0;False;0;False;-1;None;df966ac7d8c519248af875af35dafb6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-328.0164,-485.223;Inherit;True;Property;_SecondTex;纹理贴图;6;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-334.5456,-294.6007;Inherit;True;Property;_MaskTex;遮罩贴图;9;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;31;-270.3042,-6.313584;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-190.6723,-98.88303;Inherit;False;Property;_AlphaIntensity;Alpha强度;1;0;Create;False;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;3;-242.8,-1090.583;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;216.8913,-351.253;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-281.3001,-923.9847;Inherit;False;Property;_MainColor;主色调;2;1;[HDR];Create;False;0;0;False;0;False;0.6792453,0.6792453,0.6792453,0;0,0.2332882,0.2401495,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;30;369.8816,-300.8333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;177.3147,-766.1046;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;676.3999,-387.7;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;FxClass/AlphaMask;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;27;0;25;0
WireConnection;27;2;26;0
WireConnection;18;0;17;0
WireConnection;18;2;21;0
WireConnection;1;1;18;0
WireConnection;28;1;27;0
WireConnection;31;0;32;0
WireConnection;22;0;1;1
WireConnection;22;1;6;1
WireConnection;22;2;28;1
WireConnection;22;3;3;4
WireConnection;22;4;29;0
WireConnection;22;5;31;0
WireConnection;30;0;22;0
WireConnection;2;0;3;0
WireConnection;2;1;4;0
WireConnection;2;2;28;1
WireConnection;0;2;2;0
WireConnection;0;9;30;0
ASEEND*/
//CHKSM=51223A6B558F79D0BDB72DEAD77B69B53C0C6C2C