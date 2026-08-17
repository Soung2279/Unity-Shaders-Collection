using System;
using UnityEngine;

namespace Game.Editor.VFXTools.EffectMeshGenerator
{
    public enum EffectMeshType
    {
        Slash,
        Ribbon,
        LightningRibbon,
        Arc,
        ArcRibbon,
        Plane,
        FlatRing,
        Sphere,
        Hemisphere,
        ZHemisphere,
        OpenCylinder,
        BeamDome,
        RisingSpiralRibbon,
        CylinderSpiralRibbon
    }

    [Serializable]
    public sealed class EffectMeshParameters
    {
        public int divisions = 12;
        public int widthDivisions = 2;
        public float thickness = 0.5f;
        public float length = 3f;
        public float curve = 0.8f;
        public float topCurve = 0.2f;
        public float taper = 0.35f;
        public float endTaper = 0.35f;
        public float spread;
        public float bottomSpread;
        public float twist;
        public bool waveEnabled;
        public float waveCount = 1f;
        public float waveCountX = 1f;
        public float waveHeight = 1f;
        public float waveHeightX;
        public float waveHeightZ;
        public float waveOffset;
        public int seed;
        public int seedX;
        public float yClip;
        public float cylinderScale = 1f;
        public int cylinderDivisions = 2;
        public bool beamEndCap;

        public bool vertexAlphaEnabled;
        [Range(0f, 1f)] public float topAlpha = 1f;
        [Range(0f, 1f)] public float bottomAlpha = 1f;
        [Range(0.001f, 1f)] public float topAlphaRange = 0.5f;
        [Range(0.001f, 1f)] public float bottomAlphaRange = 0.5f;

        public bool mirrorZ;
        public bool doubleSided;
        public bool crossMesh;
        public Vector3 pivot;
        public Vector3 scale = Vector3.one;
        public Vector3 rotation;
        public Vector2 textureTiling = Vector2.one;
        public float uvRotation;

        public EffectMeshParameters Clone()
        {
            return JsonUtility.FromJson<EffectMeshParameters>(JsonUtility.ToJson(this));
        }

        public void Sanitize()
        {
            divisions = Mathf.Clamp(divisions, 1, 256);
            widthDivisions = Mathf.Clamp(widthDivisions, 1, 128);
            cylinderDivisions = Mathf.Clamp(cylinderDivisions, 1, 128);
            thickness = Mathf.Max(0.001f, thickness);
            length = Mathf.Max(0.001f, length);
            taper = Mathf.Clamp01(taper);
            endTaper = Mathf.Clamp01(endTaper);
            topAlpha = Mathf.Clamp01(topAlpha);
            bottomAlpha = Mathf.Clamp01(bottomAlpha);
            topAlphaRange = Mathf.Clamp(topAlphaRange, 0.001f, 1f);
            bottomAlphaRange = Mathf.Clamp(bottomAlphaRange, 0.001f, 1f);
            yClip = Mathf.Clamp01(yClip);
            cylinderScale = Mathf.Clamp01(cylinderScale);
            scale.x = Mathf.Abs(scale.x) < 0.0001f ? 0.0001f : scale.x;
            scale.y = Mathf.Abs(scale.y) < 0.0001f ? 0.0001f : scale.y;
            scale.z = Mathf.Abs(scale.z) < 0.0001f ? 0.0001f : scale.z;
        }
    }

    public static class EffectMeshTemplates
    {
        public static EffectMeshParameters Get(EffectMeshType type)
        {
            var p = new EffectMeshParameters();
            switch (type)
            {
                case EffectMeshType.Ribbon:
                    Set(p, 24, 2, 0.35f, 4f, 0.8f, 0.2f, 0.15f, 0f, 0f, 1f);
                    break;
                case EffectMeshType.LightningRibbon:
                    Set(p, 24, 1, 0.22f, 5f, 0f, 0f, 0.75f, 0f, 0f, 5f);
                    p.waveHeightX = 0.7f;
                    p.waveHeightZ = 0.25f;
                    break;
                case EffectMeshType.RisingSpiralRibbon:
                    Set(p, 32, 2, 0.35f, 5f, 1.2f, 0.2f, 0.25f, 0.7f, 0.4f, 3f);
                    break;
                case EffectMeshType.CylinderSpiralRibbon:
                    Set(p, 32, 2, 0.35f, 5f, 1f, 0f, 0f, 0f, 0f, 3f);
                    break;
                case EffectMeshType.Arc:
                    Set(p, 12, 2, 0.8f, 1.5f, 1.1f, 0.3f, 0f, 0.1f, 0f, 1f);
                    p.mirrorZ = true;
                    break;
                case EffectMeshType.ArcRibbon:
                    Set(p, 12, 2, 0.2f, 1.5f, 1f, 0f, 0f, 0f, 0.5f, 1f);
                    break;
                case EffectMeshType.Plane:
                    Set(p, 1, 1, 2f, 2f, 0f, 0f, 0f, 0f, 0f, 1f);
                    break;
                case EffectMeshType.FlatRing:
                    Set(p, 32, 1, 0.5f, 3f, 0f, 0f, 0f, 0f, 0f, 1f);
                    break;
                case EffectMeshType.Sphere:
                    Set(p, 16, 4, 1f, 2f, 0f, 0f, 0f, 0f, 0f, 1f);
                    break;
                case EffectMeshType.Hemisphere:
                case EffectMeshType.ZHemisphere:
                    Set(p, 12, 4, 1f, 2f, 0f, 0f, 0f, 0f, 0f, 1f);
                    break;
                case EffectMeshType.OpenCylinder:
                    Set(p, 2, 12, 1f, 0.3f, 0f, 0f, 0f, 0.5f, 0f, 1f);
                    break;
                case EffectMeshType.BeamDome:
                    Set(p, 5, 8, 1f, 4f, 0f, 0f, 0f, 0f, 0f, 1f);
                    p.cylinderDivisions = 2;
                    break;
                default:
                    Set(p, 12, 2, 0.5f, 3f, 0.8f, 0.2f, 0.35f, 0f, 0f, 1f);
                    break;
            }

            p.endTaper = p.taper;
            return p;
        }

        private static void Set(EffectMeshParameters p, int divisions, int widthDivisions,
            float thickness, float length, float curve, float topCurve, float taper,
            float spread, float twist, float waveCount)
        {
            p.divisions = divisions;
            p.widthDivisions = widthDivisions;
            p.thickness = thickness;
            p.length = length;
            p.curve = curve;
            p.topCurve = topCurve;
            p.taper = taper;
            p.endTaper = taper;
            p.spread = spread;
            p.twist = twist;
            p.waveCount = waveCount;
        }
    }
}
