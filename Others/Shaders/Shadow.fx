//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldLightViewProjMat		: WORLDLIGHTVIEWPROJ;
float4x3 g_WorldViewMatArray[50]		: WORLDMATRIXARRAY;
float4x4 g_InvViewLightViewProjMat		: INVVIEWLIGHTVIEWPROJ;

float4 g_WorldLightViewProjDepth		: WORLDLIGHTVIEWPROJDEPTH;
float4 g_InvViewLightViewProjDepth		: INVVIEWLIGHTVIEWPROJDEPTH;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat					: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////

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

texture3D g_DiffuseVolumeTex : DIFFUSEVOLUMETEXTURE
< 
	string UIName = "Diffuse Volume Texture";
>;
sampler3D g_DiffuseVolumeSampler = sampler_state
{
	texture = < g_DiffuseVolumeTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_ShadowMapTex : SHADOWMAPTEXTURE;
sampler2D g_ShadowMapSampler = sampler_state
{
    Texture = < g_ShadowMapTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Border;
	AddressV = Border;
	BorderColor = { 1.0f, 1.0f, 1.0f, 1.0f};
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
#ifdef DEPTH_SHADOWMAP
    float TexCoord1			: TEXCOORD1;
#endif
};

struct VertexDownOutput 
{
    float4 Position				: POSITION;
	float2 TexCoord0			: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput ShadowVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_WorldLightViewProjMat );
	Output.TexCoord0 = Input.TexCoord0;
#ifdef DEPTH_SHADOWMAP
	Output.TexCoord1 = dot( float4( Input.Position.xyz, 1.0f ), g_WorldLightViewProjDepth );
	Output.Position.z = Output.TexCoord1 * Output.Position.w;
#endif

	return Output;
}

VertexOutput ShadowAniVS( VertexInputAni Input )
{
	VertexOutput Output;

    float3 WorldViewPos = mul( float4( Input.Position.xyz , 1.0 ), g_WorldViewMatArray[ Input.nBoneIndex.x ] );

	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_InvViewLightViewProjMat );
	Output.TexCoord0 = Input.TexCoord0;
#ifdef DEPTH_SHADOWMAP
	Output.TexCoord1 = dot(float4( WorldViewPos, 1.f ), g_InvViewLightViewProjDepth);
	Output.Position.z = Output.TexCoord1 * Output.Position.w;
#endif
	
    return Output;
}

VertexDownOutput DrawQuadVS( VertexInput Input ) 
{
	VertexDownOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0; 

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 ShadowPS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
#ifdef DEPTH_SHADOWMAP
	clip( DiffuseTex.a - 0.5f );								// 현재 D3DRS_ALPHAREF를 무조건 0x80정도로 생각해서 하드코딩한 값이다 나중에 파라메터로 받던지 어케 하자
	float fDepth = Input.TexCoord1;
	return float4( fDepth, 0, 0, DiffuseTex.a );
#else
	return float4( 0.0f, 0.0f, 0.0f, DiffuseTex.a );
#endif
}

float4 ShadowTex3DPS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex3D( g_DiffuseVolumeSampler, float3( Input.TexCoord0, 0.0f ) );	// 어차피 검게 찍을거니까 텍스처 좌표는 상관없다.
#ifdef DEPTH_SHADOWMAP
	clip( DiffuseTex.a - 0.5f );								// 현재 D3DRS_ALPHAREF를 무조건 0x80정도로 생각해서 하드코딩한 값이다 나중에 파라메터로 받던지 어케 하자
	float fDepth = Input.TexCoord1;
	return float4( fDepth, 0, 0, DiffuseTex.a );
#else
	return float4( 0.0f, 0.0f, 0.0f, DiffuseTex.a );
#endif
}

float4 DownFilterPS( VertexDownOutput Input ) : COLOR0
{
	float f = 2 * 1.5 / 1024.f;	
	float fValue = 0;

	for( int y = -1; y <= 1; y++)	
	for( int x = -1; x <= 1; x++)
	{
		fValue += tex2D( g_ShadowMapSampler, Input.TexCoord0 + float2(x*f,y*f) );
	}
	fValue *= 0.111111;
	return float4(fValue, 0, 0, 1);
}

float4 ClearPS( VertexOutput Input ) : COLOR
{
	return float4( 1, 1, 1, 1 );
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
technique ShadowAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 ShadowAniVS();
		PixelShader  = compile ps_2_0 ShadowPS();
    }
} 
 
technique DownFilterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DrawQuadVS();
		PixelShader  = compile ps_2_0 DownFilterPS();
    }
}

technique DrawQuadTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DrawQuadVS();
		PixelShader  = compile ps_2_0 ClearPS();
    }
}

technique ShadowTex3DTech
{
    pass p0
    {
		VertexShader = compile vs_2_0 ShadowVS();
		PixelShader  = compile ps_2_0 ShadowTex3DPS();
    }
}
technique ShadowAniTex3DTech
{
    pass p0
    {
		VertexShader = compile vs_2_0 ShadowAniVS();
		PixelShader  = compile ps_2_0 ShadowTex3DPS();
    }
}