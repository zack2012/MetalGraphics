//
//  Shaders.metal
//  HelloTriangle
//
//  Created by lowe on 2018/8/17.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex helloTriangleShader(device Vertex *vertices [[buffer(0)]],
                                  constant Uniforms *uniforms [[buffer(1)]],
                                  uint vid [[vertex_id]]) {
    Vertex out;
    auto vtx = vertices[vid];
    out.position = uniforms->modelViewProjectionMatrix * vtx.position;
    out.color = vtx.color;
    return out;
}

fragment float4 helloTriangleFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}

