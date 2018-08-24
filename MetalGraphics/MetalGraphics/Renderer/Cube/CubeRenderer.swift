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
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer?
    
    var rotationX: Float = 0
    var rotationY: Float = 0
    var time: Float = 0
    
    
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
        vertexBuffer = device.makeBuffer(bytes: CubeRenderer.vertices,
                                         length: CubeRenderer.vertices.count * MemoryLayout<Vertex>.stride,
                                         options: .storageModeShared)
        vertexBuffer?.label = "Vertices"
        
        indexBuffer = device.makeBuffer(bytes: CubeRenderer.indices,
                                        length: CubeRenderer.indices.count * MemoryLayout<Float>.stride,
                                        options: .storageModeShared)
        indexBuffer?.label = "Indices"
        
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: .storageModeShared)
        uniformBuffer?.label = "Uniforms"
    }
    
    func drawInView(_ view: CubeView) {
        updateUniformBuffer(view: view, duration: Float(view.frameDuration()))
        
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
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: CubeRenderer.indices.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer!,
                                      indexBufferOffset: 0)
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable!)
        commandBuffer.commit()
    }
    
    private func updateUniformBuffer(view: CubeView, duration: Float) {
        time += duration
        rotationX += duration * .pi / 2
        rotationY += duration * .pi / 3
        let scaleFactor = sin(5 * time) * 0.25 + 1
        let rotate1 = Math.matrixRotation(axis: float3(1, 0, 0), angle: rotationY)
        let rotate2 = Math.matrixRotation(axis: float3(0, 1, 0), angle: rotationY)
        let scale = Math.matrixScale(scaleFactor)
        let translate = Math.matrixTranslate(x: 0, y: 0, z: -5)
        let size = view.metalLayer.drawableSize
        let apsect = Float(size.width / size.height)
        let projection = Math.matrixPerspective(aspect: apsect, fovy: 72.radien, near: 1, far: 100)
        let mat = projection * translate * rotate2 * rotate1 * scale
        var uniforms = Uniforms(modelViewProjectionMatrix: mat)
        self.uniformBuffer?.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<Uniforms>.stride)
    }
}

extension CubeRenderer {
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
    
    private static let indices: [UInt16] = [
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    ]
    
    struct Uniforms {
        var modelViewProjectionMatrix: float4x4
    }
}

fileprivate extension Double {
    var radien: Float {
        return Float(self) * .pi / 180
    }
}

fileprivate extension Int {
    var radien: Float {
        return Float(self) * .pi / 180
    }
}
