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
}
