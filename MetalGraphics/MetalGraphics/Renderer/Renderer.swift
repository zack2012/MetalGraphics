//
//  Renderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import UIKit
import GSMath

protocol Renderer: class, MTKViewDelegate {
    var rotationX: Float { get set }
    var rotationY: Float { get set }
    var scaleFactor: Float { get }
    var translate: float3 { get }
    
    var uniformBuffer: MTLBuffer? { get set }
    init(mtkView: MTKView)
    
    func updateDynamicBuffer(view: MTKView)
}

extension Renderer {
    var scaleFactor: Float {
        return 0.8
    }
    
    var translate: float3 {
        return float3(0, 0, -5);
    }
    
    func updateDynamicBuffer(view: MTKView) {
        if uniformBuffer == nil {
            uniformBuffer = view.device?.makeBuffer(length: Uniforms.memoryStride, options: .storageModeShared)
        }
        
        let uniforms = makeUniforms(view: view)

        let uniformRawBuffer = uniformBuffer?.contents()
        uniformRawBuffer?.storeBytes(of: uniforms,
                                     toByteOffset: 0,
                                     as: Uniforms.self)
    }
    
    func makeUniforms(view: MTKView) -> Uniforms {
        let rotate1 = GSMath.rotation(axis: float3(1, 0, 0), angle: rotationX)
        let rotate2 = GSMath.rotation(axis: float3(0, 1, 0), angle: rotationY)
        let scale = GSMath.scale(scaleFactor)
        let translate = GSMath.translate(x: self.translate.x,
                                         y: self.translate.y,
                                         z: self.translate.z)
        let size = view.drawableSize
        let apsect = Float(size.width / size.height)
        
        let projection = GSMath.perspective(aspect: apsect, fovy: 72.radian, near: 1, far: 100)
        let world = translate * rotate2 * rotate1 * scale
        let world3x3 = float3x3(world.columns.0.xyz, world.columns.1.xyz, world.columns.2.xyz)
        let normal = world3x3.inverse.transpose
        let mvp = projection * world
        
        let uniforms = Uniforms(mvp: mvp, world: world, normal: normal)
        
        return uniforms
    }
}
