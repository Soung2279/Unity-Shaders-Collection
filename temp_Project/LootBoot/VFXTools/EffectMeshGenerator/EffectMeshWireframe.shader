Shader "VFX/Utility/EffectMeshWireframe"
{
    Properties
    {
        _WireColor ("Wire Color", Color) = (0.015, 0.02, 0.025, 0.9)
        _UseVertexAlpha ("Use Vertex Alpha", Float) = 1
        _UseVertexColor ("Use Vertex Color", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+10" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "Wireframe"
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            ZWrite Off
            ZTest LEqual
            Cull Off
            Offset -1, -1
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _WireColor;
                float _UseVertexAlpha;
                float _UseVertexColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
            };
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.color = input.color;
                return output;
            }
            half4 frag(Varyings input) : SV_Target
            {
                half vertexAlpha = lerp(1.0h, input.color.a, _UseVertexAlpha);
                half3 color = lerp(_WireColor.rgb, input.color.rgb, _UseVertexColor);
                half guideAlpha = lerp(1.0h, input.color.a, _UseVertexColor);
                return half4(color, saturate(_WireColor.a * vertexAlpha * guideAlpha));
            }
            ENDHLSL
        }
    }
}
