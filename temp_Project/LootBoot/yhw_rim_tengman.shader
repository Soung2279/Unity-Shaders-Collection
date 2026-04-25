// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33097,y:32583,varname:node_9361,prsc:2|emission-9897-OUT;n:type:ShaderForge.SFN_Tex2d,id:9715,x:32509,y:32529,ptovrint:False,ptlb:Main_tex,ptin:_Main_tex,varname:node_9715,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:16807e2775dd8e846af77031ae3af6a1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:3770,x:32447,y:32731,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_3770,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.4669811,c3:0.4669811,c4:1;n:type:ShaderForge.SFN_Multiply,id:9897,x:32850,y:32663,varname:node_9897,prsc:2|A-9715-RGB,B-3770-RGB,C-3467-OUT;n:type:ShaderForge.SFN_Fresnel,id:4680,x:32510,y:32893,varname:node_4680,prsc:2|NRM-462-OUT,EXP-3979-OUT;n:type:ShaderForge.SFN_NormalVector,id:462,x:32114,y:32797,prsc:2,pt:False;n:type:ShaderForge.SFN_Slider,id:3979,x:32049,y:33030,ptovrint:False,ptlb:Value,ptin:_Value,varname:node_3979,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:2.618475,max:5;n:type:ShaderForge.SFN_Multiply,id:3467,x:32752,y:32972,varname:node_3467,prsc:2|A-4680-OUT,B-6163-OUT;n:type:ShaderForge.SFN_Slider,id:6163,x:32277,y:33136,ptovrint:False,ptlb:Value2,ptin:_Value2,varname:node_6163,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:2.545917,max:5;proporder:9715-3770-3979-6163;pass:END;sub:END;*/

Shader "yhw/rim_tengman" {
    Properties {
        _Main_tex ("Main_tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,0.4669811,0.4669811,1)
        _Value ("Value", Range(-5, 5)) = 2.618475
        _Value2 ("Value2", Range(-5, 5)) = 2.545917
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Main_tex; uniform float4 _Main_tex_ST;
            uniform float4 _Color;
            uniform float _Value;
            uniform float _Value2;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _Main_tex_var = tex2D(_Main_tex,TRANSFORM_TEX(i.uv0, _Main_tex));
                float3 emissive = (_Main_tex_var.rgb*_Color.rgb*(pow(1.0-max(0,dot(i.normalDir, viewDirection)),_Value)*_Value2));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
