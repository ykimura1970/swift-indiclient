//
//  INDIPropertyType.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDI Property type.
public enum INDIPropertyType {
    case INDINumber(_ vectorProperty: INDINumberVectorProperty = INDINumberVectorProperty())
    case INDISwitch(_ vectorProperty: INDISwitchVectorProperty = INDISwitchVectorProperty())
    case INDIText(_ vectorProperty: INDITextVectorProperty = INDITextVectorProperty())
    case INDILight(_ vectorProperty: INDILightVectorProperty = INDILightVectorProperty())
    case INDIBlob(_ vectorProperty: INDIBlobVectorProperty = INDIBlobVectorProperty())
    case INDIUnknown
    
    public init(_ object: INDIVectorProperty) {
        switch object {
        case is INDINumberVectorProperty: self = .INDINumber(object as! INDINumberVectorProperty)
        case is INDISwitchVectorProperty: self = .INDISwitch(object as! INDISwitchVectorProperty)
        case is INDITextVectorProperty: self = .INDIText(object as! INDITextVectorProperty)
        case is INDILightVectorProperty: self = .INDILight(object as! INDILightVectorProperty)
        case is INDIBlobVectorProperty: self = .INDIBlob(object as! INDIBlobVectorProperty)
        default: self = .INDIUnknown
        }
    }
    
    public var propertyIsEmpty: Bool {
        get {
            switch self {
            case .INDINumber(let vectorProperty): vectorProperty.propertyIsEmpty
            case .INDISwitch(let vectorProperty): vectorProperty.propertyIsEmpty
            case .INDIText(let vectorProperty): vectorProperty.propertyIsEmpty
            case .INDILight(let vectorProperty): vectorProperty.propertyIsEmpty
            case .INDIBlob(let vectorProperty): vectorProperty.propertyIsEmpty
            default: false
            }
        }
    }
    
    public var propertyCount: Int {
        get {
            switch self {
            case .INDINumber(let vectorProperty): vectorProperty.propertyCount
            case .INDISwitch(let vectorProperty): vectorProperty.propertyCount
            case .INDIText(let vectorProperty): vectorProperty.propertyCount
            case .INDILight(let vectorProperty): vectorProperty.propertyCount
            case .INDIBlob(let vectorProperty): vectorProperty.propertyCount
            default: .zero
            }
        }
    }
    
    public var vectorProperty: INDIVectorProperty? {
        get {
            switch self {
            case .INDINumber(let vectorProperty): vectorProperty
            case .INDISwitch(let vectorProperty): vectorProperty
            case .INDIText(let vectorProperty): vectorProperty
            case .INDILight(let vectorProperty): vectorProperty
            case .INDIBlob(let vectorProperty): vectorProperty
            case .INDIUnknown: nil
            }
        }
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        vectorProperty?.isDeviceNameMatch(otherName) ?? false
    }
    
    public func isPropertyNameMatch(_ otherName: String) -> Bool {
        vectorProperty?.isPropertyNameMatch(otherName) ?? false
    }
    
    public func isPropertyLabelMatch(_ otherLabel: String) -> Bool {
        vectorProperty?.isPropertyLabelMatch(otherLabel) ?? false
    }
}

extension INDIPropertyType: Equatable {
    public static func == (lhs: INDIPropertyType, rhs: INDIPropertyType) -> Bool {
        switch (lhs, rhs) {
        case (.INDINumber(_), .INDINumber(_)): true
        case (.INDISwitch(_), .INDISwitch(_)): true
        case (.INDIText(_), .INDIText(_)): true
        case (.INDILight(_), .INDILight(_)): true
        case (.INDIBlob(_), .INDIBlob(_)): true
        case (_, .INDIUnknown): true
        case (.INDIUnknown, _): true
        default: false
        }
    }
}
