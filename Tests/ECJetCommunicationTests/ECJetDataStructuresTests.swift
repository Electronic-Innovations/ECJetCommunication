import XCTest
@testable import ECJetCommunication

final class ECJetDataStructuresTests: XCTestCase {
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
        XCTAssertEqual(try! PrintDelay(bytes: [216, 71, 3, 0, 1]).mm, 215.0, accuracy: 0.001)
    }
    
    func testEncodePrintDelay() throws {
        XCTAssertEqual(try! Frame.encodePrintDelay(mm: 215.0), [216, 71, 3, 0, 1])
        XCTAssertEqual(try! PrintDelay(mm: 215.0).bytes, [216, 71, 3, 0, 1])
    }
    
    func testPrintHeight() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x07,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x96,0x79,0x65,0x7F],
                                        verificationMethod: .crc16)!
        let printHeight = try! PrintHeight(bytes: frame.data)
        XCTAssertEqual(printHeight.mm, 150.0, accuracy: 0.01)
    }
    
    func testPrintCount() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x09,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x0C,0x00,0x00,0x00,0xAE,0x8B,0x7F], verificationMethod: .crc16)
        let printCount = try! PrintCount(bytes: frame!.data)
        XCTAssertEqual(printCount.type, .editingData)
        XCTAssertEqual(printCount.count, 12)
        
        let getFrame = Frame(bytes: [0x7E,0x00,0x0A,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0xA2,0x01,0x00,0x00,0xB3,0x61,0x7F], verificationMethod: .crc16)
        let printCount2 = try! PrintCount(type: .editingData, bytes: getFrame!.data)
        XCTAssertEqual(printCount2.type, .editingData)
        XCTAssertEqual(printCount2.count, 418)
    }
    
    func testReverseMessage() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x0B,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x01,0x5B,0x60,0x7F], verificationMethod: .crc16)
        let reverseMessage = try! ReverseMessage(bytes: frame!.data)
        XCTAssertEqual(reverseMessage.horizontal, .flipped)
        XCTAssertEqual(reverseMessage.vertical, .flipped)
        
        let frame2 = Frame(bytes: [0x7E,0x00,0x0C,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0xDF,0xC5,0x7F], verificationMethod: .crc16)
        let reverseMessage2 = try! ReverseMessage(bytes: frame2!.data)
        XCTAssertEqual(reverseMessage2.horizontal, .normal)
        XCTAssertEqual(reverseMessage2.vertical, .flipped)
    }
    
    func testTriggerRepeat() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x0D,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x18,0x8D,0x7F],verificationMethod: .crc16)
        let triggerRepeat = try! TriggerRepeat(bytes: frame!.data)
        XCTAssertEqual(triggerRepeat.count, 1)
    }
    
    func testPrinterStatus() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x0F,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0xC8,0x3A,0x7F], verificationMethod: .crc16)
        let status = try! PrinterStatus(bytes: frame!.data)
        XCTAssertEqual(status.status, .jetStop)
        XCTAssertEqual(status.warningStatus, 0)
    }
    
    func testPrintHeadCode() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x11,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x31,0x32,0x31,0x30,0x38,0x30,0x31,0x30,0x30,0x30,0x31,0x37,0x30,0x31,0x55,0x9F,0x7F], verificationMethod: .crc16)
        let printHeadCode = try! PrintHeadCode(bytes: frame!.data)
        XCTAssertEqual(printHeadCode.code, "12108010001701")
    }
    
    func testPhotocellMode() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x12,0x00,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0xA6,0x33,0x7F], verificationMethod: .crc16)
        let photocellMode = try! PhotocellMode(bytes: frame!.data)
        XCTAssertEqual(photocellMode.mode, .remote)
    }
    
    func testJetStatus() throws {
        let frame = Frame(bytes: [0x7E,0x00,0x14,0x00,0x0C,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0xAA,0xAA,0x00,0xAE,0x83,0x0C,0x59,0x52,0x00,0x00,0xE9,0x09,0x7F], verificationMethod: .crc16)
        let jetStatus = try! JetStatus(bytes: frame!.data)
        XCTAssertEqual(jetStatus.referencePressure, 0xAA)
        XCTAssertEqual(jetStatus.setPressure, 0xAA)
        XCTAssertEqual(jetStatus.readPressure, 0x00)
        XCTAssertEqual(jetStatus.solventAddition, 0xAE)
        XCTAssertEqual(jetStatus.modulation, 0x83)
        XCTAssertEqual(jetStatus.phase, 0x0C)
        XCTAssertEqual(jetStatus.referenceInkSpeed, 0x5952)
        XCTAssertEqual(jetStatus.inkSpeed, 0x0000)
    }
}
