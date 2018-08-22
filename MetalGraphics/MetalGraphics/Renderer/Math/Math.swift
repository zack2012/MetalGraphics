//
//  Math.swift
//  MetalGraphics
//
//  Created by zack on 2018/8/22.
//  Copyright © 2018 lowe. All rights reserved.
//

import simd
import Darwin

public enum Math {
    public static func matrixRotation(axis: float3, angle: Float) -> float4x4 {
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
    
    public static func matrixScale(_ scale: Float) -> float4x4 {
        return matrixScale(xScale: scale, yScale: scale, zScale: scale)
    }
    
    public static func matrixScale(xScale: Float, yScale: Float, zScale: Float) -> float4x4 {
        let x = float4(xScale, 0, 0, 0)
        let y = float4(0, yScale, 0, 0)
        let z = float4(0, 0, zScale, 0)
        let w = float4(0, 0, 0, 1)
        return float4x4(x, y, z, w)
    }
    
    public static func matrixTranslate(x: Float, y: Float, z: Float) -> float4x4 {
        let xx = float4(1, 0, 0, 0)
        let yy = float4(0, 1, 0, 0)
        let zz = float4(0, 0, 1, 0)
        let ww = float4(x, y, z, 1)
        return float4x4(xx, yy, zz, ww)
    }
}
