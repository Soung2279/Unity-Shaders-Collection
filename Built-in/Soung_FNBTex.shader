// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/双面材质(面具)"
{
	Properties
	{
		[Header(FrontTex)]_MainTexU("正面纹理", 2D) = "white" {}
		_FresnelSet("菲涅尔设置", Vector) = (0,1,5,0)
		[HDR]_FreColor("菲涅尔颜色", Color) = (1,1,1,1)
		[Header(BackTex)]_BackTex("背面纹理", 2D) = "white" {}
		_BackTilnSpeed("背面重铺与速率", Vector) = (1,1,0.2,0)
		[Header(NoiseTex)]_NoiseTex("扭曲贴图", 2D) = "white" {}
		_NoisePwr("扭曲强度", Float) = 0.2
		_NoiseTilnSpeed1("扭曲重铺与速率", Vector) = (1,1,0.2,0)
		[Header(AddTex)]_AddTex("叠加贴图", 2D) = "white" {}
		[HDR]_AddColor("叠加颜色", Color) = (1,1,1,1)
		_AddTilnSpeed2("叠加重铺与速率", Vector) = (1,1,0,-0.2)
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
		Cull Off
		ColorMask RGBA
		ZWrite On
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTexU;
			uniform float4 _MainTexU_ST;
			uniform float3 _FresnelSet;
			uniform float4 _FreColor;
			uniform sampler2D _BackTex;
			uniform float4 _BackTilnSpeed;
			uniform sampler2D _AddTex;
			uniform float4 _AddTilnSpeed2;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTilnSpeed1;
			uniform float _NoisePwr;
			uniform float4 _AddColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
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
			
			fixed4 frag (v2f i , bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTexU = i.ase_texcoord1.xy * _MainTexU_ST.xy + _MainTexU_ST.zw;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV4 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode4 = ( _FresnelSet.x + _FresnelSet.y * pow( 1.0 - fresnelNdotV4, _FresnelSet.z ) );
				float2 appendResult19 = (float2(_BackTilnSpeed.z , _BackTilnSpeed.w));
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_11_0 = (ase_screenPosNorm).xy;
				float2 appendResult18 = (float2(_BackTilnSpeed.x , _BackTilnSpeed.y));
				float2 panner13 = ( 1.0 * _Time.y * appendResult19 + ( temp_output_11_0 * appendResult18 ));
				float2 appendResult39 = (float2(_AddTilnSpeed2.z , _AddTilnSpeed2.w));
				float2 appendResult38 = (float2(_AddTilnSpeed2.x , _AddTilnSpeed2.y));
				float2 panner40 = ( 1.0 * _Time.y * appendResult39 + ( temp_output_11_0 * appendResult38 ));
				float2 appendResult23 = (float2(_NoiseTilnSpeed1.z , _NoiseTilnSpeed1.w));
				float2 appendResult21 = (float2(_NoiseTilnSpeed1.x , _NoiseTilnSpeed1.y));
				float2 panner24 = ( 1.0 * _Time.y * appendResult23 + ( temp_output_11_0 * appendResult21 ));
				float2 temp_cast_0 = (tex2D( _NoiseTex, panner24 ).r).xx;
				float2 lerpResult44 = lerp( panner40 , temp_cast_0 , _NoisePwr);
				float4 switchResult1 = (((ase_vface>0)?(( tex2D( _MainTexU, uv_MainTexU ) + ( saturate( fresnelNode4 ) * _FreColor ) )):(( tex2D( _BackTex, panner13 ) + ( tex2D( _AddTex, lerpResult44 ) * _AddColor ) ))));
				
				
				finalColor = switchResult1;
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
Node;AmplifyShaderEditor.ScreenPosInputsNode;10;-1601.568,402.0339;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;-1421.568,402.0339;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;4;-780.2894,128.2119;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;6;-494.2891,128.2119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-367.239,128.1868;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;3;-923.2903,147.2119;Inherit;False;Property;_FresnelSet;菲涅尔设置;1;0;Create;False;0;0;0;False;0;False;0,1,5;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-187.5098,52.9617;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;538.8058,54.4248;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/双面材质(面具);0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SwitchByFaceNode;1;336.948,54.27647;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1080.542,474.4335;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;17;-1247.542,477.4335;Inherit;False;Property;_BackTilnSpeed;背面重铺与速率;4;0;Create;False;0;0;0;False;0;False;1,1,0.2,0;1,1,0.2,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;19;-1079.542,571.4335;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;13;-818.8041,546.9517;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-940.3906,404.9405;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1224.612,768.7283;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1223.612,865.7283;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;24;-962.8737,841.2465;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1080.615,718.4742;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;22;-1391.612,771.7283;Inherit;False;Property;_NoiseTilnSpeed1;扭曲重铺与速率;7;0;Create;False;0;0;0;False;0;False;1,1,0.2,0;1,1,0.2,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;38;-1220.634,1028.213;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1219.634,1125.212;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1076.636,977.9607;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;40;-1005.017,1100.731;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;42;-1387.633,1031.213;Inherit;False;Property;_AddTilnSpeed2;叠加重铺与速率;10;0;Create;False;0;0;0;False;0;False;1,1,0,-0.2;1,1,0,-0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;44;-457.968,942.6797;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-643.2443,1001.634;Inherit;False;Property;_NoisePwr;扭曲强度;6;0;Create;False;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-12.74276,917.5216;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;36;-228.9193,1105.834;Inherit;False;Property;_AddColor;叠加颜色;9;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;156.0886,473.1336;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-498.7517,222.6528;Inherit;False;Property;_FreColor;菲涅尔颜色;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-648.8035,472.166;Inherit;True;Property;_BackTex;背面纹理;3;1;[Header];Create;False;1;BackTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-522.687,-58.69663;Inherit;True;Property;_MainTexU;正面纹理;0;1;[Header];Create;False;1;FrontTex;0;0;False;0;False;-1;None;8e64da819265c13478784d28fa7193ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-791.1195,811.7097;Inherit;True;Property;_NoiseTex;扭曲贴图;5;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;None;ace1b3ce760c86143b3bcbf4d61986f1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-316.0772,912.159;Inherit;True;Property;_AddTex;叠加贴图;8;1;[Header];Create;False;1;AddTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;11;0;10;0
WireConnection;4;1;3;1
WireConnection;4;2;3;2
WireConnection;4;3;3;3
WireConnection;6;0;4;0
WireConnection;8;0;6;0
WireConnection;8;1;9;0
WireConnection;7;0;2;0
WireConnection;7;1;8;0
WireConnection;0;0;1;0
WireConnection;1;0;7;0
WireConnection;1;1;43;0
WireConnection;18;0;17;1
WireConnection;18;1;17;2
WireConnection;19;0;17;3
WireConnection;19;1;17;4
WireConnection;13;0;20;0
WireConnection;13;2;19;0
WireConnection;20;0;11;0
WireConnection;20;1;18;0
WireConnection;21;0;22;1
WireConnection;21;1;22;2
WireConnection;23;0;22;3
WireConnection;23;1;22;4
WireConnection;24;0;25;0
WireConnection;24;2;23;0
WireConnection;25;0;11;0
WireConnection;25;1;21;0
WireConnection;38;0;42;1
WireConnection;38;1;42;2
WireConnection;39;0;42;3
WireConnection;39;1;42;4
WireConnection;41;0;11;0
WireConnection;41;1;38;0
WireConnection;40;0;41;0
WireConnection;40;2;39;0
WireConnection;44;0;40;0
WireConnection;44;1;32;1
WireConnection;44;2;35;0
WireConnection;37;0;33;0
WireConnection;37;1;36;0
WireConnection;43;0;12;0
WireConnection;43;1;37;0
WireConnection;12;1;13;0
WireConnection;32;1;24;0
WireConnection;33;1;44;0
ASEEND*/
//CHKSM=83CE86CB60FC6585CB4157E554E380842CEB4BA8