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

extension String {
	
	/// Create SHA256 hash of string
	var hashSHA256: Data {
		Data(SHA256(self).digest())
	}
	
	/// Generate one time challenge code for OAuth2 web page
	/// - Returns: Challenge code
	static func generateChallengeCode( _ length: Int ) -> String {
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
	
}

extension Data {
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
