// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/基本效果/通用程序光晕"
{
	Properties
	{
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1
		[HDR]_BaseColor("颜色", Color) = (1,1,1,1)
		[Enum(AGlow,0,BGlow,1)]_GlowMode("生成光晕样式", Float) = 0
		_AGlowRange("A光晕范围", Range( 0.5 , 1)) = 0.5
		_AGlowPower("A光晕亮度", Range( 0 , 1)) = 0.5
		_BGlowRange("B光晕大小", Range( 0 , 1)) = 0.5
		_BGlowPower("B光晕过渡", Range( 0 , 1)) = 0.5

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha [_BlendMode]
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half _BlendMode;
			uniform half4 _BaseColor;
			uniform half _AGlowRange;
			uniform half _AGlowPower;
			uniform half _BGlowRange;
			uniform half _BGlowPower;
			uniform half _GlowMode;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_color = v.color;
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
				half2 texCoord29 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				half2 texCoord101 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				half2 temp_output_91_0 = ( ( texCoord101 - float2( 0.5,0.5 ) ) * 2.0 );
				half2 temp_output_93_0 = ( temp_output_91_0 * temp_output_91_0 );
				half lerpResult110 = lerp( saturate( ( ( ( 1.0 - distance( texCoord29 , half2( 0.5,0.5 ) ) ) - _AGlowRange ) * (1.0 + (_AGlowPower - 0.0) * (20.0 - 1.0) / (1.0 - 0.0)) ) ) , ( 1.0 - pow( saturate( ( ( (temp_output_93_0).x + (temp_output_93_0).y ) - (-1.0 + (_BGlowRange - 0.0) * (0.0 - -1.0) / (1.0 - 0.0)) ) ) , (0.0 + (_BGlowPower - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) ) ) , _GlowMode);
				
				
				finalColor = ( i.ase_color * _BaseColor * lerpResult110 );
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
Node;AmplifyShaderEditor.CommentaryNode;109;-2358.382,136.4796;Inherit;False;1137.356;333.2486;Distance生成;10;76;75;82;114;77;78;31;29;30;32;光晕A;1,0.8209315,0.6556604,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;90;-2859.078,486.5738;Inherit;False;1636.932;378.763;UV生成;16;107;112;106;104;102;98;92;100;99;97;94;95;93;91;96;101;光晕B;0.5613208,0.7605385,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1992.576,199.3489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;30;-2123.319,179.48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2344.974,180.092;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-2845.257,569.3281;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-2633.785,569.6369;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2498.783,569.6369;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-2368.813,557.4651;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-2038.311,554.9651;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;-2234.312,604.9649;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;97;-2235.874,528.717;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-1922.311,554.9651;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;100;-1793.311,554.9651;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2643.784,666.6364;Inherit;False;Constant;_bglowvector;bglowvector;42;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-1207.126,483.0851;Inherit;False;Property;_GlowMode;生成光晕样式;2;1;[Enum];Create;False;0;2;AGlow;0;BGlow;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;110;-1055.526,441.185;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;88;-1104.069,567.1534;Inherit;False;Property;_BaseColor;颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;3;-1065.883,270.6852;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-871.3863,393.3515;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-871.2443,315.9312;Inherit;False;Property;_BlendMode;混合模式;0;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-662.9612,394.7063;Half;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/基本效果/通用程序光晕;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TFHCRemapNode;98;-2120.019,685.2404;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;102;-1522.283,553.7119;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;104;-1385.24,554.5939;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1950.042,683.5234;Inherit;False;Property;_BGlowPower;B光晕过渡;6;0;Create;False;0;0;0;False;0;False;0.5;1.39;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;112;-1688.587,689.4295;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2107.523,270.4922;Inherit;False;Property;_AGlowRange;A光晕范围;3;0;Create;False;0;0;0;False;0;False;0.5;0;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2105.383,346.5774;Inherit;False;Property;_AGlowPower;A光晕亮度;4;0;Create;False;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;114;-1830.547,303.1284;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-1656.814,246.3873;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1525.024,246.3945;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;-1396.674,247.5125;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-2383.007,680.2834;Inherit;False;Property;_BGlowRange;B光晕大小;5;0;Create;False;2;______________________________________________________________________;GlobalMask;2;Glo;0;Option2;1;0;False;0;False;0.5;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;31;-2289.721,304.8441;Inherit;False;Constant;_aglowcenter;aglowcenter;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;32;0;30;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;96;0;101;0
WireConnection;91;0;96;0
WireConnection;91;1;92;0
WireConnection;93;0;91;0
WireConnection;93;1;91;0
WireConnection;95;0;97;0
WireConnection;95;1;94;0
WireConnection;94;0;93;0
WireConnection;97;0;93;0
WireConnection;99;0;95;0
WireConnection;99;1;98;0
WireConnection;100;0;99;0
WireConnection;110;0;76;0
WireConnection;110;1;104;0
WireConnection;110;2;111;0
WireConnection;83;0;3;0
WireConnection;83;1;88;0
WireConnection;83;2;110;0
WireConnection;0;0;83;0
WireConnection;98;0;107;0
WireConnection;102;0;100;0
WireConnection;102;1;112;0
WireConnection;104;0;102;0
WireConnection;112;0;106;0
WireConnection;114;0;77;0
WireConnection;82;0;32;0
WireConnection;82;1;78;0
WireConnection;75;0;82;0
WireConnection;75;1;114;0
WireConnection;76;0;75;0
ASEEND*/
//CHKSM=D358A1D8E9FE9306329D38C4623E6670A4EADABF