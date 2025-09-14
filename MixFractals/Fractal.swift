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
	var aspect: Float
	var maxIter: Int32
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
	
	private var uniforms: FractalUniforms
	private let startScale: Float = 6.0
	private let baseIter: Int32 = 500
	
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
		
		self.uniforms = FractalUniforms(
			center: SIMD2<Float>(0.0, 0.0),
			scale: self.startScale,
			aspect: 1,
			maxIter: self.baseIter
		)
		super.init(frame: frameRect, device: device)
		
		// Настраиваем формат пикселей для MTKView
		self.colorPixelFormat = .bgra8Unorm
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		self.addGestureRecognizer(pinch)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		self.addGestureRecognizer(pan)
		
		self.uniforms.aspect = Float(self.bounds.width / self.bounds.height)
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

		// Рисуем 6 вершины (2 треугольника)
		// vertexCount: 6 → GPU должен вызвать вершинный шейдер 6 раз (по одному разу на каждую вершину).
		// vertexID внутри шейдера = 0, 1, 2, 3, 4, 5.
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
	
	@objc
	private func handlePinch(_ sender: UIPinchGestureRecognizer) {
		if sender.state == .changed || sender.state == .ended {
			self.uniforms.scale *= Float(1 / sender.scale)
			let zoomFactor = log10(self.startScale / self.uniforms.scale) // 6.0 = начальный scale
			self.uniforms.maxIter = Int32(Float(self.baseIter) * (1 + zoomFactor))
			sender.scale = 1.0
		}
	}
	
	@objc
	private func handlePan(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self) // смещение
		// Производим нормальлизацию
		self.uniforms.center.x -= Float(translation.x) / Float(bounds.width) * self.uniforms.scale
		self.uniforms.center.y += Float(translation.y) / Float(bounds.height) * self.uniforms.scale
		// Обнуляем translation, иначе будет накапливаться
		gesture.setTranslation(.zero, in: self)
	}
}
