//
//  INDISwitchProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation

@Observable
final public class INDISwitchProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    private(set) public var switchState: INDISwitchState
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, switchState: INDISwitchState) {
        self.switchState = switchState
        super.init(elementName: elementName, elementLabel: elementLabel)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", switchState: .Off)
    }
    
    // MARK: - Computed Property
    public var switchStateAsString: String {
        get {
            switchState.toString()
        }
    }
    
    public var switchStateAsBool: Bool {
        get {
            switchState.toBool()
        }
    }
    
    private var vectorProperty: INDISwitchVectorProperty? {
        get {
            parent as? INDISwitchVectorProperty
        }
    }
    
    // MARK: - Protocol Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        return INDISwitchProperty(elementName: self.elementName, elementLabel: self.elementLabel, switchState: self.switchState)
    }
    
    // MARK: - Original Method
    public func setSwitchState(_ switchState: INDISwitchState) {
        self.switchState = switchState
    }
    
    public func setSwitchState(from string: String) -> Bool {
        guard let switchState = INDISwitchState.switchState(from: string) else { return false }
        self.switchState = switchState
        return true
    }
    
    public func setSwitchState(from bool: Bool) {
        switchState = INDISwitchState.switchState(from: bool)
    }
    
    // MARK: - Override Method
    public override func clear() {
        switchState = .Off
        super.clear()
    }
}
