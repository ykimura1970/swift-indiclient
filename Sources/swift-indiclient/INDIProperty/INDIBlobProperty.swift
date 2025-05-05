//
//  INDIBlobProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation
import os

final public class INDIBlobProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var format: String
    private(set) public var blob: Data
    private(set) public var blobLength: Int
    private(set) public var size: Int
    @ObservationIgnored private let lock = OSAllocatedUnfairLock()
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, format: String, blob: Data, blobLength: Int, size: Int) {
        self.format = format
        self.blob = blob
        self.blobLength = blobLength
        self.size = size
        super.init(elementName: elementName, elementLabel: elementLabel)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", format: "", blob: Data(), blobLength: 0, size: 0)
    }
    
    // MARK: - Computed Property
    public var vectorProperty: INDIBlobVectorProperty? {
        get {
            parent as? INDIBlobVectorProperty
        }
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDIBlobProperty(elementName: self.elementName, elementLabel: self.elementLabel, format: self.format, blob: self.blob, blobLength: self.blobLength, size: self.size)
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self.format = format
    }
    
    public func setBlob(blob: Data) {
        lock.withLock({
            self.blob = blob
        })
    }
    
    public func setBlobLength(_ blobLength: Int) {
        self.blobLength = blobLength
    }
    
    public func setSize(size: Int) {
        self.size = size
    }
    
    // MARK: - Override Method
    public override func clear() {
        format = ""
        lock.withLock({
            blob = Data()
        })
        blobLength = 0
        size = 0
        super.clear()
    }
}
