//
//  INDINumberProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Observation
import os

@Observable
final public class INDINumberProperty: INDIProperty, @unchecked Sendable {
    // MARK: - Original Property
    @ObservationIgnored private(set) public var format: String
    @ObservationIgnored private(set) public var min: Double
    @ObservationIgnored private(set) public var max: Double
    @ObservationIgnored private(set) public var step: Double
    private(set) public var value: Double
    @ObservationIgnored private let lock = OSAllocatedUnfairLock()
    
    // MARK: - Initializer
    public init(elementName: String, elementLabel: String, format: String, min: Double, max: Double, step: Double, value: Double) {
        self.format = format
        self.min = min
        self.max = max
        self.step = step
        self.value = value
        super.init(elementName: elementName, elementLabel: elementLabel)
    }
    
    public convenience init() {
        self.init(elementName: "", elementLabel: "", format: "", min: 0.0, max: 0.0, step: 0.0, value: 0.0)
    }
    
    // MARK: - Computed Property
    public var closedRange: ClosedRange<Double> {
        get {
            min...max
        }
    }
    
    public var vectorProperty: INDINumberVectorProperty? {
        get {
            parent as? INDINumberVectorProperty
        }
    }
    
    // MARK: - Protocol Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDINumberProperty(elementName: self.elementName, elementLabel: self.elementLabel, format: self.format, min: self.min, max: self.max, step: self.step, value: self.value)
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self.format = format
    }
    
    public func setMin(_ min: Double) {
        self.min = min
    }
    
    public func setMax(_ max: Double) {
        self.max = max
    }
    
    public func setClosedRange(_ closedRange: ClosedRange<Double>) {
        min = closedRange.lowerBound
        max = closedRange.upperBound
    }
    
    public func setStep(_ step: Double) {
        self.step = step
    }
    
    public func setValue(_ value: Double) {
        lock.withLock({
            self.value = value
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        format = ""
        min = 0.0
        max = 0.0
        step = 0.0
        lock.withLock({
            value = 0.0})
        super.clear()
    }
}
