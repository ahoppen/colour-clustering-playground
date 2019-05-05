//
//  Transform.metal
//  MetalTest
//
//  Created by Alex Hoppen on 20.03.19.
//  Copyright © 2019 Alex Hoppen. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#define RED_SHIFT 0
#define GREEN_SHIFT 8
#define BLUE_SHIFT 16
#define CLASSIFICATION_SHIFT 24

#define REFERENCE_X 95.05
#define REFERENCE_Y 100.0
#define REFERENCE_Z 108.9

float normalizeRgbComponent(float value) {
    if (value > 0.04045) {
        return 100 * pow(((value + 0.055) / 1.055), 2.4);
    } else {
        return value / 12.92 * 100;
    }
}

float denormalizeRgbComponent(float value) {
    if (value > 0.0031308) {
        return 1.055 * pow(value, (1. / 2.4)) - 0.055;
    } else {
        return 12.92 * value;
    }
}

float normalizeXYZComponent(float value) {
    if (value > 0.008856) {
        return pow(value, 1.0/3.0);
    } else {
        return (7.787 * value) + (16.0 / 116.0);
    }
}

float denormalizeXYZComponent(float value) {
    float pow3 = pow(value, 3);
    if (pow3 > 0.008856) {
        return pow3;
    } else {
        return (value - 16.0 / 116.0) / 7.787;
    }
}

kernel void rgbToLab(device const uint32_t *in [[buffer(0)]],
                     device float4 *out [[buffer(1)]],
                     uint gid [[thread_position_in_grid]]) {
    uint32_t currentColor = in[gid];
    float red   = static_cast<float>((currentColor >> RED_SHIFT) & 0xff);
    float green = static_cast<float>((currentColor >> GREEN_SHIFT) & 0xff);
    float blue  = static_cast<float>((currentColor >> BLUE_SHIFT) & 0xff);
    
    red = red / 255;
    green = green / 255;
    blue = blue / 255;

    red = normalizeRgbComponent(red);
    green = normalizeRgbComponent(green);
    blue = normalizeRgbComponent(blue);

    float x = red * 0.4124 + green * 0.3576 + blue * 0.1805;
    float y = red * 0.2126 + green * 0.7152 + blue * 0.0722;
    float z = red * 0.0193 + green * 0.1192 + blue * 0.9505;

    x = x / REFERENCE_X;
    y = y / REFERENCE_Y;
    z = z / REFERENCE_Z;

    x = normalizeXYZComponent(x);
    y = normalizeXYZComponent(y);
    z = normalizeXYZComponent(z);

    float l = (116.0 * y) - 16.0;
    float a = 500.0 * (x - y);
    float b = 200.0 * (y - z);
    
    out[gid] = {l, a, b, 0};
}

kernel void labToRgb(device const float4 *in [[buffer(0)]],
                     device uint32_t *out [[buffer(1)]],
                     uint gid [[thread_position_in_grid]]) {
    float4 currentColor = in[gid];
    
    float l = currentColor.x;
    float a = currentColor.y;
    float b = currentColor.z;

    float y = (l + 16) / 116;
    float x = a / 500 + y;
    float z = y - b / 200;

    x = denormalizeXYZComponent(x) * REFERENCE_X;
    y = denormalizeXYZComponent(y) * REFERENCE_Y;
    z = denormalizeXYZComponent(z) * REFERENCE_Z;
    
    x = x / 100;
    y = y / 100;
    z = z / 100;
    
    float red = x *  3.2406 + y * -1.5372 + z * -0.4986;
    float green = x * -0.9689 + y *  1.8758 + z *  0.0415;
    float blue = x *  0.0557 + y * -0.2040 + z *  1.0570;

    red = denormalizeRgbComponent(red) * 255;
    green = denormalizeRgbComponent(green) * 255;
    blue = denormalizeRgbComponent(blue) * 255;
    
    out[gid] = static_cast<uint8_t>(red) << RED_SHIFT |
               static_cast<uint8_t>(green) << GREEN_SHIFT |
               static_cast<uint8_t>(blue) << BLUE_SHIFT |
               0xff << CLASSIFICATION_SHIFT;
}

kernel void classifyPixelsLab(device float4 *in [[buffer(0)]],
                              device float4 *colorPalette [[buffer(1)]],
                              device uint8_t *colorPaletteSize [[buffer(2)]],
                              uint id [[thread_position_in_grid]]) {
    float4 currentColor = in[id];
    
    float curDistance = 0xffffff;
    uint8_t chosenReferenceColorIndex;
    
    uint8_t colorPaletteSizeValue = *colorPaletteSize;
    for (uint8_t i = 0; i < colorPaletteSizeValue; i++) {
        float4 referenceColor = colorPalette[i];
        
        float distance = (currentColor.x - referenceColor.x) * (currentColor.x - referenceColor.x) +
                         (currentColor.y - referenceColor.y) * (currentColor.y - referenceColor.y) +
                         (currentColor.z - referenceColor.z) * (currentColor.z - referenceColor.z);
        
        if (distance < curDistance) {
            chosenReferenceColorIndex = i;
            curDistance = distance;
        }
    }
    in[id].w = chosenReferenceColorIndex;
}

kernel void classifyPixels(device uint32_t *in [[buffer(0)]],
                           device uint32_t *colorPalette [[buffer(1)]],
                           device uint8_t *colorPaletteSize [[buffer(2)]],
                           uint id [[thread_position_in_grid]]) {
    uint32_t currentColor = in[id];
    uint8_t red   = (currentColor >> RED_SHIFT) & 0xff;
    uint8_t green = (currentColor >> GREEN_SHIFT) & 0xff;
    uint8_t blue  = (currentColor >> BLUE_SHIFT) & 0xff;
    
    uint32_t curDistance = 0xffffff;
    uint8_t chosenReferenceColorIndex;
    
    uint8_t colorPaletteSizeValue = *colorPaletteSize;
    for (uint8_t i = 0; i < colorPaletteSizeValue; i++) {
        uint32_t referenceColor = colorPalette[i];
        uint8_t referenceRed   = (referenceColor >> RED_SHIFT) & 0xff;
        uint8_t referenceGreen = (referenceColor >> GREEN_SHIFT) & 0xff;
        uint8_t referenceBlue  = (referenceColor >> BLUE_SHIFT) & 0xff;
        
        uint32_t distance = (red - referenceRed) * (red - referenceRed) +
                            (green - referenceGreen) * (green - referenceGreen) +
                            (blue - referenceBlue) * (blue - referenceBlue);
        
        if (distance < curDistance) {
            chosenReferenceColorIndex = i;
            curDistance = distance;
        }
    }
    in[id] = (in[id] & 0x00ffffff) | chosenReferenceColorIndex << 24;
}

kernel void aggregateClusterMeans(device const uint32_t *image [[buffer(0)]],
                                  device uint32_t *colorAggregation [[buffer(1)]],
                                  device uint8_t *numberOfClusters [[buffer(2)]],
                                  uint pixel [[thread_position_in_grid]],
                                  uint threadPos [[thread_position_in_threadgroup]],
                                  uint threadGroupPos [[threadgroup_position_in_grid]]) {
    uint32_t currentColor = image[pixel];
    uint8_t classification = (currentColor >> CLASSIFICATION_SHIFT) & 0xff;
    uint8_t red   = (currentColor >> RED_SHIFT) & 0xff;
    uint8_t green = (currentColor >> GREEN_SHIFT) & 0xff;
    uint8_t blue  = (currentColor >> BLUE_SHIFT) & 0xff;
    
    uint8_t numberOfClustersValue = *numberOfClusters;
    
    for (uint8_t i = 0; i < 64; i++) {
        threadgroup_barrier(mem_flags::mem_threadgroup);
        // Make sure, only one thread per thread group writes to colorAggregation
        if (i == threadPos) {
            // Offset at which this thread starts to write
            uint32_t threadOffset = numberOfClustersValue * 4 * threadGroupPos;
            // Within the threads storage space the offset of the chosen classification
            uint32_t classificationOffset = classification * 4;
            
            colorAggregation[threadOffset + classificationOffset + 0] += red;
            colorAggregation[threadOffset + classificationOffset + 1] += green;
            colorAggregation[threadOffset + classificationOffset + 2] += blue;
            colorAggregation[threadOffset + classificationOffset + 3] += 1;
        }
    }
}

kernel void aggregateClusterMeansLab(device const float4 *image [[buffer(0)]],
                                     device float4 *colorAggregation [[buffer(1)]],
                                     device uint8_t *numberOfClusters [[buffer(2)]],
                                     uint pixel [[thread_position_in_grid]],
                                     uint threadPos [[thread_position_in_threadgroup]],
                                     uint threadGroupPos [[threadgroup_position_in_grid]]) {
    float4 currentColor = image[pixel];
    
    uint8_t numberOfClustersValue = *numberOfClusters;
    
    for (uint8_t i = 0; i < 64; i++) {
        threadgroup_barrier(mem_flags::mem_threadgroup);
        // Make sure, only one thread per thread group writes to colorAggregation
        if (i == threadPos) {
            // Offset at which this thread starts to write
            uint32_t threadOffset = numberOfClustersValue * threadGroupPos;
            // Within the threads storage space the offset of the chosen classification
            uint32_t classificationOffset = currentColor.w;
            
            colorAggregation[threadOffset + classificationOffset].x += currentColor.x;
            colorAggregation[threadOffset + classificationOffset].y += currentColor.y;
            colorAggregation[threadOffset + classificationOffset].z += currentColor.z;
            colorAggregation[threadOffset + classificationOffset].w += 1;
        }
    }
}

kernel void pickColorFromPalette(device uint32_t *in [[buffer(0)]],
                                 device uint32_t *colorPalette [[buffer(1)]],
                                 uint id [[thread_position_in_grid]]) {
    uint32_t currentColor = in[id];
    uint8_t classification = (currentColor >> CLASSIFICATION_SHIFT) & 0xff;
    
    in[id] = colorPalette[classification];
}

kernel void pickColorFromPaletteLab(device float4 *in [[buffer(0)]],
                                    device float4 *colorPalette [[buffer(1)]],
                                    uint id [[thread_position_in_grid]]) {
    uint8_t classificationIndex = static_cast<uint8_t>(in[id].w);
    
    in[id] = colorPalette[classificationIndex];
}
