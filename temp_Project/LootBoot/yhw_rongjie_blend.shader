// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33950,y:32614,varname:node_9361,prsc:2|emission-489-OUT,alpha-1934-OUT;n:type:ShaderForge.SFN_Tex2d,id:211,x:32787,y:32771,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4077,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:2314,x:32783,y:32173,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:489,x:33431,y:32603,varname:node_489,prsc:2|A-2314-RGB,B-7600-RGB,C-211-RGB,D-4355-OUT;n:type:ShaderForge.SFN_VertexColor,id:7600,x:32787,y:32622,varname:node_7600,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4355,x:33195,y:32768,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_1726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Step,id:4743,x:33104,y:32997,varname:node_4743,prsc:2|A-2284-OUT,B-1377-OUT;n:type:ShaderForge.SFN_OneMinus,id:9375,x:33283,y:33027,varname:node_9375,prsc:2|IN-4743-OUT;n:type:ShaderForge.SFN_Multiply,id:2534,x:33490,y:32984,varname:node_2534,prsc:2|A-3207-OUT,B-9375-OUT;n:type:ShaderForge.SFN_VertexColor,id:8287,x:32244,y:33337,varname:node_8287,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:6911,x:32493,y:33337,varname:node_6911,prsc:2|IN-8287-A;n:type:ShaderForge.SFN_Slider,id:4240,x:32507,y:33204,ptovrint:False,ptlb:rongjie_qiangdu,ptin:_rongjie_qiangdu,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.01,cur:-0.01,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:1377,x:32879,y:33280,ptovrint:False,ptlb:particle_control(A),ptin:_particle_controlA,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4240-OUT,B-4432-OUT;n:type:ShaderForge.SFN_Tex2d,id:6967,x:32478,y:32967,ptovrint:False,ptlb:rongjie_Tex,ptin:_rongjie_Tex,varname:node_3615,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Desaturate,id:7811,x:32684,y:32967,varname:node_7811,prsc:2|COL-6967-RGB;n:type:ShaderForge.SFN_RemapRange,id:4432,x:32664,y:33337,varname:node_4432,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-6911-OUT;n:type:ShaderForge.SFN_Multiply,id:3207,x:33218,y:32850,varname:node_3207,prsc:2|A-211-A,B-7768-OUT;n:type:ShaderForge.SFN_Clamp01,id:1934,x:33659,y:32984,varname:node_1934,prsc:2|IN-2534-OUT;n:type:ShaderForge.SFN_Multiply,id:2284,x:32851,y:33082,varname:node_2284,prsc:2|A-7811-OUT,B-6967-A;n:type:ShaderForge.SFN_ValueProperty,id:7768,x:32940,y:32927,ptovrint:False,ptlb:alpha,ptin:_alpha,varname:node_1540,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:211-2314-4355-4240-1377-6967-7768;pass:END;sub:END;*/

Shader "yhw/rongjie_blend" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex_Power ("MainTex_Power", Float ) = 2
        _rongjie_qiangdu ("rongjie_qiangdu", Range(-0.01, 1)) = -0.01
        [MaterialToggle] _particle_controlA ("particle_control(A)", Float ) = -0.01
        _rongjie_Tex ("rongjie_Tex", 2D) = "white" {}
        _alpha ("alpha", Float ) = 1
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
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainColor;
            uniform float _MainTex_Power;
            uniform float _rongjie_qiangdu;
            uniform fixed _particle_controlA;
            uniform sampler2D _rongjie_Tex; uniform float4 _rongjie_Tex_ST;
            uniform float _alpha;
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
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = (_MainColor.rgb*i.vertexColor.rgb*_MainTex_var.rgb*_MainTex_Power);
                float3 finalColor = emissive;
                float4 _rongjie_Tex_var = tex2D(_rongjie_Tex,TRANSFORM_TEX(i.uv0, _rongjie_Tex));
                fixed4 finalRGBA = fixed4(finalColor,saturate(((_MainTex_var.a*_alpha)*(1.0 - step((dot(_rongjie_Tex_var.rgb,float3(0.3,0.59,0.11))*_rongjie_Tex_var.a),lerp( _rongjie_qiangdu, ((1.0 - i.vertexColor.a)*1.01+-0.01), _particle_controlA ))))));
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
