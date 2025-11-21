//
//  INDITextProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Combine

public class INDITextProperty: INDIProperty, ObservableObject {
    // MARK: - Original Property
    @Published internal(set) public var text: String
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, text: String, parent: INDIVectorProperty? = nil) {
        self.text = text
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", text: "")
    }
    
    // MARK: - Original Method
    public func setText(_ text: String) {
        self.text = text
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDITextProperty(elementName: self.elementName, elementLabel: self.elementLabel, text: self.text, parent: self.parent)
    }
    
    public override func clear() {
        self.text = ""
        super.clear()
    }
}
