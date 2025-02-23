//
//  INDVectorPropertyTemplate.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

public class INDIVectorPropertyTemplate<T: INDIProperty>: INDIVectorProperty, IteratorProtocol, @unchecked Sendable {
    public typealias Element = T
    
    // MARK: - Original Property
    private(set) public var properties: [Element] = []
    private var index: Int = 0
    
    // MARK: - Initializer
    deinit {
        properties.removeAll()
    }
    
    // MARK: - Computed Property
    public subscript(index: Int) -> Element {
        get {
            assert(properties.startIndex <= index && index < properties.endIndex, "index out of range.")
            return properties[index]
        }
        set {
            assert(properties.startIndex <= index && index < properties.endIndex, "index out of range.")
            properties[index] = newValue
        }
    }
    
    public var copyProperties: [Element] {
        get {
            properties.map({ $0.copy() as! Element })
        }
    }
    
    public var propertyCount: Int {
        get {
            properties.count
        }
    }
    
    public var propertyIsEmpty: Bool {
        get {
            properties.isEmpty
        }
    }
    
    // MARK: - Protocol Method
    public func next() -> Element? {
        guard index < properties.count else { return nil }
        defer { index += 1 }
        return properties[index]
    }
    
    // MARK: - Fundamental Method
    public func appendProperty(property: Element) {
        properties.append(property)
    }
    
    public func findPropertyByElementName(_ name: String) -> Element? {
        properties.first(where: { $0.isElementNameMatch(name) })
    }
    
    public func findPropertyIndexByElementName(_ name: String) -> Int {
        properties.firstIndex(where: { $0.isElementNameMatch(name) }) ?? -1
    }
    
    public func createNewCommand(newProperties: [Element]) -> String {
        return ""
    }
    
    // MARK: - Override Method
    public override func clear() {
        properties.removeAll()
        super.clear()
    }
}
