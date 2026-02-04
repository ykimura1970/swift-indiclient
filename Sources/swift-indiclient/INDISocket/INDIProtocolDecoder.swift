//
//  INDIProtocolDecoder.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2026/02/02.
//

import Foundation
internal import NIOCore
internal import NIOFoundationCompat

final class INDIProtocolDecoder: ChannelInboundHandler, Sendable {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = INDIProtocolElement
    
    // inbound
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let protocolData = buffer.readData(length: buffer.readableBytes)!
        
        do {
            let element = try INDIProtocolStackParser.parse(with: protocolData)
            context.fireChannelRead(wrapInboundOut(element))
        } catch {
            context.fireErrorCaught(error)
        }
    }
}
