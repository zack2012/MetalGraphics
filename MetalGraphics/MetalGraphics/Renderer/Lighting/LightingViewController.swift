//
//  LightingViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/3.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import MetalKit
import Metal

class LightingViewController: BaseViewController {
    var mtkView: MTKView!
    var device: MTLDevice!
    var renderer: LightingRenderer!
    
    override func loadView() {
        device = MTLCreateSystemDefaultDevice()
        let mtkView = MTKView(frame: UIScreen.main.bounds, device: device)
        self.view = mtkView
        self.renderer = LightingRenderer(mtkView: mtkView)
    }
}
