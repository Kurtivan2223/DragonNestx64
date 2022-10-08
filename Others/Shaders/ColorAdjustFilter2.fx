//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_fSceneShadow		: SCENESHADOW;
float4 g_fSceneMidTone		: SCENEMIDTONE;
float4 g_fSceneHilight		: SCENEHILIGHT;
float4 g_fSceneLuminanceWeight	: SCENELUMINANCEWEIGHT;
float g_fSceneSaturation	: SCENESATURATION;

float4 g_fHilightMinParam		: HILIGHTMINPARAM;
float4 g_fHilightMulParam		: HILIGHTMULPARAM;
float4 g_fHilightCenterParam	: HILIGHTCENTERPARAM;
float4 g_fHilightMulAddParam	: HILIGHTMULADDPARAM;

float4 g_fMidToneMinParam		: MIDTONEMINPARAM;
float4 g_fMidToneMulParam		: MIDTONEMULPARAM;
float4 g_fMidToneCenterParam	: MIDTONECENTERPARAM;
float4 g_fMidToneMulAddParam	: MIDTONEMULADDPARAM;

float4 g_fShadowMinParam		: SHADOWMINPARAM;
float4 g_fShadowMulParam		: SHADOWMULPARAM;
float4 g_fShadowCenterParam		: SHADOWCENTERPARAM;
float4 g_fShadowMulAddParam		: SHADOWMULADDPARAM;

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
	float3 Color;
	float3 Hilight, MidTone, Shadow;
	
	Color = tex2D( g_BackBufferSampler, Input.TexCoord0 ).xyz;
	
	Hilight = abs( Color - g_fHilightCenterParam ) * g_fHilightMulParam + g_fHilightMinParam + max( 0, Color - g_fHilightCenterParam ) * g_fHilightMulAddParam;
	MidTone = abs( Color - g_fMidToneCenterParam ) * g_fMidToneMulParam + g_fMidToneMinParam + max( 0, Color - g_fMidToneCenterParam ) * g_fMidToneMulAddParam;
	Shadow = abs( Color - g_fShadowCenterParam ) * g_fShadowMulParam + g_fShadowMinParam + max( 0, Color - g_fShadowCenterParam ) * g_fShadowMulAddParam;

	Color += Hilight * g_fSceneHilight + MidTone * g_fSceneMidTone + Shadow * g_fSceneShadow;
	
    float3 ScaledLuminance = dot( Color.xyz, g_fSceneLuminanceWeight.xyz );
    float3 Result = Color * g_fSceneSaturation + ScaledLuminance;
	
	return float4( Result, 1.0f );
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
