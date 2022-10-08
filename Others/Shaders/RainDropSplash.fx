//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldMat						: WORLD;
float4x4 g_ViewProjMat					: VIEWPROJ;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float g_fElapsedTime				: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
texture3D g_RainDropSplashTex : RAINDROPSPLASHTEX;
sampler3D g_RainDropSplashSampler = sampler_state
{
	texture = < g_RainDropSplashTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float g_fInvLifeTime					: INVSPLASHLIFETIME;
float4 g_RainDropSplashPos[ 200 ]		: SPLASHPOSITION;

//------------------------------------
struct VertexInput
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    int4   nVertexIndex			: BLENDINDICES0;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float3 TexCoord0			: TEXCOORD0;
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

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput RainDropSplashVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float4 OutPos = mul( float4( Input.Position, 1.0f ), g_WorldMat );
	OutPos.xyz += g_RainDropSplashPos[ Input.nVertexIndex.x ].xyz;
	Output.Position = mul( float4( OutPos.xyz, 1.0f ), g_ViewProjMat );
	Output.TexCoord0 = float3( Input.TexCoord0.xy, ( g_fElapsedTime - g_RainDropSplashPos[ Input.nVertexIndex.x ].w ) * g_fInvLifeTime );

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif

	return Output;
}

//-----------------------------------
PixelOutput RainDropSplashPS( VertexOutput Input) : COLOR
{
	PixelOutput Output;

	Output.Color = tex3D( g_RainDropSplashSampler, Input.TexCoord0 );
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
}

//-----------------------------------
technique RainDropSplashTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 RainDropSplashVS();
		PixelShader = compile ps_2_0 RainDropSplashPS();
    }
}
