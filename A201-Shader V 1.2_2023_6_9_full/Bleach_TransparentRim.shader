Shader "A201-Shader/特殊制作/菲涅尔边缘光_TransparentRim" {
Properties {


_RimColor ("边缘颜色", Color) = (0.5,0.5,0.5,0.5)
_InnerColor ("内部颜色", Color) = (0.5,0.5,0.5,0.5)
_InnerColorPower ("内部颜色强度", Range(0.0,1.0)) = 0.5
_RimPower ("边缘颜色强度", Range(0.0,5.0)) = 2.5
_AlphaPower ("边缘颜色透明度", Range(0.0,8.0)) = 4.0
_AllPower ("整体强度", Range(0.0, 10.0)) = 1.0


}
SubShader {
Tags { "Queue" = "Transparent" }

CGPROGRAM
#pragma surface surf Lambert alpha
struct Input {
float3 viewDir;
INTERNAL_DATA
};
float4 _RimColor;
float _RimPower;
float _AlphaPower;
float _AlphaMin;
float _InnerColorPower;
float _AllPower;
float4 _InnerColor;
void surf (Input IN, inout SurfaceOutput o) {
half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
o.Emission = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
o.Alpha = (pow (rim, _AlphaPower))*_AllPower;
}
ENDCG
}
Fallback "VertexLit"
} 