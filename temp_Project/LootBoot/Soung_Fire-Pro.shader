Shader "Soung/Effect/ToonFirePro"
{
	Properties
	{

		[HDR][Header(FireColor)] _Color2( "内焰颜色", Color ) = ( 1, 0.639221, 0, 1 )
		[HDR] _Color1( "外焰颜色", Color ) = ( 1, 0, 0, 1 )
		_Float2( "外焰宽度", Range( 0, 1 ) ) = 0
		[HDR] _Color0( "描边颜色", Color ) = ( 0, 0, 0, 1 )
		_Float1( "描边宽度", Range( 0, 1 ) ) = 0
		[Header(Details)] _Float4( "细节1流动强度 (建议默认)", Float ) = 2
		_Float3( "细节1缩放", Float ) = 5.09
		_TillSpeed( "细节1偏移与流动", Vector ) = ( 2, 1, 0, -1 )
		_Float6( "细节2流动强度 (建议默认)", Float ) = 0.6
		_Float5( "细节2缩放", Float ) = 3
		_TillSpeed02( "细节2偏移与流动", Vector ) = ( 2, 1, 0, -0.7 )
		[Header(Dissolve)] _Float0( "火焰溶解", Range( 0, 2 ) ) = 0
		[KeywordEnum( Up,Down,Left,Right,OFF )] _SwitchUP( "火焰方向 (使用遮罩时关闭)", Float ) = 0
		_Float10( "火焰主体大小 (不溶解部分)", Range( 0, 10 ) ) = 1
		_Float8( "火焰范围", Range( 0, 1 ) ) = 1
		_Vector1( "火焰范围偏移 (CustomeXY)", Vector ) = ( 0, 0, 0, 0 )
		_Float7( "整体溶解倍增 (建议默认)", Range( 0, 1 ) ) = 0.1
		[Toggle] _CustomeZ( "CustomeZ控制溶解", Float ) = 0
		[Header(Mask)] _manuMask( "刀光遮罩", 2D ) = "white" {}
		[KeywordEnum( A,R )] _switchmaskp( "切换遮罩通道", Float ) = 0
		[Enum(Default,0,Flipbook,1)] _MaskTexUVMode( "遮罩贴图UV模式", Float ) = 0
		_FlipbookSets( "遮罩序列X/Y/速度/首帧", Vector ) = ( 2, 2, 2, 0 )
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Off
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		ENDHLSL

		
		Pass
		{
			
			Name "Universal2D"
			

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA

			

			HLSLPROGRAM
            #define _SURFACE_TYPE_TRANSPARENT 1
            #pragma multi_compile_instancing
            #pragma multi_compile_local _RECEIVE_SHADOWS_OFF

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#pragma shader_feature_local _SWITCHUP_UP _SWITCHUP_DOWN _SWITCHUP_LEFT _SWITCHUP_RIGHT _SWITCHUP_OFF
			#pragma shader_feature_local _SWITCHMASKP_A _SWITCHMASKP_R

			struct Attributes
			{
				float4 positionOS : POSITION;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord2 : TEXCOORD0;
				float4 ase_texcoord3 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color0;
			float4 _Color1;
			float4 _Color2;
			float4 _manuMask_ST;
			float4 _TillSpeed02;
			float4 _FlipbookSets;
			float4 _TillSpeed;
			float2 _Vector1;
			float _Float10;
			float _Float8;
			float _Float6;
			float _Float4;
			float _Float3;
			float _Float7;
			float _CustomeZ;
			float _Float0;
			float _Float1;
			float _Float2;
			float _Float5;
			float _MaskTexUVMode;
			CBUFFER_END

			sampler2D _manuMask;


float2 voronoihash( float2 p )
				{
					
					p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
					return frac( sin( p ) *43758.5453);
				}
			
					float voronoi( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
				{
					float2 n = floor( v );
					float2 f = frac( v );
					float F1 = 8.0;
					float F2 = 8.0; float2 mg = 0; int i, j;
					for ( j = -1; j <= 1; j++ )
					{
						for ( i = -1; i <= 1; i++ )
					 	{
					 		float2 g = float2( i, j );
					 		float2 o = voronoihash( n + g );
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
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3.xy = input.ase_texcoord.xy;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				output.positionCS = vertexInput.positionCS;
				return output;
			}

			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}

			half4 frag ( PackedVaryings input ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODDitheringTransition( input.positionCS.xyz, unity_LODFade.x );
				#endif

				float4 texCoord76 = input.ase_texcoord2;
				texCoord76.xy = input.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult75 = lerp( _Float0 , texCoord76.z , _CustomeZ);
				float temp_output_44_0 = ( lerpResult75 * _Float7 );
				float temp_output_8_0 = ( _Float1 + temp_output_44_0 );
				float time19 = ( _TimeParameters.x * _Float4 );
				float2 voronoiSmoothId19 = 0;
				float2 appendResult29 = (float2(_TillSpeed.z , _TillSpeed.w));
				float2 appendResult28 = (float2(_TillSpeed.x , _TillSpeed.y));
				float2 texCoord26 = input.ase_texcoord3.xy * appendResult28 + float2( 0,0 );
				float2 panner24 = ( 1.0 * _Time.y * appendResult29 + texCoord26);
				float2 coords19 = panner24 * _Float3;
				float2 id19 = 0;
				float2 uv19 = 0;
				float voroi19 = voronoi( coords19, time19, id19, uv19, 0, voronoiSmoothId19 );
				float time30 = ( _TimeParameters.x * _Float6 );
				float2 voronoiSmoothId30 = 0;
				float2 appendResult37 = (float2(_TillSpeed02.z , _TillSpeed02.w));
				float2 appendResult38 = (float2(_TillSpeed02.x , _TillSpeed02.y));
				float2 texCoord36 = input.ase_texcoord3.xy * appendResult38 + float2( 0,0 );
				float2 panner35 = ( 1.0 * _Time.y * appendResult37 + texCoord36);
				float2 coords30 = panner35 * _Float5;
				float2 id30 = 0;
				float2 uv30 = 0;
				float voroi30 = voronoi( coords30, time30, id30, uv30, 0, voronoiSmoothId30 );
				float blendOpSrc40 = voroi19;
				float blendOpDest40 = voroi30;
				float2 _Vector0 = float2(0.5,0.5);
				float4 texCoord80 = input.ase_texcoord2;
				texCoord80.xy = input.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult58 = (float2(( _Vector0.x + _Vector1.x + texCoord80.x ) , ( _Vector0.y + _Vector1.y + texCoord80.y )));
				float2 texCoord51 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_52_0 =  (1.0 + ( distance( appendResult58 , texCoord51 ) - 0.0 ) * ( 0.0 - 1.0 ) / ( _Float8 - 0.0 ) );
				float2 texCoord63 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord67 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord70 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord72 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined( _SWITCHUP_UP )
				float staticSwitch66 = ( 1.0 - saturate( texCoord63.y ) );
				#elif defined( _SWITCHUP_DOWN )
				float staticSwitch66 = saturate( texCoord67.y );
				#elif defined( _SWITCHUP_LEFT )
				float staticSwitch66 = saturate( texCoord70.x );
				#elif defined( _SWITCHUP_RIGHT )
				float staticSwitch66 = ( 1.0 - saturate( texCoord72.x ) );
				#elif defined( _SWITCHUP_OFF )
				float staticSwitch66 = 1.0;
				#else
				float staticSwitch66 = ( 1.0 - saturate( texCoord63.y ) );
				#endif
				float temp_output_41_0 = saturate( ( ( ( saturate( (( blendOpDest40 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest40 ) * ( 1.0 - blendOpSrc40 ) ) : ( 2.0 * blendOpDest40 * blendOpSrc40 ) ) )) * temp_output_52_0 ) + ( temp_output_52_0 * 0.1 * _Float10 * staticSwitch66 ) ) );
				float4 lerpResult17 = lerp( _Color1 , _Color2 , step( ( ( _Float2 + temp_output_8_0 ) * _Float7 ) , temp_output_41_0 ));
				float4 lerpResult11 = lerp( _Color0 , lerpResult17 , step( ( temp_output_8_0 * _Float7 ) , temp_output_41_0 ));
				
				float2 uv_manuMask = input.ase_texcoord3.xy * _manuMask_ST.xy + _manuMask_ST.zw;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles112 = _FlipbookSets.x * _FlipbookSets.y;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset112 = 1.0f / _FlipbookSets.x;
				float fbrowsoffset112 = 1.0f / _FlipbookSets.y;
				// Speed of animation
				float fbspeed112 = _Time[ 1 ] * _FlipbookSets.z;
				// UV Tiling (col and row offset)
				float2 fbtiling112 = float2(fbcolsoffset112, fbrowsoffset112);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex112 = floor( fmod( fbspeed112 + _FlipbookSets.w, fbtotaltiles112) );
				fbcurrenttileindex112 += ( fbcurrenttileindex112 < 0) ? fbtotaltiles112 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox112 = round ( fmod ( fbcurrenttileindex112, _FlipbookSets.x ) );
				// Multiply Offset X by coloffset
				float fboffsetx112 = fblinearindextox112 * fbcolsoffset112;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy112 = round( fmod( ( fbcurrenttileindex112 - fblinearindextox112 ) / _FlipbookSets.x, _FlipbookSets.y ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy112 = (int)(_FlipbookSets.y-1) - fblinearindextoy112;
				// Multiply Offset Y by rowoffset
				float fboffsety112 = fblinearindextoy112 * fbrowsoffset112;
				// UV Offset
				float2 fboffset112 = float2(fboffsetx112, fboffsety112);
				// Flipbook UV
				float2 fbuv112 = uv_manuMask * fbtiling112 + fboffset112;
				// *** END Flipbook UV Animation vars ***
				float2 lerpResult113 = lerp( uv_manuMask , fbuv112 , _MaskTexUVMode);
				float4 tex2DNode81 = tex2D( _manuMask, lerpResult113 );
				#if defined( _SWITCHMASKP_A )
				float staticSwitch89 = tex2DNode81.a;
				#elif defined( _SWITCHMASKP_R )
				float staticSwitch89 = tex2DNode81.r;
				#else
				float staticSwitch89 = tex2DNode81.a;
				#endif
				
				float3 Color = ( lerpResult11 * input.ase_color ).rgb;
				float Alpha = ( input.ase_color.a * ( step( temp_output_44_0 , temp_output_41_0 ) * staticSwitch89 ) );

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}