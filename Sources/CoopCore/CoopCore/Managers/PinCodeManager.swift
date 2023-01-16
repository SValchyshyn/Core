//
//  PinCodeManager.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 24.03.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import Foundation

public protocol PinCodeManager {
	/// Indicates whether there is a saved pin code
	var hasPinCodeStored: Bool { get }

	/// Save pin code
	func savePinCode(_ pincode: String) throws

	/// Delete pin code
	func deletePinCode() throws

	/// Get current pin code
	func getPinCode() throws -> String?
}

public final class PinCodeKeychainManager: PinCodeManager {

	private struct Constants {
		// Constant for accessing the pin code in keychain
		static let pincodeKeychainConstant = "pincodeKeychainConstant"
	}

	public init() {}

	// MARK: - Properties

	private let keychainManager: Keychain = .shared

	/// Indicates if the pin code is saved in the keychain
	public var hasPinCodeStored: Bool {
		(try? getPinCode()) != nil
	}

	// MARK: - Public methods
	
	/// Save pin code to the keychain
	public func savePinCode(_ pincode: String) throws {
		try keychainManager.addOrUpdateGenericPassword(account: nil,
													   service: Constants.pincodeKeychainConstant,
													   password: pincode)
	}
	
	/// Delete pin code from the keychain
	public func deletePinCode() throws {
		try keychainManager.deleteGenericPassword(account: nil,
												  service: Constants.pincodeKeychainConstant)
	}
	
	/// Get current pin code from keychain
	public func getPinCode() throws -> String? {
		return try keychainManager.findGenericPassword( account: nil,
														service: Constants.pincodeKeychainConstant )
	}
}
