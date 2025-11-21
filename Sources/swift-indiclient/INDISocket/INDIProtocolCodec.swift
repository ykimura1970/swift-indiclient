//
//  INDIProtocolCodec.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation
internal import NIOCore
internal import NIOFoundationCompat

class INDIProtocolCodec: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = INDIProtocolElement
    typealias OutboundIn = INDIProtocolElement
    typealias OutboundOut = String
    
    // inbound
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let data = buffer.readData(length: buffer.readableBytes)!
        
        do {
            let element = try INDIProtocolStackParser.parse(with: data)
            context.fireChannelRead(wrapInboundOut(element))
        } catch {
            context.fireErrorCaught(error)
        }
    }
    
    // outbound
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let element = unwrapOutboundIn(data)
        context.write(wrapOutboundOut(element.createXMLString()), promise: promise)
    }
}
