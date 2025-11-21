//
//  INDVectorPropertyTemplate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//
import Foundation

public class INDIVectorPropertyTemplate<T: INDIProperty>: INDIVectorProperty, IteratorProtocol {
    public typealias Element = T
    
    // MARK: - Original Property
    internal(set) public var properties: [T]
    
    // MARK: - Protocol Property
    var index: Int = 0

    // MARK: - Initializer
    public override init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", dynamic: Bool = false) {
        self.properties = []
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyPermission: propertyPermission, timeout: timeout, propertyState: propertyState, timestamp: timestamp, dynamic: dynamic)
    }
    
    deinit {
        self.properties.removeAll()
    }
    
    // MARK: - Original Computed Property
    public var propertyIsEmpty: Bool {
        get {
            self.properties.isEmpty
        }
    }
    
    public var propertyCount: Int {
        get {
            self.properties.count
        }
    }

    // MARK: - Computed Property
    public subscript(index: Int) -> Element {
        get {
            assert(self.properties.startIndex <= index && index < self.properties.endIndex, "index out of range.")
            return self.properties[index]
        }
        set {
            assert(self.properties.startIndex <= index && index < self.properties.endIndex, "index out of range.")
            self.properties[index] = newValue
        }
    }
    
    // MARK: - Protocol Method
    public func next() -> T? {
        guard index < self.properties.count else { return nil }
        defer { index += 1 }
        return self.properties[index]
    }
    
    // MARK: - Fundamental Method
    public func appendProperty(property: T) {
        self.properties.append(property)
    }
    
    public func appendProperties(contentOf properties: [T]) {
        self.properties.append(contentsOf: properties)
    }
    
    public func findPropertyByElementName(_ name: String) -> T? {
        self.properties.first(where: { $0.isElementNameMatch(name) })
    }
    
    public func findPropertyIndexByElementName(_ name: String) -> Int {
        self.properties.firstIndex(where: { $0.isElementNameMatch(name) }) ?? -1
    }
    
    internal func createNewCommand() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewRootINDIProtocolElement() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] { [] }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copiedProperties = self.properties.map({ $0.copy() as! T })
        
        let newVectorProperty = INDIVectorPropertyTemplate<T>(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, dynamic: self.dynamic)
        newVectorProperty.appendProperties(contentOf: copiedProperties)
        
        return newVectorProperty
    }
    
    public override func clear() {
        self.properties.removeAll()
        super.clear()
    }
}
