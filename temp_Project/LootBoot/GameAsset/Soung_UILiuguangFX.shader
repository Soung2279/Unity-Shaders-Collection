// Made with Amplify Shader Editor v1.9.9.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Soung/UI/UIFXLiuguang"
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

        [Enum(UnityEngine.Rendering.CullMode)] _CullingMode( "剔除模式", Float ) = 0
        [Enum(Additive,1,AlphaBlend,10)] _BlendMode( "混合模式", Float ) = 1
        [Header(LiuGuangTex)] _LiuGuangTex( "流光纹理", 2D ) = "white" {}
        [HDR] _BaseColor( "流光颜色", Color ) = ( 1, 0.4584408, 0, 1 )
        [IntRange] _RotatorLVal( "流光旋转", Range( 0, 360 ) ) = 0
        [Enum(R,0,A,1)] _SwitchP( "流光通道切换", Float ) = 1
        [Enum(Custom1xy,0,Material,1)] _UVSpeedMode( "流光流动模式", Float ) = 1
        _LiuguangUSpeed( "流光U速度", Float ) = 0.1
        _LiuguangVSpeed( "流光V速度", Float ) = -1
        _MaskTex( "流光遮罩", 2D ) = "white" {}
        [IntRange] _RotatorVal( "遮罩旋转", Range( 0, 360 ) ) = 0
        [Enum(R,0,A,1)] _SwitchLP( "遮罩通道切换", Float ) = 1

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
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha [_BlendMode]
        ColorMask [_ColorMask]

        
        Pass
        {
            Name "Default"
        CGPROGRAM
            #define ASE_VERSION 19904

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityShaderVariables.cginc"
            #define ASE_NEEDS_FRAG_COLOR
            #define ASE_NEEDS_TEXTURE_COORDINATES2
            #define ASE_NEEDS_TEXTURE_COORDINATES0
            #define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0


            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 ase_texcoord2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                float4 ase_texcoord3 : TEXCOORD3;
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
            uniform sampler2D _LiuGuangTex;
            uniform float4 _LiuGuangTex_ST;
            uniform float _LiuguangUSpeed;
            uniform float _LiuguangVSpeed;
            uniform float _UVSpeedMode;
            uniform float _RotatorLVal;
            uniform float _SwitchP;
            uniform float4 _BaseColor;
            uniform sampler2D _MaskTex;
            uniform float4 _MaskTex_ST;
            uniform float _RotatorVal;
            uniform float _SwitchLP;


            v2f vert(appdata_t v )
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.ase_texcoord3 = v.ase_texcoord2;

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

                float4 texCoord77 = IN.ase_texcoord3;
                texCoord77.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
                float2 appendResult80 = (float2(texCoord77.x , texCoord77.y));
                float2 uv_LiuGuangTex = IN.texcoord.xy * _LiuGuangTex_ST.xy + _LiuGuangTex_ST.zw;
                float2 appendResult57 = (float2(_LiuguangUSpeed , _LiuguangVSpeed));
                float2 panner5 = ( 1.0 * _Time.y * appendResult57 + uv_LiuGuangTex);
                float2 lerpResult81 = lerp( ( appendResult80 + uv_LiuGuangTex ) , panner5 , _UVSpeedMode);
                float2 _RotatorInt = float2(0.5,0.5);
                float cos58 = cos(  (0.0 + ( _RotatorLVal - 0.0 ) * ( 6.28 - 0.0 ) / ( 360.0 - 0.0 ) ) );
                float sin58 = sin(  (0.0 + ( _RotatorLVal - 0.0 ) * ( 6.28 - 0.0 ) / ( 360.0 - 0.0 ) ) );
                float2 rotator58 = mul( lerpResult81 - _RotatorInt , float2x2( cos58 , -sin58 , sin58 , cos58 )) + _RotatorInt;
                float4 tex2DNode3 = tex2D( _LiuGuangTex, rotator58 );
                float lerpResult11 = lerp( tex2DNode3.r , tex2DNode3.a , _SwitchP);
                float2 uv_MaskTex = IN.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
                float cos37 = cos(  (0.0 + ( _RotatorVal - 0.0 ) * ( 6.28 - 0.0 ) / ( 360.0 - 0.0 ) ) );
                float sin37 = sin(  (0.0 + ( _RotatorVal - 0.0 ) * ( 6.28 - 0.0 ) / ( 360.0 - 0.0 ) ) );
                float2 rotator37 = mul( uv_MaskTex - _RotatorInt , float2x2( cos37 , -sin37 , sin37 , cos37 )) + _RotatorInt;
                float4 tex2DNode8 = tex2D( _MaskTex, rotator37 );
                float lerpResult62 = lerp( tex2DNode8.r , tex2DNode8.a , _SwitchLP);
                float4 FinalColor66 = ( IN.color * lerpResult11 * _BaseColor * lerpResult62 );
                float FinalAlpha67 = ( IN.color.a * lerpResult11 * _BaseColor.a * lerpResult62 );
                float4 appendResult71 = (float4((FinalColor66).rgb , FinalAlpha67));
                

                half4 color = appendResult71;

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
Version=19904
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;70;-2313.44,-437.9171;Inherit;False;1985.013;1139.056;LiuguangMain;30;67;69;66;64;62;10;8;34;36;37;38;60;61;35;59;40;11;16;3;57;56;55;4;58;5;77;79;80;81;82;流光Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;-1816.057,264.0301;Inherit;False;Property;_LiuguangVSpeed;流光V速度;8;0;Create;False;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;55;-1815.057,187.0301;Inherit;False;Property;_LiuguangUSpeed;流光U速度;7;0;Create;False;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;-2257.646,-391.8488;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;4;-2408.232,-31.1391;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-2009.811,-367.7916;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;-1665.057,214.0301;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;36;-1923.421,500.048;Inherit;False;Property;_RotatorVal;遮罩旋转;10;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-1834.811,-368.7916;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;-1682.22,-241.6605;Inherit;False;Property;_UVSpeedMode;流光流动模式;6;1;[Enum];Create;False;0;2;Custom1xy;0;Material;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;60;-2397.549,210.1747;Inherit;False;Property;_RotatorLVal;流光旋转;4;1;[IntRange];Create;False;0;0;0;False;0;False;0;45;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;5;-1696.439,-35.03918;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;38;-1698.317,369.3495;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;34;-1644.008,501.775;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;6.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;35;-2297.789,302.0152;Inherit;False;Constant;_RotatorInt;RotatorInt;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCRemapNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;61;-2113.137,188.9017;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;6.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;81;-1489.22,-340.6605;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;37;-1446.952,369.5781;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;58;-1936.057,67.03009;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;-1268.843,-131.3401;Inherit;True;Property;_LiuGuangTex;流光纹理;2;1;[Header];Create;False;1;LiuGuangTex;0;0;False;0;False;-1;None;f199b48ee89eaf14382704de4f5c8a7c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;8;-1267.457,346.7329;Inherit;True;Property;_MaskTex;流光遮罩;9;0;Create;False;0;0;0;False;0;False;-1;None;7881c90d2099a4c44a70b3646e7e06f2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;10;-1171.928,65.1599;Inherit;False;Property;_SwitchP;流光通道切换;5;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;64;-1166.844,540.0383;Inherit;False;Property;_SwitchLP;遮罩通道切换;11;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;11;-949.9282,-35.84006;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;40;-1050.243,-379.7084;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;62;-978.8435,443.0384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;16;-1198.406,142.3394;Inherit;False;Property;_BaseColor;流光颜色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,0.4584408,0,1;2.118547,2.118547,2.118547,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;59;-701.0569,-59.96991;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;66;-549.8621,-60.27324;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;69;-696.1107,171.4582;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;68;-259.938,-141.9289;Inherit;False;66;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;67;-555.0115,172.488;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;-79.36694,-141.4511;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;65;-259.6688,-64.39886;Inherit;False;67;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;71;131.6331,-88.45111;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;-251.3669,22.54889;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;76;-253.3669,99.54889;Inherit;False;Property;_CullingMode;剔除模式;0;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;283.1348,-88.25775;Float;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;3;Soung/UI/UIFXLiuguang;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;2;True;_CullingMode;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;80;0;77;1
WireConnection;80;1;77;2
WireConnection;57;0;55;0
WireConnection;57;1;56;0
WireConnection;79;0;80;0
WireConnection;79;1;4;0
WireConnection;5;0;4;0
WireConnection;5;2;57;0
WireConnection;34;0;36;0
WireConnection;61;0;60;0
WireConnection;81;0;79;0
WireConnection;81;1;5;0
WireConnection;81;2;82;0
WireConnection;37;0;38;0
WireConnection;37;1;35;0
WireConnection;37;2;34;0
WireConnection;58;0;81;0
WireConnection;58;1;35;0
WireConnection;58;2;61;0
WireConnection;3;1;58;0
WireConnection;8;1;37;0
WireConnection;11;0;3;1
WireConnection;11;1;3;4
WireConnection;11;2;10;0
WireConnection;62;0;8;1
WireConnection;62;1;8;4
WireConnection;62;2;64;0
WireConnection;59;0;40;0
WireConnection;59;1;11;0
WireConnection;59;2;16;0
WireConnection;59;3;62;0
WireConnection;66;0;59;0
WireConnection;69;0;40;4
WireConnection;69;1;11;0
WireConnection;69;2;16;4
WireConnection;69;3;62;0
WireConnection;67;0;69;0
WireConnection;74;0;68;0
WireConnection;71;0;74;0
WireConnection;71;3;65;0
WireConnection;53;0;71;0
ASEEND*/
//CHKSM=6D6D3D1919EB880C36723B2D44FCEB27ADE51DDC