//2026.4.24 created by Soung
Shader "Soung/Effect/ScreenFx"
{
    Properties
    {
        [Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(ON,1,OFF,0)]_Zwrite("深度写入", Float) = 0
        [Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
        [Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1

        [Header(MainTex)]_MainTex("主贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_MainTexP("主帖图通道", Float) = 0
        [HDR]_MainColor("主帖图颜色", Color) = (1,1,1,1)
        [IntRange]_MainTexRotator("主帖图旋转", Range( 0 , 360)) = 0
        [Toggle(_USE_HSV_ON)]_UseHSV("主帖图启用HSV色相调整", Float) = 0
        _MainTexHue("主帖图色相变换", Range( 0 , 1)) = 0
        _MainTexSaturation("主帖图饱和度", Range( 0 , 1.5)) = 1
        [Enum(Material,0,Custom1xy,1)]_MainTexFlowMode("主帖图流动模式", Float) = 0
        [Enum(Repeat,0,Clamp,1)]_MainTexClamp("主帖图重铺模式", Float) = 0
        [KeywordEnum(Local,Polar,Screen)] _MainTexUVMode("主帖图UV模式", Float) = 0
        _MainTexPolarSets("主帖图Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _MainTexScreenTilingOffset("主帖图Screen重铺与偏移", Vector) = (1,1,0,0)
        _MainTexUspeed("主帖图U速率", Float) = 0
        _MainTexVspeed("主帖图V速率", Float) = 0

        [Header(NoiseTex)][Enum(OFF,0,ON,1)]_NoiseSwitch("扭曲开关", Float) = 0
        _NoiseTex("扭曲贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_NoiseTexP("扭曲贴图通道", Float) = 0
        _NoisePower("扭曲强度", Range( 0 , 1)) = 0
        [Toggle]_NoiseEffLiuguang("扭曲是否影响流光", Float) = 0
        [Toggle]_NoiseEffDissolve("扭曲是否影响溶解", Float) = 0
        [KeywordEnum(Local,Polar,Screen)] _NoiseTexUVMode("扭曲贴图UV模式", Float) = 0
        _NoiseTexPolarSets("扭曲Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _NoiseTexScreenTilingOffset("扭曲Screen重铺与偏移", Vector) = (1,1,0,0)
        _NoiseTexUspeed("扭曲U速率", Float) = 0
        _NoiseTexVspeed("扭曲V速率", Float) = 0

        [Header(ProgramMask)][Enum(ON,0,OFF,1)]_ProMaskSwitch("程序遮罩开关", Float) = 0
        [KeywordEnum(UP,DOWN,LEFT,RIGHT)] _ProMaskDir("程序遮罩方向", Float) = 0
        _ProMaskRange("程序遮罩范围", Range( 1 , 8)) = 1

        [Header(MaskTex)][Enum(OFF,0,ON,1)]_MaskSwitch("遮罩开关", Float) = 0
        _MaskTex("遮罩贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_MaskTexP("遮罩贴图通道", Float) = 0
        [IntRange]_MaskTexRotator("遮罩贴图旋转", Range( 0 , 360)) = 0
        [Enum(OFF,0,ON,1)]_OneMinusMask("反相遮罩", Float) = 0
        [Enum(Repeat,0,Clamp,1)]_MaskTexClamp("遮罩贴图重铺模式", Float) = 0
        [Enum(Material,0,Custom2xy,1)]_MaskTexFlowMode("遮罩帖图流动模式", Float) = 0
        _MaskTexUspeed("遮罩U速度", Float) = 0
        _MaskTexVspeed("遮罩V速度", Float) = 0

        [Header(MaskTexPlus)][Enum(OFF,0,ON,1)]_MaskTexPlusSwitch("额外遮罩开关", Float) = 0
        [Toggle]_MaskPlusUsePro("额外遮罩使用程序", Float) = 0
        _MaskTexPlus("额外遮罩", 2D) = "white" {}
        [Enum(R,0,A,1)]_MaskTexPlusP("额外遮罩通道", Float) = 0
        [IntRange]_MaskTexPlusRotator("额外遮罩旋转", Range( 0 , 360)) = 0
        [Enum(Repeat,0,Clamp,1)]_MaskTexPlusClamp("额外遮罩重铺模式", Float) = 0
        _MaskTexPlusUspeed("额外遮罩U速度", Float) = 0
        _MaskTexPlusVspeed("额外遮罩V速度", Float) = 0

        [Header(Liuguang)][Enum(OFF,0,ON,1)]_LiuguangSwitch("流光开关", Float) = 0
        _LiuguangTex("流光贴图", 2D) = "black" {}
        [Enum(R,0,A,1)]_LiuguangTexP("流光纹理通道", Float) = 0
        [IntRange]_LiuguangTexRotator("流光纹理旋转", Range( 0 , 360)) = 0
        [Toggle]_UseLGTexColor("是否禁用流光自身颜色", Float) = 1
        [HDR]_LiuguangColor("流光颜色", Color) = (0,0,0,1)
        [KeywordEnum(Local,Polar,Screen)] _LiuguangTexUVmode("流光UV模式", Float) = 0
        _LiuguangPolarScale("流光Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _LiuguangScreenTilingOffset("流光Screen重铺与偏移", Vector) = (1,1,0,0)
        _LiuguangUSpeed("流光U速率", Float) = 0
        _LiuguangVSpeed("流光V速率", Float) = 0

        [Header(DissolveTex)][Enum(OFF,0,ON,1)]_DissolveTexSwitch("溶解开关", Float) = 0
        _DissolveTex("溶解贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_DissolveTexP("溶解贴图通道", Float) = 0
        [IntRange]_DissolveTexRotator("溶解贴图旋转", Range( 0 , 360)) = 0
        _DissolveSmooth("溶解平滑度", Range( 0 , 1)) = 0
        _DissolvePower("溶解进度", Range( 0 , 2)) = 0.3787051
        [Enum(Material,0,Custom1z,1)]_DissolveMode("溶解控制模式", Float) = 0
        [Enum(Soft,0,Edge,1)]_DissolveEdgeSwitch("溶解边缘模式", Float) = 0
        [HDR]_DissolveEdgeColor("溶解边缘颜色", Color) = (1,0.4109318,0,1)
        [Enum(Mult,0,Add,1)]_DissolveColorMode("溶解颜色混合模式", Float) = 0
        _DissolveEdgeWide("溶解边缘宽度", Range( 0 , 1)) = 0.1420648
        [KeywordEnum(Local,Polar,Screen)] _DissolveTexUVMode("溶解贴图UV模式", Float) = 0
        _DissolveTexPolarSets("溶解Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _DissolveTexScreenTilingOffset("溶解Screen重铺与偏移", Vector) = (1,1,0,0)
        _DissolveTexUspeed("溶解U速度", Float) = 0
        _DissolveTexVspeed("溶解V速度", Float) = 0

        [Header(DissloveTexPath)][Enum(OFF,0,ON,1)]_DissolveTexPlusSwitch("定向溶解开关", Float) = 0
        [Toggle]_DissolveTexPlusUsePro("定向溶解使用程序遮罩", Float) = 0
        _DissolveTexPlus("定向溶解贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_DissolveTexPlusP("定向溶解通道", Float) = 0
        [IntRange]_DissolveTexPlusRotator("定向溶解旋转", Range( 0 , 360)) = 0
        _DissolveTexPlusPower("定向溶解强度", Range( 1 , 7)) = 1
        [Enum(Material,0,Custome2xy,1)]_DissolveTexPlusFlowMode("定向溶解流动模式", Float) = 0
        [Enum(Repeat,0,Clmap,1)]_DissolveTexPlusClamp("定向溶解重铺模式", Float) = 0
        _DissolveTexPlusUspeed("定向溶解U速度", Float) = 0
        _DissolveTexPlusVspeed("定向溶解V速度", Float) = 0
    }

    SubShader
    {
        LOD 0

        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

        Cull [_CullingMode]
        AlphaToMask Off

        HLSLINCLUDE
        #pragma target 3.0

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        ENDHLSL

        Pass
        {
            Name "Universal2D"
            Tags { "LightMode"="Universal2D" }

            Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
            ZWrite [_Zwrite]
            ZTest [_ZTestMode]
            Offset 0 , 0
            ColorMask RGBA

            HLSLPROGRAM

            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            #pragma shader_feature_local _PROMASKDIR_UP _PROMASKDIR_DOWN _PROMASKDIR_LEFT _PROMASKDIR_RIGHT
            #pragma shader_feature_local _MAINTEXUVMODE_LOCAL _MAINTEXUVMODE_POLAR _MAINTEXUVMODE_SCREEN
            #pragma shader_feature_local _NOISETEXUVMODE_LOCAL _NOISETEXUVMODE_POLAR _NOISETEXUVMODE_SCREEN
            #pragma shader_feature_local _DISSOLVETEXUVMODE_LOCAL _DISSOLVETEXUVMODE_POLAR _DISSOLVETEXUVMODE_SCREEN
            #pragma shader_feature_local _LIUGUANGTEXUVMODE_LOCAL _LIUGUANGTEXUVMODE_POLAR _LIUGUANGTEXUVMODE_SCREEN
            #pragma shader_feature_local _USE_HSV_ON

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 texcoord   : TEXCOORD0;   // UV0
                float4 texcoord1  : TEXCOORD1;   // Custom1.xyzw
                float4 texcoord2  : TEXCOORD2;   // Custom2.xy
                float4 ase_color  : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct PackedVaryings
            {
                float4 positionCS      : SV_POSITION;
                float4 clipPosV        : TEXCOORD0;   // 保留完整 clip-space 坐标（含 clip_w）
                float4 ase_texcoord6   : TEXCOORD1;   // UV0
                float4 ase_texcoord7   : TEXCOORD2;   // Custom1.xyzw
                float4 ase_color       : COLOR;
                float4 ase_texcoord8   : TEXCOORD3;   // Custom2.xy
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _MainColor;
                float4 _MainTexPolarSets;
                float4 _MainTexScreenTilingOffset;
                float4 _NoiseTex_ST;
                float4 _NoiseTexPolarSets;
                float4 _NoiseTexScreenTilingOffset;
                float4 _MaskTex_ST;
                float4 _MaskTexPlus_ST;
                float4 _LiuguangTex_ST;
                float4 _LiuguangColor;
                float4 _LiuguangPolarScale;
                float4 _LiuguangScreenTilingOffset;
                float4 _DissolveTex_ST;
                float4 _DissolveEdgeColor;
                float4 _DissolveTexPolarSets;
                float4 _DissolveTexScreenTilingOffset;
                float4 _DissolveTexPlus_ST;

                float _CullingMode;
                float _Zwrite;
                float _ZTestMode;
                float _BlendMode;

                float _MainTexP;
                float _MainTexRotator;
                float _MainTexHue;
                float _MainTexSaturation;
                float _MainTexFlowMode;
                float _MainTexClamp;
                float _MainTexUspeed;
                float _MainTexVspeed;

                float _NoiseSwitch;
                float _NoisePower;
                float _NoiseTexP;
                float _NoiseTexUspeed;
                float _NoiseTexVspeed;
                float _NoiseEffLiuguang;
                float _NoiseEffDissolve;

                float _MaskSwitch;
                float _MaskTexP;
                float _MaskTexRotator;
                float _OneMinusMask;
                float _MaskTexClamp;
                float _MaskTexFlowMode;
                float _MaskTexUspeed;
                float _MaskTexVspeed;

                float _MaskTexPlusSwitch;
                float _MaskPlusUsePro;
                float _MaskTexPlusP;
                float _MaskTexPlusClamp;
                float _MaskTexPlusRotator;
                float _MaskTexPlusUspeed;
                float _MaskTexPlusVspeed;

                float _ProMaskSwitch;
                float _ProMaskRange;

                float _LiuguangSwitch;
                float _LiuguangTexP;
                float _LiuguangTexRotator;
                float _UseLGTexColor;
                float _LiuguangUSpeed;
                float _LiuguangVSpeed;

                float _DissolveTexSwitch;
                float _DissolveTexP;
                float _DissolveTexRotator;
                float _DissolveSmooth;
                float _DissolveMode;
                float _DissolvePower;
                float _DissolveEdgeSwitch;
                float _DissolveEdgeWide;
                float _DissolveTexUspeed;
                float _DissolveTexVspeed;
                float _DissolveColorMode;

                float _DissolveTexPlusSwitch;
                float _DissolveTexPlusUsePro;
                float _DissolveTexPlusP;
                float _DissolveTexPlusRotator;
                float _DissolveTexPlusPower;
                float _DissolveTexPlusFlowMode;
                float _DissolveTexPlusClamp;
                float _DissolveTexPlusUspeed;
                float _DissolveTexPlusVspeed;
            CBUFFER_END

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _DissolveTex;
            sampler2D _DissolveTexPlus;
            sampler2D _LiuguangTex;
            sampler2D _MaskTex;
            sampler2D _MaskTexPlus;

            #if defined(_USE_HSV_ON)
            float3 HSVToRGB( float3 c )
            {
                float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
                float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
                return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
            }
            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
                float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
                float d = q.x - min( q.w, q.y );
                float e = 1.0e-10;
                return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }
            #endif

            inline float2 RotateUV(float2 uv, float angleDeg)
            {
                float rad = (angleDeg * PI) / 180.0;
                float c = cos(rad);
                float s = sin(rad);
                float2 d = uv - float2(0.5, 0.5);
                return float2(d.x * c + d.y * s, d.x * (-s) + d.y * c) + float2(0.5, 0.5);
            }

            // 将 clip-space 坐标转换为屏幕抓取坐标（处理 DX/GL Y 轴翻转）
            inline float4 ASE_ComputeGrabScreenPos( float4 pos )
            {
                #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                #else
                float scale = 1.0;
                #endif
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
                return o;
            }

            // 从 Local UV 计算 Polar UV
            inline float2 ComputePolarUV(float2 uv, float4 polarSets)
            {
                float2 center = float2(polarSets.x, polarSets.y);
                float2 d = uv - center;
                return float2(
                    polarSets.z * (length(d) * 2.0),
                    (atan2(d.x, d.y) * (1.0 / TWO_PI)) * polarSets.w
                );
            }

            PackedVaryings vert( Attributes input )
            {
                PackedVaryings output = (PackedVaryings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.ase_texcoord6.xy = input.texcoord.xy;
                output.ase_texcoord6.zw = 0;
                output.ase_texcoord7    = input.texcoord1;
                output.ase_color        = input.ase_color;
                output.ase_texcoord8    = input.texcoord2;

                VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
                output.positionCS = vertexInput.positionCS;
                output.clipPosV   = vertexInput.positionCS;
                return output;
            }

            half4 frag( PackedVaryings input ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 屏幕 UV（仅 Screen 模式贴图使用，避免移动端冗余透视除法）
                #if defined(_MAINTEXUVMODE_SCREEN) || defined(_NOISETEXUVMODE_SCREEN) || defined(_DISSOLVETEXUVMODE_SCREEN) || defined(_LIUGUANGTEXUVMODE_SCREEN)
                float4 grabScreenPos = ASE_ComputeGrabScreenPos( ComputeScreenPos( input.clipPosV ) );
                float2 screenUV      = grabScreenPos.rg / grabScreenPos.w;
                #else
                float2 screenUV      = float2(0.0, 0.0);
                #endif

                float2 uv0 = input.ase_texcoord6.xy;
                float4 c1  = input.ase_texcoord7;    // Custom1: xy=流动偏移, z=溶解控制
                float2 c2  = input.ase_texcoord8.xy; // Custom2: 遮罩/定向溶解流动

                // ── 扭曲 ─────────────────────────────────────────────────────
                float noiseOffset = 0.0;
                if (_NoiseSwitch > 0.01)
                {
                    float2 uv_NoiseTex = uv0 * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                    #if defined(_NOISETEXUVMODE_POLAR)
                    float2 noiseBaseUV = ComputePolarUV(uv_NoiseTex, _NoiseTexPolarSets);
                    #elif defined(_NOISETEXUVMODE_SCREEN)
                    float2 noiseBaseUV = screenUV * _NoiseTexScreenTilingOffset.xy + _NoiseTexScreenTilingOffset.zw;
                    #else
                    float2 noiseBaseUV = uv_NoiseTex;
                    #endif
                    float4 noiseSamp = tex2D(_NoiseTex, _Time.y * float2(_NoiseTexUspeed, _NoiseTexVspeed) + noiseBaseUV);
                    noiseOffset = (lerp(noiseSamp.r, noiseSamp.a, _NoiseTexP) - 0.5) * _NoisePower;
                }

                // ── 主贴图 ───────────────────────────────────────────────────
                float2 uv_MainTex = uv0 * _MainTex_ST.xy + _MainTex_ST.zw;
                #if defined(_MAINTEXUVMODE_POLAR)
                float2 mainBaseUV = ComputePolarUV(uv_MainTex, _MainTexPolarSets);
                #elif defined(_MAINTEXUVMODE_SCREEN)
                float2 mainBaseUV = screenUV * _MainTexScreenTilingOffset.xy + _MainTexScreenTilingOffset.zw;
                #else
                float2 mainBaseUV = uv_MainTex;
                #endif
                float2 mainFlowUV   = lerp(_Time.y * float2(_MainTexUspeed, _MainTexVspeed) + mainBaseUV,
                                           mainBaseUV + c1.xy, _MainTexFlowMode);
                float2 mainRotUV    = RotateUV(noiseOffset + mainFlowUV, _MainTexRotator);
                float2 mainSampleUV = lerp(mainRotUV, saturate(mainRotUV), _MainTexClamp);
                float4 mainTex      = tex2D(_MainTex, mainSampleUV);

                #if defined(_USE_HSV_ON)
                float3 mainHSV  = RGBToHSV(mainTex.rgb);
                float3 mainRGB  = HSVToRGB(float3(_MainTexHue + mainHSV.x, mainHSV.y * _MainTexSaturation, mainHSV.z));
                float4 mainColor = _MainColor * float4(mainRGB, 0.0);
                #else
                float4 mainColor = _MainColor * float4(mainTex.rgb, 0.0);
                #endif

                // ── 溶解贴图 ─────────────────────────────────────────────────
                float dissolveThreshold = lerp(_DissolvePower, c1.z, _DissolveMode);

                float4 dissolveTex = float4(0, 0, 0, 0);
                if (_DissolveTexSwitch > 0.01)
                {
                    float2 uv_DissolveTex = uv0 * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                    #if defined(_DISSOLVETEXUVMODE_POLAR)
                    float2 dissolveBaseUV = ComputePolarUV(uv_DissolveTex, _DissolveTexPolarSets);
                    #elif defined(_DISSOLVETEXUVMODE_SCREEN)
                    float2 dissolveBaseUV = screenUV * _DissolveTexScreenTilingOffset.xy + _DissolveTexScreenTilingOffset.zw;
                    #else
                    float2 dissolveBaseUV = uv_DissolveTex;
                    #endif
                    float2 dissolveNoiseOff = float2(noiseOffset, -noiseOffset) * _NoiseEffDissolve;
                    float2 dissolveRotUV    = RotateUV(_Time.y * float2(_DissolveTexUspeed, _DissolveTexVspeed)
                                                       + dissolveBaseUV + dissolveNoiseOff, _DissolveTexRotator);
                    dissolveTex = tex2D(_DissolveTex, dissolveRotUV);
                }
                float dissolveGray = lerp(dissolveTex.r, dissolveTex.a, _DissolveTexP);

                // ── 定向溶解贴图 ─────────────────────────────────────────────
                float2 uv_DissolveTexPlus   = uv0 * _DissolveTexPlus_ST.xy + _DissolveTexPlus_ST.zw;
                float2 dissolvePathSpeed    = lerp(float2(_DissolveTexPlusUspeed, _DissolveTexPlusVspeed),
                                                   float2(_DissolveTexPlusUspeed, _DissolveTexPlusVspeed) + c2,
                                                   _DissolveTexPlusFlowMode);
                float2 dissolvePathUV       = _Time.y * dissolvePathSpeed + uv_DissolveTexPlus;

                float4 dissolvePathTex = float4(0, 0, 0, 0);
                if (_DissolveTexPlusSwitch > 0.01)
                {
                    float2 dissolvePathRotUV    = RotateUV(dissolvePathUV, _DissolveTexPlusRotator);
                    float2 dissolvePathSampleUV = lerp(dissolvePathRotUV, saturate(dissolvePathRotUV), _DissolveTexPlusClamp);
                    dissolvePathTex = tex2D(_DissolveTexPlus, dissolvePathSampleUV);
                }
                float dissolvePathGray = lerp(dissolvePathTex.r, dissolvePathTex.a, _DissolveTexPlusP);

                // ── 程序遮罩 ─────────────────────────────────────────────────
                #if defined(_PROMASKDIR_UP)
                float proMaskValue = 1.0 - uv0.y;
                #elif defined(_PROMASKDIR_DOWN)
                float proMaskValue = uv0.y;
                #elif defined(_PROMASKDIR_LEFT)
                float proMaskValue = uv0.x;
                #elif defined(_PROMASKDIR_RIGHT)
                float proMaskValue = 1.0 - uv0.x;
                #else
                float proMaskValue = 1.0 - uv0.y;
                #endif
                float proMask = lerp(saturate(smoothstep(0.0, _ProMaskRange, proMaskValue) * (_ProMaskRange / 0.4)),
                                     0.0, _ProMaskSwitch);

                // ── 溶解混合 ─────────────────────────────────────────────────
                float dissolveMixed  = lerp(dissolveGray,
                                            lerp(dissolvePathGray, proMask, _DissolveTexPlusUsePro),
                                            _DissolveTexPlusSwitch);
                float dissolveInput  = saturate((dissolveMixed + dissolveGray / _DissolveTexPlusPower) / 2.0);
                float dissolveStep   = smoothstep(dissolveThreshold - _DissolveSmooth, dissolveThreshold, dissolveInput);
                float4 dissolveEdge  = _DissolveEdgeColor * (step(dissolveThreshold - _DissolveEdgeWide, dissolveInput)
                                                            - step(dissolveThreshold, dissolveInput));
                float4 dissolveResult = lerp(dissolveStep.xxxx, dissolveStep + dissolveEdge, _DissolveEdgeSwitch);
                float3 dissolveColor  = lerp((1.0).xxx, dissolveResult.rgb, _DissolveTexSwitch);

                float4 baseColor     = mainColor * input.ase_color;
                float4 dissolvedColor = lerp(baseColor * float4(dissolveColor, 0.0),
                                             baseColor + dissolveEdge, _DissolveColorMode);

                // ── 流光 ─────────────────────────────────────────────────────
                float4 lgTex = float4(0, 0, 0, 0);
                if (_LiuguangSwitch > 0.01)
                {
                    float2 uv_LiuguangTex = uv0 * _LiuguangTex_ST.xy + _LiuguangTex_ST.zw;
                    #if defined(_LIUGUANGTEXUVMODE_POLAR)
                    float2 lgBaseUV = ComputePolarUV(uv_LiuguangTex, _LiuguangPolarScale);
                    #elif defined(_LIUGUANGTEXUVMODE_SCREEN)
                    float2 lgBaseUV = screenUV * _LiuguangScreenTilingOffset.xy + _LiuguangScreenTilingOffset.zw;
                    #else
                    float2 lgBaseUV = RotateUV(uv_LiuguangTex, _LiuguangTexRotator);
                    #endif
                    float2 lgSampleUV = _Time.y * float2(_LiuguangUSpeed, _LiuguangVSpeed) + lgBaseUV
                                       + float2(noiseOffset, -noiseOffset) * _NoiseEffLiuguang;
                    lgTex = tex2D(_LiuguangTex, lgSampleUV);
                }
                float  lgGray  = lerp(lgTex.r, lgTex.a, _LiuguangTexP);
                float4 lgColor = lerp(float4(lgTex.rgb * lgGray, 0.0) * _LiuguangColor,
                                      lgGray * _LiuguangColor, _UseLGTexColor);
                lgColor = lerp((0.0).xxxx, lgColor, _LiuguangSwitch);

                // ── 遮罩 ─────────────────────────────────────────────────────
                float2 uv_MaskTex = uv0 * _MaskTex_ST.xy + _MaskTex_ST.zw;
                float2 maskFlowUV = lerp(_Time.y * float2(_MaskTexUspeed, _MaskTexVspeed) + uv_MaskTex,
                                         uv_MaskTex + c2, _MaskTexFlowMode);
                float4 maskTex = float4(0, 0, 0, 0);
                if (_MaskSwitch > 0.01)
                {
                    float2 maskRotUV    = RotateUV(maskFlowUV, _MaskTexRotator);
                    float2 maskSampleUV = lerp(maskRotUV, saturate(maskRotUV), _MaskTexClamp);
                    maskTex = tex2D(_MaskTex, maskSampleUV);
                }
                float maskGray  = lerp(maskTex.r, maskTex.a, _MaskTexP);
                float maskAlpha = lerp(1.0, lerp(maskGray, smoothstep(1.0, -1.0, maskGray), _OneMinusMask), _MaskSwitch);

                // ── 额外遮罩 ─────────────────────────────────────────────────
                float2 uv_MaskTexPlus = uv0 * _MaskTexPlus_ST.xy + _MaskTexPlus_ST.zw;
                float2 maskPlusUV     = _Time.y * float2(_MaskTexPlusUspeed, _MaskTexPlusVspeed) + uv_MaskTexPlus;
                float4 maskPlusTex = float4(0, 0, 0, 0);
                if (_MaskTexPlusSwitch > 0.01)
                {
                    float2 maskPlusRotUV    = RotateUV(maskPlusUV, _MaskTexPlusRotator);
                    float2 maskPlusSampleUV = lerp(maskPlusRotUV, saturate(maskPlusRotUV), _MaskTexPlusClamp);
                    maskPlusTex = tex2D(_MaskTexPlus, maskPlusSampleUV);
                }
                float maskPlusGray  = lerp(maskPlusTex.r, maskPlusTex.a, _MaskTexPlusP);
                float maskPlusAlpha = lerp(1.0, lerp(maskPlusGray, proMask, _MaskPlusUsePro), _MaskTexPlusSwitch);

                // ── 输出 ─────────────────────────────────────────────────────
                float mainAlpha     = _MainColor.a * lerp(mainTex.r, mainTex.a, _MainTexP);
                float dissolveAlpha = lerp(1.0, dissolveResult.a, _DissolveTexSwitch);

                float3 Color = (dissolvedColor + lgColor).rgb;
                float  Alpha = saturate(mainAlpha * input.ase_color.a * dissolveAlpha * maskAlpha * maskPlusAlpha);

                return half4(Color, Alpha);
            }
            ENDHLSL
        }
    }
    CustomEditor ""
    FallBack "Hidden/Shader Graph/FallbackError"
    Fallback Off
}
