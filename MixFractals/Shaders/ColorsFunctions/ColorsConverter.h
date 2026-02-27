//
//  ColorsConverter.h
//  MixFractals
//
//  Created by Михаил Фокин on 20.09.2025.
//

#ifndef ColorsConverter_h
#define ColorsConverter_h

// функция перевода HSV → RGB
float3 hsv2rgb(float h, float s, float v);

// гладкая раскраска по continuous iteration count
float3 smoothColor(int iter, float2 z, int maxIter);


#endif /* ColorsConverter_h */
