import XCTest
@testable import ECJetCommunication

final class ECJetCommunicationTests: XCTestCase {
    func testLowerBytes() throws {
        let value: UInt16 = 0x1234
        XCTAssertEqual(value.lowerByte, 0x34)
    }
    
    func testUpperBytes() throws {
        let value: UInt16 = 0x1234
        XCTAssertEqual(value.upperByte, 0x12)
    }
    
    func dtestStartJetFrame() throws {
        let d: [UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1E,0xED,0x7F]
        let data = Data(d)
        let frame = Frame(address: 0, command: .startPrint, data: [], verification: .crc16)
        let frame2 = Frame(address: 0, command: .startPrint)
        let frame3 = Frame(bytes: d, verificationMethod: .crc16)!
        XCTAssertEqual(frame.data, d)
        XCTAssertEqual(frame2.bytes, d)
        XCTAssertEqual(frame3.bytes, d)
    }
    
    func dtestByteEscape1() throws {
        let d: [UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5D,0x7D,0x5E,0x7D,0x5F,0xA0,0x94,0x7F]
        let a = Frame(address: 0, command: .startPrint, data: [0x7D, 0x7E, 0x7F])
        XCTAssertEqual(a.bytes, d)
    }
    
    func dtestByteEscape2() throws {
        let d: [UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5D,0x7D,0x5E,0x7D,0x5F,0xA0,0x94,0x7F]
        let b = Frame(bytes: d, verificationMethod: .crc16)!
        XCTAssertEqual(b.data, [0x7D, 0x7E, 0x7F])
    }
    
    func testCRC() throws {
        let data: [UInt8] = [0x00,0x16,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
        let result = Frame.crc16_x25(data)
        XCTAssertEqual(result, 0xA4C3)
    }
    
    func testDecodeMessageList() throws {
        let data: [UInt8] = [7, 0, 50, 48, 48, 48, 45, 67, 104, 117, 106, 105, 95, 69, 78, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 49, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 50, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 51, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 53, 95, 49, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 53, 95, 50, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 69, 83, 84, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let frame = Frame(address: 0, command: .getMessageList, information: CommandInformation(acknowledge: .complete), data: data)
        let decodedMessageList = frame.decodeGetMessageList()
        let actualMessageList: [String] = ["Something should be here"]
        XCTAssertEqual(decodedMessageList, actualMessageList)
    }
    
    func testFrame() throws {
        let f = Frame.createStartPrint()
        let command = f.command
        XCTAssertEqual(command, Command.startPrint)
    }
    
    func testSetPrintHeightPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x07,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x96,0x79,0x65,0x7F]
        let frame = Frame(address: 0, command: .setPrintHeight, information: CommandInformation.fromPC(), data: [0x96], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testSetPrintHeightResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x07,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0xDA,0xD8,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .setPrintHeight)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
    }
    
    func testGetPrintHeightPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x08,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x5B,0x9C,0x7F]
        let frame = Frame(address: 0, command: .getPrintHeight, information: CommandInformation.fromPC(), data: [], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testGetPrintHeightResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x08,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x96,0xBC,0xF0,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .getPrintHeight)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
        XCTAssertEqual(frame.data, [0x96])
    }
    
    func testSetPrintCountPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x09,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x0C,0x00,0x00,0x00,0xAE,0x8B,0x7F]
        let frame = Frame(address: 0, command: .setPrintCount, information: CommandInformation.fromPC(), data: [0x02,0x0C,0x00,0x00,0x00], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testSetPrintCountResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x09,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x91,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .setPrintCount)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
    }
    
    func testGetPrintCountPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0A,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x1B,0x3D,0x7F]
        let frame = Frame.getPrintCount(countType: .editing)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testGetPrintCountResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0A,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0xA2,0x01,0x00,0x00,0xB3,0x61,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .getPrintCount)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
        XCTAssertEqual(Frame.decodePrintCount(frame.data), 0x01A2)
    }
    
    
    
    func testGetJetStatusPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x14,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE1,0x0F,0x7F]
        let frame = Frame(address: 0, command: .getJetStatus, information: CommandInformation.fromPC(), data: [], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testGetJetStatusResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x14,0x00 ,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,
                             0xAA,0xAA,0x00,0xAE,0x83,0x0C,0x59,0x52,0x00,0x00,0xE9,0x09,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .getJetStatus)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
        XCTAssertEqual(frame.data, [0xAA,0xAA,0x00,0xAE,0x83,0x0C,0x59,0x52,0x00,0x00])
    }
    
    func testStartPrintPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1E,0xED,0x7F]
        let frame = Frame(address: 0, command: .startPrint, information: CommandInformation.fromPC(), data: [], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testStartPrintResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x18,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0xD3,0xB5,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .startPrint)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
    }
    
    func testStopPrintPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x19,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x8F,0xB8,0x7F]
        let frame = Frame(address: 0, command: .stopPrint, information: CommandInformation.fromPC(), data: [], verification: .crc16)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testStopPrintResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x19,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x42,0xE0,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .stopPrint)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
    }
    
    func testSetReversePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0B,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x01,0x5B,0x60,0x7F]
        let frame = Frame.setReverse(horizontal: true, vertical: true)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testSetReverseResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0B,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x25,0x3A,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .setReverseMessage)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
    }
    
    func testGetReversePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0C,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0E,0xC2,0x7F]
        let frame = Frame(command: .getReverseMessage)
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testGetReverseResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x0C,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0xDF,0xC5,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .getReverseMessage)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
        XCTAssertEqual(Frame.decodeGetReverse(frame.data), Frame.ReverseSettings(horizontal: false, vertical: true))
    }
    
    func testDownloadRemoteBufferPacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x20,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A,0x00,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x30,0xD4,0x50,0x7F]
        let frame = Frame.downloadRemoteBuffer(address: 0, message: "1234567890")
        XCTAssertEqual(bytes, frame.bytes)
    }
    func testDownloadRemoteBufferResponsePacket() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x20,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x5F,0x20,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.address, 0)
        XCTAssertEqual(frame.command, .downloadRemoteBuffer)
        XCTAssertEqual(frame.information.acknowledge, CommandInformation.ReceptionStatus.complete)
        XCTAssertEqual(frame.data, [0x00])
    }


}
