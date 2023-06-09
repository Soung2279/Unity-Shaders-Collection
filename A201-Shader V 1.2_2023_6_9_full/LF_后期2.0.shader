// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/后期处理/黑白闪+色散+晕影后处理2.0"
{
	Properties
	{
		_Float20("色阶黑", Float) = 0
		_Float19("色阶白", Float) = 1
		_Float24("暗角强度", Float) = 0
		_Float31("暗角阈值", Range( 0 , 1)) = 0
		_Float6("中心位置U", Range( -0.5 , 0.5)) = 0
		_Float7("中心位置V", Range( -0.5 , 0.5)) = 0
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_TextureSample1("Mask", 2D) = "white" {}
		[Enum(R,0,A,1)]_Float29("Mask通道", Float) = 0
		[Toggle]_Float10("OneMinusMask", Float) = 0
		_Float9("Mask强度", Float) = 1
		_MaskPower("MaskPower", Float) = 1
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_Float5("模糊缩放", Float) = 0
		[Enum(Material,0,Custom1x,1)]_Float37("模糊控制方式", Float) = 0
		_Float11("色散强度", Float) = 0
		[Enum(Material,0,Custom1y,1)]_Float36("色散控制方式", Float) = 0
		_Float8("色散模糊比重", Range( 0 , 1)) = 0
		_Float25("放射纹理强度", Float) = 0
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Toggle][Space(10) ]_Float34("黑白闪开关", Float) = 0
		[Enum(Material,0,Custom1w,1)]_Float35("黑白闪开关控制方式(0:Off,1:Ture)", Float) = 0
		_Color0("黑白闪颜色1", Color) = (1,1,1,1)
		_Color1("黑白闪颜色2", Color) = (0,0,0,1)
		[Toggle]_Float17("黑白切换", Float) = 0
		[Enum(Material,0,ParticleAlphy,1)]_Float33("黑白切换控制方式", Float) = 0
		_TextureSample0("黑白闪纹理", 2D) = "white" {}
		[Enum(U,0,V,1)]_Float30("极坐标方向", Float) = 0
		[Enum(Material,0,Custom1z,1)]_Float32("黑白闪流动控制方式", Float) = 0
		_Float21("黑白闪纹理强度", Range( 0 , 1)) = 0
		[HideInInspector]_TextureSample0_ST("_TextureSample0_ST", Vector) = (10,0.4,0,0)
		_Float2("黑白范围", Range( 0 , 1)) = 1
		_Float3("黑白过度", Range( 0 , 0.1)) = 0
		[Header(_________________________________________________________________________________________________________________________________________)][Enum(Partercal,0,Material,1)][Space(10) ]_Float12("震屏测试(Custom2xy_UV震频,zw_UV振幅)", Float) = 1
		_Float15("U震频测试(随数值变化往复震动)", Float) = 0
		_Float18("V振频测试(随数值变化往复震动)", Float) = 0
		_Float13("U振幅测试", Range( 0 , 1)) = 0
		_Float14("V振幅测试", Range( 0 , 1)) = 0
		[HideInInspector]_TextureSample1_ST("_TextureSample1_ST", Vector) = (1,1,0,0)
		[Header(________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(10) ]_TextureSample2("肌理图", 2D) = "white" {}
		_Float27("旋转肌理图", Range( 0 , 1)) = 0
		_Float23("肌理混合", Range( 0 , 1)) = 0
		[HideInInspector]_TextureSample2_ST("_TextureSample2_ST", Vector) = (1,1,0,0)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent+1000" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		
		
		GrabPass{ "_GrabScreen0" }

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


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _Float31;
			uniform float _Float24;
			uniform sampler2D _TextureSample2;
			uniform float _Float27;
			uniform float4 _TextureSample2_ST;
			uniform float _Float23;
			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabScreen0 )
			uniform float _Float15;
			uniform float _Float18;
			uniform float _Float13;
			uniform float _Float14;
			uniform float _Float12;
			uniform sampler2D _TextureSample0;
			uniform float _Float6;
			uniform float _Float7;
			uniform float _Float30;
			uniform float4 _TextureSample0_ST;
			uniform float _Float32;
			uniform float _Float25;
			uniform sampler2D _TextureSample1;
			uniform float4 _TextureSample1_ST;
			uniform float _Float29;
			uniform float _Float10;
			uniform float _MaskPower;
			uniform float _Float9;
			uniform float _Float5;
			uniform float _Float37;
			uniform float _Float11;
			uniform float _Float36;
			uniform float _Float8;
			uniform float4 _Color0;
			uniform float4 _Color1;
			uniform float _Float2;
			uniform float _Float3;
			uniform float _Float21;
			uniform float _Float17;
			uniform float _Float33;
			uniform float _Float34;
			uniform float _Float35;
			uniform float _Float20;
			uniform float _Float19;
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
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.color;
				
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
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult449 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult322 = (float2(( ase_screenPosNorm.x * ( _ScreenParams.x / _ScreenParams.y ) ) , ase_screenPosNorm.y));
				float cos430 = cos( ( _Float27 * UNITY_PI ) );
				float sin430 = sin( ( _Float27 * UNITY_PI ) );
				float2 rotator430 = mul( appendResult322 - float2( 0.5,0.5 ) , float2x2( cos430 , -sin430 , sin430 , cos430 )) + float2( 0.5,0.5 );
				float2 appendResult287 = (float2(_TextureSample2_ST.x , _TextureSample2_ST.y));
				float2 appendResult288 = (float2(_TextureSample2_ST.z , _TextureSample2_ST.w));
				float4 tex2DNode278 = tex2D( _TextureSample2, (rotator430*appendResult287 + appendResult288) );
				float temp_output_363_0 = (1.0 + (_Float23 - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0));
				float4 temp_cast_0 = (( tex2DNode278.r * temp_output_363_0 )).xxxx;
				float4 texCoord147 = i.ase_texcoord2;
				texCoord147.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult392 = (float4(_Float15 , _Float18 , _Float13 , _Float14));
				float4 lerpResult386 = lerp( texCoord147 , appendResult392 , _Float12);
				float4 break224 = lerpResult386;
				float2 appendResult212 = (float2(( sin( break224.x ) * break224.z * 0.5 ) , ( sin( break224.y ) * break224.w * 0.5 )));
				float2 clampResult385 = clamp( appendResult212 , float2( -1,-1 ) , float2( 1,1 ) );
				float2 UV376 = ((ase_grabScreenPosNorm).xy*1.0 + clampResult385);
				float2 appendResult65 = (float2(_Float6 , _Float7));
				float2 pianyi2274 = ( UV376 - appendResult65 );
				float2 texCoord257 = i.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break245 = float2( 1,0 );
				float cos248 = cos( ( length( (texCoord257*2.0 + -1.0) ) * break245.y ) );
				float sin248 = sin( ( length( (texCoord257*2.0 + -1.0) ) * break245.y ) );
				float2 rotator248 = mul( pianyi2274 - float2( 0.5,0.5 ) , float2x2( cos248 , -sin248 , sin248 , cos248 )) + float2( 0.5,0.5 );
				float2 temp_output_262_0 = (rotator248*2.0 + -1.0);
				float2 break255 = temp_output_262_0;
				float temp_output_261_0 = ( ( atan2( break255.y , break255.x ) / ( 2.0 * UNITY_PI ) ) + 0.5 );
				float temp_output_258_0 = pow( length( temp_output_262_0 ) , break245.x );
				float2 appendResult253 = (float2(temp_output_261_0 , temp_output_258_0));
				float2 appendResult247 = (float2(temp_output_258_0 , temp_output_261_0));
				float2 lerpResult302 = lerp( appendResult253 , appendResult247 , _Float30);
				float2 appendResult154 = (float2(_TextureSample0_ST.z , _TextureSample0_ST.w));
				float4 texCoord150 = i.ase_texcoord4;
				texCoord150.xy = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult153 = (float2(_TextureSample0_ST.z , texCoord150.z));
				float2 lerpResult306 = lerp( appendResult154 , appendResult153 , _Float32);
				float4 appendResult155 = (float4(_TextureSample0_ST.xy , lerpResult306));
				float4 break242 = appendResult155;
				float2 appendResult252 = (float2(break242.x , break242.y));
				float2 appendResult241 = (float2(break242.z , break242.w));
				float2 break237 = (lerpResult302*appendResult252 + appendResult241);
				float2 appendResult243 = (float2(break237.x , break237.y));
				float jizuobiao407 = tex2D( _TextureSample0, appendResult243 ).r;
				float2 temp_cast_2 = (jizuobiao407).xx;
				float2 appendResult166 = (float2(_TextureSample1_ST.x , _TextureSample1_ST.y));
				float2 appendResult167 = (float2(_TextureSample1_ST.z , _TextureSample1_ST.w));
				float4 tex2DNode130 = tex2D( _TextureSample1, (UV376*appendResult166 + appendResult167) );
				float lerpResult299 = lerp( tex2DNode130.r , tex2DNode130.a , _Float29);
				float lerpResult364 = lerp( lerpResult299 , ( 1.0 - lerpResult299 ) , _Float10);
				float mask173 = saturate( ( pow( lerpResult364 , _MaskPower ) * _Float9 ) );
				float2 lerpResult416 = lerp( UV376 , temp_cast_2 , ( _Float25 * 0.01 * mask173 ));
				float2 jizuobiao_pianyig421 = lerpResult416;
				half2 pianyi74 = ( jizuobiao_pianyig421 - (float2( 0,0 ) + (appendResult65 - float2( -0.5,-0.5 )) * (float2( 1,1 ) - float2( 0,0 )) / (float2( 0.5,0.5 ) - float2( -0.5,-0.5 ))) );
				float4 texCoord144 = i.ase_texcoord4;
				texCoord144.xy = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult316 = lerp( _Float5 , texCoord144.x , _Float37);
				float2 temp_output_51_0 = ( pianyi74 * float2( 0.01,0.01 ) * lerpResult316 );
				float2 temp_output_72_0 = ( jizuobiao_pianyig421 - temp_output_51_0 );
				float4 screenColor1 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_72_0);
				float4 texCoord186 = i.ase_texcoord4;
				texCoord186.xy = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult313 = lerp( _Float11 , texCoord186.y , _Float36);
				float2 temp_output_189_0 = ( lerpResult313 * float2( 0.01,0.01 ) * pianyi74 );
				float2 temp_output_190_0 = ( jizuobiao_pianyig421 - temp_output_189_0 );
				float4 screenColor185 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_190_0);
				float2 temp_output_191_0 = ( temp_output_190_0 - temp_output_189_0 );
				float4 screenColor183 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_191_0);
				float4 screenColor184 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,( temp_output_191_0 - temp_output_189_0 ));
				float4 appendResult60 = (float4(screenColor185.r , screenColor183.g , screenColor184.b , 1.0));
				float2 temp_output_80_0 = ( temp_output_72_0 - temp_output_51_0 );
				float4 screenColor38 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_80_0);
				float2 temp_output_81_0 = ( temp_output_80_0 - temp_output_51_0 );
				float4 screenColor61 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_81_0);
				float2 temp_output_96_0 = ( temp_output_81_0 - temp_output_51_0 );
				float4 screenColor82 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_96_0);
				float2 temp_output_97_0 = ( temp_output_96_0 - temp_output_51_0 );
				float4 screenColor83 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_97_0);
				float2 temp_output_98_0 = ( temp_output_97_0 - temp_output_51_0 );
				float4 screenColor84 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_98_0);
				float2 temp_output_99_0 = ( temp_output_98_0 - temp_output_51_0 );
				float4 screenColor85 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_99_0);
				float2 temp_output_100_0 = ( temp_output_99_0 - temp_output_51_0 );
				float4 screenColor86 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_100_0);
				float2 temp_output_101_0 = ( temp_output_100_0 - temp_output_51_0 );
				float4 screenColor87 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_101_0);
				float2 temp_output_103_0 = ( temp_output_101_0 - temp_output_51_0 );
				float4 screenColor88 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_103_0);
				float2 temp_output_102_0 = ( temp_output_103_0 - temp_output_51_0 );
				float4 screenColor89 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_102_0);
				float2 temp_output_105_0 = ( temp_output_102_0 - temp_output_51_0 );
				float4 screenColor90 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_105_0);
				float2 temp_output_104_0 = ( temp_output_105_0 - temp_output_51_0 );
				float4 screenColor91 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_104_0);
				float2 temp_output_107_0 = ( temp_output_104_0 - temp_output_51_0 );
				float4 screenColor92 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_107_0);
				float2 temp_output_106_0 = ( temp_output_107_0 - temp_output_51_0 );
				float4 screenColor93 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_106_0);
				float2 temp_output_109_0 = ( temp_output_106_0 - temp_output_51_0 );
				float4 screenColor94 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_109_0);
				float2 temp_output_112_0 = ( temp_output_109_0 - temp_output_51_0 );
				float4 screenColor116 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_112_0);
				float2 temp_output_113_0 = ( temp_output_112_0 - temp_output_51_0 );
				float4 screenColor117 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_113_0);
				float2 temp_output_115_0 = ( temp_output_113_0 - temp_output_51_0 );
				float4 screenColor118 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,temp_output_115_0);
				float4 screenColor119 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,( temp_output_115_0 - temp_output_51_0 ));
				float4 appendResult123 = (float4(( ( ( screenColor1 + screenColor38 + screenColor61 + screenColor82 + screenColor83 + screenColor84 + screenColor85 + screenColor86 + screenColor87 + screenColor88 ) + ( screenColor89 + screenColor90 + screenColor91 + screenColor92 + screenColor93 + screenColor94 + screenColor116 + screenColor117 + screenColor118 + screenColor119 ) ) / 20.0 ).rgb , 1.0));
				float4 lerpResult128 = lerp( appendResult60 , appendResult123 , _Float8);
				float4 lerpResult131 = lerp( screenColor1 , lerpResult128 , mask173);
				float4 mohu194 = lerpResult131;
				float3 desaturateInitialColor25 = mohu194.xyz;
				float desaturateDot25 = dot( desaturateInitialColor25, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar25 = lerp( desaturateInitialColor25, desaturateDot25.xxx, 1.0 );
				float temp_output_27_0 = (desaturateVar25).x;
				float lerpResult233 = lerp( 1.0 , jizuobiao407 , _Float21);
				float lerpResult181 = lerp( temp_output_27_0 , lerpResult233 , mask173);
				float smoothstepResult11 = smoothstep( _Float2 , ( _Float2 + _Float3 ) , ( temp_output_27_0 + ( temp_output_27_0 * lerpResult181 ) ));
				float lerpResult307 = lerp( _Float17 , i.ase_color.a , _Float33);
				float lerpResult32 = lerp( smoothstepResult11 , ( 1.0 - smoothstepResult11 ) , lerpResult307);
				float4 lerpResult15 = lerp( _Color0 , _Color1 , lerpResult32);
				float4 texCoord408 = i.ase_texcoord4;
				texCoord408.xy = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult311 = lerp( _Float34 , texCoord408.w , _Float35);
				float4 lerpResult225 = lerp( mohu194 , lerpResult15 , lerpResult311);
				float4 temp_cast_7 = (_Float20).xxxx;
				float4 temp_cast_8 = (_Float19).xxxx;
				float4 lerpResult283 = lerp( temp_cast_0 , (temp_cast_7 + (lerpResult225 - float4( 0,0,0,0 )) * (temp_cast_8 - temp_cast_7) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) , saturate( ( tex2DNode278.r + temp_output_363_0 ) ));
				
				
				finalColor = ( pow( (1.0 + (distance( appendResult449 , float2( 0.5,0.5 ) ) - 0.0) * (0.0 - 1.0) / (( 1.0 - _Float31 ) - 0.0)) , _Float24 ) * lerpResult283 );
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
Node;AmplifyShaderEditor.CommentaryNode;277;-4736.962,-1105.137;Inherit;False;1998.289;512.6697; 震屏;20;387;214;204;211;2;399;398;382;376;381;385;212;147;386;224;392;389;388;393;394;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-4727.046,-681.1764;Inherit;False;Property;_Float14;V振幅测试;34;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-4729.046,-774.1762;Inherit;False;Property;_Float13;U振幅测试;33;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;-4717.046,-966.1779;Inherit;False;Property;_Float15;U震频测试(随数值变化往复震动);31;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-4719.046,-864.1762;Inherit;False;Property;_Float18;V振频测试(随数值变化往复震动);32;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;-4417.177,-1059.416;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;392;-4416.046,-883.176;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-4418.06,-676.2609;Inherit;False;Property;_Float12;震屏测试(Custom2xy_UV震频,zw_UV振幅);30;2;[Header];[Enum];Create;False;1;_________________________________________________________________________________________________________________________________________;2;Partercal;0;Material;1;0;False;1;Space(10) ;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;386;-4159.158,-920.591;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;224;-3995.397,-917.8846;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SinOpNode;398;-3828.661,-1009.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-3884.45,-691.9223;Inherit;False;Constant;_Float16;Float 16;28;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;399;-3829.865,-925.0755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-3609.678,-736.8029;Inherit;False;3;3;0;FLOAT;0.001;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-3600.625,-853.7363;Inherit;False;3;3;0;FLOAT;0.001;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;212;-3458.31,-829.3328;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;2;-3620.45,-1028.172;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;382;-3322.773,-969.6219;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;385;-3319.568,-829.7615;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;381;-3123.311,-964.6978;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;276;-4132.915,-1712.394;Inherit;False;1176.905;515.004;中心偏移;16;74;414;421;413;416;418;425;417;429;419;274;62;65;377;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4073.315,-1383.544;Inherit;False;Property;_Float6;中心位置U;4;0;Create;False;0;0;0;False;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;272;-2924.931,-1709.787;Inherit;False;3039.915;564.56;极坐标;35;305;154;153;150;267;236;257;8;407;6;243;237;239;302;252;241;301;253;242;247;261;258;155;256;306;260;263;244;255;262;248;275;259;245;246;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;376;-2929.56,-964.0715;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-4079.315,-1290.543;Inherit;False;Property;_Float7;中心位置V;5;0;Create;False;0;0;0;False;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;-3571.898,-1482.731;Inherit;False;376;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;257;-2905.085,-1559.392;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;65;-3761.315,-1369.844;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;267;-2657.549,-1439.935;Inherit;False;Constant;_Vector3;Vector 3;35;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;236;-2677.698,-1556.874;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-3295.379,-1480.352;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;246;-2480.069,-1547.83;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-3151.076,-1482.538;Inherit;False;pianyi2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;245;-2487.332,-1470.156;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-2368.353,-1542.314;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-2401.934,-1631.612;Inherit;False;274;pianyi2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;178;-5112.011,-564.1052;Inherit;False;2063.579;381.6744;Mask;17;173;142;132;133;299;298;166;378;130;164;167;165;365;367;368;364;366;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;248;-2238.954,-1586.077;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;165;-5074.589,-387.5508;Inherit;False;Property;_TextureSample1_ST;_TextureSample1_ST;35;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;262;-2046.359,-1587.058;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;167;-4847.256,-303.5507;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;8;-2361.924,-1413.856;Inherit;False;Property;_TextureSample0_ST;_TextureSample0_ST;27;1;[HideInInspector];Create;False;0;0;0;False;0;False;10,0.4,0,0;10,0.4,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;378;-4993.495,-476.9852;Inherit;False;376;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;166;-4846.553,-398.0986;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;150;-2606.494,-1317.503;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;255;-1812.152,-1647.514;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;244;-1667.152,-1650.514;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-2062.723,-1269.132;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;164;-4680.333,-464.5538;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-1777.144,-1253.253;Inherit;False;Property;_Float32;黑白闪流动控制方式;25;1;[Enum];Create;False;0;2;Material;0;Custom1z;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;263;-1729.152,-1546.515;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-2059.115,-1357.481;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;256;-1538.153,-1649.514;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-4342.993,-290.4895;Inherit;False;Property;_Float29;Mask通道;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;260;-1842.789,-1500.248;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;-4492.199,-488.0501;Inherit;True;Property;_TextureSample1;Mask;6;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;306;-1569.553,-1375.509;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-1402.99,-1440.104;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;299;-4144.825,-452.8099;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;261;-1407.854,-1650.215;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;258;-1555.381,-1501.462;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;366;-3982.617,-386.0197;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;253;-1252.267,-1662.105;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-4011.772,-306.0529;Inherit;False;Property;_Float10;OneMinusMask;8;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;-1252.105,-1476.582;Inherit;False;Property;_Float30;极坐标方向;24;1;[Enum];Create;False;0;2;U;0;V;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;242;-1249.75,-1400.485;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;247;-1249.026,-1567.608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-3808.641,-326.9616;Inherit;False;Property;_MaskPower;MaskPower;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;252;-1014.09,-1484.751;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;302;-1005.107,-1613.733;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-1011.473,-1354.437;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;364;-3812.762,-453.3644;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-3641.71,-322.2978;Inherit;False;Property;_Float9;Mask强度;9;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;367;-3656.13,-453.3644;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;239;-845.8013,-1528.134;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;237;-655.4673,-1529.465;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-3501.275,-457.6354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;142;-3370.284,-459.0595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;-519.1553,-1530.952;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-371.9388,-1559.712;Inherit;True;Property;_TextureSample0;黑白闪纹理;23;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-3236.891,-463.8931;Inherit;False;mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-4104.018,-1566.562;Inherit;False;Property;_Float25;放射纹理强度;16;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;-75.17916,-1539.392;Inherit;False;jizuobiao;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-4116.293,-1473.795;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;-3916.753,-1664.985;Inherit;False;376;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;-3915.163,-1588.147;Inherit;False;407;jizuobiao;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;425;-3886.148,-1514.111;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;416;-3678.63,-1654.28;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;413;-3522.328,-1371.762;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;2;FLOAT2;0.5,0.5;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;421;-3519.04,-1657.439;Inherit;False;jizuobiao_pianyig;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;414;-3299.162,-1652.715;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;160;-3614.383,73.32238;Inherit;False;3029.239;3776.961;色散模糊;60;423;73;194;131;174;128;129;123;124;121;122;120;110;111;91;94;1;89;82;117;61;92;38;119;83;88;86;118;116;85;87;90;84;93;114;115;113;112;109;106;107;104;105;102;103;101;100;99;98;97;96;81;80;72;51;316;144;52;315;424;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-3166.746,-1649.419;Half;False;pianyi;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-3485.702,410.1396;Inherit;False;Property;_Float5;模糊缩放;11;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;-3552.585,492.2527;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;315;-3408.793,687.8748;Inherit;False;Property;_Float37;模糊控制方式;12;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;316;-3212.467,547.4677;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3170.778,232.64;Inherit;False;74;pianyi;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;423;-3001.723,139.5231;Inherit;False;421;jizuobiao_pianyig;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2931.264,232.5079;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0.01,0.01;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-2710.308,145.4295;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;-2474.516,289.875;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-2444.516,501.4006;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-2507.049,677.8018;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-2477.049,889.328;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-2504.575,1128.17;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-2474.575,1339.695;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-2497.151,1489.452;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2476.401,1660.595;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-2475.058,1836.277;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-2442.583,2037.905;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2488.492,2231.815;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-2456.017,2433.444;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-2478.593,2578.251;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-2476.041,2773.895;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;193;-3041.498,-563.486;Inherit;False;1465.526;618.359;色散;14;60;183;184;185;192;191;190;189;313;188;314;186;420;422;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;-2485.674,2925.723;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-2484.066,3176.251;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;314;-2925.495,-158.5524;Inherit;False;Property;_Float36;色散控制方式;14;1;[Enum];Create;False;0;2;Material;0;Custom1y;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;186;-2979.306,-339.0989;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;188;-2957.695,-436.6658;Inherit;False;Property;_Float11;色散强度;13;0;Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-2506.642,3321.058;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;-2723.836,-403.5999;Inherit;False;74;pianyi;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;313;-2682.221,-316.8588;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-2525.186,-440.7775;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0.01,0.01;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-2504.09,3516.702;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;-2591.508,-515.2716;Inherit;False;421;jizuobiao_pianyig;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-2382.295,-510.283;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-2513.723,3668.528;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;84;-2275.967,1067.057;Inherit;False;Global;_GrabScreen6;Grab Screen 6;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;83;-2275.063,883.696;Inherit;False;Global;_GrabScreen5;Grab Screen 5;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;93;-2282.472,2738.013;Inherit;False;Global;_GrabScreen15;Grab Screen 15;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;86;-2260.157,1459.943;Inherit;False;Global;_GrabScreen8;Grab Screen 8;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;38;-2264.84,321.9986;Inherit;False;Global;_GrabScreen1;Grab Screen 1;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;82;-2271.967,704.0568;Inherit;False;Global;_GrabScreen4;Grab Screen 4;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;1;-2260.248,135.5534;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;90;-2275.376,2195.374;Inherit;False;Global;_GrabScreen12;Grab Screen 12;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-2236.244,-359.3539;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;89;-2271.345,1992.957;Inherit;False;Global;_GrabScreen11;Grab Screen 11;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;92;-2279.376,2558.374;Inherit;False;Global;_GrabScreen14;Grab Screen 14;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;61;-2267.936,501.6387;Inherit;False;Global;_GrabScreen2;Grab Screen 2;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;118;-2310.521,3480.82;Inherit;False;Global;_GrabScreen19;Grab Screen 19;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;94;-2279.509,2922.565;Inherit;False;Global;_GrabScreen16;Grab Screen 16;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;117;-2307.425,3301.181;Inherit;False;Global;_GrabScreen18;Grab Screen 18;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;116;-2306.521,3117.82;Inherit;False;Global;_GrabScreen17;Grab Screen 17;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;119;-2307.558,3665.37;Inherit;False;Global;_GrabScreen20;Grab Screen 20;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;88;-2268.249,1813.318;Inherit;False;Global;_GrabScreen10;Grab Screen 10;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;85;-2279.063,1246.695;Inherit;False;Global;_GrabScreen7;Grab Screen 7;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;87;-2263.253,1639.581;Inherit;False;Global;_GrabScreen9;Grab Screen 9;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;91;-2278.472,2375.013;Inherit;False;Global;_GrabScreen13;Grab Screen 13;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1813.566,460.2583;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1853.792,1997.213;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;192;-2188.009,-108.0437;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;185;-1999.108,-513.4861;Inherit;False;Global;_GrabScreen23;Grab Screen 23;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;183;-2002.204,-333.8467;Inherit;False;Global;_GrabScreen21;Grab Screen 21;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;184;-2006.235,-131.4286;Inherit;False;Global;_GrabScreen22;Grab Screen 22;0;0;Create;True;0;0;0;False;0;False;Instance;1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-1631.312,590.1537;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-1649.871,456.6212;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-1727.979,-312.9386;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;-1461.703,464.1137;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1456.684,584.8297;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;424;-1598.122,140.8784;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;-1330.785,467.8737;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1570.904,744.1427;Inherit;False;Property;_Float8;色散模糊比重;15;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-1146.372,419.333;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-1151.361,550.538;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;131;-951.918,359.7545;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;140;-2714.231,-1130.144;Inherit;False;2823.603;559.0208;黑白闪;33;312;307;16;11;325;34;308;229;197;225;15;231;232;311;23;310;32;408;28;30;14;31;13;29;181;233;27;177;235;409;234;25;195;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-772.9241,353.3435;Inherit;False;mohu;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-2689.742,-1053.608;Inherit;False;194;mohu;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-2580.523,-732.5659;Inherit;False;Property;_Float21;黑白闪纹理强度;26;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-2484.683,-940.4055;Inherit;False;Constant;_Float22;Float 22;34;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;-2499.984,-843.8369;Inherit;False;407;jizuobiao;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;25;-2513.467,-1051.962;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;27;-2275.187,-1038.264;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;233;-2228.632,-901.309;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;289;-1510.78,-558.8934;Inherit;False;1682.968;580.6578;肌理;18;324;323;282;363;281;278;285;430;288;287;286;431;322;320;432;318;321;319;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-2249.471,-778.3909;Inherit;False;173;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;319;-1498.091,-322.713;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;181;-2050.773,-922.1574;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2165.714,-690.6608;Inherit;False;Property;_Float3;黑白过度;29;0;Create;False;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1898.643,-974.9044;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2060.43,-796.671;Inherit;False;Property;_Float2;黑白范围;28;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;318;-1489.504,-513.8096;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;321;-1320.504,-297.8118;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;432;-1288.437,-208.5565;Inherit;False;Property;_Float27;旋转肌理图;37;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;320;-1206.349,-508.0658;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1764.439,-1034.115;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1736.688,-764.2158;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;286;-1496.183,-156.4492;Inherit;False;Property;_TextureSample2_ST;_TextureSample2_ST;39;1;[HideInInspector];Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;322;-1038.8,-494.2283;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;431;-1021.945,-328.7207;Inherit;False;1;0;FLOAT;1.12;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-1553.437,-913.1485;Inherit;False;Property;_Float17;黑白切换;21;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;11;-1568.391,-1032.808;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-1604.618,-662.1326;Inherit;False;Property;_Float33;黑白切换控制方式;22;1;[Enum];Create;False;0;2;Material;0;ParticleAlphy;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;34;-1571.361,-830.2374;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;450;218.1792,-1213.733;Inherit;False;826.9999;301;暗角;8;446;445;451;457;437;458;449;435;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;287;-1179.976,-132.4081;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;288;-1045.806,-82.79927;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;430;-852.7877,-464.6239;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;16;-1370.059,-878.5808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;307;-1344.253,-726.3637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;285;-676.1514,-462.5925;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;435;198.1643,-1172.733;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;312;-1083.761,-656.6249;Inherit;False;Property;_Float35;黑白闪开关控制方式(0:Off,1:Ture);18;1;[Enum];Create;False;0;2;Material;0;Custom1w;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;310;-799.4988,-823.8187;Inherit;False;Property;_Float34;黑白闪开关;17;2;[Header];[Toggle];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;2;Off;0;Ture;1;0;False;1;Space(10) ;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;32;-1159.271,-907.6461;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;282;-657.9757,-284.4778;Inherit;False;Property;_Float23;肌理混合;38;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;408;-1008.479,-830.9738;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-976.38,-1082.647;Inherit;False;Property;_Color0;黑白闪颜色1;19;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;28;-1201.306,-1080.208;Inherit;False;Property;_Color1;黑白闪颜色2;20;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;278;-430.11,-490.6191;Inherit;True;Property;_TextureSample2;肌理图;36;1;[Header];Create;False;1;________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________;0;0;False;1;Space(10) ;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;197;-719.7275,-1053.577;Inherit;False;194;mohu;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;311;-648.2902,-776.1107;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;449;435.1792,-1164.733;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;15;-730.7632,-960.7763;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;457;225.4384,-990.121;Inherit;False;Property;_Float31;暗角阈值;3;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;363;-346.7921,-277.8245;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-312.2306,-811.6902;Inherit;False;Property;_Float19;色阶白;1;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;458;536.4384,-1043.121;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;225;-473.9021,-991.1444;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;437;567.1792,-1157.733;Inherit;False;2;0;FLOAT2;0.5,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;323;-85.09055,-300.4572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-297.7314,-923.6901;Inherit;False;Property;_Float20;色阶黑;0;0;Create;False;1;_______________________________________________________________________________________________________________________;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-60.77313,-447.0432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;750.1792,-992.7329;Inherit;False;Property;_Float24;暗角强度;2;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;229;-78.30896,-993.7134;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;1,1,1,1;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;451;715.4384,-1156.121;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;324;38.65588,-303.5128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;283;326.9404,-846.4106;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;445;904.1792,-1151.733;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2.53;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;1074.179,-875.733;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;19;1215.312,-842.268;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/后期处理/黑白闪+色散+晕影后处理2.0;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;7;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=1000;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;392;0;393;0
WireConnection;392;1;394;0
WireConnection;392;2;388;0
WireConnection;392;3;389;0
WireConnection;386;0;147;0
WireConnection;386;1;392;0
WireConnection;386;2;387;0
WireConnection;224;0;386;0
WireConnection;398;0;224;0
WireConnection;399;0;224;1
WireConnection;204;0;399;0
WireConnection;204;1;224;3
WireConnection;204;2;214;0
WireConnection;211;0;398;0
WireConnection;211;1;224;2
WireConnection;211;2;214;0
WireConnection;212;0;211;0
WireConnection;212;1;204;0
WireConnection;382;0;2;0
WireConnection;385;0;212;0
WireConnection;381;0;382;0
WireConnection;381;2;385;0
WireConnection;376;0;381;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;236;0;257;0
WireConnection;62;0;377;0
WireConnection;62;1;65;0
WireConnection;246;0;236;0
WireConnection;274;0;62;0
WireConnection;245;0;267;0
WireConnection;259;0;246;0
WireConnection;259;1;245;1
WireConnection;248;0;275;0
WireConnection;248;2;259;0
WireConnection;262;0;248;0
WireConnection;167;0;165;3
WireConnection;167;1;165;4
WireConnection;166;0;165;1
WireConnection;166;1;165;2
WireConnection;255;0;262;0
WireConnection;244;0;255;1
WireConnection;244;1;255;0
WireConnection;153;0;8;3
WireConnection;153;1;150;3
WireConnection;164;0;378;0
WireConnection;164;1;166;0
WireConnection;164;2;167;0
WireConnection;154;0;8;3
WireConnection;154;1;8;4
WireConnection;256;0;244;0
WireConnection;256;1;263;0
WireConnection;260;0;262;0
WireConnection;130;1;164;0
WireConnection;306;0;154;0
WireConnection;306;1;153;0
WireConnection;306;2;305;0
WireConnection;155;0;8;0
WireConnection;155;2;306;0
WireConnection;299;0;130;1
WireConnection;299;1;130;4
WireConnection;299;2;298;0
WireConnection;261;0;256;0
WireConnection;258;0;260;0
WireConnection;258;1;245;0
WireConnection;366;0;299;0
WireConnection;253;0;261;0
WireConnection;253;1;258;0
WireConnection;242;0;155;0
WireConnection;247;0;258;0
WireConnection;247;1;261;0
WireConnection;252;0;242;0
WireConnection;252;1;242;1
WireConnection;302;0;253;0
WireConnection;302;1;247;0
WireConnection;302;2;301;0
WireConnection;241;0;242;2
WireConnection;241;1;242;3
WireConnection;364;0;299;0
WireConnection;364;1;366;0
WireConnection;364;2;365;0
WireConnection;367;0;364;0
WireConnection;367;1;368;0
WireConnection;239;0;302;0
WireConnection;239;1;252;0
WireConnection;239;2;241;0
WireConnection;237;0;239;0
WireConnection;132;0;367;0
WireConnection;132;1;133;0
WireConnection;142;0;132;0
WireConnection;243;0;237;0
WireConnection;243;1;237;1
WireConnection;6;1;243;0
WireConnection;173;0;142;0
WireConnection;407;0;6;1
WireConnection;425;0;419;0
WireConnection;425;2;429;0
WireConnection;416;0;417;0
WireConnection;416;1;418;0
WireConnection;416;2;425;0
WireConnection;413;0;65;0
WireConnection;421;0;416;0
WireConnection;414;0;421;0
WireConnection;414;1;413;0
WireConnection;74;0;414;0
WireConnection;316;0;52;0
WireConnection;316;1;144;1
WireConnection;316;2;315;0
WireConnection;51;0;73;0
WireConnection;51;2;316;0
WireConnection;72;0;423;0
WireConnection;72;1;51;0
WireConnection;80;0;72;0
WireConnection;80;1;51;0
WireConnection;81;0;80;0
WireConnection;81;1;51;0
WireConnection;96;0;81;0
WireConnection;96;1;51;0
WireConnection;97;0;96;0
WireConnection;97;1;51;0
WireConnection;98;0;97;0
WireConnection;98;1;51;0
WireConnection;99;0;98;0
WireConnection;99;1;51;0
WireConnection;100;0;99;0
WireConnection;100;1;51;0
WireConnection;101;0;100;0
WireConnection;101;1;51;0
WireConnection;103;0;101;0
WireConnection;103;1;51;0
WireConnection;102;0;103;0
WireConnection;102;1;51;0
WireConnection;105;0;102;0
WireConnection;105;1;51;0
WireConnection;104;0;105;0
WireConnection;104;1;51;0
WireConnection;107;0;104;0
WireConnection;107;1;51;0
WireConnection;106;0;107;0
WireConnection;106;1;51;0
WireConnection;109;0;106;0
WireConnection;109;1;51;0
WireConnection;112;0;109;0
WireConnection;112;1;51;0
WireConnection;113;0;112;0
WireConnection;113;1;51;0
WireConnection;313;0;188;0
WireConnection;313;1;186;2
WireConnection;313;2;314;0
WireConnection;189;0;313;0
WireConnection;189;2;420;0
WireConnection;115;0;113;0
WireConnection;115;1;51;0
WireConnection;190;0;422;0
WireConnection;190;1;189;0
WireConnection;114;0;115;0
WireConnection;114;1;51;0
WireConnection;84;0;98;0
WireConnection;83;0;97;0
WireConnection;93;0;106;0
WireConnection;86;0;100;0
WireConnection;38;0;80;0
WireConnection;82;0;96;0
WireConnection;1;0;72;0
WireConnection;90;0;105;0
WireConnection;191;0;190;0
WireConnection;191;1;189;0
WireConnection;89;0;102;0
WireConnection;92;0;107;0
WireConnection;61;0;81;0
WireConnection;118;0;115;0
WireConnection;94;0;109;0
WireConnection;117;0;113;0
WireConnection;116;0;112;0
WireConnection;119;0;114;0
WireConnection;88;0;103;0
WireConnection;85;0;99;0
WireConnection;87;0;101;0
WireConnection;91;0;104;0
WireConnection;110;0;1;0
WireConnection;110;1;38;0
WireConnection;110;2;61;0
WireConnection;110;3;82;0
WireConnection;110;4;83;0
WireConnection;110;5;84;0
WireConnection;110;6;85;0
WireConnection;110;7;86;0
WireConnection;110;8;87;0
WireConnection;110;9;88;0
WireConnection;111;0;89;0
WireConnection;111;1;90;0
WireConnection;111;2;91;0
WireConnection;111;3;92;0
WireConnection;111;4;93;0
WireConnection;111;5;94;0
WireConnection;111;6;116;0
WireConnection;111;7;117;0
WireConnection;111;8;118;0
WireConnection;111;9;119;0
WireConnection;192;0;191;0
WireConnection;192;1;189;0
WireConnection;185;0;190;0
WireConnection;183;0;191;0
WireConnection;184;0;192;0
WireConnection;120;0;110;0
WireConnection;120;1;111;0
WireConnection;60;0;185;1
WireConnection;60;1;183;2
WireConnection;60;2;184;3
WireConnection;121;0;120;0
WireConnection;121;1;122;0
WireConnection;424;0;60;0
WireConnection;123;0;121;0
WireConnection;123;3;124;0
WireConnection;128;0;424;0
WireConnection;128;1;123;0
WireConnection;128;2;129;0
WireConnection;131;0;1;0
WireConnection;131;1;128;0
WireConnection;131;2;174;0
WireConnection;194;0;131;0
WireConnection;25;0;195;0
WireConnection;27;0;25;0
WireConnection;233;0;235;0
WireConnection;233;1;409;0
WireConnection;233;2;234;0
WireConnection;181;0;27;0
WireConnection;181;1;233;0
WireConnection;181;2;177;0
WireConnection;13;0;27;0
WireConnection;13;1;181;0
WireConnection;321;0;319;1
WireConnection;321;1;319;2
WireConnection;320;0;318;1
WireConnection;320;1;321;0
WireConnection;14;0;27;0
WireConnection;14;1;13;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;322;0;320;0
WireConnection;322;1;318;2
WireConnection;431;0;432;0
WireConnection;11;0;14;0
WireConnection;11;1;29;0
WireConnection;11;2;30;0
WireConnection;287;0;286;1
WireConnection;287;1;286;2
WireConnection;288;0;286;3
WireConnection;288;1;286;4
WireConnection;430;0;322;0
WireConnection;430;2;431;0
WireConnection;16;0;11;0
WireConnection;307;0;325;0
WireConnection;307;1;34;4
WireConnection;307;2;308;0
WireConnection;285;0;430;0
WireConnection;285;1;287;0
WireConnection;285;2;288;0
WireConnection;32;0;11;0
WireConnection;32;1;16;0
WireConnection;32;2;307;0
WireConnection;278;1;285;0
WireConnection;311;0;310;0
WireConnection;311;1;408;4
WireConnection;311;2;312;0
WireConnection;449;0;435;1
WireConnection;449;1;435;2
WireConnection;15;0;23;0
WireConnection;15;1;28;0
WireConnection;15;2;32;0
WireConnection;363;0;282;0
WireConnection;458;0;457;0
WireConnection;225;0;197;0
WireConnection;225;1;15;0
WireConnection;225;2;311;0
WireConnection;437;0;449;0
WireConnection;323;0;278;1
WireConnection;323;1;363;0
WireConnection;281;0;278;1
WireConnection;281;1;363;0
WireConnection;229;0;225;0
WireConnection;229;3;232;0
WireConnection;229;4;231;0
WireConnection;451;0;437;0
WireConnection;451;2;458;0
WireConnection;324;0;323;0
WireConnection;283;0;281;0
WireConnection;283;1;229;0
WireConnection;283;2;324;0
WireConnection;445;0;451;0
WireConnection;445;1;446;0
WireConnection;444;0;445;0
WireConnection;444;1;283;0
WireConnection;19;0;444;0
ASEEND*/
//CHKSM=F139FCFCECDF6B63EBF91CB8DBE313A80245BA14