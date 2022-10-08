#include "CalcFog.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_ProjMat					: PROJ;
float4x4 g_BiasMat					: BIAS;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_DecalColor				: DECALCOLOR;

texture2D g_DiffuseTex : DIFFUSETEXTURE
< 
	string UIName = "Diffuse Texture";
>;
sampler2D g_DiffuseSampler = sampler_state
{
	texture = < g_DiffuseTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float Alpha					: DEPTH0;
};

struct VertexInputPoint
{
    float3 Position				: POSITION;
    float4 Color				: BLENDWEIGHT;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
    float Alpha					: TEXCOORD2;
};

struct VertexOutputPoint
{
    float4 Position				: POSITION;
    float4 TexCoord0			: TEXCOORD0;
    float4 Color				: TEXCOORD1;
    float4 Fog		    		: TEXCOORD2;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput DecalVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;
	
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;
	Output.Fog.zw = CalcFogValue( Output.Position.z );
	
	Output.Alpha = Input.Alpha;

	return Output;
}

VertexOutputPoint PointLightDecalVS( VertexInputPoint Input ) 
{
	VertexOutputPoint Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f), g_ProjMat );
	Output.TexCoord0 = mul( Output.Position, g_BiasMat);
	Output.Color = Input.Color;

	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;
	Output.Fog.zw = CalcFogValue( Output.Position.z );

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 DecalPS( VertexOutput Input ) : COLOR
{
	float4 Result = tex2D( g_DiffuseSampler, Input.TexCoord0 ) * g_DecalColor;
	Result.xyz = CalcFogColor( Result.xyz, Input.Fog );

	Result = Result * Input.Alpha;
	
	return Result;
}

float4 PointLightDecalPS( VertexOutputPoint Input ) : COLOR
{
	float4 TexColor = tex2D( g_DiffuseSampler, Input.TexCoord0.xy / Input.TexCoord0.w );
	float4 Result = TexColor * float4( Input.Color.xyz, 1.0f );
	// 포그가 진해지면 포인트라이트 점점 꺼준다..
	Result.xyz = lerp( TexColor.xyz, Result.xyz, Input.Fog.z );

	return Result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique DecalTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DecalVS();
		PixelShader  = compile ps_2_0 DecalPS();
    }
}

technique PointLightDecalTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 PointLightDecalVS();
		PixelShader  = compile ps_2_0 PointLightDecalPS();
    }
}
