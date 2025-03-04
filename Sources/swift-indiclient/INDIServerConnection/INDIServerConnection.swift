//
//  INDIServerConnection.swift
//  INDIClient
//
//  Created by Yoshio Kimura Studio Parsec LLC on 2024/10/03.
//

import Foundation
import Network

public actor INDIServerConnection {
    // MARK: - Delegate Property
    weak var delegate: INDIServerConnectionDelegate?
    
    // MARK: - Private Property
    private let _host: String
    private let _port: UInt16
    private var _timeout: TimeInterval
    private let _connection: NWConnection
    private var _connected: Bool
    private var _receivedData: Data
    private var _indiParser: INDIProtocolParser
    
    // MARK: - Initializer
    public init(host: String, port: UInt16, timeout: TimeInterval = 3.0) {
        self._host = host
        self._port = port
        self._timeout = timeout
        self._connection = .init(host: NWEndpoint.Host(self._host), port: NWEndpoint.Port(rawValue: self._port)!, using: .tcp)
        self._connected = false
        self._receivedData = .init()
        self._indiParser = .init()
    }
    
    deinit {
        self._receivedData.removeAll()
    }
    
    // MARK: - Computed Property
    public var host: String {
        self._host
    }
    
    public var port: UInt16 {
        self._port
    }
    
    // MARK: - Fundamental Method
    public func setDelegate(delegate: INDIServerConnectionDelegate) {
        self.delegate = delegate
    }
    
    public func setTimeout(timeout: TimeInterval) {
        self._timeout = timeout
    }
    
    public func getTimeout() -> TimeInterval {
        self._timeout
    }
    
    /// Connect to the INDI Server.
    /// - Returns: If true, connection completed, otherwise false.
    public func connectToServer() async -> Bool {
        let result: Bool = await withCheckedContinuation({ continuation in
            _connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    continuation.resume(returning: true)
                case .waiting(let error):
                    print("INDIServerConnection.connectToServer: waiting \(error).")
                    continuation.resume(returning: false)
                case .failed(let error):
                    print("INDIServerConnection.connectToServer: failed \(error).")
                case .cancelled:
                    print("INDIServerConnection.connectToServer: cancelled.")
                    continuation.resume(returning: false)
                case .setup:
                    break
                case .preparing:
                    break
                @unknown default:
                    break
                }
            }
            _connection.start(queue: DispatchQueue(label: UUID().uuidString))
        })
        
        switch result {
        case true:
            _connected = true
            await delegate?.onConnected(sender: self)
            
            Task.detached(operation: { [weak self] in
                guard let self else { return }
                while await _connected {
                    await processReceive()
                }
            })
        case false:
            _connected = false
        @unknown default:
            _connected = false
            return false
        }
        
        return result
    }
    
    /// Disconnect from the INDI Server.
    public func disconnectFromServer() async {
        _connected = false
        _connection.stateUpdateHandler = nil
        _connection.cancel()
        await delegate?.onDisconnected(sender: self)
    }
    
    /// Sending data to the INDI Server.
    /// - Parameters:
    ///  - data: Data to send.
    /// - Returns: The number of bytes sent if successful, or 0 if unsuccessful.
    public func sendData(data: Data) async -> Int {
        let result: Bool = await withCheckedContinuation({ [weak self] continuation in
            self?._connection.send(content: data, completion: .contentProcessed({ error in
                if let error {
                    print("INDIServerConnection.sendData: \(error).")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true)
                }
            }))
        })
        return result ? data.count : 0
    }
}

// MARK: - Helper Method
extension INDIServerConnection {
    /// Receive data from the INDI Server.
    private func processReceive() async {
        let result: (data: Data?, error: Error?) = await withCheckedContinuation({ continuation in
            // Packet receive.
            self._connection.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: { [weak self] (data, context, isComplete, error) in
                if self?._connection.state == .ready && !isComplete, let data = data, !data.isEmpty {
                    continuation.resume(returning: (data, nil))
                } else {
                    continuation.resume(returning: (nil, error))
                }
            })
        })
        
        if let data = result.data {
            // Parsing the INDI Protocol.
            let elements = await _indiParser.parse(data: data)
            
            // Processing INDI Protocol parsing result.
            for element in elements {
                _ = await delegate?.processINDICommand(sender: self, xmlCommand: element)
            }
        } else if let error = result.error {
            print("INDIServerConnection.processReceive: \(error).")
            await disconnectFromServer()
            await delegate?.onDisconnected(sender: self)
        }
    }
}
