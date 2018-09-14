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
        
        let barItem1 = UIBarButtonItem(title: "参数调整",
                                        style: .plain, target: self,
                                        action: #selector(rightButtonTapped(_:)))
        let barItem2 = UIBarButtonItem(title: "镜面反射",
                                       style: .plain,
                                       target: self,
                                       action: #selector(rightButton1Tapped(_:)))
        navigationItem.rightBarButtonItems = [barItem1,  barItem2]
    }
    
    @objc func rightButtonTapped(_ sender: UIBarButtonItem) {
       
    }
    
    @objc func rightButton1Tapped(_ sender: UIBarButtonItem) {
        
    }
}
