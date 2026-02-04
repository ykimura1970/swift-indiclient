//
//  INDISwitchState.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// Switch state.
public enum INDISwitchState: String, Sendable {
    case Off = "Off"
    case On = "On"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case Self.Off.rawValue.lowercased(): self = .Off
        case Self.On.rawValue.lowercased(): self = .On
        default: return nil
        }
    }
    
    public init(from boolValue: Bool) {
        switch boolValue {
        case false: self = .Off
        case true: self = .On
        }
    }
    
    func toString() -> String {
        self.rawValue
    }
    
    func toBool() -> Bool {
        switch self {
        case .Off: false
        case .On: true
        }
    }
}
