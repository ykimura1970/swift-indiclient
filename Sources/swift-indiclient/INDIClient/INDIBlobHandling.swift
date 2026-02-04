//
//  INDIBlobHandling.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/02.
//

import Foundation

public enum INDIBlobHandling: String, Sendable {
    case Never = "Never"        // Never receive BLOBs
    case Also = "Also"          // Receive BLOBs along with normal messages.
    case Only = "Only"          // Only receive BLOBs from drivers, ignore all other traffic.
    
    public func toString() -> String {
        self.rawValue
    }
}
