float4x3 g_WorldViewMatArray[ 50 ]	: WORLDMATRIXARRAY;

float3 CalcBlendPosition( float3 Position, int4 BoneIndex, float4 BoneWeight )
{
    float3 WorldViewPos = mul( float4( Position.xyz , 1.0 ), g_WorldViewMatArray[ BoneIndex.x ] ) * BoneWeight.x;
	WorldViewPos += mul( float4( Position.xyz , 1.0 ), g_WorldViewMatArray[ BoneIndex.y ] ) * BoneWeight.y;
	WorldViewPos += mul( float4( Position.xyz , 1.0 ), g_WorldViewMatArray[ BoneIndex.z ] ) * BoneWeight.z;
	WorldViewPos += mul( float4( Position.xyz , 1.0 ), g_WorldViewMatArray[ BoneIndex.w ] ) * BoneWeight.w;
	return WorldViewPos;
}

float3 CalcBlendNormal( float3 Normal, int4 BoneIndex, float4 BoneWeight )
{
	float3 WorldViewNormal = normalize( mul( Normal, g_WorldViewMatArray[ BoneIndex.x ] ) ) * BoneWeight.x;
	WorldViewNormal += mul( Normal, g_WorldViewMatArray[ BoneIndex.y ] ) * BoneWeight.y;
	WorldViewNormal += mul( Normal, g_WorldViewMatArray[ BoneIndex.z ] ) * BoneWeight.z;
	WorldViewNormal += mul( Normal, g_WorldViewMatArray[ BoneIndex.w ] ) * BoneWeight.w;
	return normalize(WorldViewNormal);
}
