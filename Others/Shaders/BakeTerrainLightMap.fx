//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;
float4x4 g_WorldViewMat			: WORLDVIEW;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat					: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_LightAmbient				: LIGHTAMBIENT;
int g_DirLightCount				: DIRLIGHTCOUNT;
float3 g_DirLightDirection[ 5 ] : DIRLIGHTDIRECTION;
float4 g_DirLightDiffuse[ 5 ]	: DIRLIGHTDIFFUSE;

#define LIGHTMAP_SAVE_SCALE			0.5f
#define MATERIAL_AMBIENT			float4( 0.682f, 0.682f, 0.682f, 1.0f )
#define MATERIAL_DIFFUSE			float4( 0.682f, 0.682f, 0.682f, 1.0f )


//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float g_fSlopeBias							: SLOPEBIAS;
float4x4 g_BakeLightViewProjMat				: BAKELIGHTVIEWPROJMAT;
texture2D g_LightMapTex					: SHADOWMAPTEXTURE;
sampler2D g_LightMapSampler = sampler_state
{
    Texture = < g_LightMapTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Mirror;
	AddressV = Mirror;
};

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
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoordDiffuse		: TEXCOORD1;
};

struct VertexInputBlur
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexOutputBlur
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexBakeInput
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
};

struct VertexBakeOutput
{
    float4 Position				: POSITION;
    float4 Color				: TEXCOORD1;
    float4 LightSpacePos		: TEXCOORD2;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput ShadowVS( VertexInput Input ) 
{
	VertexOutput Output;
	float3 BiasPosition;
	
	BiasPosition = Input.Position - Input.Normal * g_fSlopeBias;
	Output.Position = mul( float4( BiasPosition.xyz, 1.0f ), g_WorldViewProjMat );
	Output.TexCoordDiffuse = Input.TexCoord0;
	Output.TexCoord0 = Output.Position.zw;
	
	return Output;
}

VertexBakeOutput BakeLightMapVS( VertexBakeInput Input ) 
{
	VertexBakeOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewProjMat );
	Output.Position.y = -Output.Position.y;
	float3 WorldViewNormal = mul( Input.Normal, g_WorldViewMat );
	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );
	for( int i = 0; i < g_DirLightCount; i++ )
	{
		 DiffuseLight.xyz += g_DirLightDiffuse[ i ].xyz * max( 0 , dot( WorldViewNormal, -g_DirLightDirection[ i ] ) );
	}
	Output.Color = ( DiffuseLight * MATERIAL_DIFFUSE ) * LIGHTMAP_SAVE_SCALE;
	Output.LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_BakeLightViewProjMat );

	return Output;
}

VertexOutputBlur BlurLightMapVS( VertexInputBlur Input ) 
{
	VertexOutputBlur Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 ShadowPS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoordDiffuse );
	clip( DiffuseTex.a - 0.5f );	// 현재 D3DRS_ALPHAREF를 무조건 0x80정도로 생각해서 하드코딩한 값이다 나중에 파라메터로 받던지 어케 하자
	float fDepth = Input.TexCoord0.x / Input.TexCoord0.y;
	return float4( fDepth, fDepth, fDepth, DiffuseTex.a );
}

float4 BakeLightMapPS( VertexBakeOutput Input ) : COLOR
{
	float2 fShadowMapCoord = Input.LightSpacePos.xy / Input.LightSpacePos.w * 0.5f + float2( 0.5f, 0.5f );
	fShadowMapCoord.y = 1.0f - fShadowMapCoord.y;
	float4 fShadowValue = Input.Color;
	if( tex2D( g_LightMapSampler, fShadowMapCoord ).x < ( Input.LightSpacePos.z / Input.LightSpacePos.w ) )
	{
		fShadowValue = float4( 0.0f, 0.0f, 0.0f, 1.0f );
	}
	fShadowValue.a = 1.0f;
	
	return fShadowValue;
}

float4 BlurLightMapPS( VertexOutputBlur Input ) : COLOR0
{
	return tex2D( g_LightMapSampler, Input.TexCoord0 );
}


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique ShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 ShadowVS();
		PixelShader  = compile ps_2_0 ShadowPS();
    }
}

technique BakeLightMapTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeLightMapVS();
		PixelShader  = compile ps_2_0 BakeLightMapPS();
    }
}

technique BlurLightMapTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BlurLightMapVS();
		PixelShader  = compile ps_2_0 BlurLightMapPS();
    }
}
