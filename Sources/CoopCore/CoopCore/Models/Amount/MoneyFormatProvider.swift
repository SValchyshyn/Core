//
//  MoneyFormatProvider.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 24.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

// public enum MoneyFormatSymbolGravity {
//	case top
//	case bottom
//	case left
//	case right
// }

public protocol MoneyFormatProvider {
//	var symbolGravity: MoneyFormatSymbolGravity { get }
	
	/// Return text representation of `AmountUI`. Combines `value` and `currency` visualy representable way.
	func format(amount: AmountUI) -> String
}
