// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/UI/间隔流光"
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

        [HideInInspector] _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Header(FlowTex (UseClampMode))]_TextureSample1("流光纹理 (使用Clamp模式, 精灵图非图集)", 2D) = "black" {}
        [HDR]_Color0("流光颜色", Color) = (1,1,1,1)
        _Speed1("流动速率 (V方向)", Float) = 1
        _Jiange("流动间隔时间 (s)", Float) = 3
        [Header(NoiseTex)]_TextureSample2("扰动纹理", 2D) = "white" {}
        _Float0("扰动强度", Float) = 0.1
        _Vector1("扰动速率", Vector) = (0.2,0.2,0,0)
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

            uniform sampler2D _TextureSample1;
            uniform float4 _TextureSample1_ST;
            uniform float _Speed1;
            uniform float _Jiange;
            uniform sampler2D _TextureSample2;
            uniform float2 _Vector1;
            uniform float4 _TextureSample2_ST;
            uniform float _Float0;
            uniform float4 _Color0;
            float JiangeCustome22( float offsetY, float jiange )
            {
            	for(int i = 0 ;i<9999; i++)
            	{
            		if(offsetY>jiange)
            		{
            			offsetY -= jiange+1;
            		}
            	}
            	return offsetY;
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
                float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
                float2 uv_TextureSample1 = IN.texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
                float mulTime23 = _Time.y * _Speed1;
                float offsetY22 = mulTime23;
                float jiange22 = _Jiange;
                float localJiangeCustome22 = JiangeCustome22( offsetY22 , jiange22 );
                float2 uv_TextureSample2 = IN.texcoord.xy * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
                float2 panner14 = ( 1.0 * _Time.y * _Vector1 + uv_TextureSample2);
                float2 temp_cast_0 = (tex2D( _TextureSample2, panner14 ).r).xx;
                float2 lerpResult9 = lerp( ( uv_TextureSample1 + localJiangeCustome22 ) , temp_cast_0 , _Float0);
                float4 break87 = ( ( IN.color * tex2DNode2 ) + ( tex2DNode2.a * tex2D( _TextureSample1, lerpResult9 ) * _Color0 ) );
                float clampResult88 = clamp( break87.a , 0.0 , 1.0 );
                float4 appendResult90 = (float4(break87.r , break87.g , break87.b , clampResult88));
                

                half4 color = (appendResult90).xyzw;

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
Node;AmplifyShaderEditor.CommentaryNode;52;-2147.637,321.5772;Inherit;False;1427.687;712.8179;流光纹理部分;11;17;3;10;9;14;15;11;12;21;27;67;Liuguang;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-2124.241,381.8384;Inherit;False;718.8;323.6;使用自定义表达式更改UV流动;6;22;25;24;26;6;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1371.801,393.8178;Inherit;False;471;243;取得精灵图纹理;2;2;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-1933.506,558.9138;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1800.062,423.8996;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-1516.827,535.8483;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2112.011,553.4138;Inherit;False;Property;_Speed1;流动速率 (V方向);2;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-2060.893,739.2253;Inherit;False;0;11;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-1674.539,715.2681;Inherit;True;Property;_TextureSample2;扰动纹理;4;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;1180ffdafb3fa9f4e81a54562fbf7d21;1180ffdafb3fa9f4e81a54562fbf7d21;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;15;-2014.807,860.9169;Inherit;False;Property;_Vector1;扰动速率;6;0;Create;False;0;0;0;False;0;False;0.2,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;14;-1839.297,744.4894;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1949.827,628.8483;Inherit;False;Property;_Jiange;流动间隔时间 (s);3;0;Create;False;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;22;-1768.953,558.7803;Inherit;False;for(int i = 0 @i<9999@ i++)${$	if(offsetY>jiange)$	{$		offsetY -= jiange+1@$	}$}$return offsetY@;1;Create;2;True;offsetY;FLOAT;0;In;;Inherit;False;True;jiange;FLOAT;0;In;;Inherit;False;JiangeCustome;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;-1373.244,688.1591;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1527.463,906.6711;Inherit;False;Property;_Float0;扰动强度;5;0;Create;False;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-688.1412,543.6453;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-506.0492,451.0547;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-692.1161,422.2343;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;87;-309.5462,450.228;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;88;-195.5468,522.228;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-58.54671,450.228;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;89;63.45335,445.228;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;248.1963,450.15;Float;False;True;-1;2;ASEMaterialInspector;0;3;VFX/UI_间隔流光;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ColorNode;17;-1142.577,853.1826;Inherit;False;Property;_Color0;流光颜色;1;1;[HDR];Create;False;1;Color;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1355.79,444.1172;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1185.423,440.3865;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;67;-886.0422,399.5844;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1227.221,659.7114;Inherit;True;Property;_TextureSample1;流光纹理 (使用Clamp模式, 精灵图非图集);0;1;[Header];Create;False;1;FlowTex (UseClampMode);0;0;False;0;False;-1;030dc6821cbe6eb4d992657dae6623c8;030dc6821cbe6eb4d992657dae6623c8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;23;0;24;0
WireConnection;26;0;6;0
WireConnection;26;1;22;0
WireConnection;11;1;14;0
WireConnection;14;0;12;0
WireConnection;14;2;15;0
WireConnection;22;0;23;0
WireConnection;22;1;25;0
WireConnection;9;0;26;0
WireConnection;9;1;11;1
WireConnection;9;2;10;0
WireConnection;72;0;2;4
WireConnection;72;1;3;0
WireConnection;72;2;17;0
WireConnection;81;0;91;0
WireConnection;81;1;72;0
WireConnection;91;0;67;0
WireConnection;91;1;2;0
WireConnection;87;0;81;0
WireConnection;88;0;87;3
WireConnection;90;0;87;0
WireConnection;90;1;87;1
WireConnection;90;2;87;2
WireConnection;90;3;88;0
WireConnection;89;0;90;0
WireConnection;0;0;89;0
WireConnection;2;0;1;0
WireConnection;3;1;9;0
ASEEND*/
//CHKSM=69BDD8D099D0AF54D7ADC97126A7D1C6CF5B199B