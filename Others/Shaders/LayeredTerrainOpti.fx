#include "CalcShadow.fxh"
#include "CalcFog.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
shared float4x4 g_ProjMat		: PROJECTION;

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

float4 g_MaterialDiffuse : MATERIALDIFFUSE
<
    string UIName = "Material Diffuse";
> = { 0.8f, 0.8f, 0.8f, 1.0f};
float4 g_MaterialAmbient : MATERIALAMBIENT
<
    string UIName = "Material Ambient";
> = { 0.8f, 0.8f, 0.8f, 1.0f};

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
struct VertexInput
{
    float3 Position				: POSITION;
    float4 LayerAlpha			: COLOR0;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD1;
    float4 Fog		    		: TEXCOORD2;
    float4 LayerAlpha			: TEXCOORD3;
    float2 LightMapCoord		: TEXCOORD4;
    float3 ShadowMapCoord		: TEXCOORD5;
};

struct PixelOutput
{
	float4 Color				: COLOR0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput LayeredTerrainVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
									
	Output.LayerAlpha = Input.LayerAlpha;
	Output.TexCoord0.xy = ( Input.Position.xz + g_WorldOffset.xz ) / g_fTileSize * g_fTextureDistance.x;

	Output.Fog.zw = CalcFogValue( Output.Position.z );																			
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;

	Output.LightMapCoord = Input.Position.xz / g_TerrainBlockSize + g_fPixelSize.xy;
	float4 LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjMat );
	Output.ShadowMapCoord.xy = 0.5f * LightSpacePos.xy / LightSpacePos.w + float2( 0.5f, 0.5f );
	Output.ShadowMapCoord.y = 1.0f - Output.ShadowMapCoord.y;
	Output.ShadowMapCoord.z = dot( float4( Input.Position.xyz, 1.0f ), g_WorldLightViewProjDepth );
	
	return Output;
}
//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcTerrain1( VertexOutput Input )
{
	return tex2D( g_LayerSampler1, Input.TexCoord0 );
}

float4 CalcTerrain2( VertexOutput Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0 );
	float4 LayerTex2 = tex2D( g_LayerSampler2, Input.TexCoord0 );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );
	Result.w = 1.0f;
	
	return Result;
}

float4 CalcTerrain3( VertexOutput Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0 );
	float4 LayerTex2 = tex2D( g_LayerSampler2, Input.TexCoord0 );
	float4 LayerTex3 = tex2D( g_LayerSampler3, Input.TexCoord0 );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );
	Result = lerp( Result, LayerTex3, Input.LayerAlpha.x );
	
	Result.w = 1.0f;
	
	return Result;
}

float4 CalcTerrain4( VertexOutput Input )
{
	float4 LayerTex1 = tex2D( g_LayerSampler1, Input.TexCoord0 );
	float4 LayerTex2 = tex2D( g_LayerSampler2, Input.TexCoord0 );
	float4 LayerTex3 = tex2D( g_LayerSampler3, Input.TexCoord0 );
	float4 LayerTex4 = tex2D( g_LayerSampler4, Input.TexCoord0 );
	
	float4 Result = lerp( LayerTex1, LayerTex2, Input.LayerAlpha.w );
	Result = lerp( Result, LayerTex3, Input.LayerAlpha.x );
	Result = lerp( Result, LayerTex4, Input.LayerAlpha.y );
	
	Result.w = 1.0f;
	
	return Result;
}

PixelOutput LayeredTerrain1PS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color =  CalcTerrain1( Input );	

	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;
	
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );
	
	return Output;
}

PixelOutput LayeredTerrain2PS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color =  CalcTerrain2( Input );	

	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;
	
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );
	
	return Output;
}

PixelOutput LayeredTerrain3PS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color =  CalcTerrain3( Input );	

	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;
	
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );
	
	return Output;
}

PixelOutput LayeredTerrain4PS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color =  CalcTerrain4( Input );	

	float4 ShadowColor;	
	ShadowColor = tex2D( g_LightMapSampler, Input.LightMapCoord ) * LIGHTMAP_RESTORE_SCALE;
	float3 AmbientColor = g_LightAmbient * MATERIAL_AMBIENT;
	ShadowColor.xyz = CalcTerrainShadow( Input.ShadowMapCoord, AmbientColor, ShadowColor.xyz ) ;
	Output.Color.xyz *= ShadowColor.xyz;
	
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );
	
	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique LayeredTerrainTech1
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredTerrainVS();
		PixelShader  = compile ps_2_0 LayeredTerrain1PS();
    }
}

technique LayeredTerrainTech2
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredTerrainVS();
		PixelShader  = compile ps_2_0 LayeredTerrain2PS();
    }
}

technique LayeredTerrainTech3
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredTerrainVS();
		PixelShader  = compile ps_2_0 LayeredTerrain3PS();
    }
}

technique LayeredTerrainTech4
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 LayeredTerrainVS();
		PixelShader  = compile ps_2_0 LayeredTerrain4PS();
    }
}
