//
//  ViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/8/18.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit

private let chapterCellIdentifier = "ChapterCell"
private let cellHeight: CGFloat = 44

class ViewController: UIViewController {
    var tableView: UITableView!
    
    private var models: [SectionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildModels()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ChapterCell.self, forCellReuseIdentifier: chapterCellIdentifier)
        
        view.addSubview(tableView)
    }
    
    private func buildModels() {
        var model = SectionModel(header: "图形学的 Hello World", footer: nil,
                                 content: ["Draw a Triangle"],
                                 viewControllerClasses: [HelloTriangleViewController.self])
        models.append(model)
        
        model.header = "坐标变换"
        model.content = ["Draw a cube"]
        model.viewControllerClasses = [CubeViewController.self]
        models.append(model)
        
        model.header = "光照"
        model.content = ["Blinn-Phong Lighting Model"]
        model.viewControllerClasses = [LightingViewController.self]
        models.append(model)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chapterCellIdentifier, for: indexPath) as! ChapterCell
        
        cell.chapterLabel.text = models[indexPath.section].content[indexPath.row]
        cell.chapterLabel.sizeToFit()
        cell.chapterLabel.frame.origin = CGPoint(x: 16, y: cellHeight / 2 - cell.chapterLabel.bounds.midY)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return models[section].footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let clz = models[indexPath.section].viewControllerClasses[indexPath.row]
        let vc = clz.init(nibName: nil, bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController {
    private struct SectionModel {
        var header: String?
        var footer: String?
        var content: [String]
        var viewControllerClasses: [BaseViewController.Type]
    }
}
