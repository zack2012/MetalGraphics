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
    var cubeView: CubeView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cubeView = CubeView(frame: view.bounds)
        renderer = CubeRenderer(device: cubeView.metalLayer.device!)
        cubeView.delegate = renderer
        view.addSubview(cubeView)
        self.cubeView = cubeView
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        cubeView.addGestureRecognizer(gesture)
    }

    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        guard let renderer = self.renderer else {
            return
        }
        
        let point = sender.translation(in: cubeView)
        let deltaX = renderer.rotationX + Float(point.x.radian)
        let deltaY = renderer.rotationY + Float(point.y.radian)
        renderer.rotationX = deltaX
        renderer.rotationY = deltaY
        sender.setTranslation(.zero, in: self.cubeView)
    }
}
