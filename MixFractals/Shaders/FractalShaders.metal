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
	float2 center;
	float scale;
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

// Фрагментный шейдер: считаем Мандельброта
fragment float4 fragment_fractal(VertexOut in [[stage_in]],
							  constant FractalUniforms& uniforms [[buffer(0)]]) {
	// координаты пикселя в комплексной плоскости
	float2 c = (in.uv - 0.5) * uniforms.scale + uniforms.center;

	// считаем Мандельброта
	float2 z = c;
	int iter = 0;
	const int maxIter = 200;

	while (dot(z, z) < 4.0 && iter < maxIter) {
		z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
		iter++;
	}

	float t = float(iter) / maxIter;
	return float4(t, t * 0.5, 1.0 - t, 1.0);
}


