//
//  ModelIORender.swift
//  MetalGraphics
//
//  Created by lowe on 2018/10/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import ModelIO

class ModelIORenderer: NSObject, Renderer {
    
    var rotationX: Float = 0
    var rotationY: Float = 0
    var scaleFactor: Float = 1.4
    var translate: float3 = float3(0, 0, -5)
    var uniformBuffer: MTLBuffer?
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState
    private var depthStencilState: MTLDepthStencilState
    
    private var dragonMeshes: [MTKMesh]
    private var teapotMeshes: [MTKMesh]
    
    required init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "modelIOShader")
        let fragmentFunc = library.makeFunction(name: "modelIOFragment")
        renderPipelineDesc.vertexFunction = vertexFunc
        renderPipelineDesc.fragmentFunction = fragmentFunc
        
        let mtlVertexDesc = MTLVertexDescriptor()
        
        // position
        mtlVertexDesc.attributes[0].format = .float3
        mtlVertexDesc.attributes[0].offset = 0
        // if had n bufferIndex, then MTKMesh.vertexBuffers.count == n
        mtlVertexDesc.attributes[0].bufferIndex = 0
        
        // normal
        mtlVertexDesc.attributes[1].format = .float3
        mtlVertexDesc.attributes[1].offset = 12
        mtlVertexDesc.attributes[1].bufferIndex = 0
        
        mtlVertexDesc.layouts[0].stride = 24
        
        renderPipelineDesc.vertexDescriptor = mtlVertexDesc
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // set mtkView.depthStencilPixelFormat, the defalut value is .invalid
        mtkView.depthStencilPixelFormat = .depth32Float
        renderPipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        self.renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .less
        depthStateDesc.isDepthWriteEnabled = true
        self.depthStencilState = self.device.makeDepthStencilState(descriptor: depthStateDesc)!
        
        let mdlVertexDesc = try! MTKModelIOVertexDescriptorFromMetalWithError(mtlVertexDesc)
        
        // attribute.name must be set, or draw call will failed
        var attribute = mdlVertexDesc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = mdlVertexDesc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        
        // MTKMeshBufferAllocator must be set, or MTKMesh.newMeshes will be failed
        let bufferAlloctor = MTKMeshBufferAllocator(device: self.device)
        let dragon = ModelIORenderer.importAssert(name: "dragon",
                                                  bufferAllocator: bufferAlloctor,
                                                  vertexDescriptor: mdlVertexDesc)
        let teapot = ModelIORenderer.importAssert(name: "teapot",
                                                  bufferAllocator: bufferAlloctor,
                                                  vertexDescriptor: mdlVertexDesc)
        (_, self.dragonMeshes) = try! MTKMesh.newMeshes(asset: dragon, device: self.device)
        (_, self.teapotMeshes) = try! MTKMesh.newMeshes(asset: teapot, device: self.device)
        super.init()
        
        mtkView.delegate = self
    }
    
    private static func importAssert(name: String,
                                     bufferAllocator: MDLMeshBufferAllocator? = nil,
                                     vertexDescriptor: MDLVertexDescriptor? = nil
                                     ) -> MDLAsset {
        let bundle = Bundle.main
        let url = bundle.url(forResource: name, withExtension: "obj")!
        return MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let drawable = view.currentDrawable,
            let renderPassDesc = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
            return
        }
        
        setupEncoder(encoder)
        scaleFactor = 1.4
        updateDynamicBuffer(view: view)
        
        encoder.encode { encoder in
            encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            draw(encoder: encoder, meshes: self.dragonMeshes)
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func encoder(_ encoder: MTLRenderCommandEncoder, callback: (MTLRenderCommandEncoder) -> Void) {
        callback(encoder)
        encoder.endEncoding()
    }
    
    private func setupEncoder(_ encoder: MTLRenderCommandEncoder) {
        encoder.setDepthStencilState(depthStencilState)
        encoder.setCullMode(.back)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setRenderPipelineState(renderPipelineState)
    }
    
    private func draw(encoder: MTLRenderCommandEncoder, meshes: [MTKMesh]) {
        for mesh in meshes {
            for (i, meshBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(meshBuffer.buffer, offset: meshBuffer.offset, index: i)
            }
            
            for submesh in mesh.submeshes {
                encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: submesh.indexBuffer.buffer,
                                              indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
    }
}

