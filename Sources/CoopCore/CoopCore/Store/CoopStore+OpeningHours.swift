//
//  OpeningHours.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension CoopStore {
	
	/// Creates a UTC date that corresponds to calling `Date()` in the current application time zone.
	private var _nowDate: Date {
		return Date().addingTimeInterval( Double( TimeZone.current.secondsFromGMT() - TimeZone.fittedTimeZone.secondsFromGMT() ) )
	}

	/// `true` if the store is open right now.
	var isCurrentlyOpen: Bool {
		// The opening hours are in UTC dates from the Copenhagen timezone (so the string value is +1, but the current timezone is i.e. -3). So we must get the Copenhagen time and convert it to UTC before comparing the times
		let now = _nowDate
		return openingHours.contains { $0.fromDate < now && now < $0.toDate }
	}

	/// Returns the datetime for the next time the store opens.
	/// If no next open date is found, nil is returned.
	/// All the openHours entries are iterated and the first .fromDate that is in the future is returned.
	var nextOpenTime: Date? {
		// The opening hours are in UTC dates from the Copenhagen timezone (so the string value is +1, but the current timezone is i.e. -3). So we must get the Copenhagen time and convert it to UTC before comparing the times
		let now = _nowDate
		return openingHours.first { $0.fromDate > now }?.fromDate
	}

	/// Returns the datetime for the next time the store closes.
	/// If no next closing date is found, nil is returned.
	/// All the openHours entries are iterated and the first .toDate that is in the future is returned.
	var nextCloseTime: Date? {
		// The opening hours are in UTC dates from the Copenhagen timezone (so the string value is +1, but the current timezone is i.e. -3). So we must get the Copenhagen time and convert it to UTC before comparing the times
		let now = _nowDate
		return openingHours.first { now < $0.toDate }?.toDate
	}

	/// Representation of the store schedule for a single day.
	struct OpeningHours: Codable {
		/// Date from which the store can be considered opened.
		let fromDate: Date

		/// Date up to which the store can be considered opened.
		let toDate: Date

		/// Extra information about the schedule.
		public let text: String

		/// Day of the week that the schedule is for.
		public let day: String

		/**
		The default coding keys, used to decode objects from the older versions of the app and default encoding.
		*/
		private enum CodingKeys: String, CodingKey {
			case fromDate
			case toDate
			case text
			case day
		}

		/**
		The keys used by the server
		*/
		private enum JSONKeys: String, CodingKey {
			case fromDate = "FromDate"
			case toDate = "ToDate"
			case text = "Text"
			case day = "Day"
		}

		/// Convenience init. Will create a closed store.
		public init() {
			fromDate = Date()
			toDate = Date()
			text = "ukendt"
			day = "ukendt"
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: AnyKey.self)
			fromDate = try container.decode(keys: [CodingKeys.fromDate, JSONKeys.fromDate])
			toDate = try container.decode(keys: [CodingKeys.toDate, JSONKeys.toDate])
			text = try container.decode(keys: [CodingKeys.text, JSONKeys.text])
			day = try container.decode(keys: [CodingKeys.day, JSONKeys.day])
		}
	}
}
