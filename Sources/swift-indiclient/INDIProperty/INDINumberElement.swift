//
//  INDINumberElement.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/11/27.
//

import Foundation
internal import NIOConcurrencyHelpers

final public class INDINumberElement: INDIElement, NSCopying, @unchecked Sendable {
    // MARK: - Original Property
    var _format: String
    var _minValue: Double
    var _maxValue: Double
    var _stepValue: Double
    var _value: Double
    
    // MARK: - Initializer
    public init(elementName: String = "", elementLabel: String = "", format: String = "", minValue: Double = 0, maxValue: Double = 0, stepValue: Double = 0, value: Double = 0, parent: INDIProperty? = nil) {
        self._format = format
        self._minValue = minValue
        self._maxValue = maxValue
        self._stepValue = stepValue
        self._value = value
        super.init(elementName: elementName, elementLabel: elementLabel, parent: parent)
    }
    
    // MARK: - Original Computed Property
    public var range: ClosedRange<Double> {
        get {
            self._lock.withLock({
                self._minValue...self._maxValue
            })
        }
    }
    
    public var minMaxStep: (minValue: Double, maxValue: Double, stepValue: Double) {
        get {
            self._lock.withLock({
                (self._minValue, self._maxValue, self._stepValue)
            })
        }
    }
    
    public var format: String {
        get {
            self._format
        }
    }
    
    public var minValue: Double {
        get {
            self._lock.withLock({
                self._minValue
            })
        }
    }
    
    public var maxValue: Double {
        get {
            self._lock.withLock({
                self._maxValue
            })
        }
    }
    
    public var stepValue: Double {
        get {
            self._lock.withLock({
                self._stepValue
            })
        }
    }
    
    public var value: Double {
        get {
            self._lock.withLock({
                self._value
            })
        }
    }
    
    public var valueAsInt: Int {
        get {
            self._lock.withLock({
                Int(self._value)
            })
        }
    }
    
    // MARK: - Original Method
    public func setFormat(_ format: String) {
        self._format = format
    }
    
    public func setMin(_ minValue: Double) {
        self._lock.withLockVoid({
            self._minValue = minValue
        })
    }
    
    public func setMax(_ maxValue: Double) {
        self._lock.withLockVoid({
            self._maxValue = maxValue
        })
    }
    
    public func setMinMax(minValue: Double, maxValue: Double) {
        setMin(minValue)
        setMax(maxValue)
    }
    
    public func setMinMax(doubleRange: ClosedRange<Double>) {
        setMin(doubleRange.lowerBound)
        setMax(doubleRange.upperBound)
    }
    
    public func setStep(_ stepValue: Double) {
        self._stepValue = stepValue
    }
    
    public func setValue(_ value: Double) {
        self._lock.withLockVoid({
            self._value = value
        })
    }
    
    public func setValue(_ value: Int) {
        self._lock.withLock({
            self._value = Double(value)
        })
    }
    
    public func clone() -> INDINumberElement {
        copy() as! INDINumberElement
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        self._lock.withLock({
            INDINumberElement(elementName: self._elementName, elementLabel: self._elementLabel, format: self._format, minValue: self._minValue, maxValue: self._maxValue, stepValue: self._stepValue, value: self._value, parent: self._parent)
        })
    }
    
    // MARK: - Override Method
    public override func clear() {
        self._format = ""
        self._stepValue = 0
        self._lock.withLock({
            self._minValue = 0
            self._maxValue = 0
            self._value = 0
        })
        super.clear()
    }
}
