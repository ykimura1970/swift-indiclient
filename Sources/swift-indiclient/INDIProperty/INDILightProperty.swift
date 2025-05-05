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
    @ObservationIgnored private let lock = OSAllocatedUnfairLock()
    
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
        lock.withLock({
            self.lightState = lightState
        })
    }
    
    public func setLightState(from string: String) -> Bool {
        guard let lightState = INDIPropertyState.propertyState(from: string) else { return false }
        lock.withLock({
            self.lightState = lightState
        })
        return true
    }
    
    // MARK: - Override Method
    public override func clear() {
        lock.withLock({
            lightState = .Idle
        })
        super.clear()
    }
}
