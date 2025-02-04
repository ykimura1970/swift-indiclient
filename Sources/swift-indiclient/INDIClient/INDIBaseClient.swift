//
//  INDIBaseClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/28.
//

public actor INDIBaseClient: INDIAbstractClient {
    // MARK: - Delegate Property
    public weak var delegate: INDIClientMediatorDelegate?
    
    // MARK: - Fundamental Property
    public var serverConnection: INDIServerConnection
    public var serverConnected: Bool
    public var verbose: Bool
    public var baseDevices: [INDIBaseDevice]
    public var watchDevices: [String]
    public var blobHandling: INDIBlobHandling
    
    // MARK: - Initializer
    public init() {
        self.serverConnection = .init(host: "localhost", port: 7624)
        self.serverConnected = false
        self.verbose = false
        self.baseDevices = []
        self.watchDevices = []
        self.blobHandling = .Never
    }
    
    // MARK: - Protocol Method
    public func connectServer() async -> Bool {
        if serverConnected {
            print("INDIBaseClient.connectServer: Already connected.")
            return true
        }
        
        print("INDIBaseClient.connectServer: creating new connection.")
        
        await serverConnection.setDelegate(delegate: self)
        if await !serverConnection.connectToServer() {
            serverConnected = false
            return false
        }
        
        serverConnected = true
        delegate?.serverConnected(sender: self)
        await sendGetPropertiesCommand()
        
        return true
    }
    
    public func disconnectServer() async {
        if !serverConnected {
            print("INDIBaseClient.disconnectServer: Already disconnected.")
        }
        
        await serverConnection.disconnectFromServer()
        clear()
        _ = delegate?.serverDisconnected(sender: self)
    }
    
    // MARK: - Original Method
    /// Connect to INDI driver.
    /// - Parameters:
    ///  - deviceName: device name to connect to.
    public func connectDevice(deviceName: String) async {
        await setDriverConnection(deviceName: deviceName, status: true)
    }
    
    /// Disconnect INDI driver.
    /// - Parameters:
    ///  - deviceName: device name to disconnect.
    public func disconnectDevice(deviceName: String) async {
        await setDriverConnection(deviceName: deviceName, status: false)
    }
    
    // MARK: - Original Helper Method
    private func setDriverConnection(deviceName: String, status: Bool) async {
        if let baseDevice = getBaseDevice(deviceName: deviceName) {
            if let connectionVectorProperty = await baseDevice.getSwitchVectorProperty(propertyName: "CONNECTION") {
                // If we need to connect.
                if status {
                    // If there is no need to do anything, i.e. already conencted.
                    if connectionVectorProperty.findPropertyByElementName("CONNECT")?.switchState == .On {
                        return
                    }
                    
                    let newProperties = connectionVectorProperty.copyProperties
                    newProperties.forEach({ $0.setSwitchState(.Off) })
                    newProperties.first(where: { $0.isElementNameMatch("CONNECT") })?.setSwitchState(.On)
                    
                    _ = await sendData(data: connectionVectorProperty.createNewCommand(newProperties: newProperties).data(using: .ascii)!)
                } else {
                    // If there is no need to do anything, i.e. already disconnected.
                    if connectionVectorProperty.findPropertyByElementName("DISCONNECT")?.switchState == .On {
                        return
                    }
                    
                    let newProperties = connectionVectorProperty.copyProperties
                    newProperties.forEach({ $0.setSwitchState(.Off) })
                    newProperties.first(where: { $0.isElementNameMatch("DISCONNECT") })?.setSwitchState(.On)
                    
                    _ = await sendData(data: connectionVectorProperty.createNewCommand(newProperties: newProperties).data(using: .ascii)!)
                }
                
                return
            }
        }
        
        print("INDIBaseClient.setDriverConnection: Unable to find driver \(deviceName).")
        return
    }
}
