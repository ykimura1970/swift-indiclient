//
//  INDIElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

public class INDIElement: NSObject, Identifiable, @unchecked Sendable {
    // MARK: - Fundamental Property
    internal var _elementName: String
    internal var _elementLabel: String
    internal var _parent: INDIProperty?
    internal let _lock: NIOLock = NIOLock()
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", parent: INDIProperty? = nil) {
        self._elementName = elementName
        self._elementLabel = elementLabel
        self._parent = parent
    }
    
    // MARK: - Computed Property
    public var elementName: String {
        get {
            self._elementName
        }
    }
    
    public var elementLabel: String {
        get {
            self._elementLabel
        }
    }
    
    // MARK: - Fundamental Method
    public func setParent(_ parent: INDIProperty) {
        self._parent = parent
    }
    
    public func setElementName(_ name: String) {
        self._elementName = name
    }
    
    public func setElementLabel(_ label: String) {
        self._elementLabel = label
    }
    
    public func getElementName() -> String {
        self.elementName
    }
    
    public func getElementLabel() -> String {
        self.elementLabel
    }
    
    public func isElementNameMatch(_ otherName: String) -> Bool {
        self._elementName == otherName
    }
    
    public func isElementLabelMatch(_ otherLabel: String) -> Bool {
        self._elementLabel == otherLabel
    }
    
    public func clear() {
        self._elementName = ""
        self._elementLabel = ""
        self._parent = nil
    }
}
