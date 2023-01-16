//
//  AuthCode.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 29.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

/// Auth code for two-factor authentication
public struct AuthCode {
	
	public let code: String
	public let codeVerifier: String
	public let redirectURI: String
	
	public init(code: String, codeVerifier: String, redirectURI: String) {
		self.code = code
		self.codeVerifier = codeVerifier
		self.redirectURI = redirectURI
	}
	
}
