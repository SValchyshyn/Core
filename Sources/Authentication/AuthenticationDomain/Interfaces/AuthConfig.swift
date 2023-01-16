//
//  AuthConfig.swift
//  AuthenticationDomain
//
//  Created by Ihor Zabrotskyi on 08.12.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public protocol AuthConfig {
	
	var authURL: URL { get }
	
	func authCode(for callbackURL: URL) -> Result<AuthCode, AuthTokenValidationError>?
	
}
