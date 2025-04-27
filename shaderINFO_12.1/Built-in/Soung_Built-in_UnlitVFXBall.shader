// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/无光照扭曲球体"
{
	Properties
	{
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Header(MainTex)]_MainTex("主纹理", 2D) = "white" {}
		[HDR]_Color("主纹理颜色", Color) = (1,1,1,1)
		[Enum(Local,0,Screen,1)]_MTSMode("主纹理UV模式", Float) = 0
		_MTSTilingOffset("纹理重铺与偏移", Vector) = (1,1,0,0)
		[Header(Distortion_Tex)]_NiuquTex("扭曲贴图", 2D) = "white" {}
		_NiuquPower("扭曲强度", Float) = 0
		_UVSpeeds("主纹理与扭曲速度", Vector) = (0,0,0,0)
		[HDR]_FresnelColor("菲涅尔颜色", Color) = (0,0.2464237,1,1)
		_FresnelScale("菲涅尔范围", Float) = 1
		_FresnelPower("菲涅尔强度", Float) = 6

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
		ZWrite Off
		ZTest LEqual
		
		
		
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullingMode;
			uniform float _BlendMode;
			uniform sampler2D _MainTex;
			uniform float4 _UVSpeeds;
			uniform float4 _MainTex_ST;
			uniform float4 _MTSTilingOffset;
			uniform float _MTSMode;
			uniform float _NiuquPower;
			uniform sampler2D _NiuquTex;
			uniform float4 _NiuquTex_ST;
			uniform float4 _Color;
			uniform float _FresnelScale;
			uniform float _FresnelPower;
			uniform float4 _FresnelColor;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_color = v.color;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord3.w = 0;
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
				float2 appendResult61 = (float2(_UVSpeeds.x , _UVSpeeds.y));
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 screenPos = i.ase_texcoord2;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult57 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 appendResult55 = (float2(_MTSTilingOffset.x , _MTSTilingOffset.y));
				float2 appendResult56 = (float2(_MTSTilingOffset.z , _MTSTilingOffset.w));
				float2 lerpResult76 = lerp( uv_MainTex , (appendResult57*appendResult55 + appendResult56) , _MTSMode);
				float2 appendResult88 = (float2(_UVSpeeds.z , _UVSpeeds.w));
				float2 uv_NiuquTex = i.ase_texcoord1.xy * _NiuquTex_ST.xy + _NiuquTex_ST.zw;
				float2 panner92 = ( 1.0 * _Time.y * appendResult88 + uv_NiuquTex);
				float2 panner62 = ( 1.0 * _Time.y * appendResult61 + ( lerpResult76 + ( _NiuquPower * (-0.5 + (tex2D( _NiuquTex, panner92 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) ));
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode1 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV1, _FresnelPower ) );
				float temp_output_49_0 = saturate( fresnelNode1 );
				
				
				finalColor = ( i.ase_color * ( ( ( tex2D( _MainTex, panner62 ) * _Color ) * ( 1.0 - temp_output_49_0 ) ) + ( temp_output_49_0 * _FresnelColor ) ) );
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
Node;AmplifyShaderEditor.CommentaryNode;84;-1273.475,-371.2359;Inherit;False;855.3;335.3;Comment;7;2;81;3;19;18;1;49;菲涅尔;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2052.858,-949.3368;Inherit;False;1621.915;564.9651;UV;7;80;61;38;62;79;4;101;主纹理;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;79;-2038.879,-904.9755;Inherit;False;749.861;509.6483;切换主纹理UV模式;9;76;77;78;54;59;56;55;57;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;53;-2028.726,-763.7961;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1805.629,-734.696;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-1802.654,-588.749;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;-1802.254,-490.249;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;59;-1634.886,-735.7475;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;54;-1971.751,-583.5491;Inherit;False;Property;_MTSTilingOffset;纹理重铺与偏移;5;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-1660.333,-862.0798;Inherit;False;0;38;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;-1607.787,-614.3607;Inherit;False;Property;_MTSMode;主纹理UV模式;4;1;[Enum];Create;False;0;2;Local;0;Screen;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;76;-1434.061,-759.1322;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;49;-849.4313,-301.3903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-1118.94,-217.4251;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;3;False;3;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1263.858,-190.0359;Float;False;Property;_FresnelScale;菲涅尔范围;10;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-852.2857,-216.4307;Float;False;Property;_FresnelColor;菲涅尔颜色;9;1;[HDR];Create;False;0;0;0;False;0;False;0,0.2464237,1,1;2.190492,2.124009,9.189588,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;81;-701.2079,-329.2269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-545.0278,-298.593;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;85;-2338.062,-372.7121;Inherit;False;1044.604;296.1412;扭曲;7;98;96;95;94;92;88;90;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;90;-2326.596,-310.109;Inherit;False;0;94;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;88;-2243.504,-188.158;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;92;-2106.169,-304.953;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;95;-1604.472,-250.7146;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1570.236,-327.5891;Inherit;False;Property;_NiuquPower;扭曲强度;7;0;Create;False;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-1429.004,-302.3048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1261.615,-758.5863;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-1264.553,-665.1993;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;62;-1119.531,-759.7028;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-640.9716,-650.9083;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;4;-933.9976,-587.1821;Float;False;Property;_Color;主纹理颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;102;-2670.083,-697.0955;Inherit;False;Property;_UVSpeeds;主纹理与扭曲速度;8;0;Create;False;0;0;0;False;0;False;0,0,0,0;0.2,0.2,0.1,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-195.3741,-319.5615;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;82;-160.2419,-494.2519;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;31.91838,-343.1931;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-395.6693,-650.9942;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;73;162.3594,-343.5887;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/无光照扭曲球体;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;0;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;38;-942.9887,-788.822;Inherit;True;Property;_MainTex;主纹理;2;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;70429964131645f4abf190ff44a2ae31;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;-1933.514,-333.7289;Inherit;True;Property;_NiuquTex;扭曲贴图;6;1;[Header];Create;False;1;Distortion_Tex;0;0;False;0;False;-1;None;b4eb66c2bc68c2a4ba2c355f07faf4db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;108;-393.4103,-729.9749;Inherit;False;Property;_CullingMode;剔除模式;1;1;[Enum];Create;False;0;2;Option1;0;Option2;1;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-391.4103,-806.9749;Inherit;False;Property;_BlendMode;混合模式;0;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1262.206,-112.6023;Float;False;Property;_FresnelPower;菲涅尔强度;11;0;Create;False;0;0;0;False;0;False;6;4.94;0;0;0;1;FLOAT;0
WireConnection;57;0;53;1
WireConnection;57;1;53;2
WireConnection;55;0;54;1
WireConnection;55;1;54;2
WireConnection;56;0;54;3
WireConnection;56;1;54;4
WireConnection;59;0;57;0
WireConnection;59;1;55;0
WireConnection;59;2;56;0
WireConnection;76;0;78;0
WireConnection;76;1;59;0
WireConnection;76;2;77;0
WireConnection;49;0;1;0
WireConnection;1;2;18;0
WireConnection;1;3;19;0
WireConnection;81;0;49;0
WireConnection;2;0;49;0
WireConnection;2;1;3;0
WireConnection;88;0;102;3
WireConnection;88;1;102;4
WireConnection;92;0;90;0
WireConnection;92;2;88;0
WireConnection;95;0;94;1
WireConnection;98;0;96;0
WireConnection;98;1;95;0
WireConnection;101;0;76;0
WireConnection;101;1;98;0
WireConnection;61;0;102;1
WireConnection;61;1;102;2
WireConnection;62;0;101;0
WireConnection;62;2;61;0
WireConnection;80;0;38;0
WireConnection;80;1;4;0
WireConnection;6;0;37;0
WireConnection;6;1;2;0
WireConnection;83;0;82;0
WireConnection;83;1;6;0
WireConnection;37;0;80;0
WireConnection;37;1;81;0
WireConnection;73;0;83;0
WireConnection;38;1;62;0
WireConnection;94;1;92;0
ASEEND*/
//CHKSM=0FA2A2AF99715C5AEE9EF6F1D51852F1B43DE43E