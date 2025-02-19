//
//  INDITextProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation

@Observable
final public class INDITextProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var text: String
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, text: String) {
        self.text = text
        super.init(elementName: elementName, elementLabel: elementLabel)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", text: "")
    }
    
    // MARK: - Computed Property
    public var vectorProperty: INDITextVectorProperty? {
        get {
            parent as? INDITextVectorProperty
        }
    }
    
    // MARK: - Protocol Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        return INDITextProperty(elementName: self.elementName, elementLabel: self.elementLabel, text: self.text)
    }
    
    // MARK: - Original Method
    public func setText(_ text: String) {
        self.text = text
    }
    
    // MARK: - Override Method
    public override func clear() {
        text = ""
        super.clear()
    }
}
