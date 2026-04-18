//2025.10.31 optimized by Soung
Shader "Soung/Effect/FullFx"
{
    Properties
    {
        [Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(ON,1,OFF,0)]_Zwrite("深度写入", Float) = 0
        [Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
        [Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1

        [Header(DepthFade)][KeywordEnum(ON,OFF)]_SOFT_PARTICLES_ON("软粒子开关", Float) = 1
        _SoftParticle("软粒子值", Range( 0 , 20)) = 0

        [Header(MainTex)]_MainTex("主贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_MainTexP("主帖图通道", Float) = 0
        [HDR]_MainColor("主帖图颜色", Color) = (1,1,1,1)
        [IntRange]_MainTexRotator("主帖图旋转", Range( 0 , 360)) = 0
        _MainTexHue("主帖图色相变换", Range( 0 , 1)) = 0
        _MainTexSaturation("主帖图饱和度", Range( 0 , 1.5)) = 1
        [Enum(Material,0,Custom1xy,1)]_MainTexFlowMode("主帖图流动模式", Float) = 0
        [Enum(Repeat,0,Clamp,1)]_MainTexClamp("主帖图重铺模式", Float) = 0
        [Enum(Local,0,Polar,1,PolarDistortion,2)]_MainTexUVMode("主帖图UV模式", Float) = 0
        _MainTexPolarSets("主帖图Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _MainTexPolarDistortionPower("主帖图Polar扭曲强度", Float) = 0
        _MainTexPolarDistortionUVScale("主帖图Polar扭曲段数", Float) = 1
        _MainTexUspeed("主帖图U速率", Float) = 0
        _MainTexVspeed("主帖图V速率", Float) = 0

        [Header(NoiseTex)][Enum(OFF,0,ON,1)]_NoiseSwitch("扭曲开关", Float) = 0
        _NoiseTex("扭曲贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_NoiseTexP("扭曲贴图通道", Float) = 0
        _NoisePower("扭曲强度", Range( 0 , 1)) = 0
        _NoiseTexUspeed("扭曲U速率", Float) = 0
        _NoiseTexVspeed("扭曲V速率", Float) = 0

        [Header(GamTex)][Enum(OFF,0,ON,1)]_GamTexSwitch("颜色叠加开关", Float) = 0
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

        [Header(VertexTex)][Enum(OFF,0,ON,1)]_VertexSwitch("顶点偏移开关", Float) = 0
        _VertexTex("顶点偏移贴图", 2D) = "white" {}
        [IntRange]_VertexTexRotator("顶点偏移旋转", Range( 0 , 360)) = 0
        [Enum(Material,0,Custom1w,1)]_VertexMode("顶点偏移模式", Float) = 0
        _VertexPower("顶点偏移强度", Float) = 0
        _VertexTexDir("顶点偏移轴向", Vector) = (1,1,1,0)
        _VertexTexUspeed("顶点偏移U速率", Float) = 0
        _VertexTexVspeed("顶点偏移V速率", Float) = 0
        
        [Header(Fresnel)][Enum(OFF,0,ON,1)]_FresnelSwitch("菲涅尔开关", Float) = 0
        [HDR]_FresnelColor("菲涅尔颜色", Color) = (1,1,1,1)
        [Enum(Fresnel,0,Bokeh,1)]_FresnelMode("菲涅尔模式", Float) = 0
        [Enum(Mult,0,Add,1)]_FresnelColorMode("菲涅尔颜色模式", Float) = 0
        [Enum(Notuse,0,Use,1)]_FresnelAlphaMode("菲涅尔Alpha模式", Float) = 0
        _FresnelSet("菲涅尔强度/边缘/范围", Vector) = (0,1,5,0)
    }

    SubShader
    {
        LOD 0

        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

        Cull [_CullingMode]
        AlphaToMask Off

        HLSLINCLUDE
        #pragma target 4.5
        #pragma prefer_hlslcc gles

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
        ENDHLSL

        Pass
        {
            
            Name "Forward"
            Tags { "LightMode"="SRPDefaultUnlit" }

            Blend SrcAlpha [_BlendMode], One OneMinusSrcAlpha
            ZWrite [_Zwrite]
            ZTest [_ZTestMode]
            Offset 0 , 0
            ColorMask RGBA

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            #pragma vertex vert
            #pragma fragment frag
		
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #pragma shader_feature_local _PROMASKDIR_UP _PROMASKDIR_DOWN _PROMASKDIR_LEFT _PROMASKDIR_RIGHT
            #pragma shader_feature_local _LIUGUANGTEXUVMODE_LOCAL _LIUGUANGTEXUVMODE_POLAR _LIUGUANGTEXUVMODE_SCREEN

            #pragma shader_feature_local _SOFT_PARTICLES_ON _SOFT_PARTICLES_OFF

            #if defined(_SOFT_PARTICLES_ON)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            struct Attributes
            {
                float4 positionOS : POSITION;	//顶点位置
                float3 normalOS : NORMAL;	//顶点法向
                float4 texcoord : TEXCOORD0;	//UV0
                float4 texcoord1 : TEXCOORD1;	//UV1 (Custom1.xyzw)
                float4 texcoord2 : TEXCOORD2;	//UV2 (Custom2.xy)
                float4 ase_color : COLOR;	//顶点颜色
                UNITY_VERTEX_INPUT_INSTANCE_ID	//GPU Instance ID
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;           // 裁剪空间位置
                float4 clipPosV : TEXCOORD0;              // 裁剪位置
                float3 positionWS : TEXCOORD1;            // 世界空间位置
                float4 ase_texcoord6 : TEXCOORD2;         // 自定义数据
                float4 ase_texcoord7 : TEXCOORD3;         // 自定义数据 (传递Custom1.xyzw)
                float4 ase_color : COLOR;                 // 顶点颜色
                float4 ase_texcoord8 : TEXCOORD4;         // 自定义数据 (传递Custom2.xy)
                float4 ase_texcoord9 : TEXCOORD5;         // 自定义数据
                UNITY_VERTEX_INPUT_INSTANCE_ID             // 实例ID
                UNITY_VERTEX_OUTPUT_STEREO                 // 立体渲染信息
                #if defined(_SOFT_PARTICLES_ON)
                    float4 scrPos : TEXCOORD6;
                #endif
            };

            CBUFFER_START(UnityPerMaterial)
                // === 所有float4属性（已经是16字节对齐）===
                float4 _MainTex_ST;
                float4 _MainColor;
                float4 _MainTexPolarSets;
                float4 _NoiseTex_ST;
                float4 _GamTex_ST;
                float4 _MaskTex_ST;
                float4 _MaskTexPlus_ST;
                float4 _LiuguangTex_ST;
                float4 _LiuguangColor;
                float4 _LiuguangPolarScale;
                float4 _LiuguangScreenTilingOffset;
                float4 _DissolveTex_ST;
                float4 _DissolveEdgeColor;
                float4 _DissolveTexPlus_ST;
                float4 _VertexTex_ST;
                float4 _VertexTexDir;
                float4 _FresnelColor;
                float4 _FresnelSet;
                
                // === 所有float属性重新按4个一组排列 ===
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
                float _MainTexUVMode;
                float _MainTexUspeed;
                
                // 组4: 主纹理速度和扭曲
                float _MainTexVspeed;
                float _MainTexPolarDistortionPower;
                float _MainTexPolarDistortionUVScale;
                float _SoftParticle;
                
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
                
                // 组19: 顶点偏移
                float _DissolveTexPlusVspeed;
                float _VertexSwitch;
                float _VertexTexRotator;
                float _VertexMode;
                
                // 组20: 顶点偏移速度
                float _VertexPower;
                float _VertexTexUspeed;
                float _VertexTexVspeed;
                float _FresnelSwitch;
                
                // 组21: 菲涅尔（最后一组，正好4个）
                float _FresnelColorMode;
                float _FresnelAlphaMode;
                float _FresnelMode;
                float _padding1;        // 如果需要，添加padding确保对齐
            CBUFFER_END

            sampler2D _VertexTex;
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GamTex;
            sampler2D _DissolveTex;
            sampler2D _DissolveTexPlus;
            sampler2D _LiuguangTex;
            sampler2D _MaskTex;
            sampler2D _MaskTexPlus;


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
            

            PackedVaryings VertexFunction( Attributes input  )
            {
                PackedVaryings output = (PackedVaryings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float ValueZero = 0.0;
                float4 temp_cast_0 = (ValueZero).xxxx;
                float4 texCoord8 = input.texcoord1;
                texCoord8.xy = input.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
                float custom1w12 = texCoord8.w;
                float lerpResult139 = lerp( _VertexPower , custom1w12 , _VertexMode);
                float2 appendResult135 = (float2(_VertexTexUspeed , _VertexTexVspeed));
                float2 uv_VertexTex = input.texcoord.xy * _VertexTex_ST.xy + _VertexTex_ST.zw;
                float2 panner137 = ( 1.0 * _Time.y * appendResult135 + uv_VertexTex);
                float ValueHalfCircle = 180.0;
                float cos394 = cos( ( ( _VertexTexRotator * PI ) / ValueHalfCircle ) );
                float sin394 = sin( ( ( _VertexTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator394 = mul( panner137 - float2( 0.5,0.5 ) , float2x2( cos394 , -sin394 , sin394 , cos394 )) + float2( 0.5,0.5 );
                float4 lerpResult154 = lerp( temp_cast_0 , ( lerpResult139 * float4( input.normalOS , 0.0 ) * tex2Dlod( _VertexTex, float4( rotator394, 0, 0.0) ).r * _VertexTexDir ) , _VertexSwitch);
                float4 VertexTexOffset157 = lerpResult154;
                float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
                output.ase_texcoord9.xyz = ase_normalWS;
                output.ase_texcoord6.xy = input.texcoord.xy;
                output.ase_texcoord7 = input.texcoord1;
                output.ase_color = input.ase_color;
                output.ase_texcoord8 = input.texcoord2;
                output.ase_texcoord6.zw = 0;
                output.ase_texcoord9.w = 0;
                float3 vertexValue = VertexTexOffset157.xyz;
                input.positionOS.xyz += vertexValue;
                input.normalOS = input.normalOS;
                VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

                output.positionCS = vertexInput.positionCS;
                output.clipPosV = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;

                // 仅在启用软粒子时计算屏幕位置
                #if defined(_SOFT_PARTICLES_ON)
                    output.scrPos = ComputeScreenPos(vertexInput.positionCS);
                #endif

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

                float3 WorldPosition = input.positionWS;
                float3 WorldViewDirection = GetWorldSpaceNormalizeViewDir( WorldPosition );
                float4 ScreenPos = ComputeScreenPos( input.clipPosV );

                float ValueZero = 0.0;
                float2 appendResult54 = (float2(_NoiseTexUspeed , _NoiseTexVspeed));
                float2 uv_NoiseTex = input.ase_texcoord6.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                float2 panner50 = ( 1.0 * _Time.y * appendResult54 + uv_NoiseTex);
                float4 tex2DNode17 = tex2D( _NoiseTex, panner50 );
                float lerpResult63 = lerp( tex2DNode17.r , tex2DNode17.a , _NoiseTexP);
                float lerpResult60 = lerp( ValueZero , ( (-0.5 + (lerpResult63 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * _NoisePower ) , _NoiseSwitch);
                float2 appendResult34 = (float2(_MainTexUspeed , _MainTexVspeed));
                float2 uv_MainTex = input.ase_texcoord6.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                // 极坐标UV实现（标准模式）
                float2 appendResult24 = (float2(_MainTexPolarSets.x , _MainTexPolarSets.y));
                float2 temp_output_34_0_g3 = ( uv_MainTex - appendResult24 );
                float2 break39_g3 = temp_output_34_0_g3;
                float2 appendResult50_g3 = (float2(( _MainTexPolarSets.z * ( length( temp_output_34_0_g3 ) * 2.0 ) ) , ( ( atan2( break39_g3.x , break39_g3.y ) * ( 1.0 / TWO_PI ) ) * _MainTexPolarSets.w )));
                
                // 极坐标扭曲模式实现
                // 1. 首先重映射UV坐标到[-1,1]并计算距离
                float2 remappedUV = uv_MainTex * 2.0 - 1.0;
                float remappedDist = length(remappedUV);
                
                // 2. 计算基于距离的旋转角度
                float rotAngle = ((1.0 - remappedDist) * 2.0 * _MainTexPolarDistortionPower) * PI;
                
                // 3. 应用旋转变换
                float cosRot = cos(rotAngle);
                float sinRot = sin(rotAngle);
                float2 rotatedUV = mul(uv_MainTex - float2(0.5, 0.5), float2x2(cosRot, -sinRot, sinRot, cosRot)) + float2(0.5, 0.5);
                
                // 4. 重映射到[-1,1]为极坐标计算做准备
                float2 polarDistortionUV = rotatedUV * 2.0 - 1.0;
                
                // 5. 计算距离和角度
                float polarR = pow(length(polarDistortionUV), _MainTexPolarDistortionUVScale);
                float polarTheta = (atan2(polarDistortionUV.y, polarDistortionUV.x) / (2.0 * PI)) + 0.5;
                
                // 6. 组装成最终的极坐标UV
                float2 polarDistortionResult = float2(polarR, polarTheta);
                
                // 根据模式选择UV变换方式
                float2 finalUV = uv_MainTex; // 默认使用原始UV
                if (_MainTexUVMode < 0.5) {
                    finalUV = uv_MainTex; // Local模式
                } 
                else if (_MainTexUVMode < 1.5) {
                    finalUV = appendResult50_g3; // 标准Polar模式
                }
                else {
                    finalUV = polarDistortionResult; // PolarDistortion模式
                }
                
                float2 lerpResult27 = finalUV;
                
                float2 panner35 = ( 1.0 * _Time.y * appendResult34 + lerpResult27);
                float4 texCoord8 = input.ase_texcoord7;
                texCoord8.xy = input.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
                float custom1x9 = texCoord8.x;
                float custom1y10 = texCoord8.y;
                float2 appendResult31 = (float2(custom1x9 , custom1y10));
                float2 lerpResult443 = lerp( panner35 , ( lerpResult27 + appendResult31 ) , _MainTexFlowMode);
                float ValueHalfCircle = 180.0;
                float cos42 = cos( ( ( _MainTexRotator * PI ) / ValueHalfCircle ) );
                float sin42 = sin( ( ( _MainTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator42 = mul( ( lerpResult60 + lerpResult443 ) - float2( 0.5,0.5 ) , float2x2( cos42 , -sin42 , sin42 , cos42 )) + float2( 0.5,0.5 );
                float2 lerpResult40 = lerp( rotator42 , saturate( rotator42 ) , _MainTexClamp);
                float4 tex2DNode15 = tex2D( _MainTex, lerpResult40 );
                float3 hsvTorgb107 = RGBToHSV( tex2DNode15.rgb );
                float3 hsvTorgb106 = HSVToRGB( float3(( _MainTexHue + hsvTorgb107.x ),( hsvTorgb107.y * _MainTexSaturation ),hsvTorgb107.z) );
                float4 MainTexColor113 = ( _MainColor * float4( hsvTorgb106 , 0.0 ) );
                float Toggle168 = 1.0;
                float3 temp_cast_2 = (Toggle168).xxx;
                float2 appendResult82 = (float2(_GamTexUspeed , _GamTexVspeed));
                float2 uv_GamTex = input.ase_texcoord6.xy * _GamTex_ST.xy + _GamTex_ST.zw;
                float2 panner85 = ( 1.0 * _Time.y * appendResult82 + uv_GamTex);
                float2 temp_cast_3 = (ValueZero).xx;
                float2 MainTexUV120 = lerpResult443;
                float2 lerpResult78 = lerp( temp_cast_3 , MainTexUV120 , _GamTexFollowMainTex);
                float cos102 = cos( ( ( _GamTexRotator * PI ) / ValueHalfCircle ) );
                float sin102 = sin( ( ( _GamTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator102 = mul( ( panner85 + lerpResult78 ) - float2( 0.5,0.5 ) , float2x2( cos102 , -sin102 , sin102 , cos102 )) + float2( 0.5,0.5 );
                float2 lerpResult89 = lerp( rotator102 , saturate( rotator102 ) , _GamTexClamp);

                //优化颜色叠加采样条件, 避免不必要的采样
                float4 tex2DNode101 = float4(0,0,0,0);
                if (_GamTexSwitch > 0.01) 
                {
                    tex2DNode101 = tex2D( _GamTex, ( lerpResult60 + lerpResult89 ) );
                }
                
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
                float2 panner317 = ( 1.0 * _Time.y * appendResult323 + uv_DissolveTex);
                float cos328 = cos( ( ( _DissolveTexRotator * PI ) / ValueHalfCircle ) );
                float sin328 = sin( ( ( _DissolveTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator328 = mul( panner317 - float2( 0.5,0.5 ) , float2x2( cos328 , -sin328 , sin328 , cos328 )) + float2( 0.5,0.5 );

                //优化溶解采样条件, 避免不必要的采样
                float4 tex2DNode302 = float4(0,0,0,0);
                if (_DissolveTexSwitch > 0.01) 
                {
                    tex2DNode302 = tex2D( _DissolveTex, rotator328 );
                }

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
                float cos316 = cos( ( ( _DissolveTexPlusRotator * PI ) / ValueHalfCircle ) );
                float sin316 = sin( ( ( _DissolveTexPlusRotator * PI ) / ValueHalfCircle ) );
                float2 rotator316 = mul( panner267 - float2( 0.5,0.5 ) , float2x2( cos316 , -sin316 , sin316 , cos316 )) + float2( 0.5,0.5 );
                float2 lerpResult272 = lerp( rotator316 , saturate( rotator316 ) , _DissolveTexPlusClamp);


                //优化定向溶解采样条件, 避免不必要的采样
                float4 tex2DNode303 = float4(0,0,0,0);
                if (_DissolveTexPlusSwitch > 0.01) 
                {
                    tex2DNode303 = tex2D( _DissolveTexPlus, lerpResult272 );
                }

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
                float smoothstepResult409 = smoothstep( 0.0 , _ProMaskRange , staticSwitch425);
                float lerpResult438 = lerp( saturate( ( smoothstepResult409 * ( _ProMaskRange / 0.4 ) ) ) , ValueZero , _ProMaskSwitch);
                float ProMask431 = lerpResult438;
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
                float4 temp_cast_10 = (Toggle168).xxxx;
                float3 ase_normalWS = input.ase_texcoord9.xyz;
                float fresnelNdotV124 = dot( ase_normalWS, WorldViewDirection );
                float fresnelNode124 = ( _FresnelSet.x + _FresnelSet.y * pow( abs(1.0 - fresnelNdotV124), _FresnelSet.z ) );
                float temp_output_126_0 = saturate( fresnelNode124 );
                float lerpResult127 = lerp( temp_output_126_0 , ( 1.0 - temp_output_126_0 ) , _FresnelMode);
                float4 lerpResult245 = lerp( temp_cast_10 , ( _FresnelColor * lerpResult127 ) , _FresnelSwitch);
                float4 FresnelColor132 = lerpResult245;
                float4 baseColor = ( MainTexColor113 * float4( GamColor103 , 0.0 ) * input.ase_color );
                float4 dissolveBlendedColor = lerp( 
                    ( baseColor * float4( DissolveColor304 , 0.0 ) ),  // 乘法混合
                    ( baseColor + dissolvealphaEDGE),  // 加法混合
                    _DissolveColorMode
                );
                float4 temp_output_338_0 = dissolveBlendedColor;

                float4 lerpResult347 = lerp( ( temp_output_338_0 * FresnelColor132 ) , ( temp_output_338_0 + FresnelColor132 ) , _FresnelColorMode);
                float4 temp_cast_13 = (ValueZero).xxxx;
                float2 appendResult210 = (float2(_LiuguangUSpeed , _LiuguangVSpeed));
                float2 uv_LiuguangTex = input.ase_texcoord6.xy * _LiuguangTex_ST.xy + _LiuguangTex_ST.zw;
                float cos240 = cos( ( ( _LiuguangTexRotator * PI ) / ValueHalfCircle ) );
                float sin240 = sin( ( ( _LiuguangTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator240 = mul( uv_LiuguangTex - float2( 0.5,0.5 ) , float2x2( cos240 , -sin240 , sin240 , cos240 )) + float2( 0.5,0.5 );
                float2 appendResult227 = (float2(_LiuguangPolarScale.x , _LiuguangPolarScale.y));
                float2 temp_output_34_0_g4 = ( uv_LiuguangTex - appendResult227 );
                float2 break39_g4 = temp_output_34_0_g4;
                float2 appendResult50_g4 = (float2(( _LiuguangPolarScale.z * ( length( temp_output_34_0_g4 ) * 2.0 ) ) , ( ( atan2( break39_g4.x , break39_g4.y ) * ( 1.0 / TWO_PI ) ) * _LiuguangPolarScale.w )));
                float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ScreenPos );
                float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
                float2 appendResult225 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
                float2 appendResult226 = (float2(_LiuguangScreenTilingOffset.x , _LiuguangScreenTilingOffset.y));
                float2 appendResult228 = (float2(_LiuguangScreenTilingOffset.z , _LiuguangScreenTilingOffset.w));
                #if defined( _LIUGUANGTEXUVMODE_LOCAL )
                float2 staticSwitch239 = rotator240;
                #elif defined( _LIUGUANGTEXUVMODE_POLAR )
                float2 staticSwitch239 = appendResult50_g4;
                #elif defined( _LIUGUANGTEXUVMODE_SCREEN )
                float2 staticSwitch239 = (appendResult225*appendResult226 + appendResult228);
                #else
                float2 staticSwitch239 = rotator240;
                #endif
                float2 panner215 = ( 1.0 * _Time.y * appendResult210 + staticSwitch239);

                //优化流光纹理采样条件, 避免不必要的采样
                float4 tex2DNode196 = float4(0,0,0,0);
                if (_LiuguangSwitch > 0.01)
                {
                    tex2DNode196 = tex2D( _LiuguangTex, panner215 );
                }

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
                float cos161 = cos( ( ( _MaskTexRotator * PI ) / ValueHalfCircle ) );
                float sin161 = sin( ( ( _MaskTexRotator * PI ) / ValueHalfCircle ) );
                float2 rotator161 = mul( lerpResult459 - float2( 0.5,0.5 ) , float2x2( cos161 , -sin161 , sin161 , cos161 )) + float2( 0.5,0.5 );
                float2 lerpResult172 = lerp( rotator161 , saturate( rotator161 ) , _MaskTexClamp);

                //优化遮罩纹理采样条件, 避免不必要的采样
                float4 tex2DNode158 = float4(0,0,0,0);
                if (_MaskSwitch > 0.01)
                {
                    tex2DNode158 = tex2D( _MaskTex, lerpResult172 );
                }

                float lerpResult171 = lerp( tex2DNode158.r , tex2DNode158.a , _MaskTexP);
                float smoothstepResult383 = smoothstep( 1.0 , -1.0 , lerpResult171);
                float lerpResult380 = lerp( lerpResult171 , smoothstepResult383 , _OneMinusMask);
                float lerpResult247 = lerp( Toggle168 , lerpResult380 , _MaskSwitch);
                float MaskTexAlpha193 = lerpResult247;
                float2 appendResult180 = (float2(_MaskTexPlusUspeed , _MaskTexPlusVspeed));
                float2 uv_MaskTexPlus = input.ase_texcoord6.xy * _MaskTexPlus_ST.xy + _MaskTexPlus_ST.zw;
                float2 panner181 = ( 1.0 * _Time.y * appendResult180 + uv_MaskTexPlus);
                float cos186 = cos( ( ( _MaskTexPlusRotator * PI ) / ValueHalfCircle ) );
                float sin186 = sin( ( ( _MaskTexPlusRotator * PI ) / ValueHalfCircle ) );
                float2 rotator186 = mul( panner181 - float2( 0.5,0.5 ) , float2x2( cos186 , -sin186 , sin186 , cos186 )) + float2( 0.5,0.5 );
                float2 lerpResult190 = lerp( rotator186 , saturate( rotator186 ) , _MaskTexPlusClamp);

                //优化额外遮罩纹理采样条件, 避免不必要的采样
                float4 tex2DNode187 = float4(0,0,0,0);
                if (_MaskTexPlusSwitch > 0.01)
                {
                    tex2DNode187 = tex2D( _MaskTexPlus, lerpResult190 );
                }

                float lerpResult188 = lerp( tex2DNode187.r , tex2DNode187.a , _MaskTexPlusP);
                float lerpResult435 = lerp( lerpResult188 , ProMask431 , _MaskPlusUsePro);
                float lerpResult241 = lerp( Toggle168 , lerpResult435 , _MaskTexPlusSwitch);
                float MaskTexPlusAlpha194 = lerpResult241;
                float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
                ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;

                //优化软粒子 深度纹理采样
                float SoftParticleAlpha402 = 1.0;
                #if defined(_SOFT_PARTICLES_ON)
                    if (_SoftParticle > 0.001)
                    {
                        float4 screenPos = input.scrPos / input.scrPos.w;
                        screenPos.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPos.z : screenPos.z * 0.5 + 0.5;
                        float screenDepth399 = LinearEyeDepth(SampleSceneDepth( screenPos.xy ),_ZBufferParams);
                        float distanceDepth399 = abs( ( screenDepth399 - LinearEyeDepth(screenPos.z,_ZBufferParams ) ) / ( _SoftParticle ) );
                        SoftParticleAlpha402 = saturate( distanceDepth399 );
                    }
                #endif

                float temp_output_365_0 = ( MainTexAlpha114 * input.ase_color.a * DissolveAlpha305 * MaskTexAlpha193 * MaskTexPlusAlpha194 * SoftParticleAlpha402 );
                float lerpResult93 = lerp( tex2DNode101.r , tex2DNode101.a , _GamTexP);
                float lerpResult355 = lerp( Toggle168 , lerpResult93 , _GamTexSwitch);
                float GamAlpha123 = lerpResult355;
                float lerpResult371 = lerp( temp_output_365_0 , ( temp_output_365_0 * GamAlpha123 ) , _GamAlphaMode);
                float FresnelAlpha389 = ( _FresnelColor.a * lerpResult127 );
                float lerpResult392 = lerp( lerpResult371 , ( lerpResult371 * FresnelAlpha389 ) , _FresnelAlphaMode);
                
                float3 Color = (( lerpResult347 + LiuguangColor223 )).rgb;
                float Alpha = saturate( lerpResult392 );

                return half4( Color, Alpha );
            }
            ENDHLSL
        }
    }
    CustomEditor "ShaderGUI_AllEffect"
    FallBack "Hidden/Shader Graph/FallbackError"
    Fallback Off
}