//
//  HIPEventedProperty.swift
//  HIPEventedProperty
//
//  Created by Steve Johnson on 7/14/16.
//  Copyright © 2016 Hipmunk, Inc. All rights reserved.
//

import Foundation


/**
 There are several varieties of `HIPEventedProperty`. `HIPEventSourceWithValue` specifies methods common
 to all of them.
 */
public protocol HIPEventSourceWithValue: class {
    /// Type of the value stored in this property
    associatedtype ValueType

    /// Stored value of the property. Whenever this changes, all subscribers are fired unless their associated
    /// objects have been deallocated.
    var value: ValueType { get set }

    // This protocol only applies to HIPEventSource, but Swift doesn't let us specify that, so its methods
    // are declared as part of HIPEventSourceWithValue.
    func subscribe(withObject object: AnyObject, callback: @escaping () -> Void) -> (() -> Void)

    // This protocol only applies to HIPEventSource, but Swift doesn't let us specify that, so its methods
    // are declared as part of HIPEventSourceWithValue.
    func subscribeOnce(withObject object: AnyObject, callback: @escaping () -> Void) -> (() -> Void)
}


public extension HIPEventSourceWithValue {
    /// `onChange(value)` is called whenever `self.value` changes.
    public func subscribeToValue(withObject object: AnyObject, onChange: @escaping (ValueType) -> ()) -> () -> () {
        return self.subscribe(withObject: object) { [weak self] in
            guard let strongSelf = self else { return }
            onChange(strongSelf.value)
        }
    }

    /// `onChange(value)` is called the next time `self.value` changes, unless `self` is deallocated first.
    public func subscribeOnceToValue(withObject object: AnyObject, onChange: @escaping (ValueType) -> ()) -> () -> () {
        var unsubscribe: (() -> ())?
        unsubscribe = self.subscribeOnce(withObject: object, callback: { [weak self] in
            guard let strongSelf = self else { return }
            onChange(strongSelf.value)
            unsubscribe?()
            unsubscribe = nil
        })
        return unsubscribe!
    }

    /// `onChange(oldValue, newValue)` is called whenever `self.value` changes.
    public func subscribeToSlidingWindow(
        withObject object: AnyObject,
        onChange: @escaping (ValueType, ValueType) -> ())
        -> () -> ()
    {
        var lastValue = self.value
        return self.subscribe(withObject: object) { [weak self] in
            guard let strongSelf = self else { return }
            let newValue = strongSelf.value
            onChange(lastValue, newValue)
            lastValue = newValue
        }
    }
}


/**
 The "normal" variety of `HIPEventedProperty` requires an equatable, non-optional value type.

 See `HIPEventSourceWithValue` for more methods.
 
 When the value changes, subscribers are only fired if the new value is not `==` to the old value, unless
 `shouldSkipDuplicates` is set to `true`.
 */
open class HIPEventedProperty<T: Equatable>: HIPEventSource, HIPEventSourceWithValue {
    public typealias ValueType = T

    /// Stored value of the property. Whenever this changes, all subscribers are fired unless their associated
    /// objects have been deallocated, or the new value is `==` to the old value and `shouldSkipDuplicates`
    /// is `true`.
    open var value: T { didSet {
        if shouldSkipDuplicates && oldValue == value { return }
        fireEvent()
    } }

    /// If `true` (default), subscribers are not fired when `value` is set if it is not `==` to the previous
    /// value.
    open var shouldSkipDuplicates: Bool

    /**
     - parameter initialValue: Initial value of the property
     - parameter skipDuplicates: If `true` (default), subscribers are not fired when `value` is set if it is not `==` to the previous value.
     */
    public init(_ initialValue: T, shouldSkipDuplicates: Bool = true) {
        self.value = initialValue
        self.shouldSkipDuplicates = shouldSkipDuplicates
    }
}


/**
 The "optional" variety of `HIPEventedProperty` requires an equatable, non-optional value type, but the stored
 value may be `nil`. In other words, You instantiate with `HIPEventedPropertyOptional<MyType>`, and the type
 of `value` is `MyType?`.
 
 See `HIPEventSourceWithValue` for more methods.
 
 When the value changes, subscribers are only fired if the new value is not `==` to the old value, unless
 `shouldSkipDuplicates` is set to `true`.
 */
open class HIPEventedPropertyOptional<T: Equatable>: HIPEventSource, HIPEventSourceWithValue {
    public typealias ValueType = T?

    /// Stored value of the property. Whenever this changes, all subscribers are fired unless their associated
    /// objects have been deallocated, or the new value is `==` to the old value and `shouldSkipDuplicates`
    /// is `true`.
    open var value: T? { didSet {
        if shouldSkipDuplicates && oldValue == value { return }
        fireEvent()
    } }

    /// If `true` (default), subscribers are not fired when `value` is set if it is not `==` to the previous
    /// value.
    open var shouldSkipDuplicates: Bool

    /**
     - parameter initialValue: Initial value of the property
     - parameter skipDuplicates: If `true` (default), subscribers are not fired when `value` is set if it is not `==` to the previous value.
     */
    public init(_ initialValue: T?, shouldSkipDuplicates: Bool = true) {
        self.value = initialValue
        self.shouldSkipDuplicates = shouldSkipDuplicates
    }
}


/**
 The "basic" variety of `HIPEventedProperty` has no constraints on the type, but performs no duplicate
 value checks before firing subscribers.
 
 See `HIPEventSourceWithValue` for more methods.
 */
open class HIPEventedPropertyBasic<T>: HIPEventSource, HIPEventSourceWithValue {
    public typealias ValueType = T

    /// Stored value of the property. Whenever this changes, all subscribers are fired unless their associated
    /// objects have been deallocated.
    open var value: T { didSet { fireEvent() } }

    /**
     - parameter initialValue: Initial value of the property
     - parameter skipDuplicates: If `true` (default), subscribers are not fired when `value` is set if it is not `==` to the previous value.
     */
    public init(_ initialValue: T) {
        self.value = initialValue
    }
}
