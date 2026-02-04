//
//  INDIBlobElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDIBlobElement: INDIElement, @unchecked Sendable {
    // MARK: - Original Property
    internal var _format: String
    internal var _blob: Data
    internal var _blobLength: Int
    internal var _size: Int
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", format: String = "", blob: Data = Data(), blobLength: Int = 0, size: Int = 0, parent: INDIProperty? = nil) {
        self._format = format
        self._blob = blob
        self._blobLength = blobLength
        self._size = size
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Computed Property
    public var format: String {
        get {
            self._lock.withLock({
                self._format
            })
        }
    }
    
    public var blob: Data {
        get {
            self._lock.withLock({
                self._blob
            })
        }
    }
    
    public var blobLength: Int {
        get {
            self._lock.withLock({
                self._blobLength
            })
        }
    }
    
    public var size: Int {
        get {
            self._lock.withLock({
                self._size
            })
        }
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self._lock.withLockVoid({
            self._format = format
        })
    }
    
    public func setBlob(blob: Data) {
        self._lock.withLockVoid({
            self._blob = blob
        })
    }
    
    public func setBlobLength(_ blobLength: Int) {
        self._lock.withLockVoid({
            self._blobLength = blobLength
        })
    }
    
    public func setSize(_ size: Int) {
        self._lock.withLockVoid({
            self._size = size
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._lock.withLockVoid({
            self._format = ""
            self._blob = Data()
            self._blobLength = 0
            self._size = 0
        })
        super.clear()
    }
}
