//
//  SphereParameterViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
import Metal

class SphereParameterViewController: UIViewController {
    private var label: UILabel!
    private var slider: UISlider!

    var update: ((Int, MTLPrimitiveType) -> Void)?
    var currentIteration = 0
    var currentType: MTLPrimitiveType = .line

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel(_:)))
        
        let presentMaxWidth = SphereViewController.presentMaxWidth
        label = UILabel(frame: .zero)
        label.text = "迭代次数: \(currentIteration)"
        label.sizeToFit()
        label.frame.size.width = presentMaxWidth
        label.frame.origin = CGPoint(x: 15, y: 10 + 44)
        view.addSubview(label)
        
        slider = UISlider(frame: CGRect(x: label.frame.origin.x,
                                        y: label.frame.maxY + 16,
                                        width: presentMaxWidth - label.frame.origin.x * 2,
                                        height: 10))
        slider.minimumValue = 0
        slider.maximumValue = 8
        slider.value = Float(currentIteration)
        slider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        let segment = UISegmentedControl(items: ["line", "lineStrip", "triangle", "triangleStrip"])
        segment.sizeToFit()
        segment.frame.origin.x = label.frame.origin.x
        segment.frame.origin.y = slider.frame.maxY + 24
        segment.frame.size.width = slider.frame.width
        segment.selectedSegmentIndex = Int(self.currentType.rawValue - 1)
        segment.addTarget(self, action: #selector(segmentChange(_:)), for: .valueChanged)
        view.addSubview(segment)
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func sliderChange(_ sender: UISlider) {
        let iteration = Int(sender.value)
        label.text = "迭代次数: \(iteration)"
        update?(iteration, currentType)
    }
    
    @objc private func segmentChange(_ sender: UISegmentedControl) {
        let iteration = Int(slider.value)
        currentType = MTLPrimitiveType(rawValue: UInt(sender.selectedSegmentIndex + 1))!
        update?(iteration, currentType)
    }
}
