//
//  Theme.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 09.04.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/// Base abstraction of `theme` resources that we can reuse, generically, throughout the whitelabeling applications.
open class ThemeContainer<Key: Hashable, Value> {

	/// Interface for providing custom `Value` instances for each application based on custom `Keys`.
	public typealias Resolver = ( _ valueForKey: Key ) -> Value

	// MARK: - Properties.

	/// Used as backup if the value is not found at runtime.
	private let _resolver: Resolver

	// MARK: - Init.

	/// - Parameter resolver: Provides the actual `Valie` instances. Will be stored, make sure to `weak reference` instances in it.
	public init( resolver: @escaping Resolver ) {
		self._resolver = resolver
	}

	/// Convenience usage for the `ThemeContainer` so it's easier to reference values out of it.
	public subscript( key: Key ) -> Value {
		return _resolver( key )
	}

}
