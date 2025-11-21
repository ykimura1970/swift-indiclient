//
//  INDILightVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

final public class INDILightVectorProperty: INDIVectorPropertyTemplate<INDILightProperty>, @unchecked Sendable {
    // MARK: - Initializer
    public init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", timestamp: String = "", dynamic: Bool = false) {
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, timestamp: timestamp, dynamic: dynamic)
    }
    
    // MARK: - Override Method
    public override func setPropertyPermission(_ propertyPermision: INDIPropertyPermission) { }
    
    public override func setPropertyPermission(from string: String) { }
    
    public override func setTimeout(_ timeout: Double) { }
    
    public override func setPropertyState(_ propertyState: INDIPropertyState) { }
    
    public override func setPropertyState(from string: String) { }
}
