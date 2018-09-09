//
//  GSMathTests.swift
//  GSMathTests
//
//  Created by lowe on 2018/9/8.
//  Copyright © 2018 lowe. All rights reserved.
//

import XCTest
@testable import GSMath
import simd

class GSMathTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private func assertEqual<T: BinaryFloatingPoint>(_ x: T, _ y: T) {
        let accuracy = T.init(0.00001)
        XCTAssertEqual(x, y, accuracy: accuracy)
    }
    
    private func assertEqual(_ x: float2, _ y: float2) {
        assertEqual(x.x, y.x)
        assertEqual(x.y, y.y)
    }
    
    private func assertEqual(_ x: float3, _ y: float3) {
        assertEqual(x.x, y.x)
        assertEqual(x.y, y.y)
        assertEqual(x.z, y.z)
    }
    
    private func assertEqual(_ x: float4, _ y: float4) {
        assertEqual(x.x, y.x)
        assertEqual(x.y, y.y)
        assertEqual(x.z, y.z)
        assertEqual(x.w, y.w)
    }
    
    func testSimd() {
        let f2 = float2(1.1, 2.2)
        let t2 = float2(3.3, 4.4)
        assertEqual(f2.dot(t2), 13.31)
        assertEqual(f2.normalize, float2(0.4472136, 0.8944272))
        
        let f3 = float3(x: 1.1, y: 1.2, z: 1.3)
        let t3 = float3(x: 2.1, y: 2.2, z: 2.3)
        assertEqual(f3.cross(t3), float3(-0.1, 0.2, -0.1))
        assertEqual(f3.xy, float2(1.1, 1.2))
        assertEqual(f3.yz, float2(1.2, 1.3))
        assertEqual(f3.dot(t3), 7.94)
        assertEqual(f3.normalize, float3(0.528017, 0.576018, 0.62402))

        let f4 = float4(x: 1.1, y: 1.2, z: 1.3, w: 1.4)
        let t4 = float4(x: 3.1, y: 3.2, z: 3.3, w: 3.4)
        assertEqual(f4.xy, float2(1.1, 1.2))
        assertEqual(f4.yz, float2(1.2, 1.3))
        assertEqual(f4.xyz, float3(1.1, 1.2, 1.3))
        assertEqual(f4.dot(t4), 16.3)
        assertEqual(f4.cross(t4), simd_make_float4(float3(-0.2, 0.4, -0.2), 1))
        assertEqual(f4.normalize, float4(0.43825, 0.478091, 0.517932, 0.557773))
    }
    
    func testNormalizePerformance() {
        let f3 = float3(x: 1.1, y: 1.2, z: 1.3)
        self.measure {
            for _ in 0 ..< 10000000 {
                let _ = f3.normalize
            }
        }
    }
    
    func testCross() {
        let f3 = float3(x: 1.1, y: 1.2, z: 1.3)
        let t3 = float3(x: 2.1, y: 2.2, z: 2.3)
        self.measure {
            for _ in 0 ..< 10000000 {
                let _ = f3.cross(t3)
//                let _ = simd_cross(f3, t3)
            }
        }
    }
}
