//
//  LightingShaders.metal
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../ShaderTypes.h"

vertex Vertex lambertianShader(uint vid [[vertex_id]],
                               device Vertex *vertics [[buffer(0)]],
                               constant Uniforms *uniforms [[buffer(1)]],
                               constant PointLight *light [[buffer(2)]],
                               constant Material *material [[buffer(3)]]
                               ) {
    Vertex vertexOut;
    float4 worldPosition = uniforms->world * vertics[vid].position;
    float4 centerInWorldPosition = uniforms->world * float4(0, 0, 0, 1);
    float4 lightVec = normalize(light->position - worldPosition);
    float4 normalVec = normalize(worldPosition - centerInWorldPosition);
    vertexOut.position = uniforms->mvp * vertics[vid].position;
    float cosValue = max(0.0, dot(normalVec, lightVec));
    float4 cosVec = float4(cosValue, cosValue, cosValue, 1);
    vertexOut.color = light->intensity * material->diffuse * cosVec;
    
    return vertexOut;
}

fragment float4 lambertianFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
