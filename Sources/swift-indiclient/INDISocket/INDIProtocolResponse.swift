//
//  INDIProtocolResponse.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

struct INDIProtocolResponse: Sendable {
    var result: Bool = false
    var error: INDISocketError?
}
