//
//  AtomicDictionary.swift
//  CoopM16
//
//  Created by Coruț Fabrizio on 07/02/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// An atomic implementation of a mutable dictionary.
/// Backed up by`NSMutableDictionary` and `objc_sync_` API.
public final class AtomicMutableDictionary {
	/// Underlying dictionary which is atomically protected.
	private let _dictionary: NSMutableDictionary

	/// Used to synchronize access in the assign and remove methods.
	private let _lockObject: NSObject

	/// Copy of the underlying dictionary.
	public var dictionary: NSMutableDictionary? {
		defer {
			// Make sure to exit the synchronization zone.
			objc_sync_exit( _lockObject )
		}

		// Synchronize the copy process.
		objc_sync_enter( _lockObject )
		return _dictionary.mutableCopy() as? NSMutableDictionary
	}

	public init( initialDictionary: NSMutableDictionary ) {
		_dictionary = initialDictionary
		_lockObject = .init()
	}

	/// Access the `value` found at `key`.
	public subscript( key: NSCopying ) -> Any? {
		get {
			defer {
				// Exit the synchronization zone.
				objc_sync_exit( _lockObject )
			}

			// Synchronize the read of objects.
			objc_sync_enter( _lockObject )
			return _dictionary.object( forKey: key )
		}

		set {
			// Start the synchronization block when writing in the dictionary.
			objc_sync_enter( _lockObject )

			// If the new value is `nil`, then remove the object found at the ky.
			if let value = newValue {
				_dictionary.setObject( value, forKey: key )
			} else {
				_dictionary.removeObject( forKey: key )
			}

			// Exit the synchronization zone.
			objc_sync_exit( _lockObject )
		}
	}
}
