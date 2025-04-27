// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/进阶功能/表面流光"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 10
		[Header(MainTex)]_MainTexU("主纹理", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 1
		[Header(LiuGuangTex)]_LiuGuangTex("流光纹理", 2D) = "white" {}
		[HDR]_LGColor("流光颜色", Color) = (1,0.4584408,0,1)
		_LGSpeed("流光速度", Vector) = (0.1,-1,0,0)
		_MaskTex("流光遮罩", 2D) = "white" {}
		[IntRange]_RotatorVal("遮罩旋转", Range( 0 , 360)) = 0
		[Header(NoiseTex)]_NoiseTex("扰动纹理", 2D) = "white" {}
		_NoiseInt("扰动强度", Range( 0 , 1)) = 0.04952465
		_NoiseSpeed("扰动速率", Vector) = (0.5,0.5,0,0)
		[Toggle]_NoiseSwitch("对主纹理扰动", Float) = 0

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
		Cull [_CullingMode]
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
			#define ASE_NEEDS_FRAG_COLOR


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

			uniform float _CullingMode;
			uniform float _BlendMode;
			uniform float4 _MainColor;
			uniform sampler2D _MainTexU;
			uniform float4 _MainTexU_ST;
			uniform sampler2D _LiuGuangTex;
			uniform float4 _LiuGuangTex_ST;
			uniform sampler2D _NoiseTex;
			uniform float2 _NoiseSpeed;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseInt;
			uniform float _NoiseSwitch;
			uniform float _SwitchP;
			uniform float2 _LGSpeed;
			uniform float4 _LGColor;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _RotatorVal;

			
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
				float2 uv_MainTexU = i.ase_texcoord1.xy * _MainTexU_ST.xy + _MainTexU_ST.zw;
				float2 uv_LiuGuangTex = i.ase_texcoord1.xy * _LiuGuangTex_ST.xy + _LiuGuangTex_ST.zw;
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner20 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTex);
				float2 temp_cast_0 = (tex2D( _NoiseTex, panner20 ).r).xx;
				float2 lerpResult19 = lerp( uv_LiuGuangTex , temp_cast_0 , _NoiseInt);
				float2 lerpResult51 = lerp( uv_MainTexU , lerpResult19 , _NoiseSwitch);
				float4 tex2DNode7 = tex2D( _MainTexU, lerpResult51 );
				float lerpResult11 = lerp( tex2DNode7.r , tex2DNode7.a , _SwitchP);
				float4 appendResult49 = (float4((( _MainColor * i.ase_color * tex2DNode7 )).rgb , ( _MainColor.a * i.ase_color.a * lerpResult11 )));
				float2 panner5 = ( 1.0 * _Time.y * _LGSpeed + lerpResult19);
				float2 uv_MaskTex = i.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float cos37 = cos( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
				float sin37 = sin( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
				float2 rotator37 = mul( uv_MaskTex - float2( 0.5,0.5 ) , float2x2( cos37 , -sin37 , sin37 , cos37 )) + float2( 0.5,0.5 );
				
				
				finalColor = ( (appendResult49).xyzw + ( tex2D( _LiuGuangTex, panner5 ).r * _LGColor * tex2D( _MaskTex, rotator37 ).r * lerpResult11 ) );
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
Node;AmplifyShaderEditor.CommentaryNode;44;-1830.115,-46.77792;Inherit;False;1060.314;484.6455;扰动流光;10;4;31;19;14;30;20;21;5;26;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1749.376,449.851;Inherit;False;978;363;旋转实现;6;8;36;38;37;35;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;34;-1473.78,642.015;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;6.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;35;-1465.561,516.2554;Inherit;False;Constant;_RotatorInt;RotatorInt;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode;37;-1296.724,496.8181;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-1677.089,492.5895;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;5;-939.51,-1.500219;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1815.863,185.9287;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;20;-1603.977,191.3288;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;19;-1137.245,167.0293;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1357.303,38.39995;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-1055.229,496.973;Inherit;True;Property;_MaskTex;流光遮罩;8;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;-966.4769,259.8784;Inherit;False;Property;_LGColor;流光颜色;6;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4584408,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;30;-1771.372,308.665;Inherit;False;Property;_NoiseSpeed;扰动速率;12;0;Create;False;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;31;-1133.375,17.66492;Inherit;False;Property;_LGSpeed;流光速度;7;0;Create;False;0;0;0;False;0;False;0.1,-1;0.1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;36;-1740.193,639.288;Inherit;False;Property;_RotatorVal;遮罩旋转;9;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-755.2143,-30.5;Inherit;True;Property;_LiuGuangTex;流光纹理;5;1;[Header];Create;False;1;LiuGuangTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1434.401,162.5003;Inherit;True;Property;_NoiseTex;扰动纹理;10;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;51;-1065.517,-240.9786;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1275.301,-246;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-1221.517,-124.9786;Inherit;False;Property;_NoiseSwitch;对主纹理扰动;13;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-919.2997,-270.0001;Inherit;True;Property;_MainTexU;主纹理;2;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-835.3989,-437.8002;Inherit;False;Property;_MainColor;主颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;40;-632.6149,-434.8684;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-451.5982,-311.9156;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-637.2997,-153;Inherit;False;Property;_SwitchP;贴图通道切换;4;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;11;-479.2999,-196;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-360.6992,-0.5336809;Inherit;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-310.5215,-242.7938;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;42;-328.2166,-316.2677;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-146.5215,-311.7938;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;50;-18.51306,-315.5035;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;190.4785,-19.79382;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;387,-20;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/进阶功能/表面流光;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;1;192.5,-95.5;Inherit;False;Property;_CullingMode;剔除模式;0;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;318.5,-94.5;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1421.406,351.0081;Inherit;False;Property;_NoiseInt;扰动强度;11;0;Create;False;0;0;0;False;0;False;0.04952465;0;0;1;0;1;FLOAT;0
WireConnection;34;0;36;0
WireConnection;37;0;38;0
WireConnection;37;1;35;0
WireConnection;37;2;34;0
WireConnection;5;0;19;0
WireConnection;5;2;31;0
WireConnection;20;0;21;0
WireConnection;20;2;30;0
WireConnection;19;0;4;0
WireConnection;19;1;14;1
WireConnection;19;2;26;0
WireConnection;8;1;37;0
WireConnection;3;1;5;0
WireConnection;14;1;20;0
WireConnection;51;0;6;0
WireConnection;51;1;19;0
WireConnection;51;2;52;0
WireConnection;7;1;51;0
WireConnection;45;0;15;0
WireConnection;45;1;40;0
WireConnection;45;2;7;0
WireConnection;11;0;7;1
WireConnection;11;1;7;4
WireConnection;11;2;10;0
WireConnection;12;0;3;1
WireConnection;12;1;16;0
WireConnection;12;2;8;1
WireConnection;12;3;11;0
WireConnection;47;0;15;4
WireConnection;47;1;40;4
WireConnection;47;2;11;0
WireConnection;42;0;45;0
WireConnection;49;0;42;0
WireConnection;49;3;47;0
WireConnection;50;0;49;0
WireConnection;46;0;50;0
WireConnection;46;1;12;0
WireConnection;0;0;46;0
ASEEND*/
//CHKSM=F5DB6048B14402CA9098B48FE7E2276DF52F2A6B