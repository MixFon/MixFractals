//
//  FractalShaders.metal
//  MixFractals
//
//  Created by Михаил Фокин on 13.09.2025.
//

#include <metal_stdlib>
using namespace metal;

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
vertex VertexOut vertex_fractal(uint vertexID [[vertex_id]]) {
	float2 positions[6] = {
		float2(-1.0, -1.0), // 0
		float2( 1.0, -1.0), // 1
		float2(-1.0,  1.0), // 2

		float2( 1.0, -1.0), // 3
		float2( 1.0,  1.0), // 4
		float2(-1.0,  1.0)  // 5
	};

	float2 uvs[6] = {
		float2(0.0, 0.0),
		float2(1.0, 0.0),
		float2(0.0, 1.0),

		float2(1.0, 0.0),
		float2(1.0, 1.0),
		float2(0.0, 1.0)
	};

	VertexOut out;
	out.position = float4(positions[vertexID], 0.0, 1.0);
	out.uv = uvs[vertexID];
	return out;
}

fragment float4 fragment_fractal(VertexOut in [[stage_in]],
							  constant FractalUniforms& uniforms [[buffer(0)]]) {
	// переводим экранные координаты (uv) в комплексную плоскость
	float2 c = float2(
		(in.uv.x - 0.5) * uniforms.scale * uniforms.aspect + uniforms.center.x,
		(in.uv.y - 0.5) * uniforms.scale + uniforms.center.y
	);

	float2 z = c;
	int iter = 0;

	while (dot(z, z) < 2.0 && iter < uniforms.maxIter) {
		z = float2(z.x*z.x - z.y*z.y + uniforms.center.x, 2.0*z.x*z.y - uniforms.center.y); //+ c;
		iter++;
	}

	// нормализуем для цвета
	float t = float(iter) / uniforms.maxIter;
	return float4(t, t * 0.5, 1.0 - t, 1.0);
}


