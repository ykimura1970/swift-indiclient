//
//  INDIBaseDevice.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import Collections
internal import DequeModule

public actor INDIBaseDevice: Identifiable, Hashable {
    // MARK: - Delegate Property
    public weak var delegate: INDIDeviceMediatorDelegate?
    
    // MARK: - Fundamental Property
    nonisolated(unsafe) private(set) public var deviceName: String
    private(set) var vectorProperties: [INDIVectorProperty]
    private(set) var propertyGroups: OrderedSet<String>
    private(set) var messageQueue: Deque<String>
    
    // MARK: - Initializer
    public init(deviceName: String) {
        self.deviceName = deviceName
        self.vectorProperties = []
        self.propertyGroups = []
        self.messageQueue = []
    }
    
    // MARK: - Protocol Method
    public static func == (lhs: INDIBaseDevice, rhs: INDIBaseDevice) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    // MARK: - Fundamental Method
    public func setDelegate(delegate: INDIDeviceMediatorDelegate?) {
        self.delegate = delegate
    }
    
    /// Get driver name.
    /// - Returns: driver name.
    public func getDriverName() -> String {
        guard let textProperty = getTextVectorProperty(propertyName: "DRIVER_INFO")?.properties.first(where: { $0.isElementNameMatch("DRIVER_NAME") }) as? INDITextProperty else { return "" }
        return textProperty.text
    }
    
    /// Get execution file name of driver.
    /// - Returns: execution file name.
    public func getDriverExec() -> String {
        guard let textProperty = getTextVectorProperty(propertyName: "DRIVER_IINFO")?.properties.first(where: { $0.isElementNameMatch("DRIVER_EXEC") }) as? INDITextProperty else { return "" }
        return textProperty.text
    }
    
    /// Get driver version.
    /// - Returns: driver version.
    public func getDriverVersion() -> String {
        guard let textProperty = getTextVectorProperty(propertyName: "DRIVER_INFO")?.properties.first(where: { $0.isElementNameMatch("DRIVER_VERSION") }) as? INDITextProperty else { return "" }
        return textProperty.text
    }
    
    /// Get driver interface code.
    /// - Returns: driver interface code.
    public func getDriverInterface() -> UInt16 {
        guard let textProperty = getTextVectorProperty(propertyName: "DRIVER_INFO")?.properties.first(where: { $0.isElementNameMatch("DRIVER_INTERFACE") }) as? INDITextProperty else { return 0 }
        return UInt16(textProperty.text) ?? 0
    }
    
    /// Get driver interface names.
    /// - Returns: Array of driver interface names.
    public func getDriverInterfaceAsStrings() -> [String] {
        INDIDriverInterface(rawValue: getDriverInterface()).toStrings()
    }
    
    /// Check if the given device name matches.
    /// - Parameters:
    ///  - otherDeviceName: The device name to check for location.
    /// - Returns: True if they match, false if they don't.
    nonisolated public func isDeviceNameMatch(_ otherName: String) -> Bool {
        deviceName == otherName
    }
}

// MARK: - Vector Property Method
extension INDIBaseDevice {
    /// Get vector property groups.
    /// - Returns: Array of group name of vector property.
    public func getVectorPropertyGroups() -> [String] {
        Array(propertyGroups)
    }
    
    /// Get vector properties by group name.
    /// - Parameters:
    ///  - groupName: vector proeprty group name.
    /// - Returns: vector properties by group name.
    public func getVectorPropertiesByGroup(groupName: String) -> [INDIVectorProperty] {
        Dictionary(grouping: vectorProperties, by: { $0.groupName })[groupName] ?? []
    }
    
    /// Get all vector properties.
    /// - Returns: Array of all vector properties.
    public func getAllVectorProperties() -> [INDIVectorProperty] {
        vectorProperties
    }
    
    /// Get vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    ///  - type: property type.
    /// - Returns: A vector property that matches the specified property name and proeprty type. Otherwise nil.
    public func getVectorProperty(propertyName: String, propertyType: INDIPropertyType = .INDIUnknown) -> INDIVectorProperty? {
        propertyType == .INDIUnknown ? vectorProperties.first(where: { $0.isPropertyNameMatch(propertyName) }) : vectorProperties.first(where: { $0.isPropertyNameMatch(propertyName) && $0.propertyType == propertyType })
    }
    
    /// Get number vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: A number vector property that matches the specified property name. Otherwise nil.
    public func getNumberVectorProperty(propertyName: String) -> INDINumberVectorProperty? {
        getVectorProperty(propertyName: propertyName, propertyType: .INDINumber) as? INDINumberVectorProperty
    }
    
    /// Get switch vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: A switch vector property that matches the specified property name. Otherwise nil.
    public func getSwitchVectorProperty(propertyName: String) -> INDISwitchVectorProperty? {
        getVectorProperty(propertyName: propertyName, propertyType: .INDISwitch) as? INDISwitchVectorProperty
    }
    
    /// Get text vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: A text vector property that matches the specified proeprty name. Otherwise nil.
    public func getTextVectorProperty(propertyName: String) -> INDITextVectorProperty? {
        getVectorProperty(propertyName: propertyName, propertyType: .INDIText) as? INDITextVectorProperty
    }
    
    /// Get light vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: A light vector property that matches the specified property name. Otherwise nil.
    public func getLightVectorProperty(propertyName: String) -> INDILightVectorProperty? {
        getVectorProperty(propertyName: propertyName, propertyType: .INDILight) as? INDILightVectorProperty
    }
    
    /// Get blob vector property.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: A blob vector property that matches the specified property name. Otherwise nil.
    public func getBlobVetorProperty(propertyName: String) -> INDIBlobVectorProperty? {
        getVectorProperty(propertyName: propertyName, propertyType: .INDIBlob) as? INDIBlobVectorProperty
    }
    
    /// Get property state for the specified property name.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: property state for the specified property name.
    public func getVectorPropertyState(propertyName: String) -> INDIPropertyState? {
        vectorProperties.first(where: { $0.isPropertyNameMatch(propertyName) })?.propertyState
    }
    
    /// Get property permission for the specified property name.
    /// - Parameters:
    ///  - propertyName: property name.
    /// - Returns: property permission for the specified property name.
    public func getVectorPropertyPermission(propertyName: String) -> INDIPropertyPermission? {
        vectorProperties.first(where: { $0.isGroupName(propertyName) })?.propertyPermission
    }
}

// MARK: - Vector Property Operation Method
extension INDIBaseDevice {
    /// Build a vector property given the supplied XML element (defXXX).
    /// - Parameters:
    ///  - xmlCommand: XML element.
    /// - Returns: 0 if successful, -1 otherwise.
    public func buildVectorProperty(xmlCommand: INDIProtocolElement) async -> Int {
        guard let deviceName = xmlCommand.attributes["device"], let propertyName = xmlCommand.attributes["name"] else { return -1 }
        let tagName = xmlCommand.tagName
        
        // Find type of tag.
        let typeName: [String : INDIPropertyType] = [
            "defNumberVector" : .INDINumber,
            "defSwitchVector" : .INDISwitch,
            "defTextVector" : .INDIText,
            "defLightVector" : .INDILight,
            "defBLOBVector" : .INDIBlob
        ]
        
        guard let tagType = typeName[tagName] else {
            print("INDI: <\(tagName)> Unable to process tag.")
            return -1
        }
        
        if getVectorProperty(propertyName: propertyName) != nil {
            return INDIErrorType.PropertyDuplicated.rawValue
        }
        
        if deviceName.isEmpty {
            return -1
        }
        
        var vectorProperty: INDIVectorProperty
        
        switch tagType {
        case .INDINumber:
            let typedVectorProperty = INDINumberVectorProperty()
            
            for element in xmlCommand.children {
                if element.tagName != "defNumber" { continue }
                
                let property = INDINumberProperty()
                property.setParent(parent: typedVectorProperty)
                
                if let elementName = element.attributes["name"] {
                    property.setElementName(elementName)
                }
                if let elementLabel = element.attributes["label"] {
                    property.setElementLabel(elementLabel)
                }
                
                if let elementFormat = element.attributes["format"] {
                    property.setFormat(elementFormat)
                }
                
                if let elementMin = Double(element.attributes["min"] ?? "") {
                    property.setMin(elementMin)
                }
                if let elementMax = Double(element.attributes["max"] ?? "") {
                    property.setMax(elementMax)
                }
                if let elementStep = Double(element.attributes["step"] ?? "") {
                    property.setStep(elementStep)
                }
                
                if let elementValue = Double(element.stringValue) {
                    property.setValue(elementValue)
                }
                
                if !property.isElementNameMatch("") {
                    typedVectorProperty.appendProperty(property: property)
                }
            }
            vectorProperty = typedVectorProperty
        case .INDISwitch:
            let typedVectorProperty = INDISwitchVectorProperty()
            
            for element in xmlCommand.children {
                if element.tagName != "defSwitch" { continue }
                
                let property = INDISwitchProperty()
                property.setParent(parent: typedVectorProperty)
                
                if let elementName = element.attributes["name"] {
                    property.setElementName(elementName)
                }
                if let elementLabel = element.attributes["label"] {
                    property.setElementLabel(elementLabel)
                }
                
                _ = property.setSwitchState(from: element.stringValue)
                
                if !property.isElementNameMatch("") {
                    typedVectorProperty.appendProperty(property: property)
                }
            }
            vectorProperty = typedVectorProperty
        case .INDIText:
            let typedVectorProperty = INDITextVectorProperty()
            
            for element in xmlCommand.children {
                if element.tagName != "defText" { continue }
                
                let property = INDITextProperty()
                property.setParent(parent: typedVectorProperty)
                
                if let elementName = element.attributes["name"] {
                    property.setElementName(elementName)
                }
                if let elementLabel = element.attributes["label"] {
                    property.setElementLabel(elementLabel)
                }
                
                property.setText(element.stringValue)
                
                if !property.isElementNameMatch("") {
                    typedVectorProperty.appendProperty(property: property)
                }
            }
            vectorProperty = typedVectorProperty
        case .INDILight:
            let typedVectorProperty = INDILightVectorProperty()
            
            for element in xmlCommand.children {
                if element.tagName != "defLight" { continue }
                
                let property = INDILightProperty()
                property.setParent(parent: typedVectorProperty)
                
                if let elementName = element.attributes["name"] {
                    property.setElementName(elementName)
                }
                if let elementLabel = element.attributes["label"] {
                    property.setElementLabel(elementLabel)
                }
                
                _ = property.setLightState(from: element.stringValue)
                
                if !property.isElementNameMatch("") {
                    typedVectorProperty.appendProperty(property: property)
                }
            }
            vectorProperty = typedVectorProperty
        case .INDIBlob:
            let typedVectorProperty = INDIBlobVectorProperty()
            
            for element in xmlCommand.children {
                if element.tagName != "defBLOB" { continue }
                
                let property = INDIBlobProperty()
                property.setParent(parent: typedVectorProperty)
                
                if let elementName = element.attributes["name"] {
                    property.setElementName(elementName)
                }
                if let elementLabel = element.attributes["label"] {
                    property.setElementLabel(elementLabel)
                }
                
                if let elementFormat = element.attributes["format"] {
                    property.setFormat(elementFormat)
                }
                
                if !property.isElementNameMatch("") {
                    typedVectorProperty.appendProperty(property: property)
                }
            }
            vectorProperty = typedVectorProperty
        default:
            return -1
        }
        
        vectorProperty.setDeviceName(deviceName)
        vectorProperty.setPropertyName(propertyName)
        
        if let propertyLabel = xmlCommand.attributes["label"] {
            vectorProperty.setPropertyLabel(propertyLabel)
        }
        if let groupName = xmlCommand.attributes["group"] {
            vectorProperty.setGroupName(groupName)
            appendVectorPropertyGroup(groupName: groupName)
        }
        
        _ = vectorProperty.setPropertyState(from: xmlCommand.attributes["state"] ?? "")
        
        if vectorProperty.propertyType != .INDILight {
            _ = vectorProperty.setPropertyPermission(from: xmlCommand.attributes["perm"] ?? "")
        }
        
        appendVectorProperty(vectorProperty: vectorProperty)
        delegate?.newVectorProperty(sender: self, vectorProperty: vectorProperty)
        
        return 0
    }
    
    /// Handle setXXX command from client.
    /// - Parameters:
    ///  - xmlCommand: XML element.
    /// - Returns: 0 if successful, -1 otherwise.
    public func updateVectorProperty(xmlCommand: INDIProtocolElement) async -> Int {
        guard let propertyName = xmlCommand.attributes["name"] else { return -1 }
        let tagName = xmlCommand.tagName

        // check message
        await checkMessage(xmlCommand: xmlCommand)
        
        // Find type of tag.
        let typeName: [String : INDIPropertyType] = [
            "setNumberVector" : .INDINumber,
            "setSwitchVector" : .INDISwitch,
            "setTextVector" : .INDIText,
            "setLightVector" : .INDILight,
            "setBLOBVector" : .INDIBlob
        ]
        
        guard let tagType = typeName[tagName] else {
            print("INDI: <\(tagName)> Unable to process tag.")
            return -1
        }
        
        // update specific values.
        if let vectorProperty = getVectorProperty(propertyName: propertyName, propertyType: tagType) {
            // 1. set overall vector property state, if any.
            if let propertyState = INDIPropertyState.propertyState(from: xmlCommand.attributes["state"] ?? "") {
                vectorProperty.setPropertyState(propertyState)
            } else {
                print("INDI: <\(tagName)> bogus state \(xmlCommand.attributes["state"] ?? "").")
                return -1
            }
            
            // 2. allow changing the timeout.
            if let timeout = Double(xmlCommand.attributes["timeout"] ?? "") {
                vectorProperty.setTimeout(timeout)
            }
            
            // update spepcific values.
            switch tagType {
            case .INDINumber:
                let typedVectorProperty = vectorProperty as! INDINumberVectorProperty
                
                xmlCommand.children.forEach({ element in
                    if let elementName = element.attributes["name"] {
                        if let property = typedVectorProperty.findPropertyByElementName(elementName) {
                            if let elementValue = Double(element.stringValue) {
                                property.setValue(elementValue)
                            }
                            
                            // permit changing of min/max.
                            if let elementMin = Double(element.attributes["min"] ?? "") {
                                property.setMin(elementMin)
                            }
                            if let elementMax = Double(element.attributes["max"] ?? "") {
                                property.setMax(elementMax)
                            }
                        }
                    }
                })
            case .INDISwitch:
                let typedVectorProperty = vectorProperty as! INDISwitchVectorProperty
                
                xmlCommand.children.forEach({ element in
                    if let elementName = element.attributes["name"] {
                        if let property = typedVectorProperty.findPropertyByElementName(elementName) {
                            _ = property.setSwitchState(from: element.stringValue)
                        }
                    }
                })
            case .INDIText:
                let typedVectorProperty = vectorProperty as! INDITextVectorProperty
                
                xmlCommand.children.forEach({ element in
                    if let elementName = element.attributes["name"] {
                        if let property = typedVectorProperty.findPropertyByElementName(elementName) {
                            property.setText(element.stringValue)
                        }
                    }
                })
            case .INDILight:
                let typedVectorProperty = vectorProperty as! INDILightVectorProperty
                
                xmlCommand.children.forEach({ element in
                    if let elementName = element.attributes["name"] {
                        if let property = typedVectorProperty.findPropertyByElementName(elementName) {
                            _ = property.setLightState(from: element.stringValue)
                        }
                    }
                })
            case .INDIBlob:
                let typedVectorProperty = vectorProperty as! INDIBlobVectorProperty
                if setBlob(vectorProperty: typedVectorProperty, xmlCommand: xmlCommand) < 0 {
                    return -1
                }
            case .INDIUnknown:
                return -1
            }
            
            delegate?.updateVectorProperty(sender: self, vectorProperty: vectorProperty)
            return 0
        }
        
        print("INDI: Could not find vector property \(propertyName), type \(tagType) in \(deviceName).")
        return -1
    }
    
    /// Parse and store BLOB in the respective vector property.
    /// - Parameters:
    ///  - vectorProperty: INDIBlobVectorProperty instance.
    ///  - xmlCommand: XML element.
    /// - Returns: 0 if parsing is successful, -1 otherwise.
    private func setBlob(vectorProperty: INDIBlobVectorProperty, xmlCommand: INDIProtocolElement) -> Int {
        for element in xmlCommand.children {
            if element.tagName != "oneBLOB" { continue }
            
            guard let elementName = element.attributes["name"], let format = element.attributes["format"], let size = Int(element.attributes["size"] ?? "0") else {
                print("INDI: \(vectorProperty.deviceName).\(vectorProperty.propertyName) No valid members.")
                return -1
            }
            
            if size == 0 {
                continue
            }
            
            if let property = vectorProperty.findPropertyByElementName(elementName) {
                if let base64DecodeData = Data(base64Encoded: element.blobData) {
                    property.setSize(size: size)
                    property.setBlob(blob: base64DecodeData)
                    property.setBlobLength(base64DecodeData.count)
                } else {
                    print("INDI: \(vectorProperty.deviceName).\(vectorProperty.propertyName).\(elementName) base64 decode error.")
                    return -1
                }
                
                if format.hasSuffix(".z") {
                    property.setFormat(String(format.dropLast(2)))
                    
                    do {
                        let data = NSMutableData(data: property.blob)
                        try data.decompress(using: .zlib)
                        property.setSize(size: data.count)
                        property.setBlob(blob: data as Data)
                    } catch let error {
                        print("\(error)")
                        print("INDI: \(vectorProperty.deviceName).\(vectorProperty.propertyName).\(elementName) compression error.")
                        return -1
                    }
                } else {
                    property.setFormat(format)
                }
            }
        }

        return 0
    }
    
    /// Handle delXXX command line from client.
    /// - Parameters:
    ///  - xmlCommand: XML element to parse and set.
    /// - Returns: True if the vector property exists and was deleted, false otherwise.
    public func removeVectorProperty(propertyName: String) -> Int {
        var result = INDIErrorType.PropertyInvalid.rawValue
        
        vectorProperties.removeAll(where: {
            if $0.isPropertyNameMatch(propertyName) {
                result = 0
                return true
            }
            return false
        })
        
        if result != 0 {
            print("Error: Property \(propertyName) not found in device \(deviceName).")
        }
        
        return result
    }
}

// MARK: - Message Method
extension INDIBaseDevice {
    /// Check and add message to the driver's message queue.
    /// - Parameters:
    ///  - xmlCommand: XML element.
    nonisolated public func checkMessage(xmlCommand: INDIProtocolElement) async {
        guard let message = xmlCommand.attributes["message"] else { return }
        
        var finalMessage = ""
        if let timestamp = xmlCommand.attributes["timestamp"] {
            finalMessage = "\(timestamp): \(message)"
        } else {
            let formatter = ISO8601DateFormatter()
            finalMessage = formatter.string(from: Date()).dropLast() + ": \(message)"
        }
        
        await appendMessage(message: finalMessage)
    }
    
    /// Get the message with the specified index from messageQueue.
    /// - Parameters:
    ///  - index: messageQueue index.
    /// - Returns: message string
    public func messageQueue(index: Int) -> String {
        index >= 0 && index < messageQueue.count ? messageQueue[index] : ""
    }
    
    /// Get the message with the last from messageQueue.
    /// - Returns: message string.
    public func lastMessage() -> String {
        messageQueue.last ?? ""
    }
}

// MARK: - Helper Method
extension INDIBaseDevice {
    /// Append new vector property group.
    /// - Parameters:
    ///  - groupName: vector proeprty gorup name.
    private func appendVectorPropertyGroup(groupName: String) {
        propertyGroups.append(groupName)
    }

    /// Append new vector property.
    /// - Parameters:
    ///  - vectorProperty: vector property.
    private func appendVectorProperty(vectorProperty: INDIVectorProperty) {
        vectorProperties.append(vectorProperty)
    }
    
    /// Append new message.
    /// - Parameters:
    ///  - message: message string.
    private func appendMessage(message: String) {
        messageQueue.append(message)
    }
}
