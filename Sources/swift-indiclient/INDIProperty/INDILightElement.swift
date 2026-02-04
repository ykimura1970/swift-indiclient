//
//  INDILightElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDILightElement: INDIElement, @unchecked Sendable {
    // MARK: - Original Property
    internal var _lightState: INDIPropertyState
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", lightState: INDIPropertyState = .Ok, parent: INDIProperty? = nil) {
        self._lightState = lightState
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Original Computed Property
    public var lightState: INDIPropertyState {
        get {
            self._lock.withLock({
                self._lightState
            })
        }
    }
    
    public var lightStateAsString: String {
        get {
            self._lock.withLock({
                self._lightState.toString()
            })
        }
    }
    
    // MARK: - Original Method
    public func setLightState(lightState: INDIPropertyState) {
        self._lock.withLock({
            self._lightState = lightState
        })
    }
    
    public func setLightState(from stringLightState: String) {
        self._lock.withLockVoid({
            self._lightState = .init(rawValue: stringLightState) ?? .Ok
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._lock.withLockVoid({
            self._lightState = .Ok
        })
        super.clear()
    }
}
