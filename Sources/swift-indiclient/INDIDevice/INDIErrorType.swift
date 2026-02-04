//
//  INDIErrorType.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2026/02/03.
//

import Foundation

public enum INDIErrorType: Int, Sendable {
    case DeviceNotFound     = -1        // Device not found error.
    case PropertyInvalid    = -2        // Property invalid error.
    case PropertyDuplicated = -3        // Property duplicated error.
    case DispatchError      = -4        // Dispatch error.
}
