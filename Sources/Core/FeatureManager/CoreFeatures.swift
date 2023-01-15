//
//  CoreFeatures.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 29.05.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/**
Enum containing all the features required by Core module
*/
public enum CoreFeatures: Feature {
	/// Use mock data for all mockable endpoints (see MockResponseProvider).
	case mockData
	
	public var identifier: String {
		switch self {
		case .mockData: return "mock_data"
		}
	}
}
