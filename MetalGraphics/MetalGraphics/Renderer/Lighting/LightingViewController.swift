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
        return LightingRenderer.self
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
                                       action: #selector(rightLeftButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [barItem1,  barItem2]
    }
    
    @objc func rightButtonTapped(_ sender: UIBarButtonItem) {
        guard let renderer = self.renderer as? LightingRenderer else {
            return
        }
        
        let p = LightingParameterViewController()
        p.pointLight = renderer.pointLight
        p.material = renderer.material
        
        p.update = { (pointLight, material) -> Void in
            renderer.pointLight = pointLight
            renderer.material = material
        }
        
        let vc = UINavigationController(rootViewController: p)
        let delegate = AlertTransitioningDelegate()
        let presentMaxWidth: CGFloat = SphereViewController.presentMaxWidth
        delegate.originFrame = CGRect(x: self.view.bounds.midX - presentMaxWidth / 2,
                                      y: self.view.bounds.maxY,
                                      width: presentMaxWidth,
                                      height: 320)
        delegate.targetFrame = CGRect(x: delegate.originFrame.origin.x,
                                      y: 120,
                                      width: delegate.originFrame.width,
                                      height: delegate.originFrame.height)
        transitionDelegate = delegate
        vc.transitioningDelegate = delegate
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true, completion: nil)
    }
    
    @objc func rightLeftButtonTapped(_ sender: UIBarButtonItem) {
        guard let renderer = self.renderer as? LightingRenderer else {
            return
        }
        
        let p = LightingReflectParameterViewController()
        p.viewer = renderer.viewer
        p.material = renderer.material
        
        p.update = { (viewer, material) -> Void in
            renderer.viewer = viewer
            renderer.material = material
        }
        
        let vc = UINavigationController(rootViewController: p)
        vc.navigationBar.layer.cornerRadius = 5
        vc.navigationBar.clipsToBounds = true
        let delegate = AlertTransitioningDelegate()
        let presentMaxWidth: CGFloat = SphereViewController.presentMaxWidth
        delegate.originFrame = CGRect(x: self.view.bounds.midX - presentMaxWidth / 2,
                                      y: self.view.bounds.maxY,
                                      width: presentMaxWidth,
                                      height: 500)
        delegate.targetFrame = CGRect(x: delegate.originFrame.origin.x,
                                      y: 120,
                                      width: delegate.originFrame.width,
                                      height: delegate.originFrame.height)
        transitionDelegate = delegate
        vc.transitioningDelegate = delegate
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true, completion: nil)
    }
    
    static let presentMaxWidth: CGFloat = 320 - 16
}
