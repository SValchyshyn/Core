//
//  AuthenticationFeature.swift
//  Authentication
//
//  Created by Ihor Zabrotskyi on 23.11.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation
import Core

public enum AuthenticationFeature: Feature {
	/// Loyalty Card Scanner
	case loyaltyCardScanner
	
	public var identifier: String {
		switch self {
		case .loyaltyCardScanner: return "loyalty_card_scanner"
		}
	}
}
