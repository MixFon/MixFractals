//
//  Julia_3.metal
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

#include <metal_stdlib>
#include "../Structs.h"
#include "../ColorsFunctions/ColorsConverter.h"

using namespace metal;

fragment float4 fragment_mandelbrot_3_fractal(VertexOut in [[stage_in]], constant FractalUniforms& uniforms [[buffer(0)]]) {
	// Переводим экранные координаты (uv) в комплексную плоскость
	// Вычитаем 0.5 чтобы центр прямоугольника (экрана был в 0,0)
	float2 c = float2(
		(in.uv.x - 0.5) * uniforms.scale * uniforms.aspect + uniforms.center.x,
		(in.uv.y - 0.5) * uniforms.scale + uniforms.center.y
	);

	float2 z = c;
	int iter = 0;

	while (dot(z, z) < 2.0 && iter < uniforms.maxIter) {
		z = float2(z.x*z.x*z.x - 3.0*z.x*z.y*z.y, 3.0*z.x*z.x*z.y - z.y*z.y*z.y) + uniforms.point;
		iter++;
	}

	float hue = float(iter) / uniforms.maxIter; // 0..1
	float s = 1.0;
	float v = (iter < uniforms.maxIter) ? 1.0 : 0.0;

	float3 color = hsv2rgb(hue, s, v);
	return float4(color, 1.0);
}


