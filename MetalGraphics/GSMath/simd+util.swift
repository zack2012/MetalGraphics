//
//  simd+util.swift
//  GSMath
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import simd

public extension float2 {
    var normalize: float2 {
        return simd_normalize(self)
    }
    
    func dot(_ other: float2) -> Float {
        return simd_dot(self, other)
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
        return simd_dot(self, other)
    }
    
    func cross(_ other: float3) -> float3 {
        return simd_cross(self, other)
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
        return simd_dot(self, other)
    }
    
    func cross(_ other: float4) -> float4 {
        return simd_make_float4(self.xyz.cross(other.xyz), 1)
    }
}
