//
//  INDIDriverInterface.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/02.
//

import Foundation

/// The DRIVER INTERFACE enum defines the class to devices the driver implements.
/// A driver may implement one or more interface.
public struct INDIDriverInterface: OptionSet, Sendable {
    public var rawValue: UInt16
    
    public static let GeneralInterface         = INDIDriverInterface([])
    public static let TelescocpeInterface      = INDIDriverInterface(rawValue: 1 << 0)
    public static let CCDInterface             = INDIDriverInterface(rawValue: 1 << 1)
    public static let GuiderInterface          = INDIDriverInterface(rawValue: 1 << 2)
    public static let FocuserInterface         = INDIDriverInterface(rawValue: 1 << 3)
    public static let FilterInterface          = INDIDriverInterface(rawValue: 1 << 4)
    public static let DomeInterface            = INDIDriverInterface(rawValue: 1 << 5)
    public static let GPSInterface             = INDIDriverInterface(rawValue: 1 << 6)
    public static let WeatherInterface         = INDIDriverInterface(rawValue: 1 << 7)
    public static let AdaptiveOpticsInterface  = INDIDriverInterface(rawValue: 1 << 8)
    public static let DustcapInterface         = INDIDriverInterface(rawValue: 1 << 9)
    public static let LightBoxInterface        = INDIDriverInterface(rawValue: 1 << 10)
    public static let DetectorInterface        = INDIDriverInterface(rawValue: 1 << 11)
    public static let RotatorInterface         = INDIDriverInterface(rawValue: 1 << 12)
    public static let SpectrographInterface    = INDIDriverInterface(rawValue: 1 << 13)
    public static let CorrelatorInterface      = INDIDriverInterface(rawValue: 1 << 14)
    public static let AuxInterface             = INDIDriverInterface(rawValue: 1 << 15)
    public static let SensorInterface          = INDIDriverInterface(rawValue: SpectrographInterface.rawValue + DetectorInterface.rawValue + CorrelatorInterface.rawValue)
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public init(rawValues: [UInt16]) {
        self.rawValue = rawValues.reduce(0) { $0 | $1 }
    }
    
    public func toInterfaces() -> [UInt16] {
        var interfaces: [UInt16] = []
        
        if self.rawValue == 0 {
            return [0]
        }
        
        for bit in 0..<16 {
            if self.rawValue & (1 << bit) != 0 {
                interfaces.append(1 << bit)
            }
        }
        
        return interfaces
    }
    
    public func toStrings() -> [String] {
        var strings: [String] = []
        
        if self.rawValue == 0 {
            strings.append("General")
        }
        if self.rawValue & Self.TelescocpeInterface.rawValue != 0 {
            strings.append("Telescocpe")
        }
        if self.rawValue & Self.CCDInterface.rawValue != 0 {
            strings.append("CCD")
        }
        if self.rawValue & Self.GuiderInterface.rawValue != 0 {
            strings.append("Guider")
        }
        if self.rawValue & Self.FocuserInterface.rawValue != 0 {
            strings.append("Focuser")
        }
        if self.rawValue & Self.FilterInterface.rawValue != 0 {
            strings.append("Filter")
        }
        if self.rawValue & Self.DomeInterface.rawValue != 0 {
            strings.append("Dome")
        }
        if self.rawValue & Self.GPSInterface.rawValue != 0 {
            strings.append("GPS")
        }
        if self.rawValue & Self.WeatherInterface.rawValue != 0 {
            strings.append("Weather")
        }
        if self.rawValue & Self.AdaptiveOpticsInterface.rawValue != 0 {
            strings.append("AdaptiveOptics")
        }
        if self.rawValue & Self.DustcapInterface.rawValue != 0 {
            strings.append("Dustcap")
        }
        if self.rawValue & Self.LightBoxInterface.rawValue != 0 {
            strings.append("LightBox")
        }
        if self.rawValue & Self.DetectorInterface.rawValue != 0 {
            strings.append("Detector")
        }
        if self.rawValue & Self.RotatorInterface.rawValue != 0 {
            strings.append("Rotator")
        }
        if self.rawValue & Self.SpectrographInterface.rawValue != 0 {
            strings.append("Spectrograph")
        }
        if self.rawValue & Self.CorrelatorInterface.rawValue != 0 {
            strings.append("Correlator")
        }
        if self.rawValue & Self.AuxInterface.rawValue != 0 {
            strings.append("Aux")
        }
        
        return strings
    }
}
