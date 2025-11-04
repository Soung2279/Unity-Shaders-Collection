// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/星空刀光"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("剔除模式", Float) = 0
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 0
		[Header(BaseTex)]_MainTex("纹理图", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		[Enum(R,0,A,1)]_MainTexP("主帖图通道", Float) = 0
		[Enum(Screen,0,Local,1)]_UVMode("主帖图UV模式", Float) = 0
		_TilingOffset("屏幕模式重铺偏移", Vector) = (1,1,0,0)
		_USpeed("主帖图U速率", Float) = 0.1
		_VSpeed("主帖图V速率", Float) = 0
		[Header(Distortion)]_NIUQU_Tex("扭曲纹理", 2D) = "white" {}
		_NIUQU_Power("扭曲强度", Range( 0 , 1)) = 0
		_Niuqu_U_speed("扭曲U速度", Float) = 0
		_Niuqu_V_speed("扭曲V速度", Float) = 0
		[Header(DaoMask)]_MaskTex2("刀光形状", 2D) = "white" {}
		[IntRange]_Mask_Tex_Rotator2("形状旋转", Range( 0 , 360)) = 0
		[Enum(R,0,A,1)]_MaskTex_A_R2("形状通道", Float) = 0
		[Enum(Material,0,Custom1zw,1)]_one_UV("形状流动控制模式", Float) = 0
		_MaskTex3("缓入缓出", 2D) = "white" {}
		[IntRange]_Mask_Tex_Rotator3("缓图旋转", Range( 0 , 360)) = 0
		[Enum(R,0,A,1)]_MaskTex_A_R3("缓图通道", Float) = 0
		[Header(Dissiovle)]_DissTex("溶解贴图", 2D) = "white" {}
		_Diss_Power("溶解进度", Range( 0 , 1)) = 0
		_DisSmooth("溶解平滑度", Range( 0.5 , 1)) = 0.5
		[Enum(Material,0,Custom1y,1)]_DisMode("溶解控制模式", Float) = 0
		[Header(Gam)]_GamTex("颜色渐变", 2D) = "white" {}
		[IntRange]_GamTex_Rotator("颜色渐变旋转", Range( 0 , 360)) = 0
		[Header(Vertex)]_WPO_Tex("顶点偏移", 2D) = "white" {}
		[Enum(Material,0,Custom1x,1)]_WPO_CustomSwitch_Y("顶点偏移控制模式", Float) = 0
		_WPO_tex_power("顶点偏移强度", Float) = 0
		_WPO_Tex_Direction("顶点偏移轴向", Vector) = (1,1,1,0)
		_WPO_Tex_U_speed("顶点偏移U速度", Float) = 0
		_WPO_Tex_V_speed("顶点偏移V速度", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull [_CullingMode]
		ZWrite Off
		Blend SrcAlpha [_BlendMode]
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 vertexColor : COLOR;
			float4 screenPos;
			float2 uv_texcoord;
			float4 uv2_texcoord2;
		};

		uniform float _CullingMode;
		uniform float _BlendMode;
		uniform float _WPO_tex_power;
		uniform float _WPO_CustomSwitch_Y;
		uniform sampler2D _WPO_Tex;
		uniform float _WPO_Tex_U_speed;
		uniform float _WPO_Tex_V_speed;
		uniform float4 _WPO_Tex_ST;
		uniform float4 _WPO_Tex_Direction;
		uniform float4 _MainColor;
		uniform sampler2D _MainTex;
		uniform float _USpeed;
		uniform float _VSpeed;
		uniform float4 _TilingOffset;
		uniform float4 _MainTex_ST;
		uniform float _UVMode;
		uniform float _NIUQU_Power;
		uniform sampler2D _NIUQU_Tex;
		uniform float _Niuqu_U_speed;
		uniform float _Niuqu_V_speed;
		uniform float4 _NIUQU_Tex_ST;
		uniform sampler2D _GamTex;
		uniform float4 _GamTex_ST;
		uniform float _GamTex_Rotator;
		uniform float _DisSmooth;
		uniform sampler2D _DissTex;
		uniform float4 _DissTex_ST;
		uniform float _Diss_Power;
		uniform float _DisMode;
		uniform float _MainTexP;
		uniform sampler2D _MaskTex2;
		uniform float4 _MaskTex2_ST;
		uniform float _one_UV;
		uniform float _Mask_Tex_Rotator2;
		uniform float _MaskTex_A_R2;
		uniform sampler2D _MaskTex3;
		uniform float4 _MaskTex3_ST;
		uniform float _Mask_Tex_Rotator3;
		uniform float _MaskTex_A_R3;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float custom1x169 = v.texcoord1.x;
			float lerpResult255 = lerp( _WPO_tex_power , custom1x169 , _WPO_CustomSwitch_Y);
			float3 ase_vertexNormal = v.normal.xyz;
			float2 appendResult246 = (float2(_WPO_Tex_U_speed , _WPO_Tex_V_speed));
			float2 uv_WPO_Tex = v.texcoord.xy * _WPO_Tex_ST.xy + _WPO_Tex_ST.zw;
			float2 panner249 = ( 1.0 * _Time.y * appendResult246 + uv_WPO_Tex);
			float4 Vertex262 = ( lerpResult255 * float4( ase_vertexNormal , 0.0 ) * tex2Dlod( _WPO_Tex, float4( panner249, 0, 0.0) ) * _WPO_Tex_Direction );
			v.vertex.xyz += Vertex262.rgb;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult16 = (float2(_USpeed , _VSpeed));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult11 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float2 appendResult12 = (float2(_TilingOffset.x , _TilingOffset.y));
			float2 appendResult13 = (float2(_TilingOffset.z , _TilingOffset.w));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 lerpResult54 = lerp( (appendResult11*appendResult12 + appendResult13) , uv_MainTex , _UVMode);
			float2 panner7 = ( 1.0 * _Time.y * appendResult16 + lerpResult54);
			float2 appendResult225 = (float2(_Niuqu_U_speed , _Niuqu_V_speed));
			float2 uv_NIUQU_Tex = i.uv_texcoord * _NIUQU_Tex_ST.xy + _NIUQU_Tex_ST.zw;
			float2 panner226 = ( 1.0 * _Time.y * appendResult225 + uv_NIUQU_Tex);
			float NiuquUV235 = ( _NIUQU_Power * (-0.5 + (tex2D( _NIUQU_Tex, panner226 ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) );
			float4 tex2DNode2 = tex2D( _MainTex, ( panner7 + NiuquUV235 ) );
			float4 MainColor139 = ( _MainColor * tex2DNode2 );
			float2 uv_GamTex = i.uv_texcoord * _GamTex_ST.xy + _GamTex_ST.zw;
			float cos131 = cos( ( ( _GamTex_Rotator * UNITY_PI ) / 180.0 ) );
			float sin131 = sin( ( ( _GamTex_Rotator * UNITY_PI ) / 180.0 ) );
			float2 rotator131 = mul( uv_GamTex - float2( 0.5,0.5 ) , float2x2( cos131 , -sin131 , sin131 , cos131 )) + float2( 0.5,0.5 );
			float4 GamColor180 = tex2D( _GamTex, rotator131 );
			float2 uv_DissTex = i.uv_texcoord * _DissTex_ST.xy + _DissTex_ST.zw;
			float custom1y170 = i.uv2_texcoord2.y;
			float lerpResult167 = lerp( _Diss_Power , custom1y170 , _DisMode);
			float smoothstepResult27 = smoothstep( ( 1.0 - _DisSmooth ) , _DisSmooth , saturate( ( ( tex2D( _DissTex, uv_DissTex ).r + 1.0 ) - ( lerpResult167 * 2.0 ) ) ));
			float DissolveResult181 = smoothstepResult27;
			o.Emission = ( i.vertexColor * MainColor139 * GamColor180 * DissolveResult181 ).rgb;
			float lerpResult58 = lerp( tex2DNode2.r , tex2DNode2.a , _MainTexP);
			float MainAlpha141 = ( _MainColor.a * lerpResult58 );
			float2 uv_MaskTex2 = i.uv_texcoord * _MaskTex2_ST.xy + _MaskTex2_ST.zw;
			float custom1z171 = i.uv2_texcoord2.z;
			float custom1w172 = i.uv2_texcoord2.w;
			float2 appendResult207 = (float2(custom1z171 , custom1w172));
			float2 lerpResult213 = lerp( uv_MaskTex2 , ( uv_MaskTex2 + appendResult207 ) , _one_UV);
			float cos151 = cos( ( ( _Mask_Tex_Rotator2 * UNITY_PI ) / 180.0 ) );
			float sin151 = sin( ( ( _Mask_Tex_Rotator2 * UNITY_PI ) / 180.0 ) );
			float2 rotator151 = mul( lerpResult213 - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
			float4 tex2DNode150 = tex2D( _MaskTex2, rotator151 );
			float lerpResult148 = lerp( tex2DNode150.r , tex2DNode150.a , _MaskTex_A_R2);
			float Mask1Alpha178 = lerpResult148;
			float2 uv_MaskTex3 = i.uv_texcoord * _MaskTex3_ST.xy + _MaskTex3_ST.zw;
			float cos161 = cos( ( ( _Mask_Tex_Rotator3 * UNITY_PI ) / 180.0 ) );
			float sin161 = sin( ( ( _Mask_Tex_Rotator3 * UNITY_PI ) / 180.0 ) );
			float2 rotator161 = mul( uv_MaskTex3 - float2( 0.5,0.5 ) , float2x2( cos161 , -sin161 , sin161 , cos161 )) + float2( 0.5,0.5 );
			float4 tex2DNode160 = tex2D( _MaskTex3, rotator161 );
			float lerpResult158 = lerp( tex2DNode160.r , tex2DNode160.a , _MaskTex_A_R3);
			float Mask2Alpha179 = lerpResult158;
			o.Alpha = ( i.vertexColor.a * MainAlpha141 * Mask1Alpha178 * Mask2Alpha179 * DissolveResult181 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float4 screenPos : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.uv2_texcoord2;
				o.customPack2.xyzw = v.texcoord1;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack2.xyzw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				surfIN.vertexColor = IN.color;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;196;-2631.347,947.4234;Inherit;False;278.7705;128.204;Settings;2;197;198;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-1458.361,-205.0155;Inherit;False;556.2673;307.1271;Color;4;194;188;189;184;着色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;183;-1483.393,129.3325;Inherit;False;435.2683;371.115;Alpha;5;193;192;190;191;185;透明度;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;-2338.128,-229.7083;Inherit;False;457.4368;364.0155;Comment;5;95;172;171;169;170;粒子自定义数据组;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;137;-2580.601,1166.771;Inherit;False;1195.786;359.5765;Comment;8;180;33;135;132;136;134;133;131;颜色渐变;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-3990.541,695.4276;Inherit;False;1310.37;441.2618;溶解;14;181;168;29;28;25;20;176;167;24;27;26;22;21;23;溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-3988.479,-780.1473;Inherit;False;2014.468;496.2517;uv模式;23;236;237;7;2;3;141;142;58;139;138;57;55;54;16;56;53;52;10;13;12;15;11;14;主贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;131;-2053.466,1240.782;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;133;-2179.304,1288.135;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;134;-2355.853,1289.038;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2438.715,1445.218;Inherit;False;Constant;_Float13;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;132;-2565.974,1237.228;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;14;-3977.379,-679.8473;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;11;-3758.281,-650.7471;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;15;-3941.404,-510.6002;Inherit;False;Property;_TilingOffset;屏幕模式重铺偏移;7;0;Create;False;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;12;-3758.306,-517.8002;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-3756.906,-420.3001;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;10;-3612.538,-650.7985;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-3610.179,-530.5912;Inherit;False;Property;_USpeed;主帖图U速率;8;0;Create;False;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3609.179,-457.5911;Inherit;False;Property;_VSpeed;主帖图V速率;9;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-3383.585,-629.5912;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-3459.28,-504.9793;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;54;-3169.504,-649.5009;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;147;-3992.163,-238.5149;Inherit;False;1622.498;513.7159;MASK;16;150;178;148;149;151;211;213;208;155;153;154;156;207;215;216;220;形状遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;157;-3985.731,1178.855;Inherit;False;1357.449;347.0982;MASK;10;179;159;165;160;162;166;164;163;161;158;缓入缓出遮罩;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;158;-2985.022,1278.61;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;161;-3459.487,1249.452;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-2317.469,-124.5475;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3545.002,942.1966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-3423.627,774.6734;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-3299.46,774.7344;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;-3163.194,774.7354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-3027.238,773.7354;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3978.35,902.7296;Inherit;False;Property;_Diss_Power;溶解进度;22;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;167;-3699.974,942.312;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-3881.664,973.6747;Inherit;False;170;custom1y;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-3706.56,743.4276;Inherit;True;Property;_DissTex;溶解贴图;21;1;[Header];Create;False;1;Dissiovle;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-3680.279,1060.275;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-3541.719,1042.498;Inherit;False;Property;_DisSmooth;溶解平滑度;23;0;Create;False;0;0;0;False;0;False;0.5;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-3220.685,877.0669;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-2486.835,993.7021;Inherit;False;Property;_CullingMode;剔除模式;0;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-2620.835,993.7021;Inherit;False;Property;_BlendMode;混合模式;1;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2565.46,1367.528;Inherit;False;Property;_GamTex_Rotator;颜色渐变旋转;26;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3299.134,-503.0786;Inherit;False;Property;_UVMode;主帖图UV模式;6;1;[Enum];Create;False;0;2;Screen;0;Local;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;160;-3283.402,1220.744;Inherit;True;Property;_MaskTex3;缓入缓出;18;0;Create;False;1;Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;216;-3969.452,19.90304;Inherit;False;172;custom1w;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-3970.579,-59.83978;Inherit;False;171;custom1z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-3787.561,192.0969;Inherit;False;Constant;_Float14;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;154;-3706.264,106.0554;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;-3532.738,105.2759;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;208;-3975.151,-192.1438;Inherit;False;0;150;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;213;-3383.013,-62.79095;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;151;-3205.392,54.83169;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;148;-2727.846,54.91811;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-2569.05,50.85885;Inherit;False;Mask1Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;150;-3024.227,-2.945839;Inherit;True;Property;_MaskTex2;刀光形状;14;1;[Header];Create;False;1;DaoMask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;207;-3804.921,-39.60954;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;220;-3658.456,-64.22192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-1880.872,1211.593;Inherit;True;Property;_GamTex;颜色渐变;25;1;[Header];Create;False;1;Gam;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-2094.725,-105.2924;Inherit;False;custom1y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-2091.725,-30.29221;Inherit;False;custom1z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;221;-3992.197,314.014;Inherit;False;1307.604;360.9412;扭曲;10;235;230;229;227;228;226;225;222;223;224;纹理扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;224;-3984.323,355.0649;Inherit;False;0;227;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;223;-3979.877,476.4721;Inherit;False;Property;_Niuqu_U_speed;扭曲U速度;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-3981.317,551.4414;Inherit;False;Property;_Niuqu_V_speed;扭曲V速度;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;225;-3841.557,498.1503;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;226;-3717.06,359.7978;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;228;-3273.604,508.0109;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2598.94,-371.876;Inherit;False;Property;_MainTexP;主帖图通道;5;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-2403.556,-664.9241;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-2244.556,-669.9241;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;58;-2448.94,-484.876;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-2292.68,-507.9285;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-2162.257,-510.5241;Inherit;False;MainAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-2663.14,-735.517;Inherit;False;Property;_MainColor;主颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-2742.14,-561.2876;Inherit;True;Property;_MainTex;纹理图;3;1;[Header];Create;False;1;BaseTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;7;-3026.155,-531.4406;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-2856.913,-530.6805;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;-3016.913,-409.6805;Inherit;False;235;NiuquUV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;227;-3552.721,479.5187;Inherit;True;Property;_NIUQU_Tex;扭曲纹理;10;1;[Header];Create;False;1;Distortion;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;155;-3967.304,99.40816;Inherit;False;Property;_Mask_Tex_Rotator2;形状旋转;15;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2901.571,189.7202;Inherit;False;Property;_MaskTex_A_R2;形状通道;16;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-3160.747,1413.41;Inherit;False;Property;_MaskTex_A_R3;缓图通道;20;1;[Enum];Create;False;0;2;R;0;A;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;-2820.564,1273.928;Inherit;False;Mask2Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;-1579.052,1211.128;Inherit;False;GamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-2093.725,46.7076;Inherit;False;custom1w;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;243;-2645.51,328.2222;Inherit;False;1090.342;556.5039;顶点偏移;14;262;253;257;252;247;254;249;246;245;244;255;250;248;261;顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-2092.725,-180.2928;Inherit;False;custom1x;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-3275.369,430.3333;Inherit;False;Property;_NIUQU_Power;扭曲强度;11;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-3004.534,483.1201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;-2877.74,479.442;Inherit;False;NiuquUV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-3866.974,1049.312;Inherit;False;Property;_DisMode;溶解控制模式;24;1;[Enum];Create;False;0;2;Material;0;Custom1y;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3641.013,33.20968;Inherit;False;Property;_one_UV;形状流动控制模式;17;1;[Enum];Create;False;0;2;Material;0;Custom1zw;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;255;-2436.803,431.175;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;246;-2471.627,743.2911;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;249;-2345.08,721.892;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;252;-2380.822,548.104;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-1878.957,528.1289;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;253;-2046.492,518.0529;Inherit;False;Property;_WPO_Tex_Direction;顶点偏移轴向;30;0;Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-1747.453,522.9918;Inherit;False;Vertex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;254;-2175.856,693.2189;Inherit;True;Property;_WPO_Tex;顶点偏移;27;1;[Header];Create;False;1;Vertex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-2875.892,769.1885;Inherit;False;DissolveResult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;163;-3585.326,1296.804;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;164;-3761.878,1297.707;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-3844.739,1453.886;Inherit;False;Constant;_Float15;Float 11;13;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;162;-3971.996,1245.898;Inherit;False;0;160;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;165;-3971.481,1376.197;Inherit;False;Property;_Mask_Tex_Rotator3;缓图旋转;19;1;[IntRange];Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-2627.112,449.6429;Inherit;False;169;custom1x;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-2625.859,376.769;Inherit;False;Property;_WPO_tex_power;顶点偏移强度;29;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;250;-2629.366,524.8969;Inherit;False;Property;_WPO_CustomSwitch_Y;顶点偏移控制模式;28;1;[Enum];Create;False;0;2;Material;0;Custom1x;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-2632.034,717.006;Inherit;False;Property;_WPO_Tex_U_speed;顶点偏移U速度;31;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;245;-2632.134,793.2729;Inherit;False;Property;_WPO_Tex_V_speed;顶点偏移V速度;32;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;247;-2630.935,597.438;Inherit;False;0;254;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;34;-1641.648,-160.554;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-1114.417,-158.4031;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-1246.676,167.0783;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-1461.156,185.0103;Inherit;False;141;MainAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-1461.052,262.1386;Inherit;False;178;Mask1Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-1333.377,-63.15998;Inherit;False;180;GamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-1330.904,-138.5771;Inherit;False;139;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-1350.716,12.60168;Inherit;False;181;DissolveResult;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;17;-842.8839,-207.4452;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;A201-Shader/Built-in/特殊制作/星空刀光;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;True;_BlendMode;0;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;False;0;0;True;_CullingMode;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-1035.853,134.5857;Inherit;False;262;Vertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-1471.156,421.0104;Inherit;False;181;DissolveResult;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;192;-1461.156,342.0104;Inherit;False;179;Mask2Alpha;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;131;0;132;0
WireConnection;131;2;133;0
WireConnection;133;0;134;0
WireConnection;133;1;136;0
WireConnection;134;0;135;0
WireConnection;11;0;14;1
WireConnection;11;1;14;2
WireConnection;12;0;15;1
WireConnection;12;1;15;2
WireConnection;13;0;15;3
WireConnection;13;1;15;4
WireConnection;10;0;11;0
WireConnection;10;1;12;0
WireConnection;10;2;13;0
WireConnection;16;0;52;0
WireConnection;16;1;53;0
WireConnection;54;0;10;0
WireConnection;54;1;56;0
WireConnection;54;2;55;0
WireConnection;158;0;160;1
WireConnection;158;1;160;4
WireConnection;158;2;159;0
WireConnection;161;0;162;0
WireConnection;161;2;163;0
WireConnection;23;0;167;0
WireConnection;23;1;25;0
WireConnection;21;0;20;1
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;26;0;22;0
WireConnection;27;0;26;0
WireConnection;27;1;29;0
WireConnection;27;2;28;0
WireConnection;167;0;24;0
WireConnection;167;1;176;0
WireConnection;167;2;168;0
WireConnection;29;0;28;0
WireConnection;160;1;161;0
WireConnection;154;0;155;0
WireConnection;153;0;154;0
WireConnection;153;1;156;0
WireConnection;213;0;208;0
WireConnection;213;1;220;0
WireConnection;213;2;211;0
WireConnection;151;0;213;0
WireConnection;151;2;153;0
WireConnection;148;0;150;1
WireConnection;148;1;150;4
WireConnection;148;2;149;0
WireConnection;178;0;148;0
WireConnection;150;1;151;0
WireConnection;207;0;215;0
WireConnection;207;1;216;0
WireConnection;220;0;208;0
WireConnection;220;1;207;0
WireConnection;33;1;131;0
WireConnection;170;0;95;2
WireConnection;171;0;95;3
WireConnection;225;0;223;0
WireConnection;225;1;222;0
WireConnection;226;0;224;0
WireConnection;226;2;225;0
WireConnection;228;0;227;1
WireConnection;138;0;3;0
WireConnection;138;1;2;0
WireConnection;139;0;138;0
WireConnection;58;0;2;1
WireConnection;58;1;2;4
WireConnection;58;2;57;0
WireConnection;142;0;3;4
WireConnection;142;1;58;0
WireConnection;141;0;142;0
WireConnection;2;1;237;0
WireConnection;7;0;54;0
WireConnection;7;2;16;0
WireConnection;237;0;7;0
WireConnection;237;1;236;0
WireConnection;227;1;226;0
WireConnection;179;0;158;0
WireConnection;180;0;33;0
WireConnection;172;0;95;4
WireConnection;169;0;95;1
WireConnection;230;0;229;0
WireConnection;230;1;228;0
WireConnection;235;0;230;0
WireConnection;255;0;248;0
WireConnection;255;1;261;0
WireConnection;255;2;250;0
WireConnection;246;0;244;0
WireConnection;246;1;245;0
WireConnection;249;0;247;0
WireConnection;249;2;246;0
WireConnection;257;0;255;0
WireConnection;257;1;252;0
WireConnection;257;2;254;0
WireConnection;257;3;253;0
WireConnection;262;0;257;0
WireConnection;254;1;249;0
WireConnection;181;0;27;0
WireConnection;163;0;164;0
WireConnection;163;1;166;0
WireConnection;164;0;165;0
WireConnection;184;0;34;0
WireConnection;184;1;188;0
WireConnection;184;2;189;0
WireConnection;184;3;194;0
WireConnection;185;0;34;4
WireConnection;185;1;191;0
WireConnection;185;2;190;0
WireConnection;185;3;192;0
WireConnection;185;4;193;0
WireConnection;17;2;184;0
WireConnection;17;9;185;0
WireConnection;17;11;263;0
ASEEND*/
//CHKSM=07A3DE2AF71CBD27F258D8F7D901E1ABCB79C2F9