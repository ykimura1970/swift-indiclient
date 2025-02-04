//
//  INDIAbstractClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/28.
//

import Foundation

public protocol INDIAbstractClient: Actor, INDIServerConnectionDelegate {
    // MARK: - Delegate Property
    var delegate: INDIClientMediatorDelegate? { get set }
    
    // MARK: - Fundamental Property
    var serverConnection: INDIServerConnection { get set }
    var serverConnected: Bool { get set }
    var verbose: Bool { get set }
    var baseDevices: [INDIBaseDevice] { get set }
    var watchDevices: [String] { get set }
    var blobHandling: INDIBlobHandling { get set }
    
    // MARK: - Computed Property
    var isServerConnected: Bool { get }
    var isVerbose: Bool { get }
    
    // MARK: - Fundamental Method
    /// Set the class instance to which INDIClientMediatorDelegate is applied.
    /// - Parameters:
    ///  - delegate: The class instance to which INDIClientMediatorDelegate is applied.
    func setDelegate(delegate: (any INDIClientMediatorDelegate)?)
    
    /// Set verbose mode.
    /// - Parameters:
    ///  - enable: If true, enable FULL verbose output. Any XML message output, including BLOBs, are printed on standard output. Only use this for debugging purpopse.
    func setVerbose(enable: Bool)
    
    /// Add a device to watch list.
    /// - Parameters:
    ///  - devieName: device name of watch.
    func appendWatchDevice(deviceName: String)
    
    /// Add a device.
    /// - Parameters:
    ///  - baseDevice: INDIBaseDevice instance.
    func appendBaseDevice(baseDevice: INDIBaseDevice)
    
    /// Get  base device of the specified device name.
    /// - Parameters:
    ///  - deviceName: device name.
    /// - Returns: An instance of INDIBaseDevice for the given device name.
    func getBaseDevice(deviceName: String) -> INDIBaseDevice?
    
    /// Clear device and watch devices.
    func clear()
    
    // MARK: - Server Method
    /// Set the server connection object.
    /// - Parameters:
    ///  - serverConnection: INDIServerConnection instance.
    func setServerConnection(serverConnection: INDIServerConnection)
    
    /// Connect to INDI Server.
    func connectServer() async -> Bool
    
    /// Disconnect from INDI Server. Any decides previously created will be  deleted and memory cleared.
    func disconnectServer() async 
    
    /// Set binary large object policy mode.
    /// - Parameters:
    ///  - deviceName: device name.
    ///  - blobHandling: binary large object policy.
    func setBlobMode(deviceName: String, blobHandling: INDIBlobHandling) async -> Bool
    
    /// Get binary large object policy if set previously by setBlobMode.
    /// - Returns: binary large object policy.
    func getBlobMode() -> INDIBlobHandling
    
    /// Send Data.
    /// - Parameters:
    ///  - data: send data.
    /// - Returns: The number of bytes sent if the send was successful, otherwise 0.
    func sendData(data: Data) async -> Int
    
    func newUniversalMessage(message: String)
}

// MARK: - Default Implement
public extension INDIAbstractClient {
    var isServerConnected: Bool {
        serverConnected
    }
    
    var isVerbose: Bool {
        verbose
    }
    
    func setDelegate(delegate: (any INDIClientMediatorDelegate)?) {
        self.delegate = delegate
    }
    
    func setVerbose(enable: Bool) {
        verbose = enable
    }
    
    func appendWatchDevice(deviceName: String) {
        watchDevices.append(deviceName)
    }
    
    func appendBaseDevice(baseDevice: INDIBaseDevice) {
        baseDevices.append(baseDevice)
    }
    
    func getBaseDevice(deviceName: String) -> INDIBaseDevice? {
        baseDevices.first(where: { $0.isDeviceNameMatch(deviceName) })
    }
    
    func clear() {
        baseDevices.removeAll()
        watchDevices.removeAll()
        blobHandling = .Never
    }
    
    func setServerConnection(serverConnection: INDIServerConnection) {
        self.serverConnection = serverConnection
    }
    
    func setBlobMode(deviceName: String, blobHandling: INDIBlobHandling) async -> Bool {
        self.blobHandling = blobHandling
        
        let attribute = XMLElement(kind: .attribute)
        attribute.name = "device"
        attribute.stringValue = deviceName
        
        let element = XMLElement(name: "enableBLOB")
        element.stringValue = blobHandling.toString()
        element.addAttribute(attribute)
        
        return await sendData(data: element.xmlString.data(using: .ascii)!) > 0
    }
    
    func getBlobMode() -> INDIBlobHandling {
        blobHandling
    }
    
    func sendData(data: Data) async -> Int {
        return await serverConnection.sendData(data: data)
    }
    
    func newUniversalMessage(message: String) { }
    
    func onConnected(sender: INDIServerConnection) {
        serverConnected = true
    }
    
    func onDisconnected(sender: INDIServerConnection) {
        serverConnected = false
    }
    
    nonisolated func processINDICommand(sender: INDIServerConnection, xmlCommand: INDIProtocolElement) async -> Int {
        let tagName = xmlCommand.tagName
        
        // Ignore echoed newXXX.
        if tagName.hasPrefix("new") { return 0 }
        
        if tagName == "message" {
            return await messageCmd(xmlCommand: xmlCommand)
        }
        
        if tagName == "delProperty" {
            return await delVectorPropertyCmd(xmlCommand: xmlCommand)
        }
        
        if tagName == "getProperpties" {
            return INDIErrorType.PropertyDuplicated.rawValue
        }
        
        // If BlobMode is Only, we ignore everything else not related to blobs.
        if await blobHandling == .Only && tagName != "defBLOBVector" && tagName != "setBLOBVector" {
            return 0
        }
        
        if let baseDevice = await findDevice(xmlCommand: xmlCommand, create: true) {
            if tagName.hasPrefix("def") {
                return await baseDevice.buildVectorProperty(xmlCommand: xmlCommand)
            } else if tagName.hasPrefix("set") {
                return await baseDevice.updateVectorProperty(xmlCommand: xmlCommand)
            }
        }
        
        return INDIErrorType.DeviceNotFound.rawValue
    }
}

// MARK: - Helper Method
extension INDIAbstractClient {
    /// Find a device, and if it does not exists, if create is set true.
    /// - Parameters:
    ///  - xmlCommand: XML element.
    ///  - create: If INDIBaseDevice does not exists, create a new one if create is true, do nothing if false.
    /// - Returns: An existing or new ly created INDIBaseDevice instance, otherwise nil.
    internal func findDevice(xmlCommand: INDIProtocolElement, create: Bool) async -> INDIBaseDevice? {
        guard let deviceName = xmlCommand.attributes["device"] else {
            print("No device attribute found in element \(xmlCommand.tagName).")
            return nil
        }
        
        if deviceName.isEmpty {
            print("Device name is empty! \(xmlCommand.tagName).")
            return nil
        }
        
        if let baseDevice = getBaseDevice(deviceName: deviceName) {
            return baseDevice
        }
        
        // Not found, create if true.
        if create {
            let baseDevice = INDIBaseDevice(deviceName: deviceName)
            appendBaseDevice(baseDevice: baseDevice)
            delegate?.newDevice(sender: self, baseDevice: baseDevice)
            return baseDevice
        }
        
        print("INDI <\(xmlCommand.tagName)> No such device \(deviceName).")
        return nil
    }
    
    internal func delVectorPropertyCmd(xmlCommand: INDIProtocolElement) async -> Int {
        guard let deviceName = xmlCommand.attributes["device"], let baseDevice = getBaseDevice(deviceName: deviceName) else {
            return INDIErrorType.DeviceNotFound.rawValue
        }
        
        await baseDevice.checkMessage(xmlCommand: xmlCommand)
        
        guard let propertyName = xmlCommand.attributes["name"] else {
            return removeDevice(deviceName: deviceName)
        }
        
        if let vectorProperty = await baseDevice.getVectorProperty(propertyName: propertyName) {
            if serverConnected {
                await baseDevice.delegate?.removeVectorProperty(sender: baseDevice, vectorProperty: vectorProperty)
            }
            return await baseDevice.removeVectorProperty(propertyName: propertyName)
        }
        
        // Silently ignore BLOBHandling Only clients.
        if blobHandling == .Only {
            return 0
        }
        
        print("Cannot delete property \(propertyName) as it is not defined yet. Check driver.")
        return -1
    }
    
    internal func removeDevice(deviceName: String) -> Int {
        if let baseDevice = baseDevices.first(where: { $0.isDeviceNameMatch(deviceName) }) {
            delegate?.removeDevice(sender: self, baseDevice: baseDevice)
            baseDevices.removeAll(where: { $0 === baseDevice })
            watchDevices.removeAll(where: { $0 == deviceName })
            return 0
        }
        
        print("Device \(deviceName) not found.")
        return INDIErrorType.DeviceNotFound.rawValue
    }
    
    nonisolated internal func messageCmd(xmlCommand: INDIProtocolElement) async -> Int {
        if let baseDevice = await findDevice(xmlCommand: xmlCommand, create: false) {
            await baseDevice.checkMessage(xmlCommand: xmlCommand)
        } else {
            guard let message = xmlCommand.attributes["message"] else {
                print("No message content found.")
                return -1
            }
            
            var finalMessage = ""
            if let timestamp = xmlCommand.attributes["timestamp"] {
                finalMessage = "\(timestamp): \(message)"
            } else {
                let formatter = ISO8601DateFormatter()
                finalMessage = formatter.string(from: Date()).dropLast() + ": \(message)"
            }
            await newUniversalMessage(message: finalMessage)
        }
        
        return 0
    }
    
    internal func sendGetPropertiesCommand() async {
        if watchDevices.isEmpty {
            let stringCommand = createGetPropertiesCOmmand(deviceName: "")
            if let data = stringCommand.data(using: .ascii) {
                _ = await sendData(data: data)
                
                if isVerbose { print("\(stringCommand)") }
            }
        } else {
            for deviceName in watchDevices {
                let stringCommand = createGetPropertiesCOmmand(deviceName: deviceName)
                if let data = stringCommand.data(using: .ascii) {
                    _ = await sendData(data: data)
                    
                    if isVerbose { print("\(stringCommand)") }
                }
            }
        }
    }
    
    internal func createGetPropertiesCOmmand(deviceName: String) -> String {
        var xmlString = "<getProperties version='\(INDIProtocolVersion)'"
        
        if !deviceName.isEmpty {
            xmlString = "\(xmlString) device='\(deviceName)'"
        }
        
        return "\(xmlString)/>"
    }
}
