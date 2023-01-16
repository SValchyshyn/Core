//
//  AppConfigEndpoint.swift
//  AppConfig
//
//  Created by Marian Hunchak on 11.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import CoreNetworking

enum AppConfigEndpoint {
	case latestConfig
	
	var httpMethod: HTTPMethod {
		return .GET
	}
	
	var path: String {
		return "appconfig/v1/AppConfiguration"
	}
	
	var errorIdentifier: String {
		switch self {
		case .latestConfig:
			return "appConfig.getlatestConfig"
		}
	}
}
