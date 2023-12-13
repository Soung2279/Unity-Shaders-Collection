// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/序列帧材质_Blend"
{
	Properties
	{
		_MainTex("序列帧图集", 2D) = "white" {}
		[KeywordEnum(R,A)] _SwitchP("切换贴图通道", Float) = 0
		_Filpval("横纵数量-速度-起始帧", Vector) = (4,4,3,0)
		[HDR]_MainColor1("主颜色", Color) = (1,1,1,0.5019608)
		_Mask("遮罩贴图", 2D) = "white" {}
		_MaskMult("遮罩强度", Range( 0.01 , 3)) = 2
		[Toggle(_FIXSWIT_ON)] _FixSwit("启用边缘修复", Float) = 0
		_Fixval("修复阈值 (建议默认)", Range( 1 , 200)) = 150
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma shader_feature_local _FIXSWIT_ON
		#pragma shader_feature_local _SWITCHP_R _SWITCHP_A
		#pragma surface surf StandardCustomLighting keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
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

		uniform float4 _MainColor1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Filpval;
		uniform float _Fixval;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _MaskMult;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float mulTime10 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles3 = _Filpval.x * _Filpval.y;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset3 = 1.0f / _Filpval.x;
			float fbrowsoffset3 = 1.0f / _Filpval.y;
			// Speed of animation
			float fbspeed3 = mulTime10 * _Filpval.z;
			// UV Tiling (col and row offset)
			float2 fbtiling3 = float2(fbcolsoffset3, fbrowsoffset3);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex3 = round( fmod( fbspeed3 + _Filpval.w, fbtotaltiles3) );
			fbcurrenttileindex3 += ( fbcurrenttileindex3 < 0) ? fbtotaltiles3 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox3 = round ( fmod ( fbcurrenttileindex3, _Filpval.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx3 = fblinearindextox3 * fbcolsoffset3;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy3 = round( fmod( ( fbcurrenttileindex3 - fblinearindextox3 ) / _Filpval.x, _Filpval.y ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy3 = (int)(_Filpval.y-1) - fblinearindextoy3;
			// Multiply Offset Y by rowoffset
			float fboffsety3 = fblinearindextoy3 * fbrowsoffset3;
			// UV Offset
			float2 fboffset3 = float2(fboffsetx3, fboffsety3);
			// Flipbook UV
			half2 fbuv3 = frac( uv_MainTex ) * fbtiling3 + fboffset3;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode16 = tex2D( _MainTex, fbuv3 );
			#if defined(_SWITCHP_R)
				float staticSwitch56 = tex2DNode16.r;
			#elif defined(_SWITCHP_A)
				float staticSwitch56 = tex2DNode16.a;
			#else
				float staticSwitch56 = tex2DNode16.r;
			#endif
			float temp_output_51_0 = saturate( ( ( 1.0 - saturate( i.uv_texcoord.x ) ) * ( 1.0 - saturate( i.uv_texcoord.y ) ) * saturate( i.uv_texcoord.x ) * saturate( i.uv_texcoord.y ) * _Fixval ) );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			#ifdef _FIXSWIT_ON
				float staticSwitch55 = ( saturate( ( tex2D( _Mask, uv_Mask ).r * _MaskMult ) ) * temp_output_51_0 );
			#else
				float staticSwitch55 = temp_output_51_0;
			#endif
			c.rgb = 0;
			c.a = ( staticSwitch56 * i.vertexColor.a * staticSwitch55 );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float mulTime10 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles3 = _Filpval.x * _Filpval.y;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset3 = 1.0f / _Filpval.x;
			float fbrowsoffset3 = 1.0f / _Filpval.y;
			// Speed of animation
			float fbspeed3 = mulTime10 * _Filpval.z;
			// UV Tiling (col and row offset)
			float2 fbtiling3 = float2(fbcolsoffset3, fbrowsoffset3);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex3 = round( fmod( fbspeed3 + _Filpval.w, fbtotaltiles3) );
			fbcurrenttileindex3 += ( fbcurrenttileindex3 < 0) ? fbtotaltiles3 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox3 = round ( fmod ( fbcurrenttileindex3, _Filpval.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx3 = fblinearindextox3 * fbcolsoffset3;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy3 = round( fmod( ( fbcurrenttileindex3 - fblinearindextox3 ) / _Filpval.x, _Filpval.y ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy3 = (int)(_Filpval.y-1) - fblinearindextoy3;
			// Multiply Offset Y by rowoffset
			float fboffsety3 = fblinearindextoy3 * fbrowsoffset3;
			// UV Offset
			float2 fboffset3 = float2(fboffsetx3, fboffsety3);
			// Flipbook UV
			half2 fbuv3 = frac( uv_MainTex ) * fbtiling3 + fboffset3;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode16 = tex2D( _MainTex, fbuv3 );
			float temp_output_51_0 = saturate( ( ( 1.0 - saturate( i.uv_texcoord.x ) ) * ( 1.0 - saturate( i.uv_texcoord.y ) ) * saturate( i.uv_texcoord.x ) * saturate( i.uv_texcoord.y ) * _Fixval ) );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			#ifdef _FIXSWIT_ON
				float staticSwitch55 = ( saturate( ( tex2D( _Mask, uv_Mask ).r * _MaskMult ) ) * temp_output_51_0 );
			#else
				float staticSwitch55 = temp_output_51_0;
			#endif
			o.Emission = ( _MainColor1 * tex2DNode16 * i.vertexColor * staticSwitch55 ).rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;53;-1021.9,-810.2963;Inherit;False;763.5814;315.0896;遮罩贴图;5;38;34;33;52;32;叠加遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-1013.076,-92.9817;Inherit;False;596.8669;424.9827;利用FlipBook节点实现UV动画;5;10;3;5;4;39;序列帧动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;39;-983.6185,78.00105;Inherit;False;Property;_Filpval;横纵数量-速度-起始帧;2;0;Create;False;0;0;0;False;0;False;4,4,3,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;4;-781.9224,-37.40588;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;3;-638.5806,82.01262;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-845.014,252.3728;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-398.9231,52.93799;Inherit;True;Property;_MainTex;序列帧图集;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;40;-1018.092,-447.014;Inherit;False;949.1721;309.5532;利用程序遮罩修复FlipBook出现的切边;11;51;50;49;48;47;46;45;44;43;42;41;修复遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-988.6629,-391.714;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-989.7729,-272.9727;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;43;-776.6608,-336.7153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-777.3638,-405.209;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-776.3638,-270.2092;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;-775.7709,-203.9721;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-651.3618,-407.209;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;48;-650.6588,-337.7153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-651.0488,-267.0473;Inherit;False;Property;_Fixval;修复阈值 (建议默认);7;0;Create;False;0;0;0;False;0;False;150;25;1;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-391.3343,-357.023;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;51;-196.6195,-357.1196;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-986.6805,-43.85715;Inherit;False;0;16;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-808.8437,-763.2378;Inherit;True;Property;_Mask;遮罩贴图;4;0;Create;False;0;0;0;False;0;False;-1;None;8c4a7fca2884fab419769ccc0355c0c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1011.683,-739.9551;Inherit;False;0;32;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-788.8483,-577.5785;Inherit;False;Property;_MaskMult;遮罩强度;5;0;Create;False;0;0;0;False;0;False;2;1;0.01;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-512.5477,-668.9907;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;38;-391.5831,-666.9261;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-30.97968,-502.6753;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;55;96.93983,-496.9302;Inherit;False;Property;_FixSwit;启用边缘修复;6;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;56;-108.1047,125.0131;Inherit;False;Property;_SwitchP;切换贴图通道;1;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;23;-315.6331,-116.5378;Inherit;False;Property;_MainColor1;主颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0.5019608;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;294.7242,-73.42565;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;17;-273.0954,243.4314;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;103.7775,314.0971;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;500.7727,-121.2791;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;VFX/FlipBlend;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;8;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;5;0
WireConnection;3;0;4;0
WireConnection;3;1;39;1
WireConnection;3;2;39;2
WireConnection;3;3;39;3
WireConnection;3;4;39;4
WireConnection;3;5;10;0
WireConnection;16;1;3;0
WireConnection;43;0;41;2
WireConnection;44;0;41;1
WireConnection;45;0;42;1
WireConnection;46;0;42;2
WireConnection;47;0;44;0
WireConnection;48;0;43;0
WireConnection;50;0;47;0
WireConnection;50;1;48;0
WireConnection;50;2;45;0
WireConnection;50;3;46;0
WireConnection;50;4;49;0
WireConnection;51;0;50;0
WireConnection;32;1;52;0
WireConnection;34;0;32;1
WireConnection;34;1;33;0
WireConnection;38;0;34;0
WireConnection;54;0;38;0
WireConnection;54;1;51;0
WireConnection;55;1;51;0
WireConnection;55;0;54;0
WireConnection;56;1;16;1
WireConnection;56;0;16;4
WireConnection;20;0;23;0
WireConnection;20;1;16;0
WireConnection;20;2;17;0
WireConnection;20;3;55;0
WireConnection;31;0;56;0
WireConnection;31;1;17;4
WireConnection;31;2;55;0
WireConnection;0;2;20;0
WireConnection;0;9;31;0
ASEEND*/
//CHKSM=82052E02997DAFB8194B9F63C32124A73C8673F3