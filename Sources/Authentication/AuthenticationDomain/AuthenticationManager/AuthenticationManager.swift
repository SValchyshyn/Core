//
//  AuthenticationManager.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import RemoteLog
import DefaultAppConfiguration

public typealias AuthScope = DefaultAppConfiguration.AuthScope
public typealias AccessTokenRequest = DefaultAppConfiguration.AccessTokenRequest

public struct AuthenticationManager {
	
	public struct Notifications {
		public static let userWillLogOut = Notification.Name("platformUserWillLogOutNotification")
		public static let userLoggedOut = Notification.Name("platformUserLoggedOutNotification")

		/// Notification user info key to indicate whether user was forced to log out
		public static let isForcedKey = "isForced"
	}
	
	/// Storage for auth tokens
	private let authTokenStorage: AuthTokenStorage
	
	/// Provides and updates tokens.
	private let repository: AccessTokenRepository
	
	/// Manager for web cookies.
	@Injectable private var cookiesManager: CookiesManager
	
	public init(authTokenStorage: AuthTokenStorage, useIdToken: Bool = true) {
		self.authTokenStorage = authTokenStorage
		repository = AccessTokenRepository(authTokenStorage: authTokenStorage, useIdToken: useIdToken)
	}
	
	// MARK: Authentication
	
	/// Get current user ID if present
	public var userID: String? {
		repository.cachedIdToken?.userID
	}
	
	/// Checks if user is logged in.
	public var userIsAuthenticated: Bool {
		// Verify that the user is authenticating by checking if he has at least one auth token in storage or cookies in cookiesManager(KNB and CoopDK case when we don't have a parent token for platform auth)
		!authTokenStorage.isEmpty || !cookiesManager.isEmpty
	}
	
	public func authenticate() async throws {
		try await repository.renewIdToken() // Force renew id token
	}
	
	// MARK: Log out
	
	/// - Parameter isForced: Flag to indicate whether user was forced to log out
	public func handleLogOut(isForced: Bool = false) {
		Task { await _handleLogOut(isForced: isForced) }
	}
	
	@MainActor private func _handleLogOut(isForced: Bool) async {
		// userInfo for notification
		let userInfo = [Notifications.isForcedKey: isForced]

		// Post will log-out notification to be handled by the app delegate
		NotificationCenter.default.post(name: Notifications.userWillLogOut, object: nil, userInfo: userInfo)
		
		// Cancell all updating tasks
		await repository.reset()
		
		// Clear auth token storage
		authTokenStorage.removeAll()
		
		// Clear web coockies to prevet auto login
		cookiesManager.clearCookies()

		// Post logged-out notification to be handled by the app delegate
		NotificationCenter.default.post(name: Notifications.userLoggedOut, object: nil, userInfo: userInfo)
	}
	
	// MARK: Access token
	
	/// Tries to get cached access token, otherwise get new token.
	public func accessToken(for request: AccessTokenRequest) async throws -> String {
		if let token = cachedAccessToken(for: request) { return token }
		return try await renewAccessToken(for: request)
	}
	
	/// Returns access token from cahce.
	public func cachedAccessToken(for request: AccessTokenRequest) -> String? {
		repository.cachedAccessToken(for: request)
	}
	
	/// Returns new access token by refreshing existed or by getting new one.
	public func renewAccessToken(for request: AccessTokenRequest) async throws -> String {
		guard userIsAuthenticated else { throw AuthManagerError.notLoggedIn }
		
		do {
			return try await repository.renewAccessToken(for: request)
		} catch {
			if case AuthTokenValidationError.userBlocked = error {
				await _handleLogOut(isForced: true)
			}
			
			throw error
		}
	}
	
}
