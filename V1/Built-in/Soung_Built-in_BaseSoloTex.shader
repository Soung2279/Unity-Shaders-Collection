// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/基本效果/通用单贴图材质"
{
	Properties
	{
		[Header(MainTex)]_MainTexU("贴图", 2D) = "white" {}
		[HDR]_BaseColor("颜色", Color) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1
		[Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 0
		[IntRange]_RotatorVal("贴图旋转", Range( 0 , 360)) = 0
		_TexScale("贴图缩放", Range( 0 , 5)) = 1
		_HueSwitch("色相变换", Range( 0 , 1)) = 0
		_SaturationVa("饱和度", Range( 0 , 1.5)) = 1
		_DepthFade("软粒子", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 4.0
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _BlendMode;
			uniform float _CullingMode;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthFade;
			uniform float _HueSwitch;
			uniform sampler2D _MainTexU;
			uniform float4 _MainTexU_ST;
			uniform float _RotatorVal;
			uniform float _TexScale;
			uniform float _SaturationVa;
			uniform float4 _BaseColor;
			uniform float _SwitchP;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
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
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth74 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth74 = abs( ( screenDepth74 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
				float2 uv_MainTexU = i.ase_texcoord2.xy * _MainTexU_ST.xy + _MainTexU_ST.zw;
				float cos51 = cos( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
				float sin51 = sin( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
				float2 rotator51 = mul( uv_MainTexU - float2( 0.5,0.5 ) , float2x2( cos51 , -sin51 , sin51 , cos51 )) + float2( 0.5,0.5 );
				float2 myVarName60 = rotator51;
				float4 tex2DNode1 = tex2D( _MainTexU, ( ( myVarName60 * _TexScale ) + -( _TexScale * 0.5 ) + 0.5 ) );
				float3 hsvTorgb14 = RGBToHSV( (tex2DNode1).rgb );
				float3 hsvTorgb15 = HSVToRGB( float3(( _HueSwitch + hsvTorgb14.x ),( hsvTorgb14.y * _SaturationVa ),hsvTorgb14.z) );
				float3 appendResult69 = (float3(_BaseColor.r , _BaseColor.g , _BaseColor.b));
				float3 appendResult70 = (float3(i.ase_color.r , i.ase_color.g , i.ase_color.b));
				float lerpResult5 = lerp( tex2DNode1.r , tex2DNode1.a , _SwitchP);
				float4 appendResult19 = (float4(( hsvTorgb15 * appendResult69 * appendResult70 ) , ( lerpResult5 * _BaseColor.a * i.ase_color.a )));
				
				
				finalColor = ( saturate( distanceDepth74 ) * (appendResult19).xyzw );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback "Particles/Standard Unlit"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;78;-694.2518,-275.3338;Inherit;False;623.8999;141.6;深度消隐;3;75;77;74;软粒子;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-700.0571,-112.3159;Inherit;False;636;414;色相与饱和度变换;6;15;66;23;64;22;14;贴图颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-1167.461,-252.3126;Inherit;False;267;125;公开材质属性;2;11;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2094.016,-535.9822;Inherit;False;909.8999;802;贴图UV变换;2;43;59;贴图UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-2078.43,-490.1173;Inherit;False;878;362;旋转实现;6;60;42;51;56;45;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2077.052,-118.4895;Inherit;False;717;368;缩放实现;7;61;30;27;28;31;40;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;55;-1802.833,-297.9548;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;6.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;45;-1794.614,-423.713;Inherit;False;Constant;_RotatorInt;RotatorInt;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;56;-2063.378,-302.1489;Inherit;False;Property;_RotatorVal;贴图旋转;5;1;[IntRange];Create;False;0;0;0;False;0;False;0;90;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;51;-1625.778,-443.1502;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-2006.142,-447.3788;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1385.931,-448.6863;Inherit;False;myVarName;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1802.383,-51.25961;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1941.921,79.18849;Inherit;False;Constant;_ScaleInt;ScaleInt;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;28;-1673.974,59.80606;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1801.379,38.80581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1555.122,34.88808;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-1979.031,-72.88651;Inherit;False;60;myVarName;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2067.198,6.696677;Inherit;False;Property;_TexScale;贴图缩放;6;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-418.9601,-62.91815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-414.0571,136.6841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;15;-285.4514,36.07349;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;14;-685.5551,10.79332;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;22;-687.9601,-67.91815;Inherit;False;Property;_HueSwitch;色相变换;7;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-685.0571,155.6841;Inherit;False;Property;_SaturationVa;饱和度;8;0;Create;False;0;0;0;False;0;False;1;1;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-886,83;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;17;-888.2877,5.918488;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1044,194;Inherit;False;Property;_SwitchP;贴图通道切换;4;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;4;-648.1982,483.2492;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;69;-495.6907,342.3528;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-279.6907,534.3528;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1157.99,-206.2554;Inherit;False;Property;_BlendMode;混合模式;3;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1026.527,-205.0391;Inherit;False;Property;_CullingMode;剔除模式;2;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-690.1,312.6999;Inherit;False;Property;_BaseColor;颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1174,6;Inherit;True;Property;_MainTexU;贴图;0;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;70;-496.6907,507.3528;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;440.8915,-108.076;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DepthFade;74;-422.1735,-228.1649;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;77;-196.6085,-229.176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-681.6087,-209.176;Inherit;False;Property;_DepthFade;软粒子;9;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-26.24675,318.5807;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;20;239.8442,26.1873;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;106.8041,31.47732;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;644,-107.5;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/基本效果/通用单贴图材质;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;_SrcBlend;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;4;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;Particles/Standard Unlit;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;55;0;56;0
WireConnection;51;0;42;0
WireConnection;51;1;45;0
WireConnection;51;2;55;0
WireConnection;60;0;51;0
WireConnection;26;0;61;0
WireConnection;26;1;40;0
WireConnection;28;0;27;0
WireConnection;27;0;40;0
WireConnection;27;1;31;0
WireConnection;30;0;26;0
WireConnection;30;1;28;0
WireConnection;30;2;31;0
WireConnection;23;0;22;0
WireConnection;23;1;14;1
WireConnection;66;0;14;2
WireConnection;66;1;64;0
WireConnection;15;0;23;0
WireConnection;15;1;66;0
WireConnection;15;2;14;3
WireConnection;14;0;17;0
WireConnection;5;0;1;1
WireConnection;5;1;1;4
WireConnection;5;2;6;0
WireConnection;17;0;1;0
WireConnection;69;0;2;1
WireConnection;69;1;2;2
WireConnection;69;2;2;3
WireConnection;71;0;5;0
WireConnection;71;1;2;4
WireConnection;71;2;4;4
WireConnection;1;1;30;0
WireConnection;70;0;4;1
WireConnection;70;1;4;2
WireConnection;70;2;4;3
WireConnection;76;0;77;0
WireConnection;76;1;20;0
WireConnection;74;0;75;0
WireConnection;77;0;74;0
WireConnection;68;0;15;0
WireConnection;68;1;69;0
WireConnection;68;2;70;0
WireConnection;20;0;19;0
WireConnection;19;0;68;0
WireConnection;19;3;71;0
WireConnection;0;0;76;0
ASEEND*/
//CHKSM=EF791C1C2A6A095A874CFFA54CFBA3344B935812