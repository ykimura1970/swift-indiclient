//
//  INDIBlobVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

final public class INDIBlobVectorProperty: INDIVectorPropertyTemplate<INDIBlobProperty>, @unchecked Sendable {
    // MARK: - Initializer
    public init() {
        super.init(deviceName: "", propertyName: "", propertyLabel: "", groupName: "", propertyPermission: .ReadOnly, timeout: 0.0, propertyState: .Idle, timestamp: "", propertyType: .INDIBlob)
    }
    
    // MARK: - Override Method
    public override func createNewCommand(newProperties: [Element]) -> String {
        let elementRoot = XMLElement(name: "newBLOBVector")
        elementRoot.addAttribute(createXMLAttribute(elementName: "device", stringValue: deviceName))
        elementRoot.addAttribute(createXMLAttribute(elementName: "name", stringValue: propertyName))
        
        if !timestamp.isEmpty {
            elementRoot.addAttribute(createXMLAttribute(elementName: "timestamp", stringValue: timestamp))
        }
        
        for property in newProperties {
            let elementChild = XMLElement(name: "oneBLOB")
            elementChild.addAttribute(createXMLAttribute(elementName: "name", stringValue: property.elementName))
            elementChild.addAttribute(createXMLAttribute(elementName: "size", stringValue: "\(property.size)"))
            
            if property.size == 0 {
                elementChild.addAttribute(createXMLAttribute(elementName: "enclen", stringValue: "0"))
                elementChild.addAttribute(createXMLAttribute(elementName: "format", stringValue: property.format))
            } else {
                let data = property.blob.base64EncodedData()
                elementChild.stringValue = String(data: data, encoding: .ascii)
                elementChild.addAttribute(createXMLAttribute(elementName: "enclen", stringValue: "\(data.count)"))
                elementChild.addAttribute(createXMLAttribute(elementName: "format", stringValue: property.format))
            }
            elementRoot.addChild(elementChild)
        }
        
        return elementRoot.xmlString
    }
}
