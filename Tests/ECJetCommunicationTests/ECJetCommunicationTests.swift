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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
        XCTAssertEqual(Frame.decodePrintCount(frame.data), 0x01A2)
    }
    
    func testDecodePrintWidth() throws {
        XCTAssertEqual(Frame.decodePrintWidth(data: [80,0,1]), 0.08, accuracy: Double.ulpOfOne)
        XCTAssertEqual(Frame.decodePrintWidth(data: [44,1,1]), 0.3, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [248,2,1]), 0.76, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [22,3,1]), 0.79, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [62,3,1]), 0.83, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [102,3,1]), 0.87, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [142,3,1]), 0.91, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintWidth(data: [232,253,1]), 65.0, accuracy: 0.001)
    }
    
    func testEncodePrintWidth() throws {
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.08), [80,0,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.3), [44,1,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.76), [248,2,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.79), [22,3,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.83), [62,3,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.87), [102,3,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 0.91), [142,3,1])
        XCTAssertEqual(try! Frame.encodePrintWidth(mm: 65.0), [232,253,1])
    }
    
    func testDecodePrintInterval() throws {
        XCTAssertEqual(Frame.decodePrintInterval(data: [238,132,0,0,1]), 34.03, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [172,17,1,0,1]), 70.06, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [94,102,3,1,1]), 17000.03, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [255,0,0,0,1]), 0.255, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [0,1,0,0,1]), 0.256, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [255,74,0,0,1]), 19.198, accuracy: 0.001)
        XCTAssertEqual(Frame.decodePrintInterval(data: [0,75,0,0,1]), 19.2, accuracy: 0.001)
    }
    
    func testEncodePrintInterval() throws {
        XCTAssertEqual(try! Frame.encodePrintInterval(mm: 34.03), [238,132,0,0,1])
        XCTAssertEqual(try! Frame.encodePrintInterval(mm: 70.06), [172,17,1,0,1])
        XCTAssertEqual(try! Frame.encodePrintInterval(mm: 17000.03), [94,102,3,1,1])
        XCTAssertEqual(try! Frame.encodePrintInterval(mm: 1.0), [232,3,0,0,1])
    }
    
    func testEncodePrintIntervalUInt8Overflow() throws {
        // This test highlights a bug with r2.truncatingRemainder(dividingBy: 0.256) for 19.2
        XCTAssertEqual(try! Frame.encodePrintInterval(mm: 19.2), [0,75,0,0,1])
    }
    
    func testDecodePrintDelay() throws {
        XCTAssertEqual(Frame.decodePrintDelay(data: [216, 71, 3, 0, 1]), 215.0, accuracy: 0.001)
    }
    
    func testEncodePrintDelay() throws {
        XCTAssertEqual(try! Frame.encodePrintDelay(mm: 215.0), [216, 71, 3, 0, 1])
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
        XCTAssertEqual(frame.data, [0xAA,0xAA,0x00,0xAE,0x83,0x0C,0x59,0x52,0x00,0x00])
    }
    
    func testStartJetPacket() throws {
        let frame = Frame(command: .startJet)
        let bytes: [UInt8] = [0x7E,0x00,0x16,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC3,0xA4,0x7F]
        XCTAssertEqual(bytes, frame.bytes)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
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
        XCTAssertEqual(frame.information.acknowledge, ReceptionStatus.complete)
        XCTAssertEqual(frame.data, [0x00])
    }
    
    func testDecodeFontList() throws {
        let data: [UInt8] = [41, 53, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 0, 55, 32, 72, 105, 103, 104, 67, 97, 112, 115, 73, 0, 0, 0, 0, 0, 55, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 0, 55, 32, 66, 101, 110, 103, 97, 108, 101, 115, 101, 0, 0, 0, 0, 0, 57, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 0, 57, 32, 66, 101, 110, 103, 97, 108, 101, 115, 101, 0, 0, 0, 0, 0, 49, 50, 32, 72, 105, 103, 104, 67, 97, 112, 115, 82, 0, 0, 0, 0, 49, 50, 32, 66, 101, 110, 103, 97, 108, 101, 115, 101, 0, 0, 0, 0, 49, 50, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 49, 54, 32, 72, 105, 103, 104, 70, 117, 108, 108, 0, 0, 0, 0, 0, 49, 54, 32, 66, 101, 110, 103, 97, 108, 101, 115, 101, 0, 0, 0, 0, 49, 54, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 50, 52, 32, 66, 101, 110, 103, 97, 108, 101, 115, 101, 0, 0, 0, 0, 50, 52, 32, 72, 105, 103, 104, 70, 117, 108, 108, 0, 0, 0, 0, 0, 50, 52, 32, 72, 105, 103, 104, 67, 97, 112, 115, 0, 0, 0, 0, 0, 51, 50, 32, 72, 105, 103, 104, 70, 117, 108, 108, 0, 0, 0, 0, 0, 57, 32, 67, 104, 105, 110, 101, 115, 101, 0, 0, 0, 0, 0, 0, 0, 49, 50, 32, 67, 104, 105, 110, 101, 115, 101, 0, 0, 0, 0, 0, 0, 49, 54, 32, 67, 104, 105, 110, 101, 115, 101, 0, 0, 0, 0, 0, 0, 50, 52, 32, 67, 104, 105, 110, 101, 115, 101, 0, 0, 0, 0, 0, 0, 55, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 0, 57, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 0, 49, 50, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 49, 54, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 50, 48, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 50, 52, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 51, 50, 32, 65, 114, 97, 98, 105, 99, 0, 0, 0, 0, 0, 0, 0, 49, 50, 32, 75, 111, 114, 101, 97, 0, 0, 0, 0, 0, 0, 0, 0, 49, 54, 32, 75, 111, 114, 101, 97, 0, 0, 0, 0, 0, 0, 0, 0, 50, 52, 32, 75, 111, 114, 101, 97, 0, 0, 0, 0, 0, 0, 0, 0, 55, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 49, 50, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 49, 53, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 49, 54, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 50, 49, 32, 70, 97, 114, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0, 57, 32, 67, 104, 105, 110, 101, 115, 101, 70, 0, 0, 0, 0, 0, 0, 49, 50, 32, 67, 104, 105, 110, 101, 115, 101, 70, 0, 0, 0, 0, 0, 49, 54, 32, 67, 104, 105, 110, 101, 115, 101, 70, 0, 0, 0, 0, 0, 50, 52, 32, 67, 104, 105, 110, 101, 115, 101, 70, 0, 0, 0, 0, 0, 55, 32, 67, 104, 105, 110, 101, 115, 101, 0, 0, 0, 0, 0, 0, 0]
        let frame = Frame(address: 0, command: .getFontList, information: CommandInformation(acknowledge: .complete), data: data)
        let decodedFontList: [String] = frame.decodeGetFontList()
        let actualFontList: [String] = ["5 HighCaps",
                                        "7 HighCapsI", "7 HighCaps", "7 Bengalese",
                                        "9 HighCaps", "9 Bengalese",
                                        "12 HighCapsR", "12 Bengalese", "12 HighCaps",
                                        "16 HighFull", "16 Bengalese", "16 HighCaps",
                                        "24 Bengalese", "24 HighFull", "24 HighCaps",
                                        "32 HighFull",
                                        "9 Chinese", "12 Chinese", "16 Chinese", "24 Chinese",
                                        "7 Arabic", "9 Arabic", "12 Arabic", "16 Arabic", "20 Arabic", "24 Arabic", "32 Arabic",
                                        "12 Korea", "16 Korea", "24 Korea",
                                        "7 Farsi", "9 Farsi", "12 Farsi", "15 Farsi", "16 Farsi", "21 Farsi",
                                        "9 ChineseF", "12 ChineseF", "16 ChineseF", "24 ChineseF", "7 Chinese"]
        XCTAssertEqual(decodedFontList, actualFontList)
    }
    
    func testDecodeMessageList() throws {
        let data: [UInt8] = [7, 0, 50, 48, 48, 48, 45, 67, 104, 117, 106, 105, 95, 69, 78, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 49, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 50, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 49, 54, 95, 51, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 53, 95, 49, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 105, 103, 104, 83, 112, 101, 101, 100, 95, 53, 95, 50, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 69, 83, 84, 46, 110, 109, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let frame = Frame(address: 0, command: .getMessageList, information: CommandInformation(acknowledge: .complete), data: data)
        let decodedMessageList = frame.decodeGetMessageList()
        let actualMessageList: [String] = ["2000-Chuji_EN.nmk", "HighSpeed_16_1.nmk", "HighSpeed_16_2.nmk", "HighSpeed_16_3.nmk", "HighSpeed_5_1.nmk", "HighSpeed_5_2.nmk", "TEST.nmk"]
        XCTAssertEqual(decodedMessageList, actualMessageList)
    }
    
    func testByteCapture() throws {
        let bytes:[UInt8] = [0x7E,0x00,0x20,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5D,0x7D,0x5E,0x7D,0x5F,0x79,0xE0,0x7F]
        let frame = Frame(bytes: bytes, verificationMethod: .crc16)!
        XCTAssertEqual(frame.data, [0x7D,0x7E,0x7F])
    }
    
    func testByteEscaping() throws {
        let frame1 = Frame(address: 0, command:.setTriggerRepeat, data: [0x7D])
        XCTAssertEqual(frame1.bytes, [0x7E,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5D,0xF3,0x34,0x7F])
        let frame2 = Frame(address: 0, command:.setTriggerRepeat, data: [0x7E])
        XCTAssertEqual(frame2.bytes, [0x7E,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5E,0x68,0x06,0x7F])
        let frame3 = Frame(address: 0, command:.setTriggerRepeat, data: [0x7F])
        XCTAssertEqual(frame3.bytes, [0x7E,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7D,0x5F,0xE1,0x17,0x7F])
    }
    
    func testPrintWidthStruct() throws {
        XCTAssertEqual(PrintWidth(bytes: (80,0,1)).mm, 0.08, accuracy: Double.ulpOfOne)
        XCTAssertEqual(PrintWidth(bytes: (44,1,1)).mm, 0.3, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (248,2,1)).mm, 0.76, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (22,3,1)).mm, 0.79, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (62,3,1)).mm, 0.83, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (102,3,1)).mm, 0.87, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (142,3,1)).mm, 0.91, accuracy: 0.001)
        XCTAssertEqual(PrintWidth(bytes: (232,253,1)).mm, 65.0, accuracy: 0.001)
        
        // Commented out becaused Tuples aren't able to be made Equatable
        //XCTAssertEqual(try! PrintWidth(mm: 0.08).bytes, (80,0,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.3).bytes, (44,1,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.76).bytes, (248,2,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.79).bytes, (22,3,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.83).bytes, (62,3,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.87).bytes, (102,3,1))
        //XCTAssertEqual(try! PrintWidth(mm: 0.91).bytes, (142,3,1))
        //XCTAssertEqual(try! PrintWidth(mm: 65.0).bytes, (232,253,1))
        
        let a = try! PrintWidth(mm: 0.08).bytes
        XCTAssertEqual(a.0, 80)
        XCTAssertEqual(a.1, 0)
        XCTAssertEqual(a.2, 1)
        
    }

}
