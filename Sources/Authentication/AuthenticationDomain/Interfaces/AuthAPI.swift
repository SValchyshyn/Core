//
//  AuthAPI.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

public protocol AuthErrorProtocol: Error, CustomStringConvertible {}

public protocol AuthAPI {
	
	// MARK: Refresh auth token
	
	func refreshToken(with refreshToken: String) async throws -> AuthToken
	
	// MARK: Renew auth token
	
	func makeAuthConfig(idToken: JWTToken?, scopes: [AuthScope], audiences: [String]) throws -> AuthConfig
	
	func silentRenewToken(for authConfig: AuthConfig) async throws -> AuthToken?
	
	func renewToken(with authCode: AuthCode) async throws -> AuthToken
	
}
