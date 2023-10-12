// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/简单序列帧材质_Addtive"
{
	Properties
	{
		_MainTex("主帖图", 2D) = "white" {}
		[HDR]_MainColor1("颜色", Color) = (0.6132076,0.6132076,0.6132076,0.5333334)
		[Enum(R,1,A,0)]_RASwitch("贴图通道切换", Float) = 1
		_FlipU("横向数量", Float) = 3
		_FlipV("纵向数量", Float) = 3
		_FlipSpeed("动画速率", Float) = 3
		_DepthFade("深度消隐", Range( 0 , 100)) = 1
		_Mask("遮罩", 2D) = "white" {}
		_MaskMult("遮罩强度", Float) = 0
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

		uniform float4 _MainColor1;
		uniform sampler2D _MainTex;
		uniform float _FlipU;
		uniform float _FlipV;
		uniform float _FlipSpeed;
		uniform float _RASwitch;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _MaskMult;
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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth18 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth18 = abs( ( screenDepth18 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			o.Emission = ( ( _MainColor1 * tex2DNode16 * _MainColor1.a * i.vertexColor * ( ( _RASwitch * tex2DNode16.r ) + ( tex2DNode16.a * ( 1.0 - _RASwitch ) ) ) ) * saturate( ( tex2D( _Mask, uv_Mask ).r * _MaskMult ) ) * saturate( distanceDepth18 ) ).rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;43;314.7648,471.6049;Inherit;False;617;133;深度消隐;3;19;21;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-1504.077,-241.407;Inherit;False;671.853;557.815;序列帧动画/UV动画实现;7;10;9;8;7;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;3;-1075.28,43.19951;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1476.806,-64.94623;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-1239.518,3.940399;Inherit;False;Property;_FlipU;FlipU;3;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1236.815,81.49179;Inherit;False;Property;_FlipV;FlipV;4;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1241.07,153.3594;Inherit;False;Property;_FlipSpeed;FlipSpeed;5;0;Create;True;0;0;0;False;0;False;3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1261.157,232.0614;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;4;-1257.68,-206.7576;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;23;-765.5806,-263.0261;Inherit;False;Property;_MainColor1;Main Color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.6132076,0.6132076,0.6132076,0.5333334;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-782.5845,-19.12237;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;-1;78b20f2461fab944d98c9f7f4b44695e;78b20f2461fab944d98c9f7f4b44695e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;84.66501,-323.1465;Inherit;True;Property;_Mask;Mask;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;229.7689,-128.3144;Inherit;False;Property;_MaskMult;MaskMult;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;381.7038,-229.605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;42;549.4064,-177.9337;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-497.4029,80.5041;Inherit;False;Property;_RASwitch;R/A Switch;2;1;[Enum];Create;True;0;2;R;1;A;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-479.2061,166.4702;Inherit;False;Constant;_Int1;Int1;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-112.5016,91.7403;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-320.2061,170.4702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-321.7734,47.27792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;66.07198,47.65217;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;17;154.4879,297.6146;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;367.6672,-49.51519;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;18;581.5776,511.1667;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;809.2781,511.3423;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;323.5546,529.2316;Inherit;False;Property;_DepthFade;Depth Fade;6;0;Create;True;0;0;0;False;0;False;1;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1168.064,75.9181;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;VFX/Flip Add;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;7;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;954.2391,171.3615;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
WireConnection;3;0;4;0
WireConnection;3;1;7;0
WireConnection;3;2;8;0
WireConnection;3;3;9;0
WireConnection;3;5;10;0
WireConnection;4;0;5;0
WireConnection;16;1;3;0
WireConnection;38;0;37;1
WireConnection;38;1;39;0
WireConnection;42;0;38;0
WireConnection;28;0;16;4
WireConnection;28;1;30;0
WireConnection;30;0;29;0
WireConnection;30;1;24;0
WireConnection;25;0;24;0
WireConnection;25;1;16;1
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;20;0;23;0
WireConnection;20;1;16;0
WireConnection;20;2;23;4
WireConnection;20;3;17;0
WireConnection;20;4;27;0
WireConnection;18;0;19;0
WireConnection;21;0;18;0
WireConnection;0;2;22;0
WireConnection;22;0;20;0
WireConnection;22;1;42;0
WireConnection;22;2;21;0
ASEEND*/
//CHKSM=006AFF4EE8C9FC0BBDBA5ADA258105C68F40A03F