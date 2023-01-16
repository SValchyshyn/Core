//
//  RenewAuthTokenManager.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 28.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Core
import Log

/// Wrapper for `AuthAPI` and `AuthUIRenewManager` with common functionality.
struct RenewAuthTokenManager {
	
	@Injectable private var authAPI: AuthAPI
	
	// MARK: Refresh token
	
	func refreshToken(with refreshToken: String) async throws -> AuthToken {
		do {
			return try await authAPI.refreshToken(with: refreshToken)
		} catch {
			if let authError = error as? AuthErrorProtocol {
				// Log second part of refresh token which is safe to be shared.
				let refreshTokenFootprint = refreshToken.split(separator: ".")[1]
				Log.technical.log(.notice, "Failed to refresh token, refresh token footprint: \(refreshTokenFootprint) with an error: \(authError.description)", [.identifier("RenewAuthTokenManager.refreshToken")])
			}

			throw error
		}
	}
	
	// MARK: Renew token
	
	func renewToken(audiences: [String], scopes: [AuthScope], idToken: JWTToken? = nil) async throws -> AuthToken {
		let authConfig = try authAPI.makeAuthConfig(idToken: idToken, scopes: scopes, audiences: audiences)
		
		while true {
			// Check cancellation before continuation
			try Task.checkCancellation()
			
			// Silent flow without extra UI verification
			if let authToken = try await authAPI.silentRenewToken(for: authConfig) {
				return authToken
			}
			
			// Try to renew token with UI flow.
			switch try await AuthUIRenewManager.shared.renewToken(wuth: authConfig) {
			case .authToken(let authToken):
				return authToken
				
			case .cookiesUpdated:
				continue // Restart auth config flow with new coockies
			}
		}
	}
	
}
