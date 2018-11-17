//
//  File.swift
//  GSMath
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import simd
import QuartzCore

public extension Double {
    var radian: Float {
        return Float(self) * .pi / 180
    }
}

public extension Int {
    var radian: Float {
        return Float(self) * .pi / 180
    }
}

public extension CGFloat {
    var radian: Float {
        return Float(self) * .pi / 180
    }
}

public extension float2 {
    var normalize: float2 {
        return simd.normalize(self)
    }
    
    func dot(_ other: float2) -> Float {
        return simd.dot(self, other)
    }
}

public extension float3 {
    var normalize: float3 {
        return simd_normalize(self)
    }
    
    var xy: float2 {
        return simd_make_float2(self)
    }
    
    var yz: float2 {
        return simd_make_float2(y, z)
    }
    
    func dot(_ other: float3) -> Float {
        return simd.dot(self, other)
    }
    
    func cross(_ other: float3) -> float3 {
        return simd.cross(self, other)
    }
}

public extension float4 {
    var normalize: float4 {
        return simd_normalize(self)
    }
    
    var xy: float2 {
        return simd_make_float2(self)
    }
    
    var yz: float2 {
        return simd_make_float2(y, z)
    }
    
    var xyz: float3 {
        return simd_make_float3(self)
    }
    
    func dot(_ other: float4) -> Float {
        return simd.dot(self, other)
    }
    
    func cross(_ other: float4) -> float4 {
        return simd_make_float4(self.xyz.cross(other.xyz), 1)
    }
}

// Mark - Matrix
public func rotation(axis: float3, angle: Float) -> float4x4 {
    let c = cos(angle)
    let s = sin(angle)
    
    var x = float4()
    x.x = c + (1 - c) * axis.x * axis.x
    x.y = (1 - c) * axis.x * axis.y + s * axis.z
    x.z = (1 - c) * axis.x * axis.z - s * axis.y
    x.w = 0
    
    var y = float4()
    y.x = (1 - c) * axis.x * axis.y - s * axis.z
    y.y = c + (1 - c) * axis.y * axis.y
    y.z = (1 - c) * axis.y * axis.z + s * axis.x
    y.w = 0
    
    var z = float4()
    z.x = (1 - c) * axis.x * axis.z + s * axis.y
    z.y = (1 - c) * axis.y * axis.z - s * axis.x
    z.z = c + (1 - c) * axis.z * axis.z
    z.w = 0
    
    let w = float4(0, 0, 0, 1)
    
    let mat = float4x4(x, y, z, w)
    return mat
}

public extension float3x3 {
    /// 法线变换矩阵
    var normalMatrix: float3x3 {
        return inverse.transpose
    }
}

public extension float4x4 {
    var upperLeft: float3x3 {
        return float3x3(columns.0.xyz, columns.1.xyz, columns.2.xyz)
    }
    
    /// 法线变换矩阵
    var normalMatrix: float3x3 {
        return upperLeft.normalMatrix
    }
}

public func scale(_ unifyScale: Float) -> float4x4 {
    return scale(xScale: unifyScale, yScale: unifyScale, zScale: unifyScale)
}

public func scale(xScale: Float, yScale: Float, zScale: Float) -> float4x4 {
    let x = float4(xScale, 0, 0, 0)
    let y = float4(0, yScale, 0, 0)
    let z = float4(0, 0, zScale, 0)
    let w = float4(0, 0, 0, 1)
    return float4x4(x, y, z, w)
}

public func translate(x: Float, y: Float, z: Float) -> float4x4 {
    let xx = float4(1, 0, 0, 0)
    let yy = float4(0, 1, 0, 0)
    let zz = float4(0, 0, 1, 0)
    let ww = float4(x, y, z, 1)
    return float4x4(xx, yy, zz, ww)
}

public func perspective(aspect: Float, fovy: Float, near: Float, far: Float) -> float4x4 {
    let yScale = 1 / tan(fovy * 0.5)
    
    // 这里除以apsect是为了保证如果在clip space里的坐标相等，则在屏幕上显示时也应该相等，不受屏幕aspect的影响
    let xScale = yScale / aspect
    
    // Metal里NDC z轴的取值范围是[0,1]
    let zRange = far - near
    let zScale = -far / zRange
    let wz = -far * near / zRange
    
    let p = float4(xScale, 0, 0, 0)
    let q = float4(0, yScale, 0, 0)
    let r = float4(0, 0, zScale, -1)
    let s = float4(0, 0, wz, 0)
    
    return float4x4(p, q, r, s)
}

public func ortho(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> float4x4 {
    let x = float4(2 / (right - left), 0, 0, 0)
    let y = float4(0, 2 / (top - bottom), 0, 0)
    
    // Metal里NDC z轴的取值范围是[0,1]
    let z = float4(0, 0, 1 / (near - far), 0)
    let w: float4 = [
        (left + right) / (left - right),
        (bottom + top) / (bottom - top),
        near / (near - far),
        1
    ]
    
    return float4x4(x, y, z, w)
}
