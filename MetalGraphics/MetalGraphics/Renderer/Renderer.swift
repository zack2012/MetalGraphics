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

protocol Renderer: class, MTKViewDelegate {
    var rotationX: Float { get set }
    var rotationY: Float { get set }
    var scaleFactor: Float { get }
    
    var uniformBuffer: MTLBuffer? { get set }
    init(mtkView: MTKView)
    
    func updateUniformBuffer(view: MTKView)
}

extension Renderer {
    var scaleFactor: Float {
        return 0.8
    }
    
    func updateUniformBuffer(view: MTKView) {
        if uniformBuffer == nil {
            uniformBuffer = view.device?.makeBuffer(length: Uniforms.memoryStride, options: .storageModeShared)
        }
        
        let rotate1 = Math.matrixRotation(axis: float3(1, 0, 0), angle: rotationX)
        let rotate2 = Math.matrixRotation(axis: float3(0, 1, 0), angle: rotationY)
        let scale = Math.matrixScale(scaleFactor)
        let translate = Math.matrixTranslate(x: 0, y: 0, z: -5)
        let size = view.drawableSize
        let apsect = Float(size.width / size.height)
        let projection = Math.matrixPerspective(aspect: apsect, fovy: 72.radian, near: 1, far: 100)
        let mat = projection * translate * rotate2 * rotate1 * scale
        
        let uniforms = Uniforms(modelViewProjectionMatrix: mat)
        let uniformRawBuffer = uniformBuffer?.contents()
        uniformRawBuffer?.storeBytes(of: uniforms,
                                     toByteOffset: 0,
                                     as: Uniforms.self)
    }
    
}
