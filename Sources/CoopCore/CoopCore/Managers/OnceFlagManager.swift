//
//  OnceFlagManager.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 08.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UserDefault

/// Allows the execution of code only once, regardless of app launches, for each `oldKey/ currentKey` pair passed at `init`.
/// Uses `UserDefaults` as underlying storage to determine whether the code has been executed once or not, hence, the `once` is persisted
/// between app launches and app installs over the old application, but not if the app is removed and installed again.
public final class OnceFlagManager {

	/// The `key` where the current `once flag` will be found.
	private let _currentFlagKey: String

	/// The actual flag accessor. Use `shouldClearOnLogout: true` so we do not reset the value upon `logout`.
	public private(set) lazy var hasExecuted: UserDefault<Bool> = .init( key: _currentFlagKey, defaultValue: false, shouldClearOnLogout: false )

	// MARK: - Init.

	/// - Parameters:
	///   - oldKey: The key where the `old` flag has been stored previously, for clean-up purposes.
	///   - currentKey: Used to uniquely identify the new `flag`.
	public init( oldKey: String? = nil, currentKey: String ) {
		oldKey.map { UserDefaults.appSettings.removeObject( forKey: $0 ) }
		self._currentFlagKey = currentKey
	}

	/// Initilaizer for creating a manager with a type safe flag
	/// - Parameters:
	///   - flag: The flag we want to create the manager with.
	public convenience init<T: OnceFlag>( flag: T ){
		self.init(oldKey: nil, currentKey: flag.rawValue)
	}

	// MARK: - Public.

	/// Executes the `block` only `once` for each unique `oldKey/ currentKey` pair with which the object has been initialized.
	/// If the `once flag` has been set already, the `block` will never get executed.
	/// - Parameter block: Critical code to be executed once.
	public func executeOnce( block: () -> Void ) {
		guard !hasExecuted.wrappedValue else { return }

		// Execute the block only if the
		block()

		// Reset the flag so we do not execute the code more than one time.
		hasExecuted.wrappedValue = true
	}
}

/// Protocol defining the requirements for Once flags
public protocol OnceFlag: RawRepresentable where Self.RawValue == String {}
