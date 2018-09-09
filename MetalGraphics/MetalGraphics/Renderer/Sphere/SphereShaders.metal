//
//  SphereShaders.metal
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../ShaderTypes.h"

vertex Vertex sphereShader(device Vertex *vertics [[buffer(0)]],
                                constant Uniforms *uniforms [[buffer(1)]],
                                uint vid [[vertex_id]]) {
    Vertex vertexOut;
    vertexOut.position = uniforms->mvp * vertics[vid].position;
    vertexOut.color = vertics[vid].color;
    
    return vertexOut;
}

fragment float4 sphereFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
