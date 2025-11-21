//
//  INDIProtocolFramingCodec.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation
internal import NIOCore
internal import NIOConcurrencyHelpers

enum FramingCodecError: Error {
    case badFraming
}


class INDIProtocolFramingCodec: ByteToMessageDecoder, MessageToByteEncoder, @unchecked Sendable {
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = String
    
    // inbound
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard buffer.readableBytesView.first == UInt8(ascii: " ") || buffer.readableBytesView.first == UInt8(ascii: "<") || buffer.readableBytesView.first == UInt8(ascii: "\n") else {
            throw FramingCodecError.badFraming
        }
        
        guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
            return .needMoreData
        }
        
        let parser = XMLParser(data: data)
        
        var count = buffer.readableBytes
        if !parser.parse() {
            let lines = buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes)!.split(separator: "\n")
            
            if parser.lineNumber == lines.count && parser.columnNumber == lines.last!.count + 1 {
                return .needMoreData
            }
            
            count = lines[0..<parser.lineNumber - 1].reduce(0, { $0 + $1.count }) + parser.lineNumber - 1
        }
        
        let slice = buffer.readSlice(length: count)!
        context.fireChannelRead(wrapInboundOut(slice))
        
        if parser.parse() { return .needMoreData }
        return .continue
    }
    
    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        while try decode(context: context, buffer: &buffer) == .continue { }
        return .needMoreData
    }
    
    func encode(data: String, out: inout ByteBuffer) throws {
        var buffer = ByteBuffer(string: data)
        out.writeBuffer(&buffer)
    }
}
