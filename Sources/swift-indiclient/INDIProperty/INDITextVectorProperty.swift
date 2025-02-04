//
//  INDITextVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

final public class INDITextVectorProperty: INDIVectorPropertyTemplate<INDITextProperty>, @unchecked Sendable {
    // MARK: - Initializer
    public init() {
        super.init(deviceName: "", propertyName: "", propertyLabel: "", groupName: "", propertyPermission: .ReadOnly, timeout: 0.0, propertyState: .Idle, timestamp: "", propertyType: .INDIText)
    }
    
    // MARK: - Override Method
    public override func createNewCommand(newProperties: [Element]) -> String {
        let elementRoot = XMLElement(name: "newTextVector")
        elementRoot.addAttribute(createXMLAttribute(elementName: "device", stringValue: deviceName))
        elementRoot.addAttribute(createXMLAttribute(elementName: "name", stringValue: propertyName))
        
        for property in newProperties {
            let elementChild = XMLElement(name: "oneText")
            elementChild.stringValue = property.text
            elementChild.addAttribute(createXMLAttribute(elementName: "name", stringValue: property.elementName))
            elementRoot.addChild(elementChild)
        }
        
        return elementRoot.xmlString
    }
}
