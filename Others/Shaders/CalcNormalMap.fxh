#define CalcNormalSpecular			\
	Output.Position = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldViewProjMat );		\
																							\
	Output.WorldViewTangent = mul( Input.Tangent, g_WorldViewMat );							\
	Output.WorldViewBinormal = mul( Input.Binormal, g_WorldViewMat );						\
	Output.WorldViewNormal = mul( Input.Normal, g_WorldViewMat );							\
																							\
	Output.WorldViewPos = mul( float4( Input.Position.xyz, 1.0f ) , g_WorldViewMat );		\
	Output.WorldViewEyeVec = -normalize( Output.WorldViewPos );								\
																							\
																							\
	Output.TexCoord0 = Input.TexCoord0;														\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\



#define CalcNormalSpecularAni			\
    float3 WorldViewPos = CalcBlendPosition( Input.Position, Input.nBoneIndex, Input.fWeight );		\
																									\
	Output.Position = mul( float4( WorldViewPos, 1.f ) , g_ProjMat );								\
	Output.WorldViewPos = WorldViewPos;																\
	Output.WorldViewEyeVec = -normalize( WorldViewPos );											\
																									\
	Output.WorldViewNormal = CalcBlendNormal( Input.Normal, Input.nBoneIndex, Input.fWeight );		\
	Output.WorldViewTangent = mul( Input.Tangent, g_WorldViewMatArray[ Input.nBoneIndex.x ] );		\
	Output.WorldViewBinormal = mul( Input.Binormal, g_WorldViewMatArray[ Input.nBoneIndex.x ] );	\
																									\
																									\
	Output.TexCoord0 = Input.TexCoord0;																\
	float2 ScreenCoord = Output.Position.xy / Output.Position.w;						\
	Output.Fog.xy = ( ScreenCoord + 1.0f ) * 0.5f;										\
	Output.Fog.y = 1.0f - Output.Fog.y;													\
