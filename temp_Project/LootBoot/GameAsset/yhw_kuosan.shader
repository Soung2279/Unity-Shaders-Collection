// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:34768,y:32546,varname:node_9361,prsc:2|emission-372-OUT,clip-3061-OUT;n:type:ShaderForge.SFN_Tex2d,id:4850,x:33616,y:32743,ptovrint:False,ptlb:Diffuse,ptin:_Diffuse,varname:node_4850,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2777-OUT;n:type:ShaderForge.SFN_Tex2d,id:5300,x:32890,y:32594,ptovrint:False,ptlb:Niose01,ptin:_Niose01,varname:node_5300,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9649-UVOUT;n:type:ShaderForge.SFN_Panner,id:9649,x:32677,y:32594,varname:node_9649,prsc:2,spu:0.1,spv:0.1|UVIN-933-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:933,x:32441,y:32719,varname:node_933,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Panner,id:4083,x:32692,y:32843,varname:node_4083,prsc:2,spu:0,spv:-0.05|UVIN-933-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:647,x:32890,y:32843,ptovrint:False,ptlb:Niose02,ptin:_Niose02,varname:node_647,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-4083-UVOUT;n:type:ShaderForge.SFN_Add,id:1518,x:33094,y:32737,varname:node_1518,prsc:2|A-5300-R,B-647-G;n:type:ShaderForge.SFN_Multiply,id:7004,x:33266,y:32594,varname:node_7004,prsc:2|A-9573-OUT,B-1518-OUT;n:type:ShaderForge.SFN_Vector1,id:9573,x:33094,y:32594,varname:node_9573,prsc:2,v1:0.05;n:type:ShaderForge.SFN_TexCoord,id:1485,x:33207,y:32408,varname:node_1485,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:2777,x:33418,y:32530,varname:node_2777,prsc:2|A-1485-UVOUT,B-7004-OUT;n:type:ShaderForge.SFN_Multiply,id:795,x:33815,y:32529,varname:node_795,prsc:2|A-6134-RGB,B-4850-RGB;n:type:ShaderForge.SFN_If,id:300,x:33670,y:33081,varname:node_300,prsc:2|A-6083-OUT,B-2467-A,GT-6180-OUT,EQ-6180-OUT,LT-3828-OUT;n:type:ShaderForge.SFN_Tex2d,id:2467,x:33248,y:33109,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_2467,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:4764,x:33117,y:32941,ptovrint:False,ptlb:K_toumingdu,ptin:_K_toumingdu,varname:node_4764,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.7402693,max:1;n:type:ShaderForge.SFN_Vector1,id:282,x:33223,y:33027,varname:node_282,prsc:2,v1:0.08;n:type:ShaderForge.SFN_Vector1,id:6180,x:33271,y:33287,varname:node_6180,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:3828,x:33271,y:33356,varname:node_3828,prsc:2,v1:0;n:type:ShaderForge.SFN_Add,id:6083,x:33454,y:32983,varname:node_6083,prsc:2|A-4764-OUT,B-282-OUT;n:type:ShaderForge.SFN_If,id:2307,x:33670,y:33236,varname:node_2307,prsc:2|A-4764-OUT,B-2467-A,GT-6180-OUT,EQ-6180-OUT,LT-3828-OUT;n:type:ShaderForge.SFN_Subtract,id:3713,x:33875,y:33120,varname:node_3713,prsc:2|A-300-OUT,B-2307-OUT;n:type:ShaderForge.SFN_Multiply,id:7817,x:34082,y:33143,varname:node_7817,prsc:2|A-3713-OUT,B-5583-OUT;n:type:ShaderForge.SFN_Vector1,id:5583,x:33894,y:33284,varname:node_5583,prsc:2,v1:5;n:type:ShaderForge.SFN_Add,id:1671,x:34272,y:33005,varname:node_1671,prsc:2|A-300-OUT,B-7817-OUT;n:type:ShaderForge.SFN_Multiply,id:3061,x:34474,y:33005,varname:node_3061,prsc:2|A-1671-OUT,B-9746-OUT;n:type:ShaderForge.SFN_Tex2d,id:9306,x:34272,y:33184,ptovrint:False,ptlb:alpha,ptin:_alpha,varname:node_9306,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:9746,x:34487,y:33254,varname:node_9746,prsc:2|A-9306-A,B-7339-OUT;n:type:ShaderForge.SFN_Vector1,id:7339,x:34252,y:33409,varname:node_7339,prsc:2,v1:5;n:type:ShaderForge.SFN_Slider,id:1376,x:33956,y:32406,ptovrint:False,ptlb:qiangdu,ptin:_qiangdu,varname:node_1376,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:5,max:10;n:type:ShaderForge.SFN_Multiply,id:372,x:34336,y:32446,varname:node_372,prsc:2|A-1376-OUT,B-795-OUT;n:type:ShaderForge.SFN_Color,id:6134,x:33618,y:32425,ptovrint:False,ptlb:Main_color,ptin:_Main_color,varname:node_6134,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4264706,c2:0.1944204,c3:0.1944204,c4:1;proporder:4850-5300-647-6134-2467-4764-9306-1376;pass:END;sub:END;*/

Shader "yhw/kuosan" {
    Properties {
        _Diffuse ("Diffuse", 2D) = "white" {}
        _Niose01 ("Niose01", 2D) = "white" {}
        _Niose02 ("Niose02", 2D) = "white" {}
        _Main_color ("Main_color", Color) = (0.4264706,0.1944204,0.1944204,1)
        _Mask ("Mask", 2D) = "white" {}
        _K_toumingdu ("K_toumingdu", Range(-1, 1)) = 0.7402693
        _alpha ("alpha", 2D) = "white" {}
        _qiangdu ("qiangdu", Range(0, 10)) = 5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform sampler2D _Niose01; uniform float4 _Niose01_ST;
            uniform sampler2D _Niose02; uniform float4 _Niose02_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _K_toumingdu;
            uniform sampler2D _alpha; uniform float4 _alpha_ST;
            uniform float _qiangdu;
            uniform float4 _Main_color;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float node_300_if_leA = step((_K_toumingdu+0.08),_Mask_var.a);
                float node_300_if_leB = step(_Mask_var.a,(_K_toumingdu+0.08));
                float node_3828 = 0.0;
                float node_6180 = 1.0;
                float node_300 = lerp((node_300_if_leA*node_3828)+(node_300_if_leB*node_6180),node_6180,node_300_if_leA*node_300_if_leB);
                float node_2307_if_leA = step(_K_toumingdu,_Mask_var.a);
                float node_2307_if_leB = step(_Mask_var.a,_K_toumingdu);
                float4 _alpha_var = tex2D(_alpha,TRANSFORM_TEX(i.uv0, _alpha));
                clip(((node_300+((node_300-lerp((node_2307_if_leA*node_3828)+(node_2307_if_leB*node_6180),node_6180,node_2307_if_leA*node_2307_if_leB))*5.0))*(_alpha_var.a*5.0)) - 0.5);
////// Lighting:
////// Emissive:
                float4 node_8467 = _Time;
                float2 node_9649 = (i.uv0+node_8467.g*float2(0.1,0.1));
                float4 _Niose01_var = tex2D(_Niose01,TRANSFORM_TEX(node_9649, _Niose01));
                float2 node_4083 = (i.uv0+node_8467.g*float2(0,-0.05));
                float4 _Niose02_var = tex2D(_Niose02,TRANSFORM_TEX(node_4083, _Niose02));
                float2 node_2777 = (i.uv0+(0.05*(_Niose01_var.r+_Niose02_var.g)));
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(node_2777, _Diffuse));
                float3 emissive = (_qiangdu*(_Main_color.rgb*_Diffuse_var.rgb));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _K_toumingdu;
            uniform sampler2D _alpha; uniform float4 _alpha_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float node_300_if_leA = step((_K_toumingdu+0.08),_Mask_var.a);
                float node_300_if_leB = step(_Mask_var.a,(_K_toumingdu+0.08));
                float node_3828 = 0.0;
                float node_6180 = 1.0;
                float node_300 = lerp((node_300_if_leA*node_3828)+(node_300_if_leB*node_6180),node_6180,node_300_if_leA*node_300_if_leB);
                float node_2307_if_leA = step(_K_toumingdu,_Mask_var.a);
                float node_2307_if_leB = step(_Mask_var.a,_K_toumingdu);
                float4 _alpha_var = tex2D(_alpha,TRANSFORM_TEX(i.uv0, _alpha));
                clip(((node_300+((node_300-lerp((node_2307_if_leA*node_3828)+(node_2307_if_leB*node_6180),node_6180,node_2307_if_leA*node_2307_if_leB))*5.0))*(_alpha_var.a*5.0)) - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
