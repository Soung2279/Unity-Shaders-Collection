// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/序列帧材质_Addtive"
{
	Properties
	{
		[Header(FlipBookTex)]_MainTex("序列帧图集", 2D) = "white" {}
		[KeywordEnum(R,A)] _SwitchP("贴图通道切换", Float) = 0
		_Flipbookval("横纵数量-速度-起始帧", Vector) = (0,0,0,0)
		[HDR]_MainColor1("主颜色", Color) = (0.6132076,0.6132076,0.6132076,0.5333334)
		[Header(MaskTex)]_Mask("遮罩贴图", 2D) = "white" {}
		_MaskMult("遮罩强度", Range( 0.01 , 2)) = 0
		[Toggle(_USEFIX_ON)] _UseFix("启用边缘修复", Float) = 0
		_Fixval("修复阈值 (建议默认)", Range( 1 , 200)) = 150
		[Header(DepthFade)]_DepthFade("软粒子", Range( 0 , 100)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		Blend One One
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USEFIX_ON
		#pragma shader_feature_local _SWITCHP_R _SWITCHP_A
		#pragma surface surf StandardCustomLighting keepalpha noshadow nofog 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _MaskMult;
		uniform float _Fixval;
		uniform float4 _MainColor1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Flipbookval;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFade;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float temp_output_86_0 = saturate( ( tex2D( _Mask, uv_Mask ).r * _MaskMult ) );
			#ifdef _USEFIX_ON
				float staticSwitch84 = ( saturate( ( ( 1.0 - saturate( i.uv_texcoord.x ) ) * ( 1.0 - saturate( i.uv_texcoord.y ) ) * saturate( i.uv_texcoord.x ) * saturate( i.uv_texcoord.y ) * _Fixval ) ) * temp_output_86_0 );
			#else
				float staticSwitch84 = temp_output_86_0;
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float mulTime10 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles3 = _Flipbookval.x * _Flipbookval.y;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset3 = 1.0f / _Flipbookval.x;
			float fbrowsoffset3 = 1.0f / _Flipbookval.y;
			// Speed of animation
			float fbspeed3 = mulTime10 * _Flipbookval.z;
			// UV Tiling (col and row offset)
			float2 fbtiling3 = float2(fbcolsoffset3, fbrowsoffset3);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex3 = round( fmod( fbspeed3 + _Flipbookval.w, fbtotaltiles3) );
			fbcurrenttileindex3 += ( fbcurrenttileindex3 < 0) ? fbtotaltiles3 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox3 = round ( fmod ( fbcurrenttileindex3, _Flipbookval.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx3 = fblinearindextox3 * fbcolsoffset3;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy3 = round( fmod( ( fbcurrenttileindex3 - fblinearindextox3 ) / _Flipbookval.x, _Flipbookval.y ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy3 = (int)(_Flipbookval.y-1) - fblinearindextoy3;
			// Multiply Offset Y by rowoffset
			float fboffsety3 = fblinearindextoy3 * fbrowsoffset3;
			// UV Offset
			float2 fboffset3 = float2(fboffsetx3, fboffsety3);
			// Flipbook UV
			half2 fbuv3 = frac( uv_MainTex ) * fbtiling3 + fboffset3;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode16 = tex2D( _MainTex, fbuv3 );
			float3 appendResult46 = (float3(tex2DNode16.r , tex2DNode16.g , tex2DNode16.b));
			#if defined(_SWITCHP_R)
				float staticSwitch44 = tex2DNode16.r;
			#elif defined(_SWITCHP_A)
				float staticSwitch44 = tex2DNode16.a;
			#else
				float staticSwitch44 = tex2DNode16.r;
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth18 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth18 = abs( ( screenDepth18 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			o.Emission = ( staticSwitch84 * ( _MainColor1 * float4( appendResult46 , 0.0 ) * i.vertexColor * staticSwitch44 ) * saturate( distanceDepth18 ) ).rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;92;-1182.401,-466.4693;Inherit;False;743;303;可控强度的遮罩贴图;5;86;39;45;37;38;叠加遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-219.0875,217.0354;Inherit;False;617;133;深度消隐;3;19;21;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-1417.077,-120.407;Inherit;False;568.853;418.815;利用FlipBook节点实现UV动画;5;10;3;4;5;90;序列帧动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.DepthFade;18;47.72462,256.5972;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;275.4252,256.7728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;687.3649,-65.66476;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;VFX/FlipAddtive;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;9;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;488.5407,-17.22137;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;50;-1384.371,-823.4329;Inherit;False;949.1721;309.5532;利用程序遮罩修复FlipBook出现的切边;11;83;69;77;51;88;87;52;89;55;56;53;修复遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-1354.942,-768.1327;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-1356.052,-649.3914;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;90;-1402.068,51.7226;Inherit;False;Property;_Flipbookval;横纵数量-速度-起始帧;2;0;Create;False;0;0;0;False;0;False;0,0,0,0;4,3,3,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1402.806,-71.94623;Inherit;False;0;16;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;4;-1199.68,-65.7576;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;3;-1068.28,56.19951;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1265.157,226.0614;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-545.4709,54.67236;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;44;-418.9749,96.64117;Inherit;True;Property;_SwitchP;贴图通道切换;1;0;Create;False;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-217.0323,-0.09805679;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;-761.4366,-149.7058;Inherit;False;Property;_MainColor1;主颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;0.6132076,0.6132076,0.6132076,0.5333334;2,2,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;52;-1142.94,-713.134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;87;-1143.643,-781.6277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;-1142.643,-646.6279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;-1142.05,-580.3908;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;88;-1017.641,-783.6277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;51;-1016.938,-714.134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1017.328,-643.466;Inherit;False;Property;_Fixval;修复阈值 (建议默认);7;0;Create;False;0;0;0;False;0;False;150;150;1;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-757.6139,-733.4417;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;83;-562.899,-733.5383;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-682.3481,-332.7642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;45;-1174.72,-405.6822;Inherit;False;0;37;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;86;-563.1436,-332.9573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-388.7257,-529.1472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;84;-207.4306,-339.4124;Inherit;True;Property;_UseFix;启用边缘修复;6;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-836.4846,26.17764;Inherit;True;Property;_MainTex;序列帧图集;0;1;[Header];Create;False;1;FlipBookTex;0;0;False;0;False;-1;None;68073cd98bb6f554cbe77ff4e194b96a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;17;-708.3607,214.4387;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-967.3883,-429.3057;Inherit;True;Property;_Mask;遮罩贴图;4;1;[Header];Create;False;1;MaskTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-210.2978,274.6622;Inherit;False;Property;_DepthFade;软粒子;8;1;[Header];Create;False;1;DepthFade;0;0;False;0;False;1;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-950.2841,-239.4727;Inherit;False;Property;_MaskMult;遮罩强度;5;0;Create;False;0;0;0;False;0;False;0;1;0.01;2;0;1;FLOAT;0
WireConnection;18;0;19;0
WireConnection;21;0;18;0
WireConnection;0;2;22;0
WireConnection;22;0;84;0
WireConnection;22;1;20;0
WireConnection;22;2;21;0
WireConnection;4;0;5;0
WireConnection;3;0;4;0
WireConnection;3;1;90;1
WireConnection;3;2;90;2
WireConnection;3;3;90;3
WireConnection;3;4;90;4
WireConnection;3;5;10;0
WireConnection;46;0;16;1
WireConnection;46;1;16;2
WireConnection;46;2;16;3
WireConnection;44;1;16;1
WireConnection;44;0;16;4
WireConnection;20;0;23;0
WireConnection;20;1;46;0
WireConnection;20;2;17;0
WireConnection;20;3;44;0
WireConnection;52;0;56;2
WireConnection;87;0;56;1
WireConnection;89;0;55;1
WireConnection;53;0;55;2
WireConnection;88;0;87;0
WireConnection;51;0;52;0
WireConnection;69;0;88;0
WireConnection;69;1;51;0
WireConnection;69;2;89;0
WireConnection;69;3;53;0
WireConnection;69;4;77;0
WireConnection;83;0;69;0
WireConnection;38;0;37;1
WireConnection;38;1;39;0
WireConnection;86;0;38;0
WireConnection;85;0;83;0
WireConnection;85;1;86;0
WireConnection;84;1;86;0
WireConnection;84;0;85;0
WireConnection;16;1;3;0
WireConnection;37;1;45;0
ASEEND*/
//CHKSM=19EB200491BAB7D8C2AF41FA1CE2D94BAC029C00