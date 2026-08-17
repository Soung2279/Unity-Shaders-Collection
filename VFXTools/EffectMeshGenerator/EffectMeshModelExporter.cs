using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;
using UnityEngine;

namespace Game.Editor.VFXTools.EffectMeshGenerator
{
    /// <summary>OBJ plus automatic official/fallback FBX export for generated effect meshes.</summary>
    public static class EffectMeshModelExporter
    {
        public enum FbxBackend
        {
            BuiltInAscii,
            UnityFbxExporter
        }

        private const string FbxExporterTypeName =
            "UnityEditor.Formats.Fbx.Exporter.ModelExporter, Unity.Formats.Fbx.Editor";
        private static readonly CultureInfo Invariant = CultureInfo.InvariantCulture;

        public static bool HasUnityFbxExporter => Type.GetType(FbxExporterTypeName, false) != null;
        public static FbxBackend ActiveFbxBackend => HasUnityFbxExporter ? FbxBackend.UnityFbxExporter : FbxBackend.BuiltInAscii;

        public static void ExportObj(Mesh mesh, string path)
        {
            Validate(mesh, path);
            Vector3[] vertices = mesh.vertices;
            Vector3[] normals = GetNormals(mesh);
            Vector2[] uvs = GetUvs(mesh);
            Color32[] colors = GetColors(mesh);
            int[] triangles = mesh.triangles;
            var text = new StringBuilder(Mathf.Max(1024, vertices.Length * 96));

            text.AppendLine("# Effect Mesh Generator OBJ");
            text.Append("o ").AppendLine(SanitizeName(mesh.name));
            for (int i = 0; i < vertices.Length; i++)
            {
                Vector3 v = ConvertPosition(vertices[i]);
                Color32 c = colors[i];
                text.Append("v ").Append(F(v.x)).Append(' ').Append(F(v.y)).Append(' ').Append(F(v.z))
                    .Append(' ').Append(F(c.r / 255f)).Append(' ').Append(F(c.g / 255f)).Append(' ')
                    .Append(F(c.b / 255f)).Append(' ').Append(F(c.a / 255f)).AppendLine();
            }
            for (int i = 0; i < uvs.Length; i++)
                text.Append("vt ").Append(F(uvs[i].x)).Append(' ').Append(F(uvs[i].y)).AppendLine();
            for (int i = 0; i < normals.Length; i++)
            {
                Vector3 n = ConvertNormal(normals[i]);
                text.Append("vn ").Append(F(n.x)).Append(' ').Append(F(n.y)).Append(' ').Append(F(n.z)).AppendLine();
            }

            text.AppendLine("s 1");
            for (int i = 0; i < triangles.Length; i += 3)
            {
                // Mirroring X changes handedness; reverse the polygon to preserve the visible front face.
                AppendObjCorner(text, triangles[i] + 1);
                AppendObjCorner(text, triangles[i + 2] + 1);
                AppendObjCorner(text, triangles[i + 1] + 1);
                text.AppendLine();
            }
            WriteAllText(path, text.ToString());
        }

        public static FbxBackend ExportFbx(Mesh mesh, string path)
        {
            Validate(mesh, path);
            if (!HasUnityFbxExporter)
            {
                ExportFbxAscii(mesh, path);
                return FbxBackend.BuiltInAscii;
            }

            ExportFbxWithUnityPackage(mesh, path);
            return FbxBackend.UnityFbxExporter;
        }

        private static void ExportFbxWithUnityPackage(Mesh mesh, string path)
        {
            Type exporterType = Type.GetType(FbxExporterTypeName, true);
            MethodInfo exportMethod = exporterType.GetMethod("ExportObject", BindingFlags.Public | BindingFlags.Static,
                null, new[] { typeof(string), typeof(UnityEngine.Object) }, null);
            if (exportMethod == null) throw new MissingMethodException(exporterType.FullName, "ExportObject(string, Object)");

            var root = new GameObject(SanitizeName(mesh.name), typeof(MeshFilter), typeof(MeshRenderer))
            {
                hideFlags = HideFlags.HideAndDontSave
            };
            root.GetComponent<MeshFilter>().sharedMesh = mesh;
            try
            {
                string exportedPath = exportMethod.Invoke(null, new object[] { path, root }) as string;
                if (string.IsNullOrEmpty(exportedPath) || !File.Exists(path))
                    throw new IOException("Unity FBX Exporter did not create the requested file.");
            }
            finally
            {
                UnityEngine.Object.DestroyImmediate(root);
            }
        }

        private static void ExportFbxAscii(Mesh mesh, string path)
        {
            Vector3[] vertices = mesh.vertices;
            Vector3[] normals = GetNormals(mesh);
            Vector2[] uvs = GetUvs(mesh);
            Color32[] colors = GetColors(mesh);
            int[] triangles = mesh.triangles;
            string name = SanitizeName(mesh.name);
            long seed = (DateTime.UtcNow.Ticks & 0x0000FFFFFFFFFFFFL) / 16L * 16L;
            long geometryId = seed;
            long modelId = seed + 1;
            long documentId = seed + 2;
            long materialId = seed + 3;
            var text = new StringBuilder(Mathf.Max(4096, vertices.Length * 180));

            text.AppendLine("; FBX 7.4.0 project file");
            text.AppendLine("; Created by Unity Effect Mesh Generator built-in exporter");
            text.AppendLine("FBXHeaderExtension:  {");
            text.AppendLine("\tFBXHeaderVersion: 1003");
            text.AppendLine("\tFBXVersion: 7400");
            text.AppendLine("\tCreator: \"Unity Effect Mesh Generator\"");
            text.AppendLine("\tSceneInfo: \"SceneInfo::GlobalInfo\", \"UserData\" {");
            text.AppendLine("\t\tType: \"UserData\"");
            text.AppendLine("\t\tVersion: 100");
            text.AppendLine("\t\tMetaData:  {");
            text.AppendLine("\t\t\tVersion: 100");
            text.AppendLine("\t\t\tTitle: \"Effect Mesh Generator\"");
            text.AppendLine("\t\t\tSubject: \"\"");
            text.AppendLine("\t\t\tAuthor: \"Unity\"");
            text.AppendLine("\t\t\tKeywords: \"VFX Mesh\"");
            text.AppendLine("\t\t\tRevision: \"1.0\"");
            text.AppendLine("\t\t\tComment: \"\"");
            text.AppendLine("\t\t}");
            text.AppendLine("\t\tProperties70:  {");
            text.AppendLine("\t\t\tP: \"DocumentUrl\", \"KString\", \"Url\", \"\", \"\"");
            text.AppendLine("\t\t\tP: \"SrcDocumentUrl\", \"KString\", \"Url\", \"\", \"\"");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.AppendLine("}");
            text.AppendLine("GlobalSettings:  {");
            text.AppendLine("\tVersion: 1000");
            text.AppendLine("\tProperties70:  {");
            text.AppendLine("\t\tP: \"UpAxis\", \"int\", \"Integer\", \"\",1");
            text.AppendLine("\t\tP: \"UpAxisSign\", \"int\", \"Integer\", \"\",1");
            text.AppendLine("\t\tP: \"FrontAxis\", \"int\", \"Integer\", \"\",2");
            text.AppendLine("\t\tP: \"FrontAxisSign\", \"int\", \"Integer\", \"\",1");
            text.AppendLine("\t\tP: \"CoordAxis\", \"int\", \"Integer\", \"\",0");
            text.AppendLine("\t\tP: \"CoordAxisSign\", \"int\", \"Integer\", \"\",1");
            text.AppendLine("\t\tP: \"UnitScaleFactor\", \"double\", \"Number\", \"\",1");
            text.AppendLine("\t\tP: \"OriginalUnitScaleFactor\", \"double\", \"Number\", \"\",1");
            text.AppendLine("\t\tP: \"AmbientColor\", \"ColorRGB\", \"Color\", \"\",0,0,0");
            text.AppendLine("\t\tP: \"DefaultCamera\", \"KString\", \"\", \"\", \"Producer Perspective\"");
            text.AppendLine("\t\tP: \"TimeMode\", \"enum\", \"\", \"\",0");
            text.AppendLine("\t\tP: \"TimeSpanStart\", \"KTime\", \"Time\", \"\",0");
            text.AppendLine("\t\tP: \"TimeSpanStop\", \"KTime\", \"Time\", \"\",46186158000");
            text.AppendLine("\t}");
            text.AppendLine("}");
            text.AppendLine("Documents:  {");
            text.AppendLine("\tCount: 1");
            text.Append("\tDocument: ").Append(documentId).AppendLine(", \"Scene\", \"Scene\" {");
            text.AppendLine("\t\tProperties70:  {");
            text.AppendLine("\t\t\tP: \"SourceObject\", \"object\", \"\", \"\"");
            text.AppendLine("\t\t\tP: \"ActiveAnimStackName\", \"KString\", \"\", \"\", \"\"");
            text.AppendLine("\t\t}");
            text.AppendLine("\t\tRootNode: 0");
            text.AppendLine("\t}");
            text.AppendLine("}");
            text.AppendLine("References:  {");
            text.AppendLine("}");
            text.AppendLine("Definitions:  {");
            text.AppendLine("\tVersion: 100");
            text.AppendLine("\tCount: 4");
            text.AppendLine("\tObjectType: \"GlobalSettings\" {");
            text.AppendLine("\t\tCount: 1");
            text.AppendLine("\t}");
            text.AppendLine("\tObjectType: \"Model\" {");
            text.AppendLine("\t\tCount: 1");
            text.AppendLine("\t\tPropertyTemplate: \"FbxNode\" {");
            text.AppendLine("\t\t\tProperties70:  {");
            text.AppendLine("\t\t\t\tP: \"QuaternionInterpolate\", \"enum\", \"\", \"\",0");
            AppendFbxNodeTemplateProperties(text);
            text.AppendLine("\t\t\t\tP: \"RotationOrder\", \"enum\", \"\", \"\",0");
            text.AppendLine("\t\t\t\tP: \"RotationActive\", \"bool\", \"\", \"\",0");
            text.AppendLine("\t\t\t\tP: \"InheritType\", \"enum\", \"\", \"\",0");
            text.AppendLine("\t\t\t\tP: \"Lcl Translation\", \"Lcl Translation\", \"\", \"A\",0,0,0");
            text.AppendLine("\t\t\t\tP: \"Lcl Rotation\", \"Lcl Rotation\", \"\", \"A\",0,0,0");
            text.AppendLine("\t\t\t\tP: \"Lcl Scaling\", \"Lcl Scaling\", \"\", \"A\",1,1,1");
            text.AppendLine("\t\t\t\tP: \"Visibility\", \"Visibility\", \"\", \"A\",1");
            text.AppendLine("\t\t\t}");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.AppendLine("\tObjectType: \"Geometry\" {");
            text.AppendLine("\t\tCount: 1");
            text.AppendLine("\t\tPropertyTemplate: \"FbxMesh\" {");
            text.AppendLine("\t\t\tProperties70:  {");
            text.AppendLine("\t\t\t\tP: \"Color\", \"ColorRGB\", \"Color\", \"\",0.8,0.8,0.8");
            text.AppendLine("\t\t\t\tP: \"BBoxMin\", \"Vector3D\", \"Vector\", \"\",0,0,0");
            text.AppendLine("\t\t\t\tP: \"BBoxMax\", \"Vector3D\", \"Vector\", \"\",0,0,0");
            text.AppendLine("\t\t\t\tP: \"Primary Visibility\", \"bool\", \"\", \"\",1");
            text.AppendLine("\t\t\t\tP: \"Casts Shadows\", \"bool\", \"\", \"\",1");
            text.AppendLine("\t\t\t\tP: \"Receive Shadows\", \"bool\", \"\", \"\",1");
            text.AppendLine("\t\t\t}");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.AppendLine("\tObjectType: \"Material\" {");
            text.AppendLine("\t\tCount: 1");
            text.AppendLine("\t\tPropertyTemplate: \"FbxSurfaceLambert\" {");
            text.AppendLine("\t\t\tProperties70:  {");
            text.AppendLine("\t\t\t\tP: \"ShadingModel\", \"KString\", \"\", \"\", \"Lambert\"");
            text.AppendLine("\t\t\t\tP: \"MultiLayer\", \"bool\", \"\", \"\",0");
            text.AppendLine("\t\t\t\tP: \"EmissiveColor\", \"Color\", \"\", \"A\",0,0,0");
            text.AppendLine("\t\t\t\tP: \"EmissiveFactor\", \"Number\", \"\", \"A\",1");
            text.AppendLine("\t\t\t\tP: \"AmbientColor\", \"Color\", \"\", \"A\",0.2,0.2,0.2");
            text.AppendLine("\t\t\t\tP: \"AmbientFactor\", \"Number\", \"\", \"A\",1");
            text.AppendLine("\t\t\t\tP: \"DiffuseColor\", \"Color\", \"\", \"A\",0.8,0.8,0.8");
            text.AppendLine("\t\t\t\tP: \"DiffuseFactor\", \"Number\", \"\", \"A\",1");
            text.AppendLine("\t\t\t\tP: \"TransparencyFactor\", \"Number\", \"\", \"A\",0");
            text.AppendLine("\t\t\t}");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.AppendLine("}");
            text.AppendLine("Objects:  {");
            text.Append("\tGeometry: ").Append(geometryId).AppendLine(", \"Geometry::Scene\", \"Mesh\" {");
            AppendFbxVertices(text, vertices);
            AppendFbxPolygonIndices(text, triangles);
            text.AppendLine("\t\tGeometryVersion: 124");
            AppendFbxNormals(text, triangles, normals);
            AppendFbxColors(text, triangles, colors);
            AppendFbxUvs(text, triangles, uvs);
            text.AppendLine("\t\tLayerElementMaterial: 0 {");
            text.AppendLine("\t\t\tVersion: 101");
            text.AppendLine("\t\t\tName: \"Material\"");
            text.AppendLine("\t\t\tMappingInformationType: \"AllSame\"");
            text.AppendLine("\t\t\tReferenceInformationType: \"IndexToDirect\"");
            text.AppendLine("\t\t\tMaterials: *1 {");
            text.AppendLine("\t\t\t\ta: 0");
            text.AppendLine("\t\t\t}");
            text.AppendLine("\t\t}");
            text.AppendLine("\t\tLayer: 0 {");
            text.AppendLine("\t\t\tVersion: 100");
            AppendFbxLayer(text, "LayerElementNormal");
            AppendFbxLayer(text, "LayerElementMaterial");
            AppendFbxLayer(text, "LayerElementColor");
            AppendFbxLayer(text, "LayerElementUV");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.Append("\tModel: ").Append(modelId).Append(", \"Model::").Append(name).AppendLine("\", \"Mesh\" {");
            text.AppendLine("\t\tVersion: 232");
            text.AppendLine("\t\tProperties70:  {");
            text.AppendLine("\t\t\tP: \"RotationOrder\", \"enum\", \"\", \"\",4");
            text.AppendLine("\t\t\tP: \"RotationActive\", \"bool\", \"\", \"\",1");
            text.AppendLine("\t\t\tP: \"InheritType\", \"enum\", \"\", \"\",1");
            text.AppendLine("\t\t\tP: \"ScalingMax\", \"Vector3D\", \"Vector\", \"\",0,0,0");
            text.AppendLine("\t\t\tP: \"DefaultAttributeIndex\", \"int\", \"Integer\", \"\",0");
            text.AppendLine("\t\t}");
            text.AppendLine("\t\tShading: W");
            text.AppendLine("\t\tCulling: \"CullingOff\"");
            text.AppendLine("\t}");
            text.Append("\tMaterial: ").Append(materialId).AppendLine(", \"Material::Default\", \"\" {");
            text.AppendLine("\t\tVersion: 102");
            text.AppendLine("\t\tShadingModel: \"lambert\"");
            text.AppendLine("\t\tMultiLayer: 0");
            text.AppendLine("\t\tProperties70:  {");
            text.AppendLine("\t\t\tP: \"AmbientColor\", \"Color\", \"\", \"A\",0,0,0");
            text.AppendLine("\t\t\tP: \"DiffuseColor\", \"Color\", \"\", \"A\",0.5,0.5,0.5");
            text.AppendLine("\t\t\tP: \"Opacity\", \"double\", \"Number\", \"\",1");
            text.AppendLine("\t\t}");
            text.AppendLine("\t}");
            text.AppendLine("}");
            text.AppendLine("Connections:  {");
            text.Append("\tC: \"OO\",").Append(modelId).AppendLine(",0");
            text.Append("\tC: \"OO\",").Append(materialId).Append(',').Append(modelId).AppendLine();
            text.Append("\tC: \"OO\",").Append(geometryId).Append(',').Append(modelId).AppendLine();
            text.AppendLine("}");
            text.AppendLine("Takes:  {");
            text.AppendLine("\tCurrent: \"\"");
            text.AppendLine("}");
            WriteAllText(path, text.ToString());
        }

        private static void AppendObjCorner(StringBuilder text, int index)
        {
            text.Append(text.Length > 0 && text[text.Length - 1] == '\n' ? "f " : " ")
                .Append(index).Append('/').Append(index).Append('/').Append(index);
        }

        private static void AppendFbxNodeTemplateProperties(StringBuilder text)
        {
            string[] vectorProperties =
            {
                "RotationOffset", "RotationPivot", "ScalingOffset", "ScalingPivot", "TranslationMin", "TranslationMax",
                "RotationStiffness", "PreRotation", "PostRotation", "RotationMin", "RotationMax", "ScalingMin", "ScalingMax",
                "GeometricTranslation", "GeometricRotation", "GeometricScaling"
            };
            for (int i = 0; i < vectorProperties.Length; i++)
            {
                string defaultValue = vectorProperties[i] == "ScalingMax" || vectorProperties[i] == "GeometricScaling" ? "1,1,1" : "0,0,0";
                text.Append("\t\t\t\tP: \"").Append(vectorProperties[i])
                    .Append("\", \"Vector3D\", \"Vector\", \"\",").Append(defaultValue).AppendLine();
            }
            string[] boolProperties =
            {
                "TranslationActive", "TranslationMinX", "TranslationMinY", "TranslationMinZ", "TranslationMaxX", "TranslationMaxY",
                "TranslationMaxZ", "RotationSpaceForLimitOnly", "RotationMinX", "RotationMinY", "RotationMinZ", "RotationMaxX",
                "RotationMaxY", "RotationMaxZ", "ScalingActive", "ScalingMinX", "ScalingMinY", "ScalingMinZ", "ScalingMaxX",
                "ScalingMaxY", "ScalingMaxZ", "Show", "NegativePercentShapeSupport", "Freeze", "LODBox"
            };
            for (int i = 0; i < boolProperties.Length; i++)
            {
                int value = boolProperties[i] == "Show" || boolProperties[i] == "NegativePercentShapeSupport" ? 1 : 0;
                text.Append("\t\t\t\tP: \"").Append(boolProperties[i]).Append("\", \"bool\", \"\", \"\",")
                    .Append(value).AppendLine();
            }
            text.AppendLine("\t\t\t\tP: \"AxisLen\", \"double\", \"Number\", \"\",10");
            text.AppendLine("\t\t\t\tP: \"DefaultAttributeIndex\", \"int\", \"Integer\", \"\",-1");
        }

        private static void AppendFbxVertices(StringBuilder text, Vector3[] vertices)
        {
            text.Append("\t\tVertices: *").Append(vertices.Length * 3).AppendLine(" {");
            text.Append("\t\t\ta: ");
            for (int i = 0; i < vertices.Length; i++)
            {
                Vector3 v = ConvertPosition(vertices[i]);
                if (i > 0) text.Append(',');
                text.Append(F(v.x)).Append(',').Append(F(v.y)).Append(',').Append(F(v.z));
            }
            text.AppendLine().AppendLine("\t\t}");
        }

        private static void AppendFbxPolygonIndices(StringBuilder text, int[] triangles)
        {
            text.Append("\t\tPolygonVertexIndex: *").Append(triangles.Length).AppendLine(" {");
            text.Append("\t\t\ta: ");
            for (int i = 0; i < triangles.Length; i += 3)
            {
                if (i > 0) text.Append(',');
                text.Append(triangles[i]).Append(',').Append(triangles[i + 2]).Append(',').Append(-triangles[i + 1] - 1);
            }
            text.AppendLine().AppendLine("\t\t}");
        }

        private static void AppendFbxNormals(StringBuilder text, int[] triangles, Vector3[] normals)
        {
            text.AppendLine("\t\tLayerElementNormal: 0 {");
            text.AppendLine("\t\t\tVersion: 102");
            text.AppendLine("\t\t\tName: \"Normals\"");
            text.AppendLine("\t\t\tMappingInformationType: \"ByPolygonVertex\"");
            text.AppendLine("\t\t\tReferenceInformationType: \"Direct\"");
            text.Append("\t\t\tNormals: *").Append(triangles.Length * 3).AppendLine(" {");
            text.Append("\t\t\t\ta: ");
            for (int i = 0; i < triangles.Length; i += 3)
            {
                int[] order = { triangles[i], triangles[i + 2], triangles[i + 1] };
                for (int j = 0; j < 3; j++)
                {
                    if (i > 0 || j > 0) text.Append(',');
                    Vector3 n = ConvertNormal(normals[order[j]]);
                    text.Append(F(n.x)).Append(',').Append(F(n.y)).Append(',').Append(F(n.z));
                }
            }
            text.AppendLine().AppendLine("\t\t\t}");
            text.Append("\t\t\tNormalsW: *").Append(triangles.Length).AppendLine(" {");
            text.Append("\t\t\t\ta: ");
            for (int i = 0; i < triangles.Length; i++)
            {
                if (i > 0) text.Append(',');
                text.Append('1');
            }
            text.AppendLine().AppendLine("\t\t\t}");
            text.AppendLine("\t\t}");
        }

        private static void AppendFbxColors(StringBuilder text, int[] triangles, Color32[] colors)
        {
            text.AppendLine("\t\tLayerElementColor: 0 {");
            text.AppendLine("\t\t\tVersion: 101");
            text.AppendLine("\t\t\tName: \"VertexColors\"");
            text.AppendLine("\t\t\tMappingInformationType: \"ByPolygonVertex\"");
            text.AppendLine("\t\t\tReferenceInformationType: \"IndexToDirect\"");
            text.Append("\t\t\tColors: *").Append(colors.Length * 4).AppendLine(" {");
            text.Append("\t\t\t\ta: ");
            for (int i = 0; i < colors.Length; i++)
            {
                if (i > 0) text.Append(',');
                Color32 c = colors[i];
                text.Append(F(c.r / 255f)).Append(',').Append(F(c.g / 255f)).Append(',')
                    .Append(F(c.b / 255f)).Append(',').Append(F(c.a / 255f));
            }
            text.AppendLine().AppendLine("\t\t\t}");
            AppendFbxIndexArray(text, "ColorIndex", triangles);
            text.AppendLine("\t\t}");
        }

        private static void AppendFbxUvs(StringBuilder text, int[] triangles, Vector2[] uvs)
        {
            text.AppendLine("\t\tLayerElementUV: 0 {");
            text.AppendLine("\t\t\tVersion: 101");
            text.AppendLine("\t\t\tName: \"UVSet0\"");
            text.AppendLine("\t\t\tMappingInformationType: \"ByPolygonVertex\"");
            text.AppendLine("\t\t\tReferenceInformationType: \"IndexToDirect\"");
            text.Append("\t\t\tUV: *").Append(uvs.Length * 2).AppendLine(" {");
            text.Append("\t\t\t\ta: ");
            for (int i = 0; i < uvs.Length; i++)
            {
                if (i > 0) text.Append(',');
                text.Append(F(uvs[i].x)).Append(',').Append(F(uvs[i].y));
            }
            text.AppendLine().AppendLine("\t\t\t}");
            AppendFbxIndexArray(text, "UVIndex", triangles);
            text.AppendLine("\t\t}");
        }

        private static void AppendFbxIndexArray(StringBuilder text, string property, int[] triangles)
        {
            text.Append("\t\t\t").Append(property).Append(": *").Append(triangles.Length).AppendLine(" {");
            text.Append("\t\t\t\ta: ");
            for (int i = 0; i < triangles.Length; i += 3)
            {
                if (i > 0) text.Append(',');
                text.Append(triangles[i]).Append(',').Append(triangles[i + 2]).Append(',').Append(triangles[i + 1]);
            }
            text.AppendLine().AppendLine("\t\t\t}");
        }

        private static void AppendFbxLayer(StringBuilder text, string type)
        {
            text.AppendLine("\t\t\tLayerElement:  {");
            text.Append("\t\t\t\tType: \"").Append(type).AppendLine("\"");
            text.AppendLine("\t\t\t\tTypedIndex: 0");
            text.AppendLine("\t\t\t}");
        }

        private static Vector3[] GetNormals(Mesh mesh)
        {
            Vector3[] normals = mesh.normals;
            if (normals != null && normals.Length == mesh.vertexCount) return normals;
            var copy = UnityEngine.Object.Instantiate(mesh);
            copy.RecalculateNormals();
            normals = copy.normals;
            UnityEngine.Object.DestroyImmediate(copy);
            return normals;
        }

        private static Vector2[] GetUvs(Mesh mesh)
        {
            Vector2[] uvs = mesh.uv;
            return uvs != null && uvs.Length == mesh.vertexCount ? uvs : new Vector2[mesh.vertexCount];
        }

        private static Color32[] GetColors(Mesh mesh)
        {
            Color32[] colors = mesh.colors32;
            if (colors != null && colors.Length == mesh.vertexCount) return colors;
            colors = new Color32[mesh.vertexCount];
            for (int i = 0; i < colors.Length; i++) colors[i] = new Color32(255, 255, 255, 255);
            return colors;
        }

        private static Vector3 ConvertPosition(Vector3 value) => new Vector3(-value.x, value.y, value.z);
        private static Vector3 ConvertNormal(Vector3 value) => new Vector3(-value.x, value.y, value.z).normalized;
        private static string F(float value) => value.ToString("R", Invariant);
        private static string SanitizeName(string value) => string.IsNullOrWhiteSpace(value) ? "EffectMesh" : value.Replace(' ', '_').Replace('"', '_');

        private static void Validate(Mesh mesh, string path)
        {
            if (mesh == null) throw new ArgumentNullException(nameof(mesh));
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentException("Export path is empty.", nameof(path));
            string directory = Path.GetDirectoryName(Path.GetFullPath(path));
            if (!string.IsNullOrEmpty(directory)) Directory.CreateDirectory(directory);
        }

        private static void WriteAllText(string path, string contents)
        {
            File.WriteAllText(path, contents, new UTF8Encoding(false));
        }
    }
}
