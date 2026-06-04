// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FxClass/AdditiveMask"
{
	Properties
	{
		[HDR]_MainColor1("主色调", Color) = (0.6792453,0.6792453,0.6792453,0)
		_MainTex1("主贴图", 2D) = "white" {}
		_MainTexUspeed1("主贴图U速度", Float) = 0
		_MianTexVspeed1("主贴图V速度", Float) = 0
		_SecondTex1("纹理贴图", 2D) = "white" {}
		_SecTexUspeed1("纹理贴图U速度", Float) = 0
		_SecTexVspeed1("纹理贴图V速度", Float) = 0
		_MaskTex1("遮罩贴图", 2D) = "white" {}
		_Softedge1("软粒子", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "PreviewType" = "Plane" "IsEmissive" = "true" }
		Cull Off
		ZWrite Off
		Blend One One

		Pass
		{
			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile _ SOFTPARTICLES_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 uvMain : TEXCOORD0;
				float2 uvMask : TEXCOORD1;
				float2 uvSecond : TEXCOORD2;
				float4 projPos : TEXCOORD3;
			};

			sampler2D _SecondTex1;
			sampler2D _MaskTex1;
			sampler2D _MainTex1;
			float4 _MainColor1;
			float4 _MaskTex1_ST;
			float4 _MainTex1_ST;
			float _MainTexUspeed1;
			float _MianTexVspeed1;
			float _SecTexUspeed1;
			float _SecTexVspeed1;
			float _Softedge1;
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uvMain = TRANSFORM_TEX(v.uv, _MainTex1);
				o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex1);
				o.uvSecond = v.uv;
				o.projPos = ComputeScreenPos(o.pos);
				return o;
			}

			fixed ComputeSoftFade(v2f i)
			{
				if (_Softedge1 <= 0.0001)
					return 1.0;

				#if defined(SOFTPARTICLES_ON)
					float4 projPos = i.projPos;
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
					float partZ = LinearEyeDepth(projPos.z / projPos.w);
					return saturate(abs(sceneZ - partZ) / _Softedge1);
				#else
					return 1.0;
				#endif
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 secondPanner = i.uvMask + _Time.y * float2(_SecTexUspeed1, _SecTexVspeed1);
				float2 mainPanner = i.uvMain + _Time.y * float2(_MainTexUspeed1, _MianTexVspeed1);

				fixed secondTex = tex2D(_SecondTex1, secondPanner).r;
				fixed mainTex = tex2D(_MainTex1, mainPanner).r;
				fixed maskTex = tex2D(_MaskTex1, i.uvMask).r;
				fixed depthFade = ComputeSoftFade(i);
				fixed4 color = i.color * _MainColor1 * secondTex * mainTex * maskTex * depthFade * i.color.a;
				return fixed4(color.rgb, 1.0);
			}

			ENDHLSL
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;98;1828;614;1048.583;327.9868;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;28;-718.663,-293.8559;Inherit;False;Property;_MianTexVspeed1;主贴图V速度;4;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-718.663,-365.8559;Inherit;False;Property;_MainTexUspeed1;主贴图U速度;3;0;Create;False;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-730.3793,-30.39435;Inherit;False;Property;_SecTexVspeed1;纹理贴图V速度;7;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-731.3793,-98.3943;Inherit;False;Property;_SecTexUspeed1;纹理贴图U速度;6;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-658.663,-483.4979;Inherit;False;0;39;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-655.0793,-222.7943;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;32;-579.663,-363.8559;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-577.3793,-94.39429;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;36;-436.3792,-148.3944;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-387.6889,226.4415;Inherit;False;Property;_Softedge1;软粒子;9;0;Create;False;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;38;-438.6629,-417.856;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;44;-174.4364,-785.3474;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;42;-217.8853,206.797;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;40;-259.6528,-179.9875;Inherit;True;Property;_SecondTex1;纹理贴图;5;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-266.1821,10.6347;Inherit;True;Property;_MaskTex1;遮罩贴图;8;0;Create;False;0;0;False;0;False;-1;None;4c5ed528efef347438076da92444f1b0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;39;-259.6365,-447.449;Inherit;True;Property;_MainTex1;主贴图;2;0;Create;False;0;0;False;0;False;-1;None;c5876a02acc3dc14ba891c894e84c86b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;46;-212.9366,-618.7491;Inherit;False;Property;_MainColor1;主色调;1;1;[HDR];Create;False;0;0;False;0;False;0.6792453,0.6792453,0.6792453,0;0.6792453,0.6792453,0.6792453,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;245.6783,-460.8691;Inherit;False;7;7;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;676.3999,-387.7;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;FxClass/AdditiveMask;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;29;0
WireConnection;32;1;28;0
WireConnection;35;0;31;0
WireConnection;35;1;30;0
WireConnection;36;0;34;0
WireConnection;36;2;35;0
WireConnection;38;0;33;0
WireConnection;38;2;32;0
WireConnection;42;0;37;0
WireConnection;40;1;36;0
WireConnection;39;1;38;0
WireConnection;48;0;44;0
WireConnection;48;1;46;0
WireConnection;48;2;40;1
WireConnection;48;3;39;1
WireConnection;48;4;41;1
WireConnection;48;5;42;0
WireConnection;48;6;44;4
WireConnection;0;2;48;0
ASEEND*/
//CHKSM=F0F20164E943712B1343B02D1343B103F4E9CF90
