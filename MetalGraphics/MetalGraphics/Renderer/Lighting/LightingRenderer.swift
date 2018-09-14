//
//  LightingRenderer.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import Metal
import MetalKit
import GSMath

class LightingRenderer: NSObject, Renderer {
    var rotationX: Float = 0
    var rotationY: Float = 0
    
    var pointLight = PointLight(position: float4(5, 5, 5, 1),
                                intensity: float4(1, 0.5, 0.8, 1))
    var material = Material(diffuse: float4(0.8, 0.3, 0.5, 1),
                            specular: float4(),
                            exponent: 8)
    var viewer = Viewer(position: float4(3, 3, 10, 1))
    
    var primitiveType: MTLPrimitiveType = .triangle
    var iteration = 6
    
    var scaleFactor: Float {
        return 1.5
    }
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    var renderPipelineState: MTLRenderPipelineState!
    var verticsBuffer: MTLBuffer?
    var vertics: [Vertex] = []
    
    var lightBuffer: MTLBuffer?
    var materialBuffer: MTLBuffer?
    var viewerBuffer: MTLBuffer?

    var uniformBuffer: MTLBuffer?
    
    required init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        uniformBuffer = device.makeBuffer(length: Uniforms.memoryStride, options: .storageModeShared)
        
        super.init()
        
        let renderPipelineDesc = MTLRenderPipelineDescriptor()
        renderPipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        let library = device.makeDefaultLibrary()!
        let (vertex, fragment) = shaderName()
        let vertexFunc = library.makeFunction(name: vertex)
        let fragmentFunc = library.makeFunction(name: fragment)
        
        renderPipelineDesc.vertexFunction = vertexFunc
        renderPipelineDesc.fragmentFunction = fragmentFunc
        
        self.renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDesc)
        
        mtkView.delegate = self
        makeBuffer(n: iteration)
        
        lightBuffer = device.makeBuffer(length: PointLight.memoryStride, options: .storageModeShared)
        materialBuffer = device.makeBuffer(length: Material.memoryStride, options: .storageModeShared)
        viewerBuffer = device.makeBuffer(length: Viewer.memoryStride, options: .storageModeShared)
    }
    
    func shaderName() -> (vertex: String, fragment: String) {
        return ("lightingShader", "lightingFragment")
    }
    
    private func makeBuffer(n: Int) {
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
    
    func updateDynamicBuffer(view: MTKView) {
        var uniforms = makeUniforms(view: view)

        let uniformRawBuffer = uniformBuffer?.contents()
        uniformRawBuffer?.copyMemory(from: &uniforms, byteCount: Uniforms.memoryStride)
        
        lightBuffer?.contents().copyMemory(from: &pointLight, byteCount: lightBuffer!.length)
        materialBuffer?.contents().copyMemory(from: &material, byteCount: materialBuffer!.length)
        viewerBuffer?.contents().copyMemory(from: &viewer, byteCount: viewerBuffer!.length)
    }
    
    func makeUniforms(view: MTKView) -> Uniforms {
        let rotate1 = GSMath.rotation(axis: float3(1, 0, 0), angle: rotationX)
        let rotate2 = GSMath.rotation(axis: float3(0, 1, 0), angle: rotationY)
        let scale = GSMath.scale(scaleFactor)
        let translate = GSMath.translate(x: 0, y: 0, z: -5)
        let size = view.drawableSize
        let apsect = Float(size.width / size.height)
        let projection = GSMath.perspective(aspect: apsect, fovy: 72.radian, near: 1, far: 100)
        let world = translate * rotate2 * rotate1 * scale
        let mat = projection * world
        
        let uniforms = Uniforms(mvp: mat, world: world)
        return uniforms
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
        encoder.setVertexBuffer(lightBuffer, offset: 0, index: 2)
        encoder.setVertexBuffer(materialBuffer, offset: 0, index: 3)
        encoder.setVertexBuffer(viewerBuffer, offset: 0, index: 4)
        
        encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertics.count)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

