//
//  DateFormatters.swift
//  CoopCore
//
//  Created by Jens Willy Johannsen on 10/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/**
Abstraction layer on top of `DateFormatter` instances, in order to enforce immutability
*/
public protocol ImmutableDateFormatter {
	func string( from date: Date ) -> String
	func date( from string: String ) -> Date?
}

extension DateFormatter: ImmutableDateFormatter {}

public extension Locale {
	
	/// Injected `locale` specific for each application.
	static var fittedLocale: Locale {
		let localeProvider: LocaleProvider = ServiceLocator.inject()
		return localeProvider.appLocale
	}
}

public extension TimeZone {
	
	/// UTC timezone
	static let utc = TimeZone( abbreviation: "UTC" )!
	
	/// Time zone set to "Europe/Copenhagen"
	static let copenhagen = TimeZone( identifier: "Europe/Copenhagen" )!		// Explicit unwrap would have failed the first time
	
	/// Injected `timeZone` specific for each application.
	static var fittedTimeZone: TimeZone {
		let localeProvider: LocaleProvider = ServiceLocator.inject()
		return localeProvider.timeZone
	}
}

public extension DateFormatter {
	/**
	UTC date formatter with milliseconds.
	*/
	static let utcFormatterWithMilliseconds: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		formatter.timeZone = .utc
		formatter.locale = Locale( identifier: "en_US_POSIX" )	// Enforce the format even if the user changes to AM/PM format
		return formatter
	}()
}

public extension Date {
	// Properties for retriving day, month and year
	var day: Int { return Calendar.current.component( .day, from: self ) }
	var month: Int { return Calendar.current.component( .month, from: self ) }
	var year: Int { return Calendar.current.component( .year, from: self ) }

	/**
	Get the date as a string relative to the current time.
	*/
	func relativeTimeString( dateFormatter: ImmutableDateFormatter = DateFormatter.timeFormatter(), todayFormat: String, yesterdayFormat: String ) -> String {
		// Get seconds ago
		let secondsAgo = -self.timeIntervalSinceNow

		// Less than 24 hours ago
		if secondsAgo > 0 && secondsAgo < 24 * 3600 {
			// Compare the day components to see if it was today
			let dayComponent = Calendar.current.component( .day, from: self )
			let dayComponentNow = Calendar.current.component( .day, from: Date() )

			// Was it today?
			if dayComponent == dayComponentNow {
				// Yes: Return string a string from today
				return String( format: todayFormat, dateFormatter.string( from: self ) )
			} else {
				// Must be yesterday
				return String( format: yesterdayFormat, dateFormatter.string( from: self ) )
			}
		}

		// One day ago
		if Int( secondsAgo / (24 * 3600) ) == 1	{ // If we didn't have this check we couldn't just check the day component, we'd also have to check month and year. The Int() typecast is necessary and will always round down so this will match times from 24 to 48 hours ago.
			// Compare the day components to see if it was yesterday
			let dayComponent = Calendar.current.component( .day, from: self )
			let dayComponentYesterday = Calendar.current.component( .day, from: Date().addingTimeInterval( -60*60*24 ))

			if dayComponent == dayComponentYesterday {
				return String( format: yesterdayFormat, dateFormatter.string( from: self ) )
			}
		}

		// Not today or yesterday
		return "\(DateFormatter.pastDateFormatter.string( from: self ))".stringWithCapitalizedFirstLetter()
	}

	// Returns the weekDay indication of a given date
	func weekDayIndex() -> Int {
		return Calendar.current.component( .weekday, from: self ) - 1
	}

	// Returns the stringValue for a weekDay (f.ex. Onsdag), localized via the Calendar's Locale
	func weekDayDescription() -> String {
		return DateFormatter().weekdaySymbols[ self.weekDayIndex() ]
	}

	/// The added time to the current date that computes the Date after which we should prompt the review.
	static let reviewRequestOffset: TimeInterval = 60*60*24

	/**
	Creates the Date after which we should prompt the review.
	*/
	static func createReviewDate() -> Date {
		return Date().addingTimeInterval( reviewRequestOffset )
	}
}

/// Cached rfc3339 formatters with milliseconds (indexed by their timezone)
private var rfc3339FormattersWithMilliseconds = [TimeZone: DateFormatter]()

/// Cached rfc3339 formatters with milliseconds and timezone offset (indexed by their timezone) 
private var rfc3339FormattersWithMillisecondsAndOffset = [TimeZone: DateFormatter]()

/// Cached rfc3339 formatters without milliseconds (indexed by their timezone)
private var rfc3339FormattersWithoutMilliseconds = [TimeZone: DateFormatter]()

/// Cached time formatters (indexed by their timezone)
private var timeFormatters = [TimeZone: DateFormatter]()

/// We lock on a dedicated object instead of directly locking the dictionaries due to a Swift optimization. We cannot lock an emtpy dictionary. Swift dictionaries are not initially allocated, instead a `_swiftEmptyDictionaryStorage` singleton is used.
/// Locking the `_swiftEmptyDictionaryStorage` singleton will cause a deadlock since we will never release the lock on the singleton once a real dictionary is created.
private let formattersLock = NSObject()

public extension DateFormatter {
	struct Constants {
		public static let paymentConfirmedDateSeparator = "-"
	}

	private static var fittedLocale: Locale {
		let localeProvider: LocaleProvider = ServiceLocator.inject()
		return localeProvider.appLocale
	}

	/**
	Get a date from a RFC3339 formatted string.  Formats with, without milliseconds and offset are accepted.

	- parameter fromRFC3339String:	The string to be converted to a date.
	- parameter timeZone:			The timezone of the given string date. **NOTE: UTC timezone is used by default**
	*/
	class func date( fromRFC3339String: String, timeZone: TimeZone = .utc ) -> Date? {
		return rfc3339FormatterWithoutMilliseconds( timeZone ).date( from: fromRFC3339String ) ?? rfc3339FormatterWithMilliseconds( timeZone ).date( from: fromRFC3339String ) ?? rfc3339FormatterWithMillisecondsAndOffset( timeZone ).date( from: fromRFC3339String )
	}

	/// Get a date from a UTC date format string. Both formats with or without milliseconds are accepted.
	///
	/// - Parameter utcString: The string to be converted to a date
	/// - Returns: A date, if the format of the string is valid, otherwise nil.
	class func date( fromUTCString utcString: String ) -> Date? {
		return DateFormatter.utcFormatterWithMilliseconds.date( from: utcString ) ?? DateFormatter.utcFormatterWithoutMilliseconds.date( from: utcString )
	}

	/**
	Date formatter showing only the day and shtortened month name in the format "dd. MMM."
	*/
	static let dayMonthFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.dateFormat = "dd. MMM"
		return formatter
	}()

	/**
	Date formatter showing only the day and shtortened month name in the format "d. MMM."
	*/
	static let singleDayMonthFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .fittedTimeZone
		formatter.dateFormat = "d. MMM"
		return formatter
	}()

	/**
	Date formatter showing the day and full month name in the format "dd. MMMM.".

	This formatter uses the "Europe/Paris" timezone. Currently this is only used for `StampsCampaign` start and end dates which are parsed using the `UTC` timezone.
	*/
	static let dayAndFullMonthFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .fittedTimeZone
		formatter.dateFormat = "d. MMMM"
		return formatter
	}()

	/**
	Date formatter for showing only the time part of a Date

	- parameters:
	- timezone: The time zone to for the formatter. If you pass nil here, the time zone will default to the current local time zone

	When we parse a date from the API with a certaom timezone, we should use the same timezone to output the date.
	This will mean that 'nothing is lost in translation'. However, this means that the date will be shown in the local time where the date is valid, meaning that if we get a store opening date, the output of this formatters `string(from:)` method will be in that store's local time, **not** the user's.
	*/
	static func timeFormatter( timezone: TimeZone? = nil ) -> ImmutableDateFormatter {
		// Synchronize to avoid race conditions on the cached date formatters dictionary
		objc_sync_enter( formattersLock )

		// Check if we have a cached formatter for specified timezone (if a formatter is created without a timezone, its timezone is the `.current`)
		if let cachedFormatter = timeFormatters[ timezone ?? .current ] {
			// Release the lock
			objc_sync_exit( formattersLock )

			return cachedFormatter
		}

		// Otherwise create it
		let formatter = DateFormatter()
		formatter.dateFormat = "HH.mm"
		if let timeZone = timezone {
			formatter.timeZone = timeZone
		}

		// Cache it
		timeFormatters[ timezone ?? .current ] = formatter

		// Release the lock
		objc_sync_exit( formattersLock )

		return formatter
	}

	/**
	Date formatter with the RFC-3339 format and no milliseconds.
	*/
	class func rfc3339FormatterWithoutMilliseconds( _ timeZone: TimeZone ) -> ImmutableDateFormatter {
		// Synchronize to avoid race conditions on the cached date formatters dictionary
		objc_sync_enter( formattersLock )

		// Check if we have a cached formatter for specified timezone
		if let cachedFormatter = rfc3339FormattersWithoutMilliseconds[ timeZone ] {
			// Release the lock
			objc_sync_exit( formattersLock )
			return cachedFormatter
		}

		// Otherwise create it
		let formatter = DateFormatter()
		formatter.timeZone = timeZone

		// We set explicitly the locale since otherwise the date format will be overriden if the user changes to AM/PM format.
		formatter.locale = Locale( identifier: "en_US_POSIX" )
		formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"

		// Cache it
		rfc3339FormattersWithoutMilliseconds[ timeZone ] = formatter

		// Release the lock
		objc_sync_exit( formattersLock )

		return formatter
	}

	/**
	RFC-3339 date formatter with fraction of seconds.
	*/
	class func rfc3339FormatterWithMilliseconds( _ timeZone: TimeZone ) -> ImmutableDateFormatter {
		// Synchronize to avoid race conditions on the cached date formatters dictionary
		objc_sync_enter( formattersLock )

		// Check if we have a cached formatter for specified timezone
		if let cachedFormatter = rfc3339FormattersWithMilliseconds[ timeZone ] {
			// Release the lock
			objc_sync_exit( formattersLock )

			return cachedFormatter
		}

		// Otherwise create it
		let formatter = DateFormatter()
		formatter.timeZone = timeZone

		// We set explicitly the locale since otherwise the date format will be overriden if the user changes to AM/PM format.
		formatter.locale = Locale( identifier: "en_US_POSIX" )
		formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.S"

		// Cache it
		rfc3339FormattersWithMilliseconds[ timeZone ] = formatter

		// Release the lock
		objc_sync_exit( formattersLock )

		return formatter
	}

	/**
	RFC-3339 date formatter with fraction of seconds and timezone offset.
	*/
	class func rfc3339FormatterWithMillisecondsAndOffset( _ timeZone: TimeZone ) -> ImmutableDateFormatter {
		// Synchronize to avoid race conditions on the cached date formatters dictionary
		objc_sync_enter( formattersLock )

		// Check if we have a cached formatter for specified timezone
		if let cachedFormatter = rfc3339FormattersWithMillisecondsAndOffset[ timeZone ] {
			// Release the lock
			objc_sync_exit( formattersLock )

			return cachedFormatter
		}

		// Otherwise create it
		let formatter = DateFormatter()
		formatter.timeZone = timeZone

		// We set explicitly the locale since otherwise the date format will be overriden if the user changes to AM/PM format.
		formatter.locale = Locale( identifier: "en_US_POSIX" )
		formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SZ"

		// Cache it
		rfc3339FormattersWithMillisecondsAndOffset[ timeZone ] = formatter

		// Release the lock
		objc_sync_exit( formattersLock )

		return formatter
	}

	/**
	Date formatter configured according to the ISO-8601 format with miliseconds and a time zone indication: "yyyy-MM-dd'T'HH:mm:ss.SZZZZZ". Date example "2018-11-30T12:44:23.6005469+01:00".
	*/
	static let iso8601FormatterWithMilliseconds: ImmutableDateFormatter = {
		// TODO: We should start using the `ISO8601DateFormatter` once we drop support for iOS 9 -GKD
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZZZZZ"
		formatter.locale = Locale( identifier: "en_US_POSIX" )	// Enforce the format even if the user changes to AM/PM format
		return formatter
	}()

	/**
	UTC date formatter without milliseconds.
	*/
	static let utcFormatterWithoutMilliseconds: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		formatter.timeZone = .utc
		formatter.locale = Locale( identifier: "en_US_POSIX" )	// Enforce the format even if the user changes to AM/PM format
		return formatter
	}()

	/**
	Date formatter for showing a date in the past.
	*/
	static let pastDateFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .fittedTimeZone
		formatter.dateFormat = CoreLocalizedString( "dt_past_date" )
		return formatter
	}()

	/**
	Date formatter for birth dates.

	This formatter uses the `UTC` timezone and is currently used for `MemberModel` (Profile), Credit, and NewsFeed, which uses `UTC` timezone when parsing dates.
	*/
	static let birthDateFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .utc
		formatter.dateFormat = "d. MMMM yyyy "
		return formatter
	}()

	/**
	Date formatter for Prime feature.

	This formatter uses the `UTC` timezone and is currently used for `PrimeSubscription`.
	*/
	static let primeNextProcessingDateFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .utc
		formatter.dateFormat = "d. MMM yyyy "
		return formatter
	}()

	/**
	Year, month, day formatter.
	*/
	static let yearMonthDayFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()

	/**
	Date formatter for showing timestamps in a user friendly format.

	This formatter uses the injected timezone. Currently this is only used for `BonusTransactionItem` and `ReceiptItem`.
	*/
	static let timeStampDateFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .fittedTimeZone
		formatter.dateFormat = "d. MMMM yyyy HH:mm"
		return formatter
	}()

	/**
	Formatter for short numberical month year formats e.g.: "8/16".
	Used for `CreditCard` expiry dates.
	*/
	static let shorthandMonthAndYearDateFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale( identifier: "en_US_POSIX" )
		formatter.timeZone = .utc
		formatter.dateFormat = "M/yy"
		return formatter
	}()

	/**
	Date formatter used to extract information about the date used in showing the QR code in SelfScanningPaymentConfirmedViewController
	*/
	class func paymentConfirmationQRCodeDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "HHmmddMMyy"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "Europe/Paris")
		return formatter
	}

	/**
	Date formatter for showing timestamps in a user friendly format, without seconds and with localized string
	*/
	static let RFC3339LocalizedFormatterWithoutSeconds: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.dateFormat = CoreLocalizedString( "dt_timestamp_date" )
		return formatter
	}()

	/**
	Date formatter for showing timestamps with abbreviated month in a user friendly format.

	This formatter uses the `Europe/Copenhagen` timezone for the Danish version and "America/Godhab" for the Greenlandic one. Currently this is only used for BonusTransactions which are parsed base on the app variant.
	*/
	static let timeStampDateFormatterAbbreviatedMonth: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .fittedTimeZone
		formatter.dateFormat = "d. MMM yyyy HH:mm"
		return formatter
	}()

	/**
	Date formatter for parsing item.modifiedDate for shoppingListAPI
	*/
	static let modifiedDateFormatterWithMilliseconds: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
		formatter.locale = Locale( identifier: "en_US_POSIX" )	// Enforce the format even if the user changes to AM/PM format
		formatter.timeZone = .utc
		return formatter
	}()

	/**
	Formatter for short month year formats e.g.: "Aug. 2016"
	*/
	static let shortMonthYearFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.dateFormat = "MMM yyyy"
		return formatter
	}()

	/**
	Formatter for full month and year format in Danish/Greenlandic. e.g.: "August 2018".
	*/
	static let fullMonthYearFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.dateFormat = "LLLL yyyy"
		return formatter
	}()

	/**
	Formatter for day, full month and year formats, e.g. 31. maj 2022.
	*/
	static let dayFullMonthYearFormatter: ImmutableDateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .fittedLocale
		formatter.timeZone = .utc
		formatter.dateFormat = "d. MMMM yyyy"
		return formatter
	}()

	/**
	Date strings with short month year format e.g.: "Aug. 16"

	- parameter month:	Month number 1-12
	- parameter year:	Year e.g. 2016
	- returns:			Short month year format
	*/
	class func monthYearFormat( month: Int, year: Int ) -> String {
		var result = ""
		var comps = DateComponents()
		comps.month = month
		comps.year = year
		if let date = Calendar.current.date( from: comps ) {
			result = shortMonthYearFormatter.string( from: date ).stringWithCapitalizedFirstLetter()
		}
		return result
	}
}

public extension JSONDecoder {
	
	/// Creates new `JSONDecoder` and tries to set date formatter as date decoding strategy.
	static func make(with dateFormatter: ImmutableDateFormatter?) -> JSONDecoder {
		let decoder = JSONDecoder()
		try? dateFormatter.map(decoder.setDateDecodeStrategy)
		return decoder
	}
	
	/// Tries to set `ImmutableDateFormatter` as date decoding strategy.
	func setDateDecodeStrategy(_ dateFormatter: ImmutableDateFormatter) throws {
		struct UnsupportedImmutableDateFormatterError: Error {}
		
		// Casting here is neccessary, since `.formatted` requires a DateFormatter - this is safe as well, since `decoder` will not modify the date formatter.
		guard let dateFormatter = dateFormatter as? DateFormatter else {
			throw UnsupportedImmutableDateFormatterError()
		}
		
		dateDecodingStrategy = .formatted(dateFormatter)
	}
	
}
