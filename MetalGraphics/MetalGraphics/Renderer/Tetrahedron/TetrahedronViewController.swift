//
//  TetrahedronViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/3.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import MetalKit
import Metal

class TetrahedronViewController: BaseViewController {
    var mtkView: MTKView!
    var device: MTLDevice!
    var renderer: TetrahedronRenderer!
    
    override func loadView() {
        device = MTLCreateSystemDefaultDevice()
        mtkView = MTKView(frame: UIScreen.main.bounds, device: device)
        self.view = mtkView
    }
    
    override func viewDidLoad() {
        self.renderer = TetrahedronRenderer(mtkView: mtkView)

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        view.addGestureRecognizer(gesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "line",
                                                            style: .plain, target: self,
                                                            action: #selector(rightBarItemTapped(_:)))
        
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
    
    @objc func rightBarItemTapped(_ sender: UIBarButtonItem) {
        renderer.isDrawLine.toggle()
        sender.title = renderer.isDrawLine ? "line" : "fill"
    }
}
