//
//  Oidc.swift
//  CoopCore
//
//  Created by Marian Hunchak on 24.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public struct Oidc: Codable {
	public let configuration: OidcConfiguration
	public let client: Client
}

public struct OidcConfiguration: Codable {
	public let issuer: String
	public let authorizationEndpoint: String
	public let tokenEndpoint: String
}

public struct Client: Codable {
	public let clientID: String
	public let redirectUris: [String]

	enum CodingKeys: String, CodingKey {
		case clientID = "clientId"
		case redirectUris
	}
}
