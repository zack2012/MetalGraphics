//
//  LambertianViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/10.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit

class LambertianViewController: LightingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
    }
    
    @objc override func rightButtonTapped(_ sender: UIBarButtonItem) {
        guard let renderer = self.renderer as? LambertianRenderer else {
            return
        }
        
        let p = LambertianParameterViewController()
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
    
    static let presentMaxWidth: CGFloat = 320 - 16
    
    override var renderClass: Renderer.Type {
        return LambertianRenderer.self
    }
}
