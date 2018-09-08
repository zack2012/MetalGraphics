//
//  SphereViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/7.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit

class SphereViewController: MetalViewController {
    private var transitionDelegate: AlertTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "参数调整",
                                                            style: .plain, target: self,
                                                            action: #selector(rightButtonTapped(_:)))
        mtkView.preferredFramesPerSecond = 30
    }
    
    override var renderClass: Renderer.Type {
        return SphereRenderer.self
    }
    
    @objc private func rightButtonTapped(_ sender: UIBarButtonItem) {
        guard let renderer = self.renderer as? SphereRenderer else {
            return
        }
        
        let sp = SphereParameterViewController()
        sp.currentIteration = renderer.iteration
        sp.currentType = renderer.primitiveType
        
        sp.update = { (iteration, type) -> Void in
            renderer.primitiveType = type
            renderer.iteration = iteration
            renderer.makeBuffer(n: iteration)
        }
        
        let vc = UINavigationController(rootViewController: sp)
        let delegate = AlertTransitioningDelegate()
        let presentMaxWidth: CGFloat = SphereViewController.presentMaxWidth
        delegate.originFrame = CGRect(x: self.view.bounds.midX - presentMaxWidth / 2,
                                      y: self.view.bounds.maxY,
                                      width: presentMaxWidth,
                                      height: 240)
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
