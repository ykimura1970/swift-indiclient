//
//  INDIProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

public class INDIProperty: NSCopying, Identifiable, @unchecked Sendable {
    // MARK: - Fundamental Property
    private(set) public var elementName: String
    private(set) public var elementLabel: String
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String) {
        self.elementName = elementName
        self.elementLabel = elementLabel
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "")
    }
    
    // MARK: - Protocol Method
    public func copy(with zone: NSZone? = nil) -> Any {
        INDIProperty(elementName: self.elementName, elementLabel: self.elementLabel)
    }
    
    // MARK: - Fundamental Method
    public func setElementName(_ name: String) {
        self.elementName = name
    }
    
    public func setElementLabel(_ label: String) {
        elementLabel = label
    }
    
    public func isElementNameMatch(_ otherName: String) -> Bool {
        elementName == otherName
    }
    
    public func isElementLabelMatch(_ otherLabel: String) -> Bool {
        elementLabel == otherLabel
    }
    
    public func clear() {
        elementName = ""
        elementLabel = ""
    }
}
