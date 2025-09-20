//
//  FractalShaders.metal
//  MixFractals
//
//  Created by Михаил Фокин on 13.09.2025.
//

#include <metal_stdlib>
#include "Structs.h"

using namespace metal;

// Вершинный шейдер: рисуем fullscreen quad (две треугольные полоски)
vertex VertexOut vertex_fractal(uint vertexID [[vertex_id]], const device VertexIn* vertices [[buffer(0)]]) {
	VertexOut out;
	out.position = float4(vertices[vertexID].position, 0.0, 1.0);
	out.uv = vertices[vertexID].uv;
	return out;
}

