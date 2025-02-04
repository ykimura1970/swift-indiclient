//
//  INDIServerConnectionDelegate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/03.
//

import Foundation

public protocol INDIServerConnectionDelegate: Actor {
    /// What happends when you connected to an INDI Server.
    /// - Parameters:
    ///  - sender: The INDIServerConnection instance from which the connection originates.
    func onConnected(sender: INDIServerConnection)
    
    /// What happends when you disconnect INDI Server.
    /// - Parameters:
    ///  - sender: THe INDIServerConnection instance from which the connection originates.
    func onDisconnected(sender: INDIServerConnection)
    
    /// Process INDI Protocol command received from INDI Server to respective devices handled by the client.
    /// - Parameters:
    ///  - sender: THe INDIServerConnection instance from which the connection originates.
    nonisolated func processINDICommand(sender: INDIServerConnection, xmlCommand: INDIProtocolElement) async -> Int
}

// MARK: - Default Implement.
public extension INDIServerConnectionDelegate {
    func onConnected(sender: INDIServerConnection) { }
    
    func onDisconnected(sender: INDIServerConnection) { }
    
    nonisolated func processINDICommand(sender: INDIServerConnection, xmlCommand: XMLElement) async -> Int { 0 }
}
