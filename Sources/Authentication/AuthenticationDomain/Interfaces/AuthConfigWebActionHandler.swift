//
//  AuthConfigWebActionHandler.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 27.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core

extension AuthUIPresentation {
	
	func renewToken(authConfig: AuthConfig) async throws -> AuthToken {
		let urlRequest = URLRequest(url: authConfig.authURL)
		let actionHandler = AuthConfigWebActionHandler(authConfig: authConfig)
		return try await authenticate(with: urlRequest, actionHandler: actionHandler)
	}
	
}

/// `AuthWebActionHandler` implementation for `AuthConfig`.
private struct AuthConfigWebActionHandler: AuthWebActionHandler {
	
	let authConfig: AuthConfig
	@Injectable private var authAPI: AuthAPI

	func handleWebAction(with urlRequest: URLRequest) async throws -> AuthToken? {
		guard let authCode = try urlRequest.url.flatMap(authConfig.authCode)?.get() else { return nil }
		return try await authAPI.renewToken(with: authCode)
	}
	
}
