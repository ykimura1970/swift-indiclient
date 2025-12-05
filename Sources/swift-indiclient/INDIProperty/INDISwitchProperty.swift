//
//  INDISwitchProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Combine
internal import NIOConcurrencyHelpers

final public class INDISwitchProperty: INDIProperty, ObservableObject, @unchecked Sendable {
    // MARK: - Original Property
    @Published internal(set) public var switchState: INDISwitchState
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", switchState: INDISwitchState = .Off, parent: INDIVectorProperty? = nil) {
        self.switchState = switchState
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }

    // MARK: - Original Computed Property
    public var switchStateAsString: String {
        get {
            lock.withLock({
                self.switchState.toString()
            })
        }
    }
    
    public var switchStateAsBool: Bool {
        get {
            lock.withLock({
                self.switchState.toBool()
            })
        }
    }
    
    // MARK: - Original Method
    public func setSwitchState(_ switchState: INDISwitchState) {
        lock.withLock({
            self.switchState = switchState
        })
    }
    
    public func setSwitchState(from stringSwitchState: String) {
        lock.withLock({
            self.switchState = INDISwitchState.switchState(from: stringSwitchState) ?? .Off
        })
    }
    
    public func setSwitchState(from boolSwitchState: Bool) {
        lock.withLock({
            self.switchState = INDISwitchState.switchState(from: boolSwitchState)
        })
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        lock.withLock({
            INDISwitchProperty(elementName: self.elementName, elementLabel: self.elementLabel, switchState: self.switchState, parent: self.parent)
        })
    }
    
    public override func clear() {
        lock.withLock({
            self.switchState = .Off
        })
        super.clear()
    }
}
