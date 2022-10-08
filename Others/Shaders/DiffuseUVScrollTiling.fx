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
float4x4 g_ProjMat				: PROJECTION;
float g_fFXElapsedTime				: FXTIME
<
    string UIName = "FX Time";
> = 0.0f;

float g_StartTime				: STARTTIME
<
    string UIName = "Start Time";
> = 0.0f;

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
#define _USE_DIFFUSE_
#include "MaterialColor.fxh"

texture2D g_MaskTex : MASKTEXTURE
< 
	string UIName = "Scroll Mask Texture";
>;
sampler2D g_MaskSampler = sampler_state
{
	texture = < g_MaskTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float g_ScrollSpeedU		: SCROLLSPEEDU
<
    string UIName = "Scroll Speed U";
> = 0.0f;
float g_ScrollSpeedV		: SCROLLSPEEDV
<
    string UIName = "Scroll Speed V";
> = 0.0f;
float g_ScrollTiling		: TILINGSCALE
<
    string UIName = "Scroll Tiling";
> = 1.0f;

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexInputAni {
    float3 Position				: POSITION;
    float3 Normal				: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Color				: TEXCOORD1;
    float4 Fog		    		: TEXCOORD2;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD3;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD4;
#endif
};

struct VertexOutputShadow
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Color				: TEXCOORD1;
    float4 Fog		    		: TEXCOORD2;
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
    float4 LightSpacePos		: TEXCOORD3;
#endif
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD4;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD5;
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
#define CalcDiffuse																				\
																									\
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );	\
	Output.Position = mul( float4(WorldViewPos,1), g_ProjMat );	\
	float3 WorldViewNormal = mul( Input.Normal, g_WorldViewMat );						\
																						\
	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	DiffuseLight = CalcDiffuseAll( DiffuseLight, WorldViewNormal, WorldViewPos );					\
																						\
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;								\
	float4 Diffuse = g_MaterialDiffuse * DiffuseLight;									\
	Output.Color = Diffuse + Ambient;													\
	Output.Color.w = g_MaterialAmbient.w;												\
	Output.TexCoord0 = Input.TexCoord0;													\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\
	

VertexOutput DiffuseUVScrollVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	CalcDiffuse;
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

VertexOutputShadow DiffuseUVScrollShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;
	
	CalcDiffuse;
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjMat );
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

#define 	CalcDiffuseAni																			\
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
	Output.TexCoord0 = Input.TexCoord0;																\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\
	

VertexOutput DiffuseUVScrollAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	CalcDiffuseAni;
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

VertexOutputShadow DiffuseAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;
	
	CalcDiffuseAni;
	Output.Fog.zw = CalcFogValue( Output.Position.z );
	
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( WorldViewPos.xyz, 1.0f ) , g_InvViewLightViewProjMat );
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

VertexOutput DiffuseUVScrollVS( VertexInput Input ) 
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
	
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcDiffuseColor( VertexOutput Input )
{
	float4 MaskTex = tex2D( g_MaskSampler, Input.TexCoord0 );
	float2 AddCoord = float2( frac( g_ScrollSpeedU * (g_fFXElapsedTime+g_StartTime) ), frac( g_ScrollSpeedV * (g_fFXElapsedTime+g_StartTime) ) ) * MaskTex.r;
	float4 DiffuseTex = tex2D( g_DiffuseSampler, float2(0,1)+float2(1,g_ScrollTiling)*Input.TexCoord0 - float2(1,g_ScrollTiling+1)*AddCoord );
	float4 Result = Input.Color * DiffuseTex;
	Result.a *= MaskTex.a;
	
	return Result;
}

PixelOutput DiffuseUVScrollPS( VertexOutput Input )
{
	PixelOutput Output;

	Output.Color = CalcDiffuseColor( Input );
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif
	
	return Output;
}

PixelOutput DiffuseUVScrollShadowPS( VertexOutputShadow Input )
{
	PixelOutput Output;

	Output.Color = CalcDiffuseColor( ( VertexOutput )Input );
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
technique DiffuseTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseUVScrollVS();
		PixelShader  = compile ps_2_0 DiffuseUVScrollPS();
    }
}
technique DiffuseAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseUVScrollAniVS();
		PixelShader  = compile ps_2_0 DiffuseUVScrollPS();
    }
}
technique DiffuseShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseUVScrollShadowVS();
		PixelShader  = compile ps_2_0 DiffuseUVScrollShadowPS();
    }
}
technique DiffuseAniShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseAniShadowVS();
		PixelShader  = compile ps_2_0 DiffuseUVScrollShadowPS();
    }
}
#else
technique DiffuseTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseUVScrollVS();
		PixelShader  = compile ps_2_0 DiffuseUVScrollPS();
    }
}
#endif
