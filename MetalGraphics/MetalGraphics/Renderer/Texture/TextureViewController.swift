//
//  TextureViewController.swift
//  MetalGraphics
//
//  Created by lowe on 2018/10/20.
//  Copyright © 2018 lowe. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class TextureViewController: MetalViewController {
    override var renderClass: Renderer.Type {
        return TextureRenderer.self
    }
}
