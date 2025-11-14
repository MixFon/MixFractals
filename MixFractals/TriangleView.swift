//
//  FractalMetallView.swift
//  MixFractals
//
//  Created by Михаил Фокин on 14.11.2025.
//

import MetalKit

final class TriangleView: MTKView {
	
	private let commandQueue: MTLCommandQueue?
	private let renderPipelineState: MTLRenderPipelineState?
	
	override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
		self.commandQueue = device?.makeCommandQueue()
		
		// Загружаем шейдеры
		let library = device?.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_main")
		let fragmentFunc = library?.makeFunction(name: "fragment_main")
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		
		self.renderPipelineState = try? device?.makeRenderPipelineState(descriptor: descriptor)
		
		super.init(frame: frameRect, device: device)
		
		// Настраиваем формат пикселей для MTKView
		self.colorPixelFormat = .bgra8Unorm
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		guard let drawable = currentDrawable, let descriptor = currentRenderPassDescriptor else { return }
		
		// Создаём command buffer
		let commandBuffer = self.commandQueue?.makeCommandBuffer()
		
		// Создаём render encoder
		let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
		
		if let renderPipelineState = self.renderPipelineState {
			encoder?.setRenderPipelineState(renderPipelineState)
		}
		
		// Рисуем 3 вершины (треугольник)
		// vertexCount: 3 → GPU должен вызвать вершинный шейдер 3 раза (по одному разу на каждую вершину).
		// vertexID внутри шейдера = 0, 1, 2.
		encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
		// Это задаётся параметром type в drawPrimitives:
		// .triangle → каждые 3 вершины образуют треугольник.
		// .line → каждые 2 вершины образуют линию.
		// .point → каждая вершина рисуется как точка.
		encoder?.endEncoding()
		
		// Привязываем drawable и коммитим
		commandBuffer?.present(drawable)
		commandBuffer?.commit()
	}
}
