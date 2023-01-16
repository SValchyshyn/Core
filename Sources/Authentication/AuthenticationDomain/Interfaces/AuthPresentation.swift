//
//  AuthPresentation.swift
//  AuthenticationDomain
//
//  Created by Ihor Zabrotskyi on 13.12.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public protocol AuthWebActionHandler {
	
	func handleWebAction(with urlRequest: URLRequest) async throws -> AuthToken?
	
}

public protocol AuthUIPresentation {
	
	func authenticate(with authRequest: URLRequest, actionHandler: AuthWebActionHandler) async throws -> AuthToken
	
}
