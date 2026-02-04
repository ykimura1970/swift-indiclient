//
//  INDINumberProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec on 2024/11/27.
//

import Foundation

final public class INDINumberProperty: INDIPropertyTemplate<INDINumberElement>, NSCopying, @unchecked Sendable {
    // MARK: - Original Method
    public func clone() -> INDINumberProperty {
        copy() as! INDINumberProperty
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        var copiedElements = [INDINumberElement]()
        
        self._lock.withLockVoid({
            self._elements.forEach({ element in
                copiedElements.append(element.clone())
            })
        })
        
        let newNumberProperty = self._lock.withLock({
            INDINumberProperty(deviceName: self._deviceName, propertyName: self._propertyName, propertyLabel: self._propertyLabel, groupName: self._groupName, propertyPermission: self._propertyPermission, timeout: self._timeout, propertyState: self._propertyState, timestamp: self._timestamp, dynamic: self._dynamic)
        })
        
        newNumberProperty.appendElements(contentOf: copiedElements)
        
        return newNumberProperty
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
        
        self._lock.withLockVoid({
            self._elements.forEach({ element in
                var child = INDIProtocolElement(tagName: "oneNumber")
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: element.elementName))
                child.addStringValue(string: String(format: "      %.20g", element.value))
                children.append(child)
            })
        })
        
        return children
    }
}
