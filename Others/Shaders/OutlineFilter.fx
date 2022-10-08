#include "CalcBlendBone.fxh"
#include "CalcFog.fxh"
#include "CalcLight.fxh"
#include "CalcShadow.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat				: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
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

float g_fOutlineStrength	: OUTLINESTRENGTH;
float2 g_fPixelSize			: PIXELSIZE;
float4 g_OutlineColor		: OUTLINECOLOR;

texture2D g_OutlineSource	: OUTLINESOURCE;
sampler2D g_OutlineSourceSampler = sampler_state
{
	Texture = < g_OutlineSource >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BlurBuffer : HORIBLURBUFFER;
sampler2D g_BlurBufferSampler = sampler_state
{
	Texture = < g_BlurBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

#define BLUR_COUNT		13
float2 g_BlurOffsetHori[ BLUR_COUNT ] =
{
    { -6, 0 },
    { -5, 0 },
    { -4, 0 },
    { -3, 0 },
    { -2, 0 },
    { -1, 0 },
    {  0, 0 },
    {  1, 0 },
    {  2, 0 },
    {  3, 0 },
    {  4, 0 },
    {  5, 0 },
    {  6, 0 },
};

float2 g_BlurOffsetVert[ BLUR_COUNT ] =
{
    { 0, -6 },
    { 0, -5 },
    { 0, -4 },
    { 0, -3 },
    { 0, -2 },
    { 0, -1 },
    { 0,  0 },
    { 0,  1 },
    { 0,  2 },
    { 0,  3 },
    { 0,  4 },
    { 0,  5 },
    { 0,  6 },
};

float g_fBlurWeights[ BLUR_COUNT ] = 
{
    0.002216,
    0.008764,
    0.026995,
    0.064759,
    0.120985,
    0.176033,
    0.199471,
    0.176033,
    0.120985,
    0.064759,
    0.026995,
    0.008764,
    0.002216,
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexInputAni {
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexInputBloom
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexOutputBloom
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput DiffuseVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

VertexOutput DiffuseAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
    float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;

    return Output;
}

VertexOutputBloom BloomFilterVS( VertexInputBloom Input ) 
{
	VertexOutputBloom Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 DiffusePS( VertexOutput Input ) : COLOR0
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	clip( DiffuseTex.a - ( 0x7f / 255.0f + 0.0001f ) );

	return float4( g_OutlineColor.xyz * g_fOutlineStrength, 1.0f );
}

float4 HoriFilterPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result += tex2D( g_OutlineSourceSampler, TexCoord + g_BlurOffsetHori[ i ] * g_fPixelSize ) * g_fBlurWeights[ i ];
	}
	return Result;
}

float4 VertFilterPS( VertexOutputBloom Input ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result += tex2D( g_BlurBufferSampler, Input.TexCoord0 + g_BlurOffsetVert[ i ] * g_fPixelSize ) * g_fBlurWeights[ i ];
	}
	float fOriginalAlpha = tex2D( g_OutlineSourceSampler, Input.TexCoord0 ).w + 0.0001f;
	clip( 1.0f - fOriginalAlpha );
	return float4( Result.xyz, 1.0f );
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique DiffuseTech			// 0
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseVS();
		PixelShader  = compile ps_2_0 DiffusePS();
    }
}
technique DiffuseAniTech		// 1
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseAniVS();
		PixelShader  = compile ps_2_0 DiffusePS();
    }
}

technique BloomHoriTech			// 2
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 HoriFilterPS();
    }
}

technique BloomVertTech			// 3
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 VertFilterPS();
    }
}
