//
//  FeatureStatus.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public enum FeatureStatus: String {
	/// The feature is on
	case enabled = "on"

	/// The feature is enabled, but with a different behaviour than the usual one. For example, if top up is `restricted`, we show the blob saying "become a regular user to enable top up"
	case restricted

	/// The feature is disabled
	case disabled = "off"
	
	/// Computed utility variable for checking whether the feature is enabled
	public var isEnabled: Bool {
		switch self {
		case .enabled:
			return true

		case .restricted, .disabled:
			return false
		}
	}
}
