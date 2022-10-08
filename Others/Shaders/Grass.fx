#include "CalcFog.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;
#ifdef BAKE_VELOCITY
float4x4 g_PrevWorldViewProjMat		: PREVWORLDVIEWPROJ;
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat				: PROJECTION;
shared float g_fElapsedTime				: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
#define _USE_DIFFUSE_
#include "MaterialColor.fxh"

float4 g_InteractivePos  : INTERACTIVEPOS = float4(1000000,1000000,0,0);
#define g_InteractivePower (0.035f)
#define g_InteractiveRadius (100.0f)

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
	float Shake					: DEPTH0;
    float4 Color				: COLOR0;
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
VertexOutput GrassVS( VertexInput Input ) 
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
	Output.TexCoord0 = Input.TexCoord0;

	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;
	Output.Fog.zw = CalcFogValue( Output.Position.z );
	Output.Color = Input.Color;

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


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput GrassPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;

	Output.Color = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	Output.Color.xyz *= ( Input.Color.xyz * 2.0f );
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
technique GrassTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 GrassVS();
		PixelShader  = compile ps_2_0 GrassPS();
    }
}
