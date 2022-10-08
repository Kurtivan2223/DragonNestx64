#include "CalcFog.fxh"
#include "CalcShadow.fxh"
//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat			: WORLDVIEW;
float4x4 g_ProjMat					: PROJ;
float4x4 g_WorldMat					: WORLD;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_InvViewMat		: VIEWI;
shared float g_fElapsedTime			: TIME;

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

float3 g_DirLightDirection[ 5 ] : DIRLIGHTDIRECTION;
float4 g_DirLightSpecular[ 5 ]	: DIRLIGHTSPECULAR;


//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////

float g_fWaterDirectionX : WATERDIRECTIONX
<
    string UIName = "Water X Direction";
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.1f;
> = 1.0f;
float g_fWaterDirectionZ : WATERDIRECTIONZ
<
    string UIName = "Water Z Direction";
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.1f;
> = 1.0f;

float g_fWaterSpeed : WATERSPEED
<
    string UIName = "Water Speed";
    float UIMin = 0.0f;
    float UIMax = 1.0f;
    float UIStep = 0.005f;
> = 0.05f;
float g_fWaterWaveStrength : WATERWAVESTRENGTH
<
    string UIName = "Water Wave Strength";
    float UIMin = 0.01f;
    float UIMax = 0.1f;
    float UIStep = 0.005f;
> = 0.025f;

float4 g_fWaterColor : WATERCOLOR
<
	string UIName = "Water Color";
> = { 0.6f, 0.8f, 1.0f, 0.2f };

float4x4 g_LastViewMat	: LASTVIEW;

texture2D g_NormalTex : NORMALTEXTURE
< 
	string UIName = "Bump Texture";
>;
sampler2D g_NormalSampler = sampler_state
{
	texture = < g_NormalTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture2D g_DiffuseTex : NORMALTEXTURE
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

texture2D g_WaterMapTex : WATERTEXTURE
< 
	string UIName = "WaterMap Texture";
>;
sampler2D g_WaterMapSampler = sampler_state
{
	texture = < g_WaterMapTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
	BorderColor = { 0.0f, 0.0f, 0.0f, 0.0f};
};

texture2D g_TransparencyTex : TRANSPARENCYTEX
< 
	string UIName = "Transparency Texture";
>;
sampler2D g_TransparencySampler = sampler_state
{
	texture = < g_TransparencyTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Border;
	AddressV = Border;
	BorderColor = {0.0f, 0.0f, 0.0f, 1.0f};
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Vertex Buffer Declaration
//////////////////////////////////////////////////////////////////////////////////////////////
struct VertexInput
{
    float3 Position				: POSITION;
    float3 Normal					: NORMAL;
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoord1			: TEXCOORD1;
};

struct VertexOutput
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoord1			: TEXCOORD1;
    float4 OutPosition    		: TEXCOORD2;
	float3 Reflect				: TEXCOORD3;
	float2 Fog					: TEXCOORD4;
	float3 WorldViewPos			: TEXCOORD5;
#ifdef BAKE_DEPTHMAP
    float DepthValue			: TEXCOORD6;
#endif
	float4 ScreenPos		: TEXCOORD7;
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput WaterVS( VertexInput Input ) 
{
	VertexOutput Output;

	float3 WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldViewMat );
	Output.WorldViewPos = WorldViewPos;
	Output.Position = mul( float4( WorldViewPos, 1.0f ) , g_ProjMat );
	Output.OutPosition = Output.Position;
	Output.OutPosition.xy = ( Output.Position.xy + Output.Position.w ) * 0.5f;
	Output.OutPosition.y = Output.Position.w - Output.OutPosition.y;

	float fDist = g_FogFactor.z - Output.Position.z;
	Output.Fog.xy = fDist * g_FogFactor.xy;

	Output.TexCoord0 = Input.TexCoord0;
	Output.TexCoord1 = Input.TexCoord1;

	float3 WorldPos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldMat );
	float3 WorldNormal = mul( Input.Normal, g_WorldMat );
	float3 vEyeVec = normalize( WorldPos - g_InvViewMat[ 3 ].xyz );
	Output.Reflect = normalize( reflect( vEyeVec, WorldNormal ) );

#ifdef BAKE_DEPTHMAP
	Output.DepthValue = Output.Position.z;
#endif

	Output.ScreenPos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldMat );
	Output.ScreenPos = mul( Output.ScreenPos , g_LastViewMat );
	Output.ScreenPos = mul( Output.ScreenPos , g_ProjMat );

	Output.ScreenPos.xy = ( Output.ScreenPos.xy * 0.5f + Output.ScreenPos.w * 0.5f );
	Output.ScreenPos.y = Output.ScreenPos.w - Output.ScreenPos.y;
	
	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////
PixelOutput WaterPS( VertexOutput Input ) : COLOR
{
	PixelOutput Output;
	
	float fTime = g_fElapsedTime * g_fWaterSpeed;
	
	float2 VecDirection = float2( -fTime * g_fWaterDirectionX, fTime * g_fWaterDirectionZ );
	// 기본 Dir이랑 똑같이 움직이면 픽셀이 다음프레임에서도 같은 왜곡위치의 픽셀을 구해와서 울렁이는 효과가 없게된다.
	// 그래서 기본 Dir과 다른 값을 줘야하는데, 축소나 확대 Scale을 먹이면 왜곡과 유속이 같이 영향받게 되므로
	// 왜곡의 방향을 바꿈으로 다른 값이 되도록 하겠다.
	float2 VecNormalUV = float2( fTime * g_fWaterDirectionX, fTime * g_fWaterDirectionZ );
	float Transparency = tex2D( g_TransparencySampler, Input.TexCoord1 ).a;

	float3 NormalTex = ( tex2D( g_NormalSampler, Input.TexCoord0 + VecNormalUV ).xyz - 0.5f ) * g_fWaterWaveStrength;
	float4 diff = tex2D( g_DiffuseSampler, Input.TexCoord0 + VecDirection + NormalTex.xy );

	// 스펙큘러 마스크는 노말맵의 a채널에 넣어두기로 합니다.
	float4 SpecularTex = tex2D( g_NormalSampler, Input.TexCoord0 + VecDirection + NormalTex.xy );

	float4 SpecularLight = float4( 0.0f, 0.0f, 0.0f, 0.0f );
	float3 WorldViewEyeVec = -normalize( Input.WorldViewPos );
	float3 HalfWayVec = normalize( WorldViewEyeVec - g_DirLightDirection[ 0 ] );
	float3 WorldViewNormal = mul( float3( 0.0f, 1.0f, 0.0f ), g_WorldViewMat );
	WorldViewNormal = normalize( WorldViewNormal );
	SpecularLight.xyz += g_DirLightSpecular[ 0 ].xyz * pow( max( 0 , dot( WorldViewNormal, HalfWayVec ) ), 10.0f );
	SpecularLight.xyz = SpecularLight.xyz * SpecularTex.a;
	diff += SpecularLight;

	float2 ScreenPos = Input.ScreenPos.xy / Input.ScreenPos.w + NormalTex.xy;
	float3 reflectColor = tex2D( g_WaterMapSampler, ScreenPos );

	float2 fFogValue = saturate( Input.Fog.xy );

	Output.Color.rgb = lerp( reflectColor, g_fWaterColor.rgb, g_fWaterColor.a ) * float3(0.8,0.8,0.8);	
	Output.Color.rgb = lerp( Output.Color.rgb, diff, diff.a );
	Output.Color.a = Transparency;

	clip( 0.0001f - fFogValue.y );
	Output.Color.xyz = lerp( g_FogColor.xyz, Output.Color.xyz, fFogValue.x );

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, 1.0f );
#endif

	return Output;
	
}


//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
#ifdef ETERNITY_ENGINE
technique WaterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 WaterVS();
		PixelShader  = compile ps_2_0 WaterPS();
    }
}
#else
technique WaterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 WaterVS();
		PixelShader  = compile ps_2_0 WaterPS();
    }
}
#endif