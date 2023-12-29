// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/UI/UI区域呼吸"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [HDR][Header(AutoColorChange)]_MainColor("霓虹颜色 (不能使用纯白纯黑)", Color) = (1,0,0.05476761,1)
        _MaskTex("区域遮罩", 2D) = "white" {}
        [Enum(Manual,0,Auto,1)]_ChangeMode("颜色变换模式", Float) = 1
        _ChangeValue("手动变换值", Range( -1 , 1)) = 0
        _ChangeSpeed("自动变换速度", Float) = 1
        [Header(AutoAlphaChange)][Enum(Manual,0,Auto,1)]_BreethMode("呼吸模式", Float) = 0
        _BreethMValue("手动呼吸值", Range( 0 , 1)) = 1
        _BreethTimeScale("自动呼吸间隔", Float) = 1
        _BreethColorScale("自动呼吸提亮", Range( 0 , 1)) = 0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

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


        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        
        Pass
        {
            Name "Default"
        CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

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

            uniform float4 _MainColor;
            uniform float _ChangeValue;
            uniform float _ChangeSpeed;
            uniform float _ChangeMode;
            uniform sampler2D _MaskTex;
            uniform float4 _MaskTex_ST;
            uniform float _BreethMValue;
            uniform float _BreethTimeScale;
            uniform float _BreethColorScale;
            uniform float _BreethMode;
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

                float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float3 hsvTorgb2 = RGBToHSV( _MainColor.rgb );
                float mulTime11 = _Time.y * _ChangeSpeed;
                float lerpResult15 = lerp( _ChangeValue , mulTime11 , _ChangeMode);
                float3 hsvTorgb3 = HSVToRGB( float3(( hsvTorgb2.x + lerpResult15 ),hsvTorgb2.y,hsvTorgb2.z) );
                float2 uv_MaskTex = IN.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
                float lerpResult28 = lerp( _BreethMValue , ( saturate( ( ( ( _SinTime.w + 1.0 ) / 2.0 ) * _BreethTimeScale ) ) + _BreethColorScale ) , _BreethMode);
                float4 break67 = ( tex2D( _MainTex, uv_MainTex ) + ( float4( hsvTorgb3 , 0.0 ) * tex2D( _MaskTex, uv_MaskTex ) * lerpResult28 ) );
                float4 appendResult65 = (float4(break67.r , break67.g , break67.b , saturate( break67.a )));
                

                half4 color = (appendResult65).xyzw;

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
    CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.RangedFloatNode;39;-1443.398,615.4666;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1090.978,684.2243;Inherit;False;Property;_BreethTimeScale;自动呼吸间隔;7;0;Create;False;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-856.2346,683.5349;Inherit;False;Property;_BreethColorScale;自动呼吸提亮;8;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;30;-1444.398,395.4651;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-1440.398,539.4658;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-544.2346,664.5349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;15;-944.1654,250.6931;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1266.298,245.3796;Inherit;False;Property;_ChangeValue;手动变换值;3;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;2;-972.1394,29.04467;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;12;-1318.956,315.7689;Inherit;False;Property;_ChangeSpeed;自动变换速度;4;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1160.166,392.6923;Inherit;False;Property;_ChangeMode;颜色变换模式;2;1;[Enum];Create;False;0;2;Manual;0;Auto;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;3;-592.9091,54.60231;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;28;-458.9664,344.4326;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-768.4171,340.2498;Inherit;False;Property;_BreethMValue;手动呼吸值;6;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-1167.957,320.7688;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1300.398,467.4651;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;42;-1181.398,467.4651;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-979.9769,467.2227;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-854.9771,468.2227;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-736.5578,226.2795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-625.9662,484.4326;Inherit;False;Property;_BreethMode;呼吸模式;5;2;[Header];[Enum];Create;False;1;AutoAlphaChange;2;Manual;0;Auto;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-1226.752,25.41363;Inherit;False;Property;_MainColor;霓虹颜色 (不能使用纯白纯黑);0;2;[HDR];[Header];Create;False;1;AutoColorChange;0;0;False;0;False;1,0,0.05476761,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-876.3165,826.9355;Inherit;False;0;60;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-262.9738,296.7065;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-101.4734,14.40652;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;16.02635,14.63936;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;68;143.0257,120.6394;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;270.025,15.63936;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;64;391.0248,10.63936;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;55;578.4506,16.1317;Float;False;True;-1;2;ASEMaterialInspector;0;3;VFX/UINeon;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;58;-657.3344,-144.0225;Inherit;True;Property;_TextureSample0;Texture Sample 0;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;59;-828.5227,-138.1672;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;60;-668.8369,803.7856;Inherit;True;Property;_MaskTex;区域遮罩;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;51;0;47;0
WireConnection;51;1;50;0
WireConnection;15;0;5;0
WireConnection;15;1;11;0
WireConnection;15;2;14;0
WireConnection;2;0;10;0
WireConnection;3;0;4;0
WireConnection;3;1;2;2
WireConnection;3;2;2;3
WireConnection;28;0;17;0
WireConnection;28;1;51;0
WireConnection;28;2;29;0
WireConnection;11;0;12;0
WireConnection;40;0;30;4
WireConnection;40;1;38;0
WireConnection;42;0;40;0
WireConnection;42;1;39;0
WireConnection;49;0;42;0
WireConnection;49;1;48;0
WireConnection;47;0;49;0
WireConnection;4;0;2;1
WireConnection;4;1;15;0
WireConnection;63;0;3;0
WireConnection;63;1;60;0
WireConnection;63;2;28;0
WireConnection;62;0;58;0
WireConnection;62;1;63;0
WireConnection;67;0;62;0
WireConnection;68;0;67;3
WireConnection;65;0;67;0
WireConnection;65;1;67;1
WireConnection;65;2;67;2
WireConnection;65;3;68;0
WireConnection;64;0;65;0
WireConnection;55;0;64;0
WireConnection;58;0;59;0
WireConnection;60;1;61;0
ASEEND*/
//CHKSM=D315075C6DFD54C1B0AF39CC28A28800369B98CA