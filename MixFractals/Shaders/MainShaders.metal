//
//  MainShaders.metal
//  MixFractals
//
//  Created by Михаил Фокин on 13.09.2025.
//

#include <metal_stdlib>
using namespace metal;

/*
 Визуально
 Вершинный шейдер получает три точки и их цвета.
 GPU соединяет эти вершины в треугольник.
 Для каждого пикселя внутри треугольника запускается фрагментный шейдер.
 Фрагментный шейдер берёт цвет и рисует его на экране.
 В центре треугольника цвет будет смесью красного, зелёного и синего.
*/

// Структура для вершинных данных
struct Vertex {
	// position [[position]] — атрибут, указывающий GPU, что это позиция вершины в пространстве (обязательный выход вершины)
	float4 position [[position]];
	float4 color;
};

// Вершинный шейдер.
// vertex — ключевое слово, указывающее, что это вершинный шейдер.
// Возвращаем структуру Vertex → она пойдёт во фрагментный шейдер.
// vertexID [[vertex_id]] — это встроенный атрибут, который Metal автоматически передаёт (номер текущей вершины).
vertex Vertex vertex_main(uint vertexID [[vertex_id]]) {
	// Каждая вершина описывается float4(x, y, z, w) в NDC (normalized device coordinates).
	// x и y ∈ [-1, 1] → экран.
	// z используется для глубины.
	// w = 1.0 (гомогенные координаты).
	float4 positions[3] = {
		float4( 0.0,  0.5, 0.0, 1.0),  // верх
		float4(-0.5, -0.5, 0.0, 1.0),  // левый низ
		float4( 0.5, -0.5, 0.0, 1.0)   // правый низ
	};

	float4 colors[3] = {
		float4(1, 0, 0, 1), // красный
		float4(0, 1, 0, 1), // зелёный
		float4(0, 0, 1, 1)  // синий
	};

	Vertex out;
	out.position = positions[vertexID];
	out.color = colors[vertexID];
	return out;
}

// Фрагментный шейдер
// fragment — ключевое слово (фрагментный шейдер).
// На вход получает интерполированные данные от вершинного шейдера ([[stage_in]]).
fragment float4 fragment_main(Vertex in [[stage_in]]) {
	// Здесь это color. Metal сам интерполирует цвет между вершинами (по barycentric interpolation).
	// Возвращаем float4 — это цвет пикселя.
	return in.color;
}
