//////////////////////////////////////////////////////////////////////////////////////////////
// World Mat Param
//////////////////////////////////////////////////////////////////////////////////////////////
float4x4 g_WorldViewMat					: WORLDVIEW;

//////////////////////////////////////////////////////////////////////////////////////////////
// Shared Param
//////////////////////////////////////////////////////////////////////////////////////////////
shared float4x4 g_ProjMat				: PROJECTION;
shared float4x4 g_ViewMat				: VIEW;

float4x4 g_BillBoardMat				: BILLBOARDMAT;

float g_fParticleTime		: PARTICLETIME;
float g_fParticleScale		: PARTICLESCALE;
float4 g_Origin				: ORIGIN;
float4 g_fParticleColor		: PARTICLECOLOR;


float g_fLifeTime			: LIFETIME;
float g_fResistTime			: RESISTTIME;
float g_fResistScale		: RESISTSCALE;
float g_fGravityAccel		: GRAVITYACCEL;
float4 g_GravityVecView		: GRAVITYVECTORVIEW;
float g_fRotateStart		: ROTATESTART;
float g_fRotateRange		: ROTATERANGE;
float g_fScaleTable[ 21 ]	: SCALETABLE;
float4 g_fColorTable[ 21 ]	: COLORTABLE;
float g_fMultiOriginalTime;
float4 g_IteratePos[ 40 ];
int g_nUseRotateByDir;

float4 g_fVertexOffset[ 4 ] = 
{ 
	float4( -0.5f, 0.5f, 0.0f, 0.0f ), 
	float4( 0.5f, 0.5f, 0.0f, 0.0f ), 
	float4( -0.5f, -0.5f, 0.0f, 0.0f ), 
	float4( 0.5f, -0.5f, 0.0f, 0.0f ) 
};

float4 g_fUVTable[ 4 ] = 
{ 
	float4( 0.0f, 0.0f, 0.0f, 0.0f ), 
	float4( 1.0f, 0.0f, 0.0f, 0.0f ), 
	float4( 0.0f, 1.0f, 0.0f, 0.0f ), 
	float4( 1.0f, 1.0f, 0.0f, 0.0f ) 
};


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

texture2D g_BackBuffer : BACKBUFFER;
sampler2D ScreenSampler = sampler_state 
{
    texture = < g_BackBuffer >;
};

texture2D g_DepthTex : DEPTHTEX;
sampler2D g_DepthTexSampler = sampler_state
{
	Texture = < g_DepthTex >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
};

//------------------------------------
struct VertexInput
{
    float4 Direction			: BLENDWEIGHT;
    float2 fBirthTime			: TEXCOORD0;
    int4   nVertexIndex			: BLENDINDICES0;
    float3 StartOffset			: NORMAL;
    float  fSizeAdjustRate		: DEPTH;
};

struct VertexOutput 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float4 DiffuseColor			: TEXCOORD1;
    float4 ProjPos			: TEXCOORD2;
};

struct VertexOutputAlpha 
{
    float4 Position				: POSITION;
    float2 TexCoord0			: TEXCOORD0;
    float2 TexCoord1			: TEXCOORD1;
    float4 DiffuseColor			: TEXCOORD2;
};

struct PixelOutput
{
	float4 Color				: COLOR0;
#ifdef BAKE_DEPTHMAP
	float4 Depth				: COLOR1;
#endif
};

#define INV_SCALE_DISTRIBUTE (0.01)
#define SCALE_DISTRIBUTE (100.0)
#define TABLE_COUNT (20)

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
#define CalcParticle( Output, Origin )																	\
    float4 Direction = mul( float4( Input.Direction.xyz, 0.0 ), g_WorldViewMat ) * Input.Direction.w;	\
    float fOriginalTime = (g_fParticleTime - Input.fBirthTime.x) * g_fMultiOriginalTime;				\
																										\
    float fCurrentTime;																					\
    if( fOriginalTime > g_fResistTime )																	\
    {																									\
		fCurrentTime = ( fOriginalTime - ( fOriginalTime - g_fResistTime ) * g_fResistScale ) * g_fLifeTime;	\
    }																									\
    else																								\
    {																									\
		fCurrentTime = fOriginalTime * g_fLifeTime;														\
    }																									\
	float fHalfTime = fCurrentTime * 0.5f;																\
	Direction = Direction * fCurrentTime + Origin;														\
	float fGravityValue = pow( g_fGravityAccel, fHalfTime + 1.0f );										\
	float4 FinalDir = fGravityValue * g_GravityVecView * fCurrentTime + Direction;						\
																										\
	float fRotateResult = g_fRotateRange * fOriginalTime + g_fRotateStart;								\
	fRotateResult *= Input.fBirthTime.y;																\
	float fTableTime = fOriginalTime * TABLE_COUNT;														\
	float fStartTable = floor( fTableTime );															\
	float fEndTable = fStartTable + 1.0f;																\
	float fTableValue = frac( fTableTime );																\
	float fScaleValue = lerp( g_fScaleTable[ fStartTable ], g_fScaleTable[ fEndTable ], fTableValue );	\
	fScaleValue *= g_fParticleScale;																	\
	fScaleValue = fScaleValue + fScaleValue * Input.fSizeAdjustRate;									\
																										\
	int nVertexIndex;																					\
	if( ( fOriginalTime < 0.0f ) || ( fOriginalTime >= 1.0f ) )											\
	{																									\
		nVertexIndex = 0;																				\
	}																									\
	else																								\
	{																									\
		nVertexIndex = Input.nVertexIndex.x;															\
	}																									\
	float4 Position = g_fVertexOffset[ nVertexIndex ] * fScaleValue;									\
	float3 NewPos;																								\
																												\
	if( g_nUseRotateByDir > 0 )																					\
	{																											\
		float4 TempDirection = mul( float4( Input.Direction.xyz, 0.0 ), g_WorldViewMat ) * Input.Direction.w;	\
		float fTempBirthTime = Input.fBirthTime.x + 0.1f;														\
		float fTempOriginalTime = (g_fParticleTime - fTempBirthTime)*g_fMultiOriginalTime;						\
		float fTempTime;																						\
		if( fTempOriginalTime > g_fResistTime )																	\
		{																										\
			fTempTime = fTempOriginalTime - ( fTempOriginalTime - g_fResistTime ) * g_fResistScale;				\
		}																										\
		else																									\
		{																										\
			fTempTime = fTempOriginalTime;																		\
		}																										\
		fTempTime = fTempTime * g_fLifeTime;																	\
		float fTempHalfTime = fTempTime * 0.5f;																	\
		TempDirection = TempDirection * fTempTime + Origin;														\
		float fTempGravityWeight = pow( g_fGravityAccel, fTempHalfTime + 1 );									\
		TempDirection = fTempGravityWeight * g_GravityVecView * fTempTime + TempDirection;						\
		TempDirection = mul( float4( TempDirection.xyz, 1.0f ), g_ProjMat );									\
		float4 TempOrigDir = mul( float4( FinalDir.xyz, 1.0f ), g_ProjMat );									\
		TempOrigDir = TempDirection - TempOrigDir;																\
		fRotateResult = fRotateResult + atan2( TempOrigDir.x, -TempOrigDir.y );										\
	}																											\
	float fSinValue = sin( fRotateResult );																\
	float fCosValue = cos( fRotateResult );																\
																										\
	NewPos.x = Position.x * fCosValue - Position.y * fSinValue;											\
	NewPos.y = Position.x * fSinValue + Position.y * fCosValue;											\
	NewPos.z = 0;																						\
																										\
	float4 Offset = mul( float4( Input.StartOffset.xyz, 0.0 ), g_WorldViewMat );						\
	NewPos.x += Offset.x;							\
	NewPos.y += Offset.y;							\
	NewPos.z += Offset.z;							\
													\
	NewPos = mul( NewPos, g_BillBoardMat); 																\
																										\
	Output.TexCoord0 = g_fUVTable[ nVertexIndex ];														\
																										\
	FinalDir.x += NewPos.x;						\
	FinalDir.y += NewPos.y;						\
	FinalDir.z += NewPos.z;						\
																										\
	Output.Position = mul( float4( FinalDir.xyz, 1.0f ), g_ProjMat );														\
	Output.DiffuseColor = lerp( g_fColorTable[ fStartTable ], g_fColorTable[ fEndTable ], fTableValue ) * g_fParticleColor;	\

VertexOutput NormalVS( VertexInput Input ) 
{
    VertexOutput Out;
    
    CalcParticle( Out, g_Origin );
	
	Out.ProjPos = Out.Position;

    return Out;
}

VertexOutput IterateVS( VertexInput Input ) 
{
    VertexOutput Out;
    
    CalcParticle( Out, mul( g_IteratePos[ Input.nVertexIndex.y ], g_ViewMat ) );
	
	Out.ProjPos = Out.Position;

    return Out;
}

VertexOutputAlpha NormalBumpVS( VertexInput Input ) 
{
    VertexOutputAlpha Out;
    
    CalcParticle( Out, g_Origin );
    Out.TexCoord1 = float2( ( Out.Position.x / Out.Position.w ) * 0.5f + 0.5f, ( Out.Position.y / Out.Position.w )*( -0.5f ) + 0.5f );
    return Out;
}

VertexOutputAlpha IterateBumpVS( VertexInput Input ) 
{
    VertexOutputAlpha Out;
    
    CalcParticle( Out, mul( g_IteratePos[ Input.nVertexIndex.y ], g_ViewMat ) );
    Out.TexCoord1 = float2( ( Out.Position.x / Out.Position.w ) * 0.5f + 0.5f, ( Out.Position.y / Out.Position.w )*( -0.5f ) + 0.5f );

    return Out;
}

//-----------------------------------
PixelOutput NormalPS( VertexOutput Input) : COLOR
{
	PixelOutput Output;

	Output.Color = tex2D( g_DiffuseSampler, Input.TexCoord0 ) * Input.DiffuseColor;

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, Output.Color.a );
#endif

	return Output;
}

PixelOutput NormalDepthPS( VertexOutput Input) : COLOR
{
	PixelOutput Output;
	
	float2 ScreenPos = 0.5f * Input.ProjPos.xy / Input.ProjPos.w + float2( 0.5f, 0.5f );
	ScreenPos.y = 1.0f - ScreenPos.y;
	
	float fDepth = tex2D( g_DepthTexSampler, ScreenPos ).x  - ( Input.ProjPos.z ) * INV_SCALE_DISTRIBUTE;
	clip( fDepth );	
 
	Output.Color = tex2D( g_DiffuseSampler, Input.TexCoord0 ) * Input.DiffuseColor;
	Output.Color = Output.Color.bgra;

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, Output.Color.a );
#endif

	return Output;
}

PixelOutput BumpPS( VertexOutputAlpha Input ) : COLOR
{
	PixelOutput Output;

	float4 DiffuseTex = tex2D( g_DiffuseSampler, Input.TexCoord0 );
	DiffuseTex = DiffuseTex - float4( 0.5, 0.5, 0.0f, 0.0f );
	DiffuseTex.xy *= 0.01f;
	float4 OutTexture = tex2D( ScreenSampler, Input.TexCoord1 + DiffuseTex.xy );
	Output.Color = Input.DiffuseColor * OutTexture;
	Output.Color.a *= DiffuseTex.w;

#ifdef BAKE_DEPTHMAP
	Output.Depth = float4( Input.DepthValue.x, 0.0f, 0.0f, Output.Color.a );
#endif

	return Output;
}


//-----------------------------------
technique NormalTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 NormalVS();
		PixelShader = compile ps_2_0 NormalPS();
    }
}

technique IterateTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 IterateVS();
		PixelShader = compile ps_2_0 NormalPS();
    }
}

technique NormalBumpTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 NormalBumpVS();
		PixelShader = compile ps_2_0 BumpPS();
    }
}

technique IterateBumpTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 IterateBumpVS();
		PixelShader = compile ps_2_0 BumpPS();
    }
}

// Depth 
technique NormalDepthTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 NormalVS();
		PixelShader = compile ps_2_0 NormalDepthPS();
    }
}

technique IterateDepthTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 IterateVS();
		PixelShader = compile ps_2_0 NormalDepthPS();
    }
}