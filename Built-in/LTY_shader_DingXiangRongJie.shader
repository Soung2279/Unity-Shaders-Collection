// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/进阶功能/定向溶解和极坐标(旧版无GUI)_RongJieSD"
{
	Properties
	{
		_WebSite("此Shader教程网址:www.magesbox.com/article/detail/id/1963.html", Int) = 1963
		[Header(__________________________________________________________________________________________)]
		[Enum(Less or Equal,4,Always,8)]_ZTestMode("深度测试", Float) = 4
		[Enum(AlphaBlend,10,Additive,1)]_Dst("材质模式", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("剔除模式", Float) = 0
		[Header(MainTex)]_maintex("主贴图", 2D) = "white" {}
		[HDR]_Maincolor("主贴图颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_A_R("主贴图通道", Float) = 0
		[Enum(OFF,0,ON,1)]_one_UV("是否使用粒子控制UV", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_MianClamp("是否主贴图重铺", Float) = 0
		_soft("物体刚度", Float) = 0
		_mainRotator("主贴图旋转", Float) = 0
		_Main_U_Speed("主贴图U方向持续流动", Float) = 0
		_Main_V_Speed("主贴图V方向持续流动", Float) = 0
		[Header(GAM)]_Gam("颜色叠加", 2D) = "white" {}
		_GAMRotator("颜色叠加贴图旋转", Float) = 0
		_Gam_u_speed("颜色叠加U方向持续流动", Float) = 0
		_Gam_v_speed("颜色叠加V方向持续流动", Float) = 0
		[Header(MASKTEX)]_MASKTEX("遮罩贴图", 2D) = "white" {}
		[Enum(Repeat,0,Clmap,1)]_MaskClamp("是否重铺遮罩贴图", Float) = 0
		_MASKRotator("遮罩贴图旋转", Float) = 0
		_MASK_u_speed("遮罩贴图U方向持续流动", Float) = 0
		_MASK_v_speed("遮罩贴图V方向持续流动", Float) = 0
		[Header(NIUQU_Tex)]_NIUQU_Tex("扭曲贴图", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_NIUQUONOFF("起始状态扭曲", Float) = 0
		_NIUQU_Power("扭曲速度", Float) = 0
		_Niuqu_U_speed("扭曲U方向持续流动", Float) = 0
		_Niuqu_V_speed("扭曲V方向持续流动", Float) = 0
		[Header(DissloveTexPlus_JiZuoBiao)][Enum(Normal,0,JiZuoBiao,1)]_DissolveJiZuoBiao("溶解贴图UV模式", Float) = 0
		_ScaleOffset("ScaleOffset", Vector) = (1,1,0,0)
		_Jizuobiao_U_Speed("极坐标模式U方向持续流动", Float) = 0
		_Jizuobiao_V_Speed("极坐标模式V方向持续流动", Float) = 0
		[Header(Disslove)]_DissolveTex("溶解贴图", 2D) = "white" {}
		_DissolveTexRotator("溶解贴图旋转", Float) = 0
		[Toggle]_CustomdataDis("是否粒子控制溶解贴图", Float) = 0
		[Enum(R,0,A,1)]_DissolveRA("溶解贴图通道", Float) = 0
		[Enum(ON,0,OFF,1)]_Use_Disslove("是否使用溶解", Float) = 0
		_DissolvePower("数值溶解程度", Range( 0 , 2)) = 0
		_DissolveSmooth("溶解平滑度", Range( 0 , 1)) = 0
		_DissolveTexDivide("定向溶解强度", Range( 1 , 7)) = 1
		_DissolveTex_u_speed("定向溶解U方向持续流动", Float) = 0
		_DissolveTex_v_speed("定向溶解V方向持续流动", Float) = 0
		[Enum(Disslove,0,MiaoBian,1)]_Use_MiaoBian("是否描边溶解", Float) = 1
		[HDR]_DissloveEdgeColor("描边颜色", Color) = (1,1,1,1)
		_DissolveEdgeWide("描边宽度", Range( 0 , 1)) = 0.05727924
		[Header(DissloveTexPlus)][Enum(OFF,0,ON,1)]_IFDirectionalDissolve("是否开启附加贴图", Float) = 1
		[Enum(OFF,0,ON,1)]_OneScale("是否开启一次性放大缩小", Float) = 1
		[Enum(OFF,0,ON,1)]_CustomSacle("CustomSacle", Float) = 0
		_Scale("一次性放大数值", Float) = 1
		_DissloveTexPlus("定向溶解贴图", 2D) = "white" {}
		_DissolveTexPlus_Rotator("定向溶解贴图旋转", Float) = 0
		[Enum(Repeat,0,Clmap,1)]_DissloveTexClamp("定向溶解重铺模式", Float) = 0
		[Enum(R,0,A,1)]_DissolveTexPlusRA("定向溶解贴图通道", Float) = 0
		_DissolveTexPlus_u_speed("定向溶解U方向流动速度", Float) = 0
		_DissolveTexPlus_v_speed("定向溶解V方向流动速度", Float) = 0
		[Header(DissovleSTex)]_DissovleSTex("溶解溶解结果贴图", 2D) = "white" {}
		[Enum(R,0,A,1)]_DissovleSA_R("切换溶解溶解结果贴图通道", Float) = 0
		_DissSpower("溶解溶解数值", Range( 0 , 1)) = 0
		_DissovleSsmooth("溶解柔和度", Range( 0.5 , 1)) = 0.5
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
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 uv2_tex4coord2;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
		};

		uniform half _Dst;
		uniform half _ZTestMode;
		uniform half _CullMode;
		uniform half _CustomdataDis;
		uniform half _DissolvePower;
		uniform half _DissolveSmooth;
		uniform sampler2D _DissolveTex;
		uniform half _DissolveTex_u_speed;
		uniform half _DissolveTex_v_speed;
		uniform float4 _DissolveTex_ST;
		uniform half _DissolveTexRotator;
		uniform half4 _ScaleOffset;
		uniform half _Jizuobiao_U_Speed;
		uniform half _Jizuobiao_V_Speed;
		uniform half _DissolveJiZuoBiao;
		uniform half _DissolveRA;
		uniform sampler2D _DissloveTexPlus;
		uniform half _DissolveTexPlus_u_speed;
		uniform half _DissolveTexPlus_v_speed;
		uniform float4 _DissloveTexPlus_ST;
		uniform half _Scale;
		uniform half _CustomSacle;
		uniform half _OneScale;
		uniform half _DissolveTexPlus_Rotator;
		uniform half _DissloveTexClamp;
		uniform half _DissolveTexPlusRA;
		uniform half _IFDirectionalDissolve;
		uniform half _DissolveTexDivide;
		uniform half4 _DissloveEdgeColor;
		uniform half _DissolveEdgeWide;
		uniform half _Use_MiaoBian;
		uniform half _Use_Disslove;
		uniform sampler2D _maintex;
		uniform half _Main_U_Speed;
		uniform half _Main_V_Speed;
		uniform float4 _maintex_ST;
		uniform half _one_UV;
		uniform half _NIUQU_Power;
		uniform sampler2D _NIUQU_Tex;
		uniform half _Niuqu_U_speed;
		uniform half _Niuqu_V_speed;
		uniform float4 _NIUQU_Tex_ST;
		uniform half _NIUQUONOFF;
		uniform half _mainRotator;
		uniform half _MianClamp;
		uniform half4 _Maincolor;
		uniform sampler2D _Gam;
		uniform half _Gam_u_speed;
		uniform half _Gam_v_speed;
		uniform float4 _Gam_ST;
		uniform half _GAMRotator;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform half _soft;
		uniform half _A_R;
		uniform sampler2D _MASKTEX;
		uniform half _MASK_u_speed;
		uniform half _MASK_v_speed;
		uniform float4 _MASKTEX_ST;
		uniform half _MASKRotator;
		uniform half _MaskClamp;
		uniform half _DissovleSsmooth;
		uniform sampler2D _DissovleSTex;
		uniform float4 _DissovleSTex_ST;
		uniform half _DissovleSA_R;
		uniform half _DissSpower;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			half2 appendResult550 = (half2(_DissolveTex_u_speed , _DissolveTex_v_speed));
			float2 uv_DissolveTex = i.uv_texcoord * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
			half2 panner552 = ( 1.0 * _Time.y * appendResult550 + uv_DissolveTex);
			float cos694 = cos( ( ( _DissolveTexRotator * UNITY_PI ) / 180.0 ) );
			float sin694 = sin( ( ( _DissolveTexRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator694 = mul( panner552 - float2( 0.5,0.5 ) , float2x2( cos694 , -sin694 , sin694 , cos694 )) + float2( 0.5,0.5 );
			half2 temp_output_677_0 = (uv_DissolveTex*2.0 + -1.0);
			half2 break678 = temp_output_677_0;
			half2 appendResult685 = (half2(pow( length( temp_output_677_0 ) , 1.0 ) , ( ( atan2( break678.y , break678.x ) / ( 2.0 * UNITY_PI ) ) + 0.5 )));
			half2 appendResult688 = (half2(_ScaleOffset.x , _ScaleOffset.y));
			half2 appendResult689 = (half2(_ScaleOffset.z , _ScaleOffset.w));
			half2 appendResult699 = (half2(( _Jizuobiao_U_Speed * _Time.y ) , ( _Time.y * _Jizuobiao_V_Speed )));
			half2 lerpResult691 = lerp( rotator694 , ( (appendResult685*appendResult688 + appendResult689) + appendResult699 ) , _DissolveJiZuoBiao);
			half4 tex2DNode512 = tex2D( _DissolveTex, lerpResult691 );
			half lerpResult560 = lerp( tex2DNode512.r , tex2DNode512.a , _DissolveRA);
			half2 appendResult555 = (half2(_DissolveTexPlus_u_speed , _DissolveTexPlus_v_speed));
			float2 uv_DissloveTexPlus = i.uv_texcoord * _DissloveTexPlus_ST.xy + _DissloveTexPlus_ST.zw;
			half2 temp_cast_0 = (0.5).xx;
			half five300 = i.uv2_tex4coord2.y;
			half lerpResult735 = lerp( _Scale , ( five300 + 1.0 ) , _CustomSacle);
			half2 lerpResult724 = lerp( uv_DissloveTexPlus , ( ( ( uv_DissloveTexPlus - temp_cast_0 ) * lerpResult735 ) + 0.5 ) , _OneScale);
			half2 panner556 = ( 1.0 * _Time.y * appendResult555 + lerpResult724);
			float cos580 = cos( ( ( _DissolveTexPlus_Rotator * UNITY_PI ) / 180.0 ) );
			float sin580 = sin( ( ( _DissolveTexPlus_Rotator * UNITY_PI ) / 180.0 ) );
			half2 rotator580 = mul( panner556 - float2( 0.5,0.5 ) , float2x2( cos580 , -sin580 , sin580 , cos580 )) + float2( 0.5,0.5 );
			half2 lerpResult728 = lerp( rotator580 , saturate( rotator580 ) , _DissloveTexClamp);
			half4 tex2DNode513 = tex2D( _DissloveTexPlus, lerpResult728 );
			half lerpResult558 = lerp( tex2DNode513.r , tex2DNode513.a , _DissolveTexPlusRA);
			half lerpResult669 = lerp( lerpResult560 , lerpResult558 , _IFDirectionalDissolve);
			half temp_output_528_0 = saturate( ( ( lerpResult669 + ( lerpResult560 / _DissolveTexDivide ) ) / 2.0 ) );
			half smoothstepResult529 = smoothstep( ( (( _CustomdataDis )?( i.uv2_tex4coord2.x ):( _DissolvePower )) - _DissolveSmooth ) , (( _CustomdataDis )?( i.uv2_tex4coord2.x ):( _DissolvePower )) , temp_output_528_0);
			half4 temp_cast_1 = (smoothstepResult529).xxxx;
			half4 lerpResult656 = lerp( temp_cast_1 , ( smoothstepResult529 + ( _DissloveEdgeColor * ( step( ( (( _CustomdataDis )?( i.uv2_tex4coord2.x ):( _DissolvePower )) - _DissolveEdgeWide ) , temp_output_528_0 ) - step( (( _CustomdataDis )?( i.uv2_tex4coord2.x ):( _DissolvePower )) , temp_output_528_0 ) ) ) ) , _Use_MiaoBian);
			half4 temp_cast_2 = (1.0).xxxx;
			half4 lerpResult596 = lerp( lerpResult656 , temp_cast_2 , _Use_Disslove);
			half3 appendResult660 = (half3(lerpResult596.rgb));
			half3 Three217 = appendResult660;
			half2 appendResult298 = (half2(( _Main_U_Speed * _Time.y ) , ( _Time.y * _Main_V_Speed )));
			float2 uv_maintex = i.uv_texcoord * _maintex_ST.xy + _maintex_ST.zw;
			half2 appendResult301 = (half2(i.uv2_tex4coord2.z , i.uv2_tex4coord2.w));
			half2 lerpResult308 = lerp( ( appendResult298 + uv_maintex ) , ( uv_maintex + appendResult301 ) , _one_UV);
			half2 appendResult283 = (half2(_Niuqu_U_speed , _Niuqu_V_speed));
			float2 uv_NIUQU_Tex = i.uv_texcoord * _NIUQU_Tex_ST.xy + _NIUQU_Tex_ST.zw;
			half2 panner286 = ( 1.0 * _Time.y * appendResult283 + uv_NIUQU_Tex);
			half lerpResult309 = lerp( 0.0 , ( _NIUQU_Power * (-0.5 + (tex2D( _NIUQU_Tex, panner286 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) ) , _NIUQUONOFF);
			half2 ONE214 = ( lerpResult308 + lerpResult309 );
			float cos321 = cos( ( ( _mainRotator * UNITY_PI ) / 180.0 ) );
			float sin321 = sin( ( ( _mainRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator321 = mul( ONE214 - float2( 0.5,0.5 ) , float2x2( cos321 , -sin321 , sin321 , cos321 )) + float2( 0.5,0.5 );
			half2 lerpResult411 = lerp( rotator321 , saturate( rotator321 ) , _MianClamp);
			half4 tex2DNode1 = tex2D( _maintex, lerpResult411 );
			half2 appendResult601 = (half2(_Gam_u_speed , _Gam_v_speed));
			float2 uv_Gam = i.uv_texcoord * _Gam_ST.xy + _Gam_ST.zw;
			half2 panner602 = ( 1.0 * _Time.y * appendResult601 + uv_Gam);
			float cos399 = cos( ( ( _GAMRotator * UNITY_PI ) / 180.0 ) );
			float sin399 = sin( ( ( _GAMRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator399 = mul( panner602 - float2( 0.5,0.5 ) , float2x2( cos399 , -sin399 , sin399 , cos399 )) + float2( 0.5,0.5 );
			half4 Gam258 = tex2D( _Gam, rotator399 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			half4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth393 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half distanceDepth393 = abs( ( screenDepth393 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _soft ) );
			half soft219 = saturate( distanceDepth393 );
			o.Emission = ( half4( Three217 , 0.0 ) * ( tex2DNode1 * _Maincolor * i.vertexColor ) * Gam258 * soft219 ).rgb;
			half lerpResult409 = lerp( tex2DNode1.r , tex2DNode1.a , _A_R);
			half2 appendResult332 = (half2(_MASK_u_speed , _MASK_v_speed));
			float2 uv_MASKTEX = i.uv_texcoord * _MASKTEX_ST.xy + _MASKTEX_ST.zw;
			half2 panner334 = ( 1.0 * _Time.y * appendResult332 + uv_MASKTEX);
			float cos335 = cos( ( ( _MASKRotator * UNITY_PI ) / 180.0 ) );
			float sin335 = sin( ( ( _MASKRotator * UNITY_PI ) / 180.0 ) );
			half2 rotator335 = mul( panner334 - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
			half2 lerpResult413 = lerp( rotator335 , saturate( rotator335 ) , _MaskClamp);
			half two215 = tex2D( _MASKTEX, lerpResult413 ).r;
			half Three1661 = (lerpResult596).a;
			float2 uv_DissovleSTex = i.uv_texcoord * _DissovleSTex_ST.xy + _DissovleSTex_ST.zw;
			half4 tex2DNode743 = tex2D( _DissovleSTex, uv_DissovleSTex );
			half lerpResult751 = lerp( tex2DNode743.r , tex2DNode743.a , _DissovleSA_R);
			half smoothstepResult761 = smoothstep( ( 1.0 - _DissovleSsmooth ) , _DissovleSsmooth , saturate( ( ( lerpResult751 + 1.0 ) - ( _DissSpower * 2.0 ) ) ));
			o.Alpha = ( i.vertexColor.a * _Maincolor.a * lerpResult409 * soft219 * two215 * Three1661 * smoothstepResult761 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
1986;99;1656;856;5465.667;-114.4281;4.796343;True;True
Node;AmplifyShaderEditor.CommentaryNode;277;-3631.951,-297.5521;Inherit;False;1354.221;449.7465;UV流动;15;214;308;302;306;305;300;301;298;297;293;289;288;284;287;285;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;668;-4739.222,682.256;Inherit;False;4675.539;2137.225;Comment;13;598;597;596;737;676;656;657;655;675;674;693;673;672;定向溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-3605.563,-19.91314;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;672;-4697.84,1649.792;Inherit;False;1011.51;481.8318;Comment;10;694;552;695;698;696;550;548;697;549;551;溶解UV流动;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;673;-3675.412,1641.857;Inherit;False;2314.051;489.9723;Comment;27;558;559;513;728;730;729;580;573;556;571;555;569;724;554;553;723;566;726;716;721;735;722;715;736;734;557;731;定向溶解采样贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-3393.502,-17.56817;Inherit;False;five;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;693;-4698.494,809.0233;Inherit;False;1835.52;815.9932;Comment;23;691;692;705;699;690;700;703;688;689;685;686;706;701;684;687;704;683;682;681;679;680;678;677;极坐标;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;551;-4292.257,1690.113;Inherit;False;0;512;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;731;-3505.134,1899.227;Inherit;False;300;five;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;557;-3648.122,1699.634;Inherit;False;0;513;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;677;-4648.493,1004.022;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;734;-3651.185,1905.329;Inherit;False;Property;_CustomSacle;CustomSacle;46;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;715;-3516.609,1823.443;Inherit;False;Property;_Scale;Scale;47;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;722;-3652.615,1823.599;Inherit;False;Constant;_Float8;Float 8;54;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;736;-3352.673,1901.959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;678;-4455.49,1071.021;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;735;-3240.706,1862.193;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;721;-3413.202,1731.025;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ATan2OpNode;679;-4244.49,1067.021;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;680;-4219.491,1273.02;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;716;-3278.354,1730.753;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;682;-4243.616,987.447;Inherit;False;Constant;_Exp;Exp;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;553;-3658.184,1984.406;Inherit;False;Property;_DissolveTexPlus_u_speed;DissolveTexPlus_u_speed;52;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;681;-4021.493,1158.02;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;-3659.988,2060.929;Inherit;False;Property;_DissolveTexPlus_v_speed;DissolveTexPlus_v_speed;53;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;566;-3105.527,1981.25;Inherit;False;Property;_DissolveTexPlus_Rotator;DissolveTexPlus_Rotator;49;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;683;-4426.49,859.0231;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;726;-3098.283,1827.621;Inherit;False;Property;_OneScale;OneScale;45;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;723;-3141.84,1732.125;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;687;-4027.239,988.379;Half;False;Property;_ScaleOffset;ScaleOffset;28;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;549;-4647.84,1791.009;Inherit;False;Property;_DissolveTex_v_speed;DissolveTex_v_speed;40;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;555;-3393.395,2032.385;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;724;-2964.83,1707.667;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;686;-3891.478,1159.431;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;697;-4657.472,1864.823;Inherit;False;Property;_DissolveTexRotator;DissolveTexRotator;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;701;-3668.483,1250.435;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;704;-3674.875,1322.7;Inherit;False;Property;_Jizuobiao_V_Speed;Jizuobiao_V_Speed;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;569;-3104.788,2058.486;Inherit;False;Constant;_Float3;Float 3;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;571;-2854.485,1987.692;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;548;-4647.488,1715.906;Inherit;False;Property;_DissolveTex_u_speed;DissolveTex_u_speed;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;706;-3666.952,1178.778;Inherit;False;Property;_Jizuobiao_U_Speed;Jizuobiao_U_Speed;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;684;-4104.949,862.2661;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;685;-3866.819,862.8911;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;689;-3717.771,1059.696;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;696;-4426.866,1871.333;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;550;-4420.21,1730.36;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;698;-4658.725,1938.513;Inherit;False;Constant;_Float5;Float 5;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;573;-2674.65,1988.901;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;688;-3835.268,1013.335;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;703;-3421.074,1196.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;556;-2812.253,1710.998;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;700;-3421.25,1298.262;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;580;-2638.733,1711.127;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;552;-4067.66,1696.738;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;699;-3274.364,1225.299;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;695;-4258.478,1870.594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;690;-3682.477,866.283;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;694;-3871.648,1695.423;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;705;-3455.458,859.4581;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;729;-2460.758,1844.951;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;692;-3256.07,942.756;Inherit;False;Property;_DissolveJiZuoBiao;DissolveJiZuoBiao;27;2;[Header];[Enum];Create;True;1;DissloveTexPlus_JiZuoBiao;2;Normal;0;JiZuoBiao;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;730;-2462.001,1754.387;Inherit;False;Property;_DissloveTexClamp;DissloveTexClamp;50;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;276;-3635.16,160.0837;Inherit;False;1363.104;498.9412;扭曲;13;310;309;307;304;303;299;292;286;283;282;281;280;296;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;674;-2848.863,806.5726;Inherit;False;1507.009;513.9473;Comment;16;526;518;669;670;561;512;515;560;519;525;528;529;523;520;521;522;一系列不知名操作;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;728;-2316.244,1710.531;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;691;-3048.07,850.072;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;513;-2170.875,1680.175;Inherit;True;Property;_DissloveTexPlus;DissloveTexPlus;48;1;[Header];Create;True;0;0;0;False;0;False;-1;None;089c1b64b61a3544e8bf7b11ace9e73c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;280;-3625.28,397.5116;Inherit;False;Property;_Niuqu_V_speed;Niuqu_V_speed;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-3622.84,322.5423;Inherit;False;Property;_Niuqu_U_speed;Niuqu_U_speed;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;-2528.621,1056.753;Inherit;False;Property;_DissolveRA;DissolveR/A;34;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;559;-2084.987,1864.766;Inherit;False;Property;_DissolveTexPlusRA;DissolveTexPlusR/A;51;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;512;-2669.712,860.2877;Inherit;True;Property;_DissolveTex;DissolveTex;31;1;[Header];Create;True;1;Disslove;0;0;False;0;False;-1;None;f4dbfe7d8f42449498c13f2ad2570aa1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-3627.286,201.1347;Inherit;False;0;292;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;283;-3427.52,348.2205;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;515;-2363.695,1093.937;Inherit;False;Property;_DissolveTexDivide;DissolveTexDivide;38;0;Create;True;0;0;0;False;0;False;1;0;1;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;670;-2298.105,1005.691;Inherit;False;Property;_IFDirectionalDissolve;IFDirectionalDissolve;44;2;[Header];[Enum];Create;True;1;DissloveTexPlus;2;OFF;0;ON;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;560;-2291.262,885.8024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;558;-1870.243,1709.79;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;287;-3561.992,-162.2661;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-3568.385,-90.00101;Inherit;False;Property;_Main_V_Speed;Main_V_Speed;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-3568.393,-234.408;Inherit;False;Property;_Main_U_Speed;Main_U_Speed;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;286;-3289.022,207.8677;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;669;-2066.481,887.0076;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;518;-2057.743,1003.49;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-3314.583,-216.6011;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-3314.76,-114.439;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;292;-3200.683,450.5889;Inherit;True;Property;_NIUQU_Tex;NIUQU_Tex;22;1;[Header];Create;True;1;NIUQU_Tex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;521;-2754.102,1150.16;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;519;-1908.523,884.369;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;675;-2843.399,1332.988;Inherit;False;1494.915;297.4599;Comment;7;652;651;654;650;649;647;648;溶解亮边;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-2804.312,1073.537;Inherit;False;Property;_DissolvePower;DissolvePower;36;0;Create;True;0;0;0;False;0;False;0;0.797;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;523;-2295.296,1170.726;Inherit;False;Property;_CustomdataDis;CustomdataDis;33;0;Create;True;0;0;0;False;0;False;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;301;-3369.907,59.18082;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;297;-3172.138,-98.3521;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;296;-2881.566,471.0812;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-2835.331,310.4033;Inherit;False;Property;_NIUQU_Power;NIUQU_Power;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;298;-3167.873,-187.4021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;525;-1785.387,884.0745;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;648;-2473.395,1546.122;Inherit;False;Property;_DissolveEdgeWide;DissolveEdgeWide;43;0;Create;True;0;0;0;False;0;False;0.05727924;0.542;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;647;-1894.74,1406.669;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-2911.634,-37.75615;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-2672.098,443.4905;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;528;-1663.398,884.6221;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2928,80;Inherit;False;Property;_one_UV;one_UV;7;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;311;-2245.8,203.5904;Inherit;False;1006.245;458.0202;MASK;15;215;335;325;327;413;414;334;324;331;332;323;333;329;330;322;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-2667.015,577.6531;Inherit;False;Property;_NIUQUONOFF;NIUQU,ON/OFF;23;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;-2919.584,-157.6369;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-2653.288,354.2102;Inherit;False;Constant;_Float4;Float 4;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-2226.01,444.1964;Inherit;False;Property;_MASK_v_speed;MASK_v_speed;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;522;-2067.797,1229.664;Inherit;False;Property;_DissolveSmooth;DissolveSmooth;37;0;Create;True;0;0;0;False;0;False;0;0.542;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;649;-1752.835,1407.45;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-2225.661,369.0941;Inherit;False;Property;_MASK_u_speed;MASK_u_speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;650;-1748.032,1506.684;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;309;-2484.673,435.0109;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;312;-2232.101,-296.441;Inherit;False;982.6001;358.3385;旋转;8;412;318;317;316;320;319;321;272;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-2221.225,515.1809;Inherit;False;Property;_MASKRotator;MASKRotator;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;308;-2656,-64;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;651;-1624.552,1407.163;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;737;-2985.025,2146.243;Inherit;False;1625.076;555.8684;溶解;15;746;740;750;761;759;757;756;755;754;753;752;751;748;747;743;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;654;-2398.644,1368.533;Inherit;False;Property;_DissloveEdgeColor;DissloveEdgeColor;42;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;323;-2222.479,588.8699;Inherit;False;Constant;_Float11;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;526;-1801.122,1164.182;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;333;-2029.619,521.691;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-2220.745,-252.786;Inherit;False;Property;_mainRotator;mainRotator;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;331;-2229.74,244.8812;Inherit;False;0;327;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;332;-2043.378,383.5476;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-2512.695,202.5097;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;380;-1217.368,269.0422;Inherit;False;1156.728;391.3604;color;12;258;406;399;396;391;389;385;381;601;599;600;602;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-2469.554,-66.80891;Inherit;False;ONE;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;599;-1170.854,438.5941;Inherit;False;Property;_Gam_u_speed;Gam_u_speed;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-1490.005,1381.017;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PiNode;317;-2156.874,-167.4247;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;600;-1171.203,515.6633;Inherit;False;Property;_Gam_v_speed;Gam_v_speed;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;529;-1525.763,882.3281;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-1822.07,554.788;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;740;-2949.449,2205.994;Inherit;False;0;743;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;318;-2156.531,-92.62392;Inherit;False;Constant;_Float6;Float 6;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;334;-1947.074,249.1145;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-907.5216,569.19;Inherit;False;Property;_GAMRotator;GAMRotator;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;384;-2236.824,67.49414;Inherit;False;993.7101;115.0895;软粒子;4;219;400;393;388;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-745.5668,562.3893;Inherit;False;Constant;_Float12;Float 12;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;657;-1299.397,1014.45;Inherit;False;Property;_Use_MiaoBian;Use_MiaoBian;41;1;[Enum];Create;True;0;2;Disslove;0;MiaoBian;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;743;-2736.643,2177.347;Inherit;True;Property;_DissovleSTex;DissovleSTex;54;1;[Header];Create;True;1;DissovleSTex;0;0;False;0;False;-1;None;2a956a84be59a874abec997f0534e27b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;747;-2604.695,2362.665;Inherit;False;Property;_DissovleSA_R;DissovleSA_R;55;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;601;-902.3995,469.8763;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;389;-747.4027,488.6293;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;391;-1138.869,314.5356;Inherit;False;0;406;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;335;-1771.23,249.4355;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-1980.289,-249.4081;Inherit;False;214;ONE;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;320;-1961.117,-166.3957;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;655;-1296.935,920.4944;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;602;-874.5473,319.7747;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;396;-538.8129,503.7762;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;597;-923.565,1041.962;Inherit;False;Property;_Use_Disslove;Use_Disslove;35;1;[Enum];Create;True;0;2;ON;0;OFF;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;751;-2335.573,2204.237;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;750;-2343.733,2325.892;Inherit;False;Constant;_Float7;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;656;-1122.731,864.0704;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;598;-908.0223,961.9802;Inherit;False;Constant;_Float0;Float 0;48;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;325;-1602.54,349.1278;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;272;-1578.205,-253.976;Inherit;False;317.8248;263.5372;Clamp;2;314;411;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;748;-2594.951,2567.231;Inherit;False;Constant;_Float9;Float 7;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;321;-1808.96,-244.0197;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;746;-2695.937,2448.457;Inherit;False;Property;_DissSpower;DissSpower;56;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-1982.767,105.9033;Inherit;False;Property;_soft;soft;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;414;-1766.938,402.0963;Inherit;False;Property;_MaskClamp;MaskClamp;18;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;413;-1401.816,326.6682;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;753;-2424.09,2453.638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;399;-702.1927,320.6443;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;752;-2148.4,2201.814;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;314;-1567.395,-159.7357;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;393;-1813.016,92.68621;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;-1775.921,-122.3622;Inherit;False;Property;_MianClamp;MianClamp;8;1;[Enum];Create;True;0;2;Repeat;0;Clmap;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;596;-732.934,864.1172;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;676;-513.7018,813.8;Inherit;False;413.0406;265.3306;Comment;4;217;661;665;660;分离A通道;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;406;-526.4666,306.4032;Inherit;True;Property;_Gam;Gam;13;1;[Header];Create;True;1;GAM;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;660;-446.1526,868.5111;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;400;-1568.06,114.2263;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;327;-1519.675,468.3153;Inherit;True;Property;_MASKTEX;MASKTEX;17;1;[Header];Create;True;1;MASKTEX;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;754;-2040.954,2201.493;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;411;-1404.012,-216.5919;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;665;-497.0372,956.2023;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;-2185.095,2462.568;Inherit;False;Property;_DissovleSsmooth;DissovleSsmooth;57;0;Create;True;0;0;0;False;0;False;0.5;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1425.57,106.7642;Inherit;False;soft;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1217.643,-52.25809;Inherit;False;Property;_Maincolor;Maincolor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1.843137,1.843137,1.843137,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-291.3256,863.8;Inherit;False;Three;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;141;-531.9512,-18.95077;Inherit;False;468.0641;274.429;ALPHA模式连到不透明度，ADD模式连到Emission;4;666;216;220;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;756;-1914.356,2287.098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-832.0872,141.8924;Inherit;False;Property;_A_R;A_R;6;1;[Enum];Create;True;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1219.613,-242.7918;Inherit;True;Property;_maintex;maintex;4;1;[Header];Create;True;1;MainTex;0;0;False;0;False;-1;None;174ececcfecaefd42bf821d98974e1d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-240.1303,305.7083;Inherit;False;Gam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;3;-1019.07,-50.59649;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-1507.36,245.8365;Inherit;False;two;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;661;-291.5441,956.8802;Inherit;False;Three1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;757;-1911.046,2200.336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;666;-505.9324,176.4583;Inherit;False;661;Three1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;761;-1777.223,2260.844;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;409;-676.9509,100.0943;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-511.7618,28.69876;Inherit;False;219;soft;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-789.5484,-145.3452;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-516.7797,-187.6422;Inherit;False;217;Three;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-513.8923,-94.90076;Inherit;False;258;Gam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-507.7344,103.4531;Inherit;False;215;two;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;671;-9122.377,-3310.365;Inherit;False;1762.399;332.7929;Comment;13;589;593;587;586;588;590;585;591;592;583;584;582;727;溶解贴图扭曲;1,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;582;-9116.305,-3129.409;Inherit;False;Constant;_DissolveNiuqu_U_speed;DissolveNiuqu_U_speed;57;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;593;-7741.541,-3153.47;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;759;-1758.778,2186;Inherit;False;Constant;_Float10;Float 8;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;590;-8228.603,-3182.407;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;589;-7565.395,-3154.624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-662.4127,17.31891;Inherit;False;Property;_ZTestMode;深度测试;0;1;[Enum];Create;False;0;2;Less or Equal;4;Always;8;0;True;0;False;4;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;591;-8531.137,-3246.815;Inherit;True;Property;_DissloveNIUQU_Tex;DissloveNIUQU_Tex;57;1;[Header];Create;True;1;DissloveNIUQU;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;586;-7964.612,-3207.901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;587;-7960.483,-3299.278;Inherit;False;Constant;_Float1;Float 1;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-659.3129,-60.63021;Inherit;False;Property;_CullMode;剔除模式;2;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-8005.663,-3111.485;Inherit;False;Constant;_DissolveNIUQUONOFF;DissolveNIUQU,ON/OFF;55;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-8220.113,-3269.689;Inherit;False;Constant;_DissolveNIUQU_Power;DissolveNIUQU_Power;56;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;592;-8751.376,-3251.224;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;583;-9061.696,-3258.522;Inherit;False;0;292;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;584;-8885.616,-3082.52;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;727;-9115.493,-3056.63;Inherit;False;Constant;_DissolveNiuqu_V_speed;DissolveNiuqu_V_speed;58;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-659.8276,-138.7818;Inherit;False;Property;_Dst;材质模式;1;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-178.9894,-164.5165;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-193.802,57.0362;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;768;135.0494,298.022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;8.669239,-135.6083;Half;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;LTY/ShaderNew/DingXiangRongJie;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;-1;1;True;238;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;True;135;0;0;False;-1;0;False;-1;0;True;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;False;0;0;True;142;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;300;0;288;2
WireConnection;677;0;551;0
WireConnection;736;0;731;0
WireConnection;678;0;677;0
WireConnection;735;0;715;0
WireConnection;735;1;736;0
WireConnection;735;2;734;0
WireConnection;721;0;557;0
WireConnection;721;1;722;0
WireConnection;679;0;678;1
WireConnection;679;1;678;0
WireConnection;716;0;721;0
WireConnection;716;1;735;0
WireConnection;681;0;679;0
WireConnection;681;1;680;0
WireConnection;683;0;677;0
WireConnection;723;0;716;0
WireConnection;723;1;722;0
WireConnection;555;0;553;0
WireConnection;555;1;554;0
WireConnection;724;0;557;0
WireConnection;724;1;723;0
WireConnection;724;2;726;0
WireConnection;686;0;681;0
WireConnection;571;0;566;0
WireConnection;684;0;683;0
WireConnection;684;1;682;0
WireConnection;685;0;684;0
WireConnection;685;1;686;0
WireConnection;689;0;687;3
WireConnection;689;1;687;4
WireConnection;696;0;697;0
WireConnection;550;0;548;0
WireConnection;550;1;549;0
WireConnection;573;0;571;0
WireConnection;573;1;569;0
WireConnection;688;0;687;1
WireConnection;688;1;687;2
WireConnection;703;0;706;0
WireConnection;703;1;701;0
WireConnection;556;0;724;0
WireConnection;556;2;555;0
WireConnection;700;0;701;0
WireConnection;700;1;704;0
WireConnection;580;0;556;0
WireConnection;580;2;573;0
WireConnection;552;0;551;0
WireConnection;552;2;550;0
WireConnection;699;0;703;0
WireConnection;699;1;700;0
WireConnection;695;0;696;0
WireConnection;695;1;698;0
WireConnection;690;0;685;0
WireConnection;690;1;688;0
WireConnection;690;2;689;0
WireConnection;694;0;552;0
WireConnection;694;2;695;0
WireConnection;705;0;690;0
WireConnection;705;1;699;0
WireConnection;729;0;580;0
WireConnection;728;0;580;0
WireConnection;728;1;729;0
WireConnection;728;2;730;0
WireConnection;691;0;694;0
WireConnection;691;1;705;0
WireConnection;691;2;692;0
WireConnection;513;1;728;0
WireConnection;512;1;691;0
WireConnection;283;0;281;0
WireConnection;283;1;280;0
WireConnection;560;0;512;1
WireConnection;560;1;512;4
WireConnection;560;2;561;0
WireConnection;558;0;513;1
WireConnection;558;1;513;4
WireConnection;558;2;559;0
WireConnection;286;0;282;0
WireConnection;286;2;283;0
WireConnection;669;0;560;0
WireConnection;669;1;558;0
WireConnection;669;2;670;0
WireConnection;518;0;560;0
WireConnection;518;1;515;0
WireConnection;293;0;284;0
WireConnection;293;1;287;0
WireConnection;289;0;287;0
WireConnection;289;1;285;0
WireConnection;292;1;286;0
WireConnection;519;0;669;0
WireConnection;519;1;518;0
WireConnection;523;0;520;0
WireConnection;523;1;521;1
WireConnection;301;0;288;3
WireConnection;301;1;288;4
WireConnection;296;0;292;1
WireConnection;298;0;293;0
WireConnection;298;1;289;0
WireConnection;525;0;519;0
WireConnection;647;0;523;0
WireConnection;647;1;648;0
WireConnection;302;0;297;0
WireConnection;302;1;301;0
WireConnection;307;0;299;0
WireConnection;307;1;296;0
WireConnection;528;0;525;0
WireConnection;305;0;298;0
WireConnection;305;1;297;0
WireConnection;649;0;647;0
WireConnection;649;1;528;0
WireConnection;650;0;523;0
WireConnection;650;1;528;0
WireConnection;309;0;303;0
WireConnection;309;1;307;0
WireConnection;309;2;304;0
WireConnection;308;0;305;0
WireConnection;308;1;302;0
WireConnection;308;2;306;0
WireConnection;651;0;649;0
WireConnection;651;1;650;0
WireConnection;526;0;523;0
WireConnection;526;1;522;0
WireConnection;333;0;322;0
WireConnection;332;0;330;0
WireConnection;332;1;329;0
WireConnection;310;0;308;0
WireConnection;310;1;309;0
WireConnection;214;0;310;0
WireConnection;652;0;654;0
WireConnection;652;1;651;0
WireConnection;317;0;316;0
WireConnection;529;0;528;0
WireConnection;529;1;526;0
WireConnection;529;2;523;0
WireConnection;324;0;333;0
WireConnection;324;1;323;0
WireConnection;334;0;331;0
WireConnection;334;2;332;0
WireConnection;743;1;740;0
WireConnection;601;0;599;0
WireConnection;601;1;600;0
WireConnection;389;0;381;0
WireConnection;335;0;334;0
WireConnection;335;2;324;0
WireConnection;320;0;317;0
WireConnection;320;1;318;0
WireConnection;655;0;529;0
WireConnection;655;1;652;0
WireConnection;602;0;391;0
WireConnection;602;2;601;0
WireConnection;396;0;389;0
WireConnection;396;1;385;0
WireConnection;751;0;743;1
WireConnection;751;1;743;4
WireConnection;751;2;747;0
WireConnection;656;0;529;0
WireConnection;656;1;655;0
WireConnection;656;2;657;0
WireConnection;325;0;335;0
WireConnection;321;0;319;0
WireConnection;321;2;320;0
WireConnection;413;0;335;0
WireConnection;413;1;325;0
WireConnection;413;2;414;0
WireConnection;753;0;746;0
WireConnection;753;1;748;0
WireConnection;399;0;602;0
WireConnection;399;2;396;0
WireConnection;752;0;751;0
WireConnection;752;1;750;0
WireConnection;314;0;321;0
WireConnection;393;0;388;0
WireConnection;596;0;656;0
WireConnection;596;1;598;0
WireConnection;596;2;597;0
WireConnection;406;1;399;0
WireConnection;660;0;596;0
WireConnection;400;0;393;0
WireConnection;327;1;413;0
WireConnection;754;0;752;0
WireConnection;754;1;753;0
WireConnection;411;0;321;0
WireConnection;411;1;314;0
WireConnection;411;2;412;0
WireConnection;665;0;596;0
WireConnection;219;0;400;0
WireConnection;217;0;660;0
WireConnection;756;0;755;0
WireConnection;1;1;411;0
WireConnection;258;0;406;0
WireConnection;215;0;327;1
WireConnection;661;0;665;0
WireConnection;757;0;754;0
WireConnection;761;0;757;0
WireConnection;761;1;756;0
WireConnection;761;2;755;0
WireConnection;409;0;1;1
WireConnection;409;1;1;4
WireConnection;409;2;410;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;4;2;3;0
WireConnection;593;0;587;0
WireConnection;593;1;586;0
WireConnection;593;2;588;0
WireConnection;590;0;591;1
WireConnection;589;0;593;0
WireConnection;591;1;592;0
WireConnection;586;0;585;0
WireConnection;586;1;590;0
WireConnection;592;0;583;0
WireConnection;592;2;584;0
WireConnection;584;0;582;0
WireConnection;584;1;727;0
WireConnection;658;0;218;0
WireConnection;658;1;4;0
WireConnection;658;2;257;0
WireConnection;658;3;220;0
WireConnection;137;0;3;4
WireConnection;137;1;2;4
WireConnection;137;2;409;0
WireConnection;137;3;220;0
WireConnection;137;4;216;0
WireConnection;137;5;666;0
WireConnection;137;6;761;0
WireConnection;0;2;658;0
WireConnection;0;9;137;0
ASEEND*/
//CHKSM=C32DE79AE06B8885794BF4E2F37C651E19BA0FB4