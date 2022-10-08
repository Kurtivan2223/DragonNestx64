//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float2 g_fBlurRadius			: BLURRADIUS;

texture2D g_LookupTex : LOOKUPTEX;
sampler2D g_LookupTexSampler = sampler_state
{
	Texture = < g_LookupTex >;
    AddressU = Clamp;
    AddressV = Wrap;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BackBuffer : BACKBUFFER;
sampler2D g_BackBufferSampler = sampler_state
{
	Texture = < g_BackBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BlurHoriBuffer : BLURHORI;
sampler2D g_BlurHoriSampler = sampler_state
{
	Texture = < g_BlurHoriBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
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
VertexOutput WaterColorFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 BlurHoriPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BackBufferSampler, TexCoord + g_BlurOffsetHori[ i ] * g_fBlurRadius ).xyz * g_fBlurWeights[ i ];
	}

	Result.w = 1.0f;
	
	return Result;
}

float4 BlurVertPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	int i;
	float4 Result;
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BlurHoriSampler, TexCoord + g_BlurOffsetVert[ i ] * g_fBlurRadius ).xyz * g_fBlurWeights[ i ];
	}
	
	Result.w = 1.0f;
	
	return Result;
}

float4 StairPS( float2 TexCoord : TEXCOORD0 ) : COLOR0
{
	float4 Result = tex2D( g_BackBufferSampler, TexCoord );
	float fBrightness = max( Result.x, max( Result.y, Result.z ) );
	float fModiBrightness = tex2D( g_LookupTexSampler, float2( fBrightness, fBrightness ) ).x;
	Result.xyz *= ( fModiBrightness / fBrightness );
	
	return Result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique BlurHoriTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 WaterColorFilterVS();	
		PixelShader  = compile ps_2_0 BlurHoriPS();
    }
}

technique BlurVertTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 WaterColorFilterVS();
		PixelShader  = compile ps_2_0 BlurVertPS();
    }
}

technique StairTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 WaterColorFilterVS();	
		PixelShader  = compile ps_2_0 StairPS();
    }
}
