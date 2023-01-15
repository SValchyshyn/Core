//
//  Array-Extensions.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 08/06/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
	
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()

		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}

	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}

public extension Array {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Iterator.Element? {
		return indices.contains(index) ? self[index] : nil
	}

	/// Counts the number of elements matching the predicate.
	///
	/// - Parameter predicate: The predicate to match for
	/// - Returns: The number of elements matching the predicate
	func count( where predicate: (Element) -> Bool ) -> Int {
		return filter( predicate ).count
	}
}
