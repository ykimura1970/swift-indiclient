//
//  INDIPropertyState.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import SwiftUI

/// Property state.
public enum INDIPropertyState: String, Sendable {
    case Idle = "Idle"
    case Ok = "Ok"
    case Busy = "Busy"
    case Alert = "Alert"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case Self.Idle.rawValue.lowercased(): self = .Idle
        case Self.Ok.rawValue.lowercased(): self = .Ok
        case Self.Busy.rawValue.lowercased(): self = .Busy
        case Self.Alert.rawValue.lowercased(): self = .Alert
        default: return nil
        }
    }
    
    func toString() -> String {
        self.rawValue
    }
}
