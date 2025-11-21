//
//  INDISwitchVectorPropertyRule.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDISwitchVectorProperty rule hint.
public enum INDISwitchVectorPropertyRule: Sendable {
    case OneOfMany
    case AtMostOne
    case AnyOfMany
    
    static func  switchVectorPropertyRule(from stringSwitchVectorPropertyRule: String) -> INDISwitchVectorPropertyRule? {
        switch stringSwitchVectorPropertyRule.lowercased() {
        case "oneofmany": .OneOfMany
        case "atmostone": .AtMostOne
        case "anyofmany": .AnyOfMany
        default: nil
        }
    }
    
    func toString() -> String {
        switch self {
        case .OneOfMany: "OneOfMany"
        case .AtMostOne: "AtMostOne"
        case .AnyOfMany: "AnyOfMany"
        }
    }
}
