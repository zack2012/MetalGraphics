//
//  LightingReflectParameterViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/14.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal
import simd

class LightingReflectParameterViewController: UIViewController {
    private var viewerLabel: UILabel!
    private var exponentLabel: UILabel!
    
    private var lightSliders: [UISlider] = []
    private var materialSliders: [UISlider] = []
    
    var update: ((Viewer, Material) -> Void)?
    var viewer = Viewer(position: float4(3, 3, 10, 1))
    var material = Material(diffuse: float4(0.8, 0.3, 0.5, 1),
                            specular: float4(),
                            exponent: 32)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel(_:)))
        
        let presentMaxWidth = SphereViewController.presentMaxWidth
        viewerLabel = UILabel(frame: .zero)
        viewerLabel.text = String(format: "观察者位置: (x: %0.1f, y: %0.1f, z: %0.1f)", viewer.position.x, viewer.position.y, viewer.position.z)
        viewerLabel.sizeToFit()
        viewerLabel.frame.size.width = presentMaxWidth
        viewerLabel.frame.origin = CGPoint(x: 15, y: 10 + 44)
        view.addSubview(viewerLabel)
        
        var startOriginY = viewerLabel.frame.maxY + 8
        for i in 0 ..< 3 {
            let slider = UISlider(frame: CGRect(x: viewerLabel.frame.origin.x,
                                                y: startOriginY + 16,
                                                width: presentMaxWidth - viewerLabel.frame.origin.x * 2,
                                                height: 10))
            slider.minimumValue = -10
            slider.maximumValue = 10
            slider.value = viewer.position[i]
            slider.addTarget(self, action: #selector(lightSliderChanged(_:)), for: .valueChanged)
            lightSliders.append(slider)
            view.addSubview(slider)
            startOriginY += 50
        }
        
        exponentLabel = UILabel(frame: .zero)
        exponentLabel.text = String(format: "镜面反射系数: %u", material.exponent)
        exponentLabel.sizeToFit()
        exponentLabel.frame.size.width = presentMaxWidth
        exponentLabel.frame.origin = CGPoint(x: 15, y: startOriginY + 16)
        view.addSubview(exponentLabel)
        startOriginY += 16 + exponentLabel.frame.height
        
        for _ in 0 ..< 1 {
            let slider = UISlider(frame: CGRect(x: viewerLabel.frame.origin.x,
                                                y: startOriginY + 16,
                                                width: presentMaxWidth - viewerLabel.frame.origin.x * 2,
                                                height: 10))
            slider.minimumValue = 0
            slider.maximumValue = 500
            slider.value = Float(material.exponent)
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
        
        viewer.position[index] = sender.value
        
        viewerLabel.text = String(format: "观察者位置: (x: %0.1f, y: %0.1f, z: %0.1f)", viewer.position.x, viewer.position.y, viewer.position.z)
        
        update?(viewer, material)
    }
    
    @objc private func materialSliderChanged(_ sender: UISlider) {
        material.exponent = UInt32(sender.value)
        
        exponentLabel.text = String(format: "镜面反射系数: %u", material.exponent)
        
        update?(viewer, material)
    }
}
