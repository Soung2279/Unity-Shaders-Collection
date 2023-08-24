//警告！！！该shader完全未经过性能优化，请勿引入到项目中
//主要目的是方便动画师或者特效师制作个人demo，请勿用于任何商业用途
//个人知乎账号ID:shuang-miao-80 后续可能会有更新
//https://zhuanlan.zhihu.com/p/421146056
//技术谈论Q群:897384540
//最后,玩的开心!!!
Shader "A201-Shader/特殊制作/BA式卡通着色器_PPX_BA"
{
	Properties
	{
		_WebSite("此Shader教程网址:www.bilibili.com/video/BV1T94y1y7Um/", Int) = 2023
		[Header(__________________________________________________________________________________________)]
		_ASEOutlineWidth( "描边宽度", Float ) = 0
		_Cutoff( "遮罩剪裁值", Float ) = 0.5
		_ASEOutlineColor( "描边颜色", Color ) = (0,0,0,0)
		_shadow_clip("阴影裁剪值", Range( 0 , 1)) = 0.64
		_shadow_edge("过渡阴影范围", Range( 0 , 1)) = 0
		_BaseTex("主贴图", 2D) = "white" {}
		_Base_color("基础色", Color) = (1,1,1,0)
		_light("亮部颜色", Color) = (1,1,1,0)
		_drak("暗部颜色", Color) = (0,0,0,0)
		[Toggle(_IF_WITH_MOUTH_ON)] _IF_with_mouth("启用嘴型", Float) = 0
		[NoScaleOffset]_Mouth("嘴型图(8x8)", 2D) = "white" {}
		[IntRange]_U("U", Range( 1 , 8)) = 0
		[IntRange]_V("V", Range( 1 , 8)) = 1.175121
		_Mouth_mask("嘴型遮罩", 2D) = "black" {}
		[HDR]_frensel_color("菲涅尔颜色", Color) = (0.3166077,1,0,0)
		_frensel_power("菲涅尔强度", Range( 0 , 3)) = 0.3368064
		_frensel_range("菲涅尔范围", Range( 0 , 1)) = 0.5524385
		_frensel_hard("菲涅尔过渡值", Range( 0 , 1)) = 1
		[Enum(off,0,on,1)]_Zwrite("写入深度(ZWrite)", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式", Float) = 0
		[IntRange][Enum(UnityEngine.Rendering.CompareFunction)]_Ztest("深度测试(Ztest)", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _IF_WITH_MOUTH_ON
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
		};

		uniform float _Zwrite;
		uniform float _Cull;
		uniform float _Ztest;
		uniform sampler2D _BaseTex;
		uniform float4 _BaseTex_ST;
		uniform sampler2D _Mouth;
		uniform float _U;
		uniform float _V;
		uniform sampler2D _Mouth_mask;
		uniform float4 _Mouth_mask_ST;
		uniform float4 _drak;
		uniform float4 _light;
		uniform float _shadow_clip;
		uniform float _shadow_edge;
		uniform float4 _Base_color;
		uniform float4 _frensel_color;
		uniform float _frensel_power;
		uniform float _frensel_range;
		uniform float _frensel_hard;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_BaseTex = i.uv_texcoord * _BaseTex_ST.xy + _BaseTex_ST.zw;
			float2 appendResult34 = (float2(( ceil( ( _U - 1.0 ) ) * 0.125 ) , ( ceil( ( _V - 9.0 ) ) * 0.125 )));
			float4 tex2DNode36 = tex2D( _Mouth, ( ( i.uv_texcoord * 0.5 ) + appendResult34 ) );
			float2 uv_Mouth_mask = i.uv_texcoord * _Mouth_mask_ST.xy + _Mouth_mask_ST.zw;
			#ifdef _IF_WITH_MOUTH_ON
				float staticSwitch75 = tex2D( _Mouth_mask, uv_Mouth_mask ).r;
			#else
				float staticSwitch75 = 0.0;
			#endif
			float temp_output_37_0 = ( staticSwitch75 * tex2DNode36.a );
			float4 lerpResult39 = lerp( tex2D( _BaseTex, uv_BaseTex ) , tex2DNode36 , temp_output_37_0);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult6 = dot( ase_worldlightDir , ase_worldNormal );
			float smoothstepResult14 = smoothstep( _shadow_clip , ( _shadow_clip + _shadow_edge ) , ( ( dotResult6 + 1.0 ) * 0.5 ));
			float4 lerpResult17 = lerp( _drak , _light , smoothstepResult14);
			float3 base_part21 = (( lerpResult39 * lerpResult17 * _Base_color )).rgb;
			float dotResult51 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult55 = smoothstep( _frensel_range , ( _frensel_range + _frensel_hard ) , ( 1.0 - dotResult51 ));
			float3 frensel61 = (( _frensel_color * _frensel_power * saturate( smoothstepResult55 ) )).rgb;
			float alpha43 = saturate( ( ( 1.0 - staticSwitch75 ) + temp_output_37_0 ) );
			float4 appendResult24 = (float4((( base_part21 + frensel61 )).xyz , alpha43));
			o.Emission = appendResult24.xyz;
			o.Alpha = 1;
			float temp_output_46_0 = alpha43;
			clip( temp_output_46_0 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
