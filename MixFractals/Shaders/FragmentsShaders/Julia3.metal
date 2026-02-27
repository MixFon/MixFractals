//
//  Julia3.metal
//  MixFractals
//
//  Created by Михаил Фокин on 23.02.2026.
//

#include <metal_stdlib>
#include "../Structs.h"
#include "../ColorsFunctions/ColorsConverter.h"

using namespace metal;

fragment float4 fragment_julia3_fractal(VertexOut in [[stage_in]], constant FractalUniforms& uniforms [[buffer(0)]]) {
	float2 c = float2(
		(in.uv.x - 0.5) * uniforms.scale * uniforms.aspect + uniforms.center.x,
		(in.uv.y - 0.5) * uniforms.scale + uniforms.center.y
	);

	float2 z = c;
	int iter = 0;
	
	while (dot(z, z) < 4.0 && iter < uniforms.maxIter) {
		float x2 = z.x * z.x;
		float y2 = z.y * z.y;
		
		z = float2(
			z.x * x2 - 3.0 * z.x * y2,
			3.0 * x2 * z.y - z.y * y2
		) + uniforms.point;
		iter++;
	}

	float3 color = smoothColor(iter, z, uniforms.maxIter);
	return float4(color, 1.0);
}

