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

public enum Command: UInt16 {
    case setPrintWidth = 0x0001
    case getPrintWidth = 0x0002
    case setPrintDelay = 0x0003
    case getPrintDelay = 0x0004
    case setPrintInteval = 0x0005
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
    case printTriggerState = 0x1000
    case printGoState = 0x1001
    case printEndState = 0x1002
    case requestRemoteData = 0x1003
    case printFaultState = 0x1004
    
}

public struct CommandInformation {
    let acknowledge: ReceptionStatus
    let nr: UInt16
    let devStatus: UInt16
    let status: UInt16
    
    public enum ReceptionStatus: UInt8 {
        case complete = 0x06
        case frameError = 0x15
        case fromPC = 0x00
    }
    
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



public struct Frame: CustomStringConvertible {
    //let bytes: [UInt8]
    
    let address: UInt8
    let command: Command
    let dataOffset: UInt16
    let information: CommandInformation
    let data: [UInt8]
    let verification: VerificationMode
    
    public enum VerificationMode {
        case none
        case mod256
        case crc16
    }

    public init?(bytes: [UInt8], verificationMethod: VerificationMode) {
        var input = bytes
        
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
            print("Couldn't recognise the command: \(commandProvided)")
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
        self.data = input
        
        self.verification = verificationMethod
    }
    
    public init(address: UInt8 = 0, command: Command, information: CommandInformation = CommandInformation.fromPC(), dataOffset: UInt16 = 0x0C, data: [UInt8] = [], verification: VerificationMode = .crc16) {
        self.address = address
        self.command = command
        self.information = information
        self.dataOffset = dataOffset
        self.data = data
        self.verification = verification
    }
    
    public var bytes: [UInt8] {
        var temp: [UInt8] = []
        temp.append(0x7E)                           // Start
        temp.append(address)                        // Address
        temp.append(command.rawValue.lowerByte)     // Command
        temp.append(command.rawValue.upperByte)
        temp.append(0x0C)                           // Data Offset
        temp.append(0x00)
        for byte in information.bytes {                   // Information
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
            let crc = Frame.crc16_x25([UInt8](temp[1...]))
            temp.append(crc.lowerByte)
            temp.append(crc.upperByte)
        }
        
        temp.append(0x7F)                           // End
        return(temp)
    }

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
    
    public enum CountType: UInt8 {
        case total = 0x00
        case printing = 0x01
        case editing = 0x02
    }
    
    
    // ----- Decoding data inside frames -----
    // You should have a valid frame and know what type it is. Then you can use a function from here to
    // reliably decode the data.
    
    // [FileCount] 2 bytes Number of message
    // [FilleNameList] array of file names, each file name occupies 32 bytes
    public func decodeGetMessageList() -> [String] {
        precondition(self.command == .getMessageList)
        
        let messageCount: UInt16 = UInt16(upper: self.data[1], lower: self.data[0])
        precondition(self.data.count == ((messageCount * 32) + 2))
        
        return [""]
    }
    
    public func decodePrintWidth() -> UInt16 {
        precondition(self.command == .setPrintWidth || self.command == .getPrintWidth)
        precondition(self.data.count == 3) // I don't understand why it needs 3 values?
        return UInt16(upper:self.data[0], lower: self.data[1])
    }
    
    public static func decodePrintCount(_ data: [UInt8]) -> Int {
        precondition(data.count == 4, "Wrong number of bytes when decoding print count")
        return Int(bytes: data)
    }
    
    public static func getPrintCount(address: UInt8 = 0, countType: CountType, verification: VerificationMode = .crc16) -> Frame {
        return Frame(address: address, command: .getPrintCount, data: [countType.rawValue], verification: verification)
    }
    
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
    
    public static func decodeGetReverse(_ data: [UInt8]) -> ReverseSettings {
        precondition(data.count == 2, "wrong number of bytes when decodint get reverse message")
        return ReverseSettings(horizontal: data[0] == 1 ? true : false, vertical: data[1] == 1 ? true : false)
    }
    
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
    
    // let address: UInt8
    // let command: Command
    // let dataOffset: UInt16
    // let information: CommandInformation
    // let data: [UInt8]
    // let verification: VerificationMode
    // [0, setPrintWidth, Acknowledge, [0x56 0x00]]
    
    
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
        output.append("\(self.data)]")
        return output
    }
    
    public static func mod256(_ data: Data) -> UInt8 {
        return 0xFF
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

}




