using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Grab Pass 特性：将当前颜色缓冲绑定为 _CameraColorAttachmentA 供热扭曲等效果使用
/// </summary>
public class GrabPassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        public string shaderTagName = "Grab";
        public LayerMask layerMask = -1;
        
        [Header("性能设置")]
        [Tooltip("采样分辨率缩放（1.0 = 全分辨率，0.5 = 半分辨率）")]
        [Range(0.25f, 1f)]
        public float resolutionScale = 1f;
    }

    public Settings settings = new Settings();
    private GrabPass grabPass;

    public override void Create()
    {
        grabPass = new GrabPass(settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(grabPass);
    }

    protected override void Dispose(bool disposing)
    {
        grabPass?.Dispose();
    }

    class GrabPass : ScriptableRenderPass
    {
        private readonly ShaderTagId shaderTagId;
        private FilteringSettings filteringSettings;
        private readonly Settings settings;
        private RTHandle tempColorTarget;

        public GrabPass(Settings settings)
        {
            this.settings = settings;
            renderPassEvent = settings.renderPassEvent;
            shaderTagId = new ShaderTagId(settings.shaderTagName);
            filteringSettings = new FilteringSettings(RenderQueueRange.transparent, settings.layerMask);
            ConfigureInput(ScriptableRenderPassInput.Color);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.width = Mathf.Max(1, Mathf.CeilToInt(descriptor.width * settings.resolutionScale));
            descriptor.height = Mathf.Max(1, Mathf.CeilToInt(descriptor.height * settings.resolutionScale));
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;

            RenderingUtils.ReAllocateIfNeeded(ref tempColorTarget, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_GrabPassTemp");
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (tempColorTarget == null) return;

            var cmd = CommandBufferPool.Get("Grab Pass");
            var sourceColorTarget = renderingData.cameraData.renderer.cameraColorTargetHandle;

            cmd.Blit(sourceColorTarget.nameID, tempColorTarget.nameID);
            cmd.SetGlobalTexture("_CameraColorAttachmentA", tempColorTarget.nameID);
            cmd.SetRenderTarget(sourceColorTarget, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store);

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            var drawingSettings = CreateDrawingSettings(shaderTagId, ref renderingData, SortingCriteria.CommonTransparent);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

            CommandBufferPool.Release(cmd);
        }

        public void Dispose()
        {
            tempColorTarget?.Release();
        }
    }
}