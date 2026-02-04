//
//  INDISwitchProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDISwitchProperty: INDIPropertyTemplate<INDISwitchElement>, @unchecked Sendable {
    // MARK: - Original Property
    internal var _switchPropertyRule: INDISwitchPropertyRule
    
    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", switchVectorPropertyRule: INDISwitchPropertyRule = .OneOfMany, dynamic: Bool = false) {
        self._switchPropertyRule = switchVectorPropertyRule
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyPermission: propertyPermission, timeout: timeout, propertyState: propertyState, timestamp: timestamp, dynamic: dynamic)
    }
    
    // MARK: - Original Computed Property
    public var switchPropertyRule: INDISwitchPropertyRule {
        get {
            self._switchPropertyRule
        }
    }
    
    public var switchPropertyRuleAsString: String {
        get {
            self._switchPropertyRule.toString()
        }
    }
    
    // MARK: - Original Method
    public func setSwitchPropertyRule(_ switchPropertyRule: INDISwitchPropertyRule) {
        self._switchPropertyRule = switchPropertyRule
    }
    
    public func setSwitchPropertyRule(_ stringSwitchPropertyRule: String){
        self._switchPropertyRule = .init(rawValue: stringSwitchPropertyRule) ?? .OneOfMany
    }
    
    public func reset() {
        self._lock.withLock({
            self._elements.forEach({ element in
                element.setSwitchState(.Off)
            })
        })
    }
    
    public func findOnSwitch() -> INDISwitchElement? {
        self._lock.withLock({
            self._elements.first(where: { $0.switchStateAsBool })
        })
    }
    
    public func findOnSwitchIndex() -> Int {
        self._lock.withLock({
            self._elements.firstIndex(where: { $0.switchStateAsBool }) ?? -1
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._switchPropertyRule = .OneOfMany
        super.clear()
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
        var root = INDIProtocolElement(tagName: "newSwitchVector")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        
        return root
    }
    
    internal override func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] {
        var children = [INDIProtocolElement]()
        
        if switchPropertyRule == .OneOfMany, let element = findOnSwitch() {
            var child = INDIProtocolElement(tagName: "oneSwitch")
            
            self._lock.withLock({
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: element.elementName))
                child.addStringValue(string: element.switchStateAsString)
            })
            
            children.append(child)
        } else {
            self._lock.withLock({
                self._elements.forEach({ element in
                    var child = INDIProtocolElement(tagName: "oneSwitch")
                    child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: element.elementName))
                    child.addStringValue(string: element.switchStateAsString)
                    children.append(child)
                })
            })
        }
        
        return children
    }
}
