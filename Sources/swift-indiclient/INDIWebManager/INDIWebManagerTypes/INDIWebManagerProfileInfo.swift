//
//  INDIWebManagerProfileInfo.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/04.
//

import Foundation

/// Profile Information.
public struct INDIWebManagerProfileInfo: Codable, Hashable, Sendable {
    public var id: Int
    public var name: String
    public var port: UInt16
    public var autostart: Int
    public var autoconnect: Int
    
    public init(id: Int, name: String, port: UInt16, autostart: Int, autoconnect: Int) {
        self.id = id
        self.name = name
        self.port = port
        self.autostart = autostart
        self.autoconnect = autoconnect
    }
    
    public init() {
        self.init(id: -1, name: "", port: 8624, autostart: 0, autoconnect: 0)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case port
        case autostart
        case autoconnect
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(port, forKey: .port)
        try container.encode(autostart, forKey: .autostart)
        try container.encode(autoconnect, forKey: .autoconnect)
    }
}
