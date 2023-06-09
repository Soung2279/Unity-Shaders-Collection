// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "A201-Shader/基本效果/表面流光制作_Liuguang" { 

	Properties {
		//_Offset ("Offset",Range (0.00,1.00)) = 1.00
		_MainColor("主颜色", color) = (1.0,1.0,1.0,1.0)
		_MainTex ("主贴图", 2D) = "white" {}
		_Mask ("Alpha遮罩（流光纹理）", 2D ) = "white" {}

	}
	
	SubShader {
		Tags { "Queue"= "Transparent"} // water uses -120
         ZWrite Off
         Cull Off
         Offset -1, -1
         Blend SrcAlpha One
		
		Pass {
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_fwdbase nolightmap nodirlightmap
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
			
			#include "UnityCG.cginc"

			
			struct appdata {
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			struct v2f {
				float4 pos : POSITION;
				half2 texcoord : TEXCOORD0;
				half2 texcoord1 : TEXCOORD1;
				fixed4 color : COLOR;
			};
	
			sampler2D _MainTex;
			sampler2D _Mask;
			fixed4 _MainColor;		
			half4 _MainTex_ST;
			half4 _Mask_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);	
				o.texcoord1 = TRANSFORM_TEX(v.texcoord,_Mask);			
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 texColor = _MainColor * tex2D(_MainTex, i.texcoord) * 2 ;
				fixed4 maskColor = tex2D(_Mask, i.texcoord1);
				fixed4 finalColor = texColor * maskColor;
				finalColor.a *= i.color.a;
				return finalColor;
			}
			
			ENDCG
		}
	} 
	
	FallBack "Unlit/Texture"
}
