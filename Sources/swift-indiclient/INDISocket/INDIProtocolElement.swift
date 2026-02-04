//
//  INDIProtocolElement.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/12/22.
//

import Foundation

public struct INDIProtocolElement: Equatable, Sendable {
    public struct Attribute: Equatable, Sendable {
        let key: String
        let value: String
    }
    
    // MARK: - Fundamental Property
    public let tagName: String
    private(set) var stringValue: String?
    private(set) var children: [INDIProtocolElement] = []
    private(set) var attributes: [Attribute] = []
    
    // MARK: - Computed Property
    public var device: String? {
        get {
            self.attributes.first(where: { $0.key == "device" })?.value
        }
    }
    
    public var name: String? {
        get {
            self.attributes.first(where: { $0.key == "name" })?.value
        }
    }
    
    public var state: String? {
        get {
            self.attributes.first(where: { $0.key == "state" })?.value
        }
    }
    
    // MARK: - Fundamental Method
    public mutating func addChild(child: INDIProtocolElement) {
        self.children.append(child)
    }
    
    public mutating func addChildren(contentOf children: [INDIProtocolElement]) {
        self.children.append(contentsOf: children)
    }
    
    public mutating func addAttribute(attribute: Attribute) {
        self.attributes.append(attribute)
    }
    
    public mutating func addStringValue(string: String) {
        if self.stringValue == nil {
            self.stringValue = string
        } else {
            self.stringValue! += string
        }
    }
    
    public func getAttributeValue(_ key: String) -> String? {
        self.attributes.first(where: { $0.key == key })?.value
    }
    
    public func isWhitespaceWithNoElements() -> Bool {
        let stringValueInWhitespaceOrNil = self.stringValue?.isAllWhitespace() ?? true
        return self.tagName.isEmpty && stringValueInWhitespaceOrNil && self.children.isEmpty
    }
    
    public func createXMLString() -> String {
        var xmlString: String = ""
        
        xmlString += "<\(self.tagName)"
        for attribute in self.attributes {
            xmlString += " \(attribute.key)='\(attribute.value)'"
        }
        
        if self.children.isEmpty {
            if let stringValue {
                xmlString += ">\n      \(stringValue)\n"
            } else {
                xmlString += "/>\n"
                return xmlString
            }
        } else {
            xmlString += ">\n"
            for child in children {
                xmlString += child.createXMLString()
            }
        }
        
        xmlString += "</\(tagName)>\n"
        
        return xmlString
    }
}
