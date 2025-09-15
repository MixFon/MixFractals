//
//  FractalShaders.metal
//  MixFractals
//
//  Created by Михаил Фокин on 13.09.2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
	float2 position;
	float2 uv;
};

struct VertexOut {
	float4 position [[position]];
	float2 uv;
};

struct FractalUniforms {
	float2 center; // куда смотрим (панорамирование)
	float scale;   // масштаб (zoom)
	float aspect;  // отношение сторок экрана
	int maxIter;   // количество итераций для точности
};

// Вершинный шейдер: рисуем fullscreen quad (две треугольные полоски)
vertex VertexOut vertex_fractal(uint vertexID [[vertex_id]], const device VertexIn* vertices [[buffer(0)]]) {
	VertexOut out;
	out.position = float4(vertices[vertexID].position, 0.0, 1.0);
	out.uv = vertices[vertexID].uv;
	return out;
}

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

fragment float4 fragment_fractal(VertexOut in [[stage_in]], constant FractalUniforms& uniforms [[buffer(0)]]) {
	// Переводим экранные координаты (uv) в комплексную плоскость
	// Вычитаем 0.5 чтобы центр прямоугольника (экрана был в 0,0)
	float2 c = float2(
		(in.uv.x - 0.5) * uniforms.scale * uniforms.aspect,// + uniforms.center.x,
		(in.uv.y - 0.5) * uniforms.scale// + uniforms.center.y
	);

	float2 z = c;
	int iter = 0;

	while (dot(z, z) < 2.0 && iter < uniforms.maxIter) {
		z = float2(z.x*z.x - z.y*z.y + uniforms.center.x, 2.0*z.x*z.y + uniforms.center.y);// + c;
		iter++;
	}

	float hue = float(iter) / uniforms.maxIter; // 0..1
	float s = 1.0;
	float v = (iter < uniforms.maxIter) ? 1.0 : 0.0;

	float3 color = hsv2rgb(hue, s, v);
	return float4(color, 1.0);
}
