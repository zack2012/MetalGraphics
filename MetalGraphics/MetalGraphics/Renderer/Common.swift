//
//  Common.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Foundation
import simd

protocol QueryMemoryLayout {
    static var memoryStride: Int { get }
}

extension QueryMemoryLayout {
    static var memoryStride: Int {
        return MemoryLayout<Self>.stride
    }
}

extension Collection where Element: QueryMemoryLayout {
    var memoryStride: Int {
        return MemoryLayout<Element>.stride * count
    }
}

extension Float: QueryMemoryLayout {}
extension UInt16: QueryMemoryLayout {}

struct Vertex: QueryMemoryLayout {
    /// 顶点位置，单位像素
    var position: float4
    
    /// 顶点颜色，RGBA
    var color: float4
}

struct Uniforms: QueryMemoryLayout {
    var modelViewProjectionMatrix: float4x4
}

enum GraphicsError: Error {
    case isNil(message: String)
}
