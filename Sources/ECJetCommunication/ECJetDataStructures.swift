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

// MARK: Get Trigger Repeat 0x0E
// 1 byte Trigger repetition number (minimum 1)
public struct TriggerRepeat: CustomStringConvertible {
    public let count: UInt8
    public var bytes: [UInt8] { return [count] }
    public var description: String { return "\(count)" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        if bytes[0] < 1 { throw ValueError.encodingValueError }
        self.count = bytes[0]
    }
}

// MARK: Get Printer Status 0x0F
// The 5-byte data structure is as follows:
// [Working Status] 1 byte
//      - 1 jet stop
//      - 2 jet start
//      - 4 printing
// [Warning Status] 4 bytes Warning message
// 4 bytes total 32 bits, from 0 to 31 bits for warning messages 3.00 to 3.31 respectively
// For example,
// - 0001h means there is a warning message 3.00
// - 0002h indicates that there is a warning message 3.01
// - 0003h indicates that there are warning messages 3.00 and 3.01

public struct PrinterStatus: CustomStringConvertible {
    
    public enum WorkingStatus: UInt8 {
        case jetStop = 1
        case jetStart = 2
        case printing = 4
        
        func description() -> String {
            switch self {
            case .jetStop:
                return "Jet Stopped"
            case .jetStart:
                return "Jet Started"
            case .printing:
                return "Printing"
            }
        }
    }
    public let status: WorkingStatus
    public let warningStatus: UInt32
    
    public var description: String { return "\(self.status.description()), \(warningStatus)" } // TODO: warningStatus in human readable form.
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 5 { throw ValueError.incorrectNumberOfBytesError }
        if let status = WorkingStatus(rawValue: UInt8(bytes[0])) {
            self.status = status
            self.warningStatus = UInt32(bytes[1])
            + (UInt32(bytes[2]) << 8)
            + (UInt32(bytes[3]) << 16)
            + (UInt32(bytes[4]) << 24)
        } else {
            throw ValueError.encodingValueError
        }
    }
    
    public init(status: WorkingStatus, bytes: [UInt8]) throws {
        if bytes.count != 4 { throw ValueError.incorrectNumberOfBytesError }
        self.warningStatus = UInt32(bytes[0])
        + (UInt32(bytes[1]) << 8)
        + (UInt32(bytes[2]) << 16)
        + (UInt32(bytes[3]) << 24)
        self.status = status
    }
}

// MARK: Get Print Head Code 0x11
// 14 bytes print head code ASCII value For example, the print head code is
// "12108010001701"
// The data is 31h 32h 31h 30h 38h 30h 31h 30h 30h 30h 31h 37h 30h 31h

public struct PrintHeadCode: CustomStringConvertible {
    public let code: String
    public var description: String { return "\(self.code)" }
    public var bytes: [UInt8] { return self.code.asciiValues }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 14 { throw ValueError.incorrectNumberOfBytesError }
        if let string = String(bytes: bytes, encoding: .utf8) {
            self.code = string
        } else {
            throw ValueError.encodingValueError
        }
        
    }
}

// MARK: Get Photocell Mode 0x13
// 1byte
//      - 0 interior trigger
//      - 1 photocell edge trigger
//      - 2 photocell level trigger
//      - 3 remote
public struct PhotocellMode: CustomStringConvertible {
    public enum Mode: UInt8, CustomStringConvertible {
        case interiorTrigger = 0
        case edgeTrigger = 1
        case levelTrigger = 2
        case remote = 3
        
        public var description: String {
            switch self {
            case .interiorTrigger:
                return "Interior Trigger"
            case .edgeTrigger:
                return "Edge Trigger"
            case .levelTrigger:
                return "Level Trigger"
            case .remote:
                return "Remote"
            }
        }
    }
    
    public let mode: Mode
    public var description: String { return self.mode.description }
    public var bytes: [UInt8] { return [UInt8(self.mode.rawValue)] }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 1 { throw ValueError.incorrectNumberOfBytesError }
        if let m = Mode(rawValue: bytes[0]) {
            self.mode = m
        } else {
            throw ValueError.encodingValueError
        }
    }
}

// MARK: Get Jet Status 0x14
// The 10 bytes of data structure are as follows:
// [RefPress] 1 byte Reference pressure
// [Press] 1 byte Set pressure
// [ReadPress] 1 byte read pressure
// [SolventAddtion] 1 byte Solvent addition pressure
// [Modulation] 1 byte modulation
// [Phase] 1 byte Phase
// [RefVOD] 2 bytes reference ink speed
// [VOD] 2 bytes ink speed

public struct JetStatus: CustomStringConvertible {
    public let referencePressure: UInt8
    public let setPressure: UInt8
    public let readPressure: UInt8
    public let solventAddition: UInt8
    public let modulation: UInt8
    public let phase: UInt8
    public let referenceInkSpeed: UInt16
    public let inkSpeed: UInt16
    
    public var description: String { return "{refp:\(referencePressure),sp:\(setPressure),rp:\(readPressure),sa:\(solventAddition),m:\(modulation),ph:\(phase),ris:\(referenceInkSpeed),is:\(inkSpeed)}" }
    
    public init(bytes: [UInt8]) throws {
        if bytes.count != 10 { throw ValueError.incorrectNumberOfBytesError }
        self.referencePressure = bytes[0]
        self.setPressure = bytes[1]
        self.readPressure = bytes[2]
        self.solventAddition = bytes[3]
        self.modulation = bytes[4]
        self.phase = bytes[5]
        self.referenceInkSpeed = UInt16(upper: bytes[6], lower: bytes[7])
        self.inkSpeed = UInt16(upper: bytes[8], lower: bytes[9])
    }
}

/*
// MARK: - Decoding data inside frames
// You should have a valid frame and know what type it is. Then you can use a function from here to
// reliably decode the data.


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
