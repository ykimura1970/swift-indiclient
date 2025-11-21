//
//  INDINumberProperty.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
import Combine

public class INDINumberProperty: INDIProperty, ObservableObject {
    // MARK: - Original Property
    internal(set) public var format: String
    internal(set) public var minValue: Double
    internal(set) public var maxValue: Double
    internal(set) public var stepValue: Double
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
            minValue...maxValue
        }
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self.format = format
    }
    
    public func setMin(_ minValue: Double) {
        self.minValue = minValue
    }
    
    public func setMax(_ maxValue: Double) {
        self.maxValue = maxValue
    }
    
    public func setStep(_ stepValue: Double) {
        self.stepValue = stepValue
    }
    
    public func setValue(_ value: Double) {
        self.value = value
    }
    
    // MARK: - Override Method
    public override func copy(with zone: NSZone? = nil) -> Any {
        INDINumberProperty(elementName: self.elementName, elementLabel: self.elementLabel, format: self.format, minValue: self.minValue, maxValue: self.maxValue, stepValue: self.stepValue, value: self.value, parent: self.parent)
    }
    
    public override func clear() {
        self.format = ""
        self.minValue = 0
        self.maxValue = 0
        self.stepValue = 0
        self.value = 0
        super.clear()
    }
}
