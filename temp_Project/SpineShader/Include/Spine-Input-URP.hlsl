#ifndef URP_LIT_INPUT_INCLUDED
#define URP_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

////////////////////////////////////////
// Defines
//
#undef LIGHTMAP_ON

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
half _Cutoff;
half4 _Color;
half4 _Black;
half4 _FillColor;
half _FillPhase;
half4 _GlowColor;
half _GlowIntensity;
half _UseEdgeExpand;
half _EdgeExpandRadius;
half _EdgeExpandSamples;
half _EdgeFeather;  // 新增：羽化强度
half2 _FlowSpeed;
float4 _FlowTex_ST;
half _UseScreenUV;
float4 _ScreenTex_ST;
half _MaskStatus;
half _SwitchP;
half _SwitchGlowP;
CBUFFER_END

sampler2D _MainTex;
sampler2D _GlowMaskTex;
sampler2D _FlowTex;
sampler2D _GlobalMaskTex;
float4 _GlowMaskTex_TexelSize;

#endif // URP_LIT_INPUT_INCLUDED
