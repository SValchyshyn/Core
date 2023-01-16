//
//  StoresAPIEndpoint.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 26.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import AuthenticationDomain
import DefaultAppConfiguration

enum StoresAPIEndpoint: RemoteConfigurableAPIEndpoint {
	case stores
	case store(storeId: String)
	case chains
	case chain(chainId: String)
	
	var configKey: String {
		return "store"
	}
	
	var completeUrl: URL? {
		guard let baseUrl = baseUrl, var components = URLComponents( url: baseUrl, resolvingAgainstBaseURL: true ) else {
			return nil
		}
		
		components.path.append({ () -> String in
			switch self {
			case .stores:
				return "v3/stores"
				
			case .store(let storeId):
				return "v3/stores/\(storeId)"
				
			case .chains:
				return "v3/chains"
				
			case .chain(let chainId):
				return "v3/chains/\(chainId)"
			}
		}())
		
		return components.url
	}
	
	var requiredScopes: [AuthScope] {
		// No specific scopes required. Use parent token
		return [ .useRefreshToken ]
	}
	
	var errorIdentifier: String {
		switch self {
		case .stores:
			return "storeData.stores"
			
		case .store:
			return "storeData.store"
			
		case .chains:
			return "chainData.chains"
			
		case .chain:
			return "chainData.chain"
		}
	}
}
