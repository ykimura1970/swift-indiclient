//
//  INDILightVectorProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

final public class INDILightVectorProperty: INDIVectorPropertyTemplate<INDILightProperty>, @unchecked Sendable {
    // MARK: - Initializer
    public init() {
        super.init(deviceName: "", propertyName: "", propertyLabel: "", groupName: "", propertyPermission: .ReadOnly, timeout: 0.0, propertyState: .Idle, timestamp: "", propertyType: .INDILight)
    }
    
    // MARK: - Override Method
    public override func setPropertyPermission(_ propertyPermision: INDIPropertyPermission) { }
    
    public override func setPropertyPermission(from string: String) -> Bool { return true }
    
    public override func setTimeout(_ timeout: Double) { }
    
    public override func setPropertyState(_ propertyState: INDIPropertyState) { }
    
    public override func setPropertyState(from string: String) -> Bool { return true }
}
