// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/视差星星收缩"
{
	Properties
	{
		[Header(Settings)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 0
		[Header(MainTex)]_MainTex("主贴图", 2D) = "white" {}
		[HDR]_MainColor("主体颜色", Color) = (1,1,1,1)
		[Enum(Local,0,Screen,1)]_MainTexUVSW("主帖图UV模式", Float) = 0
		_TexUVFlow("屏幕UV与整体流动速度", Vector) = (0,0,0,0)
		[Header(NoiseTex)]_Distr("扰动贴图", 2D) = "black" {}
		_NoiseInt("扰动强度", Range( 0 , 1)) = 0.06342169
		_NoiseU("扰动U方向速率", Float) = 1
		_NoiseV("扰动V方向速率", Float) = 1
		[Header(OutlineTex)]_ScreenOutLineTex("描边帖图", 2D) = "white" {}
		[HDR]_OutlineColor("描边颜色", Color) = (1,1,1,1)
		[Enum(Color,0,Tex,1)]_MiaoSW("描边模式", Float) = 0
		[Enum(Local,0,Screen,1)]_MiaoTexUVSW("描边UV模式", Float) = 0
		_MiaoUVFlow("描边屏幕UV与整体流动", Vector) = (0,0,0,0)
		_Stroke("描边宽度", Range( 0 , 2)) = 1.238479
		_Shrink("收缩值", Range( 0 , 1.5)) = 0.8270243
		[Enum(OFF,0,ON,1)]_CustomXSW("Custom1.x控制收缩", Float) = 0
		[Enum(Soft,0,Hard,1)]_StarSwitch("星星边缘平滑", Float) = 0

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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _BlendMode;
			uniform float _CullingMode;
			uniform sampler2D _MainTex;
			uniform float4 _TexUVFlow;
			uniform float4 _MainTex_ST;
			uniform float _MainTexUVSW;
			uniform sampler2D _Distr;
			uniform float _NoiseU;
			uniform float _NoiseV;
			uniform float4 _Distr_ST;
			uniform float _NoiseInt;
			uniform float4 _MainColor;
			uniform float _Shrink;
			uniform float _CustomXSW;
			uniform float _Stroke;
			uniform float4 _OutlineColor;
			uniform sampler2D _ScreenOutLineTex;
			uniform float4 _MiaoUVFlow;
			uniform float4 _ScreenOutLineTex_ST;
			uniform float _MiaoTexUVSW;
			uniform float _MiaoSW;
			uniform float _StarSwitch;

			
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
				o.ase_color = v.color;
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
				float2 appendResult91 = (float2(_TexUVFlow.z , _TexUVFlow.w));
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult86 = (float2(( ase_screenPosNorm.x * _TexUVFlow.x ) , ( ase_screenPosNorm.y * _TexUVFlow.y )));
				float2 lerpResult153 = lerp( uv_MainTex , appendResult86 , _MainTexUVSW);
				float2 appendResult215 = (float2(_NoiseU , _NoiseV));
				float2 uv_Distr = i.ase_texcoord1.xy * _Distr_ST.xy + _Distr_ST.zw;
				float2 panner216 = ( 1.0 * _Time.y * appendResult215 + uv_Distr);
				float NoiseT225 = tex2D( _Distr, panner216 ).r;
				float2 temp_cast_0 = (NoiseT225).xx;
				float2 lerpResult222 = lerp( lerpResult153 , temp_cast_0 , _NoiseInt);
				float2 panner88 = ( 1.0 * _Time.y * appendResult91 + lerpResult222);
				float4 MainColor182 = ( tex2D( _MainTex, panner88 ) * _MainColor * i.ase_color );
				float2 texCoord48 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float blendOpSrc39 = texCoord48.x;
				float blendOpDest39 = texCoord48.y;
				float temp_output_39_0 = ( saturate( abs( blendOpSrc39 - blendOpDest39 ) ));
				float blendOpSrc41 = texCoord48.x;
				float blendOpDest41 = ( 1.0 - texCoord48.y );
				float temp_output_41_0 = ( saturate( abs( blendOpSrc41 - blendOpDest41 ) ));
				float blendOpSrc32 = temp_output_39_0;
				float blendOpDest32 = temp_output_41_0;
				float ShapeUp170 = ( saturate( ( blendOpDest32/ max( 1.0 - blendOpSrc32, 0.00001 ) ) ));
				float blendOpSrc40 = temp_output_41_0;
				float blendOpDest40 = temp_output_39_0;
				float ShapeDown171 = ( saturate( ( blendOpDest40/ max( 1.0 - blendOpSrc40, 0.00001 ) ) ));
				float temp_output_8_0 = ( ShapeUp170 * ShapeDown171 );
				float4 texCoord68 = i.ase_texcoord3;
				texCoord68.xy = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float Custom1xUsage111 = texCoord68.x;
				float lerpResult158 = lerp( _Shrink , Custom1xUsage111 , _CustomXSW);
				float CustomChoose175 = lerpResult158;
				float temp_output_15_0 = ( 1.0 - CustomChoose175 );
				float temp_output_12_0 = step( temp_output_8_0 , temp_output_15_0 );
				float saferPower9 = abs( temp_output_8_0 );
				float OutlineWigth192 = _Stroke;
				float2 appendResult125 = (float2(_MiaoUVFlow.z , _MiaoUVFlow.w));
				float2 uv_ScreenOutLineTex = i.ase_texcoord1.xy * _ScreenOutLineTex_ST.xy + _ScreenOutLineTex_ST.zw;
				float2 appendResult123 = (float2(( ase_screenPosNorm.x * _MiaoUVFlow.x ) , ( ase_screenPosNorm.y * _MiaoUVFlow.y )));
				float2 lerpResult162 = lerp( uv_ScreenOutLineTex , appendResult123 , _MiaoTexUVSW);
				float2 panner124 = ( 1.0 * _Time.y * appendResult125 + lerpResult162);
				float4 lerpResult165 = lerp( _OutlineColor , ( tex2D( _ScreenOutLineTex, panner124 ) * _OutlineColor ) , _MiaoSW);
				float4 OutlineColor180 = lerpResult165;
				float temp_output_58_0 = ( 1.0 - CustomChoose175 );
				float temp_output_65_0 = ( 1.0 - ( step( temp_output_58_0 , ShapeUp170 ) * step( temp_output_58_0 , ShapeDown171 ) ) );
				float temp_output_59_0 = ( temp_output_58_0 + OutlineWigth192 );
				float4 lerpResult186 = lerp( ( ( MainColor182 * temp_output_12_0 ) + ( ( step( pow( saferPower9 , OutlineWigth192 ) , temp_output_15_0 ) - temp_output_12_0 ) * OutlineColor180 ) ) , ( ( MainColor182 * temp_output_65_0 ) + ( OutlineColor180 * ( ( 1.0 - ( step( temp_output_59_0 , ShapeDown171 ) * step( temp_output_59_0 , ShapeUp170 ) ) ) - temp_output_65_0 ) ) ) , _StarSwitch);
				
				
				finalColor = lerpResult186;
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
Node;AmplifyShaderEditor.CommentaryNode;226;874.2739,-542.3147;Inherit;False;274.5667;125.6471;Settings;2;228;227;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;223;-1076.393,67.04353;Inherit;False;989;345;UV流动;7;225;217;216;215;219;220;214;扰动贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;179;-1068.201,572.2464;Inherit;False;2619.46;762.8047;直角形状计算;29;38;183;181;35;37;34;66;64;61;62;65;63;56;55;173;174;58;59;177;170;171;40;41;32;39;49;48;193;194;星星收缩B;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;194;-1058.033,1093.011;Inherit;False;490;231;共用宽度控制;2;192;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;188;870.9809,-381.1546;Inherit;False;818;393;Custom1.x;7;175;159;158;115;13;111;68;粒子系统控制收缩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;164;-1098.461,-478.5811;Inherit;False;1942.721;497.8063;屏幕UV;13;180;128;124;162;163;161;125;123;121;160;119;122;167;描边贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;114.3707,-394.9998;Inherit;False;523;283;贴图也乘以颜色方便调整;4;166;165;129;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;157;1.357376,44.75894;Inherit;False;1556.009;507.7011;圆形形状计算;15;19;184;23;185;21;18;16;12;15;176;169;172;8;9;190;星星收缩A;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;156;-1106.669,-1035.113;Inherit;False;1846.278;542.1787;屏幕UV;18;182;25;22;24;88;222;224;218;155;154;153;93;86;82;84;26;91;229;主帖图;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-879.3334,-643.3926;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;-1064.866,-894.0004;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-745.8664,-696.0005;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-745.4363,-863.1133;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;86;-600.4371,-863.1136;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-688.8553,-988.2871;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;153;-457.0024,-886.0728;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-619.0022,-766.0728;Inherit;False;Property;_MainTexUVSW;主帖图UV模式;4;1;[Enum];Create;False;0;2;Local;0;Screen;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-819.9432,-302.3608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;119;-1047.373,-332.249;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-814.5803,-134.4885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;-678.9436,-302.363;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;-671.7722,-87.07021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;161;-751.5106,-431.0206;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;163;-689.258,-206.6329;Inherit;False;Property;_MiaoTexUVSW;描边UV模式;13;1;[Enum];Create;False;0;2;Local;0;Screen;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;162;-510.9707,-326.634;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;124;-348.2802,-325.6164;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;20;127.8948,-287.9509;Inherit;False;Property;_OutlineColor;描边颜色;11;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;4.924578,4.924578,4.924578,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;357.4481,-350.5585;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;165;491.9783,-284.9064;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;166;341.7498,-241.9285;Inherit;False;Property;_MiaoSW;描边模式;12;1;[Enum];Create;False;0;2;Color;0;Tex;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1044.701,628.3804;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;49;-832.1424,792.9446;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;39;-649.542,645.7639;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;32;-344.2051,645.6345;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;41;-648.0459,873.9568;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;40;-344.5392,875.2756;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-103.6193,875.0486;Inherit;False;ShapeDown;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-106.8733,645.1417;Inherit;False;ShapeUp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;32.50305,1219.187;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-108.3152,1153.899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;130.8896,647.4973;Inherit;False;170;ShapeUp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;126.9277,875.9968;Inherit;False;171;ShapeDown;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;55;339.0896,630.2004;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;56;345.4665,855.6124;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;475.9974,631.4149;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;614.924,631.0897;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;62;338.7641,1215.331;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;61;342.9861,989.8356;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;479.5149,990.5065;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;616.7473,991.2746;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;793.454,755.3768;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;9;429.6805,335.9604;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;204.2959,111.0088;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;20.57831,105.1068;Inherit;False;170;ShapeUp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;17.61635,186.6059;Inherit;False;171;ShapeDown;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;649.8683,-289.6773;Inherit;False;OutlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;440.722,159.8116;Inherit;False;175;CustomChoose;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;647.8457,136.636;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;12;814.2252,112.7489;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;16;784.3643,332.6094;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;910.3978,332.0686;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;898.2958,-339.5658;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;1117.571,-321.051;Inherit;False;Custom1xUsage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;1167.292,-136.1614;Inherit;False;111;Custom1xUsage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;158;1353.252,-154.3766;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;1158.329,-61.06271;Inherit;False;Property;_CustomXSW;Custom1.x控制收缩;17;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;1496.421,-157.9357;Inherit;False;CustomChoose;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;1196.01,629.8217;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;1194.907,729.9004;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;992.2894,723.4435;Inherit;False;180;OutlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;997.2156,624.556;Inherit;False;182;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;1337.502,705.4169;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;1201.736,215.8102;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;1006.06,234.5233;Inherit;False;180;OutlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;1200.322,95.50719;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;1001.606,88.16027;Inherit;False;182;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;1344.584,192.6226;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;187;1570.472,369.2853;Inherit;False;Property;_StarSwitch;星星边缘平滑;18;1;[Enum];Create;False;0;2;Soft;0;Hard;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;881.1649,-155.5752;Inherit;False;Property;_Shrink;收缩值;16;0;Create;False;0;0;0;False;0;False;0.8270243;0.573;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;237.9857,352.9777;Inherit;False;192;OutlineWigth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-161.3676,1239.391;Inherit;False;192;OutlineWigth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-344.193,1150.51;Inherit;False;175;CustomChoose;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1047.116,1141.15;Inherit;False;Property;_Stroke;描边宽度;15;0;Create;False;0;0;0;False;0;False;1.238479;1.352;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-767.7888,1142.355;Inherit;False;OutlineWigth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;160;-1084.461,-163.4651;Inherit;False;Property;_MiaoUVFlow;描边屏幕UV与整体流动;14;0;Create;False;0;0;0;False;0;False;0,0,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;155;-1093.586,-721.0913;Inherit;False;Property;_TexUVFlow;屏幕UV与整体流动速度;5;0;Create;False;0;0;0;False;0;False;0,0,0,0;4,3,0.5,0.4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;214;-1060.944,333.1584;Inherit;False;Property;_NoiseV;扰动V方向速率;9;0;Create;False;0;0;0;False;0;False;1;-0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-1057.944,259.1587;Inherit;False;Property;_NoiseU;扰动U方向速率;8;0;Create;False;0;0;0;False;0;False;1;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;219;-1048.944,135.1994;Inherit;False;0;217;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;215;-892.9041,265.2794;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;216;-742.2662,140.7966;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;225;-284.3939,136.0436;Inherit;False;NoiseT;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-466.5873,-967.5554;Inherit;False;Property;_NoiseInt;扰动强度;7;0;Create;False;0;0;0;False;0;False;0.06342169;0.103;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-463.0365,-762.6705;Inherit;False;225;NoiseT;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;222;-199.587,-886.9554;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;88;-56.29512,-664.1447;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;22;116.8487,-868.2772;Inherit;False;Property;_MainColor;主体颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;2,2,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;407.3895,-686.9478;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;540.535,-692.5476;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;228;1018.505,-497.3044;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;890.6663,-497.3458;Inherit;False;Property;_CullingMode;剔除模式;0;2;[Header];[Enum];Create;False;1;Settings;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;116.1453,-692.0968;Inherit;True;Property;_MainTex;主贴图;2;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;70429964131645f4abf190ff44a2ae31;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;217;-566.1862,111.9173;Inherit;True;Property;_Distr;扰动贴图;6;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;None;7e8dfd0c9de33d446b68aa25b33d466f;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;128;-181.6068,-355.7435;Inherit;True;Property;_ScreenOutLineTex;描边帖图;10;1;[Header];Create;False;1;OutlineTex;0;0;False;0;False;-1;None;c6d166d5abfa9d742bff2fc3a1feeafe;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;186;1719.335,326.2342;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;229;320.4641,-868.012;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2011.433,325.2917;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/特殊制作/视差星星收缩;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;True;_CullingMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;91;0;155;3
WireConnection;91;1;155;4
WireConnection;84;0;26;2
WireConnection;84;1;155;2
WireConnection;82;0;26;1
WireConnection;82;1;155;1
WireConnection;86;0;82;0
WireConnection;86;1;84;0
WireConnection;153;0;93;0
WireConnection;153;1;86;0
WireConnection;153;2;154;0
WireConnection;122;0;119;1
WireConnection;122;1;160;1
WireConnection;121;0;119;2
WireConnection;121;1;160;2
WireConnection;123;0;122;0
WireConnection;123;1;121;0
WireConnection;125;0;160;3
WireConnection;125;1;160;4
WireConnection;162;0;161;0
WireConnection;162;1;123;0
WireConnection;162;2;163;0
WireConnection;124;0;162;0
WireConnection;124;2;125;0
WireConnection;129;0;128;0
WireConnection;129;1;20;0
WireConnection;165;0;20;0
WireConnection;165;1;129;0
WireConnection;165;2;166;0
WireConnection;49;0;48;2
WireConnection;39;0;48;1
WireConnection;39;1;48;2
WireConnection;32;0;39;0
WireConnection;32;1;41;0
WireConnection;41;0;48;1
WireConnection;41;1;49;0
WireConnection;40;0;41;0
WireConnection;40;1;39;0
WireConnection;171;0;40;0
WireConnection;170;0;32;0
WireConnection;59;0;58;0
WireConnection;59;1;193;0
WireConnection;58;0;177;0
WireConnection;55;0;58;0
WireConnection;55;1;174;0
WireConnection;56;0;58;0
WireConnection;56;1;173;0
WireConnection;63;0;55;0
WireConnection;63;1;56;0
WireConnection;65;0;63;0
WireConnection;62;0;59;0
WireConnection;62;1;174;0
WireConnection;61;0;59;0
WireConnection;61;1;173;0
WireConnection;64;0;61;0
WireConnection;64;1;62;0
WireConnection;66;0;64;0
WireConnection;34;0;66;0
WireConnection;34;1;65;0
WireConnection;9;0;8;0
WireConnection;9;1;190;0
WireConnection;8;0;172;0
WireConnection;8;1;169;0
WireConnection;180;0;165;0
WireConnection;15;0;176;0
WireConnection;12;0;8;0
WireConnection;12;1;15;0
WireConnection;16;0;9;0
WireConnection;16;1;15;0
WireConnection;18;0;16;0
WireConnection;18;1;12;0
WireConnection;111;0;68;1
WireConnection;158;0;13;0
WireConnection;158;1;115;0
WireConnection;158;2;159;0
WireConnection;175;0;158;0
WireConnection;37;0;183;0
WireConnection;37;1;65;0
WireConnection;35;0;181;0
WireConnection;35;1;34;0
WireConnection;38;0;37;0
WireConnection;38;1;35;0
WireConnection;21;0;18;0
WireConnection;21;1;185;0
WireConnection;23;0;184;0
WireConnection;23;1;12;0
WireConnection;19;0;23;0
WireConnection;19;1;21;0
WireConnection;192;0;10;0
WireConnection;215;0;220;0
WireConnection;215;1;214;0
WireConnection;216;0;219;0
WireConnection;216;2;215;0
WireConnection;225;0;217;1
WireConnection;222;0;153;0
WireConnection;222;1;224;0
WireConnection;222;2;218;0
WireConnection;88;0;222;0
WireConnection;88;2;91;0
WireConnection;25;0;24;0
WireConnection;25;1;22;0
WireConnection;25;2;229;0
WireConnection;182;0;25;0
WireConnection;24;1;88;0
WireConnection;217;1;216;0
WireConnection;128;1;124;0
WireConnection;186;0;19;0
WireConnection;186;1;38;0
WireConnection;186;2;187;0
WireConnection;0;0;186;0
ASEEND*/
//CHKSM=E881F2A4EFF813134C6EE91D4957B6FEF0A36BCB