//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef BAKE_VELOCITY
float4x4 g_PrevViewRotProjMat		: PREVVIEWROTPROJ;
#endif

float g_fElapsedTime : ELAPSEDTIME;
//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
/////////////////////////////// ///////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_ViewRotProjMat		: VIEWROTPROJ;

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

#include "CalcFog.fxh"

float4 g_ScreenSizeScale		: SCREENSIZESCALE = float4(  0.5f + 0.5f / 1280.0f, 0.5f - 0.5f / 800.0f, 0, 0);
// Scale Distribution
#define SCALE_DISTRIBUTE (100.0f)
#define INV_SCALE_DISTRIBUTE (0.01f)

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

texture2D g_LayerTex : LAYERTEXTURE
< 
	string UIName = "Layer Texture";
>;
sampler2D g_LayerSampler = sampler_state
{
	texture = < g_LayerTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float g_RotationSpeed : ROTATIONSPEED
<
    string UIName = "Rotation Speed";
> = { 0.005f };

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
    float2 TexCoord1			: TEXCOORD1;
    float4 ProjPos				: TEXCOORD2;
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD3;
#endif
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
#ifdef BAKE_VELOCITY
    float4 Velocity				: COLOR2;
#endif
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _3DSMAX_
float4x4 g_WorldViewProjMat			: WORLDVIEWPROJ;
VertexOutput SkyBoxVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewProjMat );
	Output.Position.z = Output.Position.w*0.999;;
	Output.TexCoord0 = Input.TexCoord0;
	Output.TexCoord1 = Input.TexCoord0;
	Output.TexCoord1.x += g_fElapsedTime * g_RotationSpeed;
	Output.ProjPos = Output.Position;

	return Output;
}
#else
VertexOutput SkyBoxVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_ViewRotProjMat );
	Output.Position.z = Output.Position.w*0.99999;;
	Output.TexCoord0 = Input.TexCoord0;
	Output.TexCoord1 = Input.TexCoord0;
	Output.TexCoord1.x += g_fElapsedTime * g_RotationSpeed;
	Output.ProjPos = Output.Position;

#ifdef BAKE_VELOCITY
	Output.Velocity = Output.Position.xy / Output.Position.w;
	float4 PrevWorldViewProjPos = mul( float4( Input.Position.xyz, 1.0f ), g_PrevViewRotProjMat );
	Output.Velocity -= PrevWorldViewProjPos.xy / PrevWorldViewProjPos.w;
#endif																					

	return Output;
}

#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput SkyBoxPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 layerTexture = tex2D( g_LayerSampler, Input.TexCoord1 );
	
	Output.Color.rgb = lerp( Output.Color.rgb, layerTexture.rgb, layerTexture.a);

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( 1000000.0f, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique SkyBoxTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SkyBoxVS();
		PixelShader  = compile ps_2_0 SkyBoxPS();
    }
}

