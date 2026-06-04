Shader "Soung/Effect/ScreenSimpleFX"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _CullingMode( "剔除模式", Float ) = 0
        [Enum(Additive,1,AlphaBlend,10)] _BlendMode( "混合模式", Float ) = 10
        [HDR] _ColorA( "渐变起始颜色A", Color ) = ( 1, 1, 1, 1 )
        [HDR] _ColorB( "渐变结束颜色B", Color ) = ( 1, 1, 1, 1 )
        _ColorSpeed( "颜色变化速度", Float ) = 1
        _MainTex( "贴图", 2D ) = "white" {}
        [Enum(R,0,A,1)] _MainTexP( "贴图通道", Float ) = 0
        [IntRange] _MainTexRotatorValue( "贴图旋转", Range( 0, 360 ) ) = 0
        [KeywordEnum( Local,Polar,Screen )] _UVSampleMode( "UV采样模式", Float ) = 0
        _PolarSettings( "极坐标中心/横纵速度", Vector ) = ( 0.5, 0.5, 1, 1 )
        _ScreenTillings( "屏幕采样偏移", Vector ) = ( 1, 1, 0, 0 )
        _MainTexUSpeed( "U流动速度", Float ) = 0
        _MainTexVSpeed( "V流动速度", Float ) = 0
        [Enum(EdgeFade,0,CenterFade,1)] _MaskMode( "遮罩模式", Float ) = 0
        [Enum(Circle,0,Square,1)] _MaskShape( "遮罩形状", Float ) = 0
        _MaskRange( "遮罩范围", Range(0, 1) ) = 0.5
        _MaskSoftness( "遮罩软化", Range(0, 1) ) = 0.1
        [Toggle(_NOISE_ON)] _NoiseEnable( "程序扰动开启", Float ) = 0
        _NoiseScale( "噪波缩放", Float ) = 5
        _NoiseStrength( "扰动强度", Range(0, 5) ) = 0.1
        _NoiseSpeed( "噪波速度", Float ) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

        Cull [_CullingMode]
        AlphaToMask Off

        Pass
        {
            Name "Forward"
            Tags { "LightMode"="Universal2D" }

            Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            ColorMask RGBA

            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _UVSAMPLEMODE_LOCAL _UVSAMPLEMODE_POLAR _UVSAMPLEMODE_SCREEN
            #pragma shader_feature_local _NOISE_ON

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorA;
                float4 _ColorB;
                float _ColorSpeed;
                float4 _MainTex_ST;
                float4 _PolarSettings;
                float4 _ScreenTillings;
                float _MainTexUSpeed;
                float _MainTexVSpeed;
                float _MainTexRotatorValue;
                float _MainTexP;
                float _MaskMode;
                float _MaskShape;
                float _MaskRange;
                float _MaskSoftness;
                float _NoiseScale;
                float _NoiseStrength;
                float _NoiseSpeed;
            CBUFFER_END

            sampler2D _MainTex;

            float2 VoronoiDistortion(float2 uv, float scale, float speed, float time)
            {
                uv = uv * scale + time * speed;
                float2 i = floor(uv);
                float2 f = frac(uv);
                // smoothstep 平滑插值，保证 C1 连续
                float2 u = f * f * (3.0 - 2.0 * f);

                // X 通道噪声
                float ax = frac(sin(dot(i,               float2(127.1, 311.7))) * 43758.5453);
                float bx = frac(sin(dot(i + float2(1,0), float2(127.1, 311.7))) * 43758.5453);
                float cx = frac(sin(dot(i + float2(0,1), float2(127.1, 311.7))) * 43758.5453);
                float dx = frac(sin(dot(i + float2(1,1), float2(127.1, 311.7))) * 43758.5453);
                float nx = lerp(lerp(ax, bx, u.x), lerp(cx, dx, u.x), u.y);

                // Y 通道噪声（不同哈希参数）
                float ay = frac(sin(dot(i,               float2(269.5, 183.3))) * 43758.5453);
                float by = frac(sin(dot(i + float2(1,0), float2(269.5, 183.3))) * 43758.5453);
                float cy = frac(sin(dot(i + float2(0,1), float2(269.5, 183.3))) * 43758.5453);
                float dy = frac(sin(dot(i + float2(1,1), float2(269.5, 183.3))) * 43758.5453);
                float ny = lerp(lerp(ay, by, u.x), lerp(cy, dy, u.x), u.y);

                return float2(nx, ny) * 2.0 - 1.0;
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color      : COLOR;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color      : COLOR;
                float2 uv         : TEXCOORD0;
                float4 screenPos  : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.color      = input.color;
                output.uv         = input.uv;
                output.screenPos  = ComputeScreenPos(output.positionCS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // ---- UV 计算 ----
                float2 localUV = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                #if defined(_UVSAMPLEMODE_POLAR)
                    float2 delta = localUV - float2(_PolarSettings.x, _PolarSettings.y);
                    float2 sampleUV = float2(
                        _PolarSettings.z * (length(delta) * 2.0),
                        (atan2(delta.x, delta.y) * (1.0 / TWO_PI)) * _PolarSettings.w
                    );
                #elif defined(_UVSAMPLEMODE_SCREEN)
                    float2 screenNorm = (input.screenPos.xy / input.screenPos.w);
                    float2 sampleUV = screenNorm * _ScreenTillings.xy + _ScreenTillings.zw;
                #else
                    float2 sampleUV = localUV;
                #endif

                // ---- Voronoi UV扰动 ----
                #if defined(_NOISE_ON)
                    sampleUV += VoronoiDistortion(sampleUV, _NoiseScale, _NoiseSpeed, _Time.y) * _NoiseStrength;
                #endif

                // ---- 旋转 + 流动 ----
                float rotRad = (_MainTexRotatorValue * PI) / 180.0;
                float2 pivot = float2(0.5, 0.5);
                float cosA = cos(rotRad);
                float sinA = sin(rotRad);
                float2 rotated = mul(sampleUV - pivot, float2x2(cosA, -sinA, sinA, cosA)) + pivot;
                float2 finalUV = rotated + float2(_MainTexUSpeed, _MainTexVSpeed) * _Time.y;

                // ---- 采样 ----
                float4 texColor = tex2D(_MainTex, finalUV);

                float alpha = lerp(texColor.r, texColor.a, _MainTexP);
                float colorT = sin(_Time.y * _ColorSpeed) * 0.5 + 0.5;
                float4 baseColor = lerp(_ColorA, _ColorB, colorT);
                float3 color = (input.color * float4(baseColor.rgb, 0.0) * float4(texColor.rgb, 0.0)).rgb;

                // ---- 程序遮罩 ----
                float2 maskUV = input.uv - 0.5;
                float distCircle = length(maskUV);
                float distSquare = max(abs(maskUV.x), abs(maskUV.y));
                float dist = lerp(distCircle, distSquare, _MaskShape);
                float half_soft = _MaskSoftness * 0.5;
                float mask = smoothstep(_MaskRange - half_soft, _MaskRange + half_soft, dist);
                alpha *= lerp(mask, 1.0 - mask, _MaskMode);

                return half4(color, alpha);
            }
            ENDHLSL
        }
    }


    FallBack Off
}
