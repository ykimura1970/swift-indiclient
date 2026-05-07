//
//  INDISocket.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/19.
//

import Foundation
internal import NIOCore
internal import NIOFoundationCompat
internal import NIOConcurrencyHelpers
internal import NIOPosix

public class INDISocket: @unchecked Sendable {
    // MARK: - Delegate Property
    weak var delegate: INDISocketDelegate?
    
    // MARK: - Fundamental Property
    internal let lock = NIOLock()
    internal let group: MultiThreadedEventLoopGroup
    internal var channel: Channel?
    internal var timeout: TimeAmount
    
    // MARK: - Initializer
    public init(numberOfThreads: Int = 1) {
        self.timeout = .seconds(3)
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
    }
    
    // MARK: - Fundamental Method
    public func setConnectionTimeout(_ timeout: Float) {
        self.timeout = .nanoseconds(Int64(timeout * 1_000_000_000))
    }
    
    public func connectToHost(hostname: String, port: Int) async -> Bool {
        if self.channel == nil {
            do {
                let bootstrap = ClientBootstrap(group: self.group)
                    .channelOption(ChannelOptions.socket(.init(SOL_SOCKET), .init(SO_REUSEADDR)), value: 1)
                    .connectTimeout(self.timeout)
                    .channelInitializer({ channel in
                        channel.pipeline.addHandler(ByteToMessageHandler(INDIProtocolFramingCodec()))
                            .flatMap({
                                channel.pipeline.addHandlers([INDIProtocolDecoder(), INDIProtocolHandler(parent: self)])
                            })
                    })
                
                self.channel = try await bootstrap.connect(host: hostname, port: port).flatMap({ channel in
                    self.channel = channel
                    return channel.eventLoop.makeSucceededFuture(channel)
                }).get()
            } catch {
                print("INDISocket.connectToHost: \(error)")
                return false
            }
            
            return true
        }
        
        return false
    }
    
    public func disconnectFromHost() async -> Bool {
        guard let channel = self.channel else { return false }
        channel.close(promise: nil)
        
        do {
            try await group.shutdownGracefully()
        } catch {
            print("INDISocket.disconnectFromHost: \(error)")
            return false
        }
        
        return true
    }
    
    public func write(root: INDIProtocolElement) -> Bool {
        guard let channel = self.channel else { return false }
        
        channel.writeAndFlush(root, promise: nil)
        return true
    }
    
    public func processReceivedData(root: INDIProtocolElement) {
        _ = self.delegate?.processINDIProtocol(self, root: root)
    }
}
