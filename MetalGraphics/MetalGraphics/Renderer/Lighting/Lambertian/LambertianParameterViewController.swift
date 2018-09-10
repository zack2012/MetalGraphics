//
//  LambertianParameterViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal
import simd

class LambertianParameterViewController: UIViewController {
    private var label: UILabel!
    private var slider: UISlider!

    private var lightSliders: [UISlider] = []
    
    var update: ((PointLight, Material) -> Void)?
    var pointLight = PointLight(position: float4(5, 5, 5, 1),
                                intensity: float4(1, 0.5, 0.8, 1))
    var material = Material(diffuse: float4(0.8, 0.3, 0.5, 1),
                            specular: float4())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel(_:)))
        
        let presentMaxWidth = SphereViewController.presentMaxWidth
        label = UILabel(frame: .zero)
        label.text = String(format: "光源位置: (x: %0.2f, y: %0.2f, z: %0.2f)", pointLight.position.x, pointLight.position.y, pointLight.position.z)
        label.sizeToFit()
        label.frame.size.width = presentMaxWidth
        label.frame.origin = CGPoint(x: 15, y: 10 + 44)
        view.addSubview(label)
        
        var startOriginY = label.frame.maxY + 8
        for i in 0 ..< 3 {
            let slider = UISlider(frame: CGRect(x: label.frame.origin.x,
                                                y: startOriginY + 16,
                                                width: presentMaxWidth - label.frame.origin.x * 2,
                                                height: 10))
            slider.minimumValue = -10
            slider.maximumValue = 10
            slider.value = pointLight.position[i]
            slider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
            lightSliders.append(slider)
            view.addSubview(slider)
            startOriginY += 50
        }
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func sliderChange(_ sender: UISlider) {
        guard let index = lightSliders.index(of: sender) else {
            return
        }
        
        pointLight.position[index] = sender.value
        
        label.text = String(format: "光源位置: (x: %0.1f, y: %0.1f, z: %0.1f)", pointLight.position.x, pointLight.position.y, pointLight.position.z)
        
        update?(pointLight, material)
    }
    
}
