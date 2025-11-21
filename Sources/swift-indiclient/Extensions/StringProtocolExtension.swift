//
//  File.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

public extension StringProtocol {
    func isAllWhitespace() -> Bool {
        unicodeScalars.allSatisfy(CharacterSet.whitespacesAndNewlines.contains(_:))
    }
}
