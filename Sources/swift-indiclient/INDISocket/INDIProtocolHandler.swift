//
//  INDIProtocolHandler.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation
internal import NIOCore
internal import NIOConcurrencyHelpers
internal import NIOPosix

class INDIProtocolHandler: ChannelDuplexHandler, @unchecked Sendable {
    public typealias InboundIn = INDIProtocolElement
    public typealias OutboundIn = INDIProtocolElement
    public typealias OutboundOut = ByteBuffer

    weak private let _parent: INDISocket?
    
    init(parent: INDISocket) {
        self._parent = parent
    }
    
    // inbound
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let element = unwrapInboundIn(data)
        
        if let socket = self._parent {
            socket.processReceivedData(root: element)
        }
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: any Error) {
        context.fireErrorCaught(error)
    }
    
    // outobund
    public func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let element = unwrapOutboundIn(data)
        let sendData = element.createXMLString().data(using: .ascii)!
        let buffer = ByteBuffer(data: sendData)
        
        context.write(wrapOutboundOut(buffer), promise: nil)
    }
}
