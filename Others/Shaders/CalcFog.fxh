float4 g_FogFactor			    : FOGFACTOR		// fogEnd, forRange, ?, ?
= { 5000.0f, 1.0f / 2000.0f, 0.0f, 0.0f };
float4 g_FogColor				: FOGCOLOR
= { 1.0f, 0.0f, 0.0f, 1.0f };

texture2D g_FogSkyBoxTex : FOGSKYBOXTEX;
sampler2D g_FogSkyBoxSampler = sampler_state
{
	texture = < g_FogSkyBoxTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

float2 CalcFogValue( float PositionZ )
{
	float fDist = g_FogFactor.z - PositionZ;
	float2 vReturn = saturate( fDist * g_FogFactor.xy );
	vReturn.y *= vReturn.y;
	return vReturn;
}

float3 CalcFogColor( float3 Color, float4 FogValue )
{
#ifdef _3DSMAX_
	return Color;
#else
	float3 FogColor = tex2D( g_FogSkyBoxSampler, FogValue.xy ).xyz;
	FogColor = lerp( g_FogColor.xyz, FogColor, FogValue.w );
	return lerp( FogColor, Color, FogValue.z );
#endif
}
