// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/Built-in/特殊制作/雪地材质与脚印"
{
	Properties
	{
		_Metallic("金属度", Range( 0 , 1)) = 0
		_Smoothness("平滑度", Range( 0 , 1)) = 0
		[IntRange]_Tesslla("细分等级", Range( 1 , 20)) = 0
		[HDR][Header(Albedo)]_MainTex("基础纹理", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		[Header(Normal)]_NormalTex("法线贴图", 2D) = "bump" {}
		_NormalScale("法线强度", Float) = 1
		[HDR][Header(Fresnel)]_FreColor("菲涅尔颜色", Color) = (1,1,1,1)
		_FreScale("菲涅尔强度", Float) = 1
		_FrePow("菲涅尔范围", Float) = 2.8
		[Header(Spark)]_Spark("高光", 2D) = "white" {}
		[HDR]_SparkColor("高光颜色", Color) = (1,1,1,1)
		_SparkPow("高光强度", Float) = 2.99
		_SparkRangePow("高光范围", Float) = 6.5
		[Header(VertexOffset)]_VertexOffset("顶点偏移", 2D) = "white" {}
		_VOffsetMult("偏移强度", Float) = 0.25
		[NoScaleOffset]_Step("足迹RT", 2D) = "white" {}
		[HDR]_StepColor("足迹颜色", Color) = (0.128311,0.2306703,0.5566038,1)
		_StepMult("足迹深度", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _VertexOffset;
		uniform float4 _VertexOffset_ST;
		uniform sampler2D _Step;
		uniform float _StepMult;
		uniform float _VOffsetMult;
		uniform sampler2D _NormalTex;
		uniform float4 _NormalTex_ST;
		uniform float _NormalScale;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _MainColor;
		uniform float4 _StepColor;
		uniform float4 _FreColor;
		uniform float _FreScale;
		uniform float _FrePow;
		uniform sampler2D _Spark;
		uniform float4 _Spark_ST;
		uniform float _SparkPow;
		uniform float _SparkRangePow;
		uniform float4 _SparkColor;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Tesslla;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_0 = (_Tesslla).xxxx;
			return temp_cast_0;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_VertexOffset = v.texcoord.xy * _VertexOffset_ST.xy + _VertexOffset_ST.zw;
			float2 uv_Step47 = v.texcoord;
			float4 tex2DNode47 = tex2Dlod( _Step, float4( uv_Step47, 0, 0.0) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _VertexOffset, float4( uv_VertexOffset, 0, 0.0) ).r - ( tex2DNode47.r * _StepMult ) ) * ase_vertexNormal * _VOffsetMult );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalTex = i.uv_texcoord * _NormalTex_ST.xy + _NormalTex_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _NormalTex, uv_NormalTex ), _NormalScale );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Step47 = i.uv_texcoord;
			float4 tex2DNode47 = tex2D( _Step, uv_Step47 );
			float4 lerpResult57 = lerp( ( tex2DNode1 * _MainColor ) , ( tex2DNode1 * _StepColor ) , tex2DNode47.r);
			o.Albedo = lerpResult57.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV10 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode10 = ( 0.0 + _FreScale * pow( 1.0 - fresnelNdotV10, _FrePow ) );
			float2 uv_Spark = i.uv_texcoord * _Spark_ST.xy + _Spark_ST.zw;
			float4 temp_cast_1 = (_SparkPow).xxxx;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult17 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult19 = dot( normalizeResult17 , ase_worldNormal );
			o.Emission = ( ( _FreColor * fresnelNode10 ) + ( pow( tex2D( _Spark, uv_Spark ) , temp_cast_1 ) * pow( saturate( dotResult19 ) , _SparkRangePow ) * _SparkColor ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
Node;AmplifyShaderEditor.CommentaryNode;63;-587.7402,-616.6746;Inherit;False;1044.894;582.696;基础色;7;65;1;56;27;57;58;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-596.2324,179.1854;Inherit;False;893.7682;618.3094;顶点偏移;9;33;52;31;34;32;54;53;47;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-2055.407,-175.2284;Inherit;False;1423.668;728.6052;雪地高光;15;25;62;60;22;23;14;15;19;24;20;18;17;16;21;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-1393.915,-651.2991;Inherit;False;763.7902;443.1535;菲涅尔;7;37;36;10;11;12;5;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-1379.575,-563.6395;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-1355.863,-423.5924;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-768.871,-485.7362;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-843.3275,39.16866;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-576.6374,13.93871;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;90.6218,568.9198;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1781.81,141.9964;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;17;-1670.652,143.8929;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;18;-1757.565,236.707;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;19;-1532.565,142.707;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-1962.823,208.5377;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;14;-2031.802,62.50298;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;23;-1468.04,-71.83397;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;22;-1333.822,143.7045;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;62;-1154.432,145.565;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;323.3632,69.32823;Inherit;False;Property;_Metallic;金属度;0;0;Create;False;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;322.8055,151.4044;Inherit;False;Property;_Smoothness;平滑度;1;0;Create;False;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;809.3512,-39.34183;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;A201-Shader/Built-in/特殊制作/雪地材质与脚印;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;2;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;46;538.1275,291.4957;Inherit;False;Property;_Tesslla;细分等级;2;1;[IntRange];Create;False;0;0;0;False;0;False;0;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-69.40382,655.7377;Inherit;False;Property;_VOffsetMult;偏移强度;15;0;Create;False;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-149.4036,460.0217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-296.1485,505.294;Inherit;False;Property;_StepMult;足迹深度;18;0;Create;False;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;32;-299.7038,593.1761;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;52;-23.87212,387.9003;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1328.617,227.3617;Inherit;False;Property;_SparkRangePow;高光范围;13;0;Create;False;0;0;0;False;0;False;6.5;6.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;10;-1067.567,-439.9044;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-140.1885,76.24896;Inherit;False;Property;_NormalScale;法线强度;6;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1204.174,-363.1588;Inherit;False;Property;_FreScale;菲涅尔强度;8;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-1132.862,364.4058;Inherit;False;Property;_SparkColor;高光颜色;11;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-1643.212,66.23577;Inherit;False;Property;_SparkPow;高光强度;12;0;Create;False;0;0;0;False;0;False;2.99;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-984.3171,-609.42;Inherit;False;Property;_FreColor;菲涅尔颜色;7;2;[HDR];[Header];Create;False;1;Fresnel;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;-577.9257,430.6794;Inherit;True;Property;_Step;足迹RT;16;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;38.23455,-399.3153;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;24.27758,-223.768;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;57;224.3663,-247.3749;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;27;-245.5854,-379.074;Inherit;False;Property;_MainColor;主颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;56;-242.347,-205.2323;Inherit;False;Property;_StepColor;足迹颜色;17;1;[HDR];Create;False;0;0;0;False;0;False;0.128311,0.2306703,0.5566038,1;0.128311,0.2306703,0.5566038,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-356.5529,-575.8087;Inherit;True;Property;_MainTex;基础纹理;3;2;[HDR];[Header];Create;False;1;Albedo;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-579.3723,-551.6864;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-1204.174,-290.1588;Inherit;False;Property;_FrePow;菲涅尔范围;9;0;Create;False;0;0;0;False;0;False;2.8;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-2008.05,-105.3593;Inherit;False;0;20;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-550.4918,261.2463;Inherit;False;0;31;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-347.4918,0.2463379;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;31;-336.857,236.0224;Inherit;True;Property;_VertexOffset;顶点偏移;14;1;[Header];Create;False;1;VertexOffset;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-1790.935,-128.5956;Inherit;True;Property;_Spark;高光;10;1;[Header];Create;False;1;Spark;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;22.83304,-23.76024;Inherit;True;Property;_NormalTex;法线贴图;5;1;[Header];Create;False;1;Normal;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;37;0;36;0
WireConnection;37;1;10;0
WireConnection;21;0;23;0
WireConnection;21;1;62;0
WireConnection;21;2;25;0
WireConnection;30;0;37;0
WireConnection;30;1;21;0
WireConnection;33;0;52;0
WireConnection;33;1;32;0
WireConnection;33;2;34;0
WireConnection;16;0;14;0
WireConnection;16;1;15;0
WireConnection;17;0;16;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;23;0;20;0
WireConnection;23;1;24;0
WireConnection;22;0;19;0
WireConnection;62;0;22;0
WireConnection;62;1;60;0
WireConnection;0;0;57;0
WireConnection;0;1;2;0
WireConnection;0;2;30;0
WireConnection;0;3;44;0
WireConnection;0;4;45;0
WireConnection;0;11;33;0
WireConnection;0;14;46;0
WireConnection;53;0;47;1
WireConnection;53;1;54;0
WireConnection;52;0;31;1
WireConnection;52;1;53;0
WireConnection;10;0;6;0
WireConnection;10;4;5;0
WireConnection;10;2;11;0
WireConnection;10;3;12;0
WireConnection;28;0;1;0
WireConnection;28;1;27;0
WireConnection;58;0;1;0
WireConnection;58;1;56;0
WireConnection;57;0;28;0
WireConnection;57;1;58;0
WireConnection;57;2;47;1
WireConnection;1;1;65;0
WireConnection;31;1;67;0
WireConnection;20;1;66;0
WireConnection;2;1;68;0
WireConnection;2;5;64;0
ASEEND*/
//CHKSM=52AE76621196B0B34A1F87BEDDD059350BB7E3C0