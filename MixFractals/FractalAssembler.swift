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

final class JuliaAssembler: _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		let library = device?.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_fractal")
		let fragmentFunc = library?.makeFunction(name: "fragment_julia_fractal")
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		return descriptor
	}
}

final class Mandelbrot3Assembler: _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		let library = device?.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_fractal")
		let fragmentFunc = library?.makeFunction(name: "fragment_mandelbrot_3_fractal")
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		return descriptor
	}
}

final class MandelbrotAssembler: _FractalAssembler {
	
	func assembleRenderPipelineDescriptor(device: (any MTLDevice)?) -> MTLRenderPipelineDescriptor {
		let library = device?.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_fractal")
		let fragmentFunc = library?.makeFunction(name: "fragment_mandelbrot_fractal")
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		return descriptor
	}
}
