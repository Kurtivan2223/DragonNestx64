//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_SwordTrailColor			: SWORDTRAILCOLOR;


texture2D g_SwordTrailTexture : SWORDTRAILTEXTURE;
sampler2D g_SwordTrailSampler = sampler_state
{
	texture = < g_SwordTrailTexture >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_SwordTrailNormalTexture : SWORDTRAILNORMALTEXTURE;
sampler2D g_SwordTrailNormalSampler = sampler_state
{
	texture = < g_SwordTrailNormalTexture >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_BackBuffer : BACKBUFFER;
sampler2D g_BackBufferSampler = sampler_state
{
	Texture = < g_BackBuffer >;
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
    float3 TexCoord1			: TEXCOORD1;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD2;
#endif
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
};

VertexOutput SwordTrailVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position, 1.0f ), g_WorldViewProjMat );
	Output.TexCoord1.xyz = Output.Position.xyw;
	
	/*float2 fUV = Output.Position.xy / Output.Position.w;
	fUV.x = (fUV.x*0.5+0.5);
	fUV.y = (-fUV.y*0.5+0.5);
	Output.TexCoord1.xy = fUV;
	*/
	
	Output.TexCoord0.x = 1 - Input.TexCoord0.x;
	Output.TexCoord0.y = Input.TexCoord0.y;
	
#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////

#define 	CalcEnvColor																\
	float4 normalTexture = tex2D( g_SwordTrailNormalSampler, Input.TexCoord0 );			\
	normalTexture = normalTexture - float4( 0.5, 0.5, 0.0f, 0.0f );						\
																						\
	float2 fUV = Input.TexCoord1.xy / Input.TexCoord1.z;								\
	fUV.x = (fUV.x*0.5+0.5);															\
	fUV.y = (-fUV.y*0.5+0.5);															\
																						\
	float4 envTexture = tex2D( g_BackBufferSampler,  fUV + normalTexture.xy * 0.11 );	\
	
PixelOutput SwordTrailPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	float4 result;
	float4 diffuseTexture = tex2D( g_SwordTrailSampler, Input.TexCoord0 );
	CalcEnvColor;

	result = saturate( diffuseTexture + envTexture);
	result.a = 1;;
	
	Output.Color = result;
	
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
}

PixelOutput SwordTrailPSRevSubtract( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	float4 result;
	float4 diffuseTexture = tex2D( g_SwordTrailSampler, Input.TexCoord0 );
	CalcEnvColor;

	result = saturate( envTexture - diffuseTexture );
	result.a = 1.0f - result.a;

	Output.Color = result;
	
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique SwordTrailTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SwordTrailVS();
		PixelShader  = compile ps_2_0 SwordTrailPS();
    }
}

technique SwordTrailTechSubtract
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SwordTrailVS();
		PixelShader  = compile ps_2_0 SwordTrailPSRevSubtract();
    }
}