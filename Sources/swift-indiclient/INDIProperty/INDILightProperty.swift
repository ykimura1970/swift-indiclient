//
//  INDILightProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDILightProperty: INDIPropertyTemplate<INDILightElement>, @unchecked Sendable {
    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyState: INDIPropertyState = .Idle, timestamp: String = "", dynamic: Bool = false) {
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyState: propertyState, timestamp: timestamp, dynamic: dynamic)
    }
    
    // MARK: - Override Method
    public override func setPropertyPermission(_ propertyPermision: INDIPropertyPermission) { }
    
    public override func setPropertyPermission(from stringPropertyPermission: String) { }
    
    public override func setTimeout(_ timeout: Double) { }
}
