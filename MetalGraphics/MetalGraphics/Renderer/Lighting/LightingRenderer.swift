//
//  LightingRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit

class LightingRenderer: NSObject {
    private let vertics = [
        Vertex(position: float4(0, 0, 1, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(0, 2 * sqrt(2) / 3, -1 / 3, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(-sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(1, 0, 0, 1)),
    ]
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue

    private var renderPipelineState: MTLRenderPipelineState
    private var verticsBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    
    init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        let library = self.device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "lightingShader")
        let fragmentFunc = library.makeFunction(name: "lightingFragment")
        
        renderPipelineDesc.vertexFunction = vertexFunc
        renderPipelineDesc.fragmentFunction = fragmentFunc
        
        self.renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        super.init()
        
        mtkView.delegate = self
    }
}

extension LightingRenderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
