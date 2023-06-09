// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:1761,x:33981,y:32443,varname:node_1761,prsc:2|emission-1077-OUT,alpha-8945-OUT,voffset-3179-OUT;n:type:ShaderForge.SFN_Tex2d,id:5485,x:32055,y:32415,ptovrint:False,ptlb:Textures,ptin:_Textures,varname:node_5485,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-3814-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:5062,x:32460,y:32528,varname:node_5062,prsc:2;n:type:ShaderForge.SFN_Color,id:3569,x:32404,y:32180,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_3569,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:8018,x:32656,y:32289,varname:node_8018,prsc:2|A-3569-RGB,B-5485-RGB,C-5062-RGB;n:type:ShaderForge.SFN_SwitchProperty,id:4275,x:32132,y:32642,ptovrint:False,ptlb:TextureAlpha,ptin:_TextureAlpha,varname:node_4275,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-5485-R,B-5485-A;n:type:ShaderForge.SFN_DepthBlend,id:5518,x:32239,y:33166,varname:node_5518,prsc:2|DIST-6694-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:8806,x:32504,y:33023,ptovrint:False,ptlb:SoftParticle,ptin:_SoftParticle,varname:node_8806,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2176-OUT,B-5518-OUT;n:type:ShaderForge.SFN_TexCoord,id:1130,x:30092,y:31897,varname:node_1130,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:3610,x:29879,y:31954,varname:node_3610,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8092,x:29902,y:31798,ptovrint:False,ptlb:U Speed,ptin:_USpeed,varname:node_8092,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:899,x:29904,y:32139,ptovrint:False,ptlb:V Speed,ptin:_VSpeed,varname:node_899,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6103,x:30187,y:32184,varname:node_6103,prsc:2|A-3610-T,B-899-OUT;n:type:ShaderForge.SFN_Multiply,id:2835,x:30104,y:31751,varname:node_2835,prsc:2|A-8092-OUT,B-3610-T;n:type:ShaderForge.SFN_Append,id:7461,x:30474,y:31916,varname:node_7461,prsc:2|A-5074-OUT,B-31-OUT;n:type:ShaderForge.SFN_Add,id:5074,x:30288,y:31828,varname:node_5074,prsc:2|A-2835-OUT,B-1130-U;n:type:ShaderForge.SFN_Add,id:31,x:30399,y:32050,varname:node_31,prsc:2|A-1130-V,B-6103-OUT;n:type:ShaderForge.SFN_Multiply,id:7551,x:33021,y:32860,varname:node_7551,prsc:2|A-7234-OUT,B-5062-A,C-8806-OUT,D-24-OUT,E-6339-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7234,x:32557,y:32818,ptovrint:False,ptlb:Mask Tex,ptin:_MaskTex,varname:node_7234,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4275-OUT,B-1096-OUT;n:type:ShaderForge.SFN_Tex2d,id:272,x:32132,y:32837,ptovrint:False,ptlb:Opacity Textures,ptin:_OpacityTextures,varname:node_272,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1056-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1096,x:32293,y:32844,varname:node_1096,prsc:2|A-4275-OUT,B-272-R;n:type:ShaderForge.SFN_Fresnel,id:9623,x:31997,y:33354,varname:node_9623,prsc:2|EXP-8418-OUT;n:type:ShaderForge.SFN_OneMinus,id:6208,x:32193,y:33336,varname:node_6208,prsc:2|IN-9623-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8418,x:31805,y:33413,ptovrint:False,ptlb: Fresnel   Power,ptin:_FresnelPower,varname:node_8418,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:24,x:32694,y:33306,ptovrint:False,ptlb:Fresnel Op,ptin:_FresnelOp,varname:node_24,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-292-OUT,B-3016-OUT;n:type:ShaderForge.SFN_Vector1,id:292,x:32381,y:33248,varname:node_292,prsc:2,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:6339,x:32738,y:33534,ptovrint:False,ptlb:Dissolve,ptin:_Dissolve,varname:node_6339,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-168-OUT,B-1855-OUT;n:type:ShaderForge.SFN_Vector1,id:168,x:32519,y:33495,varname:node_168,prsc:2,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:1785,x:31071,y:32222,ptovrint:False,ptlb:PanUV,ptin:_PanUV,varname:node_9480,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7461-OUT,B-358-OUT;n:type:ShaderForge.SFN_TexCoord,id:3152,x:30431,y:32310,varname:node_3152,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:358,x:30853,y:32308,varname:node_358,prsc:2|A-3152-UVOUT,B-2626-OUT;n:type:ShaderForge.SFN_Append,id:2626,x:30665,y:32399,varname:node_2626,prsc:2|A-1530-Z,B-1530-W;n:type:ShaderForge.SFN_TexCoord,id:1530,x:30383,y:32493,varname:node_1530,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_Lerp,id:7982,x:33037,y:32406,varname:node_7982,prsc:2|A-71-OUT,B-8018-OUT,T-5880-VFACE;n:type:ShaderForge.SFN_FaceSign,id:5880,x:32809,y:32519,varname:node_5880,prsc:2,fstp:0;n:type:ShaderForge.SFN_Multiply,id:71,x:32828,y:32372,varname:node_71,prsc:2|A-8018-OUT,B-5685-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5685,x:32656,y:32461,ptovrint:False,ptlb:BackFacePower,ptin:_BackFacePower,varname:node_5685,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:6189,x:31283,y:32591,varname:node_6189,prsc:2|A-1785-OUT,B-2201-OUT;n:type:ShaderForge.SFN_Tex2d,id:5123,x:30784,y:32867,ptovrint:False,ptlb:niuqu_Tex,ptin:_niuqu_Tex,varname:node_5123,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5002-OUT;n:type:ShaderForge.SFN_Multiply,id:2201,x:30970,y:32884,varname:node_2201,prsc:2|A-5123-R,B-7867-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7867,x:30784,y:33075,ptovrint:False,ptlb:NIUQU,ptin:_NIUQU,varname:node_7867,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Rotator,id:3814,x:31476,y:32591,varname:node_3814,prsc:2|UVIN-6189-OUT,ANG-7173-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3492,x:30958,y:33048,ptovrint:False,ptlb:Rotator,ptin:_Rotator,varname:node_3492,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:813,x:31147,y:33048,varname:node_813,prsc:2|A-3492-OUT,B-6943-OUT;n:type:ShaderForge.SFN_Pi,id:6943,x:30974,y:33116,varname:node_6943,prsc:2;n:type:ShaderForge.SFN_Divide,id:7173,x:31322,y:33070,varname:node_7173,prsc:2|A-813-OUT,B-3119-OUT;n:type:ShaderForge.SFN_Vector1,id:3119,x:31045,y:33227,varname:node_3119,prsc:2,v1:180;n:type:ShaderForge.SFN_Multiply,id:7169,x:33271,y:32319,varname:node_7169,prsc:2|A-9931-RGB,B-7982-OUT;n:type:ShaderForge.SFN_Tex2d,id:9931,x:32993,y:32077,ptovrint:False,ptlb:RampColor,ptin:_RampColor,varname:node_9931,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9892-UVOUT;n:type:ShaderForge.SFN_Multiply,id:8945,x:33512,y:32862,varname:node_8945,prsc:2|A-3569-A,B-7551-OUT,C-632-R,D-882-OUT;n:type:ShaderForge.SFN_Tex2d,id:8297,x:32101,y:33884,ptovrint:False,ptlb:Disslov,ptin:_Disslov,varname:node_8001,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5378-UVOUT;n:type:ShaderForge.SFN_ValueProperty,id:6474,x:31411,y:33698,ptovrint:False,ptlb:DissPower,ptin:_DissPower,varname:node_3928,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Smoothstep,id:1855,x:32478,y:33691,varname:node_1855,prsc:2|A-4983-OUT,B-9589-OUT,V-8297-R;n:type:ShaderForge.SFN_ValueProperty,id:6120,x:32047,y:33777,ptovrint:False,ptlb:Smoot,ptin:_Smoot,varname:node_8360,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:9589,x:32237,y:33707,varname:node_9589,prsc:2|A-4983-OUT,B-6120-OUT;n:type:ShaderForge.SFN_OneMinus,id:2205,x:31411,y:33550,varname:node_2205,prsc:2|IN-1530-U;n:type:ShaderForge.SFN_ValueProperty,id:6694,x:32033,y:33166,ptovrint:False,ptlb:SoftPower,ptin:_SoftPower,varname:node_6694,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:4983,x:31821,y:33545,ptovrint:False,ptlb:DissOrPower,ptin:_DissOrPower,varname:node_4983,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2205-OUT,B-6474-OUT;n:type:ShaderForge.SFN_Add,id:6284,x:31486,y:33892,varname:node_6284,prsc:2|A-2201-OUT,B-672-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7786,x:31683,y:33874,ptovrint:False,ptlb:NiuQUDiss,ptin:_NiuQUDiss,varname:node_7786,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-672-OUT,B-6284-OUT;n:type:ShaderForge.SFN_Tex2d,id:5590,x:33480,y:33808,ptovrint:False,ptlb:VertexT,ptin:_VertexT,varname:node_6095,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-6227-OUT;n:type:ShaderForge.SFN_Vector4Property,id:9339,x:33518,y:33984,ptovrint:False,ptlb:VertexPower,ptin:_VertexPower,varname:node_3318,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1,v2:1,v3:1,v4:0;n:type:ShaderForge.SFN_Append,id:6227,x:33299,y:33836,varname:node_6227,prsc:2|A-5515-OUT,B-5927-OUT;n:type:ShaderForge.SFN_Add,id:5515,x:33084,y:33822,varname:node_5515,prsc:2|A-9778-OUT,B-6300-U;n:type:ShaderForge.SFN_Add,id:5927,x:33176,y:34117,varname:node_5927,prsc:2|A-6300-V,B-880-OUT;n:type:ShaderForge.SFN_Multiply,id:880,x:32907,y:34264,varname:node_880,prsc:2|A-6902-T,B-4622-OUT;n:type:ShaderForge.SFN_Multiply,id:9778,x:32906,y:33822,varname:node_9778,prsc:2|A-6861-OUT,B-6902-T;n:type:ShaderForge.SFN_Time,id:6902,x:32679,y:34005,varname:node_6902,prsc:2;n:type:ShaderForge.SFN_TexCoord,id:6300,x:32907,y:34069,varname:node_6300,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_ValueProperty,id:6861,x:32692,y:33804,ptovrint:False,ptlb:VPan_U,ptin:_VPan_U,varname:node_626,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:4622,x:32663,y:34298,ptovrint:False,ptlb:VPan_V,ptin:_VPan_V,varname:node_9913,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:3179,x:34068,y:33831,ptovrint:False,ptlb:VerTexOffest,ptin:_VerTexOffest,varname:node_5945,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6182-OUT,B-2697-OUT;n:type:ShaderForge.SFN_Multiply,id:2697,x:33873,y:33857,varname:node_2697,prsc:2|A-5590-RGB,B-9339-XYZ,C-1516-OUT,D-2611-V;n:type:ShaderForge.SFN_NormalVector,id:1516,x:33518,y:34197,prsc:2,pt:True;n:type:ShaderForge.SFN_Vector1,id:6182,x:33678,y:33757,varname:node_6182,prsc:2,v1:0;n:type:ShaderForge.SFN_TexCoord,id:2611,x:33742,y:34060,varname:node_2611,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_TexCoord,id:925,x:30822,y:33416,varname:node_925,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:6743,x:30846,y:33594,varname:node_6743,prsc:2|A-2775-T,B-1871-OUT;n:type:ShaderForge.SFN_Multiply,id:4948,x:30834,y:33270,varname:node_4948,prsc:2|A-773-OUT,B-2775-T;n:type:ShaderForge.SFN_Append,id:3064,x:31204,y:33435,varname:node_3064,prsc:2|A-8670-OUT,B-8504-OUT;n:type:ShaderForge.SFN_Add,id:8670,x:31018,y:33347,varname:node_8670,prsc:2|A-4948-OUT,B-925-U;n:type:ShaderForge.SFN_Add,id:8504,x:31018,y:33544,varname:node_8504,prsc:2|A-925-V,B-6743-OUT;n:type:ShaderForge.SFN_Time,id:2775,x:30609,y:33487,varname:node_2775,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:773,x:30609,y:33270,ptovrint:False,ptlb:OpacityU_Speed,ptin:_OpacityU_Speed,varname:node_773,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:1871,x:30609,y:33648,ptovrint:False,ptlb:OpacityV_Speed,ptin:_OpacityV_Speed,varname:_OpacityU_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:632,x:33021,y:33057,ptovrint:False,ptlb:MaskTextures,ptin:_MaskTextures,varname:node_632,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Vector1,id:2176,x:32313,y:32996,varname:node_2176,prsc:2,v1:1;n:type:ShaderForge.SFN_TexCoord,id:9632,x:30241,y:32856,varname:node_9632,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:8416,x:30113,y:33010,varname:node_8416,prsc:2|A-7090-T,B-4776-OUT;n:type:ShaderForge.SFN_Multiply,id:8068,x:30113,y:32770,varname:node_8068,prsc:2|A-7412-OUT,B-7090-T;n:type:ShaderForge.SFN_Append,id:5002,x:30578,y:32867,varname:node_5002,prsc:2|A-6266-OUT,B-9087-OUT;n:type:ShaderForge.SFN_Add,id:6266,x:30411,y:32770,varname:node_6266,prsc:2|A-8068-OUT,B-9632-U;n:type:ShaderForge.SFN_Add,id:9087,x:30411,y:32994,varname:node_9087,prsc:2|A-9632-V,B-8416-OUT;n:type:ShaderForge.SFN_Time,id:7090,x:29930,y:32863,varname:node_7090,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7412,x:29930,y:32770,ptovrint:False,ptlb:N_U_Speed,ptin:_N_U_Speed,varname:node_7412,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:4776,x:29930,y:33030,ptovrint:False,ptlb:N_V_Speed,ptin:_N_V_Speed,varname:node_4776,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:3016,x:32492,y:33306,ptovrint:False,ptlb:Fresnel_Oneminus,ptin:_Fresnel_Oneminus,varname:node_3016,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6208-OUT,B-1827-OUT;n:type:ShaderForge.SFN_OneMinus,id:1827,x:32337,y:33400,varname:node_1827,prsc:2|IN-6208-OUT;n:type:ShaderForge.SFN_HalfVector,id:5061,x:33292,y:32072,varname:node_5061,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1308,x:30599,y:33904,ptovrint:False,ptlb:Disslov_U_speed,ptin:_Disslov_U_speed,varname:node_1308,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:1521,x:30599,y:34165,ptovrint:False,ptlb:Disslov_V_speed,ptin:_Disslov_V_speed,varname:node_1521,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Time,id:8509,x:30599,y:33987,varname:node_8509,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3142,x:30853,y:33860,varname:node_3142,prsc:2|A-1308-OUT,B-8509-T;n:type:ShaderForge.SFN_Multiply,id:7685,x:30850,y:34146,varname:node_7685,prsc:2|A-8509-T,B-1521-OUT;n:type:ShaderForge.SFN_TexCoord,id:7717,x:30850,y:33987,varname:node_7717,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:473,x:31090,y:33899,varname:node_473,prsc:2|A-3142-OUT,B-7717-U;n:type:ShaderForge.SFN_Add,id:566,x:31108,y:34069,varname:node_566,prsc:2|A-7717-V,B-7685-OUT;n:type:ShaderForge.SFN_Append,id:672,x:31281,y:34012,varname:node_672,prsc:2|A-473-OUT,B-566-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6155,x:31273,y:34232,ptovrint:False,ptlb:Rotator_Disslov,ptin:_Rotator_Disslov,varname:_Rotator_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6550,x:31462,y:34232,varname:node_6550,prsc:2|A-6155-OUT,B-1194-OUT;n:type:ShaderForge.SFN_Pi,id:1194,x:31289,y:34300,varname:node_1194,prsc:2;n:type:ShaderForge.SFN_Divide,id:1690,x:31665,y:34256,varname:node_1690,prsc:2|A-6550-OUT,B-3247-OUT;n:type:ShaderForge.SFN_Rotator,id:5378,x:31885,y:33874,varname:node_5378,prsc:2|UVIN-7786-OUT,ANG-1690-OUT;n:type:ShaderForge.SFN_Vector1,id:3247,x:31451,y:34421,varname:node_3247,prsc:2,v1:180;n:type:ShaderForge.SFN_Tex2d,id:9301,x:29891,y:33278,ptovrint:False,ptlb:mask_niuqu,ptin:_mask_niuqu,varname:__copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9150-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4047,x:29891,y:33486,ptovrint:False,ptlb:NIUQU_mask,ptin:_NIUQU_mask,varname:_NIUQU_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:5919,x:29348,y:33267,varname:node_5919,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:2283,x:29220,y:33421,varname:node_2283,prsc:2|A-1876-T,B-2473-OUT;n:type:ShaderForge.SFN_Multiply,id:1717,x:29220,y:33181,varname:node_1717,prsc:2|A-5041-OUT,B-1876-T;n:type:ShaderForge.SFN_Append,id:9150,x:29685,y:33278,varname:node_9150,prsc:2|A-8703-OUT,B-6549-OUT;n:type:ShaderForge.SFN_Add,id:8703,x:29518,y:33181,varname:node_8703,prsc:2|A-1717-OUT,B-5919-U;n:type:ShaderForge.SFN_Add,id:6549,x:29518,y:33405,varname:node_6549,prsc:2|A-5919-V,B-2283-OUT;n:type:ShaderForge.SFN_Time,id:1876,x:29037,y:33274,varname:node_1876,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5041,x:29037,y:33181,ptovrint:False,ptlb:mask_niuqu_Speed_u,ptin:_mask_niuqu_Speed_u,varname:_N_U_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:2473,x:29037,y:33441,ptovrint:False,ptlb:mask_niuqu_Speed_v,ptin:_mask_niuqu_Speed_v,varname:_N_V_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6551,x:30077,y:33295,varname:node_6551,prsc:2|A-9301-R,B-4047-OUT;n:type:ShaderForge.SFN_Add,id:1591,x:31559,y:33297,varname:node_1591,prsc:2|A-321-OUT,B-3064-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:321,x:30306,y:33295,ptovrint:False,ptlb:mask_niuqu_off,ptin:_mask_niuqu_off,varname:node_321,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-1313-OUT,B-6551-OUT;n:type:ShaderForge.SFN_Vector1,id:1313,x:30077,y:33223,varname:node_1313,prsc:2,v1:0;n:type:ShaderForge.SFN_ViewVector,id:4257,x:32960,y:33313,varname:node_4257,prsc:2;n:type:ShaderForge.SFN_NormalVector,id:6312,x:32960,y:33470,prsc:2,pt:False;n:type:ShaderForge.SFN_Dot,id:2521,x:33167,y:33415,varname:node_2521,prsc:2,dt:0|A-4257-OUT,B-6312-OUT;n:type:ShaderForge.SFN_Abs,id:9586,x:33368,y:33415,varname:node_9586,prsc:2|IN-2521-OUT;n:type:ShaderForge.SFN_Power,id:882,x:33594,y:33415,varname:node_882,prsc:2|VAL-9586-OUT,EXP-5368-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5368,x:33283,y:33627,ptovrint:False,ptlb:yuhua_power,ptin:_yuhua_power,varname:node_5368,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_OneMinus,id:1978,x:33883,y:33469,varname:node_1978,prsc:2|IN-882-OUT;n:type:ShaderForge.SFN_Multiply,id:1401,x:30196,y:33672,varname:node_1401,prsc:2|A-9887-OUT,B-9565-OUT;n:type:ShaderForge.SFN_Pi,id:9565,x:30023,y:33740,varname:node_9565,prsc:2;n:type:ShaderForge.SFN_Divide,id:1114,x:30399,y:33696,varname:node_1114,prsc:2|A-1401-OUT,B-7358-OUT;n:type:ShaderForge.SFN_Vector1,id:7358,x:30094,y:33851,varname:node_7358,prsc:2,v1:180;n:type:ShaderForge.SFN_ValueProperty,id:9887,x:29990,y:33672,ptovrint:False,ptlb:Mask_R,ptin:_Mask_R,varname:node_9887,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Rotator,id:1056,x:31760,y:33267,varname:node_1056,prsc:2|UVIN-1591-OUT,ANG-1114-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3462,x:31762,y:32045,ptovrint:False,ptlb:Ramp_R,ptin:_Ramp_R,varname:node_3462,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6354,x:31968,y:32061,varname:node_6354,prsc:2|A-3462-OUT,B-5691-OUT;n:type:ShaderForge.SFN_Pi,id:5691,x:31795,y:32129,varname:node_5691,prsc:2;n:type:ShaderForge.SFN_Divide,id:1153,x:32171,y:32085,varname:node_1153,prsc:2|A-6354-OUT,B-9914-OUT;n:type:ShaderForge.SFN_Vector1,id:9914,x:31866,y:32240,varname:node_9914,prsc:2,v1:180;n:type:ShaderForge.SFN_TexCoord,id:3829,x:32205,y:31728,varname:node_3829,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Rotator,id:9892,x:32504,y:31857,varname:node_9892,prsc:2|UVIN-3829-UVOUT,ANG-1153-OUT;n:type:ShaderForge.SFN_Add,id:1077,x:33497,y:32319,varname:node_1077,prsc:2|A-7169-OUT,B-3311-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:3311,x:33294,y:32611,ptovrint:False,ptlb:Fre_ad,ptin:_Fre_ad,varname:node_3311,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6149-OUT,B-7793-OUT;n:type:ShaderForge.SFN_Vector1,id:6149,x:32992,y:32616,varname:node_6149,prsc:2,v1:0;n:type:ShaderForge.SFN_Color,id:4365,x:32845,y:32682,ptovrint:False,ptlb:Fre_color,ptin:_Fre_color,varname:node_4365,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:7793,x:33112,y:32681,varname:node_7793,prsc:2|A-4365-RGB,B-3016-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7402,x:31704,y:32832,ptovrint:False,ptlb:mask_Pan,ptin:_mask_Pan,varname:node_7402,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-1056-UVOUT,B-358-OUT;n:type:ShaderForge.SFN_Add,id:2799,x:31901,y:32779,varname:node_2799,prsc:2|A-7402-OUT,B-1056-UVOUT;proporder:5485-3492-4275-1785-3569-8092-899-6694-8806-272-9887-7234-773-1871-8297-6339-6120-4983-6474-1521-1308-6155-5123-7867-7412-4776-7786-9931-3462-5685-24-3016-8418-5590-3179-9339-6861-4622-632-9301-4047-5041-2473-321-5368-3311-4365-7402;pass:END;sub:END;*/

Shader "A201-Shader/进阶功能/多功能溶解Alpha模式_Alpha Double" {
    Properties {
        _Textures ("主贴图", 2D) = "white" {}
        _Rotator ("主贴图旋转", Float ) = 0
        [MaterialToggle] _TextureAlpha ("主贴图Alpha模式", Float ) = 0
        [MaterialToggle] _PanUV ("粒子系统控制UV", Float ) = 0
        [HDR]_Color ("颜色", Color) = (0.5,0.5,0.5,1)
        _USpeed ("U方向流动速度", Float ) = 0
        _VSpeed ("V方向流动速度", Float ) = 0
        _SoftPower ("顶点平滑强度", Float ) = 1
        [MaterialToggle] _SoftParticle ("是否启用顶点平滑(SoftParticle)", Float ) = 1
        _OpacityTextures ("透明度贴图(Opacity)", 2D) = "white" {}
        _Mask_R ("贴图旋转", Float ) = 0
        [MaterialToggle] _MaskTex ("是否启用透明度贴图", Float ) = 0
        _OpacityU_Speed ("透明度贴图U方向流动速度", Float ) = 0
        _OpacityV_Speed ("透明度贴图V方向流动速度", Float ) = 0
        _Disslov ("溶解贴图(Disslove)", 2D) = "white" {}
        [MaterialToggle] _Dissolve ("是否启用溶解贴图", Float ) = 1
        _Smoot ("溶解平滑度", Float ) = 0
        [MaterialToggle] _DissOrPower ("是否启用定向溶解", Float ) = 1
        _DissPower ("定向溶解强度", Float ) = 0
        _Disslov_V_speed ("溶解V方向流动速度", Float ) = 0
        _Disslov_U_speed ("溶解U方向流动速度", Float ) = 0
        _Rotator_Disslov ("溶解贴图旋转", Float ) = 0
        _niuqu_Tex ("扭曲贴图", 2D) = "white" {}
        _NIUQU ("扭曲强度", Float ) = 0
        _N_U_Speed ("扭曲U方向流动速度", Float ) = 0
        _N_V_Speed ("扭曲V方向流动速度", Float ) = 0
        [MaterialToggle] _NiuQUDiss ("启用扭曲溶解", Float ) = 0
        _RampColor ("颜色渐变(Ramp)", 2D) = "white" {}
        _Ramp_R ("颜色渐变旋转", Float ) = 0
        _BackFacePower ("颜色渐变强度", Float ) = 1
        [MaterialToggle] _FresnelOp ("是否启用菲涅尔效果", Float ) = 1
        [MaterialToggle] _Fresnel_Oneminus ("菲涅尔反转", Float ) = 1
        _FresnelPower ("菲涅尔强度", Float ) = 0
        _VertexT ("颜色渐变顶点(Vertex)", 2D) = "white" {}
        [MaterialToggle] _VerTexOffest ("是否启用顶点偏移", Float ) = 0
        _VertexPower ("顶点偏移数值", Vector) = (1,1,1,0)
        _VPan_U ("顶点偏移U方向流动速度", Float ) = 0
        _VPan_V ("顶点偏移V方向流动速度", Float ) = 0
        _MaskTextures ("遮罩贴图", 2D) = "white" {}
        _mask_niuqu ("遮罩扭曲贴图", 2D) = "white" {}
        _NIUQU_mask ("遮罩扭曲数值", Float ) = 0
        _mask_niuqu_Speed_u ("扭曲遮罩U方向流动速度", Float ) = 0
        _mask_niuqu_Speed_v ("扭曲遮罩V方向流动速度", Float ) = 0
        [MaterialToggle] _mask_niuqu_off ("mask_niuqu_off", Float ) = 0
        _yuhua_power ("yuhua_power", Float ) = 0
        [MaterialToggle] _Fre_ad ("Fre_ad", Float ) = 0
        [HDR]_Fre_color ("Fre_color", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _mask_Pan ("mask_Pan", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
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
            uniform float _FresnelPower;
            uniform fixed _FresnelOp;
            uniform fixed _Dissolve;
            uniform fixed _PanUV;
            uniform float _BackFacePower;
            uniform sampler2D _niuqu_Tex; uniform float4 _niuqu_Tex_ST;
            uniform float _NIUQU;
            uniform float _Rotator;
            uniform sampler2D _RampColor; uniform float4 _RampColor_ST;
            uniform sampler2D _Disslov; uniform float4 _Disslov_ST;
            uniform float _DissPower;
            uniform float _Smoot;
            uniform float _SoftPower;
            uniform fixed _DissOrPower;
            uniform fixed _NiuQUDiss;
            uniform sampler2D _VertexT; uniform float4 _VertexT_ST;
            uniform float4 _VertexPower;
            uniform float _VPan_U;
            uniform float _VPan_V;
            uniform fixed _VerTexOffest;
            uniform float _OpacityU_Speed;
            uniform float _OpacityV_Speed;
            uniform sampler2D _MaskTextures; uniform float4 _MaskTextures_ST;
            uniform float _N_U_Speed;
            uniform float _N_V_Speed;
            uniform fixed _Fresnel_Oneminus;
            uniform float _Disslov_U_speed;
            uniform float _Disslov_V_speed;
            uniform float _Rotator_Disslov;
            uniform sampler2D _mask_niuqu; uniform float4 _mask_niuqu_ST;
            uniform float _NIUQU_mask;
            uniform float _mask_niuqu_Speed_u;
            uniform float _mask_niuqu_Speed_v;
            uniform fixed _mask_niuqu_off;
            uniform float _yuhua_power;
            uniform float _Mask_R;
            uniform float _Ramp_R;
            uniform fixed _Fre_ad;
            uniform float4 _Fre_color;
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
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_6902 = _Time;
                float2 node_6227 = float2(((_VPan_U*node_6902.g)+o.uv0.r),(o.uv0.g+(node_6902.g*_VPan_V)));
                float4 _VertexT_var = tex2Dlod(_VertexT,float4(TRANSFORM_TEX(node_6227, _VertexT),0.0,0));
                v.vertex.xyz += lerp( 0.0, (_VertexT_var.rgb*_VertexPower.rgb*v.normal*o.uv1.g), _VerTexOffest );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
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
                float node_9892_ang = ((_Ramp_R*3.141592654)/180.0);
                float node_9892_spd = 1.0;
                float node_9892_cos = cos(node_9892_spd*node_9892_ang);
                float node_9892_sin = sin(node_9892_spd*node_9892_ang);
                float2 node_9892_piv = float2(0.5,0.5);
                float2 node_9892 = (mul(i.uv0-node_9892_piv,float2x2( node_9892_cos, -node_9892_sin, node_9892_sin, node_9892_cos))+node_9892_piv);
                float4 _RampColor_var = tex2D(_RampColor,TRANSFORM_TEX(node_9892, _RampColor));
                float node_3814_ang = ((_Rotator*3.141592654)/180.0);
                float node_3814_spd = 1.0;
                float node_3814_cos = cos(node_3814_spd*node_3814_ang);
                float node_3814_sin = sin(node_3814_spd*node_3814_ang);
                float2 node_3814_piv = float2(0.5,0.5);
                float4 node_3610 = _Time;
                float2 node_358 = (i.uv0+float2(i.uv1.b,i.uv1.a));
                float4 node_7090 = _Time;
                float2 node_5002 = float2(((_N_U_Speed*node_7090.g)+i.uv0.r),(i.uv0.g+(node_7090.g*_N_V_Speed)));
                float4 _niuqu_Tex_var = tex2D(_niuqu_Tex,TRANSFORM_TEX(node_5002, _niuqu_Tex));
                float node_2201 = (_niuqu_Tex_var.r*_NIUQU);
                float2 node_3814 = (mul((lerp( float2(((_USpeed*node_3610.g)+i.uv0.r),(i.uv0.g+(node_3610.g*_VSpeed))), node_358, _PanUV )+node_2201)-node_3814_piv,float2x2( node_3814_cos, -node_3814_sin, node_3814_sin, node_3814_cos))+node_3814_piv);
                float4 _Textures_var = tex2D(_Textures,TRANSFORM_TEX(node_3814, _Textures));
                float3 node_8018 = (_Color.rgb*_Textures_var.rgb*i.vertexColor.rgb);
                float node_6208 = (1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),_FresnelPower));
                float _Fresnel_Oneminus_var = lerp( node_6208, (1.0 - node_6208), _Fresnel_Oneminus );
                float3 emissive = ((_RampColor_var.rgb*lerp((node_8018*_BackFacePower),node_8018,isFrontFace))+lerp( 0.0, (_Fre_color.rgb*_Fresnel_Oneminus_var), _Fre_ad ));
                float3 finalColor = emissive;
                float _TextureAlpha_var = lerp( _Textures_var.r, _Textures_var.a, _TextureAlpha );
                float node_1056_ang = ((_Mask_R*3.141592654)/180.0);
                float node_1056_spd = 1.0;
                float node_1056_cos = cos(node_1056_spd*node_1056_ang);
                float node_1056_sin = sin(node_1056_spd*node_1056_ang);
                float2 node_1056_piv = float2(0.5,0.5);
                float4 node_1876 = _Time;
                float2 node_9150 = float2(((_mask_niuqu_Speed_u*node_1876.g)+i.uv0.r),(i.uv0.g+(node_1876.g*_mask_niuqu_Speed_v)));
                float4 _mask_niuqu_var = tex2D(_mask_niuqu,TRANSFORM_TEX(node_9150, _mask_niuqu));
                float4 node_2775 = _Time;
                float2 node_1056 = (mul((lerp( 0.0, (_mask_niuqu_var.r*_NIUQU_mask), _mask_niuqu_off )+float2(((_OpacityU_Speed*node_2775.g)+i.uv0.r),(i.uv0.g+(node_2775.g*_OpacityV_Speed))))-node_1056_piv,float2x2( node_1056_cos, -node_1056_sin, node_1056_sin, node_1056_cos))+node_1056_piv);
                float4 _OpacityTextures_var = tex2D(_OpacityTextures,TRANSFORM_TEX(node_1056, _OpacityTextures));
                float _DissOrPower_var = lerp( (1.0 - i.uv1.r), _DissPower, _DissOrPower );
                float node_5378_ang = ((_Rotator_Disslov*3.141592654)/180.0);
                float node_5378_spd = 1.0;
                float node_5378_cos = cos(node_5378_spd*node_5378_ang);
                float node_5378_sin = sin(node_5378_spd*node_5378_ang);
                float2 node_5378_piv = float2(0.5,0.5);
                float4 node_8509 = _Time;
                float2 node_672 = float2(((_Disslov_U_speed*node_8509.g)+i.uv0.r),(i.uv0.g+(node_8509.g*_Disslov_V_speed)));
                float2 node_5378 = (mul(lerp( node_672, (node_2201+node_672), _NiuQUDiss )-node_5378_piv,float2x2( node_5378_cos, -node_5378_sin, node_5378_sin, node_5378_cos))+node_5378_piv);
                float4 _Disslov_var = tex2D(_Disslov,TRANSFORM_TEX(node_5378, _Disslov));
                float4 _MaskTextures_var = tex2D(_MaskTextures,TRANSFORM_TEX(i.uv0, _MaskTextures));
                float node_882 = pow(abs(dot(viewDirection,i.normalDir)),_yuhua_power);
                fixed4 finalRGBA = fixed4(finalColor,(_Color.a*(lerp( _TextureAlpha_var, (_TextureAlpha_var*_OpacityTextures_var.r), _MaskTex )*i.vertexColor.a*lerp( 1.0, saturate((sceneZ-partZ)/_SoftPower), _SoftParticle )*lerp( 1.0, _Fresnel_Oneminus_var, _FresnelOp )*lerp( 1.0, smoothstep( _DissOrPower_var, (_DissOrPower_var+_Smoot), _Disslov_var.r ), _Dissolve ))*_MaskTextures_var.r*node_882));
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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
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
                float4 node_6902 = _Time;
                float2 node_6227 = float2(((_VPan_U*node_6902.g)+o.uv0.r),(o.uv0.g+(node_6902.g*_VPan_V)));
                float4 _VertexT_var = tex2Dlod(_VertexT,float4(TRANSFORM_TEX(node_6227, _VertexT),0.0,0));
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
