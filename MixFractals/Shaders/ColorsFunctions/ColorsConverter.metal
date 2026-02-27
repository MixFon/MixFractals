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

// гладкая итерация для непрерывной раскраски
float smoothIter(float iter, float2 z) {
	float r2 = dot(z, z);
	float log_zn = 0.5 * log(r2);
	float nu = log(log_zn / log(2.0)) / log(2.0);
	return iter + 1.0 - nu;
}

// гладкая раскраска по continuous iteration count
float3 smoothColor(int iter, float2 z, int maxIter) {
	if (iter >= maxIter) {
		return float3(0.0);
	}
	
	float si = smoothIter(float(iter), z);
	float t = si / float(maxIter);       // 0..1
	float hue = fmod(t * 5.0, 1.0);      // несколько оборотов по кругу
	float s = 1.0;
	float v = 1.0;
	
	return hsv2rgb(hue, s, v);
}


