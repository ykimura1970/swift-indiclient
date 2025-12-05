//
//  INDILightProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import SwiftUI
import Combine
internal import NIOConcurrencyHelpers

final public class INDILightProperty: INDIProperty, ObservableObject, @unchecked Sendable {
    // MARK: - Original Property
    @Published internal(set) public var lightState: INDIPropertyState
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", lightState: INDIPropertyState = .Ok, parent: INDIVectorProperty? = nil) {
        self.lightState = lightState
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Original Computed Property
    var lightStateAsString: String {
        get {
            lock.withLock({
                self.lightState.toString()
            })
        }
    }
    
    var lightStateAsColor: Color {
        get {
            lock.withLock({
                self.lightState.toColor()
            })
        }
    }
    
    // MARK: - Original Method
    public func setLightState(lightState: INDIPropertyState) {
        lock.withLock({
            self.lightState = lightState
        })
    }
    
    public func setLightState(from stringLightState: String) {
        lock.withLock({
            self.lightState = INDIPropertyState.propertyState(from: stringLightState) ?? .Ok
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        lock.withLock({
            self.lightState = .Ok
        })
        super.clear()
    }
}
