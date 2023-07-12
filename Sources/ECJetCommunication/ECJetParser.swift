//
//  ECJetParser.swift
//  
//
//  Created by Daniel Pink on 11/7/2023.
//

import Foundation

enum Fragment {
    //case prelude([UInt8])
    case token([UInt8])
    case unprocessed([UInt8])
    case aftermath([UInt8])
}

public class Tokenizer {
    var buffer: [UInt8] = []
    
    public init() {}
    
    func process(input: [UInt8]) -> (Fragment?, Fragment) {
        let messageStart = input.firstIndex(of: 126)
        let messageFinish = input.firstIndex(of: 127)
        
        switch (messageStart, messageFinish) {
        case (nil, nil):
            // There is no message
            // return everything so that it can be kept for more data
            return (nil, .aftermath(input))
        case (.some(let start), .some(let finish)):
            // There is at least one complete message
            // return the message and everything after.
            if(finish > start) {
                return (Fragment.token([UInt8](input[start...finish])), .unprocessed([UInt8](input[(finish + 1)...])))
            } else {
                return (nil, .unprocessed([UInt8](input[(finish + 1)...])))
            }
            // Need to also check that there is nothing before the message
        case (.some(let start), nil):
            // We don't have a complete message yet
            // Return everything after the start of the message
            return (nil, .aftermath([UInt8](input[start...])))
        case (nil, .some(let finish)):
            // Tail end of a message
            // throw out the start and return everything after the malformed message.
            return (nil, .unprocessed([UInt8](input[(finish + 1)...])))
        }
    }
    
    public func next() -> [UInt8]? {
        var processing: Bool = true
        var token:[UInt8]? = nil
        
        while processing {
            switch process(input: self.buffer) {
            case (nil, .unprocessed(let u)):
                self.buffer = u
            case (nil, .aftermath(let a)):
                self.buffer = a
                processing = false
            case (.token(let t), .unprocessed(let u)):
                self.buffer = u
                processing = false
                token = t
            default:
                processing = false
            }
        }
        
        return token
    }
    
    public func append(input: [UInt8]) {
        self.buffer = self.buffer + input
    }
}

