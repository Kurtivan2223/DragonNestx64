//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float3 g_ViewPosition			: VIEWPOSITION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_LineTrailColor			: LINETRAILCOLOR;
float g_fLineTrailWidth			: LINETRAILWIDTH;
float g_fLineTrailInverseLifeTime		: LINETRAILINVERSELIFETIME;
float g_fLineTrailStartTime		: LINETRAILSTARTTIME;

texture2D g_LineTrailTexture : LINETRAILTEXTURE;
sampler2D g_LineTrailSampler = sampler_state
{
	texture = < g_LineTrailTexture >;
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
    float3 Tangent				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD1;
#endif
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
};

VertexOutput LineTrailVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float3 ToCameraVec = g_ViewPosition - Input.Position;
	float3 Normal = normalize( cross( ToCameraVec, Input.Tangent ) );
	float fLineWidth = g_fLineTrailWidth * ( Input.TexCoord0.y - 0.5f );
	float3 FinalPosition = Input.Position + Normal * fLineWidth;
	
	Output.Position = mul( float4( FinalPosition, 1.0f ), g_WorldViewProjMat );
	Output.TexCoord0.x = ( Input.TexCoord0.x - g_fLineTrailStartTime ) * g_fLineTrailInverseLifeTime;
	Output.TexCoord0.y = Input.TexCoord0.y;
	
#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput LineTrailPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = tex2D( g_LineTrailSampler, Input.TexCoord0 );
	
	Output.Color *= g_LineTrailColor;
	
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique LineTrailTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LineTrailVS();
		PixelShader  = compile ps_2_0 LineTrailPS();
    }
}
