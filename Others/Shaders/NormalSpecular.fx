#include "CalcBlendBone.fxh"
#include "CalcNormalMap.fxh"
#include "CalcFog.fxh"
#include "CalcLight.fxh"
#include "CalcShadow.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat				: WORLDVIEW;
float4x4 g_WorldViewProjMat			: WORLDVIEWPROJ;
#ifdef BAKE_VELOCITY
float4x4 g_PrevWorldViewProjMat		: PREVWORLDVIEWPROJ;
float4x4 g_InvWorldViewPrevWVPMat : INVWORLDVIEWPREVWORLDVIEWPROJ;
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat			: PROJECTION;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _3DSMAX_
float4 g_LightDir		: DIRECTION
<
    string UIName = "Light Direction";
	string Object = "TargetLight";
	int RefID = 0;
> = { 0.577f, -0.577f, 0.577f, 0.0f };
float4 g_LightDiffuse : LIGHTCOLOR
<
    int LightRef = 0;
> = { 1.0f, 1.0f, 1.0f, 1.0f };
float4 g_LightSpecular : LIGHTSPECULAR
<
> = { 1.0f, 1.0f, 1.0f, 1.0f };
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
#define _USE_DIFFUSE_
#define _USE_SPECULAR_
#define _USE_NORMALMAP_
#include "MaterialColor.fxh"

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
    float3 Tangent				: TANGENT;
    float3 Binormal				: BINORMAL;
};

struct VertexInputAni {
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
    float3 Tangent				: TANGENT;
    float3 Binormal				: BINORMAL;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
    float3 WorldViewPos			: TEXCOORD2;
    float3 WorldViewEyeVec		: TEXCOORD3;
    float3 WorldViewNormal		: TEXCOORD4;
    float3 WorldViewTangent		: TEXCOORD5;
    float3 WorldViewBinormal	: TEXCOORD6;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD7;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD8;
#endif
};

struct VertexOutputShadow
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
    float3 WorldViewPos			: TEXCOORD2;
    float3 WorldViewEyeVec		: TEXCOORD3;
    float3 WorldViewNormal		: TEXCOORD4;
    float3 WorldViewTangent		: TEXCOORD5;
    float3 WorldViewBinormal	: TEXCOORD6;
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
    float4 LightSpacePos		: TEXCOORD7;
#endif
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD8;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD9;
#endif
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
#ifdef BAKE_VELOCITY
    float4 Velocity				: COLOR2;
#endif
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput NormalSpecularVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	CalcNormalSpecular;
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = Output.Position.xy / Output.Position.w;
	float4 PrevWorldViewProjPos = mul( float4( Input.Position.xyz, 1.0f ), g_PrevWorldViewProjMat );
	Output.Velocity -= PrevWorldViewProjPos.xy / PrevWorldViewProjPos.w;
#endif																					

	return Output;
}

VertexOutputShadow NormalSpecularShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;

	CalcNormalSpecular;
	Output.Fog.zw = CalcFogValue( Output.Position.z );
	
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjMat );
	Output.LightSpacePos.z = dot( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjDepth ) * Output.LightSpacePos.w;
#endif

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = Output.Position.xy / Output.Position.w;
	float4 PrevWorldViewProjPos = mul( float4( Input.Position.xyz, 1.0f ), g_PrevWorldViewProjMat );
	Output.Velocity -= PrevWorldViewProjPos.xy / PrevWorldViewProjPos.w;
#endif																					

	return Output;
}

VertexOutput NormalSpecularAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	CalcNormalSpecularAni
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = Output.Position.xy / Output.Position.w;
	float4 PrevWorldViewProjPos = mul( float4( WorldViewPos.xyz, 1.0f ), g_InvWorldViewPrevWVPMat );
	Output.Velocity -= PrevWorldViewProjPos.xy / PrevWorldViewProjPos.w;
#endif							

    return Output;
}

VertexOutputShadow NormalSpecularAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;
	
	CalcNormalSpecularAni
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( WorldViewPos.xyz, 1.0f ) , g_InvViewLightViewProjMat );
	Output.LightSpacePos.z = dot( float4( WorldViewPos.xyz, 1.0f ) , g_InvViewLightViewProjDepth ) * Output.LightSpacePos.w;
#endif

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = Output.Position.xy / Output.Position.w;
	float4 PrevWorldViewProjPos = mul( float4( WorldViewPos.xyz, 1.0f ), g_InvWorldViewPrevWVPMat );
	Output.Velocity -= PrevWorldViewProjPos.xy / PrevWorldViewProjPos.w;
#endif							

    return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
float4 CalcNormalSpecularColor( VertexOutput Input )
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 SpecularTex = tex2D( g_SpecularSampler, Input.TexCoord0 );
	float3 NormalTex = g_BumpPower * ( tex2D( g_NormalSampler, Input.TexCoord0 ).xyz - 0.5 );

	float3 WorldViewNormal = normalize( Input.WorldViewNormal );
	float3 WorldViewTangent = normalize( Input.WorldViewTangent );
	float3 WorldViewBinormal = normalize( Input.WorldViewBinormal );

	NormalTex = normalize( WorldViewNormal + ( NormalTex.x * WorldViewTangent + NormalTex.y * WorldViewBinormal ) );

	// calculate Directional Light
	int i;
	float4 DiffuseLight;
	float4 SpecularLight;

	DiffuseLight = float4( 0.0f, 0.0f, 0.0f, g_MaterialAmbient.w );
	SpecularLight = float4( 0.0f, 0.0f, 0.0f, 0.0f );
#ifndef DISABLE_DIR_LIGHT
	for( i = 0; i < g_DirLightCount; i++ )
	{
		CalcDirLight( DiffuseLight, SpecularLight, i, NormalTex, Input.WorldViewEyeVec );
	}
#endif
#ifndef DISABLE_POINT_LIGHT
	// calculate Point Light
	for( i = 0; i < g_PointLightCount; i++ )
	{
		CalcPointLight( DiffuseLight, SpecularLight, i, NormalTex, Input.WorldViewEyeVec, Input.WorldViewPos );	
	}
#endif
#ifndef DISABLE_SPOT_LIGHT
	// calculate Spot Light
	for( i = 0; i < g_SpotLightCount; i++ )
	{
		CalcSpotLight( DiffuseLight, SpecularLight, i, NormalTex, Input.WorldViewEyeVec, Input.WorldViewPos );
	}
#endif

	DiffuseLight = ( g_LightAmbient * g_MaterialAmbient + g_MaterialDiffuse * DiffuseLight ) * DiffuseTex;
	SpecularLight = g_MaterialSpecular * SpecularLight * SpecularTex;
	float4 Result = DiffuseLight + SpecularLight;
	
	return Result;
}

PixelOutput NormalSpecularPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcNormalSpecularColor( Input );
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

PixelOutput NormalSpecularShadowPS( VertexOutputShadow Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcNormalSpecularColor( ( VertexOutput )Input );
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.Color.xyz *= CalcShadow( Input.LightSpacePos );
#endif
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}
#else
float4x4 g_ViewMat				: VIEW;

float4 NormalSpecularPS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 SpecularTex = tex2D( g_SpecularSampler, Input.TexCoord0 );
	float3 NormalTex = g_BumpPower * ( tex2D( g_NormalSampler, Input.TexCoord0 ).xyz - 0.5 );

	float3 WorldViewNormal = normalize( Input.WorldViewNormal );
	float3 WorldViewTangent = normalize( Input.WorldViewTangent );
	float3 WorldViewBinormal = normalize( Input.WorldViewBinormal );

	NormalTex = normalize( WorldViewNormal + ( NormalTex.x * WorldViewTangent + NormalTex.y * WorldViewBinormal ) );

	// calculate Directional Light
	float4 DiffuseLight;
	float4 SpecularLight;
	float3 HalfWayVec;

	float3 LightDir = mul( g_LightDir, g_ViewMat );
	DiffuseLight.xyz = g_LightDiffuse.xyz * max( 0 , dot( NormalTex, LightDir ) );
	DiffuseLight.w = g_MaterialAmbient.w;

	HalfWayVec = normalize( Input.WorldViewEyeVec + LightDir );
	SpecularLight.xyz = g_LightSpecular.xyz * pow( max( 0 , dot( NormalTex, HalfWayVec ) ) , g_SpecPower );
	SpecularLight.w = 0.0f;

	DiffuseLight = ( g_LightAmbient * g_MaterialAmbient + g_MaterialDiffuse * DiffuseLight ) * DiffuseTex;
	SpecularLight = g_MaterialSpecular * SpecularLight * SpecularTex;
	float4 Result = DiffuseLight + SpecularLight;
	
	return Result;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
technique NormalSpecularTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularVS();
		PixelShader  = compile ps_3_0 NormalSpecularPS();
    }
}

technique NormalSpecularAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularAniVS();
		PixelShader  = compile ps_3_0 NormalSpecularPS();
    }
}
technique NormalSpecularShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularShadowVS();
		PixelShader  = compile ps_3_0 NormalSpecularShadowPS();
    }
}

technique NormalSpecularAniShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularAniShadowVS();
		PixelShader  = compile ps_3_0 NormalSpecularShadowPS();
    }
}
#else
technique NormalSpecularTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularVS();
		PixelShader  = compile ps_3_0 NormalSpecularPS();
    }
}
#endif
