//
//  MetalViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import GSMath

class MetalViewController: BaseViewController {
    var mtkView: MTKView!
    var device: MTLDevice!
    var renderer: Renderer!
    
    override func loadView() {
        device = MTLCreateSystemDefaultDevice()
        mtkView = MTKView(frame: UIScreen.main.bounds, device: device)
        self.view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderer = renderClass.init(mtkView: mtkView)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        guard let renderer = self.renderer else {
            return
        }
        
        let point = sender.translation(in: view)
        let deltaX = renderer.rotationX + Float(point.x.radian)
        let deltaY = renderer.rotationY + Float(point.y.radian)
        renderer.rotationX = deltaX
        renderer.rotationY = deltaY
        sender.setTranslation(.zero, in: self.view)
    }
    
    var renderClass: Renderer.Type {
        fatalError()
    }
}
