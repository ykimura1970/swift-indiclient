//
//  INDIProtocolElement.swift
//  INDIClient
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
    private(set) public var stringValue: String?
    private(set) public var children: [INDIProtocolElement] = []
    private(set) public var attributes: [Attribute] = []
    
    // MARK: - Computed Property
    public var device: String? {
        get {
            getAttribute(name: "device")
        }
    }
    
    public var name: String? {
        get {
            getAttribute(name: "name")
        }
    }
    
    public var state: String? {
        get {
            getAttribute(name: "state")
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
        self.stringValue = string
    }
    
    public func getAttribute(name: String) -> String? {
        attributes.first(where: { $0.key == name })?.value
    }
    
    public func isAnswerBack(request: INDIProtocolElement) -> Bool {
        guard let requestDevice = request.device, let requestName = request.name else { return false }
        guard let responseDevice = device, let responseName = name else { return false }
        
        if requestDevice == responseDevice && requestName == responseName && (state == INDIPropertyState.Ok.toString() || state == INDIPropertyState.Alert.toString()) {
            return state == INDIPropertyState.Ok.toString()
        }
        return false
    }
    
    public func isWhitespaceWithNoElements() -> Bool {
        let stringValueInWhitespaceOrNil = stringValue?.isAllWhitespace() ?? true
        return self.tagName == "" && stringValueInWhitespaceOrNil && self.children.isEmpty
    }
    
    public func createXMLString() -> String {
        var xmlString: String = ""
        
        xmlString += "<\(tagName)"
        for attribute in attributes {
            xmlString += " \(attribute.key)='\(attribute.value)'"
        }
        
        if children.isEmpty {
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
