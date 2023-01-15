//
//  Error-Extensions.swift
//  CoopCore
//
//  Created by Frederik Sørensen on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension Error {
	/// Computed variable checking if this is a network error
	var isNetworkError: Bool {
		if self is URLError {
			return true
		}

		// Check if this is an APIError
		guard let apiError = self as? APIError else {
			return false
		}

		switch apiError {
		case let .networkError( networkError ) where networkError is URLError:
			// Network error
			return true

		case .notReachable:
			// No internet connection is handled as network error
			return true

		default:
			return false
		}
	}

	/// Computed variable checking if the error is retryable. Currently network errors and HTTP status errors (except 401) are considered retryable
	var isRetryable: Bool {
		guard let apiError = self as? APIError else {
			// Currently only API errors are considered retryable
			return false
		}

		switch apiError {
		case .httpStatusError( let statusCode, _, _ ):
			if statusCode != 401 {
				return true
			} else {
				// We don't want to retry authentication errors
				return false
			}

		case .networkError, .notReachable:
			return true

		case .unableToConvertData, .noLoggedInUser, .invalidJSON, .unauthorized, .forbidden, .tokenExpired, .invalidURL, .invalidPOSTString, .invalidResponse, .missingRequestInfo, .failedCoreDataDelete, .failedCoreDateSave, .missingDataElement, .pinCodeNotSet:
			return false
		}
	}
}
