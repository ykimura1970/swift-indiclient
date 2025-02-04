//
//  INDINumberVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec on 2024/11/27.
//

import Foundation

final public class INDINumberVectorProperty: INDIVectorPropertyTemplate<INDINumberProperty>, @unchecked Sendable {
    // MARK: - Initialiazer
    public init() {
        super.init(deviceName: "", propertyName: "", propertyLabel: "", groupName: "", propertyPermission: .ReadOnly, timeout: 0.0, propertyState: .Idle, timestamp: "", propertyType: .INDINumber)
    }
    
    // MARK: - Override Method
    public override func createNewCommand(newProperties: [Element]) -> String {
        let elementRoot = XMLElement(name: "newNumberVector")
        elementRoot.addAttribute(createXMLAttribute(elementName: "device", stringValue: deviceName))
        elementRoot.addAttribute(createXMLAttribute(elementName: "name", stringValue: propertyName))
        
        for property in newProperties {
            let elementChild = XMLElement(name: "oneNumber")
            elementChild.stringValue = String(property.value)
            elementChild.addAttribute(createXMLAttribute(elementName: "name", stringValue: property.elementName))
            elementRoot.addChild(elementChild)
        }
        
        return elementRoot.xmlString
    }
}
