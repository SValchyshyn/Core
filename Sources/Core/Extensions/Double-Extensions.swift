//
//  Double-Extensions.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 06.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public extension Double {

	/// Returns formatted price string that can be used for analytics tracking.
	var analyticsPriceString: String? {
		String.analyticsPriceStringFormatter.string(from: NSNumber(value: self))
	}

}
