#include "CalcBlendBone.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_ProjMat			: PROJ;

float4 g_MaterialAmbient : MATERIALAMBIENT
<
    string UIName = "Ambient Material";
> = { 0.682f, 0.682f, 0.682f, 1.0f};

float4 g_MaterialDiffuse : MATERIALDIFFUSE
<
    string UIName = "Diffuse Material";
> = { 0.682f, 0.682f, 0.682f, 1.0f};

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

struct VertexInputAni {
    float3 Position				: POSITION; 
    float2 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD1;
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

VertexOutput FlatVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

VertexOutput FlatAniVS( VertexInputAni Input ) 
{
	VertexOutput Output;

	float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;
	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput FlatPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	Output.Color *= g_MaterialAmbient;
	
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( 1000000.0f, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( 0.0f, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique FlatTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 FlatVS();
		PixelShader  = compile ps_2_0 FlatPS();
    }
}

technique FlatAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 FlatAniVS();
		PixelShader  = compile ps_2_0 FlatPS();
    }
}
