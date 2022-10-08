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
float4x4 g_InvViewMat				: INVVIEW;
#ifdef BAKE_VELOCITY
float4x4 g_PrevWorldViewProjMat		: PREVWORLDVIEWPROJ;
float4x4 g_InvWorldViewPrevWVPMat : INVWORLDVIEWPREVWORLDVIEWPROJ;
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat				: PROJECTION;
shared float g_fElapsedTime				: TIME;

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
#define _USE_EMISSIVE_
#include "MaterialColor.fxh"

texture2D g_EnvTex : ENVTEXTURE
< 
	string UIName = "Environment Texture";
>;
sampler2D g_EnvSampler = sampler_state
{
	texture = < g_EnvTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float4 TexCoord0			: TEXCOORD0;
    float3 Tangent				: TANGENT;
    float3 Binormal				: BINORMAL;
};

struct VertexInputAni {
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float4 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
    float3 Tangent				: TANGENT;
    float3 Binormal				: BINORMAL;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float3 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
    float3 WorldViewPos			: TEXCOORD2;
    float3 WorldViewEyeVec		: TEXCOORD3;
    float3 WorldViewNormal		: TEXCOORD4;
    float3 WorldViewTangent		: TEXCOORD5;
    float3 WorldViewBinormal	: TEXCOORD6;
    float3 Reflect				: TEXCOORD7;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD8;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD9;
#endif
};

struct VertexOutputShadow
{
    float4 Position				: POSITION;
    float3 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
    float3 WorldViewPos			: TEXCOORD2;
    float3 WorldViewEyeVec		: TEXCOORD3;
    float3 WorldViewNormal		: TEXCOORD4;
    float3 WorldViewTangent		: TEXCOORD5;
    float3 WorldViewBinormal	: TEXCOORD6;
    float3 Reflect				: TEXCOORD7;
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
    float4 LightSpacePos		: TEXCOORD8;
#endif
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD9;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD10;
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
VertexOutput NormalSpecularReflectVS( VertexInput Input ) 
{
	VertexOutput Output;

	CalcNormalSpecular;	
	Output.Fog.zw = CalcFogValue( Output.Position.z );

	Output.TexCoord0.z = 0;
	float3 WorldViewReflect = reflect( normalize( Output.WorldViewPos ), Output.WorldViewNormal );
	Output.Reflect = normalize( mul( WorldViewReflect, g_InvViewMat ) );
	Output.Reflect.y = 0.5f - Output.Reflect.y * 0.5f;
		

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

VertexOutputShadow NormalSpecularReflectShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;

	CalcNormalSpecular;	
	Output.Fog.zw = CalcFogValue( Output.Position.z );

	Output.TexCoord0.z = 0;
	float3 WorldViewReflect = reflect( normalize( Output.WorldViewPos ), Output.WorldViewNormal );
	Output.Reflect = normalize( mul( WorldViewReflect, g_InvViewMat ) );
	Output.Reflect.y = 0.5f - Output.Reflect.y * 0.5f;


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

VertexOutput NormalSpecularReflectAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	CalcNormalSpecularAni
	Output.Fog.zw = CalcFogValue( Output.Position.z );
	
	Output.TexCoord0.z = 0;
	float3 WorldViewReflect = reflect( normalize( Output.WorldViewPos ), Output.WorldViewNormal );
	Output.Reflect = normalize( mul( WorldViewReflect, g_InvViewMat ) );
	Output.Reflect.y = 0.5f - Output.Reflect.y * 0.5f;
	
	
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

VertexOutputShadow NormalSpecularReflectAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;

	CalcNormalSpecularAni
	Output.Fog.zw = CalcFogValue( Output.Position.z );

	Output.TexCoord0.z = 0;
	float3 WorldViewReflect = reflect( normalize( Output.WorldViewPos ), Output.WorldViewNormal );
	Output.Reflect = normalize( mul( WorldViewReflect, g_InvViewMat ) );
	Output.Reflect.y = 0.5f - Output.Reflect.y * 0.5f;
	

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
float4 CalcNormalSpecularReflectColor( VertexOutput Input )
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
	// calculate Spot Light
#endif
#ifndef DISABLE_SPOT_LIGHT
	for( i = 0; i < g_SpotLightCount; i++ )
	{
		CalcSpotLight( DiffuseLight, SpecularLight, i, NormalTex, Input.WorldViewEyeVec, Input.WorldViewPos );
	}
#endif
	
	float2 TexCoord;
	TexCoord.x = frac( atan2( Input.Reflect.x, Input.Reflect.z ) / (6.283185308 ) + 1.0f );
	TexCoord.y = Input.Reflect.y;
	float4 EnvTex = tex2D( g_EnvSampler, TexCoord );
	EnvTex *= (SpecularLight * SpecularTex);
	
	DiffuseLight = ( g_LightAmbient * g_MaterialAmbient + g_MaterialDiffuse * DiffuseLight ) * DiffuseTex;
	SpecularLight = g_MaterialSpecular * SpecularLight * SpecularTex;
	float4 Result = DiffuseLight + SpecularLight;
		
	// Emissive Àû¿ë.
	float fEmissive = g_EmissivePower + g_EmissivePowerRange * cos( g_fElapsedTime * g_EmissiveAniSpeed );
	float4 EmissiveTex = tex2D( g_EmissiveSampler, Input.TexCoord0 ) * fEmissive;
	Result.xyz = lerp( Result.xyz, EmissiveTex.xyz, EmissiveTex.a );
			
	Result += EnvTex;
	
	Result.xyz = CalcFogColor( Result.xyz, Input.Fog );
	
	return Result;	
}

PixelOutput NormalSpecularReflectPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcNormalSpecularReflectColor( Input );
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

PixelOutput NormalSpecularReflectShadowPS( VertexOutputShadow Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcNormalSpecularReflectColor( ( VertexOutput )Input );
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

float4 NormalSpecularReflectPS( VertexOutput Input ) : COLOR
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

	float2 TexCoord;
	TexCoord.x = frac( atan2( Input.Reflect.x, Input.Reflect.z ) / (6.283185308 ) + 1.0f );
	TexCoord.y = Input.Reflect.y;
	float4 EnvTex = tex2D( g_EnvSampler, TexCoord );
	EnvTex *= (SpecularLight * SpecularTex);

	DiffuseLight = ( g_LightAmbient * g_MaterialAmbient + g_MaterialDiffuse * DiffuseLight ) * DiffuseTex;
	SpecularLight = g_MaterialSpecular * SpecularLight * SpecularTex;
	float4 Result = DiffuseLight + SpecularLight + EnvTex;
	
	return Result;
}
#endif


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
technique NormalSpecularReflectTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularReflectVS();
		PixelShader  = compile ps_3_0 NormalSpecularReflectPS();
    }
}
technique NormalSpecularReflectAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularReflectAniVS();
		PixelShader  = compile ps_3_0 NormalSpecularReflectPS();
    }
}
technique NormalSpecularReflectShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularReflectShadowVS();
		PixelShader  = compile ps_3_0 NormalSpecularReflectShadowPS();
    }
}
technique NormalSpecularReflectAniShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularReflectAniShadowVS();
		PixelShader  = compile ps_3_0 NormalSpecularReflectShadowPS();
    }
}
#else
technique NormalSpecularReflectTech
{
    pass p0 
    {		
		VertexShader = compile vs_3_0 NormalSpecularReflectVS();
		PixelShader  = compile ps_3_0 NormalSpecularReflectPS();
    }
}
#endif
