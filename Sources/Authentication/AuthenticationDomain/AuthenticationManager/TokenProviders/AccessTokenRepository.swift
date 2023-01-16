//
//  AccessTokenRepository.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 30.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Log

/// Manager for providing access tokens.
class AccessTokenRepository: IDTokenRepository {
	
	typealias AccessToken = String
	
	/// If ID token should be used for getting access token
	private let useIdToken: Bool
	
	/// Access token update tasks.
	private let taskExecutor = UniqueTaskExecutor<AccessTokenRequest, AccessToken>()
	
	init(authTokenStorage: AuthTokenStorage, useIdToken: Bool) {
		self.useIdToken = useIdToken
		super.init(authTokenStorage: authTokenStorage)
	}
	
	// MARK: Access token
	
	/// Gets access token from storage.
	func cachedAccessToken(for request: AccessTokenRequest) -> AccessToken? {
		// Only `secureStorage` strategy can be cached
		guard request.persistanceStrategy == .secureStorage else { return nil }
		
		// Get auth token from storage and validate it
		return authTokenStorage[request.storageKey].flatMap { $0.isExpired ? nil : $0.accessToken }
	}
	
	/// Gets new access token from server.
	func renewAccessToken(for request: AccessTokenRequest) async throws -> AccessToken {
		try await taskExecutor.performTask(for: request) {
			try await self.updateAccessToken(for: request)
		}
	}
	
	/// Gets new access token from server.
	private func updateAccessToken(for request: AccessTokenRequest) async throws -> AccessToken {
		let authToken = try await updatedAuthToken(for: request)
		
		// Check if current task was not cancelled before saving and returning
		try Task.checkCancellation()
		
		// Store auth token only on `secureStorage` strategy
		if request.persistanceStrategy == .secureStorage {
			authTokenStorage[request.storageKey] = authToken
		}
		
		return authToken.accessToken
	}
	
	// MARK: Auth token
	
	private func updatedAuthToken(for request: AccessTokenRequest) async throws -> AuthToken {
		if let token = try await refreshAuthToken(for: request) { return token }
		return try await renewAuthToken(for: request)
	}
	
	private func refreshAuthToken(for request: AccessTokenRequest) async throws -> AuthToken? {
		guard let refreshToken = authTokenStorage[request.storageKey]?.refreshToken else { return nil }
		
		do {
			return try await renewTokenManager.refreshToken(with: refreshToken)
		} catch let error as AuthErrorProtocol {
			authTokenStorage[request.storageKey]?.refreshToken = nil
			throw error
		} catch {
			throw error
		}
	}
	
	private func renewAuthToken(for request: AccessTokenRequest) async throws -> AuthToken {
		try await renewTokenManager.renewToken(audiences: request.audiences, scopes: request.scopes, idToken: idToken)
	}
	
	// MARK: ID token
	
	/// Gets ID token for renew auth token.
	private var idToken: JWTToken? {
		get async throws {
			// Check if ID token is needed for renew auth token
			guard useIdToken else { return nil }
			
			// Get exist ID token and check expiration
			if let idToken = cachedIdToken, !idToken.isExpired { return idToken }
			
			Log.technical.log(.info, "IdToken is expired. Trying to renew", [.identifier("AccessTokenRepository.idToken.isExpired")])
			
			do {
				let idToken = try await renewIdToken() // Try to renew ID token if expired
				Log.technical.log(.info, "IdToken was successfuly renewed", [.identifier("AccessTokenRepository.idToken.renewSuccess")])
				
				return idToken
			} catch {
				Log.technical.log(.error, "Error while trying to renew idToken token: \(error).", [.identifier("AccessTokenRepository.idToken.renewFailed")])
				
				throw error
			}
		}
	}
	
	// MARK: Reset
	
	/// Reset repository storage and all tasks
	override func reset() async {
		await super.reset()
		await taskExecutor.cancelTasks()
	}
	
}

private extension AccessTokenRequest {
	
	/// Unique identifier based on `audiences` and `scopes`
	var storageKey: String {
		"\(audiences) : \(scopes.map { $0.rawValue })"
	}
	
}
