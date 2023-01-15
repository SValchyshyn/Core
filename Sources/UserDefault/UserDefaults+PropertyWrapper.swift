//
//  UserDefaults+PropertyWrapper.swift
//  UserDefault
//
//  Created by Frederik Sørensen on 15/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import Log
import Logging

/// A wrapper around retrieving and storing values in User Defaults.
/// If the value should not be cleared on logout, set the `shouldClearOnLogout` flag to `false` (defaults to `true`). This will store the value separately from the user-related settings.
/// If the value should be migrated from another `UserDefaults` instance, use the `Migration` structure to provide information regarding the migration.
///
/// Usage:
/// ```
/// enum UserSettings
/// {
///     @UserDefault(key: "KeyForDefaults", defaultValue: false) // `shouldClearOnLogout` defaults to `true`, `migration` defaults to `nil`.
///     static var someValue: Bool
/// }
///
/// print( UserSettings.someValue )
/// // Prints 'false' (default value)
///
/// // Update value of the user setting
/// UserSettings.someValue = true
///
/// print( UserSettings.someValue )
/// // Prints 'true' (new, stored value)
/// ```
///
/// Use this value for simple data structures that are InfoPlist compliant. For other and more complex types, see `CodableUserDefault`.
@propertyWrapper
public class UserDefault<T> {
	/// The key to use in the `UserDefaults` instance.
	fileprivate let _key: String

	/// The default value to return, in case no value is stored or registered in the `UserDefaults` instance.
	fileprivate let _defaultValue: T

	/// Where the information will be stored.
	fileprivate let _defaults: UserDefaults
	
	public init( key: String, defaultValue: T, userDefaults: UserDefaults, migration: Migration? = nil ) {
		self._key = key
		self._defaultValue = defaultValue
		self._defaults = userDefaults
		migration.map( self.perform(migration:) )
	}

	public required convenience init( key: String, defaultValue: T, shouldClearOnLogout: Bool = true, migration: Migration? = nil ) {
		let userDefaults: UserDefaults = shouldClearOnLogout ? .userSettings : .appSettings
		self.init(key: key, defaultValue: defaultValue, userDefaults: userDefaults, migration: migration)
	}

	/// Convenience `init` allowing us to reference keys as `enums` as opposed to bare-bone `Strings`.
	public convenience init<RR: RawRepresentable>( key: RR, defaultValue: T, shouldClearOnLogout: Bool = true, migration: Migration? = nil ) where RR.RawValue == String {
		self.init( key: key.rawValue, defaultValue: defaultValue, shouldClearOnLogout: shouldClearOnLogout, migration: migration )
	}

	// MARK: - Public interface.

	/// Called when the object is setup and the data migration between different `UserDefaults` suites can be performed.
	/// - Parameter migration: Contains information about where the data used to be found.
	func perform( migration: Migration ) {
		// Do the migration if needed
		migration.migrate { wrappedValue = $0 }
	}

	// MARK: - PropertyWrapper implementation.

	public var wrappedValue: T {
		get {
			do {
				return try _defaults.getObject( forKey: _key ) ?? _defaultValue
			} catch {
				assert(false, "Wrong type conversion for \(_key) to \(T.Type.self)")
				Log.technical.log(.error, "Wrong type conversion for \(_key) to \(T.Type.self)", [.identifier("userDefaults.wrappedValue.conversion")])
				return _defaultValue
			}
		}
		set { _defaults.setObject( newValue, forKey: _key ) }
	}
}

/// A wrapper around retrieving and storing values in User Defaults using `JSONEncoder()` and `JSONDecoder()`. We don't use any date strategies here, since they are encoded and decoded with the default strategy.
/// If the value should not be cleared on logout, set the `shouldClearOnLogout` flag to `false` (defaults to `true`). This will store the value separately from the user-related settings.
/// If the value should be migrated from another `UserDefaults` instance, use the `Migration` structure to provide information regarding the migration.
///
/// Usage:
/// ```
/// struct Person: Codable, CustomStringConvertible
/// {
///     let name: String
///
///     var description: String {
///         return "My name is \(name)"
///     }
/// }
///
/// enum UserSettings
/// {
///     @CodableUserDefault( key: "KeyForDefaults", defaultValue: nil )
///     static var person: Person?
/// }
///
/// print( UserSettings.person )
/// // Prints 'nil' (default value)
///
/// // Update value of the user setting
/// UserSettings.person = Person( name: "Some cool name" )
///
/// print( UserSettings.person )
/// // Prints 'My name is Some cool name' (new, stored value)
/// ```
///
/// Use this value for data structures that are non-InfoPlist compliant, i.e. `Codable` types.
@propertyWrapper
public class CodableUserDefault<T: Codable>: UserDefault<T> {

	/// Decodes the object from `Data`.
	private let _decoder: JSONDecoder = .init()

	override func perform( migration: Migration ) {
		migration.migrate { (objectData: Data) in
			// For CodableUserDefault we store the information as `Data`, so be careful to extract it as data.
			// We do not want to go through the decoding and encoding process so we just bypass it by storing directly in the UserDefaults.
			_defaults.setObject( objectData, forKey: _key )
		}
	}

	// MARK: - Property wrapper implementation.

	public override var wrappedValue: T {
		get {
			do {
				return try _defaults.getCodableObject( forKey: _key, decoder: _decoder ) ?? _defaultValue
			} catch {
				// If we have no value set in the decoder's userInfo, this means that this is the first time we log the error.
				if _decoder.userInfo[ UserDefaults.logginUserKey ] == nil {
					// Log the error and then update the value so we don't log the error again for the same propertyWrapper.
					Log.technical.log(.notice, "Could not decode \(T.self): \(error)", [.identifier("core.codableUserDefault.1")])
					_decoder.userInfo[ UserDefaults.logginUserKey ] = true
				}
				return _defaultValue
			}
		}
		set {
			// Reset the error logic flag since a new value has been added.
			// The new value can possibly bring new decoding problems.
			// e.g. bad encoding can be because of the `Migration`; bad encoding can simply be bad by-hand implemented encoding.
			_decoder.userInfo[ UserDefaults.logginUserKey ] = nil

			do {
				try _defaults.setCodableObject( newValue, forKey: _key )
			} catch {
				fatalError( "Type '\(type(of: newValue))' is not Codable compliant, underlying error: \(error)" )
			}
		}
	}
}

/// A wrapper around retrieving and storing values in User Defaults. The data should not be something the app relies on for its good functioning but rather some data points
/// based on which some "nice to have" decisions can be made.
/// The data is stored in a special manner such that it will be easy to identify and purge without affecting any other user/ app session related data.
@propertyWrapper
public final class PurgeableUserDefault<T>: UserDefault<T> {

	// MARK: - Init.

	public convenience init( key: String, defaultValue: T, migration: Migration? = nil ) {
		// Always shouldClearOnLogout == true since the purgeable data should be something that has the least priority
		// of all the data that is stored in `UserDefaults`.
		// In order to differentiate all the purgeable data without actually creating extra UserDefaults suites, we suffix the key with a special identifier.
		self.init( key: key + UserDefaults.PersistencePolicies.purgebleKeyIdentifier, defaultValue: defaultValue, shouldClearOnLogout: true, migration: migration )
	}

	// MARK: - PropertyWrapper implementation.

	// Must be overriden otherwise the compiler will complain.
	public override var wrappedValue: T {
		get { super.wrappedValue }
		set { super.wrappedValue = newValue }
	}
}

/// `Codable` conforming counterpart of the `PurgeableUserDefault`.
@propertyWrapper
public final class PurgeableCodableUserDefault<T: Codable>: CodableUserDefault<T> {

	// MARK: - Init.

	public convenience init( key: String, defaultValue: T, migration: Migration? = nil ) {
		// Always shouldClearOnLogout == true since the purgeable data should be something that has the least priority
		// of all the data that is stored in `UserDefaults`.
		// In order to differentiate all the purgeable data without actually creating extra UserDefaults suites, we suffix the key with a special identifier.
		self.init( key: key + UserDefaults.PersistencePolicies.purgebleKeyIdentifier, defaultValue: defaultValue, shouldClearOnLogout: true, migration: migration )
	}

	// MARK: - PropertyWrapper implementation.

	// Must be overriden otherwise the compiler will complain.
	public override var wrappedValue: T {
		get { super.wrappedValue }
		set { super.wrappedValue = newValue }
	}
}
