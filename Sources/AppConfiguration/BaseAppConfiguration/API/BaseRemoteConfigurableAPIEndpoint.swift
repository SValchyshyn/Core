//
//  BaseRemoteConfigurableAPIEndpoint.swift
//  AppConfiguration
//
//  Created by Coruț Fabrizio on 11.10.2021.
//

import Foundation
import Core
import CoreNetworking

public protocol BaseRemoteConfigurableAPIEndpoint {
	
	/// A key in `AppConfig` with data that belongs to this endpoint.
	var configKey: String { get }
	
	/// Complete `URL`  for this endpoint. Does not require any additional modification.
	var completeUrl: URL? { get }
	
	/// Current `API endpoint base URL` extracted from `AppConfig`.
	var baseUrl: URL? { get }
}

public extension BaseRemoteConfigurableAPIEndpoint {
	
	func timeout( for httpMethod: HTTPMethod ) -> TimeInterval? {
		(ServiceLocator.inject() as AppConfigEndpointProvider)
			.endpoint( for: configKey )?.timeout( for: httpMethod )
	}
}
