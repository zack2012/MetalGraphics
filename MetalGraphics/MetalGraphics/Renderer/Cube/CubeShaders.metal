//
//  CubeShaders.metal
//  MetalGraphics
//
//  Created by lowe on 2018/8/21.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../ShaderTypes.h"


vertex Vertex cubeShader(device Vertex *vertics [[buffer(0)]],
                         constant Uniforms *uniforms [[buffer(1)]],
                         uint vid [[vertex_id]]) {
    Vertex vertexOut;
    vertexOut.position = uniforms->mvp * vertics[vid].position;
    vertexOut.color = vertics[vid].color;
    
    return vertexOut;
}

fragment float4 cubeFragment(Vertex vertexIn [[stage_in]]) {
    return vertexIn.color;
}
