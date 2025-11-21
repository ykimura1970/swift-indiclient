//
//  INDISocketError.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

enum INDISocketError: Error {
    case notReady
    case canBind
    case timeout
    case connectionResetByPeer
}
