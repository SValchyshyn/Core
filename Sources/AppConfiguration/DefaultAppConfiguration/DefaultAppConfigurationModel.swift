//
//  DefaultAppConfiguration.swift
//  DefaultAppConfiguration
//
//  Created by Georgi Damyanov on 26/04/2021.
//

import Foundation
import Core
import BaseAppConfiguration

/**
The configuration format of the configuration data
*/

public struct DefaultAppConfigurationModel: AppConfigurationProviding {
	
	public static let configFileName = CoreConfiguration.appConfigDefaultFileName
	
	enum CodingKeys: String, CodingKey {
		case oidc = "oidc"
		case endpoints = "endpoints"
		case empty = ""
	}
	
	public let oidc: Oidc
	public let endpoints: [String: Endpoint]
	public var appSpecificConfig: [String: Data] = [:]
	
	public mutating func setAppSpecificConfig(_ value: Data?, forKey key: String) {
		appSpecificConfig[key] = value
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.oidc = try container.decode(Oidc.self, forKey: .oidc)
		self.endpoints = try container.decode([String: Endpoint].self, forKey: .endpoints)
		self.appSpecificConfig = try container.decodeIfPresent([String: Data].self, forKey: .empty) ?? [:]
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(oidc, forKey: .oidc)
		try container.encode(endpoints, forKey: .endpoints)
		try container.encode(appSpecificConfig, forKey: .empty)
	}
}
