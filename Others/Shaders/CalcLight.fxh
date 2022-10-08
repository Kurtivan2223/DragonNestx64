#ifndef DIR_LIGHT_COUNT
#define DIR_LIGHT_COUNT 1
#endif
#ifndef POINT_LIGHT_COUNT
#define POINT_LIGHT_COUNT 1
#endif
#ifndef SPOT_LIGHT_COUNT
#define SPOT_LIGHT_COUNT 1
#endif

float4 g_LightAmbient				: LIGHTAMBIENT;

#ifndef DISABLE_DIR_LIGHT
	int g_DirLightCount									: DIRLIGHTCOUNT;
	float3 g_DirLightDirection[ DIR_LIGHT_COUNT ]		: DIRLIGHTDIRECTION;
	float4 g_DirLightDiffuse[ DIR_LIGHT_COUNT ]			: DIRLIGHTDIFFUSE;
	float4 g_DirLightSpecular[ DIR_LIGHT_COUNT ]		: DIRLIGHTSPECULAR;
#endif

#ifndef DISABLE_POINT_LIGHT
	int g_PointLightCount								: POINTLIGHTCOUNT;
	float4 g_PointLightPosition[ POINT_LIGHT_COUNT ]	: POINTLIGHTPOSITION;
	float4 g_PointLightDiffuse[ POINT_LIGHT_COUNT ]		: POINTLIGHTDIFFUSE;
	float4 g_PointLightSpecular[ POINT_LIGHT_COUNT ]	: POINTLIGHTSPECULAR;
#endif

#ifndef DISABLE_SPOT_LIGHT
	int g_SpotLightCount								: SPOTLIGHTCOUNT;
	float4 g_SpotLightDirection[ SPOT_LIGHT_COUNT ]		: SPOTLIGHTDIRECTION;
	float4 g_SpotLightPosition[ SPOT_LIGHT_COUNT ]		: SPOTLIGHTPOSITION;
	float4 g_SpotLightDiffuse[ SPOT_LIGHT_COUNT ]		: SPOTLIGHTDIFFUSE;
	float4 g_SpotLightSpecular[ SPOT_LIGHT_COUNT ]		: SPOTLIGHTSPECULAR;
#endif

#ifndef DISABLE_DIR_LIGHT
	#define CalcDirLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec )										\
			DiffuseResult.xyz += g_DirLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, -g_DirLightDirection[ Index ] ) );		\
																																\
			float3 HalfWayVec = normalize( WorldViewEyeVec - g_DirLightDirection[ Index ] );									\
			SpecularResult.xyz += g_DirLightSpecular[ Index ].xyz * pow( max( 0 , dot( Normal, HalfWayVec ) ), g_SpecPower );
#else
	#define CalcDirLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec )
#endif

#ifndef DISABLE_POINT_LIGHT
	#define CalcPointLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec, WorldViewPos )							\
			float3 LightVec = g_PointLightPosition[ Index ].xyz - WorldViewPos.xyz;													\
			float fLength = length( LightVec );																						\
			float fAttenuation = max( 0.0f, 1.0f - ( fLength * g_PointLightPosition[ Index ].w ) );									\
			LightVec = LightVec / fLength;																							\
			DiffuseResult.xyz += g_PointLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, LightVec ) ) * fAttenuation;				\
																																	\
			float3 HalfWayVec = normalize( WorldViewEyeVec + LightVec );															\
			SpecularResult.xyz += g_PointLightSpecular[ Index ].xyz * pow( max( 0 , dot( Normal, HalfWayVec ) ), g_SpecPower ) * fAttenuation;	
#else
	#define CalcPointLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec, WorldViewPos )
#endif

#ifndef DISABLE_SPOT_LIGHT
	#define CalcSpotLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec, WorldViewPos )									\
			float3 SpotLightVec = g_SpotLightPosition[ Index ].xyz - WorldViewPos.xyz;															\
			float fSpotLength = length( SpotLightVec );																								\
			SpotLightVec = SpotLightVec / fSpotLength;																									\
			float fSpotDot = dot( -g_SpotLightDirection[ Index ].xyz, SpotLightVec.xyz );														\
			float fSpotAttenuation;																												\
			if( fSpotLength <= g_SpotLightPosition[ Index ].w )																					\
			{																																\
				fSpotAttenuation = min( 1.0f, max( 0.0f, ( fSpotDot - g_SpotLightSpecular[ Index ].w ) / g_SpotLightDiffuse[ Index ].w ) );		\
				fSpotAttenuation = pow( fSpotAttenuation, g_SpotLightDirection[ Index ].w );														\
			}																																\
			else																															\
			{																																\
				fSpotAttenuation = 0.0f;																										\
			}																																\
			DiffuseResult.xyz += g_SpotLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, SpotLightVec ) ) * fSpotAttenuation;						\
																																			\
			float3 HalfWayVec = normalize( WorldViewEyeVec + SpotLightVec );																	\
			SpecularResult.xyz += g_SpotLightSpecular[ Index ].xyz * pow( max( 0 , dot( Normal, HalfWayVec ) ), g_SpecPower ) * fSpotAttenuation;
#else
	#define CalcSpotLight( DiffuseResult, SpecularResult, Index, Normal, WorldViewEyeVec, WorldViewPos )
#endif
		

#ifdef _USE_SPECULAR_
struct TwoLight
{
	float4 Diffuse;
	float4 Specular;
};
TwoLight CalcLightAll( TwoLight Light, float3 WorldViewNormal, float3 EyeVec, float3 WorldViewPos )
{
	int i;
#ifndef DISABLE_DIR_LIGHT
	for( i = 0; i < g_DirLightCount; i++ )
	{
		CalcDirLight( Light.Diffuse, Light.Specular, i, WorldViewNormal, EyeVec );
	}
#endif
#ifndef DISABLE_POINT_LIGHT
	for( i = 0; i < g_PointLightCount; i++ )
	{
		CalcPointLight( Light.Diffuse, Light.Specular, i, WorldViewNormal, EyeVec, WorldViewPos );
	}
#endif
#ifndef DISABLE_SPOT_LIGHT
	for( i = 0; i < g_SpotLightCount; i++ )
	{
		CalcSpotLight( Light.Diffuse, Light.Specular, i, WorldViewNormal, EyeVec, WorldViewPos );
	}
#endif
	return Light;
}
#endif


#ifndef DISABLE_DIR_LIGHT
	#define CalcDirLightDiffuse( DiffuseResult, Index, Normal )																	\
			DiffuseResult.xyz += g_DirLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, -g_DirLightDirection[ Index ] ) );
#else
	#define CalcDirLightDiffuse( DiffuseResult, Index, Normal )
#endif


#ifndef DISABLE_POINT_LIGHT
	#define CalcPointLightDiffuse( DiffuseResult, Index, Normal, WorldViewPos )														\
			float3 LightVec = g_PointLightPosition[ Index ].xyz - WorldViewPos.xyz;													\
			float fLength = length( LightVec );																						\
			float fAttenuation = max( 0.0f, 1.0f - ( fLength * g_PointLightPosition[ Index ].w ) );									\
			LightVec = LightVec / fLength;																							\
			DiffuseResult.xyz += g_PointLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, LightVec ) ) * fAttenuation;
#else
	#define CalcPointLightDiffuse( DiffuseResult, Index, Normal, WorldViewPos )
#endif


#ifndef DISABLE_SPOT_LIGHT
	#define CalcSpotLightDiffuse( DiffuseResult, Index, Normal, WorldViewPos )																\
			float3 SpotLightVec = g_SpotLightPosition[ Index ].xyz - WorldViewPos.xyz;															\
			float fSpotLength = length( SpotLightVec );																								\
			SpotLightVec = SpotLightVec / fSpotLength;																									\
			float fSpotDot = dot( -g_SpotLightDirection[ Index ].xyz, SpotLightVec.xyz );														\
			float fSpotAttenuation;																												\
			if( fSpotLength <= g_SpotLightPosition[ Index ].w )																					\
			{																																\
				fSpotAttenuation = min( 1.0f, max( 0.0f, ( fSpotDot - g_SpotLightSpecular[ Index ].w ) / g_SpotLightDiffuse[ Index ].w ) );		\
				fSpotAttenuation = pow( fSpotAttenuation, g_SpotLightDirection[ Index ].w );														\
			}																																\
			else																															\
			{																																\
				fSpotAttenuation = 0.0f;																										\
			}																																\
			DiffuseResult.xyz += g_SpotLightDiffuse[ Index ].xyz * max( 0 , dot( Normal, SpotLightVec ) ) * fSpotAttenuation;
#else
	#define CalcSpotLightDiffuse( DiffuseResult, Index, Normal, WorldViewPos )
#endif
		
		
float4 CalcDiffuseAll( float4 DiffuseColor, float3 WorldViewNormal, float3 WorldViewPos )
{
	int i;
#if DIR_LIGHT_COUNT == 1
		CalcDirLightDiffuse( DiffuseColor, 0, WorldViewNormal );
#else
#ifndef DISABLE_DIR_LIGHT
	for( i = 0; i < g_DirLightCount; i++ )
	{
		CalcDirLightDiffuse( DiffuseColor, i, WorldViewNormal );
	}
#endif
#endif

#if POINT_LIGHT_COUNT == 1
		CalcPointLightDiffuse( DiffuseColor, 0, WorldViewNormal, WorldViewPos );
#else
#ifndef DISABLE_POINT_LIGHT
	for( i = 0; i < g_PointLightCount; i++ )
	{
		CalcPointLightDiffuse( DiffuseColor, i, WorldViewNormal, WorldViewPos );
	}
#endif
#endif

#if SPOT_LIGHT_COUNT == 1
		CalcSpotLightDiffuse( DiffuseColor, 0, WorldViewNormal, WorldViewPos );
#else
#ifndef DISABLE_SPOT_LIGHT
	for( i = 0; i < g_SpotLightCount; i++ )
	{
		CalcSpotLightDiffuse( DiffuseColor, i, WorldViewNormal, WorldViewPos );
	}
#endif
#endif
	return DiffuseColor;
}
