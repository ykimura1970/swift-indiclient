//
//  INDIPropertyType.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDI Property type.
public enum INDIPropertyType: Sendable{
    case INDINumber
    case INDISwitch
    case INDIText
    case INDILight
    case INDIBlob
    case INDIUnknown
    
    func toString() -> String {
        switch self {
        case .INDINumber: "INDINumber"
        case .INDISwitch: "INDISwitch"
        case .INDIText: "INDIText"
        case .INDILight: "INDILight"
        case .INDIBlob: "INDIBlob"
        case .INDIUnknown: "INDIUnknown"
        }
    }
}
