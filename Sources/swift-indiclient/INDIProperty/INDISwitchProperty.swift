//
//  INDISwitchVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDISwitchVectorProperty: INDIVectorPropertyTemplate<INDISwitchProperty>, @unchecked Sendable {
    // MARK: - Original Property
    internal var switchVectorPropertyRule: INDISwitchVectorPropertyRule
    
    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", switchVectorPropertyRule: INDISwitchVectorPropertyRule = .OneOfMany, dynamic: Bool = false) {
        self.switchVectorPropertyRule = switchVectorPropertyRule
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyPermission: propertyPermission, timeout: timeout, propertyState: propertyState, timestamp: timestamp, dynamic: dynamic)
    }
    
    // MARK: - Original Computed Property
    public var switchVectorPropertyRuleAsString: String {
        get {
            switchVectorPropertyRule.toString()
        }
    }
    
    // MARK: - Original Method
    public func setSwitchVectorPropertyRule(_ switchVectorPropertyRule: INDISwitchVectorPropertyRule) {
        self.switchVectorPropertyRule = switchVectorPropertyRule
    }
    
    public func setSwitchVectorPropertyRule(_ stringSwitchVectorPropertyRule: String){
        self.switchVectorPropertyRule = INDISwitchVectorPropertyRule.switchVectorPropertyRule(from: stringSwitchVectorPropertyRule) ?? .OneOfMany
    }
    
    public func getSwitchVectorPropertyRule() -> INDISwitchVectorPropertyRule {
        self.switchVectorPropertyRule
    }
    
    public func reset() {
        lock.withLock({
            self.properties.forEach({ property in
                property.setSwitchState(.Off)
            })
        })
    }
    
    public func findOnSwitch() -> INDISwitchProperty? {
        lock.withLock({
            self.properties.first(where: { $0.switchStateAsBool })
        })
    }
    
    public func findOnSwitchIndex() -> Int {
        lock.withLock({
            self.properties.firstIndex(where: { $0.switchStateAsBool }) ?? -1
        })
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        var copiedProperties = [INDISwitchProperty]()
        
        let newSwitchVectorProperty = lock.withLock({
            let copiedProperties = self.properties.map({ $0.copy() as! INDISwitchProperty })
            
            return INDISwitchVectorProperty(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, switchVectorPropertyRule: self.switchVectorPropertyRule, dynamic: self.dynamic)
        })
        
        newSwitchVectorProperty.appendProperties(contentOf: copiedProperties)
        
        return newSwitchVectorProperty
    }
    
    public override func clear() {
        switchVectorPropertyRule = .OneOfMany
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
        
        if switchVectorPropertyRule == .OneOfMany, let property = findOnSwitch() {
            var child = INDIProtocolElement(tagName: "oneSwitch")
            
            lock.withLock({
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
                child.addStringValue(string: property.switchStateAsString)
            })
            
            children.append(child)
        } else {
            lock.withLock({
                self.properties.forEach({ property in
                    var child = INDIProtocolElement(tagName: "oneSwitch")
                    child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
                    child.addStringValue(string: property.switchStateAsString)
                    children.append(child)
                })
            })
        }
        
        return children
    }
}
