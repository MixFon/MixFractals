//
//  Julia2.metal
//  MixFractals
//
//  Created by Михаил Фокин on 23.02.2026.
//

#include <metal_stdlib>
#include "../Structs.h"
#include "../ColorsFunctions/ColorsConverter.h"

using namespace metal;

fragment float4 fragment_julia2_fractal(VertexOut in [[stage_in]], constant FractalUniforms& uniforms [[buffer(0)]]) {
	float2 c = float2(
		(in.uv.x - 0.5) * uniforms.scale * uniforms.aspect + uniforms.center.x,
		(in.uv.y - 0.5) * uniforms.scale + uniforms.center.y
	);

	float2 z = c;
	int iter = 0;
	
	while (dot(z, z) < 4.0 && iter < uniforms.maxIter) {
		float x = z.x;
		float y = z.y;
		float x2 = x * x;
		float y2 = y * y;
		
		z = float2(
			x2 - y2,
			2.0 * x * y
		) + uniforms.point;
		iter++;
	}

	float3 color = smoothColor(iter, z, uniforms.maxIter);
	return float4(color, 1.0);
}

