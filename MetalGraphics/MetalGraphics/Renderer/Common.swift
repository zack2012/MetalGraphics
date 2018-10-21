//
//  Common.swift
//  MetalGraphics
//
//  Created by lowe on 2018/9/4.
//  Copyright © 2018 lowe. All rights reserved.
//

import UIKit
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

func importAssert(name: String,
                  bufferAllocator: MDLMeshBufferAllocator,
                  vertexDescriptor: MDLVertexDescriptor? = nil
    ) -> MDLAsset {
    let bundle = Bundle.main
    let url = bundle.url(forResource: name, withExtension: "obj")!
    return MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
}

func loadTexture(device: MTLDevice, imageName: String) throws -> MTLTexture {
//    let textureLoader = MTKTextureLoader(device: device)
//    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
//        .origin: MTKTextureLoader.Origin.bottomLeft
//    ]
//
//    let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
//
//    guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
//        fatalError()
//    }
//
//    let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
    
    let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil

    guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
        fatalError()
    }

    let image = UIImage(contentsOfFile: url.path)!
    let cgImage = image.cgImage!
    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bitsPerComponent = 8
    let bytesPerRow = cgImage.bytesPerRow
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let rawData = UnsafeMutableRawPointer.allocate(byteCount: width * height * bytesPerPixel, alignment: MemoryLayout<UInt8>.alignment)
    defer {
        rawData.deallocate()
    }

    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
    let context = CGContext(data: rawData,
                            width: width,
                            height: height,
                            bitsPerComponent: bitsPerComponent,
                            bytesPerRow: bytesPerRow,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo)!

    // 调整原点到左下角
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm_srgb, width: width, height: height, mipmapped: false)
    textureDesc.usage = .shaderRead
    
    let texture = device.makeTexture(descriptor: textureDesc)!
    
    let region = MTLRegionMake2D(0, 0, width, height)
    texture.replace(region: region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
    
    return texture
}
