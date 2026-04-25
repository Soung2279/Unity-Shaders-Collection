// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:32796,y:32620,varname:node_9361,prsc:2|emission-2615-OUT,alpha-3446-OUT;n:type:ShaderForge.SFN_Tex2d,id:408,x:31989,y:32416,ptovrint:False,ptlb:Main_tex,ptin:_Main_tex,varname:node_408,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ab35cd9fd85f9b340bae4232d448388f,ntxv:0,isnm:False|UVIN-8696-OUT;n:type:ShaderForge.SFN_Multiply,id:2615,x:32565,y:32665,varname:node_2615,prsc:2|A-9207-OUT,B-3162-RGB,C-4580-RGB;n:type:ShaderForge.SFN_Color,id:3162,x:32164,y:32837,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_3162,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_VertexColor,id:4580,x:32187,y:33018,varname:node_4580,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:7962,x:31971,y:32626,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_7962,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ac1a8fbe553304b45bcb44ebe0f1667f,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Time,id:587,x:31077,y:32591,varname:node_587,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4447,x:31077,y:32785,ptovrint:False,ptlb:V_speed,ptin:_V_speed,varname:node_4447,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:4120,x:31090,y:32473,ptovrint:False,ptlb:U_speed,ptin:_U_speed,varname:node_4120,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:7228,x:31272,y:32528,varname:node_7228,prsc:2|A-4120-OUT,B-587-T;n:type:ShaderForge.SFN_Multiply,id:8185,x:31272,y:32683,varname:node_8185,prsc:2|A-587-T,B-4447-OUT;n:type:ShaderForge.SFN_Append,id:6668,x:31505,y:32600,varname:node_6668,prsc:2|A-7228-OUT,B-8185-OUT;n:type:ShaderForge.SFN_TexCoord,id:9736,x:31376,y:32312,varname:node_9736,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:8696,x:31777,y:32529,varname:node_8696,prsc:2|A-9736-UVOUT,B-6668-OUT;n:type:ShaderForge.SFN_Multiply,id:9207,x:32277,y:32601,varname:node_9207,prsc:2|A-408-RGB,B-7962-RGB;n:type:ShaderForge.SFN_Multiply,id:3446,x:32490,y:32878,varname:node_3446,prsc:2|A-7962-A,B-3162-A,C-4580-A;proporder:408-3162-7962-4447-4120;pass:END;sub:END;*/

Shader "yhw/mask_uvmove_blend" {
    Properties {
        _Main_tex ("Main_tex", 2D) = "white" {}
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Mask ("Mask", 2D) = "white" {}
        _V_speed ("V_speed", Float ) = 0
        _U_speed ("U_speed", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Main_tex; uniform float4 _Main_tex_ST;
            uniform float4 _Color;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _V_speed;
            uniform float _U_speed;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_587 = _Time;
                float2 node_8696 = (i.uv0+float2((_U_speed*node_587.g),(node_587.g*_V_speed)));
                float4 _Main_tex_var = tex2D(_Main_tex,TRANSFORM_TEX(node_8696, _Main_tex));
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float3 emissive = ((_Main_tex_var.rgb*_Mask_var.rgb)*_Color.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(_Mask_var.a*_Color.a*i.vertexColor.a));
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
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
