// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/序列帧材质"
{
	Properties
	{
		_MainTex("序列帧图集", 2D) = "white" {}
		_Filpval("横纵数量-速度-起始帧", Vector) = (4,4,3,0)
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[HDR]_MainColor1("主颜色", Color) = (1,1,1,1)
		[Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1
		_Fixval("修复阈值 (建议默认)", Range( 1 , 200)) = 200
		[Enum(R,0,A,1)]_SwithcTexP("贴图通道切换", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 4.5
		ENDCG
		Blend SrcAlpha [_BlendMode]
		AlphaToMask Off
		Cull [_CullingMode]
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
			#define ASE_NEEDS_FRAG_COLOR


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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullingMode;
			uniform float _BlendMode;
			uniform float _Fixval;
			uniform float4 _MainColor1;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Filpval;
			uniform float _SwithcTexP;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
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
				float2 texCoord41 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord42 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
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
				float lerpResult62 = lerp( tex2DNode16.r , tex2DNode16.a , _SwithcTexP);
				float4 appendResult64 = (float4((( saturate( ( ( 1.0 - saturate( texCoord41.x ) ) * ( 1.0 - saturate( texCoord41.y ) ) * saturate( texCoord42.x ) * saturate( texCoord42.y ) * _Fixval ) ) * _MainColor1 * tex2DNode16 * i.ase_color )).rgb , ( _MainColor1.a * lerpResult62 * i.ase_color.a )));
				
				
				finalColor = (appendResult64).xyzw;
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
Node;AmplifyShaderEditor.CommentaryNode;2;-1217.076,-94.9817;Inherit;False;895.8669;424.9827;利用FlipBook节点实现UV动画;9;63;16;5;10;3;4;39;61;60;序列帧动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;39;-1187.619,76.00105;Inherit;False;Property;_Filpval;横纵数量-速度-起始帧;1;0;Create;False;0;0;0;False;0;False;4,4,3,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;4;-985.9224,-39.40588;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;3;-842.5806,80.01262;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1049.014,250.3728;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1217.292,-432.5141;Inherit;False;949.1721;309.5532;利用程序遮罩修复FlipBook出现的切边;11;51;50;49;48;47;46;45;44;43;42;41;修复遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;43;-975.8608,-322.2154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-976.5638,-390.7091;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-975.5638,-255.7093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;-974.9709,-189.4721;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-850.5618,-392.7091;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;48;-849.8588,-323.2154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-590.5342,-342.5231;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;51;-395.8194,-342.6197;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1190.68,-45.85715;Inherit;False;0;16;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-606.9231,50.93799;Inherit;True;Property;_MainTex;序列帧图集;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-851.2488,-251.5474;Inherit;False;Property;_Fixval;修复阈值 (建议默认);5;0;Create;False;0;0;0;False;0;False;200;25;1;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;62;-300.3052,127.9194;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-475.705,240.7194;Inherit;False;Property;_SwithcTexP;贴图通道切换;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-604.4438,-41.63666;Inherit;False;Property;_BlendMode;混合模式;4;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-463.9806,-40.42035;Inherit;False;Property;_CullingMode;剔除模式;2;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-49.97579,8.474356;Inherit;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;-305.2325,-75.43822;Inherit;False;Property;_MainColor1;主颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;17;-303.2951,248.1317;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;65;153.3945,3.61936;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;339.1953,8.619379;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-48.2225,223.0971;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;57;650.9546,8.27742;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/序列帧材质;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ComponentMaskNode;66;468.2955,3.519362;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1188.973,-258.4727;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1187.863,-377.2141;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;4;0;5;0
WireConnection;3;0;4;0
WireConnection;3;1;39;1
WireConnection;3;2;39;2
WireConnection;3;3;39;3
WireConnection;3;4;39;4
WireConnection;3;5;10;0
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
WireConnection;16;1;3;0
WireConnection;62;0;16;1
WireConnection;62;1;16;4
WireConnection;62;2;63;0
WireConnection;20;0;51;0
WireConnection;20;1;23;0
WireConnection;20;2;16;0
WireConnection;20;3;17;0
WireConnection;65;0;20;0
WireConnection;64;0;65;0
WireConnection;64;3;31;0
WireConnection;31;0;23;4
WireConnection;31;1;62;0
WireConnection;31;2;17;4
WireConnection;57;0;66;0
WireConnection;66;0;64;0
ASEEND*/
//CHKSM=01C545B8BD3147044D1BFBC7CA026D67B66ABD3D