#ifndef SPINE_DISTORT_OUTLINE_PASS_URP_INCLUDED
#define SPINE_DISTORT_OUTLINE_PASS_URP_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ─────────────────────────────────────────────────────────────────────────────
// CBuffer
// ─────────────────────────────────────────────────────────────────────────────
CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    float4 _MainTex_TexelSize;   // (1/w, 1/h, w, h)
    float4 _OutlineColor;
    float  _OutlineWidth;
    float  _ThresholdEnd;
    float  _OutlineSmoothness;
    int    _OutlineReferenceTexWidth;
    // ── Fire Color ──
    float4 _FireInnerColor;
    float4 _FireOuterColor;
    float  _FireOuterWidth;
    float  _FireEdgeWidth;
    // ── Fire Noise Layer 1 ──
    float  _NoiseTimeSpeed1;
    float  _NoiseScale1;
    float4 _TillSpeed1;
    // ── Fire Noise Layer 2 ──
    float  _NoiseTimeSpeed2;
    float  _NoiseScale2;
    float4 _TillSpeed2;
    // ── Dissolve ──
    float  _DissolveAmount;
    float  _FireBodySize;
    float  _DissolveMul;
CBUFFER_END

sampler2D _MainTex;

// ─────────────────────────────────────────────────────────────────────────────
// Voronoi 噪波（复用 Soung_Fire-Pro 逻辑，两层叠加产生火焰形态）
// ─────────────────────────────────────────────────────────────────────────────
float2 _VoronoiHash(float2 p)
{
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return frac(sin(p) * 43758.5453);
}

float _Voronoi(float2 v, float time)
{
    float2 n = floor(v);
    float2 f = frac(v);
    float  F1 = 8.0;
    int i, j;
    for (j = -1; j <= 1; j++)
    {
        for (i = -1; i <= 1; i++)
        {
            float2 g = float2(i, j);
            float2 o = _VoronoiHash(n + g);
            o = sin(time + o * 6.2831) * 0.5 + 0.5;
            float2 r = f - g - o;
            float  d = 0.5 * dot(r, r);
            if (d < F1) { F1 = d; }
        }
    }
    return F1;
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertex / Fragment 结构体
// ─────────────────────────────────────────────────────────────────────────────
struct VertexInput {
    float4 positionOS  : POSITION;
    float2 uv          : TEXCOORD0;
    float4 vertexColor : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput {
    float4 pos             : SV_POSITION;
    float2 uv              : TEXCOORD0;
    float  vertexColorAlpha : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

// ─────────────────────────────────────────────────────────────────────────────
// 顶点着色器
// ─────────────────────────────────────────────────────────────────────────────
VertexOutput vertDistortOutline(VertexInput v) {
    VertexOutput o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 clipPos = TransformObjectToHClip(v.positionOS.xyz);

    // 使用 clip-space XY 方向作为"外扩法线"的近似（适用于居中的 2D Spine 角色）
    float2 clipDir = clipPos.xy;
    float dirLen = length(clipDir);
    clipDir = (dirLen > 0.001) ? clipDir / dirLen : float2(0.0, 1.0);

    // clip-space 径向外扩（无扰动）
    float2 ndcOffset = clipDir * _OutlineWidth
                     * float2(2.0 / _ScreenParams.x, 2.0 / _ScreenParams.y);
    clipPos.xy += ndcOffset * clipPos.w;

    o.pos             = clipPos;
    o.uv              = v.uv;   // 原始 UV 不变，供 frag 采样原图 alpha
    o.vertexColorAlpha = v.vertexColor.a;
    return o;
}

// ─────────────────────────────────────────────────────────────────────────────
// 片元着色器
// ─────────────────────────────────────────────────────────────────────────────
float4 fragDistortOutline(VertexOutput i) : SV_Target {
    float centerAlpha = tex2D(_MainTex, i.uv).a * i.vertexColorAlpha;

    // 条件 1：丢弃角色本体内部（不透明区域）
    clip(_ThresholdEnd - centerAlpha);

    // 条件 2：只保留真正位于轮廓环内的像素（邻近轮廓的位置）。
    // 纯透明的 atlas 空白区（alpha≈0）虽满足条件1，但其邻域也全为0，
    // 不满足条件2 → 被丢弃，避免整块 atlas 区域被填色。
    //
    // 采样偏移与 computeOutlinePixel 保持一致：
    //   outlineWidthCompensated = OutlineWidth / (ReferenceWidth * texelSize.x)
    //   xOffset = texelSize.x * outlineWidthCompensated = OutlineWidth / ReferenceWidth
    float compensated = _OutlineWidth / (float(_OutlineReferenceTexWidth) * _MainTex_TexelSize.x);
    float dx = _MainTex_TexelSize.x * compensated;
    float dy = _MainTex_TexelSize.y * compensated;
    float dxd = dx * 0.7;
    float dyd = dy * 0.7;

    float neighborMax = max(
        max(max(tex2D(_MainTex, i.uv + float2( dx,  0)).a, tex2D(_MainTex, i.uv + float2(-dx,   0)).a),
            max(tex2D(_MainTex, i.uv + float2(  0, dy)).a, tex2D(_MainTex, i.uv + float2(  0, -dy)).a)),
        max(max(tex2D(_MainTex, i.uv + float2( dxd,  dyd)).a, tex2D(_MainTex, i.uv + float2(-dxd,  dyd)).a),
            max(tex2D(_MainTex, i.uv + float2( dxd, -dyd)).a, tex2D(_MainTex, i.uv + float2(-dxd, -dyd)).a))
    ) * i.vertexColorAlpha;

    // 使用平滑过渡，与 _OutlineSmoothness 参数对应
    float thresholdStart = _ThresholdEnd * (1.0 - _OutlineSmoothness);
    float outlineAlpha = saturate((neighborMax - thresholdStart) / max(_ThresholdEnd - thresholdStart, 0.0001));
    clip(outlineAlpha - 0.001);

    // ── 两层 Voronoi 火焰（参照 Soung_Fire-Pro.shader 逻辑）─────────────────────────
    // Layer 1
    float2 panner1 = i.uv * _TillSpeed1.xy + _TillSpeed1.zw * _Time.y;
    float  voroi1  = _Voronoi(panner1 * _NoiseScale1, _Time.y * _NoiseTimeSpeed1);

    // Layer 2
    float2 panner2 = i.uv * _TillSpeed2.xy + _TillSpeed2.zw * _Time.y;
    float  voroi2  = _Voronoi(panner2 * _NoiseScale2, _Time.y * _NoiseTimeSpeed2);

    // Overlay 混合（与 Fire-Pro 完全一致）
    float noiseBlend = saturate((voroi2 > 0.5)
        ? (1.0 - 2.0 * (1.0 - voroi2) * (1.0 - voroi1))
        : (2.0 * voroi2 * voroi1));

    // Y 方向渐变：底部 (y=0) 不溶解，顶部 (y=1) 完全溶解
    float dirMask = 1.0 - saturate(i.uv.y);

    // 综合形态値（对应 Fire-Pro 的 temp_output_41_0）
    float shapeVal = saturate(noiseBlend * dirMask + dirMask * 0.1 * _FireBodySize);

    // 溶解 / 颜色阈値（对应 Fire-Pro 的 step 判断）
    float dissolveT = _DissolveAmount * _DissolveMul;
    float edgeT     = (_FireEdgeWidth  + _DissolveAmount * _DissolveMul) * _DissolveMul;
    float outerT    = (_FireOuterWidth + _FireEdgeWidth + _DissolveAmount * _DissolveMul) * _DissolveMul;

    // 溶解裁剪
    clip(shapeVal - dissolveT);

    // 三段颜色：描边色(_OutlineColor) → 外焰(_FireOuterColor) → 内焰(_FireInnerColor)
    float4 fireColor  = lerp(_FireOuterColor, _FireInnerColor, step(outerT, shapeVal));
    float4 finalColor = lerp(_OutlineColor,   fireColor,       step(edgeT,  shapeVal));

    float finalAlpha = finalColor.a * outlineAlpha;
    return float4(finalColor.rgb * finalAlpha, finalAlpha);
}

#endif // SPINE_DISTORT_OUTLINE_PASS_URP_INCLUDED
