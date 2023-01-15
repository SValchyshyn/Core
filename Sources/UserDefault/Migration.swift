//
//  Migration.swift
//  UserDefault
//
//  Created by Coruț Fabrizio on 13.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/// A structure to encapsulate the information regarding migrating from one `UserDefaults` instance to another.
public struct Migration {
	/// The key in the old `UserDefaults` instance
	let key: String

	/// The `UserDefaults` instance that the value was previously stored in.
	let defaults: UserDefaults

	public init( key: String, from defaults: UserDefaults = .standard ) {
		self.key = key
		self.defaults = defaults
	}

	/// Convenience `init` allowing us to reference keys as `enums` as opposed to bare-bone `Strings`.
	public init<RR: RawRepresentable>( key: RR, from defaults: UserDefaults = .standard ) where RR.RawValue == String {
		self.init( key: key.rawValue, from: defaults )
	}

	/// Extracts the value found in the current `defaults` and cleans it up. If the value is not found/ is `nil`, the `oldValueProvider` is never called.
	/// - Parameter oldValueProvider: Is provided with the `old value` and just before it's cleared out.
	func migrate<T>( oldValueProvider: (T) -> Void ) {
		// We can't find the value in the old defaults, or value is of unexpected type, do nothing.
		guard let valueInOldDefaults = defaults.object( forKey: key ), let value = valueInOldDefaults as? T else { return }

		// Provide the actual value.
		oldValueProvider( value )

		// Make sure to remove it from the defaults afterwards.
		defaults.removeObject( forKey: key )
	}
}
