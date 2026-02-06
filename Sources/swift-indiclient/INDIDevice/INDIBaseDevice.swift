//
//  INDIBaseDevice.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import DequeModule
internal import NIOConcurrencyHelpers

public typealias INDIDriverInterface = INDIBaseDevice.INDIDriverInterface

final public class INDIBaseDevice: @unchecked Sendable {
    public enum INDIWatch: Int {
        case WatchNew = 0       // Applies to discovered properties only.
        case WatchUpdate        // Applies to updated properties only.
        case WatchNewOrUpdate   // Applies when a property appears or is updated, i.e. both of the above.
    }
    
    public enum INDIDriverInterface: Int {
        case GeneralInterface           = 0b00000000000000000000    // Default interface for all INDI devices.
        case TelescopeInterface         = 0b00000000000000000001    // Telescope interface, must subclass INDI Telescope.
        case CCDInterface               = 0b00000000000000000010    // CCD interface, must subclass INDI CCD.
        case GuiderInterface            = 0b00000000000000000100    // Guider interface, must subclass INDI GuiderInterface.
        case FocuserInterface           = 0b00000000000000001000    // Focuser interface, must subclass INDI FocuserInterface.
        case FilterInterface            = 0b00000000000000010000    // Filter interface, must subclass INDI FilterInterface.
        case DomeInterface              = 0b00000000000000100000    // Dome interface, must subclass INDI Dome.
        case GPSInterface               = 0b00000000000001000000    // GPS interface, must subclass INDi GPS.
        case WeatherInterface           = 0b00000000000010000000    // Weather interface, must subclass INDI Weather.
        case AdaptiveOpticsInterface    = 0b00000000000100000000    // Adaptive Optics interface.
        case DustcapInterface           = 0b00000000001000000000    // Dust cap interface.
        case LightboxInterface          = 0b00000000010000000000    // Light box interface.
        case DetectorInterface          = 0b00000000100000000000    // Detector interface, must subclass INDI Detector.
        case RotatorInterface           = 0b00000001000000000000    // Rotator interface, must subclass INDI RotatorInterface.
        case SpectrographInterface      = 0b00000010000000000000    // Spectrograph interface.
        case CorrelatorInterface        = 0b00000100000000000000    // Correlators (interferometers) interface.
        case AuxInterface               = 0b00001000000000000000    // Auxiliary interface.
        case OutputInterface            = 0b00010000000000000000    // Digital Output (e.g. Relay) interface.
        case InputInterface             = 0b00100000000000000000    // Digital/Analog Input (e.g. GPIO) interface.
        case PowerInterface             = 0b01000000000000000000    // Power Controller interface.
        case IMUInterface               = 0b10000000000000000000    // Intertial Measurement Unit interface.
        case SensorInterface            = 0b00000110100000000000    // Correlator & Spectrograph & Detector
        
        public static let General = "General"
        public static let Telescope = "Mount"
        public static let CCD = "Camera"
        public static let Guider = "Guider"
        public static let Focuser = "Focuser"
        public static let Filter = "FilterWheel"
        public static let Dome = "Dome"
        public static let GPS = "GPS"
        public static let Weather = "Weather"
        public static let AdaptiveOptics = "AdaptiveOptics"
        public static let DustCap = "DustCap"
        public static let LightBox = "LightBox"
        public static let Detector = "Detector"
        public static let Rotator = "Rotator"
        public static let Spectrograph = "Spectrograph"
        public static let Correlator = "Correlator"
        public static let Auxiliary = "Auxiliary"
        public static let Output = "Output"
        public static let Input = "Input"
        public static let Power = "Power"
        public static let IMU = "IMU"
        public static let Sensor = "Sensor"
        
        func toString() -> String {
            switch self {
            case .GeneralInterface: Self.General
            case .TelescopeInterface: Self.Telescope
            case .CCDInterface: Self.CCD
            case .GuiderInterface: Self.Guider
            case .FocuserInterface: Self.Focuser
            case .FilterInterface: Self.Filter
            case .DomeInterface: Self.Dome
            case .GPSInterface: Self.GPS
            case .WeatherInterface: Self.Weather
            case .AdaptiveOpticsInterface: Self.AdaptiveOptics
            case .DustcapInterface: Self.DustCap
            case .LightboxInterface: Self.LightBox
            case .DetectorInterface: Self.Detector
            case .RotatorInterface: Self.Rotator
            case .SpectrographInterface: Self.Spectrograph
            case .CorrelatorInterface: Self.Correlator
            case .AuxInterface: Self.Auxiliary
            case .OutputInterface: Self.Output
            case .InputInterface: Self.Input
            case .PowerInterface: Self.Power
            case .IMUInterface: Self.IMU
            case .SensorInterface: Self.Sensor
            }
        }
    }

    public struct INDIWatchDetails {
        var watch: INDIWatch = .WatchNew
        var handler: ((INDIPropertyType) -> Void)?
    }
    
    // MARK: - Delegate Property
    public weak var delegate: INDIBaseDeviceDelegate?
    
    // MARK: - Fundamental Property
    internal var _deviceName: String
    internal var _properties: [INDIPropertyType]
    internal var _watchProperty: [String : INDIWatchDetails]
    internal var _messageLog: Deque<String>
    internal var _lock = NIOLock()
    
    // MARK: - Initializer
    public init() {
        self._deviceName = ""
        self._properties = []
        self._watchProperty = [:]
        self._messageLog = []
    }
    
    // MARK: - Computed Property
    public var isConnected: Bool {
        get {
            guard let switchProperty = getSwitchProperty(propertyName: "CONNECTION"), let switchElement = switchProperty.findElementByName("CONNECT") else { return false }
            return switchElement.switchStateAsBool && switchProperty.propertyState == .Ok
        }
    }
    
    public var deviceName: String {
        get {
            self._deviceName
        }
    }
    
    public var driverName: String? {
        get {
            getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_NAME")?.text
        }
    }
    
    public var driverExec: String? {
        get {
            getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_EXEC")?.text
        }
    }
    
    public var driverVersion: String? {
        get {
            getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_VERSION")?.text
        }
    }
    
    public var driverInterface: Int {
        get {
            Int(getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_INTERFACE")?.text ?? "") ?? 0
        }
    }
    
    // MARK: - Fundamental Method
    public func setDeviceName(_ name: String) {
        self._deviceName = name
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        self._deviceName == otherName
    }
    
    public func attach() {
        delegate?.newDevice(self)
    }
    
    public func detach() {
        delegate?.removeDevice(self)
    }
    
    /// Call the callback handler function if property is available.
    /// - Parameters:
    ///  - propertyName: Name of property/
    ///  - handler: Hander as an argument of the function you can use INDINumberVectorProperty, INDISwitchVectorProperty
    ///  - watch: You can decide whether the handler should be executed only once (WatchNew) on discovery of the property or also on every change of the value (WatchUpdate) or both (WatchUpdateOrUpdate).
    public func watchProperty(propertyName: String, watch: INDIWatch = .WatchNew, handler: @Sendable @escaping (INDIPropertyType) -> Void) {
        if self._watchProperty[propertyName] == nil {
            self._watchProperty[propertyName] = INDIWatchDetails()
        }
        
        self._watchProperty[propertyName]!.watch = watch
        self._watchProperty[propertyName]!.handler = handler
        
        // call handler function if property already exists.
        if let property = getProperty(propertyName: propertyName) {
            handler(property)
        }
    }
    
    public func getDriverName() -> String? {
        getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_NAME")?.text
    }
    
    public func getDriverExec() -> String? {
        getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_EXEC")?.text
    }
    
    public func getDriverVersion() -> String? {
        getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_VERSION")?.text
    }
    
    public func getDriverInterface() -> Int {
        Int(getTextProperty(propertyName: "DRIVER_INFO")?.findElementByName("DRIVER_INTERFACE")?.text ?? "") ?? 0
    }
}

// MARK: - Property Method
public extension INDIBaseDevice {
    func getProperties() -> [INDIPropertyType] {
        self._lock.withLock({
            self._properties
        })
    }
    
    func getProperty(propertyName: String, propertyType: INDIPropertyType = .INDIUnknown) -> INDIPropertyType? {
        self._lock.withLock({
            self._properties.first(where: { $0 != .INDIUnknown && $0.isPropertyNameMatch(propertyName) && ($0 == propertyType || propertyType == .INDIUnknown) })
        })
    }
    
    func getNumberProperty(propertyName: String) -> INDINumberProperty? {
        getProperty(propertyName: propertyName, propertyType: .INDINumber())?.numberProperty
    }
    
    func getSwitchProperty(propertyName: String) -> INDISwitchProperty? {
        getProperty(propertyName: propertyName, propertyType: .INDISwitch())?.switchProperty
    }
    
    func getTextProperty(propertyName: String) -> INDITextProperty? {
        getProperty(propertyName: propertyName, propertyType: .INDIText())?.textProperty
    }
    
    func getLightProperty(propertyName: String) -> INDILightProperty? {
        getProperty(propertyName: propertyName, propertyType: .INDILight())?.lightProperty
    }
    
    func getBlobProperty(propertyName: String) -> INDIBlobProperty? {
        getProperty(propertyName: propertyName, propertyType: .INDIBlob())?.blobProperty
    }
    
    func getPropertyState(propertyName: String) -> INDIPropertyState {
        getProperty(propertyName: propertyName)?.propertyState ?? .Idle
    }
    
    func getPropertyPermission(propertyName: String) -> INDIPropertyPermission {
        getProperty(propertyName: propertyName)?.propertyPermission ?? .ReadOnly
    }
    
    func removeProperty(propertyName: String) -> Int {
        var result = INDIErrorType.PropertyInvalid.rawValue
        
        self._lock.withLockVoid({
            self._properties.removeAll(where: {
                if $0.isPropertyNameMatch(propertyName) {
                    result = 0
                    return true
                }
                return false
            })
        })
        
        if result != 0 {
            print("Error: Property \(propertyName) not found in device \(self.deviceName).")
        }
        
        return result
    }
}

// MARK: - Property Build and Update Method
public extension INDIBaseDevice {
    /// Build a property given the supplied XML element (defXXX).
    /// - Parameters:
    ///  - root: XML element to parse and build.
    ///  - isDynamic: set to true if property is loaded from an XML file.
    /// - Returns: 0 if parsing is successful, -1 otherwise.
    func buildProperty(root: INDIProtocolElement, isDynamic: Bool = false) -> Int {
        guard let deviceName = root.getAttributeValue("device"), let propertyName = root.getAttributeValue("name") else { return -1 }
        
        if self._deviceName.isEmpty {
            self._deviceName = deviceName
        }
        
        if getProperty(propertyName: propertyName) != nil {
            return INDIErrorType.PropertyDuplicated.rawValue
        }
        
        // find type of tag.
        let tagTypeName: [String : INDIPropertyType] = [
            "defNumberVector" : .INDINumber(),
            "defSwitchVector" : .INDISwitch(),
            "defTextVector" : .INDIText(),
            "defLightVector" : .INDILight(),
            "defBLOBVector" : .INDIBlob()
        ]
        
        guard let rootTagType = tagTypeName[root.tagName] else {
            print("INDI: <\(root.tagName)> Unable to process tag.")
            return -1
        }
        
        var property: INDIPropertyType
        switch rootTagType {
        case .INDINumber(_):
            let numberProperty = INDINumberProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defNumber" {
                    let element = INDINumberElement()
                    element.setParent(numberProperty)
                    element.setElementName(child.getAttributeValue("name") ?? "")
                    element.setElementLabel(child.getAttributeValue("label") ?? "")
                    element.setFormat(child.getAttributeValue("format") ?? "")
                    element.setMin(Double(child.getAttributeValue("min") ?? "") ?? 0)
                    element.setMax(Double(child.getAttributeValue("max") ?? "") ?? 0)
                    element.setStep(Double(child.getAttributeValue("step") ?? "") ?? 0)
                    element.setValue(Double(child.stringValue ?? "") ?? 0)
                    
                    if !element.elementName.isEmpty {
                        numberProperty.appendElement(element: element)
                    }
                }
            })
            
            property = .INDINumber(numberProperty)
        case .INDISwitch(_):
            let switchProperty = INDISwitchProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defSwitch" {
                    let element = INDISwitchElement()
                    element.setParent(switchProperty)
                    element.setElementName(child.getAttributeValue("name") ?? "")
                    element.setElementLabel(child.getAttributeValue("label") ?? "")
                    element.setSwitchState(from: child.stringValue ?? "")
                    
                    if !element.elementName.isEmpty {
                        switchProperty.appendElement(element: element)
                    }
                }
            })
            
            property = .INDISwitch(switchProperty)
        case .INDIText(_):
            let textProperty = INDITextProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defText" {
                    let element = INDITextElement()
                    element.setParent(textProperty)
                    element.setElementName(child.getAttributeValue("name") ?? "")
                    element.setElementLabel(child.getAttributeValue("label") ?? "")
                    element.setText(child.stringValue ?? "")
                    
                    if !element.elementName.isEmpty {
                        textProperty.appendElement(element: element)
                    }
                }
            })
            
            property = .INDIText(textProperty)
        case .INDILight(_):
            let lightProperty = INDILightProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defLight" {
                    let element = INDILightElement()
                    element.setParent(lightProperty)
                    element.setElementName(child.getAttributeValue("name") ?? "")
                    element.setElementLabel(child.getAttributeValue("label") ?? "")
                    element.setLightState(from: child.stringValue ?? "")
                    
                    if !element.elementName.isEmpty {
                        lightProperty.appendElement(element: element)
                    }
                }
            })
            
            property = .INDILight(lightProperty)
        case .INDIBlob(_):
            let blobProperty = INDIBlobProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defBLOB" {
                    let element = INDIBlobElement()
                    element.setParent(blobProperty)
                    element.setElementName(child.getAttributeValue("name") ?? "")
                    element.setElementLabel(child.getAttributeValue("label") ?? "")
                    element.setFormat(child.getAttributeValue("format") ?? "")
                    
                    if !element.elementName.isEmpty {
                        blobProperty.appendElement(element: element)
                    }
                }
            })
            
            property = .INDIBlob(blobProperty)
        case .INDIUnknown:
            return -1
        }
        
        if property.isEmpty {
            print("\(propertyName): \(root.tagName) with no valid members.")
            return 0
        }
        
        property.property?.setDeviceName(deviceName)
        property.property?.setPropertyName(propertyName)
        property.property?.setPropertyLabel(root.getAttributeValue("label") ?? "")
        property.property?.setGroupName(root.getAttributeValue("group") ?? "")
        property.property?.setPropertyState(from: root.getAttributeValue("state") ?? "")
        property.property?.setTimeout(Double(root.getAttributeValue("timeout") ?? "") ?? 0)
        property.property?.setDynamic(dynamic: isDynamic)
        
        if rootTagType != .INDILight() {
            property.property?.setPropertyPermission(from: root.getAttributeValue("perm") ?? "")
        }
        
        self._lock.withLock({
            self._properties.append(property)
        })
        self.delegate?.newProperty(self, property: property)
        
        return 0
    }
    
    /// Handle setXXX commands from client.
    /// - Parameters:
    ///  - root: XML element to parse and update.
    /// - Returns: 0 if parsing is successful, -1 otherwise.
    func setValue(root: INDIProtocolElement) -> Int {
        guard let propertyName = root.getAttributeValue("name") else {
            print("INDI: <\(root.tagName)> unable to find name attribute.")
            return -1
        }
        
        // check emssage.
        checkMessage(root: root)
        
        // find type of tag.
        let tagTypeName: [String : INDIPropertyType] = [
            "setNumberVector" : .INDINumber(),
            "setSwitchVector" : .INDISwitch(),
            "setTextVector" : .INDIText(),
            "setLightVector" : .INDILight(),
            "setBLOBVector" : .INDIBlob()
        ]
        
        guard let rootTagType = tagTypeName[root.tagName] else {
            print("INDI: <\(root.tagName) unable to process tag.")
            return -1
        }
        
        // update generic value.
        guard let property = getProperty(propertyName: propertyName) else {
            print("INDI: Could not find property \(propertyName) in \(deviceName).")
            return -1
        }
        
        // 1. set overall vector property state, if any.
        if let propertyState = INDIPropertyState(rawValue: root.getAttributeValue("state") ?? "") {
            property.property?.setPropertyState(propertyState)
        } else {
            print("INDI: <\(root.tagName) bogus state \(root.getAttributeValue("state") ?? "nil") for \(propertyName).")
            return -1
        }
        
        // 2.allow changing the timeout.
        if let timeout = Double(root.getAttributeValue("timeout") ?? "") {
            property.property?.setTimeout(timeout)
        }
        
        // update specific values.
        switch rootTagType {
        case .INDINumber(_):
            if case let INDIPropertyType.INDINumber(numberProperty) = property {
                self._lock.withLockVoid({
                    root.children.forEach({ child in
                        if let element = numberProperty.findElementByName(child.getAttributeValue("name") ?? "") {
                            element.setValue(Double(child.stringValue ?? "") ?? 0)
                            
                            // permit chaning of min/max
                            if let minValue = Double(child.getAttributeValue("min") ?? "") { element.setMin(minValue) }
                            if let maxValue = Double(child.getAttributeValue("max") ?? "") { element.setMax(maxValue) }
                        }
                    })
                })
            }
        case .INDISwitch(_):
            if case let INDIPropertyType.INDISwitch(switchProperty) = property {
                self._lock.withLockVoid({
                    root.children.forEach({ child in
                        if let element = switchProperty.findElementByName(child.getAttributeValue("name") ?? "") {
                            element.setSwitchState(from: child.stringValue ?? "")
                        }
                    })
                })
            }
        case .INDIText(_):
            if case let INDIPropertyType.INDIText(textProperty) = property {
                self._lock.withLockVoid({
                    root.children.forEach({ child in
                        if let element = textProperty.findElementByName(child.getAttributeValue("name") ?? "") {
                            element.setText(child.stringValue ?? "")
                        }
                    })
                })
            }
        case .INDILight(_):
            if case let INDIPropertyType.INDILight(lightProperty) = property {
                self._lock.withLockVoid({
                    root.children.forEach({ child in
                        if let element = lightProperty.findElementByName(child.getAttributeValue("name") ?? "") {
                            element.setLightState(from: child.stringValue ?? "")
                        }
                    })
                })
            }
        case .INDIBlob(_):
            if case let INDIPropertyType.INDIBlob(blobProperty) = property {
                if setBLOB(blobProperty: blobProperty, root: root) < 0 {
                    return -1
                }
            }
        case .INDIUnknown:
            return -1
        }
        
        self.delegate?.updateProperty(self, property: property)
        
        return 0
    }
    
    func setBLOB(blobProperty: INDIBlobProperty, root: INDIProtocolElement) -> Int {
        let result = self._lock.withLock({
            for child in root.children {
                if child.tagName == "oneBLOB" {
                    guard let elementName = child.getAttributeValue("name"), let format = child.getAttributeValue("format"), let sizeString = child.getAttributeValue("size") else {
                        print("INDI: \(deviceName).\(blobProperty.propertyName) No vaild members.")
                        return -1
                    }
                    
                    guard let element = blobProperty.findElementByName(elementName) else {
                        print("INDI: \(deviceName).\(blobProperty.propertyName).\(elementName) No valid members.")
                        return -1
                    }
                    
                    let size = Int(sizeString) ?? 0
                    if size == 0 {
                        continue
                    }
                    
                    element.setSize(size)
                    
                    if let base64DecodeData = Data(base64Encoded: child.stringValue!) {
                        element.setBlob(blob: base64DecodeData)
                        element.setBlobLength(base64DecodeData.count)
                    } else {
                        print("INDI: \(deviceName).\(blobProperty.propertyName).\(elementName) base64 decode error.")
                        return -1
                    }
                    
                    if format.hasSuffix(".z") {
                        element.setFormat(String(format.dropLast(2)))
                        
                        do {
                            let data = NSMutableData(data: element.blob)
                            try data.decompress(using: .zlib)
                            element.setSize(data.count)
                            element.setBlob(blob: data as Data)
                        } catch let error {
                            print("INDI: \(deviceName).\(blobProperty.propertyName).\(elementName) compression error. \(error)")
                            return -1
                        }
                    } else {
                        element.setFormat(format)
                    }
                }
            }
            
            return 0
        })
        
        return result
    }
}

// MARK: - Message Method
public extension INDIBaseDevice {
    func checkMessage(root: INDIProtocolElement) {
        guard let message = root.getAttributeValue("message") else { return }
        
        var finalMessage = ""
        if let timestamp = root.getAttributeValue("timestamp") {
            finalMessage = "\(timestamp): \(message)"
        } else {
            let formatter = ISO8601DateFormatter()
            finalMessage = "\(formatter.string(from: Date()).dropFirst()): \(message)"
        }
        
        self._lock.withLockVoid({
            self._messageLog.append(finalMessage)
        })
        
        delegate?.newMessage(self, messageID: self._messageLog.count - 1)
    }
    
    func messageQueue(index: Int) -> String {
        assert(index < self._messageLog.count)
        return self._lock.withLock({
            return self._messageLog[index]
        })
    }
    
    func lastMessage() -> String {
        assert(self._messageLog.count != 0)
        return self._lock.withLock({
            return self._messageLog.last!
        })
    }
}
