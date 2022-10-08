//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float g_fElapsedTime				: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
texture2D g_RainfallTex : RAINFALLTEXTURE;
sampler2D g_RainfallSampler = sampler_state
{
	texture = < g_RainfallTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float g_fRainSpeed			: RAINSPEED;
float g_fRainStretchValue	: RAINSTRETCHVALUE;
float g_fRainOffset			: RAINOFFSET;
float3 g_RainVertexOffset	: RAINVERTEXOFFSET;

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
VertexOutput RainfallVS( VertexInput Input ) 
{
	VertexOutput Output;
	float3 Position;

	if( Input.Position.y > 0.0f )
	{
		Position = Input.Position + g_RainVertexOffset;
	}
	else
	{
		Position = Input.Position - g_RainVertexOffset;
	}
	Output.Position = mul( float4( Position, 1.0f ), g_WorldViewProjMat );
	Output.TexCoord0.x = Input.TexCoord0.x + g_fRainOffset;
	Output.TexCoord0.y = Input.TexCoord0.y - g_fElapsedTime * g_fRainSpeed;
	Output.TexCoord0.y *= g_fRainStretchValue;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 RainfallPS( VertexOutput Input ) : COLOR
{
	return tex2D( g_RainfallSampler, Input.TexCoord0 );
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique RainfallTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 RainfallVS();
		PixelShader  = compile ps_2_0 RainfallPS();
    }
}