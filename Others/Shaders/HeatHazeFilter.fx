//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float g_fElapsedTime : ELAPSEDTIME;
float g_fDistortionPower : DISTORTIONPOWER;

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

texture2D g_PerturbationTexture : PERTURBATIONTEXTURE;
sampler2D g_PerturbationSampler = sampler_state
{
	Texture = <g_PerturbationTexture >;
	AddressU = Wrap;
    AddressV = Wrap;
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
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput HeatHazeVS( VertexInput Input ) 
{
	VertexOutput Output;

	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 HeatHazePS( VertexOutput Input ) : COLOR0
{
	float2 fUV = Input.TexCoord0;
	float2 fNormalUV = fUV + g_fElapsedTime*0.002;
	float3 vNormal = tex2D( g_PerturbationSampler, fNormalUV );
	vNormal.xy = vNormal.xy * 2.0 - 1.0;
	float2 distortion = (vNormal.xy) * 0.0025 + sin( (fUV.x + fUV.y) * 100.0 + g_fElapsedTime ) * 0.001;
	distortion *= saturate(Input.TexCoord0.y*2.0) * g_fDistortionPower ;
	fUV += distortion;
	float3 Color = tex2D(g_BackBufferSampler , fUV).xyz;
	
	return float4( Color.xyz, 1.0f );
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique HeatHazeTech
{
    pass p0 
    {
		VertexShader = compile vs_2_0 HeatHazeVS();
		PixelShader  = compile ps_2_0 HeatHazePS();
    }
}
