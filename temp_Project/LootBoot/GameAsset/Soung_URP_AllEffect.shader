//2026.3.17 updated for Universal2D by Soung
Shader "Soung/Effect/FullFx"
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
        _MainTexHue("主帖图色相变换", Range( 0 , 1)) = 0
        _MainTexSaturation("主帖图饱和度", Range( 0 , 1.5)) = 1
        [Toggle(_USE_HSV_ON)]_UseHSV("主帖图启用HSV色相调整", Float) = 0
        [Enum(Material,0,Custom1xy,1)]_MainTexFlowMode("主帖图流动模式", Float) = 0
        [Enum(Repeat,0,Clamp,1)]_MainTexClamp("主帖图重铺模式", Float) = 0
        [KeywordEnum(Local,Polar,PolarDistortion)]_MainTexUVMode("主帖图UV模式", Float) = 0
        _MainTexPolarSets("主帖图Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _MainTexPolarDistortionPower("主帖图Polar扭曲强度", Float) = 0
        _MainTexPolarDistortionUVScale("主帖图Polar扭曲段数", Float) = 1
        _MainTexUspeed("主帖图U速率", Float) = 0
        _MainTexVspeed("主帖图V速率", Float) = 0


        [Header(NoiseTex)][Toggle(_NOISE_ON)]_NoiseSwitch("扭曲开关", Float) = 0
        _NoiseTex("扭曲贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_NoiseTexP("扭曲贴图通道", Float) = 0
        _NoisePower("扭曲强度", Range( 0 , 1)) = 0
        [Enum(Local,0,Polar,1,Screen,2)]_NoiseTexUVMode("扭曲UV模式", Float) = 0
        _NoisePolarScale("扭曲Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _NoiseScreenTilingOffset("扭曲Screen重铺与偏移", Vector) = (1,1,0,0)
        [Enum(OFF,0,ON,1)]_NoiseUseCustom1w("扭曲强度使用Custom1.w", Float) = 0
        [Enum(OFF,0,ON,1)]_NoiseAffectLiuguang("扭曲影响流光", Float) = 0
        [Enum(OFF,0,ON,1)]_NoiseAffectDissolve("扭曲影响溶解", Float) = 0
        _NoiseTexUspeed("扭曲U速率", Float) = 0
        _NoiseTexVspeed("扭曲V速率", Float) = 0

        [Header(GamTex)][Toggle(_GAMTEX_ON)]_GamTexSwitch("颜色叠加开关", Float) = 0
        _GamTex("颜色叠加贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_GamTexP("颜色叠加通道", Float) = 0
        [IntRange]_GamTexRotator("颜色叠加旋转", Range( 0 , 360)) = 0
        _GamTexDesaturate("颜色叠加去色", Range( 0 , 1)) = 1
        [Enum(Repeat,0,Clmap,1)]_GamTexClamp("颜色叠加重铺模式", Float) = 0
        [Enum(OFF,0,ON,1)]_GamTexFollowMainTex("颜色叠加跟随主贴图流动", Float) = 0
        _GamTexUspeed("颜色叠加U速率", Float) = 0
        _GamTexVspeed("颜色叠加V速率", Float) = 0
        [Enum(Notuse,0,Use,1)]_GamAlphaMode("颜色叠加Alpha模式", Float) = 0

        [Header(ProgramMask)][Enum(ON,0,OFF,1)]_ProMaskSwitch("程序遮罩开关", Float) = 0
        [KeywordEnum(UP,DOWN,LEFT,RIGHT)] _ProMaskDir("程序遮罩方向", Float) = 0
        [Enum(Linear,0,Circle,1)]_ProMaskShape("程序遮罩形状", Float) = 0
        _ProMaskRange("程序遮罩范围", Range( 1 , 8)) = 1
        [Header(MaskTex)][Toggle(_MASKTEX_ON)]_MaskSwitch("遮罩开关", Float) = 0

        _MaskTex("遮罩贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_MaskTexP("遮罩贴图通道", Float) = 0
        [IntRange]_MaskTexRotator("遮罩贴图旋转", Range( 0 , 360)) = 0
        [Enum(OFF,0,ON,1)]_OneMinusMask("反相遮罩", Float) = 0
        [Enum(Repeat,0,Clamp,1)]_MaskTexClamp("遮罩贴图重铺模式", Float) = 0
        [Enum(Material,0,Custom2xy,1)]_MaskTexFlowMode("遮罩帖图流动模式", Float) = 0
        _MaskTexUspeed("遮罩U速度", Float) = 0
        _MaskTexVspeed("遮罩V速度", Float) = 0

        [Header(MaskTexPlus)][Toggle(_MASKTEXPLUS_ON)]_MaskTexPlusSwitch("额外遮罩开关", Float) = 0
        [Toggle]_MaskPlusUsePro("额外遮罩使用程序", Float) = 0
        _MaskTexPlus("额外遮罩", 2D) = "white" {}
        [Enum(R,0,A,1)]_MaskTexPlusP("额外遮罩通道", Float) = 0
        [IntRange]_MaskTexPlusRotator("额外遮罩旋转", Range( 0 , 360)) = 0
        [Enum(Repeat,0,Clamp,1)]_MaskTexPlusClamp("额外遮罩重铺模式", Float) = 0
        _MaskTexPlusUspeed("额外遮罩U速度", Float) = 0
        _MaskTexPlusVspeed("额外遮罩V速度", Float) = 0

        [Header(Liuguang)][Toggle(_LIUGUANG_ON)]_LiuguangSwitch("流光开关", Float) = 0
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

        [Header(DissolveTex)][Toggle(_DISSOLVETEX_ON)]_DissolveTexSwitch("溶解开关", Float) = 0
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
        [Enum(Local,0,Polar,1,Screen,2)]_DissolveTexUVMode("溶解UV模式", Float) = 0
        _DissolvePolarScale("溶解Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _DissolveScreenTilingOffset("溶解Screen重铺与偏移", Vector) = (1,1,0,0)
        _DissolveTexUspeed("溶解U速度", Float) = 0
        _DissolveTexVspeed("溶解V速度", Float) = 0

        [Header(DissloveTexPath)][Toggle(_DISSOLVETEXPLUS_ON)]_DissolveTexPlusSwitch("定向溶解开关", Float) = 0
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
        #pragma target 3.5

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
            #pragma shader_feature_local _LIUGUANGTEXUVMODE_LOCAL _LIUGUANGTEXUVMODE_POLAR _LIUGUANGTEXUVMODE_SCREEN
            #pragma shader_feature_local _MAINTEXUVMODE_LOCAL _MAINTEXUVMODE_POLAR _MAINTEXUVMODE_POLARDISTORTION
            #pragma shader_feature_local _USE_HSV_ON
            #pragma shader_feature_local _NOISE_ON
            #pragma shader_feature_local _GAMTEX_ON
            #pragma shader_feature_local _LIUGUANG_ON
            #pragma shader_feature_local _DISSOLVETEX_ON
            #pragma shader_feature_local _DISSOLVETEXPLUS_ON
            #pragma shader_feature_local _MASKTEX_ON
            #pragma shader_feature_local _MASKTEXPLUS_ON

            struct Attributes
            {
                float4 positionOS : POSITION;	//顶点位置
                float4 texcoord : TEXCOORD0;	//UV0
                float4 texcoord1 : TEXCOORD1;	//UV1 (Custom1.xyzw)
                float4 texcoord2 : TEXCOORD2;	//UV2 (Custom2.xy)
                float4 ase_color : COLOR;	//顶点颜色
                UNITY_VERTEX_INPUT_INSTANCE_ID	//GPU Instance ID
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 clipPosV : TEXCOORD0;
                float4 ase_texcoord6 : TEXCOORD1;         // UV0
                float4 ase_texcoord7 : TEXCOORD2;         // Custom1.xyzw
                float4 ase_color : COLOR;
                float4 ase_texcoord8 : TEXCOORD3;         // Custom2.xy
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                // === 所有float4属性（已经是16字节对齐）===
                float4 _MainTex_ST;
                float4 _MainColor;
                float4 _MainTexPolarSets;
                float4 _NoiseTex_ST;
                float4 _NoisePolarScale;
                float4 _NoiseScreenTilingOffset;
                float4 _GamTex_ST;
                float4 _MaskTex_ST;
                float4 _MaskTexPlus_ST;
                float4 _LiuguangTex_ST;
                float4 _LiuguangColor;
                float4 _LiuguangPolarScale;
                float4 _LiuguangScreenTilingOffset;
                float4 _DissolveTex_ST;
                float4 _DissolvePolarScale;
                float4 _DissolveScreenTilingOffset;
                float4 _DissolveEdgeColor;
                float4 _DissolveTexPlus_ST;
                // === float属性 ===
                // 组1: 基础设置
                float _CullingMode;
                float _Zwrite;
                float _ZTestMode;
                float _BlendMode;
                
                // 组2: 主纹理
                float _MainTexP;
                float _MainTexRotator;
                float _MainTexHue;
                float _MainTexSaturation;
                
                // 组3: 主纹理控制
                float _MainTexFlowMode;
                float _MainTexClamp;
                float _MainTexUspeed;
                float _MainTexVspeed;

                // 组4: 极坐标UV参数
                float _MainTexPolarDistortionPower;
                float _MainTexPolarDistortionUVScale;

                // 组5: 噪声
                float _NoiseSwitch;
                float _NoisePower;
                float _NoiseTexP;
                float _NoiseTexUspeed;
                
                // 组6: 噪声和颜色叠加
                float _NoiseTexVspeed;
                float _GamTexSwitch;
                float _GamTexP;
                float _GamTexRotator;
                
                // 组7: 颜色叠加
                float _GamTexDesaturate;
                float _GamTexClamp;
                float _GamTexFollowMainTex;
                float _GamTexUspeed;
                
                // 组8: 颜色叠加和遮罩
                float _GamTexVspeed;
                float _GamAlphaMode;
                float _MaskSwitch;
                float _MaskTexP;
                
                // 组9: 遮罩
                float _MaskTexRotator;
                float _OneMinusMask;
                float _MaskTexClamp;
                float _MaskTexFlowMode;
                
                // 组10: 遮罩速度
                float _MaskTexUspeed;
                float _MaskTexVspeed;
                float _MaskTexPlusSwitch;
                float _MaskPlusUsePro;
                
                // 组11: 额外遮罩
                float _MaskTexPlusP;
                float _MaskTexPlusClamp;
                float _MaskTexPlusRotator;
                float _MaskTexPlusUspeed;
                
                // 组12: 额外遮罩和程序遮罩
                float _MaskTexPlusVspeed;
                float _ProMaskSwitch;
                float _ProMaskRange;
                float _LiuguangSwitch;
                
                // 组13: 流光
                float _LiuguangTexP;
                float _LiuguangTexRotator;
                float _UseLGTexColor;
                float _LiuguangUSpeed;
                
                // 组14: 流光速度
                float _LiuguangVSpeed;
                float _DissolveTexSwitch;
                float _DissolveTexP;
                float _DissolveTexRotator;
                
                // 组15: 溶解
                float _DissolveSmooth;
                float _DissolveMode;
                float _DissolvePower;
                float _DissolveEdgeSwitch;
                
                // 组16: 溶解边缘
                float _DissolveEdgeWide;
                float _DissolveTexUspeed;
                float _DissolveTexVspeed;
                float _DissolveColorMode;
                
                // 组17: 定向溶解
                float _DissolveTexPlusSwitch;
                float _DissolveTexPlusUsePro;
                float _DissolveTexPlusP;
                float _DissolveTexPlusRotator;
                
                // 组18: 定向溶解控制
                float _DissolveTexPlusPower;
                float _DissolveTexPlusFlowMode;
                float _DissolveTexPlusClamp;
                float _DissolveTexPlusUspeed;

                // 组19: 定向溶解尾 + 扩展参数
                float _DissolveTexPlusVspeed;
                float _NoiseTexUVMode;
                float _NoiseUseCustom1w;
                float _NoiseAffectLiuguang;
                float _NoiseAffectDissolve;
                float _ProMaskShape;
                float _DissolveTexUVMode;
            CBUFFER_END

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GamTex;
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
            // 封装UV旋转为内联函数，减少冗余代码，支持按需调用
            inline float2 RotateUV(float2 uv, float angleDeg)
            {
                float rad = (angleDeg * PI) / 180.0;
                float c = cos(rad);
                float s = sin(rad);
                return mul(uv - float2(0.5, 0.5), float2x2(c, -s, s, c)) + float2(0.5, 0.5);
            }

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

            inline float2 PolarUV(float2 uv, float4 polarScale)
            {
                float2 delta = ( uv - polarScale.xy );
                return float2(( polarScale.z * ( length( delta ) * 2.0 ) ) , ( ( atan2( delta.x , delta.y ) * ( 1.0 / TWO_PI ) ) * polarScale.w ));
            }

            inline float2 ScreenUV(float4 screenPos, float4 tilingOffset)
            {
                float4 grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
                float4 grabScreenPosNorm = grabScreenPos / grabScreenPos.w;
                return (float2(grabScreenPosNorm.x , grabScreenPosNorm.y) * tilingOffset.xy + tilingOffset.zw);
            }
            

            PackedVaryings VertexFunction( Attributes input  )
            {
                PackedVaryings output = (PackedVaryings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.ase_texcoord6.xy = input.texcoord.xy;
                output.ase_texcoord7 = input.texcoord1;
                output.ase_color = input.ase_color;
                output.ase_texcoord8 = input.texcoord2;
                output.ase_texcoord6.zw = 0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

                output.positionCS = vertexInput.positionCS;
                output.clipPosV = vertexInput.positionCS;

                return output;
            }


            PackedVaryings vert( Attributes input )
            {
                return VertexFunction( input );
            }

            half4 frag ( PackedVaryings input ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 ScreenPos = ComputeScreenPos( input.clipPosV );

                float ValueZero = 0.0;
                // 优化噪声采样条件，_NoiseSwitch关闭时完全跳过采样
                float lerpResult60 = ValueZero;
                #if defined(_NOISE_ON)
                    float2 appendResult54 = (float2(_NoiseTexUspeed , _NoiseTexVspeed));
                    float2 uv_NoiseTex = input.ase_texcoord6.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                    float2 noiseUV = uv_NoiseTex;
                    if ( _NoiseTexUVMode == 1 )
                    {
                        noiseUV = PolarUV( uv_NoiseTex, _NoisePolarScale );
                    }
                    else if ( _NoiseTexUVMode == 2 )
                    {
                        noiseUV = ScreenUV( ScreenPos, _NoiseScreenTilingOffset );
                    }
                    float2 panner50 = ( 1.0 * _Time.y * appendResult54 + noiseUV);
                    float4 tex2DNode17 = tex2D( _NoiseTex, panner50 );
                    float lerpResult63 = lerp( tex2DNode17.r , tex2DNode17.a , _NoiseTexP);
                    float noisePower = ( _NoisePower * lerp( 1.0 , saturate( input.ase_texcoord7.w ) , _NoiseUseCustom1w ) );
                    lerpResult60 = ( (-0.5 + (lerpResult63 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * noisePower );
                #endif
                float2 appendResult34 = (float2(_MainTexUspeed , _MainTexVspeed));
                float2 uv_MainTex = input.ase_texcoord6.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                // 编译期决议UV模式，未选中的路径完全不编译进最终variant
                #if defined(_MAINTEXUVMODE_POLAR)
                // 标准极坐标模式
                float2 appendResult24 = (float2(_MainTexPolarSets.x , _MainTexPolarSets.y));
                float2 temp_output_34_0_g3 = ( uv_MainTex - appendResult24 );
                float2 break39_g3 = temp_output_34_0_g3;
                float2 finalUV = (float2(( _MainTexPolarSets.z * ( length( temp_output_34_0_g3 ) * 2.0 ) ) , ( ( atan2( break39_g3.x , break39_g3.y ) * ( 1.0 / TWO_PI ) ) * _MainTexPolarSets.w )));
                #elif defined(_MAINTEXUVMODE_POLARDISTORTION)
                // 极坐标扭曲模式
                float2 remappedUV = uv_MainTex * 2.0 - 1.0;
                float remappedDist = length(remappedUV);
                float rotAngle = ((1.0 - remappedDist) * 2.0 * _MainTexPolarDistortionPower) * PI;
                float cosRot = cos(rotAngle);
                float sinRot = sin(rotAngle);
                float2 rotatedUV = mul(uv_MainTex - float2(0.5, 0.5), float2x2(cosRot, -sinRot, sinRot, cosRot)) + float2(0.5, 0.5);
                float2 polarDistortionUV = rotatedUV * 2.0 - 1.0;
                float polarR = pow(length(polarDistortionUV), _MainTexPolarDistortionUVScale);
                float polarTheta = (atan2(polarDistortionUV.y, polarDistortionUV.x) / (2.0 * PI)) + 0.5;
                float2 finalUV = float2(polarR, polarTheta);
                #else
                // Local模式（默认），直接使用原始UV，无任何额外开销
                float2 finalUV = uv_MainTex;
                #endif

                float2 panner35 = ( 1.0 * _Time.y * appendResult34 + finalUV);
                float4 texCoord8 = input.ase_texcoord7;
                texCoord8.xy = input.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
                float custom1x9 = texCoord8.x;
                float custom1y10 = texCoord8.y;
                float2 appendResult31 = (float2(custom1x9 , custom1y10));
                float2 lerpResult443 = lerp( panner35 , ( finalUV + appendResult31 ) , _MainTexFlowMode);
                float ValueHalfCircle = 180.0;
                float2 rotator42 = RotateUV( lerpResult60 + lerpResult443, _MainTexRotator );
                float2 lerpResult40 = lerp( rotator42 , saturate( rotator42 ) , _MainTexClamp);
                float4 tex2DNode15 = tex2D( _MainTex, lerpResult40 );
                #if defined(_USE_HSV_ON)
                float3 hsvTorgb107 = RGBToHSV( tex2DNode15.rgb );
                float3 hsvTorgb106 = HSVToRGB( float3(( _MainTexHue + hsvTorgb107.x ),( hsvTorgb107.y * _MainTexSaturation ),hsvTorgb107.z) );
                float4 MainTexColor113 = ( _MainColor * float4( hsvTorgb106 , 0.0 ) );
                #else
                float4 MainTexColor113 = ( _MainColor * float4( tex2DNode15.rgb , 0.0 ) );
                #endif
                float Toggle168 = 1.0;
                float3 temp_cast_2 = (Toggle168).xxx;
                float2 appendResult82 = (float2(_GamTexUspeed , _GamTexVspeed));
                float2 uv_GamTex = input.ase_texcoord6.xy * _GamTex_ST.xy + _GamTex_ST.zw;
                float2 panner85 = ( 1.0 * _Time.y * appendResult82 + uv_GamTex);
                float2 temp_cast_3 = (ValueZero).xx;
                float2 MainTexUV120 = lerpResult443;
                float2 lerpResult78 = lerp( temp_cast_3 , MainTexUV120 , _GamTexFollowMainTex);

                //优化颜色叠加采样条件, 避免不必要的采样
                float4 tex2DNode101 = float4(0,0,0,0);
                #if defined(_GAMTEX_ON)
                    float2 rotator102 = RotateUV( panner85 + lerpResult78, _GamTexRotator );
                    float2 lerpResult89 = lerp( rotator102 , saturate( rotator102 ) , _GamTexClamp);
                    tex2DNode101 = tex2D( _GamTex, ( lerpResult60 + lerpResult89 ) );
                #endif
                
                float3 desaturateInitialColor91 = tex2DNode101.rgb;
                float desaturateDot91 = dot( desaturateInitialColor91, float3( 0.299, 0.587, 0.114 ));
                float3 desaturateVar91 = lerp( desaturateInitialColor91, desaturateDot91.xxx, _GamTexDesaturate );
                float3 appendResult92 = (float3(desaturateVar91));
                float3 lerpResult352 = lerp( temp_cast_2 , appendResult92 , _GamTexSwitch);
                float3 GamColor103 = lerpResult352;
                float3 temp_cast_6 = (Toggle168).xxx;
                float custom1z11 = texCoord8.z;
                float lerpResult330 = lerp( _DissolvePower , custom1z11 , _DissolveMode);
                float DissolveValue334 = lerpResult330;
                float2 appendResult323 = (float2(_DissolveTexUspeed , _DissolveTexVspeed));
                float2 uv_DissolveTex = input.ase_texcoord6.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                float2 dissolveUV = uv_DissolveTex;
                if ( _DissolveTexUVMode == 1 )
                {
                    dissolveUV = PolarUV( uv_DissolveTex, _DissolvePolarScale );
                }
                else if ( _DissolveTexUVMode == 2 )
                {
                    dissolveUV = ScreenUV( ScreenPos, _DissolveScreenTilingOffset );
                }
                float2 panner317 = ( 1.0 * _Time.y * appendResult323 + dissolveUV);
                float dissolveNoiseOffset = lerp( ValueZero , lerpResult60 , _NoiseAffectDissolve );

                //优化溶解采样条件, 避免不必要的采样
                float4 tex2DNode302 = float4(0,0,0,0);
                #if defined(_DISSOLVETEX_ON)
                    float2 rotator328 = RotateUV( panner317 + dissolveNoiseOffset, _DissolveTexRotator );
                    tex2DNode302 = tex2D( _DissolveTex, rotator328 );
                #endif

                float lerpResult276 = lerp( tex2DNode302.r , tex2DNode302.a , _DissolveTexP);
                float2 appendResult263 = (float2(_DissolveTexPlusUspeed , _DissolveTexPlusVspeed));
                float4 texCoord384 = input.ase_texcoord8;
                texCoord384.xy = input.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
                float custom2x385 = texCoord384.x;
                float custom2y386 = texCoord384.y;
                float2 appendResult264 = (float2(custom2x385 , custom2y386));
                float2 lerpResult265 = lerp( appendResult263 , ( appendResult263 + appendResult264 ) , _DissolveTexPlusFlowMode);
                float2 uv_DissolveTexPlus = input.ase_texcoord6.xy * _DissolveTexPlus_ST.xy + _DissolveTexPlus_ST.zw;
                float2 panner267 = ( 1.0 * _Time.y * lerpResult265 + uv_DissolveTexPlus);

                //优化定向溶解采样条件, 避免不必要的采样
                float4 tex2DNode303 = float4(0,0,0,0);
                #if defined(_DISSOLVETEXPLUS_ON)
                    float2 rotator316 = RotateUV( panner267, _DissolveTexPlusRotator );
                    float2 lerpResult272 = lerp( rotator316 , saturate( rotator316 ) , _DissolveTexPlusClamp);
                    tex2DNode303 = tex2D( _DissolveTexPlus, lerpResult272 );
                #endif

                float lerpResult275 = lerp( tex2DNode303.r , tex2DNode303.a , _DissolveTexPlusP);
                float2 texCoord406 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
                #if defined( _PROMASKDIR_UP )
                float staticSwitch425 = ( 1.0 - texCoord406.y );
                #elif defined( _PROMASKDIR_DOWN )
                float staticSwitch425 = texCoord406.y;
                #elif defined( _PROMASKDIR_LEFT )
                float staticSwitch425 = texCoord406.x;
                #elif defined( _PROMASKDIR_RIGHT )
                float staticSwitch425 = ( 1.0 - texCoord406.x );
                #else
                float staticSwitch425 = ( 1.0 - texCoord406.y );
                #endif
                float ProMask431 = ValueZero;
                if ( _ProMaskShape == 1 )
                {
                    float2 centeredProMaskUV = ( input.ase_texcoord6.xy - float2( 0.5, 0.5 ) );
                    float circleProMask = pow( saturate( 1.0 - ( length( centeredProMaskUV ) * 1.41421356 ) ) , _ProMaskRange );
                    ProMask431 = lerp( circleProMask , ValueZero , _ProMaskSwitch);
                }
                else
                {
                    float smoothstepResult409 = smoothstep( 0.0 , _ProMaskRange , staticSwitch425);
                    ProMask431 = lerp( saturate( ( smoothstepResult409 * ( _ProMaskRange / 0.4 ) ) ) , ValueZero , _ProMaskSwitch);
                }
                float lerpResult432 = lerp( lerpResult275 , ProMask431 , _DissolveTexPlusUsePro);
                float lerpResult278 = lerp( lerpResult276 , lerpResult432 , _DissolveTexPlusSwitch);
                float temp_output_283_0 = saturate( ( ( lerpResult278 + ( lerpResult276 / _DissolveTexPlusPower ) ) / 2.0 ) );
                float smoothstepResult286 = smoothstep( ( DissolveValue334 - _DissolveSmooth ) , DissolveValue334 , temp_output_283_0);
                float4 temp_cast_7 = (smoothstepResult286).xxxx;

                float4 dissolvealphaEDGE = ( _DissolveEdgeColor * ( step( ( DissolveValue334 - _DissolveEdgeWide ) , temp_output_283_0 ) - step( DissolveValue334 , temp_output_283_0 ) ) );
                float4 lerpResult299 = lerp( temp_cast_7 , ( smoothstepResult286 + dissolvealphaEDGE), _DissolveEdgeSwitch);

                float3 appendResult301 = (float3(lerpResult299.rgb));
                float3 lerpResult356 = lerp( temp_cast_6 , appendResult301 , _DissolveTexSwitch);
                float3 DissolveColor304 = lerpResult356;

                //float4 temp_output_338_0 = ( MainTexColor113 * float4( GamColor103 , 0.0 ) * input.ase_color * float4( DissolveColor304 , 0.0 ) );
                
                float4 baseColor = ( MainTexColor113 * float4( GamColor103 , 0.0 ) * input.ase_color );
                float4 dissolveBlendedColor = lerp( 
                    ( baseColor * float4( DissolveColor304 , 0.0 ) ),  // 乘法混合
                    ( baseColor + dissolvealphaEDGE),  // 加法混合
                    _DissolveColorMode
                );
                float4 temp_output_338_0 = dissolveBlendedColor;

                float4 temp_cast_13 = (ValueZero).xxxx;

                //优化流光纹理采样条件, 避免不必要的采样
                float4 tex2DNode196 = float4(0,0,0,0);
                #if defined(_LIUGUANG_ON)
                    float2 appendResult210 = (float2(_LiuguangUSpeed , _LiuguangVSpeed));
                    float2 uv_LiuguangTex = input.ase_texcoord6.xy * _LiuguangTex_ST.xy + _LiuguangTex_ST.zw;
                    float2 rotator240 = RotateUV( uv_LiuguangTex, _LiuguangTexRotator );
                    float2 appendResult50_g4 = PolarUV( uv_LiuguangTex, _LiuguangPolarScale );
                    float2 screenUVLiuguang = ScreenUV( ScreenPos, _LiuguangScreenTilingOffset );
                    #if defined( _LIUGUANGTEXUVMODE_LOCAL )
                    float2 staticSwitch239 = rotator240;
                    #elif defined( _LIUGUANGTEXUVMODE_POLAR )
                    float2 staticSwitch239 = appendResult50_g4;
                    #elif defined( _LIUGUANGTEXUVMODE_SCREEN )
                    float2 staticSwitch239 = screenUVLiuguang;
                    #else
                    float2 staticSwitch239 = rotator240;
                    #endif
                    float liuguangNoiseOffset = lerp( ValueZero , lerpResult60 , _NoiseAffectLiuguang );
                    float2 panner215 = ( 1.0 * _Time.y * appendResult210 + staticSwitch239);
                    tex2DNode196 = tex2D( _LiuguangTex, ( panner215 + liuguangNoiseOffset ) );
                #endif

                float3 appendResult200 = (float3(tex2DNode196.r , tex2DNode196.g , tex2DNode196.b));
                float lerpResult197 = lerp( tex2DNode196.r , tex2DNode196.a , _LiuguangTexP);

                float4 colorTerm = lerpResult197 * _LiuguangColor;
                float4 lerpResult204 = lerp( float4(appendResult200 * lerpResult197, 0.0) * _LiuguangColor, colorTerm, _UseLGTexColor);
                float4 lerpResult220 = lerp( temp_cast_13 , lerpResult204 , _LiuguangSwitch);
                float4 LiuguangColor223 = lerpResult220;
                
                float lerpResult104 = lerp( tex2DNode15.r , tex2DNode15.a , _MainTexP);
                float MainTexAlpha114 = ( _MainColor.a * lerpResult104 );
                float lerpResult357 = lerp( Toggle168 , (lerpResult299).a , _DissolveTexSwitch);
                float DissolveAlpha305 = lerpResult357;
                float2 appendResult162 = (float2(_MaskTexUspeed , _MaskTexVspeed));
                float2 uv_MaskTex = input.ase_texcoord6.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
                float2 panner160 = ( 1.0 * _Time.y * appendResult162 + uv_MaskTex);
                float2 appendResult457 = (float2(custom2x385 , custom2y386));
                float2 lerpResult459 = lerp( panner160 , ( uv_MaskTex + appendResult457 ) , _MaskTexFlowMode);

                //优化遮罩纹理采样条件, 避免不必要的采样
                float4 tex2DNode158 = float4(0,0,0,0);
                #if defined(_MASKTEX_ON)
                    float2 rotator161 = RotateUV( lerpResult459, _MaskTexRotator );
                    float2 lerpResult172 = lerp( rotator161 , saturate( rotator161 ) , _MaskTexClamp);
                    tex2DNode158 = tex2D( _MaskTex, lerpResult172 );
                #endif

                float lerpResult171 = lerp( tex2DNode158.r , tex2DNode158.a , _MaskTexP);
                float smoothstepResult383 = smoothstep( 1.0 , -1.0 , lerpResult171);
                float lerpResult380 = lerp( lerpResult171 , smoothstepResult383 , _OneMinusMask);
                float lerpResult247 = lerp( Toggle168 , lerpResult380 , _MaskSwitch);
                float MaskTexAlpha193 = lerpResult247;
                float2 appendResult180 = (float2(_MaskTexPlusUspeed , _MaskTexPlusVspeed));
                float2 uv_MaskTexPlus = input.ase_texcoord6.xy * _MaskTexPlus_ST.xy + _MaskTexPlus_ST.zw;
                float2 panner181 = ( 1.0 * _Time.y * appendResult180 + uv_MaskTexPlus);

                //优化额外遮罩纹理采样条件, 避免不必要的采样
                float4 tex2DNode187 = float4(0,0,0,0);
                #if defined(_MASKTEXPLUS_ON)
                    float2 rotator186 = RotateUV( panner181, _MaskTexPlusRotator );
                    float2 lerpResult190 = lerp( rotator186 , saturate( rotator186 ) , _MaskTexPlusClamp);
                    tex2DNode187 = tex2D( _MaskTexPlus, lerpResult190 );
                #endif

                float lerpResult188 = lerp( tex2DNode187.r , tex2DNode187.a , _MaskTexPlusP);
                float lerpResult435 = lerp( lerpResult188 , ProMask431 , _MaskPlusUsePro);
                float lerpResult241 = lerp( Toggle168 , lerpResult435 , _MaskTexPlusSwitch);
                float MaskTexPlusAlpha194 = lerpResult241;
                float temp_output_365_0 = ( MainTexAlpha114 * input.ase_color.a * DissolveAlpha305 * MaskTexAlpha193 * MaskTexPlusAlpha194 );
                float lerpResult93 = lerp( tex2DNode101.r , tex2DNode101.a , _GamTexP);
                float lerpResult355 = lerp( Toggle168 , lerpResult93 , _GamTexSwitch);
                float GamAlpha123 = lerpResult355;
                float lerpResult371 = lerp( temp_output_365_0 , ( temp_output_365_0 * GamAlpha123 ) , _GamAlphaMode);
                float3 Color = (( temp_output_338_0 + LiuguangColor223 )).rgb;
                float Alpha = saturate( lerpResult371 );

                return half4( Color, Alpha );
            }
            ENDHLSL
        }
    }
    CustomEditor "ShaderGUI_AllEffect"
    FallBack "Hidden/Shader Graph/FallbackError"
    Fallback Off
}