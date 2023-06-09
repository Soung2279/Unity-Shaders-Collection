// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/特殊制作/折射与色差故障_SinVFX"
{
	Properties
	{
		_Distortion_Tex("扭曲贴图", 2D) = "white" {}
		[Toggle(_DISTORTION_TEX2UV_ON)] _Distortion_Tex2UV("扭曲贴图反面UV", Float) = 0
		_DistortionU("扭曲贴图U方向速率", Float) = 0
		_DistortionV("扭曲贴图V方向速率", Float) = 0
		_Indensity("扭曲强度", Float) = 0
		_AlphaTex("Alpha贴图", 2D) = "white" {}
		[Toggle(_ALPHATEX2UV_ON)] _AlphaTex2UV("Alpha贴图反面UV", Float) = 0
		_AlphaU("Alpha贴图U方向速率", Float) = 0
		_AlphaV("Alpha贴图V方向速率", Float) = 0
		_AlphaTex1("Alpha附加贴图 1", 2D) = "white" {}
		[Toggle(_ALPHATEX12UV_ON)] _AlphaTex12UV("Alpha贴图反面UV", Float) = 0
		_AlphaTex1U("Alpha贴图U方向速率", Float) = 0
		_AlphaTex1V("Alpha贴图V方向速率", Float) = 0
		_AlphaTex2("Alpha附加贴图 2", 2D) = "white" {}
		[Toggle(_ALPHATEX22UV_ON)] _AlphaTex22UV("Alpha贴图反面UV", Float) = 0
		_AlphaTex2U("Alpha贴图U方向速率", Float) = 0
		_AlphaTex2V("Alpha贴图V方向速率", Float) = 0
		_IOR1("材质最小折射率", Float) = 1
		_IOR2("材质最大折射率", Float) = 1.4
		[Header(Refraction)]
		_ChromaticAberration("色差强度", Range( 0 , 0.3)) = 0.1
		_SpecColor("高光颜色",Color)=(1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature _DISTORTION_TEX2UV_ON
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma shader_feature _ALPHATEX2UV_ON
		#pragma shader_feature _ALPHATEX12UV_ON
		#pragma shader_feature _ALPHATEX22UV_ON
		#pragma surface surf BlinnPhong alpha:fade keepalpha finalcolor:RefractionF noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float3 worldPos;
		};

		uniform sampler2D _Distortion_Tex;
		uniform float4 _Distortion_Tex_ST;
		uniform float _DistortionU;
		uniform float _DistortionV;
		uniform float _Indensity;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _IOR1;
		uniform float _IOR2;
		uniform sampler2D _AlphaTex;
		uniform float4 _AlphaTex_ST;
		uniform float _AlphaU;
		uniform float _AlphaV;
		uniform sampler2D _AlphaTex1;
		uniform float4 _AlphaTex1_ST;
		uniform float _AlphaTex1U;
		uniform float _AlphaTex1V;
		uniform sampler2D _AlphaTex2;
		uniform float4 _AlphaTex2_ST;
		uniform float _AlphaTex2U;
		uniform float _AlphaTex2V;

		inline float4 Refraction( Input i, SurfaceOutput o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutput o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float temp_output_63_0 = ( i.vertexColor.a * _Indensity );
			float2 uv0_AlphaTex = i.uv_texcoord * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
			float2 uv1_AlphaTex = i.uv2_texcoord2 * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
			#ifdef _ALPHATEX2UV_ON
				float2 staticSwitch72 = uv1_AlphaTex;
			#else
				float2 staticSwitch72 = uv0_AlphaTex;
			#endif
			float2 appendResult46 = (float2(_AlphaU , _AlphaV));
			float3 desaturateInitialColor65 = tex2D( _AlphaTex, ( staticSwitch72 + ( _Time.y * appendResult46 ) ) ).rgb;
			float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 0.0 );
			float2 uv0_AlphaTex1 = i.uv_texcoord * _AlphaTex1_ST.xy + _AlphaTex1_ST.zw;
			float2 uv1_AlphaTex1 = i.uv2_texcoord2 * _AlphaTex1_ST.xy + _AlphaTex1_ST.zw;
			#ifdef _ALPHATEX12UV_ON
				float2 staticSwitch82 = uv1_AlphaTex1;
			#else
				float2 staticSwitch82 = uv0_AlphaTex1;
			#endif
			float2 appendResult80 = (float2(_AlphaTex1U , _AlphaTex1V));
			float3 desaturateInitialColor87 = tex2D( _AlphaTex1, ( staticSwitch82 + ( _Time.y * appendResult80 ) ) ).rgb;
			float desaturateDot87 = dot( desaturateInitialColor87, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar87 = lerp( desaturateInitialColor87, desaturateDot87.xxx, 1.0 );
			float2 uv0_AlphaTex2 = i.uv_texcoord * _AlphaTex2_ST.xy + _AlphaTex2_ST.zw;
			float2 uv1_AlphaTex2 = i.uv2_texcoord2 * _AlphaTex2_ST.xy + _AlphaTex2_ST.zw;
			#ifdef _ALPHATEX22UV_ON
				float2 staticSwitch98 = uv1_AlphaTex2;
			#else
				float2 staticSwitch98 = uv0_AlphaTex2;
			#endif
			float2 appendResult91 = (float2(_AlphaTex2U , _AlphaTex2V));
			float3 desaturateInitialColor90 = tex2D( _AlphaTex2, ( staticSwitch98 + ( _Time.y * appendResult91 ) ) ).rgb;
			float desaturateDot90 = dot( desaturateInitialColor90, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar90 = lerp( desaturateInitialColor90, desaturateDot90.xxx, 1.0 );
			float lerpResult67 = lerp( _IOR1 , _IOR2 , ( temp_output_63_0 * desaturateVar65 * (desaturateVar87).x * (desaturateVar90).x ).x);
			color.rgb = color.rgb + Refraction( i, o, lerpResult67, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv0_Distortion_Tex = i.uv_texcoord * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
			float2 uv1_Distortion_Tex = i.uv2_texcoord2 * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
			#ifdef _DISTORTION_TEX2UV_ON
				float2 staticSwitch70 = uv1_Distortion_Tex;
			#else
				float2 staticSwitch70 = uv0_Distortion_Tex;
			#endif
			float2 appendResult3 = (float2(_DistortionU , _DistortionV));
			float temp_output_63_0 = ( i.vertexColor.a * _Indensity );
			float4 lerpResult60 = lerp( float4( float3(0,0,1) , 0.0 ) , tex2D( _Distortion_Tex, ( staticSwitch70 + ( _Time.y * appendResult3 ) ) ) , temp_output_63_0);
			o.Normal = lerpResult60.rgb;
			o.Alpha = 0.0;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
0;0;1920;1029;2623.938;-775.4548;1.647208;True;True
Node;AmplifyShaderEditor.RangedFloatNode;97;-1764.895,2124.695;Float;False;Property;_AlphaTex2V;AlphaTex2V;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1764.392,2015.288;Float;False;Property;_AlphaTex2U;AlphaTex2U;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1693.24,1555.995;Float;False;Property;_AlphaTex1V;AlphaTex1V;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1692.737,1446.588;Float;False;Property;_AlphaTex1U;AlphaTex1U;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;-1623.027,1822.604;Float;False;1;95;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;99;-1615.595,1698.725;Float;False;0;95;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-1551.372,1253.904;Float;False;1;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;80;-1480.24,1499.995;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-1543.94,1130.025;Float;False;0;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-1575.389,923.0203;Float;False;Property;_AlphaV;AlphaV;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1574.886,813.6138;Float;False;Property;_AlphaU;AlphaU;7;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;81;-1532.24,1369.995;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-1551.895,2068.695;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;92;-1603.895,1938.695;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1313.24,1452.995;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-1426.089,497.0504;Float;False;0;50;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;45;-1414.389,737.0203;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-1362.389,867.0203;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;75;-1433.521,620.9294;Float;False;1;50;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;82;-1237.372,1203.904;Float;False;Property;_AlphaTex12UV;AlphaTex12UV;10;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1384.895,2021.695;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;98;-1309.027,1772.604;Float;False;Property;_AlphaTex22UV;AlphaTex22UV;14;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1867.43,163.811;Float;False;Property;_DistortionV;DistortionV;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;72;-1119.521,570.9294;Float;False;Property;_AlphaTex2UV;AlphaTex2UV;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1195.389,820.0203;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-1123.181,1957.528;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-1051.526,1388.828;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1866.927,54.40448;Float;False;Property;_DistortionU;DistortionU;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-933.6749,755.8541;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1706.43,-22.18903;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1716.13,-383.1591;Float;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;-917.8883,1336.154;Float;True;Property;_AlphaTex1;AlphaTex1;9;0;Create;True;0;0;False;0;None;24488b843501cd8438feb796bfe87c7e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;3;-1654.43,107.811;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;74;-1732.521,-236.0706;Float;False;1;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;95;-989.5427,1904.854;Float;True;Property;_AlphaTex2;AlphaTex2;13;0;Create;True;0;0;False;0;None;243931021c6eca34b90d769cd904d102;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1487.43,60.81097;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;50;-770.3877,716.357;Float;True;Property;_AlphaTex;AlphaTex;5;0;Create;True;0;0;False;0;None;cc01fe3ffd19df44d8f7b0e05d8c9ecd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;-760.6718,394.7097;Float;False;Property;_Indensity;Indensity;4;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;87;-627.5208,1146.077;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DesaturateOpNode;90;-699.1752,1714.777;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;62;-780.6611,215.2979;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;70;-1398.521,-223.0706;Float;False;Property;_Distortion_Tex2UV;Distortion_Tex2UV;1;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;88;-370.5559,1078.541;Float;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-1225.716,-3.355291;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-510.0658,289.4367;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;65;-343.7271,699.7895;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;89;-442.2102,1647.241;Float;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-105.8718,230.1125;Float;False;Property;_IOR1;IOR1;17;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-105.8386,323.6413;Float;False;Property;_IOR2;IOR2;18;0;Create;True;0;0;False;0;1.4;1.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;61;-627.1041,-254.3397;Float;False;Constant;_NoneNormal;NoneNormal;6;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;9;-1053.382,-32.63161;Float;True;Property;_Distortion_Tex;Distortion_Tex;0;0;Create;True;0;0;False;0;None;9a4a55d8d2e54394d97426434477cdcf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-81.43979,496.4662;Float;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;67;150.3489,293.1428;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;383.7585,381.4213;Float;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-430.9625,-32.50388;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;590.5408,58.13877;Float;False;True;7;Float;ASEMaterialInspector;0;0;BlinnPhong;SinVFX/ASE_RefractionDistortion;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;19;-1;0;False;0;0;False;-1;21;0;False;-1;0;0;0;False;0.3;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;80;0;77;0
WireConnection;80;1;76;0
WireConnection;91;0;96;0
WireConnection;91;1;97;0
WireConnection;83;0;81;0
WireConnection;83;1;80;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;82;1;78;0
WireConnection;82;0;79;0
WireConnection;93;0;92;0
WireConnection;93;1;91;0
WireConnection;98;1;99;0
WireConnection;98;0;100;0
WireConnection;72;1;47;0
WireConnection;72;0;75;0
WireConnection;48;0;45;0
WireConnection;48;1;46;0
WireConnection;94;0;98;0
WireConnection;94;1;93;0
WireConnection;84;0;82;0
WireConnection;84;1;83;0
WireConnection;49;0;72;0
WireConnection;49;1;48;0
WireConnection;85;1;84;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;95;1;94;0
WireConnection;4;0;6;0
WireConnection;4;1;3;0
WireConnection;50;1;49;0
WireConnection;87;0;85;0
WireConnection;90;0;95;0
WireConnection;70;1;8;0
WireConnection;70;0;74;0
WireConnection;88;0;87;0
WireConnection;7;0;70;0
WireConnection;7;1;4;0
WireConnection;63;0;62;4
WireConnection;63;1;64;0
WireConnection;65;0;50;0
WireConnection;89;0;90;0
WireConnection;9;1;7;0
WireConnection;66;0;63;0
WireConnection;66;1;65;0
WireConnection;66;2;88;0
WireConnection;66;3;89;0
WireConnection;67;0;68;0
WireConnection;67;1;69;0
WireConnection;67;2;66;0
WireConnection;60;0;61;0
WireConnection;60;1;9;0
WireConnection;60;2;63;0
WireConnection;0;1;60;0
WireConnection;0;8;67;0
WireConnection;0;9;59;0
ASEEND*/
//CHKSM=16EFB525298B35C98FFCC53FD51A3195295BBB44