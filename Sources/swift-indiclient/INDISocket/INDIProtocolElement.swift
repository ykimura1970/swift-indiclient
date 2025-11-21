//
//  INDIProtocolElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/12/22.
//

import Foundation

public struct INDIProtocolElement: Sendable {
    // MARK: - Fundamental Property
    public var tagName: String
    public var attributes: [String : String]
    public var children: [INDIProtocolElement]
    public var stringValue: String
    public var blobData: Data
    
    // MARK: - Initializer
    public init(tagName: String, stringValue: String, blobData: Data = Data()) {
        self.tagName = tagName
        self.attributes = [:]
        self.children = []
        self.stringValue = stringValue
        self.blobData = blobData
    }
    
    public init() {
        self.init(tagName: "", stringValue: "")
    }
    
    // MARK: - Fundamental Method
    mutating public func setAttribute(key: String, value: String) {
        attributes[key] = value
    }
    
    mutating public func setChildElement(element: INDIProtocolElement) {
        children.append(element)
    }
}
