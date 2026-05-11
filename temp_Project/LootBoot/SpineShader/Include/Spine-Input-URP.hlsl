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
half2 _FlowSpeed;
float4 _FlowTex_ST;
float4 _ScreenTex_ST;
half _SwitchGlowP;
CBUFFER_END

sampler2D _MainTex;
sampler2D _GlowMaskTex;
sampler2D _FlowTex;

#endif // URP_LIT_INPUT_INCLUDED
