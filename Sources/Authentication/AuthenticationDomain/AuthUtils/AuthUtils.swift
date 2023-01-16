//
//  AuthUtils.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoopCore
import Log

public final class AuthUtils {
	public enum Constants {
		/// Length of random bytes for state
		public static let stateBytesLength = 8
		
		/// Length of random bytes for nonce
		public static let nonceBytesLength = 8
		
		/// Length of random bytes for nonce
		public static let codeVerifierLength = 128
	}
	
	public enum TokenDecodeErrors: Error {
		case badToken
		case other
	}
	
	public struct WebTokenPayload: Decodable {
		var userId: String?
		var expiration: Int64?
		
		private enum CodingKeys: String, CodingKey {
			case userId
			case expiration = "exp"
		}
	}
	
	public static func extractUserId( idToken: String ) -> String? {
		// Try extracting `userId` from provided `idToken`.
		do {
			return try AuthUtils.extractTokenData( token: idToken )?.userId
		} catch let error {
			// TODO: Stop logging jwt once this error stop occuring on regular basis -SV
			Log.technical.log(.error, "Failed to parse jwt token for userId with error: \(error), jwt token: \(idToken)", [.identifier("AuthUtils.extractUserId")])
			return nil
		}
	}
	
	public static func extractExpiration( idToken: String ) -> Int64? {
		// Try extracting `expiration` from provided `idToken`.
		do {
			return try AuthUtils.extractTokenData( token: idToken )?.expiration
		} catch let error {
			// TODO: Stop logging jwt once this error stop occuring on regular basis -SV
			Log.technical.log(.error, "Failed to parse jwt token for expiration with error: \(error), jwt token: \(idToken)", [.identifier("AuthUtils.extractExpiration")])
			return nil
		}
	}
	
	public static func isExpired( idToken: String ) -> Bool {
		guard let expiration = AuthUtils.extractExpiration( idToken: idToken ) else {
			return false
		}
		
		let now = NSDate().timeIntervalSince1970
		let validFor = TimeInterval( expiration ) - now
		let isExpired = validFor < 0
		Log.technical.log(.info, "Token exp: \(expiration), now: \(now), validFor: \(validFor), isExpired: \(isExpired)", [.identifier("AuthUtils.isExpired")])
		return isExpired
	}
	
	/// Try to decode jwt token data. Returns `userId` if found.
	private static func extractTokenData( token: String ) throws -> WebTokenPayload? {
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
			let dataModel = try JSONDecoder().decode( WebTokenPayload.self, from: bodyData )
			
			return dataModel
		}

		let segments = token.components(separatedBy: ".")
		// Decode payload by dropping header part.
		return try decodeJWTPart( segments[1] )
	}
	
	/**
	Generate one time challenge code for OAuth2 web page

	- returns: Challenge code
	*/
	public static func generateChallengeCode( _ length: Int ) -> String {
		// Valid characters for challenge code
		let characters = Array( "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~" )

		// Generate random string of valid characters
		var challengeCode = ""
		while challengeCode.count < length {
			let index = Int.random( in: 0..<characters.count )
			let character = characters[ index ]
			challengeCode.append( character )
		}
		return challengeCode
	}
	
	/**
	Generate a "high-entropy cryptographic random string"

	- parameter length:	Number of bytes to generate. Defaults to 32.
	- returns: A **url-base64** encoded string containing the random data if the operation was successful. Returns nil if an error occurred.
	*/
	public static func generateRandomBytesString(_ length: Int = 32 ) -> String? {
		var keyData = Data( count: length )
		let result = keyData.withUnsafeMutableBytes {
			SecRandomCopyBytes( kSecRandomDefault, length, $0.baseAddress! )	// Explicit unwrap, `baseAddress` cannot be `nil` when the data is not empty -GKD
		}
		if result == errSecSuccess {
			return keyData.base64URLEncodedString()	// Use url-base64 encoding
		} else {
			Log.technical.log(.error, "Error generating random bytes", [.identifier("Authentication.AuthUtils.generateRandomBytesString")])
			return nil
		}
	}
	
	/**
	Create SHA256 hash of string

	- parameter string:	String to be hashed
	- returns:			Hashed string as Data
	*/
	public static func hashSHA256(_ string: String ) -> Data {
		let sha256 = SHA256( string )
		return Data( sha256.digest())
	}
}

public extension Data {
	/**
	Base64 and URL encode data

	- parameter data:	Data to be encoded
	- returns: Encoded data
	*/
	func base64URLEncodedString() -> String {
		// Base64 encode data
		var result = self.base64EncodedString()

		// Special URL encoding (https://tools.ietf.org/html/rfc7636)
		result = String( result.split( separator: "=" ).first ?? Substring())	// Remove any trailing "="
		result = result.replacingOccurrences( of: "+", with: "-" )				// Replace "+"
		result = result.replacingOccurrences( of: "/", with: "_" )				// Replace "/"

		return result
	}
}
