//
//  SphereRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import simd

class SphereRenderer: NSObject, Renderer {
    var rotationX: Float = 0
    var rotationY: Float = 0
    
    var primitiveType: MTLPrimitiveType = .lineStrip
    var iteration = 5
    
    var scaleFactor: Float {
        return 1.5
    }
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    
    private var renderPipelineState: MTLRenderPipelineState
    private var verticsBuffer: MTLBuffer?
    private var vertics: [Vertex] = []
    
    var uniformBuffer: MTLBuffer?
    
    required init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "sphereShader")
        let fragmentFunc = library.makeFunction(name: "sphereFragment")
        
        renderPipelineDesc.vertexFunction = vertexFunc
        renderPipelineDesc.fragmentFunction = fragmentFunc
        
        self.renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        super.init()
        
        mtkView.delegate = self
        makeBuffer(n: iteration)
    }
    
    func makeBuffer(n: Int) {
        self.vertics.removeAll(keepingCapacity: true)

        let vertics = [
            Vertex(position: float4(0, 0, 1, 1), color: float4(1, 0, 0, 1)),
            Vertex(position: float4(0, 2 * sqrt(2) / 3, -1 / 3, 1), color: float4(0, 1, 0, 1)),
            Vertex(position: float4(-sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(0, 0, 1, 1)),
            Vertex(position: float4(sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(1, 1, 0, 1)),
        ]
        
        func makeBufferImpl(a: Vertex, b: Vertex, c: Vertex, n: Int) {
            if n > 0 {
                let v1 = (a + b).normalize()
                let v2 = (b + c).normalize()
                let v3 = (c + a).normalize()
                
                makeBufferImpl(a: a, b: v1, c: v3, n: n - 1)
                makeBufferImpl(a: b, b: v2, c: v1, n: n - 1)
                makeBufferImpl(a: c, b: v3, c: v2, n: n - 1)
                makeBufferImpl(a: v1, b: v2, c: v3, n: n - 1)

                return
            }
            
            self.vertics.append(a)
            self.vertics.append(b)
            self.vertics.append(c)
        }
        
        makeBufferImpl(a: vertics[0], b: vertics[1], c: vertics[2], n: n)
        makeBufferImpl(a: vertics[0], b: vertics[3], c: vertics[1], n: n)
        makeBufferImpl(a: vertics[0], b: vertics[2], c: vertics[3], n: n)
        makeBufferImpl(a: vertics[1], b: vertics[3], c: vertics[2], n: n)
        
        verticsBuffer = device.makeBuffer(bytes: &self.vertics, length: self.vertics.memoryStride, options: .storageModeShared)
    }
    
    func draw(in view: MTKView) {
        updateDynamicBuffer(view: view)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let renderPassDesc = MTLRenderPassDescriptor()
        renderPassDesc.colorAttachments[0].texture = drawable.texture
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].storeAction = .store
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
            return
        }
        
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        
        encoder.setVertexBuffer(verticsBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertics.count)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
