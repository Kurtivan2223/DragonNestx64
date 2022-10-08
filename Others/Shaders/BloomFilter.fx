//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float g_fBloomScale		    : BLOOMSCALE;
float2 g_fPixelSize			: PIXELSIZE;

texture2D g_BackBuffer : BACKBUFFER;
sampler2D g_BackBufferSampler = sampler_state
{
	Texture = < g_BackBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
};

texture2D g_BrightPass : DOWNSAMPLEBUFFER;
sampler2D g_BrightPassSampler = sampler_state
{
	Texture = < g_BrightPass >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BloomHori : HORIBLURBUFFER;
sampler2D g_BloomHoriSampler = sampler_state
{
	Texture = < g_BloomHori >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BloomVert : VERTBLURBUFFER;
sampler2D g_BloomVertSampler = sampler_state
{
	Texture = < g_BloomVert >;
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

struct VertexOutput
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput BloomFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 BrightPassPS( VertexOutput Input ) : COLOR0
{
	float4 Result;
	
	Result.xyz = pow( tex2D( g_BackBufferSampler, Input.TexCoord0 ).xyz, 6.0f );
	Result.w = 1.0f;

	return Result;
}

float4 BloomHoriPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BrightPassSampler, TexCoord + g_BlurOffsetHori[ i ] * g_fPixelSize ).xyz * g_fBlurWeights[ i ] * g_fBloomScale;
	}

	Result.w = 1.0f;
	
	return Result;
}

float4 BloomVertPS( VertexOutput Input ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BloomHoriSampler, Input.TexCoord0 + g_BlurOffsetVert[ i ] * g_fPixelSize ).xyz * g_fBlurWeights[ i ] * g_fBloomScale;
	}
	
	Result.w = 1.0f;
	
	return Result;
}

float4 BloomCopyPS( VertexOutput Input ) : COLOR0
{
	float4 Result;
	
	Result.xyz = tex2D( g_BloomVertSampler, Input.TexCoord0 ).xyz;
	Result.xyz += tex2D( g_BackBufferSampler, Input.TexCoord0 );
	Result.w = 1.0f;
	
	return Result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique BrightPassTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 BrightPassPS();
    }
}

technique BloomHoriTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 BloomHoriPS();
    }
}

technique BloomVertTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 BloomVertPS();
    }
}

technique BloomCopyTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BloomFilterVS();
		PixelShader  = compile ps_2_0 BloomCopyPS();
    }
}
