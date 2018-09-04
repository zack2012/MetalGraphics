//
//  Common.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    /// 顶点位置，单位像素
    var position: float4
    
    /// 顶点颜色，RGBA
    var color: float4
}

enum GraphicsError: Error {
    case isNil(message: String)
}
