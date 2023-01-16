//
//  Array-Combinations.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 22/05/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public extension Array {

	/// All the possible combinations of all sizes, without repetition. e.g. `[1,2,3]` will be considered to be the same as `[1,3,2]`.
	var combinations: [[Element]] {
		guard !isEmpty else { return [self] }

		let tail = Array( self[1..<endIndex] )
		let head = self[0]

		let first = tail.combinations
		let rest = first.map { $0 + [head] }

		return first + rest
	}
}
