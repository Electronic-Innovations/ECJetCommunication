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
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// https://gist.github.com/totocaster/3a1f008c780793b86a6c4d2d6ae735c4
extension String {
    func sanitized() -> String {
        // see for ressoning on charachrer sets https://superuser.com/a/358861
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
            .union(.newlines)
            .union(.illegalCharacters)
            .union(.controlCharacters)
        
        return self
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
    }
    
    mutating func sanitize() -> Void {
        self = self.sanitized()
    }
    
    func whitespaceCondenced() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    mutating func condenceWhitespace() -> Void {
        self = self.whitespaceCondenced()
    }
}

//https://stackoverflow.com/questions/29835242/whats-the-simplest-way-to-convert-from-a-single-character-string-to-an-ascii-va
extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
