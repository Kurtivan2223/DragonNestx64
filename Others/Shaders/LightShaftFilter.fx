//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
texture2D g_LightShaftSourBuffer : LIGHTSHAFTSOUR;
sampler2D g_LightShaftSourSampler = sampler_state
{
	Texture = < g_LightShaftSourBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_LightShaftDestBuffer : LIGHTSHAFTDEST;
sampler2D g_LightShaftDestSampler = sampler_state
{
	Texture = < g_LightShaftDestBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
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
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
};

texture2D g_DepthTex : DEPTHTEX;
sampler2D g_DepthTexSampler = sampler_state
{
	Texture = < g_DepthTex >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
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
VertexOutput LightShaftFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 LightShaftFilterCopyPS( VertexOutput Input ) : COLOR0
{
	return tex2D( g_LightShaftSourSampler, Input.TexCoord0 );
}

float4 LightShaftFilterBlendPS( VertexOutput Input ) : COLOR0
{
	float4 Result = tex2D( g_LightShaftDestSampler, Input.TexCoord0 );
	Result.w = 0.5f;
	return Result;
}

float4 LightShaftFilterExtractPS( VertexOutput Input ) : COLOR0
{
	float fDepth = tex2D( g_DepthTexSampler, Input.TexCoord0 ).r;
	float4 Color = tex2D( g_BackBufferSampler, Input.TexCoord0 );
	if( fDepth < 9900.0f )
	{
		Color = float4( 0.0f, 0.0f, 0.0f, 1.0f );
	}
	return Color;
}

float4 LightShaftFilterFinalPS( VertexOutput Input ) : COLOR0
{
	float4 Color = tex2D( g_LightShaftSourSampler, Input.TexCoord0 );
	float4 OriginalColor = tex2D( g_BackBufferSampler, Input.TexCoord0 );
	Color.w = dot( Color.xyz, float3( 0.299999982f, 1.0f, 0.0f ) );
	Color.w = saturate( 1.0f - Color.w );
	float4 Result;
	Result = OriginalColor * Color.w + Color;
	return Result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique LightShaftCopyTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LightShaftFilterVS();
		PixelShader  = compile ps_2_0 LightShaftFilterCopyPS();
    }
}

technique LightShaftBlendTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LightShaftFilterVS();
		PixelShader  = compile ps_2_0 LightShaftFilterBlendPS();
    }
}

technique LightShaftExtractTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LightShaftFilterVS();
		PixelShader  = compile ps_2_0 LightShaftFilterExtractPS();
    }
}

technique LightShaftFinalTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LightShaftFilterVS();
		PixelShader  = compile ps_2_0 LightShaftFilterFinalPS();
    }
}
