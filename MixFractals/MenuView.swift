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
    let items = [
		Item(title: "Julia", assembly: JuliaAssembler()),
		Item(title: "Mandelbrot", assembly: MandelbrotAssembler()),
		Item(title: "Mandelbrot^3", assembly: Mandelbrot3Assembler()),
    ]
    
    var body: some View {
        NavigationView {
            List(items) { item in
				NavigationLink(destination: FractalWrapper(assembly: item.assembly)) {
					Text(item.title)
                }
            }
            .navigationTitle("Список")
        }
    }
}
