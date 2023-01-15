//
//  AtomicValue.swift
//  Core
//
//  Created by Olexandr Belozierov on 28.02.2021.
//

import Foundation

@propertyWrapper
public final class AtomicValue<T: Equatable> {
	
	private let mutex = NSLock()
	private var value: T
	
	public init(wrappedValue: T) {
		self.value = wrappedValue
	}
	
	public var wrappedValue: T {
		get { mutex.locked { value } }
		set { mutex.locked { value = newValue } }
	}
	
	/// Updates value with new value and returns previous value
	@discardableResult public func update(with newValue: T) -> T {
		mutex.locked {
			defer { value = newValue }
			return value
		}
	}
	
}

/// Convenience declaration and streamline of the `AtomicValue` usage.
extension AtomicValue: ExpressibleByBooleanLiteral where T == Bool {
	
	public convenience init( booleanLiteral value: Bool ) {
		self.init( wrappedValue: value )
	}
}

public extension AtomicValue where T: Equatable {
	
	/// Compares two values for equality and, if they are equal, replaces it with desired.
	@discardableResult func compareExchange(expected: T, desired: T) -> Bool {
		mutex.locked {
			if value != expected { return false }
			value = desired
			return true
		}
	}
}

public extension NSLock {
	
	func locked<T>(_ block: () -> T) -> T {
		lock()
		defer { unlock() }
		return block()
	}
	
}
