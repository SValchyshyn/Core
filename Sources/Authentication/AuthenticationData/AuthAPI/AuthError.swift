//
//  AuthError.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 04.10.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation
import AuthenticationDomain

public enum AuthError: String, Error, Decodable, AuthErrorProtocol {
	case invalidGrand = "invalid_grant"
	case invalidRequest = "invalid_request"
	case tokenInactive = "token_inactive"
	
	public var description: String {
		rawValue
	}
}

public struct AuthErrorModel: Decodable {
	public var error: AuthError
	public var errorDescription: String
	
	enum CodingKeys: String, CodingKey {
		case error
		case errorDescription = "error_description"
	}
	
	public static func initFrom( data: Data ) -> AuthErrorModel? {
		let decoder = JSONDecoder()
		return try? decoder.decode( self, from: data )
	}
}
