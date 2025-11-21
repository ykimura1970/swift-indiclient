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

struct INDIProtocolRequestWrapper {
    let request: INDIProtocolElement
    let promise: EventLoopPromise<INDIProtocolResponse>
}

class INDIProtocolHandler: ChannelDuplexHandler, @unchecked Sendable {
    public typealias InboundIn = INDIProtocolElement
    public typealias OutboundIn = INDIProtocolRequestWrapper
    public typealias OutboundOut = INDIProtocolElement
    
    private var queue = CircularBuffer<(INDIProtocolElement, EventLoopPromise<INDIProtocolResponse>)>()
    private var delegate: INDISocketDelegate?
    
    init(delegate: INDISocketDelegate? = nil) {
        self.delegate = delegate
    }
    
    // inbound
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        _ = delegate?.processINDIProtocol(root: response)
        
        if !queue.isEmpty {
            if let request = queue.first?.0 {
                if response.isAnswerBack(request: request) || !request.tagName.contains("set") {
                    let promise = queue.removeFirst().1
                    promise.succeed(INDIProtocolResponse(result: true))
                }
            }
        }
        
        context.fireChannelRead(data)
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: any Error) {
        context.fireErrorCaught(error)
    }
    
    // outobund
    public func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let requestWrapper = unwrapOutboundIn(data)
        context.write(wrapOutboundOut(requestWrapper.request), promise: promise)
        
        if requestWrapper.request.tagName.contains("new") {
            queue.append((requestWrapper.request, requestWrapper.promise))
        } else {
            requestWrapper.promise.succeed(INDIProtocolResponse(result: true))
        }
    }
}
