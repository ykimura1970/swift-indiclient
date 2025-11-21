//
//  INDINumberVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec on 2024/11/27.
//

import Foundation

final public class INDINumberVectorProperty: INDIVectorPropertyTemplate<INDINumberProperty> {
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copiedProperty = self.properties.map({ $0.copy() as! INDINumberProperty })
        
        let newNumberVectorProperty = INDINumberVectorProperty(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, dynamic: self.dynamic)
        newNumberVectorProperty.appendProperties(contentOf: copiedProperty)
        
        return newNumberVectorProperty
    }
    
    internal override func createNewCommand() -> INDIProtocolElement {
        var root = createNewRootINDIProtocolElement()
        let children = createNewChildrenINDIProtocolElement()
        
        if !children.isEmpty {
            root.addChildren(contentOf: children)
        }
        
        return root
    }
    
    internal override func createNewRootINDIProtocolElement() -> INDIProtocolElement {
        var root = INDIProtocolElement(tagName: "newNumberVector")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        
        return root
    }
    
    internal override func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] {
        var children = [INDIProtocolElement]()
        
        self.properties.forEach({ property in
            var element = INDIProtocolElement(tagName: "oneNumber")
            element.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
            element.addStringValue(string: String(format: "      %.20g", property.value))
            children.append(element)
        })
        
        return children
    }
}
