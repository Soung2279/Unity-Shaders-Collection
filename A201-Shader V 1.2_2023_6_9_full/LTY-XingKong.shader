// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/特殊制作/星空刀光制作_XingKong"
{
	Properties
	{
		[Header(Screen_Tex)]_Screen_Tex("面向屏幕的贴图", 2D) = "white" {}
		[HDR]_Screen_Color("屏幕贴图颜色 ", Color) = (1,1,1,1)
		_Opacity("屏幕贴图不透明度", Range( 0 , 1)) = 1
		_TilingOffset("Tiling / Offset", Vector) = (1,1,0,0)
		_panner("UV流动速度", Vector) = (0.1,0,1,0)
		_Gam("颜色叠加", 2D) = "white" {}
		[Header(Mask)]_Mask("主要蒙版贴图（用来确定形状）", 2D) = "white" {}
		[Toggle(_ONE_UV_ON)] _One_UV("是否使用粒子控制蒙版UV流动", Float) = 0
		_Mask_U_Speed("主蒙版U方向流动速度", Float) = 0
		_Mask_V_Speed("主蒙版V方向流动速度", Float) = 0
		[Header(Mask_T)]_Mask_m2("额外蒙版贴图（用来缓入缓出）", 2D) = "white" {}
		[Header(Dissiovle)]_Diss("溶解贴图", 2D) = "white" {}
		[Toggle(_ONE_DISS_ON)] _One_Diss("是否使用粒子控制溶解（X控制）", Float) = 0
		_Diss_Power("数值溶解强度", Float) = 0
		_Smooth("溶解平滑度", Range( 0.5 , 1)) = 0.5
		[HideInInspector] _tex4coord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _ONE_DISS_ON
		#pragma shader_feature_local _ONE_UV_ON
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float4 uv2_tex4coord2;
			float4 vertexColor : COLOR;
		};

		uniform float4 _Screen_Color;
		uniform sampler2D _Screen_Tex;
		uniform float4 _panner;
		uniform float4 _TilingOffset;
		uniform float _Smooth;
		uniform sampler2D _Diss;
		uniform float4 _Diss_ST;
		uniform float _Diss_Power;
		uniform sampler2D _Gam;
		uniform float4 _Gam_ST;
		uniform float _Opacity;
		uniform sampler2D _Mask;
		uniform float _Mask_U_Speed;
		uniform float _Mask_V_Speed;
		uniform float4 _Mask_ST;
		uniform sampler2D _Mask_m2;
		uniform float4 _Mask_m2_ST;


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
			float mulTime8 = _Time.y * _panner.z;
			float2 appendResult16 = (float2(_panner.x , _panner.y));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult11 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float2 appendResult12 = (float2(_TilingOffset.x , _TilingOffset.y));
			float2 appendResult13 = (float2(_TilingOffset.z , _TilingOffset.w));
			float2 panner7 = ( mulTime8 * appendResult16 + (appendResult11*appendResult12 + appendResult13));
			float4 tex2DNode2 = tex2D( _Screen_Tex, panner7 );
			float2 uv_Diss = i.uv_texcoord * _Diss_ST.xy + _Diss_ST.zw;
			#ifdef _ONE_DISS_ON
				float staticSwitch30 = i.uv2_tex4coord2.x;
			#else
				float staticSwitch30 = _Diss_Power;
			#endif
			float smoothstepResult27 = smoothstep( ( 1.0 - _Smooth ) , _Smooth , saturate( ( ( tex2D( _Diss, uv_Diss ).r + 1.0 ) - ( staticSwitch30 * 2.0 ) ) ));
			float2 uv_Gam = i.uv_texcoord * _Gam_ST.xy + _Gam_ST.zw;
			o.Emission = ( _Screen_Color * tex2DNode2 * smoothstepResult27 * tex2D( _Gam, uv_Gam ) * i.vertexColor ).rgb;
			float2 appendResult40 = (float2(_Mask_U_Speed , _Mask_V_Speed));
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 uv2s4_Mask = i.uv2_tex4coord2;
			uv2s4_Mask.xy = i.uv2_tex4coord2.xy * _Mask_ST.xy + _Mask_ST.zw;
			float2 appendResult43 = (float2(uv2s4_Mask.z , uv2s4_Mask.w));
			#ifdef _ONE_UV_ON
				float2 staticSwitch41 = ( uv_Mask + appendResult43 );
			#else
				float2 staticSwitch41 = uv_Mask;
			#endif
			float2 panner35 = ( 1.0 * _Time.y * appendResult40 + staticSwitch41);
			float2 uv_Mask_m2 = i.uv_texcoord * _Mask_m2_ST.xy + _Mask_m2_ST.zw;
			o.Alpha = ( _Screen_Color.a * tex2DNode2.a * _Opacity * tex2D( _Mask, panner35 ).r * smoothstepResult27 * i.vertexColor.a * tex2D( _Mask_m2, uv_Mask_m2 ).r );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
2099;201;1461;818;1928.882;202.3335;1.554497;True;True
Node;AmplifyShaderEditor.CommentaryNode;32;-2029.966,1050.681;Inherit;False;1315.512;525.4197;溶解;12;27;26;22;21;20;29;28;23;30;25;24;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1868.315,307.1937;Inherit;False;1141.661;470.8777;蒙版;10;19;35;41;36;40;43;42;38;37;50;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2147.144,-165.478;Inherit;False;1416.668;459.8881;屏幕贴图;13;9;8;10;16;7;14;15;11;13;12;2;34;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1924.564,1291.983;Inherit;False;Property;_Diss_Power;Diss_Power;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-1979.965,1369.1;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1666.843,607.3457;Inherit;False;1;19;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-1842.125,344.3844;Inherit;False;0;19;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;14;-2097.144,-115.478;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;30;-1766.694,1291.489;Inherit;False;Property;_One_Diss;One_Diss;13;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;15;-2052.169,53.76938;Inherit;False;Property;_TilingOffset;Tiling/Offset;4;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-1714.776,1100.681;Inherit;True;Property;_Diss;Diss;12;1;[Header];Create;True;1;Dissiovle;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;43;-1437.689,683.8901;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1690.495,1394.528;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1839.663,478.6219;Inherit;False;Property;_Mask_U_Speed;Mask_U_Speed;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1865.071,49.5694;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1864.671,142.0694;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-1866.046,-46.37763;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1836.646,561.6094;Inherit;False;Property;_Mask_V_Speed;Mask_V_Speed;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1518.656,447.0146;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1554.218,1297.45;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1385.843,1130.927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;9;-1729.094,82.41018;Inherit;False;Property;_panner;panner;5;0;Create;True;0;0;0;False;0;False;0.1,0,1,0;0,0,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;-1656.39,508.5583;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;10;-1565.303,-45.42908;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;41;-1361.349,342.4552;Inherit;False;Property;_One_UV;One_UV;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1225.676,1129.988;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-1543.251,166.778;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1506.955,70.57763;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1527.468,1392.28;Inherit;False;Property;_Smooth;Smooth;15;0;Create;True;0;0;0;False;0;False;0.5;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1103.235,-467.7387;Inherit;False;370;280;丰富颜色用;1;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;35;-1180.063,395.7889;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;29;-1232.754,1234.658;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;7;-1311.595,77.83871;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;26;-1058.41,1129.989;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-1312.09,-111.0122;Inherit;False;Property;_Screen_Color;Screen_Color ;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-903.4527,1129.989;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-646.6631,186.8966;Inherit;False;Property;_Opacity;Opacity;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;34;-948.4451,123.8863;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-1053.235,-417.7386;Inherit;True;Property;_Gam;Gam;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-1009.649,367.1914;Inherit;True;Property;_Mask;Mask;7;1;[Header];Create;True;1;Mask;0;0;False;0;False;-1;None;315503c40ada1b24f9cd869f6cbff7e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1026.962,-76.00832;Inherit;True;Property;_Screen_Tex;Screen_Tex;1;1;[Header];Create;True;1;Screen_Tex;0;0;False;0;False;-1;73d1980d996b4794fa39b7c24633d572;73d1980d996b4794fa39b7c24633d572;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;51;-1007.304,840.0582;Inherit;True;Property;_Mask_m2;Mask_m2;11;1;[Header];Create;True;1;Mask_T;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-123.5835,-204.3925;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-127.3579,132.1999;Inherit;True;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;17;231.7864,-201.0217;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;LTY/shader/XingKong;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;1;24;0
WireConnection;30;0;31;1
WireConnection;43;0;42;3
WireConnection;43;1;42;4
WireConnection;12;0;15;1
WireConnection;12;1;15;2
WireConnection;13;0;15;3
WireConnection;13;1;15;4
WireConnection;11;0;14;1
WireConnection;11;1;14;2
WireConnection;50;0;36;0
WireConnection;50;1;43;0
WireConnection;23;0;30;0
WireConnection;23;1;25;0
WireConnection;21;0;20;1
WireConnection;40;0;38;0
WireConnection;40;1;37;0
WireConnection;10;0;11;0
WireConnection;10;1;12;0
WireConnection;10;2;13;0
WireConnection;41;1;36;0
WireConnection;41;0;50;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;8;0;9;3
WireConnection;16;0;9;1
WireConnection;16;1;9;2
WireConnection;35;0;41;0
WireConnection;35;2;40;0
WireConnection;29;0;28;0
WireConnection;7;0;10;0
WireConnection;7;2;16;0
WireConnection;7;1;8;0
WireConnection;26;0;22;0
WireConnection;27;0;26;0
WireConnection;27;1;29;0
WireConnection;27;2;28;0
WireConnection;19;1;35;0
WireConnection;2;1;7;0
WireConnection;5;0;3;0
WireConnection;5;1;2;0
WireConnection;5;2;27;0
WireConnection;5;3;33;0
WireConnection;5;4;34;0
WireConnection;18;0;3;4
WireConnection;18;1;2;4
WireConnection;18;2;4;0
WireConnection;18;3;19;1
WireConnection;18;4;27;0
WireConnection;18;5;34;4
WireConnection;18;6;51;1
WireConnection;17;2;5;0
WireConnection;17;9;18;0
ASEEND*/
//CHKSM=A52CAEFD5BB47A94B9DA8CE114BEB32CABADFCC6