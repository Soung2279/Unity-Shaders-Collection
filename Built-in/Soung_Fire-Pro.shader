// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/个人制作/风格化火焰_程序纹理"
{
	Properties
	{
		[HDR][Header(FireColor)]_Color2("内焰颜色", Color) = (1,0.639221,0,1)
		[HDR]_Color1("外焰颜色", Color) = (1,0,0,1)
		_Float2("外焰宽度", Range( 0 , 1)) = 0
		[HDR]_Color0("描边颜色", Color) = (0,0,0,1)
		_Float1("描边宽度", Range( 0 , 1)) = 0
		[Header(Details)]_Float4("细节1流动强度 (建议默认)", Float) = 2
		_Float3("细节1缩放", Float) = 5.09
		_TillSpeed("细节1偏移与流动", Vector) = (2,1,0,-1)
		_Float6("细节2流动强度 (建议默认)", Float) = 0.6
		_Float5("细节2缩放", Float) = 3
		_TillSpeed02("细节2偏移与流动", Vector) = (2,1,0,-0.7)
		[Header(Dissolve)]_Float0("火焰溶解", Range( 0 , 2)) = 0
		_Float10("火焰主体大小 (不溶解部分)", Range( 0 , 10)) = 1
		_Float8("火焰范围", Range( 0 , 1)) = 1
		_Vector1("火焰范围偏移 (CustomeXY)", Vector) = (0,0,0,0)
		_Float7("整体溶解倍增 (建议默认)", Range( 0 , 1)) = 0.1
		[KeywordEnum(Up,Down,Left,Right,OFF)] _SwitchUP("火焰方向 (使用遮罩时关闭)", Float) = 0
		[Toggle]_CustomeZ("CustomeZ控制溶解", Float) = 0
		[Header(Mask)]_manuMask("刀光遮罩", 2D) = "white" {}
		[KeywordEnum(A,R)] _switchmaskp("切换遮罩通道", Float) = 0
		[Toggle]_OpenDepth("开启深度 (模型穿插地面时启用)", Float) = 0

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
		Cull Off
		ColorMask RGBA
		ZWrite [_OpenDepth]
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
			#pragma shader_feature_local _SWITCHUP_UP _SWITCHUP_DOWN _SWITCHUP_LEFT _SWITCHUP_RIGHT _SWITCHUP_OFF
			#pragma shader_feature_local _SWITCHMASKP_A _SWITCHMASKP_R


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
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

			uniform float _OpenDepth;
			uniform float4 _Color0;
			uniform float4 _Color1;
			uniform float4 _Color2;
			uniform float _Float2;
			uniform float _Float1;
			uniform float _Float0;
			uniform float _CustomeZ;
			uniform float _Float7;
			uniform float _Float3;
			uniform float _Float4;
			uniform float4 _TillSpeed;
			uniform float _Float5;
			uniform float _Float6;
			uniform float4 _TillSpeed02;
			uniform float2 _Vector1;
			uniform float _Float8;
			uniform float _Float10;
			uniform sampler2D _manuMask;
			uniform float4 _manuMask_ST;
					float2 voronoihash19( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi19( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash19( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash30( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi30( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash30( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1 = v.ase_texcoord2;
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
				float4 texCoord76 = i.ase_texcoord1;
				texCoord76.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult75 = lerp( _Float0 , texCoord76.z , _CustomeZ);
				float temp_output_44_0 = ( lerpResult75 * _Float7 );
				float temp_output_8_0 = ( _Float1 + temp_output_44_0 );
				float time19 = ( _Time.y * _Float4 );
				float2 voronoiSmoothId19 = 0;
				float2 appendResult29 = (float2(_TillSpeed.z , _TillSpeed.w));
				float2 appendResult28 = (float2(_TillSpeed.x , _TillSpeed.y));
				float2 texCoord26 = i.ase_texcoord2.xy * appendResult28 + float2( 0,0 );
				float2 panner24 = ( 1.0 * _Time.y * appendResult29 + texCoord26);
				float2 coords19 = panner24 * _Float3;
				float2 id19 = 0;
				float2 uv19 = 0;
				float voroi19 = voronoi19( coords19, time19, id19, uv19, 0, voronoiSmoothId19 );
				float time30 = ( _Time.y * _Float6 );
				float2 voronoiSmoothId30 = 0;
				float2 appendResult37 = (float2(_TillSpeed02.z , _TillSpeed02.w));
				float2 appendResult38 = (float2(_TillSpeed02.x , _TillSpeed02.y));
				float2 texCoord36 = i.ase_texcoord2.xy * appendResult38 + float2( 0,0 );
				float2 panner35 = ( 1.0 * _Time.y * appendResult37 + texCoord36);
				float2 coords30 = panner35 * _Float5;
				float2 id30 = 0;
				float2 uv30 = 0;
				float voroi30 = voronoi30( coords30, time30, id30, uv30, 0, voronoiSmoothId30 );
				float blendOpSrc40 = voroi19;
				float blendOpDest40 = voroi30;
				float2 _Vector0 = float2(0.5,0.5);
				float4 texCoord80 = i.ase_texcoord1;
				texCoord80.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult58 = (float2(( _Vector0.x + _Vector1.x + texCoord80.x ) , ( _Vector0.y + _Vector1.y + texCoord80.y )));
				float2 texCoord51 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_52_0 = (1.0 + (distance( appendResult58 , texCoord51 ) - 0.0) * (0.0 - 1.0) / (_Float8 - 0.0));
				float2 texCoord63 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord67 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord70 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord72 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_SWITCHUP_UP)
				float staticSwitch66 = ( 1.0 - saturate( texCoord63.y ) );
				#elif defined(_SWITCHUP_DOWN)
				float staticSwitch66 = saturate( texCoord67.y );
				#elif defined(_SWITCHUP_LEFT)
				float staticSwitch66 = saturate( texCoord70.x );
				#elif defined(_SWITCHUP_RIGHT)
				float staticSwitch66 = ( 1.0 - saturate( texCoord72.x ) );
				#elif defined(_SWITCHUP_OFF)
				float staticSwitch66 = 1.0;
				#else
				float staticSwitch66 = ( 1.0 - saturate( texCoord63.y ) );
				#endif
				float temp_output_41_0 = saturate( ( ( ( saturate( (( blendOpDest40 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest40 ) * ( 1.0 - blendOpSrc40 ) ) : ( 2.0 * blendOpDest40 * blendOpSrc40 ) ) )) * temp_output_52_0 ) + ( temp_output_52_0 * 0.1 * _Float10 * staticSwitch66 ) ) );
				float4 lerpResult17 = lerp( _Color1 , _Color2 , step( ( ( _Float2 + temp_output_8_0 ) * _Float7 ) , temp_output_41_0 ));
				float4 lerpResult11 = lerp( _Color0 , lerpResult17 , step( ( temp_output_8_0 * _Float7 ) , temp_output_41_0 ));
				float2 uv_manuMask = i.ase_texcoord2.xy * _manuMask_ST.xy + _manuMask_ST.zw;
				float2 appendResult83 = (float2(texCoord80.x , texCoord80.y));
				float4 tex2DNode81 = tex2D( _manuMask, ( uv_manuMask - appendResult83 ) );
				#if defined(_SWITCHMASKP_A)
				float staticSwitch89 = tex2DNode81.a;
				#elif defined(_SWITCHMASKP_R)
				float staticSwitch89 = tex2DNode81.r;
				#else
				float staticSwitch89 = tex2DNode81.a;
				#endif
				float4 appendResult7 = (float4(lerpResult11.rgb , ( step( temp_output_44_0 , temp_output_41_0 ) * staticSwitch89 )));
				
				
				finalColor = ( appendResult7 * i.ase_color );
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
Node;AmplifyShaderEditor.CommentaryNode;99;-901.2678,73.30051;Inherit;False;935.67;422.4238;颜色控制;8;87;7;86;6;13;18;11;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;98;-2198.882,362.8238;Inherit;False;1285.73;375.0473;火焰溶解实现;15;16;10;46;14;45;47;15;8;9;44;5;75;77;76;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;96;-3234.685,356.8631;Inherit;False;973;385;第一套火焰细节;10;27;26;28;19;20;23;21;22;24;29;;1,0.2583481,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;95;-3262.32,779.8095;Inherit;False;1007;390;第二套火焰细节;10;33;34;32;30;35;31;36;38;37;39;;1,0.6771932,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;93;-3340.625,1212.215;Inherit;False;1208.9;462.7001;控制火焰偏移;11;62;80;52;53;50;51;56;58;57;55;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-2947.757,1702.71;Inherit;False;836.9529;276.8169;使用遮罩图控制火焰形状 (刀光);5;82;89;81;83;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-2983.729,2000.749;Inherit;False;871.8003;956.9817;利用程序遮罩控制火焰方向;12;66;74;73;72;70;69;63;67;71;68;64;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;65;-2586.976,2087.886;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;64;-2748.976,2088.886;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-2752.086,2314.629;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-2756.586,2744.129;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-2949.086,2268.629;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-2950.976,2042.887;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;69;-2753.086,2527.629;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-2952.086,2504.629;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-2955.586,2721.129;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;73;-2598.335,2744.357;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2582.729,2314.338;Inherit;False;Constant;_DefaultOFFMask;DefaultOFFMask;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;66;-2345.558,2083.629;Inherit;False;Property;_SwitchUP;火焰方向 (使用遮罩时关闭);16;0;Create;False;0;0;0;False;0;False;0;0;4;True;;KeywordEnum;5;Up;Down;Left;Right;OFF;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-2714.776,1814.418;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-2856.819,1868.147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;81;-2587.698,1785.881;Inherit;True;Property;_manuMask;刀光遮罩;18;1;[Header];Create;False;1;Mask;0;0;False;0;False;-1;None;1cfc5a1f78d9f60479d287985a3922cb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;89;-2298.34,1786.483;Inherit;False;Property;_switchmaskp;切换遮罩通道;19;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;A;R;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-2933.949,1746.735;Inherit;False;0;81;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;49;-3264.08,1258.234;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2965.635,1284.998;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-2968.702,1398.347;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;58;-2831.222,1285.416;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-2828.682,1392.604;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;50;-2619.267,1284.614;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2678.76,1512.358;Inherit;False;Property;_Float8;火焰范围;13;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-3312.814,1509.308;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-2392.392,1509.844;Inherit;False;Property;_Float10;火焰主体大小 (不溶解部分);12;0;Create;False;0;0;0;False;0;False;1;1.2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;39;-3253.02,861.8911;Inherit;False;Property;_TillSpeed02;细节2偏移与流动;10;0;Create;False;0;0;0;False;0;False;2,1,0,-0.7;1.32,2.01,-0.7,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;37;-3049.118,935.9908;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-3050.019,845.2908;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-2901.016,822.7894;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;31;-2876.739,957.8315;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;35;-2676.739,910.8311;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;30;-2417.787,908.7979;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;32;-2563.739,1027.837;Inherit;False;Property;_Float5;细节2缩放;9;0;Create;False;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2689.739,1028.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-3024.327,508.9916;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;24;-2679.947,483.8323;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2684.947,598.832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-2848.947,599.832;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2561.947,598.8324;Inherit;False;Property;_Float3;细节1缩放;6;0;Create;False;0;0;0;False;0;False;5.09;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;19;-2422.994,483.7989;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.DynamicAppendNode;28;-3025.227,419.2921;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-2899.224,396.7907;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;40;-2111.181,764.0725;Inherit;True;Overlay;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2171.326,512.0857;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;-1907.653,639.5118;Inherit;False;Property;_CustomeZ;CustomeZ控制溶解;17;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;75;-1713.229,560.2562;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1974.942,555.4883;Inherit;False;Property;_Float0;火焰溶解;11;1;[Header];Create;False;1;Dissolve;0;0;False;0;False;0;0.36;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1564.9,560.0438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1701.044,481.1504;Inherit;False;Property;_Float1;描边宽度;4;0;Create;False;0;0;0;False;0;False;0;0.481;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1435.304,485.6538;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1699.808,403.208;Inherit;False;Property;_Float2;外焰宽度;2;0;Create;False;0;0;0;False;0;False;0;0.236;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1314.172,511.8225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1307.437,412.0349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1171.692,413.2107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;10;-1163.631,511.7232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;16;-1032.312,414.5871;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;4;-1033.18,560.1241;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-635.7886,305.0262;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;11;-437.5346,123.7942;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-888.0302,143.686;Inherit;False;Property;_Color1;外焰颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-656.5083,118.7059;Inherit;False;Property;_Color0;描边颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;86;-431.2079,240.7836;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;-249.8147,190.1875;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-92.76116,217.5327;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;111.814,367.8737;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/个人制作/风格化火焰_程序纹理;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_OpenDepth;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TFHCRemapNode;52;-2395.338,1284.198;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2104.798,1575.957;Inherit;False;Constant;_DecreaseMask;DecreaseMask;16;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1907.028,1559.697;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-1331.09,762.4279;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1594.454,1118.09;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1844.02,962.337;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-869.9875,559.5509;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;50.51991,490.6537;Inherit;False;Property;_OpenDepth;开启深度 (模型穿插地面时启用);20;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;27;-3223.228,434.8923;Inherit;False;Property;_TillSpeed;细节1偏移与流动;7;0;Create;False;0;0;0;False;0;False;2,1,0,-1;1.04,2.3,-0.57,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-2853.947,665.832;Inherit;False;Property;_Float4;细节1流动强度 (建议默认);5;1;[Header];Create;False;1;Details;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2865.739,1045.835;Inherit;False;Property;_Float6;细节2流动强度 (建议默认);8;0;Create;False;0;0;0;False;0;False;0.6;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-863.8007,322.8125;Inherit;False;Property;_Color2;内焰颜色;0;2;[HDR];[Header];Create;False;1;FireColor;0;0;False;0;False;1,0.639221,0,1;1,0.4270763,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-1560.354,657.4013;Inherit;False;Property;_Float7;整体溶解倍增 (建议默认);15;0;Create;False;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;56;-3306.79,1386.475;Inherit;False;Property;_Vector1;火焰范围偏移 (CustomeXY);14;0;Create;False;0;0;0;False;0;False;0,0;-0.37,0.17;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;65;0;64;0
WireConnection;64;0;63;2
WireConnection;68;0;67;2
WireConnection;71;0;72;1
WireConnection;69;0;70;1
WireConnection;73;0;71;0
WireConnection;66;1;65;0
WireConnection;66;0;68;0
WireConnection;66;2;69;0
WireConnection;66;3;73;0
WireConnection;66;4;74;0
WireConnection;85;0;82;0
WireConnection;85;1;83;0
WireConnection;83;0;80;1
WireConnection;83;1;80;2
WireConnection;81;1;85;0
WireConnection;89;1;81;4
WireConnection;89;0;81;1
WireConnection;55;0;49;1
WireConnection;55;1;56;1
WireConnection;55;2;80;1
WireConnection;57;0;49;2
WireConnection;57;1;56;2
WireConnection;57;2;80;2
WireConnection;58;0;55;0
WireConnection;58;1;57;0
WireConnection;50;0;58;0
WireConnection;50;1;51;0
WireConnection;37;0;39;3
WireConnection;37;1;39;4
WireConnection;38;0;39;1
WireConnection;38;1;39;2
WireConnection;36;0;38;0
WireConnection;35;0;36;0
WireConnection;35;2;37;0
WireConnection;30;0;35;0
WireConnection;30;1;34;0
WireConnection;30;2;32;0
WireConnection;34;0;31;0
WireConnection;34;1;33;0
WireConnection;29;0;27;3
WireConnection;29;1;27;4
WireConnection;24;0;26;0
WireConnection;24;2;29;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;19;0;24;0
WireConnection;19;1;22;0
WireConnection;19;2;20;0
WireConnection;28;0;27;1
WireConnection;28;1;27;2
WireConnection;26;0;28;0
WireConnection;40;0;19;0
WireConnection;40;1;30;0
WireConnection;75;0;5;0
WireConnection;75;1;76;3
WireConnection;75;2;77;0
WireConnection;44;0;75;0
WireConnection;44;1;47;0
WireConnection;8;0;9;0
WireConnection;8;1;44;0
WireConnection;45;0;8;0
WireConnection;45;1;47;0
WireConnection;14;0;15;0
WireConnection;14;1;8;0
WireConnection;46;0;14;0
WireConnection;46;1;47;0
WireConnection;10;0;45;0
WireConnection;10;1;41;0
WireConnection;16;0;46;0
WireConnection;16;1;41;0
WireConnection;4;0;44;0
WireConnection;4;1;41;0
WireConnection;17;0;13;0
WireConnection;17;1;18;0
WireConnection;17;2;16;0
WireConnection;11;0;6;0
WireConnection;11;1;17;0
WireConnection;11;2;10;0
WireConnection;7;0;11;0
WireConnection;7;3;84;0
WireConnection;87;0;7;0
WireConnection;87;1;86;0
WireConnection;0;0;87;0
WireConnection;52;0;50;0
WireConnection;52;2;53;0
WireConnection;59;0;52;0
WireConnection;59;1;60;0
WireConnection;59;2;62;0
WireConnection;59;3;66;0
WireConnection;41;0;61;0
WireConnection;61;0;54;0
WireConnection;61;1;59;0
WireConnection;54;0;40;0
WireConnection;54;1;52;0
WireConnection;84;0;4;0
WireConnection;84;1;89;0
ASEEND*/
//CHKSM=69DFB7BF3CB4E6C819B2C91FF25F458BB85455CC