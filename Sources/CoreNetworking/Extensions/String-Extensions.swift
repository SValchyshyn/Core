//
//  NSDate-Extensions.swift
//  CoopM16
//
//  Created by Jens Willy Johannsen on 28/04/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Log

public extension NumberFormatter {
	struct Constants {
		public static let numberOfFractionDigits = 2
	}
}

public extension String {
	/// Static number formatter used for prices
	static var priceStringFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.decimalSeparator = ","
		formatter.groupingSeparator = "."
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = NumberFormatter.Constants.numberOfFractionDigits
		formatter.maximumFractionDigits = NumberFormatter.Constants.numberOfFractionDigits
		return formatter
	}()

	/// Static number formatter used for prices without decimals
	static var wholePriceStringFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.decimalSeparator = ","
		formatter.groupingSeparator = "."
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0
		return formatter
	}()

	/// Static number formatter that hides trailing zeroes
	static var priceWithoutTrailingZeroesFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.decimalSeparator = ","
		formatter.groupingSeparator = "."
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = NumberFormatter.Constants.numberOfFractionDigits
		return formatter
	}()

	/// Static number formatter used for price formatting in tracking
	static var analyticsPriceStringFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		return formatter
	}()

	/**
	Check if the string matches the given regular expression pattern.

	- parameter regExPattern:	The pattern used for evaluation.
	*/
	func matchesRegularExpression( _ regExPattern: String ) -> Bool {
		do {
			// Create a regular expression with the given pattern.
			let regex = try NSRegularExpression( pattern: regExPattern, options: .caseInsensitive )

			// Get the matches for the given pattern
			let matches = regex.matches( in: self, options: [], range: NSRange( location: 0, length: self.count ))

			// Make sure we have exactly one match
			return matches.count == 1
		} catch {
			Log.technical.log(.error, "Error while creating regular expression with pattern: \(regExPattern)", [.identifier("CoopCore.String.matchesRegularExpression")])
			return false
		}
	}

	/**
	Capitalize first letter of string.

	- returns:	String with capitalized first letter
	*/
	func stringWithCapitalizedFirstLetter() -> String {
		let first = self.prefix(1).uppercased()
		let rest = self.dropFirst()
		return first + rest
	}

	/**
	Remove abbreviation dot from end of string if it exists. If the string doesn't end with a dot, the original string is returned

	- returns:	String without the abbreviation dot at the end of the string.
	*/
	func stringWithoutAbbreviationDot() -> String {
		let last = self.suffix(1)
		if last == "." {
			return String(self.dropLast())
		} else {
			return self
		}
	}

	/**
	Removes the HTML from a string by rendering it into an `NSAttributedString`

	- returns: String without HTML tags
	*/
	func stringWithoutHTML() -> String? {
		do {
			// Convert the string to NSData
			if let data = self.data( using: String.Encoding.unicode, allowLossyConversion: true ) {
				// Convert the text to attributed string to remove all HTML tags
				let attributedString = try NSMutableAttributedString( data: data, options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html ], documentAttributes: nil )

				// Return only the string from the attributed string
				return attributedString.string
			}
		} catch {
			// Log the error and return `nil`
			Log.technical.log(.error, "\(error)", [.identifier("CoopCore.String.stringWithoutHTML")])
		}

		// Fall-through
		return nil
	}

	/**
	Convert a semantic version string to an indexpath.
	String must be in semantic version format e.g. "1.0.2" or "1.2"

	- returns: An IndexPath representation of the string
	*/
	func indexPathFromVersionString() -> IndexPath {
		let components = self.components( separatedBy: "." )
		let indexes = components.map { Int( $0 ) ?? 0 }
		return IndexPath( indexes: indexes )
	}

	/*
	Obfuscated card number with first and last four digits being visible.

	- returns:	Obfuscated card number showing the first four digits + '-xxxx-xxxx-' + the last four digits
	*/
	func asObfuscatedCardNumberString() -> String {
		var firstFourDigits = ""
		var lastFourDigits = ""

		if self.count >= 4 {
			let lastFourDigitsIndex = self.index( self.endIndex, offsetBy: -4 )
			let firstFourDigitsIndex = self.index( self.startIndex, offsetBy: 4 )
			lastFourDigits = String( self[ lastFourDigitsIndex...] )
			firstFourDigits = String( self[..<firstFourDigitsIndex] )
		}

		return firstFourDigits + "-XXXX-XXXX-" + lastFourDigits
	}

	// Inserts [separator] for every [n] character in a string fx. "ABC".inserting( " ", 1 ) = "A B C"
	func inserting( separator: String, every step: Int ) -> String {
		var result: String = ""
		let characters = Array( self )
		stride( from: 0, to: characters.count, by: step ).forEach {
			result += String( characters[ $0..<min($0+step, characters.count) ])
			if $0+step < characters.count {
				result += separator
			}
		}
		return result
	}

	/*
	Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
	- Parameter length: Desired maximum lengths of a string
	- Parameter trailing: A 'String' that will be appended after the truncation.

	- Returns: 'String' object.
	*/
	func truncate( toLength: Int, withTrailing: String = "…" ) -> String {
		return ( self.count > toLength ) ? self.prefix( toLength ) + withTrailing : self
	}

	/**
	Returns an array of indices [Int] in self of the occurence provided

	- parameter occurrence: 	The occurence for which we want the indices
	*/
	func indices( of occurrence: String ) -> [ Int ] {
		var indices = [ Int ]()
		var position = startIndex
		while let range = range( of: occurrence, range: position ..< endIndex ) {
			let i = distance( from: startIndex, to: range.lowerBound )
			indices.append( i )
			let offset = occurrence.distance( from: occurrence.startIndex, to: occurrence.endIndex ) - 1
			guard let after = index( range.lowerBound, offsetBy: offset, limitedBy: endIndex ) else {
				break
			}
			position = index( after: after )
		}
		return indices
	}

	/**
	Returns an array of Range's for the searchString found in self

	- parameter searchString:	The sub-string for which we want the ranges
	*/
	func ranges( of searchString: String ) -> [ Range<String.Index> ] {
		let indicesInString = self.indices( of: searchString )
		return indicesInString.map({ index( startIndex, offsetBy: $0 ) ..< index( startIndex, offsetBy: $0 + searchString.count ) })
	}

	/**
	Attempts to convert string into a JSON dictionary
	*/
	func convertToJSONDictionary() -> [ String: AnyObject ]? {
		guard let data = self.data( using: .utf8, allowLossyConversion: false ) else { return nil }
		return try? JSONSerialization.jsonObject( with: data, options: .mutableContainers ) as? [ String: AnyObject ]
	}

	/**
	Replace the last occurrance of a string with another string.

	- parameter searchString: 		The string we want to replace
	- parameter replacementString: 	The string we are repalcing with
	*/
	func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String ) -> String {
		let options = String.CompareOptions.backwards

		// Find the range of the last occurrance of the given string
		if let range = self.range( of: searchString, options: options, range: nil, locale: nil) {
			// Replace the string at that range
			return self.replacingCharacters( in: range, with: replacementString )
		}

		return self
	}
	
	/// Returns a String without leading and trailing white spaces and new lines.
	var trimmed: String {
		return trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	/// Extension. Returns the trimmed version of this string if it is not empty.
	var nonBlankOrNil: String? {
		if trimmed.isEmpty {
			return nil
		} else {
			return trimmed
		}
	}
	
	/// Extension. Returns the trimmed non-empty version of this string if it is longer than minLength.
	func nonBlankOrNil( minLength: Int ) -> String? {
		if let value = nonBlankOrNil {
			if value.count < minLength {
				return nil
			} else {
				return value
			}
		} else {
			return nil
		}
	}
	
	func isEmpty() -> Bool {
		return ( self.trimmingCharacters(in: .whitespacesAndNewlines) == "" )
	}
}

public extension Optional where Wrapped == String {
	/// `true` if the wrapped`String` is either `nil` or `isEmpty == true`.
	var isNilOrEmpty: Bool {
		return self?.isEmpty ?? true
	}
}

/// Utility extension to extract submatches from regex searches.
public extension String {
	enum MatchError: Error {
		case invalidIndex
	}

	/**
	Return the specificed submatch in the `NSTextCheckingResult` from a regex or similar.

	- parameter match: The `NSTextCheckingResult` to extract match from
	- returns: The string at the specified index
	- throws: A `MatchError.invalidIndex` if index is out of bounds
	*/
	func submatch( in match: NSTextCheckingResult, index: Int ) throws -> String {
		if match.numberOfRanges <= index {
			throw MatchError.invalidIndex
		}

		return (self as NSString).substring( with: NSRange( location: match.range( at: index ).location, length: match.range( at: index ).length ))
	}

	/**
	If possible returns the string between the two provided substrings

	- parameter fromString: The substring before the string we want to extract
	- parameter toString:	The substring after the string we want to extract
	*/
	func slice( fromString: String, toString: String ) -> String? {
		return ( range( of: fromString )?.upperBound ).flatMap { substringFrom in
			( range( of: toString, range: substringFrom..<endIndex )?.lowerBound ).map { substringTo in
				String( self[ substringFrom..<substringTo ] )
			}
		}
	}
}
