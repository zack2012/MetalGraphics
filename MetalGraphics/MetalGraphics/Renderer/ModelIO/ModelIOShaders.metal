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

struct VertexInput {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

vertex Vertex modelIOShader(VertexInput in [[stage_in]],
                            constant Uniforms *uniforms [[buffer(2)]]
                            ) {
    Vertex vertexOut;

    float4 position = float4(in.position, 1);
    vertexOut.position = uniforms->mvp * position;
    float4 world = uniforms->world * position;
    
    // 法向量必须为单位向量
    float3 normal = normalize(uniforms->normal * in.normal);
    
    float3 lightPosition = float3(10, 10, 10);
    
    // 指向光源的单位向量
    float3 lightVec = normalize(lightPosition - world.xyz);
    
    float cosValue = max(0.0, dot(normal, lightVec));
    float3 cosVec = float3(cosValue, cosValue, cosValue);
    
    // 环境光系数
    float3 ca = float3(0.2, 0.2, 0.2);
    float3 la = float3(0.8, 0.8, 0.8);
    
    // 镜面反射系数
    float3 cr = float3(0.7, 0.7, 0.7);
    float3 lr = float3(0.8, 0.8, 0.8);
    
    uint p = 8;
    float3 viewer = float3(3, 3, 10);
    float3 e = normalize(viewer - world.xyz);
    float len = length(lightVec + e);
    float3 h = (lightVec + e) / len;
    float rcosValue = max(0.0, dot(h, normal));
    float3 rcosVec = float3(rcosValue);

    float3 color = ca * la + float3(0.8, 0.8, 0.8) * float3(0.8, 0.8, 0.8) * cosVec + cr * lr * pow(rcosVec, p);
    // 颜色范围要在0～1之间
    vertexOut.color = clamp(float4(color, 1), float4(), float4(1, 1, 1, 1));
    
    return vertexOut;
}

fragment float4 modelIOFragment(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
