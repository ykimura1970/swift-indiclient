//
//  INDIWatchDeviceProperty.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/19.
//

import Foundation
internal import NIOConcurrencyHelpers

final class INDIWatchDeviceProperty: @unchecked Sendable {
    struct INDIDeviceInfo {
        var device: INDIBaseDevice?
        var properties: Set<String> = []
        var newDeviceHandler: ((INDIBaseDevice) -> Void)?
        
        func emitWatchDevice() {
            if let device, let newDeviceHandler {
                newDeviceHandler(device)
            }
        }
    }
    
    // MARK: - Fundamental Property
    private var _watchedDevice: Set<String> = []
    private var _data: [String : INDIDeviceInfo] = [:]
    private let _lock = NIOLock()
    
    // MARK: - Original Computed Property
    var isEmpty: Bool {
        get {
            self._lock.withLock({
                self._data.isEmpty
            })
        }
    }
    
    var devices: [INDIBaseDevice] {
        get {
            self._lock.withLock({
                self._data.values.compactMap({ $0.device })
            })
        }
    }
    
    var deviceInfos: [INDIDeviceInfo] {
        get {
            self._lock.withLock({
                self._data.values.map({ $0 })
            })
        }
    }
    
    // MARK: - Fundamental Method
    func getDeviceByName(_ name: String) -> INDIBaseDevice? {
        self._lock.withLock({
            self._data[name]?.device
        })
    }
    
    func ensureDeviceByName(name: String, constructHandler: @escaping () -> INDIBaseDevice) -> INDIDeviceInfo {
        var deviceInfo = self._lock.withLock({
            self._data[name]
        })
        
        if deviceInfo == nil {
            deviceInfo = INDIDeviceInfo()
            deviceInfo!.device = constructHandler()
            deviceInfo!.device?.setDeviceName(name)
            deviceInfo!.device?.attach()
            deviceInfo!.emitWatchDevice()
            self._lock.withLockVoid({
                self._data[name] = deviceInfo
            })
        }
        
        return deviceInfo!
    }
    
    func isDeviceWatched(_ name: String) -> Bool {
        self._lock.withLock({
            self._watchedDevice.count == 0 || self._watchedDevice.firstIndex(of: name) != nil
        })
    }
    
    func unwatchDevices() {
        self._lock.withLockVoid({
            self._watchedDevice.removeAll()
        })
    }
    
    func watchDevice(deviceName: String) {
        self._lock.withLockVoid({
            self._watchedDevice.insert(deviceName)
        })
    }
    
    func watchDevice(deviceName: String, handler: @escaping (INDIBaseDevice) -> Void) {
        self._lock.withLockVoid({
            self._watchedDevice.insert(deviceName)
            self._data[deviceName]?.newDeviceHandler = handler
        })
    }
    
    func watchProperty(deviceName: String, propertyName: String) {
        self._lock.withLockVoid({
            if !self._watchedDevice.insert(deviceName).inserted {
                self._data[deviceName]?.properties.insert(propertyName)
            }
        })
    }
    
    func clear() {
        self._lock.withLockVoid({
            self._data.removeAll()
        })
    }
    
    func clearDevices() {
        self._lock.withLockVoid({
            for key in self._data.keys {
                self._data[key]?.device = nil
            }
        })
    }
    
    func deleteDevice(device: INDIBaseDevice) -> Bool {
        self._lock.withLock({
            self._data.removeValue(forKey: device.deviceName) != nil
        })
    }
    
    func processXML(root: INDIProtocolElement, constructHandler: @escaping () -> INDIBaseDevice = { INDIBaseDevice() }) -> Int {
        #if DEBUG
        print("\(root)")
        #endif
        guard let deviceName = root.getAttributeValue("device") else { return 0 }
        if deviceName.isEmpty || !isDeviceWatched(deviceName) { return 0 }
        
        // Get the device information, if not available, create it.
        let deviceInfo = ensureDeviceByName(name: deviceName, constructHandler: constructHandler)
        
        // If ew are asked to watch for specific properties only, we ignore everything else.
        if deviceInfo.properties.count != 0 {
            if deviceInfo.properties.firstIndex(of: root.getAttributeValue("name") ?? "") == nil {
                return 0
            }
        }
        
        let defVectors = ["defNumberVector", "defSwitchVector", "defTextVector", "defLightVector", "defBLOBVector"]
        
        if defVectors.firstIndex(of: root.tagName) != nil {
            return deviceInfo.device?.buildProperty(root: root) ?? INDIErrorType.DeviceNotFound.rawValue
        }
        
        let setVectors = ["setNumberVector", "setSwitchVector", "setTextVector", "setLightVector", "setBLOBVector"]
        
        if setVectors.firstIndex(of: root.tagName) != nil {
            return deviceInfo.device?.setValue(root: root) ?? INDIErrorType.DeviceNotFound.rawValue
        }
        
        return -1
    }
}
