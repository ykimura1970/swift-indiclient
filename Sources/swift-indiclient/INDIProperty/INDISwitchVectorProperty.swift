//
//  INDISwitchVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

public class INDISwitchVectorProperty: INDIVectorPropertyTemplate<INDISwitchProperty> {
    // MARK: - Original Property
    internal(set) public var switchVectorPropertyRule: INDISwitchVectorPropertyRule
    
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
        if let switchVectorPropertyRule = INDISwitchVectorPropertyRule.switchVectorPropertyRule(from: stringSwitchVectorPropertyRule) {
            self.switchVectorPropertyRule = switchVectorPropertyRule
        } else {
            self.switchVectorPropertyRule = .OneOfMany
        }
    }
    
    public func reset() {
        self.properties.forEach({ property in
            property.setSwitchState(.Off)
        })
    }
    
    public func findOnSwitch() -> INDISwitchProperty? {
        self.properties.first(where: { $0.switchStateAsBool })
    }
    
    public func findOnSwitchIndex() -> Int {
        self.properties.firstIndex(where: { $0.switchStateAsBool }) ?? -1
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copiedProperties = self.properties.map({ $0.copy() as! INDISwitchProperty })
        
        let newSwitchVectorProperty = INDISwitchVectorProperty(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, switchVectorPropertyRule: self.switchVectorPropertyRule, dynamic: self.dynamic)
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
            child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
            child.addStringValue(string: property.switchStateAsString)
            children.append(child)
        } else {
            self.properties.forEach({ property in
                var child = INDIProtocolElement(tagName: "oneSwitch")
                child.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: property.elementName))
                child.addStringValue(string: property.switchStateAsString)
                children.append(child)
            })
        }
        
        return children
    }
}
