// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/全面功能/基础PBR渲染_SinC"
{
	Properties
	{
		[Header(AOMetallicGloss)]
		_MainAO("环境光AO值", Float) = 0
		_MainGloss("光泽度", Float) = 1
		_MainMetallic("金属度", Float) = 1
		_SubAO("次表面AO值", Float) = 0
		_SubGloss("次表面光泽度", Float) = 1
		_SubMetallic("次表面金属度", Float) = 1
		[Header(Diffuse)]
		_MainDiffuse("漫反射贴图", 2D) = "white" {}
		[HDR]_Color("基础色", Color) = (1,1,1,1)
		_MainDiffuseU("漫反射贴图U方向速率", Float) = 0
		_MainDiffuseV("漫反射贴图V方向速率", Float) = 0
		_DiffuseIndensity("漫反射强度", Float) = 1
		_SubDiffuse("次表面漫反射贴图", 2D) = "white" {}
		[HDR]_SubColor("次表面颜色", Color) = (1,1,1,1)
		_SubDiffuseU("次表面漫反射贴图U方向速率", Float) = 0
		_SubDiffuseV("次表面漫反射贴图V方向速率", Float) = 0
		_SubDiffuseIndensity("次表面漫反射强度", Float) = 1
		[Header(Normal)]
		[Normal]_MainNormal("法线贴图", 2D) = "bump" {}
		_MainNormalU("法线贴图U方向速率", Float) = 0
		_MainNormalV("法线贴图V方向速率", Float) = 0
		_MainNormalScale("法线贴图缩放比例", Float) = 1
		[Normal]_SubNormal("次表面法线贴图", 2D) = "bump" {}
		_SubNormalU("次表面法线贴图U方向速率", Float) = 0
		_SubNormalV("次表面法线贴图V方向速率", Float) = 0
		_SubNormalScale("次表面法线贴图缩放比例", Float) = 1
		[Header(Specular)]
		_MainSecTex("镜面贴图", 2D) = "white" {}
		_MainSecTexU("镜面贴图U方向速率", Float) = 0
		_MainSecTexV("镜面贴图V方向速率", Float) = 0
		_SubSecTex("次表面镜面贴图", 2D) = "white" {}
		_SubSecTexU("次表面镜面贴图U方向速率", Float) = 0
		_SubSecTexV("次表面镜面贴图V方向速率", Float) = 0
		[Header(Alpha)]
		_Alpha("Alpha贴图", 2D) = "white" {}
		_AlphaU("Alpha贴图U方向速率", Float) = 0
		_AlphaV("Alpha贴图V方向速率", Float) = 0
		_AddAlpha("叠加Alpha贴图", 2D) = "white" {}
		_AddAlphaU("叠加Alpha贴图U方向速率", Float) = 0
		_AddAlphaV("叠加Alpha贴图V方向速率", Float) = 0
		[Toggle]_AlphaDistortionTexInfluenceAddAlpha("主Alpha扭曲是否影响叠加Aplha", Float) = 0
		_DetailAlpha("细节Alpha贴图", 2D) = "white" {}
		_DetailAlphaU("细节Alpha贴图U方向速率", Float) = 0
		_DetailAlphaV("细节Alpha贴图V方向速率", Float) = 0
		[Toggle]_AlphaDistortionTexInfluenceDetailAlpha("主Alpha扭曲是否影响细节Aplha", Float) = 0
		_AlphaBias("Alpha偏差", Float) = 0
		[Header(AlphaDistortion)]
		_AlphaDistortionTex("Alpha扭曲贴图", 2D) = "white" {}
		[Toggle]_AlphaDistortion2UV("使用Alpha扭曲贴图UV2", Float) = 0
		_DistortionIndensity("扭曲强度", Float) = 0
		_AlphaDistortionU("Alpha扭曲贴图U方向速率", Float) = 0
		_AlphaDistortionV("Alpha扭曲贴图V方向速率", Float) = 0
		_AlphaDistortionMask("Alpha扭曲遮罩贴图", 2D) = "white" {}
		[Toggle]_AlphaDistortionMask2UV("使用Alpha扭曲遮罩贴图UV2", Float) = 0
		_AlphaDistortionMaskU("Alpha扭曲遮罩贴图U方向速率", Float) = 0
		_AlphaDistortionMaskV("Alpha扭曲遮罩贴图V方向速率", Float) = 0
		[Header(Emission)]
		_SubEmission("自发光贴图", 2D) = "white" {}
		[HDR]_SubEmissionColor("自发光颜色", Color) = (1,1,1,1)
		_SubEmissionIndensity("自发光强度", Float) = 1
		_SubEmissionU("自发光贴图U方向速率", Float) = 0
		_SubEmissionV("自发光贴图V方向速率", Float) = 0
		[Header(CubeMap)]
		_MainCubemap("主CubeMap图", CUBE) = "white" {}
		_MainCubemapIndensity("主CubeMap光照系数", Float) = 1
		_SubCubemap("次表面CubeMap图", CUBE) = "white" {}
		_SubCubemapIndensity("次表面CubeMap光照系数", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float3 worldRefl;
			INTERNAL_DATA
		};

		uniform float _MainNormalScale;
		uniform sampler2D _MainNormal;
		uniform float4 _MainNormal_ST;
		uniform float _MainNormalU;
		uniform float _MainNormalV;
		uniform float _SubNormalScale;
		uniform sampler2D _SubNormal;
		uniform float4 _SubNormal_ST;
		uniform float _SubNormalU;
		uniform float _SubNormalV;
		uniform sampler2D _Alpha;
		uniform float4 _Alpha_ST;
		uniform float _AlphaU;
		uniform float _AlphaV;
		uniform sampler2D _AlphaDistortionMask;
		uniform half _AlphaDistortionMask2UV;
		uniform float4 _AlphaDistortionMask_ST;
		uniform float _AlphaDistortionMaskU;
		uniform float _AlphaDistortionMaskV;
		uniform sampler2D _AlphaDistortionTex;
		uniform half _AlphaDistortion2UV;
		uniform float4 _AlphaDistortionTex_ST;
		uniform float _AlphaDistortionU;
		uniform float _AlphaDistortionV;
		uniform float _DistortionIndensity;
		uniform sampler2D _AddAlpha;
		uniform half _AlphaDistortionTexInfluenceAddAlpha;
		uniform float4 _AddAlpha_ST;
		uniform float _AddAlphaU;
		uniform float _AddAlphaV;
		uniform sampler2D _DetailAlpha;
		uniform half _AlphaDistortionTexInfluenceDetailAlpha;
		uniform float4 _DetailAlpha_ST;
		uniform float _DetailAlphaU;
		uniform float _DetailAlphaV;
		uniform float _AlphaBias;
		uniform float _SubDiffuseIndensity;
		uniform half _SubCubemapIndensity;
		uniform samplerCUBE _SubCubemap;
		uniform sampler2D _SubDiffuse;
		uniform float4 _SubDiffuse_ST;
		uniform float _SubDiffuseU;
		uniform float _SubDiffuseV;
		uniform float4 _SubColor;
		uniform float _DiffuseIndensity;
		uniform half _MainCubemapIndensity;
		uniform samplerCUBE _MainCubemap;
		uniform sampler2D _MainDiffuse;
		uniform float4 _MainDiffuse_ST;
		uniform float _MainDiffuseU;
		uniform float _MainDiffuseV;
		uniform float4 _Color;
		uniform float4 _SubEmissionColor;
		uniform sampler2D _SubEmission;
		uniform float4 _SubEmission_ST;
		uniform float _SubEmissionU;
		uniform float _SubEmissionV;
		uniform float _SubEmissionIndensity;
		uniform sampler2D _MainSecTex;
		uniform float4 _MainSecTex_ST;
		uniform float _MainSecTexU;
		uniform float _MainSecTexV;
		uniform float _MainMetallic;
		uniform sampler2D _SubSecTex;
		uniform float4 _SubSecTex_ST;
		uniform float _SubSecTexU;
		uniform float _SubSecTexV;
		uniform float _SubMetallic;
		uniform float _MainGloss;
		uniform float _SubGloss;
		uniform float _MainAO;
		uniform float _SubAO;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv0_MainNormal = i.uv_texcoord * _MainNormal_ST.xy + _MainNormal_ST.zw;
			float2 appendResult30 = (float2(( _MainNormalU * _Time.y ) , ( _Time.y * _MainNormalV )));
			float3 tex2DNode14 = UnpackScaleNormal( tex2D( _MainNormal, ( uv0_MainNormal + appendResult30 ) ), _MainNormalScale );
			float2 uv0_SubNormal = i.uv_texcoord * _SubNormal_ST.xy + _SubNormal_ST.zw;
			float2 appendResult164 = (float2(( _SubNormalU * _Time.y ) , ( _Time.y * _SubNormalV )));
			float3 tex2DNode167 = UnpackScaleNormal( tex2D( _SubNormal, ( uv0_SubNormal + appendResult164 ) ), _SubNormalScale );
			float2 uv0_Alpha = i.uv_texcoord * _Alpha_ST.xy + _Alpha_ST.zw;
			float2 appendResult88 = (float2(( _AlphaU * _Time.y ) , ( _Time.y * _AlphaV )));
			float2 uv0_AlphaDistortionMask = i.uv_texcoord * _AlphaDistortionMask_ST.xy + _AlphaDistortionMask_ST.zw;
			float2 uv1_AlphaDistortionMask = i.uv2_texcoord2 * _AlphaDistortionMask_ST.xy + _AlphaDistortionMask_ST.zw;
			float2 appendResult175 = (float2(_AlphaDistortionMaskU , _AlphaDistortionMaskV));
			float3 desaturateInitialColor183 = tex2D( _AlphaDistortionMask, ( (( _AlphaDistortionMask2UV )?( uv1_AlphaDistortionMask ):( uv0_AlphaDistortionMask )) + ( appendResult175 * _Time.y ) ) ).rgb;
			float desaturateDot183 = dot( desaturateInitialColor183, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar183 = lerp( desaturateInitialColor183, desaturateDot183.xxx, 1.0 );
			float2 uv0_AlphaDistortionTex = i.uv_texcoord * _AlphaDistortionTex_ST.xy + _AlphaDistortionTex_ST.zw;
			float2 uv1_AlphaDistortionTex = i.uv2_texcoord2 * _AlphaDistortionTex_ST.xy + _AlphaDistortionTex_ST.zw;
			float2 appendResult126 = (float2(_AlphaDistortionU , _AlphaDistortionV));
			float3 desaturateInitialColor133 = tex2D( _AlphaDistortionTex, ( (( _AlphaDistortion2UV )?( uv1_AlphaDistortionTex ):( uv0_AlphaDistortionTex )) + ( appendResult126 * _Time.y ) ) ).rgb;
			float desaturateDot133 = dot( desaturateInitialColor133, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar133 = lerp( desaturateInitialColor133, desaturateDot133.xxx, 1.0 );
			float3 temp_output_185_0 = ( desaturateVar183 * desaturateVar133 );
			float3 lerpResult143 = lerp( float3( ( uv0_Alpha + appendResult88 ) ,  0.0 ) , temp_output_185_0 , _DistortionIndensity);
			float2 uv0_AddAlpha = i.uv_texcoord * _AddAlpha_ST.xy + _AddAlpha_ST.zw;
			float2 appendResult192 = (float2(( _AddAlphaU * _Time.y ) , ( _Time.y * _AddAlphaV )));
			float2 temp_output_193_0 = ( uv0_AddAlpha + appendResult192 );
			float3 lerpResult200 = lerp( float3( temp_output_193_0 ,  0.0 ) , temp_output_185_0 , _DistortionIndensity);
			float2 uv0_DetailAlpha = i.uv_texcoord * _DetailAlpha_ST.xy + _DetailAlpha_ST.zw;
			float2 appendResult210 = (float2(( _DetailAlphaU * _Time.y ) , ( _Time.y * _DetailAlphaV )));
			float2 temp_output_211_0 = ( uv0_DetailAlpha + appendResult210 );
			float3 lerpResult213 = lerp( float3( temp_output_211_0 ,  0.0 ) , temp_output_185_0 , _DistortionIndensity);
			float4 clampResult199 = clamp( ( tex2D( _Alpha, lerpResult143.xy ) + ( tex2D( _AddAlpha, (( _AlphaDistortionTexInfluenceAddAlpha )?( lerpResult200 ):( half3( temp_output_193_0 ,  0.0 ) )).xy ) * ( tex2D( _DetailAlpha, (( _AlphaDistortionTexInfluenceDetailAlpha )?( lerpResult213 ):( half3( temp_output_211_0 ,  0.0 ) )).xy ) + _AlphaBias ) ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
			float3 desaturateInitialColor46 = clampResult199.rgb;
			float desaturateDot46 = dot( desaturateInitialColor46, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar46 = lerp( desaturateInitialColor46, desaturateDot46.xxx, 1.0 );
			float temp_output_47_0 = (desaturateVar46).x;
			float3 lerpResult168 = lerp( tex2DNode14 , tex2DNode167 , ( 1.0 - temp_output_47_0 ));
			o.Normal = lerpResult168;
			half3 SubNormal224 = tex2DNode167;
			float2 uv0_SubDiffuse = i.uv_texcoord * _SubDiffuse_ST.xy + _SubDiffuse_ST.zw;
			float2 appendResult57 = (float2(( _SubDiffuseU * _Time.y ) , ( _Time.y * _SubDiffuseV )));
			half3 MainNormal223 = tex2DNode14;
			float2 uv0_MainDiffuse = i.uv_texcoord * _MainDiffuse_ST.xy + _MainDiffuse_ST.zw;
			float2 appendResult20 = (float2(( _MainDiffuseU * _Time.y ) , ( _Time.y * _MainDiffuseV )));
			o.Albedo = ( ( ( _SubDiffuseIndensity * ( ( _SubCubemapIndensity * texCUBE( _SubCubemap, WorldReflectionVector( i , SubNormal224 ) ) ) + ( tex2D( _SubDiffuse, ( uv0_SubDiffuse + appendResult57 ) ) * _SubColor * _SubColor.a ) ) ) * ( 1.0 - temp_output_47_0 ) ) + ( temp_output_47_0 * ( _DiffuseIndensity * ( ( _MainCubemapIndensity * texCUBE( _MainCubemap, WorldReflectionVector( i , MainNormal223 ) ) ) + ( tex2D( _MainDiffuse, ( uv0_MainDiffuse + appendResult20 ) ) * _Color * _Color.a ) ) ) ) ).rgb;
			float2 uv0_SubEmission = i.uv_texcoord * _SubEmission_ST.xy + _SubEmission_ST.zw;
			float2 appendResult150 = (float2(( _SubEmissionU * _Time.y ) , ( _Time.y * _SubEmissionV )));
			float temp_output_97_0 = ( 1.0 - temp_output_47_0 );
			o.Emission = ( ( _SubEmissionColor * tex2D( _SubEmission, ( uv0_SubEmission + appendResult150 ) ) * _SubEmissionIndensity ) * temp_output_97_0 ).rgb;
			float2 uv0_MainSecTex = i.uv_texcoord * _MainSecTex_ST.xy + _MainSecTex_ST.zw;
			float2 appendResult40 = (float2(( _MainSecTexU * _Time.y ) , ( _Time.y * _MainSecTexV )));
			float4 tex2DNode4 = tex2D( _MainSecTex, ( uv0_MainSecTex + appendResult40 ) );
			float2 uv0_SubSecTex = i.uv_texcoord * _SubSecTex_ST.xy + _SubSecTex_ST.zw;
			float2 appendResult70 = (float2(( _SubSecTexU * _Time.y ) , ( _Time.y * _SubSecTexV )));
			float4 tex2DNode68 = tex2D( _SubSecTex, ( uv0_SubSecTex + appendResult70 ) );
			o.Metallic = ( ( temp_output_47_0 * ( tex2DNode4.b * _MainMetallic ) ) + ( ( 1.0 - temp_output_47_0 ) * ( tex2DNode68.b * _SubMetallic ) ) );
			o.Smoothness = ( ( temp_output_47_0 * ( tex2DNode4.g * _MainGloss ) ) + ( ( 1.0 - temp_output_47_0 ) * ( tex2DNode68.g * _SubGloss ) ) );
			o.Occlusion = ( ( temp_output_47_0 * ( tex2DNode4.r * _MainAO ) ) + ( temp_output_97_0 * ( tex2DNode68.r * _SubAO ) ) );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
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
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
/*ASEBEGIN
Version=17800
0;0;1920;1029;10888.49;4162.024;5.846449;True;False
Node;AmplifyShaderEditor.CommentaryNode;120;-7592.749,-533.8282;Inherit;False;1207;533.7722;UV扭曲贴图;11;133;132;131;129;128;127;126;125;124;123;238;Alpha的UV扭曲贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;172;-7595.835,-1106.866;Inherit;False;1207;533.7722;UV扭曲贴图;11;183;182;181;179;178;177;176;175;174;173;237;Alpha的UV扭曲贴图的遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-7555.757,-816.8928;Float;False;Property;_AlphaDistortionMaskU;AlphaDistortionMaskU;44;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-7555.757,-736.8926;Float;False;Property;_AlphaDistortionMaskV;AlphaDistortionMaskV;45;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-7552.671,-163.8558;Float;False;Property;_AlphaDistortionV;AlphaDistortionV;41;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-7552.671,-243.8559;Float;False;Property;_AlphaDistortionU;AlphaDistortionU;40;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;178;-7448.854,-648.6238;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;176;-7545.835,-944.8661;Inherit;False;0;182;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-7542.749,-371.8282;Inherit;False;0;132;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;126;-7347.155,-233.4778;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;177;-7545.835,-1056.868;Inherit;False;1;182;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;175;-7350.241,-806.5148;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;127;-7542.749,-483.8293;Inherit;False;1;132;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;128;-7445.769,-75.58658;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;203;-6995.784,454.0823;Inherit;False;646.5266;428.8364;Comment;8;211;210;209;208;207;206;205;204;Alpha黑白值额外补齐贴图的遮罩图的原UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;238;-7229.832,-456.8368;Half;False;Property;_AlphaDistortion2UV;AlphaDistortion2UV;38;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-7187.156,-232.0723;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-7190.242,-805.1098;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;237;-7238.68,-959.4881;Half;False;Property;_AlphaDistortionMask2UV;AlphaDistortionMask2UV;43;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-6926.808,767.9167;Float;False;Property;_DetailAlphaV;DetailAlphaV;34;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-6929.808,615.918;Float;False;Property;_DetailAlphaU;DetailAlphaU;33;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;195;-7013.991,5.910579;Inherit;False;646.5266;428.8364;Comment;8;194;193;192;191;190;189;188;187;Alpha黑白值额外补齐贴图的原UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-7033.75,-277.8284;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;246;-4470.045,483.2512;Inherit;False;1234.934;478.8363;Comment;3;157;166;167;副法线;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;245;-4479.751,-8.756607;Inherit;False;1234.935;478.8363;Comment;3;24;33;14;主法线;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-7036.836,-850.8661;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;204;-6945.784,687.5099;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-6948.015,167.7467;Float;False;Property;_AddAlphaU;AddAlphaU;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;182;-6884.834,-889.8661;Inherit;True;Property;_AlphaDistortionMask;AlphaDistortionMask;42;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;157;-4420.045,533.2512;Inherit;False;646.5266;428.8364;Comment;8;165;164;163;162;161;160;159;158;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-4429.751,41.24339;Inherit;False;646.5266;428.8364;Comment;8;32;31;30;29;28;27;26;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-6945.015,319.7466;Float;False;Property;_AddAlphaV;AddAlphaV;30;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;189;-6963.99,239.3388;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-6765.805,618.918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;132;-6881.748,-316.8285;Inherit;True;Property;_AlphaDistortionTex;AlphaDistortionTex;37;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-6764.805,716.9169;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;183;-6596.835,-882.8661;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-4363.775,203.0796;Float;False;Property;_MainNormalU;MainNormalU;13;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-4354.068,695.0872;Float;False;Property;_SubNormalU;SubNormalU;17;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;133;-6593.748,-309.8284;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;82;-7029.434,-1568.058;Inherit;False;646.5266;428.8364;Comment;8;90;89;88;87;86;85;84;83;Alpha原UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;162;-4370.046,766.6798;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-6783.017,268.7467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-6784.017,170.7468;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-4360.775,355.0797;Float;False;Property;_MainNormalV;MainNormalV;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;29;-4379.752,274.6721;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;209;-6733.19,488.8962;Inherit;False;0;202;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;210;-6638.338,619.2341;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-4351.068,847.0875;Float;False;Property;_SubNormalV;SubNormalV;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;194;-6751.403,40.72508;Inherit;False;0;196;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-4199.774,206.0796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-6314.591,-721.3282;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;83;-6979.434,-1334.63;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-6960.457,-1254.222;Float;False;Property;_AlphaV;AlphaV;27;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-4189.067,796.0874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-6299.187,-504.5599;Float;False;Property;_DistortionIndensity;DistortionIndensity;39;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;211;-6503.252,508.3671;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-6963.457,-1406.222;Float;False;Property;_AlphaU;AlphaU;26;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;192;-6656.554,171.0632;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-4198.774,304.0798;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-4190.067,698.0872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;248;-5020.447,-2586.035;Inherit;False;1583.154;856.967;Comment;8;51;229;60;63;228;61;62;64;副图+副颜色+副强度+副cubemap叠加;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-4159.78,82.27299;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-6799.458,-1403.222;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;213;-6137.731,294.3506;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-6798.458,-1305.222;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-6521.473,60.19633;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;247;-5153.159,-1573.094;Inherit;False;1768.171;843.0817;Comment;8;23;230;3;5;6;236;10;2;主图+主颜色+主强度+主cubemap叠加;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;164;-4062.607,698.4037;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-4150.074,574.2808;Inherit;False;0;167;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;30;-4072.313,206.396;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;-6766.846,-1533.243;Inherit;False;0;45;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;88;-6671.994,-1402.906;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3772.593,164.6283;Float;False;Property;_MainNormalScale;MainNormalScale;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-3931.246,92.53902;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;200;-5880.579,-362.0476;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;23;-5053.066,-1158.849;Inherit;False;646.5266;428.8364;Comment;8;15;18;19;16;17;20;21;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;243;-5591.382,397.4686;Inherit;False;371;280;Comment;1;202;Alpha黑白值额外补齐贴图的遮罩图;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-3921.539,584.5468;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;51;-4970.447,-2157.905;Inherit;False;646.5266;428.8364;Comment;8;59;58;57;56;55;54;53;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-3762.885,656.636;Float;False;Property;_SubNormalScale;SubNormalScale;16;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;240;-5925.259,453.7605;Half;False;Property;_AlphaDistortionTexInfluenceDetailAlpha;AlphaDistortionTexInfluenceDetailAlpha;31;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-5179.489,519.4379;Float;False;Property;_AlphaBias;AlphaBias;36;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-3555.111,556.1866;Inherit;True;Property;_SubNormal;SubNormal;15;1;[Normal];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;250;-2404.836,-8.105911;Inherit;False;1319.194;553.4288;Comment;8;36;7;9;4;8;11;12;13;主SEC;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-4920.447,-1924.475;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-4904.47,-1996.068;Float;False;Property;_SubDiffuseU;SubDiffuseU;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;242;-5366.986,-335.4529;Inherit;False;371;280;Comment;1;196;Alpha黑白值额外补齐贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-4901.47,-1844.068;Float;False;Property;_SubDiffuseV;SubDiffuseV;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-6536.908,-1513.772;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-5003.066,-925.4205;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-4984.089,-845.0126;Float;False;Property;_MainDiffuseV;MainDiffuseV;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;251;-2399.67,620.2134;Inherit;False;1269.196;527.5837;Comment;8;68;77;80;67;74;71;79;66;副SEC;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;14;-3564.817,64.17888;Inherit;True;Property;_MainNormal;MainNormal;11;1;[Normal];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;239;-5622.469,-273.3748;Half;False;Property;_AlphaDistortionTexInfluenceAddAlpha;AlphaDistortionTexInfluenceAddAlpha;35;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;202;-5541.382,447.4684;Inherit;True;Property;_DetailAlpha;DetailAlpha;32;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-4987.088,-997.0125;Float;False;Property;_MainDiffuseU;MainDiffuseU;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2364.733,685.9578;Inherit;False;646.5266;428.8364;Comment;8;81;78;76;75;73;72;70;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;249;-1877.581,-1215.659;Inherit;False;1493.591;628.9783;Comment;6;144;156;171;153;155;154;副自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-3210.523,558.1539;Half;False;SubNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;196;-5316.986,-285.4529;Inherit;True;Property;_AddAlpha;AddAlpha;28;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;229;-4919.386,-2536.035;Inherit;False;989.8743;347.8282;Cubemap;5;222;221;227;225;226;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;143;-5802.357,-739.7063;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;36;-2354.836,41.89409;Inherit;False;646.5266;428.8364;Comment;8;44;43;42;41;40;39;38;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-3228.039,55.65421;Half;False;MainNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;230;-5103.159,-1523.094;Inherit;False;989.8743;347.8282;Cubemap;5;235;234;233;232;231;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;241;-5681.643,-797.3779;Inherit;False;371;280;Comment;1;45;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-5006.174,454.7824;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-4739.47,-1895.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-4740.47,-1993.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-4823.088,-994.0125;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-4822.088,-896.0126;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2298.758,847.7939;Float;False;Property;_SubSecTexU;SubSecTexU;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-4695.626,-993.696;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2288.861,203.7302;Float;False;Property;_MainSecTexU;MainSecTexU;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2285.861,355.7304;Float;False;Property;_MainSecTexV;MainSecTexV;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;37;-2304.838,275.3225;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-4796.55,-1108.848;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;144;-1827.581,-1015.517;Inherit;False;646.5266;428.8364;Comment;8;152;151;150;149;148;147;146;145;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;45;-5631.643,-747.3779;Inherit;True;Property;_Alpha;Alpha;25;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-4613.008,-1992.751;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-4742.264,-2128.142;Inherit;False;0;61;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-4953.426,-246.051;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;244;-4199.914,-492.3638;Inherit;False;857.5107;309.6256;;4;199;198;46;47;限制+去色+取单通道;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-5053.159,-1387.772;Inherit;False;223;MainNormal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2295.758,999.7939;Float;False;Property;_SubSecTexV;SubSecTexV;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-4869.386,-2400.711;Inherit;False;224;SubNormal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;69;-2314.735,919.386;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-4477.922,-2103.619;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2134.758,850.7939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2124.861,206.7302;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2123.861,304.7303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;-4149.914,-435.7381;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;146;-1777.581,-782.0875;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;222;-4663.28,-2392.983;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;145;-1761.604,-853.6808;Float;False;Property;_SubEmissionU;SubEmissionU;53;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-2133.758,948.7939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;231;-4847.052,-1380.044;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-4560.54,-1104.563;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1758.604,-701.6806;Float;False;Property;_SubEmissionV;SubEmissionV;54;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-4601.285,-1473.094;Half;False;Property;_MainCubemapIndensity;MainCubemapIndensity;58;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;235;-4643.437,-1405.266;Inherit;True;Property;_MainCubemap;MainCubemap;57;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;-1997.4,207.0466;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;3;-4301.927,-946.1666;Float;False;Property;_Color;Color;3;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-2094.764,726.9867;Inherit;False;0;68;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;70;-2007.296,851.11;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;60;-4219.31,-1945.222;Float;False;Property;_SubColor;SubColor;7;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2084.867,82.92363;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-4390.186,-1134.069;Inherit;True;Property;_MainDiffuse;MainDiffuse;4;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;221;-4459.666,-2418.206;Inherit;True;Property;_SubCubemap;SubCubemap;59;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1597.605,-850.6808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-1596.605,-752.6808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;-4417.513,-2486.035;Half;False;Property;_SubCubemapIndensity;SubCubemapIndensity;60;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;-4307.569,-2133.126;Inherit;True;Property;_SubDiffuse;SubDiffuse;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;199;-3903.691,-437.5525;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;151;-1599.399,-985.7537;Inherit;False;0;153;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-4015.554,-2130.436;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-4282.285,-1410.095;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1856.332,93.18974;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DesaturateOpNode;46;-3743.188,-438.5706;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-4098.512,-2423.035;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;150;-1470.143,-850.3637;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-1866.229,737.2527;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-4034.499,-1114.236;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3856.929,-2294.454;Float;False;Property;_SubDiffuseIndensity;SubDiffuseIndensity;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;-1704.614,670.2134;Inherit;True;Property;_SubSecTex;SubSecTex;22;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-1335.057,-961.2306;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-3776.049,-1273.109;Float;False;Property;_DiffuseIndensity;DiffuseIndensity;1;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;228;-3865.466,-2220.687;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;47;-3579.403,-442.3638;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1687.114,860.7972;Float;False;Property;_SubAO;SubAO;49;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1659.782,67.73979;Inherit;True;Property;_MainSecTex;MainSecTex;19;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1685.113,1032.797;Float;False;Property;_SubMetallic;SubMetallic;51;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1686.114,955.7972;Float;False;Property;_SubGloss;SubGloss;50;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1640.281,430.3229;Float;False;Property;_MainMetallic;MainMetallic;48;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1642.282,258.3229;Float;False;Property;_MainAO;MainAO;46;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1641.282,353.3229;Float;False;Property;_MainGloss;MainGloss;47;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-3910.637,-1234.512;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;153;-1164.703,-990.7379;Inherit;True;Property;_SubEmission;SubEmission;52;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3606.294,-2265.328;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;49;-3152.854,-1312.191;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;99;-962.3776,-353.0667;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-1115.015,-798.6392;Float;False;Property;_SubEmissionIndensity;SubEmissionIndensity;56;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;171;-1096.823,-1165.659;Float;False;Property;_SubEmissionColor;SubEmissionColor;55;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3553.988,-1260.549;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;98;-961.9233,-415.9714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1299.475,886.0562;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1306.662,696.3149;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1302.525,796.6302;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1254.643,283.5819;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1257.693,194.1558;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1261.829,93.84154;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;97;-960.8246,-483.0044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2943.018,-1190.374;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-457.6229,79.73942;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-540.7168,873.5107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-538.5645,783.8657;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-540.7168,961.0437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-724.118,-948.6823;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;170;-3160.706,395.481;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-455.4706,-97.43904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-457.6229,-7.793705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2856.9,-1465.934;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2701.629,-1340.228;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-115.6612,484.9634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-114.9957,662.4197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-114.9957,573.4189;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;168;-2999.297,229.5675;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-552.99,-926.2509;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;294.262,-879.544;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SinCourse/双层PBR简化;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;126;0;124;0
WireConnection;126;1;123;0
WireConnection;175;0;173;0
WireConnection;175;1;174;0
WireConnection;238;0;125;0
WireConnection;238;1;127;0
WireConnection;129;0;126;0
WireConnection;129;1;128;0
WireConnection;179;0;175;0
WireConnection;179;1;178;0
WireConnection;237;0;176;0
WireConnection;237;1;177;0
WireConnection;131;0;238;0
WireConnection;131;1;129;0
WireConnection;181;0;237;0
WireConnection;181;1;179;0
WireConnection;182;1;181;0
WireConnection;207;0;206;0
WireConnection;207;1;204;0
WireConnection;132;1;131;0
WireConnection;208;0;204;0
WireConnection;208;1;205;0
WireConnection;183;0;182;0
WireConnection;133;0;132;0
WireConnection;191;0;189;0
WireConnection;191;1;187;0
WireConnection;190;0;188;0
WireConnection;190;1;189;0
WireConnection;210;0;207;0
WireConnection;210;1;208;0
WireConnection;27;0;28;0
WireConnection;27;1;29;0
WireConnection;185;0;183;0
WireConnection;185;1;133;0
WireConnection;158;0;162;0
WireConnection;158;1;165;0
WireConnection;211;0;209;0
WireConnection;211;1;210;0
WireConnection;192;0;190;0
WireConnection;192;1;191;0
WireConnection;26;0;29;0
WireConnection;26;1;25;0
WireConnection;163;0;159;0
WireConnection;163;1;162;0
WireConnection;86;0;85;0
WireConnection;86;1;83;0
WireConnection;213;0;211;0
WireConnection;213;1;185;0
WireConnection;213;2;140;0
WireConnection;87;0;83;0
WireConnection;87;1;84;0
WireConnection;193;0;194;0
WireConnection;193;1;192;0
WireConnection;164;0;163;0
WireConnection;164;1;158;0
WireConnection;30;0;27;0
WireConnection;30;1;26;0
WireConnection;88;0;86;0
WireConnection;88;1;87;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;200;0;193;0
WireConnection;200;1;185;0
WireConnection;200;2;140;0
WireConnection;161;0;160;0
WireConnection;161;1;164;0
WireConnection;240;0;211;0
WireConnection;240;1;213;0
WireConnection;167;1;161;0
WireConnection;167;5;166;0
WireConnection;90;0;89;0
WireConnection;90;1;88;0
WireConnection;14;1;32;0
WireConnection;14;5;33;0
WireConnection;239;0;193;0
WireConnection;239;1;200;0
WireConnection;202;1;240;0
WireConnection;224;0;167;0
WireConnection;196;1;239;0
WireConnection;143;0;90;0
WireConnection;143;1;185;0
WireConnection;143;2;140;0
WireConnection;223;0;14;0
WireConnection;215;0;202;0
WireConnection;215;1;216;0
WireConnection;55;0;54;0
WireConnection;55;1;53;0
WireConnection;56;0;52;0
WireConnection;56;1;54;0
WireConnection;19;0;16;0
WireConnection;19;1;17;0
WireConnection;18;0;17;0
WireConnection;18;1;15;0
WireConnection;20;0;19;0
WireConnection;20;1;18;0
WireConnection;45;1;143;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;220;0;196;0
WireConnection;220;1;215;0
WireConnection;59;0;58;0
WireConnection;59;1;57;0
WireConnection;75;0;73;0
WireConnection;75;1;69;0
WireConnection;38;0;42;0
WireConnection;38;1;37;0
WireConnection;39;0;37;0
WireConnection;39;1;43;0
WireConnection;198;0;45;0
WireConnection;198;1;220;0
WireConnection;222;0;225;0
WireConnection;76;0;69;0
WireConnection;76;1;78;0
WireConnection;231;0;233;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;235;1;231;0
WireConnection;40;0;38;0
WireConnection;40;1;39;0
WireConnection;70;0;75;0
WireConnection;70;1;76;0
WireConnection;2;1;22;0
WireConnection;221;1;222;0
WireConnection;148;0;145;0
WireConnection;148;1;146;0
WireConnection;149;0;146;0
WireConnection;149;1;147;0
WireConnection;61;1;59;0
WireConnection;199;0;198;0
WireConnection;63;0;61;0
WireConnection;63;1;60;0
WireConnection;63;2;60;4
WireConnection;234;0;232;0
WireConnection;234;1;235;0
WireConnection;41;0;44;0
WireConnection;41;1;40;0
WireConnection;46;0;199;0
WireConnection;226;0;227;0
WireConnection;226;1;221;0
WireConnection;150;0;148;0
WireConnection;150;1;149;0
WireConnection;81;0;72;0
WireConnection;81;1;70;0
WireConnection;5;0;2;0
WireConnection;5;1;3;0
WireConnection;5;2;3;4
WireConnection;68;1;81;0
WireConnection;152;0;151;0
WireConnection;152;1;150;0
WireConnection;228;0;226;0
WireConnection;228;1;63;0
WireConnection;47;0;46;0
WireConnection;4;1;41;0
WireConnection;236;0;234;0
WireConnection;236;1;5;0
WireConnection;153;1;152;0
WireConnection;64;0;62;0
WireConnection;64;1;228;0
WireConnection;49;0;47;0
WireConnection;99;0;47;0
WireConnection;10;0;6;0
WireConnection;10;1;236;0
WireConnection;98;0;47;0
WireConnection;79;0;68;3
WireConnection;79;1;67;0
WireConnection;71;0;68;1
WireConnection;71;1;77;0
WireConnection;74;0;68;2
WireConnection;74;1;80;0
WireConnection;13;0;4;3
WireConnection;13;1;9;0
WireConnection;12;0;4;2
WireConnection;12;1;8;0
WireConnection;11;0;4;1
WireConnection;11;1;7;0
WireConnection;97;0;47;0
WireConnection;48;0;47;0
WireConnection;48;1;10;0
WireConnection;93;0;47;0
WireConnection;93;1;13;0
WireConnection;116;0;98;0
WireConnection;116;1;74;0
WireConnection;114;0;97;0
WireConnection;114;1;71;0
WireConnection;115;0;99;0
WireConnection;115;1;79;0
WireConnection;155;0;171;0
WireConnection;155;1;153;0
WireConnection;155;2;156;0
WireConnection;170;0;47;0
WireConnection;91;0;47;0
WireConnection;91;1;11;0
WireConnection;92;0;47;0
WireConnection;92;1;12;0
WireConnection;50;0;64;0
WireConnection;50;1;49;0
WireConnection;65;0;50;0
WireConnection;65;1;48;0
WireConnection;117;0;91;0
WireConnection;117;1;114;0
WireConnection;119;0;93;0
WireConnection;119;1;115;0
WireConnection;118;0;92;0
WireConnection;118;1;116;0
WireConnection;168;0;14;0
WireConnection;168;1;167;0
WireConnection;168;2;170;0
WireConnection;154;0;155;0
WireConnection;154;1;97;0
WireConnection;0;0;65;0
WireConnection;0;1;168;0
WireConnection;0;2;154;0
WireConnection;0;3;119;0
WireConnection;0;4;118;0
WireConnection;0;5;117;0
ASEEND*/
//CHKSM=FB1B950F942E7D9B970C58BB45D7699FF328F60F