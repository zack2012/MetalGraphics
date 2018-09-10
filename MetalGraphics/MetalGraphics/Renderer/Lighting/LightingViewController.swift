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
    var transitionDelegate: AlertTransitioningDelegate?

    override var renderClass: Renderer.Type {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.preferredFramesPerSecond = 30
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "参数调整",
                                                            style: .plain, target: self,
                                                            action: #selector(rightButtonTapped(_:)))
    }
    
    @objc func rightButtonTapped(_ sender: UIBarButtonItem) {
       
    }
}
