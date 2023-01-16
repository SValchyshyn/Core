//
//  AuthEndpoint.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import DefaultAppConfiguration
import AuthenticationDomain

enum AuthEndpoint: RemoteConfigurableAPIEndpoint {
	case auth
	case token
	
	var configKey: String {
		// Not provided for Auth feature
		return ""
	}
	
	var baseUrl: URL? {
		// Not provided for Auth feature
		return nil
	}
	
	var completeUrl: URL? {
		switch self {
		case .auth:
			return URL( string: appConfig.config.oidc.configuration.authorizationEndpoint )

		case .token:
			return URL( string: appConfig.config.oidc.configuration.tokenEndpoint )
		}
	}
	
	var requiredScopes: [AuthScope] {
		return [ .useRefreshToken ]
	}
	
	func getRequiredAudiences() -> [String] {
		return [""]
	}
	
	var errorIdentifier: String {
		switch self {
		case .auth:
			return "auth.authCode"
			
		case .token:
			return "auth.token"
		}
	}
}
