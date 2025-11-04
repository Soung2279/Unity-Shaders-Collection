// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/进阶功能/卡通地裂带溶解"
{
	Properties
	{
		[Header(MainTex)]_MainTex("地裂贴图", 2D) = "white" {}
		_ReMap("高度重映射(建议默认)", Vector) = (0,1,1,0)
		[KeywordEnum(R,A)] _SwitchP("切换贴图通道", Float) = 0
		_CScale("地裂深度", Range( 0 , 1)) = 0
		[HDR]_InnColor("表面颜色", Color) = (1,0,0,1)
		[HDR]_OutColor("深处颜色", Color) = (0,0,0,1)
		[Header(LiuguangTex)]_liuguangTex("流光贴图", 2D) = "white" {}
		[KeywordEnum(off,on)] _jizuobiao("是否启用极坐标流光", Float) = 0
		_liuguang_ST("流光极坐标中心和重铺", Vector) = (1,5,0,0)
		_LiuVspeed("流光V速度", Float) = 0
		_LiuUspeed("流光U速度", Float) = 0
		[Header(DissolveTex)]_DisTex("溶解贴图", 2D) = "white" {}
		_disc("溶解强度", Range( 0 , 1)) = 0
		_dissoft("溶解软硬", Range( 0 , 1)) = 0
		[Toggle(_CUSTOMEDIS_ON)] _customedis("CustomeX控制溶解", Float) = 0
		[Header(SpawnTex)]_SpawnTex("出现贴图(第二套溶解)", 2D) = "white" {}
		_happen("出现程度", Range( 0 , 1)) = 0
		_happensoft("出现软硬", Range( 0.5 , 1)) = 0
		[Toggle(_CUSTOMESPA_ON)] _customespa("CustomeY控制出现", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _JIZUOBIAO_OFF _JIZUOBIAO_ON
			#pragma shader_feature_local _SWITCHP_R _SWITCHP_A
			#pragma shader_feature_local _CUSTOMEDIS_ON
			#pragma shader_feature_local _CUSTOMESPA_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _OutColor;
			uniform float4 _InnColor;
			uniform sampler2D _liuguangTex;
			uniform float _LiuUspeed;
			uniform float _LiuVspeed;
			uniform float4 _liuguangTex_ST;
			uniform float4 _liuguang_ST;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _ReMap;
			uniform float _CScale;
			uniform float _dissoft;
			uniform sampler2D _DisTex;
			uniform float4 _DisTex_ST;
			uniform float _disc;
			uniform float _happensoft;
			uniform sampler2D _SpawnTex;
			uniform float4 _SpawnTex_ST;
			uniform float _happen;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_color = v.color;
				o.ase_texcoord1.xy = v.ase_texcoord1.xy;
				o.ase_texcoord1.zw = v.ase_texcoord.xy;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult24 = (float2(_LiuUspeed , _LiuVspeed));
				float2 uv2_liuguangTex = i.ase_texcoord1.xy * _liuguangTex_ST.xy + _liuguangTex_ST.zw;
				float2 appendResult25 = (float2(_liuguang_ST.x , _liuguang_ST.y));
				float2 CenteredUV15_g1 = ( uv2_liuguangTex - appendResult25 );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * _liuguang_ST.z * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / 6.28318548202515 ) * _liuguang_ST.w )));
				#if defined(_JIZUOBIAO_OFF)
				float2 staticSwitch21 = uv2_liuguangTex;
				#elif defined(_JIZUOBIAO_ON)
				float2 staticSwitch21 = appendResult23_g1;
				#else
				float2 staticSwitch21 = uv2_liuguangTex;
				#endif
				float2 panner28 = ( 1.0 * _Time.y * appendResult24 + staticSwitch21);
				float2 uv_MainTex = i.ase_texcoord1.zw * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float4 temp_cast_0 = (_ReMap.x).xxxx;
				float4 temp_cast_1 = (_ReMap.y).xxxx;
				float4 temp_cast_2 = (_ReMap.z).xxxx;
				float4 temp_cast_3 = (_ReMap.w).xxxx;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = Unity_SafeNormalize( ase_tanViewDir );
				float2 Offset1 = ( ( (temp_cast_2 + (tex2DNode4 - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)).r - 1 ) * ase_tanViewDir.xy * (0.0 + (_CScale - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) ) + uv_MainTex;
				float4 tex2DNode9 = tex2D( _MainTex, Offset1 );
				#if defined(_SWITCHP_R)
				float staticSwitch11 = tex2DNode9.r;
				#elif defined(_SWITCHP_A)
				float staticSwitch11 = tex2DNode9.a;
				#else
				float staticSwitch11 = tex2DNode9.r;
				#endif
				float4 lerpResult12 = lerp( _OutColor , ( _InnColor * tex2D( _liuguangTex, panner28 ) ) , staticSwitch11);
				#if defined(_SWITCHP_R)
				float staticSwitch5 = tex2DNode4.r;
				#elif defined(_SWITCHP_A)
				float staticSwitch5 = tex2DNode4.a;
				#else
				float staticSwitch5 = tex2DNode4.r;
				#endif
				float MainP71 = staticSwitch5;
				float2 uv_DisTex = i.ase_texcoord1.zw * _DisTex_ST.xy + _DisTex_ST.zw;
				float4 texCoord39 = i.ase_texcoord5;
				texCoord39.xy = i.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMEDIS_ON
				float staticSwitch38 = texCoord39.x;
				#else
				float staticSwitch38 = _disc;
				#endif
				float smoothstepResult45 = smoothstep( ( 1.0 - _dissoft ) , _dissoft , saturate( ( ( tex2D( _DisTex, uv_DisTex ).r + 1.0 ) - ( staticSwitch38 * 2.0 ) ) ));
				float2 uv_SpawnTex = i.ase_texcoord1.zw * _SpawnTex_ST.xy + _SpawnTex_ST.zw;
				float4 texCoord53 = i.ase_texcoord5;
				texCoord53.xy = i.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMESPA_ON
				float staticSwitch52 = texCoord53.y;
				#else
				float staticSwitch52 = _happen;
				#endif
				float smoothstepResult59 = smoothstep( ( 1.0 - _happensoft ) , _happensoft , saturate( ( ( tex2D( _SpawnTex, uv_SpawnTex ).r + 1.0 ) - ( ( 1.0 - staticSwitch52 ) * 2.0 ) ) ));
				float4 appendResult14 = (float4(lerpResult12.rgb , ( MainP71 * smoothstepResult45 * smoothstepResult59 * _InnColor.a )));
				
				
				finalColor = ( i.ase_color * appendResult14 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;67;-2516.202,-218.1087;Inherit;False;1595.732;577.2711;简易地裂;14;3;11;9;1;8;6;7;18;70;19;71;5;4;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2376.945,378.9763;Inherit;False;1455.46;464.7801;流光纹理;10;29;25;24;20;28;26;22;21;68;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2320.12,871.9648;Inherit;False;1399.511;534.917;软溶解;13;45;43;44;37;36;38;33;42;35;32;34;39;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2442.857,1430.13;Inherit;False;1530.245;491.3259;渐变出现（第二套溶解）;14;59;56;57;58;49;47;46;48;55;50;51;53;52;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2411.616,1674.328;Inherit;False;Property;_happen;出现程度;16;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;52;-2146.385,1725.606;Inherit;False;Property;_customespa;CustomeY控制出现;18;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-2354.884,1751.307;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;51;-1928.086,1730.805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1776.287,1731.208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1912.285,1800.105;Inherit;False;Constant;_Float5;Float 5;15;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1913.686,1658.108;Inherit;False;Constant;_Float4;Float 4;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-1751.887,1494.808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-1610.786,1495.308;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1624.484,1612.806;Inherit;False;Property;_happensoft;出现软硬;17;0;Create;False;0;0;0;False;0;False;0;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;57;-1333.584,1587.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;-1364.284,1494.307;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;59;-1147.563,1569.804;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2257.745,1165.559;Inherit;False;Property;_disc;溶解强度;12;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-2199.745,1242.559;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1542.443,989.5596;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;42;-1405.751,989.5596;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-1737.747,990.5596;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;38;-1984.746,1165.559;Inherit;False;Property;_customedis;CustomeX控制溶解;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1780.747,1170.559;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1911.746,1263.559;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1610.747,1159.559;Inherit;False;Property;_dissoft;溶解软硬;13;0;Create;False;0;0;0;False;0;False;0;0.499;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1361.748,1057.559;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-1152.455,990.3063;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-2169.352,906.6272;Inherit;True;Property;_DisTex;溶解贴图;11;1;[Header];Create;False;1;DissolveTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-2010.746,1096.546;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-2499.231,-99.71356;Inherit;True;Property;_MainTex;地裂贴图;0;1;[Header];Create;False;1;MainTex;0;0;False;0;False;-1;None;e0183e60b5677b5418b5712f74fdba19;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-689.272,464.8468;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-907.7173,352.7169;Inherit;False;Property;_InnColor;表面颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0,1;2,0.7058824,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;26;-2005.79,537.4011;Inherit;False;Polar Coordinates;-1;;1;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-2146.768,609.8549;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-2230.573,479.8065;Inherit;False;1;29;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;21;-1638.299,509.0768;Inherit;False;Property;_jizuobiao;是否启用极坐标流光;7;0;Create;False;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;2;off;on;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;28;-1419.696,513.6962;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;29;-1246.594,485.4148;Inherit;True;Property;_liuguangTex;流光贴图;6;1;[Header];Create;False;1;LiuguangTex;0;0;False;0;False;-1;None;862570ac1240e6a4eb4a7198db6bf068;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;24;-1572.91,626.9252;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1785.74,616.5814;Inherit;False;Property;_LiuUspeed;流光U速度;10;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1786.74,690.5814;Inherit;False;Property;_LiuVspeed;流光V速度;9;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;22;-2360.255,613.739;Inherit;False;Property;_liuguang_ST;流光极坐标中心和重铺;8;0;Create;False;0;0;0;False;0;False;1,5,0,0;0.5,0.5,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;5;-2209.229,-76.71358;Inherit;False;Property;_SwitchP;切换贴图通道;2;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-2051.481,-75.62231;Inherit;False;MainP;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;19;-2205.599,39.28329;Inherit;False;Property;_ReMap;高度重映射(建议默认);1;0;Create;False;0;0;0;False;0;False;0,1,1,0;0,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;18;-1813.333,43.1313;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1850.01,-78.9502;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-1805.577,208.2014;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxMappingNode;1;-1620.369,14.77057;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;9;-1401.655,-10.10612;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-1122.443,-158.4276;Inherit;False;Property;_OutColor;深处颜色;5;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2002.076,37.27822;Inherit;False;71;MainP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;11;-1117.586,15.49938;Inherit;False;Property;_SwitchP2;SwitchP;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;R;A;Reference;5;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;12;-494.1122,-158.8504;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;46;-2068.989,1466.709;Inherit;True;Property;_SpawnTex;出现贴图(第二套溶解);15;1;[Header];Create;False;1;SpawnTex;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-353.7528,382.3598;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-523.3958,378.3075;Inherit;False;71;MainP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-117.4481,-158.9129;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;61;-64.02048,-319.2319;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;116.6609,-183.1195;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;254.3559,-181.7839;Float;False;True;-1;2;ASEMaterialInspector;100;5;A201-Shader/Built-in/进阶功能/卡通地裂带溶解;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2264.695,214.7657;Inherit;False;Property;_CScale;地裂深度;3;0;Create;False;0;0;0;False;0;False;0;0.118;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;73;-1990.154,151.6105;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
WireConnection;52;1;54;0
WireConnection;52;0;53;2
WireConnection;51;0;52;0
WireConnection;50;0;51;0
WireConnection;50;1;55;0
WireConnection;47;0;46;1
WireConnection;47;1;48;0
WireConnection;49;0;47;0
WireConnection;49;1;50;0
WireConnection;57;0;58;0
WireConnection;56;0;49;0
WireConnection;59;0;56;0
WireConnection;59;1;57;0
WireConnection;59;2;58;0
WireConnection;35;0;33;0
WireConnection;35;1;36;0
WireConnection;42;0;35;0
WireConnection;33;0;32;1
WireConnection;33;1;34;0
WireConnection;38;1;40;0
WireConnection;38;0;39;1
WireConnection;36;0;38;0
WireConnection;36;1;37;0
WireConnection;43;0;44;0
WireConnection;45;0;42;0
WireConnection;45;1;43;0
WireConnection;45;2;44;0
WireConnection;30;0;13;0
WireConnection;30;1;29;0
WireConnection;26;1;20;0
WireConnection;26;2;25;0
WireConnection;26;3;22;3
WireConnection;26;4;22;4
WireConnection;25;0;22;1
WireConnection;25;1;22;2
WireConnection;21;1;20;0
WireConnection;21;0;26;0
WireConnection;28;0;21;0
WireConnection;28;2;24;0
WireConnection;29;1;28;0
WireConnection;24;0;68;0
WireConnection;24;1;69;0
WireConnection;5;1;4;1
WireConnection;5;0;4;4
WireConnection;71;0;5;0
WireConnection;18;0;4;0
WireConnection;18;1;19;1
WireConnection;18;2;19;2
WireConnection;18;3;19;3
WireConnection;18;4;19;4
WireConnection;1;0;6;0
WireConnection;1;1;18;0
WireConnection;1;2;73;0
WireConnection;1;3;8;0
WireConnection;9;1;1;0
WireConnection;11;1;9;1
WireConnection;11;0;9;4
WireConnection;12;0;3;0
WireConnection;12;1;30;0
WireConnection;12;2;11;0
WireConnection;60;0;72;0
WireConnection;60;1;45;0
WireConnection;60;2;59;0
WireConnection;60;3;13;4
WireConnection;14;0;12;0
WireConnection;14;3;60;0
WireConnection;62;0;61;0
WireConnection;62;1;14;0
WireConnection;0;0;62;0
WireConnection;73;0;7;0
ASEEND*/
//CHKSM=A20B5A951EF3193815285FBB566AEA152D211643