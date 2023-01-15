//
//  APIError.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 20/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public enum APIError: Error, CustomStringConvertible {
	/** Unable to convert password data to a UTF-8 string */
	case unableToConvertData

	/** The API call requires a user to be logged in */
	case noLoggedInUser

	/// Invalid JSON. Cannot parse as the expected object.
	case invalidJSON( message: String? )

	/// 401 Unauthorized received
	case unauthorized

	/// 403 Forbidden received
	case forbidden

	/// Token expired, but we haven't tried to reauthorize yet
	case tokenExpired

	/// The Internet is not reachable
	case notReachable

	/// Network error while making the request
	case networkError( Error )

	/// Other HTTP status code >= 400
	case httpStatusError( statusCode: Int, errorString: String?, payload: Data? )

	case invalidURL( urlString: String? )
	case invalidPOSTString
	case invalidResponse
	case missingRequestInfo
	case failedCoreDataDelete
	case failedCoreDateSave
	case missingDataElement

	// PIN Code is not set
	case pinCodeNotSet

	public var description: String {
		switch self {
		case .invalidJSON( let message ): return "invalidJSON(message: \(message ?? ""))"
		case .httpStatusError( let statusCode, let errorString, _ ): return "httpStatusError( statusCode: \(statusCode), errorString: \(errorString ?? "") )"
		case .invalidURL( let urlString ): return "invalidURL( urlString: \(urlString ?? ""))"
		case .unableToConvertData: return "unableToConvertData"
		case .noLoggedInUser: return "noLoggedInUser"
		case .unauthorized: return "unauthorized"
		case .forbidden: return "forbidden"
		case .tokenExpired: return "tokenExpired"
		case .notReachable: return "notReachable"
		case .networkError( let error): return "networkError(\(error))"
		case .invalidPOSTString: return "invalidPOSTString"
		case .invalidResponse: return "invalidResponse"
		case .missingRequestInfo: return "missingRequestInfo"
		case .failedCoreDataDelete: return "failedCoreDataDelete"
		case .failedCoreDateSave: return "failedCoreDateSave"
		case .missingDataElement: return "missingDataElement"
		case .pinCodeNotSet: return "pinCodeNotSet"
		}
	}
	
	public enum HTTPStatusCode: Int {
		case internalServerError = 500
	}
	
	/// Error status code.
	public var httpStatusCode: Int? {
		guard case let .httpStatusError( statusCode, _, _ ) = self else {
			return nil
		}
		
		return statusCode
	}
	
	/// Check if APIError matches status code error.
	/// - Parameter errorCode: `HTTPStatusCode` object.
	/// - Returns: `Bool` object. `true` if `error` matches `APIErrorHTTPStatusCode`.
	 public func matches( _ errorCode: HTTPStatusCode ) -> Bool {
		guard let statusCode = httpStatusCode else {
			return false
		}
		
		return statusCode == errorCode.rawValue
	}
}
