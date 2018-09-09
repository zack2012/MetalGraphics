//
//  Shaders.metal
//  TetrahedronShaders
//
//  Created by lowe on 2018/8/17.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../ShaderTypes.h"

vertex Vertex tetrahedronShader(device Vertex *vertics [[buffer(0)]],
                                constant Uniforms *uniforms [[buffer(1)]],
                                uint vid [[vertex_id]]) {
    Vertex vertexOut;
    vertexOut.position = uniforms->mvp * vertics[vid].position;
    vertexOut.color = vertics[vid].color;
    
    return vertexOut;
}

fragment float4 tetrahedronFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}

