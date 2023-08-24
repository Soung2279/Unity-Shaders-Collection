// Made with Amplify Shader Editor v1.9.1.7
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/特殊制作/星星收缩视差_AQG_Star"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		[KeywordEnum(RGBA,R,G,B,A)] _ColorRGBA("贴图通道选择", Float) = 0
		_MainTex_X("主贴图X轴流动", Float) = 0
		_MainTex_Y("主贴图Y轴流动", Float) = 0
		[Toggle(_SCREENOPEN_ON)] _ScreenOpen("世界贴图开关", Float) = 0
		_ScreenPositionMainTex_X("世界主帖图X轴重铺值", Float) = 1
		_ScreenPositionMainTex_Y("世界主帖图Y轴重铺值", Float) = 1
		[HDR]_MainColor("主体颜色", Color) = (1,1,1,1)
		[HDR]_OutlineColor("边颜色", Color) = (1,1,1,1)
		[Toggle(_CUSTOMDATA_ON)] _CustomData("是否启用粒子自定义——U", Float) = 0
		_Shrink("收缩", Range( 0 , 1.5)) = 0.8270243
		_Stroke("描边", Range( 1 , 1.5)) = 1.238479
		[Toggle(_SCREENOUTLINEOPEN_ON)] _ScreenOutLineOpen("世界外描边贴图开关", Float) = 0
		_ScreenOutLineTex("世界外描边主帖图", 2D) = "white" {}
		[KeywordEnum(RGBA,R,G,B,A)] _ColorRGBA1("贴图通道选择", Float) = 0
		_ScreenPositionOutLine_X("世界外描边帖图X轴重铺值", Float) = 1
		_ScreenPositionOutLine_Y("世界外描边帖图Y轴重铺值", Float) = 1
		_OutLine_X("外描边X轴流动", Float) = 0
		_OutLine_Y("外描边Y轴流动", Float) = 0
		[Toggle]_Open("直角星星开关========================", Float) = 0
		_MainTex1("主贴图", 2D) = "white" {}
		[KeywordEnum(RGBA,R,G,B,A)] _ColorRGBA2("贴图通道选择", Float) = 0
		_MainTex_X1("主贴图X轴流动", Float) = 0
		_MainTex_Y1("主贴图Y轴流动", Float) = 0
		[Toggle(_SCREENOPEN1_ON)] _ScreenOpen1("世界贴图开关", Float) = 0
		_ScreenPositionMainTex_X1("世界主帖图X轴重铺值", Float) = 1
		_ScreenPositionMainTex_Y1("世界主帖图Y轴重铺值", Float) = 1
		[HDR]_MainColor1("主体颜色", Color) = (1,1,1,1)
		[HDR]_OutlineColor1("边颜色", Color) = (1,1,1,1)
		[Toggle(_CUSTOMDATA1_ON)] _CustomData1("是否启用粒子自定义——V", Float) = 0
		_AngleStroke("直角星星边缘", Range( 0 , 1)) = 0.2304192
		_AngleShrink("直角星星收缩", Range( 0 , 2)) = 0.4715825
		[Toggle(_SCREENOUTLINEOPEN1_ON)] _ScreenOutLineOpen1("世界外描边贴图开关", Float) = 0
		_ScreenOutLineTex1("世界外描边主帖图", 2D) = "white" {}
		[KeywordEnum(RGBA,R,G,B,A)] _ColorRGBA3("贴图通道选择", Float) = 0
		_ScreenPositionOutLine_X1("世界外描边帖图X轴重铺值", Float) = 1
		_ScreenPositionOutLine_Y1("世界外描边帖图Y轴重铺值", Float) = 1
		_OutLine_X1("外描边X轴流动", Float) = 0
		_OutLine_Y1("外描边Y轴流动", Float) = 0

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
			#pragma shader_feature_local _COLORRGBA_RGBA _COLORRGBA_R _COLORRGBA_G _COLORRGBA_B _COLORRGBA_A
			#pragma shader_feature_local _SCREENOPEN_ON
			#pragma shader_feature_local _CUSTOMDATA_ON
			#pragma shader_feature_local _SCREENOUTLINEOPEN_ON
			#pragma shader_feature_local _COLORRGBA1_RGBA _COLORRGBA1_R _COLORRGBA1_G _COLORRGBA1_B _COLORRGBA1_A
			#pragma shader_feature_local _COLORRGBA2_RGBA _COLORRGBA2_R _COLORRGBA2_G _COLORRGBA2_B _COLORRGBA2_A
			#pragma shader_feature_local _SCREENOPEN1_ON
			#pragma shader_feature_local _CUSTOMDATA1_ON
			#pragma shader_feature_local _SCREENOUTLINEOPEN1_ON
			#pragma shader_feature_local _COLORRGBA3_RGBA _COLORRGBA3_R _COLORRGBA3_G _COLORRGBA3_B _COLORRGBA3_A


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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

			uniform float _Open;
			uniform sampler2D _MainTex;
			uniform float _MainTex_X;
			uniform float _MainTex_Y;
			uniform float4 _MainTex_ST;
			uniform float _ScreenPositionMainTex_X;
			uniform float _ScreenPositionMainTex_Y;
			uniform float4 _MainColor;
			uniform float _Shrink;
			uniform float _Stroke;
			uniform float4 _OutlineColor;
			uniform sampler2D _ScreenOutLineTex;
			uniform float _OutLine_X;
			uniform float _OutLine_Y;
			uniform float _ScreenPositionOutLine_X;
			uniform float _ScreenPositionOutLine_Y;
			uniform sampler2D _MainTex1;
			uniform float _MainTex_X1;
			uniform float _MainTex_Y1;
			uniform float4 _MainTex1_ST;
			uniform float _ScreenPositionMainTex_X1;
			uniform float _ScreenPositionMainTex_Y1;
			uniform float4 _MainColor1;
			uniform float _AngleShrink;
			uniform float _AngleStroke;
			uniform float4 _OutlineColor1;
			uniform sampler2D _ScreenOutLineTex1;
			uniform float _OutLine_X1;
			uniform float _OutLine_Y1;
			uniform float _ScreenPositionOutLine_X1;
			uniform float _ScreenPositionOutLine_Y1;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
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
				float3 appendResult91 = (float3(_MainTex_X , _MainTex_Y , 0.0));
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult86 = (float2(( ase_screenPosNorm.x * _ScreenPositionMainTex_X ) , ( ase_screenPosNorm.y * _ScreenPositionMainTex_Y )));
				#ifdef _SCREENOPEN_ON
				float2 staticSwitch92 = appendResult86;
				#else
				float2 staticSwitch92 = uv_MainTex;
				#endif
				float2 panner88 = ( 1.0 * _Time.y * appendResult91.xy + staticSwitch92);
				float4 tex2DNode24 = tex2D( _MainTex, panner88 );
				float4 temp_cast_1 = (tex2DNode24.r).xxxx;
				float4 temp_cast_2 = (tex2DNode24.g).xxxx;
				float4 temp_cast_3 = (tex2DNode24.b).xxxx;
				float4 temp_cast_4 = (tex2DNode24.a).xxxx;
				#if defined(_COLORRGBA_RGBA)
				float4 staticSwitch149 = tex2DNode24;
				#elif defined(_COLORRGBA_R)
				float4 staticSwitch149 = temp_cast_1;
				#elif defined(_COLORRGBA_G)
				float4 staticSwitch149 = temp_cast_2;
				#elif defined(_COLORRGBA_B)
				float4 staticSwitch149 = temp_cast_3;
				#elif defined(_COLORRGBA_A)
				float4 staticSwitch149 = temp_cast_4;
				#else
				float4 staticSwitch149 = tex2DNode24;
				#endif
				float2 texCoord2 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float blendOpSrc3 = texCoord2.x;
				float blendOpDest3 = texCoord2.y;
				float temp_output_3_0 = ( saturate( abs( blendOpSrc3 - blendOpDest3 ) ));
				float blendOpSrc4 = texCoord2.x;
				float blendOpDest4 = ( 1.0 - texCoord2.y );
				float temp_output_4_0 = ( saturate( abs( blendOpSrc4 - blendOpDest4 ) ));
				float blendOpSrc6 = temp_output_3_0;
				float blendOpDest6 = temp_output_4_0;
				float blendOpSrc7 = temp_output_4_0;
				float blendOpDest7 = temp_output_3_0;
				float temp_output_8_0 = ( ( saturate( ( blendOpDest6/ max( 1.0 - blendOpSrc6, 0.00001 ) ) )) * ( saturate( ( blendOpDest7/ max( 1.0 - blendOpSrc7, 0.00001 ) ) )) );
				float4 texCoord68 = i.ase_texcoord3;
				texCoord68.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float myVarName111 = texCoord68.x;
				#ifdef _CUSTOMDATA_ON
				float staticSwitch117 = myVarName111;
				#else
				float staticSwitch117 = _Shrink;
				#endif
				float temp_output_15_0 = ( 1.0 - staticSwitch117 );
				float temp_output_12_0 = step( temp_output_8_0 , temp_output_15_0 );
				float saferPower9 = abs( temp_output_8_0 );
				float3 appendResult125 = (float3(_OutLine_X , _OutLine_Y , 0.0));
				float2 appendResult123 = (float2(( ase_screenPosNorm.x * _ScreenPositionOutLine_X ) , ( ase_screenPosNorm.y * _ScreenPositionOutLine_Y )));
				float2 panner124 = ( 1.0 * _Time.y * appendResult125.xy + appendResult123);
				float4 tex2DNode128 = tex2D( _ScreenOutLineTex, panner124 );
				float4 temp_cast_6 = (tex2DNode128.r).xxxx;
				float4 temp_cast_7 = (tex2DNode128.g).xxxx;
				float4 temp_cast_8 = (tex2DNode128.b).xxxx;
				float4 temp_cast_9 = (tex2DNode128.a).xxxx;
				#if defined(_COLORRGBA1_RGBA)
				float4 staticSwitch150 = tex2DNode128;
				#elif defined(_COLORRGBA1_R)
				float4 staticSwitch150 = temp_cast_6;
				#elif defined(_COLORRGBA1_G)
				float4 staticSwitch150 = temp_cast_7;
				#elif defined(_COLORRGBA1_B)
				float4 staticSwitch150 = temp_cast_8;
				#elif defined(_COLORRGBA1_A)
				float4 staticSwitch150 = temp_cast_9;
				#else
				float4 staticSwitch150 = tex2DNode128;
				#endif
				#ifdef _SCREENOUTLINEOPEN_ON
				float4 staticSwitch130 = ( staticSwitch150 * _OutlineColor );
				#else
				float4 staticSwitch130 = _OutlineColor;
				#endif
				float3 appendResult104 = (float3(_MainTex_X1 , _MainTex_Y1 , 0.0));
				float2 uv_MainTex1 = i.ase_texcoord1.xy * _MainTex1_ST.xy + _MainTex1_ST.zw;
				float2 appendResult103 = (float2(( ase_screenPosNorm.x * _ScreenPositionMainTex_X1 ) , ( ase_screenPosNorm.y * _ScreenPositionMainTex_Y1 )));
				#ifdef _SCREENOPEN1_ON
				float2 staticSwitch107 = appendResult103;
				#else
				float2 staticSwitch107 = uv_MainTex1;
				#endif
				float2 panner99 = ( 1.0 * _Time.y * appendResult104.xy + staticSwitch107);
				float4 tex2DNode51 = tex2D( _MainTex1, panner99 );
				float4 temp_cast_11 = (tex2DNode51.r).xxxx;
				float4 temp_cast_12 = (tex2DNode51.g).xxxx;
				float4 temp_cast_13 = (tex2DNode51.b).xxxx;
				float4 temp_cast_14 = (tex2DNode51.a).xxxx;
				#if defined(_COLORRGBA2_RGBA)
				float4 staticSwitch151 = tex2DNode51;
				#elif defined(_COLORRGBA2_R)
				float4 staticSwitch151 = temp_cast_11;
				#elif defined(_COLORRGBA2_G)
				float4 staticSwitch151 = temp_cast_12;
				#elif defined(_COLORRGBA2_B)
				float4 staticSwitch151 = temp_cast_13;
				#elif defined(_COLORRGBA2_A)
				float4 staticSwitch151 = temp_cast_14;
				#else
				float4 staticSwitch151 = tex2DNode51;
				#endif
				float myVarName1114 = texCoord68.y;
				#ifdef _CUSTOMDATA1_ON
				float staticSwitch96 = myVarName1114;
				#else
				float staticSwitch96 = _AngleShrink;
				#endif
				float temp_output_58_0 = ( 1.0 - staticSwitch96 );
				float2 texCoord48 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float blendOpSrc39 = texCoord48.x;
				float blendOpDest39 = texCoord48.y;
				float temp_output_39_0 = ( saturate( abs( blendOpSrc39 - blendOpDest39 ) ));
				float blendOpSrc41 = texCoord48.x;
				float blendOpDest41 = ( 1.0 - texCoord48.y );
				float temp_output_41_0 = ( saturate( abs( blendOpSrc41 - blendOpDest41 ) ));
				float blendOpSrc32 = temp_output_39_0;
				float blendOpDest32 = temp_output_41_0;
				float temp_output_32_0 = ( saturate( ( blendOpDest32/ max( 1.0 - blendOpSrc32, 0.00001 ) ) ));
				float blendOpSrc40 = temp_output_41_0;
				float blendOpDest40 = temp_output_39_0;
				float temp_output_40_0 = ( saturate( ( blendOpDest40/ max( 1.0 - blendOpSrc40, 0.00001 ) ) ));
				float temp_output_65_0 = ( 1.0 - ( step( temp_output_58_0 , temp_output_32_0 ) * step( temp_output_58_0 , temp_output_40_0 ) ) );
				float temp_output_59_0 = ( temp_output_58_0 + _AngleStroke );
				float3 appendResult131 = (float3(_OutLine_X1 , _OutLine_Y1 , 0.0));
				float2 appendResult134 = (float2(( ase_screenPosNorm.x * _ScreenPositionOutLine_X1 ) , ( ase_screenPosNorm.y * _ScreenPositionOutLine_Y1 )));
				float2 panner137 = ( 1.0 * _Time.y * appendResult131.xy + appendResult134);
				float4 tex2DNode139 = tex2D( _ScreenOutLineTex1, panner137 );
				float4 temp_cast_16 = (tex2DNode139.r).xxxx;
				float4 temp_cast_17 = (tex2DNode139.g).xxxx;
				float4 temp_cast_18 = (tex2DNode139.b).xxxx;
				float4 temp_cast_19 = (tex2DNode139.a).xxxx;
				#if defined(_COLORRGBA3_RGBA)
				float4 staticSwitch152 = tex2DNode139;
				#elif defined(_COLORRGBA3_R)
				float4 staticSwitch152 = temp_cast_16;
				#elif defined(_COLORRGBA3_G)
				float4 staticSwitch152 = temp_cast_17;
				#elif defined(_COLORRGBA3_B)
				float4 staticSwitch152 = temp_cast_18;
				#elif defined(_COLORRGBA3_A)
				float4 staticSwitch152 = temp_cast_19;
				#else
				float4 staticSwitch152 = tex2DNode139;
				#endif
				#ifdef _SCREENOUTLINEOPEN1_ON
				float4 staticSwitch144 = ( staticSwitch152 * _OutlineColor1 );
				#else
				float4 staticSwitch144 = _OutlineColor1;
				#endif
				
				
				finalColor = (( _Open )?( ( ( ( staticSwitch151 * _MainColor1 ) * temp_output_65_0 ) + ( ( ( 1.0 - ( step( temp_output_59_0 , temp_output_40_0 ) * step( temp_output_59_0 , temp_output_32_0 ) ) ) - temp_output_65_0 ) * staticSwitch144 ) ) ):( ( ( ( staticSwitch149 * _MainColor ) * temp_output_12_0 ) + ( ( step( pow( saferPower9 , _Stroke ) , temp_output_15_0 ) - temp_output_12_0 ) * staticSwitch130 ) ) ));
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19107
Node;AmplifyShaderEditor.BlendOpsNode;6;420.5329,87.55177;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;1928.429,420.4115;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;2239.331,209.8291;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;2507.283,208.984;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;3;-14.80379,87.68129;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;7;427.1986,364.1945;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;1361.671,613.91;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;1572.392,37.01572;Inherit;False;Property;_MainColor;主体颜色;7;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;1977.392,18.1441;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;5;-201.404,393.8636;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;722.6427,219.5067;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;12;1564.583,231.3338;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;9;1118.058,381.5666;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;889.1007,634.4508;Inherit;False;111;myVarName;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;32;282.2626,2642.307;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;39;-153.074,2642.436;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;40;288.9285,2918.948;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;41;-147.5779,2921.629;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-339.6742,2948.617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;2135.128,2913.714;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;2341.189,2639.524;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;1642.702,2404.638;Inherit;False;Property;_MainColor1;主体颜色;27;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,0.1179245,0.1179245,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2047.699,2385.767;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-585.2338,2622.053;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;38;2727.811,2640.452;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;62;897.7089,3513.054;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;928.2025,2254.189;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;105;722.2021,2247.189;Inherit;False;Property;_MainTex_X1;主贴图X轴流动;22;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;725.2021,2327.189;Inherit;False;Property;_MainTex_Y1;主贴图Y轴流动;23;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;99;1194.651,2229.497;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;51;1557.234,2201.82;Inherit;True;Property;_MainTex1;主贴图;20;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;109;427.211,2064.954;Inherit;False;0;51;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;56;892.4888,2965.434;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;61;895.2524,3226.846;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-229.6769,3293.28;Inherit;False;114;myVarName1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-305.0774,3431.321;Inherit;False;Property;_AngleShrink;直角星星收缩;31;0;Create;False;0;0;0;False;0;False;0.4715825;0.84;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;100;-244.3044,1747.293;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;152.7131,1640.911;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;170.7133,1936.912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;425.7132,1790.911;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-84.49992,1955.65;Inherit;False;Property;_ScreenPositionMainTex_Y1;世界主帖图Y轴重铺值;26;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-76.28719,1660.649;Inherit;False;Property;_ScreenPositionMainTex_X1;世界主帖图X轴重铺值;25;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;2453.173,627.098;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;107;828.4291,2066.211;Inherit;False;Property;_ScreenOpen1;世界贴图开关;24;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;55;872.0334,2626.8;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1251.334,2629.266;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;1626.903,2627.384;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;1284.35,3231.517;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;16;1564.642,589.2859;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;1643.491,3226.946;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;637.2383,3283.262;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;351.4946,3279.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;253.6672,3483.871;Inherit;False;Property;_AngleStroke;直角星星边缘;30;0;Create;False;0;0;0;False;0;False;0.2304192;0.043;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;96;69.36018,3273.731;Inherit;False;Property;_CustomData1;是否启用粒子自定义——V;29;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;972.2678,1222.707;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;119;212.6669,913.5278;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;616.0969,811.4156;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;889.0963,961.4147;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;126;766.2675,1215.707;Inherit;False;Property;_OutLine_X;外描边X轴流动;17;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;769.2675,1295.707;Inherit;False;Property;_OutLine_Y;外描边Y轴流动;18;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;124;1129.906,1078.535;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;118;340.6669,832.5286;Inherit;False;Property;_ScreenPositionOutLine_X;世界外描边帖图X轴重铺值;15;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;624.4598,1080.289;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;340.46,1097.289;Inherit;False;Property;_ScreenPositionOutLine_Y;世界外描边帖图Y轴重铺值;16;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;2543.294,2905.313;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;131;1098.25,4175.166;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;132;338.6493,3865.989;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;742.0787,3763.878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;134;1015.079,3913.875;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;135;892.2499,4168.167;Inherit;False;Property;_OutLine_X1;外描边X轴流动;37;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;895.2499,4248.165;Inherit;False;Property;_OutLine_Y1;外描边Y轴流动;38;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;137;1255.888,4030.995;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;140;466.6491,3784.991;Inherit;False;Property;_ScreenPositionOutLine_X1;世界外描边帖图X轴重铺值;35;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;750.4418,4032.749;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;466.4421,4049.749;Inherit;False;Property;_ScreenPositionOutLine_Y1;世界外描边帖图Y轴重铺值;36;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;1640.085,3940.014;Inherit;False;Property;_OutlineColor1;边颜色;28;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.4232385,1.53523,5.278032,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;2012.961,673.8264;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-1746.299,1544.776;Inherit;False;myVarName1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-1746.949,1374.229;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-446.9645,67.29762;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;4;-9.307652,366.8756;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;704.8723,494.4291;Inherit;False;Property;_Stroke;描边;11;0;Create;False;0;0;0;False;0;False;1.238479;1.189;1;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;802.6857,725.2143;Inherit;True;Property;_Shrink;收缩;10;0;Create;False;0;0;0;False;0;False;0.8270243;0.96;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;130;2169.645,646.8029;Inherit;False;Property;_ScreenOutLineOpen;世界外描边贴图开关;12;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-2019.224,1417.714;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;117;1129.101,610.4508;Inherit;False;Property;_CustomData;是否启用粒子自定义——U;9;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-112.0309,-1101.785;Inherit;False;Property;_ScreenPositionMainTex_X;世界主帖图X轴重铺值;5;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;-240.0309,-1021.785;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-80.03089,-813.7852;Inherit;False;Property;_ScreenPositionMainTex_Y;世界主帖图Y轴重铺值;6;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;175.969,-829.7852;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;163.3991,-1123.898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;86;436.399,-973.8983;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;88;880.5526,-481.2705;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;614.1028,-456.5777;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;89;408.1025,-463.5777;Inherit;False;Property;_MainTex_X;主贴图X轴流动;2;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;411.1025,-383.5775;Inherit;False;Property;_MainTex_Y;主贴图Y轴流动;3;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;288.9804,-670.0716;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;92;690.1998,-668.8146;Inherit;False;Property;_ScreenOpen;世界贴图开关;4;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;24;1071.893,-510.5901;Inherit;True;Property;_MainTex;主贴图;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;149;1486.746,-510.1104;Inherit;False;Property;_ColorRGBA;贴图通道选择;1;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;RGBA;R;G;B;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;128;1373.31,828.7818;Inherit;True;Property;_ScreenOutLineTex;世界外描边主帖图;13;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;1736.535,1193.399;Inherit;False;Property;_OutlineColor;边颜色;8;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,0.9097375,0.05098039,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;139;1437.967,3638.548;Inherit;True;Property;_ScreenOutLineTex1;世界外描边主帖图;33;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;152;1723.231,3640.877;Inherit;False;Property;_ColorRGBA3;贴图通道选择;34;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;RGBA;R;G;B;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;1963.039,3643.204;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;144;2215.211,3611.784;Inherit;False;Property;_ScreenOutLineOpen1;世界外描边贴图开关;32;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;150;1705.679,827.8661;Inherit;False;Property;_ColorRGBA1;贴图通道选择;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;RGBA;R;G;B;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;151;1854.712,2202.058;Inherit;False;Property;_ColorRGBA2;贴图通道选择;21;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;5;RGBA;R;G;B;A;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;4216.447,1542.15;Float;False;True;-1;2;ASEMaterialInspector;100;5;AQG/Star;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;3761.352,1538.335;Inherit;False;Property;_Open;直角星星开关========================;19;0;Create;False;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;6;0;3;0
WireConnection;6;1;4;0
WireConnection;18;0;16;0
WireConnection;18;1;12;0
WireConnection;23;0;25;0
WireConnection;23;1;12;0
WireConnection;19;0;23;0
WireConnection;19;1;21;0
WireConnection;3;0;2;1
WireConnection;3;1;2;2
WireConnection;7;0;4;0
WireConnection;7;1;3;0
WireConnection;15;0;117;0
WireConnection;25;0;149;0
WireConnection;25;1;22;0
WireConnection;5;0;2;2
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;12;0;8;0
WireConnection;12;1;15;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;32;0;39;0
WireConnection;32;1;41;0
WireConnection;39;0;48;1
WireConnection;39;1;48;2
WireConnection;40;0;41;0
WireConnection;40;1;39;0
WireConnection;41;0;48;1
WireConnection;41;1;49;0
WireConnection;49;0;48;2
WireConnection;34;0;66;0
WireConnection;34;1;65;0
WireConnection;37;0;45;0
WireConnection;37;1;65;0
WireConnection;45;0;151;0
WireConnection;45;1;44;0
WireConnection;38;0;37;0
WireConnection;38;1;35;0
WireConnection;62;0;59;0
WireConnection;62;1;32;0
WireConnection;104;0;105;0
WireConnection;104;1;106;0
WireConnection;99;0;107;0
WireConnection;99;2;104;0
WireConnection;51;1;99;0
WireConnection;56;0;58;0
WireConnection;56;1;40;0
WireConnection;61;0;59;0
WireConnection;61;1;40;0
WireConnection;101;0;100;1
WireConnection;101;1;110;0
WireConnection;102;0;100;2
WireConnection;102;1;108;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;21;0;18;0
WireConnection;21;1;130;0
WireConnection;107;1;109;0
WireConnection;107;0;103;0
WireConnection;55;0;58;0
WireConnection;55;1;32;0
WireConnection;63;0;55;0
WireConnection;63;1;56;0
WireConnection;65;0;63;0
WireConnection;64;0;61;0
WireConnection;64;1;62;0
WireConnection;16;0;9;0
WireConnection;16;1;15;0
WireConnection;66;0;64;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;58;0;96;0
WireConnection;96;1;67;0
WireConnection;96;0;112;0
WireConnection;125;0;126;0
WireConnection;125;1;127;0
WireConnection;122;0;119;1
WireConnection;122;1;118;0
WireConnection;123;0;122;0
WireConnection;123;1;121;0
WireConnection;124;0;123;0
WireConnection;124;2;125;0
WireConnection;121;0;119;2
WireConnection;121;1;120;0
WireConnection;35;0;34;0
WireConnection;35;1;144;0
WireConnection;131;0;135;0
WireConnection;131;1;136;0
WireConnection;133;0;132;1
WireConnection;133;1;140;0
WireConnection;134;0;133;0
WireConnection;134;1;141;0
WireConnection;137;0;134;0
WireConnection;137;2;131;0
WireConnection;141;0;132;2
WireConnection;141;1;142;0
WireConnection;129;0;150;0
WireConnection;129;1;20;0
WireConnection;114;0;68;2
WireConnection;111;0;68;1
WireConnection;4;0;2;1
WireConnection;4;1;5;0
WireConnection;130;1;20;0
WireConnection;130;0;129;0
WireConnection;117;1;13;0
WireConnection;117;0;115;0
WireConnection;84;0;26;2
WireConnection;84;1;85;0
WireConnection;82;0;26;1
WireConnection;82;1;83;0
WireConnection;86;0;82;0
WireConnection;86;1;84;0
WireConnection;88;0;92;0
WireConnection;88;2;91;0
WireConnection;91;0;89;0
WireConnection;91;1;90;0
WireConnection;92;1;93;0
WireConnection;92;0;86;0
WireConnection;24;1;88;0
WireConnection;149;1;24;0
WireConnection;149;0;24;1
WireConnection;149;2;24;2
WireConnection;149;3;24;3
WireConnection;149;4;24;4
WireConnection;128;1;124;0
WireConnection;139;1;137;0
WireConnection;152;1;139;0
WireConnection;152;0;139;1
WireConnection;152;2;139;2
WireConnection;152;3;139;3
WireConnection;152;4;139;4
WireConnection;143;0;152;0
WireConnection;143;1;36;0
WireConnection;144;1;36;0
WireConnection;144;0;143;0
WireConnection;150;1;128;0
WireConnection;150;0;128;1
WireConnection;150;2;128;2
WireConnection;150;3;128;3
WireConnection;150;4;128;4
WireConnection;151;1;51;0
WireConnection;151;0;51;1
WireConnection;151;2;51;2
WireConnection;151;3;51;3
WireConnection;151;4;51;4
WireConnection;0;0;70;0
WireConnection;70;0;19;0
WireConnection;70;1;38;0
ASEEND*/
//CHKSM=A4B95E8AB90EB64ADB4893A43CE85E0D57E259EB