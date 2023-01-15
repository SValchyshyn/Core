//
//  Injectable.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 03.06.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// A wrapper around service type that was previously registered.
///
/// ## Important:
/// If you forgot to register your dependency begore initializing @Injectable property - the app will fail. See `ServiceLocator` for more info.
///
///	## Usage:
///	Simply add @Injectable before the dependency declaration
///
/// - Note: The types of Singleton and wrappedValue should be equal, i.e. OptionalValueType != ValueType
///	```
///	@Injectable private var _paymentCardRepository: PaymentCardRepository
///	```
@propertyWrapper
public struct Injectable<T> {
	public var wrappedValue: T {
		return _dependency
	}
	
	private let _dependency: T
	
	public init() {
		// Inject a dependency
		self._dependency = ServiceLocator.inject()
	}
}

/// Wrapper behaving identical to `@Injectable` defined above, with the exception that it allows
/// for nil values by leveraging `ServiceLocator` `injectSafe()`.
@propertyWrapper
public struct InjectableSafe<T> {
	public var wrappedValue: T? {
		return _dependency
	}

	private let _dependency: T?

	public init() {
		// Inject a dependency safely
		self._dependency = ServiceLocator.injectSafe()
	}
}
