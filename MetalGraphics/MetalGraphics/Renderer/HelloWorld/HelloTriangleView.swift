//
//  HelloTriangleView.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/18.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import simd

struct Vertex {
    var position: float4
    var color: float4
    
    func buffer() -> [Float] {
        var buf = [Float]()
        buf.append(contentsOf: position.compactMap { $0 })
        buf.append(contentsOf: color.compactMap { $0 })
        return buf
    }
}

class HelloTriangleView: UIView {
    private var metalLayer: CAMetalLayer {
        return layer as! CAMetalLayer
    }
    
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    private var device: MTLDevice
    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var displayLink: CADisplayLink?
    
    private let vertices: [Vertex] = [
        Vertex(position: float4(0, 250, 0, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(-250, -250, 0, 1), color: float4(0, 1, 0, 1)),
        Vertex(position: float4(250, -250, 0, 1), color: float4(0, 0, 1, 1)),
    ]
    
    private var vertexBuffer: MTLBuffer?
    
    private var sizeBuffer: MTLBuffer?
    
    override init(frame: CGRect) {
        self.device = MTLCreateSystemDefaultDevice()!
        
        super.init(frame: frame)
        
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        
        // 这里需要手动设置contentsScale, 否则为1
        metalLayer.contentsScale = UIScreen.main.scale
    
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: .storageModeShared)
    
        let scale = UIScreen.main.scale
        let drawableSize = bounds.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        metalLayer.drawableSize = drawableSize
        
        var mat = float4x4(diagonal: float4(Float(2 / drawableSize.width),
                                            Float(2 / drawableSize.height),
                                            1, 1))
        let length = MemoryLayout.stride(ofValue: mat)
        withUnsafeBytes(of: &mat) {
            self.sizeBuffer = device.makeBuffer(bytes: $0.baseAddress!,
                                                length: length,
                                                options: .storageModeShared)
        }
        
        let library = device.makeDefaultLibrary()
        let vertexFun = library?.makeFunction(name: "helloTriangleShader")
        let fragmentFun = library?.makeFunction(name: "helloTriangleFragment")
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFun
        pipelineDesc.fragmentFunction = fragmentFun
        pipelineDesc.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        commandQueue = device.makeCommandQueue()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if superview == nil {
            displayLink?.invalidate()
            displayLink = nil
        } else {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire(_:)))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    @objc func displayLinkFire(_ sender: CADisplayLink) {
        redraw()
    }
    
    func redraw() {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        
        let texture = drawable.texture
        
        let passDesc = MTLRenderPassDescriptor()
        passDesc.colorAttachments[0].texture = texture
        passDesc.colorAttachments[0].loadAction = .clear
        passDesc.colorAttachments[0].storeAction = .store
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc)
        
        encoder?.setRenderPipelineState(pipelineState)
        
        encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder?.setVertexBuffer(sizeBuffer, offset: 0, index: 1)
        
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
