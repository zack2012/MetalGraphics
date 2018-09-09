//
//  LightingViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class LightingViewController: MetalViewController {
    
    override var renderClass: Renderer.Type {
        return LightingRenderer.self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.preferredFramesPerSecond = 30
    }
}
