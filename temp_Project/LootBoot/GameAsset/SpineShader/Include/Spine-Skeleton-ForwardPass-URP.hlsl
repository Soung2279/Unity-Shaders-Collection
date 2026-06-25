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

    // 发光：只由发光开关和发光遮罩控制，遮罩只提供生效区域/透明度
#if defined(_MASK_GLOW_ON)
    half4 glowMaskSample = tex2D(_GlowMaskTex, i.uv0);
    half glowMaskAlpha = lerp(glowMaskSample.r, glowMaskSample.a, _SwitchGlowP);
    half glowBreathAlpha = 1;
    #if defined(_GLOW_BREATH_ON)
        half glowBreathPhase = (1.0 - cos(_Time.y * _GlowBreathFreq * 6.28318530718)) * 0.5;
        glowBreathAlpha = lerp(_GlowBreathMinAlpha, _GlowBreathMaxAlpha, glowBreathPhase);
    #endif

    if (glowMaskAlpha > 0.001 && _GlowIntensity > 0.001) {
        half glowAlpha = glowMaskAlpha * glowBreathAlpha * _GlowColor.a;
        half3 glowContribution = _GlowColor.rgb * _GlowIntensity * glowAlpha;
        baseColor += glowContribution;
    }
#endif

    // 流光：独立于发光遮罩，直接作用于整张图的有效透明区域
#if defined(_FLOW_GLOW_ON)
    float2 flowUV;
    #if defined(_USE_SCREEN_UV)
        float2 screenUV = i.screenPos.xy / i.screenPos.w;
        screenUV = screenUV * _ScreenTex_ST.xy + _ScreenTex_ST.zw;
        flowUV = screenUV + _Time.y * _FlowSpeed;
    #else
        flowUV = TRANSFORM_TEX(i.uv0, _FlowTex) + _Time.y * _FlowSpeed;
    #endif

    half4 flowColor = tex2D(_FlowTex, flowUV);
    half flowAlpha = flowColor.a * _FlowColor.a * finalAlpha;
    half3 flowContribution = flowColor.rgb * _FlowColor.rgb * flowAlpha;
    baseColor += flowContribution;
#endif


    return half4(baseColor, saturate(finalAlpha));
}
#endif
