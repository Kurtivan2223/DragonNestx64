#include "CalcBlendBone.fxh"
#include "CalcFog.fxh"
#include "CalcLight.fxh"
#include "CalcShadow.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;
#ifdef BAKE_VELOCITY
float4x4 g_PrevWorldViewProjMat		: PREVWORLDVIEWPROJ;
float4x4 g_InvWorldViewPrevWVPMat : INVWORLDVIEWPREVWORLDVIEWPROJ;
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat				: PROJECTION;

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
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
#include "MaterialColor.fxh"

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
};

struct VertexInputAni {
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float4 Color				: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD2;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD3;
#endif
};

struct VertexOutputShadow
{
    float4 Position				: POSITION;
    float4 Color				: TEXCOORD0;
    float4 Fog		    		: TEXCOORD1;
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
    float4 LightSpacePos		: TEXCOORD2;
#endif
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD3;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD4;
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
#ifdef ETERNITY_ENGINE
#define CalcDefault																		\
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );	\
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );		\
																						\
	float3 WorldViewNormal = mul( Input.Normal, g_WorldViewMat );						\
																						\
	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );								\
	DiffuseLight = CalcDiffuseAll( DiffuseLight, WorldViewNormal, WorldViewPos );		\
																						\
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;								\
	float4 Diffuse = g_MaterialDiffuse * DiffuseLight;									\
	Output.Color = Diffuse + Ambient;													\
	Output.Color.w = g_MaterialAmbient.w;												\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\
																						\
	
	
VertexOutput DefaultVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	CalcDefault;
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

VertexOutputShadow DefaultShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;
	
	CalcDefault;
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

#define 	CalcDefaultAni																			\
    float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );		\
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );								\
																									\
	float3 WorldViewNormal = CalcBlendNormal( Input.Normal, Input.nBoneIndex, Input.fWeight );		\
																									\
	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	DiffuseLight = CalcDiffuseAll( DiffuseLight, WorldViewNormal, WorldViewPos );					\
																									\
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;											\
	float4 Diffuse = g_MaterialDiffuse * DiffuseLight;												\
	Output.Color = Diffuse + Ambient;																\
	Output.Color.w = g_MaterialAmbient.w;															\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\


VertexOutput DefaultAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	CalcDefaultAni;
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

VertexOutputShadow DefaultAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;

	CalcDefaultAni;
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

#else
float4x4 g_ViewMat				: VIEW;

VertexOutput DefaultVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz , 1.0 ) , g_WorldViewProjMat );

	float3 TransformNormal = normalize( mul( Input.Normal, g_WorldViewMat ) );
	float3 LightVec = normalize( mul( g_LightDir, g_ViewMat ) );

	float  DiffuseLight = saturate( dot( TransformNormal, LightVec ) );
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;
	float4 Diffuse = g_MaterialDiffuse * g_LightDiffuse * DiffuseLight;
	Output.Color = Diffuse + Ambient;
	Output.Color.w = g_MaterialAmbient.w;
	Output.Fog = 0.0f;
	
	return Output;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput DefaultPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = Input.Color;
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

PixelOutput DefaultShadowPS( VertexOutputShadow Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = Input.Color;
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


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
technique DefaultTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DefaultVS();
		PixelShader  = compile ps_2_0 DefaultPS();
    }
}
technique DefaultAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DefaultAniVS();
		PixelShader  = compile ps_2_0 DefaultPS();
    }
}
technique DefaultShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DefaultShadowVS();
		PixelShader  = compile ps_2_0 DefaultShadowPS();
    }
}
technique DefaultAniShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DefaultAniShadowVS();
		PixelShader  = compile ps_2_0 DefaultShadowPS();
    }
}
#else
technique DefaultTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DefaultVS();
		PixelShader  = compile ps_2_0 DefaultPS();
    }
}
#endif
