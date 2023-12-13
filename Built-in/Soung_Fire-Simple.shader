// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/风格化火焰_简易遮罩"
{
	Properties
	{
		_MainTex1("火焰纹理", 2D) = "white" {}
		[KeywordEnum(R,A)] _MainPSwitch("切换贴图通道", Float) = 0
		[HDR]_Color2("内焰颜色", Color) = (1,0.639221,0,1)
		[HDR]_Color1("外焰颜色", Color) = (1,0,0,1)
		_Float2("外焰宽度", Range( 0 , 1)) = 0
		[HDR]_Color0("描边颜色", Color) = (0,0,0,1)
		_Float1("描边宽度", Range( 0 , 1)) = 0
		_TillSpeed("内层偏移与流动", Vector) = (0.5,0.5,0,-1)
		_TillSpeed02("外层偏移与流动", Vector) = (2,1,0,-1)
		_Float0("火焰溶解", Range( 0 , 2)) = 0
		_Float7("整体溶解倍增 (建议默认)", Range( 0 , 1)) = 0.5
		[Toggle]_CustomeZ("CustomeZ控制溶解", Float) = 0
		_MainMask("整体遮罩", 2D) = "white" {}
		[KeywordEnum(R,A)] _MaskSwitch1("切换遮罩通道", Float) = 1
		[Toggle]_OpenDepth("开启深度 (模型穿插地面时启用)", Float) = 0
		_Float20("遮罩强度", Range( 0 , 1)) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite [_OpenDepth]
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
			#pragma shader_feature_local _MAINPSWITCH_R _MAINPSWITCH_A
			#pragma shader_feature_local _MASKSWITCH1_R _MASKSWITCH1_A


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _OpenDepth;
			uniform float4 _Color0;
			uniform float4 _Color1;
			uniform float4 _Color2;
			uniform float _Float2;
			uniform float _Float1;
			uniform float _Float0;
			uniform float _CustomeZ;
			uniform float _Float7;
			uniform sampler2D _MainTex1;
			uniform float4 _TillSpeed;
			uniform float4 _TillSpeed02;
			uniform sampler2D _MainMask;
			uniform float4 _MainMask_ST;
			uniform float _Float20;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1 = v.ase_texcoord2;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
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
				float4 texCoord76 = i.ase_texcoord1;
				texCoord76.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult75 = lerp( _Float0 , texCoord76.z , _CustomeZ);
				float temp_output_44_0 = ( lerpResult75 * _Float7 );
				float temp_output_8_0 = ( _Float1 + temp_output_44_0 );
				float2 appendResult29 = (float2(_TillSpeed.z , _TillSpeed.w));
				float2 appendResult28 = (float2(_TillSpeed.x , _TillSpeed.y));
				float2 texCoord26 = i.ase_texcoord2.xy * appendResult28 + float2( 0,0 );
				float2 panner24 = ( 1.0 * _Time.y * appendResult29 + texCoord26);
				float4 tex2DNode119 = tex2D( _MainTex1, panner24 );
				#if defined(_MAINPSWITCH_R)
				float staticSwitch118 = tex2DNode119.r;
				#elif defined(_MAINPSWITCH_A)
				float staticSwitch118 = tex2DNode119.a;
				#else
				float staticSwitch118 = tex2DNode119.r;
				#endif
				float2 appendResult37 = (float2(_TillSpeed02.z , _TillSpeed02.w));
				float2 appendResult38 = (float2(_TillSpeed02.x , _TillSpeed02.y));
				float2 texCoord36 = i.ase_texcoord2.xy * appendResult38 + float2( 0,0 );
				float2 panner35 = ( 1.0 * _Time.y * appendResult37 + texCoord36);
				float4 tex2DNode114 = tex2D( _MainTex1, panner35 );
				#if defined(_MAINPSWITCH_R)
				float staticSwitch116 = tex2DNode114.r;
				#elif defined(_MAINPSWITCH_A)
				float staticSwitch116 = tex2DNode114.a;
				#else
				float staticSwitch116 = tex2DNode114.r;
				#endif
				float2 uv_MainMask = i.ase_texcoord2.xy * _MainMask_ST.xy + _MainMask_ST.zw;
				float4 tex2DNode112 = tex2D( _MainMask, uv_MainMask );
				#if defined(_MASKSWITCH1_R)
				float staticSwitch113 = tex2DNode112.r;
				#elif defined(_MASKSWITCH1_A)
				float staticSwitch113 = tex2DNode112.a;
				#else
				float staticSwitch113 = tex2DNode112.a;
				#endif
				float temp_output_41_0 = saturate( ( ( ( staticSwitch118 + staticSwitch116 ) * staticSwitch113 ) + ( staticSwitch113 * _Float20 ) ) );
				float4 lerpResult17 = lerp( _Color1 , _Color2 , step( ( ( _Float2 + temp_output_8_0 ) * _Float7 ) , temp_output_41_0 ));
				float4 lerpResult11 = lerp( _Color0 , lerpResult17 , step( ( temp_output_8_0 * _Float7 ) , temp_output_41_0 ));
				float4 appendResult7 = (float4(lerpResult11.rgb , ( step( temp_output_44_0 , temp_output_41_0 ) * staticSwitch113 )));
				
				
				finalColor = ( appendResult7 * i.ase_color );
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
Node;AmplifyShaderEditor.CommentaryNode;99;-901.2678,73.30051;Inherit;False;935.67;422.4238;颜色控制;8;87;7;86;6;13;18;11;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;98;-2198.882,362.8238;Inherit;False;1285.73;375.0473;火焰溶解实现;15;16;10;46;14;45;47;15;8;9;44;5;75;77;76;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2171.326,512.0857;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;-1907.653,639.5118;Inherit;False;Property;_CustomeZ;CustomeZ控制溶解;11;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;75;-1713.229,560.2562;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1564.9,560.0438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1699.808,403.208;Inherit;False;Property;_Float2;外焰宽度;4;0;Create;False;0;0;0;False;0;False;0;0.236;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1314.172,511.8225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1307.437,412.0349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1171.692,413.2107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;10;-1163.631,511.7232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;16;-1032.312,414.5871;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;4;-1033.18,560.1241;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-635.7886,305.0262;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;11;-437.5346,123.7942;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-888.0302,143.686;Inherit;False;Property;_Color1;外焰颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-656.5083,118.7059;Inherit;False;Property;_Color0;描边颜色;5;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;86;-431.2079,240.7836;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;-249.8147,190.1875;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-92.76116,217.5327;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-869.9875,559.5509;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;53.52412,219.2088;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/风格化火焰_简易遮罩;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_OpenDepth;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-3255.01,958.4278;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-3255.912,867.7278;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;35;-2882.632,933.2681;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3110.809,843.9265;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;116;-2415.657,928.0697;Inherit;True;Property;_MaskSwitch2;MaskSwitch;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Reference;118;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-3224.227,732.5071;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;24;-2879.847,707.3478;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-3225.127,642.8073;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-3099.124,620.3057;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-2199.65,910.5874;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1699.312,482.8819;Inherit;False;Property;_Float1;描边宽度;6;0;Create;False;0;0;0;False;0;False;0;0.481;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-214.4615,512.8181;Inherit;False;Property;_OpenDepth;开启深度 (模型穿插地面时启用);14;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;118;-2422.555,702.2622;Inherit;True;Property;_MainPSwitch;切换贴图通道;1;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;-2708.624,679.0336;Inherit;True;Property;_MainTex1;火焰纹理;0;0;Create;False;0;0;0;False;0;False;-1;1ae1f775a34996d458a66e7f1bd5123c;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;114;-2711.555,904.5557;Inherit;True;Property;_MainTex;火焰纹理;0;0;Create;False;0;0;0;False;0;False;-1;1ae1f775a34996d458a66e7f1bd5123c;None;True;0;False;white;Auto;False;Instance;119;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;112;-2492.996,1201.969;Inherit;True;Property;_MainMask;整体遮罩;12;0;Create;False;0;0;0;False;0;False;-1;678a5f28a2ced4b4f949c7d3ac54d49c;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-2709.195,1224.771;Inherit;False;0;112;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;113;-2202.138,1225.183;Inherit;False;Property;_MaskSwitch1;切换遮罩通道;13;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-1481.894,909.8265;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1957.023,909.5374;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1909.789,1230.174;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-1704.124,907.3415;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1435.304,485.6538;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;27;-3423.128,658.4075;Inherit;False;Property;_TillSpeed;内层偏移与流动;7;0;Create;False;0;0;0;False;0;False;0.5,0.5,0,-1;1.04,2.3,-0.57,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;39;-3458.913,884.3281;Inherit;False;Property;_TillSpeed02;外层偏移与流动;8;0;Create;False;0;0;0;False;0;False;2,1,0,-1;1.32,2.01,-0.7,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-1560.354,657.4013;Inherit;False;Property;_Float7;整体溶解倍增 (建议默认);10;0;Create;False;0;0;0;False;0;False;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-2203.789,1323.174;Inherit;False;Property;_Float20;遮罩强度;15;0;Create;False;0;0;0;False;0;False;1;22.93;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1974.942,555.4883;Inherit;False;Property;_Float0;火焰溶解;9;0;Create;False;1;Dissolve;0;0;False;0;False;0;0.36;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-863.8007,322.8125;Inherit;False;Property;_Color2;内焰颜色;2;1;[HDR];Create;False;1;FireColor;0;0;False;0;False;1,0.639221,0,1;1,0.4270763,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;75;0;5;0
WireConnection;75;1;76;3
WireConnection;75;2;77;0
WireConnection;44;0;75;0
WireConnection;44;1;47;0
WireConnection;45;0;8;0
WireConnection;45;1;47;0
WireConnection;14;0;15;0
WireConnection;14;1;8;0
WireConnection;46;0;14;0
WireConnection;46;1;47;0
WireConnection;10;0;45;0
WireConnection;10;1;41;0
WireConnection;16;0;46;0
WireConnection;16;1;41;0
WireConnection;4;0;44;0
WireConnection;4;1;41;0
WireConnection;17;0;13;0
WireConnection;17;1;18;0
WireConnection;17;2;16;0
WireConnection;11;0;6;0
WireConnection;11;1;17;0
WireConnection;11;2;10;0
WireConnection;7;0;11;0
WireConnection;7;3;84;0
WireConnection;87;0;7;0
WireConnection;87;1;86;0
WireConnection;84;0;4;0
WireConnection;84;1;113;0
WireConnection;0;0;87;0
WireConnection;37;0;39;3
WireConnection;37;1;39;4
WireConnection;38;0;39;1
WireConnection;38;1;39;2
WireConnection;35;0;36;0
WireConnection;35;2;37;0
WireConnection;36;0;38;0
WireConnection;116;1;114;1
WireConnection;116;0;114;4
WireConnection;29;0;27;3
WireConnection;29;1;27;4
WireConnection;24;0;26;0
WireConnection;24;2;29;0
WireConnection;28;0;27;1
WireConnection;28;1;27;2
WireConnection;26;0;28;0
WireConnection;117;0;118;0
WireConnection;117;1;116;0
WireConnection;118;1;119;1
WireConnection;118;0;119;4
WireConnection;119;1;24;0
WireConnection;114;1;35;0
WireConnection;112;1;111;0
WireConnection;113;1;112;1
WireConnection;113;0;112;4
WireConnection;41;0;121;0
WireConnection;54;0;117;0
WireConnection;54;1;113;0
WireConnection;123;0;113;0
WireConnection;123;1;122;0
WireConnection;121;0;54;0
WireConnection;121;1;123;0
WireConnection;8;0;9;0
WireConnection;8;1;44;0
ASEEND*/
//CHKSM=A6B8715F95040C5624B871A50C45C12045AABDF0