Shader "A201-Shader/Built-in/特殊制作/色差热扭曲"
{
	Properties
	{
		[Header(Heat)]
		_Distortion_Tex("热扭曲纹理", 2D) = "white" {}
		_DistortionU("热扭曲U速率", Float) = 0
		_DistortionV("热扭曲V速率", Float) = 0
		_Indensity("扭曲强度", Range(0.0, 1.0)) = 0.5

		[Header(Mask)]
		_AlphaTex("扭曲遮罩", 2D) = "white" {}
		_AlphaU("遮罩1U速率", Float) = 0
		_AlphaV("遮罩1V速率", Float) = 0
		_AlphaTex1("扭曲遮罩2", 2D) = "white" {}
		_AlphaTex1U("遮罩2U速率", Float) = 0
		_AlphaTex1V("遮罩2V速率", Float) = 0

		[Header(Refraction)]
		_IOR1("材质最小折射率", Float) = 1
		_IOR2("材质最大折射率", Float) = 1.4
		_ChromaticAberration("色差强度", Range(0.0, 0.5)) = 0.1

		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.5

		#pragma multi_compile _ALPHAPREMULTIPLY_ON

		#pragma surface surf BlinnPhong alpha:fade keepalpha finalcolor:RefractionF noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float3 worldPos;
		};

		uniform sampler2D _Distortion_Tex;
		uniform float4 _Distortion_Tex_ST;
		uniform float _DistortionU;
		uniform float _DistortionV;
		uniform float _Indensity;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _IOR1;
		uniform float _IOR2;
		uniform sampler2D _AlphaTex;
		uniform float4 _AlphaTex_ST;
		uniform float _AlphaU;
		uniform float _AlphaV;
		uniform sampler2D _AlphaTex1;
		uniform float4 _AlphaTex1_ST;
		uniform float _AlphaTex1U;
		uniform float _AlphaTex1V;

		inline float4 Refraction( Input i, SurfaceOutput o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutput o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float temp_output_63_0 = ( i.vertexColor.a * _Indensity );
			float2 uv0_AlphaTex = i.uv_texcoord * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
			float2 uv1_AlphaTex = i.uv2_texcoord2 * _AlphaTex_ST.xy + _AlphaTex_ST.zw;

			float2 staticSwitch72 = uv0_AlphaTex;

			float2 appendResult46 = (float2(_AlphaU , _AlphaV));
			float3 desaturateInitialColor65 = tex2D( _AlphaTex, ( staticSwitch72 + ( _Time.y * appendResult46 ) ) ).rgb;
			float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 0.0 );

			float2 uv0_AlphaTex1 = i.uv_texcoord * _AlphaTex1_ST.xy + _AlphaTex1_ST.zw;
			float2 staticSwitch82 = uv0_AlphaTex1;

			float2 appendResult80 = (float2(_AlphaTex1U , _AlphaTex1V));
			float3 desaturateInitialColor87 = tex2D( _AlphaTex1, ( staticSwitch82 + ( _Time.y * appendResult80 ) ) ).rgb;
			float desaturateDot87 = dot( desaturateInitialColor87, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar87 = lerp( desaturateInitialColor87, desaturateDot87.xxx, 1.0 );

			float lerpResult67 = lerp( _IOR1 , _IOR2 , ( temp_output_63_0 * desaturateVar65 * (desaturateVar87).x).x);
			color.rgb = color.rgb + Refraction( i, o, lerpResult67, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv0_Distortion_Tex = i.uv_texcoord * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;

			float2 staticSwitch70 = uv0_Distortion_Tex;

			float2 appendResult3 = (float2(_DistortionU , _DistortionV));
			float temp_output_63_0 = ( i.vertexColor.a * _Indensity );
			float4 lerpResult60 = lerp( float4( float3(0,0,1) , 0.0 ) , tex2D( _Distortion_Tex, ( staticSwitch70 + ( _Time.y * appendResult3 ) ) ) , temp_output_63_0);
			o.Normal = lerpResult60.rgb;
			o.Alpha = 0.0;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	Fallback "Diffuse"
}