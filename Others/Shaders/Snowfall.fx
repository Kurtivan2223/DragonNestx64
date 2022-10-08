//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float g_fElapsedTime				: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4	g_CamXVector : CAMXVECTOR;
float4 g_CamYVector : CAMYVECTOR;
float4 g_CamPos : CAMPOS;

texture2D g_SnowTex : SNOWTEXTURE;
sampler2D g_SnowSampler = sampler_state
{
	texture = < g_SnowTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture3D g_SnowTex3D : SNOWTEXTURE3D;
sampler3D g_SnowSampler3D = sampler_state
{
	texture = < g_SnowTex3D >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////

float g_fSnowTimer			: SNOWTIMER;
float g_fSnowHeight			: SNOWHEIGHT;
float g_fSnowSize			: SNOWSIZE;
float g_fAniSpeed			: SNOWANISPEED;

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal					: NORMAL;
    float	PointSize				: PSIZE;
};

struct VertexInputPolygon
{
    float3 Position				: POSITION;
    float3 Normal					: NORMAL;
    float2	TexCoord			: TEXCOORD0;
    float RandomStart				: PSIZE;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float	PointSize				: PSIZE;
    float4 Diffuse					: COLOR;
};

struct VertexOutputPolygon
{
    float4 Position				: POSITION;
    float4 Diffuse					: COLOR;
    float3 TexCoord				: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput SnowfallVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float fRatio = frac( g_fSnowTimer + Input.PointSize );
	float fMoveRatio = max(0, fRatio * 1.1f - 0.1f);
	float fAlphaRatio = min(1, 1+(fRatio * 1.1f - 0.1f)*10.f);
	
	float3 Position = Input.Position;
	Position += Input.Normal * g_fSnowHeight * fMoveRatio;

	Output.Position = mul( float4( Position, 1.0f ), g_WorldViewProjMat );
	
	float fLength = length(g_CamPos.xz - float2(Position.x, Position.z));
	
	Output.PointSize = Input.PointSize * (1 - min(1, fLength/5000.f));
	Output.Diffuse = float4(1,1,1, fAlphaRatio);

	return Output;
}

VertexOutputPolygon SnowfallPolygonVS( VertexInputPolygon Input ) 
{
	VertexOutputPolygon Output;
	
	float fRatio = frac( g_fSnowTimer + Input.Position.x*100 );
	float fMoveRatio = max(0, fRatio * 1.1f - 0.1f);
	float fAlphaRatio = min(1, 1+(fRatio * 1.1f - 0.1f)*10.f);
	
	float3 Position = Input.Position;
	Position += (5 + g_fSnowSize)*g_CamXVector.xyz * (Input.TexCoord.x - 0.5);
	Position += (5 + g_fSnowSize)*g_CamYVector.xyz * (1.0 - Input.TexCoord.y);
	Position += Input.Normal * g_fSnowHeight * fMoveRatio;

	Output.Position = mul( float4( Position, 1.0f ), g_WorldViewProjMat );

	Output.Diffuse = float4(1,1,1, fAlphaRatio);
	//Output.TexCoord = Input.TexCoord;
	float fTextureRatio = (sin((g_fElapsedTime + Input.RandomStart) * g_fAniSpeed) + 1.0f) * 0.5f;
	Output.TexCoord = float3( Input.TexCoord.xy, fTextureRatio );

	return Output;
}

float4 SnowfallPolygonPStex3D( VertexOutputPolygon Input ) : COLOR
{
	float4 result = tex3D( g_SnowSampler3D, Input.TexCoord ) * Input.Diffuse;
	return result;
}

float4 SnowfallPolygonPS( VertexOutputPolygon Input ) : COLOR
{
	float4 result = tex2D( g_SnowSampler, Input.TexCoord.xy ) * Input.Diffuse;
	return result;
}



//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique SnowfallTech0
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SnowfallPolygonVS();		
		PixelShader = compile ps_2_0 SnowfallPolygonPStex3D();
    }
}

technique SnowfallTech1
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SnowfallVS();
    }
}

technique SnowfallTech2
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SnowfallPolygonVS();
		PixelShader = compile ps_2_0 SnowfallPolygonPS();
    }
}