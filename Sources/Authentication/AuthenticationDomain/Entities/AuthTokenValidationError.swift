//
//  AuthTokenValidationError.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 29.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

public enum AuthTokenValidationError: Error {
	case authApiError( String, String? )
	case stateMismatchError
	case scopesMismatchError
	case authCodeMissingError
	case userBlocked
	case accessDenied
}
