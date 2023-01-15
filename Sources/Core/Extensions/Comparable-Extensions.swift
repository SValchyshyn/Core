//
//  Comparable-Extensions.swift
//  Core
//
//  Created by Roman Croitor on 04.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

public extension Comparable {
	/**
	Clamps the value to the specified low and high values.

	- parameter low: minimum value
	- parameter high: maximum value
	- returns: the value clamped to low and high
	*/
	func clamp( _ low: Self, _ high: Self ) -> Self {
		return max( low, min( self, high ))
	}
}
