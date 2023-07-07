//
//  ECJetDataStructures.swift
//  
//
//  Created by Daniel Pink on 7/7/2023.
//

import Foundation

enum ValueError: Error {
    case encodingValueError
    case setTriggerRepeatError
    case incorrectNumberOfBytesError
}

// https://oleb.net/blog/2018/03/making-illegal-states-unrepresentable/

typealias ThreeUInt8 = (UInt8, UInt8, UInt8)

// MARK: Get Print Width 0x02
public struct PrintWidth: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8)
    
    public var tuple: (UInt8, UInt8, UInt8) { return data }
    public var bytes: [UInt8] { return [data.0, data.1, data.2] }
    public var mm: Double { return (0.256 * Double(data.1)) + (0.001 * Double(data.0)) }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 3 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2])
    }
    
    public init(tuple: (UInt8, UInt8, UInt8)) {
        // Needs to only accept three bytes
        self.data = tuple
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        precondition(value < (256 * 0.256), "encodePrintWidth value (\(value)) is too large")
        let q1 = (value / 0.256).rounded(.towardZero)
        let r = value.truncatingRemainder(dividingBy: 0.256)
        let q2 = (r / 0.001).rounded(.toNearestOrAwayFromZero)
        //print("\(value),\(q1),\(r),\(q2)")
        //self.data = [UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1]
        self.data = (UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Delay 0x04
public struct PrintDelay: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public var bytes: [UInt8] { return [data.0, data.1, data.2, data.3, data.4] }
    public var mm: Double {
        let value: Double = (16777.216 * Double(self.data.3))
                             + (65.536 * Double(self.data.2))
                              + (0.256 * Double(self.data.1))
                              + (0.001 * Double(self.data.0))
        return value
    }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4])
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        self.data = (UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Interval 0x06
public struct PrintInterval: CustomStringConvertible {
    private let data: (UInt8, UInt8, UInt8, UInt8, UInt8)
    public var bytes: [UInt8] { return [data.0, data.1, data.2, data.3, data.4] }
    public var mm: Double {
        let value: Double = (16777.216 * Double(self.data.3))
                             + (65.536 * Double(self.data.2))
                              + (0.256 * Double(self.data.1))
                              + (0.001 * Double(self.data.0))
        return value
    }
    
    public var description: String {
        return "\(String(format: "%.2f", self.mm))mm"
    }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        self.data = (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4])
    }
    
    public init(mm value: Double) throws {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        self.data = (UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1)
    }
}

// MARK: Get Print Height 0x08
public struct PrintHeight: CustomStringConvertible {
    private let data: UInt8
    public var bytes: [UInt8] { return [data] }
    public var mm: Double { return Double(self.data) } // TODO: Probably a scaling factor
    public var description: String { return "\(String(format: "%.2f", self.mm))mm" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        self.data = bytes[0]
    }
    
    public init(mm value: Double) throws {
        self.data = UInt8(value) // TODO: Scaling and/or rounding likely required
    }
}

// MARK: Get Print Count 0x0A
// The 5-byte data structure is as follows:
// [CountType] 1 byte count type
//      - 0 represents the total print count of the printhead
//      - 1 represents the printing data printing count
//      - 2 represents editing data printing count
// [PrintCount] 4 bytes print count value

public struct PrintCount: CustomStringConvertible {
    
    public enum CountType: Int {
        case total = 0
        case printingData = 1
        case editingData = 2
    }
    public let type: CountType
    public let count: UInt32
    
    public var description: String { return "\(self.count)"}
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        if let type = CountType(rawValue: Int(bytes[0])) {
            self.type = type
            self.count = UInt32(bytes[1])
            + (UInt32(bytes[2]) << 8)
            + (UInt32(bytes[3]) << 16)
            + (UInt32(bytes[4]) << 24)
        } else {
            throw ValueError.encodingValueError
        }
    }
    
    public init(type: CountType, bytes: [UInt8]) throws {
        if bytes.count != 4 { throw ValueError.incorrectNumberOfBytesError }
        self.count = UInt32(bytes[0])
        + (UInt32(bytes[1]) << 8)
        + (UInt32(bytes[2]) << 16)
        + (UInt32(bytes[3]) << 24)
        self.type = type
    }
}

// MARK: Set Reverse Message 0x0B
public struct ReverseMessage: Equatable, CustomStringConvertible {
    public enum Orientation {
        case normal
        case flipped
        
        public func isNormal() -> Bool {
            switch self {
            case .normal:
                return true
            case .flipped:
                return false
            }
        }
        public func isFlipped() -> Bool {
            switch self {
            case .normal:
                return false
            case .flipped:
                return true
            }
        }
    }
    
    let horizontal: Orientation
    let vertical: Orientation
    
    public var bytes: [UInt8] { return [horizontal.isNormal() ? 0 : 1, vertical.isNormal() ? 0 : 1] }
    public var description: String { return "\(horizontal.isNormal() ? "➡️" : "⬅️")\(vertical.isNormal() ? "⬆️" : "⬇️")"}
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 2 { throw ValueError.incorrectNumberOfBytesError }
        switch bytes[0] {
        case 0:
            self.horizontal = .normal
        case 1:
            self.horizontal = .flipped
        default:
            throw ValueError.encodingValueError
        }
        
        switch bytes[1] {
        case 0:
            self.vertical = .normal
        case 1:
            self.vertical = .flipped
        default:
            throw ValueError.encodingValueError
        }
    }
}


/*
// MARK: - Decoding data inside frames
// You should have a valid frame and know what type it is. Then you can use a function from here to
// reliably decode the data.

// MARK: Set Reverse Message 0x0B
public struct ReverseSettings: Equatable {
    let horizontal: Bool
    let vertical: Bool
}

public static func setReverse(address: UInt8 = 0, horizontal: Bool, vertical: Bool, verification: VerificationMode = .crc16) -> Frame {
    return Frame(address: address, command: .setReverseMessage, data: [vertical ? 1 : 0, horizontal ? 1 : 0], verification: verification)
}

public static func setReverse(address: UInt8 = 0, settings: ReverseSettings, verification: VerificationMode = .crc16) -> Frame {
    return Frame(address: address, command: .setReverseMessage, data: [settings.vertical ? 1 : 0, settings.horizontal ? 1 : 0], verification: verification)
}

// MARK: Get Reverse Message 0x0C
public static func decodeGetReverse(_ data: [UInt8]) -> ReverseSettings {
    precondition(data.count == 2, "wrong number of bytes when decodint get reverse message")
    return ReverseSettings(horizontal: data[0] == 1 ? true : false, vertical: data[1] == 1 ? true : false)
}

// MARK: Get Trigger Repeat 0x0E
static public func decodeTriggerRepeat(data: [UInt8]) -> UInt8 {
    precondition(data.count == 1)
    return UInt8(data[0])
}

// MARK: Get Printer Status 0x0F
// MARK: Get Print Head Code 0x11
// MARK: Get Photocell Mode 0x13
// MARK: Get Jet Status 0x14
// MARK: Get System Times 0x15

// MARK: Get Date Time 0x1C

// MARK: Get Font List 0x1D
// [FontCount] 1 byte Number of fonts
// [FontNameList] An array of font names, each font name occupies 16 bytes

public func decodeGetFontList() -> [String] {
    precondition(self.command == .getFontList)
    var buffer = self.data
    let fontCount: UInt8 = buffer[0]
    precondition(self.data.count == ((Int(fontCount) * 16) + 1))
    buffer = [UInt8](buffer.dropFirst())
    
    let fontBytes = buffer.chunked(into: 16)
    precondition(fontBytes.count == fontCount)
    
    let fontList = fontBytes.map{ bytes in
        var font = ""
        if let f = String(bytes: bytes, encoding: .utf8) {
            font = f.sanitized().whitespaceCondenced()
        }
        return font
    }
    
    return fontList
}


// MARK: Get Message List 0x1E
// [FileCount] 2 bytes Number of message
// [FilleNameList] array of file names, each file name occupies 32 bytes
public func decodeGetMessageList() -> [String] {
    precondition(self.command == .getMessageList)
    var buffer = self.data
    let messageCount: UInt16 = UInt16(upper: buffer[1], lower: buffer[0])
    precondition(self.data.count == ((messageCount * 32) + 2))
    buffer = [UInt8](buffer.dropFirst(2))
    
    let messageBytes = buffer.chunked(into: 32)
    precondition(messageBytes.count == messageCount)
    
    let messageList = messageBytes.map{ bytes in
        var message = ""
        if let m = String(bytes: bytes, encoding: .utf8) {
            message = m.sanitized().whitespaceCondenced()
        }
        return message
    }
    
    return messageList
}


// MARK: Download Remote Buffer 0x20
public static func decodeDownloadRemoteBuffer(_ data: [UInt8]) -> String? {
    switch data.count {
    case 2:
        return ""
    case 0, 1:
        return nil
    default:
        //let count = UInt16(upper: data[1], lower: data[0])
        let bytes = [UInt8](data.dropFirst(2))
        return String(bytes: bytes, encoding: .utf8)
    }
}

// MARK: Get AUX Mode 0x25
// MARK: Get Shaft Encoder Mode 0x27
// MARK: Get Reference Modulation 0x29

*/
