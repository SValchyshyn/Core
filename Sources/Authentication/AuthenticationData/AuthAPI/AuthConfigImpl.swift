//
//  AuthConfigImpl.swift
//  AuthenticationData
//
//  Created by Olexandr Belozierov on 29.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core
import DefaultAppConfiguration
import AuthenticationDomain
import RemoteLog

struct AuthConfigImpl: AuthConfig {
	
	let authURL: URL
	private let redirectURI: String
	private let codeVerifier: String
	private let state: String
	
	init(authURL: URL, redirectURI: String, codeVerifier: String, state: String) {
		self.authURL = authURL
		self.redirectURI = redirectURI
		self.codeVerifier = codeVerifier
		self.state = state
	}
	
	// MARK: Callback URL
	
	private enum URLParams {
		static let error = "error"
		static let errorDescription = "error_description"
		static let state = "state"
		static let scope = "scope"
		static let code = "code"
	}

	private enum URLErrorCodes {
		static let userBlocked = "user_blocked"
		static let accessDenied = "access_denied"
	}
	
	func authCode(for callbackURL: URL) -> Result<AuthCode, AuthTokenValidationError>? {
		guard callbackURL.absoluteString.hasPrefix(redirectURI) else { return nil }
		
		if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true) {
			if let error = validateAuth(for: urlComponents) {
				return .failure(error)
			}
			
			if let state = urlComponents.queryValue(for: URLParams.state), state != self.state {
				return .failure(.stateMismatchError)
			}
			
			if let code = urlComponents.queryValue(for: URLParams.code) {
				return .success(AuthCode(code: code, codeVerifier: codeVerifier, redirectURI: redirectURI))
			}
		}
		
		return .failure(.scopesMismatchError)
	}
	
	/// Check if any errors are present in callback URL. Throw `AuthTokenValidationError` if any
	private func validateAuth(for urlComponents: URLComponents) -> AuthTokenValidationError? {
		switch urlComponents.queryValue(for: URLParams.error) {
		case URLErrorCodes.accessDenied:
			return .accessDenied
			
		case URLErrorCodes.userBlocked:
			return .userBlocked
			
		case let error?:
			let description = urlComponents.queryValue(for: URLParams.errorDescription)
			return .authApiError(error, description)
			
		case nil:
			return nil
		}
	}
	
}

private extension URLComponents {
	
	func queryValue(for name: String) -> String? {
		queryItems?.first { $0.name == name }?.value
	}
	
}
