//
//  INDIBlobVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

final public class INDIBlobVectorProperty: INDIVectorPropertyTemplate<INDIBlobProperty> {
    // MARK: - Override Method
    internal override func createNewCommand() -> INDIProtocolElement {
        var root = createNewRootINDIProtocolElement()
        let children = createNewChildrenINDIProtocolElement()
        
        if !children.isEmpty {
            root.addChildren(contentOf: children)
        }
        
        return root
    }
    
    internal override func createNewRootINDIProtocolElement() -> INDIProtocolElement {
        var root = INDIProtocolElement(tagName: "newBLOBVector")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        
        if !timestamp.isEmpty {
            root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "timestamp", value: timestamp))
        }
        
        return root
    }
    
    internal override func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] {
        var children = [INDIProtocolElement]()
        
        self.properties.forEach({ property in
            var child = INDIProtocolElement(tagName: "oneBLOB")
            child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
            child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "size", value: String(format: "%d", property.size)))
            
            if property.size == 0 {
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "enclen", value: "0"))
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "format", value: property.format))
            } else {
                let data = property.blob.base64EncodedString()
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "enclen", value: String(format: "%d", data.count)))
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "format", value: property.format))
                child.addStringValue(string: data)
            }
            
            children.append(child)
        })
        
        return children
    }
}
