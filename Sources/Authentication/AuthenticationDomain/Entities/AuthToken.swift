//
//  AuthToken.swift
//  AuthenticationDomain
//
//  Created by Ihor Zabrotskyi on 08.12.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

// Domain model
public struct AuthToken {
	
	public let accessToken: String
	public let idToken: JWTToken?
	public let expiresIn: Int?
	public var refreshToken: String?
	public let tokenGrantedTimestamp: Date
	
	public init(accessToken: String, idToken: String?, expiresIn: Int?, refreshToken: String?, tokenGrantedTimestamp: Date) {
		self.accessToken = accessToken
		self.idToken = idToken.map(JWTToken.init)
		self.expiresIn = expiresIn
		self.refreshToken = refreshToken
		self.tokenGrantedTimestamp = tokenGrantedTimestamp
	}
	
	var isExpired: Bool {
		guard let expiresIn = expiresIn.map(TimeInterval.init) else { return true }
		return Date() > tokenGrantedTimestamp.addingTimeInterval(expiresIn)
	}
	
}
