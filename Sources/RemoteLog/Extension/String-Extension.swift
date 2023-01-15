//
//  String-Extension.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 24.03.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension String {
	/// Extract groups from String using regular expression.
	///
	/// - parameter pattern: regular expression
	/// - returns extracted group contents
	func capturedGroups(withRegex pattern: String) -> [String] {
		// setup regex
		var regex: NSRegularExpression
		do {
			regex = try NSRegularExpression(pattern: pattern, options: [])
		} catch {
			return []
		}
		
		// extract groups
		let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
		guard let match = matches.first else { return [] }
		
		let lastRangeIndex = match.numberOfRanges - 1
		guard lastRangeIndex >= 1 else { return [] }
		
		// ouput group contents
		var results: [String] = []
		for i in 1...lastRangeIndex {
			let capturedGroupIndex = match.range(at: i)
			let matchedString = (self as NSString).substring(with: capturedGroupIndex)
			results.append(matchedString)
		}
		
		return results
	}
}
