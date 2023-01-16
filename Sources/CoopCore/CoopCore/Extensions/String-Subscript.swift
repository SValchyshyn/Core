//
// Created by Roland Leth on 26/08/2019.
// Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension String {

	/// Returns a `Character` at the passed in index.
	subscript(i: Int) -> Character {
		return self[index(startIndex, offsetBy: i)]
	}

	/// Returns a `String` out of a `Range<Int`.
	subscript(range: Range<Int>) -> String {
		let range = index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)
		return String(self[range])
	}

	/// Returns a `String` out of an `NSRange`.
	subscript(range: NSRange) -> String {
		let end = range.location + range.length

		return self[range.location..<end]
	}

}
