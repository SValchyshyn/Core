//
//  AuthAPIImplementation.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoreNetworking
import DefaultAppConfiguration
import AuthenticationDomain

public struct AuthAPIImplementation: AuthAPI {
	
	private enum QueryKeys: String {
		case grantType = "grant_type"
		case clientId = "client_id"
		case audience = "audience"
		case codeVerifier = "code_verifier"
		case code = "code"
		case refreshToken = "refresh_token"
		case redirectURI = "redirect_uri"
		case scope = "scope"
		case state = "state"
		case responseType = "response_type"
		case codeChallenge = "code_challenge"
		case codeChallengeMethod = "code_challenge_method"
		case nonce = "nonce"
		case idTokenHint = "id_token_hint"
		case language = "lang"
		case hideHeader = "hideHeader"
		case loginHint = "login_hint"
	}
	
	private enum Constants {
		static let responseType = "code"
		static let codeChallengeMethod = "S256"
		static let grantTypeCode = "authorization_code"
		static let grantTypeRefresh = "refresh_token"
		static let hideHeaderValue = "true"
		static let stateBytesLength = 8
		static let nonceBytesLength = 8
		static let codeVerifierLength = 128
	}
	
	@Injectable private var localeProvider: LocaleProvider
	
	public init() {}
	
	// MARK: Refresh auth token
	
	public func refreshToken(with refreshToken: String) async throws -> AuthToken {
		try await authToken(with: [.refreshToken: refreshToken,
								   .grantType: Constants.grantTypeRefresh])
	}
	
	// MARK: Create auth token
	
	public func renewToken(with authCode: AuthCode) async throws -> AuthToken {
		try await authToken(with: [.code: authCode.code,
								   .codeVerifier: authCode.codeVerifier,
								   .redirectURI: authCode.redirectURI,
								   .grantType: Constants.grantTypeCode])
	}
	
	// MARK: Auth token
	
	private func authToken(with query: [QueryKeys: String]) async throws -> AuthToken {
		let endpoint = AuthEndpoint.token
		
		guard let url = endpoint.completeUrl else {
			throw AuthManagerError.clientSideURLError
		}
		
		var query = query
		query[.clientId] = appConfig.config.oidc.client.clientID
		
		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.POST.rawValue
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = query.map { "\($0.key.rawValue)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
		
		do {
			return try await URLSession.core.execute(request,
													   errorIdentifier: endpoint.errorIdentifier,
													   returning: AuthTokenDTO.self).convertToDO()
		} catch {
			guard case APIError.httpStatusError(_, _, let data?) = error,
				  let authErrorModel = AuthErrorModel.initFrom(data: data) else { throw error }
			
			throw authErrorModel.error
		}
	}
	
	// MARK: Auth config
	
	public func makeAuthConfig(idToken: JWTToken?, scopes: [AuthScope], audiences: [String]) throws -> AuthConfig {
		let redirectURI = appConfig.config.oidc.client.redirectUris.first ?? ""
		let state = String.generateChallengeCode(Constants.stateBytesLength)
		let codeVerifier = String.generateChallengeCode(Constants.codeVerifierLength)
		
		var query: [QueryKeys: String] = [
			.clientId: appConfig.config.oidc.client.clientID,
			.responseType: Constants.responseType,
			.redirectURI: redirectURI,
			.audience: audiences.joined(separator: " "),
			.scope: scopes.map { $0.rawValue }.joined(separator: " "),
			.codeChallenge: codeVerifier.hashSHA256.base64URLEncodedString(),
			.codeChallengeMethod: Constants.codeChallengeMethod,
			.state: state,
			.nonce: .generateChallengeCode(Constants.nonceBytesLength),
			.language: localeProvider.appLocale.languageCode ?? "",
			.hideHeader: Constants.hideHeaderValue]
		
		query[.idTokenHint] = idToken?.rawValue
		
		// Attach to help idp indentify user session.
		let authAdditionalInfo: AuthAdditionalInfoProvider? = ServiceLocator.injectSafe()
		query[.loginHint] = idToken?.userID ?? authAdditionalInfo?.userID
		
		let queryItems = query.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
		guard let authURL = AuthEndpoint.auth.completeUrl?.appendingQueryItems(queryItems) else {
			throw AuthManagerError.clientSideURLError
		}
		
		return AuthConfigImpl(authURL: authURL, redirectURI: redirectURI, codeVerifier: codeVerifier, state: state)
	}
	
	public func silentRenewToken(for authConfig: AuthConfig) async throws -> AuthToken? {
		guard let authCode = try await AuthenticationURLSession(authConfig: authConfig).execute() else { return nil }
		return try await renewToken(with: authCode)
	}
	
}

private extension URL {
	
	func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		components?.queryItems = queryItems
		return components?.url
	}
	
}
