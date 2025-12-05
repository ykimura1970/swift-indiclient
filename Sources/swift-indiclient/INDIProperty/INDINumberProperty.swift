//
//  INDINumberProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Combine
internal import NIOConcurrencyHelpers

final public class INDINumberProperty: INDIProperty, ObservableObject, @unchecked Sendable {
    // MARK: - Original Property
    internal var format: String
    internal var minValue: Double
    internal var maxValue: Double
    internal var stepValue: Double
    @Published internal(set) public var value: Double
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", format: String = "", minValue: Double = 0, maxValue: Double = 0, stepValue: Double = 0, value: Double = 0, parent: INDIVectorProperty? = nil) {
        self.format = format
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepValue = stepValue
        self.value = value
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Original Computed Property
    public var range: ClosedRange<Double> {
        get {
            lock.withLock({
                self.minValue...self.maxValue
            })
        }
    }
    
    public var minMaxStep: (minValue: Double, maxValue: Double, stepValue: Double) {
        get {
            lock.withLock({
                (self.minValue, self.maxValue, self.stepValue)
            })
        }
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self.format = format
    }
    
    public func setMin(_ minValue: Double) {
        lock.withLock({
            self.minValue = minValue
        })
    }
    
    public func setMax(_ maxValue: Double) {
        lock.withLock({
            self.maxValue = maxValue
        })
    }
    
    public func setStep(_ stepValue: Double) {
        self.stepValue = stepValue
    }
    
    public func setValue(_ value: Double) {
        lock.withLock({
            self.value = value
        })
    }
    
    public func getFormat() -> String {
        self.format
    }
    
    public func getMin() -> Double {
        lock.withLock({
            self.minValue
        })
    }
    
    public func getMax() -> Double {
        lock.withLock({
            self.maxValue
        })
    }
    
    public func getStep() -> Double {
        lock.withLock({
            self.stepValue
        })
    }
    
    public func getValue() -> Double {
        lock.withLock({
            self.value
        })
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        lock.withLock({
            INDINumberProperty(elementName: self.elementName, elementLabel: self.elementLabel, format: self.format, minValue: self.minValue, maxValue: self.maxValue, stepValue: self.stepValue, value: self.value, parent: self.parent)
        })
    }
    
    public override func clear() {
        self.format = ""
        self.stepValue = 0
        lock.withLock({
            self.minValue = 0
            self.maxValue = 0
            self.value = 0
        })
        super.clear()
    }
}
