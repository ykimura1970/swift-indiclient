//
//  INDIErrorType.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDI error type.
public enum INDIErrorType: Int {
    case DeviceNotFound = -1
    case PropertyInvalid = -2
    case PropertyDuplicated = -3
    case DispatchError = -4
}
