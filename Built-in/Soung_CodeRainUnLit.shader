// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/代码雨_UnLit"
{
	Properties
	{
		[Header(FlowTex)]_CodeTex("流动纹理", 2D) = "white" {}
		_CodeSSpeed("流动纹理变化速度", Float) = 3
		[HDR]_CodeColor("流动纹理颜色", Color) = (1,1,1,1)
		_MaskTex("流动遮罩", 2D) = "white" {}
		_MaskClipValue("流动分形数量", Float) = 8
		_HighlightSize("高光范围", Float) = 1.5
		[HDR]_HighlightColor("高光颜色", Color) = (0,1,0.04867458,1)
		[Header(BackgroundTex)]_BackgroundTex("背景图", 2D) = "white" {}
		_BGMixDegree("背景图混合度", Range( 0 , 1)) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 4.5
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _CodeTex;
			uniform float _MaskClipValue;
			uniform float _CodeSSpeed;
			uniform sampler2D _MaskTex;
			uniform float4 _CodeColor;
			uniform float _HighlightSize;
			uniform float4 _HighlightColor;
			uniform float _BGMixDegree;
			uniform sampler2D _BackgroundTex;
			uniform float4 _BackgroundTex_ST;
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
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 temp_cast_0 = (_MaskClipValue).xx;
				float2 texCoord3 = i.ase_texcoord1.xy * temp_cast_0 + float2( 0,0 );
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles5 = _MaskClipValue * _MaskClipValue;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset5 = 1.0f / _MaskClipValue;
				float fbrowsoffset5 = 1.0f / _MaskClipValue;
				// Speed of animation
				float fbspeed5 = _Time.y * _CodeSSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling5 = float2(fbcolsoffset5, fbrowsoffset5);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex5 = round( fmod( fbspeed5 + 0.0, fbtotaltiles5) );
				fbcurrenttileindex5 += ( fbcurrenttileindex5 < 0) ? fbtotaltiles5 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox5 = round ( fmod ( fbcurrenttileindex5, _MaskClipValue ) );
				// Multiply Offset X by coloffset
				float fboffsetx5 = fblinearindextox5 * fbcolsoffset5;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy5 = round( fmod( ( fbcurrenttileindex5 - fblinearindextox5 ) / _MaskClipValue, _MaskClipValue ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy5 = (int)(_MaskClipValue-1) - fblinearindextoy5;
				// Multiply Offset Y by rowoffset
				float fboffsety5 = fblinearindextoy5 * fbrowsoffset5;
				// UV Offset
				float2 fboffset5 = float2(fboffsetx5, fboffsety5);
				// Flipbook UV
				half2 fbuv5 = texCoord3 * fbtiling5 + fboffset5;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode1 = tex2D( _CodeTex, fbuv5 );
				float2 texCoord11 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth12 =  1.0f / _MaskClipValue;
				float pixelHeight12 = 1.0f / 1.0;
				half2 pixelateduv12 = half2((int)(texCoord11.x / pixelWidth12) * pixelWidth12, (int)(texCoord11.y / pixelHeight12) * pixelHeight12);
				float simplePerlin2D13 = snoise( pixelateduv12*5.0 );
				simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
				float2 temp_cast_1 = (simplePerlin2D13).xx;
				float2 panner16 = ( 1.0 * _Time.y * temp_cast_1 + texCoord11);
				float4 tex2DNode9 = tex2D( _MaskTex, panner16 );
				float2 uv_BackgroundTex = i.ase_texcoord1.xy * _BackgroundTex_ST.xy + _BackgroundTex_ST.zw;
				
				
				finalColor = ( ( ( ( tex2DNode1 * tex2DNode9 * _CodeColor ) + ( tex2DNode1 * floor( ( tex2DNode9 * _HighlightSize ) ) * _HighlightColor ) ) * _BGMixDegree ) + ( ( 1.0 - _BGMixDegree ) * tex2D( _BackgroundTex, uv_BackgroundTex ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-948.8376,247.0522;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-870.2384,364.18;Inherit;False;Constant;_PixelsY;PixelsY;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCPixelate;12;-701.2384,321.18;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-500.2384,315.18;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-670.2384,439.18;Inherit;False;Constant;_NoiseScale;NoiseScale;2;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;16;-263.2384,245.18;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;9;-90.83781,216.5521;Inherit;True;Property;_MaskTex;流动遮罩;3;0;Create;False;0;0;0;False;0;False;-1;None;c138005c997604047902040a864e8aca;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;52.19689,409.3794;Inherit;False;Property;_HighlightSize;高光范围;5;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;209.1391,271.1563;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;22;333.2079,272.2281;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;25;296.4504,487.7163;Inherit;False;Property;_HighlightColor;高光颜色;6;1;[HDR];Create;False;0;0;0;False;0;False;0,1,0.04867458,1;0,1,0.04867458,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;506.9746,247.7176;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;18;-1.418701,38.14349;Inherit;False;Property;_CodeColor;流动纹理颜色;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;5;-516.4717,-17.45305;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-785.7001,-17.23658;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-947.4679,79.547;Inherit;False;Property;_MaskClipValue;流动分形数量;4;0;Create;False;0;0;0;False;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-758.7756,101.7295;Inherit;False;Property;_CodeSSpeed;流动纹理变化速度;1;0;Create;False;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-740.7756,179.7295;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;270.815,-40.63731;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;711.5579,135.222;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;508.1252,460.0491;Inherit;False;Property;_BGMixDegree;背景图混合度;8;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;961.085,440.748;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;32;956.953,539.7192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;1106.499,539.7942;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;610.2354,634.0397;Inherit;False;0;29;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;30;1242.121,516.562;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1440.776,516.3726;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/代码雨_UnLit;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;29;819.6283,610.1526;Inherit;True;Property;_BackgroundTex;背景图;7;1;[Header];Create;False;1;BackgroundTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-297.1377,-45.40283;Inherit;True;Property;_CodeTex;流动纹理;0;1;[Header];Create;False;1;FlowTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;12;0;11;0
WireConnection;12;1;6;0
WireConnection;12;2;15;0
WireConnection;13;0;12;0
WireConnection;13;1;14;0
WireConnection;16;0;11;0
WireConnection;16;2;13;0
WireConnection;9;1;16;0
WireConnection;20;0;9;0
WireConnection;20;1;21;0
WireConnection;22;0;20;0
WireConnection;24;0;1;0
WireConnection;24;1;22;0
WireConnection;24;2;25;0
WireConnection;5;0;3;0
WireConnection;5;1;6;0
WireConnection;5;2;6;0
WireConnection;5;3;7;0
WireConnection;5;5;8;0
WireConnection;3;0;6;0
WireConnection;17;0;1;0
WireConnection;17;1;9;0
WireConnection;17;2;18;0
WireConnection;26;0;17;0
WireConnection;26;1;24;0
WireConnection;31;0;26;0
WireConnection;31;1;27;0
WireConnection;32;0;27;0
WireConnection;33;0;32;0
WireConnection;33;1;29;0
WireConnection;30;0;31;0
WireConnection;30;1;33;0
WireConnection;0;0;30;0
WireConnection;29;1;34;0
WireConnection;1;1;5;0
ASEEND*/
//CHKSM=B82F7B15B514591BD81640000546611BC2583BF0