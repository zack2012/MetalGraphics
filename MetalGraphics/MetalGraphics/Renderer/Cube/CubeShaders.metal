//
//  CubeShaders.metal
//  MetalGraphics
//
//  Created by lowe on 2018/8/21.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// metal里文件里可以定义多个相同的struct
struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex cubeShader(device Vertex *vertics [[buffer(0)]],
                         constant Uniforms *uniforms [[buffer(1)]],
                         uint vid [[vertex_id]]) {
    Vertex vertexOut;
    vertexOut.position = uniforms->modelViewProjectionMatrix * vertics[vid].position;
    vertexOut.color = vertics[vid].color;
    
    return vertexOut;
}

fragment float4 cubeFragment(Vertex vertexIn [[stage_in]]) {
    return vertexIn.color;
}
