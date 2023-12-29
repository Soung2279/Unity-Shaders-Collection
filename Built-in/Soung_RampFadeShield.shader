// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/渐变采样深度护盾"
{
	Properties
	{
		_MainTexU("主纹理", 2D) = "white" {}
		[Enum(Screen,0,Model,1)]_UVChoose("UV模式", Float) = 0
		_ScreenUVTillingnSpeed("屏幕长宽/UV速率", Vector) = (8,4.5,0,0)
		_MUVSpeed("纹理UV速率 (后两项留空)", Vector) = (0,0,0,0)
		_FrenWitgh("边缘光宽度", Float) = 0
		_DepthFadeDistance("深度消隐距离", Range( 0 , 5)) = 0
		_RampTexSamp("颜色渐变采样", 2D) = "white" {}
		[HDR]_Color0("颜色强度 (保持白色最佳)", Color) = (1,1,1,1)
		_RampSampleHeight("渐变采样高度 (Y)", Range( 0 , 1)) = 1

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
		Cull Off
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _FrenWitgh;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthFadeDistance;
			uniform float4 _Color0;
			uniform sampler2D _RampTexSamp;
			uniform float _RampSampleHeight;
			uniform sampler2D _MainTexU;
			uniform float4 _ScreenUVTillingnSpeed;
			uniform float2 _MUVSpeed;
			uniform float4 _MainTexU_ST;
			uniform float _UVChoose;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord3.zw = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float dotResult2 = dot( ase_worldViewDir , ase_worldNormal );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth8 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth8 = abs( ( screenDepth8 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
				float temp_output_14_0 = saturate( ( pow( ( 1.0 - abs( dotResult2 ) ) , _FrenWitgh ) + saturate( ( 1.0 - distanceDepth8 ) ) ) );
				float2 appendResult33 = (float2(temp_output_14_0 , _RampSampleHeight));
				float2 appendResult22 = (float2(_ScreenUVTillingnSpeed.x , _ScreenUVTillingnSpeed.y));
				float2 appendResult23 = (float2(_ScreenUVTillingnSpeed.z , _ScreenUVTillingnSpeed.w));
				float2 uv_MainTexU = i.ase_texcoord3.xy * _MainTexU_ST.xy + _MainTexU_ST.zw;
				float2 panner39 = ( 1.0 * _Time.y * _MUVSpeed + uv_MainTexU);
				float2 lerpResult43 = lerp( ( ( (ase_screenPosNorm).xy * appendResult22 ) + ( appendResult23 * _Time.y ) ) , panner39 , _UVChoose);
				
				
				finalColor = ( temp_output_14_0 * ( _Color0 * tex2D( _RampTexSamp, appendResult33 ) ) * tex2D( _MainTexU, lerpResult43 ) * i.ase_color );
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
Node;AmplifyShaderEditor.CommentaryNode;49;-128.4764,-217.6673;Inherit;False;838;403;使用菲涅尔边缘光采样UV;5;28;34;33;29;31;颜色渐变采样;0.7311321,1,0.7318817,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1240.964,-370.0375;Inherit;False;1071.791;556.7419;菲涅尔边缘+深度消隐范围;4;14;13;45;46;护盾边缘实现;0.4292453,0.8630558,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1246.024,233.9411;Inherit;False;1149.172;835.5967;两套UV采样方式;5;44;27;43;37;42;贴图UV采样;1,0.7787951,0.5613208,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1226.622,32.50697;Inherit;False;788;141;深度消隐;4;11;10;9;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1226.274,-325.011;Inherit;False;791;342.9;菲涅尔边缘光;7;2;1;7;6;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-1232.671,758.1566;Inherit;False;423.6255;294.1753;模型UV;3;39;41;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;37;-1235.633,280.987;Inherit;False;664;467;屏幕UV;9;26;17;16;15;24;19;23;22;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;15;-1208.024,325.5838;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;25;-1016.33,673.1641;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-979.324,487.104;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-979.824,577.7043;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-845.3273,578.164;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;16;-1029.223,326.584;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-824.8235,331.7046;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-685.9946,331.6095;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-1217.924,800.4002;Inherit;False;0;27;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;39;-982.6234,804.6013;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;19;-1219.927,500.5056;Inherit;False;Property;_ScreenUVTillingnSpeed;屏幕长宽/UV速率;2;0;Create;False;0;0;0;False;0;False;8,4.5,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;3;-1212.293,-131.8532;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;4;-826.6574,-155.4628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;5;-716.7579,-155.1628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;6;-573.0582,-155.2575;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-715.2582,-86.06301;Inherit;False;Property;_FrenWitgh;边缘光宽度;4;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-1207.492,-282.4533;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;2;-1029.291,-224.4532;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;8;-950.456,69.91355;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1211.558,88.61344;Inherit;False;Property;_DepthFadeDistance;深度消隐距离;5;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;10;-717.4846,70.08585;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-575.195,70.29639;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-415.4241,46.96507;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-298.9697,46.91893;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;152.0791,21.92117;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-112.9786,40.20449;Inherit;False;Property;_RampSampleHeight;渐变采样高度 (Y);8;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;332.1884,-178.482;Inherit;False;Property;_Color0;颜色强度 (保持白色最佳);7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;43;-529.8733,607.4181;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-687.4357,767.1773;Inherit;False;Property;_UVChoose;UV模式;1;1;[Enum];Create;False;0;2;Screen;0;Model;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;581.3925,-25.55489;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;761.6541,279.9564;Float;False;True;-1;2;ASEMaterialInspector;100;5;ASE/12Ramp;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;561.2654,280.3413;Inherit;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;50;275.3083,355.0899;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;31;276.7657,-6.612831;Inherit;True;Property;_RampTexSamp;颜色渐变采样;6;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;41;-1219.473,924.6196;Inherit;False;Property;_MUVSpeed;纹理UV速率 (后两项留空);3;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;27;-381.9938,577.0925;Inherit;True;Property;_MainTexU;主纹理;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;22;0;19;1
WireConnection;22;1;19;2
WireConnection;23;0;19;3
WireConnection;23;1;19;4
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;16;0;15;0
WireConnection;17;0;16;0
WireConnection;17;1;22;0
WireConnection;26;0;17;0
WireConnection;26;1;24;0
WireConnection;39;0;38;0
WireConnection;39;2;41;0
WireConnection;4;0;2;0
WireConnection;5;0;4;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;8;0;9;0
WireConnection;10;0;8;0
WireConnection;11;0;10;0
WireConnection;13;0;6;0
WireConnection;13;1;11;0
WireConnection;14;0;13;0
WireConnection;33;0;14;0
WireConnection;33;1;34;0
WireConnection;43;0;26;0
WireConnection;43;1;39;0
WireConnection;43;2;44;0
WireConnection;29;0;28;0
WireConnection;29;1;31;0
WireConnection;0;0;12;0
WireConnection;12;0;14;0
WireConnection;12;1;29;0
WireConnection;12;2;27;0
WireConnection;12;3;50;0
WireConnection;31;1;33;0
WireConnection;27;1;43;0
ASEEND*/
//CHKSM=6BCFBC7B7DFB725CF5B13E051F8F915327EDA219