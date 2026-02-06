//
//  INDISwitchElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDISwitchElement: INDIElement, @unchecked Sendable {
    // MARK: - Original Property
    internal var _switchState: INDISwitchState
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", switchState: INDISwitchState = .Off, parent: INDIProperty? = nil) {
        self._switchState = switchState
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }

    // MARK: - Original Computed Property
    public var switchState: INDISwitchState {
        get {
            self._lock.withLock({
                self._switchState
            })
        }
    }
    
    public var switchStateAsString: String {
        get {
            self._lock.withLock({
                self._switchState.toString()
            })
        }
    }
    
    public var switchStateAsBool: Bool {
        get {
            self._lock.withLock({
                self._switchState.toBool()
            })
        }
    }
    
    // MARK: - Original Method
    public func setSwitchState(_ switchState: INDISwitchState) {
        self._lock.withLock({
            self._switchState = switchState
        })
    }
    
    public func setSwitchState(from stringSwitchState: String) {
        self._lock.withLock({
            self._switchState = .init(rawValue: stringSwitchState) ?? .Off
        })
    }
    
    public func setSwitchState(from boolSwitchState: Bool) {
        self._lock.withLock({
            self._switchState = .init(from: boolSwitchState)
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._lock.withLock({
            self._switchState = .Off
        })
        super.clear()
    }
}
