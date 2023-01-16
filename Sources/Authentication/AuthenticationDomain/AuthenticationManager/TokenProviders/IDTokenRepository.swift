//
//  IDTokenRepository.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 30.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

/// Manager for providing ID token.
class IDTokenRepository {
	
	private enum Constant {
		/// Main auth token key for `KeychainManager`
		static let storageKey = "parentTokenKey"
		
		/// Scope for receiving `idToken` field in auth token
		static let idTokenScope: AuthScope = "openid"
	}
	
	private enum TaskKey: Hashable {
		case idToken
	}
	
	/// Storage for auth tokens.
	let authTokenStorage: AuthTokenStorage
	
	/// Auth token updater.
	let renewTokenManager = RenewAuthTokenManager()
	
	/// ID token update task
	private let taskExecutor = UniqueTaskExecutor<TaskKey, JWTToken>()
	
	init(authTokenStorage: AuthTokenStorage) {
		self.authTokenStorage = authTokenStorage
	}
	
	// MARK: JWTToken
	
	/// Gets ID token from storage.
	var cachedIdToken: JWTToken? {
		authTokenStorage[Constant.storageKey]?.idToken
	}
	
	/// Gets new ID token from server.
	@discardableResult func renewIdToken() async throws -> JWTToken {
		try await taskExecutor.performTask(for: .idToken, operation: updateIdToken)
	}
	
	/// Gets new ID token from server.
	private func updateIdToken() async throws -> JWTToken {
		let authToken = try await updatedAuthToken()
		
		// `idToken` is required for main auth token
		guard let idToken = authToken.idToken else {
			throw AuthManagerError.unavailableToken
		}
		
		// Check if current task was not cancelled before saving and returning
		try Task.checkCancellation()
		
		// Save new token
		authTokenStorage[Constant.storageKey] = authToken
		
		return idToken
	}
	
	// MARK: Auth token
	
	/// Gets new auth token from server.
	private func updatedAuthToken() async throws -> AuthToken {
		if let authToken = try await refreshAuthToken() { return authToken }
		return try await renewAuthToken()
	}
	
	/// Gets new auth token from server based on refresh token.
	private func refreshAuthToken() async throws -> AuthToken? {
		guard let refreshToken = authTokenStorage[Constant.storageKey]?.refreshToken else { return nil }
		
		do {
			return try await renewTokenManager.refreshToken(with: refreshToken)
		} catch let error as AuthErrorProtocol {
			authTokenStorage[Constant.storageKey]?.refreshToken = nil
			throw error
		} catch {
			throw error
		}
	}
	
	/// Gets new auth token from server based on audiences and scopes.
	private func renewAuthToken() async throws -> AuthToken {
		try await renewTokenManager.renewToken(audiences: [], scopes: [.useRefreshToken, Constant.idTokenScope])
	}
	
	// MARK: Reset
	
	/// Reset repository storage and all tasks
	func reset() async {
		await taskExecutor.cancelTasks()
	}
	
}
