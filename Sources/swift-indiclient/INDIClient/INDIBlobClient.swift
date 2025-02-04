//
//  INDIBlobClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/28.
//

public actor INDIBlobClient: INDIAbstractClient {
    // MARK: - Delegate Proeprty
    public weak var delegate: INDIClientMediatorDelegate?
    
    // MARK: - Fundamental Property
    public var serverConnection: INDIServerConnection
    public var serverConnected: Bool
    public var verbose: Bool
    public var baseDevices: [INDIBaseDevice]
    public var watchDevices: [String]
    public var blobHandling: INDIBlobHandling
    
    // MARK: - Priginal Property
    private var blobEnabled: Bool
    
    // MARK: - Initializer
    public init() {
        self.serverConnection = .init(host: "localhost", port: 7624)
        self.serverConnected = false
        self.verbose = false
        self.baseDevices = []
        self.watchDevices = []
        self.blobHandling = .Never
        self.blobEnabled = false
    }
    
    // MARK: - Protocol Method
    public func connectServer() async -> Bool {
        if serverConnected {
            print("INDIBlobClient.connectServer: Already connected.")
            return true
        }
        
        print("INDIBlobClient.connectServer: creating new connection...")
        
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
            print("INDIBlobClient.disconnectServer: Already disconnected.")
            return
        }
        
        await serverConnection.disconnectFromServer()
        clear()
        delegate?.serverDisconnected(sender: self)
        serverConnected = false
    }
    
    // MARK: - Original Method
    public func setBlobEnabled(enabled: Bool) async {
        if let deviceName = baseDevices.first?.deviceName {
            blobEnabled = enabled
            _ = await setBlobMode(deviceName: deviceName, blobHandling: (enabled ? INDIBlobHandling.Only : INDIBlobHandling.Never))
        }
    }
}
