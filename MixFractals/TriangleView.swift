//
//  FractalMetallView.swift
//  MixFractals
//
//  Created by Михаил Фокин on 14.11.2025.
//

import simd
import MetalKit

final class TriangleView: MTKView {
	
	private let commandQueue: MTLCommandQueue?
	private let renderPipelineState: MTLRenderPipelineState?
	private var time: Float = 0
	private var timeBuffer: MTLBuffer!
	private let positionBuffer: MTLBuffer!
	private let colorBuffer: MTLBuffer!
	private let indexBuffer: MTLBuffer!
	private let uvBuffer: MTLBuffer!

	private let positions: [SIMD4<Float>] = [
		SIMD4(-0.5,  0.5, 0, 1),
		SIMD4(-0.5, -0.5, 0, 1),
		SIMD4( 0.5, -0.5, 0, 1),
		SIMD4( 0.5,  0.5, 0, 1),
	]
	
	private let colors: [SIMD4<Float>] = [
		SIMD4(1, 0, 0, 1), // красный
		SIMD4(0, 1, 0, 1), // зелёный
		SIMD4(0, 0, 1, 1), // синий
		SIMD4(0, 1, 1, 1), //
	]
	
	private let indices: [UInt32] = [
		0, 1, 2,   // Первый треугольник
		0, 2, 3    // Второй треугольник
	]
	
	private let uvs: [SIMD2<Float>] = [
		SIMD2(0.0, 1.0), // верх-лево
		SIMD2(0.0, 0.0), // низ-лево
		SIMD2(1.0, 0.0), // низ-право
		SIMD2(1.0, 1.0)  // верх-право
	]
	
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
		
		self.positionBuffer = device?.makeBuffer(
			bytes: self.positions,
			length: MemoryLayout<SIMD4<Float>>.stride * self.positions.count,
			options: .storageModeShared
		)
		
		self.colorBuffer = device?.makeBuffer(
			bytes: self.colors,
			length: MemoryLayout<SIMD4<Float>>.stride * self.colors.count,
			options: .storageModeShared
		)
		
		self.indexBuffer = device?.makeBuffer(
			bytes: self.indices,
			length: MemoryLayout<UInt32>.stride * self.indices.count,
			options: .storageModeShared
		)
		
		self.uvBuffer = device?.makeBuffer(
			bytes: self.uvs,
			length: MemoryLayout<SIMD2<Float>>.stride * self.uvs.count,
			options: .storageModeShared
		)
		
		self.timeBuffer = device?.makeBuffer(
			length: MemoryLayout<Float>.size,
			options: .storageModeShared
		)
		
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
		
		time += 0.5 / 60.0   // или используем CACurrentMediaTime()
		let ptr = timeBuffer.contents().bindMemory(to: Float.self, capacity: 1)
		ptr.pointee = time
		
		encoder?.setVertexBuffer(self.positionBuffer, offset: 0, index: 0)
		encoder?.setVertexBuffer(self.colorBuffer, offset: 0, index: 1)
		encoder?.setVertexBuffer(self.indexBuffer, offset: 0, index: 2)
		encoder?.setVertexBuffer(self.uvBuffer, offset: 0, index: 3)

		encoder?.setFragmentBuffer(timeBuffer, offset: 0, index: 1)
		
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
