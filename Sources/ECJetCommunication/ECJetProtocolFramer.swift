//
//  ECJetProtocolFramer.swift
//  RequestResponse
//
//  Created by Daniel Pink on 28/7/2023.
//

import Foundation
import Network

@available(iOS 13.0, *)
final class ECJetProtocol: NWProtocolFramerImplementation {

    static let definition = NWProtocolFramer.Definition(implementation: ECJetProtocol.self)

    static let label = "ECJetFrames"
    
    init(framer: NWProtocolFramer.Instance) {}
    
    func start  (framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { return .ready }
    func stop   (framer: NWProtocolFramer.Instance) -> Bool { return true }
    func wakeup (framer: NWProtocolFramer.Instance) {}
    func cleanup(framer: NWProtocolFramer.Instance) {}

    func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        while true {
            var parsedMessage: (messages: [[UInt8]], size: Int)?
            //print("Handle Input \(framer)")
            let didParse = framer.parseInput(minimumIncompleteLength: 1, maximumLength: 16_000) { buffer, isComplete in
                parsedMessage = parseMessage(from: buffer)
                //print(buffer)
                return 0
            }
            
            guard didParse, let (messages, size) = parsedMessage else {
                return 0 // need more data
            }
            //print(messages)
            
            let metaData = NWProtocolFramer.Message(definition: Self.definition)
            metaData["messages"] = messages
            
            _ = framer.deliverInputNoCopy(length: size, message: metaData, isComplete: true)
        }
    }
    
    func parseMessage(from buffer: UnsafeMutableRawBufferPointer?) -> (messages: [[UInt8]], size: Int)? {
        guard let buffer = buffer else { return nil }
        
        let STX = 0x7E as UInt8
        let ETX = 0x7F as UInt8
        guard let lastEndByte = buffer.lastIndex(of: ETX) else {
            return nil // need more data
        }
        
        let slice = buffer[...lastEndByte]
        
        let messages = splitArrayByDelimiter(arr: [UInt8](slice), delimiter: ETX)
        
        return (messages: messages, size: lastEndByte + 1)
    }
    
    func handleOutput(framer     : NWProtocolFramer.Instance,
                      message    : NWProtocolFramer.Message,
                      messageLength: Int,
                      isComplete : Bool) {
        //print("handleOutput \(message)")
        guard let messages = message["messages"] as? [[UInt8]] else {
            return try! framer.writeOutputNoCopy(length: messageLength)
        }
        
        for message in messages {
            framer.writeOutput(data: message)
        }
        
    }
}


func splitArrayByDelimiter(arr: [UInt8], delimiter: UInt8) -> [[UInt8]] {
    var result: [[UInt8]] = []
    var currentSection: [UInt8] = []
    
    for byte in arr {
        currentSection.append(byte)
        
        if byte == delimiter {
            result.append(currentSection)
            currentSection.removeAll()
        }
    }
    
    // Add the last section if it doesn't end with the delimiter
    if !currentSection.isEmpty {
        result.append(currentSection)
    }
    
    return result
}
