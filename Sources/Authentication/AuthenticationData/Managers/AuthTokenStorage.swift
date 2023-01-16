//
//  AuthTokenStorage.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 14.06.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation
import Core
import CoopCore
import AuthenticationDomain
import Log

enum AuthKeychainConstants {
	static let keychainAccountName = "\(CoreConfiguration.businessUnitName) \(CoreConfiguration.current.rawValue)"
}

public final class KeychainManagerImpl: AuthTokenStorage {
	
	public init() {
		NSKeyedUnarchiver.setClass(AuthTokenDTO.self, forClassName: "Authentication.AuthToken")
	}
	
	public subscript(tokenKey: String) -> AuthToken? {
		get {
			retrieve(by: tokenKey)
		}
		set {
			if let token = newValue {
				saveAuthToken(tokenKey: tokenKey, token: token)
			} else {
				removeStoredToken(tokenKey: tokenKey)
			}
		}
	}
	
	public func removeAll() {
		do {
			// Delete id_token if saved. Ignore any errors.
			try Keychain.shared.deleteGenericPassword( account: AuthKeychainConstants.keychainAccountName, service: nil )
		} catch let error {
			Log.technical.log(.error, "Error deleting session tokens from keychain: \(error)", [.identifier("KeychainManagerImpl.removeSessionTokens")])
		}
	}
	
	// MARK: - Private
	
	private func retrieve(by tokenKey: String) -> AuthToken? {
		var token: AuthToken?
		
		do {
			if let tokenData = try Keychain.shared.findGenericPasswordData( account: AuthKeychainConstants.keychainAccountName, service: tokenKey ) {
				guard let authToken = try AuthTokenDTO.keychainDecoded(from: tokenData) else {
					Log.technical.log(.error, "Auth token could not be decoded.", [.identifier("KeychainManagerImpl.decodeAuthToken")])
					return nil
				}
				
				token = authToken.convertToDO()
			}
		} catch {
			// Fail silent. The app will still work fine (but the user need to login again if the app is terminated).
			Log.technical.log(.error, "Error fetching auth token from keychain: \(error).", [.identifier("KeychainManagerImpl.getStoredToken")])
		}
		
		return token
	}
	
	private func saveAuthToken( tokenKey: String, token: AuthToken ) {
		// Remember token
		do {
			let tokenDTO = AuthTokenDTO(authToken: token)
			// Save the token in the keychain
			let archive = try AuthTokenDTO.keychainEncoded( tokenDTO )
			try Keychain.shared.addOrUpdateGenericPassword( account: AuthKeychainConstants.keychainAccountName, service: tokenKey, passwordData: archive )
		} catch {
			// Fail silent. The app will still work fine (but the user need to login again if the app is terminated).
			Log.technical.log(.error, "Error saving \(tokenKey) in the keychain: \(error)", [.identifier("AuthenticationManager.saveToken")])
		}
	}
	
	private func removeStoredToken( tokenKey: String ) {
		do {
			try Keychain.shared.deleteGenericPassword( account: AuthKeychainConstants.keychainAccountName, service: tokenKey )
		} catch let error {
			Log.technical.log(.error, "Error deleting session token from keychain: \(error)", [.identifier("KeychainManagerImpl.removeStoredToken")])
		}
	}
	
	public var isEmpty: Bool {
		do {
			return try Keychain.shared.findGenericPasswordData( account: AuthKeychainConstants.keychainAccountName, service: nil ) == nil
		} catch {
			// Fail silent. The app will still work fine (but the user need to login again if the app is terminated).
			Log.technical.log(.error, "Error fetching auth token from keychain: \(error).", [.identifier("KeychainManagerImpl.isAnyTokenPresent")])
			return false
		}
	}
	
}
