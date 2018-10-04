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
    var uniformBuffer: MTLBuffer?
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState
    
    private var meshes: [MTKMesh]
    
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
        mtlVertexDesc.attributes[0].bufferIndex = 0
        
        // normal
        mtlVertexDesc.attributes[1].format = .float3
        mtlVertexDesc.attributes[1].offset = 12
        mtlVertexDesc.attributes[1].bufferIndex = 0
        
        mtlVertexDesc.layouts[0].stride = 24
        
        renderPipelineDesc.vertexDescriptor = mtlVertexDesc
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        self.renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        let mdlVertexDesc = try! MTKModelIOVertexDescriptorFromMetalWithError(mtlVertexDesc)
        var attribute = mdlVertexDesc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = mdlVertexDesc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        
        // MTKMeshBufferAllocator must be set, or MTKMesh.newMeshes will be failed
        let bufferAlloctor = MTKMeshBufferAllocator(device: self.device)
        let teapot = ModelIORenderer.importAssert(name: "teapot",
                                                  bufferAllocator: bufferAlloctor,
                                                  vertexDescriptor: mdlVertexDesc)
        (_, self.meshes) = try! MTKMesh.newMeshes(asset: teapot, device: self.device)
  
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
    
    func draw(in view: MTKView) {}
    
    
}


