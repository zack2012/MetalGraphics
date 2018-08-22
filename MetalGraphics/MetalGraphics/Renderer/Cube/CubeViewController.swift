//
//  CubeViewController.swift
//  MetalGraphics
//
//  Created by zack on 2018/8/20.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit

class CubeViewController: BaseViewController {

    var renderer: CubeRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cubeView = CubeView(frame: view.bounds)
        renderer = CubeRenderer(device: cubeView.metalLayer.device!)
        cubeView.delegate = renderer
        view.addSubview(cubeView)
    }

}
