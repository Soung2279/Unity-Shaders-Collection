Shader "A201-Shader/进阶功能/颜色叠加粒子控制溶解_ice_dissolve"
{
	Properties
	{	
		_LightIceColor ("主颜色（粒子透明度控制溶解程度）", Color) = (0,0,1,1)
		_MainTex ("主贴图", 2D) = "white" {}
		_RampTex ("颜色渐变", 2D) = "white" {}
		_CutTex ("Alpha贴图", 2D) = "white" {}
		_Cutoff ("Alpha剔除数值", Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
        Cull Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normalWorld : NORMAL;
				float3 viewDirWorld : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _RampTex;
			float4 _LightIceColor;
			sampler2D _CutTex;
			float4 _CutTex_ST;
			half _Cutoff;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normalWorld=UnityObjectToWorldNormal(v.normal);
				o.viewDirWorld=WorldSpaceViewDir(v.vertex);
				//TANGENT_SPACE_ROTATION 
				o.color = v.color;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				float4 col=tex2D(_MainTex,i.uv);
				float vn = dot(i.normalWorld,normalize(i.viewDirWorld));
				float4 col2=tex2D(_RampTex,float2(vn,0.5));
				col += col.a * col2;
				col*=_LightIceColor;
				float4 cut = tex2D(_CutTex, i.uv);
				clip(i.color.a - cut.r);
				clip(col.a - _Cutoff);
				UNITY_APPLY_FOG(i.fogCoord, col);
				//return col;
				return col;
			}
			ENDCG
		}
	}
}
