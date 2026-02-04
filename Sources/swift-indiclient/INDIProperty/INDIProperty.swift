//
//  INDIVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

public class INDIProperty: NSObject, @unchecked Sendable {
    // MARK: - Fundamental Property
    internal var _deviceName: String
    internal var _propertyName: String
    internal var _propertyLabel: String
    internal var _groupName: String
    internal var _propertyPermission: INDIPropertyPermission
    internal var _timeout: Double
    internal var _propertyState: INDIPropertyState
    internal var _timestamp: String
    internal var _dynamic: Bool
    internal let _lock: NIOLock = NIOLock()

    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", dynamic: Bool = false) {
        self._deviceName = deviceName
        self._propertyName = propertyName
        self._propertyLabel = propertyLabel
        self._groupName = groupName
        self._propertyPermission = propertyPermission
        self._timeout = timeout
        self._propertyState = propertyState
        self._timestamp = timestamp
        self._dynamic = dynamic
    }
    
    // MARK: - Computed Property
    public var deviceName: String {
        get {
            self._deviceName
        }
    }
    
    public var propertyName: String {
        get {
            self._propertyName
        }
    }
    
    public var propertyLabel: String {
        get {
            self._propertyLabel
        }
    }
    
    public var groupName: String {
        get {
            self._groupName
        }
    }
    
    public var propertyPermission: INDIPropertyPermission {
        get {
            self._propertyPermission
        }
    }
    
    public var propertyPermissionAsString: String {
        get {
            self._propertyPermission.toString()
        }
    }
    
    public var timeout: Double {
        get {
            self._timeout
        }
    }
    
    public var propertyState: INDIPropertyState {
        get {
            self._lock.withLock({
                self._propertyState
            })
        }
    }
    
    public var propertyStateAsString: String {
        get {
            self._lock.withLock({
                self._propertyState.toString()
            })
        }
    }
    
    public var timestamp: String {
        get {
            self._lock.withLock({
                self._timestamp
            })
        }
    }
    
    public var isDynamic: Bool {
        get {
            self._dynamic
        }
    }
    // MARK: - Protocol Method

    // MARK: - Fundamental Method
    public func setDynamic(dynamic: Bool) {
        self._dynamic = dynamic
    }
    
    public func setDeviceName(_ name: String) {
        self._deviceName = name
    }
    
    public func setPropertyName(_ name: String) {
        self._propertyName = name
    }
    
    public func setPropertyLabel(_ label: String) {
        self._propertyLabel = label
    }
    
    public func setGroupName(_ name: String) {
        self._groupName = name
    }
    
    public func setPropertyPermission(_ propertyPermision: INDIPropertyPermission) {
        self._propertyPermission = propertyPermision
    }
    
    public func setPropertyPermission(from stringPropertyPermission: String) {
        self._propertyPermission = INDIPropertyPermission(rawValue: stringPropertyPermission) ?? .ReadOnly
    }
    
    public func setTimeout(_ timeout: Double) {
        self._lock.withLockVoid({
            self._timeout = timeout
        })
    }
    
    public func setPropertyState(_ propertyState: INDIPropertyState) {
        self._lock.withLock({
            self._propertyState = propertyState
        })
    }
    
    public func setPropertyState(from stringPropertyState: String) {
        self._lock.withLockVoid({
            self._propertyState = INDIPropertyState(rawValue: stringPropertyState) ?? .Ok
        })
    }
    
    public func setTimestamp(_ timestamp: String) {
        self._timestamp = timestamp
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
        self._deviceName = ""
        self._propertyName = ""
        self._propertyLabel = ""
        self._groupName = ""
        self._propertyPermission = .ReadOnly
        self._timestamp = ""
        self._lock.withLock({
            self._timeout = 0.0
            self._propertyState = .Idle
        })
    }
}
