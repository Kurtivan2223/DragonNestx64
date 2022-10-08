//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_fSceneLuminanceWeight	: SCENELUMINANCEWEIGHT;
float g_fSceneSaturation	: SCENESATURATION;

//#75661 Color Filter
float g_iMonochrome : MONOCHROME;
float3 g_fAbsoluteColor : ABSOLUTECOLOR;
//

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
	MinFilter = Point;
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
};

struct VertexOutput
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput ColorAdjustFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 ColorAdjustFilterPS( VertexOutput Input ) : COLOR0
{
	float3 Color = tex2D( g_BackBufferSampler, Input.TexCoord0 ).xyz;
	Color.x = tex2D( g_LookupTexSampler, Color.xx ).x;
	Color.y = tex2D( g_LookupTexSampler, Color.yy ).y;
	Color.z = tex2D( g_LookupTexSampler, Color.zz ).z;
	
    float3 ScaledLuminance = dot( Color.xyz, g_fSceneLuminanceWeight.xyz );
    float3 Result = Color * g_fSceneSaturation + ScaledLuminance;
	
	//#75661 Color Filter		
	if( g_iMonochrome > 0.0f )
		Result.xyz = (Result.x + Result.y + Result.z) / 3.0 + g_fAbsoluteColor;		
	else	
		Result = Result * g_fAbsoluteColor;
	//	
	
	return float4( Result, 1.0f );
}

float4 ColorAdjustFilterAlphaPS( VertexOutput Input ) : COLOR0
{
	float4 Color = tex2D( g_BackBufferSampler, Input.TexCoord0 );
	Color.x = tex2D( g_LookupTexSampler, Color.xx ).x;
	Color.y = tex2D( g_LookupTexSampler, Color.yy ).y;
	Color.z = tex2D( g_LookupTexSampler, Color.zz ).z;
	
    float3 ScaledLuminance = dot( Color.xyz, g_fSceneLuminanceWeight.xyz );
    float3 Result = Color * g_fSceneSaturation + ScaledLuminance;
	
	return float4( Result, Color.w );
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique ColorAdjustTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 ColorAdjustFilterVS();
		PixelShader  = compile ps_2_0 ColorAdjustFilterPS();
    }
}

technique ColorAdjustAlphaTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 ColorAdjustFilterVS();
		PixelShader  = compile ps_2_0 ColorAdjustFilterAlphaPS();
    }
}