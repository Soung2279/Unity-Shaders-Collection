Shader "A201-Shader/Built-in/特殊制作/渐变颜色制作"
{
	Properties
	{
		_Up_Color("前颜色", Color) = (1,0.5,1, 1.0)
		_Down_Color("后颜色", Color) = (0.5,1,0.5, 1.0)
		_Gradation_thickness("颜色过渡值", Float) = 4
		_Gradation_height("颜色分割值", Range(-1.0, 1.0)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Down_Color;
		uniform float4 _Up_Color;
		uniform float _Gradation_height;
		uniform float _Gradation_thickness;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 lerpResult = lerp( _Down_Color , _Up_Color , saturate( ( ( i.uv_texcoord.y - _Gradation_height ) * _Gradation_thickness ) ));
			o.Emission = lerpResult.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}