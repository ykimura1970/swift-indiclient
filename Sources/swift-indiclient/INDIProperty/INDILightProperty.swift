//
//  INDILightProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import SwiftUI
import Combine

public class INDILightProperty: INDIProperty, ObservableObject {
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
            self.lightState.toString()
        }
    }
    
    var lightStateAsColor: Color {
        get {
            self.lightState.toColor()
        }
    }
    
    // MARK: - Original Method
    public func setLightState(lightState: INDIPropertyState) {
        self.lightState = lightState
    }
    
    public func setLightState(from stringLightState: String) {
        if let lightState = INDIPropertyState.propertyState(from: stringLightState) {
            self.lightState = lightState
        } else {
            self.lightState = .Ok
        }
    }
    
    // MARK: - Override Method
    public override func clear() {
        self.lightState = .Idle
        super.clear()
    }
}
