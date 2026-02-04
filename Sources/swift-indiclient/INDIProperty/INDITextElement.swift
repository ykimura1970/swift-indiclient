//
//  INDITextElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDITextElement: INDIElement, @unchecked Sendable {
    // MARK: - Original Property
    internal var _text: String
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", text: String = "", parent: INDIProperty? = nil) {
        self._text = text
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Computed Property
    public var text: String {
        get {
            self._lock.withLock({
                self._text
            })
        }
    }
    
    // MARK: - Original Method
    public func setText(_ text: String) {
        self._lock.withLockVoid({
            self._text = text
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._lock.withLockVoid({
            self._text = ""
        })
        super.clear()
    }
}
