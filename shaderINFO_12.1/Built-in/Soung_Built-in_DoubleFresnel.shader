Shader "A201-Shader/Built-in/特殊制作/简易双层菲涅尔_Fresnel"
{
    Properties
    {
        [HDR]_RimColor ("边缘颜色", Color) = (1.0,1.0,1.0,1.0)
        [HDR]_InnerColor ("内部颜色", Color) = (1.0,1.0,1.0,1.0)
        _AlphaPower ("内部颜色范围", Range(0.0,8.0)) = 4.0
        _InnerColorPower ("内部颜色强度", Range(0.0,1.0)) = 0.5
        _RimPower ("边缘颜色范围", Range(0.0,5.0)) = 4
        _AllPower ("整体强度", Range(0.0, 10.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha One

        //surface着色器，此处不能使用Pass块
        CGPROGRAM
        #pragma surface surf Lambert alpha

        struct Input
        {
            float3 viewDir;
            INTERNAL_DATA
        };

        float4 _RimColor;
        float4 _InnerColor;
        half _AlphaPower;
        half _InnerColorPower;
        half _RimPower;
        half _AllPower;

        //边缘光计算
        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
            o.Emission = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
            o.Alpha = (pow (rim, _AlphaPower))*_AllPower;
        }
        ENDCG
    }
    Fallback "Off"
}
