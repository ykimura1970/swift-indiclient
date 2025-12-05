//
//  INDIProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

public class INDIProperty: NSObject, NSCopying, Identifiable, @unchecked Sendable {
    // MARK: - Fundamental Property
    internal var elementName: String
    internal var elementLabel: String
    internal var parent: INDIVectorProperty?
    internal let lock: NIOLock = NIOLock()
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", parent: INDIVectorProperty? = nil) {
        self.elementName = elementName
        self.elementLabel = elementLabel
        self.parent = parent
    }

    // MARK: - Protocol Method
    public func copy(with zone: NSZone? = nil) -> Any {
        INDIProperty(elementName: self.elementName, elementLabel: self.elementLabel, parent: self.parent)
    }
    
    // MARK: - Fundamental Method
    public func setParent(_ parent: INDIVectorProperty) {
        self.parent = parent
    }
    
    public func setElementName(_ name: String) {
        self.elementName = name
    }
    
    public func setElementLabel(_ label: String) {
        self.elementLabel = label
    }
    
    public func getElementName() -> String {
        self.elementName
    }
    
    public func getElementLabel() -> String {
        self.elementLabel
    }
    
    public func isElementNameMatch(_ otherName: String) -> Bool {
        self.elementName == otherName
    }
    
    public func isElementLabelMatch(_ otherLabel: String) -> Bool {
        self.elementLabel == otherLabel
    }
    
    public func clear() {
        self.elementName = ""
        self.elementLabel = ""
        self.parent = nil
    }
}
