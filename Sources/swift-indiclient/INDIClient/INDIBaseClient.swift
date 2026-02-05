//
//  INDIBaseClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/28.
//

import Foundation
internal import Atomics
internal import NIOCore
internal import NIOFoundationCompat
public import NIOConcurrencyHelpers
internal import NIOPosix

open class INDIBaseClient: INDIBaseDeviceDelegate, @unchecked Sendable {
    // MARK: - Fundamental Property
    internal var _hostname: String = "localhost"
    internal var _port: Int = 7624
    internal var _connected: ManagedAtomic<Bool> = ManagedAtomic(false)
    internal var _verbose: Bool = false
    internal var _timeout: Float = 3
    internal var _watchDevice: INDIWatchDeviceProperty = INDIWatchDeviceProperty()
    internal var _blobModes: [INDIBlobMode] = []
    internal let _socket: INDISocket
    public let _lock = NIOLock()
    
    // MARK: - Initializer
    public init(numberOfThreads: Int = 1) {
        self._socket = INDISocket(numberOfThreads: numberOfThreads)
    }
    
    // MARK: - Computed Property
    public var isServerConnected: Bool {
        get {
            self._connected.load(ordering: .relaxed)
        }
    }
    
    public var isVerbose: Bool {
        get {
            self._verbose
        }
    }
    
    public var devices: [INDIBaseDevice] {
        get {
            self._watchDevice.devices
        }
    }
    
    public var hostname: String {
        get {
            self._hostname
        }
    }
    
    public var port: Int {
        get {
            self._port
        }
    }

    /// Connect to INDI server.
    /// - Returns: True if the connection is successful, false otherwise.
    @discardableResult
    open func connectServer() async  -> Bool {
        if self._connected.load(ordering: .relaxed) {
            print("INDIBaseClient.connectServer: Already connected.")
            return false
        }
        
        print("INDIBaseClient.connectServer: creating new connection...")
        
        self._socket.delegate = self
        if await !self._socket.connectToHost(hostname: self._hostname, port: self._port) {
            self._connected.store(false, ordering: .relaxed)
            return false
        }
        
        clear()
        self._connected.store(true, ordering: .relaxed)
        serverConnected()
        sendGetProperties()
        
        return true
    }
    
    /// Disconnect from INDI server. Any devices previously created will be deleted and memory cleared.
    /// - Returns: True if disconnection is successful, false otherwise.
    @discardableResult
    open func disconnectServer(exitCode: Int = 0) async -> Bool {
        if !self._connected.exchange(false, ordering: .relaxed) {
            print("INDIBaseClient.disconnectServer: Already disconnected.")
            return false
        }
        
        let result = await self._socket.disconnectFromHost()
        await serverDisconnected(exitCode: exitCode)
        
        return result
    }
    
    @discardableResult
    open func sendData(command: INDIProtocolElement) -> Bool {
        self._socket.write(root: command)
    }
    
    /// pingReply are sent by the server on response to pingReply.
    open func newPingReply(uid: String) {
        print("Ping reply \(uid).")
    }
    
    // MARK: - INDIBaseMediatorDelegate Method
    open func newDevice(_ sender: INDIBaseDevice) { }
    
    open func removeDevice(_ sender: INDIBaseDevice) { }
    
    open func newProperty(_ sender: INDIBaseDevice, property: INDIPropertyType) { }
    
    open func updateProperty(_ sender: INDIBaseDevice, property: INDIPropertyType) { }
    
    open func removeProperty(_ sender: INDIBaseDevice, property: INDIPropertyType) { }
    
    open func newMessage(_ sender: INDIBaseDevice, messageID: Int) { }
    
    // MARK: - INDIBaseClientMethod
    open func serverConnected() { }
    
    open func serverDisconnected(exitCode: Int) async { }

    /// New universal message are sent from INDI server without a specific device. It is addressed to the client overall.
    /// - Parameters:
    ///  - message: Content of message.
    open func newUniversalMessage(message: String) { }

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
    
    public func setServer(hostname: String, port: Int) {
        self._hostname = hostname
        self._port = port
    }
    
    public func setConnectionTimeout(seconds: Float) {
        self._timeout = seconds
    }
    
    public func setVerbose(enable: Bool) {
        self._verbose = enable
    }
    
    /// Add a device to the watch list.
    /// - Parameters:
    ///  - deviceName: Device to watch for.
    public func watchDevice(deviceName: String) {
        self._watchDevice.watchDevice(deviceName: deviceName)
    }
    
    /// Add a property to the watch list. When communicating with INDI server.
    /// - Parameters:
    ///  - propertyName: Property to watch for.
    public func watchDevice(deviceName: String, propertyName: String) {
        self._watchDevice.watchProperty(deviceName: deviceName, propertyName: propertyName)
    }
    
    /// Get device.
    /// - Parameters:
    ///  - deviceName: Name of device to search for in the list of devices owned by INDI server.
    /// - Returns: If deviceName exists, it returns an instance of the device. Otherwise, it returns nil.
    public func getDevice(deviceName: String) -> INDIBaseDevice? {
        self._watchDevice.getDeviceByName(deviceName)
    }
    
    /// Get list of devices that belong to a particular INDIBaseDevice.DriverInterface "DRIVER_INTERFACE" class.
    /// - Parameters:
    ///  - driverInterface: ORed DRIVER_INTERFACE values to select the desired class of devices.
    /// - Returns: List of devices.
    public func getDevices(driverInterface: Int) -> [INDIBaseDevice] {
        self._watchDevice.devices.filter({ ($0.driverInterface & driverInterface) > 0 }).map({ $0 })
    }
    
    /// Set binary large object policy mode.
    /// - Parameters:
    ///  - deviceName: Name of device, required.
    ///  - propertyName: name of property, optional.
    ///  - blobHandling: INDIBlobHandling policy.
    public func setBLOBMode(deviceName: String, propertyName: String = "", blobHandling: INDIBlobHandling) {
        if deviceName.isEmpty { return }
        
        let index = findBIndexOfBLOBMode(deviceName: deviceName, propertyName: propertyName)
        
        if index < 0 {
            self._lock.withLockVoid({
                self._blobModes.append(INDIBlobMode(device: deviceName, propertyName: propertyName, blobHandling: blobHandling))
            })
        } else {
            self._lock.withLockVoid({
                if self._blobModes[index].blobHandling == blobHandling { return }
                self._blobModes[index].blobHandling = blobHandling
            })
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
    
    public func findBLOBMode(deviceName: String, propertyName: String = "") -> INDIBlobMode? {
        self._lock.withLock({
            self._blobModes.first(where: { $0.device == deviceName && (propertyName.isEmpty || $0.propertyName == propertyName) })
        })
    }
    
    public func findBIndexOfBLOBMode(deviceName: String, propertyName: String = "") -> Int {
        self._lock.withLock({
            self._blobModes.firstIndex(where: { $0.device == deviceName && (propertyName.isEmpty || $0.propertyName == propertyName) }) ?? -1
        })
    }
    
    public func clear() {
        self._watchDevice.clearDevices()
        self._lock.withLockVoid({
            self._blobModes.removeAll()
        })
    }
    
}

// MARK: - Send Command Method
public extension INDIBaseClient {
    /// Send new vector property command to server.
    @discardableResult
    func sendNewProperty(property: INDIProperty) -> Bool {
        switch property {
        case is INDINumberProperty:
            return sendNewNumberProperty(numberProperty: property as! INDINumberProperty)
        case is INDISwitchProperty:
            return sendNewSwitchProperty(switchProperty: property as! INDISwitchProperty)
        case is INDITextProperty:
            return sendNewTextProperty(textProperty: property as! INDITextProperty)
        case is INDILightProperty:
            print("Light type is not supported to send.")
            return false
        case is INDIBlobProperty:
            return sendNewBlobProperty(blobProperty: property as! INDIBlobProperty)
        default:
            print("Unknown type of proeprty to send.")
            return false
        }
    }
    
    @discardableResult
    func sendNewNumberProperty(deviceName: String, propertyName: String, elementName: String, value: Double) -> Bool {
        guard let numberProperty = self._watchDevice.getDeviceByName(deviceName)?.getNumberProperty(propertyName: propertyName) else { return false }
        guard let numberElement = numberProperty.findElementByName(elementName) else { return false }
        
        numberElement.setValue(value)
        
        return sendNewNumberProperty(numberProperty: numberProperty)
    }
    
    @discardableResult
    func sendNewNumberProperty(numberProperty: INDINumberProperty) -> Bool {
        return sendData(command: numberProperty.createNewCommand())
    }
    
    @discardableResult
    func sendNewSwitchProperty(deviceName: String, propertyName: String, elementName: String) -> Bool {
        guard let switchProperty = self._watchDevice.getDeviceByName(deviceName)?.getSwitchProperty(propertyName: propertyName) else { return false }
        guard let switchElement = switchProperty.findElementByName(elementName) else { return false }
        
        switchElement.setSwitchState(.On)
        
        return sendNewSwitchProperty(switchProperty: switchProperty)
    }
    
    @discardableResult
    func sendNewSwitchProperty(switchProperty: INDISwitchProperty) -> Bool {
        return sendData(command: switchProperty.createNewCommand())
    }
    
    @discardableResult
    func sendNewTextProperty(deviceName: String, propertyName: String, elementName: String, text: String) -> Bool {
        guard let textProperty = self._watchDevice.getDeviceByName(deviceName)?.getTextProperty(propertyName: propertyName) else { return false }
        guard let textElement = textProperty.findElementByName(elementName) else { return false }
        
        textElement.setText(text)
        
        return sendNewTextProperty(textProperty: textProperty)
    }
    
    @discardableResult
    func sendNewTextProperty(textProperty: INDITextProperty) -> Bool {
        return sendData(command: textProperty.createNewCommand())
    }
    
    @discardableResult
    func sendNewBlobProperty(blobProperty: INDIBlobProperty) -> Bool {
        return sendData(command: blobProperty.createNewCommand())
    }
    
    func sendGetProperties() {
        var root = INDIProtocolElement(tagName: "getProperties")
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "version", value: INDIProtocolVersion))
        
        if self._watchDevice.isEmpty {
            sendData(command: root)
        } else {
            for deviceInfo in self._watchDevice.deviceInfos {
                // If there are no specific properties to watch, we watch the complete device.
                if deviceInfo.properties.isEmpty {
                    var rootOne = root
                    rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceInfo.device!.deviceName))
                    sendData(command: rootOne)
                } else {
                    for propertyName in deviceInfo.properties {
                        var rootOne = root
                        rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceInfo.device!.deviceName))
                        rootOne.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
                        sendData(command: rootOne)
                    }
                }
            }
        }
    }
    
    @discardableResult
    func sendEnableBLOB(deviceName: String, propertyName: String, blobHandling: INDIBlobHandling) -> Bool {
        var root = INDIProtocolElement(tagName: "enableBLOB")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "device", value: deviceName))
        
        if !propertyName.isEmpty {
            root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "name", value: propertyName))
        }
        
        root.addStringValue(string: blobHandling.toString())
        
        return sendData(command: root)
    }
    
    /// Send one ping request, the server will answer back with the same uuid.
    /// - Parameters:
    ///  - uid: This string will server as identifier for the reply.
    /// reply will be dispatched to newPingReply
    func sendPingRequest(uid: String) {
        var root = INDIProtocolElement(tagName: "pingRequest")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "uid", value: uid))
        
        sendData(command: root)
    }
    
    /// Send a ping reply for the given uuid.
    func sendPingReply(uid: String) {
        var root = INDIProtocolElement(tagName: "pingReply")
        
        root.addAttribute(attribute: INDIProtocolElement.Attribute(key: "uid", value: uid))
        
        sendData(command: root)
    }
    
    func setDriverConnection(deviceName: String, status: Bool) {
        guard let device = getDevice(deviceName: deviceName) else {
            print("INDIAbstractClient: Error. Unable to find driver \(deviceName).")
            return
        }
        
        guard let switchProperty = device.getSwitchProperty(propertyName: "CONNECTION") else {
            return
        }
        
        // If we need to connect.
        if status {
            // If there is no need to do anything, i.e. already connected.
            if switchProperty[0].switchStateAsBool { return }
            
            switchProperty.reset()
            switchProperty[0].setSwitchState(.On)
            switchProperty[1].setSwitchState(.Off)
            
            sendNewSwitchProperty(switchProperty: switchProperty)
        } else {
            // If there is no need to do anything, i.e. already disconnected.
            if switchProperty[1].switchStateAsBool { return }
            
            switchProperty.reset()
            switchProperty[0].setSwitchState(.Off)
            switchProperty[1].setSwitchState(.On)
            
            sendNewSwitchProperty(switchProperty: switchProperty)
        }
    }
}

// MARK: - Command Handling Method
public extension INDIBaseClient {
    /// Remove device.
    /// - Parameters:
    ///  - deviceName: Name of removed device.
    func deleteDevice(deviceName: String) -> Int {
        if let device = self._watchDevice.getDeviceByName(deviceName) {
            _ = self._watchDevice.deleteDevice(device: device)
            device.detach()
            return 0
        }
        
        print("Device \(deviceName) not found.")
        return INDIErrorType.DeviceNotFound.rawValue
    }
    
    /// Delete property command.
    /// - Parameters:
    ///  - root: INDIProtocolElement instance.
    func deletePropertyCommand(root: INDIProtocolElement) -> Int {
        guard let device = self._watchDevice.getDeviceByName(root.getAttributeValue("device") ?? "") else { return INDIErrorType.DeviceNotFound.rawValue }
        
        device.checkMessage(root: root)
        
        if let propertyName = root.getAttributeValue("name") {
            if let property = device.getProperty(propertyName: propertyName) {
                if self.isServerConnected {
                    removeProperty(device, property: property)
                }
                return device.removeProperty(propertyName: propertyName)
            }
            
            // Silently ignore Only clients.
            if self._blobModes.isEmpty || self._blobModes.first?.blobHandling == .Only {
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
        if let device = self._watchDevice.getDeviceByName(root.getAttributeValue("device") ?? "") {
            device.checkMessage(root: root)
            return 0
        }
        
        guard let message = root.getAttributeValue("message") else {
            print("No message content found.")
            return -1
        }
        
        var finalMessage: String = ""
        if let timestamp = root.getAttributeValue("timestamp") {
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
extension INDIBaseClient: INDISocketDelegate {
    public func processINDIProtocol(_ sender: INDISocket, root: INDIProtocolElement) -> Int {
        // Ignore echoed newXXX
        if root.tagName.contains("new") { return 0 }
        
        // Just ignore any getProperties we might get.
        if root.tagName == "getProperties" {
            return INDIErrorType.PropertyDuplicated.rawValue
        }
        
        if root.tagName == "pingRequest" {
            sendPingReply(uid: root.getAttributeValue("uid") ?? "")
            return 0
        }
        
        if root.tagName == "pingReply" {
            newPingReply(uid: root.getAttributeValue("uid") ?? "")
        }
        
        if root.tagName == "message" {
            return messageCommand(root: root)
        }
        
        if root.tagName == "delProperty" {
            return deletePropertyCommand(root: root)
        }
        
        // If device is set to BLOB Only, we ignore everything else not related to blobs.
        if getBLOBMode(deviceName: root.getAttributeValue("device") ?? "") == .Only && root.tagName != "defBLOBVector" && root.tagName != "setBLOBVector" { return 0 }
        
        return self._watchDevice.processXML(root: root, constructHandler: {
            let device = INDIBaseDevice()
            device.delegate = self
            return device
        })
    }
}
