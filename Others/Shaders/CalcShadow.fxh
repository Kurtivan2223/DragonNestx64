float4x4 g_WorldLightViewProjMat	: WORLDLIGHTVIEWPROJ;
float4x4 g_InvViewLightViewProjMat	: INVVIEWLIGHTVIEWPROJ;
float4 g_WorldLightViewProjDepth		: WORLDLIGHTVIEWPROJDEPTH;
float4 g_InvViewLightViewProjDepth		: INVVIEWLIGHTVIEWPROJDEPTH;
float3 g_fShadowDensity			: SHADOWDENSITY;

#if defined( SOFT_SHADOW )

texture2D g_ShadowMapTex : SHADOWMAPTEXTURE;
sampler2D g_ShadowMapSampler = sampler_state
{
    Texture = < g_ShadowMapTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Border;
	AddressV = Border;
	BorderColor = { 1.0f, 1.f, 1.0f, 1.0f};
};

float3 CalcShadow( float4 LightSpacePos )
{
	// Calculate Shadow Color
	float2 fShadowMapCoord = 0.5f * LightSpacePos.xy / LightSpacePos.w + float2( 0.5f, 0.5f );
	fShadowMapCoord.y = 1.0f - fShadowMapCoord.y;

    float moments = tex2D( g_ShadowMapSampler, fShadowMapCoord.xy ).x * 0.999;
    float fragDepth =  (LightSpacePos.z / LightSpacePos.w);
    float mD = max(0, (moments -  fragDepth ) * 2);
    float mD_2 = mD * mD;
    float3 ResultColor = saturate( mD_2 + g_fShadowDensity * 0.7 );
    return ResultColor;

}

float3 CalcTerrainShadow( float3 fShadowMapCoord, float3 AmbientColor, float3 LightMapColor )
{
    float moments = tex2D( g_ShadowMapSampler, fShadowMapCoord.xy ).x * 0.999;
    float fragDepth = fShadowMapCoord.z;;

    float mD =  max( fragDepth < 0 , (moments - fragDepth ) * 2 );
    float mD_2 = mD * mD;
    float lightAmount = saturate( mD_2 );
	float3 ResultColor = lerp( float3(-0.1, -0.1, -0.1) , LightMapColor,  lightAmount ) +	AmbientColor;
	return ResultColor;
}

#else	// #if defined( SOFT_SHADOW )

texture2D g_ShadowMapTex : SHADOWMAPTEXTURE;
sampler2D g_ShadowMapSampler = sampler_state
{
    Texture = < g_ShadowMapTex >;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
	AddressU = Border;
	AddressV = Border;
	BorderColor = { 1.0f, 1.f, 1.0f, 1.0f};
};

float3 CalcShadow( float4 LightSpacePos )
{
	// Calculate Shadow Color
	float2 fShadowMapCoord = 0.5f * LightSpacePos.xy / LightSpacePos.w + float2( 0.5f, 0.5f );
	fShadowMapCoord.y = 1.0f - fShadowMapCoord.y;
	return ( tex2D( g_ShadowMapSampler, fShadowMapCoord ).x < ( LightSpacePos.z / LightSpacePos.w ) ) ? g_fShadowDensity : float3( 1.0f, 1.0f, 1.0f );
}

float3 CalcTerrainShadow( float3 fShadowMapCoord, float3 AmbientColor, float3 LightMapColor )
{
	float3 ResultColor;
	float lightAmount = 0;
	lightAmount = tex2D( g_ShadowMapSampler, fShadowMapCoord ).x < fShadowMapCoord.z  ?   0   :   1 ;
	ResultColor = lerp( float3(0, 0, 0) , LightMapColor,  lightAmount ) +	AmbientColor;		
	return ResultColor;
}
#endif
