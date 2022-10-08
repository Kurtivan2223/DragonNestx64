//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef BAKE_VELOCITY
float4x4 g_PrevViewRotProjMat		: PREVVIEWROTPROJ;
#endif

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
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_ViewRotProjMat		: VIEWROTPROJ;

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
    float4 ProjPos				: TEXCOORD1;
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD2;
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
	Output.Position.z = Output.Position.w*0.99999;;
	Output.TexCoord0 = Input.TexCoord0;
	Output.ProjPos = float4(0,0,0,0);

	return Output;
}
#else
VertexOutput SkyBoxVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_ViewRotProjMat );
	Output.Position.z = Output.Position.w*0.99999;;
	Output.TexCoord0 = Input.TexCoord0;
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

