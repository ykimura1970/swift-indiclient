//
//  INDILightProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation

@Observable
final public class INDILightProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var lightState: INDIPropertyState
    
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
    
    // MARK: - Protocol Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDILightProperty(elementName: self.elementName, elementLabel: self.elementLabel, lightState: self.lightState)
    }
    
    // MARK: - Original Method
    public func setLightState(lightState: INDIPropertyState) {
        self.lightState = lightState
    }
    
    public func setLightState(from string: String) -> Bool {
        guard let lightState = INDIPropertyState.propertyState(from: string) else { return false }
        self.lightState = lightState
        return true
    }
    
    // MARK: - Override Method
    public override func clear() {
        lightState = .Idle
        super.clear()
    }
}
