//
//  INDIWebManagerProfile.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/04.
//

import Foundation

/// Driver labels of specific profile.
public struct INDIWebManagerProfile: Codable, Hashable, Sendable {
    public var profileInfo: INDIWebManagerProfileInfo
    public var useDriverLabels: [String]
    
    public init(profileInfo: INDIWebManagerProfileInfo, useDriverLabels: [String] = []) {
        self.profileInfo = profileInfo
        self.useDriverLabels = useDriverLabels
    }
    
    public init() {
        self.init(profileInfo: INDIWebManagerProfileInfo())
    }
}
