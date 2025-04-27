// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/自动霓虹灯呼吸"
{
	Properties
	{
		[Enum(OFF,0,ON,1)]_ZWrite("深度写入", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Culling("剔除模式", Float) = 0
		[Enum(AlphaBlend,10,Addtive,1)]_BlendMode("混合模式", Float) = 10
		[HDR][Header(AutoColorChange)]_MainColor("霓虹颜色 (不能使用纯白纯黑)", Color) = (2,0,0.1098039,1)
		[Enum(Manual,0,Auto,1)]_ChangeMode("颜色变换模式", Float) = 1
		_ChangeValue("手动变换值", Range( -1 , 1)) = 0
		_ChangeSpeed("自动变换速度", Float) = 1
		[Header(AutoAlphaChange)][Enum(Manual,0,Auto,1)]_BreethMode("呼吸模式", Float) = 0
		_BreethMValue("手动呼吸值", Range( 0 , 1)) = 0.2
		_BreethTimeScale("自动呼吸间隔", Float) = 1
		_BreethColorScale("自动呼吸提亮", Range( 0 , 1)) = 0

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
		Cull [_Culling]
		ColorMask RGBA
		ZWrite [_ZWrite]
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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _Culling;
			uniform float _BlendMode;
			uniform float _ZWrite;
			uniform float4 _MainColor;
			uniform float _ChangeValue;
			uniform float _ChangeSpeed;
			uniform float _ChangeMode;
			uniform float _BreethMValue;
			uniform float _BreethTimeScale;
			uniform float _BreethColorScale;
			uniform float _BreethMode;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				
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
				float3 hsvTorgb2 = RGBToHSV( _MainColor.rgb );
				float mulTime11 = _Time.y * _ChangeSpeed;
				float lerpResult15 = lerp( _ChangeValue , mulTime11 , _ChangeMode);
				float3 hsvTorgb3 = HSVToRGB( float3(( hsvTorgb2.x + lerpResult15 ),hsvTorgb2.y,hsvTorgb2.z) );
				float lerpResult28 = lerp( _BreethMValue , ( saturate( ( ( ( _SinTime.w + 1.0 ) / 2.0 ) * _BreethTimeScale ) ) + _BreethColorScale ) , _BreethMode);
				float4 appendResult25 = (float4(hsvTorgb3 , ( _MainColor.a * lerpResult28 )));
				
				
				finalColor = (appendResult25).xyzw;
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
Node;AmplifyShaderEditor.CommentaryNode;53;-1109.307,-96.302;Inherit;False;1277.555;802.0907;AlphaBlend模式下，通过Time更改Hue(色相)，通过(SinTime+1)/2更改Alpha值为0-1实现呼吸;26;54;4;38;47;49;42;30;40;11;17;29;28;3;14;12;2;5;10;15;51;50;48;39;55;56;57;颜色变换与呼吸实现;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1097.597,543.9673;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-745.1773,612.725;Inherit;False;Property;_BreethTimeScale;自动呼吸间隔;9;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-510.4349,612.0355;Inherit;False;Property;_BreethColorScale;自动呼吸提亮;10;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-198.4348,593.0355;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;15;-598.3658,179.1929;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;2;-626.3398,-42.45531;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;14;-814.3658,321.1929;Inherit;False;Property;_ChangeMode;颜色变换模式;4;1;[Enum];Create;False;0;2;Manual;0;Auto;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;3;-247.1094,-16.89767;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;28;-113.1665,272.9333;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-822.1561,249.2694;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-954.5972,395.9657;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;30;-1098.597,323.9657;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;42;-835.5974,395.9657;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-634.1773,395.7234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-509.1774,396.7234;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1094.597,467.9664;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-390.7581,154.7793;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;42.02148,223.0895;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;199.4672,64.54407;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;26;334.9975,60.05417;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;525.0435,63.55215;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/自动霓虹灯呼吸;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_Culling;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;True;_ZWrite;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-280.1665,412.9333;Inherit;False;Property;_BreethMode;呼吸模式;7;2;[Header];[Enum];Create;False;1;AutoAlphaChange;2;Manual;0;Auto;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-973.1561,244.2694;Inherit;False;Property;_ChangeSpeed;自动变换速度;6;0;Create;False;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-920.4978,173.8794;Inherit;False;Property;_ChangeValue;手动变换值;5;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-883.5514,-48.68635;Inherit;False;Property;_MainColor;霓虹颜色 (不能使用纯白纯黑);3;2;[HDR];[Header];Create;False;1;AutoColorChange;0;0;False;0;False;2,0,0.1098039,1;2,0,0.1098039,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-422.6174,268.7504;Inherit;False;Property;_BreethMValue;手动呼吸值;8;0;Create;False;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1087.252,39.07756;Inherit;False;Property;_BlendMode;混合模式;2;1;[Enum];Create;False;0;2;AlphaBlend;10;Addtive;1;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1091.327,-39.97821;Inherit;False;Property;_Culling;剔除模式;1;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1089.807,118.4479;Inherit;False;Property;_ZWrite;深度写入;0;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
WireConnection;51;0;47;0
WireConnection;51;1;50;0
WireConnection;15;0;5;0
WireConnection;15;1;11;0
WireConnection;15;2;14;0
WireConnection;2;0;10;0
WireConnection;3;0;4;0
WireConnection;3;1;2;2
WireConnection;3;2;2;3
WireConnection;28;0;17;0
WireConnection;28;1;51;0
WireConnection;28;2;29;0
WireConnection;11;0;12;0
WireConnection;40;0;30;4
WireConnection;40;1;38;0
WireConnection;42;0;40;0
WireConnection;42;1;39;0
WireConnection;49;0;42;0
WireConnection;49;1;48;0
WireConnection;47;0;49;0
WireConnection;4;0;2;1
WireConnection;4;1;15;0
WireConnection;54;0;10;4
WireConnection;54;1;28;0
WireConnection;25;0;3;0
WireConnection;25;3;54;0
WireConnection;26;0;25;0
WireConnection;0;0;26;0
ASEEND*/
//CHKSM=CFA1D975ECD6EC37692969091EC0D8FE11402AEB