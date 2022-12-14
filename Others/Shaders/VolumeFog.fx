//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
#include "CalcFog.fxh"
float4x4 g_WorldViewProjMat		: WORLDVIEWPROJ;

float4	g_CamXVector : CAMXVECTOR;
float4 g_CamYVector : CAMYVECTOR;
float4 g_CamPos  : CAMPOS;
float	g_fFogHeight		: VFOGHEIGHT;
float4 g_VolumeFogColor		: VFOGCOLOR
= { 1.0f, 1.0f, 1.0f, 1.0f };
//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float g_fElapsedTime				: TIME;

//////////////////////////////////////////////////////////////////////////////////////////////
// Global Param
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////
texture2D g_VolumeFogTex : FOGTEXTURE;
sampler2D g_VolumeFogSampler = sampler_state
{
	texture = < g_VolumeFogTex >;
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

struct VertexOutput 
{
    float4 Position				: POSITION;
    float3 TexCoord0			: TEXCOORD0;
    float4 Fog		    		: TEXCOORD2;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput VolumeFogVS( VertexInput Input ) 
{
	VertexOutput Output;
	float3 Position = Input.Position;
	float fracPos = frac(Position.z);

	Position += 1.5*g_fFogHeight*g_CamXVector.xyz * (Input.TexCoord0.x - 0.5);
	Position += g_fFogHeight*g_CamYVector.xyz * (1.0 - Input.TexCoord0.y);
	
	Position.x += sin( 6.283185308 * fracPos + g_fElapsedTime*1.5 )*50;

	float3 CamZVector = cross(g_CamXVector.xyz, g_CamYVector.xyz);
	
	float dist = dot( g_CamPos, CamZVector ) - dot( Input.Position, CamZVector ) ;

	Output.TexCoord0.z = saturate( (abs(dist) - 50.f) / 150.0f );

	Output.Position = mul( float4( Position, 1.0f ), g_WorldViewProjMat );
	Output.TexCoord0.xy = Input.TexCoord0;

	Output.Fog.zw = CalcFogValue( Output.Position.z );
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;
	Output.Fog.y = 1.0f - Output.Fog.y;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
float4 VolumeFogPS( VertexOutput Input ) : COLOR
{
	float4 result = g_VolumeFogColor*tex2D( g_VolumeFogSampler, Input.TexCoord0.xy );
	result.xyz = CalcFogColor( result.xyz, Input.Fog );
	result.w *= Input.TexCoord0.z;
	return result;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique VolumeFogTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 VolumeFogVS();	
		PixelShader  = compile ps_2_0 VolumeFogPS();
    }
}
