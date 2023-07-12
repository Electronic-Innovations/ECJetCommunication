//
//  ECJetParserTests.swift
//  
//
//  Created by Daniel Pink on 11/7/2023.
//

import XCTest
@testable import ECJetCommunication

final class ECJetParserTests: XCTestCase {
    
    func testNext() throws {
        // Two packets in one buffer
        let data: [UInt8] = [126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127, 126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60, 127]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1!, [126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127])
        XCTAssertEqual(packet2!, [126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60, 127])
        XCTAssertEqual(tokenizer.buffer, [])
    }
    
    func testNext1() throws {
        // Incomplete packet followed by a good packet
        let data: [UInt8] = [0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127, 126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60, 127]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1, Optional([126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60, 127]))
        XCTAssertEqual(packet2, nil)
        XCTAssertEqual(tokenizer.buffer, [])
    }
    func testNext2() throws {
        // Good packet followed by an incomplete packet
        let data: [UInt8] = [126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127, 126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1, Optional([126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127]))
        XCTAssertEqual(packet2, nil)
        XCTAssertEqual(tokenizer.buffer, [126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60])
    }
    func testNext3() throws {
        // Incomplete packet, good packet, incomplete packet
        let data: [UInt8] = [127, 126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127, 126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1, Optional([126, 0, 20, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 225, 15, 127]))
        XCTAssertEqual(packet2, nil)
        XCTAssertEqual(tokenizer.buffer, [126, 0, 15, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 189, 60])
    }
    func testNext4() throws {
        // Incomplete packet
        let data: [UInt8] = [0, 20, 0, 12]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1, nil)
        XCTAssertEqual(packet2, nil)
        XCTAssertEqual(tokenizer.buffer, [0, 20, 0, 12])
    }
    func testNext5() throws {
        // End of a packet and garbage
        let data: [UInt8] = [225, 15, 127, 0, 20, 0, 12]
        let tokenizer = Tokenizer()
        tokenizer.append(input: data)
        let packet1 = tokenizer.next()
        let packet2 = tokenizer.next()
        XCTAssertEqual(packet1, nil)
        XCTAssertEqual(packet2, nil)
        XCTAssertEqual(tokenizer.buffer, [0, 20, 0, 12])
    }
}
