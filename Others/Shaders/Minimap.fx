//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
texture2D g_MinimapTex : MINIMAP;
sampler2D g_MinimapSampler = sampler_state
{
	Texture = < g_MinimapTex >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_OpacityTex : MINIMAP;
sampler2D g_OpacitySampler = sampler_state
{
	Texture = < g_OpacityTex >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_EnemyTex : MINIMAP;
sampler2D g_EnemySampler = sampler_state
{
	Texture = < g_EnemyTex >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexMinimapInput
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexInput
{
    float3 Position				: POSITION;
    float4 Color					: COLOR0;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexMinimapOutput
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD1;
    float2 TexCoord1			: TEXCOORD2;
};

struct VertexOutput
{
    float4 Position				: POSITION;
    float4 Color					: TEXCOORD0;
    float2 TexCoord0			: TEXCOORD1;
    float2 TexCoord1			: TEXCOORD2;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexMinimapOutput MinimapVS( VertexMinimapInput Input ) 
{
	VertexMinimapOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;
	Output.TexCoord1 = ( Input.Position.xy + 1.0f ) * 0.5;
	Output.TexCoord1.y = 1.0f - Output.TexCoord1.y;

	return Output;
}

VertexOutput EnemyVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;
	Output.TexCoord1 = ( Input.Position.xy + 1.0f ) * 0.5;
	Output.TexCoord1.y = 1.0f - Output.TexCoord1.y;
	Output.Color = Input.Color;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 MinimapPS( VertexMinimapOutput Input ) : COLOR0
{
	float4 Minimap = tex2D( g_MinimapSampler, Input.TexCoord0 );
	float4 Opacity = tex2D( g_OpacitySampler, Input.TexCoord1 );

	return Minimap * Opacity.r;
}

float4 EnemyPS( VertexOutput Input ) : COLOR0
{
	float4 Enemy = tex2D( g_EnemySampler, Input.TexCoord0 );
	float4 Opacity = tex2D( g_OpacitySampler, Input.TexCoord1 );
	
	return Enemy * Opacity.r * Input.Color;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique MinimapTech
{
    pass p0 
    {
		VertexShader = compile vs_2_0 MinimapVS();
		PixelShader  = compile ps_2_0 MinimapPS();
    }
}

technique EnemyTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 EnemyVS();
		PixelShader  = compile ps_2_0 EnemyPS();
    }
}
 