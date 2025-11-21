//
//  INDIAbstractClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/28.
//

import Foundation
internal import Atomics

open class INDIAbstractClient: INDIBaseMediatorDelegate {
    // MARK: - Delegate Property
    public var delegate: INDIBaseMediatorDelegate?
    
    // MARK: - Fundamental Property
    internal(set) public var hostname: String = "localhost"
    internal(set) public var port: Int = 7624
    internal var serverConnected: ManagedAtomic<Bool> = ManagedAtomic(false)
    internal var verbose: Bool = false
    internal var timeout: Float = 3
    internal var watchDevice: INDIWatchDeviceProperty = INDIWatchDeviceProperty()
    internal var blobModes: [INDIBlobMode] = []
    
    // MARK: - Initializer
    public init() { }
    
    // MARK: - Computed Property
    public var isServerConnected: Bool {
        get {
            self.serverConnected.load(ordering: .relaxed)
        }
    }
    
    public var isVerbose: Bool {
        get {
            self.verbose
        }
    }
    
    // MARK: - Fundamental Method
    public func setServer(hostname: String, port: Int) {
        self.hostname = hostname
        self.port = port
    }
    
    public func setConnectionTimeout(seconds: Float) {
        self.timeout = seconds
    }
    
    public func setVerbose(enable: Bool) {
        self.verbose = enable
    }
    
    open func connectServer() -> Bool { true }
    
    open func disconnectServer(exitCode: Int = 0) -> Bool { true }
    
    open func sendData(command: INDIProtocolElement) -> Bool { true }
    
    /// New universal message are sent from INDI server without a specific device. It is addressed to the client overall.
    /// - Parameters:
    ///  - message: Content of message.
    open func newUniversalMessage(message: String) { }
    
    /// pingReply are sent by the server on response to pingReply.
    open func newPingReply(uid: String) {
        print("Ping reply \(uid).")
    }
    
    /// Connect INDI driver.
    /// - Parameters:
    ///  - deviceName:  Name of the device to connect.
    public func connectDevice(deviceName: String) {
        setDriverConnection(deviceName: deviceName, status: true)
    }
    
    /// Disconnect INDI driver.
    /// - Parameters:
    ///  - deviceName: Name of the device to disconnect.
    public func disconnectDevice(deviceName: String) {
        setDriverConnection(deviceName: deviceName, status: false)
    }
    
    /// Add a device to the watch list.
    /// - Parameters:
    ///  - deviceName: Device to watch for.
    public func watchDevice(deviceName: String) {
        watchDevice.watchDevice(deviceName: deviceName)
    }
    
    /// Add a property to the watch list. When communicating with INDI server.
    /// - Parameters:
    ///  - propertyName: Property to watch for.
    public func watchDevice(deviceName: String, propertyName: String) {
        watchDevice.watchProperty(deviceName: deviceName, propertyName: propertyName)
    }
    
    /// Get device.
    /// - Parameters:
    ///  - deviceName: Name of device to search for in the list of devices owned by INDI server.
    /// - Returns: If deviceName exists, it returns an instance of the device. Otherwise, it returns nil.
    public func getDevice(deviceName: String) -> INDIBaseDevice? {
        watchDevice.getDeviceByName(deviceName)
    }
    
    /// Get all devices.
    /// - Returns: a array of all devies created in the client.
    public func getDevices() -> [INDIBaseDevice] {
        watchDevice.devices
    }
    
    /// Get list of devices that belong to a particular INDIBaseDevice.DriverInterface "DRIVER_INTERFACE" class.
    /// - Parameters:
    ///  - driverInterface: ORed DRIVER_INTERFACE values to select the desired class of devices.
    /// - Returns: List of devices.
    public func getDevices(driverInterface: Int) -> [INDIBaseDevice] {
        watchDevice.devices.filter({ ($0.getDriverInterface() & driverInterface) > 0 }).map({ $0 })
    }
    
    /// Set binary large object policy mode.
    /// - Parameters:
    ///  - deviceName: Name of device, required.
    ///  - propertyName: name of property, optional.
    ///  - blobHandling: INDIBlobHandling policy.
    public func setBLOBMode(deviceName: String, propertyName: String, blobHandling: INDIBlobHandling) {
        if deviceName.isEmpty { return }
        
        let index = findIndexBLOBMode(deviceName: deviceName, propertyName: propertyName)
        
        if index < 0 {
            blobModes.append(INDIBlobMode(device: deviceName, propertyName: propertyName, blobHandling: blobHandling))
        } else {
            if blobModes[index].blobHandling == blobHandling { return }
            blobModes[index].blobHandling = blobHandling
        }
        
        sendEnableBLOB(deviceName: deviceName, propertyName: propertyName, blobHandling: blobHandling)
    }
    
    /// Get binary large object policy mode if set previously by setBLOBMode.
    /// - Parameters:
    ///  - deviceName: Name of device.
    ///  - propertyName: Property name, can be nil to return overall device policy if it exists.
    /// - Returns: BLOB policy, if not found, it always returns also.
    public func getBLOBMode(deviceName: String, propertyName: String = "") -> INDIBlobHandling {
        var blobHandling: INDIBlobHandling = .Also
        
        if let blobMode = findBLOBMode(deviceName: deviceName, propertyName: propertyName) {
            blobHandling = blobMode.blobHandling
        }
        
        return blobHandling
    }
    
    public func findBLOBMode(deviceName: String, propertyName: String) -> INDIBlobMode? {
        self.blobModes.first(where: { $0.device == deviceName && (propertyName.isEmpty || $0.propertyName == propertyName) })
    }
    
    public func findIndexBLOBMode(deviceName: String, propertyName: String) -> Int {
        self.blobModes.firstIndex(where: { $0.device == deviceName && (propertyName.isEmpty || $0.propertyName == propertyName) }) ?? -1
    }
    
    public func clear() {
        self.watchDevice.clearDevices()
        self.blobModes.removeAll()
    }
}

// MARK: - Send Command Method
public extension INDIAbstractClient {
    /// Send new vector property command to server.
    func sendNewVectorProperty(vectorProperty: INDIVectorProperty) -> Bool {
        switch vectorProperty {
        case is INDINumberVectorProperty:
            return sendNewNumberVectorProperty(vectorProperty: vectorProperty as! INDINumberVectorProperty)
        case is INDISwitchVectorProperty:
            return sendNewSwitchVectorProperty(vectorProperty: vectorProperty as! INDISwitchVectorProperty)
        case is INDITextVectorProperty:
            return sendNewTextVectorProperty(vectorProperty: vectorProperty as! INDITextVectorProperty)
        case is INDILightVectorProperty:
            print("Light type is not supported to send.")
            return false
        case is INDIBlobVectorProperty:
            return sendNewBlobVectorProperty(vectorProperty: vectorProperty as! INDIBlobVectorProperty)
        default:
            print("Unknown type of proeprty to send.")
            return false
        }
    }
    
    func sendNewNumberVectorProperty(deviceName: String, propertyName: String, elementName: String, value: Double) -> Bool {
        guard let numberVectorProperty = watchDevice.getDeviceByName(deviceName)?.getNumberVectorProperty(propertyName: propertyName) else { return false }
        
        let newNumberVectorProperty = numberVectorProperty.copy() as! INDINumberVectorProperty
        guard let numberProperty = newNumberVectorProperty.findPropertyByElementName(elementName) else { return false }
        numberProperty.setValue(value)
        
        return sendNewNumberVectorProperty(vectorProperty: numberVectorProperty)
    }
    
    func sendNewNumberVectorProperty(vectorProperty: INDINumberVectorProperty) -> Bool {
        return sendData(command: vectorProperty.createNewCommand())
    }
    
    func sendNewSwitchVectorProperty(deviceName: String, propertyName: String, elementName: String) -> Bool {
        guard let switchVectorProperty = watchDevice.getDeviceByName(deviceName)?.getSwitchVectorProperty(propertyName: propertyName) else { return false }
        
        let newSwitchVectorProperty = switchVectorProperty.copy() as! INDISwitchVectorProperty
        guard let switchProperty = newSwitchVectorProperty.findPropertyByElementName(elementName) else { return false }
        switchProperty.setSwitchState(.On)
        
        return sendNewSwitchVectorProperty(vectorProperty: newSwitchVectorProperty)
    }
    
    func sendNewSwitchVectorProperty(vectorProperty: INDISwitchVectorProperty) -> Bool {
        return sendData(command: vectorProperty.createNewCommand())
    }
    
    func sendNewTextVectorProperty(deviceName: String, propertyName: String, elementName: String, text: String) -> Bool {
        guard let textVectorProperty = watchDevice.getDeviceByName(deviceName)?.getTextVectorProperty(propertyName: propertyName) else { return false }
        
        let newTextVectorProperty = textVectorProperty.copy() as! INDITextVectorProperty
        guard let textProperty = newTextVectorProperty.findPropertyByElementName(elementName) else { return false }
        textProperty.setText(text)
        
        return sendNewTextVectorProperty(vectorProperty: newTextVectorProperty)
    }
    
    func sendNewTextVectorProperty(vectorProperty: INDITextVectorProperty) -> Bool {
        return sendData(command: vectorProperty.createNewCommand())
    }
    
    func sendNewBlobVectorProperty(vectorProperty: INDIBlobVectorProperty) -> Bool {
        return sendData(command: vectorProperty.createNewCommand())
    }
    
    func sendGetProperties() {
        var root = INDIProtocolElement(tagName: "getProperties")
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "version", value: INDIProtocolVersion))
        
        if watchDevice.isEmpty {
            _ = sendData(command: root)
        } else {
            for deviceInfo in watchDevice.deviceInfos {
                // If there are no specific properties to watch, we watch the complete device.
                if deviceInfo.properties.isEmpty {
                    var rootOne = root
                    rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceInfo.device!.deviceName))
                    _ = sendData(command: rootOne)
                } else {
                    for propertyName in deviceInfo.properties {
                        var rootOne = root
                        rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceInfo.device!.deviceName))
                        rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
                        _ = sendData(command: rootOne)
                    }
                }
            }
        }
    }
    
    func sendEnableBLOB(deviceName: String, propertyName: String, blobHandling: INDIBlobHandling) {
        var root = INDIProtocolElement(tagName: "enableBLOB")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        
        if !propertyName.isEmpty {
            root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        }
        
        root.addStringValue(string: blobHandling.toString())
        
        _ = sendData(command: root)
    }
    
    /// Send one ping request, the server will answer back with the same uuid.
    /// - Parameters:
    ///  - uid: This string will server as identifier for the reply.
    /// reply will be dispatched to newPingReply
    func sendPingRequest(uid: String) {
        var root = INDIProtocolElement(tagName: "pingRequest")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "uid", value: uid))
        
        _ = sendData(command: root)
    }
    
    /// Send a ping reply for the given uuid.
    func sendPingReply(uid: String) {
        var root = INDIProtocolElement(tagName: "pingReply")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "uid", value: uid))
        
        _ = sendData(command: root)
    }
    
    func setDriverConnection(deviceName: String, status: Bool) {
        guard let device = getDevice(deviceName: deviceName) else {
            print("INDIAbstractClient: Error. Unable to find driver \(deviceName).")
            return
        }
        
        guard let switchVectorProperty = device.getSwitchVectorProperty(propertyName: "CONNECTION") else {
            return
        }
        
        // If we need to connect.
        if status {
            // If there is no need to do anything, i.e. already connected.
            if switchVectorProperty[0].switchStateAsBool { return }
            
            let newSwitchVectorProperty = switchVectorProperty.copy() as! INDISwitchVectorProperty
            newSwitchVectorProperty.reset()
            newSwitchVectorProperty[0].setSwitchState(.On)
            newSwitchVectorProperty[1].setSwitchState(.Off)
            
            _ = sendNewSwitchVectorProperty(vectorProperty: newSwitchVectorProperty)
        } else {
            // If there is no need to do anything, i.e. already disconnected.
            if switchVectorProperty[1].switchStateAsBool { return }
            
            let newSwitchVectorProperty = switchVectorProperty.copy() as! INDISwitchVectorProperty
            newSwitchVectorProperty.reset()
            newSwitchVectorProperty[0].setSwitchState(.Off)
            newSwitchVectorProperty[1].setSwitchState(.On)
            
            _ = sendNewSwitchVectorProperty(vectorProperty: newSwitchVectorProperty)
        }
    }
}

// MARK: - Command Handling Method
public extension INDIAbstractClient {
    /// Remove device.
    /// - Parameters:
    ///  - deviceName: Name of removed device.
    func deleteDevice(deviceName: String) -> Int {
        if let device = watchDevice.getDeviceByName(deviceName) {
            _ = watchDevice.deleteDevice(device: device)
            device.detach()
            return 0
        }
        
        print("Device \(deviceName) not found.")
        return INDIBaseDevice.INDIError.DeviceNotFound.rawValue
    }
    
    /// Delete property command.
    /// - Parameters:
    ///  - root: INDIProtocolElement instance.
    func deletePropertyCommand(root: INDIProtocolElement) -> Int {
        guard let device = watchDevice.getDeviceByName(root.getAttribute(name: "device") ?? "") else { return INDIBaseDevice.INDIError.DeviceNotFound.rawValue }
        
        device.checkMessage(root: root)
        
        if let propertyName = root.getAttribute(name: "name") {
            if let vectorProperty = device.getVectorProperty(propertyName: propertyName) {
                if isServerConnected {
                    delegate?.removeVectorProperty(sender: device, vectorProperty: vectorProperty)
                }
                return device.removeVectorProperty(propertyName: propertyName)
            }
            
            // Silently ignore Only clients.
            if blobModes.isEmpty || blobModes.first?.blobHandling == .Only {
                return 0
            }
            
            print("Cannot delete property \(propertyName) as it is not defined yet. Check driver.")
            return -1
        }
        
        return deleteDevice(deviceName: device.deviceName)
    }
    
    /// Process messages.
    /// - Parameters:
    ///  - root: INDIProtocolElement instance.
    func messageCommand(root: INDIProtocolElement) -> Int {
        if let device = watchDevice.getDeviceByName(root.getAttribute(name: "device") ?? "") {
            device.checkMessage(root: root)
            return 0
        }
        
        guard let message = root.getAttribute(name: "message") else {
            print("No message content found.")
            return -1
        }
        
        var finalMessage: String = ""
        if let timestamp = root.getAttribute(name: "timestamp") {
            finalMessage = "\(timestamp): \(message)"
        } else {
            let formatter = ISO8601DateFormatter()
            finalMessage = "\(formatter.string(from: Date()).dropLast()): \(message)"
        }
        
        newUniversalMessage(message: finalMessage)
        return 0
    }
}

// MARK: - Delegate Method
extension INDIAbstractClient: INDISocketDelegate {
    public func processINDIProtocol(root: INDIProtocolElement) -> Int {
        // Ignore echoed newXXX
        if root.tagName.contains("new") { return 0 }
        
        // Just ignore any getProperties we might get.
        if root.tagName == "getProperties" {
            return INDIBaseDevice.INDIError.PropertyDuplicated.rawValue
        }
        
        if root.tagName == "pingRequest" {
            sendPingReply(uid: root.getAttribute(name: "uid") ?? "")
            return 0
        }
        
        if root.tagName == "pingReply" {
            newPingReply(uid: root.getAttribute(name: "uid") ?? "")
        }
        
        if root.tagName == "message" {
            return messageCommand(root: root)
        }
        
        if root.tagName == "delProperty" {
            return deletePropertyCommand(root: root)
        }
        
        // If device is set to BLOB Only, we ignore everything else not related to blobs.
        if getBLOBMode(deviceName: root.getAttribute(name: "device") ?? "") == .Only && root.tagName != "defBLOBVector" && root.tagName != "setBLOBVector" { return 0 }
        
        return watchDevice.processXML(root: root, constructHandler: {
            let device = INDIBaseDevice()
            device.delegate = self
            return device
        })
    }
}
