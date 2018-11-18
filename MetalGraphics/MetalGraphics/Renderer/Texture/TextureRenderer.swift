//
//  TextureRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/10/20.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import ModelIO

class TextureRenderer: NSObject, Renderer {
    var rotationX: Float = 0
    var rotationY: Float = 0
    var scaleFactor: Float = 1.4
    var translate: float3 = float3(0, 0, -5)
    var uniformBuffer: MTLBuffer?
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState
    private var teapotRenderPipelineState: MTLRenderPipelineState
    private var depthStencilState: MTLDepthStencilState
    private var sampleState: MTLSamplerState
    
    private var cowMeshes: [MTKMesh]
    private var cowTexture: MTLTexture
    
    required init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "textureShader")
        let fragmentFunc = library.makeFunction(name: "textureFragment")
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
        mtlVertexDesc.attributes[1].offset = 0
        mtlVertexDesc.attributes[1].bufferIndex = 1
        
        // uv
        mtlVertexDesc.attributes[2].format = .float2
        mtlVertexDesc.attributes[2].offset = 12
        mtlVertexDesc.attributes[2].bufferIndex = 0
        
        mtlVertexDesc.layouts[0].stride = 20
        mtlVertexDesc.layouts[0].stepFunction = .perVertex
        
        mtlVertexDesc.layouts[1].stride = 12
        mtlVertexDesc.layouts[1].stepFunction = .perVertex
        
        renderPipelineDesc.vertexDescriptor = mtlVertexDesc
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // set mtkView.depthStencilPixelFormat, the defalut value is .invalid
        mtkView.depthStencilPixelFormat = .depth32Float
        renderPipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        self.renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        self.teapotRenderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDesc)
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
        
        attribute = mdlVertexDesc.attributes[2] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeTextureCoordinate
        
        // MTKMeshBufferAllocator must be set, or MTKMesh.newMeshes will be failed
        let bufferAlloctor = MTKMeshBufferAllocator(device: self.device)
        let cow = importAssert(name: "spot",
                               bufferAllocator: bufferAlloctor,
                               vertexDescriptor: mdlVertexDesc)
        
        
        (_, self.cowMeshes) = try! MTKMesh.newMeshes(asset: cow, device: self.device)

        cowTexture = try! loadTexture(device: device, imageName: "spot_texture.png")
        
        let sampleDesc = MTLSamplerDescriptor()
        sampleDesc.sAddressMode = .repeat
        sampleDesc.tAddressMode = .repeat
        self.sampleState = device.makeSamplerState(descriptor: sampleDesc)!
        
        super.init()
        
        mtkView.delegate = self
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
        
        setupEncoder(encoder, pipelineState: renderPipelineState)
        
        scaleFactor = 3
        updateDynamicBuffer(view: view)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        encoder.setFragmentTexture(cowTexture, index: 0)
//        encoder.setFragmentSamplerState(sampleState, index: 0)
        draw(encoder: encoder, meshes: self.cowMeshes)

        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func setupEncoder(_ encoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        encoder.setDepthStencilState(depthStencilState)
        encoder.setCullMode(.back)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setRenderPipelineState(pipelineState)
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
