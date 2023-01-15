//
//  String-Extensions.swift
//  Core
//
//  Created by Roman Croitor on 22.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public extension String {
	/**
	Capitalize first letter of string.

	- returns:	String with capitalized first letter
	*/
	func stringWithCapitalizedFirstLetter() -> String {
		let first = self.prefix(1).uppercased()
		let rest = self.dropFirst()
		return first + rest
	}
	
	/// Static number formatter used for price formatting in tracking
	static var analyticsPriceStringFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		return formatter
	}()
	
	func isEmpty() -> Bool {
		return ( self.trimmingCharacters(in: .whitespacesAndNewlines) == "" )
	}
}

public extension Optional where Wrapped == String {
	/// `true` if the wrapped`String` is either `nil` or `isEmpty == true`.
	var isNilOrEmpty: Bool {
		return self?.isEmpty ?? true
	}
}
