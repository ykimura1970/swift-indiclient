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
    // MARK: - Fundamental Property
    internal var parent: INDIBaseClient?
    internal let lock = NIOLock()
    internal let group: MultiThreadedEventLoopGroup
    internal var channel: Channel?
    internal var timeout: TimeAmount
    
    // MARK: - Initializer
    public init() {
        self.timeout = .seconds(3)
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }
    
    // MARK: - Fundamental Method
    public func setParent(_ parent: INDIBaseClient) {
        self.parent = parent
    }
    
    public func setConnectionTimeout(_ timeout: Float) {
        self.timeout = .nanoseconds(Int64(timeout * 1_000_000_000))
    }
    
    public func connectToHost(hostname: String, port: Int) -> Bool {
        if channel == nil {
            do {
                _ = try lock.withLock({
                    let bootstrap = ClientBootstrap(group: self.group)
                        .channelOption(ChannelOptions.socket(.init(SOL_SOCKET), .init(SO_REUSEADDR)), value: 1)
                        .connectTimeout(self.timeout)
                        .channelInitializer({ channel in
                            channel.pipeline.addHandlers([ByteToMessageHandler(INDIProtocolFramingCodec()), MessageToByteHandler(INDIProtocolFramingCodec())])
                                .flatMap({
                                    channel.pipeline.addHandlers([INDIProtocolCodec(), INDIProtocolHandler(delegate: self.parent)])
                                })
                        })
                    
                    return bootstrap.connect(host: hostname, port: port).flatMap({ channel in
                        self.lock.withLock({
                            self.channel = channel
                        })
                        return channel.eventLoop.makeSucceededFuture(channel)
                    })
                }).wait()
            } catch {
                print("INDISocket.connectToHost: \(error)")
                return false
            }
            
            return true
        }
        
        return false
    }
    
    public func disconnectFromHost() -> Bool {
        self.lock.withLock({
            guard let channel = self.channel else { return false }
            channel.close(promise: nil)
            return true
        })
    }
    
    public func write(root: INDIProtocolElement) -> Bool {
        let result: EventLoopFuture<INDIProtocolResult> = self.lock.withLock({
            guard let channel = self.channel else {
                return self.group.next().makeFailedFuture(INDISocketError.notReady)
            }
            
            let promise: EventLoopPromise<INDIProtocolResponse> = channel.eventLoop.makePromise()
            let requestWrapper = INDIProtocolRequestWrapper(request: root, promise: promise)
            let future = channel.writeAndFlush(requestWrapper)
            future.cascadeFailure(to: promise) // if write fails.
            return future.flatMap({ promise.futureResult.map({ INDIProtocolResult($0) }) })
        })
        
        do {
            switch try result.wait() {
            case .success(let value):
                return value
            case .failure(let error):
                print("command write error: \(error)")
                return false
            }
        } catch {
            print("command write error: \(error)")
            return false
        }
    }
}
