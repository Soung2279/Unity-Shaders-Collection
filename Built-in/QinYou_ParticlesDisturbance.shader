// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//扰动
Shader "A201-Shader/进阶功能/扰动+流光制作_RaoDong" {
Properties {
	_MainTex ("主贴图", 2D) = "black" {}//主贴图
	_MainUVspeed ("主贴图UV速率",Vector ) = (0,0,0,0)
	_AlphaTex ("Alpha贴图（与主贴图保持一致）", 2D) = "white" {}
	_noiseTex ("扰动纹理", 2D) = "white" {}//扰动噪点贴图
	
	_UVTex ("UV贴图", 2D) = "Black" {}//UV贴图
	_UVTintColor ("颜色", Color) = (1,1,1,1)
	_UVspeed ("UV速率",Vector ) = (0,0,0,0)
	_HeatSpeed ("扰动速度",Vector) = (0,0,0,0)//扰动速度
	_HeatForce  ("扰动强度", range (0,0.2)) = 0//扰动强度

	_Emission ("自发光强度", Range(0,8)) = 1
	[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 5//SrcAlpha
	[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 1//One
}

SubShader {
	Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}	
	LOD 100
	
	Lighting Off
	ZWrite Off
	Cull Off 
	Blend [_SrcBlend] [_DstBlend]
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest	
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float4 color : COLOR;
			};

			float4 _MainTex_ST;
			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _noiseTex;
			sampler2D _UVTex;
			float4 _UVTex_ST;

		  
		    float4 _UVTintColor;
			half4 _UVspeed;
			half4 _HeatSpeed;
		    half _HeatForce;
			half _Emission;

			float4 _MainUVspeed;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord, _UVTex);

				o.color = v.color;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//扰流
				float2 uv = i.texcoord;
				half4 offsetColor1 = tex2D(_noiseTex, uv + _Time.xz * _HeatSpeed.x);
			    half4 offsetColor2 = tex2D(_noiseTex, uv - _Time.yx * _HeatSpeed.y);
			    
				uv.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce + _MainUVspeed.x * _Time.y;
				uv.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce + _MainUVspeed.y * _Time.y;
				
				float2 uv1 = i.texcoord1;
				uv1.x += _UVspeed.x * _Time.y; 
				uv1.y += _UVspeed.y * _Time.y;
				
				fixed4 mainCol = tex2D(_MainTex, uv);
				fixed4 alphaCol = tex2D(_AlphaTex, uv);			
				
				fixed4 uvCol = tex2D(_UVTex, uv1) * alphaCol;
				
				fixed4 finalCol = (mainCol + uvCol)  * _Emission* _UVTintColor * i.color;
				//finalCol.a = mainCol.a;
				return finalCol;
			}
		ENDCG
		}
	}
	FallBack "Mobile/Particles/Addtive"
}
