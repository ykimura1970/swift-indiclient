//
//  INDIDBaseDeviceDelegate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/03.
//

import Foundation

public protocol INDIBaseDeviceDelegate: AnyObject {
    /// Emmited when a new device is created from INDI server.
    /// - Parameters:
    ///  - sender: A newly created instance of INDIBaseDevice.
    func newDevice(_ sender: INDIBaseDevice)
    
    /// Emmited when a device is deleted from INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice to be removed.
    func removeDevice(_ sender: INDIBaseDevice)

    /// Emmited when a new vector property is created for an INDI driver.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - property: INDIPropertyType enumeration.
    func newProperty(_ sender: INDIBaseDevice, property: INDIPropertyType)
    
    /// Emmited when a new properry value arrives from INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - property: INDIPropertyType enumeration..
    func updateProperty(_ sender: INDIBaseDevice, property: INDIPropertyType)
    
    /// Emmited when a vector property is deleted for an INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice form which the transfer originates.
    ///  - property: INDIPropertyType enumeration.
    func removeProperty(_ sender: INDIBaseDevice, property: INDIPropertyType)
    
    /// Emmited when a new message arrives from INDI server.
    /// - Parameters:
    ///  - sender: The instance of INDIBaseDevice from which the transfer originates.
    ///  - messageID: ID of the message that can be used to  retrieve the message from the device's messageQueue() function.
    func newMessage(_ sender: INDIBaseDevice, messageID: Int)
}
