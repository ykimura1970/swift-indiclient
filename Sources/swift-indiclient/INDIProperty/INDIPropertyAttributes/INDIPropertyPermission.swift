//
//  INDIPropertyPermission.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// Permission hint, with respective client.
public enum INDIPropertyPermission: String, Sendable {
    case ReadOnly = "ro"
    case WriteOnly = "wo"
    case ReadAndWrite = "rw"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case Self.ReadOnly.rawValue: self = .ReadOnly
        case Self.WriteOnly.rawValue: self = .WriteOnly
        case Self.ReadAndWrite.rawValue: self = .ReadAndWrite
        default: return nil
        }
    }
    
    func toString() -> String {
        self.rawValue
    }
}
