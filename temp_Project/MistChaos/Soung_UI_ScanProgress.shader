// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Soung/UI/SP_Progress"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [HideInInspector]_Color ("Tint", Color) = (1,1,1,1)

        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255

        [HideInInspector]_ColorMask ("Color Mask", Float) = 15

        [HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Header(Setting)][Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
        [Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1
        [Header(ProgressControl)]_XProgress("X向进度值 (_XProgress)", Range( 0 , 1)) = 1
        _YProgress("Y向进度值 (_YProgress)", Range( 0 , 1)) = 1
        _ScanXProgress("扫光X向进度 (_ScanXProgress)", Range( 0 , 1)) = 0.5
        _ScanYProgress("扫光Y向进度 (_ScanYProgress)", Range( 0 , 1)) = 0.5
        [Header(MainTex)]_SetTexture("进度条贴图", 2D) = "white" {}
        [Enum(R,0,A,1)]_SetTexturePannel("进度条通道", Float) = 1
        [HDR]_SetTextureColor("进度条颜色", Color) = (1,1,1,1)
        [IntRange]_SetTextureRotator("进度条旋转", Range( 0 , 360)) = 0
        _SetTexHue("进度条色相变换", Range( 0 , 1)) = 0
        _SetTexSaturation("进度条饱和度", Range( 0 , 1.5)) = 1
        [Header(ProgressMaskTex)][Enum(OFF,0,ON,1)]_MaskSwitch("进度遮罩开关", Float) = 0
        [NoScaleOffset]_ProgressMaskTex("进度条遮罩", 2D) = "white" {}
        [Enum(R,0,A,1)]_ProgressMaskTexP("遮罩贴图通道", Float) = 0
        [IntRange]_MaskTexRotator("遮罩贴图旋转", Range( 0 , 360)) = 0
        [Enum(Repeat,0,Clamp,1)]_MaskTexClamp("遮罩贴图重铺模式", Float) = 0
        [Enum(OFF,0,ON,1)]_OneMinusMask("反相遮罩", Float) = 0
        [Header(SaoGuang)][Enum(OFF,0,ON,1)]_LiuguangSwitch("扫光开关", Float) = 0
        [NoScaleOffset]_LiuguangTex1("扫光贴图", 2D) = "black" {}
        [HDR]_LiuguangColor1("扫光颜色", Color) = (0,0,0,1)
        [IntRange]_LiuguangTexRotator1("扫光贴图旋转", Range( 0 , 360)) = 0
        [Enum(Repeat,0,Clamp,1)]_LiuguangTexClamp1("扫光贴图重铺模式", Float) = 0
        [Enum(R,0,A,1)]_LiuguangTexP1("扫光贴图通道", Float) = 0
        [Header(InnerTex)][Enum(OFF,0,ON,1)]_InnerTexSwitch("内部纹理开关", Float) = 0
        _InnerTex("内部纹理", 2D) = "black" {}
        [Enum(R,0,A,1)]_InnerTexP("内部纹理通道", Float) = 0
        [IntRange]_InnerTexRotator("内部纹理旋转", Range( 0 , 360)) = 0
        [Enum(Local,0,Polar,1)]_InnerTexUVmode("内部纹理模式", Float) = 0
        [Toggle]_UseLGTexColor("是否禁用内部自身颜色", Float) = 1
        [HDR]_LInnerColor("内部纹理颜色", Color) = (0,0,0,1)
        _InnerPolarScale("内部Polar中心与缩放", Vector) = (0.5,0.5,1,1)
        _InnerTexUSpeed("内部纹理U速率", Float) = 0
        _InnerTexVSpeed("内部纹理V速率", Float) = 0
        [HideInInspector]_ProgressUTilling("ProgressUTilling", Float) = 1
        [HideInInspector]_ProgressVTilling("ProgressVTilling", Float) = 1
        [HideInInspector]_SaoguangTilling("SaoguangTilling", Vector) = (0,0,0,0)

    }

    SubShader
    {
		LOD 0

        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

        Stencil
        {
        	Ref [_Stencil]
        	ReadMask [_StencilReadMask]
        	WriteMask [_StencilWriteMask]
        	Comp [_StencilComp]
        	Pass [_StencilOp]
        }


        Cull [_CullingMode]
        Lighting Off
        ZWrite Off
        ZTest LEqual
        Blend SrcAlpha [_BlendMode]
        ColorMask RGBA

        
        Pass
        {
            Name "Default"
        CGPROGRAM
            #define ASE_VERSION 19801

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityShaderVariables.cginc"


            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            uniform float _BlendMode;
            uniform float _CullingMode;
            uniform float4 _SetTextureColor;
            uniform float _SetTexHue;
            uniform sampler2D _SetTexture;
            uniform float4 _SetTexture_ST;
            uniform float _SetTextureRotator;
            uniform float _SetTexSaturation;
            uniform sampler2D _InnerTex;
            uniform float _InnerTexUSpeed;
            uniform float _InnerTexVSpeed;
            uniform float4 _InnerTex_ST;
            uniform float _InnerTexRotator;
            uniform float4 _InnerPolarScale;
            uniform float _InnerTexUVmode;
            uniform float _InnerTexP;
            uniform float4 _LInnerColor;
            uniform float _UseLGTexColor;
            uniform float _InnerTexSwitch;
            uniform sampler2D _LiuguangTex1;
            uniform float2 _SaoguangTilling;
            uniform float _ScanXProgress;
            uniform float _ScanYProgress;
            uniform float _LiuguangTexRotator1;
            uniform float _LiuguangTexClamp1;
            uniform float _LiuguangTexP1;
            uniform float4 _LiuguangColor1;
            uniform float _LiuguangSwitch;
            uniform float _SetTexturePannel;
            uniform sampler2D _ProgressMaskTex;
            uniform float _ProgressUTilling;
            uniform float _ProgressVTilling;
            uniform float _XProgress;
            uniform float _YProgress;
            uniform float _MaskTexRotator;
            uniform float _MaskTexClamp;
            uniform float _ProgressMaskTexP;
            uniform float _OneMinusMask;
            uniform float _MaskSwitch;
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


            v2f vert(appdata_t v )
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                

                v.vertex.xyz +=  float3( 0, 0, 0 ) ;

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = v.texcoord;
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN ) : SV_Target
            {
                //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
                //The incoming alpha could have numerical instability, which makes it very sensible to
                //HDR color transparency blend, when it blends with the world's texture.
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

                float2 uv_SetTexture = IN.texcoord.xy * _SetTexture_ST.xy + _SetTexture_ST.zw;
                float Rotator180481 = 180.0;
                float cos646 = cos( ( ( _SetTextureRotator * UNITY_PI ) / Rotator180481 ) );
                float sin646 = sin( ( ( _SetTextureRotator * UNITY_PI ) / Rotator180481 ) );
                float2 rotator646 = mul( uv_SetTexture - float2( 0.5,0.5 ) , float2x2( cos646 , -sin646 , sin646 , cos646 )) + float2( 0.5,0.5 );
                float4 tex2DNode692 = tex2D( _SetTexture, rotator646 );
                float3 hsvTorgb707 = RGBToHSV( tex2DNode692.rgb );
                float3 hsvTorgb746 = HSVToRGB( float3(( _SetTexHue + hsvTorgb707.x ),( hsvTorgb707.y * _SetTexSaturation ),hsvTorgb707.z) );
                float4 SetTexColor781 = ( _SetTextureColor * float4( hsvTorgb746 , 0.0 ) );
                float Toggle0507 = 0.0;
                float4 temp_cast_2 = (Toggle0507).xxxx;
                float2 appendResult694 = (float2(_InnerTexUSpeed , _InnerTexVSpeed));
                float2 uv_InnerTex = IN.texcoord.xy * _InnerTex_ST.xy + _InnerTex_ST.zw;
                float cos681 = cos( ( ( _InnerTexRotator * UNITY_PI ) / Rotator180481 ) );
                float sin681 = sin( ( ( _InnerTexRotator * UNITY_PI ) / Rotator180481 ) );
                float2 rotator681 = mul( uv_InnerTex - float2( 0.5,0.5 ) , float2x2( cos681 , -sin681 , sin681 , cos681 )) + float2( 0.5,0.5 );
                float2 appendResult664 = (float2(_InnerPolarScale.x , _InnerPolarScale.y));
                float2 temp_output_34_0_g8 = ( uv_InnerTex - appendResult664 );
                float2 break39_g8 = temp_output_34_0_g8;
                float2 appendResult50_g8 = (float2(( _InnerPolarScale.z * ( length( temp_output_34_0_g8 ) * 2.0 ) ) , ( ( atan2( break39_g8.x , break39_g8.y ) * ( 1.0 / 6.28318548202515 ) ) * _InnerPolarScale.w )));
                float2 lerpResult902 = lerp( rotator681 , appendResult50_g8 , _InnerTexUVmode);
                float2 panner709 = ( 1.0 * _Time.y * appendResult694 + lerpResult902);
                float4 tex2DNode732 = tex2D( _InnerTex, panner709 );
                float lerpResult748 = lerp( tex2DNode732.r , tex2DNode732.a , _InnerTexP);
                float4 lerpResult795 = lerp( ( float4( ( tex2DNode732.rgb * lerpResult748 ) , 0.0 ) * _LInnerColor ) , ( lerpResult748 * _LInnerColor ) , _UseLGTexColor);
                float4 lerpResult809 = lerp( temp_cast_2 , lerpResult795 , _InnerTexSwitch);
                float4 LiuguangColor817 = lerpResult809;
                float4 temp_cast_4 = (Toggle0507).xxxx;
                float2 appendResult901 = (float2((1.0 + (_ScanXProgress - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) , (1.0 + (_ScanYProgress - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0))));
                float2 texCoord853 = IN.texcoord.xy * _SaoguangTilling + appendResult901;
                float cos855 = cos( ( ( _LiuguangTexRotator1 * UNITY_PI ) / Rotator180481 ) );
                float sin855 = sin( ( ( _LiuguangTexRotator1 * UNITY_PI ) / Rotator180481 ) );
                float2 rotator855 = mul( texCoord853 - float2( 0.5,0.5 ) , float2x2( cos855 , -sin855 , sin855 , cos855 )) + float2( 0.5,0.5 );
                float2 lerpResult879 = lerp( rotator855 , saturate( rotator855 ) , _LiuguangTexClamp1);
                float4 tex2DNode863 = tex2D( _LiuguangTex1, lerpResult879 );
                float lerpResult864 = lerp( tex2DNode863.r , tex2DNode863.a , _LiuguangTexP1);
                float4 lerpResult874 = lerp( temp_cast_4 , ( lerpResult864 * _LiuguangColor1 ) , _LiuguangSwitch);
                float4 LiuguangColor2875 = lerpResult874;
                float lerpResult712 = lerp( tex2DNode692.r , tex2DNode692.a , _SetTexturePannel);
                float SetTexAlpha752 = ( lerpResult712 * _SetTextureColor.a );
                float Toggle1704 = 1.0;
                float2 appendResult887 = (float2(_ProgressUTilling , _ProgressVTilling));
                float2 appendResult888 = (float2((1.0 + (_XProgress - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) , (1.0 + (_YProgress - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))));
                float2 texCoord580 = IN.texcoord.xy * appendResult887 + appendResult888;
                float cos633 = cos( ( ( _MaskTexRotator * UNITY_PI ) / Rotator180481 ) );
                float sin633 = sin( ( ( _MaskTexRotator * UNITY_PI ) / Rotator180481 ) );
                float2 rotator633 = mul( texCoord580 - float2( 0.5,0.5 ) , float2x2( cos633 , -sin633 , sin633 , cos633 )) + float2( 0.5,0.5 );
                float2 lerpResult658 = lerp( rotator633 , saturate( rotator633 ) , _MaskTexClamp);
                float4 tex2DNode673 = tex2D( _ProgressMaskTex, lerpResult658 );
                float lerpResult687 = lerp( tex2DNode673.r , tex2DNode673.a , _ProgressMaskTexP);
                float smoothstepResult699 = smoothstep( 1.0 , -1.0 , lerpResult687);
                float lerpResult721 = lerp( lerpResult687 , smoothstepResult699 , _OneMinusMask);
                float lerpResult738 = lerp( Toggle1704 , lerpResult721 , _MaskSwitch);
                float MaskTexAlpha755 = lerpResult738;
                float4 appendResult839 = (float4((( SetTexColor781 + LiuguangColor817 + LiuguangColor2875 )).rgb , saturate( ( SetTexAlpha752 * MaskTexAlpha755 ) )));
                

                half4 color = appendResult839;

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.rgb *= color.a;

                return color;
            }
        ENDCG
        }
    }
    CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;472;766.1603,150.1194;Inherit;False;371;306;Comment;6;704;689;507;500;481;479;计算常量;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;611;-2455.281,705.6949;Inherit;False;3066.189;934.3901;InnerTexture;16;817;809;797;796;795;787;783;782;765;764;748;731;732;709;694;628;内部纹理;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;479;775.1603,193.1195;Inherit;False;Constant;_RotatorDivide;RotatorDivide;67;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;628;-2440.5,762.64;Inherit;False;1056.535;855.266;UV模式;13;681;678;666;665;664;650;649;648;638;679;680;903;902;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;840;-2449.163,1670.288;Inherit;False;2125.26;528.2299;LiuguangTexture;13;875;873;874;872;867;869;862;864;863;878;877;879;841;扫光;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;481;942.1605,193.1195;Inherit;False;Rotator180;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;555;-2456.89,160.7319;Inherit;False;2216.961;509.7959;ProgressMask;19;619;596;579;755;738;721;720;719;699;698;687;674;673;658;644;643;633;597;580;进度遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;638;-2418.196,933.606;Inherit;False;Property;_InnerTexRotator;内部纹理旋转;27;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;883;-3073.515,270.2393;Inherit;False;Property;_XProgress;X向进度值 (_XProgress);2;1;[Header];Create;False;1;ProgressControl;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;884;-3072.515,437.2393;Inherit;False;Property;_YProgress;Y向进度值 (_YProgress);3;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;841;-2434.383,1727.233;Inherit;False;775.9786;322.1257;贴图旋转;7;855;849;853;844;843;900;842;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;494;-2455.374,-527.2669;Inherit;False;2474.13;655.2713;UI Texture;7;714;712;697;692;690;523;583;UI进度图;1,1,1,1;0;0
Node;AmplifyShaderEditor.PiNode;648;-2153.192,938.606;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;649;-2152.453,1007.775;Inherit;False;481;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;579;-2444.052,379.298;Inherit;False;Property;_MaskTexRotator;遮罩贴图旋转;15;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;885;-2810.515,106.2393;Inherit;False;Property;_ProgressUTilling;ProgressUTilling;34;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;886;-2811.515,183.2394;Inherit;False;Property;_ProgressVTilling;ProgressVTilling;35;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;897;-2794.278,436.581;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;896;-2795.278,269.581;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;650;-2245.803,1087.509;Inherit;False;Property;_InnerPolarScale;内部Polar中心与缩放;31;0;Create;False;0;0;0;False;0;False;0.5,0.5,1,1;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;899;-3064.003,1922.793;Inherit;False;Property;_ScanYProgress;扫光Y向进度 (_ScanYProgress);5;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;898;-3068.703,1743.993;Inherit;False;Property;_ScanXProgress;扫光X向进度 (_ScanXProgress);4;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;583;-2208.121,-354.8519;Inherit;False;757;229;贴图旋转;5;646;623;635;622;603;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;664;-2018.801,1116.509;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;665;-1977.193,938.606;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;666;-2148.92,812.097;Inherit;False;0;732;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;596;-2179.053,378.2979;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;597;-2172.054,454.298;Inherit;False;481;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;887;-2605.515,131.2394;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;888;-2618.515,369.2393;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;842;-2414.078,1898.2;Inherit;False;Property;_LiuguangTexRotator1;扫光贴图旋转;21;1;[IntRange];Create;False;0;0;0;False;0;False;0;270;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;904;-2778.453,1696.15;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;905;-2775.453,1871.15;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;678;-1887.107,1092.377;Inherit;False;Polar Coordinates;-1;;8;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;3;FLOAT2;0;FLOAT;55;FLOAT;56
Node;AmplifyShaderEditor.RotatorNode;681;-1858.553,890.7429;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;603;-2199.121,-272.8521;Inherit;False;Property;_SetTextureRotator;进度条旋转;9;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;580;-2429.143,221.8933;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;619;-1997.051,377.2979;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;900;-2408.61,1770.774;Inherit;False;Property;_SaoguangTilling;SaoguangTilling;36;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PiNode;843;-2145.075,1897.2;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;844;-2146.334,1972.369;Inherit;False;481;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;901;-2584.046,1823.817;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;680;-1655.712,946.1461;Inherit;False;Property;_InnerTexVSpeed;内部纹理V速率;33;0;Create;False;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;679;-1650.363,872.043;Inherit;False;Property;_InnerTexUSpeed;内部纹理U速率;32;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;903;-2016.508,1290.518;Inherit;False;Property;_InnerTexUVmode;内部纹理模式;28;1;[Enum];Create;False;0;2;Local;0;Polar;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;694;-1454.08,897.4968;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;622;-1930.12,-272.8521;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;623;-1929.12,-197.8523;Inherit;False;481;Rotator180;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;633;-1862.179,222.5334;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;902;-1618.508,1076.518;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;853;-2146.802,1772.69;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;849;-1972.074,1896.2;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;709;-1306.099,826.9179;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;523;-2447.088,-314.2929;Inherit;False;0;692;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;635;-1756.12,-272.8521;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;643;-1680.159,285.2385;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;644;-1742.159,358.2386;Inherit;False;Property;_MaskTexClamp;遮罩贴图重铺模式;16;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;855;-1831.434,1848.336;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;732;-1128.272,802.5989;Inherit;True;Property;_InnerTex;内部纹理;25;0;Create;False;1;LiuguangTex;0;0;False;0;False;-1;None;d0b405e940fc2f14ea93da3e3151e018;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RotatorNode;646;-1619.608,-319.4072;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;658;-1533.158,223.2385;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;877;-1655.713,1908.113;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;878;-1853.714,2058.112;Inherit;False;Property;_LiuguangTexClamp1;扫光贴图重铺模式;22;1;[Enum];Create;False;0;2;Repeat;0;Clamp;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;731;-1024.219,997.366;Inherit;False;Property;_InnerTexP;内部纹理通道;26;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;690;-946.9261,-466.6281;Inherit;False;950.814;547.9072;色相变换/拆分通道;10;781;762;746;728;729;710;711;707;752;733;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;748;-836.6648,898.085;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;692;-1436.95,-343.4365;Inherit;True;Property;_SetTexture;进度条贴图;6;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;765bdf24512fbf14ea67ba22e1dbbe1e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;674;-1261.964,420.8321;Inherit;False;Property;_ProgressMaskTexP;遮罩贴图通道;14;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;673;-1393.893,212.5906;Inherit;True;Property;_ProgressMaskTex;进度条遮罩;13;1;[NoScaleOffset];Create;False;1;MaskTex;0;0;False;0;False;-1;None;6c7f4fc440a50dd4a944dce917185de9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;879;-1518.713,1849.112;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;500;779.2643,268.3121;Inherit;False;Constant;_EmptyValue;EmptyValue;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;689;778.2643,347.312;Inherit;False;Constant;_BaseValue;BaseValue;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;764;-678.8906,788.1889;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;711;-931.6754,-420.1523;Inherit;False;Property;_SetTexHue;进度条色相变换;10;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;710;-925.6754,-193.1536;Inherit;False;Property;_SetTexSaturation;进度条饱和度;11;0;Create;False;0;0;0;False;0;False;1;1;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;707;-926.6754,-342.1534;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;687;-1106.965,307.832;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;863;-1375.141,1719.383;Inherit;True;Property;_LiuguangTex1;扫光贴图;19;1;[NoScaleOffset];Create;False;1;LiuguangTex;0;0;False;0;False;-1;None;c4ecadd2713eab24d875e74727872101;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;862;-1280.089,1911.15;Inherit;False;Property;_LiuguangTexP1;扫光贴图通道;23;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;765;-835.0667,1023.055;Inherit;False;Property;_LInnerColor;内部纹理颜色;30;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;1.040648,5.656854,2.300717,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;942.2645,269.3121;Inherit;False;Toggle0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;704;943.2645,343.312;Inherit;False;Toggle1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;782;-520.1377,788.6729;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;783;-520.1377,1010.676;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;729;-656.6754,-390.1533;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;728;-657.6754,-216.1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;697;-1301.675,-148.0285;Inherit;False;Property;_SetTexturePannel;进度条通道;7;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;698;-926.0953,430.9304;Inherit;False;Property;_OneMinusMask;反相遮罩;17;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;699;-947.0953,314.9305;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;864;-1092.535,1833.869;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;867;-1153.937,1981.84;Inherit;False;Property;_LiuguangColor1;扫光颜色;20;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;1.040648,5.656854,2.300717,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;787;-324.1377,1086.675;Inherit;False;Property;_UseLGTexColor;是否禁用内部自身颜色;29;1;[Toggle];Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;795;-108.8519,868.7559;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;796;-59.52172,792.009;Inherit;False;507;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;712;-1157.676,-245.1534;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;714;-1303.675,-74.02802;Inherit;False;Property;_SetTextureColor;进度条颜色;8;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.HSVToRGBNode;746;-511.6753,-318.1534;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;719;-1116.994,231.2637;Inherit;False;704;Toggle1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;721;-779.153,307.7975;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-1080.994,433.2637;Inherit;False;Property;_MaskSwitch;进度遮罩开关;12;2;[Header];[Enum];Create;False;1;ProgressMaskTex;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;869;-912.0074,1788.461;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;872;-881.2914,1717.393;Inherit;False;507;Toggle0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;873;-852.9086,2003.662;Inherit;False;Property;_LiuguangSwitch;扫光开关;18;2;[Header];[Enum];Create;False;1;SaoGuang;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;797;118.6611,939.4781;Inherit;False;Property;_InnerTexSwitch;内部纹理开关;24;2;[Header];[Enum];Create;False;1;InnerTex;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;809;261.6611,843.478;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;733;-934.6754,-15.15305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;762;-336.6747,-81.15352;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;738;-631.9933,284.2637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;874;-690.1083,1815.362;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;780;-218.3627,159.9089;Inherit;False;573.834;275.3175;ALLColor;5;835;829;876;825;799;最终输出颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;751;-217.5684,456.2872;Inherit;False;552.1401;210.6843;ALLAlpha;4;833;793;776;774;最终输出透明度;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;817;405.4781,843.009;Inherit;False;LiuguangColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;752;-796.6755,-14.15309;Inherit;False;SetTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;781;-197.675,-80.15361;Inherit;False;SetTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;755;-486.432,278.6901;Inherit;False;MaskTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;875;-540.9915,1810.793;Inherit;False;LiuguangColor2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;799;-201.4867,202.6782;Inherit;False;781;SetTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;825;-199.8908,277.5994;Inherit;False;817;LiuguangColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;876;-198.2177,353.205;Inherit;False;875;LiuguangColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;774;-199.7935,505.4575;Inherit;False;752;SetTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;776;-200.4417,581.8206;Inherit;False;755;MaskTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;829;29.54866,252.9967;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;793;18.54837,524.4575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;826;565.552,149.8821;Inherit;False;178.001;226.9965;Comment;2;832;830;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;835;144.5487,252.2015;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;833;162.4272,524.8741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;830;578.246,206.9945;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;832;579.731,286.026;Inherit;False;Property;_CullingMode;剔除模式;0;2;[Header];[Enum];Create;False;1;Setting;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;839;416.1314,397.9012;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;462;563.0556,398.1247;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;3;Soung/UI/SP_Progress;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;2;True;_CullingMode;True;True;True;True;True;True;0;False;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;0;False;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;481;0;479;0
WireConnection;648;0;638;0
WireConnection;897;0;884;0
WireConnection;896;0;883;0
WireConnection;664;0;650;1
WireConnection;664;1;650;2
WireConnection;665;0;648;0
WireConnection;665;1;649;0
WireConnection;596;0;579;0
WireConnection;887;0;885;0
WireConnection;887;1;886;0
WireConnection;888;0;896;0
WireConnection;888;1;897;0
WireConnection;904;0;898;0
WireConnection;905;0;899;0
WireConnection;678;1;666;0
WireConnection;678;2;664;0
WireConnection;678;3;650;3
WireConnection;678;4;650;4
WireConnection;681;0;666;0
WireConnection;681;2;665;0
WireConnection;580;0;887;0
WireConnection;580;1;888;0
WireConnection;619;0;596;0
WireConnection;619;1;597;0
WireConnection;843;0;842;0
WireConnection;901;0;904;0
WireConnection;901;1;905;0
WireConnection;694;0;679;0
WireConnection;694;1;680;0
WireConnection;622;0;603;0
WireConnection;633;0;580;0
WireConnection;633;2;619;0
WireConnection;902;0;681;0
WireConnection;902;1;678;0
WireConnection;902;2;903;0
WireConnection;853;0;900;0
WireConnection;853;1;901;0
WireConnection;849;0;843;0
WireConnection;849;1;844;0
WireConnection;709;0;902;0
WireConnection;709;2;694;0
WireConnection;635;0;622;0
WireConnection;635;1;623;0
WireConnection;643;0;633;0
WireConnection;855;0;853;0
WireConnection;855;2;849;0
WireConnection;732;1;709;0
WireConnection;646;0;523;0
WireConnection;646;2;635;0
WireConnection;658;0;633;0
WireConnection;658;1;643;0
WireConnection;658;2;644;0
WireConnection;877;0;855;0
WireConnection;748;0;732;1
WireConnection;748;1;732;4
WireConnection;748;2;731;0
WireConnection;692;1;646;0
WireConnection;673;1;658;0
WireConnection;879;0;855;0
WireConnection;879;1;877;0
WireConnection;879;2;878;0
WireConnection;764;0;732;5
WireConnection;764;1;748;0
WireConnection;707;0;692;0
WireConnection;687;0;673;1
WireConnection;687;1;673;4
WireConnection;687;2;674;0
WireConnection;863;1;879;0
WireConnection;507;0;500;0
WireConnection;704;0;689;0
WireConnection;782;0;764;0
WireConnection;782;1;765;0
WireConnection;783;0;748;0
WireConnection;783;1;765;0
WireConnection;729;0;711;0
WireConnection;729;1;707;1
WireConnection;728;0;707;2
WireConnection;728;1;710;0
WireConnection;699;0;687;0
WireConnection;864;0;863;1
WireConnection;864;1;863;4
WireConnection;864;2;862;0
WireConnection;795;0;782;0
WireConnection;795;1;783;0
WireConnection;795;2;787;0
WireConnection;712;0;692;1
WireConnection;712;1;692;4
WireConnection;712;2;697;0
WireConnection;746;0;729;0
WireConnection;746;1;728;0
WireConnection;746;2;707;3
WireConnection;721;0;687;0
WireConnection;721;1;699;0
WireConnection;721;2;698;0
WireConnection;869;0;864;0
WireConnection;869;1;867;0
WireConnection;809;0;796;0
WireConnection;809;1;795;0
WireConnection;809;2;797;0
WireConnection;733;0;712;0
WireConnection;733;1;714;4
WireConnection;762;0;714;0
WireConnection;762;1;746;0
WireConnection;738;0;719;0
WireConnection;738;1;721;0
WireConnection;738;2;720;0
WireConnection;874;0;872;0
WireConnection;874;1;869;0
WireConnection;874;2;873;0
WireConnection;817;0;809;0
WireConnection;752;0;733;0
WireConnection;781;0;762;0
WireConnection;755;0;738;0
WireConnection;875;0;874;0
WireConnection;829;0;799;0
WireConnection;829;1;825;0
WireConnection;829;2;876;0
WireConnection;793;0;774;0
WireConnection;793;1;776;0
WireConnection;835;0;829;0
WireConnection;833;0;793;0
WireConnection;839;0;835;0
WireConnection;839;3;833;0
WireConnection;462;0;839;0
ASEEND*/
//CHKSM=E13B7573DB8699ABF0E47B2F3F1692C222F43F84