//
//  Extensions.swift
//  
//
//  Created by Daniel Pink on 9/5/2023.
//

import Foundation

public extension UInt16 {
    var upperByte: UInt8 {
        get {
            return UInt8(self >> 8)
        }
    }
    var lowerByte: UInt8 {
        get {
            return UInt8(self & 0x00FF)
        }
    }
    
    init(upper: UInt8, lower: UInt8) {
        // Use the `subdata` method to get a `Data` object containing the two bytes
        let byteData: [UInt8] = [lower, upper]

        // Use the `UInt16` initializer that takes two `UInt8` values to create a `UInt16` value
        self = UInt16(byteData.withUnsafeBytes { $0.load(as: UInt16.self) })
    }
}


public extension Int {
    init(bytes: [UInt8]) {
        precondition(bytes.count == 4, "Array must have exactly 4 elements")
        let value = (Int(bytes[3]) << 24) | (Int(bytes[2]) << 16) | (Int(bytes[1]) << 8) | Int(bytes[0])
        self = value
    }
}

public extension Array {
    mutating func removeFirst(_ k: Int) -> [Element] {
        var response:[Element] = []
        for _ in 0..<k {
            response.append(self.removeFirst())
        }
        return [Element](response)
    }
    
    mutating func removeLast(_ k: Int) -> [Element] {
        var response:[Element] = []
        for _ in 0..<k {
            response.append(self.removeLast())
        }
        return [Element](response).reversed()
    }
}
