//
//  Store+OpeningHours.swift
//  Stores
//
//  Created by Coruț Fabrizio on 18.05.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public extension Store {

	/// Representation of the store schedule for a single day.
	struct OpeningHours {

		// MARK: - Properties.

		/// Date from which the store can be considered opened.
		public let fromDate: Date

		/// Date up to which the store can be considered opened.
		public let toDate: Date

		/// Extra information about the schedule.
		public let text: String

		/// Day of the week that the schedule is for.
		public let day: String

		// MARK: - Init.

		public init( fromDate: Date, toDate: Date, text: String, day: String ) {
			self.fromDate = fromDate
			self.toDate = toDate
			self.text = text
			self.day = day
		}

		/// Convenience init. Will represent a `closed Store`.
		public init() {
			fromDate = Date()
			toDate = Date()
			text = ""
			day = ""
		}
	}
}
