Shader "URP/ACEs"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _FilmSlope("Film Slope", float) = 2.51
        _FilmToe("Film Toe", float) = 0.03
        _FilmShoulder("Film Shoulder", float) = 2.43
        _FilmBlackClip("Film Black Clip", float) = 0.59
        _FilmWhiteClip("Film White Clip", float) = 0.14
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "ACES.hlsl"          //函数库


            ENDHLSL
        }
    }
}