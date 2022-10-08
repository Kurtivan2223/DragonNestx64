#include "CalcBlendBone.fxh"
#include "CalcFog.fxh"
#include "CalcShadow.fxh"
#include "CalcLight.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;
float4x4 g_ModelViewMat			: MODELVIEW;
float4x4 g_InvViewModelViewMat	: INVVIEWMODELVIEW;
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
float g_fAmbientMapScale
<
	string UIName = "AmbientMap Strength";
	string UIType = "IntSpinner";
	float UIMin = 0.0f;
	float UIMax = 10.0f;	
>  = 1.0f;

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

texture2D g_ChannelTex : CHANNELTEXTURE
< 
	string UIName = "Channel Texture";
>;
sampler2D g_ChannelSampler = sampler_state
{
	texture = < g_ChannelTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_MaskTex : MASKTEXTURE
< 
	string UIName = "Mask Texture";
>;
sampler2D g_MaskSampler = sampler_state
{
	texture = < g_MaskTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

textureCUBE g_AmbientTex : AMBIENTTEXTURE
< 
	string UIName = "Ambient Texture";
>;
samplerCUBE g_AmbientSampler = sampler_state
{
	texture = < g_AmbientTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

textureCUBE g_AmbientTex2 : AMBIENTTEXTURE2
< 
	string UIName = "Ambient Texture 2";
>;
samplerCUBE g_AmbientSampler2 = sampler_state
{
	texture = < g_AmbientTex2 >;
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
    float3 Normal				: TEXCOORD0;
    float2 TexCoord0			: TEXCOORD1;
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
    float3 Normal				: TEXCOORD0;
    float2 TexCoord0			: TEXCOORD1;
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

#define CalcDiffuse																						\
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewProjMat );	\
	Output.Normal = normalize( mul( Input.Normal, g_WorldViewMat ) );					\
	Output.TexCoord0 = Input.TexCoord0;															\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\


VertexOutput AmbientMapVS( VertexInput Input )
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

VertexOutputShadow AmbientMapShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;
	
	CalcDiffuse;
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldLightViewProjMat );
	Output.LightSpacePos.z = dot( float4( Input.Position.xyz, 1.0f ), g_WorldLightViewProjDepth ) * Output.LightSpacePos.w;
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

#define 	CalcDiffuseAni																											\
    float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );			\
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );												\
	Output.Normal = CalcBlendNormal( Input.Normal, Input.nBoneIndex, Input.fWeight );					\
	Output.TexCoord0 = Input.TexCoord0;																					\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\


VertexOutput AmbientMapAniVS( VertexInputAni Input )
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

VertexOutputShadow AmbientMapAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;
	
	CalcDiffuseAni;
	Output.Fog.zw = CalcFogValue( Output.Position.z );

#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
	Output.LightSpacePos = mul( float4( WorldViewPos.xyz, 1.0f ) , g_InvViewLightViewProjMat );
	Output.LightSpacePos.z = dot( float4( WorldViewPos, 1.0f ), g_InvViewLightViewProjDepth ) * Output.LightSpacePos.w;
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

VertexOutput AmbientMapVS( VertexInput Input ) 
{
	VertexOutput Output;

	Output.Position = mul( float4( Input.Position.xyz , 1.0 ) , g_WorldViewProjMat );
	Output.Normal = mul( Input.Normal, g_ViewMat );
	Output.TexCoord0 = Input.TexCoord0;
	Output.Fog = 0.0f;

	return Output;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcDiffuseColor( VertexOutput Input )
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 ChannelTex = tex2D( g_ChannelSampler, Input.TexCoord0 );
	float4 MaskTex = tex2D( g_MaskSampler, Input.TexCoord0 );
	float4 AmbientTex = texCUBE( g_AmbientSampler, Input.Normal.xyz );
	float4 AmbientTex2 = texCUBE( g_AmbientSampler2, Input.Normal );

	AmbientTex = lerp( AmbientTex2, AmbientTex, 1.0f ) * MaskTex;
	float4 Result = g_fAmbientMapScale * AmbientTex + DiffuseTex * g_LightAmbient; 
	Result.a = DiffuseTex.a;

	return Result;
}

PixelOutput AmbientMapPS( VertexOutput Input ) : COLOR
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

PixelOutput AmbientMapShadowPS( VertexOutputShadow Input ) : COLOR
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
technique AmbientMapTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 AmbientMapVS();
		PixelShader  = compile ps_2_0 AmbientMapPS();
    }
}
technique AmbientMapAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 AmbientMapAniVS();
		PixelShader  = compile ps_2_0 AmbientMapPS();
    }
}
technique AmbientMapShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 AmbientMapShadowVS();
		PixelShader  = compile ps_2_0 AmbientMapShadowPS();
    }
}
technique AmbientMapAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 AmbientMapAniShadowVS();
		PixelShader  = compile ps_2_0 AmbientMapShadowPS();
    }
}
#else
technique AmbientMapTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 AmbientMapVS();
		PixelShader  = compile ps_2_0 AmbientMapPS();
    }
}
#endif
