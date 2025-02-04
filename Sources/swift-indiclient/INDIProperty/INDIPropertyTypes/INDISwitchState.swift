//
//  INDISwitchState.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// Switch state.
public enum INDISwitchState: Int, Sendable {
    case Off = 0
    case On
    
    static func switchState(from stringSwitchState: String) -> INDISwitchState? {
        switch stringSwitchState.lowercased() {
        case "off": .Off
        case "on": .On
        default: nil
        }
    }
    
    static func switchState(from boolValue: Bool) -> INDISwitchState {
        switch boolValue {
        case false: .Off
        case true: .On
        }
    }
    
    func toString() -> String {
        switch self {
        case .Off: "Off"
        case .On: "On"
        }
    }
    
    func toBool() -> Bool {
        switch self {
        case .Off: false
        case .On: true
        }
    }
}
