#include "CalcBlendBone.fxh"
#include "CalcFog.fxh"
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
float4 g_LightSpecular : LIGHTSPECULAR
<
> = { 1.0f, 1.0f, 1.0f, 1.0f };
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
#define _USE_DIFFUSE_
#define _USE_SPECULAR_
#include "MaterialColor.fxh"
#include "CalcLight.fxh"

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
    float4 Diffuse				: TEXCOORD1;
    float4 Specular				: TEXCOORD2;
    float4 Fog		    		: TEXCOORD3;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD4;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD5;
#endif
};

struct VertexOutputShadow
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 Diffuse				: TEXCOORD1;
    float4 Specular				: TEXCOORD2;
    float4 Fog		    		: TEXCOORD3;
#if defined( SIMPLE_SHADOWMAP ) || defined( DEPTH_SHADOWMAP )
    float4 LightSpacePos		: TEXCOORD4;
#endif
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD5;
#endif
#ifdef BAKE_VELOCITY
    float2 Velocity				: TEXCOORD6;
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
#define CalcSpecular																				\
	Output.Position = mul( float4( Input.Position.xyz , 1.0 ) , g_WorldViewProjMat );				\
																									\
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat ).xyz;			\
	float3 EyeVec = -normalize( WorldViewPos );														\
	float3 WorldViewNormal = mul( Input.Normal, g_WorldViewMat );									\
																									\
	TwoLight LightColor;																			\
	LightColor.Diffuse = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	LightColor.Specular = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	CalcLightAll( LightColor, WorldViewNormal, EyeVec, WorldViewPos );								\
																									\
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;											\
	float4 Diffuse = g_MaterialDiffuse * LightColor.Diffuse;										\
	Output.Diffuse = Diffuse + Ambient;																\
	Output.Diffuse.w = g_MaterialAmbient.w;															\
    Output.Specular = g_MaterialSpecular * LightColor.Specular;										\
	Output.TexCoord0 = Input.TexCoord0;																\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\
	

VertexOutput SpecularVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	CalcSpecular;
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

VertexOutputShadow SpecularShadowVS( VertexInput Input ) 
{
	VertexOutputShadow Output;
	
	CalcSpecular;
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

#define CalcSpecularAni																				\
    float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );		\
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );								\
	float3 EyeVec = -normalize( WorldViewPos );														\
																									\
	float3 WorldViewNormal = CalcBlendNormal( Input.Normal, Input.nBoneIndex, Input.fWeight );		\
																									\
	TwoLight LightColor;																			\
	LightColor.Diffuse = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	LightColor.Specular = float4( 0.0f, 0.0f, 0.0f, 1.0f );											\
	CalcLightAll( LightColor, WorldViewNormal, EyeVec, WorldViewPos );								\
																									\
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;											\
	float4 Diffuse = g_MaterialDiffuse * LightColor.Diffuse;										\
	Output.Diffuse = Diffuse + Ambient;																\
	Output.Diffuse.w = g_MaterialAmbient.w;															\
    Output.Specular = g_MaterialSpecular * LightColor.Specular;										\
	Output.TexCoord0 = Input.TexCoord0;																\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\


VertexOutput SpecularAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	CalcSpecularAni;
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

VertexOutputShadow SpecularAniShadowVS( VertexInputAni Input )
{
	VertexOutputShadow Output;
	
	CalcSpecularAni;
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

VertexOutput SpecularVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = mul( float4( Input.Position.xyz , 1.0 ) , g_WorldViewProjMat );

	float3 EyeVec = -normalize( mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat ).xyz );
	float3 TransformNormal = normalize( mul( Input.Normal, g_WorldViewMat ) );
	float3 LightVec = normalize( mul( g_LightDir, g_ViewMat ) );
	float3 HalfWayVec = normalize( EyeVec + LightVec );

	float  DiffuseLight = saturate( 0 , dot( TransformNormal, LightVec ) );
    float  SpecularLight = pow( max( 0 , dot( TransformNormal, HalfWayVec ) ) , g_SpecPower );
	float4 Ambient = g_MaterialAmbient * g_LightAmbient;
	float4 Diffuse = g_MaterialDiffuse * g_LightDiffuse * DiffuseLight;
	Output.Color = Diffuse + Ambient;
	Output.Color.w = g_MaterialAmbient.w;
    Output.Specular = g_MaterialSpecular * g_LightSpecular * SpecularLight;
	Output.Fog = 0.0f;

	Output.TexCoord0 = Input.TexCoord0;
	
	Output.Diffuse.xyz = DiffuseLight;

	return Output;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcSpecularColor( VertexOutput Input )
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 SpecularTex = tex2D( g_SpecularSampler, Input.TexCoord0 );
	float4 Result = Input.Diffuse * DiffuseTex + float4( Input.Specular.xyz * SpecularTex.xyz, 0.f );
	
	return Result;
}

PixelOutput SpecularPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcSpecularColor( Input );
	
	Output.Color.xyz = CalcFogColor( Output.Color.xyz, Input.Fog );
	
#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif
#ifdef BAKE_VELOCITY
	Output.Velocity = float4( Input.Velocity, 0.0f, 1.0f );
#endif

	return Output;
}

PixelOutput SpecularShadowPS( VertexOutputShadow Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = CalcSpecularColor( ( VertexOutput )Input );
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
technique SpecularTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SpecularVS();
		PixelShader  = compile ps_2_0 SpecularPS();
    }
}
technique SpecularAniTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SpecularAniVS();
		PixelShader  = compile ps_2_0 SpecularPS();
    }
}
technique SpecularShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SpecularShadowVS();
		PixelShader  = compile ps_2_0 SpecularShadowPS();
    }
}
technique SpecularAniShadowTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SpecularAniShadowVS();
		PixelShader  = compile ps_2_0 SpecularShadowPS();
    }
}
#else
technique SpecularTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 SpecularVS();
		PixelShader  = compile ps_2_0 SpecularPS();
    }
}
#endif