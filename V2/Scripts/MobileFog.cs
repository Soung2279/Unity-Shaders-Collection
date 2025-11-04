using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("Post-processing/Mobile Fog")]
public class MobileFog : VolumeComponent, IPostProcessComponent
{
    [Header("深度雾设置")]
    [Tooltip("深度雾密度")]
    public ClampedFloatParameter fogDensity = new ClampedFloatParameter(0f, 0f, 1f);
    
    [Tooltip("深度雾开始距离")]
    public FloatParameter fogStart = new FloatParameter(0f);
    
    [Tooltip("深度雾结束距离")]
    public FloatParameter fogEnd = new FloatParameter(100f);
    
    [Header("高度雾设置")]
    [Tooltip("高度雾密度")]
    public ClampedFloatParameter heightFogDensity = new ClampedFloatParameter(0f, 0f, 1f);
    
    [Tooltip("高度雾基础高度")]
    public FloatParameter heightFogBase = new FloatParameter(0f);
    
    [Tooltip("高度雾影响范围")]
    public FloatParameter heightFogRange = new FloatParameter(50f);
    
    [Header("噪波设置")]
    [Tooltip("噪波缩放")]
    public FloatParameter noiseScale = new FloatParameter(0.01f);
    
    [Tooltip("噪波强度")]
    public ClampedFloatParameter noiseIntensity = new ClampedFloatParameter(5f, 0f, 20f);
    
    [Tooltip("噪波动画速度")]
    public FloatParameter noiseSpeed = new FloatParameter(0.1f);
    
    [Header("雾效外观")]
    [Tooltip("是否启用渐变色")]
    public BoolParameter useGradientColor = new BoolParameter(false);
    
    [Tooltip("雾的固定颜色（不使用渐变时）")]
    public ColorParameter fogColor = new ColorParameter(Color.gray);
    
    [Tooltip("近处雾的颜色")]
    public ColorParameter fogColorNear = new ColorParameter(new Color(0.8f, 0.9f, 1f, 1f)); // 偏蓝的近景色
    
    [Tooltip("远处雾的颜色")]
    public ColorParameter fogColorFar = new ColorParameter(new Color(0.6f, 0.7f, 0.9f, 1f)); // 偏紫的远景色
    
    [Tooltip("渐变过渡距离")]
    public FloatParameter gradientDistance = new FloatParameter(100f);
    
    [Tooltip("雾效强度")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(1f, 0f, 1f);
    
    [Header("移动端优化")]
    [Tooltip("使用快速模式（降低质量提升性能）")]
    public BoolParameter useFastMode = new BoolParameter(true);
    
    public bool IsActive() => (fogDensity.value > 0f || heightFogDensity.value > 0f) && intensity.value > 0f;
    public bool IsTileCompatible() => false;
}