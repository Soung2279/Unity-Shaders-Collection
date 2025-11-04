using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MobileFogRendererFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        [Header("渲染设置")]
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        
        [Header("Shader")]
        public Shader fogShader;
        
        [Header("移动端优化")]
        [Range(0.1f, 1f)]
        public float renderScale = 1f;
        
        public bool useHalfResolution = false;
    }
    
    public Settings settings = new Settings();
    private MobileFogRenderPass fogPass;
    
    public override void Create()
    {
        if (settings.fogShader == null)
        {
            Debug.LogWarning("MobileFogRendererFeature: Fog shader is missing!");
            return;
        }
        
        fogPass = new MobileFogRenderPass(settings);
    }
    
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (fogPass == null) return;
        

        fogPass.Setup();
        renderer.EnqueuePass(fogPass);
    }
}

public class MobileFogRenderPass : ScriptableRenderPass
{
    private Material fogMaterial;
    private MobileFogRendererFeature.Settings settings;
    private RTHandle tempColorTexture;
    
    // Shader属性ID缓存
    private static readonly int FogDensityID = Shader.PropertyToID("_FogDensity");
    private static readonly int FogStartID = Shader.PropertyToID("_FogStart");
    private static readonly int FogEndID = Shader.PropertyToID("_FogEnd");
    private static readonly int HeightFogDensityID = Shader.PropertyToID("_HeightFogDensity");
    private static readonly int HeightFogBaseID = Shader.PropertyToID("_HeightFogBase");
    private static readonly int HeightFogRangeID = Shader.PropertyToID("_HeightFogRange");
    private static readonly int FogColorID = Shader.PropertyToID("_FogColor");
    private static readonly int FogColorNearID = Shader.PropertyToID("_FogColorNear");
    private static readonly int FogColorFarID = Shader.PropertyToID("_FogColorFar");
    private static readonly int GradientDistanceID = Shader.PropertyToID("_GradientDistance");
    private static readonly int UseGradientColorID = Shader.PropertyToID("_UseGradientColor");
    private static readonly int IntensityID = Shader.PropertyToID("_Intensity");
    private static readonly int FastModeID = Shader.PropertyToID("_UseFastMode");
    private static readonly int NoiseScaleID = Shader.PropertyToID("_NoiseScale");
    private static readonly int NoiseIntensityID = Shader.PropertyToID("_NoiseIntensity");
    private static readonly int NoiseSpeedID = Shader.PropertyToID("_NoiseSpeed");
    
    

    
    public MobileFogRenderPass(MobileFogRendererFeature.Settings settings)
    {
        this.settings = settings;
        renderPassEvent = settings.renderPassEvent;
        
        if (settings.fogShader != null)
        {
            fogMaterial = new Material(settings.fogShader);
        }
    }
    
    public void Setup()
    {
        // 配置渲染目标
        ConfigureInput(ScriptableRenderPassInput.Color | ScriptableRenderPassInput.Depth);
    }
    
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (fogMaterial == null) return;
        
        var stack = VolumeManager.instance.stack;
        var fogVolume = stack.GetComponent<MobileFog>();
        
        if (fogVolume == null || !fogVolume.IsActive()) return;
        
        CommandBuffer cmd = CommandBufferPool.Get("Mobile Fog Effect");
        
        var cameraData = renderingData.cameraData;
        var source = cameraData.renderer.cameraColorTargetHandle;
        
        // 计算渲染分辨率
        var descriptor = cameraData.cameraTargetDescriptor;
        if (settings.useHalfResolution)
        {
            descriptor.width /= 2;
            descriptor.height /= 2;
        }
        descriptor.width = Mathf.RoundToInt(descriptor.width * settings.renderScale);
        descriptor.height = Mathf.RoundToInt(descriptor.height * settings.renderScale);
        descriptor.depthBufferBits = 0;
        
        descriptor.depthBufferBits = 0;
        
        // 设置Shader参数
        SetShaderParameters(fogVolume);
        
        // 执行雾效渲染
        RenderingUtils.ReAllocateIfNeeded(ref tempColorTexture, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempFogTexture");
        cmd.Blit(source, tempColorTexture);
        cmd.Blit(tempColorTexture, source, fogMaterial, 0);
        
        context.ExecuteCommandBuffer(cmd);
    }

    private void SetShaderParameters(MobileFog fog)
    {
        fogMaterial.SetFloat(FogDensityID, fog.fogDensity.value);
        fogMaterial.SetFloat(FogStartID, fog.fogStart.value);
        fogMaterial.SetFloat(FogEndID, fog.fogEnd.value);
        fogMaterial.SetFloat(HeightFogDensityID, fog.heightFogDensity.value);
        fogMaterial.SetFloat(HeightFogBaseID, fog.heightFogBase.value);
        fogMaterial.SetFloat(HeightFogRangeID, fog.heightFogRange.value);
        
        // 颜色相关参数
        fogMaterial.SetColor(FogColorID, fog.fogColor.value);
        fogMaterial.SetColor(FogColorNearID, fog.fogColorNear.value);
        fogMaterial.SetColor(FogColorFarID, fog.fogColorFar.value);
        fogMaterial.SetFloat(GradientDistanceID, fog.gradientDistance.value);
        fogMaterial.SetFloat(UseGradientColorID, fog.useGradientColor.value ? 1f : 0f);
        
        fogMaterial.SetFloat(IntensityID, fog.intensity.value);
        fogMaterial.SetFloat(FastModeID, fog.useFastMode.value ? 1f : 0f);
        fogMaterial.SetFloat(NoiseScaleID, fog.noiseScale.value);
        fogMaterial.SetFloat(NoiseIntensityID, fog.noiseIntensity.value);
        fogMaterial.SetFloat(NoiseSpeedID, fog.noiseSpeed.value);
        
        // 设置shader关键字
        if (fog.useGradientColor.value)
            fogMaterial.EnableKeyword("_USE_GRADIENT_COLOR");
        else
            fogMaterial.DisableKeyword("_USE_GRADIENT_COLOR");
    }
    
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        // RTHandle cleanup is handled automatically
    }
    
    public void Dispose()
    {
        tempColorTexture?.Release();
    }
}