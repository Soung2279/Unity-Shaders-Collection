// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/雨天地面"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_MainColo("Main Colo", Color) = (1,0.3342985,0.3342985,0)
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalScale("NormalScale", Float) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smothness("Smothness", Range( 0 , 1)) = 1
		_RainNormal("RainNormal", 2D) = "white" {}
		_FlipU("FlipU", Float) = 4
		_FlipV("FlipV", Float) = 4
		_FlipSpeed("FlipSpeed", Float) = 2
		_WaterNormalStr("WaterNormalStr", Float) = 1
		_NormalOffset("NormalOffset", Float) = 0.01
		_MaskTiling("MaskTiling", Float) = -4.56
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv2_texcoord2;
			float2 uv_texcoord;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalScale;
		uniform sampler2D _RainNormal;
		uniform float4 _RainNormal_ST;
		uniform float _FlipU;
		uniform float _FlipV;
		uniform float _FlipSpeed;
		uniform float _NormalOffset;
		uniform float _WaterNormalStr;
		uniform float _MaskTiling;
		uniform float4 _MainColo;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Metallic;
		uniform float _Smothness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv1_NormalMap = i.uv2_texcoord2 * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float2 uv_RainNormal = i.uv_texcoord * _RainNormal_ST.xy + _RainNormal_ST.zw;
			float mulTime49 = _Time.y * 5.0;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles44 = _FlipU * _FlipV;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset44 = 1.0f / _FlipU;
			float fbrowsoffset44 = 1.0f / _FlipV;
			// Speed of animation
			float fbspeed44 = mulTime49 * _FlipSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling44 = float2(fbcolsoffset44, fbrowsoffset44);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex44 = round( fmod( fbspeed44 + 0.0, fbtotaltiles44) );
			fbcurrenttileindex44 += ( fbcurrenttileindex44 < 0) ? fbtotaltiles44 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox44 = round ( fmod ( fbcurrenttileindex44, _FlipU ) );
			// Multiply Offset X by coloffset
			float fboffsetx44 = fblinearindextox44 * fbcolsoffset44;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy44 = round( fmod( ( fbcurrenttileindex44 - fblinearindextox44 ) / _FlipU, _FlipV ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy44 = (int)(_FlipV-1) - fblinearindextoy44;
			// Multiply Offset Y by rowoffset
			float fboffsety44 = fblinearindextoy44 * fbrowsoffset44;
			// UV Offset
			float2 fboffset44 = float2(fboffsetx44, fboffsety44);
			// Flipbook UV
			half2 fbuv44 = frac( uv_RainNormal ) * fbtiling44 + fboffset44;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode11 = tex2D( _RainNormal, fbuv44 );
			float4 appendResult72 = (float4(_NormalOffset , 0.0 , 0.0 , 0.0));
			float2 temp_cast_2 = (_MaskTiling).xx;
			float2 temp_cast_3 = (( _Time.y * 2.0 )).xx;
			float2 uv_TexCoord84 = i.uv_texcoord * temp_cast_2 + temp_cast_3;
			float simplePerlin2D85 = snoise( uv_TexCoord84 );
			simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
			float2 temp_cast_4 = (_MaskTiling).xx;
			float2 temp_cast_5 = (( _Time.y * 0.5 )).xx;
			float2 uv_TexCoord88 = i.uv_texcoord * temp_cast_4 + temp_cast_5;
			float simplePerlin2D89 = snoise( uv_TexCoord88 );
			simplePerlin2D89 = simplePerlin2D89*0.5 + 0.5;
			float temp_output_90_0 = ( simplePerlin2D85 + simplePerlin2D89 );
			float4 appendResult69 = (float4(1.0 , 0.0 , ( ( tex2DNode11.r - tex2D( _RainNormal, ( float4( fbuv44, 0.0 , 0.0 ) + appendResult72 ).xy ).r ) * _WaterNormalStr * temp_output_90_0 ) , 0.0));
			float4 appendResult73 = (float4(0.0 , _NormalOffset , 0.0 , 0.0));
			float4 appendResult70 = (float4(0.0 , 1.0 , ( _WaterNormalStr * ( tex2DNode11.r - tex2D( _RainNormal, ( float4( fbuv44, 0.0 , 0.0 ) + appendResult73 ).xy ).r ) * temp_output_90_0 ) , 0.0));
			o.Normal = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, uv1_NormalMap ), _NormalScale ) , cross( appendResult69.xyz , appendResult70.xyz ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( _MainColo * tex2D( _MainTex, uv_MainTex ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;98;-819.425,-320.9898;Inherit;False;1330.583;494.9424;制作遮罩，强化涟漪随机感;9;90;95;96;87;94;85;84;88;89;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-1225.05,204.4835;Inherit;False;1051.832;532.6508;序列帧动画/UV动画实现涟漪;9;31;82;50;46;45;57;44;11;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;60;-787.3969,764.5496;Inherit;False;839.6603;491.098;利用偏移量制作法线贴图///上偏移-左偏移;7;63;61;59;58;72;73;76;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;11;-481.9907,479.8051;Inherit;True;Property;_Subs_1197;Subs_1197;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-261.2646,1029.29;Inherit;True;Property;_Subs_1;Subs_1197;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-407.9319,894.0398;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-402.9865,1071.08;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-569.7066,892.0266;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-569.8521,1053.08;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-758.7079,1019.041;Inherit;False;Property;_NormalOffset;NormalOffset;11;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1580.299,56.16944;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;A201-Shader/个人制作/雨天地面;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;7;1236.733,187.7758;Inherit;False;Property;_Smothness;Smothness;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;1235.531,104.1555;Inherit;False;Property;_Metallic;Metallic;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-261.2646,822.7651;Inherit;True;Property;_Subs_;Subs_1197;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;83;1241.834,350.8917;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;138.8801,521.4023;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;134.0796,860.3318;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;713.736,793.0372;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CrossProductOpNode;68;976.4553,665.6936;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;714.5599,569.9528;Inherit;True;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;516.5151,508.1977;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;517.8604,758.3615;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;44;-796.2534,489.0899;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;82;-978.6534,241.733;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-1197.779,380.944;Inherit;True;0;57;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;57;-682.9899,258.9783;Inherit;True;Property;_RainNormal;RainNormal;6;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;45;-960.4909,449.8307;Inherit;False;Property;_FlipU;FlipU;7;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-957.7879,527.3822;Inherit;False;Property;_FlipV;FlipV;8;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-962.0428,599.2497;Inherit;False;Property;_FlipSpeed;FlipSpeed;9;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;49;-984.7302,668.8517;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-230.5172,-259.34;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;85;-7.017213,-265.3399;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;94;-758.7015,-45.35862;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;237.1272,-114.3083;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;89;-92.92961,-62.96992;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;739.0876,427.4346;Inherit;False;Property;_NormalScale;NormalScale;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;909.7953,347.6079;Inherit;True;Property;_NormalMap;Normal Map;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;292.4241,749.5715;Inherit;False;Property;_WaterNormalStr;WaterNormalStr;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;1304.054,-218.4881;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;982.8035,-111.9434;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;103;1058.077,-295.5719;Inherit;False;Property;_MainColo;Main Colo;1;0;Create;True;0;0;0;False;0;False;1,0.3342985,0.3342985,0;1,0.3342984,0.3342984,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-572.9254,-18.27884;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-574.8359,-133.8666;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-435.0667,-88.77753;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;87;-591.7578,-229.7188;Inherit;False;Property;_MaskTiling;MaskTiling;12;0;Create;True;0;0;0;False;0;False;-4.56;-4.56;0;0;0;1;FLOAT;0
WireConnection;11;0;57;0
WireConnection;11;1;44;0
WireConnection;59;0;57;0
WireConnection;59;1;63;0
WireConnection;61;0;44;0
WireConnection;61;1;72;0
WireConnection;63;0;44;0
WireConnection;63;1;73;0
WireConnection;72;0;76;0
WireConnection;73;1;76;0
WireConnection;0;0;105;0
WireConnection;0;1;83;0
WireConnection;0;3;5;0
WireConnection;0;4;7;0
WireConnection;58;0;57;0
WireConnection;58;1;61;0
WireConnection;83;0;2;0
WireConnection;83;1;68;0
WireConnection;65;0;11;1
WireConnection;65;1;58;1
WireConnection;66;0;11;1
WireConnection;66;1;59;1
WireConnection;70;2;78;0
WireConnection;68;0;69;0
WireConnection;68;1;70;0
WireConnection;69;2;77;0
WireConnection;77;0;65;0
WireConnection;77;1;79;0
WireConnection;77;2;90;0
WireConnection;78;0;79;0
WireConnection;78;1;66;0
WireConnection;78;2;90;0
WireConnection;44;0;82;0
WireConnection;44;1;45;0
WireConnection;44;2;46;0
WireConnection;44;3;50;0
WireConnection;44;5;49;0
WireConnection;82;0;31;0
WireConnection;84;0;87;0
WireConnection;84;1;95;0
WireConnection;85;0;84;0
WireConnection;90;0;85;0
WireConnection;90;1;89;0
WireConnection;89;0;88;0
WireConnection;2;5;102;0
WireConnection;105;0;103;0
WireConnection;105;1;9;0
WireConnection;96;0;94;0
WireConnection;95;0;94;0
WireConnection;88;0;87;0
WireConnection;88;1;96;0
ASEEND*/
//CHKSM=2261C658CEE586038418B23C911093FCF264AC53