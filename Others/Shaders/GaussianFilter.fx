//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float2 g_fBlurRadius			: BLURRADIUS;

texture2D g_GaussianSource : GAUSSIANSOURCE;
sampler2D g_GaussianSourceSampler = sampler_state
{
	Texture = < g_GaussianSource >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

#define BLUR_COUNT		13
float2 g_BlurOffsetHori[ BLUR_COUNT ] =
{
    { -0.5f,		0.0f },
    { -0.416666f,	0.0f },
    { -0.333333f,	0.0f },
    { -0.25f,		0.0f },
    { -0.166666f,	0.0f },
    { -0.0833333f,	0.0f },
    {  0.0f,		0.0f },
    { 0.0833333f,	0.0f },
    { 0.166666f,	0.0f },
    { 0.25f,		0.0f },
    { 0.333333f,	0.0f },
    { 0.416666f,	0.0f },
    { 0.5f,			0.0f },
};

float2 g_BlurOffsetVert[ BLUR_COUNT ] =
{
    { 0,	-0.5f		 },
    { 0,	-0.416666f	 },
    { 0,	-0.333333f	 },
    { 0,	-0.25f		 },
    { 0,	-0.166666f	 },
    { 0,	-0.0833333f	 },
    { 0,	0.0f		 },
    { 0,	0.0833333f	 },
    { 0,	0.166666f	 },
    { 0,	0.25f		 },
    { 0,	0.333333f	 },
    { 0,	0.416666f	 },
    { 0,	0.5f		 },
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
VertexOutput GaussianFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 GaussianHoriPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_GaussianSourceSampler, TexCoord + g_BlurOffsetHori[ i ] * g_fBlurRadius ).xyz * g_fBlurWeights[ i ];
	}

	Result.w = 1.0f;
	
	return Result;
}

float4 GaussianVertPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_GaussianSourceSampler, TexCoord + g_BlurOffsetVert[ i ] * g_fBlurRadius ).xyz * g_fBlurWeights[ i ];
	}
	
	Result.w = 1.0f;
	
	return Result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique BloomHoriTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 GaussianFilterVS();	
		PixelShader  = compile ps_2_0 GaussianHoriPS();
    }
}

technique BloomVertTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 GaussianFilterVS();
		PixelShader  = compile ps_2_0 GaussianVertPS();
    }
}
