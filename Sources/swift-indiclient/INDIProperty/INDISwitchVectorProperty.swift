//
//  INDISwitchVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

final public class INDISwitchVectorProperty: INDIVectorPropertyTemplate<INDISwitchProperty>, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var switchVectorPropertyRule: INDISwitchVectorPropertyRule
    
    // MARK: - Initializer
    public init(deviceName: String, propertyName: String, propertyLabel: String, groupName: String, propertyPermission: INDIPropertyPermission, timeout: Double, propertyState: INDIPropertyState, switchVectorPropertyRule: INDISwitchVectorPropertyRule, timestamp: String) {
        self.switchVectorPropertyRule = switchVectorPropertyRule
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyPermission: propertyPermission, timeout: timeout, propertyState: propertyState, timestamp: timestamp, propertyType: .INDISwitch)
    }
    
    public convenience init() {
        self.init(deviceName: "", propertyName: "", propertyLabel: "", groupName: "", propertyPermission: .ReadOnly, timeout: 0.0, propertyState: .Idle, switchVectorPropertyRule: .OneOfMany, timestamp: "")
    }
    
    // MARK: - Computed Property
    public var switchVectorPropertyRuleAsString: String {
        get {
            switchVectorPropertyRule.toString()
        }
    }
    
    // MARK: - Original Method
    public func setSwitchVectorPropertyRule(_ rule: INDISwitchVectorPropertyRule) {
        switchVectorPropertyRule = rule
    }
    
    public func setSwitchVectorPropertyRule(_ string: String) -> Bool {
        guard let rule = INDISwitchVectorPropertyRule.switchVectorPropertyRule(from: string) else { return false }
        switchVectorPropertyRule = rule
        return true
    }
    
    public func reset() {
        for property in properties {
            property.setSwitchState(.Off)
        }
    }
    
    public func findOnSwitch() -> INDISwitchProperty? {
        properties.first(where: { $0.switchStateAsBool })
    }
    
    public func findOnSwitchIndex() -> Int {
        properties.firstIndex(where: { $0.switchStateAsBool }) ?? -1
    }
    
    // MARK: - Override Method
    public override func clear() {
        switchVectorPropertyRule = .OneOfMany
        super.clear()
    }
    
    public override func createNewCommand(newProperties: [Element]) -> String {
        let elementRoot = XMLElement(name: "newSwitchVector")
        elementRoot.addAttribute(createXMLAttribute(elementName: "device", stringValue: deviceName))
        elementRoot.addAttribute(createXMLAttribute(elementName: "name", stringValue: propertyName))
        
        if switchVectorPropertyRule == .OneOfMany, let onSwitch = newProperties.first(where: { $0.switchStateAsBool }) {
            let elementChild = XMLElement(name: "oneSwitch")
            elementChild.stringValue = onSwitch.switchStateAsString
            elementChild.addAttribute(createXMLAttribute(elementName: "name", stringValue: onSwitch.elementName))
            elementRoot.addChild(elementChild)
        } else {
            for property in newProperties {
                let elementChild = XMLElement(name: "oneSwitch")
                elementChild.stringValue = property.switchStateAsString
                elementChild.addAttribute(createXMLAttribute(elementName: "name", stringValue: property.elementName))
                elementRoot.addChild(elementChild)
            }
        }
        
        return elementRoot.xmlString
    }
}
