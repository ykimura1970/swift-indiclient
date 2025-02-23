//
//  INDILightProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation
import os

@Observable
final public class INDILightProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var lightState: INDIPropertyState
    private let lock: OSAllocatedUnfairLock = OSAllocatedUnfairLock()
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, lightState: INDIPropertyState) {
        self.lightState = lightState
        super.init(elementName: elementName, elementLabel: elementLabel)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", lightState: .Idle)
    }
    
    // MARK: - Computed Property
    var lightStateAsString: String {
        get {
            lightState.toString()
        }
    }
    
    var vectorProperty: INDILightVectorProperty? {
        get {
            parent as? INDILightVectorProperty
        }
    }
    
    // MARK: - Protocol Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDILightProperty(elementName: self.elementName, elementLabel: self.elementLabel, lightState: self.lightState)
    }
    
    // MARK: - Original Method
    public func setLightState(lightState: INDIPropertyState) {
        lock.lock()
        self.lightState = lightState
        lock.unlock()
    }
    
    public func setLightState(from string: String) -> Bool {
        guard let lightState = INDIPropertyState.propertyState(from: string) else { return false }
        lock.lock()
        self.lightState = lightState
        lock.unlock()
        return true
    }
    
    // MARK: - Override Method
    public override func clear() {
        lock.lock()
        lightState = .Idle
        lock.unlock()
        super.clear()
    }
}
