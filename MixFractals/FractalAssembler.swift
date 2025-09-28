//
//  FractalAssembler.swift
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

import MetalKit

protocol _FractalAssembler {
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor
}

extension _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(fragmentFuncName: String, device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		let library = device?.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_fractal")
		let fragmentFunc = library?.makeFunction(name: fragmentFuncName)
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		return descriptor
	}
}

final class JuliaAssembler: _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		return assembleRenderPipelineDescriptor(fragmentFuncName: "fragment_julia_fractal", device: device)
	}
}

final class MandelbrotAssembler: _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		return assembleRenderPipelineDescriptor(fragmentFuncName: "fragment_mandelbrot_fractal", device: device)
	}
}
