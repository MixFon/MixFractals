//
//  Item.swift
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

import SwiftUI

struct Item: Identifiable {
	let id = UUID()
	let title: String
	let assembly: _FractalAssembler
}

struct MenuView: View {
	private let items = [
		Item(title: "Julia", assembly: JuliaAssembler()),
		Item(title: "Mandelbrot", assembly: MandelbrotAssembler()),
	]
	
	var body: some View {
		NavigationView {
			List {
				ForEach(items) { item in
					Section(header: Text(item.title)) {
						ForEach(Array(1...6), id: \.self) { index in
							NavigationLink(
								destination: FractalWrapper(power: Int32(index), assembly: item.assembly)
							) {
								Text("\(item.title) ^ \(index)")
							}
						}
					}
				}
			}
			.navigationTitle("Список")
		}
	}
}
