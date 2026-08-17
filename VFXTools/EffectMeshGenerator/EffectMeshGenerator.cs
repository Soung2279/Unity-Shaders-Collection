using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Game.Editor.VFXTools.EffectMeshGenerator
{
    public static class EffectMeshGenerator
    {
        private const float ArcVerticalOffset = 1.5f;
        private delegate Vector3 GridSampler(float u, float v, int i, int j, int surface);

        private sealed class MeshData
        {
            public readonly List<Vector3> vertices = new List<Vector3>();
            public readonly List<Vector2> uvs = new List<Vector2>();
            public readonly List<Color32> colors = new List<Color32>();
            public readonly List<int> triangles = new List<int>();
        }

        public static Mesh Generate(EffectMeshType type, EffectMeshParameters source)
        {
            var p = source.Clone();
            p.Sanitize();
            bool doubleSided = p.doubleSided;
            p.doubleSided = false;
            MeshData data = GenerateData(type, p, 1f);
            if (doubleSided)
            {
                MeshData back = GenerateData(type, p, -1f);
                data = CombineOppositeFacing(data, back);
            }

            ApplyOutputTransform(data, p);
            return ToMesh(type, data);
        }

        private static MeshData GenerateData(EffectMeshType type, EffectMeshParameters p, float liftDirection)
        {
            switch (type)
            {
                case EffectMeshType.Ribbon: return Ribbon(p, liftDirection);
                case EffectMeshType.LightningRibbon: return LightningRibbon(p, liftDirection);
                case EffectMeshType.RisingSpiralRibbon: return RisingSpiralRibbon(p, liftDirection);
                case EffectMeshType.CylinderSpiralRibbon: return CylinderSpiralRibbon(p, liftDirection);
                case EffectMeshType.Arc: return Arc(p, liftDirection);
                case EffectMeshType.ArcRibbon: return ArcRibbon(p, liftDirection);
                case EffectMeshType.Plane: return Plane(p, liftDirection);
                case EffectMeshType.FlatRing: return FlatRing(p, liftDirection);
                case EffectMeshType.Sphere: return Sphere(p, false, false);
                case EffectMeshType.Hemisphere: return Sphere(p, true, false);
                case EffectMeshType.ZHemisphere: return Sphere(p, false, true);
                case EffectMeshType.OpenCylinder: return OpenCylinder(p, liftDirection);
                case EffectMeshType.BeamDome: return BeamDome(p);
                default: return Slash(p, liftDirection);
            }
        }

        private static MeshData Slash(EffectMeshParameters p, float liftDirection)
        {
            int lengthSegments = p.divisions;
            int widthSegments = p.widthDivisions;
            float halfLength = p.length * 0.5f;
            float sideArcAngle = Mathf.Clamp01(p.curve * 0.5f) * Mathf.PI;
            float tubeAmount = Mathf.Clamp01(p.topCurve * 0.5f);
            var centers = new Vector3[lengthSegments + 1];
            for (int i = 0; i <= lengthSegments; i++)
            {
                float t = i / (float)lengthSegments;
                Vector2 arc = CenterlineArc(t, halfLength, sideArcAngle);
                centers[i] = new Vector3(0f, arc.x, arc.y);
            }

            int surfaces = p.crossMesh ? 2 : 1;
            return Grid(lengthSegments, widthSegments, surfaces, (uGrid, v, iGrid, j, surface) =>
            {
                int i = iGrid;
                float u = i / (float)lengthSegments;
                Vector3 tangent = PolylineTangent(centers, i);
                Vector3 width = Vector3.right;
                Vector3 normal = SurfaceNormal(tangent, width);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                Vector3 twistedWidth = twist * width;
                Vector3 twistedNormal = twist * normal;
                Vector3 surfaceWidth = surface == 0 ? twistedWidth : twistedNormal;
                Vector3 surfaceNormal = surface == 0 ? twistedNormal : SurfaceNormal(tangent, surfaceWidth);
                float currentThickness = p.thickness * TaperProfile(p, u) * (1f + Mathf.Max(0f, p.spread) * u);
                float tubeRadius = currentThickness * 0.5f;
                float tubeAngle = v * Mathf.PI;
                float flatWidthOffset = (1f - v * 2f) * tubeRadius;
                float tubeWidthOffset = Mathf.Cos(tubeAngle) * tubeRadius;
                float widthOffset = Mathf.Lerp(flatWidthOffset, tubeWidthOffset, tubeAmount);
                return centers[i] + surfaceWidth * widthOffset +
                       surfaceNormal * (Mathf.Sin(tubeAngle) * tubeRadius * tubeAmount * liftDirection);
            }, p);
        }

        private static MeshData Ribbon(EffectMeshParameters p, float liftDirection)
        {
            int ls = p.divisions;
            int ws = p.widthDivisions;
            float halfLength = p.length * 0.5f;
            float curveAmount = CurveAmount(p);
            float sideOffset = curveAmount * p.length * 0.3f;
            float liftAmount = TopCurveAmount(p);
            float waveCount = Mathf.Max(1f, p.waveCount);
            float phase = SeededPhase(p.seed);
            var centers = new Vector3[ls + 1];
            for (int i = 0; i <= ls; i++)
            {
                float u = i / (float)ls;
                float amplitude = 1f + Mathf.Max(0f, p.spread) * u;
                centers[i] = new Vector3(
                    Mathf.Sin((u - 0.5f) * Mathf.PI * waveCount + phase) * sideOffset * amplitude,
                    Mathf.Lerp(-halfLength, halfLength, u), 0f);
            }
            return RibbonGrid(p, centers, liftAmount * liftDirection, false);
        }

        private static MeshData LightningRibbon(EffectMeshParameters p, float liftDirection)
        {
            int ls = p.divisions;
            int bends = Mathf.Max(2, Mathf.RoundToInt(p.waveCount * 2f));
            float halfLength = p.length * 0.5f;
            float centerArcAngle = (p.waveHeightX == 0f ? 0f : CurveAmount(p)) * Mathf.PI;
            float sideAmplitude = p.length * 0.22f * Mathf.Max(0f, p.waveHeightX);
            float depthAmplitude = p.length * 0.08f * Mathf.Max(0f, p.waveHeightZ);
            float waveOffset = Repeat01(p.waveOffset);
            var offsets = new Vector2[bends];
            for (int i = 0; i < bends; i++)
                offsets[i] = new Vector2(SignedNoise(i, 19.73f, p.seed) * sideAmplitude,
                    SignedNoise(i, 47.11f, p.seed) * depthAmplitude);
            var anchors = new Vector3[bends + 1];
            for (int i = 0; i <= bends; i++)
            {
                float u = i / (float)bends;
                float index = Repeat01(u - waveOffset) * bends;
                int i0 = Mathf.FloorToInt(index) % bends;
                int i1 = (i0 + 1) % bends;
                Vector2 offset = Vector2.Lerp(offsets[i0], offsets[i1], index - Mathf.Floor(index));
                Vector2 arc = CenterlineArc(u, halfLength, centerArcAngle);
                float fade = Mathf.Sin(Mathf.PI * u);
                anchors[i] = new Vector3(offset.x * fade, arc.x, offset.y * fade + arc.y);
            }
            var centers = new Vector3[ls + 1];
            for (int i = 0; i <= ls; i++)
            {
                float scaled = i / (float)ls * bends;
                int index = Mathf.Min(Mathf.FloorToInt(scaled), bends - 1);
                centers[i] = Vector3.Lerp(anchors[index], anchors[index + 1], scaled - index);
            }
            return RibbonGrid(p, centers, TopCurveAmount(p) * liftDirection, true);
        }

        private static MeshData RibbonGrid(EffectMeshParameters p, Vector3[] centers, float liftAmount, bool spreadWidth)
        {
            int ls = centers.Length - 1;
            int surfaces = p.crossMesh ? 2 : 1;
            return Grid(ls, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                Vector3 tangent = PolylineTangent(centers, i);
                Vector3 side = PlanarSide(tangent);
                Vector3 normal = SurfaceNormal(tangent, side);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                side = twist * side;
                normal = twist * normal;
                Vector3 surfaceSide = surface == 0 ? side : normal;
                Vector3 surfaceNormal = surface == 0 ? normal : SurfaceNormal(tangent, surfaceSide);
                float topProfile = u * u * (3f - 2f * u);
                float bottomU = 1f - u;
                float bottomProfile = bottomU * bottomU * (3f - 2f * bottomU);
                float extra = spreadWidth
                    ? p.thickness * (Mathf.Max(0f, p.spread) * topProfile +
                                     Mathf.Max(0f, p.bottomSpread) * bottomProfile)
                    : 0f;
                float width = TaperedWidth(p, u) + extra;
                return centers[i] + surfaceSide * ((v - 0.5f) * width) +
                       surfaceNormal * (Mathf.Sin(Mathf.PI * v) * width * 0.5f * liftAmount);
            }, p);
        }

        private static MeshData RisingSpiralRibbon(EffectMeshParameters p, float liftDirection)
        {
            int lengthSegments = p.divisions;
            float halfHeight = p.length * 0.5f;
            float curveAmount = CurveAmount(p);
            float liftAmount = TopCurveAmount(p) * liftDirection;
            float spreadAmount = Mathf.Max(0f, p.spread);
            float bottomSpreadAmount = Mathf.Max(0f, p.bottomSpread);
            float turns = Mathf.Max(0.25f, p.waveCount) * Mathf.Lerp(0.5f, 1.5f, curveAmount);
            float baseRadius = Mathf.Max(p.thickness * 0.2f, p.length * 0.025f, 0.001f);
            float bottomRadius = baseRadius * (1f + bottomSpreadAmount * 10f);
            float topRadius = baseRadius + p.length * Mathf.Lerp(0.08f, 0.28f, curveAmount) * (1f + spreadAmount);
            var centers = new Vector3[lengthSegments + 1];
            for (int i = 0; i <= lengthSegments; i++)
            {
                float u = i / (float)lengthSegments;
                float angle = u * Mathf.PI * 2f * turns;
                float radius = Mathf.Lerp(bottomRadius, topRadius, u);
                centers[i] = new Vector3(Mathf.Cos(angle) * radius, Mathf.Lerp(-halfHeight, halfHeight, u),
                    Mathf.Sin(angle) * radius);
            }

            int surfaces = p.crossMesh ? 2 : 1;
            return Grid(lengthSegments, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                Vector3 tangent = PolylineTangent(centers, i);
                Vector3 radial = HorizontalRadial(centers[i]);
                Vector3 side = SurfaceSide(tangent, radial);
                Vector3 normal = SurfaceNormal(tangent, side);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                side = twist * side;
                normal = twist * normal;
                Vector3 surfaceSide = surface == 0 ? side : normal;
                Vector3 surfaceNormal = surface == 0 ? normal : SurfaceNormal(tangent, surfaceSide);
                float width = TaperedWidth(p, u);
                return centers[i] + surfaceSide * ((v - 0.5f) * width) +
                       surfaceNormal * (Mathf.Sin(Mathf.PI * v) * width * 0.5f * liftAmount);
            }, p);
        }

        private static MeshData CylinderSpiralRibbon(EffectMeshParameters p, float liftDirection)
        {
            int lengthSegments = p.divisions;
            float halfHeight = p.length * 0.5f;
            float curveAmount = CurveAmount(p);
            float liftAmount = TopCurveAmount(p) * liftDirection;
            float spreadAmount = Mathf.Max(0f, p.spread);
            float bottomSpreadAmount = Mathf.Max(0f, p.bottomSpread);
            float turns = Mathf.Max(0.25f, p.waveCount);
            float baseRadius = Mathf.Max(p.length * Mathf.Lerp(0.08f, 0.24f, curveAmount),
                p.thickness * 0.75f, 0.001f);
            var centers = new Vector3[lengthSegments + 1];
            for (int i = 0; i <= lengthSegments; i++)
            {
                float u = i / (float)lengthSegments;
                float angle = u * Mathf.PI * 2f * turns;
                float radius = baseRadius * (1f + bottomSpreadAmount * (1f - u) + spreadAmount * u);
                centers[i] = new Vector3(Mathf.Cos(angle) * radius, Mathf.Lerp(-halfHeight, halfHeight, u),
                    Mathf.Sin(angle) * radius);
            }

            int surfaces = p.crossMesh ? 2 : 1;
            return Grid(lengthSegments, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                Vector3 tangent = PolylineTangent(centers, i);
                Vector3 radial = HorizontalRadial(centers[i]);
                Vector3 normal = SurfaceSide(tangent, radial);
                Vector3 side = SideForSurfaceNormal(tangent, normal);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                side = twist * side;
                normal = twist * normal;
                Vector3 surfaceSide = surface == 0 ? side : normal;
                Vector3 surfaceNormal = surface == 0 ? normal : SurfaceNormal(tangent, surfaceSide);
                float width = TaperedWidth(p, u);
                float sideOffset = (surface == 1 ? 0.5f - v : v - 0.5f) * width;
                return centers[i] + surfaceSide * sideOffset +
                       surfaceNormal * (Mathf.Sin(Mathf.PI * v) * width * 0.5f * liftAmount);
            }, p);
        }

        private static MeshData Arc(EffectMeshParameters p, float liftDirection)
        {
            int surfaces = p.crossMesh ? 2 : 1;
            float curve = CurveAmount(p);
            float lift = TopCurveAmount(p);
            float spread = Mathf.Max(0f, p.spread);
            if (curve <= 0.0001f)
            {
                float half = p.length * 0.5f;
                return Grid(p.divisions, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
                {
                    float width = TaperedWidth(p, u);
                    float side = (v - 0.5f) * width;
                    float normal = (Mathf.Sin(Mathf.PI * v) * width * 0.5f * lift + (1f - v) * width * spread) * liftDirection;
                    Vector3 vertex = surface == 1
                        ? new Vector3(Mathf.Lerp(-half, half, u), ArcVerticalOffset + normal, side)
                        : new Vector3(Mathf.Lerp(-half, half, u), side + ArcVerticalOffset, normal);
                    Vector3 center = new Vector3(Mathf.Lerp(-half, half, u), ArcVerticalOffset, 0f);
                    Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, Vector3.right);
                    return center + twist * (vertex - center);
                }, p);
            }
            float angleTotal = curve * Mathf.PI * 2f;
            float outer = Mathf.Max(p.length / angleTotal + 1f, p.thickness, 0.001f);
            float fill = Mathf.Clamp01((p.thickness - 0.1f) / 1.9f);
            float centerTaper = 1f - Mathf.Max(p.taper, p.endTaper) * 0.5f;
            return Grid(p.divisions, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                float angle = Mathf.Lerp(-angleTotal * 0.5f, angleTotal * 0.5f, u);
                Vector3 radial = new Vector3(Mathf.Sin(angle), Mathf.Cos(angle), 0f);
                float width = TaperedWidth(p, u);
                float taperProfile = TaperProfile(p, u) * centerTaper;
                float radialWidth = Mathf.Lerp(width, outer, fill) * taperProfile;
                float radius = Mathf.Max(0f, outer - (1f - v) * radialWidth);
                float center = Mathf.Max(0f, outer - radialWidth * 0.5f);
                float side = (0.5f - v) * radialWidth;
                float normal = (Mathf.Sin(Mathf.PI * v) * width * 0.5f * lift +
                               (1f - v) * width * spread * taperProfile) * liftDirection;
                Vector3 vertex;
                if (surface == 1)
                {
                    vertex = radial * (center + normal);
                    vertex.z = -side;
                }
                else
                {
                    vertex = radial * radius;
                    vertex.z = normal;
                }
                vertex.y += ArcVerticalOffset - outer;
                Vector3 centerVertex = radial * center;
                centerVertex.y += ArcVerticalOffset - outer;
                Vector3 tangent = new Vector3(Mathf.Cos(angle), -Mathf.Sin(angle), 0f);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                return centerVertex + twist * (vertex - centerVertex);
            }, p);
        }

        private static MeshData ArcRibbon(EffectMeshParameters p, float liftDirection)
        {
            int surfaces = p.crossMesh ? 2 : 1;
            float curve = CurveAmount(p);
            float totalAngle = curve * Mathf.PI * 2f;
            float outer = curve <= 0.0001f ? 0f : Mathf.Max(p.length / totalAngle + 1f, p.thickness, 0.001f);
            float fill = Mathf.Clamp01((p.thickness - 0.1f) / 1.9f);
            return Grid(p.divisions, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                Vector3 center;
                Vector3 tangent;
                Vector3 side;
                float sideOffset;
                if (curve <= 0.0001f)
                {
                    center = new Vector3(Mathf.Lerp(-p.length * 0.5f, p.length * 0.5f, u), ArcVerticalOffset, 0f);
                    tangent = Vector3.right;
                    side = Vector3.up;
                    sideOffset = (v - 0.5f) * TaperedWidth(p, u);
                }
                else
                {
                    float angle = Mathf.Lerp(-totalAngle * 0.5f, totalAngle * 0.5f, u);
                    Vector3 radial = new Vector3(Mathf.Sin(angle), Mathf.Cos(angle), 0f);
                    tangent = new Vector3(Mathf.Cos(angle), -Mathf.Sin(angle), 0f);
                    float radialWidth = Mathf.Lerp(TaperedWidth(p, u), outer, fill) *
                                        TaperProfile(p, u) * (1f - Mathf.Max(p.taper, p.endTaper) * 0.5f);
                    center = radial * Mathf.Max(0f, outer - radialWidth * 0.5f);
                    center.y += ArcVerticalOffset - outer;
                    side = radial;
                    sideOffset = (v - 0.5f) * radialWidth;
                }
                Vector3 normal = Vector3.forward;
                Quaternion q = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, tangent);
                side = q * side;
                normal = q * normal;
                Vector3 surfaceSide = surface == 0 ? side : normal;
                Vector3 surfaceNormal = surface == 0 ? normal : SurfaceNormal(tangent, surfaceSide);
                float width = TaperedWidth(p, u);
                float normalOffset = (Mathf.Sin(Mathf.PI * v) * width * 0.5f * TopCurveAmount(p) +
                                     (1f - v) * width * Mathf.Max(0f, p.spread)) * liftDirection;
                return center + surfaceSide * sideOffset + surfaceNormal * normalOffset;
            }, p);
        }

        private static MeshData Plane(EffectMeshParameters p, float liftDirection)
        {
            int surfaces = p.crossMesh ? 2 : 1;
            return Grid(p.divisions, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                float width = TaperedWidth(p, u);
                float side = (0.5f - v) * width;
                float normal = Mathf.Sin(Mathf.PI * v) * width * 0.5f * TopCurveAmount(p) * liftDirection;
                float y = Mathf.Lerp(-p.length * 0.5f, p.length * 0.5f, u);
                Vector3 offset = surface == 1 ? new Vector3(normal, 0f, side) : new Vector3(side, 0f, normal);
                Quaternion twist = Quaternion.AngleAxis((u - 0.5f) * 180f * p.twist, Vector3.up);
                return new Vector3(0f, y, 0f) + twist * offset;
            }, p);
        }

        private static MeshData FlatRing(EffectMeshParameters p, float liftDirection)
        {
            int rs = Mathf.Max(3, p.divisions);
            int surfaces = p.crossMesh ? 2 : 1;
            float outer = Mathf.Max(p.length * 0.5f, p.thickness, 0.001f);
            float inner = Mathf.Max(outer - p.thickness, 0.001f);
            float center = (outer + inner) * 0.5f;
            return Grid(rs, p.widthDivisions, surfaces, (u, v, i, j, surface) =>
            {
                float angle = u * Mathf.PI * 2f + p.twist * Mathf.PI * v;
                Vector3 radial = new Vector3(Mathf.Cos(angle), Mathf.Sin(angle), 0f);
                float radius = Mathf.Lerp(outer, inner, v);
                float z = (Mathf.Sin(Mathf.PI * v) * p.thickness * 0.5f * TopCurveAmount(p) +
                          v * p.thickness * Mathf.Max(0f, p.spread)) * liftDirection;
                return surface == 1 ? new Vector3(radial.x * (center + z), radial.y * (center + z), (0.5f - v) * p.thickness)
                    : radial * radius + Vector3.forward * z;
            }, p);
        }

        private static MeshData Sphere(EffectMeshParameters p, bool hemisphere, bool zHemisphere)
        {
            int lat = Mathf.Max(3, p.divisions);
            int lon = Mathf.Max(8, p.widthDivisions * 4);
            float radius = Mathf.Max(p.length * 0.5f, p.thickness * 0.5f, 0.001f);
            float maxTheta = hemisphere ? Mathf.PI * 0.5f : Mathf.Lerp(Mathf.PI, 0.001f, p.yClip);
            var data = Grid(lat, lon, 1, (u, v, i, j, surface) =>
            {
                float theta = u * maxTheta;
                float phi = zHemisphere ? -Mathf.PI - v * Mathf.PI : -v * Mathf.PI * 2f + (1f - u) * p.twist * Mathf.PI;
                float sin = Mathf.Sin(theta);
                return new Vector3(Mathf.Cos(phi) * sin * radius, Mathf.Cos(theta) * radius,
                    Mathf.Sin(phi) * sin * radius);
            }, p);
            RotateUvs180(data);
            return data;
        }

        private static MeshData OpenCylinder(EffectMeshParameters p, float liftDirection)
        {
            int hs = Mathf.Max(1, p.divisions);
            int rs = Mathf.Max(8, p.widthDivisions * 4);
            float halfHeight = p.length;
            float radius = Mathf.Max(p.thickness, 0.001f);
            return Grid(hs, rs, 1, (u, v, i, j, surface) =>
            {
                float phi = v * Mathf.PI * 2f + u * p.twist * Mathf.PI;
                float wave = p.waveCount <= 1f ? 0f : Mathf.Sin(Mathf.PI * 2f * p.waveCount * u - Mathf.PI * 0.5f + SeededPhase(p.seed)) * radius * 0.16f * Mathf.Max(0f, p.waveHeight);
                float verticalScale = Mathf.Lerp(1f + Mathf.Max(0f, p.bottomSpread), 1f + Mathf.Max(0f, p.spread), u);
                float radiusScale = 1f + (Mathf.Clamp(p.curve * 0.5f, -1f, 1f) + TopCurveAmount(p) * liftDirection) * Mathf.Sin(Mathf.PI * u) * 2f;
                float current = Mathf.Max(radius * verticalScale * radiusScale + wave, 0.001f);
                return new Vector3(Mathf.Cos(phi) * current, Mathf.Lerp(-halfHeight, halfHeight, u), Mathf.Sin(phi) * current);
            }, p);
        }

        private static MeshData BeamDome(EffectMeshParameters p)
        {
            int cap = Mathf.Max(1, p.divisions);
            int cylinder = Mathf.Max(1, p.cylinderDivisions);
            int radial = Mathf.Max(8, p.widthDivisions * 4);
            float radius = Mathf.Max(p.thickness * 0.5f, 0.001f);
            float baseHeight = Mathf.Max(p.length - radius, radius * 0.1f);
            float cylinderHeight = baseHeight * p.cylinderScale;
            float capBaseY = (baseHeight - radius) * 0.5f;
            float bottomY = capBaseY - cylinderHeight;
            float totalUvLength = baseHeight + radius * (p.beamEndCap ? 2f : 1f);
            float rearCapRatio = p.beamEndCap ? radius / totalUvLength : 0f;
            float frontCapStartRatio = (baseHeight + (p.beamEndCap ? radius : 0f)) / totalUvLength;
            var rows = new List<float>();
            if (p.beamEndCap)
            {
                for (int i = 0; i <= cap; i++) rows.Add(rearCapRatio * i / cap);
                for (int i = 1; i <= cylinder; i++) rows.Add(rearCapRatio + (frontCapStartRatio - rearCapRatio) * i / cylinder);
            }
            else
            {
                for (int i = 0; i <= cylinder; i++) rows.Add(frontCapStartRatio * i / cylinder);
            }
            for (int i = 1; i <= cap; i++) rows.Add(frontCapStartRatio + (1f - frontCapStartRatio) * i / cap);
            float capTipY = capBaseY + radius;
            return GridRows(rows, radial, 1, (u, v, i, j, surface) =>
            {
                float waveProfile = Mathf.Sin(Mathf.PI * u);
                float waveScale = Mathf.Max(radius, p.length * 0.08f) * waveProfile;
                float waveX = p.waveEnabled ? Mathf.Sin(Mathf.PI * 2f * Mathf.Max(1f, p.waveCountX) * u + SeededPhase(p.seedX)) * waveScale * Mathf.Max(0f, p.waveHeightX) : 0f;
                float waveY = p.waveEnabled ? Mathf.Sin(Mathf.PI * 2f * Mathf.Max(1f, p.waveCount) * u + SeededPhase(p.seed)) * waveScale * Mathf.Max(0f, p.waveHeight) : 0f;
                float currentRadius = radius * (1f + Mathf.Max(0f, p.spread) * Mathf.Pow(1f - u, 2f) + TopCurveAmount(p) * Mathf.Sin(Mathf.PI * u) * 2f);
                float y;
                if (p.beamEndCap && u < rearCapRatio)
                {
                    float angle = (1f - u / Mathf.Max(rearCapRatio, 0.0001f)) * Mathf.PI * 0.5f;
                    currentRadius *= Mathf.Cos(angle);
                    y = bottomY - Mathf.Sin(angle) * radius;
                }
                else if (u > frontCapStartRatio)
                {
                    float angle = (u - frontCapStartRatio) / Mathf.Max(1f - frontCapStartRatio, 0.0001f) * Mathf.PI * 0.5f;
                    currentRadius *= Mathf.Cos(angle);
                    y = capBaseY + Mathf.Sin(angle) * radius;
                }
                else
                {
                    float cylinderU = p.beamEndCap
                        ? (u - rearCapRatio) / Mathf.Max(frontCapStartRatio - rearCapRatio, 0.0001f)
                        : u / Mathf.Max(frontCapStartRatio, 0.0001f);
                    y = Mathf.Lerp(bottomY, capBaseY, Mathf.Clamp01(cylinderU));
                }
                currentRadius = Mathf.Max(currentRadius, 0.001f);
                Vector3 vertex = new Vector3(Mathf.Cos(v * Mathf.PI * 2f) * currentRadius,
                    y - capTipY, Mathf.Sin(v * Mathf.PI * 2f) * currentRadius);
                vertex = Quaternion.AngleAxis(-90f, Vector3.right) * vertex;
                vertex = Quaternion.AngleAxis((1f - u) * p.twist * 180f, Vector3.forward) * vertex;
                vertex.x += waveX;
                vertex.y += waveY;
                return vertex;
            }, p);
        }

        private static MeshData Grid(int lengthSegments, int widthSegments, int surfaces, GridSampler sample,
            EffectMeshParameters p)
        {
            var rows = new List<float>(lengthSegments + 1);
            for (int i = 0; i <= lengthSegments; i++) rows.Add(i / (float)lengthSegments);
            return GridRows(rows, widthSegments, surfaces, sample, p);
        }

        private static MeshData GridRows(IReadOnlyList<float> rows, int widthSegments, int surfaces,
            GridSampler sample, EffectMeshParameters p)
        {
            var data = new MeshData();
            int lengthSegments = rows.Count - 1;
            int row = widthSegments + 1;
            int surfaceStride = row * (lengthSegments + 1);
            for (int s = 0; s < surfaces; s++)
            for (int i = 0; i <= lengthSegments; i++)
            {
                int rowIndex = s == 0 ? i : lengthSegments - i;
                float u = rows[rowIndex];
                float uvU = rows[i];
                for (int j = 0; j <= widthSegments; j++)
                {
                    float v = j / (float)widthSegments;
                    data.vertices.Add(sample(u, v, rowIndex, j, s));
                    data.uvs.Add(s == 0 ? new Vector2(uvU, 1f - v) : new Vector2(1f - uvU, v));
                    data.colors.Add(new Color32(255, 255, 255, Alpha(p, u)));
                }
            }
            for (int s = 0; s < surfaces; s++)
            {
                int offset = s * surfaceStride;
                for (int i = 0; i < lengthSegments; i++)
                for (int j = 0; j < widthSegments; j++)
                {
                    int a = offset + i * row + j;
                    int b = a + 1;
                    int c = offset + (i + 1) * row + j;
                    int d = c + 1;
                    data.triangles.Add(a); data.triangles.Add(c); data.triangles.Add(b);
                    data.triangles.Add(b); data.triangles.Add(c); data.triangles.Add(d);
                }
            }
            return data;
        }

        private static byte Alpha(EffectMeshParameters p, float u)
        {
            if (!p.vertexAlphaEnabled) return 255;
            float bottomBlend = Mathf.Clamp01(u / p.bottomAlphaRange);
            float topBlend = Mathf.Clamp01((1f - u) / p.topAlphaRange);
            float alpha = Mathf.Min(Mathf.Lerp(p.bottomAlpha, 1f, bottomBlend), Mathf.Lerp(p.topAlpha, 1f, topBlend));
            return (byte)Mathf.RoundToInt(Mathf.Clamp01(alpha) * 255f);
        }

        private static MeshData CombineOppositeFacing(MeshData front, MeshData back)
        {
            var combined = new MeshData();
            combined.vertices.AddRange(front.vertices);
            combined.uvs.AddRange(front.uvs);
            combined.colors.AddRange(front.colors);
            combined.triangles.AddRange(front.triangles);
            int vertexOffset = combined.vertices.Count;
            combined.vertices.AddRange(back.vertices);
            combined.uvs.AddRange(back.uvs);
            combined.colors.AddRange(back.colors);
            for (int i = 0; i < back.triangles.Count; i += 3)
            {
                combined.triangles.Add(back.triangles[i] + vertexOffset);
                combined.triangles.Add(back.triangles[i + 2] + vertexOffset);
                combined.triangles.Add(back.triangles[i + 1] + vertexOffset);
            }
            return combined;
        }

        private static void ApplyOutputTransform(MeshData data, EffectMeshParameters p)
        {
            Quaternion rotation = Quaternion.Euler(p.rotation);
            float radians = p.uvRotation * Mathf.Deg2Rad;
            float cos = Mathf.Cos(radians);
            float sin = Mathf.Sin(radians);
            for (int i = 0; i < data.vertices.Count; i++)
            {
                Vector3 v = data.vertices[i];
                if (p.mirrorZ) v.z = -v.z;
                v = Vector3.Scale(v - p.pivot, p.scale);
                data.vertices[i] = rotation * v;
                Vector2 uv = data.uvs[i] - Vector2.one * 0.5f;
                uv = new Vector2(uv.x * cos - uv.y * sin, uv.x * sin + uv.y * cos);
                data.uvs[i] = uv + Vector2.one * 0.5f;
            }
            if (p.mirrorZ)
                ReverseWinding(data.triangles);
        }

        private static Mesh ToMesh(EffectMeshType type, MeshData data)
        {
            var mesh = new Mesh { name = "VFX_" + type };
            if (data.vertices.Count > 65535) mesh.indexFormat = IndexFormat.UInt32;
            mesh.SetVertices(data.vertices);
            mesh.SetUVs(0, data.uvs);
            mesh.SetColors(data.colors);
            mesh.SetTriangles(data.triangles, 0, true);
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
            mesh.RecalculateBounds();
            return mesh;
        }

        private static void ReverseWinding(List<int> indices)
        {
            for (int i = 0; i < indices.Count; i += 3)
                (indices[i + 1], indices[i + 2]) = (indices[i + 2], indices[i + 1]);
        }

        private static void RotateUvs180(MeshData data)
        {
            for (int i = 0; i < data.uvs.Count; i++) data.uvs[i] = Vector2.one - data.uvs[i];
        }

        private static float CurveAmount(EffectMeshParameters p) => Mathf.Clamp01(p.curve * 0.5f);
        private static float TopCurveAmount(EffectMeshParameters p) => Mathf.Clamp01(p.topCurve * 0.5f);
        private static float TaperedWidth(EffectMeshParameters p, float u) => p.thickness * TaperProfile(p, u);
        private static float TaperProfile(EffectMeshParameters p, float u)
        {
            float start = Mathf.Sin(Mathf.Clamp01(u * 2f) * Mathf.PI * 0.5f);
            float end = Mathf.Sin(Mathf.Clamp01((1f - u) * 2f) * Mathf.PI * 0.5f);
            return Mathf.Max(0.001f, Mathf.Min(Mathf.Lerp(1f - p.taper, 1f, start), Mathf.Lerp(1f - p.endTaper, 1f, end)));
        }
        private static Vector2 CenterlineArc(float u, float halfLength, float angle)
        {
            if (angle <= 0.0001f) return new Vector2(Mathf.Lerp(-halfLength, halfLength, u), 0f);
            float half = angle * 0.5f;
            float radius = halfLength / Mathf.Sin(half);
            float current = Mathf.Lerp(-half, half, u);
            return new Vector2(radius * Mathf.Sin(current), radius * Mathf.Cos(current) - radius * Mathf.Cos(half));
        }
        private static Vector3 PolylineTangent(Vector3[] points, int i)
        {
            Vector3 tangent = points[Mathf.Min(i + 1, points.Length - 1)] - points[Mathf.Max(i - 1, 0)];
            return tangent.sqrMagnitude < 0.000001f ? Vector3.up : tangent.normalized;
        }
        private static Vector3 PlanarSide(Vector3 tangent)
        {
            Vector3 side = new Vector3(-tangent.y, tangent.x, 0f);
            return side.sqrMagnitude < 0.000001f ? Vector3.right : side.normalized;
        }
        private static Vector3 HorizontalRadial(Vector3 point)
        {
            Vector3 radial = new Vector3(point.x, 0f, point.z);
            return radial.sqrMagnitude < 0.000001f ? Vector3.right : radial.normalized;
        }
        private static Vector3 SurfaceSide(Vector3 tangent, Vector3 preferred)
        {
            Vector3 side = preferred - tangent * Vector3.Dot(preferred, tangent);
            return side.sqrMagnitude < 0.000001f ? PlanarSide(tangent) : side.normalized;
        }
        private static Vector3 SideForSurfaceNormal(Vector3 tangent, Vector3 surfaceNormal)
        {
            Vector3 side = Vector3.Cross(surfaceNormal, tangent);
            return side.sqrMagnitude < 0.000001f ? PlanarSide(tangent) : side.normalized;
        }
        private static Vector3 SurfaceNormal(Vector3 tangent, Vector3 side)
        {
            Vector3 normal = Vector3.Cross(tangent, side);
            return normal.sqrMagnitude < 0.000001f ? Vector3.forward : normal.normalized;
        }
        private static float SignedNoise(int index, float channel, int seed)
        {
            float value = Mathf.Sin((index + 1) * channel + seed * 12.9898f) * 43758.5453123f;
            return (value - Mathf.Floor(value)) * 2f - 1f;
        }
        private static float SeededPhase(int seed) => Mathf.Floor(seed) * 0.17320508075688773f;
        private static float Repeat01(float value) => value - Mathf.Floor(value);
    }
}
