// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/UI/自动故障扰动UI"
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

        _NoiseTex("扰动贴图", 2D) = "white" {}
        [Enum(U,0,V,1)]_NoisePivot("扰动方向 (匹配偏移量设置)", Float) = 0
        _NoiseScale("扰动强度", Range( 0 , 0.1)) = 0.1
        _RB_Offset("偏移量 (RU_RV_BU_BV)", Vector) = (0.05,0,0,0)
        _NoiseSpeed("扰动速率", Vector) = (1,1,0,0)
        [Enum(Manual,0,Auto,1)]_NoiseMode("扰动模式", Float) = 0
        _TimeScale("自动偏移频率", Float) = 2

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

            uniform sampler2D _NoiseTex;
            uniform float2 _NoiseSpeed;
            uniform float4 _NoiseTex_ST;
            uniform float _NoiseScale;
            uniform float _TimeScale;
            uniform float _NoiseMode;
            uniform float _NoisePivot;
            uniform float4 _RB_Offset;

            
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

                float2 texCoord11 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float2 uv_NoiseTex = IN.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                float2 panner9 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTex);
                float mulTime39 = _Time.y * _TimeScale;
                float lerpResult41 = lerp( _NoiseScale , ( _NoiseScale * sin( mulTime39 ) ) , _NoiseMode);
                float temp_output_48_0 = saturate( lerpResult41 );
                float temp_output_14_0 = ( (-0.5 + (tex2D( _NoiseTex, panner9 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * temp_output_48_0 );
                float lerpResult53 = lerp( ( texCoord11.x + temp_output_14_0 ) , texCoord11.x , _NoisePivot);
                float lerpResult54 = lerp( texCoord11.y , ( texCoord11.y + temp_output_14_0 ) , _NoisePivot);
                float2 appendResult13 = (float2(lerpResult53 , lerpResult54));
                float4 break20 = ( (0.0 + (temp_output_48_0 - 0.0) * (1.0 - 0.0) / (0.1 - 0.0)) * _RB_Offset );
                float2 appendResult26 = (float2(break20.x , break20.y));
                float4 tex2DNode4 = tex2D( _MainTex, appendResult13 );
                float2 appendResult27 = (float2(break20.z , break20.w));
                float4 appendResult30 = (float4(tex2D( _MainTex, ( appendResult13 + appendResult26 ) ).r , tex2DNode4.g , tex2D( _MainTex, ( appendResult13 + appendResult27 ) ).b , tex2DNode4.a));
                float4 break65 = ( IN.color * appendResult30 );
                float4 appendResult67 = (float4(break65.r , break65.g , break65.b , saturate( break65.a )));
                

                half4 color = (appendResult67).xyzw;

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
Node;AmplifyShaderEditor.PannerNode;9;-1917.814,121.3476;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2161.557,116.5701;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;10;-2088.814,239.3477;Inherit;False;Property;_NoiseSpeed;扰动速率;4;0;Create;False;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;27;-651.9914,387.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-651.9914,293.178;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-460.9824,153.3174;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-461.4291,360.2454;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-908.4456,307.7872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;8;-1731.218,92.67458;Inherit;True;Property;_NoiseTex;扰动贴图;0;0;Create;False;0;0;0;False;0;False;-1;6174f8d7f3f1fd142b2db0e097e10a17;6174f8d7f3f1fd142b2db0e097e10a17;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1640.33,475.9615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;39;-1917.55,499.9915;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;46;-1757.787,499.6698;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1637.397,575.9688;Inherit;False;Property;_NoiseMode;扰动模式;5;1;[Enum];Create;False;0;2;Manual;0;Auto;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;15;-1108.842,307.9935;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1906.621,412.3318;Inherit;False;Property;_NoiseScale;扰动强度;2;0;Create;False;0;0;0;False;0;False;0.1;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-1486.07,418.544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-1339.9,418.8646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1244.571,122.495;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1356.975,-8.81764;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;31;-1434.373,123;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1068.429,97.80939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-697.1879,16.22712;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;54;-881.5465,40.98477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;53;-888.5465,-144.0152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1020.467,-143.5107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-783.982,307.2344;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector4Node;17;-1110.394,476.3322;Inherit;False;Property;_RB_Offset;偏移量 (RU_RV_BU_BV);3;0;Create;False;0;0;0;False;0;False;0.05,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-1128.688,-7.643436;Inherit;False;Property;_NoisePivot;扰动方向 (匹配偏移量设置);1;1;[Enum];Create;False;0;2;U;0;V;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-77.57082,-199.4283;Inherit;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-78.42696,182.4539;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-79.42696,-9.54605;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;30;272.3496,19.77707;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;496.3331,-6.130898;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;63;-297.9657,-149.3214;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;57;240.2148,-151.8367;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;65;688.0596,-6.481674;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;67;941.0582,-6.481674;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;66;807.0589,66.51836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;68;1066.058,-11.48167;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;62;1247.794,-5.9877;Float;False;True;-1;2;ASEMaterialInspector;0;3;ASE/ui22gLITCH;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2070.55,495.9915;Inherit;False;Property;_TimeScale;自动偏移频率;6;0;Create;False;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
WireConnection;9;0;2;0
WireConnection;9;2;10;0
WireConnection;27;0;20;2
WireConnection;27;1;20;3
WireConnection;26;0;20;0
WireConnection;26;1;20;1
WireConnection;28;0;13;0
WireConnection;28;1;26;0
WireConnection;29;0;13;0
WireConnection;29;1;27;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;8;1;9;0
WireConnection;45;0;7;0
WireConnection;45;1;46;0
WireConnection;39;0;40;0
WireConnection;46;0;39;0
WireConnection;15;0;48;0
WireConnection;41;0;7;0
WireConnection;41;1;45;0
WireConnection;41;2;42;0
WireConnection;48;0;41;0
WireConnection;14;0;31;0
WireConnection;14;1;48;0
WireConnection;31;0;8;1
WireConnection;52;0;11;2
WireConnection;52;1;14;0
WireConnection;13;0;53;0
WireConnection;13;1;54;0
WireConnection;54;0;11;2
WireConnection;54;1;52;0
WireConnection;54;2;55;0
WireConnection;53;0;12;0
WireConnection;53;1;11;1
WireConnection;53;2;55;0
WireConnection;12;0;11;1
WireConnection;12;1;14;0
WireConnection;20;0;16;0
WireConnection;32;0;63;0
WireConnection;32;1;28;0
WireConnection;3;0;63;0
WireConnection;3;1;29;0
WireConnection;4;0;63;0
WireConnection;4;1;13;0
WireConnection;30;0;32;1
WireConnection;30;1;4;2
WireConnection;30;2;3;3
WireConnection;30;3;4;4
WireConnection;58;0;57;0
WireConnection;58;1;30;0
WireConnection;65;0;58;0
WireConnection;67;0;65;0
WireConnection;67;1;65;1
WireConnection;67;2;65;2
WireConnection;67;3;66;0
WireConnection;66;0;65;3
WireConnection;68;0;67;0
WireConnection;62;0;68;0
ASEEND*/
//CHKSM=1369B0639A2BED19A62C4563C6F702C753597AE4