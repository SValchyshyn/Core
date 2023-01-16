//
//  AuthManagerError.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 28.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

public enum AuthManagerError: Error {
	case authDataMissing
	case refreshTokenNotFound
	case tokenNotFound
	case unavailableToken
	case tokenStorageIsMissing
	case notReachable
	case clientSideURLError
	case clientSideDataMissingError
	case notLoggedIn
	case cancelledByUser
}
