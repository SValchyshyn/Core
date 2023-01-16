//
//  UUIDResponse.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 26/08/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import UserDefault

/**
Server response from the UUID endpoint
*/
public struct UUIDResponse: Decodable {
	public let keys: UUIDRepository
}

/**
A container of UUIDs for different third party services.
This is simply a String: String dictionary containing the raw values from the UUID service API.
*/
public typealias UUIDRepository = [String: String]

// MARK: - UUIDRepositoryKey

// swiftlint:disable all
/**
Protocol for defining UUID repository keys and accessing the value. It is not _required_ to use this protocol for accessing UUID repository values, but it is considered "best practise" (see below).

The `UUIDRepositoryKey` protocol defines a `rawValue: String` and a function for retrieving the value: `value() -> String?`.

The value function has a default implementation that calls `UUIDRepositoryManager.shared[ ... ]` and there is no need to implement that yourself.

## Recommendation
Best-practise recommendation is to declare an enum as follows:

```
enum UUIDKey: String, UUIDRepositoryKey {
    case myKey
}
```

The actual value of the corresponding UUID key in the dictionary returned from the UUID API can then be accessed as follows:

```
let uuidValue = UUIDKey.myKey.value()
```

Note that the `rawValue` of the key must match the key in the UUID API dictionary. So set an explicit value if required (`case oneKey = "1_key"`).

## Alternate solution
As the `UUIDRepositoryManager` simply requires a string as key, it is also possible to access the keys directly:

```
let uuidValue = UUIDRepositoryManager.shared[ "some-key-name" ]
```

This, however, is not recommended for consistency and readability.
*/
public protocol UUIDRepositoryKey {
	// swiftlint:enable all
	var rawValue: String { get }	// Use an `enum …: String` to implement this
	func value() -> String?			// Is implemente in protocol extension below
}

public extension UUIDRepositoryKey {
	/**
	Retrieves the value of the UUID key matching the `rawValue` name of the key in question.
	If no key in the UUID API response matches the name, `nil` is returned.

	- returns: The UUID to use for the specified key or `nil`.
	*/
	func value() -> String? {
		return UUIDRepositoryManager.shared[ self.rawValue ]
	}
}

/**
Since we should not expose the member ID to third party services we have to instead use UUIDs which are linked to the member ID.
The UUIDRepositoryManager fetches and caches the UUIDs.

It is recommended to use the `UUIDRepositoryKey` protocol for defining and accessing values.
*/
public final class UUIDRepositoryManager {
	private enum Keys {
		static let uuidRepository = "uuidRepository"
	}

	/// On-disk cache representation of the `UUIDRepository`.
	@CodableUserDefault( key: Keys.uuidRepository, defaultValue: nil, migration: Migration( key: Keys.uuidRepository ) )
	private var _uuidRepository: UUIDRepository?

	/// In-memory cache of the `UUIDRepository` so we don't go down to the `UserDefaults` everytime we want to acces a key
	/// because that action also implies `JSONDecoding`.
	private lazy var _cachedRepository: UUIDRepository? = _uuidRepository

	// MARK: - Singleton.

	public static let shared = UUIDRepositoryManager()

	private init() { }

	// MARK: - Public interface.

	/*
	These are the old definitions and are here for reference only.
	case splitAppUserID = "app_split"
	case adobeUserID = "aem_id"
	case eventLogUserID = "eventlog_id"
	*/

	/// `true` if we have cached data
	public var hasCachedData: Bool {
		return _cachedRepository != nil
	}

	/// Access to a specific key in the UUID dictionary
	subscript( key: String ) -> String? {
		return _cachedRepository?[ key ]
	}

	/**
	Erase currently cached UUIDs
	*/
	public func clearCache() {
		_cachedRepository = nil
	}
	
	public func update(with uuidRepository: UUIDRepository) {
		_cachedRepository = uuidRepository
		_uuidRepository = uuidRepository
	}
}
