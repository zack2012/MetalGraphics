//
//  ShaderTypes.h
//  MetalGraphics
//
//  Created by lowe on 2018/9/9.
//  Copyright © 2018 lowe. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 mvp;
    float4x4 world;
    float3x3 normal;
};

struct Material {
    float4 diffuse;
    float4 specular;
    uint exponent;
};

struct PointLight {
    float4 position;
    float4 intensity;
};

#endif /* ShaderTypes_h */
