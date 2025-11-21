//
//  INDIPropertyPermission.swift
//  INDIClient
//
//  Created by 木村嘉男 on 2024/10/01.
//

import Foundation

/// Permission hint, with respective client.
public enum INDIPropertyPermission: Sendable {
    case ReadOnly
    case WriteOnly
    case ReadAndWrite
    
    static func propertyPermission(from stringPropertyPermission: String) -> INDIPropertyPermission? {
        switch stringPropertyPermission.lowercased() {
        case "ro": .ReadOnly
        case "wo": .WriteOnly
        case "rw": .ReadAndWrite
        default: nil
        }
    }
    
    func toString() -> String {
        switch self {
        case .ReadOnly: "ro"
        case .WriteOnly: "wo"
        case .ReadAndWrite: "rw"
        }
    }
}
