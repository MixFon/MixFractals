//
//  glow.metal
//  MixFractals
//
//  Created by Михаил Фокин on 01.11.2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
	float4 position [[position]];
	float2 texCoord;
};

fragment float4 glow_fragment(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]], constant float &intensity [[buffer(0)]]) {
	constexpr sampler s(address::clamp_to_edge, filter::linear);
	float4 color = texture.sample(s, in.texCoord);
	float glow = smoothstep(0.4, 1.0, length(in.texCoord - 0.5));
	return mix(color, float4(1.0, 0.8, 0.3, 1.0), glow * intensity);
}
