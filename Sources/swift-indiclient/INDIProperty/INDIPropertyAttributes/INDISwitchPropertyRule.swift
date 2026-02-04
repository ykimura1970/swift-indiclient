//
//  INDISwitchVectorPropertyRule.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDISwitchVectorProperty rule hint.
public enum INDISwitchVectorPropertyRule: String, Sendable {
    case OneOfMany = "OneOfMany"
    case AtMostOne = "AtMostOne"
    case AnyOfMany = "AnyOfMany"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case Self.OneOfMany.rawValue.lowercased(): self = .OneOfMany
        case Self.AtMostOne.rawValue.lowercased(): self = .AtMostOne
        case Self.AnyOfMany.rawValue.lowercased(): self = .AnyOfMany
        default: return nil
        }
    }
    
    func toString() -> String {
        self.rawValue
    }
}
