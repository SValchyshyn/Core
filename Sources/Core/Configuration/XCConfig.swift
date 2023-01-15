//
//  XCConfig.swift
//  CoopCore
//
//  Created by Jens Willy Johannsen on 10/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public class XCConfig {

	/// Which bundle will be used in fetching the `infoDictionary`.
	public private(set) static var bundle: Bundle = .main

#if ENTERPRISE
	/// Updates the bundle from which the `infoDictionary` is looked up.
	/// - Parameter bundle: The new `Bundle`.
	public static func set( bundle: Bundle ) {
		Self.bundle = bundle
	}
#endif

	// swiftlint:disable use_tabs
	/**
	Struct containing API keys.

	Add further API keys by extending this struct and use `XCConfig.value()` to retrieve the value from Info.plist:

	```
	extension XCConfig.APISubscriptionKeys {
	  static let myFancyAPIKey: string = XCConfig.value( for: "FANCY_NEW_API" )
	}
	```
	*/
	public struct APISubscriptionKeys {}
	// swiftlint:enable use_tabs

	/**
	Generic accessor for Info.plist items.

	This function is used for all non-specialized accessors.

	**Important:** the key _must_ exist in Info.plist. Otherwise, `fatalError()` will be called.

	- parameter for key: The key to retrieve value for.
	- returns: The value from Info.plist for the specified key. If the key does not exist, a `fatalError()` will occur.
	*/
	public static func value<T>(for key: String) -> T {
		guard let value = bundle.infoDictionary?[key] as? T else {
			fatalError( "Invalid or missing Info.plist key: \(key)" )
		}

		return value
	}

	/**
	Specialized accessor for URL items from Info.plist.

	If the value does not start with "http", the value will be prepended with `https://` before converting to a URL.

	**Important:** the key _must_ exist in Info.plist. Otherwise, `fatalError()` will be called.

	- parameter for key: The key to retrieve value for.
	- returns: The value from Info.plist for the specified key. If the key does not exist, a `fatalError()` will occur.
	*/
	public static func value( for key: String ) -> URL {
		guard var stringValue = bundle.infoDictionary?[key] as? String else {
			fatalError( "Invalid or missing Info.plist key: \(key)" )
		}

		// Add https:// if not already starting with http. Note: this does not allow for e.g. file:// URLs but this is identical to the old functionality.
		if !stringValue.lowercased().starts( with: "http" ) {
			stringValue = "https://" + stringValue
		}

		guard let url = URL( string: stringValue ) else {
			fatalError( "Cannot create URL from string: \(key)" )
		}

		return url
	}

	/**
	Specialized accessor for integer items from Info.plist.

	**Important:** the key _must_ exist in Info.plist. Otherwise, `fatalError()` will be called.

	- parameter for key: The key to retrieve value for.
	- returns: The value from Info.plist for the specified key. If the key does not exist, a `fatalError()` will occur.
	*/
	public static func value( for key: String ) -> Int {
		guard let stringValue = bundle.infoDictionary?[key] as? String else {
			fatalError( "Invalid or missing Info.plist key: \(key)" )
		}

		guard let value = Int( stringValue ) else {
			fatalError( "Cannot convert string to integer: \(key)" )
		}

		return value
	}

	/**
	Specialized accessor for `RawRepresentable` enum items from Info.plist.

	**Important:** the key _must_ exist in Info.plist. Otherwise, `fatalError()` will be called.

	- parameter for key: The key to retrieve value for.
	- returns: The value from Info.plist for the specified key. If the key does not exist, a `fatalError()` will occur.
	*/
	public static func value<T: RawRepresentable>( for key: String ) -> T {
		guard let rawValue = bundle.infoDictionary?[key] as? T.RawValue else {
			fatalError( "Invalid or missing Info.plist key: \(key)" )
		}

		guard let value = T.init( rawValue: rawValue ) else {
			fatalError( "Cannot create enum value from string: \(key)" )
		}

		return value
	}

	// MARK: - Obsolete
	/*
	public static func urlValue(for key: String) -> URL {
		guard let stringValue = Bundle.main.infoDictionary?[key] as? String else {
			fatalError("Invalid or missing Info.plist key: \(key)")
		}

		guard let url = URL(string: "https://\(stringValue)") else {
			fatalError("Cannot create URL from string: \(key)")
		}

		return url
	}

	public static func enumValue<T: RawRepresentable>(for key: String) -> T {
		guard let rawValue = Bundle.main.infoDictionary?[key] as? T.RawValue else {
			fatalError("Invalid or missing Info.plist key: \(key)")
		}

		guard let value = T.init(rawValue: rawValue) else {
			fatalError("Cannot create enum value from string: \(key)")
		}

		return value
	}
	*/
}

// swiftlint:disable use_tabs
/**
Protocol for enum keys for accessing configuration values from the `Info.plist` file.

In order to access values from the Info.plist file, declare an enum of raw type `String` and conforming to `InfoPlistKey`.

The raw values of the keys should match the name of the entry in the Info.plist file.

Use the `.value()` function to retrieve the value.

**Important:** the key _must_ exist in the Info.plist file. Otherwise, `fatalError()` will be called and the app will terminate.

## Types

The default `value()` function is generic `value<T>() -> T` but the following types have specialized accessors:

* Int
* URL
  If the value does not start with "http", the value is added to "https://" before converting to a URL.
* Enum (RawRepresentable)

## Example

```
enum InfoPlist: String, InfoPlistKey {
  case authorizationServerURL = "AUTHORIZATION_SERVER_URL"  // URL
  case coreAPIKey = "CORE_API_KEY"                          // String
  case mobileDankortTennantId = "MOBILE_DANKORT_TENNANT_ID" // Int
}

enum AppVariant: String {
  case denmark = "DENMARK"
  case greenland = "GREENLAND"
}

func testXCConfig() {
  let stringValue: String = InfoPlist.coreAPIKey.value()
  let urlValue: URL = InfoPlist.authorizationServerURL.value()
  let intValue: Int = InfoPlist.mobileDankortTennantId.value()
}
```
*/
public protocol InfoPlistKey {
	// swiftlint:enable use_tabs
	var rawValue: String { get }	// Use an `enum …: String` to implement this
	func value<T>() -> T			// Is implemented in protocol extension below
}

public extension InfoPlistKey {
	/**
	Retrieves the value of the Info.plist key matching the `rawValue` name of the key in question.

	If no key in the Info.plist matches the name, `fatalError()` will be called and the app will terminate.

	- returns: The value for the specified key.
	*/
	func value<T>() -> T {
		return XCConfig.value( for: rawValue ) as T
	}

	/**
	Retrieves the value of the Info.plist key matching the `rawValue` name of the key in question as a `rawRepresentable` enum.

	If no key in the Info.plist matches the name, `fatalError()` will be called and the app will terminate.

	- returns: The value for the specified key.
	*/
	func value<T: RawRepresentable>() -> T {
		return XCConfig.value( for: rawValue ) as T
	}

	/**
	Retrieves the value of the Info.plist key matching the `rawValue` name of the key in question as a URL.

	If no key in the Info.plist matches the name, `fatalError()` will be called and the app will terminate.

	- returns: The value for the specified key.
	*/
	func value() -> URL {
		return XCConfig.value( for: rawValue ) as URL
	}

	/**
	Retrieves the value of the Info.plist key matching the `rawValue` name of the key in question as an integer.

	If no key in the Info.plist matches the name, `fatalError()` will be called and the app will terminate.

	- returns: The value for the specified key.
	*/
	func value() -> Int {
		return XCConfig.value( for: rawValue ) as Int
	}
}
