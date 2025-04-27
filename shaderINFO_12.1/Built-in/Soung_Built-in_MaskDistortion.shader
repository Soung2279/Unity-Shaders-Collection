// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/遮罩热扭曲"
{
	Properties
	{
		[Header(Distortion)]_NormalMap("法线贴图", 2D) = "white" {}
		_Distortionpower("扭曲强度", Range( 0 , 1)) = 0.5
		[Enum(Material,0,Custom1x,1)]_CustomNiu("扭曲强度模式", Float) = 0
		_NormalUs("扭曲U速度", Float) = 0
		_NormalVs("扭曲V速度", Float) = 0
		[Header(Mask)]_MaskTex("遮罩贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_MaskTex_A_R("遮罩贴图通道", Float) = 0
		[IntRange]_Mask_Tex_Rotator("遮罩贴图旋转", Range( 0 , 360)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		
		
		GrabPass{ }

		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif


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
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform sampler2D _NormalMap;
			uniform float _NormalUs;
			uniform float _NormalVs;
			uniform float4 _NormalMap_ST;
			uniform float _Distortionpower;
			uniform float _CustomNiu;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _Mask_Tex_Rotator;
			uniform float _MaskTex_A_R;
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
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
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
				float4 screenPos = i.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult108 = (float2(_NormalUs , _NormalVs));
				float2 uv_NormalMap = i.ase_texcoord2.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float2 panner107 = ( 1.0 * _Time.y * appendResult108 + uv_NormalMap);
				float3 tex2DNode14 = UnpackNormal( tex2D( _NormalMap, panner107 ) );
				float4 texCoord139 = i.ase_texcoord3;
				texCoord139.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult142 = lerp( (0.0 + (_Distortionpower - 0.0) * (0.2 - 0.0) / (1.0 - 0.0)) , (0.0 + (texCoord139.x - 0.0) * (0.2 - 0.0) / (1.0 - 0.0)) , _CustomNiu);
				float clampResult89 = clamp( ( ( ( abs( tex2DNode14.r ) + abs( tex2DNode14.g ) ) * 30.0 ) - 0.2 ) , 0.0 , 1.0 );
				float4 screenColor29 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,(( (ase_grabScreenPosNorm).xy + ( (tex2DNode14).xy * lerpResult142 * clampResult89 ) )).xy);
				float2 uv_MaskTex = i.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float cos123 = cos( ( ( _Mask_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float sin123 = sin( ( ( _Mask_Tex_Rotator * UNITY_PI ) / 180.0 ) );
				float2 rotator123 = mul( uv_MaskTex - float2( 0.5,0.5 ) , float2x2( cos123 , -sin123 , sin123 , cos123 )) + float2( 0.5,0.5 );
				float4 tex2DNode128 = tex2D( _MaskTex, rotator123 );
				float lerpResult126 = lerp( tex2DNode128.r , tex2DNode128.a , _MaskTex_A_R);
				
				
				finalColor = ( screenColor29 * i.ase_color * lerpResult126 );
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
Node;AmplifyShaderEditor.CommentaryNode;109;-1042.353,-759.7509;Inherit;False;1646.144;606.877;Comment;10;104;97;49;29;87;36;91;85;86;144;屏幕UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;144;-1025.131,-542.2057;Inherit;False;759;380;粒子自定义数据控制强度;6;142;143;139;12;137;141;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;-1028.788,-1156.974;Inherit;False;1420.848;352.2483;Comment;14;115;80;101;79;102;116;105;108;107;14;82;81;84;89;法线扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;86;-254.4957,-710.6706;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;85;-472.9315,-711.0906;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-194.0263,-627.9126;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;89;256.5044,-1082.474;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-153.061,-988.1437;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;30;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;107;-735.5344,-1083.478;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1015.755,-883.5573;Inherit;False;Property;_NormalVs;扭曲V速度;4;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;79;-270.2942,-1102.043;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;101;-269.999,-1034.357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-147.8794,-1082.829;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;-1042.649,-123.2238;Inherit;False;1147.698;349.4158;MASK;9;127;126;128;119;131;134;135;121;123;遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;123;-516.4052,-52.62743;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;121;-1028.913,-56.18175;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;135;-642.2441,-5.274711;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;134;-818.7922,-4.371879;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-1028.399,74.11814;Inherit;False;Property;_Mask_Tex_Rotator;遮罩贴图旋转;7;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-901.6531,151.8073;Inherit;False;Constant;_Float11;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;126;-41.94098,-23.46893;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-217.6664,111.3316;Inherit;False;Property;_MaskTex_A_R;遮罩贴图通道;6;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1015.755,-959.5573;Inherit;False;Property;_NormalUs;扭曲U速度;3;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-568.1345,-315.1672;Inherit;False;Property;_CustomNiu;扭曲强度模式;2;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;137;-747.2715,-501.5963;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1016.101,-407.4335;Float;False;Property;_Distortionpower;扭曲强度;1;0;Create;False;0;0;0;False;0;False;0.5;4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;139;-961.3616,-332.0895;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;143;-746.0114,-330.0699;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;142;-409.6088,-382.3477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;36;-1022.238,-623.5287;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;114;726.1559,-562.6376;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/遮罩热扭曲;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;True;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;108;-879.5349,-954.4775;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;105;-965.6427,-1088.881;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;128;-340.3213,-81.33503;Inherit;True;Property;_MaskTex;遮罩贴图;5;1;[Header];Create;False;1;Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-557.9751,-1112.266;Inherit;True;Property;_NormalMap;法线贴图;0;1;[Header];Create;False;1;Distortion;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-40.13392,-705.467;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;29;277.1927,-710.1935;Float;False;Global;_GrabScreen0;Grab Screen 0;4;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;49;276.9074,-537.7504;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;469.5978,-562.5801;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;104;78.80264,-710.725;Inherit;False;True;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;125.0103,-1082.174;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-9.305927,-986.1537;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-23.36477,-1082.56;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;86;0;85;0
WireConnection;91;0;36;0
WireConnection;91;1;142;0
WireConnection;91;2;89;0
WireConnection;89;0;81;0
WireConnection;107;0;105;0
WireConnection;107;2;108;0
WireConnection;79;0;14;1
WireConnection;101;0;14;2
WireConnection;80;0;79;0
WireConnection;80;1;101;0
WireConnection;123;0;121;0
WireConnection;123;2;135;0
WireConnection;135;0;134;0
WireConnection;135;1;119;0
WireConnection;134;0;131;0
WireConnection;126;0;128;1
WireConnection;126;1;128;4
WireConnection;126;2;127;0
WireConnection;137;0;12;0
WireConnection;143;0;139;1
WireConnection;142;0;137;0
WireConnection;142;1;143;0
WireConnection;142;2;141;0
WireConnection;36;0;14;0
WireConnection;114;0;97;0
WireConnection;108;0;115;0
WireConnection;108;1;116;0
WireConnection;128;1;123;0
WireConnection;14;1;107;0
WireConnection;87;0;86;0
WireConnection;87;1;91;0
WireConnection;29;0;104;0
WireConnection;97;0;29;0
WireConnection;97;1;49;0
WireConnection;97;2;126;0
WireConnection;104;0;87;0
WireConnection;81;0;102;0
WireConnection;81;1;82;0
WireConnection;102;0;80;0
WireConnection;102;1;84;0
ASEEND*/
//CHKSM=89E39D74C5C115CAF835E5220F3F1A2C8A88FCB7