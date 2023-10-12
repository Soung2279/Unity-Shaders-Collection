// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/简单序列帧材质_AlphaB"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		[HDR]_MainColor1("颜色", Color) = (0.6132076,0.6132076,0.6132076,0.5333334)
		[Enum(R,1,A,0)]_RASwitch("贴图通道切换", Float) = 1
		_FlipU("横向数量", Float) = 3
		_FlipV("纵向数量", Float) = 3
		_FlipSpeed("动画速率", Float) = 2
		_Mask("遮罩", 2D) = "white" {}
		_MaskMult("遮罩强度", Float) = 0
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
		uniform float _FlipU;
		uniform float _FlipV;
		uniform float _FlipSpeed;
		uniform float _RASwitch;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _MaskMult;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float mulTime10 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles3 = _FlipU * _FlipV;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset3 = 1.0f / _FlipU;
			float fbrowsoffset3 = 1.0f / _FlipV;
			// Speed of animation
			float fbspeed3 = mulTime10 * _FlipSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling3 = float2(fbcolsoffset3, fbrowsoffset3);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex3 = round( fmod( fbspeed3 + 0.0, fbtotaltiles3) );
			fbcurrenttileindex3 += ( fbcurrenttileindex3 < 0) ? fbtotaltiles3 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox3 = round ( fmod ( fbcurrenttileindex3, _FlipU ) );
			// Multiply Offset X by coloffset
			float fboffsetx3 = fblinearindextox3 * fbcolsoffset3;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy3 = round( fmod( ( fbcurrenttileindex3 - fblinearindextox3 ) / _FlipU, _FlipV ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy3 = (int)(_FlipV-1) - fblinearindextoy3;
			// Multiply Offset Y by rowoffset
			float fboffsety3 = fblinearindextoy3 * fbrowsoffset3;
			// UV Offset
			float2 fboffset3 = float2(fboffsetx3, fboffsety3);
			// Flipbook UV
			half2 fbuv3 = frac( i.uv_texcoord ) * fbtiling3 + fboffset3;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode16 = tex2D( _MainTex, fbuv3 );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			c.rgb = 0;
			c.a = ( ( i.vertexColor.a * _MainColor1.a * ( ( _RASwitch * tex2DNode16.r ) + ( tex2DNode16.a * ( 1.0 - _RASwitch ) ) ) ) * saturate( ( tex2D( _Mask, uv_Mask ) * _MaskMult ) ) ).r;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float mulTime10 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles3 = _FlipU * _FlipV;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset3 = 1.0f / _FlipU;
			float fbrowsoffset3 = 1.0f / _FlipV;
			// Speed of animation
			float fbspeed3 = mulTime10 * _FlipSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling3 = float2(fbcolsoffset3, fbrowsoffset3);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex3 = round( fmod( fbspeed3 + 0.0, fbtotaltiles3) );
			fbcurrenttileindex3 += ( fbcurrenttileindex3 < 0) ? fbtotaltiles3 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox3 = round ( fmod ( fbcurrenttileindex3, _FlipU ) );
			// Multiply Offset X by coloffset
			float fboffsetx3 = fblinearindextox3 * fbcolsoffset3;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy3 = round( fmod( ( fbcurrenttileindex3 - fblinearindextox3 ) / _FlipU, _FlipV ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy3 = (int)(_FlipV-1) - fblinearindextoy3;
			// Multiply Offset Y by rowoffset
			float fboffsety3 = fblinearindextoy3 * fbrowsoffset3;
			// UV Offset
			float2 fboffset3 = float2(fboffsetx3, fboffsety3);
			// Flipbook UV
			half2 fbuv3 = frac( i.uv_texcoord ) * fbtiling3 + fboffset3;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode16 = tex2D( _MainTex, fbuv3 );
			o.Emission = ( _MainColor1 * tex2DNode16 * i.vertexColor ).rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;2;-1076.13,-190.9187;Inherit;False;671.853;557.815;序列帧动画/UV动画实现;7;10;9;8;7;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;23;-311.6331,-120.5378;Inherit;False;Property;_MainColor1;Main Color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.6132076,0.6132076,0.6132076,0.5333334;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;605.7535,-84.83956;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;3;-647.3322,93.68777;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;16;-371.9231,65.93799;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;-1;78b20f2461fab944d98c9f7f4b44695e;78b20f2461fab944d98c9f7f4b44695e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;17;401.9341,51.31742;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;10;-833.2099,282.5497;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-820.5706,57.42863;Inherit;False;Property;_FlipU;FlipU;3;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-817.8676,134.9801;Inherit;False;Property;_FlipV;FlipV;4;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-822.1226,206.8477;Inherit;False;Property;_FlipSpeed;FlipSpeed;5;0;Create;True;0;0;0;False;0;False;2;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;4;-829.7332,-156.2693;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1052.859,-17.45798;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;200.4149,205.5433;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;220.1555,317.7524;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;94.93967,384.9271;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-16.60107,292.0092;Inherit;False;Property;_RASwitch;R/A Switch;2;1;[Enum];Create;True;0;2;R;1;A;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;377.715,285.1435;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-60.44806,387.7117;Inherit;False;Constant;_AlphaMult;AlphaMult;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;633.2066,245.4836;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;337.8567,472.7736;Inherit;True;Property;_Mask;Mask;7;0;Create;True;0;0;0;False;0;False;-1;None;8c4a7fca2884fab419769ccc0355c0c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;652.1528,565.0208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;33;483.8521,667.4331;Inherit;False;Property;_MaskMult;MaskMult;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;924.7625,357.3772;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1133.202,48.80861;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;VFX/Flip AlphaBlend;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;6;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SaturateNode;38;785.1173,539.0854;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;20;0;23;0
WireConnection;20;1;16;0
WireConnection;20;2;17;0
WireConnection;3;0;4;0
WireConnection;3;1;7;0
WireConnection;3;2;8;0
WireConnection;3;3;9;0
WireConnection;3;5;10;0
WireConnection;16;1;3;0
WireConnection;4;0;5;0
WireConnection;25;0;24;0
WireConnection;25;1;16;1
WireConnection;28;0;16;4
WireConnection;28;1;30;0
WireConnection;30;0;29;0
WireConnection;30;1;24;0
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;31;0;17;4
WireConnection;31;1;23;4
WireConnection;31;2;27;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;36;0;31;0
WireConnection;36;1;38;0
WireConnection;0;2;20;0
WireConnection;0;9;36;0
WireConnection;38;0;34;0
ASEEND*/
//CHKSM=0E90C7A1E4343A9F8F64A06D68BFBB3D8D4326DC