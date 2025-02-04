//
//  INDIWebManagerDriverInfo.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/04.
//

import Foundation

/// Driver Information.
public struct INDIWebManagerDriverInfo: Codable, Hashable, Sendable {
    public let name: String
    public let label: String
    public let skeleton: String?
    public let version: String
    public let binary: String
    public let family: String
    public let custom: Bool
    
    public init(name: String, label: String, skeleton: String?, version: String, binary: String, family: String, custom: Bool) {
        self.name = name
        self.label = label
        self.skeleton = skeleton
        self.version = version
        self.binary = binary
        self.family = family
        self.custom = custom
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case label
        case skeleton
        case version
        case binary
        case family
        case custom
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(label, forKey: .label)
    }
}
