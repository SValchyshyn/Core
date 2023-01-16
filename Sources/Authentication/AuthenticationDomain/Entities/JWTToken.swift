//
//  JWTToken.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 29.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Log

public struct JWTToken {
	
	private struct WebTokenPayload: Decodable {
		
		let userId: String?
		let expiration: Int64?
		
		private enum CodingKeys: String, CodingKey {
			case userId
			case expiration = "exp"
		}
		
	}
	
	private enum TokenDecodeErrors: Error {
		case badToken, other
	}
	
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
	
	// MARK: User ID
	
	public var userID: String? {
		// Try extracting `userId` from provided `idToken`.
		do {
			return try tokenData()?.userId
		} catch let error {
			// TODO: Stop logging jwt once this error stop occuring on regular basis -SV
			Log.technical.log(.error, "Failed to parse jwt token for userId with error: \(error), jwt token: \(rawValue)", [.identifier("AuthUtils.extractUserId")])
			return nil
		}
	}
	
	// MARK: Expire date
	
	public var isExpired: Bool {
		guard let expiration = expiration.map(TimeInterval.init) else { return false }
		
		let now = Date().timeIntervalSince1970
		let validFor = expiration - Date().timeIntervalSince1970
		let isExpired = validFor < 0
		Log.technical.log(.info, "Token exp: \(expiration), now: \(now), validFor: \(validFor), isExpired: \(isExpired)", [.identifier("AuthUtils.isExpired")])
		return isExpired
	}
	
	private var expiration: Int64? {
		// Try extracting `expiration` from provided `idToken`.
		do {
			return try tokenData()?.expiration
		} catch let error {
			// TODO: Stop logging jwt once this error stop occuring on regular basis -SV
			Log.technical.log(.error, "Failed to parse jwt token for expiration with error: \(error), jwt token: \(rawValue)", [.identifier("AuthUtils.extractExpiration")])
			return nil
		}
	}
	
	// MARK: Token data
	
	/// Try to decode jwt token data. Returns `userId` if found.
	private func tokenData() throws -> WebTokenPayload? {
		func base64Decode(_ base64: String) throws -> Data {
			let base64 = base64
				.replacingOccurrences(of: "-", with: "+")
				.replacingOccurrences(of: "_", with: "/")
			let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
			guard let decoded = Data(base64Encoded: padded) else {
				throw TokenDecodeErrors.badToken
			}
			return decoded
		}

		func decodeJWTPart(_ value: String) throws -> WebTokenPayload {
			let bodyData = try base64Decode(value)
			return try JSONDecoder().decode( WebTokenPayload.self, from: bodyData )
		}

		let segments = rawValue.components(separatedBy: ".")
		// Decode payload by dropping header part.
		return try decodeJWTPart( segments[1] )
	}
	
}
