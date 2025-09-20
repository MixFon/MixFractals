//
//  ColorsConverter.metal
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

#include <metal_stdlib>
using namespace metal;

// функция перевода HSV → RGB
float3 hsv2rgb(float h, float s, float v) {
	float c = v * s;
	float x = c * (1 - abs(fmod(h*6.0, 2.0) - 1.0));
	float m = v - c;

	float3 rgb;
	if (h < 1.0/6.0)      { rgb = float3(c,x,0); }
	else if (h < 2.0/6.0) { rgb = float3(x,c,0); }
	else if (h < 3.0/6.0) { rgb = float3(0,c,x); }
	else if (h < 4.0/6.0) { rgb = float3(0,x,c); }
	else if (h < 5.0/6.0) { rgb = float3(x,0,c); }
	else                   { rgb = float3(c,0,x); }

	return rgb + m;
}

