// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/自动故障扰动"
{
	Properties
	{
		[HDR]_MainColor("整体颜色", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTexU1("主纹理", 2D) = "white" {}
		_NoiseTex("扰动贴图", 2D) = "white" {}
		[Enum(U,0,V,1)]_NoisePivot("扰动方向 (匹配偏移量设置)", Float) = 0
		_NoiseScale("扰动强度", Range( 0 , 0.1)) = 0.1
		_RB_Offset("红蓝偏移量 (RU_RV_BU_BV)", Vector) = (0.05,0,0,0)
		[Enum(Manual,0,Auto,1)]_NoiseMode("扰动模式", Float) = 0
		_TimeScale("自动偏移间隔", Float) = 2
		_NoiseSpeed("扰动速率", Vector) = (1,1,0,0)

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

			uniform sampler2D _MainTexU1;
			uniform sampler2D _NoiseTex;
			uniform float2 _NoiseSpeed;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseScale;
			uniform float _TimeScale;
			uniform float _NoiseMode;
			uniform float _NoisePivot;
			uniform float4 _RB_Offset;
			uniform float4 _MainColor;

			
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
				float2 texCoord11 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner9 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTex);
				float mulTime39 = _Time.y * _TimeScale;
				float lerpResult41 = lerp( _NoiseScale , ( _NoiseScale * sin( mulTime39 ) ) , _NoiseMode);
				float temp_output_48_0 = saturate( lerpResult41 );
				float temp_output_14_0 = ( (-0.5 + (tex2D( _NoiseTex, panner9 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * temp_output_48_0 );
				float lerpResult53 = lerp( ( texCoord11.x + temp_output_14_0 ) , texCoord11.x , _NoisePivot);
				float lerpResult54 = lerp( texCoord11.y , ( texCoord11.y + temp_output_14_0 ) , _NoisePivot);
				float2 appendResult13 = (float2(lerpResult53 , lerpResult54));
				float4 break20 = ( (0.0 + (temp_output_48_0 - 0.0) * (1.0 - 0.0) / (0.1 - 0.0)) * _RB_Offset );
				float2 appendResult26 = (float2(break20.x , break20.y));
				float4 tex2DNode4 = tex2D( _MainTexU1, appendResult13 );
				float2 appendResult27 = (float2(break20.z , break20.w));
				float4 appendResult30 = (float4(tex2D( _MainTexU1, ( appendResult13 + appendResult26 ) ).r , tex2DNode4.g , tex2D( _MainTexU1, ( appendResult13 + appendResult27 ) ).b , tex2DNode4.a));
				
				
				finalColor = ( i.ase_color * appendResult30 * _MainColor );
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
Node;AmplifyShaderEditor.PannerNode;9;-1917.814,121.3476;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2161.557,116.5701;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;10;-2088.814,239.3477;Inherit;False;Property;_NoiseSpeed;扰动速率;8;0;Create;False;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;27;-651.9914,387.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-651.9914,293.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-460.9824,153.3174;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-461.4291,360.2454;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-908.4456,307.7872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;8;-1731.218,92.67458;Inherit;True;Property;_NoiseTex;扰动贴图;2;0;Create;False;0;0;0;False;0;False;-1;None;0222f30b8947b4a47b30891c67383f40;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1640.33,475.9615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;39;-1917.55,499.9915;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;46;-1757.787,499.6698;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2070.55,495.9915;Inherit;False;Property;_TimeScale;自动偏移间隔;7;0;Create;False;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1637.397,575.9688;Inherit;False;Property;_NoiseMode;扰动模式;6;1;[Enum];Create;False;0;2;Manual;0;Auto;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;15;-1108.842,307.9935;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1906.621,412.3318;Inherit;False;Property;_NoiseScale;扰动强度;4;0;Create;False;0;0;0;False;0;False;0.1;0.0128;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-1486.07,418.544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-1339.9,418.8646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1244.571,122.495;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;31;-1434.373,123;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1068.429,97.80939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-697.1879,16.22712;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;54;-881.5465,40.98477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;53;-888.5465,-144.0152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1020.467,-143.5107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-783.982,307.2344;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;55;-1128.688,-7.643436;Inherit;False;Property;_NoisePivot;扰动方向 (匹配偏移量设置);3;1;[Enum];Create;False;0;2;U;0;V;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;272.3496,19.77707;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;57;240.2148,-151.8367;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;496.3331,-6.130898;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;59;208.7787,165.3141;Inherit;False;Property;_MainColor;整体颜色;0;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;17;-1110.394,476.3322;Inherit;False;Property;_RB_Offset;红蓝偏移量 (RU_RV_BU_BV);5;0;Create;False;0;0;0;False;0;False;0.05,0,0,0;0.05,0.05,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;711.7939,-5.987699;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/自动故障扰动;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;32;-77.57082,-199.4283;Inherit;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-79.42696,-9.54605;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-78.42696,182.4539;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1356.975,-8.81764;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-310.0752,-198.7612;Inherit;True;Property;_MainTexU1;主纹理;1;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;None;7e8dfd0c9de33d446b68aa25b33d466f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;9;0;2;0
WireConnection;9;2;10;0
WireConnection;27;0;20;2
WireConnection;27;1;20;3
WireConnection;26;0;20;0
WireConnection;26;1;20;1
WireConnection;28;0;13;0
WireConnection;28;1;26;0
WireConnection;29;0;13;0
WireConnection;29;1;27;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;8;1;9;0
WireConnection;45;0;7;0
WireConnection;45;1;46;0
WireConnection;39;0;40;0
WireConnection;46;0;39;0
WireConnection;15;0;48;0
WireConnection;41;0;7;0
WireConnection;41;1;45;0
WireConnection;41;2;42;0
WireConnection;48;0;41;0
WireConnection;14;0;31;0
WireConnection;14;1;48;0
WireConnection;31;0;8;1
WireConnection;52;0;11;2
WireConnection;52;1;14;0
WireConnection;13;0;53;0
WireConnection;13;1;54;0
WireConnection;54;0;11;2
WireConnection;54;1;52;0
WireConnection;54;2;55;0
WireConnection;53;0;12;0
WireConnection;53;1;11;1
WireConnection;53;2;55;0
WireConnection;12;0;11;1
WireConnection;12;1;14;0
WireConnection;20;0;16;0
WireConnection;30;0;32;1
WireConnection;30;1;4;2
WireConnection;30;2;3;3
WireConnection;30;3;4;4
WireConnection;58;0;57;0
WireConnection;58;1;30;0
WireConnection;58;2;59;0
WireConnection;0;0;58;0
WireConnection;32;0;5;0
WireConnection;32;1;28;0
WireConnection;4;0;5;0
WireConnection;4;1;13;0
WireConnection;3;0;5;0
WireConnection;3;1;29;0
ASEEND*/
//CHKSM=D572293933ECE4C731738D0EE7CFC18B1B05E5AF