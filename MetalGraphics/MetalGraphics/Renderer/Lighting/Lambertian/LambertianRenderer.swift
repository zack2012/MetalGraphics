//
//  LambertianRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/10.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import GSMath

class LambertianRenderer: LightingRenderer {
    var pointLight = PointLight(position: float4(5, 5, 5, 1),
                                intensity: float4(1, 0.5, 0.8, 1))
    var material = Material(diffuse: float4(0.8, 0.3, 0.5, 1), specular: float4())
    
    required init(mtkView: MTKView) {
        super.init(mtkView: mtkView)
        
        lightBuffer = device.makeBuffer(length: PointLight.memoryStride, options: .storageModeShared)
        materialBuffer = device.makeBuffer(length: Material.memoryStride, options: .storageModeShared)
    }
    
    override func shaderName() -> (vertex: String, fragment: String) {
        return ("lambertianShader", "lambertianFragment")
    }
    
    override func updateDynamicBuffer(view: MTKView) {
        super.updateDynamicBuffer(view: view)
        
        lightBuffer?.contents().copyMemory(from: &pointLight, byteCount: lightBuffer!.length)
        
        materialBuffer?.contents().copyMemory(from: &material, byteCount: materialBuffer!.length)
    }
}
