//
//  Fractal.swift
//  MixFractals
//
//  Created by Михаил Фокин on 11.09.2025.
//

import UIKit
import SwiftUI
import MetalKit
import Foundation

struct FractalWrapper: UIViewControllerRepresentable {
	typealias UIViewControllerType = Fractal
	
	func makeUIViewController(context: Context) -> Fractal {
		Fractal()
	}
	
	func updateUIViewController(_ uiViewController: Fractal, context: Context) {
		
	}
	
}

struct FractalUniforms {
	var center: SIMD2<Float>
	var scale: Float
}

final class Fractal: UIViewController {
	
	private let device = MTLCreateSystemDefaultDevice()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let metallView = FractalMetallView(frame: self.view.bounds, device: self.device)
		metallView.clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 1)
		self.view.addSubview(metallView)
	}
}

final class FractalMetallView: MTKView {
	
	private let commandQueue: MTLCommandQueue?
	private let renderPipelineState: MTLRenderPipelineState?
	var uniforms = FractalUniforms(center: SIMD2<Float>(-0.5, 0.0), scale: 3.0)
	
	override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
		self.commandQueue = device?.makeCommandQueue()
		
		// Загружаем шейдеры
		let library = device!.makeDefaultLibrary()
		let vertexFunc = library?.makeFunction(name: "vertex_fractal")
		let fragmentFunc = library?.makeFunction(name: "fragment_fractal")
		
		// Создаём render pipeline
		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunc
		descriptor.fragmentFunction = fragmentFunc
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		
		self.renderPipelineState = try? device?.makeRenderPipelineState(descriptor: descriptor)
		
		super.init(frame: frameRect, device: device)
		
		// Настраиваем формат пикселей для MTKView
		self.colorPixelFormat = .bgra8Unorm
		startTimer()
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
		
		encoder?.setFragmentBytes(&uniforms, length: MemoryLayout<FractalUniforms>.stride, index: 0)

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
	
	private var timer: Timer?
	
	func startTimer() {
		// Запускаем таймер, который вызывает метод everySecond() каждые 1.0 секунды
		timer = Timer.scheduledTimer(timeInterval: 0.01,
									 target: self,
									 selector: #selector(everySecond),
									 userInfo: nil,
									 repeats: true)
		// Если нужно, чтобы таймер работал при скролле и т.д., можно:
		RunLoop.current.add(timer!, forMode: .common)
	}
	
	@objc private func everySecond() {
		// Обновление UI — выполняется в главном потоке
		self.uniforms.center.x += 0.001
		//self.uniforms.scale *= 0.9
	}
	
	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
}
