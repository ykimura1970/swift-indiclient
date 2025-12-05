//
//  INDIBlobProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Combine
internal import NIOConcurrencyHelpers

final public class INDIBlobProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    internal(set) public var format: String
    internal(set) public var blob: Data
    internal(set) public var blobLength: Int
    internal(set) public var size: Int
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", format: String = "", blob: Data = Data(), blobLength: Int = 0, size: Int = 0, parent: INDIVectorProperty? = nil) {
        self.format = format
        self.blob = blob
        self.blobLength = blobLength
        self.size = size
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        lock.withLock({
            self.format = format
        })
    }
    
    public func setBlob(blob: Data) {
        lock.withLock({
            self.blob = blob
        })
    }
    
    public func setBlobLength(_ blobLength: Int) {
        lock.withLock({
            self.blobLength = blobLength
        })
    }
    
    public func setSize(_ size: Int) {
        lock.withLock({
            self.size = size
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        lock.withLock({
            self.format = ""
            self.blob = Data()
            self.blobLength = 0
            self.size = 0
        })
        super.clear()
    }
}
