//
//  INDPropertyTemplate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//
import Foundation

public class INDIPropertyTemplate<T: INDIElement>: INDIProperty, IteratorProtocol, @unchecked Sendable {
    public typealias Element = T
    
    // MARK: - Original Property
    internal var _elements: [T]
    
    // MARK: - Protocol Property
    var index: Int = 0

    // MARK: - Initializer
    public override init(deviceName: String = "", propertyName: String = "", propertyLabel: String = "", groupName: String = "", propertyPermission: INDIPropertyPermission = .ReadOnly, timeout: Double = 0, propertyState: INDIPropertyState = .Idle, timestamp: String = "", dynamic: Bool = false) {
        self._elements = []
        super.init(deviceName: deviceName, propertyName: propertyName, propertyLabel: propertyLabel, groupName: groupName, propertyPermission: propertyPermission, timeout: timeout, propertyState: propertyState, timestamp: timestamp, dynamic: dynamic)
    }
    
    deinit {
        self._elements.removeAll()
    }
    
    // MARK: - Original Computed Property
    public var isEmpty: Bool {
        get {
            self._lock.withLock({
                self._elements.isEmpty
            })
        }
    }
    
    public var count: Int {
        get {
            self._lock.withLock({
                self._elements.count
            })
        }
    }
    
    public var elements: [T] {
        get {
            self._lock.withLock({
                self._elements
            })
        }
    }

    // MARK: - Computed Property
    public subscript(index: Int) -> Element {
        get {
            self._lock.withLock({
                assert(self._elements.startIndex <= index && index < self._elements.endIndex, "index out of range.")
                return self._elements[index]
            })
        }
        set {
            self._lock.withLock({
                assert(self._elements.startIndex <= index && index < self._elements.endIndex, "index out of range.")
                self._elements[index] = newValue
            })
        }
    }
    
    // MARK: - Protocol Method
    public func next() -> T? {
        self._lock.withLock({
            guard index < self._elements.count else { return nil }
            defer { index += 1 }
            return self._elements[index]
        })
    }
    
    // MARK: - Fundamental Method
    public func appendElement(element: T) {
        self._lock.withLock({
            self._elements.append(element)
        })
    }
    
    public func appendElements(contentOf elements: [T]) {
        self._lock.withLock({
            self._elements.append(contentsOf: elements)
        })
    }
    
    public func findElementByName(_ name: String) -> T? {
        self._lock.withLock({
            self._elements.first(where: { $0.isElementNameMatch(name) })
        })
    }
    
    public func findElementIndexByName(_ name: String) -> Int {
        self._lock.withLock({
            self._elements.firstIndex(where: { $0.isElementNameMatch(name) }) ?? -1
        })
    }
    
    internal func createNewCommand() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewRootINDIProtocolElement() -> INDIProtocolElement { INDIProtocolElement(tagName: "") }
    
    internal func createNewChildrenINDIProtocolElement() -> [INDIProtocolElement] { [] }
    
    // MARK: - Override Method
    public override func clear() {
        self._lock.withLock({
            self._elements.removeAll()
        })
        super.clear()
    }
}
