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
	float2 uv;
};

vertex Vertex vertex_main(uint vertexID [[vertex_id]], constant float4 *positions [[buffer(0)]], constant float4 *colors [[buffer(1)]], constant uint *indices [[buffer(2)]]) {
	float2 uvs[4] = {
		float2(0.0, 1.0), // верх-лево
		float2(0.0, 0.0), // низ-лево
		float2(1.0, 0.0), // низ-право
		float2(1.0, 1.0)  // верх-право
	};
	
	uint ind = indices[vertexID];

	Vertex out;
	out.position = positions[ind];
	out.color = colors[ind];
	out.uv = uvs[ind];
	return out;
}

/*
 (0,1) ----- (1,1)
   |           |
   |           |
 (0,0) ----- (1,0)
 */

fragment float4 fragment_main(Vertex in [[stage_in]], constant float &time [[buffer(1)]]) {
	// Используем те же координаты, что и раньше
	//float2 uv = in.position.xy;
	
	float2 uv = in.uv;
	
	// Параметры волн
	float frequency = 50.0;    // количество волн по X
	float speed = 10.0;         // скорость анимации
	
	
	// Сдвигаем вертикальную координату
	float wave = 2.5 + 0.5 * sin(uv.x * frequency + time * speed);
	float4 color = in.color * float4(wave, wave, wave, 1.0);
	return color;


	return color;
}
