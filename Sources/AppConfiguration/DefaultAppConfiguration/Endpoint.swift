//
//  Endpoint.swift
//  CoopCore
//
//  Created by Marian Hunchak on 24.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import BaseAppConfiguration

public struct Endpoint: Codable, AppConfigEndpointRepresentation {
	public let baseUrl: String
	public let auth: Auth?
	public let readTimeout: TimeInterval?
	public let writeTimeout: TimeInterval?
}

public struct Auth: Codable {
	public let type: String
	public let audiences: [String]
}
