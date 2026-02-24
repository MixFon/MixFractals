//
//  Item.swift
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

import SwiftUI

struct MenuView: View {
	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Julia")) {
					NavigationLink(destination: FractalWrapper(power: 2, assembly: Julia2Assembler())) {
						Text("Julia ^ 2")
					}
					NavigationLink(destination: FractalWrapper(power: 3, assembly: Julia3Assembler())) {
						Text("Julia ^ 3")
					}
				}
				
				Section(header: Text("Mandelbrot")) {
					NavigationLink(destination: FractalWrapper(power: 2, assembly: Mandelbrot2Assembler())) {
						Text("Mandelbrot ^ 2")
					}
					NavigationLink(destination: FractalWrapper(power: 3, assembly: Mandelbrot3Assembler())) {
						Text("Mandelbrot ^ 3")
					}
				}
			}
			.navigationTitle("Список")
		}
	}
}
