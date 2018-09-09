//
//  CubeRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/21.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import simd
import GSMath

class CubeRenderer: CubeViewDelegate {
    
    private var device: MTLDevice
    
    private var commandQueue: MTLCommandQueue?
    
    private var renderPipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?
    
    var rotationX: Float = 0
    var rotationY: Float = 0

    private var bufferIndex: Int
    private var semaphore: DispatchSemaphore
    
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        bufferIndex = 0
        semaphore = DispatchSemaphore(value: CubeRenderer.bufferCount)
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
        vertexBuffer = device.makeBuffer(bytes: CubeRenderer.vertices,
                                         length: CubeRenderer.vertices.memoryStride,
                                         options: .storageModeShared)
        vertexBuffer?.label = "Vertices"
        
        indexBuffer = device.makeBuffer(bytes: CubeRenderer.indices,
                                        length: CubeRenderer.indices.memoryStride,
                                        options: .storageModeShared)
        indexBuffer?.label = "Indices"
        
        uniformBuffer = device.makeBuffer(length: Uniforms.memoryStride * CubeRenderer.bufferCount,
                                          options: .storageModeShared)
        uniformBuffer?.label = "Uniforms"
    }
    
    func drawInView(_ view: CubeView) {
        semaphore.wait()
        
        updateUniformBuffer(view: view)
        
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            return
        }
        
        let (renderPass, drawable) = view.renderPass()
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            return
        }
        
        encoder.setRenderPipelineState(renderPipelineState!)
        encoder.setDepthStencilState(depthStencilState!)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uniformBuffer,
                                offset: bufferIndex * Uniforms.memoryStride,
                                index: 1)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: CubeRenderer.indices.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer!,
                                      indexBufferOffset: 0)
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable!)
        
        commandBuffer.addCompletedHandler { (_) in
            self.bufferIndex = (self.bufferIndex + 1) % CubeRenderer.bufferCount
            self.semaphore.signal()
        }
        
        commandBuffer.commit()
    }
    
    private func updateUniformBuffer(view: CubeView) {
        let scaleFactor: Float = 0.8
        
        let rotate1 = GSMath.rotation(axis: float3(1, 0, 0), angle: rotationX)
        let rotate2 = GSMath.rotation(axis: float3(0, 1, 0), angle: rotationY)
        let scale = GSMath.scale(scaleFactor)
        let translate = GSMath.translate(x: 0, y: 0, z: -5)
        let size = view.metalLayer.drawableSize
        let apsect = Float(size.width / size.height)
        let projection = GSMath.perspective(aspect: apsect, fovy: 72.radian, near: 1, far: 100)
        let mat = projection * translate * rotate2 * rotate1 * scale
        
        let uniforms = Uniforms(mvp: mat)
        let uniformRawBuffer = uniformBuffer?.contents()
        uniformRawBuffer?.storeBytes(of: uniforms,
                                     toByteOffset: Uniforms.memoryStride * bufferIndex,
                                     as: Uniforms.self)
    }
}

extension CubeRenderer {
    // 顶点数据
    private static let vertices = [
        Vertex(position: float4(-1,  1,  1, 1), color: float4(0, 1, 1, 1)),
        Vertex(position: float4(-1, -1,  1, 1), color: float4(0, 0, 1, 1)),
        Vertex(position: float4( 1, -1,  1, 1), color: float4(1, 0, 1, 1)),
        Vertex(position: float4( 1,  1,  1, 1), color: float4(1, 1, 1, 1)),
        
        Vertex(position: float4(-1,  1, -1, 1), color: float4(0, 1, 0, 1)),
        Vertex(position: float4(-1, -1, -1, 1), color: float4(0, 0, 0, 1)),
        Vertex(position: float4( 1, -1, -1, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4( 1,  1, -1, 1), color: float4(1, 1, 0, 1)),
    ]
    
    // 顶点数据索引
    private static let indices: [UInt16] = [
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    ]
    
    private static let bufferCount = 3
}

