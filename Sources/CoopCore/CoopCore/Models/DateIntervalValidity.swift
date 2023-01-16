//
//  DateIntervalValidity.swift
//  CoopCore
//
//  Created by Ihor Zabrotskyi on 02.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Used to express the validity of a date inteval.
public enum DateIntervalValidity {
	/// The date interval is valid compared to a reference date.
	case valid

	/// The date interval will be valid in the future compared to a reference date.
	case futureValid

	/// The date interval is not valid anymore.
	case invalid
}

/// Extension with method that calculates validity status for the `Date` based on the `startDate` and `endDate`
public extension Date {
	func validity( to startDate: Date?, endDate: Date? ) -> DateIntervalValidity {
		// Invalidate the campaign only if the date is in the future compared to the current Date.
		if let start = startDate, start > self {
			return .futureValid
		}
		// If we don't have a start date, or if we do have one but it's in the past compared to the current Date,
		// then the configuration is valid. Continue the evaluation for the endDate.

		// Invalidate the campaign only if the date is in the past compared to the current Date.
		if let end = endDate, end < self {
			return .invalid
		}
		// If we don't have an end date, of ir we do have one but it's in the future compare to the current Date.
		// then the configuration is valid. Return.

		// Configuration will be considered valid if it doesn't have have neither a startDate nor an endDate.
		return .valid
	}
}
