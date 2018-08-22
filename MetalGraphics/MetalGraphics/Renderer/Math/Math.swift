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
        x.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        x.y = 
        var y = float4()
        var z = float4()
        var w = float4()

        
        let mat = float4x4(x, y, z, w)
        return mat
    }
}
