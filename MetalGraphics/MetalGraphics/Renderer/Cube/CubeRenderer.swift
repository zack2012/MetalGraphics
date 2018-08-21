//
//  CubeRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/21.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import simd

class CubeRenderer: CubeViewDelegate {
    
    var device: MTLDevice
    
    var commandQueue: MTLCommandQueue?
    
    var renderPipelineState: MTLRenderPipelineState?
    var depthStencilState: MTLDepthStencilState?
    
    var vertices: [Vertex] = []
    
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        makePipeline()
        makeBuffers()
    }
    
    func makePipeline() {
        self.commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = library?.makeFunction(name: "cubeShader")
        pipelineDesc.fragmentFunction = library?.makeFunction(name: "cubeFragment")
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDesc.depthAttachmentPixelFormat = .depth32Float
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = .less
        depthStencilDesc.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)
    }
    
    func makeBuffers() {
        vertices = [
            Vertex(position: float4(-1,  1,  1, 1), color: float4(0, 1, 1, 1)),
            Vertex(position: float4(-1, -1,  1, 1), color: float4(0, 0, 1, 1)),
            Vertex(position: float4( 1, -1,  1, 1), color: float4(1, 0, 1, 1)),
            Vertex(position: float4( 1,  1,  1, 1), color: float4(1, 1, 1, 1)),
            
            Vertex(position: float4(-1,  1, -1, 1), color: float4(0, 1, 0, 1)),
            Vertex(position: float4(-1, -1, -1, 1), color: float4(0, 0, 0, 1)),
            Vertex(position: float4( 1, -1, -1, 1), color: float4(1, 0, 0, 1)),
            Vertex(position: float4( 1,  1, -1, 1), color: float4(1, 1, 0, 1)),
        ]
    }
    
    func drawInView(_ view: CubeView) {
        
    }
}
