//
//  INDIVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

public class INDIVectorProperty: NSObject, NSCopying, @unchecked Sendable {
    // MARK: - Fundamental Property
    internal var deviceName: String
    internal var propertyName: String
    internal var propertyLabel: String
    internal var groupName: String
    internal var propertyPermission: INDIPropertyPermission
    internal var timeout: Double
    internal var propertyState: INDIPropertyState
    internal var timestamp: String
    internal var dynamic: Bool
    internal let lock: NIOLock = NIOLock()

    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", dynamic: Bool = false) {
        self.deviceName = deviceName
        self.propertyName = propertyName
        self.propertyLabel = propertyLabel
        self.groupName = groupName
        self.propertyPermission = propertyPermission
        self.timeout = timeout
        self.propertyState = propertyState
        self.timestamp = timestamp
        self.dynamic = dynamic
    }
    
    // MARK: - Computed Property
    public var propertyPermissionAsString: String {
        get {
            propertyPermission.toString()
        }
    }
    
    public var propertyStateAsString: String {
        get {
            lock.withLock({
                propertyState.toString()
            })
        }
    }
    
    public var isDynamic: Bool {
        get {
            self.dynamic
        }
    }
    
    // MARK: - Protocol Method
    public func copy(with zone: NSZone? = nil) -> Any {
        lock.withLock({
            INDIVectorProperty(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, dynamic: self.dynamic)
        })
    }

    // MARK: - Fundamental Method
    public func setDynamic(dynamic: Bool) {
        self.dynamic = dynamic
    }
    
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
    
    public func setPropertyPermission(from stringPropertyPermission: String) {
        self.propertyPermission = INDIPropertyPermission.propertyPermission(from: stringPropertyPermission) ?? .ReadOnly
    }
    
    public func setTimeout(_ timeout: Double) {
        lock.withLock({
            self.timeout = timeout
        })
    }
    
    public func setPropertyState(_ propertyState: INDIPropertyState) {
        lock.withLock({
            self.propertyState = propertyState
        })
    }
    
    public func setPropertyState(from stringPropertyState: String) {
        lock.withLock({
            self.propertyState = INDIPropertyState.propertyState(from: stringPropertyState) ?? .Ok
        })
    }
    
    public func setTimestamp(_ timestamp: String) {
        self.timestamp = timestamp
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        self.deviceName == otherName
    }
    
    public func isPropertyNameMatch(_ otherName: String) -> Bool {
        self.propertyName == otherName
    }
    
    public func isPropertyLabelMatch(_ otherLabel: String) -> Bool {
        self.propertyLabel == otherLabel
    }
    
    public func isGroupNameMatch(_ otherName: String) -> Bool {
        self.groupName == otherName
    }
    
    public func clear() {
        self.deviceName = ""
        self.propertyName = ""
        self.propertyLabel = ""
        self.groupName = ""
        self.propertyPermission = .ReadOnly
        self.timestamp = ""
        lock.withLock({
            self.timeout = 0.0
            self.propertyState = .Idle
        })
    }
}
