//
//  INDIWebManagerServerStatus.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/04.
//

import Foundation

/// Server Status Information.
public struct INDIWebManagerServerStatus: Codable, Sendable {
    public let status: String
    public let active_profile: String
}
