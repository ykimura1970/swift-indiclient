//
//  INDIPropertyState.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import SwiftUI

/// Property state.
public enum INDIPropertyState: Int, Sendable {
    case Idle = 0
    case Ok
    case Busy
    case Alert
    
    static func propertyState(from stringPropertyState: String) -> INDIPropertyState? {
        switch stringPropertyState.lowercased() {
        case "idle": .Idle
        case "ok": .Ok
        case "busy": .Busy
        case "alert": .Alert
        default: nil
        }
    }
    
    func toString() -> String {
        switch self {
        case .Idle: "Idle"
        case .Ok: "Ok"
        case .Busy: "Busy"
        case .Alert: "Alert"
        }
    }
    
    public func toColor() -> Color {
        switch self {
        case .Idle: .green
        case .Ok: .red
        case .Busy: .yellow
        case .Alert: .orange
        }
    }
}
