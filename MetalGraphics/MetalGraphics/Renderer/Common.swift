//
//  Common.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import Foundation
import simd
import MetalKit

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

struct Vertex: QueryMemoryLayout, CustomStringConvertible {
    /// 顶点位置，单位像素
    var position: float4
    
    /// 顶点颜色，RGBA
    var color: float4
    
    var description: String {
        var str = ""
        print("position: \(position), color: \(color)", to: &str)
        return str
    }
}

extension Vertex {
    static func + (lhs: Vertex, rhs: Vertex) -> Vertex {
        let position = lhs.position + rhs.position
        let color = lhs.color + rhs.color
        return Vertex(position: float4(position.x, position.y, position.z, 1),
                      color: float4(color.x, color.y, color.z, 1))
    }
    
    func normalize() -> Vertex {
        let position3 = self.position.xyz.normalize
        let color3 = self.color.xyz.normalize
        return Vertex(position: simd_make_float4(position3, 1),
                      color: simd_make_float4(color3, 1))
    }
}

struct Uniforms: QueryMemoryLayout {
    var mvp: float4x4
    var world: float4x4
    var normal: float3x3
    
    init(mvp: float4x4, world: float4x4 = float4x4(), normal: float3x3 = float3x3()) {
        self.mvp = mvp
        self.world = world
        self.normal = normal
    }
}

struct Material: QueryMemoryLayout {
    var diffuse: float4
    var specular: float4
    var exponent: UInt32 = 0
}

struct PointLight: QueryMemoryLayout {
    var position: float4
    var intensity: float4
}

struct Viewer: QueryMemoryLayout {
    var position: float4
}

enum GraphicsError: Error {
    case isNil(message: String)
}

extension MTLRenderCommandEncoder {
    func encode(callback: (MTLRenderCommandEncoder) -> Void) {
        callback(self)
        endEncoding()
    }
}
