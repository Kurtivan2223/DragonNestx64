float4 g_MaterialAmbient : MATERIALAMBIENT
<
    string UIName = "Ambient Material";
> = { 0.682f, 0.682f, 0.682f, 1.0f};

float4 g_MaterialDiffuse : MATERIALDIFFUSE
<

    string UIName = "Diffuse Material";
> = { 0.682f, 0.682f, 0.682f, 1.0f};

#ifdef _USE_DIFFUSE_
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
float g_AlphaRef				: ALPHAREF;
#endif
#ifdef _USE_DIFFUSE_VOLUME_
texture3D g_DiffuseVolumeTex : DIFFUSEVOLUMETEXTURE
< 
	string UIName = "Diffuse Volume Texture";
>;
sampler3D g_DiffuseVolumeSampler = sampler_state
{
	texture = < g_DiffuseVolumeTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
float g_AlphaRef				: ALPHAREF;
#endif


#ifdef _USE_SPECULAR_
float g_SpecPower : SPECULARPOWER
<
    string UIName = "Specular Power";
    float UIMin = 1.0;
    float UIMax = 128.0;
    float UIStep = 1.0;
> = 15.0;
float4 g_MaterialSpecular : MATERIALSPECULAR
<
    string UIName = "Specular Material";
> = { 1.0f, 1.0f, 1.0f, 1.0f};
texture2D g_SpecularTex : SPECULARTEXTURE 
< 
	string UIName = "Specular Texture";
>;
sampler2D g_SpecularSampler = sampler_state
{
	texture = < g_SpecularTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
#endif

#ifdef _USE_EMISSIVE_
float g_EmissivePower : EMISSIVEPOWER
<
    string UIName = "Emissive Power";
> = 1.0f;
float g_EmissivePowerRange : EMISSIVEPOWERRANGE
<
    string UIName = "Emissive Power Range";
> = 0.0f;
float g_EmissiveAniSpeed : EMISSIVEANISPEED
<
    string UIName = "Emissive Ani Speed";
> = 1.0f;
texture2D g_EmissiveTex : EMISSIVETEXTURE 
< 
	string UIName = "Emissive Texture";
>;
sampler2D g_EmissiveSampler = sampler_state
{
	texture = < g_EmissiveTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
#endif


#ifdef _USE_NORMALMAP_
float g_BumpPower : BUMPPOWER
<
    string UIName = "Bump Power";
    float UIMin = 1.0;
    float UIMax = 5.0;
    float UIStep = 0.1;
> = 1.0;
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
#endif


#ifdef _USE_REFLECTMAP_
float g_ReflectPower : REFLECTPOWER
<
    string UIName = "Reflect Power";
    float UIMin = 1.0;
    float UIMax = 10.0;
    float UIStep = 0.5;
> = 1.0;
textureCUBE g_ReflectTex : REFLECTTEXTURE
< 
	string UIName = "Reflect Texture";
>;
samplerCUBE g_ReflectSampler = sampler_state
{
	texture = < g_ReflectTex >;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
#endif