// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "A201-Shader/特殊制作/固定扭曲与边缘色差(抖音色)_Douyinse"
{
	Properties
	{
		_Zhutu("主贴图", 2D) = "white" {}
		_Pianyiqiangdu("主贴图色差偏移度", Float) = 0.06
		_Niuqu("扭曲贴图", 2D) = "white" {}
		_Niuquqiangdu("扭曲强度", Float) = 0.07

		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Lambert keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Zhutu;
		uniform sampler2D _Niuqu;
		uniform float4 _Niuqu_ST;
		uniform float _Niuquqiangdu;
		uniform float _Pianyiqiangdu;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Niuqu = i.uv_texcoord * _Niuqu_ST.xy + _Niuqu_ST.zw;
			float2 lerpResult5 = lerp( i.uv_texcoord , (tex2D( _Niuqu, uv_Niuqu )).rg , _Niuquqiangdu);
			float3 appendResult16 = (float3(tex2D( _Zhutu, ( lerpResult5 + ( 1.0 * _Pianyiqiangdu ) ) ).r , tex2D( _Zhutu, lerpResult5 ).g , tex2D( _Zhutu, ( lerpResult5 + ( _Pianyiqiangdu * -1.0 ) ) ).b));
			o.Emission = appendResult16;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
215;191;1920;1022;1843.698;-13.28123;1.3;True;False
Node;AmplifyShaderEditor.SamplerNode;3;-1394,275.5;Inherit;True;Property;_Niuqu;Niuqu;1;0;Create;True;0;0;False;0;-1;05aa43dbbeddb24419e5b5b6e734d595;05aa43dbbeddb24419e5b5b6e734d595;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1093,437.5;Inherit;False;Property;_Niuquqiangdu;Niuquqiangdu;2;0;Create;True;0;0;False;0;0.07;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;4;-1106,277.5;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1117.53,622.5865;Inherit;False;Property;_Pianyiqiangdu;Pianyiqiangdu;4;0;Create;True;0;0;False;0;0.06;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1102.53,542.5865;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1110.53,704.5865;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1157,108.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-860,273.5;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-882.2094,684.9479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-880.2094,564.9479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-658.5297,675.5865;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-858.4,35.3;Inherit;True;Property;_Zhutu;Zhutu;3;0;Create;True;0;0;False;0;27fb0f15e82a5da4a9b075e522074e1c;27fb0f15e82a5da4a9b075e522074e1c;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-647.5297,285.5865;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-477,198.5;Inherit;True;Property;_主图;主图;0;0;Create;True;0;0;False;0;-1;c5f856ab3c5c154449d2a064b3df35c4;c5f856ab3c5c154449d2a064b3df35c4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-473.2094,632.9479;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;c5f856ab3c5c154449d2a064b3df35c4;c5f856ab3c5c154449d2a064b3df35c4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-481.2094,428.9479;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;c5f856ab3c5c154449d2a064b3df35c4;c5f856ab3c5c154449d2a064b3df35c4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-68.93118,379.501;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;280.2,175.9;Float;False;True;-1;2;ASEMaterialInspector;0;0;Lambert;douyinse;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;5;0;2;0
WireConnection;5;1;4;0
WireConnection;5;2;6;0
WireConnection;12;0;17;0
WireConnection;12;1;18;0
WireConnection;15;0;23;0
WireConnection;15;1;17;0
WireConnection;22;0;5;0
WireConnection;22;1;12;0
WireConnection;21;0;5;0
WireConnection;21;1;15;0
WireConnection;1;0;9;0
WireConnection;1;1;21;0
WireConnection;11;0;9;0
WireConnection;11;1;22;0
WireConnection;10;0;9;0
WireConnection;10;1;5;0
WireConnection;16;0;1;1
WireConnection;16;1;10;2
WireConnection;16;2;11;3
WireConnection;0;2;16;0
ASEEND*/
//CHKSM=CE0DC569244AAB8054E8EF776693DBF077F9AF9B