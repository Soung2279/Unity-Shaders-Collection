// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/深度护盾"
{
	Properties
	{
		[Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 0
		[Header(MainTex)]_TextureSample0("纹理", 2D) = "white" {}
		[Enum(R,0,A,1)]_MainTexP("贴图通道", Float) = 0
		[HDR]_Color0("纹理颜色", Color) = (1,1,1,1)
		_Float0("深度距离", Range( 0 , 5)) = 1
		[Enum(Custom1x,0,Material,1)]_Usecustom("深度控制模式", Float) = 0
		[Enum(Local,0,Screen,1)]_Shield("UV模式", Float) = 1
		_UVSetflow("屏幕UV与流动速度", Vector) = (1,1,0,0)
		[Header(Distortion)]_NIUQU_Tex("扭曲纹理", 2D) = "white" {}
		_NIUQU_Power("扭曲强度", Range( 0 , 1)) = 0
		_Niuqu_U_speed("扭曲U速度", Float) = 0
		_Niuqu_V_speed("扭曲V速度", Float) = 0

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
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _BlendMode;
			uniform float _CullingMode;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Float0;
			uniform float _Usecustom;
			uniform float4 _Color0;
			uniform sampler2D _TextureSample0;
			uniform float4 _UVSetflow;
			uniform float4 _TextureSample0_ST;
			uniform float _Shield;
			uniform float _NIUQU_Power;
			uniform sampler2D _NIUQU_Tex;
			uniform float _Niuqu_U_speed;
			uniform float _Niuqu_V_speed;
			uniform float _MainTexP;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
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
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 texCoord63 = i.ase_texcoord2;
				texCoord63.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult65 = lerp( texCoord63.x , _Float0 , _Usecustom);
				float screenDepth1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth1 = abs( ( screenDepth1 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( lerpResult65 ) );
				float2 appendResult39 = (float2(_UVSetflow.z , _UVSetflow.w));
				float2 uv_TextureSample0 = i.ase_texcoord3.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float2 appendResult38 = (float2(_UVSetflow.x , _UVSetflow.y));
				float2 lerpResult18 = lerp( uv_TextureSample0 , ( (ase_screenPosNorm).xy * appendResult38 ) , _Shield);
				float2 panner36 = ( 1.0 * _Time.y * appendResult39 + lerpResult18);
				float2 appendResult45 = (float2(_Niuqu_U_speed , _Niuqu_V_speed));
				float2 texCoord42 = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner46 = ( 1.0 * _Time.y * appendResult45 + texCoord42);
				float4 tex2DNode9 = tex2D( _TextureSample0, ( panner36 + ( _NIUQU_Power * (-0.5 + (tex2D( _NIUQU_Tex, panner46 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) ) );
				float lerpResult62 = lerp( tex2DNode9.r , tex2DNode9.a , _MainTexP);
				float4 appendResult59 = (float4((( saturate( ( 1.0 - distanceDepth1 ) ) * _Color0 * i.ase_color * tex2DNode9 )).rgb , ( i.ase_color.a * _Color0.a * lerpResult62 )));
				
				
				finalColor = appendResult59;
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
Node;AmplifyShaderEditor.CommentaryNode;68;-1670.85,1.917731;Inherit;False;314.8004;130.8864;Comment;2;66;67;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-2057.286,373.8386;Inherit;False;1470.7;426.254;使用屏幕UV;12;9;52;11;10;36;19;13;17;18;38;37;39;纹理;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1873.108,151.3212;Inherit;False;1285;209.8999;使用One Minus反向;7;65;3;4;1;64;63;2;深度消隐;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1645.059,704.638;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;37;-1857.059,609.638;Inherit;False;Property;_UVSetflow;屏幕UV与流动速度;8;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;38;-1645.059,603.638;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;18;-1335.328,515.4914;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1591.328,414.4913;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1506.42,539.8221;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1513.328,639.4914;Inherit;False;Property;_Shield;UV模式;7;1;[Enum];Create;False;0;2;Local;0;Screen;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-2162.242,816.7663;Inherit;False;1125.292;313.9849;扭曲;9;50;49;47;48;46;44;45;43;42;纹理扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-2154.368,857.8172;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-2149.922,979.2245;Inherit;False;Property;_Niuqu_U_speed;扭曲U速度;11;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;36;-1161.059,514.638;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-2014.603,1000.903;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2150.362,1054.195;Inherit;False;Property;_Niuqu_V_speed;扭曲V速度;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;10;-2044.402,534.5605;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;-1865.179,534.7281;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;46;-1891.106,905.5501;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-1714.466,904.9709;Inherit;True;Property;_NIUQU_Tex;扭曲纹理;9;1;[Header];Create;False;1;Distortion;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;47;-1430.35,934.4633;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1432.115,856.7856;Inherit;False;Property;_NIUQU_Power;扭曲强度;10;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1166.28,910.5724;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-981.0268,514.9778;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;58;-333.9023,251.7113;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-144.9023,256.7113;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-13.82129,257.1439;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/深度护盾;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-538.4951,256.37;Inherit;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;62;-447.9023,566.7113;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-576.9023,669.7113;Inherit;False;Property;_MainTexP;贴图通道;3;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-295.9023,519.7113;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1862.206,221.4406;Inherit;False;Property;_Float0;深度距离;5;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-772.6833,-20.44622;Inherit;False;Property;_Color0;纹理颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;7;-934.3897,-19.07565;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;1;-1090.981,206.6496;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;4;-859.3021,206.8716;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;3;-718.2081,207.3302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;-1235.693,205.8327;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1388.693,255.8327;Inherit;False;Property;_Usecustom;深度控制模式;6;1;[Enum];Create;False;0;2;Custom1x;0;Material;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1599.693,193.8327;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-868.4467,487.1422;Inherit;True;Property;_TextureSample0;纹理;2;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1646.984,45.43941;Inherit;False;Property;_CullingMode;剔除模式;0;2;[Header];[Enum];Create;False;1;Setting;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1512.206,46.8433;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;0;1;0;0;0;1;FLOAT;0
WireConnection;39;0;37;3
WireConnection;39;1;37;4
WireConnection;38;0;37;1
WireConnection;38;1;37;2
WireConnection;18;0;17;0
WireConnection;18;1;13;0
WireConnection;18;2;19;0
WireConnection;13;0;11;0
WireConnection;13;1;38;0
WireConnection;36;0;18;0
WireConnection;36;2;39;0
WireConnection;45;0;43;0
WireConnection;45;1;44;0
WireConnection;11;0;10;0
WireConnection;46;0;42;0
WireConnection;46;2;45;0
WireConnection;48;1;46;0
WireConnection;47;0;48;1
WireConnection;50;0;49;0
WireConnection;50;1;47;0
WireConnection;52;0;36;0
WireConnection;52;1;50;0
WireConnection;58;0;6;0
WireConnection;59;0;58;0
WireConnection;59;3;60;0
WireConnection;0;0;59;0
WireConnection;6;0;3;0
WireConnection;6;1;5;0
WireConnection;6;2;7;0
WireConnection;6;3;9;0
WireConnection;62;0;9;1
WireConnection;62;1;9;4
WireConnection;62;2;61;0
WireConnection;60;0;7;4
WireConnection;60;1;5;4
WireConnection;60;2;62;0
WireConnection;1;0;65;0
WireConnection;4;0;1;0
WireConnection;3;0;4;0
WireConnection;65;0;63;1
WireConnection;65;1;2;0
WireConnection;65;2;64;0
WireConnection;9;1;52;0
ASEEND*/
//CHKSM=8EBF00C41D0FB9B5E1214438C2E16806323D9C57