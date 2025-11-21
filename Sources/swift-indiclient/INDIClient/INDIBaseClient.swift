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
internal import NIOConcurrencyHelpers
internal import NIOPosix

open class INDIBaseClient: INDIAbstractClient {
    // MARK: - Original Property
    var socket = INDISocket()
    
    /// Connect to INDI server.
    /// - Returns: True if the connection is successful, false otherwise.
    open override func connectServer() -> Bool {
        if serverConnected.load(ordering: .relaxed) {
            print("INDIBaseClient.connectServer: Already connected.")
            return false
        }
        
        print("INDIBaseClient.connectServer: creating new connection...")
        
        socket.setParent(self)
        if !socket.connectToHost(hostname: hostname, port: port) {
            serverConnected.store(false, ordering: .relaxed)
            return false
        }
        
        clear()
        serverConnected.store(true, ordering: .relaxed)
        delegate?.serverConnected(sender: self)
        sendGetProperties()
        
        return true
    }
    
    /// Disconnect from INDI server. Any devices previously created will be deleted and memory cleared.
    /// - Returns: True if disconnection is successful, false otherwise.
    open override func disconnectServer(exitCode: Int = 0) -> Bool {
        if !serverConnected.exchange(false, ordering: .relaxed) {
            print("INDIBaseClient.disconnectServer: Already disconnected.")
            return false
        }
        
        let result = socket.disconnectFromHost()
        delegate?.serverDisconnected(sender: self, exitCode: exitCode)
        
        return result
    }
    
    open override func sendData(command: INDIProtocolElement) -> Bool {
        socket.write(root: command)
    }
}
