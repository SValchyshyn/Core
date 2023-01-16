//
//  AuthTokenStorage.swift
//  AuthenticationDomain
//
//  Created by Ihor Zabrotskyi on 08.12.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

public protocol AuthTokenStorage {
	
	subscript(tokenKey: String) -> AuthToken? { get nonmutating set }
	
	var isEmpty: Bool { get }
	
	func removeAll()
	
}
