#include "CalcShadow.fxh"
#include "CalcFog.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
#ifdef BAKE_VELOCITY
float4x4 g_PrevWorldViewProjMat		: PREVWORLDVIEWPROJ;
#endif
shared float4x4 g_ProjMat				: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_LightAmbient			: LIGHTAMBIENT;

float3 g_DirLightDirection[ 1 ] : DIRLIGHTDIRECTION;		// 기본적으로 코드쪽에서 SetVectorArray() 를 호출하도록 설정되어 있어서 맞춰놓는다.
float4 g_DirLightDiffuse[ 1 ]	: DIRLIGHTDIFFUSE;			// 기본적으로 코드쪽에서 SetVectorArray() 를 호출하도록 설정되어 있어서 맞춰놓는다.

#define LIGHTMAP_RESTORE_SCALE		2.0f
#define MATERIAL_AMBIENT			float4( 0.682f, 0.682f, 0.682f, 1.0f )
#define MATERIAL_DIFFUSE			float4( 0.682f, 0.682f, 0.682f, 1.0f )

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_WorldOffset;
float4 g_fTextureDistance;
float g_fTileSize;
float4 g_fPixelSize;
float4 g_fTextureRotate12 = { 1.0f, 0.0f, 1.0f, 0.0f };
float4 g_fTextureRotate34 = { 1.0f, 0.0f, 1.0f, 0.0f };

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

float4 g_TerrainBlockSize;
texture2D g_LightMap : LIGHTMAP;
sampler2D g_LightMapSampler = sampler_state
{
	Texture = < g_LightMap >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Mirror;
	AddressV = Mirror;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInputCliff
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoord1			: TEXCOORD1;
    float4 LayerAlpha			: COLOR0;
    float4 CoordAlpha			: COLOR1;
};

struct VertexOutputCliff
{
    float4 Position				: POSITION;
    float4 Color				: TEXCOORD0;
    float4 TexCoord0_1			: TEXCOORD1;
    float4 TexCoord2_Fog		: TEXCOORD2;
    float4 LayerAlpha			: TEXCOORD3;
    float4 CoordAlpha			: TEXCOORD4;
    float4 LightMapCoord		: TEXCOORD5;
    float3 ShadowMapCoord		: TEXCOORD6;
    
};

struct PixelOutput
{
	float4 Color				: COLOR0;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutputCliff LayeredCliffTerrainLowVS( VertexInputCliff Input ) 
{
	VertexOutputCliff Output;

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );

	float3 WorldViewNormal = mul( Input.Normal, g_WorldViewMat );
	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );
	DiffuseLight.xyz += g_DirLightDiffuse[ 0 ].xyz * max( 0 , dot( WorldViewNormal, -g_DirLightDirection[ 0 ] ) );

	float4 Ambient = g_LightAmbient * MATERIAL_AMBIENT;
	float4 Diffuse = DiffuseLight * MATERIAL_DIFFUSE;
	Output.Color = Diffuse + Ambient;

	Output.LayerAlpha = Input.LayerAlpha;
	Output.TexCoord0_1.xy = ( Input.Position.xz + g_WorldOffset.xz ) / g_fTileSize;
	Output.TexCoord2_Fog.zw = CalcFogValue( Output.Position.z );

	Output.CoordAlpha = Input.CoordAlpha;
	Output.TexCoord0_1.zw = Input.TexCoord0;
	Output.TexCoord2_Fog.xy = Input.TexCoord1;

	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.LightMapCoord.zw = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.LightMapCoord.w = 1.0f - Output.LightMapCoord.w;

	Output.LightMapCoord.xy = Input.Position.xz / g_TerrainBlockSize + g_fPixelSize.xy;
	float4 LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjMat );
	Output.ShadowMapCoord.xy = 0.5f * LightSpacePos.xy / LightSpacePos.w + float2( 0.5f, 0.5f );
	Output.ShadowMapCoord.y = 1.0f - Output.ShadowMapCoord.y;
	Output.ShadowMapCoord.z = dot( float4( Input.Position.xyz, 1.0f ), g_WorldLightViewProjDepth );
																		

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcCliffTerrain( VertexOutputCliff Input )
{
	float2 vTemp;
	vTemp.x = Input.TexCoord0_1.x * g_fTextureRotate12.x + Input.TexCoord0_1.y * -g_fTextureRotate12.y;
	vTemp.y = Input.TexCoord0_1.x * g_fTextureRotate12.y + Input.TexCoord0_1.y * g_fTextureRotate12.x;
	float4 LayerTex1 = tex2D( g_LayerSampler1, vTemp * g_fTextureDistance.x );
	
	vTemp.x = Input.TexCoord0_1.x * g_fTextureRotate12.z + Input.TexCoord0_1.y * -g_fTextureRotate12.w;
	vTemp.y = Input.TexCoord0_1.x * g_fTextureRotate12.w + Input.TexCoord0_1.y * g_fTextureRotate12.z;
	float4 LayerTex2 = tex2D( g_LayerSampler2, vTemp * g_fTextureDistance.y );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );

	Result.w = 1.0f;

	return Result;
}

PixelOutput LayeredCliffTerrainLowPS( VertexOutputCliff Input )
{
	PixelOutput Output;

	Output.Color = CalcCliffTerrain( Input );
	
	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;

	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz );

	Output.Color.xyz *= ShadowColor.xyz;

	float4 FogColor = tex2D( g_FogSkyBoxSampler, Input.LightMapCoord.zw );
	FogColor.xyz = lerp( g_FogColor.xyz, FogColor.xyz, Input.TexCoord2_Fog.w );
	Output.Color.xyz = lerp( FogColor.xyz, Output.Color.xyz, Input.TexCoord2_Fog.z );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 0.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique LayeredCliffTerrainLowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredCliffTerrainLowVS();
		PixelShader  = compile ps_2_0 LayeredCliffTerrainLowPS();
    }
}

