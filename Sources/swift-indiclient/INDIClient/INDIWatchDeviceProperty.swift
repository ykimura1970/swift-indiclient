//
//  INDIWatchDeviceProperty.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/19.
//

import Foundation

class INDIWatchDeviceProperty {
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
    var watchedDevice: Set<String> = []
    var data: [String : INDIDeviceInfo] = [:]
    
    // MARK: - Original Computed Property
    var isEmpty: Bool {
        get {
            self.data.isEmpty
        }
    }
    
    var devices: [INDIBaseDevice] {
        get {
            self.data.values.compactMap({ $0.device })
        }
    }
    
    var deviceInfos: [INDIDeviceInfo] {
        get {
            self.data.values.map({ $0 })
        }
    }
    
    func getDeviceByName(_ name: String) -> INDIBaseDevice? {
        self.data[name]?.device
    }
    
    func ensureDeviceByName(name: String, constructHandler: @escaping () -> INDIBaseDevice) -> INDIDeviceInfo {
        if self.data[name] == nil {
            self.data[name] = INDIDeviceInfo()
            self.data[name]?.device = constructHandler()
            self.data[name]?.device?.setDeviceName(name)
            self.data[name]?.device?.attach()
            self.data[name]?.emitWatchDevice()
        }
        
        return self.data[name]!
    }
    
    func isDeviceWatched(deviceName: String) -> Bool {
        watchedDevice.count == 0 || watchedDevice.firstIndex(of: deviceName) != nil
    }
    
    func unwatchDevices() {
        watchedDevice.removeAll()
    }
    
    func watchDevice(deviceName: String) {
        watchedDevice.insert(deviceName)
    }
    
    func watchDevice(deviceName: String, handler: @escaping (INDIBaseDevice) -> Void) {
        if !watchedDevice.insert(deviceName).inserted {
            self.data[deviceName]?.newDeviceHandler = handler
        }
    }
    
    func watchProperty(deviceName: String, propertyName: String) {
        if !watchedDevice.insert(deviceName).inserted {
            self.data[deviceName]?.properties.insert(propertyName)
        }
    }
    
    func clear() {
        self.data.removeAll()
    }
    
    func clearDevices() {
        for key in data.keys {
            data[key]?.device = nil
        }
    }
    
    func deleteDevice(device: INDIBaseDevice) -> Bool {
        self.data.removeValue(forKey: device.deviceName) != nil
    }
    
    func processXML(root: INDIProtocolElement, constructHandler: @escaping () -> INDIBaseDevice = { INDIBaseDevice() }) -> Int {
        guard let deviceName = root.getAttribute(name: "device") else { return 0 }
        if deviceName.isEmpty || !isDeviceWatched(deviceName: deviceName) { return 0 }
        
        // Get the device information, if not available, create it.
        let deviceInfo = ensureDeviceByName(name: deviceName, constructHandler: constructHandler)
        
        // If ew are asked to watch for specific properties only, we ignore everything else.
        if deviceInfo.properties.count != 0 {
            if deviceInfo.properties.firstIndex(of: root.getAttribute(name: "name") ?? "") == nil {
                return 0
            }
        }
        
        let defVectors = ["defNumberVector", "defSwitchVector", "defTextVector", "defLightVector", "defBLOBVector"]
        
        if defVectors.firstIndex(of: root.tagName) != nil {
            return deviceInfo.device?.buildVectorProperty(root: root) ?? INDIBaseDevice.INDIError.DeviceNotFound.rawValue
        }
        
        let setVectors = ["setNumberVector", "setSwitchVector", "setTextVector", "setLightVector", "setBLOBVector"]
        
        if setVectors.firstIndex(of: root.tagName) != nil {
            return deviceInfo.device?.setValue(root: root) ?? INDIBaseDevice.INDIError.DeviceNotFound.rawValue
        }
        
        return -1
    }
}
