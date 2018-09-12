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
    float3 cosVec = float3(cosValue, cosValue, cosValue);

    // 环境光系数
    float3 ca = float3(0.3, 0.2, 0.2);
    float3 la = float3(0.8, 0.8, 0.8);
    
    float3 color =  ca * la + material->diffuse.xyz * light->intensity.xyz * cosVec;
    
    // 颜色范围要在0～1之间
    vertexOut.color = clamp(float4(color, 1), float4(), float4(1, 1, 1, 1));
    
    return vertexOut;
}

fragment float4 lambertianFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
