//
//  INDISocketDelegate.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

public protocol INDISocketDelegate: AnyObject {
    /// Process received data from INDI server to respective devices handled by the client.
    /// - Parameters:
    ///  - sender: The INDISocket instance from which the connection originates.
    ///  - root: INDIProtocolElement instance.
    func processINDIProtocol(_ sender: INDISocket, root: INDIProtocolElement) -> Int
}
