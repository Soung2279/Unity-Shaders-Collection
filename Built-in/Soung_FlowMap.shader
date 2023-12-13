// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/FlowMap软溶解"
{
	Properties
	{
		[Header(MainTex)]_MainTextu("主纹理", 2D) = "white" {}
		[HDR]_MainTColor("主纹理颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_Float3("使用A通道", Float) = 0
		[Header(FlowMap (UseRnG))]_FlowMap("FlowMap贴图", 2D) = "white" {}
		[Header(SoftDissolve)]_DissloveTex("溶解贴图", 2D) = "white" {}
		_Dissolve("溶解进度", Range( 0 , 1)) = 0.08407054
		_SoftDis("溶解平滑度", Range( 0.5 , 1)) = 0.8216482
		[Enum(Material,0,Custom1x,1)]_UseDisOrCustom("溶解控制模式", Float) = 0
		[KeywordEnum(SquareMask,GlowMask,None)] _UseCirOrSqa("遮罩模式", Float) = 2
		_Fixval("方形遮罩强度", Range( 1 , 200)) = 13.02583
		_MaskSub("圆形遮罩范围", Range( 0 , 1)) = 0.4800681
		_Float0("圆形遮罩强度", Range( 0 , 10)) = 1.8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
			#pragma shader_feature_local _USECIRORSQA_SQUAREMASK _USECIRORSQA_GLOWMASK _USECIRORSQA_NONE


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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTextu;
			uniform float4 _MainTextu_ST;
			uniform sampler2D _FlowMap;
			uniform float4 _FlowMap_ST;
			uniform float _Dissolve;
			uniform float _UseDisOrCustom;
			uniform float4 _MainTColor;
			uniform float _Float3;
			uniform float _SoftDis;
			uniform sampler2D _DissloveTex;
			uniform float _Fixval;
			uniform float _MaskSub;
			uniform float _Float0;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float2 uv_MainTextu = i.ase_texcoord1.xyz.xy * _MainTextu_ST.xy + _MainTextu_ST.zw;
				float2 uv_FlowMap = i.ase_texcoord1.xyz.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float4 tex2DNode10 = tex2D( _FlowMap, uv_FlowMap );
				float2 appendResult12 = (float2(tex2DNode10.r , tex2DNode10.g));
				float3 texCoord27 = i.ase_texcoord1.xyz;
				texCoord27.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult25 = lerp( _Dissolve , texCoord27.z , _UseDisOrCustom);
				float2 lerpResult9 = lerp( uv_MainTextu , appendResult12 , lerpResult25);
				float4 tex2DNode1 = tex2D( _MainTextu, lerpResult9 );
				float lerpResult67 = lerp( tex2DNode1.r , tex2DNode1.a , _Float3);
				float smoothstepResult20 = smoothstep( ( 1.0 - _SoftDis ) , _SoftDis , ( tex2D( _DissloveTex, lerpResult9 ).r + 1.0 + ( lerpResult25 * -2.0 ) ));
				float2 texCoord46 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord47 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord29 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_USECIRORSQA_SQUAREMASK)
				float staticSwitch69 = saturate( ( ( 1.0 - saturate( texCoord46.x ) ) * ( 1.0 - saturate( texCoord46.y ) ) * saturate( texCoord47.x ) * saturate( texCoord47.y ) * _Fixval ) );
				#elif defined(_USECIRORSQA_GLOWMASK)
				float staticSwitch69 = saturate( ( ( ( 1.0 - distance( texCoord29 , float2( 0.5,0.5 ) ) ) - _MaskSub ) * _Float0 ) );
				#elif defined(_USECIRORSQA_NONE)
				float staticSwitch69 = 1.0;
				#else
				float staticSwitch69 = 1.0;
				#endif
				float4 appendResult5 = (float4((( tex2DNode1 * i.ase_color * _MainTColor )).rgba.rgb , ( lerpResult67 * i.ase_color.a * smoothstepResult20 * staticSwitch69 * _MainTColor.a )));
				
				
				finalColor = appendResult5;
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
Node;AmplifyShaderEditor.CommentaryNode;66;-1411.77,-222.5827;Inherit;False;573.2;367.8;只使用R/G通道运算;4;8;10;12;9;FlowMap扭动UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1296.104,984.3634;Inherit;False;1043.573;364.0606;圆形遮罩;9;29;30;31;34;40;37;32;71;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1295.367,642.7999;Inherit;False;953.0721;317.353;方框遮罩;11;51;50;56;55;54;53;52;49;48;47;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-514.3868,288.9019;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;-988.5009,-48.99993;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1113.499,-25;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1319.499,-179.9998;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-1471.126,424.6002;Inherit;False;Property;_UseDisOrCustom;溶解控制模式;7;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1523.844,285.6051;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-1580.891,212.0363;Inherit;False;Property;_Dissolve;溶解进度;5;0;Create;False;0;0;0;False;0;False;0.08407054;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;-1291.228,334.0141;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-715.4103,537.8694;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-849.878,556.6014;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;3;-247.6829,-45.31483;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-66.68326,-69.31483;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;4;67.31671,-74.31483;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;20;-120.508,289.9027;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;344.1734,-68.77293;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;136.5168,27.58517;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;563.5978,-68.31482;Float;False;True;-1;2;ASEMaterialInspector;100;5;ASE/FlowMap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ColorNode;65;-287.261,118.9775;Inherit;False;Property;_MainTColor;主纹理颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;22;-265.7416,312.6208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-515.3772,-1.12146;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-661.3772,109.8785;Inherit;False;Property;_Float3;使用A通道;2;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1259.438,699.4;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-1260.548,818.1416;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;48;-1047.435,754.3983;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;49;-1048.138,685.905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;52;-922.1359,683.905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-921.433,753.3984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;-467.3948,733.9941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;51;-1046.545,888.1421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-921.8232,824.0669;Inherit;False;Property;_Fixval;方形遮罩强度;9;0;Create;False;0;0;0;False;0;False;13.02583;150;1;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;-1047.138,817.905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;30;-1042.292,1043.851;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1257.949,1043.463;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;31;-1213.695,1163.215;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-706.3715,1044.008;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-846.4902,1044.217;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1054.492,1258.215;Inherit;False;Property;_MaskSub;圆形遮罩范围;10;0;Create;False;0;0;0;False;0;False;0.4800681;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-839.3715,1138.008;Inherit;False;Property;_Float0;圆形遮罩强度;11;0;Create;False;0;0;0;False;0;False;1.8;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-569.4913,1044.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;40;-444.0715,1044.99;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-537.9698,455.6991;Inherit;False;Property;_SoftDis;溶解平滑度;6;0;Create;False;0;0;0;False;0;False;0.8216482;0;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-720.7305,452.7795;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1395.499,-53.99991;Inherit;True;Property;_FlowMap;FlowMap贴图;3;1;[Header];Create;False;1;FlowMap (UseRnG);0;0;False;0;False;-1;c5e136738c936ff41b9a74e73c141944;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-807.6022,-77.31483;Inherit;True;Property;_MainTextu;主纹理;0;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;201b5292b9e490248a032c247372b5d1;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-662.11,734.0908;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-828.6608,261.3694;Inherit;True;Property;_DissloveTex;溶解贴图;4;1;[Header];Create;False;1;SoftDissolve;0;0;False;0;False;-1;ef4eb6d271748b4478d1a301146f7faa;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;69;-141.2776,732.6913;Inherit;False;Property;_UseCirOrSqa;遮罩模式;8;0;Create;False;0;0;0;False;0;False;0;2;2;True;;KeywordEnum;3;SquareMask;GlowMask;None;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-303.3882,781.2935;Inherit;False;Constant;_DefaultMask;DefaultMask;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;16;0;14;1
WireConnection;16;1;15;0
WireConnection;16;2;18;0
WireConnection;9;0;8;0
WireConnection;9;1;12;0
WireConnection;9;2;25;0
WireConnection;12;0;10;1
WireConnection;12;1;10;2
WireConnection;25;0;13;0
WireConnection;25;1;27;3
WireConnection;25;2;28;0
WireConnection;18;0;25;0
WireConnection;18;1;17;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;2;2;65;0
WireConnection;4;0;2;0
WireConnection;20;0;16;0
WireConnection;20;1;22;0
WireConnection;20;2;21;0
WireConnection;5;0;4;0
WireConnection;5;3;6;0
WireConnection;6;0;67;0
WireConnection;6;1;3;4
WireConnection;6;2;20;0
WireConnection;6;3;69;0
WireConnection;6;4;65;4
WireConnection;0;0;5;0
WireConnection;22;0;21;0
WireConnection;67;0;1;1
WireConnection;67;1;1;4
WireConnection;67;2;68;0
WireConnection;48;0;46;2
WireConnection;49;0;46;1
WireConnection;52;0;49;0
WireConnection;53;0;48;0
WireConnection;56;0;55;0
WireConnection;51;0;47;2
WireConnection;50;0;47;1
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;71;0;32;0
WireConnection;71;1;34;0
WireConnection;32;0;30;0
WireConnection;37;0;71;0
WireConnection;37;1;72;0
WireConnection;40;0;37;0
WireConnection;1;1;9;0
WireConnection;55;0;52;0
WireConnection;55;1;53;0
WireConnection;55;2;50;0
WireConnection;55;3;51;0
WireConnection;55;4;54;0
WireConnection;14;1;9;0
WireConnection;69;1;56;0
WireConnection;69;0;40;0
WireConnection;69;2;70;0
ASEEND*/
//CHKSM=005019442B690D12D9CD61735E78F6FBFC12C368