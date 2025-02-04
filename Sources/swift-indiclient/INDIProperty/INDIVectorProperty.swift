//
//  INDIVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation

public class INDIVectorProperty: Identifiable, @unchecked Sendable {
    // MARK: - Fundamental Property
    private(set) public var deviceName: String
    private(set) public var propertyName: String
    private(set) public var propertyLabel: String
    private(set) public var groupName: String
    private(set) public var propertyPermission: INDIPropertyPermission
    private(set) public var timeout: Double
    private(set) public var propertyState: INDIPropertyState
    private(set) public var timestamp: String
    private(set) public var propertyType: INDIPropertyType

    // MARK: - Initializer
    public init(deviceName: String, propertyName: String, propertyLabel: String, groupName: String, propertyPermission: INDIPropertyPermission, timeout: Double, propertyState: INDIPropertyState, timestamp: String, propertyType: INDIPropertyType = .INDIUnknown) {
        self.deviceName = deviceName
        self.propertyName = propertyName
        self.propertyLabel = propertyLabel
        self.groupName = groupName
        self.propertyPermission = propertyPermission
        self.timeout = timeout
        self.propertyState = propertyState
        self.timestamp = timestamp
        self.propertyType = propertyType
    }
    
    // MARK: - Computed Property
    public var propertyPermissionAsString: String {
        get {
            propertyPermission.toString()
        }
    }
    
    public var propertyStateAsString: String {
        get {
            propertyState.toString()
        }
    }
    
    // MARK: - Protocol Method
    public static func == (lhs: INDIVectorProperty, rhs: INDIVectorProperty) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    // MARK: - Fundamental Method
    public func setDeviceName(_ name: String) {
        deviceName = name
    }
    
    public func setPropertyName(_ name: String) {
        propertyName = name
    }
    
    public func setPropertyLabel(_ label: String) {
        propertyLabel = label
    }
    
    public func setGroupName(_ name: String) {
        groupName = name
    }
    
    public func setPropertyPermission(_ propertyPermision: INDIPropertyPermission) {
        self.propertyPermission = propertyPermision
    }
    
    public func setPropertyPermission(from string: String) -> Bool {
        guard let propertyPermission = INDIPropertyPermission.propertyPermission(from: string) else { return false }
        self.propertyPermission = propertyPermission
        return true
    }
    
    public func setTimeout(_ timeout: Double) {
        self.timeout = timeout
    }
    
    public func setPropertyState(_ propertyState: INDIPropertyState) {
        self.propertyState = propertyState
    }
    
    public func setPropertyState(from string: String) -> Bool {
        guard let propertyState = INDIPropertyState.propertyState(from: string) else { return false }
        self.propertyState = propertyState
        return true
    }
    
    public func setTimestamp(_ timestamp: String) {
        self.timestamp = timestamp
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        deviceName == otherName
    }
    
    public func isPropertyNameMatch(_ otherName: String) -> Bool {
        propertyName == otherName
    }
    
    public func isPropertyLabelMatch(_ otherLabel: String) -> Bool {
        propertyLabel == otherLabel
    }
    
    public func isGroupName(_ otherName: String) -> Bool {
        groupName == otherName
    }
    
    public func clear() {
        deviceName = ""
        propertyName = ""
        propertyLabel = ""
        groupName = ""
        propertyPermission = .ReadOnly
        timeout = 0.0
        propertyState = .Idle
        timestamp = ""
    }
    
    // MARK: - Helper Method
    internal func createXMLAttribute(elementName: String, stringValue: String) -> XMLElement {
        let element = XMLElement(kind: .attribute)
        element.name = elementName
        element.stringValue = stringValue
        return element
    }
}
