//
//  GlowController.swift
//  MixFractals
//
//  Created by Михаил Фокин on 01.11.2025.
//

import UIKit
import SwiftUI
import MetalKit
import Foundation

struct GlowWrapper: UIViewControllerRepresentable {
	
	typealias UIViewControllerType = GlowController
		
	func makeUIViewController(context: Context) -> GlowController {
		GlowController()
	}
	
	func updateUIViewController(_ uiViewController: GlowController, context: Context) {
		
	}
	
}

final class GlowController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let device = MTLCreateSystemDefaultDevice()
		
		let view = TriangleView(frame: self.view.bounds, device: device)
		self.view.addSubview(view)
	}
	
}
