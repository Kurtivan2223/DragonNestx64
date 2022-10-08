#include "CalcBlendBone.fxh"
#include "CalcFog.fxh"
#include "CalcLight.fxh"
#include "CalcShadow.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
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

// Scale Distribution
#define SCALE_DISTRIBUTE (100.0f)
#define INV_SCALE_DISTRIBUTE (0.01f)

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
#define _USE_DIFFUSE_
#include "MaterialColor.fxh"


float g_DepthAlphaRef = 0.5f;		// 이곳부터  추가해야지 안꼬인다..
//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position		: POSITION;
    float3 Normal			: NORMAL;
    float2 TexCoord0	: TEXCOORD0;
    
    float4 matWV1		: TEXCOORD1;
    float4 matWV2 		: TEXCOORD2;
    float4 matWV3 		: TEXCOORD3;
    float4 matWV4 		: TEXCOORD4;
};

struct VertexDepthInput
{
    float3 Position		: POSITION;
    float2 TexCoord0	: TEXCOORD0;
    
    float4 matWV1		: TEXCOORD1;
    float4 matWV2 		: TEXCOORD2;
    float4 matWV3 		: TEXCOORD3;
    float4 matWV4 		: TEXCOORD4;
};

struct VertexDepthInputOpaque
{
    float3 Position		: POSITION;
    float4 matWV1		: TEXCOORD1;
    float4 matWV2 		: TEXCOORD2;
    float4 matWV3 		: TEXCOORD3;
    float4 matWV4 		: TEXCOORD4;
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

struct VertexDepthOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float DepthValue			: TEXCOORD1;
};

struct VertexDepthOutputOpaque
{
    float4 Position				: POSITION;
    float DepthValue			: TEXCOORD0;
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

VertexOutput DiffuseVS( VertexInput Input ) 
{
	VertexOutput Output;

	float4x4 WorldViewMat = float4x4( Input.matWV1, Input.matWV2, Input.matWV3, Input.matWV4);

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), WorldViewMat );	
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	float3 WorldViewNormal = normalize(mul( Input.Normal, WorldViewMat ));

	float4 DiffuseLight = float4( 0.0f, 0.0f, 0.0f, 1.0f );
	DiffuseLight = CalcDiffuseAll( DiffuseLight, WorldViewNormal, WorldViewPos );

	float4 Ambient = g_MaterialAmbient * g_LightAmbient;
	float4 Diffuse = g_MaterialDiffuse * DiffuseLight;	
	Output.Color = Diffuse + Ambient;
	Output.Color.w = g_MaterialAmbient.w;
	Output.TexCoord0 = Input.TexCoord0;

	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;
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

VertexDepthOutput BakeDepthVS( VertexDepthInput Input ) 
{
	VertexDepthOutput Output;

	float4x4 WorldViewMat = float4x4( Input.matWV1, Input.matWV2, Input.matWV3, Input.matWV4);

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), WorldViewMat );
	
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;

	return Output;
}

VertexDepthOutputOpaque BakeDepthOpaqueVS( VertexDepthInputOpaque Input ) 
{
	VertexDepthOutputOpaque Output;

	float4x4 WorldViewMat = float4x4( Input.matWV1, Input.matWV2, Input.matWV3, Input.matWV4);

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), WorldViewMat );
	
	Output.Position = mul( float4( WorldViewPos, 1.0f ), g_ProjMat );
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;
	
	return Output;
}

#else

VertexOutput DiffuseVS( VertexInput Input ) 
{
	VertexOutput Output = (VertexOutput)0;

	return Output;
}
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 CalcDiffuseColor( VertexOutput Input )
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	float4 Result = Input.Color * DiffuseTex;
	
	return Result;
}

PixelOutput DiffusePS( VertexOutput Input )
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

float4 BakeDepthPS( VertexDepthOutput Input ) : COLOR
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	clip( DiffuseTex.a - g_DepthAlphaRef );	// 현재 D3DRS_ALPHAREF를 무조건 0x80정도로 생각해서 하드코딩한 값이다 나중에 파라메터로 받던지 어케 하자
	
	float fDepth = Input.DepthValue;// * SCALE_DISTRIBUTE;
	return float4(fDepth.xxx, DiffuseTex.a);
}

float4 BakeDepthOpaquePS( VertexDepthOutputOpaque Input ) : COLOR
{
	float fDepth = Input.DepthValue;// * SCALE_DISTRIBUTE;
	return float4(fDepth.xxx, 1.0);
}


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
technique DiffuseTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseVS();
		PixelShader  = compile ps_2_0 DiffusePS();
    }
}

technique BakeDepthTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthVS();
		PixelShader  = compile ps_2_0 BakeDepthPS();
    }
}

technique BakeDepthOpaqueTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthOpaqueVS();
		PixelShader  = compile ps_2_0 BakeDepthOpaquePS();
    }
}

#else
technique DiffuseTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DiffuseVS();
		PixelShader  = compile ps_2_0 DiffusePS();
    }
}
#endif
