// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/UI/扰动与溶解"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Header(NoiseTex)]_Distr("扰动贴图", 2D) = "black" {}
        [KeywordEnum(R,A)] _Keyword0("扰动贴图通道", Float) = 0
        _NoiseInt("扰动强度", Range( 0 , 1)) = 0.06342169
        _NoiseU("扰动U方向速率", Float) = 1
        _NoiseV("扰动V方向速率", Float) = 1
        [Enum(Off,0,On,1)]_noiseinfdis("扰动可影响溶解", Float) = 0
        [Header(DissolveTex)]_Dissolve("溶解贴图", 2D) = "black" {}
        _DissolveStep("溶解进度", Range( 0 , 1.05)) = 0.451481
        _EdgeWitgh("边缘宽度", Float) = 0.05
        [HDR]_EdgeColor("边缘颜色", Color) = (1,1,1,0.5450981)

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

            uniform sampler2D _Distr;
            uniform float _NoiseU;
            uniform float _NoiseV;
            uniform float4 _Distr_ST;
            uniform float _NoiseInt;
            uniform float4 _EdgeColor;
            uniform float _DissolveStep;
            uniform sampler2D _Dissolve;
            uniform float4 _Dissolve_ST;
            uniform float _EdgeWitgh;
            uniform float _noiseinfdis;

            
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

                float2 texCoord34 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float2 appendResult31 = (float2(_NoiseU , _NoiseV));
                float2 uv_Distr = IN.texcoord.xy * _Distr_ST.xy + _Distr_ST.zw;
                float2 panner35 = ( 1.0 * _Time.y * appendResult31 + uv_Distr);
                float4 tex2DNode37 = tex2D( _Distr, panner35 );
                #if defined(_KEYWORD0_R)
                float staticSwitch38 = tex2DNode37.r;
                #elif defined(_KEYWORD0_A)
                float staticSwitch38 = tex2DNode37.a;
                #else
                float staticSwitch38 = tex2DNode37.r;
                #endif
                float2 temp_cast_0 = (staticSwitch38).xx;
                float2 lerpResult29 = lerp( texCoord34 , temp_cast_0 , _NoiseInt);
                float4 tex2DNode7 = tex2D( _MainTex, lerpResult29 );
                float2 uv_Dissolve = IN.texcoord.xy * _Dissolve_ST.xy + _Dissolve_ST.zw;
                float4 tex2DNode17 = tex2D( _Dissolve, uv_Dissolve );
                float temp_output_22_0 = step( _DissolveStep , ( tex2DNode17.r + _EdgeWitgh ) );
                float temp_output_23_0 = ( temp_output_22_0 - step( _DissolveStep , tex2DNode17.r ) );
                float4 lerpResult13 = lerp( ( IN.color * tex2DNode7 ) , ( tex2DNode7.a * _EdgeColor * temp_output_23_0 ) , temp_output_23_0);
                float temp_output_14_0 = ( tex2DNode7.a * temp_output_22_0 * IN.color.a );
                float lerpResult44 = lerp( temp_output_14_0 , ( temp_output_14_0 * staticSwitch38 ) , _noiseinfdis);
                float clampResult41 = clamp( lerpResult44 , 0.0 , 1.0 );
                float4 appendResult15 = (float4((lerpResult13).rgba.rgb , clampResult41));
                

                half4 color = appendResult15;

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
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1763.843,652.7145;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;21;-1683.889,338.044;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;22;-1604.516,631.1702;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-1346.837,465.5426;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2519.067,345.1615;Inherit;False;Property;_NoiseInt;扰动强度;2;0;Create;False;0;0;0;False;0;False;0.06342169;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;35;-2728.035,182.2802;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;6;-1960.724,45.22297;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;38;-2259.648,225.4165;Inherit;False;Property;_Keyword0;扰动贴图通道;1;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3001.92,177.8802;Inherit;False;0;37;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2895.932,302.2799;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3060.532,299.8799;Inherit;False;Property;_NoiseU;扰动U方向速率;3;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-3058.532,375.8799;Inherit;False;Property;_NoiseV;扰动V方向速率;4;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;9;-1666.096,-123.5352;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1436.068,21.89233;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;13;-827.0757,25.20276;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;26;-596.7504,20.22339;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-401.9316,24.54059;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-181,25;Float;False;True;-1;2;ASEMaterialInspector;0;3;VFX/UI_扰动与溶解;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1128.682,151.0796;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-762.038,432.1441;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;41;-565.5181,101.8169;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-2287.456,439.2963;Inherit;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-2068.576,415.5333;Inherit;True;Property;_Dissolve;溶解贴图;6;1;[Header];Create;False;1;DissolveTex;0;0;False;0;False;-1;cbbfe64b9230aa845b124f9d0f947648;cbbfe64b9230aa845b124f9d0f947648;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1795.216,41.3092;Inherit;True;Property;_UISprites;UISprites;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-1934.4,671.4503;Inherit;False;Property;_EdgeWitgh;边缘宽度;8;0;Create;False;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2051.282,332.503;Inherit;False;Property;_DissolveStep;溶解进度;7;0;Create;False;0;0;0;False;0;False;0.451481;0;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-1378.368,171.8211;Inherit;False;Property;_EdgeColor;边缘颜色;9;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0.5450981;1,1,1,0.5450981;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-2557.947,153.2314;Inherit;True;Property;_Distr;扰动贴图;0;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;ef4eb6d271748b4478d1a301146f7faa;ef4eb6d271748b4478d1a301146f7faa;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-2483.425,30.11276;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;29;-2067.498,112.481;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-613.8046,494.7172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-474.6226,405.1353;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-614.6226,609.1353;Inherit;False;Property;_noiseinfdis;扰动可影响溶解;5;1;[Enum];Create;False;0;2;Off;0;On;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
WireConnection;19;0;17;1
WireConnection;19;1;20;0
WireConnection;21;0;18;0
WireConnection;21;1;17;1
WireConnection;22;0;18;0
WireConnection;22;1;19;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;35;0;36;0
WireConnection;35;2;31;0
WireConnection;38;1;37;1
WireConnection;38;0;37;4
WireConnection;31;0;33;0
WireConnection;31;1;32;0
WireConnection;40;0;9;0
WireConnection;40;1;7;0
WireConnection;13;0;40;0
WireConnection;13;1;24;0
WireConnection;13;2;23;0
WireConnection;26;0;13;0
WireConnection;15;0;26;0
WireConnection;15;3;41;0
WireConnection;0;0;15;0
WireConnection;24;0;7;4
WireConnection;24;1;25;0
WireConnection;24;2;23;0
WireConnection;14;0;7;4
WireConnection;14;1;22;0
WireConnection;14;2;9;4
WireConnection;41;0;44;0
WireConnection;17;1;39;0
WireConnection;7;0;6;0
WireConnection;7;1;29;0
WireConnection;37;1;35;0
WireConnection;29;0;34;0
WireConnection;29;1;38;0
WireConnection;29;2;30;0
WireConnection;42;0;14;0
WireConnection;42;1;38;0
WireConnection;44;0;14;0
WireConnection;44;1;42;0
WireConnection;44;2;43;0
ASEEND*/
//CHKSM=5719421C42FD851C0C88CEF1529C982B1CD99F1D