﻿struct PixelInput
{
	float4 position : SV_Position;
	float3 normal : NORMAL0;
	float2 texCoord : TEXCOORD0;
	float2 texCoordAlpha : TEXCOORD1;
	float4 color : COLOR0;
};

SamplerState alphaSampler : register(s1);
SamplerState colorSampler : register(s0);

Texture2D alphaTexture : register(t0);
Texture2D texture0 : register(t1);
Texture2D texture1 : register(t2);
Texture2D texture2 : register(t3);
Texture2D texture3 : register(t4);

float3 sunDirection = float3(1, 1, -1);

cbuffer GlobalParamsBuffer : register(b0)
{
	float4 ambientLight;
	float4 diffuseLight;
};

float3 getDiffuseLight(float3 normal) {
	float light = dot(normal, normalize(-float3(-1, 1, -1)));
	if (light < 0.0)
		light = 0.0;
	if (light > 0.5)
		light = 0.5 + (light - 0.5) * 0.65;

	float3 diffuse = diffuseLight.rgb * light;
	diffuse += ambientLight.rgb;
	diffuse = saturate(diffuse);
	return diffuse;
}

float4 main(PixelInput input) : SV_Target{
	float4 alpha = alphaTexture.Sample(alphaSampler, input.texCoordAlpha);
	float4 c0 = texture0.Sample(colorSampler, input.texCoord);
	float4 c1 = texture1.Sample(colorSampler, input.texCoord);
	float4 c2 = texture2.Sample(colorSampler, input.texCoord);
	float4 c3 = texture3.Sample(colorSampler, input.texCoord);

	float4 color = c0 * alpha.r;
	color = c1 * alpha.g + (1.0 - alpha.g) * color;
	color = c2 * alpha.b + (1.0 - alpha.b) * color;
	color = c3 * alpha.a + (1.0 - alpha.a) * color;

	color.rgb *= input.color.bgr * 2;
	color.rgb *= getDiffuseLight(input.normal);

	return color;
}