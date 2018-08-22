//
//  CubeView.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/21.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal

protocol CubeViewDelegate: class {
    func drawInView(_ view: CubeView)
}

class CubeView: UIView {
    var depthTexture: MTLTexture?
    
    var colorPixelFormat: MTLPixelFormat {
        get {
            return metalLayer.pixelFormat
        }
        
        set {
            metalLayer.pixelFormat = newValue
        }
    }
    
    var preferredFramesPerSecond = 60
    
    weak var delegate: CubeViewDelegate?
    
    private var displayLink: CADisplayLink?
    
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.device = MTLCreateSystemDefaultDevice()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            var scale = UIScreen.main.scale
            
            if let window = self.window {
                scale = window.screen.scale
            }
            
            let drawableSize = bounds.size.applying(CGAffineTransform(scaleX: scale, y: scale))
            metalLayer.drawableSize = drawableSize
            
            makeDepthTexture()
        }
    }
    
    private func makeDepthTexture() {
        let drawableSize = metalLayer.drawableSize
        let width = Int(drawableSize.width)
        let height = Int(drawableSize.height)
        
        if self.depthTexture == nil || self.depthTexture!.width != width ||
            self.depthTexture!.height != height {
            let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                width: width,
                                                                height: height,
                                                                mipmapped: false)
            desc.usage = .renderTarget
            self.depthTexture = self.metalLayer.device?.makeTexture(descriptor: desc)
        }
    }
    
    override func didMoveToWindow() {
        
        displayLink?.invalidate()
        
        if window != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
            displayLink?.preferredFramesPerSecond = self.preferredFramesPerSecond
            displayLink?.add(to: .main, forMode: .common)
        } else {
            displayLink = nil
        }
    }
    
    @objc private func displayLinkDidFire(_ sender: CADisplayLink) {
        delegate?.drawInView(self)
    }
    
    func frameDuration() -> TimeInterval {
        return displayLink?.duration ?? 0
    }
    
    func renderPass() -> (desc: MTLRenderPassDescriptor, drawable: CAMetalDrawable?) {
        let drawable = metalLayer.nextDrawable()
        let passDesc = MTLRenderPassDescriptor()
        passDesc.colorAttachments[0].texture = drawable?.texture
        passDesc.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        passDesc.colorAttachments[0].loadAction = .clear
        passDesc.colorAttachments[0].storeAction = .store
        
        passDesc.depthAttachment.texture = self.depthTexture
        passDesc.depthAttachment.clearDepth = 1
        passDesc.depthAttachment.loadAction = .clear
        passDesc.depthAttachment.storeAction = .dontCare
        
        return (passDesc, drawable)
    }
}
