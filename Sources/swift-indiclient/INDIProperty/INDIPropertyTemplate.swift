//
//  INDVectorPropertyTemplate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//
import Foundation

public class INDIVectorPropertyTemplate<T: INDIProperty>: INDIVectorProperty, IteratorProtocol, @unchecked Sendable {
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
            lock.withLock({
                self.properties.isEmpty
            })
        }
    }
    
    public var propertyCount: Int {
        get {
            lock.withLock({
                self.properties.count
            })
        }
    }

    // MARK: - Computed Property
    public subscript(index: Int) -> Element {
        get {
            lock.withLock({
                assert(self.properties.startIndex <= index && index < self.properties.endIndex, "index out of range.")
                return self.properties[index]
            })
        }
        set {
            lock.withLock({
                assert(self.properties.startIndex <= index && index < self.properties.endIndex, "index out of range.")
                self.properties[index] = newValue
            })
        }
    }
    
    // MARK: - Protocol Method
    public func next() -> T? {
        lock.withLock({
            guard index < self.properties.count else { return nil }
            defer { index += 1 }
            return self.properties[index]
        })
    }
    
    // MARK: - Fundamental Method
    public func appendProperty(property: T) {
        lock.withLock({
            self.properties.append(property)
        })
    }
    
    public func appendProperties(contentOf properties: [T]) {
        lock.withLock({
            self.properties.append(contentsOf: properties)
        })
    }
    
    public func findPropertyByElementName(_ name: String) -> T? {
        lock.withLock({
            self.properties.first(where: { $0.isElementNameMatch(name) })
        })
    }
    
    public func findPropertyIndexByElementName(_ name: String) -> Int {
        lock.withLock({
            self.properties.firstIndex(where: { $0.isElementNameMatch(name) }) ?? -1
        })
    }
    
    internal func createNewCommand() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewRootINDIProtocolElement() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] { [] }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        var copiedProperties = [T]()
        
        let newVectorProperty = lock.withLock({
            let copiedProperties = self.properties.map({ $0.copy() as! T })
            
            return INDIVectorPropertyTemplate<T>(deviceName: self.deviceName, propertyName: self.propertyName, propertyLabel: self.propertyLabel, groupName: self.groupName, propertyPermission: self.propertyPermission, timeout: self.timeout, propertyState: self.propertyState, timestamp: self.timestamp, dynamic: self.dynamic)
        })
        
        newVectorProperty.appendProperties(contentOf: copiedProperties)
        
        return newVectorProperty
    }
    
    public override func clear() {
        lock.withLock({
            self.properties.removeAll()
        })
        super.clear()
    }
}
