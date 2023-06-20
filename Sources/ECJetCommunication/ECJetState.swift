//
//  ECJetState.swift
//  
//
//  Created by Daniel Pink on 24/5/2023.
//

import Foundation

struct ECJetState {
    var printWidth: Double = 0.4
    var printInterval: Double = 0
    var printDelay: Double = 0
    var triggerRepeat: UInt8 = 0
    
    
    func handleRequest(frame: Frame) -> Frame {
        return Frame(command: .getDateTime)
    }
    
    func handleResponse(frame: Frame) {
        
    }
}
