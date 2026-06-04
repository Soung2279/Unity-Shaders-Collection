//创建于2026.3.30
Shader "Soung/UI/SingleTexMaskable"
{
    Properties
    {
        _MainTex("贴图", 2D) = "white" {}
        [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(AlphaBlend,10,Additive,1)]_BlendMode("混合模式", Float) = 1
        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 0
        [IntRange]_RotatorVal("贴图旋转", Range(0, 360)) = 0
        _TexScale("贴图缩放", Range(0, 5)) = 1

        [HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull [_CullingMode]
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"

            CGPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 mask : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _TextureSampleAdd;
            float4 _MainTex_ST;
            float4 _ClipRect;
            fixed4 _BaseColor;
            float _RotatorVal;
            float _TexScale;
            float _SwitchP;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            float2 RotateUV(float2 uv, float angleDegrees)
            {
                float angle = radians(angleDegrees);
                float s;
                float c;
                sincos(angle, s, c);
                float2 centeredUV = uv - float2(0.5, 0.5);
                float2 rotatedUV = float2(centeredUV.x * c - centeredUV.y * s, centeredUV.x * s + centeredUV.y * c);
                return rotatedUV + float2(0.5, 0.5);
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.vertex = vPosition;
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                OUT.mask = float4(
                    v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw,
                    0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy))
                );

                OUT.color = v.color * _BaseColor;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0 / alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision) * invAlphaPrecision;

                float2 finalUV;
                if (abs(_RotatorVal) > 0.001)
                {
                    finalUV = RotateUV(IN.texcoord, _RotatorVal);
                }
                else
                {
                    finalUV = IN.texcoord;
                }

                finalUV = (finalUV * _TexScale) - (_TexScale * 0.5) + 0.5;

                fixed4 texColor = tex2D(_MainTex, finalUV) + _TextureSampleAdd;
                half textureChannelAlpha = lerp(texColor.r, texColor.a, _SwitchP);

                half3 finalColor = texColor.rgb * IN.color.rgb;

                half alpha = textureChannelAlpha * IN.color.a;

                #ifdef UNITY_UI_CLIP_RECT
                    half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                    alpha *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                    clip(alpha - 0.001);
                #endif

                if (alpha <= 0.001)
                {
                    discard;
                }

                return fixed4(finalColor, saturate(alpha));
            }
            ENDCG
        }
    }
}
