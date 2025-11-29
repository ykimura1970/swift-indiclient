//
//  INDIDeviceMediatorDelegate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/03.
//

import Foundation

public protocol INDIBaseMediatorDelegate: AnyObject {
    /// Emmited when a new device is created from INDI server.
    /// - Parameters:
    ///  - sender: Instance of the delegating object that inherits INDIAbstractClient.
    ///  - baseDevice: A newly created instance of INDIBaseDevice.
    func newDevice(sender: INDIBaseDevice)
    
    /// Emmited when a device is deleted from INDI server.
    /// - Parameters:
    ///  - sender: Instance of the delegating object that inherits INDIAbstractClient.
    ///  - baseDevice: The instance of INDIBaseDevice to be removed.
    func removeDevice(sender: INDIBaseDevice)

    /// Emmited when a new vector property is created for an INDI driver.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance.
    func newVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmited when a new properry value arrives from INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance.
    func updateVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmited when a vector property is deleted for an INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice form which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance.
    func removeVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmited when a new message arrives from INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - messageID: ID of the message that can be used to  retrieve the message from the device's messageQueue() function.
    func newMessage(sender: INDIBaseDevice, messageID: Int)

    /// Emmited when the server is connected.
    /// - Parameters:
    ///  - sender: Instance of the delegating object that inherits INDIAbstractClient.
    func serverConnected()

    /// Emmited when the server gets disconnected.
    /// - Parameters:
    ///  - sender: Instance of the delegating objec that inherits INDIAbstractClient.
    ///  - exitCode: 0 if client was requested to disconnect from server. -1 if connection to server is terminated due to remote server disconnection.
    func serverDisconnected(exitCode: Int)
}

// MARK: - Default Implement
public extension INDIBaseMediatorDelegate {
    func newDevice(sender: INDIBaseDevice) { }
    
    func removeDevice(sender: INDIBaseDevice) { }
    
    func newVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func updateVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func removeVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func newMessage(sender: INDIBaseDevice, messageID: Int) { }
    
    func serverConnected() { }
    
    func serverDisconnected(exitCode: Int) { }
}
