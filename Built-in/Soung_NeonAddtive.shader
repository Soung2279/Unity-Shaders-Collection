// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/自动霓虹灯呼吸_Addtive"
{
	Properties
	{
		[HDR][Header(AutoColorChange)]_MainColor("霓虹颜色 (不能使用纯白纯黑)", Color) = (2,0.8862745,0.5019608,1)
		[Enum(Manual,0,Auto,1)]_ChangeMode("颜色变换模式", Float) = 1
		_ChangeValue("手动变换值", Range( -1 , 1)) = 0
		_ChangeSpeed("自动变换速度", Float) = 1
		[Header(AutoAlphaChange)][Enum(Manual,0,Auto,1)]_BreethMode("呼吸模式", Float) = 0
		_BreethMValue("手动呼吸值", Range( 0 , 1)) = 0
		_BreethTimeScale("自动呼吸间隔", Float) = 1
		_BreethColorScale("自动呼吸提亮", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
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
				
				
				finalColor = float4( ( hsvTorgb3 * lerpResult28 ) , 0.0 );
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
Node;AmplifyShaderEditor.CommentaryNode;58;-714.9467,69.76271;Inherit;False;533;266;Time自动变换;5;11;14;12;5;15;自动变化色相实现;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1171.26,346.269;Inherit;False;984.6375;416.2263;;13;80;29;28;17;51;83;82;79;81;78;77;76;75;自动变换明度实现;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;15;-329.3658,118.1929;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-651.4978,112.8794;Inherit;False;Property;_ChangeValue;手动变换值;2;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-704.1561,183.2694;Inherit;False;Property;_ChangeSpeed;自动变换速度;3;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-545.3657,260.1929;Inherit;False;Property;_ChangeMode;颜色变换模式;1;1;[Enum];Create;False;0;2;Manual;0;Auto;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-553.1561,188.2694;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-706.7513,-124.8864;Inherit;False;Property;_MainColor;霓虹颜色 (不能使用纯白纯黑);0;2;[HDR];[Header];Create;False;1;AutoColorChange;0;0;False;0;False;2,0.8862745,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;2;-383.5399,-120.6554;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-133.2124,94.7793;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;3;8.436462,-95.89767;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;75;-1157.949,613.351;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-1014.949,465.3483;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;77;-1158.949,393.3472;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;78;-895.9497,465.3483;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1154.949,537.3501;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-782.5296,465.106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-935.5296,560.1085;Inherit;False;Property;_BreethTimeScale;自动呼吸间隔;6;0;Create;False;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-717.7872,684.419;Inherit;False;Property;_BreethColorScale;自动呼吸提亮;7;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-449.6763,665.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-646.859,390.3234;Inherit;False;Property;_BreethMValue;手动呼吸值;5;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;-326.4074,455.5063;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-465.4081,498.506;Inherit;False;Property;_BreethMode;呼吸模式;4;2;[Header];[Enum];Create;False;1;AutoAlphaChange;2;Manual;0;Auto;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;80;-658.5297,465.106;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;252.635,144.1216;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;405.6435,-95.44785;Float;False;True;-1;2;ASEMaterialInspector;100;5;ASE/NenoAddtive;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;15;0;5;0
WireConnection;15;1;11;0
WireConnection;15;2;14;0
WireConnection;11;0;12;0
WireConnection;2;0;10;0
WireConnection;4;0;2;1
WireConnection;4;1;15;0
WireConnection;3;0;4;0
WireConnection;3;1;2;2
WireConnection;3;2;2;3
WireConnection;76;0;77;4
WireConnection;76;1;81;0
WireConnection;78;0;76;0
WireConnection;78;1;75;0
WireConnection;79;0;78;0
WireConnection;79;1;82;0
WireConnection;51;0;80;0
WireConnection;51;1;83;0
WireConnection;28;0;17;0
WireConnection;28;1;51;0
WireConnection;28;2;29;0
WireConnection;80;0;79;0
WireConnection;72;0;3;0
WireConnection;72;1;28;0
WireConnection;0;0;72;0
ASEEND*/
//CHKSM=3A74714D2F236AA5B4CBCD92A8D4BECE74FD122A