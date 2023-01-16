//
//  Store+Location.swift
//  Stores
//
//  Created by Coruț Fabrizio on 18.05.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public extension Store {

	/// Human readable information about where the `Store` is located.
	struct Location {

		// MARK: - Properties.

		public let country: String?
		public let city: String?
		public let street: String?
		public let streetNumber: String?
		public let postalCode: String?
		public let coordinates: Coordinates?

		// MARK: - Init.

		public init(
			country: String?,
			city: String?,
			street: String?,
			streetNumber: String?,
			postalCode: String?,
			coordinates: Coordinates?
		) {
			self.country = country
			self.city = city
			self.street = street
			self.streetNumber = streetNumber
			self.postalCode = postalCode
			self.coordinates = coordinates
		}
	}
}
