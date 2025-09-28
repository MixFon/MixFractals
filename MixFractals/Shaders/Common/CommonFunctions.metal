//
//  CommonFunctions.metal
//  MixFractals
//
//  Created by Михаил Фокин on 28.09.2025.
//

#include <metal_stdlib>
using namespace metal;

float2 complexPow(float2 z, int n) {
	float2 result = float2(1.0, 0.0); // z^0 = 1
	float2 base = z;

	int exp = n;
	while (exp > 0) {
		if (exp & 1) {
			// result *= base
			result = float2(
				result.x * base.x - result.y * base.y,
				result.x * base.y + result.y * base.x
			);
		}
		// base = base^2
		base = float2(
			base.x * base.x - base.y * base.y,
			2.0 * base.x * base.y
		);
		exp >>= 1;
	}
	return result;
}
