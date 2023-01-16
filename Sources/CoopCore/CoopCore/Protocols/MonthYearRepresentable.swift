//
//  MonthYearRepresentable.swift
//  CoopM16
//
//  Created by Coruț Fabrizio on 22/04/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public protocol MonthYearRepresentable: Comparable {
	var year: Int { get }
	var month: Int { get }
}

private let monthsInAYear: Int = 12
extension MonthYearRepresentable {
	/// Total number of months found in the `date` determined by `year` and `month`.
	/// e.g. `year = 2; month = 1` -> `monthlyRepresentation = year * 12 + month = 2 * 12 + 1 = 25`
	public var monthlyRepresentation: Int {
		return year * monthsInAYear + month
	}
	
	typealias MonthYearPlainRepresentation = (year: Int, month: Int)
	
	/// Reverse process of `.monthlyRepresentation`.
	static func from( monthlyRepresentation: Int ) -> MonthYearPlainRepresentation {
		var year = monthlyRepresentation / monthsInAYear
		var month = monthlyRepresentation % monthsInAYear
		
		// For the case in which monthlyRepresentation represents the 12th month, the % result will be 0 and the
		// division result will 1 more than it should have. e.g.
		// year 2, month 12 => monthRepresentation = 2 * 12 + 12 = 36.
		// year = 36 / 12 = 3 ; month = 36 % 12 = 0, which is not correct.
		if month == 0 {
			// Correct the values.
			year -= 1
			month = monthsInAYear
		}
		
		return (year, month)
	}
	
	/// Default implementation using `monthlyRepresentation`.
	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.monthlyRepresentation < rhs.monthlyRepresentation
	}
}

extension Array where Element: MonthYearRepresentable {
	/**
	Creates a new array by introducing new `MonthYearRepresentables` in the `date gaps`.
	The current array will be `sorted` in ascending calendaristic order.
	`Date gap` will be determined by two adjacent elements in the sorted array which are not
	adjacent in the calendar as well.
	e.g. `Date gap` will be created by: `[(year = 1; month = 8),(year: 1; month = 11)]`.
	
	e.g.
	
	1. `year = 1; month = 12` should be followed by `year = 2; month = 1`
	
	2. `year = 1; month = 11` should be followed by `year = 1; month = 12`
	
	3. If `self = [(year = 1; month = 8),(year: 1; month = 11)]` the method should be returning:
	`[(year = 1; month = 8), (year = 1; month = 9), (year = 1; month = 10), (year: 1; month = 11)]`
	
	4. If `self = [(year = 1; month = 11), (year = 2; month = 2)]` the method should be returning:
	`[(year = 1; month = 11), (year = 1; month = 12), (year = 2; month = 1), (year: 2; month = 2)]`
	
	- parameter initializer:		A block used to initialize the items that the gaps will be filled with. Provides the missing `year` and `month` from array.
	- returns:						`Sorted` and contiguous array, looking from a `MonthYearRepresentable` standpoint.
	*/
	public func byFillingDateGaps( initializer: (_ year: Int, _ month: Int) -> Element ) -> Self {
		// Sort the array so we can perform the filling.
		let sortedSelf = sorted( by: < )
		
		// Make sure we have at least 2 elements.
		guard count > 1, let firstElement = sortedSelf.first, let lastElement = sortedSelf.last else { return sortedSelf }
		
		// Represent the first date (the farthest into the past) and the last date (the farthest into the future/ closest to the present) as number of months.
		let firstElementhMonthlyRepresentation: Int = firstElement.monthlyRepresentation
		let lastElementMonthlyRepresentation: Int = lastElement.monthlyRepresentation
		
		// Determine how many months we have between the first and the last elements. The interval must be inclusive, so we're adding 1.
		let monthsSpan: Int = lastElementMonthlyRepresentation - firstElementhMonthlyRepresentation + 1
		
		// We are going to build the complete array and use the firstElementhMonthlyRepresentation as a normalization factor
		// because the first element will occupy the first position.
		// To determine the continuity of the items, we will make sure that their normalized
		// monthly representation will be also continuous. If it's not, then we have a gap which we have to fill.
		var completeArray: [Element] = []
		completeArray.reserveCapacity( monthsSpan )
		
		// Keep the currentOffset so we can determine when we have missing MonthItems.
		// Start at -1 so the expectedOffset, for the first value, will be 0.
		var currentOffset: Int = -1
		
		// Iterate through the available items.
		for item in sortedSelf {
			let currentItemMonthlyRepresentation: Int = item.monthlyRepresentation
			
			// Normalize the current item's monthly representation so we'll know what place
			// this item should occupy in the complete array.
			let newOffset: Int = currentItemMonthlyRepresentation - firstElementhMonthlyRepresentation
			
			// Since we want the array to be contiguous, the expected offset is the old one + 1.
			let expectedOffset = currentOffset + 1
			
			if newOffset != expectedOffset {
				// The offsets do not match, this means that we have a gap between the currentOffset and newOffset
				// We must fill this gap with empty MonthItems.
				for missingOffset in expectedOffset..<newOffset {
					// De-normalize the offset by adding firstDateRepresentedInMonths so we can compute the years and months.
					let missingItemMonthlyRepresentation: Int = missingOffset + firstElementhMonthlyRepresentation
					
					// Element is of type MonthYearRepresentable but we cannot use the from(monthlyRepresentation:) on it, so that's why we're using Element instead.
					// We need to do the reversed process of `monthlyRepresentation
					let monthYearRepresentation = Element.from( monthlyRepresentation: missingItemMonthlyRepresentation )
					
					// Add the new MonthItem.
					completeArray.append( initializer( monthYearRepresentation.year, monthYearRepresentation.month ) )
				}
			}
			
			// Insert the item in the buffer at its offset.
			completeArray.append( item )
			
			// Update the offset value.
			currentOffset = newOffset
		}
		
		return completeArray
	}
}
