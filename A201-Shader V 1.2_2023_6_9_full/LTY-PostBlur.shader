// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/后期处理/屏幕模糊效果_PostBlur"
{
	Properties
	{
		_WebSite("!平面必须在最上层，挡住所有物体才能生效!", Int) = 0
		[Header(__________________________________________________________________________________________)]
		[KeywordEnum(X8,X16,X21,X26)] _Keyword0("偏移次数（越大越平滑）", Float) = 0
		[Enum(ON,0,OFF,1)]_UV2_U("是否使用粒子控制模糊（X控制）", Float) = 1
		_U("模糊中心U方向", Range( 0 , 1)) = 0.5
		_V("模糊中心V方向", Range( 0 , 1)) = 0.5
		_Blur("模糊强度", Float) = 0
		_Mask("蒙版贴图", 2D) = "white" {}
		_MaskScale("蒙版强度", Range( 0 , 1)) = 1
		_SeSan_HunHe("散射强度", Range( 0 , 1)) = 0.5
		[Enum(ON,0,OFF,1)]_UV2_V("是否使用粒子控制散射（Y控制）", Float) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent+3000" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		Offset 0 , 0
		
		
		GrabPass{ "_GrabScreen0" }
	GrabPass{ "_GrabScreen0" }

		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
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
			#pragma shader_feature_local _KEYWORD0_X8 _KEYWORD0_X16 _KEYWORD0_X21 _KEYWORD0_X26


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabScreen0 )
			uniform half _U;
			uniform half _V;
			uniform half _Blur;
			uniform half _UV2_U;
			uniform half _SeSan_HunHe;
			uniform half _UV2_V;
			uniform sampler2D _Mask;
			uniform half _MaskScale;
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
				
				o.ase_texcoord2 = v.ase_texcoord1;
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
				half4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				half2 appendResult66 = (half2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				half4 screenColor18 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,appendResult66);
				half4 screenColor78 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,appendResult66);
				half2 appendResult59 = (half2(_U , _V));
				half4 texCoord70 = i.ase_texcoord2;
				texCoord70.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half lerpResult74 = lerp( texCoord70.x , 0.0 , _UV2_U);
				half2 temp_output_77_0 = ( ( appendResult66 - appendResult59 ) * float2( 0.01,0.01 ) * ( _Blur + lerpResult74 ) );
				half2 temp_output_83_0 = ( appendResult66 - temp_output_77_0 );
				half4 screenColor80 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_83_0);
				half2 temp_output_87_0 = ( temp_output_83_0 - temp_output_77_0 );
				half4 screenColor81 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_87_0);
				half3 appendResult82 = (half3(screenColor78.r , screenColor80.g , screenColor81.b));
				half4 screenColor84 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,appendResult66);
				half4 screenColor85 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_83_0);
				half4 screenColor86 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_87_0);
				half2 temp_output_88_0 = ( temp_output_87_0 - temp_output_77_0 );
				half4 screenColor99 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_88_0);
				half2 temp_output_89_0 = ( temp_output_88_0 - temp_output_77_0 );
				half4 screenColor100 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_89_0);
				half2 temp_output_110_0 = ( temp_output_89_0 - temp_output_77_0 );
				half4 screenColor101 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_110_0);
				half2 temp_output_90_0 = ( temp_output_110_0 - temp_output_77_0 );
				half4 screenColor102 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_90_0);
				half2 temp_output_91_0 = ( temp_output_90_0 - temp_output_77_0 );
				half4 screenColor103 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_91_0);
				half4 temp_output_124_0 = ( screenColor84 + screenColor85 + screenColor86 + screenColor99 + screenColor100 + screenColor101 + screenColor102 + screenColor103 );
				half2 myVarName111 = temp_output_77_0;
				half2 temp_output_92_0 = ( temp_output_91_0 - myVarName111 );
				half4 screenColor104 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_92_0);
				half2 temp_output_93_0 = ( temp_output_92_0 - myVarName111 );
				half4 screenColor105 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_93_0);
				half2 temp_output_95_0 = ( temp_output_93_0 - myVarName111 );
				half4 screenColor106 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_95_0);
				half2 temp_output_94_0 = ( temp_output_95_0 - myVarName111 );
				half4 screenColor107 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_94_0);
				half2 temp_output_96_0 = ( temp_output_94_0 - myVarName111 );
				half4 screenColor108 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_96_0);
				half2 temp_output_97_0 = ( temp_output_96_0 - myVarName111 );
				half4 screenColor109 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_97_0);
				half2 temp_output_113_0 = ( ( temp_output_97_0 - myVarName111 ) - myVarName111 );
				half4 screenColor115 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_113_0);
				half2 temp_output_114_0 = ( temp_output_113_0 - myVarName111 );
				half4 screenColor116 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_114_0);
				half4 temp_output_125_0 = ( temp_output_124_0 + ( screenColor104 + screenColor105 + screenColor106 + screenColor107 + screenColor108 + screenColor109 + screenColor115 + screenColor116 ) );
				half2 temp_output_117_0 = ( temp_output_114_0 - myVarName111 );
				half4 screenColor118 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_117_0);
				half2 temp_output_142_0 = ( temp_output_117_0 - myVarName111 );
				float4 screenColor152 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_142_0);
				half2 temp_output_143_0 = ( temp_output_142_0 - myVarName111 );
				float4 screenColor153 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_143_0);
				half2 temp_output_144_0 = ( temp_output_143_0 - myVarName111 );
				float4 screenColor155 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_144_0);
				half2 temp_output_145_0 = ( temp_output_144_0 - myVarName111 );
				float4 screenColor151 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_145_0);
				half4 temp_output_166_0 = ( temp_output_125_0 + ( screenColor118 + screenColor152 + screenColor153 + screenColor155 + screenColor151 ) );
				half2 temp_output_146_0 = ( temp_output_145_0 - myVarName111 );
				float4 screenColor156 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_146_0);
				half2 temp_output_147_0 = ( temp_output_146_0 - myVarName111 );
				float4 screenColor161 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_147_0);
				half2 temp_output_148_0 = ( temp_output_147_0 - myVarName111 );
				float4 screenColor159 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_148_0);
				half2 temp_output_149_0 = ( temp_output_148_0 - myVarName111 );
				float4 screenColor158 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_149_0);
				float4 screenColor157 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,( temp_output_149_0 - myVarName111 ));
				#if defined(_KEYWORD0_X8)
				half4 staticSwitch135 = ( temp_output_124_0 / 8.0 );
				#elif defined(_KEYWORD0_X16)
				half4 staticSwitch135 = ( temp_output_125_0 / 16.0 );
				#elif defined(_KEYWORD0_X21)
				half4 staticSwitch135 = ( temp_output_166_0 / 21.0 );
				#elif defined(_KEYWORD0_X26)
				half4 staticSwitch135 = ( ( temp_output_166_0 + ( screenColor156 + screenColor161 + screenColor159 + screenColor158 + screenColor157 ) ) / 21.0 );
				#else
				half4 staticSwitch135 = ( temp_output_124_0 / 8.0 );
				#endif
				half4 texCoord139 = i.ase_texcoord2;
				texCoord139.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				half lerpResult138 = lerp( texCoord139.y , 0.0 , _UV2_V);
				half4 lerpResult134 = lerp( half4( appendResult82 , 0.0 ) , staticSwitch135 , ( _SeSan_HunHe + lerpResult138 ));
				half4 lerpResult132 = lerp( screenColor18 , lerpResult134 , ( tex2D( _Mask, appendResult66 ).r * _MaskScale ));
				
				
				finalColor = lerpResult132;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
26;88;1461;824;1335.808;1858.955;3.044302;True;True
Node;AmplifyShaderEditor.CommentaryNode;76;-2661.94,-196.5382;Inherit;False;698.3702;468.5408;乘0.01让模糊值更好控制/粒子控制模糊强度;8;75;73;70;74;72;71;77;176;乘0.01让模糊值更好控制/粒子控制模糊强度;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2661.882,-740.6573;Inherit;False;456.7241;262;抓取屏幕UV;2;9;66;抓取屏幕UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2662.71,-466.9697;Inherit;False;695.9993;260.2734;屏幕模糊的中心点;4;60;59;57;58;屏幕模糊的中心点;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2654.735,-405.3171;Inherit;False;Property;_U;U;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2621.391,146.7945;Inherit;False;Property;_UV2_U;UV2_U;3;1;[Enum];Create;True;0;2;ON;0;OFF;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2654.275,-327.0437;Inherit;False;Property;_V;V;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-2653.542,-120.6973;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2622.542,62.30257;Inherit;False;Constant;_B;B;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;9;-2611.882,-690.6573;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;73;-2443.071,-150.4382;Inherit;False;Property;_Blur;Blur;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-2381.168,-399.5205;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-2366.158,-663.9259;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;74;-2443.142,-47.39732;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-2270.271,-150.4382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-2221.11,-424.2153;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2103.453,-146.5829;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0.01,0.01;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;173;-1953.776,-182.6382;Inherit;False;2496.755;2865.962;每次缩放后的UV再减缩放强度给到下一张抓屏当UV，如此规律向下循环;59;135;156;159;158;161;155;151;152;153;118;115;116;149;148;147;146;145;144;143;142;117;157;150;175;174;172;167;84;104;100;86;107;85;106;101;129;123;108;102;103;109;99;105;114;113;98;97;96;94;95;93;92;91;90;110;89;88;87;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-1479.433,-97.7235;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-1480.416,71.37445;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-1465.937,286.9888;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;89;-1468.481,482.3926;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2241.742,102.687;Inherit;False;274;166;发送节点;1;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;-1459.128,660.5597;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-2156.742,170.687;Inherit;False;myVarName;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-1462.503,861.4186;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1953.776,1750.451;Inherit;False;259;166;Comment;1;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-1459.796,1056.657;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1903.776,1800.451;Inherit;False;111;myVarName;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;-1455.317,1237.375;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;-1457.726,1419.391;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-1454.324,1608.077;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;94;-1454.901,1779.647;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-1459.404,1960.901;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-1455.595,2129.055;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1444.301,2279.702;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-1228.032,2484.535;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-1222.304,2589.221;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-773.9695,823.629;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;142;-775.8426,1011.23;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;143;-778.1328,1190.201;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;144;-769.7779,1373.729;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;145;-780.5408,1560.325;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;146;-774.8389,1759.621;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;147;-771.4706,1956.595;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;148;-768.9523,2139.899;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;100;-1257.048,662.2545;Inherit;False;Global;_GrabScreen15;Grab Screen 15;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;103;-1248.951,1231.013;Inherit;False;Global;_GrabScreen18;Grab Screen 18;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;109;-1234.909,2303.826;Inherit;False;Global;_GrabScreen24;Grab Screen 24;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;115;-793.864,456.2875;Inherit;False;Global;_GrabScreen25;Grab Screen 25;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;149;-770.2288,2302.411;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;116;-791.3079,625.2163;Inherit;False;Global;_GrabScreen26;Grab Screen 26;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;104;-1246.143,1407.943;Inherit;False;Global;_GrabScreen19;Grab Screen 19;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;99;-1255.097,469.1726;Inherit;False;Global;_GrabScreen14;Grab Screen 14;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;108;-1243.334,2126.896;Inherit;False;Global;_GrabScreen23;Grab Screen 23;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;107;-1243.334,1949.966;Inherit;False;Global;_GrabScreen22;Grab Screen 22;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;102;-1248.951,1048.467;Inherit;False;Global;_GrabScreen17;Grab Screen 17;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;129;-486.4973,339.2299;Inherit;False;489.9467;442.8872;偏移16次的模糊/这边要除以16;4;125;127;126;128;偏移16次的模糊/这边要除以16;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;101;-1248.951,857.4946;Inherit;False;Global;_GrabScreen16;Grab Screen 16;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;106;-1246.143,1773.036;Inherit;False;Global;_GrabScreen21;Grab Screen 21;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;85;-1265.018,73.18434;Inherit;False;Global;_GrabScreen12;Grab Screen 12;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;123;-775.8033,-89.7453;Inherit;False;347.9901;278.9255;偏移8次的模糊/为什么要除8呢？因为屏幕亮度为1，现在是8个想加，要让亮度恢复就需要除以8;3;122;124;121;偏移8次的模糊/为什么要除8呢？因为屏幕亮度为1，现在是8个想加，要让亮度恢复就需要除以8;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;84;-1278.674,-126.9757;Inherit;False;Global;_GrabScreen11;Grab Screen 11;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;86;-1259.586,284.965;Inherit;False;Global;_GrabScreen13;Grab Screen 13;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;105;-1246.142,1593.299;Inherit;False;Global;_GrabScreen20;Grab Screen 20;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;155;-516.2903,1374.768;Float;False;Global;_GrabScreen1;Grab Screen 18;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;167;-170.123,929.9703;Inherit;False;423.1324;236.3701;偏移21次的模糊/这边要除以21;4;163;165;164;166;偏移21次的模糊/这边要除以21;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;151;-515.7009,1558.979;Float;False;Global;_GrabScreen0;Grab Screen 20;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;150;-774.659,2501.672;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;118;-516.0865,812.7558;Inherit;False;Global;_GrabScreen27;Grab Screen 27;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;153;-516.6061,1191.971;Float;False;Global;_GrabScreen2;Grab Screen 17;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-765.4791,-52.88021;Inherit;False;8;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;152;-519.9623,1005.354;Float;False;Global;_GrabScreen3;Grab Screen 16;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-436.4973,503.1169;Inherit;False;8;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;158;-515.7539,2306.441;Float;False;Global;_GrabScreen4;Grab Screen 23;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;161;-518.1597,1946.039;Float;False;Global;_GrabScreen6;Grab Screen 25;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;172;-168.7517,1209.711;Inherit;False;423.1324;236.3701;偏移26次的模糊/这边要除以26;4;171;170;169;168;偏移26次的模糊/这边要除以26;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;157;-513.2209,2493.185;Float;False;Global;_GrabScreen5;Grab Screen 22;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;163;-159.3382,994.2179;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;156;-520.9128,1748.846;Float;False;Global;_GrabScreen8;Grab Screen 19;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-319.7618,389.2299;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;159;-516.0703,2139.52;Float;False;Global;_GrabScreen7;Grab Screen 24;9;0;Fetch;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;168;-154.5895,1268.827;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;177;-450.1066,-543.5118;Inherit;False;639.5676;339.1056;色散的占比;5;140;137;139;138;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-14.53541,969.7681;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-34.44983,1082.753;Inherit;False;Constant;_21;21;12;0;Create;True;0;0;0;False;0;False;21;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-23.48834,1358.878;Inherit;False;Constant;_Float3;Float 3;12;0;Create;True;0;0;0;False;0;False;21;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;-15.03377,1244.781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-268.0686,565.5344;Inherit;False;Constant;_16;16;7;0;Create;True;0;0;0;False;0;False;16;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;139;-298.2643,-371.0615;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;79;-1024.512,-752.0348;Inherit;False;560.8002;558.6;色散;4;80;81;78;82;色散;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-644.0854,109.2577;Inherit;False;Constant;_8;8;7;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-427.5813,-289.8668;Inherit;False;Property;_UV2_V;UV2_V;11;1;[Enum];Create;True;0;2;ON;0;OFF;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;138;-81.20921,-336.8214;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;127;-126.7687,388.0125;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;164;120.8855,969.8271;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-212.0098,-450.3846;Inherit;False;Property;_SeSan_HunHe;SeSan_HunHe;10;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;170;131.8472,1245.952;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;663.5543,-738.476;Inherit;False;804.2423;345.1505;masklerp原色彩和处理后的结果 ;4;133;131;130;132;masklerp原色彩和处理后的结果 ;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;81;-1003.912,-362.8345;Inherit;False;Global;_GrabScreen10;Grab Screen 10;3;0;Create;True;0;0;0;False;0;False;Instance;18;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;-548.733,-50.29028;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;78;-998.2593,-714.1243;Inherit;False;Global;_GrabScreen8;Grab Screen 8;3;0;Create;True;0;0;0;False;0;False;Instance;18;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;80;-1004.912,-535.6352;Inherit;False;Global;_GrabScreen9;Grab Screen 9;3;0;Create;True;0;0;0;False;0;False;Instance;18;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;133;734.1887,-471.9335;Inherit;False;Property;_MaskScale;MaskScale;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-636.3912,-571.786;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;73.63264,-443.2791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;733.17,-712.3338;Inherit;True;Property;_Mask;Mask;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;135;272.5389,-65.28062;Inherit;False;Property;_Keyword0;偏移次数;2;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;4;X8;X16;X21;X26;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2185.715,-740.6986;Inherit;False;213.1941;258.5467;抓取屏幕颜色;1;18;抓取屏幕颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;18;-2165.92,-673.0131;Inherit;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;1062.181,-491.5562;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;134;431.6978,-578.3062;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-5836.019,-1006.698;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;35;-4763.797,-309.5741;Inherit;False;Global;_GrabScreen7;Grab Screen 7;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-3724.486,-1076.061;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-4187.028,-1380.642;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-4328.313,-938.6412;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;a7b14aa0bad28484a8dcaa21c4626101;a7b14aa0bad28484a8dcaa21c4626101;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;53;-4184.167,-1689.646;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-5404.019,-1038.698;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;-4959.734,-307.4201;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-3017.051,917.1673;Inherit;False;Constant;_Float4;Float 4;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;31;-4759.822,-1098.452;Inherit;False;Global;_GrabScreen4;Grab Screen 4;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;184;-3226.211,597.2298;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;178;-3561.703,306.4703;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;187;-2974.297,605.8378;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-2699.485,606.0183;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;185;-2826.051,904.1672;Inherit;False;1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-4957.7,-475.912;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;180;-3794.912,740.8298;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenColorNode;23;-4752.004,-1197.836;Inherit;False;Global;_GrabScreen2;Grab Screen 2;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;183;-3505.912,600.8298;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-5532.019,-926.6978;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;-4936.454,-878.7952;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-4333.418,-1145.345;Inherit;True;Property;_Main;Main;0;0;Create;True;0;0;0;False;0;False;-1;a7b14aa0bad28484a8dcaa21c4626101;a7b14aa0bad28484a8dcaa21c4626101;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;22;-4763.43,-1466.776;Inherit;False;Global;_GrabScreen1;Grab Screen 1;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-5067.43,-1674.777;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;32;-4766.623,-494.944;Inherit;False;Global;_GrabScreen5;Grab Screen 5;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;179;-3799.912,537.8298;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;132;1278.093,-688.476;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-5836.019,-734.6976;Inherit;False;Property;_ONE_PostBlur;ONE_PostBlur;7;1;[Enum];Create;True;0;2;ON;0;OFF;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-5804.019,-814.6973;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-3320.13,824.4944;Inherit;False;Constant;_Float5;Float 5;12;0;Create;True;0;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;30;-4762.93,-894.0625;Inherit;False;Global;_GrabScreen3;Grab Screen 3;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-4971.43,-1482.776;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-4312.834,-1498.767;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-4960.004,-1213.836;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-5590.108,-1120.147;Inherit;False;Property;_suofang;suofang;1;0;Create;True;0;0;0;False;0;False;1;2.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-4324.677,-731.9544;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;33;-4768.335,-708.9739;Inherit;False;Global;_GrabScreen6;Grab Screen 6;3;0;Create;True;0;0;0;False;0;False;Instance;18;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;55;-4037.393,-1540.144;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-4934.699,-683.9117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-4347.431,-1658.777;Inherit;False;8;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;46;-4940.645,-1081.204;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-5227.43,-1530.776;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;26;1521.594,-686.9677;Half;False;True;-1;2;ASEMaterialInspector;100;1;LTY/shader/PostBlur;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=3000;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;174;-1953.776,1750.451;Inherit;False;259;166;接受节点;0;;1,1,1,1;0;0
WireConnection;59;0;57;0
WireConnection;59;1;58;0
WireConnection;66;0;9;1
WireConnection;66;1;9;2
WireConnection;74;0;70;1
WireConnection;74;1;71;0
WireConnection;74;2;72;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;60;0;66;0
WireConnection;60;1;59;0
WireConnection;77;0;60;0
WireConnection;77;2;75;0
WireConnection;83;0;66;0
WireConnection;83;1;77;0
WireConnection;87;0;83;0
WireConnection;87;1;77;0
WireConnection;88;0;87;0
WireConnection;88;1;77;0
WireConnection;89;0;88;0
WireConnection;89;1;77;0
WireConnection;110;0;89;0
WireConnection;110;1;77;0
WireConnection;111;0;77;0
WireConnection;90;0;110;0
WireConnection;90;1;77;0
WireConnection;91;0;90;0
WireConnection;91;1;77;0
WireConnection;92;0;91;0
WireConnection;92;1;112;0
WireConnection;93;0;92;0
WireConnection;93;1;112;0
WireConnection;95;0;93;0
WireConnection;95;1;112;0
WireConnection;94;0;95;0
WireConnection;94;1;112;0
WireConnection;96;0;94;0
WireConnection;96;1;112;0
WireConnection;97;0;96;0
WireConnection;97;1;112;0
WireConnection;98;0;97;0
WireConnection;98;1;112;0
WireConnection;113;0;98;0
WireConnection;113;1;112;0
WireConnection;114;0;113;0
WireConnection;114;1;112;0
WireConnection;117;0;114;0
WireConnection;117;1;112;0
WireConnection;142;0;117;0
WireConnection;142;1;112;0
WireConnection;143;0;142;0
WireConnection;143;1;112;0
WireConnection;144;0;143;0
WireConnection;144;1;112;0
WireConnection;145;0;144;0
WireConnection;145;1;112;0
WireConnection;146;0;145;0
WireConnection;146;1;112;0
WireConnection;147;0;146;0
WireConnection;147;1;112;0
WireConnection;148;0;147;0
WireConnection;148;1;112;0
WireConnection;100;0;89;0
WireConnection;103;0;91;0
WireConnection;109;0;97;0
WireConnection;115;0;113;0
WireConnection;149;0;148;0
WireConnection;149;1;112;0
WireConnection;116;0;114;0
WireConnection;104;0;92;0
WireConnection;99;0;88;0
WireConnection;108;0;96;0
WireConnection;107;0;94;0
WireConnection;102;0;90;0
WireConnection;101;0;110;0
WireConnection;106;0;95;0
WireConnection;85;0;83;0
WireConnection;84;0;66;0
WireConnection;86;0;87;0
WireConnection;105;0;93;0
WireConnection;155;0;144;0
WireConnection;151;0;145;0
WireConnection;150;0;149;0
WireConnection;150;1;112;0
WireConnection;118;0;117;0
WireConnection;153;0;143;0
WireConnection;124;0;84;0
WireConnection;124;1;85;0
WireConnection;124;2;86;0
WireConnection;124;3;99;0
WireConnection;124;4;100;0
WireConnection;124;5;101;0
WireConnection;124;6;102;0
WireConnection;124;7;103;0
WireConnection;152;0;142;0
WireConnection;126;0;104;0
WireConnection;126;1;105;0
WireConnection;126;2;106;0
WireConnection;126;3;107;0
WireConnection;126;4;108;0
WireConnection;126;5;109;0
WireConnection;126;6;115;0
WireConnection;126;7;116;0
WireConnection;158;0;149;0
WireConnection;161;0;147;0
WireConnection;157;0;150;0
WireConnection;163;0;118;0
WireConnection;163;1;152;0
WireConnection;163;2;153;0
WireConnection;163;3;155;0
WireConnection;163;4;151;0
WireConnection;156;0;146;0
WireConnection;125;0;124;0
WireConnection;125;1;126;0
WireConnection;159;0;148;0
WireConnection;168;0;156;0
WireConnection;168;1;161;0
WireConnection;168;2;159;0
WireConnection;168;3;158;0
WireConnection;168;4;157;0
WireConnection;166;0;125;0
WireConnection;166;1;163;0
WireConnection;169;0;166;0
WireConnection;169;1;168;0
WireConnection;138;0;139;2
WireConnection;138;2;140;0
WireConnection;127;0;125;0
WireConnection;127;1;128;0
WireConnection;164;0;166;0
WireConnection;164;1;165;0
WireConnection;170;0;169;0
WireConnection;170;1;171;0
WireConnection;81;0;87;0
WireConnection;121;0;124;0
WireConnection;121;1;122;0
WireConnection;78;0;66;0
WireConnection;80;0;83;0
WireConnection;82;0;78;1
WireConnection;82;1;80;2
WireConnection;82;2;81;3
WireConnection;136;0;137;0
WireConnection;136;1;138;0
WireConnection;130;1;66;0
WireConnection;135;1;121;0
WireConnection;135;0;127;0
WireConnection;135;2;164;0
WireConnection;135;3;170;0
WireConnection;18;0;66;0
WireConnection;131;0;130;1
WireConnection;131;1;133;0
WireConnection;134;0;82;0
WireConnection;134;1;135;0
WireConnection;134;2;136;0
WireConnection;35;0;50;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;61;0;7;0
WireConnection;61;1;63;0
WireConnection;50;0;49;0
WireConnection;50;1;6;0
WireConnection;31;0;46;0
WireConnection;184;0;183;0
WireConnection;187;0;184;0
WireConnection;187;1;188;0
WireConnection;189;0;187;0
WireConnection;189;1;185;0
WireConnection;185;0;186;0
WireConnection;49;0;48;0
WireConnection;49;1;6;0
WireConnection;23;0;29;0
WireConnection;183;0;179;0
WireConnection;183;1;180;0
WireConnection;63;0;62;1
WireConnection;63;1;64;0
WireConnection;63;2;65;0
WireConnection;47;0;46;0
WireConnection;47;1;6;0
WireConnection;22;0;28;0
WireConnection;24;1;6;0
WireConnection;32;0;49;0
WireConnection;132;0;18;0
WireConnection;132;1;134;0
WireConnection;132;2;131;0
WireConnection;30;0;47;0
WireConnection;28;0;24;0
WireConnection;28;1;6;0
WireConnection;29;0;28;0
WireConnection;29;1;6;0
WireConnection;33;0;48;0
WireConnection;55;0;53;0
WireConnection;55;3;56;0
WireConnection;48;0;47;0
WireConnection;48;1;6;0
WireConnection;52;1;22;0
WireConnection;52;2;23;0
WireConnection;52;3;31;0
WireConnection;52;4;30;0
WireConnection;52;5;33;0
WireConnection;52;6;32;0
WireConnection;52;7;35;0
WireConnection;46;0;29;0
WireConnection;46;1;6;0
WireConnection;6;2;61;0
WireConnection;26;0;132;0
ASEEND*/
//CHKSM=68A6B95D7BD625EEEE7FFE7BDF1B98281A2EA5D9