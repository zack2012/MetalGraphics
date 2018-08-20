//
//  HelloTriangleViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/18.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit

class HelloTriangleViewController: BaseViewController  {

    override func loadView() {
        view = HelloTriangleView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
