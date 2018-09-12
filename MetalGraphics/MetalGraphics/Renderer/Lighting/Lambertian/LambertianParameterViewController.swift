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
    private var lightLabel: UILabel!
    private var diffuseLabel: UILabel!

    private var lightSliders: [UISlider] = []
    private var materialSliders: [UISlider] = []
    
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
        lightLabel = UILabel(frame: .zero)
        lightLabel.text = String(format: "光源位置: (x: %0.1f, y: %0.1f, z: %0.1f)", pointLight.position.x, pointLight.position.y, pointLight.position.z)
        lightLabel.sizeToFit()
        lightLabel.frame.size.width = presentMaxWidth
        lightLabel.frame.origin = CGPoint(x: 15, y: 10 + 44)
        view.addSubview(lightLabel)
        
        var startOriginY = lightLabel.frame.maxY + 8
        for i in 0 ..< 3 {
            let slider = UISlider(frame: CGRect(x: lightLabel.frame.origin.x,
                                                y: startOriginY + 16,
                                                width: presentMaxWidth - lightLabel.frame.origin.x * 2,
                                                height: 10))
            slider.minimumValue = -10
            slider.maximumValue = 10
            slider.value = pointLight.position[i]
            slider.addTarget(self, action: #selector(lightSliderChanged(_:)), for: .valueChanged)
            lightSliders.append(slider)
            view.addSubview(slider)
            startOriginY += 50
        }
        
        
        diffuseLabel = UILabel(frame: .zero)
        diffuseLabel.text = String(format: "diffuse: (x: %0.1f, y: %0.1f, z: %0.1f)", material.diffuse.x, material.diffuse.y, material.diffuse.z)
        diffuseLabel.sizeToFit()
        diffuseLabel.frame.size.width = presentMaxWidth
        diffuseLabel.frame.origin = CGPoint(x: 15, y: startOriginY + 16)
        view.addSubview(diffuseLabel)
        startOriginY += 16 + diffuseLabel.frame.height
        
        for i in 0 ..< 3 {
            let slider = UISlider(frame: CGRect(x: lightLabel.frame.origin.x,
                                                y: startOriginY + 16,
                                                width: presentMaxWidth - lightLabel.frame.origin.x * 2,
                                                height: 10))
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.value = material.diffuse[i]
            slider.addTarget(self, action: #selector(materialSliderChanged(_:)), for: .valueChanged)
            materialSliders.append(slider)
            view.addSubview(slider)
            startOriginY += 50
        }
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func lightSliderChanged(_ sender: UISlider) {
        guard let index = lightSliders.index(of: sender) else {
            return
        }
        
        pointLight.position[index] = sender.value
        
        lightLabel.text = String(format: "光源位置: (x: %0.1f, y: %0.1f, z: %0.1f)", pointLight.position.x, pointLight.position.y, pointLight.position.z)
        
        update?(pointLight, material)
    }
    
    @objc private func materialSliderChanged(_ sender: UISlider) {
        guard let index = materialSliders.index(of: sender) else {
            return
        }
        
        material.diffuse[index] = sender.value
        
        diffuseLabel.text = String(format: "diffuse: (x: %0.1f, y: %0.1f, z: %0.1f)", material.diffuse.x, material.diffuse.y, material.diffuse.z)
        
        update?(pointLight, material)
    }
    
}
