//
//  INDIBaseDevice.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import DequeModule
internal import NIOConcurrencyHelpers

public class INDIBaseDevice: @unchecked Sendable {
    public enum INDIError: Int {
        case DeviceNotFound     = -1    // INDI Device was not found
        case PropertyInvalid    = -2    // Property has an invalid syntax or attribute.
        case PropertyDuplicated = -3    // INDI Device property already defined.
        case DispatchError      = -4    // Dispatching command to driver failed.
    }
    
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
    }

    public struct INDIWatchDetails {
        var watch: INDIWatch = .WatchNew
        var handler: ((INDIVectorProperty) -> Void)?
    }
    
    // MARK: - Delegate Property
    public weak var delegate: INDIBaseMediatorDelegate?
    
    // MARK: - Fundamental Property
    internal(set) public var deviceName: String
    internal var properties: [INDIPropertyType]
    internal var watchProperty: [String : INDIWatchDetails]
    internal var messageLog: Deque<String>
    internal var lock = NIOLock()
    
    // MARK: - Initializer
    public init() {
        self.deviceName = ""
        self.properties = []
        self.watchProperty = [:]
        self.messageLog = []
    }
    
    // MARK: - Computed Property
    public var isConnected: Bool {
        get {
            guard let switchVectorProperty = getSwitchVectorProperty(propertyName: "CONNECTION"), let switchProperty = switchVectorProperty.findPropertyByElementName("CONNECT") else { return false }
            return switchProperty.switchStateAsBool && switchVectorProperty.propertyState == .Ok
        }
    }
    
    // MARK: - Fundamental Method
    public func setDeviceName(_ name: String) {
        self.deviceName = name
    }
    
    public func isDeviceNameMatch(_ otherName: String) -> Bool {
        self.deviceName == otherName
    }
    
    public func attach() {
        delegate?.newDevice(sender: self)
    }
    
    public func detach() {
        delegate?.removeDevice(sender: self)
    }
    
    /// Call the callback handler function if property is available.
    /// - Parameters:
    ///  - propertyName: Name of property/
    ///  - handler: Hander as an argument of the function you can use INDINumberVectorProperty, INDISwitchVectorProperty
    ///  - watch: You can decide whether the handler should be executed only once (WatchNew) on discovery of the property or also on every change of the value (WatchUpdate) or both (WatchUpdateOrUpdate).
    public func watchProperty(propertyName: String, watch: INDIWatch = .WatchNew, handler: @Sendable @escaping (INDIVectorProperty) -> Void) {
        if watchProperty[propertyName] == nil {
            watchProperty[propertyName] = INDIWatchDetails()
        }
        
        watchProperty[propertyName]?.watch = watch
        watchProperty[propertyName]?.handler = handler
        
        // call handler function if property already exists.
        if let vectorProperty = getVectorProperty(propertyName: propertyName) {
            handler(vectorProperty)
        }
    }
    
    public func getDriverName() -> String? {
        getTextVectorProperty(propertyName: "DRIVER_INFO")?.findPropertyByElementName("DRIVER_NAME")?.text
    }
    
    public func getDriverExec() -> String? {
        getTextVectorProperty(propertyName: "DRIVER_INFO")?.findPropertyByElementName("DRIVER_EXEC")?.text
    }
    
    public func getDriverVersion() -> String? {
        getTextVectorProperty(propertyName: "DRIVER_INFO")?.findPropertyByElementName("DRIVER_VERSION")?.text
    }
    
    public func getDriverInterface() -> Int {
        Int(getTextVectorProperty(propertyName: "DRIVER_INFO")?.findPropertyByElementName("DRIVER_INTERFACE")?.text ?? "") ?? 0
    }
}

// MARK: - Property Method
public extension INDIBaseDevice {
    func getVectorProperties() -> [INDIVectorProperty] {
        lock.withLock({
            self.properties.compactMap({ $0.vectorProperty })
        })
    }
    
    func getVectorProperty(propertyName: String, type: INDIPropertyType = .INDIUnknown) -> INDIVectorProperty? {
        lock.withLock({
            self.properties.first(where: { $0.isPropertyNameMatch(propertyName) && ($0 == type || type == .INDIUnknown) })?.vectorProperty
        })
    }
    
    func getNumberVectorProperty(propertyName: String) -> INDINumberVectorProperty? {
        getVectorProperty(propertyName: propertyName, type: .INDINumber()) as? INDINumberVectorProperty
    }
    
    func getSwitchVectorProperty(propertyName: String) -> INDISwitchVectorProperty? {
        getVectorProperty(propertyName: propertyName, type: .INDISwitch()) as? INDISwitchVectorProperty
    }
    
    func getTextVectorProperty(propertyName: String) -> INDITextVectorProperty? {
        getVectorProperty(propertyName: propertyName, type: .INDIText()) as? INDITextVectorProperty
    }
    
    func getLightVectorProperty(propertyName: String) -> INDILightVectorProperty? {
        getVectorProperty(propertyName: propertyName, type: .INDILight()) as? INDILightVectorProperty
    }
    
    func getBlobVectorProperty(propertyName: String) -> INDIBlobVectorProperty? {
        getVectorProperty(propertyName: propertyName, type: .INDIBlob()) as? INDIBlobVectorProperty
    }
    
    func getVectorPropertyState(propertyName: String) -> INDIPropertyState {
        getVectorProperty(propertyName: propertyName)?.propertyState ?? .Idle
    }
    
    func getVectorPropertyPermission(propertyName: String) -> INDIPropertyPermission {
        getVectorProperty(propertyName: propertyName)?.propertyPermission ?? .ReadOnly
    }
    
    func removeVectorProperty(propertyName: String) -> Int {
        let result = lock.withLock({
            var result: Int = INDIError.PropertyInvalid.rawValue
            
            self.properties.removeAll(where: {
                if $0.isPropertyNameMatch(propertyName) {
                    result = 0
                    return true
                }
                return false
            })
            
            return result
        })
        
        if result != 0 {
            print("Error: Property \(propertyName) not found in device \(deviceName).")
        }
        
        return result
    }
}

// MARK: - Property Build and Update Method
public extension INDIBaseDevice {
    /// Build a vector property given the supplied XML element (defXXX).
    /// - Parameters:
    ///  - root: XML element to parse and build.
    ///  - isDynamic: set to true if property is loaded from an XML file.
    /// - Returns: 0 if parsing is successful, -1 otherwise.
    func buildVectorProperty(root: INDIProtocolElement, isDynamic: Bool = false) -> Int {
        guard let deviceName = root.getAttribute(name: "device"), let propertyName = root.getAttribute(name: "name") else { return -1 }
        
        if self.deviceName.isEmpty {
            self.deviceName = deviceName
        }
        
        if getVectorProperty(propertyName: propertyName) != nil {
            return INDIError.PropertyDuplicated.rawValue
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
        
        var wrapVectorProperty: INDIPropertyType
        switch rootTagType {
        case .INDINumber(_):
            let vectorProperty = INDINumberVectorProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defNumber" {
                    let property = INDINumberProperty()
                    property.setParent(vectorProperty)
                    property.setElementName(child.getAttribute(name: "name") ?? "")
                    property.setElementLabel(child.getAttribute(name: "label") ?? "")
                    property.setFormat(child.getAttribute(name: "format") ?? "")
                    property.setMin(Double(child.getAttribute(name: "min") ?? "") ?? 0)
                    property.setMax(Double(child.getAttribute(name: "max") ?? "") ?? 0)
                    property.setStep(Double(child.getAttribute(name: "step") ?? "") ?? 0)
                    property.setValue(Double(child.stringValue ?? "") ?? 0)
                    
                    if !property.isElementNameMatch("") {
                        vectorProperty.appendProperty(property: property)
                    }
                }
            })
            
            wrapVectorProperty = .INDINumber(vectorProperty)
        case .INDISwitch(_):
            let vectorProperty = INDISwitchVectorProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defSwitch" {
                    let property = INDISwitchProperty()
                    property.setParent(vectorProperty)
                    property.setElementName(child.getAttribute(name: "name") ?? "")
                    property.setElementLabel(child.getAttribute(name: "label") ?? "")
                    property.setSwitchState(from: child.stringValue ?? "")
                    
                    if !property.isElementNameMatch("") {
                        vectorProperty.appendProperty(property: property)
                    }
                }
            })
            
            wrapVectorProperty = .INDISwitch(vectorProperty)
        case .INDIText(_):
            let vectorProperty = INDITextVectorProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defText" {
                    let property = INDITextProperty()
                    property.setParent(vectorProperty)
                    property.setElementName(child.getAttribute(name: "name") ?? "")
                    property.setElementLabel(child.getAttribute(name: "label") ?? "")
                    property.setText(child.stringValue ?? "")
                    
                    if !property.isElementNameMatch("") {
                        vectorProperty.appendProperty(property: property)
                    }
                }
            })
            
            wrapVectorProperty = .INDIText(vectorProperty)
        case .INDILight(_):
            let vectorProperty = INDILightVectorProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defLight" {
                    let property = INDILightProperty()
                    property.setParent(vectorProperty)
                    property.setElementName(child.getAttribute(name: "name") ?? "")
                    property.setElementLabel(child.getAttribute(name: "label") ?? "")
                    property.setLightState(from: child.stringValue ?? "")
                    
                    if !property.isElementNameMatch("") {
                        vectorProperty.appendProperty(property: property)
                    }
                }
            })
            
            wrapVectorProperty = .INDILight(vectorProperty)
        case .INDIBlob(_):
            let vectorProperty = INDIBlobVectorProperty()
            
            root.children.forEach({ child in
                if child.tagName == "defBLOB" {
                    let property = INDIBlobProperty()
                    property.setParent(vectorProperty)
                    property.setElementName(child.getAttribute(name: "name") ?? "")
                    property.setElementLabel(child.getAttribute(name: "label") ?? "")
                    property.setFormat(child.getAttribute(name: "format") ?? "")
                    
                    if !property.isElementNameMatch("") {
                        vectorProperty.appendProperty(property: property)
                    }
                }
            })
            
            wrapVectorProperty = .INDIBlob(vectorProperty)
        case .INDIUnknown:
            return -1
        }
        
        if wrapVectorProperty.propertyIsEmpty {
            print("\(propertyName): \(root.tagName) with no valid members.")
            return 0
        }
        
        wrapVectorProperty.vectorProperty?.setDeviceName(deviceName)
        wrapVectorProperty.vectorProperty?.setPropertyName(propertyName)
        wrapVectorProperty.vectorProperty?.setPropertyLabel(root.getAttribute(name: "label") ?? "")
        wrapVectorProperty.vectorProperty?.setGroupName(root.getAttribute(name: "group") ?? "")
        wrapVectorProperty.vectorProperty?.setPropertyState(from: root.getAttribute(name: "state") ?? "")
        wrapVectorProperty.vectorProperty?.setTimeout(Double(root.getAttribute(name: "timeout") ?? "") ?? 0)
        wrapVectorProperty.vectorProperty?.setDynamic(dynamic: isDynamic)
        
        if rootTagType != .INDILight() {
            wrapVectorProperty.vectorProperty?.setPropertyPermission(from: root.getAttribute(name: "perm") ?? "")
        }
        
        lock.withLock({
            self.properties.append(wrapVectorProperty)
        })
        self.delegate?.newVectorProperty(sender: self, vectorProperty: wrapVectorProperty.vectorProperty!)
        
        return 0
    }
    
    /// Handle setXXX commands from client.
    /// - Parameters:
    ///  - root: XML element to parse and update.
    /// - Returns: 0 if parsing is successful, -1 otherwise.
    func setValue(root: INDIProtocolElement) -> Int {
        guard let propertyName = root.getAttribute(name: "name") else {
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
        guard let vectorProperty = getVectorProperty(propertyName: propertyName) else {
            print("INDI: Could not find property \(propertyName) in \(deviceName).")
            return -1
        }
        
        // 1. set overall vector property state, if any.
        if let propertyState = INDIPropertyState.propertyState(from: root.getAttribute(name: "state") ?? "") {
            vectorProperty.setPropertyState(propertyState)
        } else {
            print("INDI: <\(root.tagName) bogus state \(root.getAttribute(name: "state") ?? "nil") for \(propertyName).")
            return -1
        }
        
        // 2.allow changing the timeout.
        if let timeout = Double(root.getAttribute(name: "timeout") ?? "") {
            vectorProperty.setTimeout(timeout)
        }
        
        // update specific values.
        switch rootTagType {
        case .INDINumber(_):
            let typedVectorProperty = vectorProperty as! INDINumberVectorProperty
            
            lock.withLock({
                root.children.forEach({ child in
                    if let property = typedVectorProperty.findPropertyByElementName(child.getAttribute(name: "name") ?? "") {
                        property.setValue(Double(child.stringValue ?? "") ?? 0)
                        
                        // permit chaning of min/max
                        if let minValue = Double(child.getAttribute(name: "min") ?? "") { property.setMin(minValue) }
                        if let maxValue = Double(child.getAttribute(name: "max") ?? "") { property.setMax(maxValue) }
                    }
                })
            })
        case .INDISwitch(_):
            let typedVectorProperty = vectorProperty as! INDISwitchVectorProperty
            
            lock.withLock({
                root.children.forEach({ child in
                    if let property = typedVectorProperty.findPropertyByElementName(child.getAttribute(name: "name") ?? "") {
                        property.setSwitchState(from: child.stringValue ?? "")
                    }
                })
            })
        case .INDIText(_):
            let typedVectorProperty = vectorProperty as! INDITextVectorProperty
            
            lock.withLock({
                root.children.forEach({ child in
                    if let property = typedVectorProperty.findPropertyByElementName(child.getAttribute(name: "name") ?? "") {
                        property.setText(child.stringValue ?? "")
                    }
                })
            })
        case .INDILight(_):
            let typedVectorProperty = vectorProperty as!INDILightVectorProperty
            
            lock.withLock({
                root.children.forEach({ child in
                    if let property = typedVectorProperty.findPropertyByElementName(child.getAttribute(name: "name") ?? "") {
                        property.setLightState(from: child.stringValue ?? "")
                    }
                })
            })
        case .INDIBlob(_):
            let typedVectorProperty = vectorProperty as! INDIBlobVectorProperty
            
            if setBLOB(vectorProperty: typedVectorProperty, root: root) < 0 {
                return -1
            }
        case .INDIUnknown:
            return -1
        }
        
        self.delegate?.updateVectorProperty(sender: self, vectorProperty: vectorProperty)
        
        return 0
    }
    
    func setBLOB(vectorProperty: INDIBlobVectorProperty, root: INDIProtocolElement) -> Int {
        let result = lock.withLock({
            for child in root.children {
                if child.tagName == "oneBLOB" {
                    guard let elementName = child.getAttribute(name: "name"), let format = child.getAttribute(name: "format"), let sizeString = child.getAttribute(name: "size") else {
                        print("INDI: \(deviceName).\(vectorProperty.propertyName) No vaild members.")
                        return -1
                    }
                    
                    guard let property = vectorProperty.findPropertyByElementName(elementName) else {
                        print("INDI: \(deviceName).\(vectorProperty.propertyName).\(elementName) No valid members.")
                        return -1
                    }
                    
                    let size = Int(sizeString) ?? 0
                    if size == 0 {
                        continue
                    }
                    
                    property.setSize(size)
                    
                    if let base64DecodeData = Data(base64Encoded: property.blob) {
                        property.setBlob(blob: base64DecodeData)
                        property.setBlobLength(base64DecodeData.count)
                    } else {
                        print("INDI: \(deviceName).\(vectorProperty.propertyName).\(elementName) base64 decode error.")
                        return -1
                    }
                    
                    if format.hasSuffix(".z") {
                        property.setFormat(String(format.dropLast(2)))
                        
                        do {
                            let data = NSMutableData(data: property.blob)
                            try data.decompress(using: .zlib)
                            property.setSize(data.count)
                            property.setBlob(blob: data as Data)
                        } catch let error {
                            print("INDI: \(deviceName).\(vectorProperty.propertyName).\(elementName) compression error. \(error)")
                            return -1
                        }
                    } else {
                        property.setFormat(format)
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
        guard let message = root.getAttribute(name: "message") else { return }
        
        var finalMessage = ""
        if let timestamp = root.getAttribute(name: "timestamp") {
            finalMessage = "\(timestamp): \(message)"
        } else {
            let formatter = ISO8601DateFormatter()
            finalMessage = "\(formatter.string(from: Date()).dropFirst()): \(message)"
        }
        
        lock.withLock({
            messageLog.append(finalMessage)
        })
        
        delegate?.newMessage(sender: self, messageID: messageLog.count - 1)
    }
    
    func messageQueue(index: Int) -> String {
        assert(index < messageLog.count)
        return lock.withLock({
            return messageLog[index]
        })
    }
    
    func lastMessage() -> String {
        assert(messageLog.count != 0)
        return lock.withLock({
            return messageLog.last!
        })
    }
}
