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
    /// 顶点位置，单位像素
    var position: float4
    
    /// 顶点颜色，RGBA
    var color: float4
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
    
    private let vertices: [Vertex]
    
    /// 存储顶点数据的buffer
    private var vertexBuffer: MTLBuffer?
    
    /// 存储坐标变换矩阵的buffer
    private var matrixBuffer: MTLBuffer?
    
    override init(frame: CGRect) {
        self.device = MTLCreateSystemDefaultDevice()!
        
        let scale = UIScreen.main.scale
        // Metal不用point，而使用pixel，所以这里需要将point转换为pixel
        let drawableSize = frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        // 设置顶点数据，三角形的中心在屏幕的原点
        let midX = Float(drawableSize.width / 2)
        let midY = Float(drawableSize.height / 2)
        vertices = [
            Vertex(position: float4(midX, midY + 250, 0, 1), color: float4(1, 0, 0, 1)),
            Vertex(position: float4(midX - 250, midY - 250, 0, 1), color: float4(0, 1, 0, 1)),
            Vertex(position: float4(midX + 250, midY - 250, 0, 1), color: float4(0, 0, 1, 1)),
        ]
        
        super.init(frame: frame)
        
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        
        // 这里需要手动设置contentsScale, 否则为1
        metalLayer.contentsScale = UIScreen.main.scale
        metalLayer.drawableSize = drawableSize

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: .storageModeShared)
    
        
        // 设置从屏幕空间变化到裁剪空间的变换矩阵
        var mat = float4x4(diagonal: float4(Float(2 / drawableSize.width),
                                            Float(2 / drawableSize.height),
                                            1, 1))
        mat.columns.3.x = -1
        mat.columns.3.y = -1
        let length = MemoryLayout.stride(ofValue: mat)
        withUnsafePointer(to: &mat) {
            self.matrixBuffer = device.makeBuffer(bytes: $0,
                                                  length: length,
                                                  options: .storageModeShared)
        }
        
        // 获取vertex shader和fragment shader，用于设置render pipeline
        let library = device.makeDefaultLibrary()
        let vertexFun = library?.makeFunction(name: "helloTriangleShader")
        let fragmentFun = library?.makeFunction(name: "helloTriangleFragment")
        
        // 创建render pipeline
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFun
        pipelineDesc.fragmentFunction = fragmentFun
        pipelineDesc.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        // 创建commandQueue
        commandQueue = device.makeCommandQueue()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var displayLink: CADisplayLink?
    
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
        // 获取下一个空闲的texture，当作渲染目标
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        
        let texture = drawable.texture
        
        // 设置render pass
        let passDesc = MTLRenderPassDescriptor()
        passDesc.colorAttachments[0].texture = texture
        passDesc.colorAttachments[0].loadAction = .clear
        passDesc.colorAttachments[0].storeAction = .store
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc)
        
        encoder?.setRenderPipelineState(pipelineState)
        
        // 给shader vertex传入参数
        encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder?.setVertexBuffer(matrixBuffer, offset: 0, index: 1)
        
        // 调用draw call，绘制三角形
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder?.endEncoding()
        
        // 尽可能早的展示绘制内容
        commandBuffer.present(drawable)
        
        // 提交commandBuffer，commandBuffer提交后就不能继续使用了
        commandBuffer.commit()
    }
}
