// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/通用程序粒子材质"
{
	Properties
	{
		[KeywordEnum(Dot,Glow)] _dotorglow("光点状/光晕状", Float) = 0
		[HDR]_EnhancedColor("颜色 (辉光)", Color) = (1,1,1,1)
		_MaskPow("光点范围", Range( 5 , 50)) = 10
		_DotPwr("光点亮度", Range( 0 , 5)) = 1
		_MaskSub("光晕范围", Range( 0.5 , 1)) = 0.5
		_GlowPwr("光晕亮度", Range( 0 , 20)) = 20

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
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
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _DOTORGLOW_DOT _DOTORGLOW_GLOW


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

			uniform float _MaskPow;
			uniform float _DotPwr;
			uniform float _MaskSub;
			uniform float _GlowPwr;
			uniform float4 _EnhancedColor;

			
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
				float2 texCoord29 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_32_0 = ( 1.0 - distance( texCoord29 , float2( 0.5,0.5 ) ) );
				#if defined(_DOTORGLOW_DOT)
				float staticSwitch69 = saturate( ( pow( temp_output_32_0 , _MaskPow ) * _DotPwr ) );
				#elif defined(_DOTORGLOW_GLOW)
				float staticSwitch69 = saturate( ( ( temp_output_32_0 - _MaskSub ) * _GlowPwr ) );
				#else
				float staticSwitch69 = saturate( ( pow( temp_output_32_0 , _MaskPow ) * _DotPwr ) );
				#endif
				
				
				finalColor = ( i.ase_color * staticSwitch69 * _EnhancedColor * i.ase_color.a * _EnhancedColor.a );
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
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1913.018,121.4982;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;30;-1676.363,120.8862;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1476.561,121.2523;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-1160.115,-56.69604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1015.116,-56.69604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-1152.658,255.6934;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1011.868,255.7006;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;-883.4497,255.4737;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;40;-884.6964,-56.92308;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;31;-1866.765,238.2504;Inherit;False;Constant;_uvdotcenter;uvdotcenter;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-431.886,74.75146;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1281.245,41.58722;Inherit;False;Property;_DotPwr;光点亮度;3;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1425.567,274.8985;Inherit;False;Property;_MaskSub;光晕范围;4;0;Create;False;0;0;0;False;0;False;0.5;0;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1283.427,351.9837;Inherit;False;Property;_GlowPwr;光晕亮度;5;0;Create;False;0;0;0;False;0;False;20;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;69;-687.2459,93.22992;Inherit;True;Property;_dotorglow;光点状/光晕状;0;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Dot;Glow;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1437.114,-36.69798;Inherit;False;Property;_MaskPow;光点范围;2;0;Create;False;0;0;0;False;0;False;10;0;5;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;3;-619.3826,-73.91486;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-227.4608,76.1063;Float;False;True;-1;2;ASEMaterialInspector;100;5;ASE/ParDot;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ColorNode;88;-611.5688,311.5534;Inherit;False;Property;_EnhancedColor;颜色 (辉光);1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;32;0;30;0
WireConnection;36;0;32;0
WireConnection;36;1;34;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;82;0;32;0
WireConnection;82;1;78;0
WireConnection;75;0;82;0
WireConnection;75;1;77;0
WireConnection;76;0;75;0
WireConnection;40;0;37;0
WireConnection;83;0;3;0
WireConnection;83;1;69;0
WireConnection;83;2;88;0
WireConnection;83;3;3;4
WireConnection;83;4;88;4
WireConnection;69;1;40;0
WireConnection;69;0;76;0
WireConnection;0;0;83;0
ASEEND*/
//CHKSM=91091AB6EFA4A6B706E5B6E2BC311DDC3D7A9877