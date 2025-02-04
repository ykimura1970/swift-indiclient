//
//  INDIBlobHandling.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/02.
//

import Foundation

public enum INDIBlobHandling: Int, Sendable {
    case Never = 0
    case Also
    case Only
    
    public func toString() -> String {
        switch self {
        case .Never: "Never"
        case .Also: "Also"
        case .Only: "Only"
        }
    }
}
