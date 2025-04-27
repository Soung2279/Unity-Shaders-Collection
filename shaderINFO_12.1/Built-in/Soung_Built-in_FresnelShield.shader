// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/简易菲尼尔护盾"
{
	Properties
	{
		[Enum(Addtive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[HDR]_Color0("主颜色", Color) = (1,1,1,1)
		_TextureSample0("流动纹理", 2D) = "white" {}
		[KeywordEnum(R,A)] _Keyword0("切换贴图通道", Float) = 0
		Uspeed("U速度", Float) = 0
		_Vspeed("V速度", Float) = 0
		_Freset("菲涅尔整体/边缘/强度", Vector) = (0,1,5,0)

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
		Cull [_CullingMode]
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
			#pragma shader_feature_local _KEYWORD0_R _KEYWORD0_A


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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullingMode;
			uniform float _BlendMode;
			uniform float4 _Color0;
			uniform sampler2D _TextureSample0;
			uniform float Uspeed;
			uniform float _Vspeed;
			uniform float4 _TextureSample0_ST;
			uniform float3 _Freset;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_color = v.color;
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
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult18 = (float2(Uspeed , _Vspeed));
				float2 uv_TextureSample0 = i.ase_texcoord1.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float2 panner9 = ( 1.0 * _Time.y * appendResult18 + uv_TextureSample0);
				float4 tex2DNode4 = tex2D( _TextureSample0, panner9 );
				#if defined(_KEYWORD0_R)
				float staticSwitch5 = tex2DNode4.r;
				#elif defined(_KEYWORD0_A)
				float staticSwitch5 = tex2DNode4.a;
				#else
				float staticSwitch5 = tex2DNode4.r;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode1 = ( _Freset.x + _Freset.y * pow( 1.0 - fresnelNdotV1, _Freset.z ) );
				
				
				finalColor = ( i.ase_color * _Color0 * staticSwitch5 * saturate( fresnelNode1 ) );
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
Node;AmplifyShaderEditor.CommentaryNode;27;-491.0801,102.9186;Inherit;False;272;133;Comment;2;26;25;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;9;-962.3602,-139.4378;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1263.08,57.91864;Inherit;False;Property;_Vspeed;V速度;7;0;Create;False;0;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1259.08,-19.08136;Inherit;False;Property;Uspeed;U速度;6;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1120.08,5.91864;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1252.36,-144.4378;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-789.4805,-167.8778;Inherit;True;Property;_TextureSample0;流动纹理;4;0;Create;False;0;0;0;False;0;False;-1;None;0222f30b8947b4a47b30891c67383f40;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;5;-483.3632,-96.14751;Inherit;False;Property;_Keyword0;切换贴图通道;5;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-790.2618,21.78886;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;2;-499.1979,22.81381;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;22;-996.0801,40.91864;Inherit;False;Property;_Freset;菲涅尔整体/边缘/强度;8;0;Create;False;0;0;0;False;0;False;0,1,5;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;7;-502.3796,-270.7159;Inherit;False;Property;_Color0;主颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,261.0196,1024,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;6;-469.94,-439.4973;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-268.1979,-138.1862;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;16;-137.8,-139.3001;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/简易菲尼尔护盾;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-347.0801,149.9186;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Addtive;1;AlphaBlend;10;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-475.0801,149.9186;Inherit;False;Property;_CullingMode;剔除模式;2;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
WireConnection;9;0;8;0
WireConnection;9;2;18;0
WireConnection;18;0;19;0
WireConnection;18;1;20;0
WireConnection;4;1;9;0
WireConnection;5;1;4;1
WireConnection;5;0;4;4
WireConnection;1;1;22;1
WireConnection;1;2;22;2
WireConnection;1;3;22;3
WireConnection;2;0;1;0
WireConnection;3;0;6;0
WireConnection;3;1;7;0
WireConnection;3;2;5;0
WireConnection;3;3;2;0
WireConnection;16;0;3;0
ASEEND*/
//CHKSM=54657A8437EB7B7D76F5279600CAD1CEED30911D