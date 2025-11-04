#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"



CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float _FilmSlope, _FilmToe, _FilmShoulder, _FilmBlackClip, _FilmWhiteClip;
float _postExposure;
CBUFFER_END


TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);


struct appdata
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;

};




float3 ACESFilm(float3 LinearColor, float a, float b, float c, float d, float e)
{
    const float ExposureMultiplier = _postExposure;                  // 曝光值

    const float3x3 PRE_TONEMAPPING_TRANSFORM =              // 色调映射矩阵
    {
     0.575961650, 0.344143820, 0.079952030,
     0.070806820, 0.827392350, 0.101774690,
     0.028035252, 0.131523770, 0.840242300
    };

    const float3x3 EXPOSED_PRE_TONEMAPPING_TRANSFORM = ExposureMultiplier * PRE_TONEMAPPING_TRANSFORM;    // key  场景颜色乘 曝光度 整个场景的色调。

    const float3x3 POST_TONEMAPPING_TRANSFORM =
    {
        1.666954300, -0.601741150, -0.065202855,
    -0.106835220, 1.237778600, -0.130948950,
    -0.004142626, -0.087411870, 1.091555000
    };

    /*
    float a; // 2.51
    float b; // 0.03
    float c; // 2.43
    float d; // 0.59
    float e; // 0.14
    */

    float3 Color = mul(EXPOSED_PRE_TONEMAPPING_TRANSFORM, LinearColor);                        // 线性颜色转换
    Color = saturate((Color * (a * Color + b)) / (Color * (c * Color + d) + e));               // 应用到ACES 颜色校正

    return clamp(mul(POST_TONEMAPPING_TRANSFORM, Color), 0.0f, 1.0f);                          // 后置处理（颜色重构）

}



v2f vert(appdata v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.positionOS.xyz);
    o.uv = v.texcoord;
    return o;
}

half4 frag(v2f i) : SV_Target
{

    float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

    col.xyz = ACESFilm(col.xyz, _FilmSlope, _FilmToe, _FilmShoulder, _FilmBlackClip, _FilmWhiteClip);

    return col;
}