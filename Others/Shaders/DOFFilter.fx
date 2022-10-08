//////////////////////////////////////////////////////////////////////////////////////////////
// Global Variable
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
// Custom Param
//////////////////////////////////////////////////////////////////////////////////////////////

float4 g_DOFValue				:	DOFVALUE;
float2 g_DOFBlurSize			:   DOFBLURSIZE;
float g_fFocusDistance			:	FOCUSDISTANCE;
float	g_fBlurRect					: BLURRECT;

texture2D g_DOFHoriBuffer : DOFHORIBUFFER;
sampler2D g_DOFHoriBufferSampler = sampler_state
{
	Texture = < g_DOFHoriBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = None;
};

texture2D g_DOFVertBuffer : DOFVERTBUFFER;
sampler2D g_DOFVertBufferSampler = sampler_state
{
	Texture = < g_DOFVertBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Linear;
	MipFilter = None;
};

texture2D g_BlurSizeBuffer : BLURSIZEBUFFER;
sampler2D g_BlurSizeBufferSampler = sampler_state
{
	Texture = < g_BlurSizeBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
};

texture2D g_BlurSizeBlurBuffer : BLURSIZEBUFFER;
sampler2D g_BlurSizeBlurBufferSampler = sampler_state
{
	Texture = < g_BlurSizeBlurBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
};

texture2D g_BackBuffer : BACKBUFFER;
sampler2D g_BackBufferSampler = sampler_state
{
	Texture = < g_BackBuffer >;
    AddressU = Clamp;
    AddressV = Clamp;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
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

#define BLUR_COUNT		 13
float2 g_BlurOffsetHori[ BLUR_COUNT ] =
{
    { -0.5f / 512.0f,		0.0f },
    { -0.416666f  / 512.0f,	0.0f },
    { -0.333333f / 512.0f,	0.0f },
    { -0.25f / 512.0f,		0.0f },
    { -0.166666f / 512.0f,	0.0f },
    { -0.0833333f / 512.0f,	0.0f },
    {  0.0f / 512.0f,		0.0f },
    { 0.0833333f / 512.0f,	0.0f },
    { 0.166666f / 512.0f,	0.0f },
    { 0.25f / 512.0f,		0.0f },
    { 0.333333f / 512.0f,	0.0f },
    { 0.416666f / 512.0f,	0.0f },
    { 0.5f / 512.0f,		0.0f },
};

float2 g_BlurOffsetVert[ BLUR_COUNT ] =
{
    { 0,	-0.5f / 384.0f		 },
    { 0,	-0.416666f / 384.0f	 },
    { 0,	-0.333333f / 384.0f	 },
    { 0,	-0.25f / 384.0f		 },
    { 0,	-0.166666f / 384.0f	 },
    { 0,	-0.0833333f / 384.0f	 },
    { 0,	0.0f / 384.0f		 },
    { 0,	0.0833333f / 384.0f	 },
    { 0,	0.166666f / 384.0f	 },
    { 0,	0.25f / 384.0f		 },
    { 0,	0.333333f / 384.0f	 },
    { 0,	0.416666f / 384.0f	 },
    { 0,	0.5f / 384.0f		 },
};

float g_fBlurWeights[ BLUR_COUNT ] = 
{
    0.002216,
    0.008764,
    0.026995,
    0.064759,
    0.120985,
    0.176033,
    0.199471,
    0.176033,
    0.120985,
    0.064759,
    0.026995,
    0.008764,
    0.002216,
};

#define g_fMaxBlurSize (20.f)

// Scale Distribution
#define SCALE_DISTRIBUTE (100.0f)
#define INV_SCALE_DISTRIBUTE (0.01f)

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
    float2 TexCoord0			: TEXCOORD0;
};

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Vertex Shader
//////////////////////////////////////////////////////////////////////////////////////////////
VertexOutput DOFFilterVS( VertexInput Input ) 
{
	VertexOutput Output;
	
	Output.Position = float4( Input.Position, 1.0f );
	Output.TexCoord0 = Input.TexCoord0;

	return Output;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Pixel Shader
//////////////////////////////////////////////////////////////////////////////////////////////

float4 CalcBlurSizePS( VertexOutput Input ) : COLOR0
{
	float fDepth = tex2D( g_DepthTexSampler, Input.TexCoord0  ).r * SCALE_DISTRIBUTE;
	float fRelativeDistance = fDepth - g_fFocusDistance;

	float fFocusWeightFar = (fRelativeDistance - g_DOFValue.x) * g_DOFValue.y;
	float fFocusWeightNear = (-fRelativeDistance - g_DOFValue.z) * g_DOFValue.w;
	fFocusWeightFar = saturate( fFocusWeightFar) * g_DOFBlurSize.x;
	fFocusWeightNear = saturate( fFocusWeightNear) * g_DOFBlurSize.y;

	float fTotalWeight = fFocusWeightFar + fFocusWeightNear;

	return float4(fTotalWeight, 0, 0, 1);
}

float4 BlurRectPS( VertexOutput Input ) : COLOR0
{
	return float4(g_fBlurRect, 0, 0, 1);
}

float4 DOFHoriLowResFilterPS( VertexOutput Input ) : COLOR0
{
	int i;
	float4 Result;
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BackBufferSampler, Input.TexCoord0 + g_BlurOffsetHori[ i ] * g_fMaxBlurSize ).xyz * g_fBlurWeights[ i ];
	}

	Result.w = 1.0f;
	
	return Result;
}

float4 DOFVertLowResFilterPS( VertexOutput Input ) : COLOR0
{
	int i;
	float4 Result;
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_DOFHoriBufferSampler, Input.TexCoord0 + g_BlurOffsetVert[ i ] * g_fMaxBlurSize ).xyz * g_fBlurWeights[ i ];
	}
	
	Result.w = 1.0f;
	
	return Result;
}

float4 DOFCompletePS( VertexOutput Input ) : COLOR0
{
	float4 Result;
	Result = 0.0f;
	
	float fBlurSize = tex2D( g_BlurSizeBufferSampler, Input.TexCoord0 ).x;
	float fRatio = clamp(sqrt( fBlurSize / g_fMaxBlurSize ), 0, 1);
	float3 BlurColor = tex2D( g_DOFVertBufferSampler, Input.TexCoord0 ).xyz;
	float3 OriginColor =  tex2D( g_BackBufferSampler, Input.TexCoord0 ).xyz;

	Result.xyz = lerp(OriginColor, BlurColor, fRatio );

	Result.w = 1.0f;
	
	return Result;
}

float4 DOFHoriFilterPS( VertexOutput Input ) : COLOR0
{
	int i;
	float4 Result;
	float fBlurSize = tex2D( g_BlurSizeBlurBufferSampler, Input.TexCoord0 - float2( 0.8f / 160.0f, 0.8f / 100.0f )  ).x;	// 0.5 픽셀 왼쪽위 걸  가져와야 위치가 맞는다.

	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_BackBufferSampler, Input.TexCoord0 + g_BlurOffsetHori[ i ] * fBlurSize ).xyz * g_fBlurWeights[ i ];
	}
	Result.w = 1.0f;
	
	return Result;
}

float4 DOFVertFilterPS( VertexOutput Input ) : COLOR0
{
	int i;
	float4 Result;
	float fBlurSize = tex2D( g_BlurSizeBlurBufferSampler, Input.TexCoord0 - float2( 0.8f / 160.0f, 0.8f / 100.0f ) ).x;		// 0.5 픽셀 왼쪽 위걸  가져와야 위치가 맞는다.
	
	Result = 0.0f;
	for( i = 0; i < BLUR_COUNT; i++ )
	{
		Result.xyz += tex2D( g_DOFHoriBufferSampler, Input.TexCoord0 + g_BlurOffsetVert[ i ] * fBlurSize ).xyz * g_fBlurWeights[ i ];
	}
	
	Result.w = 1.0f;
	
	return Result;
}

float4 BlurSizeDownFilterPS( VertexOutput Input ) : COLOR0
{
	float2 fPixel = float2( 1.6f / 160.0f, 1.6f / 100.0f ); 
	float fDepth = tex2D( g_BlurSizeBufferSampler, Input.TexCoord0 ).r;
	fDepth += tex2D( g_BlurSizeBufferSampler, Input.TexCoord0 + float2(fPixel.x, 0) ).r;
	fDepth += tex2D( g_BlurSizeBufferSampler, Input.TexCoord0 + float2(0, fPixel.y) ).r;
	fDepth += tex2D( g_BlurSizeBufferSampler, Input.TexCoord0 + fPixel.xy ).r;
	fDepth *= 0.25f;
	return float4(fDepth, 0, 0, 1);	
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Start Technique
//////////////////////////////////////////////////////////////////////////////////////////////
technique CalcBlurSizeTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 CalcBlurSizePS();
    }
}

technique DOFHoriLowResFilterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 DOFHoriLowResFilterPS();
    }
}

technique DOFVertLowResFilterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 DOFVertLowResFilterPS();
    }
}

technique DOFCompleteTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 DOFCompletePS();
    }
}

technique DOFHoriFilterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 DOFHoriFilterPS();
    }
}

technique DOFVertFilterTech
{
    pass p0 
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 DOFVertFilterPS();
    }
}


technique BlurSizeDownFilterTech
{
    pass p0
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 BlurSizeDownFilterPS();
    }
}

technique BlurRectTech
{
    pass p0
    {		
		VertexShader = compile vs_2_0 DOFFilterVS();
		PixelShader  = compile ps_2_0 BlurRectPS();
    }
}
