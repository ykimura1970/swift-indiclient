//
//  INDIBlobMode.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/19.
//

import Foundation

public struct INDIBlobMode: Sendable {
    var device: String
    var propertyName: String
    var blobHandling: INDIBlobHandling
}
