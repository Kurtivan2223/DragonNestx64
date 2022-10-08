#include "CalcShadow.fxh"
#include "CalcFog.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
shared float4x4 g_ProjMat				: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4 g_LightAmbient			: LIGHTAMBIENT;

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
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoord1			: TEXCOORD1;
    float4 LayerAlpha			: COLOR0;
    float4 CoordAlpha			: COLOR1;
};

struct VertexOutputCliff
{
    float4 Position				: POSITION;
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
VertexOutputCliff LayeredCliffTerrainVS( VertexInputCliff Input ) 
{
	VertexOutputCliff Output;

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );

	Output.LayerAlpha = Input.LayerAlpha;
	Output.TexCoord0_1.xy = ( Input.Position.xz + g_WorldOffset.xz ) / g_fTileSize * g_fTextureDistance.x;
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
float4 CalcCliffTerrain1( VertexOutputCliff Input )
{
	float4 LayerTex41 = tex2D( g_LayerSampler1, Input.TexCoord0_1.zw );
	float4 LayerTex42 = tex2D( g_LayerSampler1, Input.TexCoord2_Fog.xy );
	float4 Result = lerp( LayerTex42, LayerTex41, Input.CoordAlpha.w );
	Result.w = 1.0f;
	
	return Result;
}

float4 CalcCliffTerrain2( VertexOutputCliff Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0_1.xy );
	float4 LayerTex41 = tex2D( g_LayerSampler2, Input.TexCoord0_1.zw );
	float4 LayerTex42 = tex2D( g_LayerSampler2, Input.TexCoord2_Fog.xy );
	float4 LayerTex4 = lerp( LayerTex42, LayerTex41, Input.CoordAlpha.w );
	
	float4 Result = lerp( LayerTex1, LayerTex4, Input.LayerAlpha.w );
	Result.w = 1.0f;

	return Result;
}

float4 CalcCliffTerrain3( VertexOutputCliff Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0_1.xy );
	float4 LayerTex2 = tex2D( g_LayerSampler2, Input.TexCoord0_1.xy );
	float4 LayerTex41 = tex2D( g_LayerSampler3, Input.TexCoord0_1.zw );
	float4 LayerTex42 = tex2D( g_LayerSampler3, Input.TexCoord2_Fog.xy );
	float4 LayerTex4 = lerp( LayerTex42, LayerTex41, Input.CoordAlpha.w );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );
	Result = lerp( Result, LayerTex4, Input.LayerAlpha.x );

	Result.w = 1.0f;

	return Result;
}

float4 CalcCliffTerrain4( VertexOutputCliff Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0_1.xy );
	float4 LayerTex2 = tex2D( g_LayerSampler2, Input.TexCoord0_1.xy );
	float4 LayerTex3 = tex2D( g_LayerSampler3, Input.TexCoord0_1.xy );
	float4 LayerTex41 = tex2D( g_LayerSampler4, Input.TexCoord0_1.zw );
	float4 LayerTex42 = tex2D( g_LayerSampler4, Input.TexCoord2_Fog.xy );
	float4 LayerTex4 = lerp( LayerTex42, LayerTex41, Input.CoordAlpha.w );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );
	Result = lerp( Result, LayerTex3, Input.LayerAlpha.x );
	Result = lerp( Result, LayerTex4, Input.LayerAlpha.y );

	Result.w = 1.0f;

	return Result;
}

PixelOutput LayeredCliffTerrain1PS( VertexOutputCliff Input )
{
	PixelOutput Output;

	Output.Color = CalcCliffTerrain1( Input );
	
	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord.xy ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;

	float4 FogColor = tex2D( g_FogSkyBoxSampler, Input.LightMapCoord.zw );
	FogColor.xyz = lerp( g_FogColor.xyz, FogColor.xyz, Input.TexCoord2_Fog.w );
	Output.Color.xyz = lerp( FogColor.xyz, Output.Color.xyz, Input.TexCoord2_Fog.z );

	return Output;
}

PixelOutput LayeredCliffTerrain2PS( VertexOutputCliff Input )
{
	PixelOutput Output;

	Output.Color = CalcCliffTerrain2( Input );
	
	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord.xy ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;

	float4 FogColor = tex2D( g_FogSkyBoxSampler, Input.LightMapCoord.zw );
	FogColor.xyz = lerp( g_FogColor.xyz, FogColor.xyz, Input.TexCoord2_Fog.w );
	Output.Color.xyz = lerp( FogColor.xyz, Output.Color.xyz, Input.TexCoord2_Fog.z );

	return Output;
}

PixelOutput LayeredCliffTerrain3PS( VertexOutputCliff Input )
{
	PixelOutput Output;

	Output.Color = CalcCliffTerrain3( Input );
	
	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;

	float4 FogColor = tex2D( g_FogSkyBoxSampler, Input.LightMapCoord.zw );
	Output.Color.xyz = lerp( FogColor.xyz, Output.Color, Input.TexCoord2_Fog.w );

	return Output;
}

PixelOutput LayeredCliffTerrain4PS( VertexOutputCliff Input )
{
	PixelOutput Output;

	Output.Color = CalcCliffTerrain4( Input );
	
	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;

	float4 FogColor = tex2D( g_FogSkyBoxSampler, Input.LightMapCoord.zw );
	Output.Color.xyz = lerp( FogColor.xyz, Output.Color, Input.TexCoord2_Fog.w );

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique LayeredCliffTerrainTech1
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredCliffTerrainVS();
		PixelShader  = compile ps_2_0 LayeredCliffTerrain1PS();
    }
}

technique LayeredCliffTerrainTech2
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredCliffTerrainVS();
		PixelShader  = compile ps_2_0 LayeredCliffTerrain2PS();
    }
}

technique LayeredCliffTerrainTech3
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredCliffTerrainVS();
		PixelShader  = compile ps_2_0 LayeredCliffTerrain3PS();
    }
}

technique LayeredCliffTerrainTech4
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredCliffTerrainVS();
		PixelShader  = compile ps_2_0 LayeredCliffTerrain4PS();
    }
}
