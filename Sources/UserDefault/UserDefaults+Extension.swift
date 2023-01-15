//
//  UserDefaults+Extension.swift
//  UserDefault
//
//  Created by Coruț Fabrizio on 13.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

public extension UserDefaults {

	/// The instance of `UserDefaults` to use for app related preferences, that do not need to be cleared on sign out.
	///
	/// This instance is used for the values wrapped by the `UserDefault` and `CodableUserDefault` property wrappers, where the `shouldClearOnLogout` is set to `false` (default value is `true`).
	static let appSettings = UserDefaults( suiteName: "appsettings" )! // Force unwrap would have failed the first time -FSO

	/// This instance is used for the values wrapped by the `UserDefault` and `CodableUserDefault` property wrappers, where the `shouldClearOnLogout` is set to `true` (default value).
	static let userSettings = UserDefaults( suiteName: "user" )! // Force unwrap would have failed the first time -JWJ

	/// Clears up all the `purgeable` data stored in the `UserDefaults`.
	static func removePurgeableData() {
		userSettings.dictionaryRepresentation().lazy
			.map { $0.key }
			.filter { $0.hasSuffix( PersistencePolicies.purgebleKeyIdentifier ) }
			.forEach { userSettings.removeObject( forKey: $0 ) }
	}

	enum InteractionError: Error {

		/// The type that was expected does not match the type that was found.
		case typeMismatch
	}

	// MARK: - UserDefault internal helpers.

	/// Used to synchronize the access to the user.
	private static let _mutex: NSLock = .init()

	/// Custom key that helps keep tracking of logging the errors so we do not flood the event log.
	/// Since the `wrappedValue` is a computed property, every time we request the object, we might encounter an error. Probably the same error. Don't log it every time.
	internal static let logginUserKey = CodingUserInfoKey( rawValue: "shouldLogError" )! // Explicit unwrap, would have failed the first time -FAIO.

	// Explicitly declare `internal` since the extension is declared `public` and that would reflect on this declaration.
	internal enum PersistencePolicies {

		/// Used to identifiy a key that can be purgeable.
		static let purgebleKeyIdentifier: String = "_purgeable"
	}

	// MARK: - Public interface.

	/// Atomically gets an object from`UserDefaults` and tries to cast it to the expected type.
	/// - Parameter defaultName: The `unique identifier` of the stored value.
	func getObject<T>( forKey defaultName: String ) throws -> T? {
		defer { Self._mutex.unlock() }
		Self._mutex.lock()

		// Do we have the value stored?
		guard let value = object( forKey: defaultName ) else { return nil }

		// Does the value match the one we're expecting?
		guard let castedValue = value as? T else {
			// In case the type of the value stored changed, clear it and return default value
			removeObject( forKey: defaultName )
			throw InteractionError.typeMismatch
		}

		return castedValue
	}

	/// Atomically updates the value in `UserDefaults`. If the provided value is `nil`, the value will be removed from the local storage as well.
	/// - Parameters:
	///   - object: The new value.
	///   - defaultName: The `unique identifier` of the stored value.
	func setObject<T>( _ object: T, forKey defaultName: String ) {
		defer { Self._mutex.unlock() }
		Self._mutex.lock()

		switch object as Any {
		// swiftlint:disable:next syntactic_sugar - We need to be explicit here about the Optional type -FSO
		case Optional<Any>.some( let value ):
			// Save the (unwrapped) value
			set( value, forKey: defaultName )

		default:
			// The value is Optional.none
			removeObject( forKey: defaultName )
		}
	}

	// MARK: - Codable implementation.

	/// Atomically gets an object from`UserDefaults` and tries to `decode` it to the expected type.
	/// - Parameters:
	///   - defaultName: The `unique identifier` of the stored value.
	///   - decoder: Used to decode
	/// - Throws: `JSONDecoder` decoding errors.
	func getCodableObject<T: Codable>( forKey defaultName: String, decoder: JSONDecoder ) throws -> T? {
		defer { Self._mutex.unlock() }
		Self._mutex.lock()

		guard let data = data( forKey: defaultName ) else {
			return nil
		}

		return try decoder.decode( T.self, from: data )
	}

	/// Atomically updates the value in `UserDefaults`. If the provided value is `nil`, the value will be removed from the local storage as well.
	/// - Parameters:
	///   - object: The new value.
	///   - defaultName: The `unique identifier` of the stored value.
	/// - Throws: `JSONEncoder` encoding errors.
	func setCodableObject<T: Codable>( _ object: T, forKey defaultName: String ) throws {
		defer { Self._mutex.unlock() }
		Self._mutex.lock()

		switch object as Any {
		case Optional<Any>.none:
			// Encoding `nil` on iOS <13 would fail, so we guard against this and remove the object in that case
			removeObject( forKey: defaultName )

		default:
			let data = try JSONEncoder().encode( object )
			set( data, forKey: defaultName )
		}
	}
	
	/**
	 Clear all items stored.
	 */
	func clear() {
		for key in dictionaryRepresentation().keys {
			removeObject(forKey: key)
		}
	}
}
