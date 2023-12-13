// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/序列帧扭曲屏幕"
{
	Properties
	{
		_TextureSample0("序列帧", 2D) = "white" {}
		[KeywordEnum(R,A)] _TexSwitchP("切换贴图通道", Float) = 0
		_Vector0("横纵数量-速率-起始帧", Vector) = (0,0,0,0)
		_Float0("扭曲强度", Range( 0 , 1)) = 0
		[KeywordEnum(DIY,Program)] _UseFix1("遮罩模式", Float) = 0
		_Fixval1("边缘过渡 (Program)", Range( 1 , 200)) = 150
		_TextureSample1("自定义遮罩 (DIY)", 2D) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent+2" }
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
		
		
		GrabPass{ }

		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature_local _TEXSWITCHP_R _TEXSWITCHP_A
			#pragma shader_feature_local _USEFIX1_DIY _USEFIX1_PROGRAM


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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform sampler2D _TextureSample0;
			uniform float4 _TextureSample0_ST;
			uniform float4 _Vector0;
			uniform float _Float0;
			uniform sampler2D _TextureSample1;
			uniform float4 _TextureSample1_ST;
			uniform float _Fixval1;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_color = v.color;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
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
				float2 uv_TextureSample0 = i.ase_texcoord2.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float mulTime67 = _Time.y * 5.0;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles65 = _Vector0.x * _Vector0.y;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset65 = 1.0f / _Vector0.x;
				float fbrowsoffset65 = 1.0f / _Vector0.y;
				// Speed of animation
				float fbspeed65 = mulTime67 * _Vector0.z;
				// UV Tiling (col and row offset)
				float2 fbtiling65 = float2(fbcolsoffset65, fbrowsoffset65);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex65 = round( fmod( fbspeed65 + _Vector0.w, fbtotaltiles65) );
				fbcurrenttileindex65 += ( fbcurrenttileindex65 < 0) ? fbtotaltiles65 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox65 = round ( fmod ( fbcurrenttileindex65, _Vector0.x ) );
				// Multiply Offset X by coloffset
				float fboffsetx65 = fblinearindextox65 * fbcolsoffset65;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy65 = round( fmod( ( fbcurrenttileindex65 - fblinearindextox65 ) / _Vector0.x, _Vector0.y ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy65 = (int)(_Vector0.y-1) - fblinearindextoy65;
				// Multiply Offset Y by rowoffset
				float fboffsety65 = fblinearindextoy65 * fbrowsoffset65;
				// UV Offset
				float2 fboffset65 = float2(fboffsetx65, fboffsety65);
				// Flipbook UV
				half2 fbuv65 = frac( uv_TextureSample0 ) * fbtiling65 + fboffset65;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode5 = tex2D( _TextureSample0, fbuv65 );
				#if defined(_TEXSWITCHP_R)
				float staticSwitch70 = tex2DNode5.r;
				#elif defined(_TEXSWITCHP_A)
				float staticSwitch70 = tex2DNode5.a;
				#else
				float staticSwitch70 = tex2DNode5.r;
				#endif
				float4 temp_cast_0 = (staticSwitch70).xxxx;
				float4 lerpResult4 = lerp( (ase_screenPosNorm).xyzw , temp_cast_0 , _Float0);
				float4 screenColor2 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,lerpResult4.xy);
				float2 uv_TextureSample1 = i.ase_texcoord2.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
				float2 texCoord50 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord51 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_USEFIX1_DIY)
				float staticSwitch61 = tex2D( _TextureSample1, uv_TextureSample1 ).a;
				#elif defined(_USEFIX1_PROGRAM)
				float staticSwitch61 = saturate( ( ( 1.0 - saturate( texCoord50.x ) ) * ( 1.0 - saturate( texCoord50.y ) ) * saturate( texCoord51.x ) * saturate( texCoord51.y ) * _Fixval1 ) );
				#else
				float staticSwitch61 = tex2D( _TextureSample1, uv_TextureSample1 ).a;
				#endif
				float4 appendResult81 = (float4((screenColor2).rgb , staticSwitch61));
				
				
				finalColor = ( i.ase_color * appendResult81 );
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
Node;AmplifyShaderEditor.CommentaryNode;86;-1855.574,-34.05748;Inherit;False;1608.031;489.8649;抓取屏幕颜色与UV，使用序列帧扰动屏幕UV，为着色器输出RGB通道信息;13;76;4;2;70;82;3;67;63;6;66;65;5;7;使用序列扭曲屏幕;0.4292453,0.7177615,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;85;-1858.475,493.8354;Inherit;False;1179;466.6;使用自定义贴图或使用程序化遮罩，为着色器输出A通道信息;14;72;59;71;61;58;50;55;51;60;53;56;57;54;52;遮罩选择模式;1,0.8296858,0.6179246,1;0;0
Node;AmplifyShaderEditor.SaturateNode;52;-1626.354,747.7168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;-1626.057,814.2239;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;57;-1500.353,746.7168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-1501.056,679.2228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;-1627.057,679.2228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1221.748,726.5476;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-1833.466,833.3937;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;55;-1394.85,886.847;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1834.236,699.9272;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1499.743,817.386;Inherit;False;Property;_Fixval1;边缘过渡 (Program);5;0;Create;False;0;0;0;False;0;False;150;200;1;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;61;-877.4573,641.0216;Inherit;False;Property;_UseFix1;遮罩模式;4;0;Create;False;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;2;DIY;Program;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;-1175.037,531.2141;Inherit;True;Property;_TextureSample1;自定义遮罩 (DIY);6;0;Create;False;0;0;0;False;0;False;-1;None;c7f2271317b63eb40b8608b5bc8d4957;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;59;-1023.733,727.7299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-1379.782,555.2921;Inherit;False;0;71;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;69;-210.796,16.48813;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-24.72206,110.7366;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;108.9747,110.778;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/序列帧扭曲屏幕;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=2;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;81;-196.2428,188.4965;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1207.557,375.3433;Inherit;False;Property;_Float0;扭曲强度;3;0;Create;False;0;0;0;False;0;False;0;0.269;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1270.593,185.9961;Inherit;True;Property;_TextureSample0;序列帧;0;0;Create;False;0;0;0;False;0;False;-1;None;8f87b57d59630754483721218b1699c5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;65;-1500.067,214.1724;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;66;-1829.727,208.367;Inherit;False;Property;_Vector0;横纵数量-速率-起始帧;2;0;Create;False;0;0;0;False;0;False;0,0,0,0;4,4,3,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1839.242,88.6382;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;63;-1614.242,211.5121;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;67;-1788.449,377.1939;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;3;-988.5926,14.29578;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;82;-1174.17,13.98382;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;70;-981.4788,209.0849;Inherit;False;Property;_TexSwitchP;切换贴图通道;1;0;Create;False;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;2;-588.3892,184.7074;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;4;-741.8892,190.4074;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;76;-431.4586,184.6423;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
WireConnection;52;0;50;2
WireConnection;54;0;51;1
WireConnection;57;0;52;0
WireConnection;56;0;53;0
WireConnection;53;0;50;1
WireConnection;60;0;56;0
WireConnection;60;1;57;0
WireConnection;60;2;54;0
WireConnection;60;3;55;0
WireConnection;60;4;58;0
WireConnection;55;0;51;2
WireConnection;61;1;71;4
WireConnection;61;0;59;0
WireConnection;71;1;72;0
WireConnection;59;0;60;0
WireConnection;68;0;69;0
WireConnection;68;1;81;0
WireConnection;0;0;68;0
WireConnection;81;0;76;0
WireConnection;81;3;61;0
WireConnection;5;1;65;0
WireConnection;65;0;63;0
WireConnection;65;1;66;1
WireConnection;65;2;66;2
WireConnection;65;3;66;3
WireConnection;65;4;66;4
WireConnection;65;5;67;0
WireConnection;63;0;6;0
WireConnection;3;0;82;0
WireConnection;70;1;5;1
WireConnection;70;0;5;4
WireConnection;2;0;4;0
WireConnection;4;0;3;0
WireConnection;4;1;70;0
WireConnection;4;2;7;0
WireConnection;76;0;2;0
ASEEND*/
//CHKSM=E8BC2B578C02F879FB62C4A8C44A8EE0CFECCD1D