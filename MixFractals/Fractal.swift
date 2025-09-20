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
	
	let assembly: _FractalAssembler
	
	func makeUIViewController(context: Context) -> Fractal {
		Fractal(assembly: self.assembly)
	}
	
	func updateUIViewController(_ uiViewController: Fractal, context: Context) {
		
	}
	
}

struct FractalUniforms {
	/// Позиция точки на экране.
	var point: SIMD2<Float>
	/// Масштаб
	var scale: Float
	/// Соотношение сторон экрана
	var aspect: Float
	/// Центр экрана. Уентр фрактала
	var center: SIMD2<Float>
	/// Максимальное количество итераций цикла в жейдере
	var maxIter: Int32
}

final class Fractal: UIViewController {
	
	private let device = MTLCreateSystemDefaultDevice()
	let assembly: _FractalAssembler
	
	init(assembly: _FractalAssembler) {
		self.assembly = assembly
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let metallView = FractalMetallView(frame: self.view.bounds, device: self.device, assembler: self.assembly)
		metallView.clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 1)
		self.view.addSubview(metallView)
	}
}

final class FractalMetallView: MTKView {
	
	private let commandQueue: MTLCommandQueue?
	private let renderPipelineState: MTLRenderPipelineState?
	
	private var uniforms: FractalUniforms
	private let startScale: Float = 6.0
	private let startIter: Int32 = 500
	private let startCenter: SIMD2<Float> = SIMD2<Float>(0.0, 0.0)
	private let startPoint: SIMD2<Float> = SIMD2<Float>(0.0, 0.0)

	private let vertices: [Vertex] = [
		// Миссив для отображения 2 треугольников на весь экран
		Vertex(position: SIMD2<Float>(-1.0, -1.0), uv: SIMD2<Float>(0.0, 0.0)),
		Vertex(position: SIMD2<Float>( 1.0, -1.0), uv: SIMD2<Float>(1.0, 0.0)),
		Vertex(position: SIMD2<Float>(-1.0,  1.0), uv: SIMD2<Float>(0.0, 1.0)),
		
		Vertex(position: SIMD2<Float>( 1.0, -1.0), uv: SIMD2<Float>(1.0, 0.0)),
		Vertex(position: SIMD2<Float>( 1.0,  1.0), uv: SIMD2<Float>(1.0, 1.0)),
		Vertex(position: SIMD2<Float>(-1.0,  1.0), uv: SIMD2<Float>(0.0, 1.0))
	]
	
	init(frame frameRect: CGRect, device: (any MTLDevice)?, assembler: _FractalAssembler) {
		self.commandQueue = device?.makeCommandQueue()
		
		let descriptor = assembler.assembleRenderPipelineDescriptor(device: device)
		
		self.renderPipelineState = try? device?.makeRenderPipelineState(descriptor: descriptor)
		
		self.uniforms = FractalUniforms(
			point: self.startPoint,
			scale: self.startScale,
			aspect: 1,
			center: self.startCenter,
			maxIter: self.startIter
		)
		super.init(frame: frameRect, device: device)
		
		// Настраиваем формат пикселей для MTKView
		self.colorPixelFormat = .bgra8Unorm
		
		setupGestures()
								  
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
		
		let vertexBuffer = self.device?.makeBuffer(
			bytes: self.vertices,
			length: self.vertices.count * MemoryLayout<Vertex>.stride,
			options: []
		)
		encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
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
	
	private func setupGestures() {
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		self.addGestureRecognizer(pinch)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		self.addGestureRecognizer(pan)
		
		// Создаем распознаватель жеста с указанием количества пальцев
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
		panGesture.minimumNumberOfTouches = 2  // Минимум 2 пальца
		panGesture.maximumNumberOfTouches = 2  // Максимум 2 пальца
		self.addGestureRecognizer(panGesture)
		
		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
		doubleTapGesture.numberOfTapsRequired = 2
		doubleTapGesture.numberOfTouchesRequired = 1 // Один палец
		self.addGestureRecognizer(doubleTapGesture)
	}
	
	@objc
	private func handlePinch(_ sender: UIPinchGestureRecognizer) {
		if sender.state == .changed || sender.state == .ended {
			self.uniforms.scale *= Float(1 / sender.scale)
			let zoomFactor = log10(self.startScale / self.uniforms.scale) // 6.0 = начальный scale
			self.uniforms.maxIter = Int32(Float(self.startIter) * (1 + zoomFactor))
			sender.scale = 1.0
		}
	}
	
	@objc
	private func handlePan(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self) // смещение
		// Производим нормальлизацию
		self.uniforms.point.x -= Float(translation.x) / Float(bounds.width) * self.uniforms.scale
		self.uniforms.point.y += Float(translation.y) / Float(bounds.height) * self.uniforms.scale
		// Обнуляем translation, иначе будет накапливаться
		gesture.setTranslation(.zero, in: self)
	}
	
	@objc
	private func handleTwoFingerPan(_ gesture: UIPanGestureRecognizer) {
		guard gesture.numberOfTouches == 2 else { return }
		let translation = gesture.translation(in: self)
		// Перемещение центра
		self.uniforms.center.x -= Float(translation.x) / Float(bounds.width) * self.uniforms.scale
		self.uniforms.center.y += Float(translation.y) / Float(bounds.height) * self.uniforms.scale
		gesture.setTranslation(.zero, in: self)
	}
	
	@objc
	private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		self.uniforms.scale = self.startScale
		self.uniforms.maxIter = self.startIter
		self.uniforms.center = self.startCenter
		self.uniforms.point = self.startPoint
		self.uniforms.aspect = Float(self.bounds.width / self.bounds.height)
	}
}
