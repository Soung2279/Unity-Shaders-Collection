#ifndef SOFT_PARTICLE_FADE
#define SOFT_PARTICLE_FADE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

// Z buffer to linear depth
inline float LinearEyeDepth( float z )
{
    return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
}

inline float4 TransformSoftParticle( float4 vertex )
{
#if SOFTPAR_ON
	float4 projPos = ComputeScreenPos(vertex);
	return projPos;
#endif
	return 0;
}

inline half ApplySoftParticle( float4 projPos, half col )
{
#if SOFTPAR_ON
	half sceneZ = LinearEyeDepth(SampleSceneDepth(projPos.xy / projPos.w), _ZBufferParams);
	half depthDiff = sceneZ - projPos.w;
	half fade = (1 - _SoftParticleFade) * depthDiff * 0.5;
	fade = saturate(fade);
	return col * fade;
#endif
	return col;
}

#define SOFT_PARTICLE_POS(idx) float4 projPos : TEXCOORD##idx;

#define TRANSFORM_SOFT_PARTICLE_POS(o) o.projPos = TransformSoftParticle(o.vertex);

#define APPLY_SOFT_PARTICLE(projPos, col) col.a = ApplySoftParticle(projPos, col.a)


#endif//SOFT_PARTICLE_FADE