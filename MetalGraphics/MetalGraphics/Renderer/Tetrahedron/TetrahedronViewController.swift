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

class TetrahedronViewController: MetalViewController {
    override func viewDidLoad() {
       super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "line",
                                                            style: .plain, target: self,
                                                            action: #selector(rightBarItemTapped(_:)))
        
    }
    
    @objc func rightBarItemTapped(_ sender: UIBarButtonItem) {
        guard let renderer = self.renderer as? TetrahedronRenderer else {
            return
        }
        renderer.isDrawLine.toggle()
        sender.title = renderer.isDrawLine ? "line" : "fill"
    }
    
    override var renderClass: Renderer.Type {
        return TetrahedronRenderer.self
    }
}
