//
//  INDITextProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDITextProperty: INDIPropertyTemplate<INDITextElement>, @unchecked Sendable {
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
        var root = INDIProtocolElement(tagName: "newTextVector")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        
        return root
    }
    
    internal override func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] {
        var children = [INDIProtocolElement]()
        
        self._lock.withLock({
            self._elements.forEach({ element in
                var child = INDIProtocolElement(tagName: "oneText")
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: element.elementName))
                child.addStringValue(string: element.text)
                children.append(child)
            })
        })
        
        return children
    }
}
