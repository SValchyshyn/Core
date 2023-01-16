//
//  String+Extensions.swift
//  CoopCore
//
//  Created by Andriy Tkach on 12/8/20.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

public extension String {
	
	/// Concatenate the given string `items` with `separator` and with `lastSeparator` between second last and last elements
	static func concatenate(items: [String], separator: String, lastSeparator: String) -> String {
		guard !items.isEmpty else {
			return ""
		}
		
		// remove last element and remember it for later concatetation with `lastSeparator`
		var stringItems = items
		let lastItem = stringItems.removeLast()
		
		guard !stringItems.isEmpty else {
			return lastItem
		}
		
		return stringItems.joined(separator: separator) + lastSeparator + lastItem
	}
}
