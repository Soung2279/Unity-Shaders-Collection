// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:1761,x:33713,y:32677,varname:node_1761,prsc:2|emission-5526-OUT,voffset-5945-OUT;n:type:ShaderForge.SFN_Multiply,id:3596,x:33085,y:33011,varname:node_3596,prsc:2|A-60-OUT,B-5865-OUT,C-6473-OUT,D-7929-OUT;n:type:ShaderForge.SFN_Tex2d,id:8357,x:32177,y:32131,ptovrint:False,ptlb:Textures,ptin:_Textures,varname:node_5485,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9089-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:7109,x:32654,y:32825,varname:node_7109,prsc:2;n:type:ShaderForge.SFN_Color,id:1737,x:32635,y:32598,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_3569,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:60,x:32880,y:32722,varname:node_60,prsc:2|A-1737-RGB,B-8357-RGB,C-3034-OUT,D-7109-RGB,E-7109-A;n:type:ShaderForge.SFN_SwitchProperty,id:2211,x:32270,y:32522,ptovrint:False,ptlb:TextureAlpha,ptin:_TextureAlpha,varname:node_4275,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8357-R,B-8357-A;n:type:ShaderForge.SFN_DepthBlend,id:2408,x:32511,y:33051,varname:node_2408,prsc:2|DIST-1401-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:5865,x:32682,y:32999,ptovrint:False,ptlb:SoftParticle,ptin:_SoftParticle,varname:node_8806,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4785-OUT,B-2408-OUT;n:type:ShaderForge.SFN_TexCoord,id:2432,x:30284,y:32500,varname:node_2432,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:4416,x:30284,y:32019,varname:node_4416,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:3278,x:30284,y:31906,ptovrint:False,ptlb:U Speed,ptin:_USpeed,varname:node_8092,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:8003,x:30284,y:32251,ptovrint:False,ptlb:V Speed,ptin:_VSpeed,varname:node_899,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:2943,x:30509,y:32073,varname:node_2943,prsc:2|A-4416-T,B-8003-OUT;n:type:ShaderForge.SFN_Multiply,id:7802,x:30509,y:31906,varname:node_7802,prsc:2|A-3278-OUT,B-4416-T;n:type:ShaderForge.SFN_Append,id:6472,x:31002,y:31964,varname:node_6472,prsc:2|A-3905-OUT,B-3782-OUT;n:type:ShaderForge.SFN_Add,id:3905,x:30737,y:31926,varname:node_3905,prsc:2|A-7802-OUT,B-2432-U;n:type:ShaderForge.SFN_Add,id:3782,x:30750,y:32095,varname:node_3782,prsc:2|A-2432-V,B-2943-OUT;n:type:ShaderForge.SFN_Multiply,id:3034,x:32446,y:32762,varname:node_3034,prsc:2|A-2211-OUT,B-1332-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:1332,x:32154,y:32972,ptovrint:False,ptlb:Mask Tex,ptin:_MaskTex,varname:node_7234,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8726-OUT,B-1876-R;n:type:ShaderForge.SFN_Tex2d,id:1876,x:31782,y:33246,ptovrint:False,ptlb:Opacity Textures,ptin:_OpacityTextures,varname:node_272,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2127-OUT;n:type:ShaderForge.SFN_Vector1,id:8726,x:31947,y:32912,varname:node_8726,prsc:2,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:6473,x:32855,y:33170,ptovrint:False,ptlb:Fresnel Op,ptin:_FresnelOp,varname:node_24,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2013-OUT,B-3031-OUT;n:type:ShaderForge.SFN_Vector1,id:2013,x:32537,y:33197,varname:node_2013,prsc:2,v1:1;n:type:ShaderForge.SFN_OneMinus,id:7680,x:32329,y:33352,varname:node_7680,prsc:2|IN-2813-OUT;n:type:ShaderForge.SFN_Fresnel,id:2813,x:32171,y:33257,varname:node_2813,prsc:2|EXP-6581-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6581,x:32002,y:33277,ptovrint:False,ptlb: Fresnel  Power,ptin:_FresnelPower,varname:node_8418,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:7807,x:31292,y:32116,ptovrint:False,ptlb:PanUV,ptin:_PanUV,varname:node_9480,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6472-OUT,B-3835-OUT;n:type:ShaderForge.SFN_Add,id:3835,x:30808,y:32443,varname:node_3835,prsc:2|A-2432-UVOUT,B-924-OUT;n:type:ShaderForge.SFN_Append,id:924,x:30539,y:32382,varname:node_924,prsc:2|A-5047-Z,B-5047-W;n:type:ShaderForge.SFN_TexCoord,id:5047,x:30284,y:32329,varname:node_5047,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_SwitchProperty,id:7929,x:32608,y:33533,ptovrint:False,ptlb:Disslove Off,ptin:_DissloveOff,varname:_FresnelOp_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6544-OUT,B-6276-OUT;n:type:ShaderForge.SFN_Vector1,id:6544,x:32319,y:33533,varname:node_6544,prsc:2,v1:1;n:type:ShaderForge.SFN_TexCoord,id:9115,x:31326,y:33588,varname:node_9115,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_Tex2d,id:6481,x:32224,y:34039,ptovrint:False,ptlb:Disslove,ptin:_Disslove,varname:node_8001,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2557-OUT;n:type:ShaderForge.SFN_Tex2d,id:8262,x:30560,y:32939,ptovrint:False,ptlb:NiuQu,ptin:_NiuQu,varname:node_8262,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5564-OUT;n:type:ShaderForge.SFN_Multiply,id:734,x:30984,y:32683,varname:node_734,prsc:2|A-6160-OUT,B-8262-R;n:type:ShaderForge.SFN_ValueProperty,id:7756,x:30584,y:32702,ptovrint:False,ptlb:NiuQuPower,ptin:_NiuQuPower,varname:node_7756,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:9401,x:31525,y:32116,varname:node_9401,prsc:2|A-7807-OUT,B-4136-OUT;n:type:ShaderForge.SFN_Append,id:5564,x:30370,y:33001,varname:node_5564,prsc:2|A-7506-OUT,B-2572-OUT;n:type:ShaderForge.SFN_Add,id:7506,x:30162,y:32951,varname:node_7506,prsc:2|A-1183-OUT,B-7181-U;n:type:ShaderForge.SFN_Add,id:2572,x:30162,y:33148,varname:node_2572,prsc:2|A-7181-V,B-3857-OUT;n:type:ShaderForge.SFN_Multiply,id:3857,x:29990,y:33195,varname:node_3857,prsc:2|A-3347-T,B-7675-OUT;n:type:ShaderForge.SFN_Multiply,id:1183,x:29978,y:32874,varname:node_1183,prsc:2|A-4681-OUT,B-3347-T;n:type:ShaderForge.SFN_Time,id:3347,x:29753,y:33091,varname:node_3347,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4681,x:29776,y:32921,ptovrint:False,ptlb:U speed Niuqu,ptin:_UspeedNiuqu,varname:_USpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:7675,x:29778,y:33262,ptovrint:False,ptlb:V Speed Niuqu,ptin:_VSpeedNiuqu,varname:_VSpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:7181,x:29957,y:33010,varname:node_7181,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_SwitchProperty,id:6189,x:31904,y:33492,ptovrint:False,ptlb:Disslove UV or Power,ptin:_DissloveUVorPower,varname:node_6189,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-1519-OUT,B-3928-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3928,x:31630,y:33730,ptovrint:False,ptlb:DisslovePower,ptin:_DisslovePower,varname:node_3928,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:6160,x:30785,y:32647,ptovrint:False,ptlb:Int or Curver,ptin:_IntorCurver,varname:node_6160,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7756-OUT,B-5047-V;n:type:ShaderForge.SFN_Multiply,id:5526,x:33390,y:32792,varname:node_5526,prsc:2|A-8110-RGB,B-3596-OUT;n:type:ShaderForge.SFN_Tex2d,id:8110,x:33411,y:32239,ptovrint:False,ptlb:RamColor,ptin:_RamColor,varname:node_8110,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-305-UVOUT;n:type:ShaderForge.SFN_Smoothstep,id:6276,x:32389,y:33607,varname:node_6276,prsc:2|A-6189-OUT,B-4798-OUT,V-6481-R;n:type:ShaderForge.SFN_ValueProperty,id:8360,x:31872,y:33778,ptovrint:False,ptlb:Smooth,ptin:_Smooth,varname:node_8360,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:4798,x:32124,y:33729,varname:node_4798,prsc:2|A-6189-OUT,B-8360-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1401,x:32288,y:33096,ptovrint:False,ptlb:SoftPower,ptin:_SoftPower,varname:node_1401,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_OneMinus,id:1519,x:31564,y:33564,varname:node_1519,prsc:2|IN-9115-U;n:type:ShaderForge.SFN_ValueProperty,id:8947,x:31148,y:32838,ptovrint:False,ptlb:Rotator,ptin:_Rotator,varname:node_3492,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3196,x:31347,y:32818,varname:node_3196,prsc:2|A-8947-OUT,B-7340-OUT;n:type:ShaderForge.SFN_Pi,id:7340,x:31148,y:32877,varname:node_7340,prsc:2;n:type:ShaderForge.SFN_Divide,id:6715,x:31555,y:32793,varname:node_6715,prsc:2|A-3196-OUT,B-2277-OUT;n:type:ShaderForge.SFN_Vector1,id:2277,x:31347,y:32976,varname:node_2277,prsc:2,v1:180;n:type:ShaderForge.SFN_Rotator,id:9089,x:31752,y:32116,varname:node_9089,prsc:2|UVIN-9401-OUT,ANG-6715-OUT;n:type:ShaderForge.SFN_Tex2d,id:6095,x:33408,y:33775,ptovrint:False,ptlb:VertexT,ptin:_VertexT,varname:node_6095,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-3423-OUT;n:type:ShaderForge.SFN_Vector4Property,id:3318,x:33408,y:33977,ptovrint:False,ptlb:VertexPower,ptin:_VertexPower,varname:node_3318,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1,v2:1,v3:1,v4:0;n:type:ShaderForge.SFN_Append,id:3423,x:33235,y:33775,varname:node_3423,prsc:2|A-5998-OUT,B-7035-OUT;n:type:ShaderForge.SFN_Add,id:5998,x:33020,y:33758,varname:node_5998,prsc:2|A-1669-OUT,B-1309-U;n:type:ShaderForge.SFN_Add,id:7035,x:33112,y:34053,varname:node_7035,prsc:2|A-1309-V,B-4322-OUT;n:type:ShaderForge.SFN_Multiply,id:4322,x:32843,y:34200,varname:node_4322,prsc:2|A-4829-T,B-9913-OUT;n:type:ShaderForge.SFN_Multiply,id:1669,x:32842,y:33758,varname:node_1669,prsc:2|A-626-OUT,B-4829-T;n:type:ShaderForge.SFN_Time,id:4829,x:32615,y:33941,varname:node_4829,prsc:2;n:type:ShaderForge.SFN_TexCoord,id:1309,x:32843,y:34005,varname:node_1309,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_ValueProperty,id:626,x:32628,y:33740,ptovrint:False,ptlb:VPan_U,ptin:_VPan_U,varname:node_626,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:9913,x:32599,y:34234,ptovrint:False,ptlb:VPan_V,ptin:_VPan_V,varname:node_9913,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:5945,x:33809,y:33767,ptovrint:False,ptlb:VerTexOffest,ptin:_VerTexOffest,varname:node_5945,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6660-OUT,B-6236-OUT;n:type:ShaderForge.SFN_Vector1,id:6660,x:33595,y:33692,varname:node_6660,prsc:2,v1:0;n:type:ShaderForge.SFN_Multiply,id:6236,x:33625,y:33864,varname:node_6236,prsc:2|A-6095-RGB,B-3318-XYZ,C-4663-OUT,D-9115-V;n:type:ShaderForge.SFN_NormalVector,id:4663,x:33408,y:34140,prsc:2,pt:True;n:type:ShaderForge.SFN_Vector1,id:3107,x:30958,y:32553,varname:node_3107,prsc:2,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:4136,x:31201,y:32611,ptovrint:False,ptlb:NQOff,ptin:_NQOff,varname:node_4136,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-3107-OUT,B-734-OUT;n:type:ShaderForge.SFN_Vector1,id:4785,x:32526,y:32981,varname:node_4785,prsc:2,v1:1;n:type:ShaderForge.SFN_Append,id:4580,x:31236,y:33246,varname:node_4580,prsc:2|A-9312-OUT,B-4070-OUT;n:type:ShaderForge.SFN_Add,id:9312,x:31011,y:33212,varname:node_9312,prsc:2|A-8987-OUT,B-6975-U;n:type:ShaderForge.SFN_Add,id:4070,x:31011,y:33409,varname:node_4070,prsc:2|A-6975-V,B-881-OUT;n:type:ShaderForge.SFN_Multiply,id:881,x:30839,y:33456,varname:node_881,prsc:2|A-8282-T,B-8795-OUT;n:type:ShaderForge.SFN_Multiply,id:8987,x:30827,y:33135,varname:node_8987,prsc:2|A-3788-OUT,B-8282-T;n:type:ShaderForge.SFN_TexCoord,id:6975,x:30806,y:33271,varname:node_6975,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:8282,x:30587,y:33281,varname:node_8282,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:3788,x:30587,y:33205,ptovrint:False,ptlb:Mask_U_Speed,ptin:_Mask_U_Speed,varname:node_3788,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:8795,x:30587,y:33456,ptovrint:False,ptlb:Mask_V_Speed,ptin:_Mask_V_Speed,varname:node_8795,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:3828,x:31827,y:34053,varname:node_3828,prsc:2|A-7184-OUT,B-6560-OUT;n:type:ShaderForge.SFN_Add,id:7184,x:31602,y:34019,varname:node_7184,prsc:2|A-5158-OUT,B-9717-U;n:type:ShaderForge.SFN_Add,id:6560,x:31602,y:34216,varname:node_6560,prsc:2|A-9717-V,B-5967-OUT;n:type:ShaderForge.SFN_Multiply,id:5967,x:31430,y:34263,varname:node_5967,prsc:2|A-1240-T,B-5487-OUT;n:type:ShaderForge.SFN_Multiply,id:5158,x:31418,y:33942,varname:node_5158,prsc:2|A-5827-OUT,B-1240-T;n:type:ShaderForge.SFN_TexCoord,id:9717,x:31397,y:34078,varname:node_9717,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:1240,x:31193,y:34159,varname:node_1240,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5827,x:31140,y:33890,ptovrint:False,ptlb:DissU_Speed,ptin:_DissU_Speed,varname:node_5827,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:5487,x:31248,y:34355,ptovrint:False,ptlb:DissV_Speed,ptin:_DissV_Speed,varname:node_5487,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:5954,x:32622,y:33273,ptovrint:False,ptlb:Fresnel_oneminus,ptin:_Fresnel_oneminus,varname:node_5954,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7680-OUT,B-2813-OUT;n:type:ShaderForge.SFN_Multiply,id:3031,x:32903,y:33352,varname:node_3031,prsc:2|A-5954-OUT,B-4265-OUT;n:type:ShaderForge.SFN_Slider,id:4265,x:32486,y:33435,ptovrint:False,ptlb:fn_v,ptin:_fn_v,varname:node_4265,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5048544,max:1;n:type:ShaderForge.SFN_ValueProperty,id:8895,x:30090,y:34334,ptovrint:False,ptlb:Rotator_copy,ptin:_Rotator_copy,varname:_Rotator_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4422,x:30354,y:34391,varname:node_4422,prsc:2|A-8895-OUT,B-1730-OUT;n:type:ShaderForge.SFN_Pi,id:1730,x:30155,y:34274,varname:node_1730,prsc:2;n:type:ShaderForge.SFN_Divide,id:185,x:30537,y:34334,varname:node_185,prsc:2|A-4422-OUT,B-7560-OUT;n:type:ShaderForge.SFN_Vector1,id:7560,x:30283,y:34391,varname:node_7560,prsc:2,v1:180;n:type:ShaderForge.SFN_Rotator,id:8292,x:30732,y:34253,varname:node_8292,prsc:2|ANG-185-OUT;n:type:ShaderForge.SFN_ValueProperty,id:201,x:30449,y:33613,ptovrint:False,ptlb:Rotator_mask,ptin:_Rotator_mask,varname:_Rotator_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7982,x:30638,y:33613,varname:node_7982,prsc:2|A-201-OUT,B-3420-OUT;n:type:ShaderForge.SFN_Pi,id:3420,x:30465,y:33681,varname:node_3420,prsc:2;n:type:ShaderForge.SFN_Divide,id:3157,x:30841,y:33672,varname:node_3157,prsc:2|A-7982-OUT,B-2852-OUT;n:type:ShaderForge.SFN_Vector1,id:2852,x:30593,y:33798,varname:node_2852,prsc:2,v1:180;n:type:ShaderForge.SFN_Rotator,id:7059,x:31412,y:33246,varname:node_7059,prsc:2|UVIN-4580-OUT,ANG-3157-OUT;n:type:ShaderForge.SFN_Tex2d,id:8367,x:31498,y:34576,ptovrint:False,ptlb:NiuQu_disslove,ptin:_NiuQu_disslove,varname:_NiuQu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-618-OUT;n:type:ShaderForge.SFN_Append,id:618,x:31308,y:34638,varname:node_618,prsc:2|A-6482-OUT,B-3582-OUT;n:type:ShaderForge.SFN_Add,id:6482,x:31100,y:34588,varname:node_6482,prsc:2|A-9714-OUT,B-8956-U;n:type:ShaderForge.SFN_Add,id:3582,x:31100,y:34785,varname:node_3582,prsc:2|A-8956-V,B-8385-OUT;n:type:ShaderForge.SFN_Multiply,id:9714,x:30916,y:34511,varname:node_9714,prsc:2|A-8953-OUT,B-4376-T;n:type:ShaderForge.SFN_Time,id:4376,x:30691,y:34728,varname:node_4376,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8953,x:30714,y:34558,ptovrint:False,ptlb:U speed Niuqu_niuqu,ptin:_UspeedNiuqu_niuqu,varname:_UspeedNiuqu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:8956,x:30895,y:34647,varname:node_8956,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:8385,x:30928,y:34832,varname:node_8385,prsc:2|A-4376-T,B-4062-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4062,x:30716,y:34899,ptovrint:False,ptlb:V Speed Niuquniuqu,ptin:_VSpeedNiuquniuqu,varname:_VSpeedNiuqu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:2557,x:32031,y:34053,varname:node_2557,prsc:2|A-3828-OUT,B-4514-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:4514,x:32043,y:34540,ptovrint:False,ptlb:Disslove_niuqu,ptin:_Disslove_niuqu,varname:node_4514,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-5806-OUT,B-423-OUT;n:type:ShaderForge.SFN_Vector1,id:5806,x:31809,y:34473,varname:node_5806,prsc:2,v1:0;n:type:ShaderForge.SFN_Multiply,id:423,x:31824,y:34558,varname:node_423,prsc:2|A-2317-OUT,B-8367-RGB;n:type:ShaderForge.SFN_ValueProperty,id:2317,x:31498,y:34477,ptovrint:False,ptlb:disslove_niuqu_power,ptin:_disslove_niuqu_power,varname:node_2317,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:3734,x:30070,y:33989,ptovrint:False,ptlb:NiuQu_mask,ptin:_NiuQu_mask,varname:_NiuQu_disslove_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-3591-OUT;n:type:ShaderForge.SFN_Append,id:3591,x:29880,y:34051,varname:node_3591,prsc:2|A-5581-OUT,B-9504-OUT;n:type:ShaderForge.SFN_Add,id:5581,x:29672,y:34001,varname:node_5581,prsc:2|A-4437-OUT,B-6645-U;n:type:ShaderForge.SFN_Add,id:9504,x:29672,y:34198,varname:node_9504,prsc:2|A-6645-V,B-1090-OUT;n:type:ShaderForge.SFN_Multiply,id:4437,x:29488,y:33924,varname:node_4437,prsc:2|A-3382-OUT,B-1209-T;n:type:ShaderForge.SFN_Time,id:1209,x:29263,y:34141,varname:node_1209,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:3382,x:29286,y:33971,ptovrint:False,ptlb:U speed Niuqu_niuqu_mask,ptin:_UspeedNiuqu_niuqu_mask,varname:_UspeedNiuqu_niuqu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:6645,x:29467,y:34060,varname:node_6645,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:1090,x:29500,y:34245,varname:node_1090,prsc:2|A-1209-T,B-5196-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5196,x:29288,y:34312,ptovrint:False,ptlb:V Speed Niuqu_mask,ptin:_VSpeedNiuqu_mask,varname:_VSpeedNiuquniuqu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:6402,x:30615,y:33953,ptovrint:False,ptlb:mask_niuqu_copy,ptin:_mask_niuqu_copy,varname:_Disslove_niuqu_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-1476-OUT,B-3319-OUT;n:type:ShaderForge.SFN_Vector1,id:1476,x:30381,y:33886,varname:node_1476,prsc:2,v1:0;n:type:ShaderForge.SFN_Multiply,id:3319,x:30396,y:33971,varname:node_3319,prsc:2|A-6885-OUT,B-3734-RGB;n:type:ShaderForge.SFN_ValueProperty,id:6885,x:30070,y:33890,ptovrint:False,ptlb:mask_niuqu_power_copy,ptin:_mask_niuqu_power_copy,varname:_disslove_niuqu_power_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:2127,x:31604,y:33246,varname:node_2127,prsc:2|A-7059-UVOUT,B-6402-OUT;n:type:ShaderForge.SFN_Multiply,id:5017,x:32736,y:32289,varname:node_5017,prsc:2|A-4464-OUT,B-6635-OUT;n:type:ShaderForge.SFN_Pi,id:6635,x:32537,y:32348,varname:node_6635,prsc:2;n:type:ShaderForge.SFN_Divide,id:2984,x:32944,y:32264,varname:node_2984,prsc:2|A-5017-OUT,B-8330-OUT;n:type:ShaderForge.SFN_Vector1,id:8330,x:32736,y:32447,varname:node_8330,prsc:2,v1:180;n:type:ShaderForge.SFN_Rotator,id:305,x:33203,y:32081,varname:node_305,prsc:2|UVIN-5785-UVOUT,ANG-2984-OUT;n:type:ShaderForge.SFN_TexCoord,id:5785,x:32775,y:32017,varname:node_5785,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_ValueProperty,id:4464,x:32504,y:32264,ptovrint:False,ptlb:Ram_Rotator,ptin:_Ram_Rotator,varname:node_4464,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;proporder:8357-2211-8947-1737-7807-3278-8003-1876-1332-3788-8795-6481-7929-5827-5487-8360-5865-1401-6473-5954-6581-4265-8262-4136-6160-7756-4681-7675-6189-3928-8110-6095-5945-3318-626-9913-201-4514-8367-8953-4062-2317-3734-6402-6885-3382-5196-4464;pass:END;sub:END;*/

Shader "A201-Shader/进阶功能/多功能溶解ADD模式_Additive" {
    Properties {
        _Textures ("主贴图", 2D) = "white" {}
        [MaterialToggle] _TextureAlpha ("主贴图Alpha模式", Float ) = 0
        _Rotator ("主贴图旋转", Float ) = 0
        [HDR]_Color ("颜色", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _PanUV ("粒子系统控制UV (添加自定义粒子流/UV2后用CustomeData控制) ", Float ) = 0
        _USpeed ("U方向流动速度", Float ) = 0
        _VSpeed ("V方向流动速度", Float ) = 0
        _OpacityTextures ("透明度贴图(Opacity)", 2D) = "white" {}
        [MaterialToggle] _MaskTex ("是否启用透明度贴图", Float ) = 1
        _Mask_U_Speed ("透明度U方向流动速度", Float ) = 0
        _Mask_V_Speed ("透明度V方向流动速度", Float ) = 0
        _Disslove ("溶解贴图(Disslove)", 2D) = "white" {}
        [MaterialToggle] _DissloveOff ("是否启用溶解贴图", Float ) = 1
        _DissU_Speed ("溶解U方向流动速度", Float ) = 0
        _DissV_Speed ("溶解V方向流动速度", Float ) = 0
        _Smooth ("溶解平滑强度", Float ) = 0
        [MaterialToggle] _SoftParticle ("是否启用顶点平滑(SoftParticle)", Float ) = 1
        _SoftPower ("顶点平滑强度", Float ) = 1
        [MaterialToggle] _FresnelOp ("是否启用菲涅尔效果", Float ) = 1
        [MaterialToggle] _Fresnel_oneminus ("菲涅尔反转", Float ) = 1
        _FresnelPower ("菲涅尔强度", Float ) = 1
        _fn_v ("菲涅尔V方向", Range(0, 1)) = 0.5048544
        _NiuQu ("扭曲贴图", 2D) = "white" {}
        [MaterialToggle] _NQOff ("是否启用扭曲贴图", Float ) = 0
        [MaterialToggle] _IntorCurver ("整数型算法/曲线算法", Float ) = 0
        _NiuQuPower ("扭曲强度", Float ) = 0
        _UspeedNiuqu ("扭曲U方向流动速度", Float ) = 0
        _VSpeedNiuqu ("扭曲V方向流动速度", Float ) = 0
        [MaterialToggle] _DissloveUVorPower ("是否启用定向溶解", Float ) = 1
        _DisslovePower ("定向溶解强度", Float ) = 0
        _RamColor ("颜色渐变(Ramp)", 2D) = "white" {}
        _VertexT ("颜色渐变顶点(Vertex)", 2D) = "white" {}
        [MaterialToggle] _VerTexOffest ("是否启用顶点偏移", Float ) = 0
        _VertexPower ("顶点偏移数值", Vector) = (1,1,1,0)
        _VPan_U ("顶点偏移U方向流动速度", Float ) = 0
        _VPan_V ("顶点偏移V方向流动速度", Float ) = 0
        _Rotator_mask ("遮罩旋转", Float ) = 0
        [MaterialToggle] _Disslove_niuqu ("是否启用叠加溶解", Float ) = 0
        _NiuQu_disslove ("叠加溶解贴图", 2D) = "white" {}
        _UspeedNiuqu_niuqu ("叠加溶解U方向流动速度", Float ) = 0
        _VSpeedNiuquniuqu ("叠加溶解V方向流动速度", Float ) = 0
        _disslove_niuqu_power ("叠加溶解强度", Float ) = 0
        _NiuQu_mask ("叠加扭曲贴图", 2D) = "white" {}
        [MaterialToggle] _mask_niuqu_copy ("是否启用叠加扭曲", Float ) = 0
        _mask_niuqu_power_copy ("叠加扭曲强度复用数值", Float ) = 0
        _UspeedNiuqu_niuqu_mask ("扭曲遮罩U方向流动速度", Float ) = 0
        _VSpeedNiuqu_mask ("扭曲遮罩V方向流动速度", Float ) = 0
        _Ram_Rotator ("颜色渐变贴图旋转", Float ) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
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
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _CameraDepthTexture;
            uniform sampler2D _Textures; uniform float4 _Textures_ST;
            uniform float4 _Color;
            uniform fixed _TextureAlpha;
            uniform fixed _SoftParticle;
            uniform float _USpeed;
            uniform float _VSpeed;
            uniform fixed _MaskTex;
            uniform sampler2D _OpacityTextures; uniform float4 _OpacityTextures_ST;
            uniform fixed _FresnelOp;
            uniform float _FresnelPower;
            uniform fixed _PanUV;
            uniform fixed _DissloveOff;
            uniform sampler2D _Disslove; uniform float4 _Disslove_ST;
            uniform sampler2D _NiuQu; uniform float4 _NiuQu_ST;
            uniform float _NiuQuPower;
            uniform float _UspeedNiuqu;
            uniform float _VSpeedNiuqu;
            uniform fixed _DissloveUVorPower;
            uniform float _DisslovePower;
            uniform fixed _IntorCurver;
            uniform sampler2D _RamColor; uniform float4 _RamColor_ST;
            uniform float _Smooth;
            uniform float _SoftPower;
            uniform float _Rotator;
            uniform sampler2D _VertexT; uniform float4 _VertexT_ST;
            uniform float4 _VertexPower;
            uniform float _VPan_U;
            uniform float _VPan_V;
            uniform fixed _VerTexOffest;
            uniform fixed _NQOff;
            uniform float _Mask_U_Speed;
            uniform float _Mask_V_Speed;
            uniform float _DissU_Speed;
            uniform float _DissV_Speed;
            uniform fixed _Fresnel_oneminus;
            uniform float _fn_v;
            uniform float _Rotator_mask;
            uniform sampler2D _NiuQu_disslove; uniform float4 _NiuQu_disslove_ST;
            uniform float _UspeedNiuqu_niuqu;
            uniform float _VSpeedNiuquniuqu;
            uniform fixed _Disslove_niuqu;
            uniform float _disslove_niuqu_power;
            uniform sampler2D _NiuQu_mask; uniform float4 _NiuQu_mask_ST;
            uniform float _UspeedNiuqu_niuqu_mask;
            uniform float _VSpeedNiuqu_mask;
            uniform fixed _mask_niuqu_copy;
            uniform float _mask_niuqu_power_copy;
            uniform float _Ram_Rotator;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_4829 = _Time;
                float2 node_3423 = float2(((_VPan_U*node_4829.g)+o.uv0.r),(o.uv0.g+(node_4829.g*_VPan_V)));
                float4 _VertexT_var = tex2Dlod(_VertexT,float4(TRANSFORM_TEX(node_3423, _VertexT),0.0,0));
                v.vertex.xyz += lerp( 0.0, (_VertexT_var.rgb*_VertexPower.rgb*v.normal*o.uv1.g), _VerTexOffest );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
////// Lighting:
////// Emissive:
                float node_305_ang = ((_Ram_Rotator*3.141592654)/180.0);
                float node_305_spd = 1.0;
                float node_305_cos = cos(node_305_spd*node_305_ang);
                float node_305_sin = sin(node_305_spd*node_305_ang);
                float2 node_305_piv = float2(0.5,0.5);
                float2 node_305 = (mul(i.uv0-node_305_piv,float2x2( node_305_cos, -node_305_sin, node_305_sin, node_305_cos))+node_305_piv);
                float4 _RamColor_var = tex2D(_RamColor,TRANSFORM_TEX(node_305, _RamColor));
                float node_9089_ang = ((_Rotator*3.141592654)/180.0);
                float node_9089_spd = 1.0;
                float node_9089_cos = cos(node_9089_spd*node_9089_ang);
                float node_9089_sin = sin(node_9089_spd*node_9089_ang);
                float2 node_9089_piv = float2(0.5,0.5);
                float4 node_4416 = _Time;
                float4 node_3347 = _Time;
                float2 node_5564 = float2(((_UspeedNiuqu*node_3347.g)+i.uv0.r),(i.uv0.g+(node_3347.g*_VSpeedNiuqu)));
                float4 _NiuQu_var = tex2D(_NiuQu,TRANSFORM_TEX(node_5564, _NiuQu));
                float2 node_9401 = (lerp( float2(((_USpeed*node_4416.g)+i.uv0.r),(i.uv0.g+(node_4416.g*_VSpeed))), (i.uv0+float2(i.uv1.b,i.uv1.a)), _PanUV )+lerp( 0.0, (lerp( _NiuQuPower, i.uv1.g, _IntorCurver )*_NiuQu_var.r), _NQOff ));
                float2 node_9089 = (mul(node_9401-node_9089_piv,float2x2( node_9089_cos, -node_9089_sin, node_9089_sin, node_9089_cos))+node_9089_piv);
                float4 _Textures_var = tex2D(_Textures,TRANSFORM_TEX(node_9089, _Textures));
                float node_7059_ang = ((_Rotator_mask*3.141592654)/180.0);
                float node_7059_spd = 1.0;
                float node_7059_cos = cos(node_7059_spd*node_7059_ang);
                float node_7059_sin = sin(node_7059_spd*node_7059_ang);
                float2 node_7059_piv = float2(0.5,0.5);
                float4 node_8282 = _Time;
                float2 node_7059 = (mul(float2(((_Mask_U_Speed*node_8282.g)+i.uv0.r),(i.uv0.g+(node_8282.g*_Mask_V_Speed)))-node_7059_piv,float2x2( node_7059_cos, -node_7059_sin, node_7059_sin, node_7059_cos))+node_7059_piv);
                float4 node_1209 = _Time;
                float2 node_3591 = float2(((_UspeedNiuqu_niuqu_mask*node_1209.g)+i.uv0.r),(i.uv0.g+(node_1209.g*_VSpeedNiuqu_mask)));
                float4 _NiuQu_mask_var = tex2D(_NiuQu_mask,TRANSFORM_TEX(node_3591, _NiuQu_mask));
                float3 node_2127 = (float3(node_7059,0.0)+lerp( 0.0, (_mask_niuqu_power_copy*_NiuQu_mask_var.rgb), _mask_niuqu_copy ));
                float4 _OpacityTextures_var = tex2D(_OpacityTextures,TRANSFORM_TEX(node_2127, _OpacityTextures));
                float node_2813 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_FresnelPower);
                float _DissloveUVorPower_var = lerp( (1.0 - i.uv1.r), _DisslovePower, _DissloveUVorPower );
                float4 node_1240 = _Time;
                float4 node_4376 = _Time;
                float2 node_618 = float2(((_UspeedNiuqu_niuqu*node_4376.g)+i.uv0.r),(i.uv0.g+(node_4376.g*_VSpeedNiuquniuqu)));
                float4 _NiuQu_disslove_var = tex2D(_NiuQu_disslove,TRANSFORM_TEX(node_618, _NiuQu_disslove));
                float3 node_2557 = (float3(float2(((_DissU_Speed*node_1240.g)+i.uv0.r),(i.uv0.g+(node_1240.g*_DissV_Speed))),0.0)+lerp( 0.0, (_disslove_niuqu_power*_NiuQu_disslove_var.rgb), _Disslove_niuqu ));
                float4 _Disslove_var = tex2D(_Disslove,TRANSFORM_TEX(node_2557, _Disslove));
                float3 emissive = (_RamColor_var.rgb*((_Color.rgb*_Textures_var.rgb*(lerp( _Textures_var.r, _Textures_var.a, _TextureAlpha )*lerp( 1.0, _OpacityTextures_var.r, _MaskTex ))*i.vertexColor.rgb*i.vertexColor.a)*lerp( 1.0, saturate((sceneZ-partZ)/_SoftPower), _SoftParticle )*lerp( 1.0, (lerp( (1.0 - node_2813), node_2813, _Fresnel_oneminus )*_fn_v), _FresnelOp )*lerp( 1.0, smoothstep( _DissloveUVorPower_var, (_DissloveUVorPower_var+_Smooth), _Disslove_var.r ), _DissloveOff )));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _VertexT; uniform float4 _VertexT_ST;
            uniform float4 _VertexPower;
            uniform float _VPan_U;
            uniform float _VPan_V;
            uniform fixed _VerTexOffest;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 uv1 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_4829 = _Time;
                float2 node_3423 = float2(((_VPan_U*node_4829.g)+o.uv0.r),(o.uv0.g+(node_4829.g*_VPan_V)));
                float4 _VertexT_var = tex2Dlod(_VertexT,float4(TRANSFORM_TEX(node_3423, _VertexT),0.0,0));
                v.vertex.xyz += lerp( 0.0, (_VertexT_var.rgb*_VertexPower.rgb*v.normal*o.uv1.g), _VerTexOffest );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
