// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/进阶功能/UV流动制作_FlowMap"
{
	Properties
	{
		_WebSite("此Shader教程网址:www.magesbox.com/article/detail/id/1967.html", Int) = 1967
		[Header(__________________________________________________________________________________________)]
		[Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
		[Enum(AlphaBlend,10,Additive,1)]_Dst("材质模式", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("剔除模式（正反面显示）", Float) = 0
		[Header(MainTex)]_maintex("主贴图", 2D) = "white" {}
		[HDR]_Maincolor("主贴图颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_A_R("主贴图通道", Float) = 0
		[Enum(OFF,0,ON,1)]_one_UV("粒子系统控制UV流动", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_MianClamp("主贴图重铺与否", Float) = 0
		_soft("软粒子", Float) = 0
		_mainRotator("主贴图旋转", Float) = 0
		_Main_U_Speed("主贴图U方向流动速度", Float) = 0
		_Main_V_Speed("主贴图V方向流动速度", Float) = 0
		[Header(GAM)]_Gam("颜色叠加（使用有色图/渐变贴图）", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_Flowmap_IF_Effect_Gam("FlowMap贴图是否影响颜色叠加", Float) = 1
		_GAMRotator("颜色叠加贴图旋转", Float) = 0
		[Header(MASKTEX)]_MASKTEX("遮罩贴图", 2D) = "white" {}
		[Enum(Repeat,0,Clmap,1)]_MaskClamp("遮罩贴图是否重铺", Float) = 0
		[Enum(OFF,0,ON,1)]_Flowmap_IF_Effect_Mask("FlowMap贴图是否影响遮罩贴图", Float) = 1
		_MASKRotator("遮罩贴图旋转", Float) = 0
		_MASK_u_speed("遮罩贴图U方向流动速度", Float) = 0
		_MASK_v_speed("遮罩贴图V方向流动速度", Float) = 0
		[Header(FlowMap)]_FlowMap_Tex("UV流动贴图（FlowMap）", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_FlowMapSC("FlowMap贴图是否由粒子控制（Y控制变形程度）", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_FlowMapClamp("FlowMap是否重铺", Float) = 0
		[Enum(Maintex_flowmap,0,Dissolve_flowmap,1)]_Flowmap_MainOrDissolve("主贴图跟随变形或变形同时溶解", Float) = 0
		_FlowMapOneScale("FlowMap贴图一次性放大倍数", Float) = 1
		_FlowMap("FlowMap跟随主贴图变形程度", Range( 0 , 1)) = 0
		[Header(DissovleTex)]_DissovleTex("溶解贴图", 2D) = "white" {}
		[Toggle(_USE_DISSOLVE_ON)] _use_dissolve("是否使用溶解（X控制溶解程度）", Float) = 0
		[Enum(OFF,0,ON,1)]_DissSC("粒子控制溶解结果显示(OFF=结果/ON=过程)", Float) = 0
		_smooth("溶解平滑程度", Range( 0.5 , 1)) = 0.6134824
		_DisspowerFlowmap("溶解程度", Range( 0 , 1)) = 1
		_Dissovle_U_speed("溶解贴图U方向流动速度", Float) = 0
		_Dissovle_V_speed("溶解贴图V方向流动速度", Float) = 0
		[Header(NIUQU_Tex)]_NIUQU_Tex("扭曲贴图", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_NIUQUONOFF("起始状态扭曲", Float) = 0
		[Enum(OFF,0,ON,1)]_Flowmap_IF_Effect_NIUQU("FlowMap贴图是否影响扭曲贴图", Float) = 1
		_NIUQU_Power("扭曲程度", Float) = 0
		_Niuqu_U_speed("扭曲贴图U方向流动速度", Float) = 0
		_Niuqu_V_speed("扭曲贴图V方向流动速度", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _tex4coord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite Off
		ZTest [_ZTestMode]
		Blend SrcAlpha [_Dst]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature _USE_DISSOLVE_ON
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float4 uv2_tex4coord2;
			float4 screenPos;
		};

		uniform half _Dst;
		uniform half _ZTestMode;
		uniform half _CullMode;
		uniform half4 _Maincolor;
		uniform sampler2D _maintex;
		uniform half _NIUQU_Power;
		uniform sampler2D _NIUQU_Tex;
		uniform half _Niuqu_U_speed;
		uniform half _Niuqu_V_speed;
		uniform float4 _NIUQU_Tex_ST;
		uniform sampler2D _FlowMap_Tex;
		uniform float4 _FlowMap_Tex_ST;
		uniform half _FlowMapOneScale;
		uniform half _FlowMapClamp;
		uniform half _FlowMap;
		uniform half _FlowMapSC;
		uniform half _DisspowerFlowmap;
		uniform half _DissSC;
		uniform half _Flowmap_MainOrDissolve;
		uniform half _Flowmap_IF_Effect_NIUQU;
		uniform half _NIUQUONOFF;
		uniform half _Main_U_Speed;
		uniform half _Main_V_Speed;
		uniform float4 _maintex_ST;
		uniform half _one_UV;
		uniform half _mainRotator;
		uniform half _MianClamp;
		uniform sampler2D _Gam;
		uniform float4 _Gam_ST;
		uniform half _Flowmap_IF_Effect_Gam;
		uniform half _GAMRotator;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform half _soft;
		uniform half _smooth;
		uniform sampler2D _DissovleTex;
		uniform half _Dissovle_U_speed;
		uniform half _Dissovle_V_speed;
		uniform float4 _DissovleTex_ST;
		uniform half _A_R;
		uniform sampler2D _MASKTEX;
		uniform half _MASK_u_speed;
		uniform half _MASK_v_speed;
		uniform float4 _MASKTEX_ST;
		uniform half _Flowmap_IF_Effect_Mask;
		uniform half _MASKRotator;
		uniform half _MaskClamp;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			half2 appendResult283 = (half2(_Niuqu_U_speed , _Niuqu_V_speed));
			float2 uv_NIUQU_Tex = i.uv_texcoord * _NIUQU_Tex_ST.xy + _NIUQU_Tex_ST.zw;
			float2 uv_FlowMap_Tex = i.uv_texcoord * _FlowMap_Tex_ST.xy + _FlowMap_Tex_ST.zw;
			half2 temp_cast_0 = (0.5).xx;
			half4 tex2DNode415 = tex2D( _FlowMap_Tex, ( ( ( uv_FlowMap_Tex - temp_cast_0 ) * _FlowMapOneScale ) + 0.5 ) );
			half2 appendResult416 = (half2(tex2DNode415.r , tex2DNode415.g));
			half2 lerpResult466 = lerp( appendResult416 , saturate( appendResult416 ) , _FlowMapClamp);
			half2 FlowMap_Tex_Append436 = lerpResult466;
			half V475 = i.uv2_tex4coord2.y;
			half lerpResult476 = lerp( _FlowMap , V475 , _FlowMapSC);
			half five300 = i.uv2_tex4coord2.x;
			half lerpResult351 = lerp( _DisspowerFlowmap , five300 , _DissSC);
			half DisspowerFlowmap431 = lerpResult351;
			half lerpResult428 = lerp( lerpResult476 , DisspowerFlowmap431 , _Flowmap_MainOrDissolve);
			half affected_by_the_FlowMap437 = lerpResult428;
			half lerpResult448 = lerp( 0.0 , affected_by_the_FlowMap437 , _Flowmap_IF_Effect_NIUQU);
			half2 lerpResult446 = lerp( uv_NIUQU_Tex , FlowMap_Tex_Append436 , lerpResult448);
			half2 panner286 = ( 1.0 * _Time.y * appendResult283 + lerpResult446);
			half lerpResult309 = lerp( 0.0 , ( _NIUQU_Power * (-0.5 + (tex2D( _NIUQU_Tex, panner286 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) , _NIUQUONOFF);
			half2 appendResult298 = (half2(( _Main_U_Speed * _Time.y ) , ( _Time.y * _Main_V_Speed )));
			float2 uv_maintex = i.uv_texcoord * _maintex_ST.xy + _maintex_ST.zw;
			half2 lerpResult418 = lerp( uv_maintex , lerpResult466 , lerpResult428);
			half2 FlowMap419 = lerpResult418;
			half2 appendResult301 = (half2(i.uv2_tex4coord2.z , i.uv2_tex4coord2.w));
			half2 lerpResult308 = lerp( ( appendResult298 + FlowMap419 ) , ( FlowMap419 + appendResult301 ) , _one_UV);
			half2 ONE214 = ( lerpResult309 + lerpResult308 );
			float cos321 = cos( ( ( _mainRotator * UNITY_PI ) / 180.0 ) );
			float sin321 = sin( ( ( _mainRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator321 = mul( ONE214 - float2( 0.5,0.5 ) , float2x2( cos321 , -sin321 , sin321 , cos321 )) + float2( 0.5,0.5 );
			half2 lerpResult411 = lerp( rotator321 , saturate( rotator321 ) , _MianClamp);
			half4 tex2DNode1 = tex2D( _maintex, lerpResult411 );
			float2 uv_Gam = i.uv_texcoord * _Gam_ST.xy + _Gam_ST.zw;
			half lerpResult433 = lerp( 0.0 , affected_by_the_FlowMap437 , _Flowmap_IF_Effect_Gam);
			half2 lerpResult430 = lerp( uv_Gam , FlowMap_Tex_Append436 , lerpResult433);
			float cos399 = cos( ( ( _GAMRotator * UNITY_PI ) / 180.0 ) );
			float sin399 = sin( ( ( _GAMRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator399 = mul( lerpResult430 - float2( 0.5,0.5 ) , float2x2( cos399 , -sin399 , sin399 , cos399 )) + float2( 0.5,0.5 );
			half4 Gam258 = tex2D( _Gam, rotator399 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			half4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth393 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half distanceDepth393 = abs( ( screenDepth393 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _soft ) );
			half soft219 = saturate( distanceDepth393 );
			half2 appendResult342 = (half2(_Dissovle_U_speed , _Dissovle_V_speed));
			float2 uv_DissovleTex = i.uv_texcoord * _DissovleTex_ST.xy + _DissovleTex_ST.zw;
			half2 panner346 = ( 1.0 * _Time.y * appendResult342 + uv_DissovleTex);
			half2 lerpResult417 = lerp( panner346 , FlowMap_Tex_Append436 , lerpResult351);
			half smoothstepResult368 = smoothstep( ( 1.0 - _smooth ) , _smooth , saturate( ( ( tex2D( _DissovleTex, lerpResult417 ).r + 1.0 ) - ( lerpResult351 * 2.0 ) ) ));
			#ifdef _USE_DISSOLVE_ON
				half staticSwitch371 = smoothstepResult368;
			#else
				half staticSwitch371 = 1.0;
			#endif
			half Three217 = staticSwitch371;
			o.Emission = ( i.vertexColor * _Maincolor * tex2DNode1 * Gam258 * soft219 * Three217 ).rgb;
			half lerpResult409 = lerp( tex2DNode1.r , tex2DNode1.a , _A_R);
			half2 appendResult332 = (half2(_MASK_u_speed , _MASK_v_speed));
			float2 uv_MASKTEX = i.uv_texcoord * _MASKTEX_ST.xy + _MASKTEX_ST.zw;
			half lerpResult442 = lerp( 0.0 , affected_by_the_FlowMap437 , _Flowmap_IF_Effect_Mask);
			half2 lerpResult444 = lerp( uv_MASKTEX , FlowMap_Tex_Append436 , lerpResult442);
			half2 panner334 = ( 1.0 * _Time.y * appendResult332 + lerpResult444);
			float cos335 = cos( ( ( _MASKRotator * UNITY_PI ) / 180.0 ) );
			float sin335 = sin( ( ( _MASKRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator335 = mul( panner334 - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
			half2 lerpResult413 = lerp( rotator335 , saturate( rotator335 ) , _MaskClamp);
			half two215 = tex2D( _MASKTEX, lerpResult413 ).r;
			o.Alpha = ( i.vertexColor.a * _Maincolor.a * lerpResult409 * Three217 * soft219 * two215 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;163;1656;856;2697.324;930.696;1.134104;True;True
Node;AmplifyShaderEditor.CommentaryNode;276;-4937.631,-1033.579;Inherit;False;2378.104;876.7546;扭曲;20;214;310;309;304;303;307;299;292;286;446;283;448;281;282;447;280;450;449;278;277;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;435;-4938.861,-143.3585;Inherit;False;1556.041;603.3998;FlowMap;31;466;464;465;436;432;419;437;463;461;428;427;429;416;415;418;460;459;458;457;425;424;471;472;473;474;476;477;478;479;480;484;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;277;-4315.874,-663.82;Inherit;False;1344.04;453.14;MainTexUV流动;15;308;306;305;302;301;300;298;293;289;288;287;285;284;422;475;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;461;-4915.152,156.6596;Inherit;False;Constant;_05;0.5;38;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-4299.667,-386.1805;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;463;-4715.854,151.2596;Inherit;False;Property;_FlowMapOneScale;FlowMapOneScale;26;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;336;-3550.347,473.907;Inherit;False;2030.024;534.6572;溶解;23;344;351;431;347;348;346;341;342;340;339;217;371;368;367;366;364;361;360;355;357;353;417;440;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-3758.97,-369.7005;Inherit;False;five;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;472;-4727.357,123.4219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;424;-4914.72,31.69801;Inherit;False;0;415;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;347;-3527.821,923.0944;Inherit;False;300;five;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-3527.64,843.2014;Inherit;False;Property;_DisspowerFlowmap;DisspowerFlowmap;32;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;473;-4540.256,140.7219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;458;-4702.349,38.01764;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;344;-3373.796,921.1439;Inherit;False;Property;_DissSC;Diss,S/C;30;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;351;-3235.921,877.3892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;471;-4545.354,220.9219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;-4571.349,38.01764;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;475;-3995.373,-387.8061;Inherit;False;V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;427;-4922.616,233.6508;Inherit;False;Property;_FlowMap;FlowMap;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;-2854.77,836.8163;Inherit;False;DisspowerFlowmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;460;-4446.749,39.81763;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;478;-4714.729,304.8087;Inherit;False;475;V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;415;-4326.668,-4.00618;Inherit;True;Property;_FlowMap_Tex;FlowMap_Tex;22;1;[Header];Create;True;1;FlowMap;0;0;False;0;False;-1;None;01f4d771177ed4e4c97217b4a0e1a64f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;432;-4924.512,307.8896;Inherit;False;431;DisspowerFlowmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;479;-4531.829,279.7086;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;477;-4691.364,382.5854;Inherit;False;Property;_FlowMapSC;FlowMap,S/C;23;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-4923.497,383.0394;Inherit;False;Property;_Flowmap_MainOrDissolve;Flowmap_MainOrDissolve;25;1;[Enum];Create;True;0;2;Maintex_flowmap;0;Dissolve_flowmap;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;416;-4050.878,24.30534;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;476;-4471.594,271.231;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;480;-4526.628,343.4085;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;464;-4321.947,189.6065;Inherit;False;Property;_FlowMapClamp;FlowMapClamp;24;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;484;-4332.929,395.4083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;465;-3983.617,162.5062;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;474;-4090.356,196.2218;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;428;-4292.023,271.8152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;437;-3995.909,272.077;Inherit;False;affected_by_the_FlowMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;466;-3873.131,20.78668;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;436;-3606.265,137.1118;Inherit;False;FlowMap_Tex_Append;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-4910.362,-782.1879;Inherit;False;437;affected_by_the_FlowMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;450;-4911.16,-705.5963;Inherit;False;Property;_Flowmap_IF_Effect_NIUQU;Flowmap_IF_Effect_NIUQU;37;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-4910.482,-857.9376;Inherit;False;436;FlowMap_Tex_Append;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;448;-4596.088,-776.7297;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-4908.665,-624.3407;Inherit;False;Property;_Niuqu_U_speed;Niuqu_U_speed;39;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-4909.344,-548.2522;Inherit;False;Property;_Niuqu_V_speed;Niuqu_V_speed;40;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-4909.345,-994.0363;Inherit;False;0;292;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;425;-4912.173,-95.02306;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;446;-4426.391,-873.8831;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;283;-4585.471,-621.6341;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;457;-4089.608,139.6615;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-4280.167,-625.4118;Inherit;False;Property;_Main_U_Speed;Main_U_Speed;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-4280.159,-481.0041;Inherit;False;Property;_Main_V_Speed;Main_V_Speed;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;418;-3708.116,-88.91148;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;286;-4210.51,-876.2539;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;287;-4273.766,-553.27;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-3952.324,-516.0441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;311;-3371.666,-144.5366;Inherit;False;1842.784;605.6085;MASK;23;470;468;467;324;333;323;322;334;332;444;331;330;329;442;445;443;441;413;325;414;215;327;335;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;-3569.349,-96.16742;Inherit;False;FlowMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-3523.229,749.1663;Inherit;False;Property;_Dissovle_V_speed;Dissovle_V_speed;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;292;-3954.932,-906.0185;Inherit;True;Property;_NIUQU_Tex;NIUQU_Tex;35;1;[Header];Create;True;1;NIUQU_Tex;0;0;False;0;False;-1;None;57fc63bb8bc7c544cb00701f0bcb1c85;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;340;-3522.302,662.9865;Inherit;False;Property;_Dissovle_U_speed;Dissovle_U_speed;33;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-3952.146,-618.2061;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;278;-3656.37,-924.0062;Inherit;False;184.726;214.7941;映射;1;296;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;-3598.996,-556.7252;Inherit;False;419;FlowMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-2937.894,128.0213;Inherit;False;Property;_MASKRotator;MASKRotator;19;0;Create;True;0;0;0;False;0;False;0;90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;301;-3996.868,-315.9207;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;342;-3317.384,658.271;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;298;-3759.501,-619.0433;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-3834.688,-982.1467;Inherit;False;Property;_NIUQU_Power;NIUQU_Power;38;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;296;-3641.51,-877.3352;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;341;-3526.377,542.3536;Inherit;False;0;353;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;304;-3371.294,-805.497;Inherit;False;Property;_NIUQUONOFF;NIUQU,ON/OFF;36;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;-3339.827,-615.782;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-3340.712,-524.1705;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;333;-2759.178,132.6899;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;323;-2933.622,201.7104;Inherit;False;Constant;_Float11;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-3352.548,348.1485;Inherit;False;Property;_Flowmap_IF_Effect_Mask;Flowmap_IF_Effect_Mask;18;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-3352.634,-426.1884;Inherit;False;Property;_one_UV;one_UV;7;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;-3315.442,756.8789;Inherit;False;436;FlowMap_Tex_Append;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;346;-3176.011,558.5854;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-3325.162,-978.3444;Inherit;False;Constant;_Float4;Float 4;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-3327.525,-900.3746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;443;-3351.75,270.519;Inherit;False;437;affected_by_the_FlowMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;308;-3123.329,-616.3024;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-3353.381,113.303;Inherit;False;Property;_MASK_u_speed;MASK_u_speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;442;-3088.302,283.5014;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;417;-2961.83,559.5477;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-3353.73,188.4052;Inherit;False;Property;_MASK_v_speed;MASK_v_speed;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-2544.264,132.6387;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;445;-3354.118,33.3651;Inherit;False;436;FlowMap_Tex_Append;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;331;-3352.924,-88.52345;Inherit;False;0;327;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;309;-3114.666,-921.9847;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;312;-2542.155,-421.0508;Inherit;False;678.2278;263.7631;主贴图旋转;6;319;316;318;317;320;321;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-2932.906,-922.8467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;467;-2455.093,98.71532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;332;-3171.098,127.7565;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-2511.146,-311.8625;Inherit;False;Property;_mainRotator;mainRotator;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;380;-4941.879,477.3406;Inherit;False;1383.157;531.6082;Gam;13;381;396;385;433;389;434;438;258;406;399;430;439;391;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;353;-2814.326,530.9462;Inherit;True;Property;_DissovleTex;DissovleTex;28;1;[Header];Create;True;1;DissovleTex;0;0;False;0;False;-1;None;28c7aad1372ff114b90d330f8a2dd938;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;444;-2976.458,-83.53519;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;317;-2345.519,-307.0025;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;318;-2516.14,-229.3846;Inherit;False;Constant;_Float6;Float 6;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;468;-2615.517,75.79755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-4922.29,736.8781;Inherit;False;Property;_GAMRotator;GAMRotator;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-4924.96,890.7248;Inherit;False;Property;_Flowmap_IF_Effect_Gam;Flowmap_IF_Effect_Gam;14;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;355;-2518.519,611.3415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-2652.841,722.9391;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;-4924.162,814.1335;Inherit;False;437;affected_by_the_FlowMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-2777.283,-928.9197;Inherit;False;ONE;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;334;-2759.014,-84.13071;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;360;-2394.927,610.3541;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;389;-4755.947,738.5566;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;335;-2570.723,-85.80065;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-4508.436,865.0942;Inherit;False;Constant;_Float12;Float 12;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;433;-4660.715,827.1155;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-4922.186,657.7767;Inherit;False;436;FlowMap_Tex_Append;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;320;-2162.392,-307.2361;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-2515.629,-384.7321;Inherit;False;214;ONE;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;414;-2400.69,68.70184;Inherit;False;Property;_MaskClamp;MaskClamp;17;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;391;-4927.571,524.3257;Inherit;False;0;406;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;384;-2538.756,-577.6961;Inherit;False;996.5168;146.8058;软粒子;4;219;400;393;388;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-2655.615,824.6356;Inherit;False;Property;_smooth;smooth;31;0;Create;True;0;0;0;False;0;False;0.6134824;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;470;-2236.813,53.14013;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;321;-2036.34,-353.4884;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;366;-2265.079,610.2092;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;272;-1855.603,-419.7483;Inherit;False;317.8248;263.5372;Clamp;3;314;411;412;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;430;-4358.397,545.964;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;325;-2379.934,-0.840762;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-2524.482,-510.9641;Inherit;False;Property;_soft;soft;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;364;-2433.394,718.5672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;396;-4354.361,741.8439;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;314;-1836.32,-352.4439;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;412;-1839.255,-241.1272;Inherit;False;Property;_MianClamp;MianClamp;8;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-2517.167,533.0721;Inherit;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;413;-2212.358,-84.0721;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;399;-4208.411,547.4925;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;368;-2113.91,609.9672;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;393;-2343.649,-530.3383;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;411;-1682.778,-375.5225;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;406;-4024.247,520.5123;Inherit;True;Property;_Gam;Gam;13;1;[Header];Create;True;1;GAM;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;371;-1956.297,531.6579;Inherit;False;Property;_use_dissolve;use_dissolve;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;400;-2035.889,-529.7325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;327;-2057.665,-111.8494;Inherit;True;Property;_MASKTEX;MASKTEX;16;1;[Header];Create;True;1;MASKTEX;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1727.156,-535.9631;Inherit;False;soft;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-3744.527,519.8174;Inherit;False;Gam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-1730.116,530.7951;Inherit;False;Three;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-1742.387,-89.39953;Inherit;False;two;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1489.375,-406.9633;Inherit;True;Property;_maintex;maintex;4;1;[Header];Create;True;1;MainTex;0;0;False;0;False;-1;None;0dc4b49a234a87244bd5bdd037b4dec1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;141;-635.0582,-304.0469;Inherit;False;468.0941;422.9443;ALPHA模式连到不透明度，ADD模式连到Emission;5;137;218;216;220;257;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-1489.133,-210.7649;Inherit;False;Property;_A_R;A_R;6;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-615.0594,-123.8334;Inherit;False;217;Three;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-617.3322,38.54305;Inherit;False;215;two;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-612.0948,-207.8759;Inherit;False;258;Gam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;3;-1364.387,-767.7239;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-1407.452,-589.9687;Inherit;False;Property;_Maincolor;Maincolor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;220;-615.1384,-44.42738;Inherit;False;219;soft;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;409;-1133.876,-355.0029;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;232.5842,-469.7425;Inherit;False;Property;_Dst;材质模式;2;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-307.1711,-267.0597;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;239.8492,-297.8818;Inherit;False;Property;_ZTestMode;深度测试;1;1;[Enum];Create;False;0;2;Less or Equal;4;Always;8;0;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;235.069,-383.7109;Inherit;False;Property;_CullMode;剔除模式;3;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-308.3711,-506.7667;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5.423859,-468.2598;Half;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;LTY/ShaderNew/Flowmap;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;-1;1;True;238;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;True;135;0;0;False;-1;0;False;-1;0;True;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;True;142;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;300;0;288;1
WireConnection;472;0;461;0
WireConnection;473;0;463;0
WireConnection;458;0;424;0
WireConnection;458;1;472;0
WireConnection;351;0;348;0
WireConnection;351;1;347;0
WireConnection;351;2;344;0
WireConnection;471;0;461;0
WireConnection;459;0;458;0
WireConnection;459;1;473;0
WireConnection;475;0;288;2
WireConnection;431;0;351;0
WireConnection;460;0;459;0
WireConnection;460;1;471;0
WireConnection;415;1;460;0
WireConnection;479;0;427;0
WireConnection;416;0;415;1
WireConnection;416;1;415;2
WireConnection;476;0;479;0
WireConnection;476;1;478;0
WireConnection;476;2;477;0
WireConnection;480;0;432;0
WireConnection;484;0;429;0
WireConnection;465;0;416;0
WireConnection;474;0;464;0
WireConnection;428;0;476;0
WireConnection;428;1;480;0
WireConnection;428;2;484;0
WireConnection;437;0;428;0
WireConnection;466;0;416;0
WireConnection;466;1;465;0
WireConnection;466;2;474;0
WireConnection;436;0;466;0
WireConnection;448;1;449;0
WireConnection;448;2;450;0
WireConnection;446;0;282;0
WireConnection;446;1;447;0
WireConnection;446;2;448;0
WireConnection;283;0;281;0
WireConnection;283;1;280;0
WireConnection;457;0;428;0
WireConnection;418;0;425;0
WireConnection;418;1;466;0
WireConnection;418;2;457;0
WireConnection;286;0;446;0
WireConnection;286;2;283;0
WireConnection;289;0;287;0
WireConnection;289;1;285;0
WireConnection;419;0;418;0
WireConnection;292;1;286;0
WireConnection;293;0;284;0
WireConnection;293;1;287;0
WireConnection;301;0;288;3
WireConnection;301;1;288;4
WireConnection;342;0;340;0
WireConnection;342;1;339;0
WireConnection;298;0;293;0
WireConnection;298;1;289;0
WireConnection;296;0;292;1
WireConnection;305;0;298;0
WireConnection;305;1;422;0
WireConnection;302;0;422;0
WireConnection;302;1;301;0
WireConnection;333;0;322;0
WireConnection;346;0;341;0
WireConnection;346;2;342;0
WireConnection;307;0;299;0
WireConnection;307;1;296;0
WireConnection;308;0;305;0
WireConnection;308;1;302;0
WireConnection;308;2;306;0
WireConnection;442;1;443;0
WireConnection;442;2;441;0
WireConnection;417;0;346;0
WireConnection;417;1;440;0
WireConnection;417;2;351;0
WireConnection;324;0;333;0
WireConnection;324;1;323;0
WireConnection;309;0;303;0
WireConnection;309;1;307;0
WireConnection;309;2;304;0
WireConnection;310;0;309;0
WireConnection;310;1;308;0
WireConnection;467;0;324;0
WireConnection;332;0;330;0
WireConnection;332;1;329;0
WireConnection;353;1;417;0
WireConnection;444;0;331;0
WireConnection;444;1;445;0
WireConnection;444;2;442;0
WireConnection;317;0;316;0
WireConnection;468;0;467;0
WireConnection;355;0;353;1
WireConnection;357;0;351;0
WireConnection;214;0;310;0
WireConnection;334;0;444;0
WireConnection;334;2;332;0
WireConnection;360;0;355;0
WireConnection;360;1;357;0
WireConnection;389;0;381;0
WireConnection;335;0;334;0
WireConnection;335;2;468;0
WireConnection;433;1;438;0
WireConnection;433;2;434;0
WireConnection;320;0;317;0
WireConnection;320;1;318;0
WireConnection;470;0;414;0
WireConnection;321;0;319;0
WireConnection;321;2;320;0
WireConnection;366;0;360;0
WireConnection;430;0;391;0
WireConnection;430;1;439;0
WireConnection;430;2;433;0
WireConnection;325;0;335;0
WireConnection;364;0;361;0
WireConnection;396;0;389;0
WireConnection;396;1;385;0
WireConnection;314;0;321;0
WireConnection;413;0;335;0
WireConnection;413;1;325;0
WireConnection;413;2;470;0
WireConnection;399;0;430;0
WireConnection;399;2;396;0
WireConnection;368;0;366;0
WireConnection;368;1;364;0
WireConnection;368;2;361;0
WireConnection;393;0;388;0
WireConnection;411;0;321;0
WireConnection;411;1;314;0
WireConnection;411;2;412;0
WireConnection;406;1;399;0
WireConnection;371;1;367;0
WireConnection;371;0;368;0
WireConnection;400;0;393;0
WireConnection;327;1;413;0
WireConnection;219;0;400;0
WireConnection;258;0;406;0
WireConnection;217;0;371;0
WireConnection;215;0;327;1
WireConnection;1;1;411;0
WireConnection;409;0;1;1
WireConnection;409;1;1;4
WireConnection;409;2;410;0
WireConnection;137;0;3;4
WireConnection;137;1;2;4
WireConnection;137;2;409;0
WireConnection;137;3;218;0
WireConnection;137;4;220;0
WireConnection;137;5;216;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;4;2;1;0
WireConnection;4;3;257;0
WireConnection;4;4;220;0
WireConnection;4;5;218;0
WireConnection;0;2;4;0
WireConnection;0;9;137;0
ASEEND*/
//CHKSM=4B283C2BF6742848248D35DB5CDB50C50C4E5CB9