//
//  RemoteConfigurableAPIEndpoint.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 02.10.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import BaseAppConfiguration

/// How to treat newly obtained token
public enum TokenPersistanceStrategy {
	/// Store in Keychain
	case secureStorage
	/// Do not store anywhere
	case oneTime
}

public struct AuthScope: RawRepresentable, ExpressibleByStringInterpolation, Hashable, Comparable {
	
	public static func < (lhs: AuthScope, rhs: AuthScope) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
	
	/// Scope for using refresh token for renew auth token
	public static let useRefreshToken: Self = "offline_access"
	
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
	
	public init(stringLiteral value: String) {
		rawValue = value
	}
	
}

public struct AccessTokenRequest: Hashable {
	
	public let audiences: [String]
	public let scopes: [AuthScope]
	public let persistanceStrategy: TokenPersistanceStrategy
	
	public init(audiences: [String], scopes: [AuthScope], persistanceStrategy: TokenPersistanceStrategy) {
		self.audiences = audiences.sorted()
		self.scopes = scopes.sorted()
		self.persistanceStrategy = persistanceStrategy
	}
	
}

public protocol RemoteConfigurableAPIEndpoint: BaseRemoteConfigurableAPIEndpoint {
	/// List of required scopes auth token should have in order to authorise API call
	var requiredScopes: [AuthScope] { get }
	/// Defines which TokenPersistanceStrategy should be applied when storing newly creting token
	func getTokenPersistanceStrategy() -> TokenPersistanceStrategy
	/// List of required audiences auth token should have in order to authorise API call
	func getRequiredAudiences() -> [String]
}

public extension RemoteConfigurableAPIEndpoint {
	
	// Get the API base url from AppConfig by appending slash to the end if missing
	var baseUrl: URL? {
		guard var baseUrl = appConfig.config.endpoints[ configKey ]?.baseUrl else {
			return nil
		}

		if baseUrl.last != "/" {
			// Append the slash in the end if missing
			baseUrl.append("/")
		}

		return URL( string: baseUrl )
	}
	
	func getTokenPersistanceStrategy() -> TokenPersistanceStrategy {
		// CoopStore tokens in secure storage by default
		return .secureStorage
	}
	
	func getRequiredAudiences() -> [String] {
		appConfig.config.endpoints[ configKey ]?.auth?.audiences ?? []
	}
	
	var tokenRequest: AccessTokenRequest {
		AccessTokenRequest(audiences: getRequiredAudiences(),
						 scopes: requiredScopes,
						 persistanceStrategy: getTokenPersistanceStrategy())
	}
	
}
