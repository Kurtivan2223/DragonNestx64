
//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_ScaleMat			: SCALE;
float4x4 g_RotateMat			: ROTATE;
float4x4 g_PositionMat			: POSITION;

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
texture2D g_LayerTex1 : LAYERTEXTURE1
< 
	string UIName = "Layer1 Texture";
>;
sampler2D g_LayerSampler1 = sampler_state
{
	Texture = < g_LayerTex1 >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
texture2D g_LayerTex2 : LAYERTEXTURE2
< 
	string UIName = "Layer2 Texture";
>;
sampler2D g_LayerSampler2 = sampler_state
{
	Texture = < g_LayerTex2 >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
texture2D g_LayerTex3 : LAYERTEXTURE3
< 
	string UIName = "Layer3 Texture";
>;
sampler2D g_LayerSampler3 = sampler_state
{
	Texture = < g_LayerTex3 >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
texture2D g_LayerTex4 : LAYERTEXTURE4
< 
	string UIName = "Layer4 Texture";
>;
sampler2D g_LayerSampler4 = sampler_state
{
	Texture = < g_LayerTex4 >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position			: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexOutput 
{
    float4 Position			: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct PixelOutput
{
	float4 Color			: COLOR0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////

VertexOutput BenchMarkVS( VertexInput Input ) 
{
	VertexOutput Output;
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_ScaleMat );
	Output.Position = mul( Output.Position, g_RotateMat );
	Output.Position = mul( Output.Position, g_PositionMat );
	Output.TexCoord0 = Input.TexCoord0;
	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////

PixelOutput BenchMarkPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	float4 LayerColor1 = tex2D( g_LayerSampler1, Input.TexCoord0 );
	float4 LayerColor2 = tex2D( g_LayerSampler2, Input.TexCoord0 );
	float4 LayerColor3 = tex2D( g_LayerSampler3, Input.TexCoord0 );
	float4 LayerColor4 = tex2D( g_LayerSampler4, Input.TexCoord0 );

	Output.Color = LayerColor1 * LayerColor2 * LayerColor3 * LayerColor4 * 0.25f;
	Output.Color *= g_MaterialAmbient;
	Output.Color *= g_MaterialDiffuse;
	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique FlatTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BenchMarkVS();
		PixelShader  = compile ps_2_0 BenchMarkPS();
    }
}
