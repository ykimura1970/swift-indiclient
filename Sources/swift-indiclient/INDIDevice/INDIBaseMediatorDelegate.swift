//
//  INDIDeviceMediatorDelegate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/03.
//

import Foundation

public protocol INDIDeviceMediatorDelegate: AnyObject, Sendable {
    /// Emmited when a new vector property is created for an INDI driver.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance.
    func newVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmited when a new property value arrives from INDI Server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance
    func updateVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmmited when a vector proeprty is deleted for an INDI Server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - vectorProperty: any INDIVectorProperty instance.
    func removeVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty)
    
    /// Emmited when a new message arrives from INDI Server.
    /// - Parameters:
    ///   - sender: The instance of INDIBaseDevice from witch the transfer originates.
    ///   - messageID: ID of the message that can be used to retrieve the message from the device's messageQueue() function.
    func newMessage(sender: INDIBaseDevice, messageID: Int)
}

// MARK: - Default Implement
public extension INDIDeviceMediatorDelegate {
    func newVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func updateVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func removeVectorProperty(sender: INDIBaseDevice, vectorProperty: INDIVectorProperty) { }
    
    func newMessage(sender: INDIBaseDevice, messageID: Int) { }
}
