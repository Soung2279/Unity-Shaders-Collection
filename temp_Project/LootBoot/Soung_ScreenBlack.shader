Shader "Soung/Effect/ScreenBlack_V"
{
    Properties
    {
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		_ButtomColor("底部颜色", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

        Cull [_CullingMode]
		AlphaToMask Off

        HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        half4 _ButtomColor;
        CBUFFER_END

        struct a2v
        {
            float4 positionOS:POSITION;
            float4 normalOS:NORMAL;
            float2 texcoord:TEXCOORD;
            float4 ase_color : COLOR;
        };
        struct v2f
        {
            float4 positionCS:SV_POSITION;
            float2 texcoord:TEXCOORD;
            float4 vertexColor : COLOR; // 传递顶点颜色到片段着色器
        };
        ENDHLSL

        Pass
        {
			Name "Forward"
			Tags { "LightMode"="SRPDefaultUnlit" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGB
            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG

            v2f VERT(a2v i)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(i.positionOS.xyz);
                o.texcoord = i.texcoord;
                o.vertexColor = i.ase_color; // 将顶点颜色传递到片段着色器
                return o;
            }

            half4 FRAG(v2f i):SV_TARGET
            {
                half4 baseColor = _ButtomColor;
                
                half4 finalColor;
                finalColor.rgb = baseColor.rgb;
                finalColor.a = baseColor.a * i.vertexColor.a;
                return finalColor;
            }
            ENDHLSL

        }

    }

}