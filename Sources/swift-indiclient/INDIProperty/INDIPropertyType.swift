//
//  INDIPropertyType.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/01.
//

import Foundation

/// INDI Property type.
public enum INDIPropertyType: Sendable {
    case INDINumber(_ property: INDINumberProperty = INDINumberProperty())
    case INDISwitch(_ property: INDISwitchProperty = INDISwitchProperty())
    case INDIText(_ property: INDITextProperty = INDITextProperty())
    case INDILight(_ property: INDILightProperty = INDILightProperty())
    case INDIBlob(_ property: INDIBlobProperty = INDIBlobProperty())
    case INDIUnknown
    
    public init(_ object: INDIProperty) {
        switch object {
        case is INDINumberProperty: self = .INDINumber(object as! INDINumberProperty)
        case is INDISwitchProperty: self = .INDISwitch(object as! INDISwitchProperty)
        case is INDITextProperty: self = .INDIText(object as! INDITextProperty)
        case is INDILightProperty: self = .INDILight(object as! INDILightProperty)
        case is INDIBlobProperty: self = .INDIBlob(object as! INDIBlobProperty)
        default: self = .INDIUnknown
        }
    }
    
    public var property: INDIProperty? {
        get {
            switch self {
            case .INDINumber(let numberProperty): numberProperty
            case .INDISwitch(let switchProperty): switchProperty
            case .INDIText(let textProperty): textProperty
            case .INDILight(let lightProperty): lightProperty
            case .INDIBlob(let blobProperty): blobProperty
            case .INDIUnknown: nil
            }
        }
    }
    
    public var numberProperty: INDINumberProperty? {
        get {
            if case let INDIPropertyType.INDINumber(numberProperty) = self {
                return numberProperty
            }
            return nil
        }
    }
    
    public var switchProperty: INDISwitchProperty? {
        get {
            if case let INDIPropertyType.INDISwitch(switchProperty) = self {
                return switchProperty
            }
            return nil
        }
    }
    
    public var textProperty: INDITextProperty? {
        get {
            if case let INDIPropertyType.INDIText(textProperty) = self {
                return textProperty
            }
            return nil
        }
    }
    
    public var lightProperty: INDILightProperty? {
        get {
            if case let INDIPropertyType.INDILight(lightProperty) = self {
                return lightProperty
            }
            return nil
        }
    }
    
    public var blobProperty: INDIBlobProperty? {
        get {
            if case let INDIPropertyType.INDIBlob(blobProperty) = self {
                return blobProperty
            }
            return nil
        }
    }
    
    public var isEmpty: Bool {
        get {
            switch self {
            case .INDINumber(let numberProperty): numberProperty.isEmpty
            case .INDISwitch(let switchProperty): switchProperty.isEmpty
            case .INDIText(let textProperty): textProperty.isEmpty
            case .INDILight(let lightProperty): lightProperty.isEmpty
            case .INDIBlob(let blobProperty): blobProperty.isEmpty
            default: false
            }
        }
    }
    
    public var count: Int {
        get {
            switch self {
            case .INDINumber(let numberProperty): numberProperty.count
            case .INDISwitch(let switchProperty): switchProperty.count
            case .INDIText(let textProperty): textProperty.count
            case .INDILight(let lightProperty): lightProperty.count
            case .INDIBlob(let blobProperty): blobProperty.count
            default: .zero
            }
        }
    }
    
    public var deviceName: String {
        get {
            self.property?.deviceName ?? ""
        }
    }
    
    public var propertyName: String {
        get {
            self.property?.propertyName ?? ""
        }
    }
    
    public var propertyLabel: String {
        get {
            self.property?.propertyLabel ?? ""
        }
    }
    
    public var groupName: String {
        get {
            self.property?.groupName ?? ""
        }
    }
    
    public var propertyState: INDIPropertyState {
        get {
            self.property?.propertyState ?? .Idle
        }
    }
    
    public var propertyPermission: INDIPropertyPermission {
        get {
            self.property?.propertyPermission ?? .ReadOnly
        }
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        property?.isDeviceNameMatch(otherName) ?? false
    }
    
    public func isPropertyNameMatch(_ otherName: String) -> Bool {
        property?.isPropertyNameMatch(otherName) ?? false
    }
    
    public func isPropertyLabelMatch(_ otherLabel: String) -> Bool {
        property?.isPropertyLabelMatch(otherLabel) ?? false
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
        case (.INDIUnknown, .INDIUnknown): true
        default: false
        }
    }
    
    public static func != (lhs: INDIPropertyType, rhs: INDIPropertyType) -> Bool {
        switch (lhs, rhs) {
        case (.INDINumber(_), .INDINumber(_)): false
        case (.INDISwitch(_), .INDISwitch(_)): false
        case (.INDIText(_), .INDIText(_)): false
        case (.INDILight(_), .INDILight(_)): false
        case (.INDIBlob(_), .INDIBlob(_)): false
        case (.INDIUnknown, .INDIUnknown): false
        default: true
        }
    }
}
