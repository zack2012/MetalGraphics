//
//  TetrahedronRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit

class TetrahedronRenderer: NSObject, Renderer {
    var rotationX: Float = 0
    var rotationY: Float = 0
    
    private let vertics = [
        Vertex(position: float4(0, 0, 1, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(0, 2 * sqrt(2) / 3, -1 / 3, 1), color: float4(0, 1, 0, 1)),
        Vertex(position: float4(-sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(0, 0, 1, 1)),
        Vertex(position: float4(sqrt(6) / 3, -sqrt(2) / 3, -1 / 3, 1), color: float4(1, 1, 0, 1)),
    ]
    
    private let lineIndices: [UInt16] = [
        0, 1, 1, 2, 2, 0,
        0, 3, 3, 1, 1, 0,
        0, 2, 2, 3, 3, 0,
        1, 2, 2, 3, 3, 1,
    ]
    
    private let triangleIndices: [UInt16] = [
        0, 1, 2,
        0, 3, 1,
        0, 2, 3,
        1, 3, 2
    ]
    
    private var indices: [UInt16] {
        return isDrawLine ? lineIndices : triangleIndices
    }
    
    private var primitiveType: MTLPrimitiveType {
        return isDrawLine ? .line : .triangle
    }
    
    private var indexBuffer: MTLBuffer? {
        return isDrawLine ? lineIndexBuffer : triangleIndexBuffer
    }
    
    var isDrawLine = true
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue

    private var renderPipelineState: MTLRenderPipelineState
    private var verticsBuffer: MTLBuffer?
    private var lineIndexBuffer: MTLBuffer?
    private var triangleIndexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer?
    
    required init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        let library = self.device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "tetrahedronShader")
        let fragmentFunc = library.makeFunction(name: "tetrahedronFragment")
        
        renderPipelineDesc.vertexFunction = vertexFunc
        renderPipelineDesc.fragmentFunction = fragmentFunc
        
        self.renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        super.init()
        
        mtkView.delegate = self
        
        verticsBuffer = device.makeBuffer(bytes: vertics, length: vertics.memoryStride, options: .storageModeShared)
        lineIndexBuffer = device.makeBuffer(bytes: lineIndices, length: lineIndices.memoryStride, options: .storageModeShared)
        triangleIndexBuffer = device.makeBuffer(bytes: triangleIndices, length: triangleIndices.memoryStride, options: .storageModeShared)
        uniformBuffer = device.makeBuffer(length: Uniforms.memoryStride, options: .storageModeShared)
    }
        
    func draw(in view: MTKView) {
        updateUniformBuffer(view: view)
        
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
        
        encoder.drawIndexedPrimitives(type: primitiveType,
                                      indexCount: indices.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer!,
                                      indexBufferOffset: 0)
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

}
