//
//  ECJetCommunication.swift
//
//  Created by Daniel Pink on 9/3/2023.
//

import Foundation

//7E 00 18 00 0C 00 00 00 00 00 00 00 00 1E ED 7F
// Given a Data buffer you should be able to
//  - create a frame from it
//  - Frame should fail to initialise if checksum fails
//  - Extract information from it automatically
//  - Bunch of static functions for creating frames of certain types

public enum BufferSize {
    case count(Int)
    case variable
}

public enum Command: UInt16 {
    case setPrintWidth = 0x0001
    case getPrintWidth = 0x0002
    case setPrintDelay = 0x0003
    case getPrintDelay = 0x0004
    case setPrintInterval = 0x0005
    case getPrintInterval = 0x0006
    case setPrintHeight = 0x0007
    case getPrintHeight = 0x0008
    case setPrintCount = 0x0009
    case getPrintCount = 0x000A
    case setReverseMessage = 0x000B
    case getReverseMessage = 0x000C
    case setTriggerRepeat = 0x000D
    case getTriggerRepeat = 0x000E
    case getPrinterStatus = 0x000F
    case setPrintHeadCode = 0x0010
    case getPrintHeadCode = 0x0011
    case setPhotocellMode = 0x0012
    case getPhotocellMode = 0x0013
    case getJetStatus = 0x0014
    case getSystemTimes = 0x0015
    case startJet = 0x0016
    case stopJet = 0x0017
    case startPrint = 0x0018
    case stopPrint = 0x0019
    case triggerPrint = 0x001A
    case setDateTime = 0x001B
    case getDateTime = 0x001C
    case getFontList = 0x001D
    case getMessageList = 0x001E
    case createField = 0x001F
    case downloadRemoteBuffer = 0x0020
    case deleteLastField = 0x0021
    case deleteMessageContent = 0x0022
    case setCurrentMessage = 0x0023
    case setAUXMode = 0x0024
    case getAUXMode = 0x0025
    case setShaftEncoderMode = 0x0026
    case getShaftEncoderMode = 0x0027
    case setReferenceModulation = 0x0028
    case getReferenceModulation = 0x0029
    case resetSerialNumber = 0x002A
    case resetCountLength = 0x002B
    case getRemoteBufferSize = 0x002F
    case printTriggerState = 0x1000
    case printGoState = 0x1001
    case printEndState = 0x1002
    case requestRemoteData = 0x1003
    case printFaultState = 0x1004
    
    static var sendDataCount: [Command: BufferSize] =
        [.setPrintWidth         : .count(3),
         .getPrintWidth         : .count(0),
        .setPrintDelay          : .count(5),
        .getPrintDelay          : .count(0),
        .setPrintInterval       : .count(5),
        .getPrintInterval       : .count(0),
        .setPrintHeight         : .count(1),
        .getPrintHeight         : .count(0),
        .setPrintCount          : .count(5),
        .getPrintCount          : .count(1),
        .setReverseMessage      : .count(2),
        .getReverseMessage      : .count(0),
        .setTriggerRepeat       : .count(1),
        .getTriggerRepeat       : .count(0),
        .getPrinterStatus       : .count(0),
        .setPrintHeadCode       : .count(14),
        .getPrintHeadCode       : .count(0),
        .setPhotocellMode       : .count(1),
        .getPhotocellMode       : .count(0),
        .getJetStatus           : .count(0),
        .getSystemTimes         : .count(0),
        .startJet               : .count(0),
        .stopJet                : .count(0),
        .startPrint             : .count(0),
        .stopPrint              : .count(0),
        .triggerPrint           : .count(0),
        .setDateTime            : .count(20),
        .getDateTime            : .count(0),
        .getFontList            : .count(0),
        .getMessageList         : .count(0),
        .createField            : .variable,
        .downloadRemoteBuffer   : .variable,
        .deleteLastField        : .count(0),
        .deleteMessageContent   : .count(0),
        .setCurrentMessage      : .count(32),
        .setAUXMode             : .count(1),
        .getAUXMode             : .count(0),
        .setShaftEncoderMode    : .count(1),
        .getShaftEncoderMode    : .count(0),
        .setReferenceModulation : .count(1),
        .getReferenceModulation : .count(0),
        .resetSerialNumber      : .count(0),
        .resetCountLength       : .count(0),
        .getRemoteBufferSize    : .count(0),
        .printTriggerState      : .count(0),
        .printGoState           : .count(0),
        .printEndState          : .count(0),
        .requestRemoteData      : .count(0),
        .printFaultState        : .count(0)]
    
    func expectedSendDataCount() -> BufferSize {
        return Command.sendDataCount[self]!
    }
    
    static var receiveDataCount: [Command: BufferSize] =
        [.setPrintWidth         : .count(0),
         .getPrintWidth         : .count(3),
        .setPrintDelay          : .count(0),
        .getPrintDelay          : .count(5),
        .setPrintInterval       : .count(0),
        .getPrintInterval       : .count(5),
        .setPrintHeight         : .count(0),
        .getPrintHeight         : .count(1),
        .setPrintCount          : .count(0),
        .getPrintCount          : .count(4),
        .setReverseMessage      : .count(0),
        .getReverseMessage      : .count(2),
        .setTriggerRepeat       : .count(0),
        .getTriggerRepeat       : .count(1),
        .getPrinterStatus       : .count(5),
        .setPrintHeadCode       : .count(0),
        .getPrintHeadCode       : .count(14),
        .setPhotocellMode       : .count(0),
        .getPhotocellMode       : .count(1),
        .getJetStatus           : .count(10),
        .getSystemTimes         : .count(32),
        .startJet               : .count(0),
        .stopJet                : .count(0),
        .startPrint             : .count(0),
        .stopPrint              : .count(0),
        .triggerPrint           : .count(0),
        .setDateTime            : .count(0),
        .getDateTime            : .count(20),
        .getFontList            : .variable,
        .getMessageList         : .variable,
        .createField            : .count(0),
        .downloadRemoteBuffer   : .count(1),
        .deleteLastField        : .count(0),
        .deleteMessageContent   : .count(0),
        .setCurrentMessage      : .count(0),
        .setAUXMode             : .count(0),
        .getAUXMode             : .count(1),
        .setShaftEncoderMode    : .count(0),
        .getShaftEncoderMode    : .count(1),
        .setReferenceModulation : .count(0),
        .getReferenceModulation : .count(1),
        .resetSerialNumber      : .count(0),
        .resetCountLength       : .count(0),
        .getRemoteBufferSize    : .count(4),
        .printTriggerState      : .count(0),
        .printGoState           : .count(0),
        .printEndState          : .count(0),
        .requestRemoteData      : .count(0),
        .printFaultState        : .count(0)]
    
    func expectedReceiveDataCount() -> BufferSize {
        return Command.receiveDataCount[self]!
    }
    func expectedDataCount(fromPC: Bool) -> BufferSize {
        return fromPC ? Command.sendDataCount[self]! : Command.receiveDataCount[self]!
    }
}

public enum ReceptionStatus: UInt8 {
    case complete = 0x06
    case frameError = 0x15
    case fromPC = 0x00
}

public enum CMDStatus: UInt16 {
    case success = 0
    case failed = 1
    case notImplemented = 2
    case jetNotRunning = 8
    case parameterError = 4
    case printerBusy = 10
}
// TODO: Use the CMDStatus enum for the status field of the CommandInformation struct

public struct CommandInformation {
    public let acknowledge: ReceptionStatus
    public let nr: UInt16
    public let devStatus: UInt16
    public let status: UInt16
    
    public init(acknowledge: ReceptionStatus, nr: UInt16 = 0, devStatus: UInt16 = 0, status: UInt16 = 0) {
        self.acknowledge = acknowledge
        self.nr = nr
        self.devStatus = devStatus
        self.status = status
    }
    
    public init?(bytes: [UInt8]) {
        precondition(bytes.count == 7, "Command Information is of the wrong size: \(bytes)")
        
        if let ack = ReceptionStatus(rawValue: bytes[0]) {
            self.acknowledge = ack
        } else {
            assertionFailure("\(bytes[0]) is not an expected ReceptionStatus (0x06, 0x15 or 0x00): \(bytes)")
            return nil
        }
        
        self.nr = UInt16(upper: bytes[1], lower: bytes[2])
        self.devStatus = UInt16(upper: bytes[3], lower: bytes[4])
        self.status = UInt16(upper: bytes[5], lower: bytes[6])
    }
    
    public static func fromPC() -> CommandInformation {
        return CommandInformation(bytes: [0,0,0,0,0,0,0])!
    }
    
    public var fromPC : Bool {
        return bytes.reduce(true) { $0 && $1 == 0 }
    }
    
    public var bytes: [UInt8] {
        var response: [UInt8] = []
        response.append(self.acknowledge.rawValue)
        
        response.append(nr.lowerByte)
        response.append(nr.upperByte)
        
        response.append(devStatus.lowerByte)
        response.append(devStatus.upperByte)
        
        response.append(status.lowerByte)
        response.append(status.upperByte)
        
        return response
    }
    
    public var prettyDescription: String {
        return "\(self.acknowledge)"
    }
}



public struct Frame: CustomStringConvertible, Hashable {
    
    public let address: UInt8
    public let command: Command
    public let dataOffset: UInt16
    public let information: CommandInformation
    public let data: [UInt8]
    public let verification: VerificationMode
    
    public var bytes: [UInt8] {
        var temp: [UInt8] = []
        temp.append(address)                        // Address
        temp.append(command.rawValue.lowerByte)     // Command
        temp.append(command.rawValue.upperByte)
        temp.append(0x0C)                           // Data Offset
        temp.append(0x00)
        for byte in information.bytes {             // Information
            temp.append(byte)
        }
        for byte in data {                          // Data
            temp.append(byte)
        }
        switch(verification) {                      // CRC
        case .none:
            break
        case .mod256:
            break
        case .crc16:
            let crc = Frame.crc16_x25(temp)
            temp.append(crc.lowerByte)
            temp.append(crc.upperByte)
        }
        temp = Frame.byteEscape(buffer: temp)       // Byte Escaping
        temp.insert(0x7E, at: 0)                    // Start
        temp.append(0x7F)                           // End
        return(temp)
    }
    
    public enum VerificationMode {
        case none
        case mod256
        case crc16
    }
    
    // MARK: - Initialisers
    public init?(bytes: [UInt8], verificationMethod: VerificationMode) {
        var input = bytes
        
        // Needs to be at least a certain number of bytes to form a frame.
        switch verificationMethod {
        case .none:
            if input.count < 14 { return nil }
        case .mod256:
            if input.count < 15 { return nil }
        case .crc16:
            if input.count < 16 { return nil }
        }
        
        // Check first byte
        if input.removeFirst() != 0x7E {
            print("First byte was wrong: \(bytes)")
            return nil
        }
        
        // Check last byte
        if input.removeLast() != 0x7F {
            print("Last byte was wrong: \(bytes)")
            return nil
        }
        
        // Byte Escaping
        input = Frame.byteCapture(buffer: input)
        
        // Check crc
        switch verificationMethod {
        case .crc16:
            let crcProvided = input.removeLast(2)
            let crc = UInt16(upper: crcProvided[1], lower: crcProvided[0])
            let crcCalculated = Frame.crc16_x25(input)
            if crc != crcCalculated {
                print("CRC was wrong: \(bytes)")
                print("Received: \(crc), Calculated: \(crcCalculated) from: \(crcProvided)")
                return nil
            }
        case .mod256:
            let modProvided = input.removeLast()
            let mod = UInt8(modProvided)
            let modCalculated = Frame.mod256(input)
            if mod != modCalculated {
                print("Mod was wrong: \(bytes)")
                print("Received: \(mod), Calculated: \(modCalculated) from: \(modProvided)")
                return nil
            }
        default:
            break
        }
        
        // address
        self.address = input.removeFirst()
        
        // command
        let commandProvided = input.removeFirst(2)
        if let com = Command(rawValue: UInt16(upper: commandProvided[1], lower: commandProvided[0])) {
            self.command = com
        } else {
            print("Couldn't recognise the command: \(commandProvided): \(bytes)")
            return nil
        }
        
        // data offset
        let offsetProvided = input.removeFirst(2)
        self.dataOffset = UInt16(upper: offsetProvided[1], lower: offsetProvided[0])
        if self.dataOffset != 0x0C {
            print("Incorrect data offset: \(bytes)")
            return nil
        }
        
        // information
        let informationProvided = [UInt8](input.removeFirst(7))
        if let information = CommandInformation(bytes: informationProvided) {
            self.information = information
        } else {
            print("Incorrect command information provided: \(informationProvided)")
            return nil
        }
        
        // data
        let expectedDataCount = self.command.expectedDataCount(fromPC: self.information.fromPC)
        switch expectedDataCount {
        case .count(let expected):
            if input.count != expected {
                print("Incorrect data length for \(self.command) \(self.information.fromPC ? "from PC" : "from Printer"): \(input), expected \(expected) bytes")
                return nil
            }
        case .variable:
            // Can't really check anything here
            break
        }
        
        self.data = input
        
        self.verification = verificationMethod
    }
    /*
     Needs a BigInt implementation to be useful. Never checked that this worked.
    public init?(integer value: Int, verificationMethod: VerificationMode) {
        //let x: Int = 2019
        let length: Int = 2 * MemoryLayout<UInt8>.size

        let a = withUnsafeBytes(of: value) { bytes in
            Array(bytes.prefix(length))
        }

        let result = Array(a.reversed())
        
        if let frame = Frame(bytes: result, verificationMethod: verificationMethod) {
            self = frame
        } else {
            return nil
        }
    }
     */
    
     // TODO: -
    /*
     
     public init?(_ input: String, verificationMethod: VerificationMode) {
        // Swift sometimes outputs data arrays in the format, 0xf400ac7b890d.
        // This is a very large integer number so it can't be used by default.
        // Treating it as a string would be a convenient way of taking output
        // from the console and entering it into test programs.
     }
     */
    
    public init(address: UInt8 = 0, command: Command, information: CommandInformation = CommandInformation.fromPC(), dataOffset: UInt16 = 0x0C, data: [UInt8] = [], verification: VerificationMode = .crc16) {
        self.address = address
        self.command = command
        self.information = information
        self.dataOffset = dataOffset
        self.data = data
        self.verification = verification
    }
    
    
    // MARK: - Generating Frames
    public static func createStartPrint() -> Frame {
        let data: [UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1E,0xED,0x7F]
        return Frame(bytes: data, verificationMethod: .crc16)!
    }
    
    // let f = Frame.downloadRemoteBuffer(address: 0, message: "Hello, World!")
    public static func downloadRemoteBuffer(address: UInt8, message: String) -> Frame {
        let data: [UInt8] = Array(message.utf8)
        let count: UInt16 = UInt16(data.count)
        let buffer = [count.lowerByte] + [count.upperByte] + data
        return Frame(address: address, command: .downloadRemoteBuffer, data: buffer)
    }
    
    public static func remoteBufferResponse(address: UInt8, message: String) -> Frame {
        let data: [UInt8] = Array(message.utf8)
        let count: UInt16 = UInt16(data.count)
        let information = CommandInformation(acknowledge: .complete)
        let buffer = [count.lowerByte] + [count.upperByte] + data
        return Frame(address: address, command: .downloadRemoteBuffer, information: information, data: buffer)
    }
    
    public enum CountType: UInt8 {
        case total = 0x00
        case printing = 0x01
        case editing = 0x02
    }
    
    
    // MARK: - Decoding data inside frames
    // You should have a valid frame and know what type it is. Then you can use a function from here to
    // reliably decode the data.
    
    // MARK: Get Print Width 0x02
    // 2 bytes print width value
    static public func decodePrintWidth(data: [UInt8]) -> Double {
        precondition(data.count == 3) // I don't understand why it needs 3 values?
        let value: Double = (0.256 * Double(data[1])) + (0.001 * Double(data[0]))
        return value
    }
    
    // This shouldn't accept a Double as all Double values cannot be encoded properly. Not sure how to handle this.
    // Needs to be added to the validation for the UI as well.
    static public func encodePrintWidth(mm value: Double) throws -> [UInt8] {
        if value < 0.0 { throw ValueError.encodingValueError }
        precondition(value < (256 * 0.256), "encodePrintWidth value (\(value)) is too large")
        let q1 = (value / 0.256).rounded(.towardZero)
        let r = value.truncatingRemainder(dividingBy: 0.256)
        let q2 = (r / 0.001).rounded(.toNearestOrAwayFromZero)
        //print("\(value),\(q1),\(r),\(q2)")
        return [UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1]
    }
    
    // MARK: Get Print Delay 0x04
    static public func decodePrintDelay(data: [UInt8]) -> Double {
        precondition(data.count == 5)
        let value: Double = (16777.216 * Double(data[3])) + (65.536 * Double(data[2])) + (0.256 * Double(data[1])) + (0.001 * Double(data[0]))
        return value
    }
    
    static public func encodePrintDelay(mm value: Double) throws -> [UInt8] {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        //print("\(value),\(q1),\(r),\(q2)")
        return [UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1]
    }
    
    // MARK: Get Print Interval 0x06
    static public func decodePrintInterval(data: [UInt8]) -> Double {
        precondition(data.count == 5)
        let value: Double = (16777.216 * Double(data[3])) + (65.536 * Double(data[2])) + (0.256 * Double(data[1])) + (0.001 * Double(data[0]))
        return value
    }
    
    // remainder vs truncating remainder
    // https://stackoverflow.com/questions/42724234/truncatingremainder-vs-remainder-in-swift
    static public func encodePrintInterval(mm value: Double) throws -> [UInt8] {
        if value < 0.0 { throw ValueError.encodingValueError }
        let q1 = (value / 16777.216).rounded(.towardZero)
        let r1 = value.truncatingRemainder(dividingBy: 16777.216)
        let q2 = (r1 / 65.536).rounded(.towardZero)
        let r2 = r1.truncatingRemainder(dividingBy: 65.536)
        let q3 = (r2 / 0.256).rounded(.towardZero)
        let r3 = r2.truncatingRemainder(dividingBy: 0.256)
        let q4 = (r3 / 0.001).rounded(.toNearestOrAwayFromZero)
        //print("\(value),\(q4),\(q3),\(q2),\(q1)")
        return [UInt8(Int(q4) % 256), UInt8(Int(q3) % 256), UInt8(Int(q2) % 256), UInt8(Int(q1) % 256), 1]
    }
    
    // MARK: Get Print Height 0x08
    static public func decodePrintHeight(data: [UInt8]) -> UInt8 {
        precondition(data.count == 1)
        return data[0]
    }
    
    static public func encodePrintHeight(value: UInt8) throws -> [UInt8] {
        if value > 230 { throw ValueError.printHeightTooHighError }
        else if value < 110 { throw ValueError.printHeightTooHighError }
        else {
            return [value]
        }
    }
    
    // MARK: Get Print Count 0x0A
    public static func decodePrintCount(_ data: [UInt8]) -> Int {
        precondition(data.count == 4, "Wrong number of bytes when decoding print count")
        return Int(bytes: data)
    }
    
    public static func getPrintCount(address: UInt8 = 0, countType: CountType, verification: VerificationMode = .crc16) -> Frame {
        return Frame(address: address, command: .getPrintCount, data: [countType.rawValue], verification: verification)
    }

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
    
    
    // MARK: - Print Out Methods
    public var description: String {
        var output: String = ""
        for byte in self.bytes {
            output.append(String(byte, radix: 16)+",")
        }
        return output
    }
    
    public var prettyDescription: String {
        var output: String = "["
        output.append("\(self.address),")
        output.append("\(self.command),")
        output.append("\(self.information.prettyDescription),")
        switch self.command {
        case .setPrintWidth, .getPrintWidth:
            let width = try? PrintWidth(bytes: self.data)
            output.append(width?.description ?? self.data.description)
        case .setPrintDelay, .getPrintDelay:
            let delay = try? PrintDelay(bytes: self.data)
            output.append(delay?.description ?? self.data.description)
        case .setPrintInterval, .getPrintInterval:
            let interval = try? PrintInterval(bytes: self.data)
            output.append(interval?.description ?? self.data.description)
        case .setPrintHeight, .getPrintHeight:
            let height = try? PrintHeight(bytes: self.data)
            output.append(height?.description ?? self.data.description)
        case .setPrintCount:
            let printCount = try? PrintCount(bytes: self.data)
            output.append(printCount?.description ?? self.data.description)
        // case .getPrintCount: // TODO:
        case .setReverseMessage, .getReverseMessage:
            let reverseMessage = try? ReverseMessage(bytes: self.data)
            output.append(reverseMessage?.description ?? self.data.description)
        case .setTriggerRepeat, .getTriggerRepeat:
            let triggerRepeat = try? TriggerRepeat(bytes: self.data)
            output.append(triggerRepeat?.description ?? self.data.description)
        case .getPrinterStatus:
            let status = try? PrinterStatus(bytes: self.data)
            output.append(status?.description ?? self.data.description)
        case .getPrintHeadCode:
            let printHeadCode = try? PrintHeadCode(bytes: self.data)
            output.append(printHeadCode?.code ?? self.data.description)
        case .getPhotocellMode:
            let photocellMode = try? PhotocellMode(bytes: self.data)
            output.append(photocellMode?.mode.description ?? self.data.description)
        case .getJetStatus:
            let jetStatus = try? JetStatus(bytes: self.data)
            output.append(jetStatus?.description ?? self.data.description)
        case .getSystemTimes:
            let systemTimes = try? SystemTimes(bytes: self.data)
            output.append(systemTimes?.description ?? self.data.description)
        case .getDateTime:
            let dateTime = try? DateTime(bytes: self.data)
            output.append(dateTime?.date.description ?? self.data.description)
        case .getFontList:
            if let fontList = try? FontList(bytes: self.data) {
                for item in fontList.list {
                    output.append("\(item),")
                }
            } else {
                output.append(self.data.description)
            }
        case .getMessageList:
            if let messageList = try? MessageList(bytes: self.data) {
                for item in messageList.list {
                    output.append("\(item),")
                }
            } else {
                output.append(self.data.description)
            }
        case .downloadRemoteBuffer:
            let remoteBuffer = try? RemoteBuffer(bytes: self.data)
            output.append(remoteBuffer?.buffer ?? self.data.description)
        default:
            output.append("\(self.data)")
        }
        output.append("]")
        return output
    }
    
    // MARK: - Checksum Methods
    // Using Mod256 as the check method, the checksum is calculated by summing all the bytes starting from
    // [ADDR] to [<DATA>] in the communication frame, and modulo the 256, which is the check word.
    // [<CHECKUSM>] is 1 byte in length.
    public static func mod256(_ data: [UInt8]) -> UInt8 {
        var mod: UInt8 = 0
        
        for byte in data {
            mod = mod &+ byte
        }
        
        return mod
    }
    
    // Using CRC16 as the check method, the input of CRC16 is all bytes in the communication frame starting from [ADDR] to [<DATA>], and the output is the check word.
    // [<CHECKSUM>] is 2 bytes in length.
    
    // The CRC16 algorithm used in this version of protocol is: CRC-16/X25.
    // Polynomial: . (0x1021).
    // Initial value: 0xFFFF.
    // Data reversal: LSB First.
    // XOR value: 0xFFFF.
    public static func crc16_x25(_ data: [UInt8]) -> UInt16 {
        var crc: UInt16 = 0xffff // Initial value
        
        for byte in data {
            crc ^= UInt16(byte)
            
            for _ in 0..<8 {
                if crc & 0x0001 != 0 {
                    crc = (crc >> 1) ^ 0x8408 // 0x8408 = reverse 0x1021
                } else {
                    crc = (crc >> 1)
                }
            }
        }
        
        return ~crc // crc ^ Xorout
    }

    // MARK: - Byte Escaping
    
    static func byteEscape(buffer: [UInt8]) -> [UInt8] {
        var result: [UInt8] = buffer
        
        //result.replace([0x7D], with: [0x7D, 0x5D])
        //result.replace([0x7E], with: [0x7D, 0x5E])
        //result.replace([0x7F], with: [0x7D, 0x5F])
        
        for (index, value) in result.enumerated() {
            if value == 0x7D {
                result.remove(at: index)
                result.insert(contentsOf: [0x7D, 0x5D], at: index)
            }
        }
        
        for (index, value) in result.enumerated() {
            if value == 0x7E {
                result.remove(at: index)
                result.insert(contentsOf: [0x7D, 0x5E], at: index)
            }
        }
        
        for (index, value) in result.enumerated() {
            if value == 0x7F {
                result.remove(at: index)
                result.insert(contentsOf: [0x7D, 0x5F], at: index)
            }
        }
        
        return result
    }
    
    static func byteCapture(buffer: [UInt8]) -> [UInt8] {
        var result: [UInt8] = buffer
        
        //result.replace([0x7D, 0x5D], with: [0x7D])
        //result.replace([0x7D, 0x5E], with: [0x7E])
        //result.replace([0x7D, 0x5F], with: [0x7F])
        
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            if result[index] == 0x5D && result[index - 1] == 0x7D {
                result.remove(at: index)
                result.remove(at: index - 1)
                result.insert(0x7D, at: index - 1)
            }
        }
        
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            if result[index] == 0x5E && result[index - 1] == 0x7D {
                result.remove(at: index)
                result.remove(at: index - 1)
                result.insert(0x7E, at: index - 1)
            }
        }
        
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            if result[index] == 0x5F && result[index - 1] == 0x7D {
                result.remove(at: index)
                result.remove(at: index - 1)
                result.insert(0x7F, at: index - 1)
            }
        }
        
        return result
    }
    
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        return lhs.bytes == rhs.bytes
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.bytes)
    }
    
    /*
    // Original Code
    void MainWindow::changeData(QByteArray &ba)
    {
        for(int i = 0; i < ba.length() * 2; i++)
        {
            if(ba.toHex().at(i) == '7')
            {
                //0x7d escapes to 0x7d 0x5d
                if(ba.toHex().at(i + 1) == 'd')
                {
                    int num = ba.indexOf(0x7d);
                    ba.remove(num, 1);
                    ba.insert(num, 0x7d);
                    ba.insert(num + 1, 0x5d);
                }
                //0x7e escapes to 0x7d 0x5e
                if(ba.toHex().at(i + 1) == 'e')
                {
                    int num = ba.indexOf(0x7e);
                    ba.remove(num, 1);
                    ba.insert(num, 0x7d);
                    ba.insert(num + 1, 0x5e);
                }
                //0x7f escapes to 0x7d 0x5f
                if(ba.toHex().at(i + 1) == 'f')
                {
                    int num = ba.indexOf(0x7f);
                    ba.remove(num, 1);
                    ba.insert(num, 0x7d);
                    ba.insert(num + 1, 0x5f);
                }
            }
            i++;//Skip a byte to avoid the situation where e7e8 judges 7e
        }
    }
     */
}

