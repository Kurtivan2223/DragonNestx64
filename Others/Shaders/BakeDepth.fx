#include "CalcBlendBone.fxh"
#include "CalcShadow.fxh"

//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewProjMat					: WORLDVIEWPROJ;
float4x4 g_WorldViewMat					: WORLDVIEW;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat					: PROJECTION;
shared float g_fElapsedTime					: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_ViewRotProjMat		: VIEWROTPROJ;

// Volume Texture Animation Time
float g_ComputeAniTimeForDepth = 0.0f;

// Scale Distribution
#define SCALE_DISTRIBUTE (100.0f)
#define INV_SCALE_DISTRIBUTE (0.01f)

// Grass Contant
float4 g_InteractivePos 					: INTERACTIVEPOS  = float4(1000000,1000000,0,0);
#define g_InteractivePower (0.035f)
#define g_InteractiveRadius (100.0f)

float g_AlphaRef				: ALPHAREF;

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
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

texture3D g_DiffuseVolumeTex : DIFFUSEVOLUMETEXTURE
< 
	string UIName = "Diffuse Volume Texture";
>;
sampler3D g_DiffuseVolumeSampler = sampler_state
{
	texture = < g_DiffuseVolumeTex >;
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
    float2 TexCoord0			: TEXCOORD0;
};

struct VertexInputAni 
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexInputOpaque
{
    float3 Position				: POSITION;
};

struct VertexInputAniOpaque
{
    float3 Position				: POSITION;
	int4   nBoneIndex			: BLENDINDICES;
	float4 fWeight				: BLENDWEIGHT;
};

struct VertexInputGrass
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
	float Shake					: DEPTH0;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float DepthValue			: TEXCOORD1;
};

struct VertexOutputOpaque
{
    float4 Position				: POSITION;
    float DepthValue			: TEXCOORD0;
};

struct VertexOutputSkybox
{
    float4 Position				: POSITION;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput BakeDepthVS( VertexInput Input ) 
{
	VertexOutput Output;

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4(WorldViewPos, 1.0f), g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;
	
	return Output;
}

VertexOutput BakeDepthAniVS( VertexInputAni Input )
{
	VertexOutput Output;
	
	float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );

	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );
	Output.TexCoord0 = Input.TexCoord0;
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;

    return Output;
}

VertexOutputOpaque BakeDepthOpaqueVS( VertexInputOpaque Input ) 
{
	VertexOutputOpaque Output;
	
	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ), g_WorldViewMat );
	Output.Position = mul( float4(WorldViewPos, 1.0f) , g_ProjMat );
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;
	
	return Output;
}

VertexOutputOpaque BakeDepthAniOpaqueVS( VertexInputAniOpaque Input )
{
	VertexOutputOpaque Output;

	float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;
	
    return Output;
}

VertexOutputSkybox BakeDepthSkyboxVS( VertexInput Input ) 
{
	VertexOutputSkybox Output;
	
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ), g_ViewRotProjMat );
	Output.Position.z = Output.Position.w*0.9999;

	return Output;
}

VertexOutput BakeDepthGrassVS( VertexInputGrass Input ) 
{
	VertexOutput Output;
	float4 MovePosition = float4( Input.Position.xyz, 1.0f );

	float2 vDir = MovePosition.xz - g_InteractivePos.xy;
	float fPower = length(vDir);
	vDir /= fPower;
	
	float fDirLength = length(g_InteractivePos.zw);
	float2 moveDir = g_InteractivePos.zw / fDirLength;
	float fDirPower = dot( -vDir, moveDir);
	if( fDirPower < 0 ) fDirPower = -fDirPower*0.3;
	
	float fDampingPower = 1.0f - abs( (2.0f * saturate( (fPower-(g_InteractiveRadius*0.5)) / (g_InteractiveRadius*1.5))) - 1.0f );
	fDampingPower = 3 * fDampingPower * fDampingPower - 2 * fDampingPower * fDampingPower * fDampingPower;
	fDampingPower = fDampingPower * fDirPower * fDirLength;

	float fCosine = cos( g_fElapsedTime + fDampingPower ) * Input.Shake;

	fCosine *= min(1.0f, fPower / g_InteractiveRadius );
	fPower = max(0, g_InteractiveRadius - fPower );
	vDir *= fPower;
	MovePosition.xz += vDir.xy * Input.Shake * g_InteractivePower;
	MovePosition.xz += fCosine;

	Output.Position = mul( MovePosition, g_WorldViewProjMat );
	Output.TexCoord0.xy = Input.TexCoord0.xy;
	Output.DepthValue = Output.Position.z * INV_SCALE_DISTRIBUTE;

	return Output;
}
//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 BakeDepthPS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	clip( DiffuseTex.a - g_AlphaRef );
	float fDepth = Input.DepthValue;
	return float4( fDepth.xxx,  DiffuseTex.a );
}

float4 BakeDepthVolumePS( VertexOutput Input ) : COLOR
{
	float4 DiffuseTex = tex3D( g_DiffuseVolumeSampler, float3(Input.TexCoord0, g_ComputeAniTimeForDepth) );
	clip( DiffuseTex.a - g_AlphaRef );
	float fDepth = Input.DepthValue;
	return float4(fDepth.xxx,  DiffuseTex.a );
}

float4 BakeDepthOpaquePS( VertexOutputOpaque Input ) : COLOR
{
	float fDepth = Input.DepthValue;
	return float4(fDepth.xxx, 1.0f);
}

float4 BakeDepthSkyboxPS( VertexOutputSkybox Input ) : COLOR
{
	float fDepth = 10000.0;
	return float4(fDepth.xxx, 1.0f);
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique BakeDepthTech			// 0
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthVS();
		PixelShader  = compile ps_2_0 BakeDepthPS();
    }
}
technique BakeDepthAniTech		// 1
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthAniVS();
		PixelShader  = compile ps_2_0 BakeDepthPS();
    }
}
technique BakeDepthSkyboxTech		// 2
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthSkyboxVS();
		PixelShader  = compile ps_2_0 BakeDepthSkyboxPS();
    }
}

technique BakeDepthGrassTech		// 3
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthGrassVS();
		PixelShader  = compile ps_2_0 BakeDepthPS();
    }
}

technique BakeDepthOpaqueTech		// 4
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthOpaqueVS();
		PixelShader  = compile ps_2_0 BakeDepthOpaquePS();
    }
}
technique BakeDepthAniOpaqueTech		// 5
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthAniOpaqueVS();
		PixelShader  = compile ps_2_0 BakeDepthOpaquePS();
    }
}

technique BakeDepthVolumeTech			// 6
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthVS();
		PixelShader  = compile ps_2_0 BakeDepthVolumePS();
    }
}
technique BakeDepthAniVolumeTech		// 7
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 BakeDepthAniVS();
		PixelShader  = compile ps_2_0 BakeDepthVolumePS();
    }
}
