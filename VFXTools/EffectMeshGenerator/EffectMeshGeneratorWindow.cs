using System.IO;
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.EffectMeshGenerator
{
    public sealed class EffectMeshGeneratorWindow : EditorWindow
    {
        private const string MenuPath = "TATools/VFXTools/Utilities/特效网格生成器";
        private const string PrefsKey = "VFXTools.EffectMeshGenerator.State";
        private const float UVScrollSpeed = 0.35f;
        private const float OrbitDampingFactor = 0.08f;
        private const float OrbitReferenceFps = 60f;
        private const float OrbitRotateSpeed = 0.8f;
        private const string DefaultMeshAssetDirectory = "Generated/VFXMeshes";
        private static readonly string[] UVRotationLabels = { "0°", "90°", "180°", "270°" };

        [SerializeField] private EffectMeshType meshType = EffectMeshType.Slash;
        [SerializeField] private EffectMeshParameters parameters = new EffectMeshParameters();
        [SerializeField] private bool wireframe = true;
        [SerializeField] private float wireframeThickness = 2.5f;
        [SerializeField] private string meshAssetDirectory = DefaultMeshAssetDirectory;
        [SerializeField] private bool alwaysOnTop;
        [SerializeField] private bool showUV;
        [SerializeField] private bool animateUVScroll;
        [SerializeField] private bool showPivot;
        [SerializeField] private bool autoRotate;
        [SerializeField] private float autoRotateSpeed = 12f;
        [SerializeField] private Color previewColor = Color.white;
        [SerializeField] private bool showPreviewTexture;
        [SerializeField] private Texture2D previewTexture;
        [SerializeField] private bool showTemplateLibrary;

        private PreviewRenderUtility preview;
        private PreviewRenderUtility uvPreview;
        private PreviewRenderUtility templatePreview;
        private Material previewMaterial;
        private Material wireMaterial;
        private Material uvMaterial;
        private Material uvLineMaterial;
        private Material uvShadowMaterial;
        private Material sceneGuideMaterial;
        private Mesh previewMesh;
        private Mesh wireMesh;
        private Mesh uvWireMesh;
        private Mesh uvBackgroundMesh;
        private Mesh sceneGridMesh;
        private Mesh pivotAxesMesh;
        private Texture2D checkerTexture;
        private Vector2 scroll;
        private Vector2 orbit = new Vector2(-20f, 25f);
        private Vector2 orbitDampingDelta;
        private Vector3 pan;
        private Vector3 panDampingDelta;
        private float distance = 6f;
        private Vector2 uvPan;
        private float uvZoom = 1f;
        private float uvScrollOffset;
        private double previousTime;
        private bool dirty = true;
        private readonly List<ThumbnailItem> thumbnailItems = new List<ThumbnailItem>();
        private Vector2 templateScroll;

        [MenuItem(MenuPath)]
        public static void Open()
        {
            if (HasOpenInstances<EffectMeshGeneratorWindow>())
            {
                FocusWindowIfItsOpen<EffectMeshGeneratorWindow>();
                return;
            }

            var window = CreateInstance<EffectMeshGeneratorWindow>();
            window.titleContent = new GUIContent("特效网格生成器");
            window.minSize = new Vector2(900f, 580f);
            window.LoadState();
            if (window.alwaysOnTop) window.ShowUtility();
            else window.Show();
        }

        private void OnEnable()
        {
            LoadState();
            CreatePreview();
            EditorApplication.update += Tick;
            previousTime = EditorApplication.timeSinceStartup;
        }

        private void OnDisable()
        {
            SaveState();
            EditorApplication.update -= Tick;
            DestroyPreview();
        }

        private void Tick()
        {
            double now = EditorApplication.timeSinceStartup;
            float delta = (float)(now - previousTime);
            previousTime = now;
            bool needsRepaint = false;
            float dampingDelta = Mathf.Min(delta, 0.1f);
            float dampingRetention = Mathf.Pow(1f - OrbitDampingFactor, dampingDelta * OrbitReferenceFps);
            float dampingStep = 1f - dampingRetention;
            if (orbitDampingDelta.sqrMagnitude > 0.000001f)
            {
                orbit += orbitDampingDelta * dampingStep;
                orbitDampingDelta *= dampingRetention;
                if (orbitDampingDelta.sqrMagnitude < 0.000001f) orbitDampingDelta = Vector2.zero;
                needsRepaint = true;
            }
            if (panDampingDelta.sqrMagnitude > 0.00000001f)
            {
                pan += panDampingDelta * dampingStep;
                panDampingDelta *= dampingRetention;
                if (panDampingDelta.sqrMagnitude < 0.00000001f) panDampingDelta = Vector3.zero;
                needsRepaint = true;
            }
            if (animateUVScroll)
            {
                uvScrollOffset = Mathf.Repeat(uvScrollOffset + delta * UVScrollSpeed, 1f);
                needsRepaint = true;
            }
            if (autoRotate)
            {
                orbit.y += autoRotateSpeed * delta;
                needsRepaint = true;
            }
            if (needsRepaint) Repaint();
        }

        private void OnGUI()
        {
            if (preview == null || uvPreview == null) CreatePreview();
            Rect full = new Rect(0f, 0f, position.width, position.height);
            float panelWidth = Mathf.Clamp(position.width * 0.36f, 330f, 440f);
            Rect panelRect = new Rect(0f, 0f, panelWidth, full.height);
            Rect previewRect = new Rect(panelWidth, 0f, full.width - panelWidth, full.height);

            GUILayout.BeginArea(panelRect, EditorStyles.helpBox);
            DrawControlPanel();
            GUILayout.EndArea();
            DrawPreview(previewRect);
        }

        private void DrawControlPanel()
        {
            GUILayout.Space(4f);
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.LabelField("Effect Mesh Generator", EditorStyles.boldLabel);
                bool newAlwaysOnTop = GUILayout.Toggle(alwaysOnTop, "窗口置顶", "Button", GUILayout.Width(72f));
                if (newAlwaysOnTop != alwaysOnTop)
                {
                    alwaysOnTop = newAlwaysOnTop;
                    ReopenWindow();
                    GUIUtility.ExitGUI();
                }
            }
            EditorGUILayout.LabelField("Three.js 参数语义迁移版", EditorStyles.miniLabel);
            GUILayout.Space(4f);

            EditorGUI.BeginChangeCheck();
            using (new EditorGUILayout.HorizontalScope())
            {
                var newType = (EffectMeshType)EditorGUILayout.EnumPopup("网格类型", meshType);
                if (newType != meshType)
                {
                    meshType = newType;
                    parameters = EffectMeshTemplates.Get(meshType);
                    dirty = true;
                    GUI.FocusControl(null);
                }
                if (GUILayout.Button(showTemplateLibrary ? "返回预览" : "模板库", GUILayout.Width(72f)))
                {
                    showTemplateLibrary = !showTemplateLibrary;
                    if (showTemplateLibrary) CreateTemplateLibrary();
                    GUI.FocusControl(null);
                    Repaint();
                }
            }

            scroll = EditorGUILayout.BeginScrollView(scroll);
            DrawGeometryParameters();
            DrawAlphaParameters();
            DrawOutputParameters();
            DrawPreviewParameters();
            EditorGUILayout.EndScrollView();
            if (EditorGUI.EndChangeCheck()) dirty = true;

            GUILayout.Space(4f);
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("恢复当前模板", GUILayout.Height(26f)))
                {
                    parameters = EffectMeshTemplates.Get(meshType);
                    dirty = true;
                }
                if (GUILayout.Button("聚焦预览", GUILayout.Height(26f))) FramePreview();
            }
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("保存 Mesh Asset", GUILayout.Height(28f))) SaveMeshAsset();
                if (GUILayout.Button("创建场景对象", GUILayout.Height(28f))) CreateSceneObject();
            }
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("导出 OBJ", GUILayout.Height(26f))) ExportModel(false);
                if (GUILayout.Button("导出 FBX", GUILayout.Height(26f))) ExportModel(true);
            }
            DrawExportBackendStatus();
            if (GUILayout.Button("应用到选中 Particle System", GUILayout.Height(26f))) ApplyToSelectedParticleSystem();
        }

        private void DrawExportBackendStatus()
        {
            EditorGUILayout.LabelField("OBJ：内置导出器", EditorStyles.miniLabel);
            if (EffectMeshModelExporter.HasUnityFbxExporter)
            {
                EditorGUILayout.LabelField("FBX：Unity FBX Exporter（官方）", EditorStyles.miniLabel);
                return;
            }

            EditorGUILayout.HelpBox("未安装 Unity FBX Exporter，FBX 将使用内置 ASCII 导出器。建议安装官方包以获得更完整的兼容性。",
                MessageType.Warning);
            if (GUILayout.Button("在 Package Manager 中安装 FBX Exporter", GUILayout.Height(24f)))
                OpenFbxExporterPackage();
        }

        private static void OpenFbxExporterPackage()
        {
            UnityEditor.PackageManager.UI.Window.Open("com.unity.formats.fbx");
        }

        private void DrawGeometryParameters()
        {
            EditorGUILayout.Space(6f);
            EditorGUILayout.LabelField("网格参数", EditorStyles.boldLabel);
            parameters.divisions = EditorGUILayout.IntSlider("长度分段", parameters.divisions, 1, 128);
            parameters.widthDivisions = EditorGUILayout.IntSlider("宽度分段", parameters.widthDivisions, 1, 64);
            parameters.thickness = EditorGUILayout.Slider("宽度 / 半径", parameters.thickness, 0.01f, 10f);
            parameters.length = EditorGUILayout.Slider("长度", parameters.length, 0.01f, 20f);

            if (meshType != EffectMeshType.Plane && meshType != EffectMeshType.FlatRing && !IsSphere(meshType))
                parameters.curve = EditorGUILayout.Slider("弯曲", parameters.curve, -2f, 2f);
            if (!IsSphere(meshType) && meshType != EffectMeshType.BeamDome)
                parameters.topCurve = EditorGUILayout.Slider("横截面弯曲", parameters.topCurve, -2f, 2f);
            if (SupportsTaper(meshType))
            {
                parameters.taper = EditorGUILayout.Slider("起点收束", parameters.taper, 0f, 1f);
                parameters.endTaper = EditorGUILayout.Slider("终点收束", parameters.endTaper, 0f, 1f);
            }
            if (!IsSphere(meshType))
            {
                parameters.spread = EditorGUILayout.Slider("顶部扩张", parameters.spread, 0f, 3f);
                if (meshType == EffectMeshType.LightningRibbon || meshType == EffectMeshType.OpenCylinder || IsTornado(meshType))
                    parameters.bottomSpread = EditorGUILayout.Slider("底部扩张", parameters.bottomSpread, 0f, 3f);
                parameters.twist = EditorGUILayout.Slider("扭转", parameters.twist, -4f, 4f);
            }

            if (meshType == EffectMeshType.Ribbon || meshType == EffectMeshType.LightningRibbon ||
                meshType == EffectMeshType.OpenCylinder || meshType == EffectMeshType.BeamDome || IsTornado(meshType))
            {
                parameters.waveCount = EditorGUILayout.Slider("波形数量", parameters.waveCount, 1f, 16f);
                parameters.seed = EditorGUILayout.IntField("随机种子", parameters.seed);
            }
            if (meshType == EffectMeshType.LightningRibbon)
            {
                parameters.waveHeightX = EditorGUILayout.Slider("横向折线", parameters.waveHeightX, 0f, 2f);
                parameters.waveHeightZ = EditorGUILayout.Slider("纵深折线", parameters.waveHeightZ, 0f, 2f);
                parameters.waveOffset = EditorGUILayout.Slider("波形偏移", parameters.waveOffset, 0f, 1f);
            }
            if (meshType == EffectMeshType.OpenCylinder)
                parameters.waveHeight = EditorGUILayout.Slider("波形高度", parameters.waveHeight, 0f, 3f);
            if (IsSphere(meshType))
            {
                parameters.yClip = EditorGUILayout.Slider("Y 裁切", parameters.yClip, 0f, 1f);
                parameters.twist = EditorGUILayout.Slider("UV 扭转", parameters.twist, -4f, 4f);
            }
            if (meshType == EffectMeshType.BeamDome)
            {
                parameters.cylinderDivisions = EditorGUILayout.IntSlider("柱体分段", parameters.cylinderDivisions, 1, 32);
                parameters.cylinderScale = EditorGUILayout.Slider("柱体长度比例", parameters.cylinderScale, 0f, 1f);
                parameters.beamEndCap = EditorGUILayout.Toggle("后端球帽", parameters.beamEndCap);
                parameters.waveEnabled = EditorGUILayout.Toggle("启用波形", parameters.waveEnabled);
                if (parameters.waveEnabled)
                {
                    parameters.waveHeight = EditorGUILayout.Slider("Y 波幅", parameters.waveHeight, 0f, 3f);
                    parameters.waveCountX = EditorGUILayout.Slider("X 波数", parameters.waveCountX, 1f, 16f);
                    parameters.waveHeightX = EditorGUILayout.Slider("X 波幅", parameters.waveHeightX, 0f, 3f);
                    parameters.seedX = EditorGUILayout.IntField("X 随机种子", parameters.seedX);
                }
            }
            if (SupportsCross(meshType)) parameters.crossMesh = EditorGUILayout.Toggle("Cross Mesh", parameters.crossMesh);
            parameters.doubleSided = EditorGUILayout.Toggle("双面网格", parameters.doubleSided);
            parameters.mirrorZ = EditorGUILayout.Toggle("镜像 Z", parameters.mirrorZ);
        }

        private void DrawAlphaParameters()
        {
            EditorGUILayout.Space(8f);
            EditorGUILayout.LabelField("顶点 Alpha", EditorStyles.boldLabel);
            parameters.vertexAlphaEnabled = EditorGUILayout.Toggle("启用", parameters.vertexAlphaEnabled);
            if (!parameters.vertexAlphaEnabled) return;
            parameters.bottomAlpha = EditorGUILayout.Slider("底部 Alpha", parameters.bottomAlpha, 0f, 1f);
            parameters.bottomAlphaRange = EditorGUILayout.Slider("底部影响范围", parameters.bottomAlphaRange, 0.001f, 1f);
            parameters.topAlpha = EditorGUILayout.Slider("顶部 Alpha", parameters.topAlpha, 0f, 1f);
            parameters.topAlphaRange = EditorGUILayout.Slider("顶部影响范围", parameters.topAlphaRange, 0.001f, 1f);
        }

        private void DrawOutputParameters()
        {
            EditorGUILayout.Space(8f);
            EditorGUILayout.LabelField("输出变换 / UV", EditorStyles.boldLabel);
            parameters.pivot = EditorGUILayout.Vector3Field("Pivot", parameters.pivot);
            parameters.scale = EditorGUILayout.Vector3Field("Scale", parameters.scale);
            parameters.rotation = EditorGUILayout.Vector3Field("Rotation", parameters.rotation);
            parameters.textureTiling = EditorGUILayout.Vector2Field("UV Tiling", parameters.textureTiling);
            int uvRotationIndex = UVRotationToIndex(parameters.uvRotation);
            int newUVRotationIndex = EditorGUILayout.Popup("UV Rotation", uvRotationIndex, UVRotationLabels);
            parameters.uvRotation = newUVRotationIndex * 90f;
            using (new EditorGUILayout.HorizontalScope())
            {
                meshAssetDirectory = EditorGUILayout.TextField("Mesh 目录 (Assets/)", meshAssetDirectory);
                if (GUILayout.Button("浏览", GUILayout.Width(52f))) BrowseMeshAssetDirectory();
            }
        }

        private void DrawPreviewParameters()
        {
            EditorGUILayout.Space(8f);
            EditorGUILayout.LabelField("预览", EditorStyles.boldLabel);
            wireframe = EditorGUILayout.Toggle("线框", wireframe);
            if (wireframe) wireframeThickness = EditorGUILayout.Slider("线框粗细", wireframeThickness, 1f, 4f);
            showUV = EditorGUILayout.Toggle("UV 预览检查", showUV);
            showPivot = EditorGUILayout.Toggle("显示 Pivot", showPivot);
            autoRotate = EditorGUILayout.Toggle("自动旋转", autoRotate);
            if (autoRotate) autoRotateSpeed = EditorGUILayout.Slider("旋转速度", autoRotateSpeed, -90f, 90f);
            showPreviewTexture = EditorGUILayout.Toggle("显示贴图", showPreviewTexture);
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel("UV 滚动检查");
                if (GUILayout.Button("重置", GUILayout.Width(58f)))
                {
                    uvScrollOffset = 0f;
                    Repaint();
                }
                animateUVScroll = GUILayout.Toggle(animateUVScroll, animateUVScroll ? "开启" : "关闭", "Button", GUILayout.Width(58f));
            }
            using (new EditorGUI.DisabledScope(!showPreviewTexture))
                previewTexture = (Texture2D)EditorGUILayout.ObjectField("_MainTex", previewTexture, typeof(Texture2D), false);
            previewColor = EditorGUILayout.ColorField("_BaseColor", previewColor);
        }

        private void DrawPreview(Rect rect)
        {
            EditorGUI.DrawRect(rect, new Color(0.075f, 0.085f, 0.1f));
            if (showTemplateLibrary)
            {
                DrawTemplateLibrary(rect);
                return;
            }
            if (dirty) RebuildMesh();
            if (previewMesh == null || previewMaterial == null) return;

            if (showUV)
            {
                const float gap = 6f;
                float width = (rect.width - gap - 8f) * 0.5f;
                Rect meshRect = new Rect(rect.x + 4f, rect.y + 4f, width, rect.height - 8f);
                Rect uvRect = new Rect(meshRect.xMax + gap, rect.y + 4f, width, rect.height - 8f);
                HandleMeshPreviewInput(meshRect);
                HandleUvPreviewInput(uvRect);
                RenderMeshPreview(meshRect, true);
                RenderUvPreview(uvRect);
                DrawMeshPreviewOverlay(meshRect);
                DrawUvPreviewOverlay(uvRect);
            }
            else
            {
                Rect meshRect = new Rect(rect.x + 4f, rect.y + 4f, rect.width - 8f, rect.height - 8f);
                HandleMeshPreviewInput(meshRect);
                RenderMeshPreview(meshRect, false);
                DrawMeshPreviewOverlay(meshRect);
            }
        }

        private void RenderMeshPreview(Rect renderRect, bool uvChecking)
        {
            preview.BeginPreview(renderRect, GUIStyle.none);
            SetupCamera(renderRect);
            bool useUserTexture = showPreviewTexture && previewTexture != null;
            Texture texture = useUserTexture ? previewTexture : checkerTexture;
            previewMaterial.SetColor("_BaseColor", previewColor);
            previewMaterial.SetTexture("_MainTex", texture != null ? texture : Texture2D.whiteTexture);
            previewMaterial.SetTextureScale("_MainTex", SafeTextureTiling(parameters.textureTiling));
            previewMaterial.SetTextureOffset("_MainTex", Vector2.zero);
            previewMaterial.SetVector("_UVOffset", new Vector4(0f, uvScrollOffset, 0f, 0f));
            previewMaterial.SetFloat("_UseTexture", uvChecking || useUserTexture ? 1f : 0f);
            previewMaterial.SetFloat("_UseSideColor", uvChecking || useUserTexture ? 0f : 1f);
            if (sceneGridMesh != null && sceneGuideMaterial != null)
                preview.DrawMesh(sceneGridMesh, Matrix4x4.identity, sceneGuideMaterial, 0);
            preview.DrawMesh(previewMesh, Matrix4x4.identity, previewMaterial, 0);
            if (wireframe && wireMesh != null && wireMaterial != null)
                DrawThickWire(preview, wireMesh, wireMaterial, renderRect, wireframeThickness);
            if (showPivot && pivotAxesMesh != null && sceneGuideMaterial != null)
                preview.DrawMesh(pivotAxesMesh, Matrix4x4.identity, sceneGuideMaterial, 0);
            preview.Render(true);
            Texture result = preview.EndPreview();
            GUI.DrawTexture(renderRect, result, ScaleMode.StretchToFill, false);
        }

        private void RenderUvPreview(Rect renderRect)
        {
            if (uvMaterial == null || uvBackgroundMesh == null || uvWireMesh == null) return;
            uvPreview.BeginPreview(renderRect, GUIStyle.none);
            SetupUvCamera(renderRect);
            Texture texture = showPreviewTexture && previewTexture != null ? previewTexture : checkerTexture;
            uvMaterial.SetTexture("_MainTex", texture != null ? texture : Texture2D.whiteTexture);
            uvMaterial.SetTextureScale("_MainTex", SafeTextureTiling(parameters.textureTiling));
            uvMaterial.SetTextureOffset("_MainTex", Vector2.zero);
            uvMaterial.SetVector("_UVOffset", new Vector4(0f, uvScrollOffset, 0f, 0f));
            uvMaterial.SetFloat("_UseTexture", 1f);
            uvPreview.DrawMesh(uvBackgroundMesh, Matrix4x4.identity, uvMaterial, 0);
            if (uvShadowMaterial != null && uvLineMaterial != null)
            {
                float pixel = uvPreview.camera.orthographicSize * 2f / Mathf.Max(1f, renderRect.height);
                uvPreview.DrawMesh(uvWireMesh, Matrix4x4.Translate(new Vector3(-pixel, 0f, -0.01f)), uvShadowMaterial, 0);
                uvPreview.DrawMesh(uvWireMesh, Matrix4x4.Translate(new Vector3(pixel, 0f, -0.01f)), uvShadowMaterial, 0);
                uvPreview.DrawMesh(uvWireMesh, Matrix4x4.Translate(new Vector3(0f, -pixel, -0.01f)), uvShadowMaterial, 0);
                uvPreview.DrawMesh(uvWireMesh, Matrix4x4.Translate(new Vector3(0f, pixel, -0.01f)), uvShadowMaterial, 0);
                uvPreview.DrawMesh(uvWireMesh, Matrix4x4.Translate(new Vector3(0f, 0f, -0.02f)), uvLineMaterial, 0);
            }
            uvPreview.Render(true);
            Texture result = uvPreview.EndPreview();
            GUI.DrawTexture(renderRect, result, ScaleMode.StretchToFill, false);
        }

        private void SetupCamera(Rect rect)
        {
            preview.camera.orthographic = false;
            Quaternion rotation = Quaternion.Euler(orbit.x, orbit.y, 0f);
            Vector3 target = previewMesh.bounds.center + pan;
            preview.camera.transform.position = target + rotation * (Vector3.back * distance);
            preview.camera.transform.rotation = rotation;
            preview.camera.aspect = Mathf.Max(0.1f, rect.width / Mathf.Max(1f, rect.height));
            preview.camera.nearClipPlane = 0.01f;
            preview.camera.farClipPlane = Mathf.Max(100f, distance * 20f);
            preview.camera.clearFlags = CameraClearFlags.Color;
            preview.camera.backgroundColor = new Color(0.115f, 0.125f, 0.145f, 1f);
        }

        private void SetupUvCamera(Rect rect)
        {
            float aspect = Mathf.Max(0.1f, rect.width / Mathf.Max(1f, rect.height));
            float halfHeight = Mathf.Max(0.5f, 0.5f / aspect);
            uvPreview.camera.orthographic = true;
            uvPreview.camera.orthographicSize = Mathf.Max(0.05f, halfHeight * 1.15f / Mathf.Max(0.05f, uvZoom));
            uvPreview.camera.transform.position = new Vector3(0.5f + uvPan.x, 0.5f + uvPan.y, -10f);
            uvPreview.camera.transform.rotation = Quaternion.identity;
            uvPreview.camera.aspect = aspect;
            uvPreview.camera.nearClipPlane = 0.01f;
            uvPreview.camera.farClipPlane = 100f;
            uvPreview.camera.clearFlags = CameraClearFlags.Color;
            uvPreview.camera.backgroundColor = new Color(0.075f, 0.085f, 0.1f, 1f);
        }

        private void HandleMeshPreviewInput(Rect rect)
        {
            Event e = Event.current;
            if (!rect.Contains(e.mousePosition)) return;
            if (e.type == EventType.MouseDrag && e.button == 0)
            {
                orbitDampingDelta += new Vector2(e.delta.y, e.delta.x) * (0.5f * OrbitRotateSpeed);
                e.Use(); Repaint();
            }
            else if (e.type == EventType.MouseDrag && e.button == 2)
            {
                float scale = distance * 0.0025f;
                Quaternion rotation = Quaternion.Euler(orbit.x, orbit.y, 0f);
                panDampingDelta += rotation * Vector3.right * (-e.delta.x * scale) + rotation * Vector3.up * (e.delta.y * scale);
                e.Use(); Repaint();
            }
            else if (e.type == EventType.ScrollWheel)
            {
                distance = Mathf.Clamp(distance * (1f + e.delta.y * 0.06f), 0.1f, 100f);
                e.Use(); Repaint();
            }
        }

        private void HandleUvPreviewInput(Rect rect)
        {
            Event e = Event.current;
            if (!rect.Contains(e.mousePosition)) return;
            if (e.type == EventType.MouseDrag && (e.button == 0 || e.button == 2))
            {
                float scale = uvPreview.camera.orthographicSize * 0.0025f;
                uvPan += new Vector2(-e.delta.x, e.delta.y) * scale;
                e.Use(); Repaint();
            }
            else if (e.type == EventType.ScrollWheel)
            {
                uvZoom = Mathf.Clamp(uvZoom * (1f - e.delta.y * 0.06f), 0.1f, 20f);
                e.Use(); Repaint();
            }
        }

        private void DrawLegacyMeshPreviewOverlay(Rect rect)
        {
            string stats = previewMesh.vertexCount + " Vertices  |  " + previewMesh.triangles.Length / 3 + " Triangles";
            GUI.Label(new Rect(rect.x + 12f, rect.y + 10f, rect.width - 24f, 20f), stats, EditorStyles.whiteMiniLabel);
            GUI.Label(new Rect(rect.x + 12f, rect.yMax - 26f, rect.width - 24f, 20f),
                showUV ? "左/中键平移 UV  ·  滚轮缩放" : "左键旋转  ·  中键平移  ·  滚轮缩放", EditorStyles.whiteMiniLabel);
        }

        private void DrawMeshPreviewOverlay(Rect rect)
        {
            string stats = previewMesh.vertexCount + " Vertices  |  " + previewMesh.triangles.Length / 3 + " Triangles";
            GUI.Label(new Rect(rect.x + 12f, rect.y + 10f, rect.width - 24f, 20f), stats, EditorStyles.whiteMiniLabel);
            GUI.Label(new Rect(rect.x + 12f, rect.yMax - 26f, rect.width - 24f, 20f), "LMB Orbit  ·  MMB Pan  ·  Wheel Zoom", EditorStyles.whiteMiniLabel);
        }

        private void DrawUvPreviewOverlay(Rect rect)
        {
            GUI.Label(new Rect(rect.x + 12f, rect.y + 10f, rect.width - 24f, 20f), "UV0  0-1 Layout", EditorStyles.whiteMiniLabel);
            GUI.Label(new Rect(rect.x + 12f, rect.yMax - 26f, rect.width - 24f, 20f), "左/中键平移 UV  ·  滚轮缩放", EditorStyles.whiteMiniLabel);
        }

        private void DrawTemplateLibrary(Rect rect)
        {
            if (templatePreview == null || previewMaterial == null) return;
            if (thumbnailItems.Count == 0) CreateTemplateLibrary();

            const float padding = 12f;
            const float gap = 10f;
            const float headerHeight = 42f;
            Rect headerRect = new Rect(rect.x + padding, rect.y + 8f, rect.width - padding * 2f, headerHeight - 8f);
            GUI.Label(headerRect, "网格模板库", EditorStyles.boldLabel);
            GUI.Label(new Rect(headerRect.x, headerRect.y + 19f, headerRect.width, 18f),
                "点击应用默认参数  ·  拖拽单个缩略图旋转", EditorStyles.whiteMiniLabel);

            Rect scrollRect = new Rect(rect.x + 4f, rect.y + headerHeight, rect.width - 8f, rect.height - headerHeight - 4f);
            int columns = Mathf.Clamp(Mathf.FloorToInt((scrollRect.width - padding + gap) / 190f), 1, 4);
            float cardWidth = (scrollRect.width - padding * 2f - gap * (columns - 1) - 14f) / columns;
            float cardHeight = Mathf.Clamp(cardWidth * 0.82f, 138f, 210f);
            int rows = Mathf.CeilToInt(thumbnailItems.Count / (float)columns);
            float contentHeight = padding * 2f + rows * cardHeight + Mathf.Max(0, rows - 1) * gap;
            Rect contentRect = new Rect(0f, 0f, Mathf.Max(1f, scrollRect.width - 16f), contentHeight);

            templateScroll = GUI.BeginScrollView(scrollRect, templateScroll, contentRect);
            for (int i = 0; i < thumbnailItems.Count; i++)
            {
                int column = i % columns;
                int row = i / columns;
                Rect cardRect = new Rect(padding + column * (cardWidth + gap), padding + row * (cardHeight + gap), cardWidth, cardHeight);
                DrawTemplateCard(i, cardRect);
            }
            GUI.EndScrollView();
        }

        private void DrawTemplateCard(int index, Rect rect)
        {
            ThumbnailItem item = thumbnailItems[index];
            bool selected = item.type == meshType;
            bool hovered = rect.Contains(Event.current.mousePosition);
            Color background = selected ? new Color(0.16f, 0.38f, 0.29f, 1f) :
                hovered ? new Color(0.18f, 0.2f, 0.24f, 1f) : new Color(0.12f, 0.135f, 0.16f, 1f);
            EditorGUI.DrawRect(rect, background);
            EditorGUI.DrawRect(new Rect(rect.x, rect.y, rect.width, selected ? 2f : 1f),
                selected ? new Color(0.2f, 1f, 0.55f) : new Color(0.3f, 0.32f, 0.36f));

            Rect imageRect = new Rect(rect.x + 4f, rect.y + 4f, rect.width - 8f, rect.height - 30f);
            HandleTemplateCardInput(index, imageRect);
            if (Event.current.type == EventType.Repaint) RenderTemplateThumbnail(item, imageRect);

            var labelStyle = new GUIStyle(EditorStyles.whiteMiniLabel)
            {
                alignment = TextAnchor.MiddleCenter,
                fontStyle = selected ? FontStyle.Bold : FontStyle.Normal
            };
            GUI.Label(new Rect(rect.x + 4f, rect.yMax - 25f, rect.width - 8f, 21f), ObjectNames.NicifyVariableName(item.type.ToString()), labelStyle);
        }

        private void RenderTemplateThumbnail(ThumbnailItem item, Rect renderRect)
        {
            templatePreview.BeginPreview(renderRect, GUIStyle.none);
            Camera camera = templatePreview.camera;
            Quaternion rotation = Quaternion.Euler(item.orbit.x, item.orbit.y, 0f);
            float distanceToMesh = Mathf.Max(0.5f, item.mesh.bounds.extents.magnitude * 2.8f);
            camera.orthographic = false;
            camera.transform.position = item.mesh.bounds.center + rotation * (Vector3.back * distanceToMesh);
            camera.transform.rotation = rotation;
            camera.aspect = Mathf.Max(0.1f, renderRect.width / Mathf.Max(1f, renderRect.height));
            camera.nearClipPlane = 0.01f;
            camera.farClipPlane = Mathf.Max(100f, distanceToMesh * 20f);
            camera.clearFlags = CameraClearFlags.Color;
            camera.backgroundColor = new Color(0.075f, 0.085f, 0.1f, 1f);

            previewMaterial.SetColor("_BaseColor", Color.white);
            previewMaterial.SetTexture("_MainTex", Texture2D.whiteTexture);
            previewMaterial.SetTextureScale("_MainTex", Vector2.one);
            previewMaterial.SetTextureOffset("_MainTex", Vector2.zero);
            previewMaterial.SetVector("_UVOffset", Vector4.zero);
            previewMaterial.SetFloat("_UseTexture", 0f);
            previewMaterial.SetFloat("_UseSideColor", 1f);
            templatePreview.DrawMesh(item.mesh, Matrix4x4.identity, previewMaterial, 0);
            if (item.wireMesh != null && wireMaterial != null)
                DrawThickWire(templatePreview, item.wireMesh, wireMaterial, renderRect, 1.2f);
            templatePreview.Render(true);
            Texture result = templatePreview.EndPreview();
            GUI.DrawTexture(renderRect, result, ScaleMode.StretchToFill, false);
        }

        private void HandleTemplateCardInput(int index, Rect rect)
        {
            Event e = Event.current;
            if (e.type == EventType.MouseDown && e.button == 0 && rect.Contains(e.mousePosition))
            {
                activeThumbnail = index;
                thumbnailMouseDown = e.mousePosition;
                thumbnailStartOrbit = thumbnailItems[index].orbit;
                thumbnailDragged = false;
                e.Use();
            }
            else if (e.type == EventType.MouseDrag && e.button == 0 && activeThumbnail == index)
            {
                Vector2 delta = e.mousePosition - thumbnailMouseDown;
                if (delta.sqrMagnitude > 9f) thumbnailDragged = true;
                thumbnailItems[index].orbit = thumbnailStartOrbit + new Vector2(-delta.y, delta.x) * 0.5f;
                e.Use();
                Repaint();
            }
            else if (e.type == EventType.MouseUp && e.button == 0 && activeThumbnail == index)
            {
                if (!thumbnailDragged && rect.Contains(e.mousePosition)) ApplyTemplate(thumbnailItems[index].type);
                activeThumbnail = -1;
                e.Use();
                Repaint();
            }
        }

        private void ApplyTemplate(EffectMeshType type)
        {
            meshType = type;
            parameters = EffectMeshTemplates.Get(type);
            showTemplateLibrary = false;
            dirty = true;
            GUI.FocusControl(null);
        }

        private void CreateTemplateLibrary()
        {
            DestroyTemplateLibrary();
            foreach (EffectMeshType type in Enum.GetValues(typeof(EffectMeshType)))
            {
                // Honeycomb is intentionally not part of the Unity migration.
                if (string.Equals(type.ToString(), "Honeycomb", StringComparison.OrdinalIgnoreCase)) continue;
                Mesh mesh = EffectMeshGenerator.Generate(type, EffectMeshTemplates.Get(type));
                mesh.hideFlags = HideFlags.HideAndDontSave;
                thumbnailItems.Add(new ThumbnailItem
                {
                    type = type,
                    mesh = mesh,
                    wireMesh = CreateWireMesh(mesh),
                    orbit = TemplateOrbit(type)
                });
            }
        }

        private void DestroyTemplateLibrary()
        {
            for (int i = 0; i < thumbnailItems.Count; i++)
            {
                if (thumbnailItems[i].mesh != null) DestroyImmediate(thumbnailItems[i].mesh);
                if (thumbnailItems[i].wireMesh != null) DestroyImmediate(thumbnailItems[i].wireMesh);
            }
            thumbnailItems.Clear();
            activeThumbnail = -1;
        }

        private static Vector2 TemplateOrbit(EffectMeshType type)
        {
            if (type == EffectMeshType.Plane || type == EffectMeshType.FlatRing) return new Vector2(-72f, 18f);
            if (type == EffectMeshType.OpenCylinder || type == EffectMeshType.BeamDome || IsTornado(type)) return new Vector2(-18f, 35f);
            if (IsSphere(type)) return new Vector2(-15f, 28f);
            return new Vector2(-20f, 25f);
        }

        private int activeThumbnail = -1;
        private Vector2 thumbnailMouseDown;
        private Vector2 thumbnailStartOrbit;
        private bool thumbnailDragged;

        private void RebuildMesh()
        {
            dirty = false;
            if (previewMesh != null) DestroyImmediate(previewMesh);
            if (wireMesh != null) DestroyImmediate(wireMesh);
            if (uvWireMesh != null) DestroyImmediate(uvWireMesh);
            if (pivotAxesMesh != null) DestroyImmediate(pivotAxesMesh);
            previewMesh = EffectMeshGenerator.Generate(meshType, parameters);
            wireMesh = CreateWireMesh(previewMesh);
            uvWireMesh = CreateUvWireMesh(previewMesh);
            pivotAxesMesh = CreatePivotAxesMesh(previewMesh, parameters);
            FramePreview(false);
        }

        private void FramePreview(bool resetOrbit = true)
        {
            if (previewMesh == null) return;
            distance = Mathf.Max(0.5f, previewMesh.bounds.extents.magnitude * 2.8f);
            pan = Vector3.zero;
            orbitDampingDelta = Vector2.zero;
            panDampingDelta = Vector3.zero;
            if (resetOrbit)
            {
                orbit = new Vector2(-20f, 25f);
                if (showUV)
                {
                    uvPan = Vector2.zero;
                    uvZoom = 1f;
                }
            }
            Repaint();
        }

        private void CreatePreview()
        {
            DestroyPreview();
            preview = new PreviewRenderUtility();
            uvPreview = new PreviewRenderUtility();
            templatePreview = new PreviewRenderUtility();
            preview.cameraFieldOfView = 35f;
            templatePreview.cameraFieldOfView = 35f;
            preview.lights[0].intensity = 1.4f;
            templatePreview.lights[0].intensity = 1.4f;
            preview.lights[0].transform.rotation = Quaternion.Euler(35f, 35f, 0f);
            templatePreview.lights[0].transform.rotation = Quaternion.Euler(35f, 35f, 0f);
            preview.ambientColor = new Color(0.35f, 0.35f, 0.35f);
            templatePreview.ambientColor = new Color(0.35f, 0.35f, 0.35f);
            Shader shader = Shader.Find("VFX/Utility/EffectMeshPreview");
            if (shader == null) shader = Shader.Find("Universal Render Pipeline/Unlit");
            if (shader != null) previewMaterial = new Material(shader) { hideFlags = HideFlags.HideAndDontSave };
            Shader wireShader = Shader.Find("VFX/Utility/EffectMeshWireframe");
            if (wireShader != null)
            {
                wireMaterial = new Material(wireShader) { hideFlags = HideFlags.HideAndDontSave };
                uvLineMaterial = new Material(wireShader) { hideFlags = HideFlags.HideAndDontSave };
                uvShadowMaterial = new Material(wireShader) { hideFlags = HideFlags.HideAndDontSave };
                sceneGuideMaterial = new Material(wireShader) { hideFlags = HideFlags.HideAndDontSave };
                wireMaterial.SetColor("_WireColor", new Color(0.015f, 0.02f, 0.025f, 0.9f));
                wireMaterial.SetFloat("_UseVertexAlpha", 1f);
                wireMaterial.SetFloat("_UseVertexColor", 0f);
                uvLineMaterial.SetColor("_WireColor", new Color(0f, 1f, 0.533f, 1f));
                uvLineMaterial.SetFloat("_UseVertexAlpha", 0f);
                uvShadowMaterial.SetColor("_WireColor", new Color(0f, 0f, 0f, 0.8f));
                uvShadowMaterial.SetFloat("_UseVertexAlpha", 0f);
                sceneGuideMaterial.SetColor("_WireColor", Color.white);
                sceneGuideMaterial.SetFloat("_UseVertexAlpha", 0f);
                sceneGuideMaterial.SetFloat("_UseVertexColor", 1f);
            }
            Shader uvShader = Shader.Find("VFX/Utility/EffectMeshUVPreview");
            if (uvShader != null) uvMaterial = new Material(uvShader) { hideFlags = HideFlags.HideAndDontSave };
            checkerTexture = CreateCheckerTexture();
            uvBackgroundMesh = CreateUvBackgroundMesh();
            sceneGridMesh = CreateSceneGridMesh();
            if (showTemplateLibrary) CreateTemplateLibrary();
            dirty = true;
        }

        private void DestroyPreview()
        {
            DestroyTemplateLibrary();
            if (previewMesh != null) DestroyImmediate(previewMesh);
            if (wireMesh != null) DestroyImmediate(wireMesh);
            if (uvWireMesh != null) DestroyImmediate(uvWireMesh);
            if (uvBackgroundMesh != null) DestroyImmediate(uvBackgroundMesh);
            if (sceneGridMesh != null) DestroyImmediate(sceneGridMesh);
            if (pivotAxesMesh != null) DestroyImmediate(pivotAxesMesh);
            if (checkerTexture != null) DestroyImmediate(checkerTexture);
            if (previewMaterial != null) DestroyImmediate(previewMaterial);
            if (wireMaterial != null) DestroyImmediate(wireMaterial);
            if (uvMaterial != null) DestroyImmediate(uvMaterial);
            if (uvLineMaterial != null) DestroyImmediate(uvLineMaterial);
            if (uvShadowMaterial != null) DestroyImmediate(uvShadowMaterial);
            if (sceneGuideMaterial != null) DestroyImmediate(sceneGuideMaterial);
            previewMesh = null;
            wireMesh = null;
            uvWireMesh = null;
            uvBackgroundMesh = null;
            sceneGridMesh = null;
            pivotAxesMesh = null;
            checkerTexture = null;
            previewMaterial = null;
            wireMaterial = null;
            uvMaterial = null;
            uvLineMaterial = null;
            uvShadowMaterial = null;
            sceneGuideMaterial = null;
            if (preview != null) preview.Cleanup();
            if (uvPreview != null) uvPreview.Cleanup();
            if (templatePreview != null) templatePreview.Cleanup();
            preview = null;
            uvPreview = null;
            templatePreview = null;
        }

        private Mesh GenerateAssetMesh()
        {
            Mesh mesh = EffectMeshGenerator.Generate(meshType, parameters);
            mesh.name = "VFX_" + meshType;
            return mesh;
        }

        private void SaveMeshAsset()
        {
            string directory = GetMeshAssetDirectory();
            if (directory == null) return;
            string path = EditorUtility.SaveFilePanelInProject("保存特效网格", "VFX_" + meshType, "asset",
                "选择保存位置", directory);
            if (string.IsNullOrEmpty(path)) return;
            Mesh mesh = SaveGeneratedMesh(path);
            if (mesh != null)
            {
                Selection.activeObject = mesh;
                EditorGUIUtility.PingObject(mesh);
            }
        }

        private void ExportModel(bool fbx)
        {
            string extension = fbx ? "fbx" : "obj";
            string path = EditorUtility.SaveFilePanel("导出 " + extension.ToUpperInvariant(),
                Application.dataPath, "VFX_" + meshType, extension);
            if (string.IsNullOrEmpty(path)) return;

            Mesh mesh = GenerateAssetMesh();
            try
            {
                string backend;
                if (fbx)
                {
                    EffectMeshModelExporter.FbxBackend usedBackend = EffectMeshModelExporter.ExportFbx(mesh, path);
                    backend = usedBackend == EffectMeshModelExporter.FbxBackend.UnityFbxExporter
                        ? "Unity FBX Exporter"
                        : "内置 ASCII 导出器";
                }
                else
                {
                    EffectMeshModelExporter.ExportObj(mesh, path);
                    backend = "内置导出器";
                }
                RefreshExportedAsset(path);
                ShowNotification(new GUIContent(extension.ToUpperInvariant() + " 导出完成 · " + backend));
                EditorUtility.RevealInFinder(path);
            }
            catch (Exception exception)
            {
                Debug.LogException(exception);
                EditorUtility.DisplayDialog("导出失败", exception.Message, "确定");
            }
            finally
            {
                DestroyImmediate(mesh);
            }
        }

        private static void RefreshExportedAsset(string path)
        {
            string projectRoot = Path.GetFullPath(Path.Combine(Application.dataPath, ".."));
            string fullPath = Path.GetFullPath(path);
            if (!fullPath.StartsWith(projectRoot + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)) return;
            AssetDatabase.Refresh();
        }

        private void CreateSceneObject()
        {
            string path = DefaultAssetPath();
            if (path == null) return;
            var go = new GameObject("VFX_" + meshType);
            Undo.RegisterCreatedObjectUndo(go, "Create Effect Mesh");
            var filter = go.AddComponent<MeshFilter>();
            var renderer = go.AddComponent<MeshRenderer>();
            filter.sharedMesh = SaveGeneratedMesh(path);
            renderer.sharedMaterial = AssetDatabase.GetBuiltinExtraResource<Material>("Default-Material.mat");
            Selection.activeGameObject = go;
        }

        private void ApplyToSelectedParticleSystem()
        {
            var ps = Selection.activeGameObject != null ? Selection.activeGameObject.GetComponent<ParticleSystem>() : null;
            if (ps == null)
            {
                ShowNotification(new GUIContent("请先选择带 ParticleSystem 的对象"));
                return;
            }
            string path = DefaultAssetPath();
            if (path == null) return;
            var renderer = ps.GetComponent<ParticleSystemRenderer>();
            Undo.RecordObject(renderer, "Apply Effect Mesh");
            renderer.renderMode = ParticleSystemRenderMode.Mesh;
            renderer.mesh = SaveGeneratedMesh(path);
            EditorUtility.SetDirty(renderer);
        }

        private Mesh SaveGeneratedMesh(string path)
        {
            if (string.IsNullOrEmpty(path)) return null;
            string directory = Path.GetDirectoryName(path)?.Replace('\\', '/');
            if (!string.IsNullOrEmpty(directory) && !AssetDatabase.IsValidFolder(directory))
                CreateAssetFolders(directory);
            path = AssetDatabase.GenerateUniqueAssetPath(path);
            Mesh mesh = GenerateAssetMesh();
            AssetDatabase.CreateAsset(mesh, path);
            AssetDatabase.SaveAssets();
            return mesh;
        }

        private string DefaultAssetPath()
        {
            string directory = GetMeshAssetDirectory();
            return directory == null ? null : directory + "/VFX_" + meshType + ".asset";
        }

        private void BrowseMeshAssetDirectory()
        {
            string currentDirectory = GetMeshAssetDirectory(false) ?? "Assets";
            string absoluteCurrentDirectory = Path.GetFullPath(Path.Combine(Application.dataPath, "..", currentDirectory));
            string selectedDirectory = EditorUtility.OpenFolderPanel("选择 Mesh Asset 目录", absoluteCurrentDirectory, string.Empty);
            if (string.IsNullOrEmpty(selectedDirectory)) return;

            string assetsRoot = Path.GetFullPath(Application.dataPath).Replace('\\', '/').TrimEnd('/');
            string selected = Path.GetFullPath(selectedDirectory).Replace('\\', '/').TrimEnd('/');
            if (!selected.StartsWith(assetsRoot + "/", StringComparison.OrdinalIgnoreCase))
            {
                EditorUtility.DisplayDialog("Mesh Asset 目录无效", "请选择项目 Assets 目录下的文件夹。", "确定");
                return;
            }

            meshAssetDirectory = selected.Substring(assetsRoot.Length + 1);
            GUI.FocusControl(null);
        }

        private string GetMeshAssetDirectory(bool showError = true)
        {
            string relativeDirectory = (meshAssetDirectory ?? string.Empty).Trim().Replace('\\', '/').Trim('/');
            if (relativeDirectory.StartsWith("Assets/", StringComparison.Ordinal))
                relativeDirectory = relativeDirectory.Substring("Assets/".Length).Trim('/');
            if (!string.IsNullOrEmpty(relativeDirectory) && relativeDirectory != "." &&
                !relativeDirectory.StartsWith("../", StringComparison.Ordinal) &&
                !relativeDirectory.Contains("/../"))
            {
                meshAssetDirectory = relativeDirectory;
                return "Assets/" + relativeDirectory;
            }

            if (showError)
                EditorUtility.DisplayDialog("Mesh Asset 目录无效", "请输入相对 Assets 的目录，例如 Generated/VFXMeshes。", "确定");
            return null;
        }

        private void ReopenWindow()
        {
            SaveState();
            Rect windowPosition = position;
            bool utility = alwaysOnTop;
            Close();
            EditorApplication.delayCall += () =>
            {
                var window = CreateInstance<EffectMeshGeneratorWindow>();
                window.position = windowPosition;
                window.titleContent = new GUIContent("特效网格生成器");
                window.minSize = new Vector2(900f, 580f);
                if (utility) window.ShowUtility();
                else window.Show();
            };
        }

        private static void CreateAssetFolders(string directory)
        {
            string[] parts = directory.Split('/');
            string current = parts[0];
            for (int i = 1; i < parts.Length; i++)
            {
                string next = current + "/" + parts[i];
                if (!AssetDatabase.IsValidFolder(next)) AssetDatabase.CreateFolder(current, parts[i]);
                current = next;
            }
        }

        private void SaveState()
        {
            var state = new SavedState { version = 6, meshType = meshType, parameters = parameters, wireframe = wireframe,
                wireframeThickness = wireframeThickness, meshAssetDirectory = meshAssetDirectory, alwaysOnTop = alwaysOnTop,
                previewColor = previewColor, orbit = orbit, pan = pan, distance = distance,
                animateUVScroll = animateUVScroll, showTemplateLibrary = showTemplateLibrary };
            EditorPrefs.SetString(PrefsKey, JsonUtility.ToJson(state));
        }

        private void LoadState()
        {
            string json = EditorPrefs.GetString(PrefsKey, string.Empty);
            if (string.IsNullOrEmpty(json))
            {
                parameters = EffectMeshTemplates.Get(meshType);
                return;
            }
            var state = JsonUtility.FromJson<SavedState>(json);
            if (state == null || state.parameters == null) return;
            meshType = state.meshType;
            parameters = state.parameters;
            wireframe = state.wireframe;
            wireframeThickness = state.version >= 6 ? Mathf.Clamp(state.wireframeThickness, 1f, 4f) : 2.5f;
            meshAssetDirectory = state.version >= 5 && !string.IsNullOrWhiteSpace(state.meshAssetDirectory)
                ? state.meshAssetDirectory.Replace('\\', '/').Replace("Assets/", string.Empty).Trim('/')
                : DefaultMeshAssetDirectory;
            alwaysOnTop = state.version >= 5 && state.alwaysOnTop;
            previewColor = state.version >= 2 ? state.previewColor : Color.white;
            orbit = state.orbit;
            pan = state.pan;
            distance = Mathf.Max(0.1f, state.distance);
            animateUVScroll = state.version >= 3 && state.animateUVScroll;
            showTemplateLibrary = state.version >= 4 && state.showTemplateLibrary;
        }

        private static bool IsSphere(EffectMeshType type) => type == EffectMeshType.Sphere || type == EffectMeshType.Hemisphere || type == EffectMeshType.ZHemisphere;
        private static bool IsTornado(EffectMeshType type) => type == EffectMeshType.RisingSpiralRibbon || type == EffectMeshType.CylinderSpiralRibbon;
        private static int UVRotationToIndex(float degrees) => Mathf.RoundToInt(Mathf.Repeat(degrees, 360f) / 90f) % 4;
        private static Vector2 SafeTextureTiling(Vector2 tiling) => new Vector2(Mathf.Max(0.01f, tiling.x), Mathf.Max(0.01f, tiling.y));
        private static bool SupportsTaper(EffectMeshType type) => type == EffectMeshType.Slash || type == EffectMeshType.Ribbon || type == EffectMeshType.LightningRibbon || IsTornado(type) || type == EffectMeshType.Arc || type == EffectMeshType.ArcRibbon || type == EffectMeshType.Plane;
        private static bool SupportsCross(EffectMeshType type) => type == EffectMeshType.Slash || type == EffectMeshType.Ribbon || type == EffectMeshType.LightningRibbon || IsTornado(type) || type == EffectMeshType.Arc || type == EffectMeshType.ArcRibbon || type == EffectMeshType.Plane || type == EffectMeshType.FlatRing;

        private static Mesh CreateWireMesh(Mesh source)
        {
            int[] triangles = source.triangles;
            var edges = new System.Collections.Generic.HashSet<ulong>();
            var lines = new System.Collections.Generic.List<int>(triangles.Length * 2);
            for (int i = 0; i < triangles.Length; i += 3)
            {
                AddEdge(triangles[i], triangles[i + 1], edges, lines);
                AddEdge(triangles[i + 1], triangles[i + 2], edges, lines);
                AddEdge(triangles[i + 2], triangles[i], edges, lines);
            }
            var mesh = new Mesh { name = source.name + "_Wire", hideFlags = HideFlags.HideAndDontSave };
            if (source.vertexCount > 65535) mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.vertices = source.vertices;
            mesh.colors32 = source.colors32;
            mesh.SetIndices(lines, MeshTopology.Lines, 0, true);
            mesh.bounds = source.bounds;
            return mesh;
        }

        private static void DrawThickWire(PreviewRenderUtility utility, Mesh mesh, Material material, Rect rect, float thicknessPixels)
        {
            utility.DrawMesh(mesh, Matrix4x4.identity, material, 0);
            if (thicknessPixels <= 1f) return;
            Camera camera = utility.camera;
            float distanceScale = camera.orthographic
                ? camera.orthographicSize * 2f / Mathf.Max(1f, rect.height)
                : Mathf.Max(0.001f, Vector3.Distance(camera.transform.position, mesh.bounds.center)) * 2f *
                  Mathf.Tan(camera.fieldOfView * Mathf.Deg2Rad * 0.5f) / Mathf.Max(1f, rect.height);
            float offset = distanceScale * (thicknessPixels - 1f) * 0.55f;
            Vector3 right = camera.transform.right * offset;
            Vector3 up = camera.transform.up * offset;
            utility.DrawMesh(mesh, Matrix4x4.Translate(right), material, 0);
            utility.DrawMesh(mesh, Matrix4x4.Translate(-right), material, 0);
            utility.DrawMesh(mesh, Matrix4x4.Translate(up), material, 0);
            utility.DrawMesh(mesh, Matrix4x4.Translate(-up), material, 0);
        }

        private static Mesh CreateSceneGridMesh()
        {
            const int halfCount = 20;
            const float spacing = 0.5f;
            float extent = halfCount * spacing;
            var vertices = new List<Vector3>((halfCount * 2 + 1) * 4 + 6);
            var colors = new List<Color32>(vertices.Capacity);
            for (int i = -halfCount; i <= halfCount; i++)
            {
                float p = i * spacing;
                byte alpha = (byte)(i == 0 ? 0 : i % 5 == 0 ? 105 : 46);
                AddGuideLine(vertices, colors, new Vector3(-extent, 0f, p), new Vector3(extent, 0f, p), new Color32(150, 160, 175, alpha));
                AddGuideLine(vertices, colors, new Vector3(p, 0f, -extent), new Vector3(p, 0f, extent), new Color32(150, 160, 175, alpha));
            }
            AddGuideLine(vertices, colors, new Vector3(-extent, 0f, 0f), new Vector3(extent, 0f, 0f), new Color32(210, 75, 75, 210));
            AddGuideLine(vertices, colors, new Vector3(0f, 0f, -extent), new Vector3(0f, 0f, extent), new Color32(70, 125, 230, 210));
            AddGuideLine(vertices, colors, Vector3.zero, new Vector3(0f, extent * 0.35f, 0f), new Color32(80, 210, 105, 220));
            return CreateLineMesh("EffectMesh_SceneGrid", vertices, colors);
        }

        private static Mesh CreatePivotAxesMesh(Mesh mesh, EffectMeshParameters p)
        {
            float length = Mathf.Clamp(mesh.bounds.extents.magnitude * 0.45f, 0.35f, 2.5f);
            Quaternion rotation = Quaternion.Euler(p.rotation);
            Vector3 origin = Vector3.zero;
            float xSign = Mathf.Sign(p.scale.x);
            float ySign = Mathf.Sign(p.scale.y);
            float zSign = Mathf.Sign(p.scale.z) * (p.mirrorZ ? -1f : 1f);
            var vertices = new List<Vector3>(18);
            var colors = new List<Color32>(18);
            AddPivotAxis(vertices, colors, rotation * Vector3.right * xSign, rotation * Vector3.up, length, new Color32(240, 65, 65, 255));
            AddPivotAxis(vertices, colors, rotation * Vector3.up * ySign, rotation * Vector3.forward, length, new Color32(70, 225, 95, 255));
            AddPivotAxis(vertices, colors, rotation * Vector3.forward * zSign, rotation * Vector3.right, length, new Color32(70, 125, 245, 255));
            return CreateLineMesh("EffectMesh_PivotAxes", vertices, colors);
        }

        private static void AddPivotAxis(List<Vector3> vertices, List<Color32> colors, Vector3 direction,
            Vector3 sideHint, float length, Color32 color)
        {
            direction.Normalize();
            Vector3 end = direction * length;
            float arrowLength = length * 0.18f;
            Vector3 side = Vector3.ProjectOnPlane(sideHint, direction).normalized * (arrowLength * 0.48f);
            Vector3 arrowBase = end - direction * arrowLength;
            AddGuideLine(vertices, colors, Vector3.zero, end, color);
            AddGuideLine(vertices, colors, end, arrowBase + side, color);
            AddGuideLine(vertices, colors, end, arrowBase - side, color);
        }

        private static void AddGuideLine(List<Vector3> vertices, List<Color32> colors, Vector3 a, Vector3 b, Color32 color)
        {
            vertices.Add(a);
            vertices.Add(b);
            colors.Add(color);
            colors.Add(color);
        }

        private static Mesh CreateLineMesh(string name, List<Vector3> vertices, List<Color32> colors)
        {
            var mesh = new Mesh { name = name, hideFlags = HideFlags.HideAndDontSave };
            mesh.SetVertices(vertices);
            mesh.SetColors(colors);
            var indices = new int[vertices.Count];
            for (int i = 0; i < indices.Length; i++) indices[i] = i;
            mesh.SetIndices(indices, MeshTopology.Lines, 0, true);
            mesh.RecalculateBounds();
            return mesh;
        }

        private static Mesh CreateUvWireMesh(Mesh source)
        {
            Vector2[] uvs = source.uv;
            var vertices = new Vector3[uvs.Length];
            // PreviewRenderUtility presents its render target rotated relative to Three.js canvas coordinates.
            // Compensate here so the visible layout still follows x = u, y = 1 - v.
            for (int i = 0; i < uvs.Length; i++) vertices[i] = new Vector3(1f - uvs[i].x, uvs[i].y, 0f);
            int[] triangles = source.triangles;
            var edges = new System.Collections.Generic.HashSet<ulong>();
            var lines = new System.Collections.Generic.List<int>(triangles.Length * 2);
            for (int i = 0; i < triangles.Length; i += 3)
            {
                AddEdge(triangles[i], triangles[i + 1], edges, lines);
                AddEdge(triangles[i + 1], triangles[i + 2], edges, lines);
                AddEdge(triangles[i + 2], triangles[i], edges, lines);
            }
            var mesh = new Mesh { name = source.name + "_UV_Wire", hideFlags = HideFlags.HideAndDontSave };
            if (vertices.Length > 65535) mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.vertices = vertices;
            mesh.colors32 = source.colors32;
            mesh.SetIndices(lines, MeshTopology.Lines, 0, true);
            mesh.RecalculateBounds();
            return mesh;
        }

        private static Mesh CreateUvBackgroundMesh()
        {
            var mesh = new Mesh { name = "UV_Checker_Background", hideFlags = HideFlags.HideAndDontSave };
            mesh.vertices = new[]
            {
                new Vector3(0f, 0f, 0f), new Vector3(1f, 0f, 0f),
                new Vector3(0f, 1f, 0f), new Vector3(1f, 1f, 0f)
            };
            mesh.uv = new[] { new Vector2(0f, 0f), new Vector2(1f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f) };
            mesh.colors32 = new[] { (Color32)Color.white, (Color32)Color.white, (Color32)Color.white, (Color32)Color.white };
            mesh.triangles = new[] { 0, 2, 1, 1, 2, 3 };
            mesh.RecalculateBounds();
            return mesh;
        }

        private static Texture2D CreateCheckerTexture()
        {
            const int size = 512;
            const int columns = 8;
            const int rows = 8;
            const int cell = size / columns;
            var texture = new Texture2D(size, size, TextureFormat.RGBA32, false, false)
            {
                name = "EffectMesh_UV_Checker_8x8",
                hideFlags = HideFlags.HideAndDontSave,
                filterMode = FilterMode.Point,
                wrapMode = TextureWrapMode.Repeat
            };
            var pixels = new Color32[size * size];
            for (int y = 0; y < size; y++)
            {
                int row = y / cell;
                for (int x = 0; x < size; x++)
                {
                    int column = x / cell;
                    int logicalRow = rows - 1 - row;
                    float t = (logicalRow * columns + column) / 63f;
                    float hue = Mathf.Lerp(0f, 280f, t) / 360f;
                    float lightness = ((logicalRow + column) & 1) == 0 ? 0.55f : 0.42f;
                    pixels[y * size + x] = HslToColor32(hue, 0.92f, lightness);
                }
            }

            for (int row = 0; row < rows; row++)
            for (int column = 0; column < columns; column++)
            {
                string number = (row * columns + column + 1).ToString();
                DrawNumber(pixels, size, column * cell, (rows - 1 - row) * cell, cell, number);
            }
            texture.SetPixels32(pixels);
            texture.Apply(false, true);
            return texture;
        }

        private static Color32 HslToColor32(float h, float s, float l)
        {
            float c = (1f - Mathf.Abs(2f * l - 1f)) * s;
            float hp = Mathf.Repeat(h, 1f) * 6f;
            float x = c * (1f - Mathf.Abs(hp % 2f - 1f));
            Vector3 rgb = hp < 1f ? new Vector3(c, x, 0f) : hp < 2f ? new Vector3(x, c, 0f) :
                hp < 3f ? new Vector3(0f, c, x) : hp < 4f ? new Vector3(0f, x, c) :
                hp < 5f ? new Vector3(x, 0f, c) : new Vector3(c, 0f, x);
            float m = l - c * 0.5f;
            return new Color(rgb.x + m, rgb.y + m, rgb.z + m, 1f);
        }

        private static readonly string[][] DigitRows =
        {
            new[] { "111", "101", "101", "101", "111" }, new[] { "010", "110", "010", "010", "111" },
            new[] { "111", "001", "111", "100", "111" }, new[] { "111", "001", "111", "001", "111" },
            new[] { "101", "101", "111", "001", "001" }, new[] { "111", "100", "111", "001", "111" },
            new[] { "111", "100", "111", "101", "111" }, new[] { "111", "001", "010", "010", "010" },
            new[] { "111", "101", "111", "101", "111" }, new[] { "111", "101", "111", "001", "111" }
        };

        private static void DrawNumber(Color32[] pixels, int textureSize, int cellX, int cellY, int cellSize, string number)
        {
            const int scale = 5;
            const int spacing = 2;
            int glyphWidth = 3 * scale;
            int width = number.Length * glyphWidth + (number.Length - 1) * spacing;
            int startX = cellX + (cellSize - width) / 2;
            int startY = cellY + (cellSize - 5 * scale) / 2;
            for (int i = 0; i < number.Length; i++)
            {
                string[] glyph = DigitRows[number[i] - '0'];
                int ox = startX + i * (glyphWidth + spacing);
                for (int gy = 0; gy < 5; gy++)
                for (int gx = 0; gx < 3; gx++)
                {
                    if (glyph[4 - gy][gx] != '1') continue;
                    int px = ox + gx * scale;
                    int py = startY + gy * scale;
                    FillRect(pixels, textureSize, px - 2, py - 2, scale + 4, scale + 4, new Color32(0, 0, 0, 255));
                }
                for (int gy = 0; gy < 5; gy++)
                for (int gx = 0; gx < 3; gx++)
                {
                    if (glyph[4 - gy][gx] != '1') continue;
                    FillRect(pixels, textureSize, ox + gx * scale, startY + gy * scale, scale, scale, Color.white);
                }
            }
        }

        private static void FillRect(Color32[] pixels, int size, int x, int y, int width, int height, Color32 color)
        {
            for (int py = Mathf.Max(0, y); py < Mathf.Min(size, y + height); py++)
            for (int px = Mathf.Max(0, x); px < Mathf.Min(size, x + width); px++)
                pixels[py * size + px] = color;
        }

        private static void AddEdge(int a, int b, System.Collections.Generic.HashSet<ulong> edges,
            System.Collections.Generic.List<int> lines)
        {
            uint min = (uint)Mathf.Min(a, b);
            uint max = (uint)Mathf.Max(a, b);
            ulong key = ((ulong)min << 32) | max;
            if (!edges.Add(key)) return;
            lines.Add(a);
            lines.Add(b);
        }

        [System.Serializable]
        private sealed class SavedState
        {
            public int version;
            public EffectMeshType meshType;
            public EffectMeshParameters parameters;
            public bool wireframe;
            public float wireframeThickness;
            public string meshAssetDirectory;
            public bool alwaysOnTop;
            public Color previewColor;
            public Vector2 orbit;
            public Vector3 pan;
            public float distance;
            public bool animateUVScroll;
            public bool showTemplateLibrary;
        }

        private sealed class ThumbnailItem
        {
            public EffectMeshType type;
            public Mesh mesh;
            public Mesh wireMesh;
            public Vector2 orbit;
        }
    }
}
