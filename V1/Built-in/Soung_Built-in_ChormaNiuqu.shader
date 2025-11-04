// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/色差扭曲流动"
{
	Properties
	{
		_MainTex("纹理", 2D) = "white" {}
		_NiuquTex("扭曲贴图", 2D) = "white" {}
		_Niuquqiangdu("扭曲强度", Range( 0 , 1)) = 0.07
		[Enum(Polar,0,Repeat,1)]_NiuquUVMode("扭曲UV模式", Float) = 0
		_PolarUVSets("极坐标中心点与缩放", Vector) = (0.5,0.5,1,1)
		_NiuquUSpeed("扭曲U速度", Float) = 0
		_NiuquVSpeed("扭曲V速度", Float) = 0
		_Pianyiqiangdu("色差偏移程度", Range( -0.1 , 0.1)) = 0.06

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
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _NiuquTex;
			uniform float _NiuquUSpeed;
			uniform float _NiuquVSpeed;
			uniform float4 _NiuquTex_ST;
			uniform float4 _PolarUVSets;
			uniform float _NiuquUVMode;
			uniform float _Niuquqiangdu;
			uniform float _Pianyiqiangdu;

			
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult36 = (float2(_NiuquUSpeed , _NiuquVSpeed));
				float2 uv_NiuquTex = i.ase_texcoord1.xy * _NiuquTex_ST.xy + _NiuquTex_ST.zw;
				float2 appendResult33 = (float2(_PolarUVSets.x , _PolarUVSets.y));
				float2 CenteredUV15_g1 = ( uv_NiuquTex - appendResult33 );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * _PolarUVSets.z * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / 6.28318548202515 ) * _PolarUVSets.w )));
				float2 lerpResult30 = lerp( appendResult23_g1 , uv_NiuquTex , _NiuquUVMode);
				float2 panner27 = ( 1.0 * _Time.y * appendResult36 + lerpResult30);
				float2 lerpResult5 = lerp( uv_MainTex , (tex2D( _NiuquTex, panner27 )).rg , (0.0 + (_Niuquqiangdu - 0.0) * (0.5 - 0.0) / (1.0 - 0.0)));
				float4 tex2DNode10 = tex2D( _MainTex, lerpResult5 );
				float3 appendResult16 = (float3(tex2D( _MainTex, ( lerpResult5 + ( 1.0 * _Pianyiqiangdu ) ) ).r , tex2DNode10.g , tex2D( _MainTex, ( lerpResult5 + ( _Pianyiqiangdu * -1.0 ) ) ).b));
				float4 appendResult42 = (float4(appendResult16 , ( tex2DNode10.a * i.ase_color.a )));
				
				
				finalColor = appendResult42;
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
Node;AmplifyShaderEditor.CommentaryNode;39;-1386.258,-39.69158;Inherit;False;1031.56;663.821;Comment;12;16;17;11;1;10;18;12;22;21;9;15;23;色散偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-3036.35,67.55;Inherit;False;1591.218;474.2415;Comment;16;6;37;5;2;4;36;35;34;31;26;32;3;30;28;33;27;扭曲采样;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;27;-2272.024,296.3991;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-2807.708,140.1267;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;28;-2676.025,139.3995;Inherit;False;Polar Coordinates;-1;;1;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;30;-2425.024,266.3996;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-2099.749,267.6264;Inherit;True;Property;_NiuquTex;扭曲贴图;1;0;Create;False;0;0;0;False;0;False;-1;05aa43dbbeddb24419e5b5b6e734d595;862570ac1240e6a4eb4a7198db6bf068;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;32;-2999.707,111.1265;Inherit;False;Property;_PolarUVSets;极坐标中心点与缩放;4;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-3019.025,284.3993;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-2594.024,310.399;Inherit;False;Property;_NiuquUVMode;扭曲UV模式;3;1;[Enum];Create;False;0;2;Polar;0;Repeat;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2581.706,385.1262;Inherit;False;Property;_NiuquUSpeed;扭曲U速度;5;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2582.706,460.1263;Inherit;False;Property;_NiuquVSpeed;扭曲V速度;6;0;Create;False;0;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2419.706,389.1261;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;4;-1809.749,267.6264;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1829.749,141.6262;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-1595.75,247.6265;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-1792.015,346.9137;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2079.749,457.6258;Inherit;False;Property;_Niuquqiangdu;扭曲强度;2;0;Create;False;0;0;0;False;0;False;0.07;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1261.669,61.5738;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1125.348,65.93517;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-1086.035,240.3276;Inherit;True;Property;_MainTex;纹理;0;0;Create;False;0;0;0;False;0;False;None;14b5f663e1f1907429ef0238a746aaff;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-994.1652,40.61413;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-986.1653,455.6141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1129.617,477.8855;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1275.938,493.5241;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-848.8454,218.9755;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-858.636,12.52767;Inherit;True;Property;_主图;主图;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-846.8455,427.9755;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1376.938,257.7622;Inherit;False;Property;_Pianyiqiangdu;色差偏移程度;7;0;Create;False;0;0;0;False;0;False;0.06;0.02;-0.1;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-553.2534,248.5013;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;25;-505.2755,634.7295;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-334.626,542.4733;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;-60.02755,248.3962;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/色差扭曲流动;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-194.5051,248.026;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;27;0;30;0
WireConnection;27;2;36;0
WireConnection;33;0;32;1
WireConnection;33;1;32;2
WireConnection;28;1;26;0
WireConnection;28;2;33;0
WireConnection;28;3;32;3
WireConnection;28;4;32;4
WireConnection;30;0;28;0
WireConnection;30;1;26;0
WireConnection;30;2;31;0
WireConnection;3;1;27;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;4;0;3;0
WireConnection;5;0;2;0
WireConnection;5;1;4;0
WireConnection;5;2;37;0
WireConnection;37;0;6;0
WireConnection;15;0;23;0
WireConnection;15;1;17;0
WireConnection;21;0;5;0
WireConnection;21;1;15;0
WireConnection;22;0;5;0
WireConnection;22;1;12;0
WireConnection;12;0;17;0
WireConnection;12;1;18;0
WireConnection;10;0;9;0
WireConnection;10;1;5;0
WireConnection;1;0;9;0
WireConnection;1;1;21;0
WireConnection;11;0;9;0
WireConnection;11;1;22;0
WireConnection;16;0;1;1
WireConnection;16;1;10;2
WireConnection;16;2;11;3
WireConnection;40;0;10;4
WireConnection;40;1;25;4
WireConnection;24;0;42;0
WireConnection;42;0;16;0
WireConnection;42;3;40;0
ASEEND*/
//CHKSM=23FBD3401E71A86B7D3E69539D9A65E7B7A13DA5