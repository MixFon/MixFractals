//
//  Structs.h
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

#ifndef Structs_h
#define Structs_h

struct VertexIn {
	float2 position;
	float2 uv;
};

struct VertexOut {
	float4 position [[position]];
	float2 uv;
};

struct FractalUniforms {
	float2 point;  // Точка на экране
	float scale;   // Масштаб (zoom)
	float aspect;  // Отношение сторок экрана
	float2 center; // Куда смотрим (панорамирование)
	int maxIter;   // Количество итераций для точности
	int power;     // Степень косплексноо числа z
};

#endif /* Structs_h */
