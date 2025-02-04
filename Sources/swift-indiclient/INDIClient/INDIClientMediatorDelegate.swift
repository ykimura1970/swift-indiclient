//
//  INDIClientMediatorDelegate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/02.
//

import Foundation

public protocol INDIClientMediatorDelegate: AnyObject, Sendable {
    /// Emmited when a new device is created from INDI Server.
    /// - Parameters:
    ///  - sender: instance of the delegating object that inherits INDIAbstractClient
    ///  - baseDevice: A newly created instance of INDIBaseDevice
    func newDevice(sender: INDIAbstractClient, baseDevice: INDIBaseDevice)
    
    /// Emmited when a device is deleted from INDI Server.
    /// - Parameters:
    ///  - sender: Insstance of the delegating object that inherits INDIAbstractClient
    ///  - baseDevice: The instance of INDIBaseDevice to be removed.
    func removeDevice(sender: INDIAbstractClient, baseDevice: INDIBaseDevice)
    
    /// Emmited when the server is connected.
    /// - Parameters:
    ///  - sender: Instance of the delegating object that inherits INDIAbstractClient
    func serverConnected(sender: INDIAbstractClient)
    
    /// Emmited when the server gets disconnected.
    /// - Parameters:
    ///  - sender: Instance of the delegating object that inherits INDIAbstractClient
    func serverDisconnected(sender: INDIAbstractClient)
}

// MARK: - Default Implement
public extension INDIClientMediatorDelegate {
    func newDevice(sender: INDIAbstractClient, baseDevice: INDIBaseDevice) { }
    
    func removeDevice(sender: INDIAbstractClient, baseDevice: INDIBaseDevice) { }
    
    func serverConnected(sender: INDIAbstractClient) { }
    
    func serverDisconnected(sender: INDIAbstractClient) { }
}
