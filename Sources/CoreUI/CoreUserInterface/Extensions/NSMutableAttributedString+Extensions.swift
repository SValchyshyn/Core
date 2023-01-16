//
//  NSMutableAttributedString+Extensions.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 05/02/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

public extension NSMutableAttributedString {
	/**
	Adds attributes for all occurrences of the given substring.
	*/
	func add(_ attributes: [NSAttributedString.Key: Any], for substring: String) {
		let stringLength = string.count
		let substringLength = substring.count
		var range = NSRange(location: 0, length: length)

		while range.location != NSNotFound {
			// Cast to NSString as we want range to be of type NSRange, not Swift's Range<Index>
			range = (string as NSString).range(of: substring, options: [], range: range)

			// If there is a valid range for a substring, apply font attribute to it.
			if range.location != NSNotFound {
				addAttributes(attributes, range: NSRange(location: range.location, length: substringLength))
				range = NSRange(location: range.location + range.length, length: stringLength - (range.location + range.length))
			}
		}
	}
}
