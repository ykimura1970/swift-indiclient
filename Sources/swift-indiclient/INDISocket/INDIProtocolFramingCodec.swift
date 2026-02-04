//
//  INDIProtocolFramingCodec.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation
internal import NIOCore
internal import NIOConcurrencyHelpers

final class INDIProtocolFramingCodec: ByteToMessageDecoder, Sendable {
    typealias InboundOut = ByteBuffer
    
    // inbound
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        if buffer.readableBytesView.last != UInt8(ascii: "\n") {
            return .needMoreData
        }
        
        if buffer.readableBytesView.first == UInt8(ascii: "\n") {
            buffer.moveReaderIndex(forwardBy: 1)
        }
        
        guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
            return .needMoreData
        }
        
        let parser = XMLParser(data: data)
        
        var count = buffer.readableBytes
        
        if !parser.parse() {
            let lines = buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes)!.split(separator: "\n")
            
            if parser.lineNumber > 1 || parser.lineNumber == 0 {
                return .needMoreData
            }
            
            count = lines[0..<parser.lineNumber - 1].reduce(0, { $0 + $1.count }) + parser.lineNumber - 1
            
            let slice = buffer.readSlice(length: count)!
            context.fireChannelRead(wrapInboundOut(slice))
            return .continue
        } else {
            context.fireChannelRead(wrapInboundOut(buffer))
            return .needMoreData
        }
    }
    
    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        while try decode(context: context, buffer: &buffer) == .continue { }
        return .needMoreData
    }
}
