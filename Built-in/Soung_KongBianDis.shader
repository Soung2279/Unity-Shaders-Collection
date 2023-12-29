// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/控边溶解"
{
	Properties
	{
		_MainTexU("主纹理", 2D) = "white" {}
		[Enum(R,0,A,1)]_Float2("贴图通道切换", Float) = 0
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		_Dissolve("溶解纹理", 2D) = "white" {}
		[Enum(Custom1x,0,Material,1)]_DissolveMode("溶解模式", Float) = 1
		_DissolveSoft("溶解进程", Range( 0 , 1)) = 0.6348544
		_DissolveSoftWigth("软溶解宽度", Range( 0 , 1)) = 1
		[HDR]_EgdeColor("边缘颜色", Color) = (1,1,1,1)
		_RampTexS("溶解渐变色 (Clamp)", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 4.5
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _RampTexS;
			uniform float _DissolveSoftWigth;
			uniform sampler2D _Dissolve;
			uniform float4 _Dissolve_ST;
			uniform float _DissolveSoft;
			uniform float _DissolveMode;
			uniform float4 _EgdeColor;
			uniform sampler2D _MainTexU;
			uniform float4 _MainTexU_ST;
			uniform float4 _MainColor;
			uniform float _Float2;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.xyz = v.ase_texcoord1.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
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
				float2 uv_Dissolve = i.ase_texcoord1.xy * _Dissolve_ST.xy + _Dissolve_ST.zw;
				float3 texCoord25 = i.ase_texcoord2.xyz;
				texCoord25.xy = i.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult26 = lerp( texCoord25.z , _DissolveSoft , _DissolveMode);
				float smoothstepResult7 = smoothstep( 0.0 , _DissolveSoftWigth , ( tex2D( _Dissolve, uv_Dissolve ).r + 1.0 + ( -2.0 * lerpResult26 ) ));
				float2 appendResult10 = (float2(smoothstepResult7 , 0.0));
				float4 tex2DNode28 = tex2D( _RampTexS, appendResult10 );
				float2 uv_MainTexU = i.ase_texcoord1.xy * _MainTexU_ST.xy + _MainTexU_ST.zw;
				float4 tex2DNode13 = tex2D( _MainTexU, uv_MainTexU );
				float4 lerpResult20 = lerp( ( tex2DNode28 * _EgdeColor ) , ( tex2DNode13 * _MainColor * i.ase_color ) , tex2DNode28.a);
				float lerpResult29 = lerp( tex2DNode13.r , tex2DNode13.a , _Float2);
				float4 appendResult23 = (float4((lerpResult20).rgb , ( lerpResult29 * _MainColor.a * i.ase_color.a * smoothstepResult7 )));
				
				
				finalColor = appendResult23;
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
Node;AmplifyShaderEditor.SamplerNode;28;-56.43612,-74.98661;Inherit;True;Property;_RampTexS;溶解渐变色 (Clamp);8;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;31.26715,115.6682;Inherit;False;Property;_EgdeColor;边缘颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;283.0746,-68.63457;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;20;437.5503,-23.79491;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;581.9858,-27.87613;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;769.6479,-22.69289;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;982.4251,-22.10013;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/控边溶解;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2;-665.6756,-44.87557;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-821.4177,115.3844;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-988.2173,110.7854;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;-994.5236,185.1371;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-1229.524,113.1375;Inherit;False;1;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1182.524,329.1378;Inherit;False;Property;_DissolveMode;溶解模式;4;1;[Enum];Create;False;0;2;Custom1x;0;Material;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1285.724,255.6654;Inherit;False;Property;_DissolveSoft;溶解进程;5;0;Create;False;0;0;0;False;0;False;0.6348544;0.6348544;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-823.0595,14.32586;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-820.4124,212.4649;Inherit;False;Property;_DissolveSoftWigth;软溶解宽度;6;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;7;-475.6104,-44.79034;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-218.815,-45.11354;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;44.74771,339.2413;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;47.0732,554.9683;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1126.418,-74.64461;Inherit;True;Property;_Dissolve;溶解纹理;3;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-544.9449,215.4131;Inherit;True;Property;_MainTexU;主纹理;0;0;Create;False;0;0;0;False;0;False;-1;None;8e64da819265c13478784d28fa7193ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-455.9893,402.9399;Inherit;False;Property;_MainColor;主颜色;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;16;-412.4396,571.6682;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-258.2273,304.8393;Inherit;False;Property;_Float2;贴图通道切换;1;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;-100.4275,252.0392;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
WireConnection;28;1;10;0
WireConnection;18;0;28;0
WireConnection;18;1;17;0
WireConnection;20;0;18;0
WireConnection;20;1;14;0
WireConnection;20;2;28;4
WireConnection;22;0;20;0
WireConnection;23;0;22;0
WireConnection;23;3;24;0
WireConnection;0;0;23;0
WireConnection;2;0;1;1
WireConnection;2;1;3;0
WireConnection;2;2;4;0
WireConnection;4;0;5;0
WireConnection;4;1;26;0
WireConnection;26;0;25;3
WireConnection;26;1;6;0
WireConnection;26;2;27;0
WireConnection;7;0;2;0
WireConnection;7;2;8;0
WireConnection;10;0;7;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;14;2;16;0
WireConnection;24;0;29;0
WireConnection;24;1;15;4
WireConnection;24;2;16;4
WireConnection;24;3;7;0
WireConnection;29;0;13;1
WireConnection;29;1;13;4
WireConnection;29;2;30;0
ASEEND*/
//CHKSM=1262438469588042E3090A2521C4FB0AC1D4639E