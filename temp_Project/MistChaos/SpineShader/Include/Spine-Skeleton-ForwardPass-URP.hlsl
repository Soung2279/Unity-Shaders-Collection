#ifndef SKELETON_FORWARD_PASS_URP_INCLUDED
#define SKELETON_FORWARD_PASS_URP_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "SpineCoreShaders/Spine-Common.cginc"
#include "SpineCoreShaders/Spine-Skeleton-Tint-Common.cginc"

struct appdata {
    float3 pos : POSITION;
    half4 color : COLOR;
    float2 uv0 : TEXCOORD0;
#if defined(_TINT_BLACK_ON)
    float2 tintBlackRG : TEXCOORD1;
    float2 tintBlackB : TEXCOORD2;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput {
    half4 color : COLOR0;
    float2 uv0 : TEXCOORD0;
    float4 pos : SV_POSITION;
#if defined(_TINT_BLACK_ON)
    float3 darkColor : TEXCOORD1;
#endif
#if defined(_FLOW_GLOW_ON)
    float4 screenPos : TEXCOORD2;
#endif
    UNITY_VERTEX_OUTPUT_STEREO
};

VertexOutput vert(appdata v) {
    VertexOutput o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float3 positionWS = TransformObjectToWorld(v.pos);
    o.pos = TransformWorldToHClip(positionWS);
    o.uv0 = v.uv0;
    o.color = PMAGammaToTargetSpace(v.color);
#if defined(_TINT_BLACK_ON)
    o.color *= _Color;
    o.darkColor = GammaToTargetSpace(
        half3(v.tintBlackRG.r, v.tintBlackRG.g, v.tintBlackB.r)) + (_Black.rgb * v.color.a);
#elif defined (APPLY_MATERIAL_TINT_COLOR)
    o.color *= _Color;
#endif

#if defined(_FLOW_GLOW_ON)
    o.screenPos = ComputeScreenPos(o.pos);
#endif

    return o;
}

// 边缘扩展函数：使用径向采样扩展遮罩边缘，支持羽化
half4 SampleExpandedMask(float2 uv, float radius, int samples, float feather) {
    // 中心采样
    half4 centerSample = tex2D(_GlowMaskTex, uv);
    
    if (radius < 0.001) {
        return centerSample; // 无扩展
    }
    
    // 累积周围采样
    half4 accumulated = centerSample;
    
    // 计算像素大小（UV空间）
    float2 pixelSize = _GlowMaskTex_TexelSize.xy * radius;
    
    // 径向采样
    float angleStep = 6.28318530718 / float(samples); // 2*PI / samples
    
    for (int i = 0; i < samples; i++) {
        float angle = float(i) * angleStep;
        float2 offset = float2(cos(angle), sin(angle)) * pixelSize;
        half4 sample = tex2D(_GlowMaskTex, uv + offset);
        
        // 根据距离计算羽化权重
        // distance 从 0 (中心) 到 1 (边缘)
        float distance = length(offset) / length(pixelSize);
        
        // 羽化衰减：越靠近边缘，权重越低
        // feather = 0: 无衰减（硬边）
        // feather = 1: 线性衰减到0（完全羽化）
        float fadeWeight = lerp(1.0, 1.0 - distance, feather);
        
        // 应用羽化权重到采样值
        sample *= fadeWeight;
        
        // 取最大值以实现扩展效果
        accumulated = max(accumulated, sample);
    }
    
    return accumulated;
}

half4 frag(VertexOutput i) : SV_Target{
    // 基础纹理采样
    float4 texColor = tex2D(_MainTex, i.uv0);
    
#if defined(_ZWRITE)
    clip(texColor.a * i.color.a - _Cutoff);
#endif

#if defined(_STRAIGHT_ALPHA_INPUT)
    texColor.rgb *= texColor.a;
#endif

    float finalAlpha = texColor.a * i.color.a;
    float3 baseColor;
    
    // 皮肤着色计算
#if defined(_TINT_BLACK_ON)
    half4 tintedColor = fragTintedColor(texColor, i.darkColor, i.color, _Color.a, _Black.a);
    baseColor = tintedColor.rgb;
    finalAlpha = tintedColor.a;
#else
    baseColor = texColor.rgb * i.color.rgb;
#endif

    // 填充效果
#if defined(_FILL_ON)
    if (_FillPhase > 0.001) {
        baseColor = lerp(baseColor, (_FillColor.rgb * finalAlpha), _FillPhase);
    }
#endif

    // 区域发光效果 (流光只在扩展后的遮罩范围内有效)
#if defined(_MASK_GLOW_ON)
    // 采样原始发光遮罩（用于发光效果）
    half maskColorR = tex2D(_GlowMaskTex, i.uv0).r;
    half maskColorA = tex2D(_GlowMaskTex, i.uv0).a;
    float maskColorAlpha = lerp(maskColorR, maskColorA, _SwitchGlowP);
    half4 maskColor = tex2D(_GlowMaskTex, i.uv0) * maskColorAlpha;
    
    // 采样扩展后的遮罩（用于流光效果）
    half4 expandedMask = maskColor;
    if (_UseEdgeExpand > 0.5) {
        int samples = (int)_EdgeExpandSamples;
        expandedMask = SampleExpandedMask(i.uv0, _EdgeExpandRadius, samples, _EdgeFeather);
        
        // 应用通道切换到扩展后的遮罩
        half expandedMaskR = expandedMask.r;
        half expandedMaskA = expandedMask.a;
        float expandedMaskAlpha = lerp(expandedMaskR, expandedMaskA, _SwitchGlowP);
        expandedMask *= expandedMaskAlpha;
    }
    
    // 联动逻辑：当 _MaskStatus 为 1 时，强制发光强度为 0
    half effectiveGlowIntensity = _GlowIntensity * (1.0 - _MaskStatus);
    
    // 计算基础发光（不包含流光）
    if (any(maskColor.rgb > 0.001) && effectiveGlowIntensity > 0.001) {
        half3 glowContribution = maskColor.rgb * _GlowColor.rgb * effectiveGlowIntensity * maskColor.a;
        baseColor += glowContribution;
    }
    
    // 流光效果：独立计算，只在扩展后的遮罩范围内显示（叠加混合）
    #if defined(_FLOW_GLOW_ON)
        if (any(expandedMask.rgb > 0.001) && effectiveGlowIntensity > 0.001) {
            // 计算流光UV (支持屏幕空间UV)
            float2 flowUV;
            #if defined(_USE_SCREEN_UV)
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                screenUV = screenUV * _ScreenTex_ST.xy + _ScreenTex_ST.zw;
                flowUV = screenUV + _Time.y * _FlowSpeed;
            #else
                flowUV = TRANSFORM_TEX(i.uv0, _FlowTex) + _Time.y * _FlowSpeed;
            #endif
            
            // 采样流光纹理
            half3 flowColor = tex2D(_FlowTex, flowUV).rgb;
            
            // 流光效果：使用叠加混合（加法），受扩展遮罩控制
            half3 flowContribution = flowColor * _GlowColor.rgb * effectiveGlowIntensity * expandedMask.rgb * expandedMask.a;
            
            // 叠加到最终颜色
            baseColor += flowContribution;
        }
    #endif
#endif

    // 应用全局显示遮罩
#if defined(_GLOBAL_MASK_ON)
    half globalMaskR = tex2D(_GlobalMaskTex, i.uv0).r;
    half globalMaskA = tex2D(_GlobalMaskTex, i.uv0).a;
    float globalMask = lerp(globalMaskR, globalMaskA, _SwitchP);
    globalMask = lerp(1.0, globalMask, _MaskStatus);
    
    baseColor *= globalMask;
    finalAlpha *= globalMask;
    
    // 提前剔除完全透明的片元
    clip(globalMask - 0.001);
#endif

    return half4(baseColor, finalAlpha);
}
#endif
