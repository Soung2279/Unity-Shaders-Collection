Shader "A201-Shader/特殊制作/基础卡通着色器_ToonTest_Built-in"
{
Properties
    {   
        _WebSite("此Shader教程地址：zhuanlan.zhihu.com/p/362441075", Int) = 362441075
        [Header(__________________________________________________________________________________________)]
        _Color("基础颜色", Color) = (1,1,1,1)
        _MainTex("基础贴图(RGB)", 2D) = "white" {}
        [Normal]_Normal("法线贴图", 2D) = "bump" {}
        _LightCutoff("Light cutoff", Range(0,1)) = 0.5
        _ShadowBands("Shadow bands", Range(1,4)) = 1

        [Header(Specular)]
        _SpecularMap("Specular map", 2D) = "white" {}
        _Glossiness("光滑度", Range(0,1)) = 0.5
        [HDR]_SpecularColor("Specular color", Color) = (0,0,0,1)

        [Header(Rim)]
        _RimSize("描边大小", Range(0,1)) = 0
        [HDR]_RimColor("描边颜色", Color) = (0,0,0,1)
        [Toggle(SHADOWED_RIM)]
        _ShadowedRim("Rim affected by shadow", float) = 0

        [Header(Emission)]
        [HDR]_Emission("自发光颜色", Color) = (0,0,0,1)
    }
SubShader
    {
      Tags { "RenderType" = "Opaque" }
    Pass
    {
                Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM

                #pragma multi_compile_fwdbase
                #pragma shader_feature SHADOWED_RIM
                #pragma target 3.0

                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                #include "AutoLight.cginc"
                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _Normal;
                float _LightCutoff;
                float _ShadowBands;

                sampler2D _SpecularMap;
                float4 _SpecularMap_ST;
                half _Glossiness;
                fixed4 _SpecularColor;
  
                float _RimSize;
                fixed4 _RimColor;

                fixed4 _Emission;
                struct a2v {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float4 texcoord : TEXCOORD0;
                };
                struct v2f {
                    float4 pos : SV_POSITION;
                    float4 uv : TEXCOORD0;
                    float4 TtoW0 : TEXCOORD1;
                    float4 TtoW1 : TEXCOORD2;
                    float4 TtoW2 : TEXCOORD3;
                    SHADOW_COORDS(4)
                };
                v2f vert(a2v v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    o.uv.zw = v.texcoord.xy * _SpecularMap_ST.xy + _SpecularMap_ST.zw;

                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                    fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                    o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                    o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                    o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                    TRANSFER_SHADOW(o);

                    return o;
                }
                half4 frag(v2f i) : SV_Target{
                 float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                 fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                 fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                 fixed3 normal = UnpackNormal(tex2D(_Normal, i.uv.xy));
                 normal = normalize(half3(dot(i.TtoW0.xyz, normal), dot(i.TtoW1.xyz, normal), dot(i.TtoW2.xyz, normal)));
                 half nDotL = saturate(dot(normal, lightDir));
                 half diff = round(saturate(nDotL / _LightCutoff) * _ShadowBands) / _ShadowBands;

                 UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                 half stepAtten = round(atten);
                 half shadow = diff * stepAtten;
                 float3 refl = reflect(lightDir, normal);
                 float vDotRefl = dot(viewDir, -refl);
                 float smoothness = tex2D(_SpecularMap, i.uv.zw).x * _Glossiness;
                 float3 specular = _SpecularColor.rgb * step(1 - smoothness, vDotRefl);
                 //float3 rim = _RimColor * step(1 - _RimSize, 1 - saturate(dot(viewDir, normal)));
                 float3 rim = _RimColor * (step(1 - _RimSize, 1 - saturate(dot(viewDir, normal))) * -1);
                 fixed4 albedo = tex2D(_MainTex, i.uv.xy) * _Color;
                 half3 col = (albedo.rgb + specular) * _LightColor0;
                 half4 c;

                 #ifdef SHADOWED_RIM
                 c.rgb = (col + rim) * shadow;
                 #else
                 c.rgb = col * shadow + rim;
                 #endif
                 c.a = albedo.a;
                 c.rgb = c.rgb + albedo.rgb * _Emission.rgb;

                 return c;

                }
                ENDCG
             }
        }
        FallBack "Diffuse"
}