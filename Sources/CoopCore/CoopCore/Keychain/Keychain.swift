//
//  Keychain.swift
//  Keychain
//
//  Created by Jens Willy Johannsen on 06/07/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

import UIKit
import Security

/**
Keychain wrapper.
*/
open class Keychain: NSObject {
	/** KeychainManager related errors */
	public enum KeychainError: Error {
		/** Unable to convert the the username to NSData */
		case unableToConvertUsername

		/** Unable to convert password data to a UTF-8 string */
		case unableToConvertData

		/** A status other than noErr was returned from a Security framework function. The status in contained in the innerStatus value. */
		case securityError(innerStatus: OSStatus)
	}

	/**
	Singleton object. All methods should be run on this object.
	*/
	public static let shared = Keychain()

	// MARK: - Generic passwords

	/**
	Adds or updates a "generic" password (as oppsosed to an internet password).
	The passwords are tied to the combination of account and service. Both parameters are optional.

	- parameter account: Optional account
	- parameter service: Optional service name
	- parameter password: Password
	- throws: KeychainError.UnableToConvertUsername, KeychainError.SecurityError
	*/
	open func addOrUpdateGenericPassword(account: String?, service: String?, password: String) throws {
		// Convert password to UTF8 data
		let passwordData = password.data(using: String.Encoding.utf8, allowLossyConversion: false)
		if passwordData == nil {
			throw KeychainError.unableToConvertUsername
		}

		var attributes = [
			kSecClass as String: kSecClassGenericPassword,
			kSecValueData as String: passwordData! // Unwrapped: already checked for nil
		] as [String: Any]

		// Add optional parameters if present
		if let account = account {
			attributes[kSecAttrAccount as String] = account
		}
		if let service = service {
			attributes[kSecAttrService as String] = service
		}

		// Attempt to add the item. This will fail if it already exists.
		var status = SecItemAdd(attributes as CFDictionary, nil)

		// Check for "already exists error"
		if status == errSecDuplicateItem {
			// Duplicate item: use update instead
			attributes.removeValue(forKey: (kSecValueData as String)) // Remove password since we are now using the dictionary as a query
			let updateAttributes = [kSecValueData as String: passwordData!] // Unwrapped: already checked for nil
			status = SecItemUpdate(attributes as CFDictionary, updateAttributes as CFDictionary)
		}

		if status != noErr {
			// Throw the error
			throw KeychainError.securityError(innerStatus: status)
		}
	}

	/**
	Adds or updates a "generic" password (as oppsosed to an internet password).
	The passwords are tied to the combination of account and service. Both parameters are optional.
	
	- parameter account: Optional account
	- parameter service: Optional service name
	- parameter password: Password information as NSData
	- throws: KeychainError.SecurityError
	*/
	open func addOrUpdateGenericPassword(account: String?, service: String?, passwordData: Data) throws {
		var attributes = [
			kSecClass as String: kSecClassGenericPassword,
			kSecValueData as String: passwordData
		] as [String: Any]

		// Add optional parameters if present
		if let account = account {
			attributes[kSecAttrAccount as String] = account
		}
		if let service = service {
			attributes[kSecAttrService as String] = service
		}

		// Attempt to add the item. This will fail if it already exists.
		var status = SecItemAdd(attributes as CFDictionary, nil)

		// Check for "already exists error"
		if status == errSecDuplicateItem {
			// Duplicate item: use update instead
			attributes.removeValue(forKey: (kSecValueData as String)) // Remove password since we are now using the dictionary as a query
			let updateAttributes = [kSecValueData as String: passwordData]
			status = SecItemUpdate(attributes as CFDictionary, updateAttributes as CFDictionary)
		}

		if status != noErr {
			// Throw the error
			throw KeychainError.securityError(innerStatus: status)
		}
	}

	/**
	Finds a generic password based on the specified account and service names.
	Both are optional.

	- parameter account: Optional account to search for
	- parameter service: Optional service name to search for
	- returns: A non-empty string if a matching password was found
	- throws: KeychainError.UnableToConvertData, KeychainError.SecurityError
	*/
	open func findGenericPassword(account: String?, service: String?) throws -> String? {
		// Find only one matching username and server
		var query: [String: NSObject] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecReturnData as String: kCFBooleanTrue,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		// Add optional parameters if present
		if let account = account {
			query[kSecAttrAccount as String] = account as NSObject?
		}
		if let service = service {
			query[kSecAttrService as String] = service as NSObject?
		}

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		// Returns nil for errSecItemNotFound.
		if status == errSecItemNotFound {
			return nil
		}

		// Throw for other errors
		if status != noErr && result == nil {
			throw KeychainError.securityError(innerStatus: status)
		}

		// Convert to data and return
		if let data = result as? Data {
			return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? // Will return nil if unable to decode UTF8 string
		} else {
			throw KeychainError.unableToConvertData
		}
	}

	/**
	Finds a generic password based on the specified account and service names.
	Both are optional.
	
	- parameter account: Optional account to search for
	- parameter service: Optional service name to search for
	- returns: A non-empty string if a matching password was found
	- throws: KeychainError.SecurityError
	*/
	open func findGenericPasswordData(account: String?, service: String?) throws -> Data? {
		// Find only one matching username and server
		var query: [String: NSObject] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecReturnData as String: kCFBooleanTrue,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		// Add optional parameters if present
		if let account = account {
			query[kSecAttrAccount as String] = account as NSObject?
		}
		if let service = service {
			query[kSecAttrService as String] = service as NSObject?
		}

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		// Returns nil for errSecItemNotFound.
		if status == errSecItemNotFound {
			return nil
		}

		// Throw for other errors
		if status != noErr && result == nil {
			throw KeychainError.securityError(innerStatus: status)
		}

		// Convert to data and return
		if let data = result as? Data {
			return data
		} else {
			return nil
		}
	}

	/**
	Deletes the _generic_ password specified by account and service.
	Both parameters are optional.

	- warning: If neither account nor service is specified, _all_ generic passwords will be deleted.

	- parameter account: Optional account name to search for
	- parameter service: Optional service name to search for
	- throws: KeychainError.SecurityError
	*/
	open func deleteGenericPassword(account: String?, service: String?) throws {
		var query = [
			kSecClass as String: kSecClassGenericPassword
		]

		// Add optional parameters if present
		if let account = account {
			query[kSecAttrAccount as String] = account as CFString?
		}
		if let service = service {
			query[kSecAttrService as String] = service as CFString?
		}

		let status = SecItemDelete(query as CFDictionary)
		if status != noErr {
			throw KeychainError.securityError(innerStatus: status)
		}
	}

	// MARK: - Internet passwords

	/**
	Adds or updates the password for the specified account for the specified server.

	If an entry with the specified account and server already exists, the password is updated. Otherwise, the entry is added.

	Throws an error if an error occurred.

	- parameter username: The account/username to add
	- parameter password: The password to add
	- parameter server: The server to add entry for
	- parameter requirePasscodeSet: If true, the `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` flag will be set with `.userPresence`. Defaults to false.
	*/
	open func addOrUpdateInternetPassword(username: String, password: String, server: String, requirePasscodeSet: Bool = false) throws {
		// Convert password to UTF8 data
		let passwordData = password.data(using: String.Encoding.utf8, allowLossyConversion: false)
		if passwordData == nil {
			throw KeychainError.unableToConvertUsername
		}

		var attributes = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrAccount as String: username,
			kSecValueData as String: passwordData!, // Unwrapped: already checked for nil
			kSecAttrServer as String: server
		] as [String: Any]

		// Set userPresence required if specified
		if requirePasscodeSet {
			let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
			attributes[kSecAttrAccessControl as String] = sacObject
		}

		// Attempt to add the item. This will fail if it already exists.
		var status = SecItemAdd(attributes as CFDictionary, nil)

		// Check for "already exists error"
		if status == errSecDuplicateItem {
			// Duplicate item: use update instead
			attributes.removeValue(forKey: (kSecValueData as String)) // Remove password since we are now using the dictionary as a query
			let updateAttributes = [kSecValueData as String: passwordData!] // Unwrapped: already checked for nil
			status = SecItemUpdate(attributes as CFDictionary, updateAttributes as CFDictionary)
		}

		if status != noErr {
			// Throw the error
			throw KeychainError.securityError(innerStatus: status)
		}
	}

	/**
	Returns all usernames for the specified server.

	- parameter server: The server name to return accounts (usernames) for.
	- returns: An array of Strings containing the accounts (usernames) registered for this server. If no accounts are registered for this server, an empty array is returned
	*/
	open func findInternetAccountsForServer(_ server: String) throws -> [String] {
		let query: [String: AnyObject] = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrServer as String: server as AnyObject,
			kSecReturnAttributes as String: kCFBooleanTrue,
			kSecMatchLimit as String: kSecMatchLimitAll
		]

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		// Returns valid but empty array for errSecItemNotFound.
		if status == errSecItemNotFound {
			return []
		}

		// Throw error for other errors
		if status != noErr && result == nil {
			throw KeychainError.securityError(innerStatus: status)
		}

		// Convert to usable data types
		if let result = result as? [NSDictionary] {
			var accounts: [String] = []

			// Iterate all results and extract only account name
			for entry in result {
				if let account = entry[(kSecAttrAccount as String)] as? String {
					accounts.append(account)
				}
			}

			return accounts
		}

		return [] // Fall-through
	}

	/**
	Finds the password associated with the specified username and server.

	- parameter username: The account/username to retrieve password for
	- parameter server: The server
	- returns: A string with the decrypted password if found. If no match was found, nil is returned.
	 */
	open func findInternetPassword(username: String, server: String) throws -> String? {
		// Find only one matching username and server
		let query = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrServer as String: server,
			kSecAttrAccount as String: username,
			kSecReturnData as String: kCFBooleanTrue as Any,
			kSecMatchLimit as String: kSecMatchLimitOne
		] as [String: Any]

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		if status != noErr && result == nil {
			throw KeychainError.securityError(innerStatus: status)
		}

		// Convert to data and return
		if let result = result as? Data {
			return NSString(data: result, encoding: String.Encoding.utf8.rawValue) as String? // Will return nil if unable to decode UTF8 string
		} else {
			throw KeychainError.unableToConvertData
		}
	}

	/**
	Deletes the entry for the specified username and server or all internet passwords for the specified server.

	- parameter username: The username to delete the entry for. Specify nil to delete _all_ entries for the specified server.
	- parameter server: The server to delete the entry for
	*/
	open func deleteInternetPassword(username: String?, server: String) throws {
		var query = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrServer as String: server
		] as [String: Any]

		// Add username if specified
		if let username = username {
			query[kSecAttrAccount as String] = username
		}

		let status = SecItemDelete(query as CFDictionary)
		if status != noErr && status != errSecItemNotFound {
			throw KeychainError.securityError(innerStatus: status)
		}
	}
	
	/**
	Clear all items stored in keychain.
	*/
	public static func clear() {
		let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
		for itemClass in secItemClasses {
			let spec: NSDictionary = [kSecClass: itemClass]
			SecItemDelete(spec)
		}
	}
}
