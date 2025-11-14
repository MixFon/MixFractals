//
//  MainShaders.metal
//  MixFractals
//
//  Created by Михаил Фокин on 13.09.2025.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
	float4 position [[position]];
	float4 color;
};

vertex Vertex vertex_main(uint vertexID [[vertex_id]]) {
	float4 positions[4] = {
		float4(-0.5,  0.5, 0.0, 1.0),  // верх
		float4(-0.5, -0.5, 0.0, 1.0),  // левый низ
		float4( 0.5, -0.5, 0.0, 1.0),  // правый низ
		float4( 0.5,  0.5, 0.0, 1.0)   // правый верх
	};

	float4 colors[4] = {
		float4(1, 0, 0, 1), // красный
		float4(0, 1, 0, 1), // зелёный
		float4(0, 0, 1, 1), // синий
		float4(0, 1, 1, 1), //
	};
	
	// Индексный буфер (как мы составляем два треугольника)
	uint indices[6] = {
		0, 1, 2,   // Первый треугольник
		0, 2, 3    // Второй треугольник
	};
	
	uint ind = indices[vertexID];

	Vertex out;
	out.position = positions[ind];
	out.color = colors[ind];
	return out;
}

fragment float4 fragment_main(Vertex in [[stage_in]]) {
	return in.color;
}
