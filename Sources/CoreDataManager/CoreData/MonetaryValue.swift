//
//  MonetaryValue.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 22/05/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Core

@objc public final class MonetaryValue: NSObject, Codable {
	private enum CodingKeys: String, CodingKey {
		case value
		case text
		case rawSuffix = "suffix"
	}

	/// Actual value .
	public let value: Double?

	/// Short description of what the monetary value represents.
	public let text: String?

	/// Raw representation of the Suffic.
	private let rawSuffix: String?

	/// Determines whether the value is represented in absolute value or percentage.
	public var suffix: Suffix {
		return Suffix( rawValue: rawSuffix ?? "" ) ?? .unknown
	}

	// MARK: - Memberwise init.

	public init( value: Double?, text: String? = nil, rawSuffix: String? = nil ) {
		self.value = value
		self.text = text
		self.rawSuffix = rawSuffix
	}
}
