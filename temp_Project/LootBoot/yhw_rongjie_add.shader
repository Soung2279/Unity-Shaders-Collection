// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33899,y:32588,varname:node_9361,prsc:2|emission-4115-OUT;n:type:ShaderForge.SFN_Tex2d,id:397,x:33002,y:32806,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4077,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:6391,x:33002,y:32491,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4115,x:33646,y:32638,varname:node_4115,prsc:2|A-6391-RGB,B-9336-RGB,C-397-RGB,D-1652-OUT,E-7852-OUT;n:type:ShaderForge.SFN_VertexColor,id:9336,x:33002,y:32657,varname:node_9336,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1652,x:33321,y:32840,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_1726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Step,id:2051,x:32738,y:33032,varname:node_2051,prsc:2|A-4471-OUT,B-8735-OUT;n:type:ShaderForge.SFN_OneMinus,id:6432,x:32917,y:33062,varname:node_6432,prsc:2|IN-2051-OUT;n:type:ShaderForge.SFN_Multiply,id:7894,x:33124,y:33019,varname:node_7894,prsc:2|A-397-A,B-6432-OUT;n:type:ShaderForge.SFN_VertexColor,id:5675,x:31878,y:33372,varname:node_5675,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:9721,x:32127,y:33372,varname:node_9721,prsc:2|IN-5675-A;n:type:ShaderForge.SFN_Slider,id:4416,x:32141,y:33239,ptovrint:False,ptlb:rongjie_amount,ptin:_rongjie_amount,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.01,cur:0.3425312,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:8735,x:32513,y:33315,ptovrint:False,ptlb:lizhi_control(A),ptin:_lizhi_controlA,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4416-OUT,B-5217-OUT;n:type:ShaderForge.SFN_Tex2d,id:848,x:32112,y:33002,ptovrint:False,ptlb:rongjie_Tex,ptin:_rongjie_Tex,varname:node_3615,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Desaturate,id:4012,x:32318,y:33002,varname:node_4012,prsc:2|COL-848-RGB;n:type:ShaderForge.SFN_RemapRange,id:5217,x:32298,y:33372,varname:node_5217,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-9721-OUT;n:type:ShaderForge.SFN_Clamp01,id:7852,x:33293,y:33019,varname:node_7852,prsc:2|IN-7894-OUT;n:type:ShaderForge.SFN_Multiply,id:4471,x:32485,y:33117,varname:node_4471,prsc:2|A-4012-OUT,B-848-A;proporder:397-6391-1652-4416-8735-848;pass:END;sub:END;*/

Shader "yhw/rongjie_add" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex_Power ("MainTex_Power", Float ) = 2
        _rongjie_amount ("rongjie_amount", Range(-0.01, 1)) = 0.3425312
        [MaterialToggle] _lizhi_controlA ("lizhi_control(A)", Float ) = 0.3425312
        _rongjie_Tex ("rongjie_Tex", 2D) = "white" {}
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
            Blend One One
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
            uniform float _rongjie_amount;
            uniform fixed _lizhi_controlA;
            uniform sampler2D _rongjie_Tex; uniform float4 _rongjie_Tex_ST;
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
                float4 _rongjie_Tex_var = tex2D(_rongjie_Tex,TRANSFORM_TEX(i.uv0, _rongjie_Tex));
                float3 emissive = (_MainColor.rgb*i.vertexColor.rgb*_MainTex_var.rgb*_MainTex_Power*saturate((_MainTex_var.a*(1.0 - step((dot(_rongjie_Tex_var.rgb,float3(0.3,0.59,0.11))*_rongjie_Tex_var.a),lerp( _rongjie_amount, ((1.0 - i.vertexColor.a)*1.01+-0.01), _lizhi_controlA ))))));
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
