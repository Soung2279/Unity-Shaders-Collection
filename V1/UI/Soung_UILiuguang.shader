// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/UI/UI表面流光"
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

        [Enum(R,0,A,1)]_SwitchP("贴图通道切换", Float) = 1
        [Header(LiuGuangTex)]_LiuGuangTex("流光纹理", 2D) = "white" {}
        [HDR]_LGColor("流光颜色", Color) = (1,0.4584408,0,1)
        _LGSpeed("流光速度", Vector) = (0.1,-1,0,0)
        _MaskTex("流光遮罩", 2D) = "white" {}
        [IntRange]_RotatorVal("遮罩旋转", Range( 0 , 360)) = 0
        [Header(NoiseTex)]_NoiseTex("扰动纹理", 2D) = "white" {}
        _NoiseInt("扰动强度", Range( 0 , 1)) = 0.04952465
        _NoiseSpeed("扰动速率", Vector) = (0.5,0.5,0,0)
        [Toggle]_NoiseSwitch("对主纹理扰动", Float) = 0

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

            uniform sampler2D _LiuGuangTex;
            uniform float4 _LiuGuangTex_ST;
            uniform sampler2D _NoiseTex;
            uniform float2 _NoiseSpeed;
            uniform float4 _NoiseTex_ST;
            uniform float _NoiseInt;
            uniform float _NoiseSwitch;
            uniform float _SwitchP;
            uniform float2 _LGSpeed;
            uniform float4 _LGColor;
            uniform sampler2D _MaskTex;
            uniform float4 _MaskTex_ST;
            uniform float _RotatorVal;

            
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

                float2 texCoord6 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float2 uv_LiuGuangTex = IN.texcoord.xy * _LiuGuangTex_ST.xy + _LiuGuangTex_ST.zw;
                float2 uv_NoiseTex = IN.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                float2 panner20 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTex);
                float2 temp_cast_0 = (tex2D( _NoiseTex, panner20 ).r).xx;
                float2 lerpResult19 = lerp( uv_LiuGuangTex , temp_cast_0 , _NoiseInt);
                float2 lerpResult51 = lerp( texCoord6 , lerpResult19 , _NoiseSwitch);
                float4 tex2DNode7 = tex2D( _MainTex, lerpResult51 );
                float lerpResult11 = lerp( tex2DNode7.r , tex2DNode7.a , _SwitchP);
                float4 appendResult49 = (float4((( IN.color * tex2DNode7 )).rgb , ( IN.color.a * lerpResult11 )));
                float2 panner5 = ( 1.0 * _Time.y * _LGSpeed + lerpResult19);
                float2 uv_MaskTex = IN.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
                float cos37 = cos( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
                float sin37 = sin( (0.0 + (_RotatorVal - 0.0) * (6.28 - 0.0) / (360.0 - 0.0)) );
                float2 rotator37 = mul( uv_MaskTex - float2( 0.5,0.5 ) , float2x2( cos37 , -sin37 , sin37 , cos37 )) + float2( 0.5,0.5 );
                

                half4 color = ( (appendResult49).xyzw + ( tex2D( _LiuGuangTex, panner5 ).r * _LGColor * tex2D( _MaskTex, rotator37 ).r * lerpResult11 ) );

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
Node;AmplifyShaderEditor.CommentaryNode;44;-1830.115,-46.77792;Inherit;False;1060.314;484.6455;扰动流光;10;4;31;19;14;30;20;21;5;26;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1749.376,449.851;Inherit;False;978;363;旋转实现;6;8;36;38;37;35;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;34;-1473.78,642.015;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;6.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;35;-1465.561,516.2554;Inherit;False;Constant;_RotatorInt;RotatorInt;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode;37;-1296.724,496.8181;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-1677.089,492.5895;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;5;-939.51,-1.500219;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1815.863,185.9287;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;20;-1603.977,191.3288;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;19;-1137.245,167.0293;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1357.303,38.39995;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-1055.229,496.973;Inherit;True;Property;_MaskTex;流光遮罩;4;0;Create;False;0;0;0;False;0;False;-1;c138005c997604047902040a864e8aca;c138005c997604047902040a864e8aca;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;-966.4769,259.8784;Inherit;False;Property;_LGColor;流光颜色;2;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4584408,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;30;-1771.372,308.665;Inherit;False;Property;_NoiseSpeed;扰动速率;8;0;Create;False;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;31;-1133.375,17.66492;Inherit;False;Property;_LGSpeed;流光速度;3;0;Create;False;0;0;0;False;0;False;0.1,-1;0.1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;36;-1740.193,639.288;Inherit;False;Property;_RotatorVal;遮罩旋转;5;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-755.2143,-30.5;Inherit;True;Property;_LiuGuangTex;流光纹理;1;1;[Header];Create;False;1;LiuGuangTex;0;0;False;0;False;-1;aa41b2e24148f2e448728f9dbb1c5ebf;aa41b2e24148f2e448728f9dbb1c5ebf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1434.401,162.5003;Inherit;True;Property;_NoiseTex;扰动纹理;6;1;[Header];Create;False;1;NoiseTex;0;0;False;0;False;-1;ace1b3ce760c86143b3bcbf4d61986f1;ace1b3ce760c86143b3bcbf4d61986f1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;51;-1065.517,-240.9786;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1275.301,-246;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-1221.517,-124.9786;Inherit;False;Property;_NoiseSwitch;对主纹理扰动;9;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-919.2997,-270.0001;Inherit;True;Property;_MainTexU;主纹理;2;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;621c500fcf6cc87478f0b8153095b045;621c500fcf6cc87478f0b8153095b045;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;40;-632.6149,-434.8684;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-637.2997,-153;Inherit;False;Property;_SwitchP;贴图通道切换;0;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;11;-479.2999,-196;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-360.6992,-0.5336809;Inherit;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;42;-328.2166,-316.2677;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-146.5215,-311.7938;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;50;-18.51306,-315.5035;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;190.4785,-19.79382;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1421.406,351.0081;Inherit;False;Property;_NoiseInt;扰动强度;7;0;Create;False;0;0;0;False;0;False;0.04952465;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;53;387,-20;Float;False;True;-1;2;ASEMaterialInspector;0;3;A201-Shader/UI/UI表面流光;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;54;-1082.55,-315.2802;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-312.5215,-222.7938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-451.5982,-297.9156;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;34;0;36;0
WireConnection;37;0;38;0
WireConnection;37;1;35;0
WireConnection;37;2;34;0
WireConnection;5;0;19;0
WireConnection;5;2;31;0
WireConnection;20;0;21;0
WireConnection;20;2;30;0
WireConnection;19;0;4;0
WireConnection;19;1;14;1
WireConnection;19;2;26;0
WireConnection;8;1;37;0
WireConnection;3;1;5;0
WireConnection;14;1;20;0
WireConnection;51;0;6;0
WireConnection;51;1;19;0
WireConnection;51;2;52;0
WireConnection;7;0;54;0
WireConnection;7;1;51;0
WireConnection;11;0;7;1
WireConnection;11;1;7;4
WireConnection;11;2;10;0
WireConnection;12;0;3;1
WireConnection;12;1;16;0
WireConnection;12;2;8;1
WireConnection;12;3;11;0
WireConnection;42;0;45;0
WireConnection;49;0;42;0
WireConnection;49;3;47;0
WireConnection;50;0;49;0
WireConnection;46;0;50;0
WireConnection;46;1;12;0
WireConnection;53;0;46;0
WireConnection;47;0;40;4
WireConnection;47;1;11;0
WireConnection;45;0;40;0
WireConnection;45;1;7;0
ASEEND*/
//CHKSM=FA997A9C55ADD2BD64FA52876484B2BB2D53CA27